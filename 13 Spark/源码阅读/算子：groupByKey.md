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

    val rdd = sc.textFile("src/main/data/reduceByKey.txt")

    val rlt = rdd.map((_,1)).groupByKey()

    println(rlt.collect().toBuffer) //ArrayBuffer((a,CompactBuffer(1, 1, 1, 1)), (b,CompactBuffer(1, 1, 1)))
  }
}

```

### 3、groupByKey和reduceByKey的区别

相同点：

	都作用于pair RDD

	都是根据key来分组或聚合

	都可以通过参数来指定分区数量，都是默认HashPartitioner

	执行逻辑均在combineByKeyWithClassTag

不同点：

	groupByKey默认没有聚合函数，得到的返回值类型是RDD[ k,Iterable[V]]。是对key对应的values分组，成一个序列。

	reduceByKey 必须传聚合函数，得到的返回值类型 RDD[(K,聚合后的V)]。通过传入的函数进行聚合操作。

	groupByKey().map() = reduceByKey

	reduceByKey会先在本地进行聚合，而groupByKey不会。

(1)groupByKey:

对rdd中每个key对应的values分组，成一个序列。每组内的元素不一定是有序的。

使用HashPartitioner对结果分区。

主要执行逻辑在combineByKeyWithClassTag

所以：

	作用域是key-value类型的键值对(pair RDD)

	transformation类型的算子，是懒加载的。

	作用：把相同key的values转成一个序列(sequence)

	如果相对序列做聚合操作，可以使用groupByKey，但是优先选择reduceByKey\aggregateByKey
	第二个实现，key-values对被保存在内存中，如果一个key有太多的values,，会导致OutOfMemoryError


(2)reduceByKey:

根据用户传入的函数对每个key对应的所有values做merge操作(具体的操作类型根据用户定义的函数)

在将结果发送给reducer前，首先它会在每个mapper上执行本地的合并，类似于mapreduce中的combiner。

使用HashPartitioner对结果分区

主要执行逻辑在combineByKeyWithClassTag

所以：

	作用域是key-value类型的键值对(pair RDD)，并且只对每个key的value进行处理，
    如果含有多个key的话，那么就对多个values进行处理。

	transformation类型的算子，是懒加载的。

	需要传递一个相关的函数作为参数，这个函数将会被应用到源RDD上并且创建一个新的RDD作为返回结果

