# 源码：LineRecordReader

```java
package org.apache.hadoop.mapreduce.lib.input;

import java.io.IOException;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.Seekable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.compress.CodecPool;
import org.apache.hadoop.io.compress.CompressionCodec;
import org.apache.hadoop.io.compress.SplitCompressionInputStream;
import org.apache.hadoop.io.compress.SplittableCompressionCodec;
import org.apache.hadoop.io.compress.CompressionCodecFactory;
import org.apache.hadoop.io.compress.Decompressor;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.logging.Log;

/**
 * Treats keys as offset in file and value as line. 
 * 偏移量作key，行作value
 */
@InterfaceAudience.LimitedPrivate({"MapReduce", "Pig"})
@InterfaceStability.Evolving

public class LineRecordReader extends RecordReader<LongWritable, Text> {
  private static final Log LOG = LogFactory.getLog(LineRecordReader.class);
  public static final String MAX_LINE_LENGTH =   // 行的最大长度
    "mapreduce.input.linerecordreader.line.maxlength";

  private long start;
  private long pos;
  private long end;
  private SplitLineReader in;
  private FSDataInputStream fileIn;
  private Seekable filePosition;
  private int maxLineLength;
  private LongWritable key;
  private Text value;
  private boolean isCompressedInput;
  private Decompressor decompressor;
  private byte[] recordDelimiterBytes;  // 记录分隔符

  public LineRecordReader() {
  }

  public LineRecordReader(byte[] recordDelimiter) {
    this.recordDelimiterBytes = recordDelimiter;
  }

  // 对分片所在的文件的操作
  public void initialize(InputSplit genericSplit,
                         TaskAttemptContext context) throws IOException {
    FileSplit split = (FileSplit) genericSplit;
    Configuration job = context.getConfiguration();
    this.maxLineLength = job.getInt(MAX_LINE_LENGTH, Integer.MAX_VALUE);
    start = split.getStart();  // 起始位置
    end = start + split.getLength();   // 结束位置
    final Path file = split.getPath();  // 包含分片数据的文件的路径

    // open the file and seek to the start of the split
    final FileSystem fs = file.getFileSystem(job);
    fileIn = fs.open(file);  
    
	// codec 算法
    CompressionCodec codec = new CompressionCodecFactory(job).getCodec(file);
    if (null!=codec) {  // 文件是压缩了的
      isCompressedInput = true;	
	  
	  // 从池中取相应的解压缩器
      decompressor = CodecPool.getDecompressor(codec);
	  
	  // codec 算法 支持切分(能在任意位置开始读数据)
      if (codec instanceof SplittableCompressionCodec) {
	  
	    // 压缩输入流
        final SplitCompressionInputStream cIn =
          ((SplittableCompressionCodec)codec).createInputStream(
            fileIn, decompressor, start, end,
            SplittableCompressionCodec.READ_MODE.BYBLOCK);
		
		// CompressedSplitLineReader：
		// 		Line reader for compressed splits 
        in = new CompressedSplitLineReader(cIn, job,
            this.recordDelimiterBytes);
        start = cIn.getAdjustedStart();
        end = cIn.getAdjustedEnd();
        filePosition = cIn;
      } else {  // 不支持切分
        in = new SplitLineReader(codec.createInputStream(fileIn,
            decompressor), job, this.recordDelimiterBytes);
        filePosition = fileIn;
      }
    } else {  // 文件是未压缩了的
      fileIn.seek(start);
	  
	  // This class can split the file correctly 
	  // even if the delimiter is multi-bytes.
	  // 可以正确的划分未压缩的文件
      in = new UncompressedSplitLineReader(
          fileIn, job, this.recordDelimiterBytes, split.getLength());
      filePosition = fileIn;
    }
    // If this is not the first split, we always throw away first record
    // because we always (except the last split) read one extra line in
    // next() method.
	// 若不是第一个split，总会扔掉第一条记录。因为我们总会
	// 使用next()方法读取额外的一行（除了最后一个split）
    if (start != 0) {
      start += in.readLine(new Text(), 0, maxBytesToConsume(start));
    }
    this.pos = start;
  }
  // readLine：从输入流中读取一行，返回读取的字节数量
 

  // 允许消耗的最大的字节数
  private int maxBytesToConsume(long pos) {
    return isCompressedInput
      ? Integer.MAX_VALUE  // 压缩的
	  // 未压缩的
      : (int) Math.max(Math.min(Integer.MAX_VALUE, end - pos), maxLineLength);
  }

  private long getFilePosition() throws IOException {
    long retVal;
    if (isCompressedInput && null != filePosition) {
      retVal = filePosition.getPos();
    } else {
      retVal = pos;    // 未压缩的
    }
    return retVal;
  }

  private int skipUtfByteOrderMark() throws IOException {
    // Strip BOM(Byte Order Mark)
    // Text only support UTF-8, we only need to check UTF-8 BOM
    // (0xEF,0xBB,0xBF) at the start of the text stream.
    int newMaxLineLength = (int) Math.min(3L + (long) maxLineLength,
        Integer.MAX_VALUE);
    int newSize = in.readLine(value, newMaxLineLength, maxBytesToConsume(pos));
    // Even we read 3 extra bytes for the first line,
    // we won't alter existing behavior (no backwards incompat issue).
    // Because the newSize is less than maxLineLength and
    // the number of bytes copied to Text is always no more than newSize.
    // If the return size from readLine is not less than maxLineLength,
    // we will discard the current line and read the next line.
    pos += newSize;
    int textLength = value.getLength();
    byte[] textBytes = value.getBytes();
    if ((textLength >= 3) && (textBytes[0] == (byte)0xEF) &&
        (textBytes[1] == (byte)0xBB) && (textBytes[2] == (byte)0xBF)) {
      // find UTF-8 BOM, strip it.
      LOG.info("Found UTF-8 BOM and skipped it");
      textLength -= 3;
      newSize -= 3;
      if (textLength > 0) {
        // It may work to use the same buffer and not do the copyBytes
        textBytes = value.copyBytes();
        value.set(textBytes, 3, textLength);
      } else {
        value.clear();
      }
    }
    return newSize;
  }

  public boolean nextKeyValue() throws IOException {
    if (key == null) {
      key = new LongWritable();
    }
    key.set(pos);  // 为null，则新建一个，并赋值
    if (value == null) {
      value = new Text();   // 为null，则新建一个
    }  
    int newSize = 0;
    // We always read one extra line, which lies outside the upper
    // split limit i.e. (end - 1) 
	// needAdditionalRecordAfterSplit：要不要额外的那行，返回false
    while (getFilePosition() <= end || in.needAdditionalRecordAfterSplit()) {
      if (pos == 0) {  // 处在起始位置
        newSize = skipUtfByteOrderMark();
      } else {
	  // 返回读取的字节数量，包括换行符（最长的）
        newSize = in.readLine(value, maxLineLength, maxBytesToConsume(pos));
        pos += newSize;  // 移动位置指针
      }

      if ((newSize == 0) || (newSize < maxLineLength)) {
        break;   // 没有读到新行就退出循环
      }

      // line too long. try again 行太长，pos - newSize 后再读
      LOG.info("Skipped line of size " + newSize + " at pos " + 
               (pos - newSize));
    }
    if (newSize == 0) {
      key = null;
      value = null;
      return false;
    } else {
      return true;
    }
  }

  @Override
  public LongWritable getCurrentKey() {  // 获取当前key
    return key;
  }

  @Override
  public Text getCurrentValue() {  // 获取当前value
    return value;
  }

  /**
   * Get the progress within the split  获取当前读取进程
   */
  public float getProgress() throws IOException {
    if (start == end) {
      return 0.0f;  // 读完了
    } else {
	// 当前位置减去初始位置 和总长度的比值
      return Math.min(1.0f, (getFilePosition() - start) / (float)(end - start));
    }
  }
  
  public synchronized void close() throws IOException {
    try {
      if (in != null) {
        in.close();
      }
    } finally {
      if (decompressor != null) {
        CodecPool.returnDecompressor(decompressor);
        decompressor = null;
      }
    }
  }
}
```
