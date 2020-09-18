# 算子：join

## 1、源码

```java
  /**
   * RDD1.join(RDD2)：对于两个k相同的(k,v)，组合成(k, (v1, v2))。没有匹配到的，就丢弃。
   *
   * 类似sql里的INNER JOIN 【交集】
   *
   * 可以指定分区器
   *
   * Return an RDD containing all pairs of elements with matching keys in `this` and `other`. Each
   * pair of elements will be returned as a (k, (v1, v2)) tuple, where (k, v1) is in `this` and
   * (k, v2) is in `other`. Uses the given Partitioner to partition the output RDD.
   */
  def join[W](other: RDD[(K, W)], partitioner: Partitioner): RDD[(K, (V, W))] = self.withScope {  //flatMapValues ？？？
    this.cogroup(other, partitioner).flatMapValues( pair =>
      for (v <- pair._1.iterator; w <- pair._2.iterator) yield (v, w)
      // for循环这行：每次循环都返回两个迭代器v\w，yield以元组的形式保存下来
    )
  }

  /**
   * 类似sql里的LEFT OUTER JOIN 【以JOIN关键字左边的表为基准】
   *
   * Perform a left outer join of `this` and `other`. For each element (k, v) in `this`, the
   * resulting RDD will either contain all pairs (k, (v, Some(w))) for w in `other`, or the
   * pair (k, (v, None)) if no elements in `other` have key k. Uses the given Partitioner to
   * partition the output RDD.
   */
  def leftOuterJoin[W](
      other: RDD[(K, W)],
      partitioner: Partitioner): RDD[(K, (V, Option[W]))] = self.withScope {
    this.cogroup(other, partitioner).flatMapValues { pair =>
      if (pair._2.isEmpty) {
        pair._1.iterator.map(v => (v, None))
      } else {
        for (v <- pair._1.iterator; w <- pair._2.iterator) yield (v, Some(w))
      }
    }
  }

  /**
   * 类似sql里的RIGHT OUTER JOIN 【以JOIN关键字右边的表为基准】
   *
   * Perform a right outer join of `this` and `other`. For each element (k, w) in `other`, the
   * resulting RDD will either contain all pairs (k, (Some(v), w)) for v in `this`, or the
   * pair (k, (None, w)) if no elements in `this` have key k. Uses the given Partitioner to
   * partition the output RDD.
   */
  def rightOuterJoin[W](other: RDD[(K, W)], partitioner: Partitioner)
      : RDD[(K, (Option[V], W))] = self.withScope {
    this.cogroup(other, partitioner).flatMapValues { pair =>
      if (pair._1.isEmpty) {
        pair._2.iterator.map(w => (None, w))
      } else {
        for (v <- pair._1.iterator; w <- pair._2.iterator) yield (Some(v), w)
      }
    }
  }

  /**
   * 类似sql里的FULL JOIN 【以JOIN关键字左右两边的表为基准】
   *
   * Perform a full outer join of `this` and `other`. For each element (k, v) in `this`, the
   * resulting RDD will either contain all pairs (k, (Some(v), Some(w))) for w in `other`, or
   * the pair (k, (Some(v), None)) if no elements in `other` have key k. Similarly, for each
   * element (k, w) in `other`, the resulting RDD will either contain all pairs
   * (k, (Some(v), Some(w))) for v in `this`, or the pair (k, (None, Some(w))) if no elements
   * in `this` have key k. Uses the given Partitioner to partition the output RDD.
   */
  def fullOuterJoin[W](other: RDD[(K, W)], partitioner: Partitioner)
      : RDD[(K, (Option[V], Option[W]))] = self.withScope {
    this.cogroup(other, partitioner).flatMapValues {
      case (vs, Seq()) => vs.iterator.map(v => (Some(v), None))
      case (Seq(), ws) => ws.iterator.map(w => (None, Some(w)))
      case (vs, ws) => for (v <- vs.iterator; w <- ws.iterator) yield (Some(v), Some(w))
    }
  }
```

**上面使用自定义分区器，下面的方法是使用默认分区器或哈希分区器，如果传入分区数参数，那么使用的是哈希分区器**

