# 源码：LineReader



package org.apache.hadoop.util;

import java.io.Closeable;
import java.io.IOException;
import java.io.InputStream;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.io.Text;

/*
 * \n：LF，换行符，新起一行，光标在新行的开头；
 * \r：CR，回车符，光标回到一旧行的开头；(即光标目前所在的行为旧行)
 * \r\n：windows下的换行
 */


/**
 * A class that provides a line reader from an input stream. 从输入流中读取行
 * Depending on the constructor used, lines will either be terminated by:
 * 取决于使用的构造方法，行终止符可以是 \n  \r  \r\n 或者自定义的字节序列分隔符
 * <ul>
 * <li>one of the following: '\n' (LF) , '\r' (CR),
 * or '\r\n' (CR+LF).</li>
 * <li><em>or</em>, a custom byte sequence delimiter</li>
 * </ul>
 * In both cases, EOF also terminates an otherwise unterminated
 * line.   EOF 可以结束其他终止符为结束的行。（功能更强大的终止符）
 */
@InterfaceAudience.LimitedPrivate({"MapReduce"})
@InterfaceStability.Unstable
public class LineReader implements Closeable {

  private static final int DEFAULT_BUFFER_SIZE = 64 * 1024; // 默认的buffer大小
  private int bufferSize = DEFAULT_BUFFER_SIZE;
  private InputStream in;
  private byte[] buffer;
  // the number of bytes of real data in the buffer
  private int bufferLength = 0; // buffer 中真正数据的字节数
  
  // the current position in the buffer 
  private int bufferPosn = 0;  // buffer 中的当前位置

  private static final byte CR = '\r';
  private static final byte LF = '\n';

  // The line delimiter 行分隔符字节数组
  private final byte[] recordDelimiterBytes;

  /**
   * Create a line reader that reads from the given stream using the
   * default buffer-size (64k).  构造方法：使用默认buffer大小
   * @param in The input stream
   * @throws IOException
   */
  public LineReader(InputStream in) {
    this(in, DEFAULT_BUFFER_SIZE);
  }

  /**
   * Create a line reader that reads from the given stream using the 
   * given buffer-size.  构造方法：直接指定buffer大小
   * @param in The input stream
   * @param bufferSize Size of the read buffer
   * @throws IOException
   */
  public LineReader(InputStream in, int bufferSize) {
    this.in = in;
    this.bufferSize = bufferSize;
    this.buffer = new byte[this.bufferSize];
    this.recordDelimiterBytes = null;
  }

  /**
   * Create a line reader that reads from the given stream using the
   * <code>io.file.buffer.size</code> specified in the given
   * <code>Configuration</code>.   
   * 构造方法：从配置文件中获取给定buffer大小
   * @param in input stream
   * @param conf configuration
   * @throws IOException
   */
  public LineReader(InputStream in, Configuration conf) throws IOException {
    this(in, conf.getInt("io.file.buffer.size", DEFAULT_BUFFER_SIZE));
  }

  /**
   * Create a line reader that reads from the given stream using the
   * default buffer-size, and using a custom delimiter of array of
   * bytes.
   * 构造方法：默认buffer大小，自定义行分隔符数组
   * @param in The input stream
   * @param recordDelimiterBytes The delimiter
   */
  public LineReader(InputStream in, byte[] recordDelimiterBytes) {
    this.in = in;
    this.bufferSize = DEFAULT_BUFFER_SIZE;
    this.buffer = new byte[this.bufferSize];
    this.recordDelimiterBytes = recordDelimiterBytes;
  }

  /**
   * Create a line reader that reads from the given stream using the
   * given buffer-size, and using a custom delimiter of array of
   * bytes.
   * 构造方法：直接指定buffer大小，自定义行分隔符数组
   * @param in The input stream
   * @param bufferSize Size of the read buffer
   * @param recordDelimiterBytes The delimiter
   * @throws IOException
   */
  public LineReader(InputStream in, int bufferSize,
      byte[] recordDelimiterBytes) {
    this.in = in;
    this.bufferSize = bufferSize;
    this.buffer = new byte[this.bufferSize];
    this.recordDelimiterBytes = recordDelimiterBytes;
  }

