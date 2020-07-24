# 官网：Tuning Spark

[TOC]

*Because of the in-memory nature of most Spark computations, Spark programs can be bottlenecked by any resource in the cluster: CPU, network bandwidth, or memory. Most often, if the data fits in memory, the bottleneck is network bandwidth, but sometimes, you also need to do some tuning, such as [storing RDDs in serialized form](http://spark.apache.org/docs/latest/rdd-programming-guide.html#rdd-persistence), to decrease memory usage. This guide will cover two main topics: data serialization, which is crucial for good network performance and can also reduce memory use, and memory tuning. We also sketch several smaller topics.*

由于 Spark 基于内存计算的本质， Spark 项目可能受集群资源的限制，如 CPU、网络带宽、内存。

本指南讲解两部分内容：数据序列化、内存优化。

## 1、Data Serialization

*Serialization plays an important role in the performance of any distributed application. Formats that are slow to serialize objects into, or consume a large number of bytes, will greatly slow down the computation. Often, this will be the first thing you should tune to optimize a Spark application. Spark aims to strike a balance between convenience (allowing you to work with any Java type in your operations) and performance. It provides two serialization libraries:*

序列化在分布式应用程序的性能中占有重要角色。且是优化一个应用程序首先应考虑到的事。

Spark 在便利(使用任意java类型)和性能间寻求平衡。提供了两种序列化库：

*[Java serialization](https://docs.oracle.com/javase/8/docs/api/java/io/Serializable.html): By default, Spark serializes objects using Java’s ObjectOutputStream framework, and can work with any class you create that implements [java.io.Serializable](https://docs.oracle.com/javase/8/docs/api/java/io/Serializable.html). You can also control the performance of your serialization more closely by extending [java.io.Externalizable](https://docs.oracle.com/javase/8/docs/api/java/io/Externalizable.html). Java serialization is flexible but often quite slow, and leads to large serialized formats for many classes.*

- Java serialization: 默认，Spark 使用 JAVA 的 `ObjectOutputStream` 序列化对象，可以序列化任意实现了 `java.io.Serializable` 接口的类。通过继承 `java.io.Externalizable` 可以控制序列化的性能。 此库非常灵活，但会创建很多类的大型序列化格式。

*[Kryo serialization](https://github.com/EsotericSoftware/kryo): Spark can also use the Kryo library (version 4) to serialize objects more quickly. Kryo is significantly faster and more compact than Java serialization (often as much as 10x), but does not support all Serializable types and requires you to register the classes you’ll use in the program in advance for best performance.*

- Kryo serialization: Kryo库序列化对象会更快、更紧凑，但不支持所有序列化类型，需要在项目中提前注册你使用的类。

*You can switch to using Kryo by initializing your job with a [SparkConf](http://spark.apache.org/docs/latest/configuration.html#spark-properties) and calling conf.set("spark.serializer", "org.apache.spark.serializer.KryoSerializer"). This setting configures the serializer used for not only shuffling data between worker nodes but also when serializing RDDs to disk. The only reason Kryo is not the default is because of the custom registration requirement, but we recommend trying it in any network-intensive application. Since Spark 2.0.0, we internally use Kryo serializer when shuffling RDDs with simple types, arrays of simple types, or string type.*

你可以在初始化 job 时，在 SparkConf 中传递配置项 `conf.set("spark.serializer", "org.apache.spark.serializer.KryoSerializer")` 来使用 Kryo。这不仅用来在 worker 节点间 shuffle 数据，也能序列化 RDD 到硬盘。

Kryo 不是默认的序列化方法的唯一原因就是需要 custom registration 。但我们推荐在网络密集型的应用程序中使用。

自从 Spark 2.0.0 ，当 shuffle 简单类型的 RDDs、简单类型的数组或字符串类型时，我们内部使用 Kryo 。

*Spark automatically includes Kryo serializers for the many commonly-used core Scala classes covered in the AllScalaRegistrar from the [Twitter chill library](https://github.com/twitter/chill).*

Twitter chill 库里的 AllScalaRegistrar 里包含了常用的 Kryo 序列化的类。

*To register your own custom classes with Kryo, use the registerKryoClasses method.*

使用 registerKryoClasses 类，来注册你使用 Kryo 自定义的类。

```scala
val conf = new SparkConf().setMaster(...).setAppName(...)
conf.registerKryoClasses(Array(classOf[MyClass1], classOf[MyClass2]))
val sc = new SparkContext(conf)
```

*The [Kryo documentation](https://github.com/EsotericSoftware/kryo) describes more advanced registration options, such as adding custom serialization code.*

*If your objects are large, you may also need to increase the spark.kryoserializer.buffer [config](http://spark.apache.org/docs/latest/configuration.html#compression-and-serialization). This value needs to be large enough to hold the largest object you will serialize.*

如果你的对象很大，那就需要增加 `spark.kryoserializer.buffer` 配置。这个值需要足够大，以能够包含住你将序列化的最大的对象。

*Finally, if you don’t register your custom classes, Kryo will still work, but it will have to store the full class name with each object, which is wasteful.*

如果你不注册你的自定义的类，Kryo 仍会运行，但它将必须存储每个对象的完整类名，这是浪费的。

## 2、Memory Tuning

*There are three considerations in tuning memory usage: the amount of memory used by your objects (you may want your entire dataset to fit in memory), the cost of accessing those objects, and the overhead of garbage collection (if you have high turnover in terms of objects).*

在调优内存使用时，有三种情况要考虑：

- 你的对象使用的内存量：你可能向将整个数据集当到内存。

- 访问这些对象的成本。

- 垃圾回收开销

*By default, Java objects are fast to access, but can easily consume a factor of 2-5x more space than the “raw” data inside their fields. This is due to several reasons:*

默认，Java 对象访问是快速的，但会消耗的空间是存储数据的空间的 2-5倍。下面的原因：

*Each distinct Java object has an “object header”, which is about 16 bytes and contains information such as a pointer to its class. For an object with very little data in it (say one Int field), this can be bigger than the data.*

- 每个对象都有一个对象头，占用16个字节，作用就是指向它的类。存在这种情况：整个对象包含的数据很少，甚至少于16字节。

Java Strings have about 40 bytes of overhead over the raw string data (since they store it in an array of Chars and keep extra data such as the length), and store each character as two bytes due to String’s internal usage of UTF-16 encoding. Thus a 10-character string can easily consume 60 bytes.*

- 存储一个 raw 字符串数据需要40字节，存储一个字符需要两个字节，那么存储10个字符的字符串需要60字节。

*Common collection classes, such as HashMap and LinkedList, use linked data structures, where there is a “wrapper” object for each entry (e.g. Map.Entry). This object not only has a header, but also pointers (typically 8 bytes each) to the next object in the list.*

- 使用链表数据结构的集合类都有一个 “wrapper” 对象，它不仅是头，也是指针(每个8个字节)，指向列表中的下个对象。

*Collections of primitive types often store them as “boxed” objects such as java.lang.Integer.*

- 原生类型的集合通常以 boxed 对象存储数据，如 java.lang.Integer

*This section will start with an overview of memory management in Spark, then discuss specific strategies the user can take to make more efficient use of memory in his/her application. In particular, we will describe how to determine the memory usage of your objects, and how to improve it – either by changing your data structures, or by storing data in a serialized format. We will then cover tuning Spark’s cache size and the Java garbage collector.*

### 2.1、Memory Management Overview

*Memory usage in Spark largely falls under one of two categories: execution and storage. Execution memory refers to that used for computation in shuffles, joins, sorts and aggregations, while storage memory refers to that used for caching and propagating internal data across the cluster. In Spark, execution and storage share a unified region (M). When no execution memory is used, storage can acquire all the available memory and vice versa. Execution may evict storage if necessary, but only until total storage memory usage falls under a certain threshold (R). In other words, R describes a subregion within M where cached blocks are never evicted. Storage may not evict execution due to complexities in implementation.*

Spark 中的内存使用主要分为两类: 执行和存储。

- 执行内存: 是指用于 shuffle 、join、sort 和 aggregation 的计算
- 存储内存: 是指用于在集群中缓存和传播内部数据。

在 Spark 中，执行和存储共享一个统一的区域(M)，当不使用执行内存时，存储内存可以获取所有可用的内存，反之亦然。如果有必要，执行可能会驱逐存储，但仅在总存储内存使用量低于某个阈值(R)时才会这样做。换句话说，R 描述了 M 中的一个子区域，其中缓存的块永远不会被驱逐。存储可能不会因为执行的复杂性而驱逐执行。

*This design ensures several desirable properties. First, applications that do not use caching can use the entire space for execution, obviating unnecessary disk spills. Second, applications that do use caching can reserve a minimum storage space (R) where their data blocks are immune to being evicted. Lastly, this approach provides reasonable out-of-the-box performance for a variety of workloads without requiring user expertise of how memory is divided internally.*

这种设计确保了几个理想的性能。首先，不使用缓存的应用程序可以将整个空间用于执行，从而避免不必要的磁盘溢出。其次，使用缓存的应用程序可以保留最小的存储空间(R)，在这里它们的数据块不会被清除。最后，这种方法为各种工作负载提供了合理的开箱即用性能，而不需要用户了解如何在内部划分内存。

*Although there are two relevant configurations, the typical user should not need to adjust them as the default values are applicable to most workloads:*

虽然有两种相关的配置，但是用户一般不需要调整它们，因为默认值适用于大多数工作负载:

*spark.memory.fraction expresses the size of M as a fraction of the (JVM heap space - 300MiB) (default 0.6). The rest of the space (40%) is reserved for user data structures, internal metadata in Spark, and safeguarding against OOM errors in the case of sparse and unusually large records.*

- spark.memory.fraction 表示 M 的大小是(JVM heap space- 300MB)的一部分(默认值0.6)。剩下的空间(40%)用于用户数据结构、Spark中的内部元数据，以及在稀疏和异常大的记录情况下防止 OOM 错误。

*spark.memory.storageFraction expresses the size of R as a fraction of M (default 0.5). R is the storage space within M where cached blocks immune to being evicted by execution.*

- spark.memory.storageFraction：将 R 的大小表示为 M 的一部分(默认值为0.5)。R 是 M 中的存储空间，缓存的块不会被执行清除。

*The value of spark.memory.fraction should be set in order to fit this amount of heap space comfortably within the JVM’s old or “tenured” generation. See the discussion of advanced GC tuning below for details.*

应该设置 `spark.memory.fraction` 的值，以便适应 JVM 的老年代或永久代的这部分堆空间。有关详细信息，请参阅下面关于 高级 GC调优的讨论。

### 2.2、Determining Memory Consumption

*The best way to size the amount of memory consumption a dataset will require is to create an RDD, put it into cache, and look at the “Storage” page in the web UI. The page will tell you how much memory the RDD is occupying.*

创建一个 RDD ，放到缓存中，在 WEB UI 的 “Storage” 页可查看这个 RDD 占用了多少内存。

*To estimate the memory consumption of a particular object, use SizeEstimator’s estimate method. This is useful for experimenting with different data layouts to trim memory usage, as well as determining the amount of space a broadcast variable will occupy on each executor heap.*

SizeEstimator 的 estimate 方法可以估算一个对象的内存消耗量。这对于试验不同的数据布局以削减内存使用，以及确定广播变量将在每个 executor 堆上占用的空间量非常有用。

### 2.3、Tuning Data Structures

*The first way to reduce memory consumption is to avoid the Java features that add overhead, such as pointer-based data structures and wrapper objects. There are several ways to do this:*

减少内存消耗的第一种方法是避免使用增加开销的 Java 特性，比如 pointer-based 的数据结构和 wrapper 对象。有几种方法可以做到这一点:

*Design your data structures to prefer arrays of objects, and primitive types, instead of the standard Java or Scala collection classes (e.g. HashMap). The [fastutil](http://fastutil.di.unimi.it/) library provides convenient collection classes for primitive types that are compatible with the Java standard library.*

- 将数据结构设计为对象数组和基本类型，而不是标准的 Java 或 Scala 集合类(e.g. HashMap)。fastutil 库为与 Java 标准库兼容的基本类型提供了方便的集合类。

*Avoid nested structures with a lot of small objects and pointers when possible.*

- 尽可能避免嵌套有大量小对象和指针的结构。

*Consider using numeric IDs or enumeration objects instead of strings for keys.*

-  考虑使用数值 id 或枚举对象代替 key 的字符串。

*If you have less than 32 GiB of RAM, set the JVM flag -XX:+UseCompressedOops to make pointers be four bytes instead of eight. You can add these options in [spark-env.sh](http://spark.apache.org/docs/latest/configuration.html#environment-variables).*

- 如果你的内存不足 32 GB，那么可以设置 JVM 参数 -XX:+UseCompressedOops，使地址指针变成4个字节，而不是8个字节。你可以在 spark-env.sh 中添加这些选项。

### 2.4、Serialized RDD Storage

*When your objects are still too large to efficiently store despite this tuning, a much simpler way to reduce memory usage is to store them in serialized form, using the serialized StorageLevels in the [RDD persistence API](http://spark.apache.org/docs/latest/rdd-programming-guide.html#rdd-persistence), such as MEMORY_ONLY_SER. Spark will then store each RDD partition as one large byte array. The only downside of storing data in serialized form is slower access times, due to having to deserialize each object on the fly. We highly recommend [using Kryo](http://spark.apache.org/docs/latest/tuning.html#data-serialization) if you want to cache data in serialized form, as it leads to much smaller sizes than Java serialization (and certainly than raw Java objects).*

尽管进行了调优，但对象仍然太大，无法有效地存储时，减少内存使用的一种更简单的方法是以序列化的形式存储它们，使用 RDD 持久性 API 中的序列化 StorageLevels ，比如 MEMORY_ONLY_SER。

然后 Spark 将每个 RDD 分区存储为一个大字节数组。以序列化形式存储数据的惟一缺点是访问时间较慢，因为必须动态地反序列化每个对象。如果您想要以序列化的形式缓存数据，我们强烈推荐使用 Kryo，因为它比 Java 序列化的大小小得多(当然也比原始Java对象小)。

### 2.5、Garbage Collection Tuning

*JVM garbage collection can be a problem when you have large “churn” in terms of the RDDs stored by your program. (It is usually not a problem in programs that just read an RDD once and then run many operations on it.) When Java needs to evict old objects to make room for new ones, it will need to trace through all your Java objects and find the unused ones. The main point to remember here is that the cost of garbage collection is proportional to the number of Java objects, so using data structures with fewer objects (e.g. an array of Ints instead of a LinkedList) greatly lowers this cost. An even better method is to persist objects in serialized form, as described above: now there will be only one object (a byte array) per RDD partition. Before trying other techniques, the first thing to try if GC is a problem is to use [serialized caching](http://spark.apache.org/docs/latest/tuning.html#serialized-rdd-storage).*

当你的程序存储了大量的 RDD 数据时， JVM GC 可能会成为一个问题。(对于那些只读取一次 RDD ，然后在上面运行许多操作的程序来说，这通常不是问题。)

当 Java 需要清除旧对象来为新对象腾出空间时，它将需要跟踪所有 Java 对象并找到未使用的对象。

这里要记住的要点是，**GC 成本与 Java 对象的数量成比例**，因此使用对象较少的数据结构(例如，一个 Int 数组而不是 LinkedList数组)可以大大降低这一成本。

一个更好的方法是以序列化的形式持久化对象，如上所述:现在每个 RDD 分区将只有一个对象(一个字节数组)。在尝试其他技术之前，如果 GC 有问题，首先要尝试的是使用序列化缓存。

*GC can also be a problem due to interference between your tasks’ working memory (the amount of space needed to run the task) and the RDDs cached on your nodes. We will discuss how to control the space allocated to the RDD cache to mitigate this.*

因为任务的工作内存(运行任务所需的空间量)和节点上缓存的 RDD 之间存在干扰，GC 也可能是一个问题。我们将讨论如何控制分配给 RDD 缓存的空间来缓解这种情况。

#### 2.5.1、Measuring the Impact of GC

*The first step in GC tuning is to collect statistics on how frequently garbage collection occurs and the amount of time spent GC. This can be done by adding -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps to the Java options. (See the configuration guide for info on passing Java options to Spark jobs.) Next time your Spark job is run, you will see messages printed in the worker’s logs each time a garbage collection occurs. Note these logs will be on your cluster’s worker nodes (in the stdout files in their work directories), not on your driver program.*

GC 调优的第一步是收集关于 GC 发生的频率和 GC 花费的时间的统计信息。这可以通过在 Java 参数中添加 `-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps` 来实现。(请参阅配置指南以获取关于将Java参数传递给Spark作业的信息。)

下一次运行 Spark 作业时，你将看到每次发生垃圾收集时在 Worker 日志中打印的消息。

注意，这些日志将在你的集群 Worker 节点上(在它们的工作目录中的 stdout 文件中)，而不是在你的 Driver 进程上。

#### 2.5.2、Advanced GC Tuning

*To further tune garbage collection, we first need to understand some basic information about memory management in the JVM:*

JVM 中关于内存管理的一些基本信息:

*Java Heap space is divided in to two regions Young and Old. The Young generation is meant to hold short-lived objects while the Old generation is intended for objects with longer lifetimes.*

- Java 堆空间分为两个区域，年轻代 和老年代。年轻代持有短生命周期的对象，而老年代持有具有更长的生命周期的对象。

*The Young generation is further divided into three regions [Eden, Survivor1, Survivor2].*

- 年轻代 被进一步划分为三个区域 [Eden, Survivor1, Survivor2]。

*A simplified description of the garbage collection procedure: When Eden is full, a minor GC is run on Eden and objects that are alive from Eden and Survivor1 are copied to Survivor2. The Survivor regions are swapped. If an object is old enough or Survivor2 is full, it is moved to Old. Finally, when Old is close to full, a full GC is invoked.*

- GC 过程的简化描述:

	当 Eden 已满时，在 Eden 上运行一个小型 GC，从 Eden 和 Survivor1 存活的对象被复制到 Survivor2 。

	交换 Survivor 区域。如果一个对象足够老(在多次GC后还存活) 或 Survivor2 已满，则将其移动到老年代中。

	最后，当老年代接近 full 时，将调用 full GC。

*The goal of GC tuning in Spark is to ensure that only long-lived RDDs are stored in the Old generation and that the Young generation is sufficiently sized to store short-lived objects. This will help avoid full GCs to collect temporary objects created during task execution. Some steps which may be useful are:*

在 Spark 中进行 GC 调优的目标是确保：老年代中只存储长期存在的 RDD，而年轻代的大小足以存储短期存在的对象。这将有助于避免在任务执行期间发生 full gc 来收集创建的临时对象。一些可能有用的步骤是:

*Check if there are too many garbage collections by collecting GC stats. If a full GC is invoked multiple times for before a task completes, it means that there isn’t enough memory available for executing tasks.*

- 通过收集 GC 的统计信息来检查是否发生了太多的 GC 。如果在任务完成之前多次调用 full GC，这意味着没有足够的可用内存来执行任务。

*If there are too many minor collections but not many major GCs, allocating more memory for Eden would help. You can set the size of the Eden to be an over-estimate of how much memory each task will need. If the size of Eden is determined to be E, then you can set the size of the Young generation using the option -Xmn=4/3*E. (The scaling up by 4/3 is to account for space used by survivor regions as well.)*

- 如果 Minor GC 太多而 Major GC 太少，那么需要为 Eden 分配更多的内存。你可以将 Eden 的大小设置为高于每个 task 所需的内存大小。如果 Eden 的大小被确定为 E，那么你可以使用选项 `-Xmn=4/3*E` 来设置年轻代的大小。（4/3的比例也考虑到了 Survivor 区域使用的空间）

*In the GC stats that are printed, if the OldGen is close to being full, reduce the amount of memory used for caching by lowering spark.memory.fraction; it is better to cache fewer objects than to slow down task execution. Alternatively, consider decreasing the size of the Young generation. This means lowering -Xmn if you’ve set it as above. If not, try changing the value of the JVM’s NewRatio parameter. Many JVMs default this to 2, meaning that the Old generation occupies 2/3 of the heap. It should be large enough such that this fraction exceeds spark.memory.fraction.*

- 在打印的 GC 统计中，如果老年代空间接近满，通过降低 spark.memory.fraction 来减少用于缓存的内存数量; 缓存更少的对象比降低任务执行速度要好。或者，考虑减少年轻代的规模。这意味着降低 -Xmn，如果你已经设置为上述。如果没有，请尝试更改 JVM 的 NewRatio 参数的值。许多 JVM 将其默认为2，这意味着老一代占用了2/3的堆。它应该足够大，使这个比例超过 spark.memory.fraction。

*Try the G1GC garbage collector with -XX:+UseG1GC. It can improve performance in some situations where garbage collection is a bottleneck. Note that with large executor heap sizes, it may be important to increase the G1 region size with -XX:G1HeapRegionSize*

- 通过设置 -XX:+UseG1GC 参数使用的 G1GC 垃圾收集器。在垃圾收集成为瓶颈的某些情况下，它可以提高性能。注意， 对于 executor heap sizes 大的集群, 用 -XX:G1HeapRegionSize 参数增加 G1 区域尺寸会很重要。

*As an example, if your task is reading data from HDFS, the amount of memory used by the task can be estimated using the size of the data block read from HDFS. Note that the size of a decompressed block is often 2 or 3 times the size of the block. So if we wish to have 3 or 4 tasks’ worth of working space, and the HDFS block size is 128 MiB, we can estimate size of Eden to be 4*3*128MiB.*

- 例如，如果你的任务正在从 HDFS 读取数据，则可以使用从 HDFS 读取的数据块的大小来估计任务所使用的内存量。 注意，解压缩块的大小通常是块大小的2到3倍。因此，如果我们希望有3或4个任务的工作空间，并且 HDFS 块大小为128MB，我们可以估计 Eden 的大小为 `4*3*128MB`。

*Monitor how the frequency and time taken by garbage collection changes with the new settings.*

- 监视随新设置的变化, GC 所花费的频率和时间。

*Our experience suggests that the effect of GC tuning depends on your application and the amount of memory available. There are many more tuning options described online, but at a high level, managing how frequently full GC takes place can help in reducing the overhead.*

*GC tuning flags for executors can be specified by setting spark.executor.defaultJavaOptions or spark.executor.extraJavaOptions in a job’s configuration.*

我们的经验表明，GC 调优的效果取决于你的应用程序和可用的内存量。官网描述了更多的调优选项，但是在高层次上，管理 full GC 发生的频率有助于减少开销。

可以通过在 Job 配置中，设置 `spark.executor.defaultJavaOptions` 或 `spark.executor.extraJavaOptions` 来指定 Executor 的 GC 调优等级。

## 3、Other Considerations

### 3.1、Level of Parallelism

*Clusters will not be fully utilized unless you set the level of parallelism for each operation high enough. Spark automatically sets the number of “map” tasks to run on each file according to its size (though you can control it through optional parameters to SparkContext.textFile, etc), and for distributed “reduce” operations, such as groupByKey and reduceByKey, it uses the largest parent RDD’s number of partitions. You can pass the level of parallelism as a second argument (see the [spark.PairRDDFunctions](http://spark.apache.org/docs/latest/api/scala/org/apache/spark/rdd/PairRDDFunctions.html) documentation), or set the config property spark.default.parallelism to change the default. In general, we recommend 2-3 tasks per CPU core in your cluster.*

除非将每个操作的并行度设置得足够高，否则集群资源不会得到充分利用。 

Spark 根据每个文件的大小自动设置要在每个文件上运行的 “map” 任务的数量(尽管你可以通过 SparkContext.textFile 的可选参数来控制它)。

对于分布式的 “reduce” 操作，例如 groupByKey 和 reduceByKey，它使用最大的父RDD的分区数。

你可以将并行度级别作为第二个参数传递(参见 spark.PairRDDFunction 文件)，或者设置配置属性 spark.default.parallelism 来更改默认值。

通常，我们建议在你的集群中每个 CPU 内核执行2-3个任务。

### 3.2、Memory Usage of Reduce Tasks

*Sometimes, you will get an OutOfMemoryError not because your RDDs don’t fit in memory, but because the working set of one of your tasks, such as one of the reduce tasks in groupByKey, was too large. Spark’s shuffle operations (sortByKey, groupByKey, reduceByKey, join, etc) build a hash table within each task to perform the grouping, which can often be large. The simplest fix here is to increase the level of parallelism, so that each task’s input set is smaller. Spark can efficiently support tasks as short as 200 ms, because it reuses one executor JVM across many tasks and it has a low task launching cost, so you can safely increase the level of parallelism to more than the number of cores in your clusters.*

有时，你会得到一个 OutOfMemoryError 错误，不是因为你的 RDD  内存不合适，而是因为你的一个任务的工作集，例如 groupByKey 中的一个 reduce 任务，占用内存太多。

Spark的 shuffle 操作( sortByKey、groupByKey、reduceByKey、join等) 在每个任务中构建一个 hash table 来执行分组，分组常常很大。这里最简单的修复方法是增加并行度，这样每个任务的输入集就会更小。Spark可以有效地支持短至 200ms 的任务，因为它跨多个任务重用一个 executor JVM，而且它的任务启动成本很低，所以可以安全地将并行度提高到比集群中的内核数量更多的水平。

### 3.3、Broadcasting Large Variables

*Using the [broadcast functionality](http://spark.apache.org/docs/latest/rdd-programming-guide.html#broadcast-variables) available in SparkContext can greatly reduce the size of each serialized task, and the cost of launching a job over a cluster. If your tasks use any large object from the driver program inside of them (e.g. a static lookup table), consider turning it into a broadcast variable. Spark prints the serialized size of each task on the master, so you can look at that to decide whether your tasks are too large; in general tasks larger than about 20 KiB are probably worth optimizing.*

使用 SparkContext 中可用的广播功能可以极大地减少每个序列化任务的大小，以及通过集群启动 job 的成本。如果你的任务使用了 Driver 进程中的任何大对象(例如，一个静态查找表)，请考虑将其转换为广播变量。 Spark 在 Master 上打印了每个任务的序列化大小，因此可以查看它来决定你的任务是否太大；一般情况下，大于20kb的任务可能值得优化。

### 3.4、Data Locality

*Data locality can have a major impact on the performance of Spark jobs. If data and the code that operates on it are together then computation tends to be fast. But if code and data are separated, one must move to the other. Typically it is faster to ship serialized code from place to place than a chunk of data because code size is much smaller than data. Spark builds its scheduling around this general principle of data locality.*

数据局部性对 Spark jobs 的性能有很大的影响。如果数据和对其进行操作的代码在一起，那么计算往往会很快。

但是，如果代码和数据是分开的，那么其中一个必须转移到另一个。通常，将序列化的代码从一个地方传送到另一个地方要比传送数据块快得多，因为代码的大小比数据小得多。Spark 根据数据局部性的一般原则构建其调度。

*Data locality is how close data is to the code processing it. There are several levels of locality based on the data’s current location. In order from closest to farthest:*

数据局部性是指数据与处理数据的代码之间的距离。基于数据的当前位置有几个级别的局部性。按从最近到最远的顺序排列:

*PROCESS_LOCAL data is in the same JVM as the running code. This is the best locality possible*

- PROCESS_LOCAL ： 数据和代码在同一个 JVM 中。这是最佳位置。 

*NODE_LOCAL data is on the same node. Examples might be in HDFS on the same node, or in another executor on the same node. This is a little slower than PROCESS_LOCAL because the data has to travel between processes*

- NODE_LOCAL : 数据在同一个节点上。实例可能在同一节点上的 HDFS 中，也可能在同一节点上的另一个 Executor 中。这比 PROCESS_LOCAL 稍微慢一些，因为数据必须在进程之间传递。

*NO_PREF data is accessed equally quickly from anywhere and has no locality preference*

- NO_PREF： 数据从任何地方访问, 速度都一样快，并且没有区域优先特性

*RACK_LOCAL data is on the same rack of servers. Data is on a different server on the same rack so needs to be sent over the network, typically through a single switch*

- RACK_LOCAL： 数据位于相同的服务器机架上。数据位于同一机架上的不同服务器上，因此需要通过网络发送，通常是通过单个交换机。

*ANY data is elsewhere on the network and not in the same rack*

- ANY ： 数据都在网络的其他地方，不在同一个机架上

*Spark prefers to schedule all tasks at the best locality level, but this is not always possible. In situations where there is no unprocessed data on any idle executor, Spark switches to lower locality levels. There are two options: a) wait until a busy CPU frees up to start a task on data on the same server, or b) immediately start a new task in a farther away place that requires moving data there.*

Spark倾向于将所有任务安排在最佳位置级别，但这并不总是可能的。在任何空闲 executor 上没有未处理的数据的情况下，Spark 切换到较低的位置级别。有两种选择:

- a)等待繁忙的 CPU 释放出来，在同一服务器上的数据上启动一个任务，或者

- b)立即在需要移动数据的较远的地方启动一个新任务。

*What Spark typically does is wait a bit in the hopes that a busy CPU frees up. Once that timeout expires, it starts moving the data from far away to the free CPU. The wait timeout for fallback between each level can be configured individually or all together in one parameter; see the spark.locality parameters on the configuration page for details. You should increase these settings if your tasks are long and see poor locality, but the default usually works well.*

Spark 通常做的是稍作等待，希望繁忙的 CPU 可以释放。一旦超时过期，它就开始将数据从远处移动到空闲的 CPU 。每个级别之间回退的等待超时可以单独配置，也可以全部配置在一个参数中; 有关详细信息，见 配置页面 spark.locality 参数 。如果你的任务很长，并且位置不好，你应该增加这些设置，但是默认设置通常工作得很好。

## 4、Summary

*This has been a short guide to point out the main concerns you should know about when tuning a Spark application – most importantly, data serialization and memory tuning. For most programs, switching to Kryo serialization and persisting data in serialized form will solve most common performance issues. Feel free to ask on the Spark mailing list about other tuning best practices.*