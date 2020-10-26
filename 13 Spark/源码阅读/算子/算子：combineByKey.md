# combineByKey算子

PairRDDFunctions.scala

## 1、源码

```java
   // 见reduceByKey源码
  /**
   * :: Experimental ::
   * Generic function to combine the elements for each key using a custom set of aggregation
   * functions. Turns an RDD[(K, V)] into a result of type RDD[(K, C)], for a "combined type" C
   *
   * Users provide three functions:
   *
   *  - `createCombiner`, which turns a V into a C (e.g., creates a one-element list)
   *  - `mergeValue`, to merge a V into a C (e.g., adds it to the end of a list)
   *  - `mergeCombiners`, to combine two C's into a single one.
   *
   * In addition, users can control the partitioning of the output RDD, and whether to perform
   * map-side aggregation (if a mapper can produce multiple items with the same key).
   *
   * @note V and C can be different -- for example, one might group an RDD of type
   * (Int, Int) into an RDD of type (Int, Seq[Int]).
   */
  @Experimental
  def combineByKeyWithClassTag[C](
      createCombiner: V => C,
      mergeValue: (C, V) => C,
      mergeCombiners: (C, C) => C,
      partitioner: Partitioner,
      mapSideCombine: Boolean = true,
      serializer: Serializer = null)(implicit ct: ClassTag[C]): RDD[(K, C)] = self.withScope {
    require(mergeCombiners != null, "mergeCombiners must be defined") // required as of Spark 0.9.0
    if (keyClass.isArray) {
      if (mapSideCombine) {
        throw new SparkException("Cannot use map-side combining with array keys.")
      }
      if (partitioner.isInstanceOf[HashPartitioner]) {
        throw new SparkException("HashPartitioner cannot partition array keys.")
      }
    }
    val aggregator = new Aggregator[K, V, C](
      self.context.clean(createCombiner),
      self.context.clean(mergeValue),
      self.context.clean(mergeCombiners))
    if (self.partitioner == Some(partitioner)) {
      self.mapPartitions(iter => {
        val context = TaskContext.get()
        new InterruptibleIterator(context, aggregator.combineValuesByKey(iter, context))
      }, preservesPartitioning = true)
    } else {
      new ShuffledRDD[K, V, C](self, partitioner)
        .setSerializer(serializer)
        .setAggregator(aggregator)
        .setMapSideCombine(mapSideCombine)
    }
  }

  /**
   * 使用一系列的自定义的聚合函数 合并每个key的value.
   *
   * 这个函数不向shuffle提供 combiner classtag information（???）
   *
   * Generic function to combine the elements for each key using a custom set of aggregation
   * functions. This method is here for backward compatibility. It does not provide combiner
   * classtag information to the shuffle.
   *
   * @see `combineByKeyWithClassTag`
   */
  def combineByKey[C](
      createCombiner: V => C,
      mergeValue: (C, V) => C,
      mergeCombiners: (C, C) => C,
      partitioner: Partitioner,          // 分区器
      mapSideCombine: Boolean = true,   //是否在map端本地合并，默认true
      serializer: Serializer = null): RDD[(K, C)] = self.withScope {
    combineByKeyWithClassTag(createCombiner, mergeValue, mergeCombiners,
      partitioner, mapSideCombine, serializer)(null)
  }

  /**
   * 简化版的combineByKeyWithClassTag，对输出RDD进行hash分区。
   * 
   *
   * Simplified version of combineByKeyWithClassTag that hash-partitions the output RDD.
   * This method is here for backward compatibility. It does not provide combiner
   * classtag information to the shuffle.
   *
   * @see `combineByKeyWithClassTag`
   */
  def combineByKey[C](
      createCombiner: V => C,
      mergeValue: (C, V) => C,
      mergeCombiners: (C, C) => C,
      numPartitions: Int): RDD[(K, C)] = self.withScope {
    combineByKeyWithClassTag(createCombiner, mergeValue, mergeCombiners, numPartitions)(null)
  }

  /**
   * 简化版的combineByKeyWithClassTag，对输出RDD进行hash分区。
   *
   * :: Experimental ::
   * Simplified version of combineByKeyWithClassTag that hash-partitions the output RDD.
   */
  @Experimental
  def combineByKeyWithClassTag[C](
      createCombiner: V => C,
      mergeValue: (C, V) => C,
      mergeCombiners: (C, C) => C,
      numPartitions: Int)(implicit ct: ClassTag[C]): RDD[(K, C)] = self.withScope {
    combineByKeyWithClassTag(createCombiner, mergeValue, mergeCombiners,
      new HashPartitioner(numPartitions))
  }

    /**
   * Simplified version of combineByKeyWithClassTag that hash-partitions the resulting RDD using the
   * existing partitioner/parallelism level. This method is here for backward compatibility. It
   * does not provide combiner classtag information to the shuffle.
   *
   * @see `combineByKeyWithClassTag`
   */
  def combineByKey[C](
      createCombiner: V => C,
      mergeValue: (C, V) => C,
      mergeCombiners: (C, C) => C): RDD[(K, C)] = self.withScope {
    combineByKeyWithClassTag(createCombiner, mergeValue, mergeCombiners)(null)
  }

  /**
   * :: Experimental ::
   * Simplified version of combineByKeyWithClassTag that hash-partitions the resulting RDD using the
   * existing partitioner/parallelism level.
   */
  @Experimental
  def combineByKeyWithClassTag[C](
      createCombiner: V => C,
      mergeValue: (C, V) => C,
      mergeCombiners: (C, C) => C)(implicit ct: ClassTag[C]): RDD[(K, C)] = self.withScope {
    combineByKeyWithClassTag(createCombiner, mergeValue, mergeCombiners, defaultPartitioner(self))
  }

```