```java
  /**
   *  Performs a hash join across the cluster.
   *
   * Return an RDD containing all pairs of elements with matching keys in `this` and `other`. Each
   * pair of elements will be returned as a (k, (v1, v2)) tuple, where (k, v1) is in `this` and
   * (k, v2) is in `other`. Performs a hash join across the cluster.
   */
  def join[W](other: RDD[(K, W)]): RDD[(K, (V, W))] = self.withScope {
    join(other, defaultPartitioner(self, other))
  }

  /**
   * Return an RDD containing all pairs of elements with matching keys in `this` and `other`. Each
   * pair of elements will be returned as a (k, (v1, v2)) tuple, where (k, v1) is in `this` and
   * (k, v2) is in `other`. Performs a hash join across the cluster.
   */
  def join[W](other: RDD[(K, W)], numPartitions: Int): RDD[(K, (V, W))] = self.withScope {
    join(other, new HashPartitioner(numPartitions))
  }

  /**
   * Perform a left outer join of `this` and `other`. For each element (k, v) in `this`, the
   * resulting RDD will either contain all pairs (k, (v, Some(w))) for w in `other`, or the
   * pair (k, (v, None)) if no elements in `other` have key k. Hash-partitions the output
   * using the existing partitioner/parallelism level.
   */
  def leftOuterJoin[W](other: RDD[(K, W)]): RDD[(K, (V, Option[W]))] = self.withScope {
    leftOuterJoin(other, defaultPartitioner(self, other))
  }

  /**
   * Perform a left outer join of `this` and `other`. For each element (k, v) in `this`, the
   * resulting RDD will either contain all pairs (k, (v, Some(w))) for w in `other`, or the
   * pair (k, (v, None)) if no elements in `other` have key k. Hash-partitions the output
   * into `numPartitions` partitions.
   */
  def leftOuterJoin[W](
      other: RDD[(K, W)],
      numPartitions: Int): RDD[(K, (V, Option[W]))] = self.withScope {
    leftOuterJoin(other, new HashPartitioner(numPartitions))
  }

  /**
   * Perform a right outer join of `this` and `other`. For each element (k, w) in `other`, the
   * resulting RDD will either contain all pairs (k, (Some(v), w)) for v in `this`, or the
   * pair (k, (None, w)) if no elements in `this` have key k. Hash-partitions the resulting
   * RDD using the existing partitioner/parallelism level.
   */
  def rightOuterJoin[W](other: RDD[(K, W)]): RDD[(K, (Option[V], W))] = self.withScope {
    rightOuterJoin(other, defaultPartitioner(self, other))
  }

  /**
   * Perform a right outer join of `this` and `other`. For each element (k, w) in `other`, the
   * resulting RDD will either contain all pairs (k, (Some(v), w)) for v in `this`, or the
   * pair (k, (None, w)) if no elements in `this` have key k. Hash-partitions the resulting
   * RDD into the given number of partitions.
   */
  def rightOuterJoin[W](
      other: RDD[(K, W)],
      numPartitions: Int): RDD[(K, (Option[V], W))] = self.withScope {
    rightOuterJoin(other, new HashPartitioner(numPartitions))
  }

  /**
   * Perform a full outer join of `this` and `other`. For each element (k, v) in `this`, the
   * resulting RDD will either contain all pairs (k, (Some(v), Some(w))) for w in `other`, or
   * the pair (k, (Some(v), None)) if no elements in `other` have key k. Similarly, for each
   * element (k, w) in `other`, the resulting RDD will either contain all pairs
   * (k, (Some(v), Some(w))) for v in `this`, or the pair (k, (None, Some(w))) if no elements
   * in `this` have key k. Hash-partitions the resulting RDD using the existing partitioner/
   * parallelism level.
   */
  def fullOuterJoin[W](other: RDD[(K, W)]): RDD[(K, (Option[V], Option[W]))] = self.withScope {
    fullOuterJoin(other, defaultPartitioner(self, other))
  }

  /**
   * Perform a full outer join of `this` and `other`. For each element (k, v) in `this`, the
   * resulting RDD will either contain all pairs (k, (Some(v), Some(w))) for w in `other`, or
   * the pair (k, (Some(v), None)) if no elements in `other` have key k. Similarly, for each
   * element (k, w) in `other`, the resulting RDD will either contain all pairs
   * (k, (Some(v), Some(w))) for v in `this`, or the pair (k, (None, Some(w))) if no elements
   * in `this` have key k. Hash-partitions the resulting RDD into the given number of partitions.
   */
  def fullOuterJoin[W](
      other: RDD[(K, W)],
      numPartitions: Int): RDD[(K, (Option[V], Option[W]))] = self.withScope {
    fullOuterJoin(other, new HashPartitioner(numPartitions))
  }
```

## 2、示例

类似sql里join，只不过这里使用相同的key匹配。

```java
bject join {
  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("join.md").setMaster("local")
    val sc = new SparkContext(conf)

    val rdd1 = sc.parallelize(Array(("1", "Spark"), ("2", "Hadoop"), ("3", "Scala"), ("4", "Java")), 2)
    val rdd2 = sc.parallelize(Array(("1", "30K"), ("2", "15K"), ("3", "25K"), ("5", "10K")), 2)

    val rlt1 = rdd1.join(rdd2)
    //(2,(Hadoop,15K))、(3,(Scala,25K))、(1,(Spark,30K))
    rlt1.collect.foreach(println)
    println("---------join---------")

    val rlt2 = rdd1.leftOuterJoin(rdd2)
    //(4,(Java,None))、(2,(Hadoop,Some(15K)))、(3,(Scala,Some(25K)))、(1,(Spark,Some(30K)))
    rlt2.collect.foreach(println)
    println("---------leftOuterJoin---------")

    val rlt3 = rdd1.rightOuterJoin(rdd2)
    //(2,(Some(Hadoop),15K))、(5,(None,10K))、(3,(Some(Scala),25K))、(1,(Some(Spark),30K))
    rlt3.collect.foreach(println)
    println("---------rightOuterJoin---------")


    val rlt4 = rdd1.fullOuterJoin(rdd2)
    //(4,(Some(Java),None))、(2,(Some(Hadoop),Some(15K)))、(5,(None,Some(10K)))、(3,(Some(Scala),Some(25K)))、(1,(Some(Spark),Some(30K)))
    rlt4.collect.foreach(println)
    println("---------fullOuterJoin---------")

    val rlt5 = rdd1.join(rdd2,2)
    //(2,(Hadoop,15K))、(3,(Scala,25K))、(1,(Spark,30K))
    rlt5.collect.foreach(println)
    println("---------指定分区数、join---------")

  }
}

```