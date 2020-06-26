# 面试准备之hadoop

## hadoop的安装过程

	（1）修改/etc/hosts文件，绑定ip地址与主机名；
	（2）关闭防火墙，关闭防火墙开机启动； systemctl stop firewalld.service
	（3）设置ssh免密登录；ssh-keygen -t rsa
	（4）解压jdk、hadoop，编辑/etc/profile配置环境变量；
	（5）编辑hadoop的配置文件；
	Core-site.xml、hdfs-site.xml、mapred-site.xml、yarn-site.xml、slave
	（6）格式化hdfs namenode -format；
	（7）启动start-all.sh
	（8）jps查看进程

## 列出正常工作的hadoop集群中hadoop都需要启动哪些进程，他们的作用分别是什么？

	（1）namenode：接收客户端读写请求、管理文件系统的命名空间
				(对文件系统的操作，如打开关闭重命名文件目录，block发送到datanode的策略)
	（2）Datanode：存储client发来的数据块block；执行数据块的读写操作；向namenode发送心跳
				（处理来自客户端的读写请求，在namenode调度下block的创建删除复制)
	（3）Secondary namenode：保存NN中对HDFS metadata的信息的备份，并减少NN重启的时间；
	（4）Nodemanager：接收ResourceManager的资源分配请求，分配具体的Container给应用。监控并报告Container使用信息给ResourceManager。
	（5）Resource manager：负责整个集群的资源管理和调度；

## 请写出以下执行命令

	1) 杀死一个job?    hadoop job -list获取jobid,   kill -9 jobID
	
	2) 删除hdfs上的/tmp/aaa目录    hadoop fs -rm -r /tmp/aaa

	3) 加入一个新的存储节点和删除一个计算节点需要刷新集群状态命令？

		静态添加datanode:
				停止namenode; 
				修改slaves文件，并更新到各个节点;
				启动namenode;
				执行hadoop balance命令start-balancer.sh。

		动态添加datanode:
				修改slaves文件，添加需要增加的节点host或者ip，并将其更新到各个节点 
				在datanode中启动执行启动datanode命令。命令：sh hadoop-daemon.sh start datanode 
				可以通过web界面查看节点添加情况。或使用命令：sh hadoop dfsadmin -report 
				执行hadoop balance命令start-balancer.sh。

		删除节点:

			sh hadoop dfsadmin  -refreshServiceAcl

			说明：dead方式并未修改slave文件和hdfs-site文件。 
			所以在集群重启时，该节点不会被添加到namenode的管理中。 
			此次在namenode上进行，其他节点可另行实验。，该命令会将该节点状态置为dead。 
			==================================================================
			a) 修改hdfs-site，添加exclude字段中的排除的节点(dfs.hosts.exclude)。 
			b) 执行sh hadoop dfsadmin -refreshNodes，强制刷新。 
			c) 查看节点状态，该节点的状态为decommission。
			
			说明：decommission方式修改了hdfs-site文件，未修改slave文件。 
			所以集群重启时，该节点虽然会被启动为datanode，但是由于添加了exclude，所以namenode会将该节点置为decommission。 
			此时namenode不会与该节点进行hdfs相关通信。也即exclude起到了一个防火墙的作用。
			
			注： 
			1. 如果在某个节点单独停止datanode，那么在namenode的统计中仍会出现该节点的datanode信息。 
			此时可通过dead或者decommission（退役）方式下线机器。

## 列出你所知道的hadoop调度器，并简要说明其工作方法？

	FIFO调度器:先按照作业的优先级高低，再按照到达时间的先后选择被执行的作业。(MR1一些阻塞型任务会持续占有资源，使得任务无法进行)
	Capacity调度器:集群有多个队列组成，在每个队列内部，作业根据FIFO（依靠优先级决定）进行调度
	Fair调度器:每个用户公平共享集群能力

## 用Java，Streaming,pipe方式开发mapreduce,各有哪些优缺点？

