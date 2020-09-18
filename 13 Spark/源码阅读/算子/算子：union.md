# 算子：union

## 1、源码

```java
  /**
   * 合并两个rdd。可能会有重复值，可以使用.distinct()去重
   *
   * Return the union of this RDD and another one. Any identical elements will appear multiple
   * times (use `.distinct()` to eliminate them).
   */
  def union(other: RDD[T]): RDD[T] = withScope {
    sc.union(this, other)
  }

  /**
   * Return the union of this RDD and another one. Any identical elements will appear multiple
   * times (use `.distinct()` to eliminate them).
   */
  // 实际调用上面的union
  def ++(other: RDD[T]): RDD[T] = withScope {
    this.union(other)
  }

  /** Build the union of a list of RDDs passed as variable-length arguments. */
  def union[T: ClassTag](first: RDD[T], rest: RDD[T]*): RDD[T] = withScope {
    union(Seq(first) ++ rest)  //连接两个集合
  }

  /** Build the union of a list of RDDs. */
  def union[T: ClassTag](rdds: Seq[RDD[T]]): RDD[T] = withScope {
  	// 删掉为空的分区
    val nonEmptyRdds = rdds.filter(!_.partitions.isEmpty)
    //取出所有分区器，并利用Set去重
    val partitioners = nonEmptyRdds.flatMap(_.partitioner).toSet
    //如果每个rdd都定义了分区器, 而且全部相同, 就使用此分区器整合所有rdd
    //【结合PartitionerAwareUnionRDD类理解】
    if (nonEmptyRdds.forall(_.partitioner.isDefined) && partitioners.size == 1) {
      new PartitionerAwareUnionRDD(this, nonEmptyRdds)  //this是当前SparkContext
    } else {
      // 否则就保留各自的分区
      new UnionRDD(this, nonEmptyRdds)
    }
  }
//参考理解：https://blog.csdn.net/IAmListening/article/details/94617939
  //def isEmpty: Boolean = { length == 0 }
  
  // /* Optionally overridden by subclasses to specify how they are partitioned. */
  // @transient val partitioner: Option[Partitioner] = None

  //  override /*TraversableLike*/ 
  // def forall(p: A => Boolean): Boolean = iterator.forall(p)
  //
 /** Tests whether a predicate holds for all values produced by this iterator.
   *  $mayNotTerminateInf  测试是否持有迭代器生成的所有制
   *
   *  @param   p     the predicate used to test elements.
   *  @return        `true` if the given predicate `p` holds for all values
   *                 produced by this iterator, otherwise `false`.
   *  @note          Reuse: $consumesIterator
   *
   *  def forall(p: A => Boolean): Boolean = {
   *  	var res = true
   * 	while (res && hasNext) res = p(next())
   *  	res
   *  }
  */

  // PartitionerAwareUnionRDD：
  // 是一个 可以接收 使用相同分区器分区的多个RDD，并组合它们成一个RDD，当保留分区器时.

```

## 2、示例

```java
object union {
  def main(Args:Array[String]): Unit = {
    val conf = new SparkConf().setAppName("mapPartitions").setMaster("local")
    val sc = new SparkContext(conf)

    val rdd1 = sc.parallelize(List(('a',1),('b',1)))
    val rdd2 = sc.parallelize(List(('c',1),('d',1),('a',1)))

    //(a,1)(b,1)(c,1)(d,1)(a,1)
    val rlt1 = rdd1.union(rdd2)
    rlt1.collect.foreach(println)
    println("--------------------union不去重--------------------")

    //(d,1)(b,1)(a,1)(c,1)
    val rlt2 = rdd1.union(rdd2).distinct()
    rlt2.collect.foreach(println)
    println("--------------------union去重--------------------")

    //(a,1)(b,1)(c,1)(d,1)(a,1)
    val rlt3 = rdd1.++(rdd2)
    rlt3.collect().foreach(println)
    println("--------------------++不去重--------------------")

  }
}
```