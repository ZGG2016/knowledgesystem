# 算子：collect

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
```