## hadoop怎么样实现二级排序 (阿里)

	hadoop中默认依据key排序，如果要按照value排序，把key和value组成一个新的key，实现WritableComparable接口。

	可以把key和value联合起来作为新的key，记作newkey。这时，newkey含有两个字段，假设分别
	是k,v。这里的k和v是原来的key和value。原来的value还是不变。这样，value就同时在newkey
	和value的位置。我们再实现newkey的比较规则，先按照key排序，在key相同的基础上再按照
	value排序。在分组时，再按照原来的key进行分组，就不会影响原有的分组逻辑了。最后在输出的
	时候，只把原有的key、value输出，就可以变通的实现了二次排序的需求。

	@Override
	public int compareTo(NewK2 o) {
	    long minus = this.first-o.first;
		if(minus != 0) {
			return (int)minus;
		}
		return (int)(this.second - o.second);
	}

	重写的方法有readFields\write\compareTo\hashCode\equals
	https://www.cnblogs.com/xuxm2007/archive/2011/09/03/2165805.html

## 简述hadoop实现join的几种方法

	（1）map端的join
	针对以下场景进行的优化：两个待连接表中，有一个表非常大，而另一个表非常小，
	以至于小表可以直接存放到内存中。这样，我们可以将小表复制多份，
	让每个map task内存中存在一份（比如存放到hash table中），
	然后只扫描大表：对于大表中的每一条记录key/value，
	在hash table中查找是否有相同的key的记录，如果有，则连接后输出即可。

	（2）reduce端的join
	reduce函数获取key相同的来自不同文件的value值，将其合并。
	
	（3）SemiJoin
	（4）reduce side join + BloomFilter

## 简述mapreduce中，combiner，partition作用

	combiner作用：有时一个map可能会产生大量的输出，
		combiner的作用是在map端对输出先做一次合并，以减少网络传输到reducer的数量。
	
	partition作用：对于map任务输出的中间结果，把hash值相同的key的数据分配给相同的reduce，不同的key的数据分配到了不同的reduce。分区数等于reduce的个数。

## hadoop生态圈的组件并做简要描述

	（1）hbase：一个分布式的、面向列的开源数据库, 利用Hadoop HDFS作为其存储系统。适合于非结构化数据存储。
	
	（2）Hive:基于Hadoop的一个数据仓库工具，可以将结构化的数据文件映射为一张数据库表，并提供简单的sql查询功能，可以将sql语句转换为MapReduce任务进行运行。
	
	（3）Sqoop:将一个关系型数据库中的数据导进到Hadoop的 HDFS中，也可以将HDFS的数据导进到关系型数据库中。
	
	（4）Zookeeper：一个开源的分布式应用程序协调服务,基于zookeeper可以实现同步服务，配置维护，命名服务。
	
	（5）Mahout:一个在Hadoop上运行的可扩展的机器学习和数据挖掘类库。

## hdfs读取文件写入文件过程

	写数据：
		1.客户端和namenode通信确认是否可以写数据，并返回datanode的位置信息。
		2.客户端将文件划分
		3.向第一台datanode传输block，以packet为单位，一个packet为64kb，然后由这台datanode向下面的datanode传输。
		4.当一个block传输完成之后，client再次请求namenode上传第二个block的服务器。

	读数据：
		1.客户端向namenode通信获取block所在的datanode节点,namenode返回给他
		2.客户端根据返回的信息找到相应datanode逐个获取文件的block并在客户端本地进行数据追加合并从而获得整个文件
	
	https://blog.csdn.net/qq_20641565/article/details/53328279

## hadoop 的 namenode 宕机,怎么解决

	先分析宕机后的损失，宕机后直接导致client无法访问，内存中的元数据丢失，但是硬盘中的元数据应该还存在，如果只是节点挂了，
	重启即可，如果是机器挂了，重启机器后看节点是否能重启，不能重启就要从secondrynamenode中恢复数据。但是最好的解决方案应该是在设计集群的初期就考虑到这个问题，做namenode的HA。
	https://www.2cto.com/net/201804/737737.html
	https://www.cnblogs.com/ggjucheng/archive/2012/04/18/2454693.html

## 一个datanode 宕机,怎么一个流程恢复

	Datanode宕机了后，如果是短暂的宕机，可以实现写好脚本监控，将它启动起来。如果是长时间宕机了，那么datanode上的数据应该已经
	被备份到其他机器了，那这台datanode就是一台新的datanode了，删除他的所有数据文件和状态文件，重新启动。

