# BlockStoreShuffleReader

```java
package org.apache.spark.shuffle

import org.apache.spark._
import org.apache.spark.internal.{config, Logging}
import org.apache.spark.serializer.SerializerManager
import org.apache.spark.storage.{BlockManager, ShuffleBlockFetcherIterator}
import org.apache.spark.util.CompletionIterator
import org.apache.spark.util.collection.ExternalSorter

/**
 * 通过从其他节点的块存储中请求分区，
 * 从一个 shuffle 中获取、读取在范围 [startPartition, endPartition) 中的分区
 *
 * Fetches and reads the partitions in range [startPartition, endPartition) from a shuffle by
 * requesting them from other nodes' block stores.
 */
private[spark] class BlockStoreShuffleReader[K, C](
    handle: BaseShuffleHandle[K, _, C],
    startPartition: Int,
    endPartition: Int,
    context: TaskContext,
    serializerManager: SerializerManager = SparkEnv.get.serializerManager,
    blockManager: BlockManager = SparkEnv.get.blockManager,
    mapOutputTracker: MapOutputTracker = SparkEnv.get.mapOutputTracker)
  extends ShuffleReader[K, C] with Logging {

    //MapOutputTracker：用来跟踪一个 stage 的 map 输出的位置。

  private val dep = handle.dependency

  /** Read the combined key-values for this reduce task */
  override def read(): Iterator[Product2[K, C]] = {
    //获取多个块的迭代器，其元素是 (BlockID, InputStream) 的元组
    val wrappedStreams = new ShuffleBlockFetcherIterator(
      context,
      blockManager.shuffleClient,
      blockManager,
      mapOutputTracker.getMapSizesByExecutorId(handle.shuffleId, startPartition, endPartition), //返回：Iterator[(BlockManagerId, Seq[(BlockId, Long)])]
      serializerManager.wrapStream,
      // Note: we use getSizeAsMb when no suffix is provided for backwards compatibility
      SparkEnv.get.conf.getSizeAsMb("spark.reducer.maxSizeInFlight", "48m") * 1024 * 1024,
      SparkEnv.get.conf.getInt("spark.reducer.maxReqsInFlight", Int.MaxValue),
      SparkEnv.get.conf.get(config.REDUCER_MAX_BLOCKS_IN_FLIGHT_PER_ADDRESS),
      SparkEnv.get.conf.get(config.MAX_REMOTE_BLOCK_SIZE_FETCH_TO_MEM),
      SparkEnv.get.conf.getBoolean("spark.shuffle.detectCorrupt", true))

      // Creates a new [[SerializerInstance]].
      //def newInstance(): SerializerInstance
    val serializerInstance = dep.serializer.newInstance()

    // Create a key/value iterator for each stream
    //对每个流，创建一个键值对迭代器
    val recordIter = wrappedStreams.flatMap { case (blockId, wrappedStream) =>
      // Note: the asKeyValueIterator below wraps a key/value iterator inside of a
      // NextIterator. The NextIterator makes sure that close() is called on the
      // underlying InputStream when all records have been read.

      // asKeyValueIterator 封装了一个键值对迭代器，在 NextIterator 内部。
      // NextIterator 保证了：当所有记录读取完成后，底层流调用close()方法
      //asKeyValueIterator：通过键-值对上的迭代器读取此流的元素。
      serializerInstance.deserializeStream(wrappedStream).asKeyValueIterator
    }
    /**
     * def taskMetrics(): TaskMetrics
     *
     * 下面的readMetrics：
     *  对每个 shuffle dependency，用来收集 shuffle read 指标的临时 shuffle read metrics holder
     *  在最后，所有的临时指标都被合并到 ShuffleReadMetrics。
     *
     *  调用完createTempShuffleReadMetrics方法后，需要在调用 mergeShuffleReadMetrics ，
     *  这会同步地合并临时值，否则，所有收集的临时数据都会丢失。
     */

    /**
     * CompletionIterator：
     * Wrapper around an iterator which calls a completion method after it successfully iterates
     * through all the elements.
     */

    // Update the context task metrics for each record read.
    // 读取一个记录，就更新 context task 指标。
    val readMetrics = context.taskMetrics.createTempShuffleReadMetrics()
    val metricIter = CompletionIterator[(Any, Any), Iterator[(Any, Any)]](
      recordIter.map { record =>
        readMetrics.incRecordsRead(1)  //读取的记录数加1
        record
      },
      context.taskMetrics().mergeShuffleReadMetrics())   //合并临时值

    // An interruptible iterator must be used here in order to support task cancellation
    // InterruptibleIterator：封装一个已存在的迭代器，提供 kill 任务功能。
    val interruptibleIter = new InterruptibleIterator[(Any, Any)](context, metricIter)

//aggregator：map/reduce-side aggregator for RDD's shuffle
    val aggregatedIter: Iterator[Product2[K, C]] = if (dep.aggregator.isDefined) {
      if (dep.mapSideCombine) {
        // We are reading values that are already combined
        val combinedKeyValuesIterator = interruptibleIter.asInstanceOf[Iterator[(K, C)]]
        //把combinedKeyValuesIterator的内容写入到一个可以溢写磁盘的map中，再以迭代器的形式返回
        dep.aggregator.get.combineCombinersByKey(combinedKeyValuesIterator, context)
      } else {
        // We don't know the value type, but also don't care -- the dependency *should*
        // have made sure its compatible w/ this aggregator, which will convert the value
        // type to the combined type C
        val keyValuesIterator = interruptibleIter.asInstanceOf[Iterator[(K, Nothing)]]
        dep.aggregator.get.combineValuesByKey(keyValuesIterator, context)
      }
    } else {  //，没有定义聚合器
      interruptibleIter.asInstanceOf[Iterator[Product2[K, C]]]
    }

    // Sort the output if there is a sort ordering defined.
    //如果定义了排序方式，就对输出进行排序。
    val resultIter = dep.keyOrdering match {
      case Some(keyOrd: Ordering[K]) =>
        // Create an ExternalSorter to sort the data.
        val sorter =
          new ExternalSorter[K, C, C](context, ordering = Some(keyOrd), serializer = dep.serializer)
        sorter.insertAll(aggregatedIter)
        context.taskMetrics().incMemoryBytesSpilled(sorter.memoryBytesSpilled)
        context.taskMetrics().incDiskBytesSpilled(sorter.diskBytesSpilled)
        context.taskMetrics().incPeakExecutionMemory(sorter.peakMemoryUsedBytes)
        // Use completion callback to stop sorter if task was finished/cancelled.
        context.addTaskCompletionListener[Unit](_ => {
          sorter.stop()
        })

        CompletionIterator[Product2[K, C], Iterator[Product2[K, C]]](sorter.iterator, sorter.stop())
      case None =>
        aggregatedIter
    }

   //???
    resultIter match {
      case _: InterruptibleIterator[Product2[K, C]] => resultIter
      case _ =>
        // Use another interruptible iterator here to support task cancellation as aggregator
        // or(and) sorter may have consumed previous interruptible iterator.
        new InterruptibleIterator[Product2[K, C]](context, resultIter)
    }
  }
}

```