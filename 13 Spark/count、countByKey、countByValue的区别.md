# count、countByKey、countByValue的区别

## 1、区别

count：

	统计rdd中元素有多少个。

	结果为Long类型

	操作对象是普通rdd

countByKey：

	统计相同的key的元素有多少个，并将结果收集到本地map。

	结果为Map[K, Long]类型

	操作对象是pair rdd

	自动加载结果数据到driver的内存中

countByValue：

	统计这个rdd中唯一值的个数(不是<k,v>里的v)，并将结果收集到本地map，以(value, count)的形式返回。

	结果为Map[T, Long]类型

	操作对象是普通rdd、或pair rdd

	自动加载结果数据到driver的内存中	

	底层调用了countByKey

## 2、示例：

      val rdd = sc.parallelize(List(1,1,2,2,2,1,4,5))
      val rlt = rdd.count() //8

      --------------------------------------------------------------------------

      val rdd = sc.parallelize(List(("a", 1), ("a", 6),("a", 7),("b", 5), ("b", 3)), 2)
      val rlt = rdd.countByKey()  //Map(b -> 2, a -> 3)

	  --------------------------------------------------------------------------

      val rdd = sc.parallelize(List(("a", 1), ("a", 1),("a", 7),("b", 2), ("b", 3)), 2)

	  //Map((b,2) -> 1, (a,7) -> 1, (b,3) -> 1, (a,1) -> 2) 
      val rlt = rdd.countByValue()  

      // Map(4 -> 1, 1 -> 3, 5 -> 1, 2 -> 3)
      val rdd = sc.parallelize(List(1,1,2,2,2,1,4,5))
