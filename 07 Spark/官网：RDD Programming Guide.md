# 官网：RDD Programming Guide

[TOC] 

**V3.0.0**

## 1、Overview  总览

从一个高层次的角度来看，**每个 Spark application 都由一个驱动程序组成** 。这个驱动程序一个在集群上运行着用户的 **main 函数和执行着各种并行操作**。

Spark 提供的主要抽象是一个弹性分布式数据集 **RDD**，它是 **在集群中分区的、执行并行操作的元素集合**。

RDD 可以根据 **Hadoop 文件系统（或者任何其它 Hadoop 支持的文件系统）中的一个文件** 创建RRD，也可以通过 **转换驱动程序中已存在的 Scala 集合** 来创建RRD。

为了让RDD在整个并行操作中更高效的重用，Spark **persist（持久化）一个 RDD 到内存中**。

最后，**RDD 会自动的从节点故障中恢复**。

在 Spark 中的第二个抽象是能够用于并行操作的 **共享变量**，默认情况下，当 Spark 的一个函数作为一组不同节点上的任务运行时，它 **将每个变量的副本应用到每个任务的函数中去**。有时候，一个变量需要在多个任务间，或者在任务和驱动程序间来共享。

Spark 支持 **两种类型的共享变量：广播变量和累加器**。

	广播变量用于在所有节点上的内存中缓存一个值。
	累加器是一个只能被 “added（增加）” 的变量，例如 counters 和 sums。

本指南介绍了每一种 Spark 所支持的语言的特性。如果启动 Spark 的交互式 shell 来学习是很容易的，要么是 `Scala shell[bin/spark-shell]`，要么是 `Python shell[ bin/pyspark]`。

## 2、Linking with Spark  依赖配置

**A. 对于scala**

Spark 3.0.0 默认支持的是 Scala 2.12。（也适用于其他的 Scala 版本）。未来编写 Scala 应用程序，你需要使用一个兼容的 Scala 版本。（如2.12.X）

首先可以通过 Maven 添加依赖：

    groupId = org.apache.spark
    artifactId = spark-core_2.12
    version = 3.0.0

然后，如果想访问 HDFS 集群，还需要添加对于 HDFS 版本的 hadoop-client 依赖

    groupId = org.apache.hadoop
    artifactId = hadoop-client
    version = <your-hdfs-version>

最后，在程序里导入 Spark 类，如下：

    import org.apache.spark.SparkContext
    import org.apache.spark.SparkConf

(Before Spark 1.3.0, you need to explicitly import org.apache.spark.SparkContext._ to enable essential implicit conversions.)

**B. 对于java**

Spark 3.0.0 支持 lambda 表达式写函数，也可以使用 `org.apache.spark.api.java.function` 包中的类。 

注意： 对 Java 7 的支持已在 Spark 2.2.0 中已移除。

首先可以通过 Maven 添加依赖：


    groupId = org.apache.spark
    artifactId = spark-core_2.12
    version = 3.0.0

然后，如果想访问 HDFS 集群，还需要添加对于 HDFS 版本的 hadoop-client 依赖

    groupId = org.apache.hadoop
    artifactId = hadoop-client
    version = <your-hdfs-version>

最后，在程序里导入 Spark 类，如下：

    import org.apache.spark.api.java.JavaSparkContext;
    import org.apache.spark.api.java.JavaRDD;
    import org.apache.spark.SparkConf;

**C. 对于python**

Spark 3.0.0 支持 Python 2.7+ 或 Python 3.4+。可以使用标准的 CPython 解释器，那么像 NumPy 一样的 
C 库就可以使用了。 同时也支持 PyPy 2.3+。

注意：在Spark 3.0.0版本，Python 2 被弃用了。

**在 Python 中配置运行 Spark applications 所需信息**，既可以在 bin/spark-submit 脚本中添加，也可以在
setup.py 中添加如下内容：

```python
	install_requires=[
		'pyspark=={site.SPARK_VERSION}'
	]
```

如果不是通过 pip 安装的 PySpark，可以使用 Spark 目录下的 `bin/spark-submit` 脚本运行 Spark applications。
这个脚本会载入 Spark 的 Java/Scala 库，并向集群提交应用程序。你也可以使用 `bin/pyspark` 启动一个 Python shell。

