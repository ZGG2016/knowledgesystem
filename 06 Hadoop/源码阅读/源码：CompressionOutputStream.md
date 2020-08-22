# 源码：CompressionOutputStream

```java
package org.apache.hadoop.io.compress;

import java.io.IOException;
import java.io.OutputStream;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;

/**
 * A compression output stream.  一个压缩输出流
 * 一个流[CompressionOutputStream] 取得输入数据,压缩后,写入到给定流out中
 */
@InterfaceAudience.Public
@InterfaceStability.Evolving

//继承OutputStream的抽象类
public abstract class CompressionOutputStream extends OutputStream {
  /**
   * The output stream to be compressed. 待压缩的输出流。
   */
  protected final OutputStream out;

  /**
   * If non-null, this is the Compressor object that we should call
   * CodecPool#returnCompressor on when this stream is closed.
   *
   * 当流关闭后,向 CodecPool.returnCompressor 方法
   * 传入的 Compressor 对象.
   */
  private Compressor trackedCompressor;

  /**
   * Create a compression output stream that writes
   * the compressed bytes to the given stream.
   *
   * 构造方法.
   * 创建压缩输出流,将压缩的字节数据写入到给定流中.
   * 一个流[CompressionOutputStream] 取得输入数据,压缩后,写入到给定流out中
   * @param out
   */
  protected CompressionOutputStream(OutputStream out) {
    this.out = out;
  }

  void setTrackedCompressor(Compressor compressor) {
    trackedCompressor = compressor;
  }

  @Override
  public void close() throws IOException {
    finish(); 
    out.close(); //调父类的
    if (trackedCompressor != null) { //如果使用了压缩器,那么将其返回到池中
      CodecPool.returnCompressor(trackedCompressor);
      trackedCompressor = null;
    }
  }
  
  @Override
  public void flush() throws IOException {
    out.flush();  //调父类的
  }
  
  /**
   * Write compressed bytes to the stream.
   * Made abstract to prevent leakage to underlying stream.  
   *
   * 将压缩的字节数据写到流中
   * 使其为抽象，以防止渗漏到底层流。  ???
   */
  @Override
  public abstract void write(byte[] b, int off, int len) throws IOException;

  /**
   * Finishes writing compressed data to the output stream 
   * without closing the underlying stream.
   *
   * 完成写入,但不关闭底层流
   *
   */
  public abstract void finish() throws IOException;
  
  /**
   * Reset the compression to the initial state. 
   * Does not reset the underlying stream.
   *
   * 重置压缩器到初始状态,但不重置底层流
   */
  public abstract void resetState() throws IOException;

}
```