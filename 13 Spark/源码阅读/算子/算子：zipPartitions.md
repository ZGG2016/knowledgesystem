# 算子：zipPartitions

## 1、源码

```java
  /**
   * 通过使用一个函数，将多个RDD按照分区组合成为新的RDD，
   * 需要组合的RDD具有相同的分区数，但对于每个分区内的元素数量没有要求
   *
   * Zip this RDD's partitions with one (or more) RDD(s) and return a new RDD by
   * applying a function to the zipped partitions. Assumes that all the RDDs have the
   * *same number of partitions*, but does *not* require them to have the same number
   * of elements in each partition.
   */
  def zipPartitions[B: ClassTag, V: ClassTag]
      (rdd2: RDD[B], preservesPartitioning: Boolean)
      (f: (Iterator[T], Iterator[B]) => Iterator[V]): RDD[V] = withScope {
    new ZippedPartitionsRDD2(sc, sc.clean(f), this, rdd2, preservesPartitioning)
  }

  def zipPartitions[B: ClassTag, V: ClassTag]
      (rdd2: RDD[B])
      (f: (Iterator[T], Iterator[B]) => Iterator[V]): RDD[V] = withScope {
    zipPartitions(rdd2, preservesPartitioning = false)(f)
  }

  def zipPartitions[B: ClassTag, C: ClassTag, V: ClassTag]
      (rdd2: RDD[B], rdd3: RDD[C], preservesPartitioning: Boolean)
      (f: (Iterator[T], Iterator[B], Iterator[C]) => Iterator[V]): RDD[V] = withScope {
    new ZippedPartitionsRDD3(sc, sc.clean(f), this, rdd2, rdd3, preservesPartitioning)
  }

  def zipPartitions[B: ClassTag, C: ClassTag, V: ClassTag]
      (rdd2: RDD[B], rdd3: RDD[C])
      (f: (Iterator[T], Iterator[B], Iterator[C]) => Iterator[V]): RDD[V] = withScope {
    zipPartitions(rdd2, rdd3, preservesPartitioning = false)(f)
  }

  def zipPartitions[B: ClassTag, C: ClassTag, D: ClassTag, V: ClassTag]
      (rdd2: RDD[B], rdd3: RDD[C], rdd4: RDD[D], preservesPartitioning: Boolean)
      (f: (Iterator[T], Iterator[B], Iterator[C], Iterator[D]) => Iterator[V]): RDD[V] = withScope {
    new ZippedPartitionsRDD4(sc, sc.clean(f), this, rdd2, rdd3, rdd4, preservesPartitioning)
  }

  def zipPartitions[B: ClassTag, C: ClassTag, D: ClassTag, V: ClassTag]
      (rdd2: RDD[B], rdd3: RDD[C], rdd4: RDD[D])
      (f: (Iterator[T], Iterator[B], Iterator[C], Iterator[D]) => Iterator[V]): RDD[V] = withScope {
    zipPartitions(rdd2, rdd3, rdd4, preservesPartitioning = false)(f)
  }
```

## 2、示例

```java
object zipPartitions {
  def main(Args:Array[String]):Unit = {
    val conf = new SparkConf().setAppName("zip").setMaster("local")
    val sc = new SparkContext(conf)

    val rdd1 = sc.parallelize(List(1, 2, 3,4),2)
    val rdd2 = sc.parallelize(List(5, 6, 7, 8),2)

    val prlt = rdd1.zipPartitions(rdd2){
      (iter1,iter2) => {
        var rlt = List[String]()
        while(iter1.hasNext && iter2.hasNext){
          rlt::=(iter1.next() + "_" + iter2.next())
        }
        rlt.iterator
      }
    }

    /**
     * 2_6
     * 1_5
     * 4_8
     * 3_7
     */
    prlt.collect.foreach(println)

  }
}
```