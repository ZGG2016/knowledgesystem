# 源码：CodecPool

**hadoop-2.7.3**

```java
package org.apache.hadoop.io.compress;

import java.util.HashSet;
import java.util.HashMap;
import java.util.Set;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.util.ReflectionUtils;

import com.google.common.cache.CacheBuilder;
import com.google.common.cache.CacheLoader;
import com.google.common.cache.LoadingCache;

/**
 * A global compressor/decompressor pool used to save and reuse 
 * (possibly native) compression/decompression codecs.
 *
 * 一个全局的 压缩器/解压缩 池,用来保存和重复使用(可能原生库)
 * 压缩器/解压缩 codecs
 */
@InterfaceAudience.Public
@InterfaceStability.Evolving
public class CodecPool {
  private static final Log LOG = LogFactory.getLog(CodecPool.class);
  
  /**
   * 一个全局压缩器池
   * A global compressor pool used to save the expensive 
   * construction/destruction of (possibly native) decompression codecs.
   */
  private static final Map<Class<Compressor>, Set<Compressor>> compressorPool =
    new HashMap<Class<Compressor>, Set<Compressor>>(); 
	//Compressor的Class对象,Set集合
  
  /**
   * 一个全局解压缩器池
   * A global decompressor pool used to save the expensive 
   * construction/destruction of (possibly native) decompression codecs.
   */
  private static final Map<Class<Decompressor>, Set<Decompressor>> decompressorPool =
    new HashMap<Class<Decompressor>, Set<Decompressor>>();

  private static <T> LoadingCache<Class<T>, AtomicInteger> createCache(
      Class<T> klass) {
    return CacheBuilder.newBuilder().build(
        new CacheLoader<Class<T>, AtomicInteger>() {
          @Override
          public AtomicInteger load(Class<T> key) throws Exception {
            return new AtomicInteger();
          }
        });
  }
  /*
   * AtomicInteger:An {@code int} value that may be updated atomically.
   *
   */
  

  /**
   * Map to track the number of leased compressors
   * 出租的压缩器个数
   */
  private static final LoadingCache<Class<Compressor>, AtomicInteger> compressorCounts =
      createCache(Compressor.class);

   /**
   * Map to tracks the number of leased decompressors
   * 出租的解压缩器个数
   */
  private static final LoadingCache<Class<Decompressor>, AtomicInteger> decompressorCounts =
      createCache(Decompressor.class);

  // 出租codec
  // pool:<codec.class,codec...codec>
  private static <T> T borrow(Map<Class<T>, Set<T>> pool,
                             Class<? extends T> codecClass) {
    T codec = null;
    
    // Check if an appropriate codec is available
    Set<T> codecSet;
    synchronized (pool) {
      codecSet = pool.get(codecClass); // 根据class对象,取出所有codec
    }

    if (codecSet != null) {
      synchronized (codecSet) {
        if (!codecSet.isEmpty()) {
          codec = codecSet.iterator().next();
          codecSet.remove(codec);  // 取完,删除
        }
      }
    }
    
    return codec;
  }
  // 归还codec
  private static <T> boolean payback(Map<Class<T>, Set<T>> pool, T codec) {
    if (codec != null) {
      Class<T> codecClass = ReflectionUtils.getClass(codec);
      Set<T> codecSet;
      synchronized (pool) {
        codecSet = pool.get(codecClass);
		// codecClass对应的value为空的话,就创建一个新的HashSet,并添加
        if (codecSet == null) {  
          codecSet = new HashSet<T>();
          pool.put(codecClass, codecSet);
        }
      }
		//否则添加对应的value
      synchronized (codecSet) {
        return codecSet.add(codec);
      }
    }
    return false;
  }
  
  @SuppressWarnings("unchecked")
  private static <T> int getLeaseCount(
      LoadingCache<Class<T>, AtomicInteger> usageCounts,
      Class<? extends T> codecClass) {
    return usageCounts.getUnchecked((Class<T>) codecClass).get();
  }
  // 更新出租的codec计数
  private static <T> void updateLeaseCount(
      LoadingCache<Class<T>, AtomicInteger> usageCounts, T codec, int delta) {
    if (codec != null) {
      Class<T> codecClass = ReflectionUtils.getClass(codec);
      usageCounts.getUnchecked(codecClass).addAndGet(delta);
    }
  }

  /**
   * Get a {@link Compressor} for the given {@link CompressionCodec} from the 
   * pool or a new one.
   * 从池中获取一个 压缩器,如果池中没有,就新建一个
   *
   * @param codec the <code>CompressionCodec</code> for which to get the 
   *              <code>Compressor</code>
   * @param conf the <code>Configuration</code> object which contains confs for creating or reinit the compressor
   * @return <code>Compressor</code> for the given 
   *         <code>CompressionCodec</code> from the pool or a new one
   */
  public static Compressor getCompressor(CompressionCodec codec, Configuration conf) {
    Compressor compressor = borrow(compressorPool, codec.getCompressorType());
    
	// 如果池中没有,就新建一个
	if (compressor == null) {
      compressor = codec.createCompressor();
      LOG.info("Got brand-new compressor ["+codec.getDefaultExtension()+"]");
    } else {
      compressor.reinit(conf); // 初始化压缩器
      if(LOG.isDebugEnabled()) {
        LOG.debug("Got recycled compressor");
      }
    }
	// 更新出租的codec计数
    updateLeaseCount(compressorCounts, compressor, 1);
    return compressor;
  }
  
  // 不指定想要获取的压缩器类型
  public static Compressor getCompressor(CompressionCodec codec) {
    return getCompressor(codec, null);
  }
  
  /**
   * Get a {@link Decompressor} for the given {@link CompressionCodec} from the
   * pool or a new one.
   * 从池中获取一个解压缩器,如果池中没有,就新建一个
   * @param codec the <code>CompressionCodec</code> for which to get the 
   *              <code>Decompressor</code>
   * @return <code>Decompressor</code> for the given 
   *         <code>CompressionCodec</code> the pool or a new one
   */
  public static Decompressor getDecompressor(CompressionCodec codec) {
    Decompressor decompressor = borrow(decompressorPool, codec.getDecompressorType());
    if (decompressor == null) {
      decompressor = codec.createDecompressor();
      LOG.info("Got brand-new decompressor ["+codec.getDefaultExtension()+"]");
    } else {  // 没有初始化
      if(LOG.isDebugEnabled()) {
        LOG.debug("Got recycled decompressor");
      }
    }
    updateLeaseCount(decompressorCounts, decompressor, 1);
    return decompressor;
  }
  
  /**
   * Return the {@link Compressor} to the pool.
   * 将压缩器返回到池中
   * @param compressor the <code>Compressor</code> to be returned to the pool
   */
  public static void returnCompressor(Compressor compressor) {
    if (compressor == null) {
      return;
    }
    // if the compressor can't be reused, don't pool it.
    if (compressor.getClass().isAnnotationPresent(DoNotPool.class)) {
      return;
    }
    compressor.reset();  // 重置状态
	// 归还
    if (payback(compressorPool, compressor)) {
	// 更新出租的codec计数
      updateLeaseCount(compressorCounts, compressor, -1);
    }
  }
  
  /**
   * Return the {@link Decompressor} to the pool.
   * 
   * @param decompressor the <code>Decompressor</code> to be returned to the 
   *                     pool
   */
  public static void returnDecompressor(Decompressor decompressor) {
    if (decompressor == null) {
      return;
    }
    // if the decompressor can't be reused, don't pool it.
    if (decompressor.getClass().isAnnotationPresent(DoNotPool.class)) {
      return;
    }
    decompressor.reset();
    if (payback(decompressorPool, decompressor)) {
      updateLeaseCount(decompressorCounts, decompressor, -1);
    }
  }

  /**
   * 返回出租给这个 CompressionCodec 的压缩器的数量
   * Return the number of leased {@link Compressor}s for this
   * {@link CompressionCodec}
   */
  public static int getLeasedCompressorsCount(CompressionCodec codec) {
    return (codec == null) ? 0 : getLeaseCount(compressorCounts,
        codec.getCompressorType());
  }

  /**
   * 返回出租给这个 CompressionCodec 的解压缩器的数量
   * Return the number of leased {@link Decompressor}s for this
   * {@link CompressionCodec}
   */
  public static int getLeasedDecompressorsCount(CompressionCodec codec) {
    return (codec == null) ? 0 : getLeaseCount(decompressorCounts,
        codec.getDecompressorType());
  }
}
```