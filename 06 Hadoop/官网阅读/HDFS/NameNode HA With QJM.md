# HDFS High Availability Using the Quorum Journal Manager   高可用性(QJM) 

[TOC]

**v3.2.1**

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

```xml
<property>
	<name>dfs.nameservices</name>
	<value>mycluster</value>
</property>
```

- dfs.ha.namenodes.[nameservice ID]：**nameservice中的每个 namenode 的唯一的标识符**。用逗号划分。让 datanode 知道哪些是 namenode 。 如果你使用 mycluster 作为 nameservice ID，那么每个 nameservice ID 可以设为 “nn1”, “nn2” and “nn3”。
		
```xml
<property>
  <name>dfs.ha.namenodes.mycluster</name>
  <value>nn1,nn2, nn3</value>
</property>
```
**注意：高可用模式下，最少使用两个 NameNodes ，但是你可以配置更多。推荐设为 3 个，考虑到通信开销，最好不超过 5.**


- dfs.namenode.rpc-address.[nameservice ID].[name node ID] ： **每个 namenode 监听的 RPC 地址。**

```xml
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
		
```xml
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

```xml
<property>
  <name>dfs.namenode.shared.edits.dir</name>
  <value>qjournal://node1.example.com:8485;node2.example.com:8485;node3.example.com:8485/mycluster</value>
</property>
```

- dfs.client.failover.proxy.provider.[nameservice ID] : **HDFS 客户端用来连接 Active NameNode 的 Java 类**

配置被 DFS 客户端用来决定哪一个 NameNode 当前是 Active，从而决定哪一个 NameNode 目前服务于客户端请求。目前只有两个实现，ConfiguredFailoverProxyProvider and the RequestHedgingProxyProvider ，(对于第一个调用，并发地调用所有的 namenode 以确定 Active namenode，并在随后的请求中调用 Active namenode，直到发生故障转移)所以除非你用了自定义的类否则就用其中之一。例如：

```xml
<property>
  <name>dfs.client.failover.proxy.provider.mycluster</name>
  <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
</property>
```

- dfs.ha.fencing.methods: **脚本或 Java 类的列表，用来在故障转移中保护 Active NameNode**

在任意时刻只有一个 Active NameNode，这对系统的正确性是可取的。当使用 Quorum Journal Manager 时，仅有一个 NameNode 写入到 JournalNodes。所以对 split-brain 场景下，不会存在损坏文件系统元数据的可能。然而，当发生故障转移时，前一个 Active NameNode 仍然有可能处理客户端的读请求，这些请求可能已经过时，但直到 NameNode 在尝试写入 JournalNodes 时才会关闭。
因为这个原因，即使在使用 QJM 的时候，配置 fencing methods 也是值得的。然而，为了提高系统在 fencing 机制失效时的可用性，建议在列表的最后配置一个总是返回 success 的 fencing method 。注意，如果你选择使用不真实的方法，你仍然需要为此配置些东西，例如，shell(/bin/true)。

故障转移期间，使用的 fencing methods 被配置为回车分隔的列表，它们将顺序的被尝试直到一个显示 fencing 已经成功。有两个与 Hadoop 运行的方式：shell 和 sshfence 。关于管多的实现你自定义的 fencing method，查看org.apache.hadoop.ha.NodeFencer类。For information on implementing your own custom fencing method, see the org.apache.hadoop.ha.NodeFencer class.

---------------------------------------------------------------------------------------------

sshfence ： **SSH 到 Active NameNode 然后杀掉这个进程**

sshfence 选择 SSH 到目标节点，然后用 fuser 命令杀掉监听在服务的 TCP 端口上的进程。为了使 fencing option 工作，它必须能够免密码 SSH 到目标节点。因此，你必须配置 dfs.ha.fencing.ssh.private-key-files 选项，这是一个逗号分隔的 SSH 私钥文件的列表。例如：

