# reduceByKey算子

## 1、源码

```java
  /**
   * Merge the values for each key using an associative and commutative reduce function. This will
   * also perform the merging locally on each mapper before sending results to a reducer, similarly
   * to a "combiner" in MapReduce. Output will be hash-partitioned with the existing partitioner/
   * parallelism level.
   *
   * 使用一个 reduce 函数合并每个 key 的值。
   *
   * 在发生结果到 reducer 前， 它会在每个 mapper 上执行本地的合并，类似 combiner
   *
   * 输出是根据并行度，进行哈希分区的。
   * 
   * 这里的 V 是 (K,V) 对数据集中的值
   */
  def reduceByKey(func: (V, V) => V): RDD[(K, V)] = self.withScope {
    reduceByKey(defaultPartitioner(self), func)  //默认
  }

  /**
   * Merge the values for each key using an associative and commutative reduce function. This will
   * also perform the merging locally on each mapper before sending results to a reducer, similarly
   * to a "combiner" in MapReduce. Output will be hash-partitioned with numPartitions partitions.
   */
  def reduceByKey(func: (V, V) => V, numPartitions: Int): RDD[(K, V)] = self.withScope {
    reduceByKey(new HashPartitioner(numPartitions), func)  //指定
  }

  /**
   * Merge the values for each key using an associative and commutative reduce function. This will
   * also perform the merging locally on each mapper before sending results to a reducer, similarly
   * to a "combiner" in MapReduce.
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
   * RDD[(K, V)] ---> RDD[(K, C)]  C是一个聚合类型
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

    // 是不是数组类型
    // private[spark] def keyClass: Class[_] = kt.runtimeClass 
    if (keyClass.isArray) {
      if (mapSideCombine) {  // 默认true，数组类型的key不能本地聚合
        throw new SparkException("Cannot use map-side combining with array keys.")
      }
      // HashPartitioner 不能分区数组类型的key
      if (partitioner.isInstanceOf[HashPartitioner]) {
        throw new SparkException("HashPartitioner cannot partition array keys.")
      }
    }

    // Aggregator：聚合数据的函数集合
    // @param createCombiner function to create the initial value of the aggregation.
    // @param mergeValue function to merge a new value into the aggregation   
    // @param mergeCombiners function to merge outputs from multiple mergeValue function.
    val aggregator = new Aggregator[K, V, C](
      // Clean a closure to make it ready to be serialized and sent to tasks。
      // 具体见ClosureCleaner
      self.context.clean(createCombiner),
      self.context.clean(mergeValue),
      self.context.clean(mergeCombiners))


    //Some(partitioner)：参数传入的分区器
    // 当前rdd的分区是不是和传入的分区相同
    if (self.partitioner == Some(partitioner)) { 
      //相同的话，终止任务（不做shuffle了）
      self.mapPartitions(iter => {

        //Spark 的一个任务操作一个分区，mapPartitions操作的对象是一个分区
        // 取的是一个分区的任务信息
        val context = TaskContext.get()

        //任务终止的迭代器
        new InterruptibleIterator(context, aggregator.combineValuesByKey(iter, context))
      }, preservesPartitioning = true) // 保留父RDD的分区信息
    } else {
      // 不相同的话，创建ShuffledRDD对象，但没有执行具体的操作。(transformation懒加载)
      new ShuffledRDD[K, V, C](self, partitioner)
        .setSerializer(serializer)
        .setAggregator(aggregator)
        .setMapSideCombine(mapSideCombine)
    }
  }

```

## 2、示例

```java
object reduceByKey {
  def main(Args:Array[String]):Unit = {
    val conf = new SparkConf().setAppName("reduceByKey").setMaster("local")
    val sc = new SparkContext(conf)

    val lines = sc.textFile("src/main/data/reduceByKey.txt")

    //val pairs = lines.map(s=>(s,1))
    val pairs = lines.map((_,1))

    //val count = pairs.reduceByKey((a,b)=>a+b)
    val count = pairs.reduceByKey(_+_)
    println(count.collect().toBuffer) //ArrayBuffer((a,4), (b,3))
  }
}
```