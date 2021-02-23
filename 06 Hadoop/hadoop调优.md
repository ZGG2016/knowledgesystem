# hadoop调优

[TOC]

#### 合理处理小文件

**(1)归档小文件 Archives**

所有的小文件都在 HAR 文件之下，存储在 NameNode 下的元数据就有所减少。

但这样需要访问两层索引文件才能获取小文件在 HAR 文件中的存储位置，效率低。

**(2)将小文件存储成SequenceFile文件**

key 是各个文件的名称，value 是文件内容。 SequenceFile 文件还支持压缩和切分。

但把已有的数据转存为 SequenceFile 比较慢，且访问时，只能从文件头顺序访问。

**(3)采用CombineFileInputFormat来作为输入**

在 mapper 中将多个文件合成一个分片作为输入。

**(4)将小文件存储到类似于 HBase 的 KV 数据库里**

将 Key 设置为小文件的文件名，Value 设置为小文件的内容，相比使用 
SequenceFile 存储小文件，使用 HBase 的时候我们可以对文件进行修改，甚至能拿到
所有的历史修改版本。

#### 开启 JVM 重用

为了实现任务隔离，hadoop 将每个 task 放到一个单独的 JVM 中执行，而对于执行时间较短的 task ，JVM 启动和关闭的时间将占用很大比例时间，为此，用户可以启用 JVM 重用功能，这样一个 JVM 可连续启动多个同类型的任务。

在mapred-site.xml文件中进行配置:

```xml
<property>
  <name>mapreduce.job.jvm.numtasks</name>
  <value>10</value>
  <description>How many tasks to run per jvm. If set to -1, there is no limit. </description>
</property>
```

开启 JVM 重用将一直占用使用到的 task 插槽，以便进行重用，直到任务完成后才能释放。如果某个"不平衡的" job 中有某几个 reduce task 执行的时间要比其他 reduce task 消耗的时间多的多的话，那么保留的插槽就会一直空闲着却无法被其他的 job 使用，直到所有的 task 都结束了才会释放。

#### 合理设置map和reduce任务数

两个都不能设置太少，也不能设置太多。太少，会导致Task等待，延长处理时间；太多，会导致 Map、Reduce任务间竞争资源，造成处理超时等错误；

map任务数量的设置可以通过调整分片的大小实现。

reduce任务数量默认是1，一个节点reduce任务数量上限由`mapreduce.tasktracker.reduce.tasks.maximum`设置（默认2）。

可以采用以下探试法来决定Reduce任务的合理数量：

每个reducer都可以在Map任务完成后立即执行：

      0.95 * (集群节点数量 * mapreduce.tasktracker.reduce.tasks.maximum)

较快的节点在完成第一个Reduce任务后，马上执行第二个：

      1.75 * (集群节点数量 * mapreduce.tasktracker.reduce.tasks.maximum)

#### 选择合理的Writable类型

如，处理整数类型数据时，直接采用IntWritable比先以Text类型读入在转换为整数类型要高效。

如果输出整数的大部分可用一个或两个字节保存，那么直接采用VIntWritable或者VLongWritable，它们采用了变长整型的编码方式，可以大大减少输出数据量。

#### 重用Writable类型

避免这样写`context.write(new Text(word), new IntWritable(1))`，这样会导致程序分配出成千上万个短周期的对象。Java垃圾收集器就要为此做很多的工作。更有效的写法是：

	class MyMapper … { 
	  Text wordText = new Text(); 
	  IntWritable one = new IntWritable(1); 
	  public void map(...) { 
	    for (String word: words) { 
	      wordText.set(word); 
	      context.write(wordText, one); 
	    } 
	  } 
	}

#### 避免不必要的Reduce任务

如果要处理的数据是排序且已经分区的，或者对于一份数据， 需要多次处理，可以先排序分区；

然后自定义 InputSplit, 将单个分区作为单个 mapreduce的输入；

在map中处理数据, Reducer设置为空。

这样, 既重用了已有的 “排序”, 也避免了多余的reduce任务和shuffle操作。

#### 增加输入文件的副本数

如果一个作业并行执行的任务数目非常多，那么这些任务共同的输入文件可能成为瓶颈。

