# 算子：randomSplit

RDD.scala

## 1、源码

```java
 /**
   * 根据提供的权重，随机划分RDD
   *
   * Randomly splits this RDD with the provided weights.
   *
   * 如果权重和不为1，将被标准化。
   *
   * @param weights weights for splits, will be normalized if they don't sum to 1
   * @param seed random seed
   *
   * @return split RDDs in an array   返回值:Array[RDD[T]]
   */
  def randomSplit(
      weights: Array[Double],
      seed: Long = Utils.random.nextLong): Array[RDD[T]] = {
    
  	//权重必须大于等于0，其和要大于0
    require(weights.forall(_ >= 0),
      s"Weights must be nonnegative, but got ${weights.mkString("[", ",", "]")}")
    require(weights.sum > 0,
      s"Sum of weights must be positive, but got ${weights.mkString("[", ",", "]")}")

    withScope {
      val sum = weights.sum
      
      //标准化权重
      val normalizedCumWeights = weights.map(_ / sum).scanLeft(0.0d)(_ + _)
      
      normalizedCumWeights.sliding(2).map { x =>
      	//不放回随机抽样
        randomSampleWithRange(x(0), x(1), seed)
      }.toArray
    }
  }

/**
 * def scanLeft[B, That](z: B)(op: (B, A) => B)(implicit bf: CanBuildFrom[Repr, B, That]): That = {
 * 		  val b = bf(repr)   //类似数组的结构
 *      b.sizeHint(this, 1)
 *      var acc = z
 *      b += acc
 *      for (x <- this) { acc = op(acc, x); b += acc } //更新的值，随时进入b中。
 *      b.result
 * }
 *
 * //定义一个滑动窗口，参数size就是窗口大小
 * //Groups elements in fixed size blocks by passing a "sliding window" over them  
 * def sliding(size: Int): Iterator[Repr] = sliding(size, 1)
 */

  /**
   * Internal method exposed for Random Splits in DataFrames. Samples an RDD given a probability  给定一个概率范围，对RDD抽样（伯努利抽样器）
   * range.
   * @param lb lower bound to use for the Bernoulli sampler  下限
   * @param ub upper bound to use for the Bernoulli sampler   上限
   * @param seed the seed for the Random number generator
   * @return A random sub-sample of the RDD without replacement.  不放回抽样
   */
  private[spark] def randomSampleWithRange(lb: Double, ub: Double, seed: Long): RDD[T] = {
    //在每个分区中，定义一个抽样器，分别抽样
    this.mapPartitionsWithIndex( { (index, partition) =>
      val sampler = new BernoulliCellSampler[T](lb, ub)
      sampler.setSeed(seed + index)
      sampler.sample(partition)
    }, preservesPartitioning = true)
  }

```

## 2、示例

```java
object randomSplit {
  def main(Args:Array[String]):Unit = {
    val conf = new SparkConf().setAppName("randomSplit").setMaster("local")
    val sc = new SparkContext(conf)

    val rdd = sc.parallelize(List(1, 2, 2, 2, 5, 6, 8, 8, 8, 8))

    val rlt = rdd.randomSplit(Array(1.0,2.0,3.0,4.0),10) //返回值类型：Array[RDD[T]]

    println(rlt.length)  //4  ，划分出了4个RDD，组成一个数组

    for(x <- rlt){
      x.collect().foreach(print) //2  |8  | 1568  | 2288  |
      println()
      println("---------------------")
    }

  }
}
```