# 算子：sample

RDD.scala

## 1、源码

```java
  /**
   * 对RDD抽样，返回其子集
   *
   * Return a sampled subset of this RDD.
   *
   * @param withReplacement can elements be sampled multiple times (replaced when sampled out)   是否是有放回抽样
   * @param fraction expected size of the sample as a fraction of this RDD's size
   *  without replacement: probability that each element is chosen; fraction must be [0, 1]
   *  with replacement: expected number of times each element is chosen; fraction must be greater
   *  than or equal to 0
   * 
   *  抽样比例，抽样子集占原RDD的比例
   * 
   *  无放回：每个元素被选择的概率，[0,1]之间
   *  有放回：每个元素被期望选择的次数，必须大于等于0
   *
   * @param seed seed for the random number generator  随机数生成器种子
   *
   * @note This is NOT guaranteed to provide exactly the fraction of the count
   * of the given [[RDD]].
   */
  def sample(
      withReplacement: Boolean,
      fraction: Double,
      seed: Long = Utils.random.nextLong): RDD[T] = {
    require(fraction >= 0,
      s"Fraction must be nonnegative, but got ${fraction}")

    withScope {
      require(fraction >= 0.0, "Negative fraction value: " + fraction)
      //有放回抽样，使用泊松分布。无放回抽样，使用伯努利分布
      if (withReplacement) {
      	  //PartitionwiseSampledRDD：抽样后，返回的RDD
        new PartitionwiseSampledRDD[T, T](this, new PoissonSampler[T](fraction), true, seed)  //true：子RDD是否和父RDD的分区一致。
      } else {
        new PartitionwiseSampledRDD[T, T](this, new BernoulliSampler[T](fraction), true, seed)
      }
    }
  }

```

## 2、示例

```java
object sample {
  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("sample").setMaster("local")
    val sc = new SparkContext(conf)

    val data = sc.parallelize(1 to 30)
    //无放回抽样，抽样比例：0.2  ，随机数生成器种子：100
    val rlt = data.sample(withReplacement = false,0.2,100).collect()

    rlt.foreach(println)  //4、5、16、19

  }
}
```