  /**
   * Create a line reader that reads from the given stream using the
   * <code>io.file.buffer.size</code> specified in the given
   * <code>Configuration</code>, and using a custom delimiter of array of
   * bytes.
   * 构造方法：从配置文件中获取给定buffer大小，自定义行分隔符数组
   * @param in input stream
   * @param conf configuration
   * @param recordDelimiterBytes The delimiter
   * @throws IOException
   */
  public LineReader(InputStream in, Configuration conf,
      byte[] recordDelimiterBytes) throws IOException {
    this.in = in;
    this.bufferSize = conf.getInt("io.file.buffer.size", DEFAULT_BUFFER_SIZE);
    this.buffer = new byte[this.bufferSize];
    this.recordDelimiterBytes = recordDelimiterBytes;
  }


  /**
   * Close the underlying stream. 关闭底层流
   * @throws IOException
   */
  public void close() throws IOException {
    in.close();
  }
  
  /**
   * 从输入流中读取一行数据 到给定的Text，
   * Read one line from the InputStream into the given Text.
   *
   *  读取的一行数据 存储的地方，不包括换行符
   * @param str the object to store the given line (without newline)
   *
   * 存储到 str 的最大的字节数；超过的部分丢弃
   * @param maxLineLength the maximum number of bytes to store into str;
   *  the rest of the line is silently discarded.
   *
   * 在这次调用中，消耗的最大的字节数
   * 这只是一个暗示，因为是允许超过这个阈值的。可以超过一个buffer的长度
   * @param maxBytesToConsume the maximum number of bytes to consume
   *  in this call.  This is only a hint, because if the line cross
   *  this threshold, we allow it to happen.  It can overshoot
   *  potentially by as much as one buffer length.
   *
   * @return the number of bytes read including the (longest) newline
   * found.返回读取的字节数量，包括换行符（最长的）
   *
   * @throws IOException if the underlying stream throws
   */
  public int readLine(Text str, int maxLineLength,
                      int maxBytesToConsume) throws IOException {
    if (this.recordDelimiterBytes != null) {  // 包含行分隔符
      return readCustomLine(str, maxLineLength, maxBytesToConsume);
    } else { // 不包含行分隔符，要自定义
      return readDefaultLine(str, maxLineLength, maxBytesToConsume);
    }
  }

  // 从输入流中读取数据存入buffer数组
  protected int fillBuffer(InputStream in, byte[] buffer, boolean inDelimiter)
      throws IOException {
    return in.read(buffer);  // 父类read
	// 返回读进 buffer 的字节数
	// the total number of bytes read into the buffer, 
  }

