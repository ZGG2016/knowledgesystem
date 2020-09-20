# 算子：repartition

## 1、源码

```java
  /**
   * 改变当前rdd的分区数，到numPartitions值。【所以，可增大，可减少】
   *
   * 如果想要减少分区数，优先使用coalesce，可避免shuffle
   *
   * Return a new RDD that has exactly numPartitions partitions.
   *
   * Can increase or decrease the level of parallelism in this RDD. Internally, this uses
   * a shuffle to redistribute data.
   *
   * If you are decreasing the number of partitions in this RDD, consider using `coalesce`,
   * which can avoid performing a shuffle.
   *
   * TODO Fix the Shuffle+Repartition data loss issue described in SPARK-23207.
   */
  def repartition(numPartitions: Int)(implicit ord: Ordering[T] = null): RDD[T] = withScope {
    coalesce(numPartitions, shuffle = true)
  }
```

## 2、示例

```java
object repartition {
  def main(Args:Array[String]): Unit = {
    val conf = new SparkConf().setAppName("repartition").setMaster("local")
    val sc = new SparkContext(conf)

    val data = sc.textFile("src/main/data/coalesce.txt",10)

    val rlt1 = data.repartition(4)
    val rlt2 = data.repartition(100)

    println(data.partitions.length) //10
    println(rlt1.partitions.length) //4
    println(rlt2.partitions.length) //100
  }
}
```