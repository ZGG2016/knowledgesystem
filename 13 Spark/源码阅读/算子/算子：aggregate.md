# 算子：aggregate

## 1、源码

RDD.scala

```java
  /**
   * 使用一个聚合函数和一个中性的"0值"，聚合每个分区的元素，再聚合这些分区的结果。
   *
   * 这个函数会返回的结果的类型U和rdd的T类型不同。【zeroValue的类型就是返回值的类型】
   *
   * 因此，需要一个操作将T合并到U，再使用另一个操作合并两个U。 
   *
   * 为避免内存分配，这两个函数被允许修改、返回第一个参数，而不是创建一个新的U。
   * 
   * Aggregate the elements of each partition, and then the results for all the partitions, using
   * given combine functions and a neutral "zero value". This function can return a different result
   * type, U, than the type of this RDD, T. Thus, we need one operation for merging a T into an U
   * and one operation for merging two U's, as in scala.TraversableOnce. Both of these functions are
   * allowed to modify and return their first argument instead of creating a new U to avoid memory
   * allocation.
   *
   * zeroValue:每个分区累积结果的初始值。
   *          seqOp操作的每个分区累积结果的初始值，以及
   *          combOp操作从不同分区合并结果的初始值
   *
   * seqOp：在一个分区内累积结果的操作
   *
   * combOp:一个合并不同分区结果的联合操作
   *
   * @param zeroValue the initial value for the accumulated result of each partition for the
   *                  `seqOp` operator, and also the initial value for the combine results from
   *                  different partitions for the `combOp` operator - this will typically be the
   *                  neutral element (e.g. `Nil` for list concatenation or `0` for summation)
   * @param seqOp an operator used to accumulate results within a partition
   * @param combOp an associative operator used to combine results from different partitions
   */
  def aggregate[U: ClassTag](zeroValue: U)(seqOp: (U, T) => U, combOp: (U, U) => U): U = withScope {
    // Clone the zero value since we will also be serializing it as part of tasks
    // 克隆一个0值
    // clone：使用Spark serializer克隆一个对象.
    var jobResult = Utils.clone(zeroValue, sc.env.serializer.newInstance())
    val cleanSeqOp = sc.clean(seqOp)
    val cleanCombOp = sc.clean(combOp)
    
    // 执行seqOp，实际调用了foldLeft方法：对每一个元素x，使用op操作x和0值
    val aggregatePartition = (it: Iterator[T]) => it.aggregate(zeroValue)(cleanSeqOp, cleanCombOp)
    
    // 执行combOp：使用combOp操作0值和每个分区的计算结果
    val mergeResult = (index: Int, taskResult: U) => jobResult = combOp(jobResult, taskResult)
    
    //runJob：Run a job on all partitions in an RDD and pass the results to a handler function.
    sc.runJob(this, aggregatePartition, mergeResult)
    jobResult
  }

  /**
    * it.aggregate(zeroValue)(cleanSeqOp, cleanCombOp):
    *   def aggregate[B](z: =>B)(seqop: (B, A) => B, combop: (B, B) => B): B = foldLeft(z)(seqop)  【TraversableOnce.scala】
    *   
    *   // 对每一个元素x，使用op操作x和0值，0值即为这里的z
    *   def foldLeft[B](z: B)(op: (B, A) => B): B = {    【TraversableOnce.scala】
    *         var result = z
    *         this foreach (x => result = op(result, x)) 
    *         result
    *    }
    *
    **/

```
## 2、示例

```java
object aggregate {
  def main(Args:Array[String]): Unit = {
    
    val conf = new SparkConf().setAppName("aggregate").setMaster("local")
    val sc = new SparkContext(conf)

    val data = List(1,2,3,4,5,6,7,8,9)
    val rdd = sc.parallelize(data,2)

    val res = data.aggregate((0,0))(
      (acc,number)=>(acc._1+number, acc._2+1),
      (par1, par2) => (par1._1+par2._1, par1._2+par2._2)
    )

    println(res)  //(45,9)

  }
}

/**
 * 分区0：1,2,3,4
 * 分区1：5,6,7,8,9
 *
 *  acc是(0,0),number是data。
 *  1、seqOp操作：foreach (x => result = op(result, x))
 * 对分区0：
 *      0+1,0+1  -->  1,1
 *      1+2,1+1  -->  3,2
 *      3+3,2+1  -->  6,3
 *      6+4,3+1  -->  10,4
 *
 * 对分区1：
 *      0+5,0+1  --> 5,1
 *      5+6,1+1  --> 11,2
 *      11+7,2+1 --> 18,3
 *      18+8,3+1 --> 26,4
 *      26+9,4+1 --> 35,5
 * 2、combOp操作：jobResult = combOp(jobResult, taskResult)
 *
 *     0,0 + 10,4 + 35,5 == 45,9
 *
 * */
```
