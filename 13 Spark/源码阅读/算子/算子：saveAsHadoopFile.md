# 算子：saveAsHadoopFile

## 1、源码

```java
  /**
   * 将RDD输出到任意hadoop支持的文件系统。
   *
   * 使用OutputFormat类支撑key和value的写入
   *
   * 【OutputFormat类：提供一个 RecordWriter 的实现，用来输出 Job 结果。输出文件保存在文件系统上。】
   *
   * 最终调用的是saveAsHadoopDataset
   *
   * Output the RDD to any Hadoop-supported file system, using a Hadoop `OutputFormat` class
   * supporting the key and value types K and V in this RDD.
   */
  //参数：存储路径
  def saveAsHadoopFile[F <: OutputFormat[K, V]](
      path: String)(implicit fm: ClassTag[F]): Unit = self.withScope {
    saveAsHadoopFile(path, keyClass, valueClass, fm.runtimeClass.asInstanceOf[Class[F]])
  }

  /**
   * 对结果进行压缩，再写入。
   *
   * Output the RDD to any Hadoop-supported file system, using a Hadoop `OutputFormat` class
   * supporting the key and value types K and V in this RDD. Compress the result with the
   * supplied codec.
   */
  //参数：存储路径，压缩器
  def saveAsHadoopFile[F <: OutputFormat[K, V]](
      path: String,
      codec: Class[_ <: CompressionCodec])(implicit fm: ClassTag[F]): Unit = self.withScope {
    val runtimeClass = fm.runtimeClass
    saveAsHadoopFile(path, keyClass, valueClass, runtimeClass.asInstanceOf[Class[F]], codec)
  }

  /**
   * 使用 new hadoop api 的 `OutputFormat`(mapreduce.OutputFormat) 对象
   *
   * Output the RDD to any Hadoop-supported file system, using a new Hadoop API `OutputFormat`
   * (mapreduce.OutputFormat) object supporting the key and value types K and V in this RDD.
   */
  //参数：存储路径
  def saveAsNewAPIHadoopFile[F <: NewOutputFormat[K, V]](
      path: String)(implicit fm: ClassTag[F]): Unit = self.withScope {
    saveAsNewAPIHadoopFile(path, keyClass, valueClass, fm.runtimeClass.asInstanceOf[Class[F]])
  }

  /**
   * Output the RDD to any Hadoop-supported file system, using a new Hadoop API `OutputFormat`
   * (mapreduce.OutputFormat) object supporting the key and value types K and V in this RDD.
   */
  //参数：存储路径、keyClass、valueClass、outputFormatClass、hadoop的配置
  def saveAsNewAPIHadoopFile(
      path: String,
      keyClass: Class[_],
      valueClass: Class[_],
      outputFormatClass: Class[_ <: NewOutputFormat[_, _]],
      conf: Configuration = self.context.hadoopConfiguration): Unit = self.withScope {
    // Rename this as hadoopConf internally to avoid shadowing (see SPARK-2038).
    val hadoopConf = conf

    //类型mapreduce中main函数
    val job = NewAPIHadoopJob.getInstance(hadoopConf)
    job.setOutputKeyClass(keyClass)
    job.setOutputValueClass(valueClass)
    job.setOutputFormatClass(outputFormatClass)
    val jobConfiguration = job.getConfiguration
    jobConfiguration.set("mapreduce.output.fileoutputformat.outputdir", path)
    saveAsNewAPIHadoopDataset(jobConfiguration)
  }

  /**
   * 对结果进行压缩，再写入。
   *
   * Output the RDD to any Hadoop-supported file system, using a Hadoop `OutputFormat` class
   * supporting the key and value types K and V in this RDD. Compress with the supplied codec.
   */
  //参数：存储路径、keyClass、valueClass、outputFormatClass、压缩器
  def saveAsHadoopFile(
      path: String,
      keyClass: Class[_],
      valueClass: Class[_],
      outputFormatClass: Class[_ <: OutputFormat[_, _]],
      codec: Class[_ <: CompressionCodec]): Unit = self.withScope {

    saveAsHadoopFile(path, keyClass, valueClass, outputFormatClass,
      new JobConf(self.context.hadoopConfiguration), Some(codec))
  }

  /**
   * Output the RDD to any Hadoop-supported file system, using a Hadoop `OutputFormat` class
   * supporting the key and value types K and V in this RDD.
   *
   * @note We should make sure our tasks are idempotent when speculation is enabled, i.e. do
   * not use output committer that writes data directly.
   * There is an example in https://issues.apache.org/jira/browse/SPARK-10063 to show the bad
   * result of using direct output committer with speculation enabled.
   *
   * 当启用推测执行时，要确保任务是幂等的。如，不要使用会直接写入数据的output committer
   * 什么是推测执行：https://blog.csdn.net/lvbiao_62/article/details/79751560
   *
   * 
   */
  //参数：存储路径、keyClass、valueClass、outputFormatClass、Job配置、压缩器
  def saveAsHadoopFile(
      path: String,
      keyClass: Class[_],
      valueClass: Class[_],
      outputFormatClass: Class[_ <: OutputFormat[_, _]],
      conf: JobConf = new JobConf(self.context.hadoopConfiguration),
      codec: Option[Class[_ <: CompressionCodec]] = None): Unit = self.withScope {
    // Rename this as hadoopConf internally to avoid shadowing (see SPARK-2038).
    val hadoopConf = conf
    hadoopConf.setOutputKeyClass(keyClass)
    hadoopConf.setOutputValueClass(valueClass)
    conf.setOutputFormat(outputFormatClass)
    for (c <- codec) {
      //启用压缩map的输出
      hadoopConf.setCompressMapOutput(true) 
      //启用压缩job的输出
      hadoopConf.set("mapreduce.output.fileoutputformat.compress", "true")
      //设置map输出的压缩器
      hadoopConf.setMapOutputCompressorClass(c) 
      //设置job输出的压缩器
      hadoopConf.set("mapreduce.output.fileoutputformat.compress.codec", c.getCanonicalName)
      //设置job输出的压缩类型
      hadoopConf.set("mapreduce.output.fileoutputformat.compress.type",
        CompressionType.BLOCK.toString)
//`mapreduce.output.fileoutputformat.compress.codec` 属性来控制使用压缩格式。默认值为RECORD，即对每一条记录进行压缩;如果将其改为BLOCK，将针对一组记录进行压缩,压缩效率更高.
    }

    // Use configured output committer if already set
    if (conf.getOutputCommitter == null) {
      hadoopConf.setOutputCommitter(classOf[FileOutputCommitter])
    }

    //如果启用了推测执行，且是直接写入数据的output committer，则提醒用户。
    // When speculation is on and output committer class name contains "Direct", we should warn
    // users that they may loss data if they are using a direct output committer.
    val speculationEnabled = self.conf.getBoolean("spark.speculation", false)
    val outputCommitterClass = hadoopConf.get("mapred.output.committer.class", "")
    if (speculationEnabled && outputCommitterClass.contains("Direct")) {
      val warningMessage =
        s"$outputCommitterClass may be an output committer that writes data directly to " +
          "the final location. Because speculation is enabled, this output committer may " +
          "cause data loss (see the case in SPARK-10063). If possible, please use an output " +
          "committer that does not have this behavior (e.g. FileOutputCommitter)."
      logWarning(warningMessage)
    }

    //设置输出路径
    //public static void setOutputPath(JobConf conf, Path outputDir) 
    FileOutputFormat.setOutputPath(hadoopConf,
      SparkHadoopWriterUtils.createPathFromString(path, hadoopConf))
    saveAsHadoopDataset(hadoopConf)
  }

  /**
   *  使用new Hadoop API
   * 
   *  参数conf：包含设置了的OutputFormat，输出路径
   *
   * Output the RDD to any Hadoop-supported storage system with new Hadoop API, using a Hadoop
   * Configuration object for that storage system. The Conf should set an OutputFormat and any
   * output paths required (e.g. a table name to write to) in the same way as it would be
   * configured for a Hadoop MapReduce job.
   *
   * @note We should make sure our tasks are idempotent when speculation is enabled, i.e. do
   * not use output committer that writes data directly.
   * There is an example in https://issues.apache.org/jira/browse/SPARK-10063 to show the bad
   * result of using direct output committer with speculation enabled.
   */
  def saveAsNewAPIHadoopDataset(conf: Configuration): Unit = self.withScope {
    val config = new HadoopMapReduceWriteConfigUtil[K, V](new SerializableConfiguration(conf))
    SparkHadoopWriter.write(
      rdd = self,
      config = config)
  }

  /**
   * Output the RDD to any Hadoop-supported storage system, using a Hadoop JobConf object for
   * that storage system. The JobConf should set an OutputFormat and any output paths required
   * (e.g. a table name to write to) in the same way as it would be configured for a Hadoop
   * MapReduce job.
   */
  def saveAsHadoopDataset(conf: JobConf): Unit = self.withScope {
    val config = new HadoopMapRedWriteConfigUtil[K, V](new SerializableJobConf(conf))
    SparkHadoopWriter.write(
      rdd = self,
      config = config)
  }

```


## 2、示例

```java
object saveAsHadoopFile {
  def main(Args:Array[String]): Unit = {
    val conf = new SparkConf().setAppName("saveAsHadoopFile").setMaster("spark://zgg:7077")
    val sc = new SparkContext(conf)

    val data = Array(("a","2"),("a","1"),("b","5"),("b","3"),("b","9"))
    val rdd = sc.parallelize(data,2)

    val outPath = "hdfs://zgg:9000/out/saveAsHadoopFile"
    rdd.saveAsHadoopFile(outPath,classOf[Text],classOf[Text],classOf[TextOutputFormat[Text,Text]])
  }
}
```