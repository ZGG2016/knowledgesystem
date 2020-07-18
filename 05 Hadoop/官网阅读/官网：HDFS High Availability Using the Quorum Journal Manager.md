# HDFS High Availability Using the Quorum Journal Manager   高可用性(QJM) 

v3.2.1

## 1、Purpose

本指南提供了 HDFS 高可用性特征的预览，以及如何使用 Quorum Journal Manager (QJM)，
配置管理高可用的 HDFS 集群。

## 2、Note: Using the Quorum Journal Manager or Conventional Shared Storage

本指南讨论如何使用  Quorum Journal Manager (QJM) 来实现 HDFS 的高可用，以在Active NameNode 和
Standby NameNode 间共享 edit logs 。使用 NFS 实现高可用请见[另一份指南](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HDFSHighAvailabilityWithNFS.html)
使用 Observer NameNode 配置 HDFS 高可用请见[此指南](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/ObserverNameNode.html)

## 3、Background

hadoop2.0 之前，HDFS 集群存在 **单点故障** 问题。每个集群只有一个 NameNode，一旦这台机器故障，
整个集群就会不可用。**除非重启 NameNode，或者在另一台机器上启动 NameNode**。

两方面影响着集群的可用性：

	（1）计划外的事件，例如机器宕机，集群不可用，直到重启 NameNode.
	（2）计划维护事件，例如 NameNode 机器上软硬件的更新，会导致windows of cluster downtime.(短期停用)

hdfs 的高可用性就解决了上述的两个问题，方法是在同一集群配置两个或更多运行的 NameNodes，一个作为 Active，
一个作为 Passive，这样就实现了热备份。当机器宕机、或者管理员发起的故障转移时，激活 Passive NameNode
实现故障转移。


## 4、Architecture

一个 HA 集群，配置两个或更多独立的机器作为 NameNode 节点。**在任意时刻，一个处在 Active 状态，其他的处在 Standyby 状态**。
Active NameNode负责处理客户端操作，Standyby NameNode 仅仅作为一个工作节点维持自身足够的状态，
在必要时候，实现 fast failover。

两类 NameNode 通过一组 JournalNodes(JNs) 进程保持通信，以此使 Standy NameNode 和 Active NameNode
保持同步。当 Active 节点操作命名空间时，会将操作日志 **持久化到JNs进程上**。而 Standby 节点会
**持续监控JNs 进程，当日志更新时，读取 JNs 上的日志，将其应用到自己的命名空间上**。Standy 节点
升级为 Active 节点前，会确保从 JournalNodes 读取了所有的日志。这就保证了 failover 发生前 Standy 
节点与 Active 节点命名空间状态保持同步。

为了实现了 fast failover，Standy 节点需要知道块位置的最新信息。为了实现这个，DataNode会配置所有
NameNode 的位置，**发送块的位置信息和心跳给他们**。

保持集群在一时间点仅有一个 Active NameNode 是非常重要的。否则命名空间被划分成了两部分，会数据丢失
或出现其他错误结果的风险。为了确保这个性质和阻止 "split_brain scenario"，**JournalNodes 在一时间点仅允许一个 NameNode 成为 writer。**
在 failover 期间，Active NameNode 是仅有的可以往 JournalNodes 写数据的 NameNode。这就有效阻止了
其他 NameNode 继续保持 Active 状态，允许新的 Active NameNode 安全的处理 failover。

## 5、Hardware resources  硬件资源

需要准备一下机器：

	NameNode 机器：运行 Active 和 Standby NameNodes 的机器，相同的硬件配置。
	
	JournalNode 机器：运行 JournalNode。可以将 JNs 进程与其他 hadoop 进程合理放在一个机器上，例如namenode、jobtracker、yarn RM。
		注意:至少于运行3个 JNs 进程，因为 edit log 的更改必须写入到大部分的 JNs 中，
		这就允许系统能容忍单台机器的故障。你也可以允许超多3个，但 JNs 进程数最好设成奇数个。
		运行 N 个 JournalNode，系统就能最多容忍 (N - 1) / 2  个机器故障，保持功能正常。

在HA集群中，**Standby NameNodes 也会执行 checkpoints 过程**。所以在 HA 集群中不需要运行
SecondryNameNode、CheckpointNode、BackupNode。 In fact, to do so would be an error(???). 
这也允许将非HA集群重新配置成HA集群，这样就可以重用 Secondary NameNode 所在的机器资源。

## 6、Deployment  部署

### 6.1、Configuration overview

和 Federation 配置类似，HA 配置向后兼容，可以使已存在的单个 NameNode 配置不需修改就可以工作。
一个新的配置特点就是集群中的所有节点都有相同的配置。

和 HDFS Federation 一样，HA 集群也使用 **nameservice ID 识别一个 HDFS 实例** ，that may in fact consist of multiple HA NameNodes。
新增加了一个 NameNode ID 的概念。**集群中的每个 NameNode 都有一个独立的NameNode ID**。
为了支持所有的NameNode 使用相同的配置文件，相关的配置参数都以 nameservice ID 和 NameNode ID 做后缀。

### 6.2、Configuration details

