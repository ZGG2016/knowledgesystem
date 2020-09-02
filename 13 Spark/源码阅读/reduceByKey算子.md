# reduceByKey算子

算子|含义
---|:---
reduceByKey(func, [numPartitions]) | 当一个(K,V)对数据集调用的时候，返回一个(K, V)对数据集，其中每个 K 的 V 是经过 func 聚合后的结果。它必须是 type (V,V) => V 的类型。像 groupByKey 一样，reduce 任务数可以通过第二个可选的参数配置。


```java
  /**
   * Merge the values for each key using an associative and commutative reduce function. This will
   * also perform the merging locally on each mapper before sending results to a reducer, similarly
   * to a "combiner" in MapReduce. Output will be hash-partitioned with the existing partitioner/
   * parallelism level.
   *
   * 使用一个 reduce 函数合并每个 key 的值。
   *
   * 在发生结果到 reducer 前， 它会在每个 mapper 上执行本地的合并，类型 combiner
   *
   * 输出是根据并行度，哈希分区的。
   * 
   * 这里的 V 是 (K,V) 对数据集中的值
   */
  def reduceByKey(func: (V, V) => V): RDD[(K, V)] = self.withScope {
    reduceByKey(defaultPartitioner(self), func)  //使用了一个分区器
  }

```

```java
  /**
   * Merge the values for each key using an associative and commutative reduce function. This will
   * also perform the merging locally on each mapper before sending results to a reducer, similarly
   * to a "combiner" in MapReduce.
   *
   * 这里的 V 是 (K,V) 对数据集中的值
   *
   * 传入了一个分区器
   */
  def reduceByKey(partitioner: Partitioner, func: (V, V) => V): RDD[(K, V)] = self.withScope {
    combineByKeyWithClassTag[V]((v: V) => v, func, func, partitioner)
  }
```

```java
/**
   * :: Experimental ::
   * Generic function to combine the elements for each key using a custom set of aggregation
   * functions. Turns an RDD[(K, V)] into a result of type RDD[(K, C)], for a "combined type" C
   *
   * 使用自定义的聚合函数合并每个 key 的元素。
   * RDD[(K, V)] ---> RDD[(K, C)]  类型V转成了C
   *
   *
   * Users provide three functions:
   *
   *  - `createCombiner`, which turns a V into a C (e.g., creates a one-element list)
   *  - `mergeValue`, to merge a V into a C (e.g., adds it to the end of a list)
   *  - `mergeCombiners`, to combine two C's into a single one.
   *
   * 用户提供了三种函数：
   *   - createCombiner ： 把一个 V 变成一个 C。（如：创建一个单元素的列表）
   *   - mergeValue ： 将一个 V 合并到一个 C 中。（如：追加到列表尾）
   *   - mergeCombiners ： 两个 C 聚合成一个。
   *
   *
   * In addition, users can control the partitioning of the output RDD, and whether to perform
   * map-side aggregation (if a mapper can produce multiple items with the same key).
   *
   * 用户可以控制 输出 RDD 的分区、在 map 端是否执行聚合操作(在mapper端同一key产生多个项的情况)
   * 【比如reduceByKey有一个分区的参数】、【mapSideCombine参数】
   *
   * @note V and C can be different -- for example, one might group an RDD of type
   * (Int, Int) into an RDD of type (Int, Seq[Int]).
   *
   * V和C的类型可以不同 -- 例如，分组一个 (Int, Int) RDD 成 (Int, Seq[Int]) 类型.
   * 【groupByKey产生的效果，value变成了一个序列】
   *
   */
  @Experimental
  def combineByKeyWithClassTag[C](
      createCombiner: V => C,
      mergeValue: (C, V) => C,
      mergeCombiners: (C, C) => C,
      partitioner: Partitioner,  // 控制 输出 RDD 的分区
      mapSideCombine: Boolean = true,  // 在 map 端是否执行聚合操作
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

```

```java
 /**
   * Choose a partitioner to use for a cogroup-like operation between a number of RDDs.
   *
   * If spark.default.parallelism is set, we'll use the value of SparkContext defaultParallelism
   * as the default partitions number, otherwise we'll use the max number of upstream partitions.
   *
   * When available, we choose the partitioner from rdds with maximum number of partitions. If this
   * partitioner is eligible (number of partitions within an order of maximum number of partitions
   * in rdds), or has partition number higher than default partitions number - we use this
   * partitioner.
   *
   * Otherwise, we'll use a new HashPartitioner with the default partitions number.
   *
   * Unless spark.default.parallelism is set, the number of partitions will be the same as the
   * number of partitions in the largest upstream RDD, as this should be least likely to cause
   * out-of-memory errors.
   *
   * We use two method parameters (rdd, others) to enforce callers passing at least 1 RDD.
   */
  def defaultPartitioner(rdd: RDD[_], others: RDD[_]*): Partitioner = {
    val rdds = (Seq(rdd) ++ others)
    val hasPartitioner = rdds.filter(_.partitioner.exists(_.numPartitions > 0))

    val hasMaxPartitioner: Option[RDD[_]] = if (hasPartitioner.nonEmpty) {
      Some(hasPartitioner.maxBy(_.partitions.length))
    } else {
      None
    }

    val defaultNumPartitions = if (rdd.context.conf.contains("spark.default.parallelism")) {
      rdd.context.defaultParallelism
    } else {
      rdds.map(_.partitions.length).max
    }

    // If the existing max partitioner is an eligible one, or its partitions number is larger
    // than the default number of partitions, use the existing partitioner.
    if (hasMaxPartitioner.nonEmpty && (isEligiblePartitioner(hasMaxPartitioner.get, rdds) ||
        defaultNumPartitions < hasMaxPartitioner.get.getNumPartitions)) {
      hasMaxPartitioner.get.partitioner.get
    } else {
      new HashPartitioner(defaultNumPartitions)
    }
  }
```