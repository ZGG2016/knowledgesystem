# 算子：count

RDD.scala

## 1、源码

```java
/**
  * 统计rdd中元素的个数，结果为Long类型
  *
  * Return the number of elements in the RDD.
  */
  def count(): Long = sc.runJob(this, Utils.getIteratorSize _).sum
  
  /**
   * 在RDD上的每个分区作用一个函数，计算结果以数组的形式返回
   *
   * Run a job on all partitions in an RDD and return the results in an array.
   *
   * @param rdd target RDD to run tasks on
   * @param func a function to run on each partition of the RDD
   * @return in-memory collection with a result of the job (each collection element will contain
   * a result from one partition)
   */
  def runJob[T, U: ClassTag](rdd: RDD[T], func: Iterator[T] => U): Array[U] = {
    runJob(rdd, func, 0 until rdd.partitions.length)
  }

  /**
   * 统计一个迭代器中的元素的个数。
   *
   * Counts the number of elements of an iterator using a while loop rather than calling
   * [[scala.collection.Iterator#size]] because it uses a for loop, which is slightly slower
   * in the current version of Scala.
   */
  def getIteratorSize(iterator: Iterator[_]): Long = {
    var count = 0L
    while (iterator.hasNext) {
      count += 1L
      iterator.next()
    }
    count
  }

  def sum[B >: A](implicit num: Numeric[B]): B = foldLeft(num.zero)(num.plus)

  //这里的(z: B)是0
  //(op: (B, A) => B)是加法运算，把A加到B上，返回B
  def foldLeft[B](z: B)(op: (B, A) => B): B = {
    var result = z
    this foreach (x => result = op(result, x))  //循环相加
    result
  }

  def zero = fromInt(0)  
  def fromInt(x: Int): T

  def plus(x: T, y: T): T
  def +(rhs: T) = plus(lhs, rhs)   
```

## 2、示例

```java
object count {
    def main(Args: Array[String]): Unit = {
      val conf = new SparkConf().setAppName("count").setMaster("local")
      val sc = new SparkContext(conf)

      val rdd = sc.parallelize(List(1,1,2,2,2,1,4,5))

      val rlt = rdd.count() //8
      println(rlt)
    }
}
```