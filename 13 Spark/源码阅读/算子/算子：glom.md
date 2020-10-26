# 算子：glom

RDD.scala

## 1、源码

```java
  /**
   * 返回一个RDD，它是通过将每个分区中的所有元素合并到一个数组中创建的。
   *
   * Return an RDD created by coalescing all elements within each partition into an array.
   */
  def glom(): RDD[Array[T]] = withScope {
    new MapPartitionsRDD[Array[T], T](this, (context, pid, iter) => Iterator(iter.toArray))
  }
```

## 2、示例

```java
object glom {
  def main(Args:Array[String]):Unit = {
    val conf = new SparkConf().setAppName("glom").setMaster("local")
    val sc = new SparkContext(conf)

    val rdd = sc.parallelize(List(1, 2, 2, 2, 5, 6, 8, 8, 8, 8),2)

    val rlt = rdd.glom()
    /**
     * 1
     * 2
     * 2
     * 2
     * 5
     * ------------------
     * 6
     * 8
     * 8
     * 8
     * 8
     * ------------------
     */
    rlt.collect().foreach(x =>{
        x.foreach(println)
        println("------------------")
    })

  }
}

```