```xml
<property>
	<name>dfs.ha.fencing.methods</name>
	<value>sshfence</value>
</property>
<property>
	<name>dfs.ha.fencing.ssh.private-key-files</name>
	<value>/home/exampleuser/.ssh/id_rsa</value>
</property>
```
可选择地，你可以配置一个非标准的用户名或者端口号来执行 SSH 。你也可能为此 SSH 配置一个 超时限制，单位毫秒，超过此超时限制 fencing method 将被认为失败。它可能被配置成这样：

```xml
<property>
	<name>dfs.ha.fencing.methods</name>
	<value>sshfence([[username][:port]])</value>
</property>
<property>
	<name>dfs.ha.fencing.ssh.connect-timeout</name>
	<value>30000</value>
</property>
```
shell : **运行任意的 shell 命令来 fence Active NameNode**

shell fence method 运行一个任意的 shell 命令，它可能配置成这样：

```xml
<property>
	<name>dfs.ha.fencing.methods</name>
	<value>shell(/path/to/my/script.sh arg1 arg2 ...)</value>
</property>
```

括号之间字符串被直接传给 bash shell 命令，可能不包含任何关闭括号。

Shell 命令将运行在一个包含当前所有 Hadoop 配置变量的环境中，在配置的 key 中用 _ 代替 . 。所用的配置已经将任何一个 namenode 特定的配置改变成通用的形式。例如 dfs_namenode_rpc-address 将包含目标节点的 RPC 地址，即使配置指定的变量可能是 dfs.namenode.rpc-address.ns1.nn1。
 
此外，下面的这些涉及到被 fence 的目标节点的变量，也是可用的：

A | B
---|:---
$target_host | hostname of the node to be fenced
$target_port | IPC port of the node to be fenced
$target_address | the above two, combined as host:port
$target_nameserviceid | the nameservice ID of the NN to be fenced
$target_namenodeid | the namenode ID of the NN to be fenced

这些环境变量可能被用来替换 shell 命令中的变量，例如：

```xml
<property>
	<name>dfs.ha.fencing.methods</name>
	<value>shell(/path/to/my/script.sh --nameservice=$target_nameserviceid $target_host:$target_port)</value>
</property>
```

如果 shell 命令结束返回 0，fence 被认为是成功了。如果返回任何其他的结束码，fence 不是成功的，列表中的下个 fence 方法将被尝试。

注意：fence 方法不实现任何的 timeout。如果 timeout 是必要的，它们应该在 shell 脚本中实现（例如通过fork subshell 在多少秒后杀死他的父 shell）。

fs.defaultFS : **Hadoop文件系统客户端使用的默认的路径前缀**

可选地，你现在可能为 Hadoop 客户端配置了默认使用的路径来用新的启用 HA 的逻辑 URI。如果你用 mycluster 作为 nameservice ID ，这个 id 将是所有你的 HDFS 路径的 authority 部分。这可能被配置成这样，在你的 core-site.xml 文件里：

```xml
<property>
  <name>fs.defaultFS</name>
  <value>hdfs://mycluster</value>
</property>
```

dfs.journalnode.edits.dir : **JournalNode 守护进程存储它的本地状态的位置**

这是一个在 JournalNode 机器上的绝对路径，此路径中存储了 edit 和 JNs 使用的其他的本地状态。你可能只用配置一个单独的路径。这些数据的冗余通过运行多个独立的 JournalNode 来实现，或者通过配置这个路径到一个 RAID 组。例如：

```xml
<property>
  <name>dfs.journalnode.edits.dir</name>
  <value>/path/to/journal/node/local/data</value>
</property>
```
### 6.3、Deployment details

在所有必要的配置被设置之后，你必须在它们运行的所有集器上启动所有的 JournalNode 守护进程。这可以通过运行 `hdfs-daemon.sh journalnode` 命令完成，然后等待守护进程在每一台相关的机器上启动。

一旦 JournalNode 被启动，你必须先同步两个 HA NameNode 磁盘上的元数据。