## hadoop分片和块的区别 ##

	输入分片：在进行map计算之前，mapreduce会根据输入文件计算输入分片，每个输入分片针对一个map任务，
		     输入分片存储的并非数据本身，而是一个分片长度和一个记录数据的位置的数组。
	块:存储的最小单位，HDFS定义其大小为128MB。存储在 HDFS上的文件均存储为多个块.实际存储数据。

## hdfs上传文件流程 ##

	1.客户端和namenode通信确认是否可以写数据，并返回datanode的位置信息。
	2.客户端将文件划分成块
	3.向第一台datanode传输block，以packet为单位，一个packet为64kb，然后由这台datanode向下面的datanode传输。
	4.当一个block传输完成之后，client再次请求namenode上传第二个block的服务器。
	{packet以chunk为单位进行校验，大小默认为512Byte}

## 讲述一下mapreduce的流程 ##

	<1>文件会被划分成多个inputsplit，每一个InputSplit都会分配一个Mapper任务,Mapper任务的输出存放在缓存中，每个map有一个环形内存缓冲区，用于存储任务的输出。默认大小100MB（io.sort.mb属性），一旦达到阀值0.8(io.sort.spill.percent),一个后台线程就把内容写到(spill)Linux本地磁盘中的指定目录（mapred.local.dir）下的新建的一个溢出写文件。
	
	<2>写磁盘前，要partition,sort。通过分区，将不同类型的数据分开处理，之后对不同分区的数据进行排序，如果有Combiner，还要对排序后的数据进行combine。等最后记录写完，将全部溢出文件合并为一个分区且排序的文件(归并排序)。
	
	<3>最后将磁盘中的数据送到Reduce中。Reducer通过Http方式得到输出文件的分区，存到内存或磁盘，排序合并。然后走Reduce阶段。

## 说一下你对hadoop生态圈的认识 ##

	存储：hdfs
	查询：hbase、hive、impala、presto、kylin
	离线计算：mapreduce、spark
	调度：zookeeper
	资源管理：yarn、mesos
	消息中间件：kafka
	数据采集:flume、logstash
	搜索：ES(Elasticsearch)
	传输：sqoop

## yarn的理解 ##

	YARN是Hadoop2.0版本引进的资源管理系统，直接从MR1演化而来。 
	核心思想：将MR1中的JobTracker的资源管理和作业调度两个功能分开，
			 分别由ResourceManager和ApplicationMaster进程实现。
 
	1.每一个应用程序对应一个ApplicationMaster
	2.目前可以支持多种计算框架运行在YARN上面，比如MapReduce、storm、Spark、Flink。

	yarn主要包括ResourceManager和NodeManager两个组件。
		ResourceManager负责为集群资源的管理与调度:
			包括Scheduler和AppllicationManager。Scheduler负责资源分配，有FIFO调度器、Capacity调度器、Fair调度器，
			ApplicationManager接收Application的请求，为其分配第一个Container来运行Application，还有监控Application的运行情况，
			在遇到失败时重启ApplicationMaster运行的Container。NodeManager接收ResourceManger的资源分配请求，分配Container给Application,监控并报告Container使用信息给ResourceManager。

	Container是Yarn对计算机计算资源的抽象，它其实就是一组CPU和内存资源，所有的应用都会运行在Container中。
	 ，它其实就是某个类型应用的实例，ApplicationMaster是应用级别的，它的主要功能就是向ResourceManager（全局的）申请计算资源（Containers）并且和NodeManager交互来执行和监控具体的task。	

## 我们开发job时，是否可以去掉reduce阶段 ##

	可以。这种情况下，map任务的输出会直接被写入由 setOutputPath(Path)指定的输出路径。不会进行排序。

## datanode在什么情况下不会备份  ##

	配置文件hdfs-site.xml中dfs.replication设为1的时候

## combiner出现在那个过程 ##

	map输出后，分区排序后

## 3个datanode中有一个datanode出现错误会怎样？  ##
	
	Datanode宕机了后，如果是短暂的宕机，可以实现写好脚本监控，将它启动起来。
	如果是长时间宕机了，那么datanode上的数据应该已经被备份到其他机器了，那这
	台datanode就是一台新的datanode了，删除他的所有数据文件和状态文件，重新启动。 

## 描述一下hadoop中，有哪些地方使用了缓存机制，作用分别是什么？  ##

	在mapreduce提交job的获取id之后，会将所有文件存储到分布式缓存上，这样文件可以被所有的mapreduce共享。 

