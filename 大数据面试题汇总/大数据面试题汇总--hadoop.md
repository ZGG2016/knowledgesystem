# 大数据面试题汇总--hadoop

[TOC]

## mapreduce的底层原理

![mapreduce01](https://s1.ax1x.com/2020/06/22/NGO3ZD.jpg)

    (1)输入文件会被划分成多个inputsplit，每一个InputSplit都会分配一个Map任务，Map任务的输出存放在环形内存缓冲区[默认大小100MB（io.sort.mb属性）]，一旦达到阀值0.8(io.sort.spill.percent)，一个后台线程就把内容写到(spill)本地磁盘中的指定目录（mapred.local.dir）下的新建的一个溢出写文件。

    (2)写磁盘前，要排序、分区。如果有Combiner，对中间过程的输出进行本地的聚集。等最后记录写完，将全部溢出文件合并为一个分区且排序的文件(归并排序)。

    (3)进入Reduce阶段。Reducer通过Http方式得到Map输出文件的分区、存到内存或磁盘、进行归并排序、执行Reduce方法。

[详细描述见 mapreduce过程详解.md]

## mapreduce的调度策略

主要有两种调度策略：

（1）容器调度器[Capacity Scheduler]

系统默认。Capacity Scheduler 允许多个组织共享整个集群，每个组织可以获得集群的一部分计算能力。通过为每个组织分配专门的队列，然后再为每个队列分配一定的集群资源，这样整个集群就可以通过设置多个队列的方式给多个组织提供服务了。除此之外，队列内部又可以垂直划分(子队列)，这样一个组织内部的多个成员就可以共享这个队列资源了，在一个队列内部，资源的调度是采用的是先进先出FIFO策略(例如，作业A和作业B被先后提交。那么在执行作业B的任务前，作业A中的所有map任务都应该已经执行完)。

（2）公平调度器[Fair Scheduler]

Fair Scheduler允许应用程序公平共享集群资源的调度器。当只有一个应用程序运行时，该应用程序可以使用整个集群资源，当其他应用程序提交之后，释放一部分资源给新提交的应用程序，所以每个应用程序最终会得到大致相同的资源量。

支持队列和层级队列。Fairscheduler 为队列分配了最小共享份额，这对确保了特定用户、组、产品应用始终获得足够的资源。当队列包含应用程序时，它至少能获得最小共享份额，但是当队列占用的资源有空余时，那么空余的资源会分配给其他运行中的应用程序。这既保证了队列的容量，又可以 在这些队列不包含应用程序时高效的利用资源。

FairScheduler默认让所有应用程序都运行，但也能通过配置文件限制每个用户、队列的运行的应用程序数量。

再详细的话，可以具体讲yarn的执行流程。

## hdfs文件系统

[hdfs架构]

HDFS 是分布式文件系统，采用主从架构。一个 HDFS 集群是由一个 Namenode 和一定数目的 Datanodes 组成。

    Namenode 是一个中心服务器，负责管理文件系统的名字空间(namespace)以及接收客户端对文件的访问请求。
    （操作文件系统的名字空间，比如打开、关闭、重命名文件或目录。它也负责确定 blocks 到具体 Datanode 节点的映射）

    Datanode 一般是一个节点一个，负责管理它所在节点上的存储，执行客户端的读写请求。

一个文件其实被分成一个或多个 blocks，一个block默认128mb，以 blocks 的形式存储在 Datanode 上。在 Namenode 的统一调度下进行 blocks 的创建、删除和复制。

## hdfs工作机制

[读写过程]

![hdfs03](https://s1.ax1x.com/2020/06/26/NreRF1.png)

	1、向namenode通信请求上传文件，namenode检查目标文件是否已存在，父目录是否存在
	2、namenode返回是否可以上传
	3、client会先对文件进行切分，比如一个blok块128m，文件有300m就会被切分成3个块，一个128M、一个128M、一个44M请求第一个 block该传输到哪些datanode服务器上
	4、namenode返回datanode的服务器
	5、client请求一台datanode上传数据（本质上是一个RPC调用，建立pipeline），第一个datanode收到请求会继续调用第二个datanode，然后第二个调用第三个datanode，将整个pipeline建立完成，逐级返回客户端
	6、client开始往A上传第一个block（先从磁盘读取数据放到一个本地内存缓存），以packet为单位（一个packet为64kb），当然在写入的时候datanode会进行数据校验，它并不是通过一个packet进行一次校验而是以chunk为单位进行校验（512byte），第一台datanode收到一个packet就会传给第二台，第二台传给第三台；第一台每传一个packet会放入一个应答队列等待应答
	7、当一个block传输完成之后，client再次请求namenode上传第二个block的服务器。

![hdfs04](https://s1.ax1x.com/2020/06/26/NreWJx.png)

	1、跟namenode通信查询元数据（block所在的datanode节点），找到文件块所在的datanode服务器
	2、挑选一台datanode（就近原则，然后随机）服务器，请求建立socket流
	3、datanode开始发送数据（从磁盘里面读取数据放入流，以packet为单位来做校验）
	4、客户端以packet为单位接收，先在本地缓存，然后写入目标文件，后面的block块就相当于是append到前面的block块最后合成最终需要的文件。

来源：[HDFS读写文件流程](https://blog.csdn.net/qq_20641565/article/details/53328279)

注：hdfs文件系统 和 hdfs工作机制 两个问题涉及范围比较大。可以统一从以下几个方面进行详细回答：

    1、架构：构成(NN、DN、block)；副本(存放、选择、安全模式、副本管道)、元数据管理(Editlog、FsImage、checkpoint、Blockreport)、健壮性(心跳检测、集群平衡、数据完整性、元数据磁盘错误)
    2、读写机制
    3、优缺点

参考：[Hadoop集群（第8期）HDFS初探之旅](https://www.cnblogs.com/xia520pi/archive/2012/05/28/2520813.html)


## nn、dn的块的大小，secondrynamenode的作用

128mb

NameNode包含了如下两个文件：

    - FsImage - 存储整个文件系统的名字空间，包括数据块到文件的映射、文件系统的属性等。

    - Editlog - 对于任何对文件系统元数据产生修改的操作，都会记录在 Editlog 中。

当 Namenode 启动时，将所有 Editlog 中的事务作用在内存中的 FsImage 上，从而得到一个文件系统的最新快照。但是在产品集群中NameNode是很少重启的，这也意味着当 NameNode 运行了很长时间后，Editlog 文件会变得很大。在这种情况下就会出现下面一些问题：

    - Editlog 文件会变的很大，怎么去管理这个文件是一个挑战。

    - NameNode 的重启会花费很长时间，因为在 Editlog 中有很多改动，要合并到 FsImage 文件上。

    - 如果 NameNode 挂掉了，那我们就丢失了很多改动，因为此时的 FsImage 文件非常旧。

所以，SecondaryNameNode 就是来帮助解决上述问题的，它的职责是合并 NameNode 的 Editlog 到 FsImage 文件中。

![hdfs05](https://s1.ax1x.com/2020/06/26/NrQEsf.jpg)

上图我们看到了Secondary NameNode是怎样工作的。

    - 首先，它定时到NameNode去获取 Editlog，并更新到Secondary NameNode自己的fsimage上。

    - 一旦它有了新的 fsimage 文件，它将其拷贝回 NameNode 中。

    - NameNode 在下次重启时会使用这个新的fsimage文件，从而减少重启的时间。

Secondary NameNode所做的不过是在文件系统中设置一个检查点来辅助NameNode更好的工作。它不是要取代掉NameNode也不是NameNode的备份。所以Secondary NameNode称为检查点节点。

NameNode是什么时候将改动写到 Editlog 中的？

    这个步骤，实际上是由DataNode的写操作触发的，当我们往DataNode写文件时，DataNode会跟NameNode通信，告诉NameNode什么文件的第几个block放在它那里，NameNode这个时候会将这些元数据信息写到 Editlog 文件中。


参考：
[[翻译]Secondary NameNode:它究竟有什么作用？](https://www.jianshu.com/p/5d292a9a8c86)
[hadoop-4 namenode和secondary namenode机制](https://blog.csdn.net/a3125504x/article/details/106265047)

##  hadoop如何保证健壮性

### 磁盘数据错误，心跳检测和重新复制

每个 Datanode 节点周期性地向 Namenode 发送心跳信号。网络割裂可能导致一部分 Datanode 跟 Namenode 失去联系。Namenode 通过心跳信号的缺失来检测这一情况，并将这些近期不再发送心跳信号 Datanode 标记为宕机，不会再将新的 IO 请求发给它们。任何存储在宕机 Datanode 上的数据将不再有效。**Datanode 的宕机可能会引起一些数据块的副本系数低于指定值，Namenode 不断地检测这些需要复制的数据块，一旦发现就启动复制操作**。在下列情况下，可能需要重新复制：**某个 Datanode 节点失效，某个副本遭到损坏，Datanode 上的硬盘错误，或者文件的副本系数增大**。

保守地说，标记 datanode 为宕机的时间很长(默认超过10分钟)，以避免由于 datanode 的状态变化而导致频繁复制。对于性能敏感的工作负载，用户可以通过设置缩短 datanode 为宕机的时间，并避免将数据读取 和/或 写入宕机的节点。

### 集群均衡

HDFS 的架构支持 **数据均衡策略**。如果某个 Datanode 节点上的空闲空间低于特定的临界点，按照均衡策略系统就会自动地将数据从这个 Datanode 移动到其他空闲的 Datanode。当对某个文件的请求突然增加，那么就自动创建该文件新的副本，并且同时重新平衡集群中的其他数据。这些均衡策略目前还没有实现。

### 数据完整性

从某个 Datanode 获取的 block 有可能是损坏的，原因可能是 Datanode 的存储设备错误、网络错误或者软件bug。HDFS 客户端软件实现了对 HDFS 文件内容的 **校验和(checksum)检查。当客户端创建一个新的 HDFS 文件，会计算这个文件每个数据块的校验和，并将校验和作为一个单独的隐藏文件保存在同一个HDFS名字空间下。当客户端获取文件内容后，它会检验从 Datanode 获取的数据 跟相应的校验和文件中的校验和 是否匹配，如果不匹配，客户端可以选择从其他Datanode获取该数据块的副本。**

### 元数据磁盘错误

FsImage 和 Editlog 是 HDFS 的核心数据结构。如果这些文件损坏了，整个 HDFS 实例都将失效。因而，**Namenode 可以配置成支持维护多个 FsImage 和 Editlog 的副本。任何对 FsImage 或者 Editlog 的修改，都将同步到它们的副本上**。当 Namenode 重启的时候，它会选取最近的完整的 FsImage 和 Editlog 来使用。

提高抗故障弹性另一个的措施就是 **通过设置多个 NameNodes 实现高可用性，要么基于 NFS 实现共享存储，要么使用一个分布式的 Edit log(Journal)。后者是推荐的方法**。

### 快照

快照支持某一特定时刻的数据的备份。利用快照，可以让 HDFS 在数据损坏时恢复到过去一个已知正确的时间点。

## hdfs为什么不适合存小文件

(1)小文件过多，会过多占用namenode的内存，并浪费block。

	A. 文件的元数据，都是存储在namenode上的，HDFS的每个命名空间对象占用150byte。那么：

	有100个1M的文件存储进入HDFS系统，那么数据块的个数就是100个，元数据的大小就是100*150byte，消耗了15000byte的内存，但是只存储了100M的数据。

	有1个100M的文件存储进入HDFS系统，那么数据块的个数就是1个，元数据的大小就是150byte，消耗量150byte的内存，存储量100M的数据。

	===============================================================================
	B. dataNode会向NameNode发送两种类型的报告：
		增量报告是当dataNode接收到block或者删除block时，会向nameNode报告。
		全量报告是周期性的，NN处理100万的block报告需要1s左右，这1s左右NN会被锁住，其它的请求会被阻塞。

(2)文件过小，寻道时间大于数据读写时间，这不符合HDFS的设计:

	HDFS为了使数据的传输速度和硬盘的传输速度接近，则设计将寻道时间（Seek）相对最小化，将block的大小设置的比较大，这样读写数据块的时间将远大于寻道时间，接近于硬盘的传输速度。

参考：[hdfs为什么不适合存小文件](https://www.cnblogs.com/qingyunzong/p/8535995.html)

## mapreduce输入相关

InputFormat 为 MapReduce Job 描述输入的细节规范。

具体来说：
- 检查 Job 输入的有效性。
- 把输入文件切分成多个逻辑InputSplit实例，并分别分发每个InputSplit给一个 Mapper。
- 提供RecordReader，RecordReader从逻辑InputSplit中获得输入记录，交由Mapper处理。

两个方法：
- createRecordReader 创建一个记录阅读器
- getSplits  返回输入文件的逻辑分片集合

TextInputFormat 是默认的InputFormat。（Keys 是行在文件的位置，Values是文本的一行。）

其中，InputSplit 表示一个独立Mapper要处理的数据。

其上限是文件系统的block的大小，下限通过 mapreduce.input.fileinputformat.split.minsize 设置

FileSplit 是默认的 InputSplit。 [进行分片的地方]

其中，RecordReader 将数据划分为键值对形式交予Mapper处理。

一般的，RecordReader 把由 InputSplit 提供的字节样式的输入文件，转化成由Mapper处理的记录样式的文件。
[RecordReader接收的数据不是键值对形式的]

## mapreduce分区

分区(Partitioner) 作用就是控制将中间过程的key（也就是这条记录）应该发送给m个reduce任务中的哪一个来进行reduce操作。

Key（或者一个key子集）通常使用 Hash 函数产生分区。

分区的数目与一个作业的 Reducer 任务的数目是一样的。

HashPartitioner是默认的 Partitioner。自定义分区需要实现Partitioner接口，重写getPartition方法。

## mapReduce有几种排序及排序发生的阶段

三种

	1、中间结果在写入磁盘前，会根据分区号和key进行一次快速排序。
		结果：数据按照partition为单位聚集在一起，同一partition内的按照key有序。
	2、在溢写到磁盘之后会归并排序；将多个小文件合并成大文件的。
		所以合并之后的大文件还是分区、有序的。
	3、reduce端在取数据的同时，会按照相同的分区，再将取过来的数据进行归并排序，
		大文件的内容按照key有序进行排序。
	4、如果需要将中间键分组规则与reduce前的键的分组等价规则不同，可以实现按值的二次排序。
		首先按照第一字段排序，然后再对第一字段相同的行按照第二字段排序

## mapreduce二次排序 

1、将原key和value作为一个新的key，实现WritableComparable接口
   重写compareTo、hashcode、equals、write和readFields方法
   
2、定制分区器，据Mapper产出的新key来决定数据进到哪个Reducer。
   继承Partitioner类，重写getPartition方法。
   
3、分组比较器，控制哪些键要分组到一个`Reduce.reduce()`方法中调用。
   继承WritableComparator类，重写compare方法。
   
4、在main函数中添加`job.setGroupingComparatorClass`、`job.setPartitionerClass`

## mapreduce中压缩技术的使用

MapReduce 可以对map的输出和job的输出进行压缩，这样能够减少储存文件
所需要的磁盘空间、加速数据在网络和磁盘上的传输。

压缩算法主要有gzip、bzip2、snappy、LZO、lz4，其中只有bzip2和LZO支持切分。
[如何选择压缩算法?]

可以在`mapred-default.xml` 文件设置，也可以在应用程序中设置。
但都需要先启动(设为true)，然后再指定压缩算法。

压缩map输出:
```java
Configuration conf = new Configuration();
conf.setBoolean("mapred.compress.map.output", true);
conf.setClass("mapred.map.output.compression.codec", GzipCodec.class, CompressionCodec.class);
```

压缩job输出:
```java
FileOutputFormat.setCompressOutput(Job, true);
FileOutputFormat.setOutputCompressorClass(Job, GzipCodec.class)
```

## mapper阶段会调用几次map函数,map类中重写哪些方法，继承什么类

	每行数据调一个map；（流式读取数据）
	setup、map、cleanup;
	继承mapper类

## 借助wordcount实例，写出mapreduce的执行流程

![hadoop01](./image/hadoop01.png)

## mapreduce中的join操作

    reduce join
 
    - Map端读取所有的文件，并在输出的内容里加上标示，代表数据是从哪个文件里来的。
    - 在reduce处理函数中，按照标识对数据进行处理。
    - 然后根据Key去join来求出结果直接输出。

    map Join   

    一个数据集很大，另一个数据集很小（能够被完全放进内存中），MAPJION会把小表全部读入内存中，把小表拷贝多份分发到大表数据所在实例上的内存里，在map阶段直接 拿另 外一个表的数据和内存中表数据做匹配。

原文链接:[Mapreduce中的join操作](https://www.cnblogs.com/tongxupeng/p/10417527.html)