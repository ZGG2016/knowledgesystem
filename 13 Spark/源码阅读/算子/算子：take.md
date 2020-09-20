# 算子：take

## 1、源码

```java
  /**
   * 取RDD的前num个元素。
   *
   * 它首先扫描一个分区，然后使用该分区的结果来估计需要满足的其他分区的数量的极限。
   *
   * Take the first num elements of the RDD. It works by first scanning one partition, and use the
   * results from that partition to estimate the number of additional partitions needed to satisfy
   * the limit.
   *
   * 适合结果数组的数据量少的情况，因为它会把数据全部都载入driver内存
   *
   *
   * 如果RDD是空的，方法会抛异常
   *
   * @note This method should only be used if the resulting array is expected to be small, as
   * all the data is loaded into the driver's memory.
   *
   * @note Due to complications in the internal implementation, this method will raise
   * an exception if called on an RDD of `Nothing` or `Null`.
   */
  def take(num: Int): Array[T] = withScope {
    val scaleUpFactor = Math.max(conf.getInt("spark.rdd.limit.scaleUpFactor", 4), 2)
    if (num == 0) {
      new Array[T](0) //返回空数组
    } else {
      //传入非0值
      val buf = new ArrayBuffer[T]
      //取这个RDD有多少个分区
      val totalParts = this.partitions.length
      var partsScanned = 0
      while (buf.size < num && partsScanned < totalParts) {
        // The number of partitions to try in this iteration. It is ok for this number to be
        // greater than totalParts because we actually cap it at totalParts in runJob.
        var numPartsToTry = 1L
        val left = num - buf.size
        if (partsScanned > 0) {
          // If we didn't find any rows after the previous iteration, quadruple and retry.
          // Otherwise, interpolate the number of partitions we need to try, but overestimate
          // it by 50%. We also cap the estimation in the end.
          if (buf.isEmpty) {
            numPartsToTry = partsScanned * scaleUpFactor
          } else {
            // As left > 0, numPartsToTry is always >= 1
            numPartsToTry = Math.ceil(1.5 * left * partsScanned / buf.size).toInt
            numPartsToTry = Math.min(numPartsToTry, partsScanned * scaleUpFactor)
          }
        }

        val p = partsScanned.until(math.min(partsScanned + numPartsToTry, totalParts).toInt)
        val res = sc.runJob(this, (it: Iterator[T]) => it.take(left).toArray, p)

        res.foreach(buf ++= _.take(num - buf.size))
        partsScanned += p.size
      }

      buf.toArray
    }
  }
```