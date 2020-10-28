# IndexShuffleBlockResolver

```java
package org.apache.spark.shuffle

import java.io._
import java.nio.channels.Channels
import java.nio.file.Files

import org.apache.spark.{SparkConf, SparkEnv}
import org.apache.spark.internal.Logging
import org.apache.spark.io.NioBufferedFileInputStream
import org.apache.spark.network.buffer.{FileSegmentManagedBuffer, ManagedBuffer}
import org.apache.spark.network.netty.SparkTransportConf
import org.apache.spark.shuffle.IndexShuffleBlockResolver.NOOP_REDUCE_ID
import org.apache.spark.storage._
import org.apache.spark.util.Utils

/**
 * Create and maintain the shuffle blocks' mapping between logic block and physical file location.
 * Data of shuffle blocks from the same map task are stored in a single consolidated data file.
 * The offsets of the data blocks in the data file are stored in a separate index file.
 *
 * We use the name of the shuffle data's shuffleBlockId with reduce ID set to 0 and add ".data"
 * as the filename postfix for data file, and ".index" as the filename postfix for index file.
 *
 */
// Note: Changes to the format in this file should be kept in sync with
// org.apache.spark.network.shuffle.ExternalShuffleBlockResolver#getSortBasedShuffleBlockData().
/**
 * 创建和维护在逻辑块和物理文件位置间的 shuffle 块的映射。
 *
 * 来自相同 map task 的 shuffle blocks 数据存储在同一个 数据文件 中。
 * 这个数据文件的偏移量存储在单独的 索引文件 中。
 * (一个map任务的输出对应一个数据文件和一个索引文件)
 *
 * 我们使用 shuffle 数据的 shuffleBlockId 的名称，将 ID 设置为 0 
 * 并添加 ".data" 作为数据文件的文件名后缀，".index"作为索引文件的文件名后缀。
 *
 */
private[spark] class IndexShuffleBlockResolver(
    conf: SparkConf,
    _blockManager: BlockManager = null)  //BlockManager：放置、检索块
  extends ShuffleBlockResolver  //ShuffleBlockResolver：定义了各阶段如何接收块数据。
  with Logging {

  private lazy val blockManager = Option(_blockManager).getOrElse(SparkEnv.get.blockManager)

//SparkTransportConf：
//提供一个fromSparkConf，用于将 Spark JVM 中的 SparkConf(例如执行器、驱动程序或独立的shuffle服务)转换为 TransportConf ，TransportConf 提供了有关环境的详细信息，如分配给这个 JVM 的内核数量。

  private val transportConf = SparkTransportConf.fromSparkConf(conf, "shuffle")

  /**
   * val diskBlockManager = {
   * //Only perform cleanup if an external service is not serving our shuffle files.
   * //外部没有在操作这个shuffle文件，仅执行清理操作
   *    val deleteFilesOnStop =
   *        !externalShuffleServiceEnabled || executorId == 
   *                   SparkContext.DRIVER_IDENTIFIER
   *    new DiskBlockManager(conf, deleteFilesOnStop)
   * }
   *
   * DiskBlockManager：创建和维护 逻辑块和磁盘上的物理位置 的映射。
   * 一个块对应一个文件，这个文件名根据 BlockId 命名。
   *
   */

//获取shuffleId下mapId的输出的数据文件
  def getDataFile(shuffleId: Int, mapId: Int): File = {
    //根据ShuffleDataBlockId取出对应的数据文件
    blockManager.diskBlockManager.getFile(ShuffleDataBlockId(shuffleId, mapId, NOOP_REDUCE_ID))
  }

//获取shuffleId下mapId的输出的索引文件。私有。
  private def getIndexFile(shuffleId: Int, mapId: Int): File = {
    //def getFile(blockId: BlockId): File = getFile(blockId.name)
    blockManager.diskBlockManager.getFile(ShuffleIndexBlockId(shuffleId, mapId, NOOP_REDUCE_ID))
  }

  /**
   * 移除一个 map 下的输出数据的数据文件和索引文件
   * Remove data file and index file that contain the output data from one map.
   */
  def removeDataByMap(shuffleId: Int, mapId: Int): Unit = {
    var file = getDataFile(shuffleId, mapId)
    if (file.exists()) {
      if (!file.delete()) {
        logWarning(s"Error deleting data ${file.getPath()}")
      }
    }

    file = getIndexFile(shuffleId, mapId)
    if (file.exists()) {
      if (!file.delete()) {
        logWarning(s"Error deleting index ${file.getPath()}")
      }
    }
  }

  /**
   * 检查给定索引和数据文件是否相互匹配。
   * 如果匹配，返回数据文件中的分区长度。否则返回null
   *
   * Check whether the given index and data files match each other.
   * If so, return the partition lengths in the data file. Otherwise return null.
   */
  //相当于，根据索引文件间接计算数据文件的字节数，和直接计算数据文件的字节数相比较。
  //返回的是存放每个块的偏移量的lengths数组
  private def checkIndexAndDataFile(index: File, data: File, blocks: Int): Array[Long] = {
    // the index file should have `block + 1` longs as offset.
    // 索引文件的偏移量为：block数+1
    // File.length()返回文件的字节大小
    //？？？(blocks + 1) * 8L
    if (index.length() != (blocks + 1) * 8L) {
      return null
    }
    //存放每个块的偏移量
    val lengths = new Array[Long](blocks)

    //读取索引文件
    //索引文件包含了每个块的偏移量，以及输出文件末尾的最后一个偏移量。
    // Read the lengths of blocks
    val in = try {
      new DataInputStream(new NioBufferedFileInputStream(index))
    } catch {
      case e: IOException =>
        return null
    }
    try {

      /**
       * readLong()返回：the next eight bytes of this input stream,返回值类型为long
       *
       */
      // Convert the offsets into lengths of each block
      //根据偏移量计算出每个块的长度，并放到lengths数组里
      var offset = in.readLong()
      //offset是0时，才能走下一步
      if (offset != 0L) {
        return null
      }
      //offset可理解成每个块的起始偏移量
      //lengths数组里的每个块的长度是8个字节
      var i = 0
      while (i < blocks) {
        val off = in.readLong()  //一次读8个字节
        lengths(i) = off - offset
        offset = off
        i += 1
      }
    } catch {
      case e: IOException =>
        return null
    } finally {
      in.close()
    }

    //数据文件的大小应等于lengths数组中每个块的长度和
    // the size of data file should match with index file
    if (data.length() == lengths.sum) {
      lengths
    } else {
      null
    }
  }

  /**
   * 写一个索引文件，其中包含每个块的偏移量，以及输出文件末尾的最后一个偏移量。
   *
   * 这将被 getBlockData 使用来获取每个块的起始位置。
   *
   * Write an index file with the offsets of each block, plus a final offset at the end for the
   * end of the output file. This will be used by getBlockData to figure out where each block
   * begins and ends.
   *
   * It will commit the data and index file as an atomic operation, use the existing ones, or
   * replace them with new ones.
   *
   * 提交数据和索引文件是一次原子操作，要么使用已存在的，要么使用新的替换旧的
   *
   *
   * Note: the `lengths` will be updated to match the existing index file if use the existing ones.
   */
  def writeIndexFileAndCommit(
      shuffleId: Int,
      mapId: Int,
      lengths: Array[Long],
      dataTmp: File): Unit = {
    val indexFile = getIndexFile(shuffleId, mapId)
    val indexTmp = Utils.tempFileWith(indexFile) //复制一个文件
    try {
      val dataFile = getDataFile(shuffleId, mapId)
      // There is only one IndexShuffleBlockResolver per executor, this synchronization make sure
      // the following check and rename are atomic.
      //每个executor仅有一个IndexShuffleBlockResolver。
      //同步保证了下面的检查和重命名是原子的。
      synchronized {
        val existingLengths = checkIndexAndDataFile(indexFile, dataFile, lengths.length)
        if (existingLengths != null) {
          // Another attempt for the same task has already written our map outputs successfully,
          // so just use the existing partition lengths and delete our temporary map outputs.
          //如果map输出数据已经成功写入了，
          //那么就使用已存在的分区长度，删除临时map输出
          System.arraycopy(existingLengths, 0, lengths, 0, lengths.length)
          if (dataTmp != null && dataTmp.exists()) {
            dataTmp.delete()
          }
        } else {
          // This is the first successful attempt in writing the map outputs for this task,
          // so override any existing index and data files with the ones we wrote.

          //这是这个任务第一次尝试写入map输出，
          //所以，使用新的覆盖已存在的索引和数据文件
          val out = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(indexTmp)))
          Utils.tryWithSafeFinally {
            // We take in lengths of each block, need to convert it to offsets.
            var offset = 0L
            out.writeLong(offset)
            for (length <- lengths) {
              offset += length
              out.writeLong(offset)
            }
          } {
            out.close()
          }

          if (indexFile.exists()) {
            indexFile.delete()
          }
          if (dataFile.exists()) {
            dataFile.delete()
          }
          if (!indexTmp.renameTo(indexFile)) {
            throw new IOException("fail to rename file " + indexTmp + " to " + indexFile)
          }
          if (dataTmp != null && dataTmp.exists() && !dataTmp.renameTo(dataFile)) {
            throw new IOException("fail to rename file " + dataTmp + " to " + dataFile)
          }
        }
      }
    } finally {
      if (indexTmp.exists() && !indexTmp.delete()) {
        logError(s"Failed to delete temporary index file at ${indexTmp.getAbsolutePath}")
      }
    }
  }
//根据blockId取出对应的块数据
  override def getBlockData(blockId: ShuffleBlockId): ManagedBuffer = {
    // The block is actually going to be a range of a single map output file for this map, so
    // find out the consolidated file, then the offset within that from our index
    // 块实际上是这个 map 输出文件中的一个范围内的数据，
    // 因此找出合并后的文件，然后从我们的索引中找出合并后的文件中的偏移量
    val indexFile = getIndexFile(blockId.shuffleId, blockId.mapId)

    // SPARK-22982: if this FileInputStream's position is seeked forward by another piece of code
    // which is incorrectly using our file descriptor then this code will fetch the wrong offsets
    // (which may cause a reducer to be sent a different reducer's data). The explicit position
    // checks added here were a useful debugging aid during SPARK-22982 and may help prevent this
    // class of issue from re-occurring in the future which is why they are left here even though
    // SPARK-22982 is fixed.
    val channel = Files.newByteChannel(indexFile.toPath)
    channel.position(blockId.reduceId * 8L)
    val in = new DataInputStream(Channels.newInputStream(channel))
    try {
      val offset = in.readLong()
      val nextOffset = in.readLong()
      val actualPosition = channel.position() //实际偏移量
      val expectedPosition = blockId.reduceId * 8L + 16 //理论偏移量
      if (actualPosition != expectedPosition) {
        throw new Exception(s"SPARK-22982: Incorrect channel position after index file reads: " +
          s"expected $expectedPosition but actual position was $actualPosition.")
      }
      //FileSegmentManagedBuffer:
      //A {@link ManagedBuffer} backed by a segment in a file.
      new FileSegmentManagedBuffer(
        transportConf,
        getDataFile(blockId.shuffleId, blockId.mapId),
        offset,
        nextOffset - offset)
    } finally {
      in.close()
    }
  }

  override def stop(): Unit = {}
}

private[spark] object IndexShuffleBlockResolver {
  // No-op reduce ID used in interactions with disk store.
  // The disk store currently expects puts to relate to a (map, reduce) pair, but in the sort
  // shuffle outputs for several reduces are glommed into a single file.
  val NOOP_REDUCE_ID = 0
}
//？？？
//与磁盘存储交互时使用的 No-op reduce ID  （无操作的reduce）
//当前，磁盘存储期望放入相关的一对 (map, reduce)，但在 sort shuffle 中，多个 reduces 的输出被合并到一个文件中。
```