  /**
   * Read a line terminated by one of CR, LF, or CRLF.
   * 读取一行，该行以 CR, LF, or CRLF 中的一个结尾。
   */
  private int readDefaultLine(Text str, int maxLineLength, int maxBytesToConsume)
  throws IOException {
    /* We're reading data from in, but the head of the stream may be
     * already buffered in buffer, so we have several cases:
     * 1. No newline characters are in the buffer, so we need to copy
     *    everything and read another buffer from the stream.
     * 2. An unambiguously terminated line is in buffer, so we just
     *    copy to str.
     * 3. Ambiguously terminated line is in buffer, i.e. buffer ends
     *    in CR.  In this case we copy everything up to CR to str, but
     *    we also need to see what follows CR: if it's LF, then we
     *    need consume LF as well, so next call to readLine will read
     *    from after that.
     * We use a flag prevCharCR to signal if previous character was CR
     * and, if it happens to be at the end of the buffer, delay
     * consuming it until we have a chance to look at the char that
     * follows.
     */
	 /* 从输入流中读取数据，但请求的数据可能已被缓存进 buffer 中。所以
	  * 有以下几种情况：
	  * 1.buffer 中没有换行符，所以会从流中复制所有数据，读取其他的buffer中的数据。
	  * 2.buffer 中有明确的终止行，所以只需往 str 复制数据。
	  * 3.buffer 中没有明确的终止行，例如buffer以'\r' (CR)结尾。这种情况下，
	  * 一方面缓存数据到CR后，一方面往str 复制数据（??）。同时也要注意CR后是
	  * 什么，如果是LF，我们也需要消费LF，以便下次继续从这个位置读数据。
	  * 
	  * 使用prevCharCR来标记前一个字符是不是CR。如果出现在buffer的末尾，
	  * 需要下一个字符到来时，才可以消费它。
	  */
	// 先清空目的地 str
    str.clear();
	
	// str 的大小
    int txtLength = 0; //tracks str.getLength(), as an optimization
    
	// 终止符计数
	int newlineLength = 0; //length of terminating newline
	
	// 前一个字符是不是CR
    boolean prevCharCR = false; //true of prev char was CR
	
	// 消费的字节数
    long bytesConsumed = 0;  
    do {
	  // bufferPosn：buffer 中的当前位置
	  // 从上次结束的地方开始
      int startPosn = bufferPosn; //starting from where we left off the last time
      
	  if (bufferPosn >= bufferLength) {
	  // 超过了buffer的大小，回到此行的开头(回车)
        startPosn = bufferPosn = 0;  
        if (prevCharCR) {
          ++bytesConsumed; //account for CR from previous read
        }
		// 继续往里读数据
		// 返回读进 buffer 的字节数
        bufferLength = fillBuffer(in, buffer, prevCharCR);
        if (bufferLength <= 0) {
          break; // EOF  没有数据可读
        }
      }
	  
	  // 找终止符
      for (; bufferPosn < bufferLength; ++bufferPosn) { //search for newline
        // 如果当前位置是换行符，buffer的位置偏移加1，结束循环
		if (buffer[bufferPosn] == LF) {
          newlineLength = (prevCharCR) ? 2 : 1;
          ++bufferPosn; // at next invocation proceed from following byte
          break;
        }
		// 如果前一个字符是回车符，但后面没有换行符，终止符计数置1，结束循环
        if (prevCharCR) { //CR + notLF, we are at notLF
          newlineLength = 1;
          break;
        }
		// 如果当前位置是回车符，则 prevCharCR = true
        prevCharCR = (buffer[bufferPosn] == CR);
      }
	  
	  // buffer中已占用的长度
      int readLength = bufferPosn - startPosn;
      if (prevCharCR && newlineLength == 0) {
        --readLength; //CR at the end of the buffer，去掉CR所占的计数
      }
	  
	  // 已经消费了的字节数
      bytesConsumed += readLength;
      int appendLength = readLength - newlineLength;  // 要写入str的字节数
	  存储到 str 的最大的字节数
	  // 如果要写入的字节数超过了最大允许写入的字节，就截掉超过的部分
      if (appendLength > maxLineLength - txtLength) {
        appendLength = maxLineLength - txtLength;
      }
      if (appendLength > 0) {
        str.append(buffer, startPosn, appendLength);  // 添加到 str
        txtLength += appendLength;  // 移动位置
      }
	// newlineLength == 0 表明还没读完一行数据，就继续读
    } while (newlineLength == 0 && bytesConsumed < maxBytesToConsume);

    if (bytesConsumed > Integer.MAX_VALUE) {
      throw new IOException("Too many bytes before newline: " + bytesConsumed);
    }
    return (int)bytesConsumed;
  }

