# mapPartitions算子

```java
  /**
   * Return a new RDD by applying a function to each partition of this RDD.
   * 
   * 对这个rdd的每个分区使用函数操作，返回一个新的rdd
   *
   * `preservesPartitioning` indicates whether the input function preserves the partitioner, which
   * should be `false` unless this is a pair RDD and the input function doesn't modify the keys.
   *
   * preservesPartitioning 表示是否保留父rdd的分区信息，默认是不保留。
   * 如果这是一个pair RDD，且输入函数不会修改key，那么就保留。
   */
  def mapPartitions[U: ClassTag](
      f: Iterator[T] => Iterator[U],
      preservesPartitioning: Boolean = false): RDD[U] = withScope {
  	// Clean a closure to make it ready to be serialized and sent to tasks
  	// return the cleaned closure
    val cleanedF = sc.clean(f)

    // 将函数作用在父rdd的每个分区产生的rdd
    new MapPartitionsRDD(
      this,  //父rdd
      //匿名函数，参数：(TaskContext, partition index, iterator)
      (context: TaskContext, index: Int, iter: Iterator[T]) => cleanedF(iter),
      preservesPartitioning)
  }

  /**
   * 只有在确定rdd元素是可被序列化的，且不需要闭包清理的情况下才使用
   * 
   * [performance] Spark's internal mapPartitionsWithIndex method that skips closure cleaning. 
   * It is a performance API to be used carefully only if we are sure that the RDD elements are
   * serializable and don't require closure cleaning.
   * 
   * @param preservesPartitioning indicates whether the input function preserves the partitioner,
   *                              which should be `false` unless this is a pair RDD and the input
   *                              function doesn't modify the keys.
   * @param isOrderSensitive whether or not the function is order-sensitive. If it's order
   *                         sensitive, it may return totally different result when the input order
   *                         is changed. Mostly stateful functions are order-sensitive.
   *
   * 函数是否对顺序敏感。如果是，那么当输入顺序变化了，计算结果就会完全不同。
   * 大多数状态函数是顺序敏感
   */
  private[spark] def mapPartitionsWithIndexInternal[U: ClassTag](
  	// 这里的Int是分区的index
      f: (Int, Iterator[T]) => Iterator[U], 
      preservesPartitioning: Boolean = false,
      isOrderSensitive: Boolean = false): RDD[U] = withScope {
    new MapPartitionsRDD(
      this, //父rdd
      // index：分区索引
      (context: TaskContext, index: Int, iter: Iterator[T]) => f(index, iter),
      preservesPartitioning = preservesPartitioning,
      isOrderSensitive = isOrderSensitive)
  }

  /**
   * [performance] Spark's internal mapPartitions method that skips closure cleaning. 跳过闭包清理
   */
  private[spark] def mapPartitionsInternal[U: ClassTag](
      f: Iterator[T] => Iterator[U],
      preservesPartitioning: Boolean = false): RDD[U] = withScope {
    new MapPartitionsRDD(
      this,
      (context: TaskContext, index: Int, iter: Iterator[T]) => f(iter),
      preservesPartitioning)
  }

  /**
   * Return a new RDD by applying a function to each partition of this RDD, while tracking the index
   * of the original partition.  在跟踪原始分区的索引时。
   *
   * `preservesPartitioning` indicates whether the input function preserves the partitioner, which
   * should be `false` unless this is a pair RDD and the input function doesn't modify the keys.
   */
  def mapPartitionsWithIndex[U: ClassTag](
      f: (Int, Iterator[T]) => Iterator[U],
      preservesPartitioning: Boolean = false): RDD[U] = withScope {
    val cleanedF = sc.clean(f)
    new MapPartitionsRDD(
      this,
      (context: TaskContext, index: Int, iter: Iterator[T]) => cleanedF(index, iter),
      preservesPartitioning)
  }


```

mapPartitions 和 mapPartitionsWithIndex 区别：

	mapPartitionsWithIndex的输入函数多了一个 分区的index 参数，
	所以可以取出分区编号。

```java
object mapPartitions {
  def main(Args:Array[String]):Unit ={
    val conf = new SparkConf().setAppName("mapPartitions").setMaster("local")
    val sc = new SparkContext(conf)
    val rdd = sc.parallelize(List(1,2,3,4,5,6,7,8,9),2)

    def func1(iter:Iterator[Int]):Iterator[String]={
      iter.toList.map(x=>"计算结果是 "+x).iterator
    }

    def func2(index:Int,iter:Iterator[Int]):Iterator[String]={
      iter.toList.map(x=>"分区 "+index+" 的计算结果是 "+x).iterator
    }

    rdd.mapPartitions(func1).foreach(println)
    println("----------------------------------------------")
    rdd.mapPartitionsWithIndex(func2).foreach(println)
  }
}
```
输出结果：


	20/09/13 12:33:23 INFO TaskSchedulerImpl: Adding task set 0.0 with 2 tasks
	20/09/13 12:33:23 INFO TaskSetManager: Starting task 0.0 in stage 0.0 (TID 0, localhost, executor driver, partition 0, PROCESS_LOCAL, 7809 bytes)
	20/09/13 12:33:23 INFO Executor: Running task 0.0 in stage 0.0 (TID 0)
	计算结果是 1
	计算结果是 2
	计算结果是 3
	计算结果是 4
	20/09/13 12:33:23 INFO Executor: Finished task 0.0 in stage 0.0 (TID 0). 751 bytes result sent to driver
	20/09/13 12:33:23 INFO TaskSetManager: Starting task 1.0 in stage 0.0 (TID 1, localhost, executor driver, partition 1, PROCESS_LOCAL, 7813 bytes)
	20/09/13 12:33:23 INFO Executor: Running task 1.0 in stage 0.0 (TID 1)
	计算结果是 5
	计算结果是 6
	计算结果是 7
	计算结果是 8
	计算结果是 9

	20/09/13 12:33:23 INFO TaskSetManager: Starting task 0.0 in stage 1.0 (TID 2, localhost, executor driver, partition 0, PROCESS_LOCAL, 7809 bytes)
	20/09/13 12:33:23 INFO Executor: Running task 0.0 in stage 1.0 (TID 2)
	分区 0 的计算结果是 1
	分区 0 的计算结果是 2
	分区 0 的计算结果是 3
	分区 0 的计算结果是 4
	20/09/13 12:33:23 INFO Executor: Finished task 0.0 in stage 1.0 (TID 2). 665 bytes result sent to driver
	20/09/13 12:33:23 INFO TaskSetManager: Starting task 1.0 in stage 1.0 (TID 3, localhost, executor driver, partition 1, PROCESS_LOCAL, 7813 bytes)
	20/09/13 12:33:23 INFO Executor: Running task 1.0 in stage 1.0 (TID 3)
	20/09/13 12:33:23 INFO TaskSetManager: Finished task 0.0 in stage 1.0 (TID 2) in 12 ms on localhost (executor driver) (1/2)
	分区 1 的计算结果是 5
	分区 1 的计算结果是 6
	分区 1 的计算结果是 7
	分区 1 的计算结果是 8
	分区 1 的计算结果是 9