- 如果你建立了一个全新的 HDFS 集群，你应该**首先在其中一台 NameNode 上运行 format 命令（hdfs namenode -format）**。

- 如果你已经格式化了 NameNode ，或者是从一个非 HA 的集群转变成一个 HA 集群，你现在应该**复制你的 NameNode 上的元数据目录到另一个 NameNode**，没有格式化的 NameNode 通过在此机器上运行 `hdfs namenode -bootstrapStandby` 命令格式化。 运行此命令也将确保 JournalNode（就像通过 dfs.namenode.shared.edits.dir 配置的那样）包含足够的 edit 事务来启动两个 NameNode。

- 如果你**将一个非 HA 的集群转变为一个 HA 的集群，你应该运行 `hdfs -initializeSharedEdits`命令**，这个命令将会用本地 NameNode 的 edit 目录中的数据初始化 JNs。

这个时候，你启动两个 HA NameNode，就像你启动一个 NameNode 一样。

你可以通过浏览他们配置的 HTTP 地址，访问分别每一个 NameNode 的 web 主页。你应该注意到配置的地址的下面将会是 NameNode 的 HA 状态（Standby或Active）。不管一个 HA NameNode 何时启动，它首先会处在Standby状态。

### 6.4、Administrative commands

Now that your HA NameNodes are configured and started, you will have access to some additional commands to administer your HA HDFS cluster. Specifically, you should familiarize yourself with all of the subcommands of the “hdfs haadmin” command. Running this command without any additional arguments will display the following usage information:

既然你的 HA NameNode 被配置和启动了，你将可以使用一些命令来管理你的 HA HDFS 集群。特别的，你应该熟悉 hdfs haadmin 命令的所有子命令。不加任何参数运行此命令将显示下面的帮助信息：

	Usage: haadmin
	    [-transitionToActive <serviceId>]
	    [-transitionToStandby <serviceId>]
	    [-failover [--forcefence] [--forceactive] <serviceId> <serviceId>]
	    [-getServiceState <serviceId>]
	    [-getAllServiceState]
	    [-checkHealth <serviceId>]
	    [-help <command>]

本指南描述这些子命令的高级用法。对于每一个子命令特殊的用法的信息，你应该运行 hdfs haadmin -help <command> 来获得。

- transitionToActive 和 transitionToStandby：**将给定的 NameNode 转变为 Active 或者 Standby**

这两个子命令使给定的 NameNode 各自转到 Active 或者 Standby 状态。这两个命令不会尝试运行任何的 fence，因此不应该经常使用。你应该更倾向于用 hdfs haadmin -failover 命令。

- failover ：**在两个 NameNode 之间发起一次故障转移**

这个子命令从第一个提供的 NameNode 到第二个提供的 NameNode 发起一次故障转移。如果第一个 NameNode 是 Standby 状态，这个命令将简单的将第二个 NameNode 转成 Active 状态，不会报错。如果第一个 NameNode 在 Active 状态，将会尝试优雅的将其转变为 Standby 状态。如果这个过程失败，将会依次使用 fence method（就像 dfs.ha.fencing.methods 配置的）直到有一个返回 success 。在这个过程之后，第二个 NameNode 将会被转换为 Active 状态。如果没有 fence method 成功，第二个 NameNode 将不会被转变成 Active 状态，将会返回一个错误。

- getServiceState ： **判断给定的 NameNode 是 Active 还是 Standby**

连接到给定的 NameNode 来判断它目前的状态，打印 Standby 或者 Active 到合适的标准输出。这个子命令可以被用作定时任务或者监控脚本，根据 NameNode 是 Standby 还是 Active 做出不同行为。

- getAllServiceState ： **返回所有 NameNode 的状态**

连接到给定的 NameNode 来判断它目前的状态，打印 Standby 或者 Active 到合适的标准输出。

- checkHealth ：**检查给定 NameNode 的健康状况**

连接到给定的 NameNode 检查它的健康状况。NameNode 可以在对自己进行一些检测，包括检查内部服务是否正常运行。如果 NameNode 是健康的，这个命令将返回 0，不是则返回非 0 值。你可以用这个命令用于检测目的。

