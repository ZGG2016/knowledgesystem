# 算子：textFile

## 1、源码

```java
  /**
   * 读取文本文件，从HDFS、本地文件系统(所有结点可访问)或任意hadoop支持的文件系统URI
   * 
   * Read a text file from HDFS, a local file system (available on all nodes), or any
   * Hadoop-supported file system URI, and return it as an RDD of Strings.
   * @param path path to the text file on a supported file system
   * @param minPartitions suggested minimum number of partitions for the resulting RDD   结果rdd的最小分区数
   * @return RDD of lines of the text file  文本文件行的RDD
   */
  def textFile(
      path: String,
      minPartitions: Int = defaultMinPartitions): RDD[String] = withScope {
    assertNotStopped()
    hadoopFile(path, classOf[TextInputFormat], classOf[LongWritable], classOf[Text],
      minPartitions).map(pair => pair._2.toString).setName(path)
  }

  //def defaultMinPartitions: Int = math.min(defaultParallelism, 2)
```

## 2、示例

```java
object coalesce {
  def main(Args:Array[String]): Unit = {
    val conf = new SparkConf().setAppName("coalesce").setMaster("local")
    val sc = new SparkContext(conf)

    val data = sc.textFile("src/main/data/coalesce.txt",10)

    val rlt1 = data.coalesce(4)
    val rlt2 = data.coalesce(100,shuffle = true)

    println(data.partitions.length) //10
    println(rlt1.partitions.length) //4
    println(rlt2.partitions.length) //100
  }
}
```