## 如何确定hadoop集群的健康状态  ##
	
	页面监控,脚本监控。 
		1.查看hdfs集群状态，也就是namenode的访问地址 http://namenode的ip:50070
			bin/hdfs fsck报告各种文件的问题
		2.查看secondary namenode的集群状态 http://namenode的ip:50090
		3.查看yarn集群的状态 http://resource manager的ip:8088
	
## hadoop的核心配置文件名称是什么？  ##

	core-site.xml

	hadoop.tmp.dir 数据存储目录	
	io.file.buffer.size 默认4096  读写操作中缓存区的大小
	fs.defaultFS  文件系统的默认名称
	http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/core-default.xml

## “jps”命令的用处？  ##
	
	jps位于jdk的bin目录下，其作用是显示当前系统的java进程情况，及其id号。

## 如何检查namenode是否正常运行？重启namenode的命令是什么？  ##

	通过节点信息和浏览器查看，通过脚本监控 
	hadoop-daemon.sh start namenode 
	hdfs-daemon.sh start namenode 

## 避免namenode故障导致集群宕机的解决方法是什么？ ##

	使用zookeeper实现hadoop的高可用性

## 一亿个数据获取前100个最大值 ##
	
	https://blog.csdn.net/qq_21383435/article/details/79044571
	https://blog.csdn.net/caicongyang/article/details/41875095
	https://blog.csdn.net/liushahe2012/article/details/68189837

## mapreduce的环形缓存区默认大小，如何设置 ##

	100mb
	
	mapred-site.xml
	mapreduce.task.io.sort.mb	100	  shuffle 的环形缓冲区大小
	mapreduce.map.sort.spill.percent	0.80   环形缓冲区溢出的阈值

	设计成环形的好处：使输入输出并行工作，即“写缓冲”可以和“溢写”并行。

	最大能设多大？？？

## Map数量和Reduce数量怎么确定的 ##

	map的数量依赖输入文件的大小，读取数据时，会将文件分片，一个分片对应一个map任务。
		正常的map数量的并行规模大致是每一个Node是10~100个，对于CPU消耗较小的作业可以设置Map数量为300个左右
	reduce的数据依赖分区的数量。
		正确的reduce任务的个数应该是0.95或者1.75 *（节点数 ×每个结点container的最大数量）。如果是0.95，那么所有的reduce任务能够在 map任务执行完后立马开始执行传输map的输出。如果是1.75，那么高速的节点会在完成他们第一批reduce任务计算之后开始计算第二批 reduce任务，这样的情况更有利于负载均衡。

## spark为啥比Hadoop算的快 ##

	中间结果是缓存在内存而不是直接写入到disk。

	1、消除了冗余的HDFS读写
		Hadoop每次shuffle操作后，必须写到磁盘，而Spark在shuffle后不一定落盘，可以cache到内存中，以便迭代时使用。
		如果操作复杂，很多的shufle操作，那么Hadoop的读写IO时间会大大增加。

	2、消除了冗余的MapReduce阶段
		Hadoop的shuffle操作一定连着完整的MapReduce操作，冗余繁琐。而Spark基于RDD提供了丰富的算子操作，且reduce操
		作产生shuffle数据，可以缓存在内存中。

	3、JVM的优化
		Hadoop每次MapReduce操作，启动一个Task便会启动一次JVM，基于进程的操作。而Spark每次MapReduce操作是基于线程的，
		只在启动Executor是启动一次JVM，内存的Task操作是在线程复用的。每次启动JVM的时间可能就需要几秒甚至十几秒，那么
		当Task多了，这个时间Hadoop不知道比Spark慢了多少。
	https://www.jianshu.com/p/6ca1421b3c47


## 怎么存数据的，怎么对数据分块的，怎么读取数据的，都有什么控制的节点，各自都是做什么用的等等。断电的话怎么办，哪些数据丢失。 ##

## 有什么模式，模式之间的区别，yarn都是由什么组件组成的，都是干啥的。 ##


## 在一个不断产生的流式数据中，如何保证每次取到的数据尽可能的随机。##

## topk问题 ##

## 100个数，如何打乱，要求最乱。 ##

![](https://i.imgur.com/LM6xSSO.jpg)

![](https://i.imgur.com/lmsadOA.jpg)

![](https://i.imgur.com/n235Dyu.jpg)