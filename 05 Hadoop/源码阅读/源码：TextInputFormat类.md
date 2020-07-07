# 源码：TextInputFormat类

```java
package org.apache.hadoop.mapreduce.lib.input;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.compress.CompressionCodec;
import org.apache.hadoop.io.compress.CompressionCodecFactory;
import org.apache.hadoop.io.compress.SplittableCompressionCodec;
import org.apache.hadoop.mapreduce.InputFormat;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.JobContext;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.TaskAttemptContext;

import com.google.common.base.Charsets;

/** An {@link InputFormat} for plain text files.  Files are broken into lines.
 * Either linefeed or carriage-return are used to signal end of line.  Keys are
 * the position in the file, and values are the line of text.. */
/** 面向纯文本的InputFormat。文件被划分成多行。
* 换行键或回车键来标记一行的结尾。
* Keys 是行在文件的位置，Values是文本的一行。
*/ 
//父类为FileInputFormat、InputFormat
@InterfaceAudience.Public
@InterfaceStability.Stable
public class TextInputFormat extends FileInputFormat<LongWritable, Text> {

  @Override
  public RecordReader<LongWritable, Text> 
    createRecordReader(InputSplit split,
                       TaskAttemptContext context) {
    String delimiter = context.getConfiguration().get(
        "textinputformat.record.delimiter");
    byte[] recordDelimiterBytes = null;
    if (null != delimiter)
	  //获取一个由分隔符组成的字符数组
      recordDelimiterBytes = delimiter.getBytes(Charsets.UTF_8);
	//Treats keys as offset in file and value as line.  
	//将偏移量作为keys，行的值作为value
    return new LineRecordReader(recordDelimiterBytes); 
  }

  //判断文件能不能分片
  @Override
  protected boolean isSplitable(JobContext context, Path file) {
    final CompressionCodec codec =  //返回文件编码方式
      new CompressionCodecFactory(context.getConfiguration()).getCodec(file);
    if (null == codec) {  //为null
      return true;
    } 
	//此接口表示一种可以分片的编码方式
    return codec instanceof SplittableCompressionCodec;
  }
}
```
	根据文件后缀判断文件是哪种编码方式
	public CompressionCodec getCodec(Path file){}
	

