# SortShuffleManager

**spark-2.4.4-bin-hadoop2.7**

```java
package org.apache.spark.shuffle.sort

import java.util.concurrent.ConcurrentHashMap

import org.apache.spark._
import org.apache.spark.internal.Logging
import org.apache.spark.shuffle._

/**
 * In sort-based shuffle, incoming records are sorted according to their target partition ids, then
 * written to a single map output file. Reducers fetch contiguous regions of this file in order to
 * read their portion of the map output. In cases where the map output data is too large to fit in
 * memory, sorted subsets of the output can be spilled to disk and those on-disk files are merged
 * to produce the final output file.
 *
 * 
 * 在基于排序的 shuffle 中，传入的记录根据它们的目标分区id进行排序，
 *     然后写入到一个 map 输出文件中。  (这样相邻的数据进入相同分区)
 * 为了能读取 map 输出的部分数据，Reducers 获取这个文件的相邻的数据区域。
 * 当装入内存中的 map 输出数据太大，排序了的输出数据可以溢写到磁盘，
       这些在磁盘上的文件被合并到最终的输出文件中。
 *
 *
 * Sort-based shuffle has two different write paths for producing its map output files:
 *
 *  - Serialized sorting: used when all three of the following conditions hold:
 *    1. The shuffle dependency specifies no aggregation or output ordering.
 *    2. The shuffle serializer supports relocation of serialized values (this is currently
 *       supported by KryoSerializer and Spark SQL's custom serializers).
 *    3. The shuffle produces fewer than 16777216 output partitions.
 *  - Deserialized sorting: used to handle all other cases.
 *
 * Sort-based shuffle 有两种不同的写入路径，来产生它的 map 输出文件：
 *   - Serialized sorting: 
 *     1. shuffle 依赖项没有指定聚合或输出顺序。
 *     2. shuffle 序列化器支持序列化值的重定位( KryoSerializer 和 Spark SQL 的自定义序列化程序目前支持这一点)
 *     3. shuffle 产生的输出分区少于16777216个。
 *   - Deserialized sorting: 除了以上情况的其他情况。
 *
 * -----------------------
 * Serialized sorting mode
 * -----------------------
 *
 * 在 serialized sorting 模式中，记录只要传递到 shuffle writer，就被序列化。
 *     然后在排序期间，以序列化的形式被缓存。
 * 
 * 这个写路径实现有几种优化方式：
 *     - 排序操作是基于序列化后的二进制数据，而不是 Java 对象。这可以减少内存消耗和 GC 负载。这种方式要求序列化器能允许序列化后的记录不需要反序列化就可以排序。
 *
 *     - 使用一种高效缓存排序器[ShuffleExternalSorter]，
 * 能够排序压缩后的记录指针和分区id组成的数组。在排序数组中，每个记录占用8字节的空间。
 * 这样可以将更多的数组放入缓存中。
 *
 *     - 溢出合并过程对属于同一分区的序列化后的记录块进行操作，并在合并期间不需反序列化记录。
 *
 *     - 当溢出压缩编解码器支持压缩数据的连接时，溢出合并只是连接序列化的压缩的溢出分区，
 * 以产生最终的输出分区。这允许使用高效的数据复制方法，如 NIO 的 "transferTo"，
 * 并避免在合并期间分配解压缩或复制缓冲区。
 *
 *
 * In the serialized sorting mode, incoming records are serialized as soon as they are passed to the
 * shuffle writer and are buffered in a serialized form during sorting. This write path implements
 * several optimizations:
 *
 *  - Its sort operates on serialized binary data rather than Java objects, which reduces memory
 *    consumption and GC overheads. This optimization requires the record serializer to have certain
 *    properties to allow serialized records to be re-ordered without requiring deserialization.
 *    See SPARK-4550, where this optimization was first proposed and implemented, for more details.
 *
 *  - It uses a specialized cache-efficient sorter ([[ShuffleExternalSorter]]) that sorts
 *    arrays of compressed record pointers and partition ids. By using only 8 bytes of space per
 *    record in the sorting array, this fits more of the array into cache.
 *
 *  - The spill merging procedure operates on blocks of serialized records that belong to the same
 *    partition and does not need to deserialize records during the merge.
 *
 *  - When the spill compression codec supports concatenation of compressed data, the spill merge
 *    simply concatenates the serialized and compressed spill partitions to produce the final output
 *    partition.  This allows efficient data copying methods, like NIO's `transferTo`, to be used
 *    and avoids the need to allocate decompression or copying buffers during the merge.
 *
 * For more details on these optimizations, see SPARK-7081.
 */
private[spark] class SortShuffleManager(conf: SparkConf) extends ShuffleManager with Logging {

  //spark 1.6+ 的版本此配置可以不用设置，也可以溢写。
  if (!conf.getBoolean("spark.shuffle.spill", true)) {
    logWarning(
      "spark.shuffle.spill was set to false, but this configuration is ignored as of Spark 1.6+." +
        " Shuffle will continue to spill to disk when necessary.")
  }

  /**
   * key:shuffle id
   * value:在这个 shuffle 中，产生输出的所有 mappers 的数量。
   * 一个 shuffle 对应的 mapper 任务的数量。
   * A mapping from shuffle ids to the number of mappers producing output for those shuffles.
   */
  private[this] val numMapsForShuffle = new ConcurrentHashMap[Int, Int]()

//IndexShuffleBlockResolver:创建和维护在逻辑块和物理文件位置间的 shuffle blocks 的映射。
  override val shuffleBlockResolver = new IndexShuffleBlockResolver(conf)

  /**
   * 注册 shuffle，获得一个 ShuffleHandle 传给任务。
   *
   * Obtains a [[ShuffleHandle]] to pass to tasks.
   */
  override def registerShuffle[K, V, C](
      shuffleId: Int,
      numMaps: Int,
      dependency: ShuffleDependency[K, V, C]): ShuffleHandle = {
    //如果分区数小于 spark.shuffle.sort.bypassMergeThreshold，且不需要 map 端的聚合操作，
    //启用bypass模式
    if (SortShuffleWriter.shouldBypassMergeSort(conf, dependency)) {
      // If there are fewer than spark.shuffle.sort.bypassMergeThreshold partitions and we don't
      // need map-side aggregation, then write numPartitions files directly and just concatenate
      // them at the end. This avoids doing serialization and deserialization twice to merge
      // together the spilled files, which would happen with the normal code path. The downside is
      // having multiple files open at a time and thus more memory allocated to buffers.

      //（numPartitions files ？？？）
      //启用bypass模式，就可以直接写入到 numPartitions 个文件，最后连接它们。 
      //这样就避免了两次序列化和反序列化来合并溢出的文件。
      //缺点是一次打开多个文件，因此有更多的内存分配给缓冲区。
      new BypassMergeSortShuffleHandle[K, V](
        shuffleId, numMaps, dependency.asInstanceOf[ShuffleDependency[K, V, V]])
    } else if (SortShuffleManager.canUseSerializedShuffle(dependency)) {
      // Otherwise, try to buffer map outputs in a serialized form, since this is more efficient:
      //如果不能启用bypass模式，尝试以序列化的形式缓存 map 输出。这样更高效：
      new SerializedShuffleHandle[K, V](
        shuffleId, numMaps, dependency.asInstanceOf[ShuffleDependency[K, V, V]])
    } else {
      // Otherwise, buffer map outputs in a deserialized form:
      //如果既不能启用bypass模式，也不能以序列化的形式缓存 map 输出，
      //那么，就以反序列化的形式缓存 map 输出
      new BaseShuffleHandle(shuffleId, numMaps, dependency)
    }
  }
---------------------------------------------------------------看到这
  /**
   * Get a reader for a range of reduce partitions (startPartition to endPartition-1, inclusive).
   * Called on executors by reduce tasks.
   *
   * 创建一个 reader，用来读取一定范围内的分区[startPartition,endPartition-1]
   * 由 reduce tasks 在 executors 上调用
   */
  override def getReader[K, C](
      handle: ShuffleHandle,
      startPartition: Int,
      endPartition: Int,
      context: TaskContext): ShuffleReader[K, C] = {
//通过从其他节点的块存储中请求分区，
//从一个 shuffle 中获取、读取在范围 [startPartition, endPartition) 中的分区
    new BlockStoreShuffleReader(
      handle.asInstanceOf[BaseShuffleHandle[K, _, C]], startPartition, endPartition, context)
  }

  // 由 map tasks 在 executors 上调用该方法。
  // 为一个给定分区创建一个 writer，返回一个 ShuffleWriter
  /** Get a writer for a given partition. Called on executors by map tasks. */
  override def getWriter[K, V](
      handle: ShuffleHandle,
      mapId: Int,
      context: TaskContext): ShuffleWriter[K, V] = {

  //key:shuffle id，value:在这个 shuffle 中，产生输出的所有 mappers 的数量。
    numMapsForShuffle.putIfAbsent(
      handle.shuffleId, handle.asInstanceOf[BaseShuffleHandle[_, _, _]].numMaps)

    val env = SparkEnv.get
    handle match {
      case unsafeShuffleHandle: SerializedShuffleHandle[K @unchecked, V @unchecked] =>
        new UnsafeShuffleWriter(
          env.blockManager,
          shuffleBlockResolver.asInstanceOf[IndexShuffleBlockResolver],
          context.taskMemoryManager(),
          unsafeShuffleHandle,
          mapId,
          context,
          env.conf)
      case bypassMergeSortHandle: BypassMergeSortShuffleHandle[K @unchecked, V @unchecked] =>
        new BypassMergeSortShuffleWriter(
          env.blockManager,
          shuffleBlockResolver.asInstanceOf[IndexShuffleBlockResolver],
          bypassMergeSortHandle,
          mapId,
          context,
          env.conf)
      case other: BaseShuffleHandle[K @unchecked, V @unchecked, _] =>
        new SortShuffleWriter(shuffleBlockResolver, other, mapId, context)
    }
  }

  /** Remove a shuffle's metadata from the ShuffleManager. */
  override def unregisterShuffle(shuffleId: Int): Boolean = {
    Option(numMapsForShuffle.remove(shuffleId)).foreach { numMaps =>
      (0 until numMaps).foreach { mapId =>
        shuffleBlockResolver.removeDataByMap(shuffleId, mapId)
      }
    }
    true
  }

  /** Shut down this ShuffleManager. */
  override def stop(): Unit = {
    shuffleBlockResolver.stop()
  }
}


private[spark] object SortShuffleManager extends Logging {

  /**
   * 当以序列化形式缓存 map 输出时，SortShuffleManager 支持的最大 shuffle 输出分区数。
   *
   * The maximum number of shuffle output partitions that SortShuffleManager supports when
   * buffering map outputs in a serialized form. This is an extreme defensive programming measure,
   * since it's extremely unlikely that a single shuffle produces over 16 million output partitions.
   * */
  val MAX_SHUFFLE_OUTPUT_PARTITIONS_FOR_SERIALIZED_MODE =
    PackedRecordPointer.MAXIMUM_PARTITION_ID + 1

  /**
   * 用来决定一个 shuffle 是否应该使用一个优化的序列化的 shuffle 路径，
   * 或者它是否应该退回到对反序列化对象进行操作的原始路径。
   *
   *
   * Helper method for determining whether a shuffle should use an optimized serialized shuffle
   * path or whether it should fall back to the original path that operates on deserialized objects.
   */
  def canUseSerializedShuffle(dependency: ShuffleDependency[_, _, _]): Boolean = {
    //val shuffleId: Int = _rdd.context.newShuffleId()
    val shufId = dependency.shuffleId

    val numPartitions = dependency.partitioner.numPartitions

    //启用supportsRelocationOfSerializedObjects，
    //且，不启用 map 端的聚合
    //且，分区数大于 MAX_SHUFFLE_OUTPUT_PARTITIONS_FOR_SERIALIZED_MODE
    //才能使用serialized shuffle
    if (!dependency.serializer.supportsRelocationOfSerializedObjects) {
      log.debug(s"Can't use serialized shuffle for shuffle $shufId because the serializer, " +
        s"${dependency.serializer.getClass.getName}, does not support object relocation")
      false
    } else if (dependency.mapSideCombine) {
      log.debug(s"Can't use serialized shuffle for shuffle $shufId because we need to do " +
        s"map-side aggregation")
      false
    } else if (numPartitions > MAX_SHUFFLE_OUTPUT_PARTITIONS_FOR_SERIALIZED_MODE) {
      log.debug(s"Can't use serialized shuffle for shuffle $shufId because it has more than " +
        s"$MAX_SHUFFLE_OUTPUT_PARTITIONS_FOR_SERIALIZED_MODE partitions")
      false
    } else {
      log.debug(s"Can use serialized shuffle for shuffle $shufId")
      true
    }
  }
}

/**
 * Subclass of [[BaseShuffleHandle]], used to identify when we've chosen to use the
 * serialized shuffle.
 */
private[spark] class SerializedShuffleHandle[K, V](
  shuffleId: Int,
  numMaps: Int,
  dependency: ShuffleDependency[K, V, V])
  extends BaseShuffleHandle(shuffleId, numMaps, dependency) {
}

/**
 * Subclass of [[BaseShuffleHandle]], used to identify when we've chosen to use the
 * bypass merge sort shuffle path.
 */
private[spark] class BypassMergeSortShuffleHandle[K, V](
  shuffleId: Int,
  numMaps: Int,
  dependency: ShuffleDependency[K, V, V])
  extends BaseShuffleHandle(shuffleId, numMaps, dependency) {
}
```

```java
/**
 * A basic ShuffleHandle implementation that just captures registerShuffle's parameters.
 */
private[spark] class BaseShuffleHandle[K, V, C](
    shuffleId: Int,
    val numMaps: Int,
    val dependency: ShuffleDependency[K, V, C])
  extends ShuffleHandle(shuffleId)

/**
 * An opaque handle to a shuffle, used by a ShuffleManager to pass information about it to tasks.
 *
 * @param shuffleId ID of the shuffle
 */
@DeveloperApi
abstract class ShuffleHandle(val shuffleId: Int) extends Serializable {}
```