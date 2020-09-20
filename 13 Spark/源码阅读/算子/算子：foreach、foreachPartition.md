# 算子：foreach、foreachPartition

## 1、源码

```java
  /**
   * 应用一个函数到这个RDD的所有元素上
   *
   * 要注意这里(f: T => Unit) 的 T。f作用的对象
   * 
   * Applies a function f to all elements of this RDD.
   */
  def foreach(f: T => Unit): Unit = withScope {
    val cleanF = sc.clean(f)
    //先应用到分区，再到分区的每个元素
    sc.runJob(this, (iter: Iterator[T]) => iter.foreach(cleanF))
  }

  /** Applies a function `f` to all values produced by this iterator.
   *
   *  @param  f   the function that is applied for its side-effect to every element.
   *              The result of function `f` is discarded. 函数结果被丢弃
   *
   *  @tparam  U  the type parameter describing the result of function `f`.
   *              This result will always be ignored. Typically `U` is `Unit`,
   *              but this is not necessary.
   *         描述函数' f '结果的类型参数。这个结果会被忽略
   *
   *  @note    Reuse: $consumesIterator
   *
   *  @usecase def foreach(f: A => Unit): Unit
   *    @inheritdoc
   *
   * def foreach[U](f: A => U) { while (hasNext) f(next()) }
   */



  /**
   * 应用一个函数到这个RDD的每个分区上。
   *
   * 要注意这里(f: Iterator[T] => Unit)的 Iterator[T] 。f作用的对象。
   *
   * 因为没有返回值并且是action操作，所以一般用在程序末尾，
   *  比如，要将数据存储到mysql、es或hbase等存储系统中
   *
   * Applies a function f to each partition of this RDD.
   */
  def foreachPartition(f: Iterator[T] => Unit): Unit = withScope {
    val cleanF = sc.clean(f)
    sc.runJob(this, (iter: Iterator[T]) => cleanF(iter))  //直接作用到分区
  }
```

## 2、示例

```java
object foreach {
  def main(Args:Array[String]): Unit = {
    val conf = new SparkConf().setAppName("foreach").setMaster("local")
    val sc = new SparkContext(conf)

    val rdd1 = sc.parallelize(List("ab", "cd"), 2)
    val rdd2 = sc.parallelize(List("ab", "cd"), 2)

    //ab
    //cd
    rdd1.foreach(x=>println(x))
    
    //ab
    //cd
    rdd2.foreachPartition(x=>{
      x.foreach(println)
    })
  }
}
```

scala中也有一个foreach方法

```java
  override /*IterableLike*/
  def foreach[U](f: A => U): Unit = {
    var i = 0
    val len = length
    while (i < len) { f(this(i)); i += 1 }
  }
```