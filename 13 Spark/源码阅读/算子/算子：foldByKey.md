# 算子：foldByKey

PairRDDFunctions.scala

## 1、源码

```java
  /**
   * 使用一个函数和一个中性的"0值"合并每个key对应的values。
   * "0值"可以添加到结果中任意次数，但不能改变结果。
   * 
   * 对于0值 --> Nil：列表连接，0：加法，1：乘法
   * 
   * Merge the values for each key using an associative function and a neutral "zero value" which
   * may be added to the result an arbitrary number of times, and must not change the result
   * (e.g., Nil for list concatenation, 0 for addition, or 1 for multiplication.).
   */
  def foldByKey(
      zeroValue: V,
      partitioner: Partitioner)(func: (V, V) => V): RDD[(K, V)] = self.withScope {
    // Serialize the zero value to a byte array so that we can get a new clone of it on each key
    //把0值序列化成一个字节数组，这样，在每个分区上就可以获得一个0值的副本
    val zeroBuffer = SparkEnv.get.serializer.newInstance().serialize(zeroValue)
    //创建字节数组，大小为zeroBuffer的大小
    val zeroArray = new Array[Byte](zeroBuffer.limit) 
    zeroBuffer.get(zeroArray)

    /**
     * SparkEnv.get：Returns the SparkEnv.
     *
     * newInstance()：Creates a new [[SerializerInstance]]. 
     *
     * def serialize[T: ClassTag](t: T): ByteBuffer
     */

    /**
     * 将此缓冲区中的字节传输到给定的目标数组中。
     * public ByteBuffer get(byte[] dst) {
     *      return get(dst, 0, dst.length);
     * }
     */    
        

    // When deserializing, use a lazy val to create just one instance of the serializer per task
    //当反序列化时，用 lazy val 为每一个task创建一个序列化器实例
    lazy val cachedSerializer = SparkEnv.get.serializer.newInstance()
    //def deserialize[T: ClassTag](bytes: ByteBuffer): T
    val createZero = () => cachedSerializer.deserialize[V](ByteBuffer.wrap(zeroArray))

    /**
     * Wraps a byte array into a buffer.
     * public static ByteBuffer wrap(byte[] array) {
     *      return wrap(array, 0, array.length);
     * }
     */       

    val cleanedFunc = self.context.clean(func)
    // 调用combineByKeyWithClassTag实现聚合
    combineByKeyWithClassTag[V]((v: V) => cleanedFunc(createZero(), v),
      cleanedFunc, cleanedFunc, partitioner)
  }

  /**
   * Merge the values for each key using an associative function and a neutral "zero value" which
   * may be added to the result an arbitrary number of times, and must not change the result
   * (e.g., Nil for list concatenation, 0 for addition, or 1 for multiplication.).
   */
  def foldByKey(zeroValue: V, numPartitions: Int)(func: (V, V) => V): RDD[(K, V)] = self.withScope {
    foldByKey(zeroValue, new HashPartitioner(numPartitions))(func)
  }

  /**
   * Merge the values for each key using an associative function and a neutral "zero value" which
   * may be added to the result an arbitrary number of times, and must not change the result
   * (e.g., Nil for list concatenation, 0 for addition, or 1 for multiplication.).
   */
  def foldByKey(zeroValue: V)(func: (V, V) => V): RDD[(K, V)] = self.withScope {
    foldByKey(zeroValue, defaultPartitioner(self))(func)
  }
```

## 2、示例

```java
object foldByKey {

  def func2(index:Int,iter:Iterator[Any]):Iterator[Any]={
    iter.toList.map(x=>"分区 "+index+" 的计算结果是 "+x).iterator
  }

  def main(Args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("groupByKey").setMaster("local")
    val sc = new SparkContext(conf)

    val rdd = sc.parallelize(List(("a", 1), ("a", 6),("a", 7),("b", 5), ("b", 3)), 2)

    //rdd.mapPartitionsWithIndex(func2).foreach(println)

    val rlt = rdd.foldByKey(2)(_ + _) 

    println(rlt.collect().toList) //List((b,10), (a,18))
  }
}

/**
 * 分区0：("a", 1), ("a", 6)
 * 分区1：("a", 7),("b", 5), ("b", 3)
 *
 * "0值":2   【第一个参数函数：创建初始值】
 *  对分区0：
 *         2+1=3
 *         3+6=9 ("a",9)
 *  对分区1：
 *         2+5=7
 *         7+3=10 ("b",10)【第二个参数函数，追加】
 *         2+7=9  ("a",9)
 *
 *  rlt:("a",9+9=18)，即  【第三个参数函数，合并】
 *      ("b",10)
 *
 * 
 * */

```

