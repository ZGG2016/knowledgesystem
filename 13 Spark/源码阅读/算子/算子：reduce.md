# 算子：reduce

## 1、源码

```java
  /**
   * 使用二元运算符 reduce RDD中的元素。
   *
   * Reduces the elements of this RDD using the specified commutative and
   * associative binary operator.
   */
  def reduce(f: (T, T) => T): T = withScope {
    val cleanF = sc.clean(f)

    // 先在每个分区内计算
    // 使用f，依次操作每个分区内的数据
    val reducePartition: Iterator[T] => Option[T] = iter => {
      if (iter.hasNext) {
        Some(iter.reduceLeft(cleanF))
      } else {
        None
      }
    }
    var jobResult: Option[T] = None

    //合并每个分区的结果
    //index:分区id   taskResult:每个分区的计算结果
    val mergeResult = (index: Int, taskResult: Option[T]) => {
    //如果当前分区有计算结果，如果匹配到已有的最终结果，就追加进去。否则就返回当前结果
    //或者这么理解：一开始jobResult是None，所以执行第二个case，后面再匹配的时候，就有值了，就追加到前面的结果
      if (taskResult.isDefined) {
        jobResult = jobResult match {
         //将当前分区结果合并到最终结果中
          case Some(value) => Some(f(value, taskResult.get))  
          //返回当前结果
          case None => taskResult
        }
      }
    }
    sc.runJob(this, reducePartition, mergeResult)
    // Get the final result out of our Option, or throw an exception if the RDD was empty
    jobResult.getOrElse(throw new UnsupportedOperationException("empty collection"))
  }


  /** 
   * 应用二元运算符从左到右地作用每个元素上。
   * 
   * Applies a binary operator to all elements of this $coll,
   *  going left to right.
   *  $willNotTerminateInf
   *  $orderDependentFold
   *
   *  @param  op    the binary operator.
   *  @tparam  B    the result type of the binary operator.  返回值类型
   *  @return  the result of inserting `op` between consecutive elements of this $coll,
   *           going left to right:
   *           {{{
   *             op( op( ... op(x_1, x_2) ..., x_{n-1}), x_n)
   *           }}}
   *           where `x,,1,,, ..., x,,n,,` are the elements of this $coll.
   *
   *  1，2，3，4.  应用加法  
   *  1+2=3
   *  3+3=6
   *  6+4=10  结果为10
   *
   *  @throws UnsupportedOperationException if this $coll is empty.   */
  def reduceLeft[B >: A](op: (B, A) => B): B = {
    if (isEmpty)
      throw new UnsupportedOperationException("empty.reduceLeft")

    var first = true

    //确定一个初始0值，类型是返回值类型B
    var acc: B = 0.asInstanceOf[B]

    for (x <- self) {
      if (first) {  //如果是第一个值的话，直接复制给结果acc
        acc = x
        first = false
      }
      else acc = op(acc, x)
    }
    acc
  }


  /**
   * 在RDD的所有分区上运行一个job，并将结果传递给handler function
   *
   * Run a job on all partitions in an RDD and pass the results to a handler function.
   *
   * @param rdd target RDD to run tasks on
   * @param processPartition a function to run on each partition of the RDD
   * @param resultHandler callback to pass each result to
   */
  def runJob[T, U: ClassTag](
      rdd: RDD[T],
      processPartition: Iterator[T] => U,
      resultHandler: (Int, U) => Unit)
  {
  	//函数作用在每个分区上
    val processFunc = (context: TaskContext, iter: Iterator[T]) => processPartition(iter)
    runJob[T, U](rdd, processFunc, 0 until rdd.partitions.length, resultHandler)
  }
```

## 2、示例

```java
object reduce {
  def main(Args:Array[String]):Unit={
    val conf = new SparkConf().setAppName("reduce").setMaster("local")
    val sc = new SparkContext(conf)

    val data = List(1,2,3,4)

    val rdd = sc.parallelize(data,2)

    val rlt = rdd.reduce((a,b)=>a+b)
    println(rlt) //10

  }
}
```