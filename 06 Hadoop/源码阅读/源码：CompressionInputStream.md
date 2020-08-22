# 源码：CompressionInputStream

```java
package org.apache.hadoop.io.compress;

import java.io.IOException;
import java.io.InputStream;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;
import org.apache.hadoop.fs.PositionedReadable;
import org.apache.hadoop.fs.Seekable;
/**
 * A compression input stream. 一个压缩输入流
 * in里的数据是压缩了的,经解压缩,被CompressionInputStream读取
 * <p>Implementations are assumed to be buffered.  This permits clients to
 * reposition the underlying input stream then call {@link #resetState()},
 * without having to also synchronize client buffers.
 * 数据是被缓存了的[高效].客户端可以使用resetState()方法重新定位流的位置,不需要
 * 同步客户端缓存区.
 */
@InterfaceAudience.Public
@InterfaceStability.Evolving

//继承 InputStream ,实现 Seekable 接口的抽象类
public abstract class CompressionInputStream extends InputStream implements Seekable {
  /**
   * The input stream to be compressed. 待压缩的输入流。
   */
  protected final InputStream in;
  protected long maxAvailableData = 0L;

  private Decompressor trackedDecompressor;  /解压缩器

  /**
   * Create a compression input stream that reads
   * the decompressed bytes from the given stream.
   *  
   * 构造方法
   * 创建一个压缩输入流,用来从给定流中读取解压缩后的字节数据
   * in里的数据是压缩了的,经解压缩,被CompressionInputStream读取
   * @param in The input stream to be compressed.
   * @throws IOException
   */
  protected CompressionInputStream(InputStream in) throws IOException {
    if (!(in instanceof Seekable) || !(in instanceof PositionedReadable)) {
        this.maxAvailableData = in.available();
    }
    this.in = in;
  }

  @Override
  public void close() throws IOException {
    in.close(); //调父类的
    if (trackedDecompressor != null) { //如果使用了解压缩器,那么将其返回到池中
      CodecPool.returnDecompressor(trackedDecompressor);
      trackedDecompressor = null;
    }
  }
  
  /**
   * Read bytes from the stream. 从流中读取字节数据
   * Made abstract to prevent leakage to underlying stream.
   */
  @Override
  public abstract int read(byte[] b, int off, int len) throws IOException;

  /**
   * Reset the decompressor to its initial state and discard any buffered data,
   * as the underlying stream may have been repositioned.
   *
   * 重置解压缩器到初始状态,丢弃缓存的数据
   * 
   */
  public abstract void resetState() throws IOException;
  
  /**
   * This method returns the current position in the stream.
   * 返回流的当前位置
   * @return Current position in stream as a long
   */
  @Override
  public long getPos() throws IOException {
    if (!(in instanceof Seekable) || !(in instanceof PositionedReadable)){
      //This way of getting the current position will not work for file
      //size which can be fit in an int and hence can not be returned by
      //available method.
      return (this.maxAvailableData - this.in.available());
    }
    else{
	//接口Seekable的getPos():
	//Return the current offset from the start of the file
      return ((Seekable)this.in).getPos();  

    }

  }

  /**
   * This method is current not supported.
   *
   * @throws UnsupportedOperationException
   */

  @Override
  public void seek(long pos) throws UnsupportedOperationException {
    throw new UnsupportedOperationException();
  }

  /**
   * This method is current not supported.
   *
   * @throws UnsupportedOperationException
   */
  @Override
  public boolean seekToNewSource(long targetPos) throws UnsupportedOperationException {
    throw new UnsupportedOperationException();
  }

  void setTrackedDecompressor(Decompressor decompressor) {
    trackedDecompressor = decompressor;
  }
}
```