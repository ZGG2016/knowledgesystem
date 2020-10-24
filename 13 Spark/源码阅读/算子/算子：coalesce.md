# 算子：coalesce

RDD.scala

## 1、源码

coalesce的作用是减少rdd的分区到 `numPartitions` 个数。

默认shuffle = false。

如果减少的分区过大，需要设置shuffle = true

想要合并到更多的分区，需要设置shuffle = true（如，100到1000）

```java
  /**
   *  减少rdd的分区到 `numPartitions` 个数
   * 
   * Return a new RDD that is reduced into `numPartitions` partitions.
   *
   * 这会导致一个窄依赖。例如，如果从1000减少到100个分区，不会shuffle。
   *     相反，这100个新分区中的每个分区将占用当前分区中的10个。
   * 
   * 如果设置了一个比当前分区数更大的一个值，将会保持不变。
   *
   * This results in a narrow dependency, e.g. if you go from 1000 partitions
   * to 100 partitions, there will not be a shuffle, instead each of the 100
   * new partitions will claim 10 of the current partitions. If a larger number
   * of partitions is requested, it will stay at the current number of partitions.
   *
   * 如果减少的分区过大，如，直接减少到1个，那么会导致你的计算只使用少量的结点
   *                                    (numPartitions = 1会使用一个结点)
   *  为了避免这种情况，可以设置shuffle = true。这会添加shuffle步骤，
   *  意味着当前上游分区将并行执行(无论当前分区是什么)。
   *
   *
   * However, if you're doing a drastic coalesce, e.g. to numPartitions = 1,
   * this may result in your computation taking place on fewer nodes than
   * you like (e.g. one node in the case of numPartitions = 1). To avoid this,
   * you can pass shuffle = true. This will add a shuffle step, but means the
   * current upstream partitions will be executed in parallel (per whatever
   * the current partitioning is).
   *
   * 设置shuffle = true，可以合并到更多的分区。
   * 如果您只有少量的分区(比如100个，而其中一些分区可能异常大，那么这将非常有用。
   * 调用coalesce(1000, shuffle = true)将产生1000个分区，使用散列分区器分发数据。
   *
   * 传入的partitionCoalescer参数必须是可序列化的
   * partitionCoalescer：定义了如何合并给定RDD的分区
   * partitionCoalescer：how to coalesce the partitions of a given RDD
   *
   * @note With shuffle = true, you can actually coalesce to a larger number
   * of partitions. This is useful if you have a small number of partitions,
   * say 100, potentially with a few partitions being abnormally large. Calling
   * coalesce(1000, shuffle = true) will result in 1000 partitions with the
   * data distributed using a hash partitioner. The optional partition coalescer
   * passed in must be serializable.
   */
  def coalesce(numPartitions: Int, shuffle: Boolean = false,
               partitionCoalescer: Option[PartitionCoalescer] = Option.empty)
              (implicit ord: Ordering[T] = null)
      : RDD[T] = withScope {
    require(numPartitions > 0, s"Number of partitions ($numPartitions) must be positive.")

    if (shuffle) {
      /** Distributes elements evenly across output partitions, starting from a random partition. 从随机分区开始，将元素均匀分布到各个输出分区。*/

/**
 * nextInt：返回一个伪随机数，在[0,指定值)间的均匀分布值。
 * byteswap32：具有良好分布的快速乘法哈希。
 * hashing.byteswap32(index)：初始种子
 */

      //针对分区操作  (index: Int, items: Iterator[T]) index为分区索引，item为分区内存
      //随机取一个分区，对分区里的每个元素加一个key，以(元素位置，元素内容)的形式
      val distributePartition = (index: Int, items: Iterator[T]) => {
        //随机选一个分区。一个分区的开始位置
        var position = new Random(hashing.byteswap32(index)).nextInt(numPartitions)
        //迭代分区内元素
        items.map { t =>
          // Note that the hash code of the key will just be the key itself. The HashPartitioner
          // will mod it with the number of total partitions.
          position = position + 1
          (position, t)
        }
      } : Iterator[(Int, T)]   //每个分区中的元素格式：(元素位置，元素内容)


	  //因为需要shuffle，所以上游任务仍需要被分发new ShuffledRDD
      // include a shuffle step so that our upstream tasks are still distributed
      new CoalescedRDD(
      	//将distributePartition作用在rdd的每个分区，返回一个ShuffledRDD
        new ShuffledRDD[Int, T, T](
          mapPartitionsWithIndexInternal(distributePartition, isOrderSensitive = true),
          new HashPartitioner(numPartitions)),
        numPartitions,
        partitionCoalescer).values //去掉key，即元素位置
    } else {
    //不做shuffle
      new CoalescedRDD(this, numPartitions, partitionCoalescer)
    }
  }
/**
 * class CoalescedRDD[T: ClassTag](
 * 	    @transient var prev: RDD[T],
 *      maxPartitions: Int,
 *      partitionCoalescer: Option[PartitionCoalescer] = None)
 * 
 * class ShuffledRDD[K: ClassTag, V: ClassTag, C: ClassTag](
 *      @transient var prev: RDD[_ <: Product2[K, V]],
 *      part: Partitioner)
 *
 * 一个跳过闭包清理的内部方法
 * private[spark] def mapPartitionsWithIndexInternal[U: ClassTag](
 *       f: (Int, Iterator[T]) => Iterator[U],
 *       preservesPartitioning: Boolean = false,
 *       isOrderSensitive: Boolean = false): RDD[U]= withScope {
 *   new MapPartitionsRDD(
 *     this,
 *     (context: TaskContext, index: Int, iter: Iterator[T]) => f(index, iter),
 *     preservesPartitioning = preservesPartitioning,
 *     isOrderSensitive = isOrderSensitive)
 * }
 *
 * 
 * Return an RDD with the values of each tuple.
 * def values: RDD[V] = self.map(_._2)
 */
```

## 2、示例

```java
object coalesce {
  def main(Args:Array[String]): Unit = {
    val conf = new SparkConf().setAppName("coalesce").setMaster("local")
    val sc = new SparkContext(conf)

    val data = sc.textFile("src/main/data/coalesce.txt",10)

    val rlt1 = data.coalesce(4)
    val rlt2 = data.coalesce(100,shuffle = true)
    val rlt3 = data.coalesce(100)

    println(data.partitions.length) //10
    println(rlt1.partitions.length) //4
    println(rlt2.partitions.length) //100
    println(rlt3.partitions.length) //10
  }
}
```