注意：这还没有实现，现在将总是返回success，除非给定的 NameNode 完全关闭。

### 6.5、Load Balancer Setup

如果你在负载均衡器(例如Azure或AWS)后面运行一组 namenode ，并且希望负载均衡器指向 active NN，你可以使用/isActive HTTP 端点作为健康状况探测。如果 NN 处于活动 HA 状态，http://NN_HOSTNAME/isActive 将返回200状态码响应，否则将返回 405。

### 6.6、In-Progress Edit Log Tailing

在默认设置下，Standby NameNode 将仅应用已完成的 edit log segments 中的 edits 。如果希望有一个 Standby NameNode，其中包含更多最新的名称空间信息，it is possible to enable tailing of in-progress edit segments 。此设置将尝试从 JournalNodes 上的内存缓存中获取 edits ，并可以将事务应用于 Standby NameNode之前的延迟时间缩短到毫秒级。如果无法从缓存中提供 edit ，Standby NameNode  仍然能够检索它，但延迟时间将长得多。相关配置有:

- dfs.ha.tail-edits.in-progress ：是否对正在进行的 edits logs 启用 tail 。这也将在 JournalNodes 上启用内存中的 edit 缓存。默认情况下禁用。

- dfs.journalnode.edit-cache-size.bytes：JournalNode 上 edits 的内存缓存的大小。

在一个典型的环境中，edits 大约需要 200 字节，因此，例如，默认的 1048576 (1MB)可以容纳大约 5000 个事务。建议监控 JournalNode 指标 `RpcRequestCacheMissAmountNumMisses` 和 `RpcRequestCacheMissAmountAvgTxns`，分别计算不能被缓存服务的请求的数量，和额外的在缓存中已经成功的请求的事务的数量。例如，如果一个请求试图从事务 ID 10 开始获取 edits ，但是缓存中最老的数据在事务 ID 20，那么平均值将增加10。


## 7、Automatic Failover

### 7.1、Introduction

上边的部分描述了如果配置一个手工故障转移。在那种模式下，系统将不会自动触发一个故障转移，将一个 NameNode 从 Active 装成 Standby ，即使 Active 节点已经失效。这个部分描述了如何配置和部署一个自动故障转移。

### 7.2、Components

自动故障转移增加了两个新的组件到 HDFS 的部署中：Zookeeper 仲裁和 ZKFailoverController 进程（简称ZKFC）。

Apache Zookeeper 是一个维护少量数据一致性的高可用的服务，通知客户端数据的变化，同时监控客户端的失效状况。 HDFS 的自动故障转移的实现依赖Zookeeper：

- Failure detection：集群中的每一台 NameNode 机器在 Zookeeper 中保持一个永久的 session。如果这台机器宕机，通知其他的NameNode，故障转移应该被触发了。

- Active NameNode 选举：Zookeeper 提供了一个简单的机制专门用来选择一个节点为 Active。如果目前 Active NameNode 宕机，另一个节点可以获取 Zookeeper 中的一个特殊的排它锁，声明它应该变成下一个 Active NameNode。

ZKFC是一个新的组件，它是一个Zookeeper客户端，同时也用来监视和管理 NameNode 的状态。每一台运行 NameNode 的机器都要同时运行一个 ZKFC 进程，此进程主要负责：

- 健康监控：ZKFC 周期性地用健康监测命令 ping 它的本地 NameNode 。只要 NameNode 及时地用健康状态响应，ZKFC 就认为此节点是健康的。如果此节点宕机、睡眠或者其他的原因进入了一个不健康的状态，健康监控器将会标记其为不健康。

- Zookeeper Session 管理：当本地的 NameNode 是健康的，ZKFC 在 Zookeeper 中保持一个打开的 session。如果本地 NameNode 是 Active 状态，它同时保持一个特殊的 “lock” znode 。这个锁是利用 Zookeeper 对 ephemeral node 的支持；如果 session 过期，这个 lock node 将会自动删除。