## 2、示例

```java
object combineByKey {
  def main(Args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("aggregateByKey").setMaster("local")

    val sc = new SparkContext(conf)

    val data = List((1,3),(1,2),(1,4),(2,3),(3,6),(3,8))
    val rdd = sc.parallelize(data,2)

    val rlt  = rdd.combineByKey(
      (v:Int) => (v,0),
      (acc:(Int,Int),v:Int) => (acc._1+v,acc._2+v),  //要定义返回值类型
      (r1:(Int,Int),r2:(Int,Int)) => (r1._1+r2._1,r1._2+r2._2)  //这里的r就是上步骤的acc
    )
    rlt.collect().foreach(println)  //(2,(3,0))、(1,(9,6))、(3,(14,8))

  }
}

/**
 * 分区 0 ： (1,3) 、(1,2)、(1,4)
 * 分区 1 ： (2,3)、(3,6) 、(3,8)
 *
 * 1.createCombiner:  (v:Int) => (v,0),  【将第一个key出现的v转换成计算规则】
 * 2.mergeValue: (acc:(Int,Int),v:Int) => (acc._1+v,acc._2+v), 【分区内计算规则】
 * 3.mergeCombiners: (r1:(Int,Int),r2:(Int,Int)) => (r1._1+r2._1,r1._2+r2._2) 【分区间计算规则】
 * 【对于第三步骤：如果不同分区有相同的key，就会执行mergeCombiners。】
 * 【如分区0的key为(1,(9,6))，分区1中也有一个key是(1,(1,1))，那么结果就是(1,(10，7))】
 *
 *
 * 对于分区0：
 *        1.         2.                                   3.
 *      (3,0)  --> (3,0)
 *        2        ((3,0),2) --> (5,2)
 *        4        ((5,2),4) --> (9,6)  --> (1,(9,6))  --> (1,(9,6))
 *
 * 对于分区1：
 *      (3,0)  --> (3,0)                --> (2,(3,0))  --> (2,(3,0))
 *      (6,0)  --> (6,0)
 *        8        ((6,0),8) --> (14,8) --> (3,(14,8)) --> (3,(14,8))
 */
```