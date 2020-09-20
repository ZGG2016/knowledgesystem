# 算子：zip

## 1、源码

```java
  /**
   * 将两个RDD组合成Key/Value形式的RDD。
   * 默认两个RDD的partition数量以及元素数量都相同。
   *
   * Zips this RDD with another one, returning key-value pairs with the first element in each RDD,
   * second element in each RDD, etc. Assumes that the two RDDs have the *same number of
   * partitions* and the *same number of elements in each partition* (e.g. one was made through
   * a map on the other).
   */
  def zip[U: ClassTag](other: RDD[U]): RDD[(T, U)] = withScope {
    zipPartitions(other, preservesPartitioning = false) { (thisIter, otherIter) =>
      new Iterator[(T, U)] {
        def hasNext: Boolean = (thisIter.hasNext, otherIter.hasNext) match {
          case (true, true) => true
          case (false, false) => false
          case _ => throw new SparkException("Can only zip RDDs with " +
            "same number of elements in each partition")
        }
        def next(): (T, U) = (thisIter.next(), otherIter.next())
      }
    }
  }



```


## 2、示例

```java
object zip {
  def main(Args:Array[String]):Unit = {
    val conf = new SparkConf().setAppName("zip").setMaster("local")
    val sc = new SparkContext(conf)

    val rdd1 = sc.parallelize(List(1, 2, 3,4),2)
    val rdd2 = sc.parallelize(List(5, 6, 7, 8),2)


    val rlt = rdd1.zip(rdd2)
    rlt.collect().foreach(println) //(1,5)、(2,6)、(3,7)、(4,8)

  }
}
```