- 基于 Zookeeper 的选举：如果本地 NameNode 是健康的，ZKFC 看到当前没有其他的节点保持 lock znode，它将自己尝试获取这个锁。如果获取成功，它就赢得了选举，然后负责运行一个故障转移来使它本地的 NameNode 变为 Active。故障转移进程与上边描述的的手工转移的类似：首先，如果有必要，原来 Active NameNode 被 fence ，然后，本地 NameNode 转变为 Active 状态。

一个参考自动故障转移的设计文档来获取更多的信息，参考Apache HDFS JIRA上的 HDFS-2185 设计文档。

### 7.3、Deploying ZooKeeper

在一个典型的部署中，Zookeeper 守护进程配置为在 3 或 5 个节点上运行。因为 Zookeeper 本身有轻量级的资源需求，将 Zookeeper 守护进程跟 HDFS 的 Active NameNode 和 Standby NameNode 在同一个硬件上是可以接受的。许多管理员也选择将第三个 Zookeeper 进程部署到 YARN ResourceManager 一个节点上。建议将 Zookeeper 节点它们的数据存储到一个单独的磁盘驱动，以为了更好的性能和解耦，与存放 HDFS 元数据的驱动程序分开。

Zookeeper 的建立超出了本文档的范围。我们将假设你已经建立起了一个 3 个或者更多节点的 ZooKeeper 集群，已经通过用 ZK CLI 连接到 ZKServer 验证了其正确性。


### 7.4、Before you begin

在你开始配置自动故障转移之前，你应该关闭你的集群。目前，在集群运行过程中，从手工故障转移到自动故障转移的转变是不可能的。

### 7.5、Configuring automatic failover

自动故障转移的配置需要增加两个新的参数到你的配置文件中。在hdfs-site.xml中增加：

```xml
<property>
   <name>dfs.ha.automatic-failover.enabled</name>
   <value>true</value>
 </property>
```

这指出集群应该被建立为自动故障转移模式。在 core-site.xml 中，增加：

```xml
<property>
   <name>ha.zookeeper.quorum</name>
   <value>zk1.example.com:2181,zk2.example.com:2181,zk3.example.com:2181</value>
</property>
```
这列出了多个正在运行 Zookeeper 服务的主机名-端口号信息。

就像本文档中先前描述的参数一样，these settings may be configured on a per-nameservice basis by suffixing the configuration key with the nameservice ID.。例如，在开启联邦的集群中，你可能需要明确的指定所要开启自动故障转移的 nameservice，用 dfs.ha.automatic-failover.enabled.my-nameservice-id 指定。

也有其他的配置参数，可能被用来管理自动故障转移的表现；然而，对于大多数的安装来说是不必要的。请参考特定文档获取更多信息。

### 7.6、Initializing HA state in ZooKeeper

After the configuration keys have been added，下一步就是初始化 Zookeeper 中的必要的状态。你可以通过在任意 NameNode 所在的主机上运行下面的命令来完成这个操作：

	[hdfs]$ $HADOOP_HOME/bin/hdfs zkfc -formatZK

这将在 Zookeeper 中创建一个 znode，自动故障转移系统存储它的数据。

### 7.7、Starting the cluster with start-dfs.sh

因为自动故障转移在配置中已经被开启了，start-dfs.sh 脚本将会在任意运行 NameNode 的机器上自动启动一个 ZKFC 守护进程。当 ZKFC 启动，它们将自动选择一个 NameNode 变成 Active。

### 7.8、Starting the cluster manually

如果手工管理集群上的服务，你将需要手动在将要运行 NameNode 的机器上启动 zkfc。你可以用下面的命令启动守护进程：

	[hdfs]$ $HADOOP_HOME/bin/hdfs --daemon start zkfc

### 7.9、Securing access to ZooKeeper

