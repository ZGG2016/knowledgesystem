# 官网：RDD Programming Guide
 
## 一、Overview  总览

从一个高层次的角度来看，**每个 Spark application 都由一个驱动程序组成**。这个驱动程序一个在集群上运行着用户的 **main 函数和执行着各种并行操作**。

Spark 提供的主要抽象是一个弹性分布式数据集 **RDD**，它是 **在集群中分区的、执行并行操作的元素集合**。

RDD 可以根据 **Hadoop 文件系统（或者任何其它 Hadoop 支持的文件系统）中的一个文件** 创建RRD，也可以通过 **转换驱动程序中已存在的 Scala 集合** 来创建RRD。

为了让RDD在整个并行操作中更高效的重用，Spark **persist（持久化）一个 RDD 到内存中**。

最后，**RDD 会自动的从节点故障中恢复**。

在 Spark 中的第二个抽象是能够用于并行操作的 **共享变量**，默认情况下，当 Spark 的一个函数作为一组不同节点上的任务运行时，它 **将每个变量的副本应用到每个任务的函数中去**。有时候，一个变量需要在多个任务间，或者在任务和驱动程序间来共享。

Spark 支持 **两种类型的共享变量：广播变量和累加器**。

	广播变量用于在所有节点上的内存中缓存一个值。
	累加器是一个只能被 “added（增加）” 的变量，例如 counters 和 sums。

本指南介绍了每一种 Spark 所支持的语言的特性。如果启动 Spark 的交互式 shell 来学习是很容易的，要么是 `Scala shell[bin/spark-shell]`，要么是 `Python shell[ bin/pyspark]`。

## 二、Linking with Spark  依赖配置

**A. 对于scala**

**B. 对于java**

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

```python
from pyspark import SparkContext, SparkConf
```

PySpark 在驱动程序和工作程序中都需要使用相同的 Python minor version。 PATH 中的版本是默认的，但你可以通过设置 PYSPARK_PYTHON 指定一个版本。

```shell
$ PYSPARK_PYTHON=python3.4 bin/pyspark
$ PYSPARK_PYTHON=/opt/pypy-2.5/bin/pypy bin/spark-submit examples/src/main/python/pi.py
```

## 三、Initializing Spark  初始化

**A. 对于scala**

**B. 对于java**

**C. 对于python**

Spark 程序必须做的第一件事情是创建一个 **SparkContext 对象**，它会告诉 Spark 如何访问集群。要创建一个 SparkContext，首先需要构建一个 **包含应用程序的信息的 SparkConf 对象**。

```python
conf = SparkConf().setAppName(appName).setMaster(master)
sc = SparkContext(conf=conf)
```
appName 参数是应用程序的名称，显示在集群UI上。 master 可以是 Spark、 Mesos、YARN cluster URL、 或 local(本地模式)。在实际实践中，当在集群上运行程序时，您不希望在程序中将 master 给硬编码，而是使用 spark-submit 启动应用程序 并且接收它。然而，对于本地测试和单元测试，您可以通过 “local” 来运行 Spark 进程。

## 四、Using the Shell  使用shell

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

```shell
$ ./bin/pyspark --master local[4]
```

向搜索路径添加 `code.py` (为了之后导入 code) :

```shell
$ ./bin/pyspark --master local[4] --py-files code.py
```

