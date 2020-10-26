# 算子：filter

RDD.scala

## 1、源码

```java
  /**
   * 返回满足条件的元素，组成的新的RDD
   *
   * 针对分区操作 
   *
   * Return a new RDD containing only the elements that satisfy a predicate.
   */
  def filter(f: T => Boolean): RDD[T] = withScope {
    val cleanF = sc.clean(f)
    new MapPartitionsRDD[T, T](
      this,
      (context, pid, iter) => iter.filter(cleanF),
      preservesPartitioning = true)
  }

//iter.filter(cleanF):scala包下的filter

  /** Returns an iterator over all the elements of this iterator that satisfy the predicate `p`.
   *  The order of the elements is preserved.  保留元素顺序
   *
   *  @param p the predicate used to test values.
   *  @return  an iterator which produces those values of this iterator which satisfy the predicate `p`.
   *  @note    Reuse: $consumesAndProducesIterator
   */
  def filter(p: A => Boolean): Iterator[A] = new AbstractIterator[A] {
    // TODO 2.12 - Make a full-fledged FilterImpl that will reverse sense of p
    private var hd: A = _
    private var hdDefined: Boolean = false

    def hasNext: Boolean = hdDefined || {
      do {
        if (!self.hasNext) return false
        hd = self.next()
      } while (!p(hd))  //判断hd是否满足p条件
      hdDefined = true
      true
    }

    def next() = if (hasNext) { hdDefined = false; hd } else empty.next()
  }
```

面试题：filter是rdd操作吗

	是，既是rdd的transformation，也是scala的函数。

	当rdd调用filter过滤时，会对每个分区执行iter.filter(cleanF)，这里的filter就是scala的函数

## 2、示例

```java
object filter {
  def main(Args:Array[String]):Unit = {
    val conf = new SparkConf().setAppName("filter").setMaster("local")
    val sc = new SparkContext(conf)

    val rdd = sc.parallelize(List(1,2,3,4,5))
    val rlt = rdd.filter(_>4)

    rlt.foreach(println)
  }
}
```