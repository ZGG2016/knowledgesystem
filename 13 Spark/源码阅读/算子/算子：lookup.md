# 算子：lookup

## 1、源码

```java
  /**
   * 在RDD中，根据key取values，返回值的列表。 
   * 
   * 如果RDD已分区，那么通过key搜索到的对应分区，这个操作就可以高效地完成。
   *  【直接从key所在的分区上找】
   *
   * Return the list of values in the RDD for key `key`. This operation is done efficiently if the
   * RDD has a known partitioner by only searching the partition that the key maps to.
   */
  def lookup(key: K): Seq[V] = self.withScope {

    self.partitioner match {
    	//已分区
      case Some(p) =>
      //根据key取到所在分区
        val index = p.getPartition(key)
        val process = (it: Iterator[(K, V)]) => {
          val buf = new ArrayBuffer[V]
          //判断元素的key是否等于传入的key
          for (pair <- it if pair._1 == key) {
            buf += pair._2  //追加进入
          }
          buf
        } : Seq[V]
        val res = self.context.runJob(self, process, Array(index))
        res(0)
       //未分区
      case None =>
      //先过滤出符合条件的，再取出value
        self.filter(_._1 == key).map(_._2).collect()
    }
  }
```

## 2、示例

```java
object lookup {
  def main(Args:Array[String]):Unit = {
    val conf = new SparkConf().setAppName("lookup.md test").setMaster("local")
    val sc = new SparkContext(conf)

    val rdd = sc.parallelize(List((1,"a"),(2,"b"),(1,"c")),2)

    val rlt = rdd.lookup(1)
    println(rlt) //WrappedArray(a, c)
  }
}
```