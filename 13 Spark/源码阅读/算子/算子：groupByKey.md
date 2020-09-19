# groupByKey算子

## 1、源码

```java
  /**
   * 在rdd中，根据每个key分组value，成一个序列。
   *
   * 通过传Partitioner参数，可以控制结果rdd的分区。
   *
   * 但不能保证组内元素有序。
   * 
   * Group the values for each key in the RDD into a single sequence. Allows controlling the
   * partitioning of the resulting key-value pair RDD by passing a Partitioner.
   * The ordering of elements within each group is not guaranteed, and may even differ
   * each time the resulting RDD is evaluated.
   *
   * 注意： 
   *
   * 1、这个操作是昂贵的。如果你分组是为了执行聚合操作(如sum、average)，
   *    那么最好使用 aggregateByKey 或 reduceByKey。
   *
   * 2、groupByKey操作会把所有的键值对放到内存，如果一个key有太多的value，
   *    那么会 OutOfMemoryError
   *
   *
   * @note This operation may be very expensive. If you are grouping in order to perform an
   * aggregation (such as a sum or average) over each key, using `PairRDDFunctions.aggregateByKey`
   * or `PairRDDFunctions.reduceByKey` will provide much better performance.
   *
   * @note As currently implemented, groupByKey must be able to hold all the key-value pairs for any
   * key in memory. If a key has too many values, it can result in an `OutOfMemoryError`.
   */
  def groupByKey(partitioner: Partitioner): RDD[(K, Iterable[V])] = self.withScope {
    // groupByKey shouldn't use map side combine because map side combine does not
    // reduce the amount of data shuffled and requires all map side data be inserted
    // into a hash table, leading to more objects in the old gen.
    /**
     * groupByKey不应该使用map端的combine。因为map端的combine不会减少shuffle的数据量，
     * 还会要求把所有map端的数据插入到hash table里，导致老生代有很多对象。
     **/
    //CompactBuffer：An append-only buffer similar to ArrayBuffer, but more memory-efficient for small buffers.
    val createCombiner = (v: V) => CompactBuffer(v)  //初始值
    val mergeValue = (buf: CompactBuffer[V], v: V) => buf += v  //追加
    //合并
    val mergeCombiners = (c1: CompactBuffer[V], c2: CompactBuffer[V]) => c1 ++= c2
    val bufs = combineByKeyWithClassTag[CompactBuffer[V]](
      createCombiner, mergeValue, mergeCombiners, partitioner, mapSideCombine = false)  // mapSideCombine = false
    bufs.asInstanceOf[RDD[(K, Iterable[V])]]
  }

  /**
   * Group the values for each key in the RDD into a single sequence. Hash-partitions the
   * resulting RDD with into `numPartitions` partitions. The ordering of elements within
   * each group is not guaranteed, and may even differ each time the resulting RDD is evaluated.
   *
   * @note This operation may be very expensive. If you are grouping in order to perform an
   * aggregation (such as a sum or average) over each key, using `PairRDDFunctions.aggregateByKey`
   * or `PairRDDFunctions.reduceByKey` will provide much better performance.
   *
   * @note As currently implemented, groupByKey must be able to hold all the key-value pairs for any
   * key in memory. If a key has too many values, it can result in an `OutOfMemoryError`.
   */
  def groupByKey(numPartitions: Int): RDD[(K, Iterable[V])] = self.withScope {
    groupByKey(new HashPartitioner(numPartitions))
  }
```
## 2、示例

```java
object groupByKey {
  def main(Args:Array[String]):Unit = {
    val conf = new SparkConf().setAppName("groupByKey").setMaster("local")
    val sc = new SparkContext(conf)

    val rdd = sc.parallelize("aabbaab")
    
    val rlt = rdd.map((_,1)).groupByKey()

    println(rlt.collect().toBuffer) //ArrayBuffer((a,CompactBuffer(1, 1, 1, 1)), (b,CompactBuffer(1, 1, 1)))
  }
}
```