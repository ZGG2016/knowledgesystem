# 算子：persist、cache

## 1、源码

```java
  /**
   * 使用指定的存储级别，标记这个RDD，即将被持久化
   * Mark this RDD for persisting using the specified level.
   *
   * @param newLevel the target storage level
   *                   当已设置了一个存储级别，判断是否允许使用新的一个存储级别覆盖旧的
   * @param allowOverride whether to override any existing level with the new one
   */
  private def persist(newLevel: StorageLevel, allowOverride: Boolean): this.type = {
    // TODO: Handle changes of StorageLevel
    
    if (storageLevel != StorageLevel.NONE && newLevel != storageLevel && !allowOverride) {
      throw new UnsupportedOperationException(
        "Cannot change storage level of an RDD after it was already assigned a level")
    }
    //如果这个RDD是第一次被标记，就注册...。这个操作仅做一次。
    // If this is the first time this RDD is marked for persisting, register it
    // with the SparkContext for cleanups and accounting. Do this only once.
    if (storageLevel == StorageLevel.NONE) {
      // 注册一个RDD以便在垃圾收集时进行清理:registerRDDForCleanup
      sc.cleaner.foreach(_.registerRDDForCleanup(this))
      sc.persistRDD(this)
    }
    storageLevel = newLevel
    this
  }

  /**
   * // Register an RDD to be persisted in memory and/or disk storage
   *  private[spark] def persistRDD(rdd: RDD[_]) {
   *       persistentRdds(rdd.id) = rdd //由键取值
   *  }
   *
   * // Keeps track of all persisted RDDs  
   * // 一个map集合，存放被持久化的所有RDD
   *  private[spark] val persistentRdds = {
   * 	val map: ConcurrentMap[Int, RDD[_]] = new MapMaker().weakValues().makeMap[Int, RDD[_]]()
   *    map.asScala  //将java集合转换成scala集合
   * }
   *
   *  // A unique ID for this RDD (within its SparkContext).  取这个RDD的唯一ID
   *   val id: Int = sc.newRddId()
   * 
   *   private val nextRddId = new AtomicInteger(0)
   *
   *  //Register a new RDD, returning its RDD ID 注册一个新的RDD，返回它的ID。
   *   private[spark] def newRddId(): Int = nextRddId.getAndIncrement()
   */
  

  /**
   * 设置这个RDD的存储级别，以便在第一次计算它之后跨操作持久化它的值。
   *
   * Set this RDD's storage level to persist its values across operations after the first time
   * it is computed. This can only be used to assign a new storage level if the RDD does not
   * have a storage level set yet. Local checkpointing is an exception.
   */
  def persist(newLevel: StorageLevel): this.type = {
  	//判断这个RDD被标记为 是否进行本地checkpoint
    if (isLocallyCheckpointed) {
      // This means the user previously called localCheckpoint(), which should have already
      // marked this RDD for persisting. Here we should override the old storage level with
      // one that is explicitly requested by the user (after adapting it to use disk).

      // 在调用localCheckpoint方法时，已经标记了这个RDD进行持久化。这里只需覆盖旧的存储级别
      //transformStorageLevel 把指定的一个存储级别转换成 使用磁盘的一种存储级别。
      persist(LocalRDDCheckpointData.transformStorageLevel(newLevel), allowOverride = true)
    } else {
      persist(newLevel, allowOverride = false)
    }
  }

  /**
   *  
   * //Return whether this RDD is marked for local checkpointing.
   * //Exposed for testing.
   * private[rdd] def isLocallyCheckpointed: Boolean = {
   * 	checkpointData match {
   *   		case Some(_: LocalRDDCheckpointData[T]) => true
   *   		case _ => false
   * 	}
   * }
   *
   */


  /**
   * Persist this RDD with the default storage level (`MEMORY_ONLY`).
   */
  def persist(): this.type = persist(StorageLevel.MEMORY_ONLY)

  /**
   * Persist this RDD with the default storage level (`MEMORY_ONLY`).
   */
  def cache(): this.type = persist()

  /**
   * 标记此RDD为非持久化，并移除内存和磁盘上的所有blocks
   * Mark the RDD as non-persistent, and remove all blocks for it from memory and disk.
   *
   *                 block没被删完，是否阻塞。
   * @param blocking Whether to block until all blocks are deleted.
   * @return This RDD.
   */
  def unpersist(blocking: Boolean = true): this.type = {
    logInfo("Removing RDD " + id + " from persistence list")
    sc.unpersistRDD(id, blocking)
    storageLevel = StorageLevel.NONE
    this
  }
  /**
   * 
   * //Unpersist an RDD from memory and/or disk storage
   * private[spark] def unpersistRDD(rddId: Int, blocking: Boolean = true) {
   *   //removeRdd：Remove all blocks belonging to the given RDD
   * 	env.blockManager.master.removeRdd(rddId, blocking)
   * 	persistentRdds.remove(rddId)
   * 	listenerBus.post(SparkListenerUnpersistRDD(rddId))
   * }
   *
   */
```

## 2、示例

```java
package func

import org.apache.spark.{SparkConf, SparkContext}

object persist {
  def main(Args:Array[String]): Unit = {
    val sparkConf = new SparkConf().setAppName("persist").setMaster("local")
    val sc = new SparkContext(sparkConf)

    val rdd1 = sc.parallelize(Array(("aa", 1), ("bb", 5), ("cc", 9))).persist()

    //(aa,1)
    //(bb,5)
    //(cc,9)
    rdd1.foreach(println)

    val rdd2 = sc.parallelize(Array(("aa", 1), ("bb", 5), ("cc", 9))).cache()

    //(aa,1)
    //(bb,5)
    //(cc,9)
    rdd2.foreach(println)
  
  }
}

```