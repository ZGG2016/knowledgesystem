# 算子：fold

RDD.scala

## 1、源码

```java
  /**
   * 使用一个associative函数和中立的"0值"，先聚合每个分区的元素，再聚合所有分区。
   *
   * op(t1, t2)可以修改t1值，将它作为返回值返回，避免了对象分配，然后不要修改t2.
   *
   * Aggregate the elements of each partition, and then the results for all the partitions, using a
   * given associative function and a neutral "zero value". The function
   * op(t1, t2) is allowed to modify t1 and return it as its result value to avoid object
   * allocation; however, it should not modify t2.
   *
   * 这与Scala等函数式语言中，为非分布式集合实现的fold操作有些不同。
   *
   * 这个fold可以分别应用到的分区上，再fold这些结果，成最终结果。
   * 而不是按顺序作用在每个元素上。
   *
   * 如果使用了非commutative的函数，得到的结果可能和应用到非分布式集合上得到的结果不同。
   *
   *
   * This behaves somewhat differently from fold operations implemented for non-distributed
   * collections in functional languages like Scala. This fold operation may be applied to
   * partitions individually, and then fold those results into the final result, rather than
   * apply the fold to each element sequentially in some defined ordering. For functions
   * that are not commutative, the result may differ from that of a fold applied to a
   * non-distributed collection.
   *
   * 初始0值不仅用在每个分区内的累积，也是在合并分区间结果时的初始值。
   *
   *
   * @param zeroValue the initial value for the accumulated result of each partition for the `op`
   *                  operator, and also the initial value for the combine results from different
   *                  partitions for the `op` operator - this will typically be the neutral
   *                  element (e.g. `Nil` for list concatenation or `0` for summation)
   * @param op an operator used to both accumulate results within a partition and combine results
   *                  from different partitions
   */
  def fold(zeroValue: T)(op: (T, T) => T): T = withScope {
    // Clone the zero value since we will also be serializing it as part of tasks
    //复制0值
    var jobResult = Utils.clone(zeroValue, sc.env.closureSerializer.newInstance())
    val cleanOp = sc.clean(op)
    //计算每个分区
    val foldPartition = (iter: Iterator[T]) => iter.fold(zeroValue)(cleanOp)
    //合并各分区
    val mergeResult = (index: Int, taskResult: T) => jobResult = op(jobResult, taskResult)
    sc.runJob(this, foldPartition, mergeResult)
    jobResult
  }

  //def fold[A1 >: A](z: A1)(op: (A1, A1) => A1): A1 = foldLeft(z)(op)

  // def foldLeft[B](z: B)(op: (B, A) => B): B = {
  // 	var result = z
  //  	this foreach (x => result = op(result, x))
  //  	result
  // }
```

## 2、示例

```java
object fold {
  def main(Args:Array[String]):Unit = {
    val conf = new SparkConf().setAppName("fold").setMaster("local")
    val sc = new SparkContext(conf)

//    val rdd = sc.parallelize(List(1, 2, 2)) //输出 9
    val rdd = sc.parallelize(List(1, 2, 2),2) //输出 11

    val rlt = rdd.fold(2)(_+_)

    println(rlt)

  }
}
```