如果你正在运行一个安全的集群，你很希望确保存储在 Zookeeper 中的信息也是安全的。这将防止恶意的客户端修改 Zookeeper 中的元数据，或者潜在地触发一个错误的故障转移。

为了确保 Zookeeper 中信息的安全，首先增加下面的配置到core-site.xml文件：

```xml
<property>
	<name>ha.zookeeper.auth</name>
	<value>@/path/to/zk-auth.txt</value>
</property>
<property>
	<name>ha.zookeeper.acl</name>
	<value>@/path/to/zk-acl.txt</value>
</property>
```
Please note the ‘@’ character in these values – this specifies that the configurations are not inline, but rather point to a file on disk. The authentication info may also be read via a CredentialProvider (pls see the CredentialProviderAPI Guide in the hadoop-common project).

The first configured file specifies a list of ZooKeeper authentications, in the same format as used by the ZK CLI. For example, you may specify something like:

请注意这两个值中的 “@”字符，这指出配置不是内联的，而是指向磁盘中的一个文件。身份验证信息将通过 CredentialProvider 读取。(pls see the CredentialProviderAPI Guide in the hadoop-common project).

The first configured file 以跟 ZK CLI使用的相同的格式指定了一个 Zookeeper 身份验证的列表。例如，你可能像下面这样指定一些东西：

	digest:hdfs-zkfcs:mypassword

…hdfs-zkfcs 是 Zookeeper 中全局唯一的用户名，mypassword 是一个唯一的字符串，作为密码。