首先配置hdfs-site.xml文件

配置的属性的顺序不重要。但是要先配置的 `dfs.nameservices` 和 `dfs.ha.namenodes.[nameservice ID]` 

- dfs.nameservices：**新的 nameservice 的逻辑名称**，例如"mycluster"。这个名称用在配置文件中，
或作为 HDFS 路径的一部分(as the authority component of absolute HDFS paths in the cluster.)
注意：如果也在使用 HDFS federation，这个配置的设置应该包含其他 nameservices，用逗号分隔。
```
<property>
	<name>dfs.nameservices</name>
	<value>mycluster</value>
</property>
```

- dfs.ha.namenodes.[nameservice ID]：**nameservice中的每个 namenode 的唯一的标识符**。用逗号划分。让 datanode 知道哪些是 namenode 。 如果你使用 mycluster 作为 nameservice ID，那么每个 nameservice ID 可以设为 “nn1”, “nn2” and “nn3”。
		
```
<property>
  <name>dfs.ha.namenodes.mycluster</name>
  <value>nn1,nn2, nn3</value>
</property>
```
**注意：高可用模式下，最少使用两个 NameNodes ，但是你可以配置更多。推荐设为 3 个，考虑到通信开销，最好不超过 5.**


- dfs.namenode.rpc-address.[nameservice ID].[name node ID] ： **每个 namenode 监听的 RPC 地址。**

```
<property>
	<name>dfs.namenode.rpc-address.mycluster.nn1</name>
	<value>machine1.example.com:8020</value>
</property>
<property>
	<name>dfs.namenode.rpc-address.mycluster.nn2</name>
	<value>machine2.example.com:8020</value>
</property>
<property>
	<name>dfs.namenode.rpc-address.mycluster.nn3</name>
	<value>machine3.example.com:8020</value>
</property>
```

注意：如果你愿意，也可以配置RPCservicerpc-address设置。


- dfs.namenode.http-address.[nameservice ID].[name node ID]:**每个 namenode 监听的 HTTP 地址**
		
```
<property>
	<name>dfs.namenode.http-address.mycluster.nn1</name>
	<value>machine1.example.com:9870</value>
</property>
<property>
	<name>dfs.namenode.http-address.mycluster.nn2</name>
	<value>machine2.example.com:9870</value>
</property>
<property>
	<name>dfs.namenode.http-address.mycluster.nn3</name>
	<value>machine3.example.com:9870</value>
</property>
```

注意：如果你启动了Hadoop的安全特性，你也应该同样地为每个NameNode设置https-address的地址。


- dfs.namenode.shared.edits.dir：**标识 NameNode 将写入/读取 edit 的一组 JNs 的URL**

这里为提供共享 edit 存储的 JournalNodes  配置地址。 根据配置的地址，Active NameNode执行写入，Standby NameNode 负责读取，以保持和 Active NameNode 同步。尽管必须指定一些 JournalNodes 地址，你只配置这些 URL 地址中的一个。URL应该是这种格式 "qjournal://host1:port1;host2:port2;host3:port3/journalId" 。

**Journal ID** 是 nameservice 一个唯一的标识符。允许一组 JNs 为多个联邦的命名空间系统提供存储。虽然不是必须的，但 **重用 nameservice ID** 作为 Journal 的标示符是一个好的想法。

例如，如果这个集群的一组 JournalNode 正运行在 "node1.example.com", "node2.example.com", 和 "node3.example.com" 这3台机器上，集群的 nameservice ID 是 mycluster ，你将用如下的配置作为值（JournalNode默认的端口号是8485）：

```
<property>
  <name>dfs.namenode.shared.edits.dir</name>
  <value>qjournal://node1.example.com:8485;node2.example.com:8485;node3.example.com:8485/mycluster</value>
</property>
```

dfs.client.failover.proxy.provider.[nameservice ID] - the Java class that HDFS clients use to contact the Active NameNode

Configure the name of the Java class which will be used by the DFS Client to determine which NameNode is the current Active, and therefore which NameNode is currently serving client requests. The two implementations which currently ship with Hadoop are the ConfiguredFailoverProxyProvider and the RequestHedgingProxyProvider (which, for the first call, concurrently invokes all namenodes to determine the active one, and on subsequent requests, invokes the active namenode until a fail-over happens), so use one of these unless you are using a custom proxy provider. For example:

<property>
  <name>dfs.client.failover.proxy.provider.mycluster</name>
  <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
</property>


### 6.3、Deployment details

### 6.4、Administrative commands

### 6.5、Load Balancer Setup

### 6.6、In-Progress Edit Log Tailing

## 7、Automatic Failover

### 7.1、Introduction

### 7.2、Components

### 7.3、Deploying ZooKeeper

### 7.4、Before you begin

### 7.5、Configuring automatic failover

### 7.6、Initializing HA state in ZooKeeper

### 7.7、Starting the cluster with start-dfs.sh

### 7.8、Starting the cluster manually

### 7.9、Securing access to ZooKeeper

### 7.10、Verifying automatic failover

## 8、Automatic Failover FAQ

## 9、HDFS Upgrade/Finalization/Rollback with HA Enabled