# Hadoop高可用性(QJM) #

## 背景 ##

hadoop2.0之前，hadoop集群存在**单点故障**的问题。每个集群只有一个NameNode，一旦这台机器故障，整个集群就会不可用。

除非重启NameNode，或者在另一台机器上启动NameNode。

两方面影响着集群的可用性：

	（1）计划外的事件，例如机器宕机，集群不可用，直到重启NameNode.
	（2）计划维护事件，例如NameNode机器上软硬件的更新，会导致windows of cluster downtime.(短期停用)

hdfs的高可用性通过提供the option of running two redundant NameNodes in the same cluster 
in an Active/Passive configuration with a hot standby. 

## 架构 ##

一个HA的集群，配置两个机器为NameNode节点。在任意时刻，一个处在Active状态，一个处在**Standyby**状态。

Active的NameNode负责处理客户端操作，Standyby的NameNode仅仅作为一个slave，**提供容错(failover)功能**。

两类NameNode通过一组**"JournalNodes"(JNs)**进程保持通信，以此使Standy NameNode**同步Active NameNode的状态**。

当在Active结点上操作命名空间时，会将操作日志持久化到JNs进程上。而Standby结点会持续监控JNs进程，当日志更新

时，读取JNs上的日志，将其应用到自己的命名空间上。Standy结点升级为Active结点前，会确保从JNs读取了所有的日志。

这就保证了failover发生前Standy结点与Active结点命名空间状态保持同步。

为了实现了快速failover，Standy结点需要知道最新的块的位置。为了实现这个，DataNode会配置这两类NameNode的位置，

发送(both)块的信息和心跳给他们。

保持集群仅有一个Active NameNode是非常重要的。否则命名空间被划分成了两部分，会导致数据丢失或其他错误结果。为了

确保这个性质和阻止"split_brain scenario"，在一个时间点，JNs仅允许一个NameNode成为writer。在failover期间，

Active NameNode是仅有的可以往JNs写数据的NameNode。

## 硬件资源 ##

需要准备一下机器：

	NameNode机器：运行Active和Standby namenode的机器，相同的硬件配置。
	JournalNode机器：运行JournalNode。可以将JNs进程与其他hadoop进程放在一个机器上，例如namenode\jobtracker\yarn RM。
					至少于运行3个JNs进程，因为edit log的更改会写入到大部分的JNs中，这就允许系统能容忍单台机器的故障。JNs
					进程数最好设成奇数个。

在HA集群中，Standby结点也会执行checkpoints过程。所以不需要运行SecondryNameNode、CheckpointNode,或BackupNode。

## 部署 ##

每个NameNode都会一个独立的NameNode ID。To support a single configuration file for all of the NameNodes, 

the relevant configuration parameters are suffixed with the nameservice ID as well as the NameNode ID.

首先配置hdfs-site.xml文件

配置的属性的顺序不重要。但是配置的dfs.nameservices和dfs.ha.namenodes.[nameservice ID]是有顺序的。在前的为active。

	dfs.nameservices   新的nameservice的逻辑名称，例如"mycluster"。这个名称用在配置文件中，as the authority component of absolute HDFS paths in the cluster.（HDFS路径的一部分）
		note：如果使用了HDFS federation，这个配置的设置应该包含其他nameservices，用逗号分隔。

	<property>
	  <name>dfs.nameservices</name>
	  <value>mycluster</value>
	</property>
	
	=================================================
	dfs.ha.namenodes.[nameservice ID] nameservice中的每个namenode的唯一的标识符。用逗号划分。让datanode知道哪些是namenode。
		note:目前，每个nameservice最多只能配置两个NameNode。
	<property>
	  <name>dfs.ha.namenodes.mycluster</name>
	  <value>nn1,nn2</value>
	</property>

	=================================================
	dfs.namenode.rpc-address.[nameservice ID].[name node ID] 每个namenode监听的RPC地址
		note:也可以配置c成“ servicerpc-address ”设置。
	<property>
	  <name>dfs.namenode.rpc-address.mycluster.nn1</name>
	  <value>machine1.example.com:8020</value>
	</property>
	<property>
	  <name>dfs.namenode.rpc-address.mycluster.nn2</name>
	  <value>machine2.example.com:8020</value>
	</property>

	=================================================
	dfs.namenode.http-address.[nameservice ID].[name node ID] 每个namenode监听的HTTP地址
		note:如果使能了hadoop的security特征，应该设置http-address
	<property>
	  <name>dfs.namenode.http-address.mycluster.nn1</name>
	  <value>machine1.example.com:50070</value>
	</property>
	<property>
	  <name>dfs.namenode.http-address.mycluster.nn2</name>
	  <value>machine2.example.com:50070</value>
	</property>

	==================================================
	dfs.namenode.shared.edits.dir