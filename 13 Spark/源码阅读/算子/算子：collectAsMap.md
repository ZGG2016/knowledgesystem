# 算子：collectAsMap

PairRDDFunctions.scala

## 1、源码

```java
  /**
   * 将RDD中的键值对以map的形式返回给master
   *
   * 注意：如果一个key有多个value，map中只会取其中一个。
   *
   * driver内存问题
   *
   * Return the key-value pairs in this RDD to the master as a Map.
   *
   * Warning: this doesn't return a multimap (so if you have multiple values to the same key, only
   *          one value per key is preserved in the map returned)
   *
   * @note this method should only be used if the resulting data is expected to be small, as
   * all the data is loaded into the driver's memory.
   */
  def collectAsMap(): Map[K, V] = self.withScope {
    val data = self.collect()
    val map = new mutable.HashMap[K, V]
    //设置map的大小
    map.sizeHint(data.length)
    //遍历数据，放入map
    data.foreach { pair => map.put(pair._1, pair._2) }
    map
  }
```

## 2、示例

```java
object collectAsMap {
  def main(Args:Array[String]): Unit = {
    val sparkConf = new SparkConf().setAppName("collect").setMaster("local")
    val sc = new SparkContext(sparkConf)

    val rdd1 = sc.parallelize(List(1,2,3))
    val rdd2 = sc.parallelize(List("a","b","c"))
    //(2,b)
    //(1,a)
    //(3,c)
    rdd1.zip(rdd2).collectAsMap.foreach(println)

  }
}
```