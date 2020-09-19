# 算子：count、countByKey

## 1、源码

```java
  /**
   * 统计相同的key的元素有多少个，并将结果收集到本地map
   *
   * 只有当结果map是少量的时候，才使用这个方法。因为所有的数据会加载到driver的内存中。
   *
   * 为了处理大量的数据，使用 rdd.mapValues(_ =>1L).reduceByKey(_ + _)。
   * 这会返回一个rdd，而不是map
   *
   * Count the number of elements for each key, collecting the results to a local Map.
   *
   * @note This method should only be used if the resulting map is expected to be small, as
   * the whole thing is loaded into the driver's memory.
   * To handle very large results, consider using rdd.mapValues(_ => 1L).reduceByKey(_ + _), which
   * returns an RDD[T, Long] instead of a map.
   */
  def countByKey(): Map[K, Long] = self.withScope {
    self.mapValues(_ => 1L).reduceByKey(_ + _).collect().toMap  //(k,1)...
  }
```

## 2、示例

```java
object countByKey {
  def main(Args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("countByKey").setMaster("local")
    val sc = new SparkContext(conf)

    val rdd = sc.parallelize(List(("a", 1), ("a", 6),("a", 7),("b", 5), ("b", 3)), 2)

    val rlt = rdd.countByKey()  //本身就会collect到driver

    println(rlt)  //Map(b -> 2, a -> 3)
  }
}
```