# ShuffleManager

**spark-2.4.4-bin-hadoop2.7**

```java
package org.apache.spark.shuffle

import org.apache.spark.{ShuffleDependency, TaskContext}

/**
 * Pluggable interface for shuffle systems. A ShuffleManager is created in SparkEnv on the driver
 * and on each executor, based on the spark.shuffle.manager setting. The driver registers shuffles
 * with it, and executors (or tasks running locally in the driver) can ask to read and write data.
 *
 * NOTE: this will be instantiated by SparkEnv so its constructor can take a SparkConf and
 * boolean isDriver as parameters.
 *
 * 一个可拔插的shuffle系统接口。在 driver 和各个 executor 的 SparkEnv 中创建。
 * 可以通过配置 `spark.shuffle.manager` 属性来设置shuffle类型。
 * 
 * driver 注册 shuffles ,executors (或driver本地运行的任务)请求读写数据。
 */
private[spark] trait ShuffleManager {

  /**
   * Register a shuffle with the manager and obtain a handle for it to pass to tasks.
   * manager 注册一个 shuffle,返回一个 ShuffleHandle，传给任务。
   */
  def registerShuffle[K, V, C](
      shuffleId: Int,
      numMaps: Int,
      dependency: ShuffleDependency[K, V, C]): ShuffleHandle

  // ShuffleHandle
  /*
   * 
   * An opaque handle to a shuffle, used by a ShuffleManager to pass information about it to tasks.
   *  一个 shuffle 的不透明句柄，它会由 ShuffleManager 把它的信息传给任务。
   * @param shuffleId ID of the shuffle
   *
   * @DeveloperApi
   * abstract class ShuffleHandle(val shuffleId: Int) extends Serializable {}
   */


  /** Get a writer for a given partition. Called on executors by map tasks. */

  // 在 map 端的 executors 上的任务调用该方法。
  // 为一个给定分区创建一个 writer，返回一个 ShuffleWriter
  def getWriter[K, V](handle: ShuffleHandle, mapId: Int, context: TaskContext): ShuffleWriter[K, V]

  // ShuffleWriter
  /**
   * package org.apache.spark.shuffle
   * 
   * Obtained inside a map task to write out records to the shuffle system.
   *
   * private[spark] abstract class ShuffleWriter[K, V] {
   *     // Write a sequence of records to this task's output
   *     @throws[IOException]
   *     def write(records: Iterator[Product2[K, V]]): Unit
   *
   *     //Close this writer, passing along whether the map completed
   *     def stop(success: Boolean): Option[MapStatus]
   * }
   * 
   *  ShuffleWriter：将 map 任务内获得的记录写入到 shuffle system。
   *      
   *     包含了两个方法:
   *         write:将一系列记录写到这个任务的输出，参数是一个迭代器
   *         stop：关闭writer，参数success表示判断map是否完成
   */ 

  /**
   * Get a reader for a range of reduce partitions (startPartition to endPartition-1, inclusive).
   * Called on executors by reduce tasks.
   *
   * 创建一个 reader，用来读取一定范围内的分区[startPartition,endPartition-1]
   * 在 executors 上，由 reduce 端的任务调用
   */
  def getReader[K, C](
      handle: ShuffleHandle,
      startPartition: Int,
      endPartition: Int,
      context: TaskContext): ShuffleReader[K, C]

 /**
  * package org.apache.spark.shuffle
  *
  * 一个 reduce 任务从 mappers 读取聚合后的记录。
  * Obtained inside a reduce task to read combined records from the mappers.
  *
  * private[spark] trait ShuffleReader[K, C] {
  *     // Read the combined key-values for this reduce task
  *     // 由这个 reduce task 读取聚合后的 key-values
  *     def read(): Iterator[Product2[K, C]]
  *
  *  
  *     Close this reader.
  *     TODO: Add this back when we make the ShuffleReader a developer API that others can implement
  *     (at which point this will likely be necessary).
  *   
  *     // def stop(): Unit
  * }
  */


  /**
   * 从 ShuffleManager 中移除一个 shuffle 的元数据
   * Remove a shuffle's metadata from the ShuffleManager.
   * @return true if the metadata removed successfully, otherwise false.
   */
  def unregisterShuffle(shuffleId: Int): Boolean

  /**
   * 返回一个解析器，能根据块坐标取出块数据。
   * Return a resolver capable of retrieving shuffle block data based on block coordinates.
   */
  def shuffleBlockResolver: ShuffleBlockResolver

  /** Shut down this ShuffleManager. */
  def stop(): Unit
}
```

```java
private[spark]
/**
 * Implementers of this trait understand how to retrieve block data for a logical shuffle block
 * identifier (i.e. map, reduce, and shuffle). Implementations may use files or file segments to
 * encapsulate shuffle data. This is used by the BlockStore to abstract over different shuffle
 * implementations when shuffle data is retrieved.
 *
 * 描述了在各个阶段如何获取块数据。
 */
trait ShuffleBlockResolver {
  type ShuffleId = Int

  /**
   * Retrieve the data for the specified block. If the data for that block is not available, 获取指定块的数据，返回一个 ManagedBuffer
   * throws an unspecified exception.
   */

  //ManagedBuffer这个接口为字节形式的数据提供了一个不可变的视图。
  def getBlockData(blockId: ShuffleBlockId): ManagedBuffer

  def stop(): Unit
}
```