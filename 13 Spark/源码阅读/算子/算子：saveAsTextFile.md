# 算子：saveAsTextFile

## 1、源码

```java
  /**
   * 以text file的形式存储这个RDD。    参数是路径，不是文件名称
   * 
   * 元素类型是字符串
   *
   * 底层调用saveAsHadoopFile方法，只不过key是NullWritable
   * saveAsHadoopFile[TextOutputFormat[NullWritable, Text]](path)
   *
   * Save this RDD as a text file, using string representations of elements.
   */
  def saveAsTextFile(path: String): Unit = withScope {
    // https://issues.apache.org/jira/browse/SPARK-2075
    //
    // NullWritable is a `Comparable` in Hadoop 1.+, so the compiler cannot find an implicit
    // Ordering for it and will use the default `null`. However, it's a `Comparable[NullWritable]`
    // in Hadoop 2.+, so the compiler will call the implicit `Ordering.ordered` method to create an
    // Ordering for `NullWritable`. That's why the compiler will generate different anonymous
    // classes for `saveAsTextFile` in Hadoop 1.+ and Hadoop 2.+.
    //
    // Therefore, here we provide an explicit Ordering `null` to make sure the compiler generate
    // same bytecodes for `saveAsTextFile`.
    val nullWritableClassTag = implicitly[ClassTag[NullWritable]]
    val textClassTag = implicitly[ClassTag[Text]]
    val r = this.mapPartitions { iter =>
      val text = new Text()
      iter.map { x =>
        text.set(x.toString)
        (NullWritable.get(), text)
      }
    }
    RDD.rddToPairRDDFunctions(r)(nullWritableClassTag, textClassTag, null)
      .saveAsHadoopFile[TextOutputFormat[NullWritable, Text]](path)
  }

/**
 *  implicit def rddToPairRDDFunctions[K, V](rdd: RDD[(K, V)])
 *     (implicit kt: ClassTag[K], vt: ClassTag[V], ord: Ordering[K] = null): 
 *          PairRDDFunctions[K, V] = {
 *               new PairRDDFunctions(rdd)
 *          }
 *
 */

  /**
   *  压缩后，再存储
   *
   * Save this RDD as a compressed text file, using string representations of elements.
   */
  def saveAsTextFile(path: String, codec: Class[_ <: CompressionCodec]): Unit = withScope {
    // https://issues.apache.org/jira/browse/SPARK-2075
    val nullWritableClassTag = implicitly[ClassTag[NullWritable]]
    val textClassTag = implicitly[ClassTag[Text]]
    val r = this.mapPartitions { iter =>
      val text = new Text()
      iter.map { x =>
        text.set(x.toString)
        (NullWritable.get(), text)
      }
    }
    RDD.rddToPairRDDFunctions(r)(nullWritableClassTag, textClassTag, null)
      .saveAsHadoopFile[TextOutputFormat[NullWritable, Text]](path, codec)
  }

```

## 2、示例

```java
object saveAsTextFile {
  def main(Args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("saveAsTextFile").setMaster("local")
    val sc = new SparkContext(conf)

    val rdd = sc.parallelize(List(1,1,2,2,2,1,4,5))

    val rlt = rdd.map(x=>x+1)

    rlt.saveAsTextFile("src/main/data/saveAsTextFile")
  }
}
```