为防止多个任务并行读取一个文件内容造成瓶颈，用户可根据需要增加输入文件的副本数目。

块的副本数，默认3：

	dfs.replication	

#### 调整心跳配置

调整心跳的间隔：

	mapreduce.jobtracker.heartbeat.interval.min

启用带外心跳：是任务运行结束或者任务运行失败时触发的，能够在出现空闲资源时第一时间通知JobTracker，以便它能够迅速为空闲资源分配新的任务：

	mapreduce.tasktracker.outofband.heartbeat

#### 修改最大槽位数

默认2：

	mapreduce.tasktracker.map.tasks.maximum

	mapreduce.tasktracker.reduce.tasks.maximum

#### 启动推测执行机制

当一个作业的某些任务运行速度明显慢于同作业的其他任务时，hadoop 会在另一个节点上为“慢任务”启动一个备份任务，这样两个任务同时处理一份数据，而 hadoop 最终会将优先完成的那个任务的结果作为最终结果，并将另一个任务杀掉。

如果启用，多个map/reduce任务并行执行，默认true：

	mapreduce.map.speculative
	mapreduce.reduce.speculative

#### 设置失败容忍度

hadoop 运行设置 task 级别和 job 级别的失败容忍度。

job 级别: hadoop  允许每个 job 有一定比例的 task 运行失败，这部分 task 对应的输入数据将被忽略；

	mapreduce.map.failures.maxpercent
	mapreduce.reduce.failures.maxpercent
	
task 级别: hadoop 允许 task 失败后再在另外节点上尝试运行，如果一个 task 经过若干次尝试运行后仍然运行失败，那么 hadoop 才会最终认为该 task 运行失败。

	mapreduce.reduce.maxattempts  默认4次
	mapreduce.map.maxattempts	  默认4次

#### 合理使用DistributedCache

一般情况下，使用外部文件有两种方法：

一种是外部文件与应用程序jar包一起放到客户端，当提交作业时由客户端上传到HDFS的一个目录下，然后通过Distributed Cache分发到各个节点上；

另一种方法是事先将外部文件直接放到HDFS上。

从效率上讲，第二种方法更高效。第二种方法不仅节省了客户端上传文件的时间，还隐含着告诉DistributedCache:"请将文件下载到各个节点的pubic级别共享目录中”，这样，后续所有的作业可重用已经下载好的文件，不必重复下载。

#### 跳过损坏的记录

当一条或几条坏数据记录导致任务运行失败时，hadoop 可自动识别并跳过这些坏记录。

	mapreduce.map.skip.maxrecords
	mapreduce.reduce.skip.maxgroups

或SkipBadRecords类下：

	任务失败次数达到该值时，才会进入skip mode
	setAttemptsToStartSkipping(Configuration conf, int attemptsToStartSkipping)

	setMapperMaxSkipRecords(Configuration conf, long maxSkipRecs)
	setReducerMaxSkipGroups(Configuration conf, long maxSkipRecs)

#### 提高作业优先级

作业的优先级越高，它能够获取的资源也越多.

提供了5种作业优先级，分别为 VERY_HIGH、 HIGH、 NORMAL、 LOW、 VERY_LOW。

	hadoop job -set-priority jobid 优先级

#### 在map端执行combine

减少shuffle的数据量

#### 调整处理RPC的线程数

监听来自客户端请求的namenode rpc服务线程数，默认10：

	dfs.namenode.handler.count=20 * log2(Cluster Size)，
	比如集群规模为 8 台时，此参数设置为 60	

	NameNode 有一个工作线程池，
	用来处理不同 DataNode 的并发心跳以及客户端并发的元数据操作。
	对于大集群或者有大量客户端的集群来说，通常需要增大参数

监听来自datanodes请求的namenode rpc服务线程数，默认10：

	dfs.namenode.service.handler.count

datanode上用于处理RPC的线程数。默认为10:

	dfs.datanode.handler.count 

#### Hadoop 宕机

（1）如果 MR 造成系统宕机。

此时要控制 Yarn 同时运行的任务数，和每个任务申请的最大内存。

调整参数：yarn.scheduler.maximum-allocation-mb（单个任务可申请的最多物理内存量，默认是 8192MB） 