如果你想访问 HDFS 中的数据，需要 **保持 HDFS 和 PySpark 版本一致。** 对于常用的 HDFS 版本，Spark 主页上也有[预先构建的包](https://spark.apache.org/downloads.html)

最后，**在你的项目里导入一些 Spark 类**，如下：

    from pyspark import SparkContext, SparkConf

PySpark 在驱动程序和工作程序中都需要使用相同的 Python minor version。 PATH 中的版本是默认的，但你可以通过设置 PYSPARK_PYTHON 指定一个版本。

```sh
$ PYSPARK_PYTHON=python3.4 bin/pyspark
$ PYSPARK_PYTHON=/opt/pypy-2.5/bin/pypy bin/spark-submit examples/src/main/python/pi.py
```

## 3、Initializing Spark  初始化

**A. 对于scala**

**B. 对于java**

Spark 程序必须做的第一件事情是创建一个 **JavaSparkContext 对象**，它会告诉 Spark 如何访问集群。要创建一个 SparkContext，首先需要构建一个 **包含应用程序的信息的 SparkConf 对象**。

```java
SparkConf conf = new SparkConf().setAppName(appName).setMaster(master);
JavaSparkContext sc = new JavaSparkContext(conf);
```
appName 参数是应用程序的名称，显示在集群UI上。 master 可以是 Spark、 Mesos、YARN cluster URL、 或 local(本地模式)。在实际实践中，当在集群上运行程序时，您不希望在程序中将 master 给硬编码，而是使用 spark-submit 启动应用程序 并且接收它。然而，对于本地测试和单元测试，您可以通过 “local” 来运行 Spark 进程。

**C. 对于python**

Spark 程序必须做的第一件事情是创建一个 **SparkContext 对象**，它会告诉 Spark 如何访问集群。要创建一个 SparkContext，首先需要构建一个 **包含应用程序的信息的 SparkConf 对象**。

```python
conf = SparkConf().setAppName(appName).setMaster(master)
sc = SparkContext(conf=conf)
```
appName 参数是应用程序的名称，显示在集群UI上。 master 可以是 Spark、 Mesos、YARN cluster URL、 或 local(本地模式)。在实际实践中，当在集群上运行程序时，您不希望在程序中将 master 给硬编码，而是使用 spark-submit 启动应用程序 并且接收它。然而，对于本地测试和单元测试，您可以通过 “local” 来运行 Spark 进程。

### 3.1、Using the Shell  使用shell

**A. 对于scala**

**B. 对于python**

在 Spark Shell 中，有一个内置 SparkContext 可供使用， 称为 sc，但不能自己再创建一个 SparkContext 了。

相关 **启动参数如下**：

 `--master` 参数用来设置这个 SparkContext 连接到哪一个 master 上。

 `--py-files` 参数用来在运行时的路径上指定 Python .zip, .egg or .py 文件，通过传递逗号分隔的列表。

 `--packages ` 参数可以为 shell session 指定一些依赖(如 Spark包)，通过提供逗号分隔 Maven coordinates(坐标) 列表。

 `--repositories` 参数设置任何额外存在且依赖的仓库（例如 Sonatype）

 **任何 Spark 包所需的 Python 依赖(在该包的requirements.txt中列出)都需要手动使用 pip 安装。**

 例如，使用四个核来运行 `bin/pyspark`:

```sh
$ ./bin/pyspark --master local[4]
```

向搜索路径添加 `code.py` (为了之后导入 code) :

```sh
$ ./bin/pyspark --master local[4] --py-files code.py
```

所有的参数项，请运行 `run pyspark --help` 。在后台，pyspark 调用更通用的 [spark-submit 脚本](http://spark.apache.org/docs/latest/submitting-applications.html)。

也可以在 IPython 中启动 PySpark shell，要求 IPython 的版本是1.0.0以更高。在运行 `bin/pyspark` 时需要设置 PYSPARK_DRIVER_PYTHON 变量为ipython

```sh
$ PYSPARK_DRIVER_PYTHON=ipython ./bin/pyspark
```
使用 Jupyter notebook ，则需要作如下配置：

```sh
$ PYSPARK_DRIVER_PYTHON=jupyter PYSPARK_DRIVER_PYTHON_OPTS=notebook ./bin/pyspark
```
你可以通过设置 PYSPARK_DRIVER_PYTHON_OPTS 参数，自定义 ipython or jupyter 命令

Jupyter Notebook 服务启动后，你可以点击 “Files” 创建一个新的 “Python 2” 笔记本。在开始使用 Spark 前，需要在你的笔记本里输入 `%pylab inline` 。

## 4、Resilient Distributed Datasets (RDDs)

Spark 主要以一个 弹性分布式数据集（RDD）的概念为中心，它是一个 **容错且可以执行并行操作的元素的集合**。有两种方法可以创建 RDD：在你的驱动程序中 parallelizing 一个已存在的集合，或者在外部存储系统中引用一个数据集，
例如，一个共享文件系统、HDFS、HBase、或者提供 Hadoop InputFormat 的任何数据源。

### 4.1、Parallelized Collections  并行集合

**A. 对于scala**

**B. 对于java**

在驱动程序中，通过已存在的集合，**使用 JavaSparkContext 的 parallelize 方法来创建** 并行集合。集合元素被复制到可以执行并行操作的分布式数据集中。例如：

```java
List<Integer> data = Arrays.asList(1, 2, 3, 4, 5);
JavaRDD<Integer> distData = sc.parallelize(data);
```
分布式数据集一旦创建，就可以执行并行操作。例如，可以这样使用 `distData.reduce(lambda a, b: a + b)` 累加元素。

并行集合的一个重要参数就是分区数量。 **Spark 的一个任务操作一个分区** 。一般来说，每个 CPU 划分2-4个分区。 **正常情况下，Spark 会根据集群情况，自动设置分区数量。然而，你也可以给 parallelize 方法传递一个参数来手动设置。** (如 `sc.parallelize(data, 10)`)。注意：代码中的一些地方使用术语片term slice(分区的同义词)来维护向后兼容性。

**C. 对于python**

在驱动程序中，通过已存在的迭代器或集合，**使用 parallelize 方法来创建** 并行集合。集合元素被复制到可以执行并行操作
的分布式数据集中。例如：

```python
data = [1, 2, 3, 4, 5]
distData = sc.parallelize(data)
```
分布式数据集一旦创建，就可以执行并行操作。例如，可以这样使用 `distData.reduce(lambda a, b: a + b)` 累加元素。

并行集合的一个重要参数就是分区数量。 **Spark 的一个任务操作一个分区** 。一般来说，每个 CPU 划分 2-4 个分区。 **正常情况下，Spark 会根据集群情况，自动设置分区数量。然而，你也可以给 parallelize 方法传递一个参数来手动设置。** (如 `sc.parallelize(data, 10)`)。注意：代码中的一些地方使用术语片term slice(分区的同义词)来维护向后兼容性。

### 4.2、External Datasets  外部数据集

**A. 对于scala**

- 针对 SequenceFiles，使用 SparkContext 的 sequenceFile[K, V] 方法，其中 K 和 V 指的是文件中 key 和 values 的类型。这些 key 和 values 应该是 Hadoop 的 Writable 接口的子类，像 IntWritable and Text。此外，Spark 可以让您为一些常见的 Writables 指定原生类型; 例如，sequenceFile[Int, String] 会自动读取 IntWritables 和 Texts.

- 针对其它的 Hadoop InputFormats，您可以使用 SparkContext.hadoopRDD 方法，它接受一个任意的 JobConf 和 input format class、 key class 和 value class。通过相同的方法你可以设置你的输入源。你还可以针对 InputFormats 使用基于 “new” MapReduce API（org.apache.hadoop.mapreduce）的 SparkContext.newAPIHadoopRDD.

**B. 对于java**

Spark 可以从 Hadoop 所支持的任何存储源中创建分布式数据集，包括 **本地文件系统、HDFS**、Cassandra、HBase、[Amazon S3](https://cwiki.apache.org/confluence/display/HADOOP2/AmazonS3) 等等。Spark 支持文本文件、[SequenceFiles](https://hadoop.apache.org/docs/stable/api/org/apache/hadoop/mapred/SequenceFileInputFormat.html)、以及任何其它的 [Hadoop InputFormat](http://hadoop.apache.org/docs/stable/api/org/apache/hadoop/mapred/InputFormat.html)。

可以使用 SparkContext 的 **textFile 方法来创建文本文件的 RDD**。此方法需要一个文件的 URI
（计算机上的本地路径，hdfs://，s3n:// 等等的 URI），并且读取它们作为一个行的集合。下面是一个调用示例:

```java
JavaRDD<String> distFile = sc.textFile("data.txt");
```

distFile 一旦创建，便可以对其进行操作。例如，我们可以使用下面的 map 和 reduce 操作来统计行的数量：`distFile.map(s -> s.length()).reduce((a, b) -> a + b)`.

使用 Spark 读文件 **需要注意以下几点**：

- 如果读取本地文件系统的文件，那么文件需要在所有的工作节点上，路径也相同。要么复制，要么使用共享的网络挂载文件系统。

- 包括 textFile 在内的所有基于文件的输入方法，均支持读取目录、压缩文件，也支持通配符匹配。例如，textFile("/my/directory"), textFile("/my/directory/*.txt"), and textFile("/my/directory/*.gz").

- textFile 方法也有一个设置分区数的参数项。默认情况下，Spark 为一个 block （HDFS 中块大小默认是 128MB）创建一个分区，但你可以手动设置一个更大的分区数，但不能比 block 的数量还少。 

除了文本文件之外，Spark 的 Java API 也支持一些 **其它的数据格式**:

- JavaSparkContext.wholeTextFiles 可以读取包含多个小文本文件的目录，并且将它们作为一个 (filename, content) 对来返回。而 textFile 是文件中的每一行返回一个记录。

- 针对 SequenceFiles，使用 SparkContext 的 sequenceFile[K, V] 方法，其中 K 和 V 指的是文件中 key 和 values 的类型。这些 key 和 values 应该是 Hadoop 的 Writable 接口的子类，像 IntWritable and Text。此外，Spark 可以让您为一些常见的 Writables 指定原生类型; 例如，sequenceFile[Int, String] 会自动读取 IntWritables 和 Texts.

- 针对其它的 Hadoop InputFormats，您可以使用 JavaSparkContext.hadoopRDD 方法，它接受一个任意的 JobConf 和 input format class、 key class 和 value class。通过相同的方法你可以设置你的输入源。你还可以针对 InputFormats 使用基于 “new” MapReduce API（org.apache.hadoop.mapreduce）的 JavaSparkContext.newAPIHadoopRDD.

- JavaRDD.saveAsObjectFile 和 JavaSparkContext.objectFile 可以以持久化的 Java 对象的格式存储一个 RDD。 虽然这不如 Avro 等专门格式高效，但它提供了一种简单的方法来保存任何RDD。

**C. 对于python**

Spark 可以从 Hadoop 所支持的任何存储源中创建分布式数据集，包括 **本地文件系统、HDFS**、Cassandra、HBase、[Amazon S3](https://cwiki.apache.org/confluence/display/HADOOP2/AmazonS3) 等等。Spark 支持文本文件、[SequenceFiles](https://hadoop.apache.org/docs/stable/api/org/apache/hadoop/mapred/SequenceFileInputFormat.html)、以及任何其它的 [Hadoop InputFormat](http://hadoop.apache.org/docs/stable/api/org/apache/hadoop/mapred/InputFormat.html)。

可以使用 SparkContext 的 **textFile 方法来创建文本文件的 RDD**。此方法需要一个文件的 URI
（计算机上的本地路径，hdfs://，s3n:// 等等的 URI），并且读取它们作为一个行的集合。下面是一个调用示例:

```sh
>>> distFile = sc.textFile("data.txt")
```

distFile 一旦创建，便可以对其进行操作。例如，我们可以使用下面的 map 和 reduce 操作来统计行的数量：`distFile.map(lambda s: len(s)).reduce(lambda a, b: a + b).`

使用 Spark 读文件 **需要注意以下几点**：

- 如果读取本地文件系统的文件，那么文件需要在所有的工作节点上，路径也相同。要么复制，要么使用共享的网络挂载文件系统。

- 包括 textFile 在内的所有基于文件的输入方法，均支持读取目录、压缩文件，也支持通配符匹配。例如，textFile("/my/directory"), textFile("/my/directory/*.txt"), and textFile("/my/directory/*.gz").

- textFile 方法也有一个设置分区数的参数项。默认情况下，Spark 为一个 block （HDFS 中块大小默认是 128MB）
创建一个分区，但你可以手动设置一个更大的分区数，但不能比 block 的数量还少。 

除了文本文件之外，Spark 的 Python API 也支持一些 **其它的数据格式**:

- SparkContext.wholeTextFiles 可以读取包含多个小文本文件的目录，并且将它们作为一个 (filename, content) 对来返回。而 textFile 是文件中的每一行返回一个记录。

- RDD.saveAsPickleFile 和 SparkContext.pickleFile 可以以持久化的Python对象的格式存储一个 RDD. 可以批量存储，默认大小是10.(Batching is used on pickle serialization, with default batch size 10.)

- SequenceFile and Hadoop Input/Output Formats

注意：这个特性当前处在试验阶段，是为更高级的用户准备的。未来可能会被 Spark SQL 的 read/write 方法取代。

### 4.3、RDD Operations  操作

RDDs 支持两种类型的操作： **transformations（转换）和 actions（动作）**。transformations 是根据已存在的数据集创建一个
新的数据集，actions 是将在 数据集上执行计算后，将值返回给驱动程序。例如，map 就是一个 transformation，它将每个数据集元素
传递给一个函数，并返回一个的新 RDD 。 reduce 是一个 action， 它通过执行一些函数，聚合 RDD 中所有元素，并将最终结果给返
回驱动程序（虽然也有一个并行 reduceByKey 返回一个分布式数据集）。

Spark 中所有的 **transformations 都是懒加载的**，因此它不会立刻计算出结果。只有当需要返回结果给驱动程序时，
transformations 才开始计算。这种设计使 Spark 的运行更高效。例如，map 所创建的数据集将被用在 reduce 中，并且只有 reduce 的计算结果返回给驱动程序，而不是返回一个更大的数据集.

**默认情况下，对于一个已转换的 RDD，每次你在这个 RDD 运行一个 action 时，它都会被重新计算。** 但是，可以使用 persist/cache 方法将 RDD 持久化到内存中；在这种情况下，Spark 为了下次查询时可以更快地访问，会把数据保存在集群上。此外，还支持持
续持久化 RDDs 到磁盘，或跨多个节点复制。


#### 4.3.1 Basics 基础

**A. 对于scala**

**B. 对于java**

```java
JavaRDD<String> lines = sc.textFile("data.txt");
JavaRDD<Integer> lineLengths = lines.map(s -> s.length());
int totalLength = lineLengths.reduce((a, b) -> a + b);
```
- 第一行从外部文件读取数据，创建一个基本的 RDD，但这个数据集并未加载到内存中或即将被操作：lines 仅仅是一个类似指针的东西，指向该文件。

- 第二行定义了 lineLengths 作为 map transformation 的结果。请注意，由于延迟加载，lineLengths 不会被立即计算。

- 最后，运行 reduce，这是一个 action。此时，Spark 分发计算任务到不同的机器上运行，每台机器都运行 map 的一部分，并执行本地运行聚合。仅仅返回它聚合后的结果给驱动程序。

如果我们也希望以后再次使用 lineLengths，我们还可以添加:

```java
lineLengths.persist(StorageLevel.MEMORY_ONLY());
```
在 reduce 之前，这将导致 lineLengths 在第一次计算之后就被保存在 memory 中。

**C. 对于python**

```python
lines = sc.textFile("data.txt")
lineLengths = lines.map(lambda s: len(s))
totalLength = lineLengths.reduce(lambda a, b: a + b)
```

- 第一行从外部文件读取数据，创建一个基本的 RDD，但这个数据集并未加载到内存中或即将被操作：lines 仅仅是一个类似指针的东西，指向该文件。

- 第二行定义了 lineLengths 作为 map transformation 的结果。请注意，由于延迟加载，lineLengths 不会被立即计算。

- 最后，运行 reduce，这是一个 action。此时，Spark 分发计算任务到不同的机器上运行，每台机器都运行 map 的一部分，并执行本地运行聚合。仅仅返回它聚合后的结果给驱动程序。

如果我们也希望以后再次使用 lineLengths，我们还可以添加:

```python
lineLengths.persist()
```
在 reduce 之前，这将导致 lineLengths 在第一次计算之后就被保存在 memory 中。

#### 4.3.2 Passing Functions to Spark  给 Spark 传函数

**A. 对于scala**

**B. 对于java**

当驱动程序在集群上运行时，Spark 的 API 在很大程度上依赖于传递函数。在 Java 中，通过实现了 `org.apache.spark.api.java.function` 包里的接口的类来表示函数。有2种推荐的方式来创建这种函数:

- 在你的类中实现 Function 接口，可以是匿名内部类，也可以是创建一个，然后传递一个它的对象给 Spark

- 使用[Lambda expressions](https://docs.python.org/2/tutorial/controlflow.html#lambda-expressions) 表达式简洁地定义一个类。

为了简洁，本指南大部分都使用了 lambda 语法，这样就很容易使用所有相同的API。如：

```java
JavaRDD<String> lines = sc.textFile("data.txt");
JavaRDD<Integer> lineLengths = lines.map(new Function<String, Integer>() {
  public Integer call(String s) { return s.length(); }
});
int totalLength = lineLengths.reduce(new Function2<Integer, Integer, Integer>() {
  public Integer call(Integer a, Integer b) { return a + b; }
});
```

或者，按如下方式写的话，会显得很笨拙：

```java
class GetLength implements Function<String, Integer> {
  public Integer call(String s) { return s.length(); }
}
class Sum implements Function2<Integer, Integer, Integer> {
  public Integer call(Integer a, Integer b) { return a + b; }
}

JavaRDD<String> lines = sc.textFile("data.txt");
JavaRDD<Integer> lineLengths = lines.map(new GetLength());
int totalLength = lineLengths.reduce(new Sum());
```
Note that anonymous inner classes in Java can also access variables in the enclosing scope as long as they are marked final. Spark will ship copies of these variables to each worker node as it does for other languages.

注意：只要闭包作用域内得变量标记为 final，Java 的匿名内部类就可以访问。 Spark会分发这些变量到每个节点上。

**C. 对于python**

当驱动程序在集群上运行时，Spark 的 API 在很大程度上依赖于传递函数。有3种推荐的方式来做到这一点:

- [Lambda expressions](https://docs.python.org/2/tutorial/controlflow.html#lambda-expressions) 适用于一些简单的函数。（Lambdas 不支持多条语句，或没有返回值的语句）

- Local defs inside the function calling into Spark, for longer code.下例描述的情况

- Top-level functions in a module. ？？？

例如，传递一个比 lambda 函数更长的函数，思考如下代码：

```python
"""MyScript.py"""
if __name__ == "__main__":
    def myFunc(s):
        words = s.split(" ")
        return len(words)

    sc = SparkContext(...)
    sc.textFile("file.txt").map(myFunc)
```

请注意，虽然也有可能传递一个类的实例（与单例对象相反）的方法的引用，这需要发送整个对象，包括类中其它方法。例如，考虑:

```python
class MyClass(object):
    def func(self, s):
        return s
    def doStuff(self, rdd):
        return rdd.map(self.func)
```

这里，如果我们创建一个新的 MyClass 类，并调用 doStuff 方法。在 map 内有 MyClass 实例的 func1 方法的引用，所以整个对象
需要被发送到集群的。

类似的方式，访问外部对象的字段将引用整个对象:

```python
class MyClass(object):
	def __init__(self):
        self.field = "Hello"
    def doStuff(self, rdd):
        return rdd.map(lambda s: self.field + s)
```     

为了避免这个问题，最简单的方式是复制 field 到一个本地变量，而不是外部访问它:

```python
def doStuff(self, rdd):
    field = self.field
    return rdd.map(lambda s: field + s)
```

#### 4.3.3 Understanding closures  理解闭包

在集群中执行代码时，一个关于 Spark 更难的事情是理解变量和方法的范围和生命周期。在其作用域之外修改变量的RDD操作经常会造成
混淆。在下面的例子中，我们将看一下使用的 foreach() 代码递增累加计数器，但类似的问题，也可能会出现其他操作上.


##### 4.3.3.1 Example

考虑一个简单的 RDD 元素求和，**在不同一个 JVM 中执行，产生的结果可能不同。** 一个常见的例子是当 Spark 运行在 local 本地模式（--master = local[n]）时，与部署 Spark 应用到群集（例如，通过 spark-submit 到 YARN）:

**A. 对于scala**

**B. 对于java**

```java
int counter = 0;
JavaRDD<Integer> rdd = sc.parallelize(data);

// Wrong: Don't do this!!
rdd.foreach(x -> counter += x);

println("Counter value: " + counter);
```

**C. 对于python**

```python
counter = 0
rdd = sc.parallelize(data)

# Wrong: Don't do this!!
def increment_counter(x):
    global counter
    counter += x
rdd.foreach(increment_counter)

print("Counter value: ", counter)

```

##### 4.3.3.2 Local vs. cluster modes

上面的代码行为是不确定的，并且可能无法按预期正常工作。为了执行作业，**Spark 将 RDD 操作的处理分解为 tasks，每个 task 由 executor 执行。** 在执行之前，Spark 计算任务的 closure（闭包）。**闭包是指 executor 在 RDD 上执行计算的时候必须可见的
那些变量和方法**（在这种情况下是foreach()）。闭包被序列化并被发送到每个 executor。

发送给每个 executor 的闭包中的变量是副本，因此，当 foreach 函数内使用计数器时，它不再是 driver 节点上的计数器。driver 节点的内存中仍有一个计数器，但该变量是 executors 不可见的！ executors 只能看到序列化闭包的副本。因此，计数器的最终值仍
然为零，因为计数器上的所有操作都引用了序列化闭包内的值。**【每个 executor 中的变量都是副本，在其中的操作改变的都只是副本的
值，而不是 driver 节点上的值】**

**在本地模式下，在某些情况下，该 foreach 函数实际上将在与 driver 相同的 JVM 内执行，并且会引用相同的原始计数器，并可能
实际更新它。**

为了确保在这些场景中明确定义的行为，**应该使用一个 Accumulator**。 Spark 中的累加器专门用于提供一种机制，**用于在集群中
的工作节点之间执行拆分时安全地更新变量**。

一般来说，closures - constructs像循环或本地定义的方法，不应该被用来改变一些全局状态。Spark并没有定义或保证从闭包外引用的对象的改变行为。这样做的一些代码可以在本地模式下工作，但这只是偶然，并且这种代码在分布式模式下的行为不会像你想的那样。如果需要某些全局聚合，请改用累加器。

##### 4.3.3.3 Printing elements of an RDD   打印RDD元素

**单台机器**：rdd.foreach(println) 或 rdd.map(println) 用于打印 RDD 的所有元素。在一台机器上，这将产生预期的输出和打印 RDD 的所有元素。

**集群**：然而，在集群 cluster 模式下，输出被写入到 executors 的标准输出，而不是驱动程序上的。因此，结果不会输出到驱动
程序的标准输出中。要打印驱动程序的所有元素，可以使用的 collect() 方法首先把 RDD 放到驱动程序节点上，再执行foreach(println)，如：`rdd.collect().foreach(println)`。但这样做可能会导致驱动程序内存耗尽，因为 collect() 的结果是整个 RDD 到一台机器上， 如果你只需要打印 RDD 的几个元素，一个更安全的方法是使用 take()：`rdd.take(100).foreach(println)`。

#### 4.3.4、Working with Key-Value Pairs  操作键值对

**A. 对于scala**

**B. 对于java**

虽然大多数 Spark 操作的对象是包含任何类型 RDDs ，只有少数特殊的操作可用于键值对的 RDDs。最常见的是分布式 “shuffle” 操作，如通过元素的 key 来进行 grouping 或 aggregating 操作.

在 Java 中，使用 scala.Tuple2 表示键值对。你可以使用 new Tuple2(a, b) 来创建一个元组，`tuple._1()`、`tuple._2()` 访问它的字段。

键值对的 RDDs 使用 JavaPairRDD 类表示。可以使用一个特殊版本的 map 操作(如mapToPair、flatMapToPair)，基于 JavaRDDs 创建一个 JavaPairRDD。 JavaPairRDD 可以使用标准的 RDD 函数，也可以使用特有的函数。

例如，下面的代码使用 reduceByKey 操作统计文本文件中每一行出现了多少次:

```java
JavaRDD<String> lines = sc.textFile("data.txt");
JavaPairRDD<String, Integer> pairs = lines.mapToPair(s -> new Tuple2(s, 1));
JavaPairRDD<String, Integer> counts = pairs.reduceByKey((a, b) -> a + b);
```

也可以使用 `counts.sortByKey()` ，按字母表的顺序进行排序，再使用 `counts.collect()` 将结果以对象列表的形式带回驱动程序。

注意：在键值对操作中，当你的 key 是自定义对象时，需要确保自定义的equals()方法与匹配的hashCode()方法一起使用。更多细节见[Object.hashCode() documentation](https://docs.oracle.com/javase/8/docs/api/java/lang/Object.html#hashCode--)

**C. 对于python**

虽然大多数 Spark 操作的对象是包含任何类型 RDDs ，只有少数特殊的操作可用于键值对的 RDDs。最常见的是分布式 “shuffle” 操作，如通过元素的 key 来进行 grouping 或 aggregating 操作.

在 Python 中，这些操作在包含内置 Python 元组的 RDDs 上工作，例如(1,2)。创建这样的元组后，再调用相关的操作。

例如，下面的代码使用 reduceByKey 操作统计文本文件中每一行出现了多少次:

```python
lines = sc.textFile("data.txt")
pairs = lines.map(lambda s: (s, 1))
counts = pairs.reduceByKey(lambda a, b: a + b)

```

也可以使用 `counts.sortByKey()` ，按字母表的顺序进行排序，再使用 `counts.collect()` 将结果以对象列表的形式带回驱动程序。

#### 4.3.5、Transformations

算子|含义
---|:---
map(func)| 返回一个新的分布式数据集，它由一个函数 func 作用在数据源中的每个元素生成。
filter(func)|返回一个新的分布式数据集，它由一个函数 func 作用在数据源的元素上，且返回值为 true 的元素组成。
flatMap(func)|与 map 类似，但是每一个输入项可以被映射成 0 个或多个输出项（所以 func 应该返回一个序列 而不是一个单独项）。
mapPartitions(func)|与 map 类似，但是独立的运行在 RDD 的每个分区(block)上。所以在一个类型为 T 的 RDD 上运行时，func 必须是 Iterator<T> => Iterator<U> 类型。
mapPartitionsWithIndex(func)|与 mapPartitions 类似，但是也需要提供一个代表分区索引整型值作为参数的 func ，所以在一个类型为 T 的 RDD 上运行时 func 必须是 (Int, Iterator<T>) => Iterator<U> 类型。【指定一个分区】
sample(withReplacement, fraction, seed)|从源数据中按一定比例抽样，并设置是否放回抽样、是否使用随机数生成器种子。
union(otherDataset)|返回一个包含了源数据集和其它数据集的并集的数据集。
intersection(otherDataset)|返回一个包含了源数据集和其它数据集的交集的数据集。
distinct([numPartitions]))|返回一个源数据集去重后的数据集。
groupByKey([numPartitions])|当一个(K,V)对数据集调用的时候，返回一个(K, Iterable<V>)对数据集。Note: 如果分组是为了在每一个 key 上执行聚合操作（如sum、average)，使用 reduceByKey 或 aggregateByKey 来计算性能会更好。默认情况下，输出结果的并行度取决于父 RDD 的分区数，，但可以传递一个可选的 numPartitions 参数来设置不同的任务数。
reduceByKey(func, [numPartitions])|当一个(K,V)对数据集调用的时候，返回一个(K, V)对数据集，其中每个 K 的 V 是经过 func 聚合后的结果。它必须是 type (V,V) => V 的类型。像 groupByKey 一样，reduce 任务数可以通过第二个可选的参数配置。
aggregateByKey(zeroValue)(seqOp, combOp, [numPartitions])|当一个(K,V)对数据集调用的时候，返回一个(K, U)对数据集，其中每个 K 的 U 是使用 combine functions and a neutral "zero" value 聚合后的结果。聚合值类型可以和输入值类型不同，同时避免不必要的分配。像 groupByKey 一样，reduce 任务数可以通过参数配置。
sortByKey([ascending], [numPartitions])|当一个(K,V)对数据集调用的时候，其中的 K 实现有序，返回一个按 keys 升序或降序的(K,V)对数据集，由 boolean 类型的 ascending 参数来指定。
join(otherDataset, [numPartitions])|在一个 (K, V) 和 (K, W) 类型的数据集上调用时，返回一个 (K, (V, W)) 对数据集，with all pairs of elements for each key. Outer joins 可以通过 leftOuterJoin, rightOuterJoin 和  fullOuterJoin 来实现。
cartesian(otherDataset)|在一个 T 和 U 类型的数据集上调用时，返回一个 (T, U) 对类型的数据集（所有元素的对）。
pipe(command, [envVars])|通过 shell 命令来将每个 RDD 的分区建立管道。例如，一个 Perl 或 bash 脚本。 RDD 的元素会被写入进程的标准输入，并且输出到标准输出的行输出被作为一个字符串型 RDD返回。 【lines output to its stdout are returned as an RDD of strings.】
coalesce(numPartitions)|减少 RDD 中分区数为 numPartitions。对于一个大的数据集执行过滤后再操作更有效。
repartition(numPartitions) |Reshuffle RDD 中的数据以创建更多或更少的分区，并将每个分区中的数据尽量保持均匀。该操作总是通过网络来 shuffles 所有的数据。
repartitionAndSortWithinPartitions(partitioner) |根据给定的分区器对 RDD 进行重新分区，并在每个结果分区中，按照 key 值对记录排序。这比每一个分区中先调用 repartition 然后再 sorting（排序）效率更高，因为它可以将排序过程推送到 shuffle 操作的机器上进行。

#### 4.3.6、Actions

算子|含义
---|:---
reduce(func)|使用函数 func 聚合数据集中的元素，这个函数输入为两个元素，返回为一个元素。这个函数应该是可交换（commutative）和关联（associative）的，这样才能保证它可以被正确地并行计算。
collect()|在驱动程序中，以一个数组的形式返回数据集中的所有元素。这在 filter 返回足够的数据子集的操作通常是有用的。
count()|返回数据集中元素的个数。
first()|返回数据集中的第一个元素（类似于 take(1)。
take(n)|将数据集中的前 n 个元素作为一个数组返回。
takeSample(withReplacement, num, [_seed_])|对一个数据集进行随机抽样，返回一个包含 num 个随机抽样（random sample）元素的数组，参数 withReplacement 指定是否有放回抽样，参数 seed 指定生成随机数的种子。
takeOrdered(n, [ordering])|返回 RDD 按自然顺序或自定义比较器排序后的前 n 个元素。
saveAsTextFile(path) | 将数据集中的元素以文本文件（或文本文件集合）的形式写入本地文件系统、HDFS 或其它 Hadoop 支持的文件系统中的给定目录中。Spark 将对每个元素调用 toString 方法，将数据元素转换为文本文件中的一行记录。
saveAsSequenceFile(path) (Java and Scala) |将数据集中的元素以 Hadoop SequenceFile 的形式写入到本地文件系统、HDFS 或其它 Hadoop 支持的文件系统指定的路径中。该操作可以在实现了 Hadoop Writable 接口的键值对 RDD 上使用。在 Scala 中，它还可以隐式转换为 Writable 的类型（Spark 包括了基本类型的转换，例如 Int，Double，String 等等)。
saveAsObjectFile(path) (Java and Scala)|使用 Java 序列化以简单的格式写入数据集元素，然后使用 SparkContext.objectFile() 进行加载。
countByKey()| 仅适用于（K,V）类型的 RDD。返回（K , Int）对的 hashmap，其中Int表示 key 的计数。
foreach(func)| 对数据集中每个元素运行函数 func 。这通常用于副作用（side effects），例如更新一个 Accumulator 或与外部存储系统进行交互。 Note: modifying variables other than Accumulators outside of the foreach() may result in undefined behavior. See Understanding closures for more details.

该 Spark RDD API 还暴露了一些 actions 的异步版本，例如针对 foreach 的 foreachAsync，它们会立即返回
一个FutureAction 到调用者，而不是在完成 action 时阻塞。这可以用于管理或等待 action 的异步执行。

#### 4.3.7、Shuffle operations

Spark 里的某些操作会触发 shuffle 。shuffle 是 spark  重新分配数据的一种机制，使得这些数据可以跨不同的分区进行分组。这通常涉及在 executors 间和 机器间复制数据，这使得 shuffle 成为一个复杂高代价的操作。

##### 4.3.7.1、Background

为了理解 shuffle 操作的过程，以 reduceByKey 为例。 reduceBykey 操作会产生一个新的 RDD，其中 key 与 所有和这个 key 相同的的值组合成为一个 tuple - key 以及与 key 相关联的所有值在 reduce 函数上的执行结果。面临的挑战是，**与这个 key 相关联的所有值不一定都在同一个分区内，甚至是不一定在同一台机器里，但是它们必须共同被计算**。

在 spark 里，对于特定的操作需要数据不跨分区分布。在计算期间，一个任务在一个分区上执行，为了所有数据都在
一个 reduceByKey 的 reduce 任务上运行，我们需要执行一个 all-to-all 操作。它必须 **从所有分区读取所有的 key 及其对应的值，并且将它们跨分区的聚集起来去计算每个 key 的结果** ，这个过程就叫做 shuffle。

尽管新混洗后的数据的每个分区中的元素集是确定的，分区本身的顺序也是确定的，但是这些元素的顺序不是确定的。**如果希望混洗后的数据是有序的**，可以使用:

- mapPartitions 对每个分区进行排序，例如，.sorted
- repartitionAndSortWithinPartitions 在分区的同时对分区进行高效的排序.
- sortBy 对 RDD 进行全局的排序

触发的 shuffle 的操作包括再分区操作（如 repartition 、 coalesce )、 ‘ByKey’ 操作（如groupByKey 和 reduceByKey，除了 counting ），和 join 操作（像 cogroup 和 join）。

##### 4.3.7.2、Performance Impact  性能影响

Shuffle 是一个代价比较高的操作，它涉及磁盘 I/O、数据序列化、网络 I/O。为了准备 shuffle 操作的数据，Spark 启动了一系列的任务，map 任务组织数据，reduce 任务完成数据的聚合。这些术语来自 MapReduce，跟 Spark 的 map 操作和 reduce 操作没有关系。

在内部，一个 map 任务的所有结果数据会保存在内存，直到内存不能全部存储为止。然后，这些数据将基于目标分区进行排序并写入一个单独的文件中。在 reduce 时，任务将读取相关的已排序的数据块。

某些 shuffle 操作会 **消耗大量的堆内存空间**，因为 shuffle 操作在数据转换前后，需要 **在使用内存中的数据结构对数据进行组织**。需要特别说明的是，reduceByKey and aggregateByKey create these structures on the map side, and 'ByKey operations generate these on the reduce side。**当内存满的时候，Spark 会把未缓存的数据存到磁盘上**，这将导致额外的磁盘 I/O 开销和垃圾回收开销的增加。

shuffle 操作还会 **在磁盘上生成大量的中间文件** 。在 Spark 1.3 中，这些文件将会保留至对应的 RDD 不再使用并被垃圾回收为止。这么做的好处是，如果在 Spark 重新计算 RDD 的血统关系时，shuffle 操作产生的这些中间文件不需要重新创建。如果 Spark 应用长期保持对 RDD 的引用，或者垃圾回收不频繁，这将导致垃圾回收的周期比较长。这意味着，长期运行 Spark 任务可能会消耗大量的磁盘空间。临时数据存储路径可以通过 SparkContext 中设置参数 `spark.local.dir` 进行配置。

shuffle 操作的行为可以通过调节多个参数进行设置。详细的说明请看 Spark 配置指南中的 [Shuffle Behavior](http://spark.apache.org/docs/latest/configuration.html#shuffle-behavior) 部分。

### 4.4、RDD Persistence  持久化

Spark 中一个很重要的能力是跨操作地 **持久化（或缓存）数据集到内存中**。当持久化了一个 RDD 时，**each node stores any partitions of it that it computes in memory and reuses them in other actions on that dataset (or datasets derived from it)**。 这样会让以后的 action 操作计算速度加快（通常超过 10 倍）。缓存是迭代算法和快速的交互式使用的重要工具。

可以使用 **persist() 方法或 cache() 方法持久化 RDD** 。数据将会在第一次 action 操作时进行计算，并缓存
在节点的内存中。Spark 的缓存具有容错机制，**如果一个缓存的 RDD 的某个分区丢失了，Spark 将自动地按照原来
的计算过程，自动重新计算。**

另外，每个持久化的 RDD 可以 **使用不同的存储级别** 进行存储，例如，持久化到磁盘、已序列化的 Java 对象持
久化到内存（可以节省空间）、跨节点间复制。这些存储级别通过传递一个 StorageLevel 对象（Scala，Java，
Python）给 persist() 方法进行设置。 **cache() 方法是使用默认存储级别的快捷设置方法，默认的存储级别
是 StorageLevel.MEMORY_ONLY（将反序列化的对象存储到内存中）**。详细的存储级别介绍如下:

存储级别|含义
---|:---
MEMORY_ONLY | 将 RDD 以反序列化的 Java 对象的形式存储在 JVM 中。如果内存空间不够，部分分区将不再缓存，而是在每次需要用到这些数据时重新进行计算。这是默认的级别。
MEMORY_AND_DISK | 将 RDD 以反序列化的 Java 对象的形式存储在 JVM 中。如果内存空间不够，将未缓存的分区存储到磁盘，在需要使用时从磁盘读取。(If the RDD does not fit in memory, store the partitions that don't fit on disk)
MEMORY_ONLY_SER (Java and Scala) | 将 RDD 以序列化的 Java 对象的形式进行存储（每个分区为一个字节 数组）。这种方式会比反序列化对象的方式节省很多空间，尤其是在使用 fast serializer 时会节省更多的空间，但是在读取时会增加 CPU 的计算负担
MEMORY_AND_DISK_SER (Java and Scala) | 类似于 MEMORY_ONLY_SER, 但是溢出的分区会存储到磁盘，而不是在用到它们时重新计算。  
DISK_ONLY | 只在磁盘上缓存 RDD。
MEMORY_ONLY_2, MEMORY_AND_DISK_2, etc | 与上面的级别功能相同，只不过每个分区只在集群的两个节点上建立副本。
OFF_HEAP (experimental) | 类似于 MEMORY_ONLY_SER，但是将数据存储在 off-heap memory 中。这需要启用 off-heap 内存。

Note: **在 Python 中**，存储对象总是使用 Pickle 库来序列化对象，所以你选择哪种序列化级别都没关系。在 Python 中**可用的存储级别有 MEMORY_ONLY，MEMORY_ONLY_2，MEMORY_AND_DISK，MEMORY_AND_DISK_2，DISK_ONLY，和 DISK_ONLY_2**。

**在 shuffle 操作中（例如 reduceByKey），即便是用户没有调用 persist 方法，Spark 也会自动缓存一些中间数据**。这么做的目的是，如果在 shuffle 的过程中某个节点运行失败时，就不需要重新计算所有的输入数据。如果用户想多次使用某个 RDD，强烈推荐在该 RDD 上调用 persist 方法。

#### 4.4.1、Which Storage Level to Choose?  选择原则

Spark 的存储级别的为了在 memory 内存使用率和 CPU 效率之间进行权衡。建议按下面的过程进行存储级别的选择:

- 如果您的 RDD 适合于默认存储级别（MEMORY_ONLY），就保持这种配置。这是 CPU 效率最高的选项，让 RDD 上的操作尽可能快地运行。

- 如果不是，试着使用 MEMORY_ONLY_SER 和选择一个能快速序列化的库，以使对象更加节省空间，但仍然能够快速访问。(Java和Scala)

- 除非计算数据集的函数是消耗很多资源，或者过滤大量的数据，否则不要溢出到磁盘。不然，重新计算分区可能与从磁盘读取分区一样快。

- 如果需要快速故障恢复，请使用复制的存储级别（例如，如果使用 Spark 来服务来自网络应用程序的请求）。所有的 存储级别通过重新计算丢失的数据来提供完整的容错能力，但副本可让您继续在 RDD 上运行任务，而无需等待重新计算一个丢失的分区。

#### 4.4.2、Removing Data 移除数据

Spark 会自动监视每个节点上的缓存使用情况，并使用 `least-recently-used（LRU）`的方式来丢弃旧数据分区。如果您想手动删除 RDD，使用 **RDD.unpersist()** 方法。这个方法默认是不阻塞的。若要阻塞直到释放资源，请在调用此方法时指定 `blocking=true` 。

## 5、Shared Variables  共享变量

通常，一个传递给 Spark 操作（例如 map 或 reduce）的函数 func 是在远程集群节点上执行的。该函数 func 在多个节点执行过程中使用的变量，是同一个变量的多个副本。这些变量的以副本的方式拷贝到每个机器上，并且各个远程机器上变量的更新并不会传播回驱动程序。通用且支持 read-write（读-写）的共享变量在任务间是不能胜任的。
所以，Spark 提供了两种特定类型的共享变量：broadcast variables（广播变量）和 accumulators（累加器）。
**【驱动程序分发的变量在各节点更新后，不会回传到驱动程序】**

### 5.1、Broadcast Variables  广播变量

广播变量允许程序员 **将一个只读变量缓存到每台机器上**，而不是传递一个副本。例如，广播变量可以用一种高效的方式给每个节点传递一份比较大的输入数据集副本。在使用广播变量时，Spark 也尝试使用高效广播算法分发广播变量以降低通信成本。

Spark 的 action 操作是通过一系列的 stage（阶段）进行执行的，这些 stage（阶段）是通过分布式的 “shuffle” 操作进行拆分的。Spark 会自动广播出每个 stage 内任务所需要的公共数据。以这种方式广播的数据使用序列化的形式进行缓存，并在每个任务运行前进行反序列化。这也就意味着，**只有在跨越多个 stage 的任务会使用相同的数据，或者在使用反序列化形式缓存数据时，使用广播变量会有比较好的效果[This means that explicitly creating broadcast variables is only useful when tasks across multiple stages need the same data or when caching the data in deserialized form is important.]。**

广播变量通过在一个变量 v 上调用 SparkContext.broadcast(v) 方法来进行创建。广播变量是 v 的一个 wrapper（包装器），可以通过调用 value 方法来访问它的值。代码示例如下:


**A. 对于scala**

**B. 对于java**

```java
Broadcast<int[]> broadcastVar = sc.broadcast(new int[] {1, 2, 3});

broadcastVar.value();
// returns [1, 2, 3]
```

在创建广播变量之后，在集群上执行的所有的函数中，应该使用该广播变量代替原来的 v 值，这样节点上的 v 最多分发一次。另外，对象 v 在广播后不应该再被修改，以保证分发到所有的节点上的广播变量具有同样的值（例如，如果以后该变量会被运到一个新的节点）。

为了释放分发广播变量占用的资源，调用 **.unpersist()** 方法释放，如果该广播变量在后面再次被使用，则会再次广播。如果要彻底释放资源，可以使用 **.destroy()** 方法，之后，该广播变量就不能再使用了。

这些方法默认是不阻塞的。若要阻塞直到释放资源，请在调用此方法时指定 `blocking=true` 。

**C. 对于python**

```sh
>>> broadcastVar = sc.broadcast([1, 2, 3])
<pyspark.broadcast.Broadcast object at 0x102789f10>

>>> broadcastVar.value
[1, 2, 3]
```
在创建广播变量之后，在集群上执行的所有的函数中，应该使用该广播变量代替原来的 v 值，这样节点上的 v 最多分发一次。另外，对象 v 在广播后不应该再被修改，以保证分发到所有的节点上的广播变量具有同样的值（例如，如果以后该变量会被运到一个新的节点）。

为了释放分发广播变量占用的资源，调用 **.unpersist()** 方法释放，如果该广播变量在后面再次被使用，则会再次广播。如果要彻底释放资源，可以使用 **.destroy()** 方法，之后，该广播变量就不能再使用了。

这些方法默认是不阻塞的。若要阻塞直到释放资源，请在调用此方法时指定 `blocking=true` 。

### 5.2、Accumulators  累加器

累加器是一个仅可以通过 associative 和 commutative 执行 added 的变量。可以被用来实现 counter 和 sums。原生 Spark 支持数值型的累加器，并且程序员**可以添加新的支持类型。**

用户可以创建命名或未命名的累加器。如下图所示，一个命名的累加器（在这个例子中是 counter）显示在 web UI 中，处在修改累加器的阶段。 Spark 在 “Tasks” 任务表中显示了任务修改的每个累加器的值。

![spark01](https://s1.ax1x.com/2020/07/18/UgDlM8.png)

在 UI 中跟踪累加器可以有助于了解运行阶段的进度（注：这在 Python 中尚不支持）.


**A. 对于scala**

**B. 对于java**

可以通过调用 SparkContext.longAccumulator() 或 SparkContext.doubleAccumulator() 方法创建数值类型的累加器以分别累加 Long 或 Double 类型的值。集群上正在运行的任务就可以使用 add 方法来累计数值。然而，它们不能够读取它的值。只有驱动程序才可以使用 value 方法读取累加器的值。

下面的代码展示了一个累加器被用于对一个数组中的元素求和:

```java
LongAccumulator accum = jsc.sc().longAccumulator();

sc.parallelize(Arrays.asList(1, 2, 3, 4)).foreach(x -> accum.add(x));
// ...
// 10/09/29 18:41:08 INFO SparkContext: Tasks finished in 0.317106 s

accum.value();
// returns 10
```
While this code used the built-in support for accumulators of type Long, programmers can also create their own types by subclassing AccumulatorV2. The AccumulatorV2 abstract class has several methods which one has to override: reset for resetting the accumulator to zero, add for adding another value into the accumulator, merge for merging another same-type accumulator into this one. Other methods that must be overridden are contained in the API documentation. For example, supposing we had a MyVector class representing mathematical vectors, we could write:

虽然此代码使用 Long 类型的累加器的内置支持，但是开发者通过 [AccumulatorV2](http://spark.apache.org/docs/latest/api/scala/org/apache/spark/util/AccumulatorV2.html) 它的子类来创建自己的类型。AccumulatorV2 抽象类有几个需要重写的方法：reset 方法可将累加器重置为 0，add 方法可将其它值添加到累加器中，merge 方法可将其他同样类型的累加器合并为一个。其他需要重写的方法可参考 API documentation。例如，假设我们有一个表示数学上 vectors（向量）的 MyVector 类，我们可以写成:

```java
class VectorAccumulatorV2 implements AccumulatorV2<MyVector, MyVector> {

  private MyVector myVector = MyVector.createZeroVector();

  public void reset() {
    myVector.reset();
  }

  public void add(MyVector v) {
    myVector.add(v);
  }
  ...
}

// Then, create an Accumulator of this type:
VectorAccumulatorV2 myVectorAcc = new VectorAccumulatorV2();
// Then, register it into spark context:
jsc.sc().register(myVectorAcc, "MyVectorAcc1");
```
注意:在开发者定义自己的 AccumulatorV2 类型时，返回值类型可能与添加的元素的类型不一致。

Warning: When a Spark task finishes, Spark will try to merge the accumulated updates in this task to an accumulator. If it fails, Spark will ignore the failure and still mark the task successful and continue to run other tasks. Hence, a buggy accumulator will not impact a Spark job, but it may not get updated correctly although a Spark job is successful.


**累加器的更新只发生在 action 操作中，Spark 保证每个任务只更新累加器一次，例如，重启任务不会更新值。在 transformations 中，如果任务或 job stages 重新执行，每个任务的更新操作可能会执行多次。**

**累加器不会改变 Spark 懒加载模式**。如果累加器在 RDD 中的一个操作中进行更新，它们的值仅被作为 action 的一部分更新一次。 因此，在一个像 map() 这样的 transformation 操作时，累加器的更新不保证被执行。下面的代码片段证明了这个特性:

```java
LongAccumulator accum = jsc.sc().longAccumulator();
data.map(x -> { accum.add(x); return f(x); });
// Here, accum is still 0 because no actions have caused the `map` to be computed.
```

**C. 对于python**

根据一个初始值 v ，通过调用 SparkContext.accumulator(v) 方法创建累加器。集群上正在运行的任务就可以使用 add 方法或者 `+=` 操作符来累加数值。然而，它们不能够读取它的值。只有驱动程序才可以使用 value 方法读取累加器的值。

下面的代码展示了一个 accumulator（累加器）被用于对一个数组中的元素求和:

```sh
>>> accum = sc.accumulator(0)
>>> accum
Accumulator<id=0, value=0>

>>> sc.parallelize([1, 2, 3, 4]).foreach(lambda x: accum.add(x))
...
10/09/29 18:41:08 INFO SparkContext: Tasks finished in 0.317106 s

>>> accum.value
10
```
虽然此代码使用内置支持 Int 类型的累加器，但是程序员可以通过实现 AccumulatorParam 接口来自定义类型。AccumulatorParam 接口有两个方法：zero 和 addInPlace。zero用来提供一个初始零值。addInPlace 用来 add 两个值。例如，有一个表示数学向量的 Vector 类，可以这么写：

```python
class VectorAccumulatorParam(AccumulatorParam):
    def zero(self, initialValue):
        return Vector.zeros(initialValue.size)

    def addInPlace(self, v1, v2):
        v1 += v2
        return v1

# Then, create an Accumulator of this type:
vecAccum = sc.accumulator(Vector(...), VectorAccumulatorParam())
```

**累加器的更新只发生在 action 操作中，Spark 保证每个任务只更新累加器一次，例如，重启任务不会更新值。在 transformations 中，如果任务或 job stages 重新执行，每个任务的更新操作可能会执行多次。**

**累加器不会改变 Spark 懒加载模式**。如果累加器在 RDD 中的一个操作中进行更新，它们的值仅被作为 action 的一部分更新一次。 因此，在一个像 map() 这样的 transformation 操作时，累加器的更新不保证被执行。下面的代码片段证明了这个特性:

```python
accum = sc.accumulator(0)
def g(x):
    accum.add(x)
    return f(x)
data.map(g)
# Here, accum is still 0 because no actions have caused the `map` to be computed.
```

## 6、Deploying to a Cluster

[应用程序提交指南](http://spark.apache.org/docs/latest/submitting-applications.html) 描述了如何提交应用程序到集群。总之，一旦你打包了应用程序为 JAR (for Java/Scala) 、 .py 集合或 .zip (for Python)，再使用 `bin/spark-submit` 脚本提交它到任何支持的集群管理器中。

## 7、Launching Spark jobs from Java / Scala

[org.apache.spark.launcher](http://spark.apache.org/docs/latest/api/java/index.html?org/apache/spark/launcher/package-summary.html) 包提供了类，用于使用简单的 Java API 来作为一个子进程启动 Spark jobs.

## 8、Unit Testing

Spark 可以使用任意流行的单元测试框架进行单元测试。在将 master URL 设置为 local 来测试时会简单的创建一个 SparkContext，运行您的操作，然后调用 `SparkContext.stop()` 将该作业停止。因为 Spark 不支持在同一个程序中并行的运行两个 contexts，所以需要确保使用 finally 块或者测试框架的 tearDown 方法停止了 context。

## 9、Where to Go from Here

您可以在 Spark 网站上看一下 Spark 程序示例。此外，Spark 在 examples 目录中包含了许多示例（Scala，Java，Python，R）。您可以通过传递 class name 到 Spark 的 `bin/run-example` 脚本以运行 Java 和 Scala 示例; 例如:

```sh
./bin/run-example SparkPi
```
For Python examples, use spark-submit instead:

```sh
./bin/spark-submit examples/src/main/python/pi.py
```
For R examples, use spark-submit instead:

```sh
./bin/spark-submit examples/src/main/r/dataframe.R
```

针对应用程序的优化，该 [配置](http://spark.apache.org/docs/latest/configuration.html) 和 [优化指南](http://spark.apache.org/docs/latest/tuning.html) 提供了一些最佳实践的信息。这些优化建议在确保你的数据以高效的格式存储在内存中尤其重要。针对部署参考，该 [集群模式概述](http://spark.apache.org/docs/latest/cluster-overview.html) 描述了分布式操作和支持的集群管理器的组件.

最后,所有的 API 文档可在 Scala，Java，Python and R 中获取.