  /**
   * Read a line terminated by a custom delimiter.
   * 读取一行，该行以自定义的终止符结尾
   */
  private int readCustomLine(Text str, int maxLineLength, int maxBytesToConsume)
      throws IOException {
   /* We're reading data from inputStream, but the head of the stream may be
    *  already captured in the previous buffer, so we have several cases:
    * 
    * 1. The buffer tail does not contain any character sequence which
    *    matches with the head of delimiter. We count it as a 
    *    ambiguous byte count = 0
    *    
    * 2. The buffer tail contains a X number of characters,
    *    that forms a sequence, which matches with the
    *    head of delimiter. We count ambiguous byte count = X
    *    
    *    // ***  eg: A segment of input file is as follows
    *    
    *    " record 1792: I found this bug very interesting and
    *     I have completely read about it. record 1793: This bug
    *     can be solved easily record 1794: This ." 
    *    
    *    delimiter = "record";
    *        
    *    supposing:- String at the end of buffer =
    *    "I found this bug very interesting and I have completely re"
    *    There for next buffer = "ad about it. record 179       ...."           
    *     
    *     The matching characters in the input
    *     buffer tail and delimiter head = "re" 
    *     Therefore, ambiguous byte count = 2 ****   //
    *     
    *     2.1 If the following bytes are the remaining characters of
    *         the delimiter, then we have to capture only up to the starting 
    *         position of delimiter. That means, we need not include the 
    *         ambiguous characters in str.
    *     
    *     2.2 If the following bytes are not the remaining characters of
    *         the delimiter ( as mentioned in the example ), 
    *         then we have to include the ambiguous characters in str. 
    */
    str.clear();
    int txtLength = 0; // tracks str.getLength(), as an optimization
    long bytesConsumed = 0;
    int delPosn = 0;
    int ambiguousByteCount=0; // To capture the ambiguous characters count
    do {
      int startPosn = bufferPosn; // Start from previous end position
      if (bufferPosn >= bufferLength) {
        startPosn = bufferPosn = 0;
        bufferLength = fillBuffer(in, buffer, ambiguousByteCount > 0);
        if (bufferLength <= 0) {
          if (ambiguousByteCount > 0) {
            str.append(recordDelimiterBytes, 0, ambiguousByteCount);
            bytesConsumed += ambiguousByteCount;
          }
          break; // EOF
        }
      }
      for (; bufferPosn < bufferLength; ++bufferPosn) {
        if (buffer[bufferPosn] == recordDelimiterBytes[delPosn]) {
          delPosn++;
          if (delPosn >= recordDelimiterBytes.length) {
            bufferPosn++;
            break;
          }
        } else if (delPosn != 0) {
          bufferPosn -= delPosn;
          if(bufferPosn < -1) {
            bufferPosn = -1;
          }
          delPosn = 0;
        }
      }
      int readLength = bufferPosn - startPosn;
      bytesConsumed += readLength;
      int appendLength = readLength - delPosn;
      if (appendLength > maxLineLength - txtLength) {
        appendLength = maxLineLength - txtLength;
      }
      bytesConsumed += ambiguousByteCount;
      if (appendLength >= 0 && ambiguousByteCount > 0) {
        //appending the ambiguous characters (refer case 2.2)
        str.append(recordDelimiterBytes, 0, ambiguousByteCount);
        ambiguousByteCount = 0;
        // since it is now certain that the split did not split a delimiter we
        // should not read the next record: clear the flag otherwise duplicate
        // records could be generated
        unsetNeedAdditionalRecordAfterSplit();
      }
      if (appendLength > 0) {
        str.append(buffer, startPosn, appendLength);
        txtLength += appendLength;
      }
      if (bufferPosn >= bufferLength) {
        if (delPosn > 0 && delPosn < recordDelimiterBytes.length) {
          ambiguousByteCount = delPosn;
          bytesConsumed -= ambiguousByteCount; //to be consumed in next
        }
      }
    } while (delPosn < recordDelimiterBytes.length 
        && bytesConsumed < maxBytesToConsume);
    if (bytesConsumed > Integer.MAX_VALUE) {
      throw new IOException("Too many bytes before delimiter: " + bytesConsumed);
    }
    return (int) bytesConsumed; 
  }

  /**
   * Read from the InputStream into the given Text.
   * @param str the object to store the given line
   * @param maxLineLength the maximum number of bytes to store into str.
   * @return the number of bytes read including the newline
   * @throws IOException if the underlying stream throws
   */
  public int readLine(Text str, int maxLineLength) throws IOException {
    return readLine(str, maxLineLength, Integer.MAX_VALUE);
  }

  /**
   * Read from the InputStream into the given Text.
   * @param str the object to store the given line
   * @return the number of bytes read including the newline
   * @throws IOException if the underlying stream throws
   */
  public int readLine(Text str) throws IOException {
    return readLine(str, Integer.MAX_VALUE, Integer.MAX_VALUE);
  }

  protected int getBufferPosn() {  // 获取当前位置
    return bufferPosn;
  }

  protected int getBufferSize() { // 获取buffer 大小
    return bufferSize;
  }

  protected void unsetNeedAdditionalRecordAfterSplit() {
    // needed for custom multi byte line delimiters only
    // see MAPREDUCE-6549 for details
  }
}