（2）如果写入文件过量造成 NameNode 宕机。

那么调高 Kafka 的存储大小，控制从 Kafka 到 HDFS 的写入速度。高峰期的时候用 Kafka 进行缓存，高峰期过去数据同步会自动跟上。

#### 调整JVM堆的最大可用内存

设置JVM堆的最大可用内存，需从应用程序角度进行配置:

	mapred.child.java.opts

#### 调整分片大小

【和块的关系】

一个分片对应一个map任务，所以也间接决定了map任务的数量。

map输入的最大的分片大小

	mapreduce.input.fileinputformat.split.maxsize [mapred-site.xml]

map输入的最小的分片大小，默认是0

	mapreduce.input.fileinputformat.split.minsize [mapred-site.xml]

分片计算方法：

	protected long computeSplitSize(long blockSize, long minSize,
	                                 long maxSize) {
	    return Math.max(minSize, Math.min(maxSize, blockSize));
	}

#### 调整内存缓存区大小

当 map 任务产生了非常大的中间数据时，可以适当调大该参数，使缓存能容纳更多的map中间数据，而不至于大频率的IO磁盘，当系统性能的瓶颈在磁盘IO的速度上，可以适当的调大此参数。

同时合理设置一个溢写比例，可以避免还未排完序，剩余的0.2已写满的情况。

内存缓存区的大小，默认100mb:

	mapreduce.task.io.sort.mb

溢写比例，默认0.8：

	mapreduce.map.sort.spill.percent

#### 调整合并文件的数量

在排序文件的同时，一次合并文件的数量，默认10：

	mapreduce.task.io.sort.factor

#### 是否压缩输出

减少传输的数据量

是否压缩job的输出，默认false：

	mapreduce.output.fileoutputformat.compress

是否压缩map的输出，默认false：

	mapreduce.map.output.compress

#### 调整reduce启动的时机

使map、reduce共存，map运行到一定程度后，reduce开始运行，减少reduce的等待时间。

map的数量完成多少时，启动reduce，默认是0.05:

	mapreduce.job.reduce.slowstart.completedmaps

#### 调整reduce端复制数据的并行度

根据map输出数据的具体情况，合理调整，可以提高复制数据的效率。

reduce 从map端复制数据的并行度，默认5：

	mapreduce.reduce.shuffle.parallelcopies

	-------------------------------------------------

	mapreduce.tasktracker.http.threads：
	运行在每个TaskTracker上，用于处理map task输出的线程数。

#### 调整从map端复制到reduce端的数据的存放内存大小

在shuffle期间，存储map输出的内存占最大堆内存的比例，默认0.7：

	mapreduce.reduce.shuffle.input.buffer.percent

#### 调整reduce端的溢写排序阈值

达到阈值后，把内存中的数据 merge sort，写到reduce节点的本地磁盘的比例(占总的堆内存)，默认0.66：

	mapreduce.reduce.shuffle.merge.percent

功能同上一个，但是根据内存中的文件数量计算的阈值，默认1000：

	mapreduce.reduce.merge.inmem.threshold

#### yarn角度

分配给container的物理内存：

	yarn.nodemanager.resource.memory-mb	

分配给container的最小内存，默认1024：

	yarn.scheduler.minimum-allocation-mb	

分配给container的最大内存，默认8192：

	yarn.scheduler.maximum-allocation-mb

分配给container的内核数：

	yarn.nodemanager.resource.cpu-vcores

分配给container的最小虚拟cpu内核数量，默认1：

	yarn.scheduler.minimum-allocation-vcores

分配给container的最大虚拟cpu内核数量，默认4：

	yarn.scheduler.maximum-allocation-vcores


情景描述：

总共 7 台机器，每天几亿条数据，数据源->Flume->Kafka->HDFS->Hive面临问题：数据统计主要用 HiveSQL，没有数据倾斜，小文件已经做了合并处理，开启的 JVM 重用，而且 IO 没有阻塞，内存用了不到 50%。但是还是跑的非常慢，而且数据量洪峰过来时，整个集群都会宕掉。基于这种情况有没有优化方案。

解决办法：

