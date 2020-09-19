# 算子：countByValue

## 1、源码

```java
  /**
   *  这个rdd中，统计唯一值的个数(不是<k,v>里的v)，并以(value, count)本地map的形式返回。
   *
   *  只有当结果map是少量的时候，才使用这个方法。因为所有的数据会加载到driver的内存中。
   *
   *  为了处理大量的数据，使用 rdd.map(x => (x, 1L)).reduceByKey(_ + _)
   *    这会返回一个rdd，而不是map。
   *
   *
   * Return the count of each unique value in this RDD as a local map of (value, count) pairs.
   *
   * @note This method should only be used if the resulting map is expected to be small, as
   * the whole thing is loaded into the driver's memory.
   * To handle very large results, consider using
   *
   * {{{
   * rdd.map(x => (x, 1L)).reduceByKey(_ + _)
   * }}}
   *
   * , which returns an RDD[T, Long] instead of a map.
   */
  def countByValue()(implicit ord: Ordering[T] = null): Map[T, Long] = withScope {
    map(value => (value, null)).countByKey() 
    //map:让原key和原value作为新rdd的key，null作为新rdd的value
  }
```

## 2、示例

```java
object countByValue {
  def main(Args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("countByValue").setMaster("local")
    val sc = new SparkContext(conf)

//    val rdd = sc.parallelize(List(("a", 1), ("a", 1),("a", 7),("b", 2), ("b", 3)), 2)
    val rdd = sc.parallelize(List(1,1,2,2,2,1,4,5))

//    val rlt = rdd.map(value => (value, null))
//    rlt.collect().foreach(println)  //((a,1),null)、((a,6),null)、((a,7),null)、((b,1),null)、((b,3),null)

    val rlt = rdd.countByValue()  //本身就会collect到driver

    // Map((b,2) -> 1, (a,7) -> 1, (b,3) -> 1, (a,1) -> 2)  有排序
    // Map(4 -> 1, 1 -> 3, 5 -> 1, 2 -> 3)
    println(rlt)

  }
}
```