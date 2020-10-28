# ShuffleBlockResolver

```java
package org.apache.spark.shuffle

import org.apache.spark.network.buffer.ManagedBuffer
import org.apache.spark.storage.ShuffleBlockId

private[spark]
/**
 * 定义了各阶段如何接收块数据。
 *
 * 实现类可以使用文件或者文件片段来封装 shuffle data.
 *
 * 当接收到 shuffle data 时，由 BlockStore 来抽象不同的 shuffle 实现。
 *
 * Implementers of this trait understand how to retrieve block data for a logical shuffle block
 * identifier (i.e. map, reduce, and shuffle). Implementations may use files or file segments to
 * encapsulate shuffle data. This is used by the BlockStore to abstract over different shuffle
 * implementations when shuffle data is retrieved.
 */
trait ShuffleBlockResolver {
  type ShuffleId = Int

  /**
   * 为指定的 block 接收数据。
   *
   * Retrieve the data for the specified block. If the data for that block is not available,
   * throws an unspecified exception.
   */

// ShuffleBlockId：
//Format of the shuffle block ids (including data and index) should be kept in sync with
// org.apache.spark.network.shuffle.ExternalShuffleBlockResolver#getBlockData().

  def getBlockData(blockId: ShuffleBlockId): ManagedBuffer

  def stop(): Unit
}


```