内存利用率不够。这个一般是 Yarn 的 2 个配置造成的，单个任务可以申请的最大内存大小，和 Hadoop 单个节点可用内存大小。调节这两个参数能提高系统内存的利用率。

（a）yarn.nodemanager.resource.memory-mb

表示该节点上 YARN 可使用的物理内存总量，默认是 8192（MB），注意，如果你的节点内存资源不够 8GB，则需要调减小这个值，而 YARN 不会智能的探测节点的物理内存总量。

（b）yarn.scheduler.maximum-allocation-mb

单个任务可申请的最多物理内存量，默认是 8192（MB）。

#### 硬件选择

master 维护全局元数据信息的重要性远远大于 slave。在较低 Hadoop 版本中，master 存在单点故障问题，因此，master 的配置应远远好于各个 slave。

#### linux参数调整

(1) noatime 和 nodiratime属性

文件挂载时设置这两个属性可以明显提高性能。默认情况下，Linuxext2/ext3 文件系统在文件被访问、创建、修改时会记录下文件的时间戳，比如：文件创建时间、最近一次修改时间和最近一次访问时间。如果系统运行时要访问大量文件，关闭这些操作，可提升文件系统的性能。Linux 提供了 noatime 这个参数来禁止记录最近一次访问时间戳。

	vi /etc/fstab
	/dev/sda2    /data     ext3  noatime,nodiratime  0 0 

(2) readahead buffer

调整linux文件系统中预读缓冲区的大小，可以明显提高顺序读文件的性能。

默认buffer大小为256 sectors，可以增大为1024或者2408 sectors（注意，并不是越大越好）。可使用 blockdev 命令进行调整。

	blockdev --setra READAHEAD xxx /dev/sda

(3) 避免RAID和LVM操作

避免在TaskTracker和DataNode的机器上执行RAID和LVM操作，这通常会降低性能。

(4) 避免使用swap分区

	查看：cat /proc/sys/vm/swappiness
	设置：vi /etc/sysctl.conf 
		在这个文档的最后加上这样一行: vm.swappiness=10
		表示物理内存使用到90%（100-10=90）的时候才使用swap交换区

(5) 查看linux的服务，可以关闭不必要的服务

	ntsysv

(6) 停止打印服务

	#/etc/init.d/cups stop
	#chkconfig cups off

(7) 关闭ipv6

	#vim /etc/modprobe.conf
	添加内容
	alias net-pf-10 off
	alias ipv6 off

(8) 调整文件最大打开数

	查看： ulimit -a    结果：open files (-n) 1024
	临时修改： ulimit -n 4096
	持久修改：
	vi /etc/security/limits.conf在文件最后加上：
	* soft nofile 65535
	* hard nofile 65535
	* soft nproc 65535
	* hard nproc 65535

(9) 修改linux内核参数

	vi /etc/sysctl.conf
	添加
	net.core.somaxconn = 32768

web应用中listen函数的backlog默认会给我们内核参数的net.core.somaxconn限制到128，而nginx定义的NGX_LISTEN_BACKLOG默认为511，所以有必要调整这个值。

[https://blog.csdn.net/muyingmiao/article/details/103209151?utm_medium=distribute.pc_aggpage_search_result.none-task-blog-2~all~sobaiduend~default-1-103209151.nonecase&utm_term=hadoop%20jvm%E9%87%8D%E7%94%A8%E5%BC%80%E5%90%AF&spm=1000.2123.3001.4430](https://blog.csdn.net/muyingmiao/article/details/103209151?utm_medium=distribute.pc_aggpage_search_result.none-task-blog-2~all~sobaiduend~default-1-103209151.nonecase&utm_term=hadoop%20jvm%E9%87%8D%E7%94%A8%E5%BC%80%E5%90%AF&spm=1000.2123.3001.4430)

[http://blog.sina.com.cn/s/blog_6a67b5c50100vop9.html](http://blog.sina.com.cn/s/blog_6a67b5c50100vop9.html)

[https://blog.csdn.net/pansaky/article/details/83347357](https://blog.csdn.net/pansaky/article/details/83347357)

[https://blog.csdn.net/dehu_zhou/article/details/52808752](https://blog.csdn.net/dehu_zhou/article/details/52808752)