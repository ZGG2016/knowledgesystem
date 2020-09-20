# 算子：distinct

## 1、源码

```java
 /** RDD去重，返回一个新的RDD
   *
   * 指定一个新RDD的分区数
   *
   * Return a new RDD containing the distinct elements in this RDD.
   */
  def distinct(numPartitions: Int)(implicit ord: Ordering[T] = null): RDD[T] = withScope {
  	//reduceByKey((x, y) => x, numPartitions):key相同的分到一个分区，只取其中的key
    map(x => (x, null)).reduceByKey((x, y) => x, numPartitions).map(_._1)
  }

  /**
   * Return a new RDD containing the distinct elements in this RDD.
   */
  def distinct(): RDD[T] = withScope {
    distinct(partitions.length)  //和父RDD的分区数相同
  }

  // Get the array of partitions of this RDD 获取一个数组，其元素为RDD的各个分区
  //final def partitions: Array[Partition]
```

## 2、示例

```java
object distinct {
  def main(Args:Array[String]):Unit = {
    val conf = new SparkConf().setAppName("distinct").setMaster("local")
    val sc = new SparkContext(conf)

    val rdd = sc.parallelize(List(1,2,2,3,3,4,5))
    val rlt1 = rdd.distinct()
    val rlt2 = rdd.distinct(2)

    // 4、1、3、5、2
    rlt1.foreach(println)
    //4、2   |   1、3、5  两个分区
    rlt2.foreach(println)
     
    println(rlt1.getNumPartitions)  //1
    println(rlt2.getNumPartitions)  //2

  }
}
```