# 算子：map、flatMap

RDD.scala

## 1、源码

```java
  /**
   * 将函数应用在RDD的所有元素上，返回一个新的RDD
   *
   * 要注意这里(f: T => U) 的 T。f作用的对象
   *
   * Return a new RDD by applying a function to all elements of this RDD.
   */
  def map[U: ClassTag](f: T => U): RDD[U] = withScope {
    val cleanF = sc.clean(f)
    new MapPartitionsRDD[U, T](this, (context, pid, iter) => iter.map(cleanF))
  }

  /**
   * 首先将函数应用在RDD的所有元素上，然后将结果展平，返回一个新的RDD
   *
   * 要注意这里(f: T => TraversableOnce[U]) 的 T。f作用的对象
   *
   *  Return a new RDD by first applying a function to all elements of this
   *  RDD, and then flattening the results.
   */
  def flatMap[U: ClassTag](f: T => TraversableOnce[U]): RDD[U] = withScope {
    val cleanF = sc.clean(f)
    new MapPartitionsRDD[U, T](this, (context, pid, iter) => iter.flatMap(cleanF))
  }

//scala包下

    /** 
     *
     * Creates a new iterator that maps all produced values of this iterator
     *  to new values using a transformation function.
     *
     *  @param f  the transformation function
     *  @return a new iterator which transforms every value produced by this
     *          iterator by applying the function `f` to it.
     *  @note   Reuse: $consumesAndProducesIterator
     */
  def map[B](f: A => B): Iterator[B] = new AbstractIterator[B] {
  	//def hasNext: Boolean -->判断这个迭代器是否还能提供下一个元素
    def hasNext = self.hasNext
    // def next(): A  --> 取这个迭代器的下一个元素
    def next() = f(self.next())
  }

    /**
     *
     * Creates a new iterator by applying a function to all values produced by this iterator
     *  and concatenating the results.
     *
     *  @param f the function to apply on each element.
     *  @return  the iterator resulting from applying the given iterator-valued function
     *           `f` to each value produced by this iterator and concatenating the results.
     *  @note    Reuse: $consumesAndProducesIterator
     */
  def flatMap[B](f: A => GenTraversableOnce[B]): Iterator[B] = new AbstractIterator[B] {
    private var cur: Iterator[B] = empty
    //f作用在迭代器的每个值后，返回一个新的迭代器
    private def nextCur() { cur = f(self.next()).toIterator }
    
    def hasNext: Boolean = {
      // Equivalent to cur.hasNext || self.hasNext && { nextCur(); hasNext }
      // but slightly shorter bytecode (better JVM inlining!)
      while (!cur.hasNext) {   
        if (!self.hasNext) return false   
        nextCur()
      }
      true
    }
    def next(): B = (if (hasNext) cur else empty).next()
  }
```

## 2、示例

```java
object map {
  def main(Args:Array[String]): Unit ={
    val conf = new SparkConf().setAppName("map").setMaster("local")
    val sc = new SparkContext(conf)

    val rdd = sc.parallelize(List("ab","cd"))

    val rlt1 = rdd.map(x=>x.toUpperCase)
    val rlt2 = rdd.flatMap(x=>x.toUpperCase) //传给flatMap的元素要是可迭代类型
    //AB
    //CD
    rlt1.collect.foreach(println)
    //A
    //B
    //C
    //D
    rlt2.collect.foreach(println)

    //val test = sc.parallelize(List(1,2,3))
    //test.map(x=>x+1)
    //test.flatMap(x=>x+1) //报错：类型不匹配

  }
}

```