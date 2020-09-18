# aggregateByKey算子

## 1、源码

```java
  /**
   * 使用聚合函数和一个中性的"0值"聚合每个key对应的values。
   *
   * 这个函数会返回结果的类型U和rdd的value类型V不同。
   *
   * 因此，需要一个操作将V合并到U，再使用另一个操作合并两个U。
   *
   * 前一个操作用来在一个分区内合并value，后一个操作用来在分区间合并value.
   *
   * 为避免内存分配，这两个函数被允许修改、返回第一个参数，而不是创建一个新的U。
   *
   * Aggregate the values of each key, using given combine functions and a neutral "zero value".
   * This function can return a different result type, U, than the type of the values in this RDD,
   * V. Thus, we need one operation for merging a V into a U and one operation for merging two U's,
   * as in scala.TraversableOnce. The  operation is used for merging values within a
   * partition, and the latter is used for merging values between partitions. To avoid memory
   * allocation, both of these functions are allowed to modify and return their first argument
   * instead of creating a new U.
   */
 //源码参考foldByKey
  def aggregateByKey[U: ClassTag](zeroValue: U, partitioner: Partitioner)(seqOp: (U, V) => U,
      combOp: (U, U) => U): RDD[(K, U)] = self.withScope {
    // Serialize the zero value to a byte array so that we can get a new clone of it on each key
    val zeroBuffer = SparkEnv.get.serializer.newInstance().serialize(zeroValue)
    val zeroArray = new Array[Byte](zeroBuffer.limit)
    zeroBuffer.get(zeroArray)

    lazy val cachedSerializer = SparkEnv.get.serializer.newInstance()
    val createZero = () => cachedSerializer.deserialize[U](ByteBuffer.wrap(zeroArray))

    // We will clean the combiner closure later in `combineByKey`
    val cleanedSeqOp = self.context.clean(seqOp)
    combineByKeyWithClassTag[U]((v: V) => cleanedSeqOp(createZero(), v),
      cleanedSeqOp, combOp, partitioner)
  }

  /**
   * Aggregate the values of each key, using given combine functions and a neutral "zero value".
   * This function can return a different result type, U, than the type of the values in this RDD,
   * V. Thus, we need one operation for merging a V into a U and one operation for merging two U's,
   * as in scala.TraversableOnce. The former operation is used for merging values within a
   * partition, and the latter is used for merging values between partitions. To avoid memory
   * allocation, both of these functions are allowed to modify and return their first argument
   * instead of creating a new U.
   */
  // 指定分区数
  def aggregateByKey[U: ClassTag](zeroValue: U, numPartitions: Int)(seqOp: (U, V) => U,
      combOp: (U, U) => U): RDD[(K, U)] = self.withScope {
    aggregateByKey(zeroValue, new HashPartitioner(numPartitions))(seqOp, combOp)
  }

  /**
   * Aggregate the values of each key, using given combine functions and a neutral "zero value".
   * This function can return a different result type, U, than the type of the values in this RDD,
   * V. Thus, we need one operation for merging a V into a U and one operation for merging two U's,
   * as in scala.TraversableOnce. The former operation is used for merging values within a
   * partition, and the latter is used for merging values between partitions. To avoid memory
   * allocation, both of these functions are allowed to modify and return their first argument
   * instead of creating a new U.
   */
  // 默认分区数
  def aggregateByKey[U: ClassTag](zeroValue: U)(seqOp: (U, V) => U,
      combOp: (U, U) => U): RDD[(K, U)] = self.withScope {
    aggregateByKey(zeroValue, defaultPartitioner(self))(seqOp, combOp)
  }

```

## 2、示例

```java
object aggregateByKey {

  def func2(index:Int,iter:Iterator[Any]):Iterator[Any]={
    iter.toList.map(x=>"分区 "+index+" 的计算结果是 "+x).iterator
  }

  def main(Args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("aggregateByKey").setMaster("local")

    val sc = new SparkContext(conf)

    val data = List((1,3),(1,2),(1,4),(2,3),(3,6),(3,8))
    val rdd = sc.parallelize(data,2)
    
    //rdd.mapPartitionsWithIndex(func2).foreach(println)

    val res  = rdd.aggregateByKey(0)(math.max, _+_)
    res.collect.foreach(println)

  }
}

/**
 * 分区 0 ： (1,3) 、(1,2)、(1,4)
 * 分区 1 ： (2,3)、(3,6) 、(3,8)
 *
 * "0值":0   【第一个参数函数：创建初始值】
 * 对分区 0： (1,4)
 *
 * 对分区 1：(2,3)
 *          (3,8)  【第二个参数函数，追加】、【第三个参数函数，合并】
 *
 * 如果"0值"是5，结果为 (1,5)(2,5)(3,8)
 */
```