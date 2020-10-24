# 算子：collect

RDD.scala

## 1、源码

```java
  /**
   * 返回包含rdd所有元素的数组。
   * 
   * 这个方法只有在结果的数据量不大的情况下使用。因为所有的数据都会载入到driver内存。
   *
   * Return an array that contains all of the elements in this RDD.
   *
   * @note This method should only be used if the resulting array is expected to be small, as
   * all the data is loaded into the driver's memory.
   */
  def collect(): Array[T] = withScope {
  	// 每个分区转数组
    val results = sc.runJob(this, (iter: Iterator[T]) => iter.toArray)
    //所有分区的结果数组合并在一起
    Array.concat(results: _*)
  }

  /**
 *  Concatenates all arrays into a single array.
 *  
 *   @param xss the given arrays
 *   @return   the array created from concatenating `xss`
 *
 * def concat[T: ClassTag](xss: Array[T]*): Array[T] = {
 * 		val b = newBuilder[T]
 *      //设置期待被添加多少个元素，即设置大小
 *      b.sizeHint(xss.map(_.length).sum)
 *      for (xs <- xss) b ++= xs
 *      b.result()
 * }
 */

    /**
   * 利用f来过滤元素
   * Return an RDD that contains all matching values by applying `f`.
   */
  def collect[U: ClassTag](f: PartialFunction[T, U]): RDD[U] = withScope {
    val cleanF = sc.clean(f)
    //先过滤掉不在函数f作用域内的值。
    //再应用f函数
    filter(cleanF.isDefinedAt).map(cleanF)
  }

  /**
   * //Checks if a value is contained in the function's domain.
   *  def isDefinedAt(x: A): Boolean
   *
   */
```

## 2、示例

```java
object collect {
  def main(Args:Array[String]): Unit = {
    val sparkConf = new SparkConf().setAppName("collect").setMaster("local")
    val sc = new SparkContext(sparkConf)

    val rdd = sc.parallelize(0 to 2)

    val f : PartialFunction[Int,String] = {case 0 => "aa"
    case 1 => "bb"
    case 2 => "cc"
    case _ => "0"
    }

    rdd.collect(f).foreach(println)
  }
}
```