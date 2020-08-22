# 源码：CompressionCodec

**hadoop-2.7.3**

```java
package org.apache.hadoop.io.compress;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;
import org.apache.hadoop.conf.Configuration;

/**
 * This class encapsulates a streaming compression/decompression pair.
 * 用来压缩和解压缩
 */
@InterfaceAudience.Public
@InterfaceStability.Evolving
public interface CompressionCodec {   //接口

  /**
   * Create a {@link CompressionOutputStream} that will write to the given 
   * {@link OutputStream}.
   * 创建 CompressionOutputStream ,用来将压缩的数据写入到 OutputStream
   * 一个流[CompressionOutputStream] 取得数据,压缩后,写入到给定流out中
   * @param out the location for the final output stream 最终输出流
   * @return a stream the user can write uncompressed data to have it compressed
   * @throws IOException
   */
  CompressionOutputStream createOutputStream(OutputStream out) 
  throws IOException;
  
  /**
   * Create a {@link CompressionOutputStream} that will write to the given 
   * {@link OutputStream} with the given {@link Compressor}.
   *  使用给定的压缩器进行压缩
   * @param out the location for the final output stream
   * @param compressor compressor to use
   * @return a stream the user can write uncompressed data to have it compressed
   * @throws IOException
   */
  CompressionOutputStream createOutputStream(OutputStream out, 
                                             Compressor compressor) 
  throws IOException;

  /**
   * Get the type of {@link Compressor} needed by this {@link CompressionCodec}.
   * 获取压缩器的类型,是gzip,还是lzo,....
   * @return the type of compressor needed by this codec.
   */
  Class<? extends Compressor> getCompressorType();
  
  /**
   * Create a new {@link Compressor} for use by this {@link CompressionCodec}.
   *  创建一个新的压缩器
   * @return a new compressor for use by this codec
   */
  Compressor createCompressor();
  
  /**
   * Create a {@link CompressionInputStream} that will read from the given
   * input stream.
   *  创建一个CompressionInputStream,用来从给定流中读取解压缩后的字节数据
   * [in里的数据是压缩了的,经解压缩,被CompressionInputStream读取]
   * @param in the stream to read compressed bytes from
   * @return a stream to read uncompressed bytes from
   * @throws IOException
   */
  CompressionInputStream createInputStream(InputStream in) throws IOException;
  
  /**
   * Create a {@link CompressionInputStream} that will read from the given 
   * {@link InputStream} with the given {@link Decompressor}.
   *   指定解压缩器
   * @param in the stream to read compressed bytes from
   * @param decompressor decompressor to use
   * @return a stream to read uncompressed bytes from
   * @throws IOException
   */
  CompressionInputStream createInputStream(InputStream in, 
                                           Decompressor decompressor) 
  throws IOException;


  /**
   * Get the type of {@link Decompressor} needed by this {@link CompressionCodec}.
   * 获取解压缩器的类型
   * @return the type of decompressor needed by this codec.
   */
  Class<? extends Decompressor> getDecompressorType();
  
  /**
   * Create a new {@link Decompressor} for use by this {@link CompressionCodec}.
   *  创建一个新的解压缩器
   * @return a new decompressor for use by this codec
   */
  Decompressor createDecompressor();
  
  /**
   * Get the default filename extension for this kind of compression.
   * 获取默认的文件扩展名.如 .gzip
   * @return the extension including the '.'
   */
  String getDefaultExtension();

  static class Util {
    /**
     * Create an output stream with a codec taken from the global CodecPool.
     *  从 CodecPool 中创建输出流
     * @param codec       The codec to use to create the output stream.
     * @param conf        The configuration to use if we need to create a new codec.
     * @param out         The output stream to wrap.
     * @return            The new output stream
     * @throws IOException
     */
    static CompressionOutputStream createOutputStreamWithCodecPool(
        CompressionCodec codec, Configuration conf, OutputStream out)
        throws IOException {
      Compressor compressor = CodecPool.getCompressor(codec, conf);
      CompressionOutputStream stream = null;
      try {
        stream = codec.createOutputStream(out, compressor);
      } finally {
        if (stream == null) {
          CodecPool.returnCompressor(compressor);
        } else {
          stream.setTrackedCompressor(compressor);
        }
      }
      return stream;
    }

    /**
     * Create an input stream with a codec taken from the global CodecPool.
     * 从 CodecPool 中创建输入流
     * @param codec       The codec to use to create the input stream.
     * @param conf        The configuration to use if we need to create a new codec.
     * @param in          The input stream to wrap.
     * @return            The new input stream
     * @throws IOException
     */
    static CompressionInputStream createInputStreamWithCodecPool(
        CompressionCodec codec,  Configuration conf, InputStream in)
          throws IOException {
      Decompressor decompressor = CodecPool.getDecompressor(codec);
      CompressionInputStream stream = null;
      try {
        stream = codec.createInputStream(in, decompressor);
      } finally {
        if (stream == null) {
          CodecPool.returnDecompressor(decompressor);
        } else {
          stream.setTrackedDecompressor(decompressor);
        }
      }
      return stream;
    }
  }
}
```