下一步，根据这个认证，生成相应的 Zookeeper ACL，使用类似于下面的命令：

	[hdfs]$ java -cp $ZK_HOME/lib/*:$ZK_HOME/zookeeper-3.4.2.jar org.apache.zookeeper.server.auth.DigestAuthenticationProvider hdfs-zkfcs:mypassword
	output: hdfs-zkfcs:mypassword->hdfs-zkfcs:P/OQvnYyU/nF/mGYvB/xurX8dYs=

Copy and paste the section of this output after the ‘->’ string into the file zk-acls.txt, prefixed by the string “digest:”. For example:

复制和粘贴输出 ”->“ 后的部分，写到 zk-acls.txt 文件中，要加上” digest: “前缀，例如：

	digest:hdfs-zkfcs:vlUvLnd8MlacsE80rDuu6ONESbM=:rwcda

为了使 ACL 生效，你应该重新运行 zkfc -formatZK 命令。

做了这些之后，你可能需要验证来自 ZK CLI 的 ACL，像下面这样：

	[zk: localhost:2181(CONNECTED) 1] getAcl /hadoop-ha'digest,'hdfs-zkfcs:vlUvLnd8MlacsE80rDuu6ONESbM=: cdrwa

### 7.10、Verifying automatic failover

一旦自动故障转移被建立，你应该验证它的可用性。为了验证，首先定位 Active NameNode 。可以通过浏览 NameNode 的 web 接口分辨哪个 NameNode 是 Active 的。- 在页面尾，每个 node 报告它的 HA 状态。

一旦定位了 Active NameNode ，你可以在那个节点上造成一个故障。例如，你可以用 kill -9 <pid of NN> 模仿一次 JVM 崩溃。或者，你可以关闭这台机器或者拔下它的网卡来模仿一次不同类型的中断。在触发了你想测试的中断之后，另一个 NameNode 应该可以在几秒后自动转变为 Active 状态。故障检测和触发一次故障转移所需的时间依靠配置 ha.zookeeper.session-timeout.ms 来实现，默认是5秒。

如果检测不成功，你可能丢掉了配置，检查 zkfc 和 NameNode 进程的日志文件以进行进一步的问题检测。

## 8、Automatic Failover FAQ

(1)我启动 ZKFC 和 NameNode 守护进程的顺序重要么？

	不重要，在任何给定的节点上，你可以任意顺序启动 ZKFC 和 NameNode 进程。

(2)我应该在此增加什么样的监控？

	你应该在每一台运行 NameNode 的机器上增加监控以确保 ZKFC 保持运行。在某些类型的
	Zookeeper 失效时，例如，ZKFC 意料之外的结束，应该被重新启动以确保，系统准备自动故障转移。

	除此之外，你应该监控 Zookeeper 集群中的每一个 Server。如果 Zookeeper 宕机，
	自动故障转移将不起作用。

(3)如果Zookeeper宕机会怎样？

	如果 Zookeeper 集群宕机，没有自动故障转移将会被触发。但是，HDFS 将继续没有任何影响的运行。
	当 Zookeeper 被重新启动，HDFS 将重新连接，不会出现问题。

(4)我可以指定两个NameNode中的一个作为主要的NameNode么？

	当然不可以。目前，这是不支持的。先启动的 NameNode 将会先变成 Active
	 状态。你可以特定的顺序，先启动你希望成为 Active 的节点，来完成这个目的。

(5)自动故障转移被配置时，如何发起一次手工故障转移？

	即使自动故障转移被卑职，你也可以用 hdfs haadmin
	 发起一次手工故障转移。这个命令将执行一次协调的故障转移。

## 9、HDFS Upgrade/Finalization/Rollback with HA Enabled

当在 HDFS 的版本间移动时，有时，新版本的软件可以被简单的安装，集群被重新启动。然而，有时，HDFS 版本的升级需要改动磁盘上的数据。在这种情况下，在安装了新版本的软件之后，你必须用 HDFS Upgrade/Finalize/Rollback 工具。since the on-disk metadata that the NN relies upon is by definition distributed, both on the two HA NNs in the pair, and on the JournalNodes in the case that QJM is being used for the shared edits storage。文档的本部分描述了在一个 HA 的集群中用 HDFS Upgrade/Finalize/Rollback 工具实现这个过程。

升级一个集群，管理员必须做下面这些：

- 1.正常关闭所有的 NameNode，安装新版本的软件。

- 2.启动所有的 JNs。注意，在执行升级、回滚和finalization操作时，所有的 JNs 处于运行状态是至关重要的。如果 JNs 中的任何一个进程在执行升级、回滚和finalization操作时宕掉，操作将失败。

- 3.用 -upgrade 启动 NameNode。

- 4.启动时，这个 NameNode 将不会像在 HA 设置时那样进入 Standby 状态。这个 NameNode 会立即进入 Active 状态，执行本地存储目录的升级，同时执行共享 edit log 的升级。

- 5.在这时，HA 中的另一个 NameNode 将不会与已经升级的 NameNode 保持同步。为了将其保持到同步，再次设置一个高可用的集群，你应该用 -bootstrapStandby  命令重新引导这个 NameNode 。启动第二个 NameNode 时还用 -upgrade 是错误的。

注意：如果任何时候你想在 finalizing or rolling back the upgrade 前，重新启动 NameNode，你应该正常的启动 NameNode，不要加任何特殊的启动标识。

- To query status of upgrade，操作者在至少一个 NameNode 运行时，执行 `hdfs dfsadmin -upgrade query` 命令。这个命令将会返回每个 NameNode 的更新进度是否完成。

- To finalize an HA upgrade，操作者需要在两个 NameNode 都运行或者其中一个是 Active 状态下，运行 hdfs dfsadmin -finalizeUpgrade 命令。这个时候，Active NameNode 将会结束共享日志，NameNode 的所有包含先前文件系统状态的本地目录将会删除它们的本地状态。

- To perform a rollback of an upgrade，首先，两个 NameNode 应该关闭。操作者应该在发起 upgrade 过程的 NameNode 上运行回滚命令，这将在本地目录和共享日志（ NFS 或者 JNs ）执行回滚。之后，NameNode应该被启动，操作者在另一个 NameNode 运行 -bootstrapStandby ，将两个 NameNode 用回滚之后的文件系统状态同步。

参考来源：[HDFS High Availability Using the Quorum Journal Manager](https://blog.csdn.net/xichenguan/article/details/38516361)