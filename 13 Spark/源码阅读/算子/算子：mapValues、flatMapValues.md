# 算子：mapValues、flatMapValues

## 1、源码

```java
  /**
   * 针对分区操作
   * 
   * 使用一个map函数操作RDD中的每个value，而不改变key。
   *
   * 和原RDD的分区数相同。【preservesPartitioning参数】
   *
   * Pass each value in the key-value pair RDD through a map function without changing the keys;
   * this also retains the original RDD's partitioning.
   */
  def mapValues[U](f: V => U): RDD[(K, U)] = self.withScope {
    val cleanF = self.context.clean(f)

    // 针对分区操作。对每个分区，操作每个(k,v)中的v，k保持不变。
    //pid:分区id
    new MapPartitionsRDD[(K, U), (K, V)](self,
      (context, pid, iter) => iter.map { case (k, v) => (k, cleanF(v)) },
      preservesPartitioning = true)
  }

  /**
   * 针对分区操作
   * 
   * 使用一个flatMap函数操作RDD中的每个value，而不改变key。
   *
   * 和原RDD的分区数相同。【preservesPartitioning参数】
   *
   * Pass each value in the key-value pair RDD through a flatMap function without changing the
   * keys; this also retains the original RDD's partitioning.
   */
  def flatMapValues[U](f: V => TraversableOnce[U]): RDD[(K, U)] = self.withScope {
    val cleanF = self.context.clean(f)
    new MapPartitionsRDD[(K, U), (K, V)](self,
      (context, pid, iter) => iter.flatMap { case (k, v) =>
        cleanF(v).map(x => (k, x))  //会对f处理的结果，再次调用map处理，所以会展平
      },
      preservesPartitioning = true)
  }
```

## 2、示例

二者区别同map、flatMap

```java
object mapValues {
  def main(Args:Array[String]): Unit = {
    val conf = new SparkConf().setAppName("mapValues").setMaster("local")
    val sc = new SparkContext(conf)

    val data = List(("a", "tom"), ("b", "jack"),("c", "mike"),("d", "alice"))
    val rdd = sc.parallelize(data,2)
    //针对分区操作
    val rlt = rdd.mapValues(x=>x.toUpperCase)
    
    rlt.collect.foreach(println) 
  }
}

/**
 * (a,TOM)
 * (b,JACK)
 * (c,MIKE)
 * (d,ALICE) 
 * 
 */
```

```java
object flatMapValues {
  def main(Args:Array[String]): Unit = {
    val conf = new SparkConf().setAppName("mapValues").setMaster("local")
    val sc = new SparkContext(conf)

    val data = List(("a", "tom"), ("b", "jack"),("c", "mike"),("d", "alice"))
    val rdd = sc.parallelize(data,2)
    //针对分区操作
    val rlt = rdd.flatMapValues(x=>x.toUpperCase)

    rlt.collect.foreach(println)
  }
}

/**
 * (a,T)
 * (a,O)
 * (a,M)
 * (b,J)
 * (b,A)
 * (b,C)
 * (b,K)
 * (c,M)
 * (c,I)
 * (c,K)
 * (c,E)
 * (d,A)
 * (d,L)
 * (d,I)
 * (d,C)
 * (d,E)
 *
 */
```