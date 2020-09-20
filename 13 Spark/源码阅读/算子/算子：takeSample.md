# 算子：takeSample

## 1、源码

```java
  /**
   * 已数组形式，返回一个固定大小的RDD的子集 
   *
   * Return a fixed-size sampled subset of this RDD in an array
   *
   * @param withReplacement whether sampling is done with replacement 否是有放回抽样
   * @param num size of the returned sample 抽样返回的样本的个数
   * @param seed seed for the random number generator
   * @return sample of specified size in an array  数组
   *
   *
   * 此方法只有再结果数组很小时使用，因为所有的数据都会载入到driver的内存
   *
   * @note this method should only be used if the resulting array is expected to be small, as
   * all the data is loaded into the driver's memory.
   */
  def takeSample(
      withReplacement: Boolean,
      num: Int,
      seed: Long = Utils.random.nextLong): Array[T] = withScope {
    val numStDev = 10.0

    require(num >= 0, "Negative number of elements requested")
    require(num <= (Int.MaxValue - (numStDev * math.sqrt(Int.MaxValue)).toInt),
      "Cannot support a sample size > Int.MaxValue - " +
      s"$numStDev * math.sqrt(Int.MaxValue)")

    //返回的样本的个数为0，就返回一个空数组
    if (num == 0) {  
      new Array[T](0)
    } else {
    	//统计这个RDD有多少个元素
      val initialCount = this.count()
      //没有元素，就返回一个空数组
      if (initialCount == 0) {
        new Array[T](0)
      } else {
        val rand = new Random(seed)
        //只有不放回，且要返回的样本大于等于RDD中的样本数，才shuffle数据
        if (!withReplacement && num >= initialCount) {
        //Shuffle the elements of an array into a random order, modifying the original array. Returns the original array.
          Utils.randomizeInPlace(this.collect(), rand)
        } else {
     //Returns a sampling rate that guarantees a sample of size greater than or equal to sampleSizeLowerBound 99.99% of the time.
          val fraction = SamplingUtils.computeFractionForSampleSize(num, initialCount,
            withReplacement)
          var samples = this.sample(withReplacement, fraction, rand.nextInt()).collect()  //有collect()

          // If the first sample didn't turn out large enough, keep trying to take samples;
          // this shouldn't happen often because we use a big multiplier for the initial size
          var numIters = 0
          //抽样的样本数量白哦与目标值，再次抽样
          while (samples.length < num) {
            logWarning(s"Needed to re-sample due to insufficient sample size. Repeat #$numIters")
            samples = this.sample(withReplacement, fraction, rand.nextInt()).collect()
            numIters += 1
          }
          Utils.randomizeInPlace(samples, rand).take(num)
        }
      }
    }
  }
```
## 2、示例

```java
object takeSample {
  def main(Args:Array[String]):Unit = {
    val conf = new SparkConf().setAppName("takeSample").setMaster("local")
    val sc = new SparkContext(conf)

    val rdd = sc.parallelize(List(1, 2, 2, 2, 5, 6, 8, 8, 8, 8))

    //给定参数：是否是有放回抽样、抽样返回的样本的个数，随机生成器种子
    //Return a fixed-size sampled subset of this RDD in an array  数组
    val rlt2 = rdd.takeSample(withReplacement = false,4,10)
    rlt2.foreach(println)  //8、6、8、2
  }
}
```