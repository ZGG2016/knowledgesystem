# 算子：cogroup

## 1、源码

**针对cogroup，可以组合2、3、4个RDD，可以使用默认分区数或指定分区数(哈希)。**

```java
  /**
   * 将多个RDD中同一个Key对应的Value以元组的形式组合到一起。
   *
   * 包含本身，一共四个RDD。
   * 
   * For each key k in `this` or `other1` or `other2` or `other3`,
   * return a resulting RDD that contains a tuple with the list of values
   * for that key in `this`, `other1`, `other2` and `other3`.
   */
  def cogroup[W1, W2, W3](other1: RDD[(K, W1)],
      other2: RDD[(K, W2)],
      other3: RDD[(K, W3)],
      partitioner: Partitioner)
      : RDD[(K, (Iterable[V], Iterable[W1], Iterable[W2], Iterable[W3]))] = self.withScope {
     // HashPartitioner 分区器不能对数组进行分区
    if (partitioner.isInstanceOf[HashPartitioner] && keyClass.isArray) {
      throw new SparkException("HashPartitioner cannot partition array keys.")
    }
    /**
      * CoGroupedRDD:An RDD that cogroups its parents. 
      * For each key k in parent RDDs, the resulting RDD contains a tuple with the list of values for that key.
      *
      * 对于其父RDDs，将相同key的value组合到一起。
      */
    val cg = new CoGroupedRDD[K](Seq(self, other1, other2, other3), partitioner)
    
    //对每个value,即Seq(self, other1, other2, other3)，判断其类型
    cg.mapValues { case Array(vs, w1s, w2s, w3s) =>
       (vs.asInstanceOf[Iterable[V]],
         w1s.asInstanceOf[Iterable[W1]],
         w2s.asInstanceOf[Iterable[W2]],
         w3s.asInstanceOf[Iterable[W3]])
    }
  }

  /**
   * 包含本身，一共两个RDD。
   * 
   * For each key k in `this` or `other`, return a resulting RDD that contains a tuple with the
   * list of values for that key in `this` as well as `other`.
   */
  def cogroup[W](other: RDD[(K, W)], partitioner: Partitioner)
      : RDD[(K, (Iterable[V], Iterable[W]))] = self.withScope {
    if (partitioner.isInstanceOf[HashPartitioner] && keyClass.isArray) {
      throw new SparkException("HashPartitioner cannot partition array keys.")
    }
    val cg = new CoGroupedRDD[K](Seq(self, other), partitioner)
    cg.mapValues { case Array(vs, w1s) =>
      (vs.asInstanceOf[Iterable[V]], w1s.asInstanceOf[Iterable[W]])
    }
  }

  /**
   * 包含本身，一共3个RDD。
   * 
   * For each key k in `this` or `other1` or `other2`, return a resulting RDD that contains a
   * tuple with the list of values for that key in `this`, `other1` and `other2`.
   */
  def cogroup[W1, W2](other1: RDD[(K, W1)], other2: RDD[(K, W2)], partitioner: Partitioner)
      : RDD[(K, (Iterable[V], Iterable[W1], Iterable[W2]))] = self.withScope {
    if (partitioner.isInstanceOf[HashPartitioner] && keyClass.isArray) {
      throw new SparkException("HashPartitioner cannot partition array keys.")
    }
    val cg = new CoGroupedRDD[K](Seq(self, other1, other2), partitioner)
    cg.mapValues { case Array(vs, w1s, w2s) =>
      (vs.asInstanceOf[Iterable[V]],
        w1s.asInstanceOf[Iterable[W1]],
        w2s.asInstanceOf[Iterable[W2]])
    }
  }

//---------------------------------------------------------------------------

  /**
   * 包含本身，一共4个RDD。 使用默认分区器，实际调用的是第一个cogroup
   * 
   * For each key k in `this` or `other1` or `other2` or `other3`,
   * return a resulting RDD that contains a tuple with the list of values
   * for that key in `this`, `other1`, `other2` and `other3`.
   */
  def cogroup[W1, W2, W3](other1: RDD[(K, W1)], other2: RDD[(K, W2)], other3: RDD[(K, W3)])
      : RDD[(K, (Iterable[V], Iterable[W1], Iterable[W2], Iterable[W3]))] = self.withScope {
    cogroup(other1, other2, other3, defaultPartitioner(self, other1, other2, other3))
  }

  /**
   * 包含本身，一共2个RDD。 使用默认分区器，实际调用的是前面的cogroup
   * For each key k in `this` or `other`, return a resulting RDD that contains a tuple with the
   * list of values for that key in `this` as well as `other`.
   */
  def cogroup[W](other: RDD[(K, W)]): RDD[(K, (Iterable[V], Iterable[W]))] = self.withScope {
    cogroup(other, defaultPartitioner(self, other))
  }

  /**
   * 包含本身，一共3个RDD。 使用默认分区器，实际调用的是前面的cogroup
   *
   * For each key k in `this` or `other1` or `other2`, return a resulting RDD that contains a
   * tuple with the list of values for that key in `this`, `other1` and `other2`.
   */
  def cogroup[W1, W2](other1: RDD[(K, W1)], other2: RDD[(K, W2)])
      : RDD[(K, (Iterable[V], Iterable[W1], Iterable[W2]))] = self.withScope {
    cogroup(other1, other2, defaultPartitioner(self, other1, other2))
  }

  /**
   * 包含本身，一共2个RDD。 指定分区数，使用哈希分区器，实际调用的是前面的cogroup
   *
   * For each key k in `this` or `other`, return a resulting RDD that contains a tuple with the
   * list of values for that key in `this` as well as `other`.
   */
  def cogroup[W](
      other: RDD[(K, W)],
      numPartitions: Int): RDD[(K, (Iterable[V], Iterable[W]))] = self.withScope {
    cogroup(other, new HashPartitioner(numPartitions))
  }

  /**
   * 包含本身，一共3个RDD。 指定分区数，使用哈希分区器，实际调用的是前面的cogroup
   *
   * For each key k in `this` or `other1` or `other2`, return a resulting RDD that contains a
   * tuple with the list of values for that key in `this`, `other1` and `other2`.
   */
  def cogroup[W1, W2](other1: RDD[(K, W1)], other2: RDD[(K, W2)], numPartitions: Int)
      : RDD[(K, (Iterable[V], Iterable[W1], Iterable[W2]))] = self.withScope {
    cogroup(other1, other2, new HashPartitioner(numPartitions))
  }

  /**
   * 包含本身，一共4个RDD。 指定分区数，使用哈希分区器，实际调用的是前面的cogroup
   *
   * For each key k in `this` or `other1` or `other2` or `other3`,
   * return a resulting RDD that contains a tuple with the list of values
   * for that key in `this`, `other1`, `other2` and `other3`.
   */
  def cogroup[W1, W2, W3](other1: RDD[(K, W1)],
      other2: RDD[(K, W2)],
      other3: RDD[(K, W3)],
      numPartitions: Int)
      : RDD[(K, (Iterable[V], Iterable[W1], Iterable[W2], Iterable[W3]))] = self.withScope {
    cogroup(other1, other2, other3, new HashPartitioner(numPartitions))
  }
```

