# sortByKey、sortBy


## 示例

```sh
scala> val rdd = sc.parallelize(List(1,2,3,4))
rdd: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[21] at parallelize at <console>:24

#  括号里的就是参数f
scala> rdd.sortBy(x => x).collect()
res11: Array[Int] = Array(1, 2, 3, 4)

scala> rdd.sortBy(x => x%3).collect()
res12: Array[Int] = Array(3, 4, 1, 2)

scala> rdd.keyBy(x=>x%3).collect()
res5: Array[(Int, Int)] = Array((1,1), (2,2), (0,3), (1,4))

scala> val srdd = rdd.keyBy(x=>x%3)
srdd: org.apache.spark.rdd.RDD[(Int, Int)] = MapPartitionsRDD[6] at keyBy at <console>:25

scala> srdd.sortByKey().collect()
res7: Array[(Int, Int)] = Array((0,3), (1,1), (1,4), (2,2))


scala> rdd.sortByKey().collect()
<console>:26: error: value sortByKey is not a member of org.apache.spark.rdd.RDD[Int]
       rdd.sortByKey().collect()
```

```sh
scala> val prdd = sc.parallelize(List(("a",3),("b",2),("c",1)))
prdd: org.apache.spark.rdd.RDD[(String, Int)] = ParallelCollectionRDD[10] at parallelize at <console>:24

scala> prdd.collect()
res11: Array[(String, Int)] = Array((a,3), (b,2), (c,1))

scala> prdd.sortBy(x=>x._2).collect()
res14: Array[(String, Int)] = Array((c,1), (b,2), (a,3))

scala> val sprdd = prdd.keyBy(x=>x._2).collect()
prdd: Array[(Int, (String, Int))] = Array((3,(a,3)), (2,(b,2)), (1,(c,1)))

scala> prdd.sortByKey().collect()
res15: Array[(String, Int)] = Array((a,3), (b,2), (c,1))
```

## sortByKey、sortBy区别与联系

sortByKey 

	由 PairRDD 调用；
	有两个参数：升降序、分区数；
	根据key排序

sortBy 

	由 RDD 或 PairRDD 调用；
	有三个参数：函数、升降序、分区数;
	通过参数f函数可以实现自定义排序方式

都默认：升序、排序后的RDD的分区数和排序前的RDD的分区数相同

sortBy 实际调用了 sortByKey 排序的。

## 源码

```scala
/**
   * Return this RDD sorted by the given key function.
   */
  def sortBy[K](
      f: (T) => K,
      ascending: Boolean = true,
      numPartitions: Int = this.partitions.length)
      (implicit ord: Ordering[K], ctag: ClassTag[K]): RDD[T] = withScope {
    this.keyBy[K](f)
        .sortByKey(ascending, numPartitions)
        .values
  }
```
参数：

- 一个函数，该函数的输入是 T 类型(泛型)，返回值类型为K；

- ascending，决定排序后的RDD是升序还是降序，默认是true，即升序；

- numPartitions，决定排序后的RDD的分区个数，默认排序后的分区个数和排序之前的个数相等，即为this.partitions.size。

```scala
/**
   * Sort the RDD by key, so that each partition contains a sorted range of the elements. Calling
   * `collect` or `save` on the resulting RDD will return or output an ordered list of records
   * (in the `save` case, they will be written to multiple `part-X` files in the filesystem, in
   * order of the keys).
   */
  // TODO: this currently doesn't work on P other than Tuple2!
  def sortByKey(ascending: Boolean = true, numPartitions: Int = self.partitions.length)
      : RDD[(K, V)] = self.withScope
  {
    val part = new RangePartitioner(numPartitions, self, ascending)
    new ShuffledRDD[K, V, V](self, part)
      .setKeyOrdering(if (ascending) ordering else ordering.reverse)
  }
```
作用：PairRDD调用时，根据key排序rdd，这样每个分区的元素都是有序的。

在排序后的rdd上调用 `collect` or `save` 可以返回或输出一个记录的有序列表。

如果是调用了 `save` ，那么会按照不同的key，写到不同的文件中。(一个分区一个文件)

返回一个 ShuffledRDD。

参数：

- ascending，决定排序后的RDD是升序还是降序，默认是true，即升序；

- numPartitions，决定排序后的RDD的分区个数，默认排序后的分区个数和排序之前的个数相等，即为self.partitions.length。

```scala
  /**
   * Return an RDD with the values of each tuple.
   */
  def values: RDD[V] = self.map(_._2)

```
作用：取PairRDD的值

```scala
/**
   * Creates tuples of the elements in this RDD by applying `f`.
   * 
   */
  def keyBy[K](f: T => K): RDD[(K, T)] = withScope {
    val cleanedF = sc.clean(f)
    map(x => (cleanedF(x), x))
  }
```

作用：将传进来的每个元素作用于f(x)中，并返回tuples类型的元素，也就变成了Key-Value类型的RDD

```scala
  /** Set key ordering for RDD's shuffle. */
  def setKeyOrdering(keyOrdering: Ordering[K]): ShuffledRDD[K, V, C] = {
    this.keyOrdering = Option(keyOrdering)
    this
  }
```
作用：决定 ShuffledRDD 是升序还是降序