所有的参数项，请运行 `run pyspark --help` 。在后台，pyspark 调用更通用的 [spark-submit 脚本](http://spark.apache.org/docs/latest/submitting-applications.html)。

也可以在 IPython 中启动 PySpark shell，要求 IPython 的版本是1.0.0以更高。在运行 `bin/pyspark` 时需要设置 PYSPARK_DRIVER_PYTHON 变量为ipython

```shell
$ PYSPARK_DRIVER_PYTHON=ipython ./bin/pyspark
```
使用 Jupyter notebook ，则需要作如下配置：

```shell
$ PYSPARK_DRIVER_PYTHON=jupyter PYSPARK_DRIVER_PYTHON_OPTS=notebook ./bin/pyspark
```
你可以通过设置 PYSPARK_DRIVER_PYTHON_OPTS 参数，自定义 ipython or jupyter 命令

Jupyter Notebook 服务启动后，你可以点击 “Files” 创建一个新的 “Python 2” 笔记本。在开始使用 Spark 前，需要在你的笔记本里输入 `%pylab inline` 。

## 四、Resilient Distributed Datasets (RDDs)


Spark 主要以一个 弹性分布式数据集（RDD）的概念为中心，它是一个 **容错且可以执行并行操作的元素的集合**。有两种方法可以创建 RDD：在你的驱动程序中 parallelizing 一个已存在的集合，或者在外部存储系统中引用一个数据集，
例如，一个共享文件系统、HDFS、HBase、或者提供 Hadoop InputFormat 的任何数据源。

### 1、Parallelized Collections  并行集合

**A. 对于scala**

**B. 对于python**

在驱动程序中，通过已存在的迭代器或集合，**使用 parallelize 方法来创建** 并行集合。集合元素被复制到可以执行并行操作
的分布式数据集中。例如：

```python
data = [1, 2, 3, 4, 5]
distData = sc.parallelize(data)
```
分布式数据集一旦创建，就可以执行并行操作。例如，可以这样使用 `distData.reduce(lambda a, b: a + b)` 累加元素。

并行集合的一个重要参数就是分区数量。 **Spark 的一个任务操作一个分区** 。一般来说，每个 CPU 划分4个分区。 **正常情况下，Spark 会根据集群情况，自动设置分区数量。然而，你也可以给 parallelize 方法传递一个参数来手动设置。** (如 `sc.parallelize(data, 10)`)。注意：代码中的一些地方使用术语片term slice(分区的同义词)来维护向后兼容性。

### 2、External Datasets  外部数据集

**A. 对于scala**

- 针对 SequenceFiles，使用 SparkContext 的 sequenceFile[K, V] 方法，其中 K 和 V 指的是文件中 key 和 values 的类型。这些 key 和 values 应该是 Hadoop 的 Writable 接口的子类，像 IntWritable and Text。此外，Spark 可以让您为一些常见的 Writables 指定原生类型; 例如，sequenceFile[Int, String] 会自动读取 IntWritables 和 Texts.

- 针对其它的 Hadoop InputFormats，您可以使用 SparkContext.hadoopRDD 方法，它接受一个任意的 JobConf 和 input format class、 key class 和 value class。通过相同的方法你可以设置你的输入源。你还可以针对 InputFormats 使用基于 “new” MapReduce API（org.apache.hadoop.mapreduce）的 SparkContext.newAPIHadoopRDD.

**B. 对于java**

**C. 对于python**

Spark 可以从 Hadoop 所支持的任何存储源中创建分布式数据集，包括 **本地文件系统、HDFS**、Cassandra、HBase、[Amazon S3](https://cwiki.apache.org/confluence/display/HADOOP2/AmazonS3) 等等。Spark 支持文本文件、[SequenceFiles](https://hadoop.apache.org/docs/stable/api/org/apache/hadoop/mapred/SequenceFileInputFormat.html)、以及任何其它的 [Hadoop InputFormat](http://hadoop.apache.org/docs/stable/api/org/apache/hadoop/mapred/InputFormat.html)。

可以使用 SparkContext 的 **textFile 方法来创建文本文件的 RDD**。此方法需要一个文件的 URI
（计算机上的本地路径，hdfs://，s3n:// 等等的 URI），并且读取它们作为一个行的集合。下面是一个调用示例:

```shell
>>> distFile = sc.textFile("data.txt")
```

distFile 一旦创建，便可以对其进行操作。例如，我们可以使用下面的 map 和 reduce 操作来统计行的数量：

```python
distFile.map(lambda s: len(s)).reduce(lambda a, b: a + b).
```

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

### 3、RDD Operations  操作

RDDs 支持两种类型的操作： **transformations（转换）和 actions（动作）**。transformations 是根据已存在的数据集创建一个
新的数据集，actions 是将在 数据集上执行计算后，将值返回给驱动程序。例如，map 就是一个 transformation，它将每个数据集元素
传递给一个函数，并返回一个的新 RDD 。 reduce 是一个 action， 它通过执行一些函数，聚合 RDD 中所有元素，并将最终结果给返
回驱动程序（虽然也有一个并行 reduceByKey 返回一个分布式数据集）。

Spark 中所有的 **transformations 都是懒加载的**，因此它不会立刻计算出结果。只有当需要返回结果给驱动程序时，
transformations 才开始计算。这种设计使 Spark 的运行更高效。例如，map 所创建的数据集将被用在 reduce 中，并且只有 reduce 的计算结果返回给驱动程序，而不是映射一个更大的数据集.

**默认情况下，对于一个已转换的 RDD，每次你在这个 RDD 运行一个 action 时，它都会被重新计算。** 但是，可以使用 persist/cache 方法将 RDD 持久化到内存中；在这种情况下，Spark 为了下次查询时可以更快地访问，会把数据保存在集群上。此外，还支持持
续持久化 RDDs 到磁盘，或跨多个节点复制。


#### （1）Basics 基础

**A. 对于scala**

**B. 对于java**

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

#### （2）Passing Functions to Spark  给 Spark 传函数

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

### 4、Understanding closures  理解闭包

在集群中执行代码时，一个关于 Spark 更难的事情是理解变量和方法的范围和生命周期。在其作用域之外修改变量的RDD操作经常会造成
混淆。在下面的例子中，我们将看一下使用的 foreach() 代码递增累加计数器，但类似的问题，也可能会出现其他操作上.


#### （1）Example

考虑一个简单的 RDD 元素求和，**在不同一个 JVM 中执行，产生的结果可能不同。** 一个常见的例子是当 Spark 运行在 local 本地模式（--master = local[n]）时，与部署 Spark 应用到群集（例如，通过 spark-submit 到 YARN）:

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

##### Local vs. cluster modes

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

##### Printing elements of an RDD   打印RDD元素

**单台机器**：rdd.foreach(println) 或 rdd.map(println) 用于打印 RDD 的所有元素。在一台机器上，这将产生预期的输出和打印 RDD 的所有元素。

**集群**：然而，在集群 cluster 模式下，输出被写入到 executors 的标准输出，而不是驱动程序上的。因此，结果不会输出到驱动
程序的标准输出中。要打印驱动程序的所有元素，可以使用的 collect() 方法首先把 RDD 放到驱动程序节点上，再执行foreach(println)，如：`rdd.collect().foreach(println)`。但这样做可能会导致驱动程序内存耗尽，因为 collect() 的结果是整个 RDD 到一台机器上， 如果你只需要打印 RDD 的几个元素，一个更安全的方法是使用 take()：`rdd.take(100).foreach(println)`。


### 5、Working with Key-Value Pairs  操作键值对

**A. 对于scala**

**B. 对于java**

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

### 6、Transformations

### 7、Actions