## 2、示例

```java
object cogroup {
  def main(Args:Array[String]): Unit = {
    val sparkConf = new SparkConf().setAppName("cogroup").setMaster("local")
    val sc = new SparkContext(sparkConf)

    val rdd1 = sc.parallelize(Array(("aa", 1), ("bb", 5), ("cc", 9)))
    val rdd2 = sc.parallelize(Array(("aa", 2), ("dd", 6), ("aa", 10)))
    val rdd3 = sc.parallelize(Array(("aa", 3), ("bb", 7), ("cc", 11)))
    val rdd4 = sc.parallelize(Array(("aa", 4), ("dd", 8), ("aa", 12)))
    
    /**
     * (aa,(CompactBuffer(1),CompactBuffer(2, 10)))
     * (dd,(CompactBuffer(),CompactBuffer(6)))
     * (bb,(CompactBuffer(5),CompactBuffer()))
     * (cc,(CompactBuffer(9),CompactBuffer()))
     */
    val rlt1 = rdd1.cogroup(rdd2)
    rlt1.collect.foreach(println)
    println("--------------连接两个RDD--------------")

    /**
     * (aa,(CompactBuffer(1),CompactBuffer(2, 10)))
     * (dd,(CompactBuffer(),CompactBuffer(6)))
     * (bb,(CompactBuffer(5),CompactBuffer()))
     * (cc,(CompactBuffer(9),CompactBuffer()))
     */
    val prlt = rdd1.cogroup(rdd2,2)
    prlt.collect.foreach(println)
    println("--------------指定分区数，连接两个RDD--------------")

    /**
     * (aa,(CompactBuffer(1),CompactBuffer(2, 10),CompactBuffer(3)))
     * (dd,(CompactBuffer(),CompactBuffer(6),CompactBuffer()))
     * (bb,(CompactBuffer(5),CompactBuffer(),CompactBuffer(7)))
     * (cc,(CompactBuffer(9),CompactBuffer(),CompactBuffer(11)))
     * 
     */
    val rlt2 = rdd1.cogroup(rdd2,rdd3)
    rlt2.collect.foreach(println)
    println("--------------连接三个RDD--------------")

    /**
     * (aa,(CompactBuffer(1),CompactBuffer(2, 10),CompactBuffer(3),CompactBuffer(4, 12)))
     * (dd,(CompactBuffer(),CompactBuffer(6),CompactBuffer(),CompactBuffer(8)))
     * (bb,(CompactBuffer(5),CompactBuffer(),CompactBuffer(7),CompactBuffer()))
     * (cc,(CompactBuffer(9),CompactBuffer(),CompactBuffer(11),CompactBuffer()))
     */
    val rlt3 = rdd1.cogroup(rdd2,rdd3,rdd4)
    rlt3.collect.foreach(println)
    println("--------------连接四个RDD--------------")


  }
}

```