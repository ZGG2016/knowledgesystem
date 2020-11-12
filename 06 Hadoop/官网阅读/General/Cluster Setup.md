# Hadoop Cluster Setup

[TOC]

## 1、Purpose

<font color="grey">This document describes how to install and configure Hadoop clusters ranging from a few nodes to extremely large clusters with thousands of nodes. To play with Hadoop, you may first want to install it on a single machine (see [Single Node Setup](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html)).</font>

<font color="grey">This document does not cover advanced topics such as [Security](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SecureMode.html) or High Availability.</font>

本文档介绍如何安装配置hadoop集群，但不涉及安全和高可用相关的高阶内容。

## 2、Prerequisites

- Install Java. See the [Hadoop Wiki](https://cwiki.apache.org/confluence/display/HADOOP2/HadoopJavaVersions) for known good versions.
- Download a stable version of Hadoop from Apache mirrors.

## 3、Installation

<font color="grey">Installing a Hadoop cluster typically involves unpacking the software on all the machines in the cluster or installing it via a packaging system as appropriate for your operating system. It is important to divide up the hardware into functions.</font>

<font color="grey">Typically one machine in the cluster is designated as the NameNode and another machine as the ResourceManager, exclusively. These are the masters. Other services (such as Web App Proxy Server and MapReduce Job History server) are usually run either on dedicated hardware or on shared infrastructure, depending upon the load.</font>

<font color="grey">The rest of the machines in the cluster act as both DataNode and NodeManager. These are the workers.</font>

将硬件划分为不同的功能是很重要的。

通常，**集群中的一台机器被指定为 NameNode ，另一台机器被指定为 ResourceManager**。这些是 masters 。**其他服务(如 Web App Proxy Server 和 MapReduce Job History Server)通常运行在专用硬件或共享基础设施上，具体取决于负载**。

**集群中的其他机器同时充当 DataNode 和 NodeManager**。这些是 workers。

## 4、Configuring Hadoop in Non-Secure Mode

<font color="grey">Hadoop’s Java configuration is driven by two types of important configuration files:</font>

<font color="grey">Read-only default configuration - core-default.xml, hdfs-default.xml, yarn-default.xml and mapred-default.xml.</font>

<font color="grey">Site-specific configuration - etc/hadoop/core-site.xml, etc/hadoop/hdfs-site.xml, etc/hadoop/yarn-site.xml and etc/hadoop/mapred-site.xml.</font>

<font color="grey">Additionally, you can control the Hadoop scripts found in the bin/ directory of the distribution, by setting site-specific values via the etc/hadoop/hadoop-env.sh and etc/hadoop/yarn-env.sh.</font>

Hadoop 的 Java 配置是由如下两类文件驱动的：

- 仅读的默认配置文件：`core-default.xml, hdfs-default.xml, yarn-default.xml and mapred-default.xml`

- 特定的配置文件：`etc/hadoop/core-site.xml, etc/hadoop/hdfs-site.xml, etc/hadoop/yarn-site.xml and etc/hadoop/mapred-site.xml.`

还可以**通过设置 `etc/hadoop/hadoop-env.sh` 和`etc/hadoop/yarn-env.sh` 中的特定值，来控制`bin/` 目录下的 Hadoop 脚本**。

<font color="grey">To configure the Hadoop cluster you will need to configure the environment in which the Hadoop daemons execute as well as the configuration parameters for the Hadoop daemons.</font>

<font color="grey">HDFS daemons are NameNode, SecondaryNameNode, and DataNode. YARN daemons are ResourceManager, NodeManager, and WebAppProxy. If MapReduce is to be used, then the MapReduce Job History Server will also be running. For large installations, these are generally running on separate hosts.</font>

要配置 Hadoop 集群，需要配置执行 Hadoop 守护进程的环境以及配置参数。

- **HDFS 守护进程是 NameNode、SecondaryNameNode 和 DataNode。**

- **YARN 守护进程是 ResourceManager、NodeManager 和 WebAppProxy。**

- **如果要使用 MapReduce ，那么 MapReduce Job History Server 也将运行。**

对于大型集群安装，它们通常运行在不同的主机上。

### 4.1、Configuring Environment of Hadoop Daemons

<font color="grey">Administrators should use the etc/hadoop/hadoop-env.sh and optionally the etc/hadoop/mapred-env.sh and etc/hadoop/yarn-env.sh scripts to do site-specific customization of the Hadoop daemons’ process environment.</font>

<font color="grey">At the very least, you must specify the JAVA_HOME so that it is correctly defined on each remote node.</font>

<font color="grey">Administrators can configure individual daemons using the configuration options shown below in the table:</font>

管理员应该通过设置 `etc/hadoop/hadoop-env.sh`，和可选的 `etc/hadoop/mapred-env.sh`、`etc/hadoop/yarn-env.sh ` 脚本来对 Hadoop 守护进程环境进行个性化设置。

至少，你需要在每个远程结点上指定 `JAVA_HOME` 。

管理员使用下表中的选项来配置独立进程：


Daemon | Environment Variable
---|:---
NameNode | HDFS_NAMENODE_OPTS
DataNode | HDFS_DATANODE_OPTS
Secondary NameNode | HDFS_SECONDARYNAMENODE_OPTS
ResourceManager | YARN_RESOURCEMANAGER_OPTS
NodeManager | YARN_NODEMANAGER_OPTS
WebAppProxy | YARN_PROXYSERVER_OPTS
Map Reduce Job History Server | MAPRED_HISTORYSERVER_OPTS

<font color="grey">For example, To configure Namenode to use parallelGC and a 4GB Java Heap, the following statement should be added in hadoop-env.sh :</font>

例如，在 `hadoop-env.sh` 中，配置 Namenode 使用 parallelGC 和 4GB 的 Java 堆内存：

	export HDFS_NAMENODE_OPTS="-XX:+UseParallelGC -Xmx4g"

See `etc/hadoop/hadoop-env.sh` for other examples.

<font color="grey">Other useful configuration parameters that you can customize include:</font>

<font color="grey">HADOOP_PID_DIR - The directory where the daemons’ process id files are stored.</font>

<font color="grey">HADOOP_LOG_DIR - The directory where the daemons’ log files are stored. Log files are automatically created if they don’t exist.</font>

<font color="grey">HADOOP_HEAPSIZE_MAX - The maximum amount of memory to use for the Java heapsize. Units supported by the JVM are also supported here. If no unit is present, it will be assumed the number is in megabytes. By default, Hadoop will let the JVM determine how much to use. This value can be overriden on a per-daemon basis using the appropriate `_OPTS` variable listed above. For example, setting HADOOP_HEAPSIZE_MAX=1g and HADOOP_NAMENODE_OPTS="-Xmx5g" will configure the NameNode with 5GB heap.</font>

你可以个性化的其他有用配置项有：

- `HADOOP_PID_DIR`: **存储守护进程的进程id文件的目录。**

- `HADOOP_LOG_DIR`: **存储守护进程的进程日志文件的目录**。如果不存在，会自动创建。

- `HADOOP_HEAPSIZE_MAX`: **可以使用的最大堆内存量**。

	这里支持 JVM 支持的单位。如果没有设置单位，将假定单位是 MB 。

	默认情况下，Hadoop 将让 JVM 决定使用多少内存。

	可以使用上面列出的 `_OPTS` 变量在每个守护进程上重写这个值。例如，设置 `HADOOP_HEAPSIZE_MAX=1g` 和 `HADOOP_NAMENODE_OPTS="-Xmx5g"` 将配置NameNode为5GB堆。

	【Daemons will prefer any Xmx setting in their respective `_OPT` variable】

大多数情况下，你可以指定 `HADOOP_PID_DIR` 和 `HADOOP_LOG_DIR` ，因为这两个设置仅能被用户设置。否则就有 symlink 攻击的可能。

<font color="grey">In most cases, you should specify the HADOOP_PID_DIR and HADOOP_LOG_DIR directories such that they can only be written to by the users that are going to run the hadoop daemons. Otherwise there is the potential for a symlink attack.</font>

<font color="grey">It is also traditional to configure HADOOP_HOME in the system-wide shell environment configuration. For example, a simple script inside /etc/profile.d:</font>

也需要在系统层面配置 `HADOOP_HOME` 变量，例如，`/etc/profile.d` 下的一个简单脚本：

	HADOOP_HOME=/path/to/hadoop
	export HADOOP_HOME

### 4.2、Configuring the Hadoop Daemons

<font color="grey">This section deals with important parameters to be specified in the given configuration files:</font>

#### 4.2.1、etc/hadoop/core-site.xml

Parameter | Value | Notes
---|:---|:---
fs.defaultFS | NameNode URI | hdfs://host:port/
io.file.buffer.size | 131072 | Size of read/write buffer used in SequenceFiles.

#### 4.2.2、etc/hadoop/hdfs-site.xml

对 NameNode 的配置:

Parameter | Value | Notes
---|:---|:---
dfs.namenode.name.dir | Path on the local filesystem where the NameNode stores the namespace and transactions logs persistently.【NameNode持久存储命名空间和事务日志的本地文件系统上的路径】 | If this is a comma-delimited list of directories then the name table is replicated in all of the directories, for redundancy.【如果这是一个以逗号分隔的目录列表，那么为了冗余，名称表将复制到所有目录中】
dfs.hosts / dfs.hosts.exclude | List of permitted/excluded DataNodes.【允许或排除在外的DataNodes列表】 | If necessary, use these files to control the list of allowable datanodes.【如果需要，使用这些文件控制可用的DataNodes列表】
dfs.blocksize | 268435456 | HDFS blocksize of 256MB for large file-systems.【对大型文件系统，块大小为256MB】
dfs.namenode.handler.count | 100 | More NameNode server threads to handle RPCs from large number of DataNodes.【需要更多NameNode服务器线程处理来自大量DataNodes的RPCs请求。】

对 DataNode 的配置:

Parameter | Value | Notes
---|:---|:---
dfs.datanode.data.dir | Comma separated list of paths on the local filesystem of a DataNode where it should store its blocks.【在本地文件系统存储数据块的DataNode的逗号分隔的列表】 | If this is a comma-delimited list of directories, then data will be stored in all named directories, typically on different devices.【如果这是一个以逗号分隔的目录列表，那么数据将被存储在所有命名了的目录，通常是在不同的设备上】

#### 4.2.3、etc/hadoop/yarn-site.xml

对 ResourceManager 、 NodeManager 的配置:

Parameter | Value | Notes
---|:---|:---
yarn.acl.enable | true / false | Enable ACLs? Defaults to false.【是否启用 ACLs，默认不启用】
yarn.admin.acl | Admin ACL | ACL to set admins on the cluster. ACLs are of for comma-separated-usersspacecomma-separated-groups. Defaults to special value of * which means anyone. Special value of just space means no one has access.【ACL用于在集群上设置管理员。...。默认值为*，表示任何人。为空意味着没有人可以访问。】
yarn.log-aggregation-enable | false | Configuration to enable or disable log aggregation【日志是否聚合】

对 ResourceManager 的配置:

Parameter | Value | Notes
---|:---|:---
yarn.resourcemanager.address |ResourceManager host:port for clients to submit jobs.【客户端提交job的地址】 | host:port If set, overrides the hostname set in yarn.resourcemanager.hostname.
yarn.resourcemanager.scheduler.address |ResourceManager host:port for ApplicationMasters to talk to Scheduler to obtain resources.【ApplicationMasters向Scheduler申请资源的地址】 |host:port If set, overrides the hostname set in yarn.resourcemanager.hostname.
yarn.resourcemanager.resource-tracker.address |ResourceManager host:port for NodeManagers.【NodeManagers地址】 |host:port If set, overrides the hostname set in yarn.resourcemanager.hostname.
yarn.resourcemanager.admin.address |ResourceManager host:port for administrative commands. |host:port If set, overrides the hostname set in yarn.resourcemanager.hostname.
yarn.resourcemanager.webapp.address |ResourceManager web-ui host:port. |host:port If set, overrides the hostname set in yarn.resourcemanager.hostname.
yarn.resourcemanager.hostname |ResourceManager host.【ResourceManager主机名】 |host Single hostname that can be set in place of setting all yarn.resourcemanager*address resources. Results in default ports for ResourceManager components.【通过设置这个，可以替代其他所有`yarn.resourcemanager*address`地址】
yarn.resourcemanager.scheduler.class |ResourceManager Scheduler class.【调度器class】 | CapacityScheduler (recommended), FairScheduler (also recommended), or FifoScheduler. Use a fully qualified class name, e.g., org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler.
yarn.scheduler.minimum-allocation-mb | Minimum limit of memory to allocate to each container request at the Resource Manager.【分配给container的最小内存】 |In MBs
yarn.scheduler.maximum-allocation-mb | Maximum limit of memory to allocate to each container request at the Resource Manager. 【分配给container的最大内存】|In MBs
yarn.resourcemanager.nodes.include-path / yarn.resourcemanager.nodes.exclude-path |List of permitted/excluded NodeManagers.【包含或排除的NodeManagers列表】 |If necessary, use these files to control the list of allowable NodeManagers.

对 NodeManager 的配置:

Parameter | Value | Notes
---|:---|:---
yarn.nodemanager.resource.memory-mb | Resource i.e. available physical memory, in MB, for given NodeManager【资源，如，对给定的NodeManager，可用的物理内存】 | Defines total available resources on the NodeManager to be made available to running containers【定义NodeManager上可供运行的containers使用的全部可用资源】
yarn.nodemanager.vmem-pmem-ratio | Maximum ratio by which virtual memory usage of tasks may exceed physical memory【任务的虚拟内存用量可能会超过物理内存的最大比例】 | The virtual memory usage of each task may exceed its physical memory limit by this ratio. The total amount of virtual memory used by tasks on the NodeManager may exceed its physical memory usage by this ratio.【每个任务的虚拟内存使用可能超出其物理内存限制的比例。NodeManager上的任务所使用的虚拟内存总量可能超过其物理内存使用量的这个比例】
yarn.nodemanager.local-dirs | Comma-separated list of paths on the local filesystem where intermediate data is written.【本地文件系统上，中间结果数据写入的目录列表，逗号分隔】 | Multiple paths help spread disk i/o.【多个路径有助于扩展磁盘i/o。】
yarn.nodemanager.log-dirs | Comma-separated list of paths on the local filesystem where logs are written. 【本地文件系统上，日志数据写入的目录列表，逗号分隔】| Multiple paths help spread disk i/o.【多个路径有助于扩展磁盘i/o。】
yarn.nodemanager.log.retain-seconds | 10800 | Default time (in seconds) to retain log files on the NodeManager Only applicable if log-aggregation is disabled.【保存NodeManager上的日志文件的默认时间(秒)，仅适用于禁用日志聚合的情况。】
yarn.nodemanager.remote-app-log-dir | /logs | HDFS directory where the application logs are moved on application completion. Need to set appropriate permissions. Only applicable if log-aggregation is enabled.【在应用程序完成时，移动应用程序日志的HDFS目录。需要设置适当的权限。仅在启用日志聚合时使用。】
yarn.nodemanager.remote-app-log-dir-suffix | logs | Suffix appended to the remote log dir. Logs will be aggregated to ${yarn.nodemanager.remote-app-log-dir}/${user}/${thisParam} Only applicable if log-aggregation is enabled.【远程日志目录的后缀，日志将被聚合到...。仅在启用日志聚合时使用】
yarn.nodemanager.aux-services | mapreduce_shuffle | Shuffle service that needs to be set for Map Reduce applications.【需要为 Map Reduce applications 设置的 Shuffle 服务】
yarn.nodemanager.env-whitelist | Environment properties to be inherited by containers from NodeManagers 【NodeManagers中的containers的内置的环境属性】| For mapreduce application in addition to the default values HADOOP_MAPRED_HOME should to be added. Property value should JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME


对 History Server 的配置(Needs to be moved elsewhere):

Parameter | Value | Notes
---|:---|:---
yarn.log-aggregation.retain-seconds | -1 | How long to keep aggregation logs before deleting them. -1 disables. Be careful, set this too small and you will spam the name node.【在删除之前，多久聚合一次日志。-1表示不聚合。设置过小，会向Namenode发送垃圾信息】
yarn.log-aggregation.retain-check-interval-seconds | -1 | Time between checks for aggregated log retention. If set to 0 or a negative value then the value is computed as one-tenth of the aggregated log retention time. Be careful, set this too small and you will spam the name node.【检查聚合日志保存的间隔时间。如果设置为0或负值，则该值将计算为聚合日志保存时间的十分之一。小心，如果设置得太小，会向Namenode发送垃圾信息。】

#### 4.2.4、etc/hadoop/mapred-site.xml

对 MapReduce Applications 的配置:

Parameter | Value | Notes
---|:---|:---
mapreduce.framework.name | yarn | Execution framework set to Hadoop YARN.
mapreduce.map.memory.mb | 1536 | Larger resource limit for maps.【maps使用的最大资源量】
mapreduce.map.java.opts | -Xmx1024M | Larger heap-size for child jvms of maps.【maps使用的最大的堆内存】
mapreduce.reduce.memory.mb | 3072 | Larger resource limit for reduces.【reduces使用的最大资源量】
mapreduce.reduce.java.opts | -Xmx2560M | Larger heap-size for child jvms of reduces.【reduces使用的最大的堆内存】
mapreduce.task.io.sort.mb | 512 | Higher memory-limit while sorting data for efficiency.【为了高效，排序数据时，需要更高的内存量】
mapreduce.task.io.sort.factor | 100 | More streams merged at once while sorting files.【当排序文件时，更多的流需要合并】
mapreduce.reduce.shuffle.parallelcopies | 50 | Higher number of parallel copies run by reduces to fetch outputs from very large number of maps.【reduces运行更多的并行副本，可以从大量maps中获取输出】

对 MapReduce JobHistory Server 的配置:

Parameter | Value | Notes
---|:---|:---
mapreduce.jobhistory.address | MapReduce JobHistory Server host:port | Default port is 10020.
mapreduce.jobhistory.webapp.address | MapReduce JobHistory Server Web UI host:port | 	Default port is 19888.
mapreduce.jobhistory.intermediate-done-dir | /mr-history/tmp | Directory where history files are written by MapReduce jobs.
mapreduce.jobhistory.done-dir | /mr-history/done | Directory where history files are managed by the MR JobHistory Server.

## 5、Monitoring Health of NodeManagers

<font color="grey">Hadoop provides a mechanism by which administrators can configure the NodeManager to run an administrator supplied script periodically to determine if a node is healthy or not.</font>

<font color="grey">Administrators can determine if the node is in a healthy state by performing any checks of their choice in the script. If the script detects the node to be in an unhealthy state, it must print a line to standard output beginning with the string ERROR. The NodeManager spawns the script periodically and checks its output. If the script’s output contains the string ERROR, as described above, the node’s status is reported as unhealthy and the node is black-listed by the ResourceManager. No further tasks will be assigned to this node. However, the NodeManager continues to run the script, so that if the node becomes healthy again, it will be removed from the blacklisted nodes on the ResourceManager automatically. The node’s health along with the output of the script, if it is unhealthy, is available to the administrator in the ResourceManager web interface. The time since the node was healthy is also displayed on the web interface.</font>

Hadoop 提供了一种机制，**管理员可以通过该机制配置 NodeManager，以周期性地运行管理员的脚本，以确定节点是否健康**。

管理员可以通过在脚本中执行检查来确定节点是否处于健康状态。如果脚本检测到节点处于不健康状态，它必须打印以字符串 `ERROR` 开始的行到标准输出。

**NodeManager 定期生成脚本并检查其输出。如果脚本的输出包含字符串 `ERROR` ，则节点的状态被报告为不健康，那么该节点就被 ResourceManager 列入黑名单。将不会向此节点分配任何其他任务。**

但是，NodeManager 继续运行脚本，因为**如果节点恢复正常，它将自动从 ResourceManager 上的黑名单中删除**。如果节点不健康，管理员可以在 ResourceManager web 界面中查看脚本输出中的节点健康状况。

web 界面上还显示了节点正常运行以来的时间。

<font color="grey">The following parameters can be used to control the node health monitoring script in etc/hadoop/yarn-site.xml.</font>

可以在 `etc/hadoop/yarn-site.xml` 中，配置如下参数控制节点健康状态。

Parameter | Value | Notes
---|:---|:---
yarn.nodemanager.health-checker.script.path | Node health script | Script to check for node’s health status.
yarn.nodemanager.health-checker.script.opts | Node health script options | Options for script to check for node’s health status.
yarn.nodemanager.health-checker.interval-ms | Node health script interval | Time interval for running health script.
yarn.nodemanager.health-checker.script.timeout-ms | Node health script timeout interval | Timeout for health script execution.

如果只有部分本地磁盘坏了，健康检查器脚本不会给出 `ERROR`。NodeManager 有能力定期检查本地磁盘的运行状况(特别是检查 nodemanager-local-dirs 和 nodemanager-log-dirs)，

并**在达到属性 `yarn.nodemanager.disk-health-checker.min-healthy-disks` 设置的坏目录数量的阈值之后，整个节点被标记为不健康，此信息也被发送到资源管理器**。启动磁盘被攻击，或者在健康检查器脚本标识的启动磁盘中的故障。

<font color="grey">The health checker script is not supposed to give ERROR if only some of the local disks become bad. NodeManager has the ability to periodically check the health of the local disks (specifically checks nodemanager-local-dirs and nodemanager-log-dirs) and after reaching the threshold of number of bad directories based on the value set for the config property yarn.nodemanager.disk-health-checker.min-healthy-disks, the whole node is marked unhealthy and this info is sent to resource manager also. The boot disk is either raided or a failure in the boot disk is identified by the health checker script.</font>

## 6、Slaves File

<font color="grey">List all worker hostnames or IP addresses in your etc/hadoop/workers file, one per line. Helper scripts (described below) will use the etc/hadoop/workers file to run commands on many hosts at once. It is not used for any of the Java-based Hadoop configuration. In order to use this functionality, ssh trusts (via either passphraseless ssh or some other means, such as Kerberos) must be established for the accounts used to run Hadoop.</font>

**在 `etc/hadoop/workers` 文件中列出所有 worker 主机名或 IP 地址，每行一个。**

帮助脚本(下面将描述)将使用 `etc/hadoop/workers` 文件在多个主机上运行一次命令。它不用于任何基于 java 的 Hadoop 配置。

为了使用此功能，必须为用于运行 Hadoop 的帐户建立ssh信任(通过无密码的 ssh 或其他方法，如 Kerberos)。

## 7、Hadoop Rack Awareness

<font color="grey">Many Hadoop components are rack-aware and take advantage of the network topology for performance and safety. Hadoop daemons obtain the rack information of the workers in the cluster by invoking an administrator configured module. See the [Rack Awareness documentation](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/RackAwareness.html) for more specific information.
It is highly recommended configuring rack awareness prior to starting HDFS.</font>

许多 Hadoop 组件都是支持机架感知的，并利用网络拓扑来提高性能和安全性。

Hadoop 守护进程通过调用管理员配置的模块来获取集群中 workers 的机架信息。有关更具体的信息，请参阅Rack感知文档。

**强烈建议在启动 HDFS 之前配置机架感知。**

## 8、Logging

<font color="grey">Hadoop uses the Apache log4j via the Apache Commons Logging framework for logging. Edit the etc/hadoop/log4j.properties file to customize the Hadoop daemons’ logging configuration (log-formats and so on).</font>

Hadoop 通过 Apache Commons 日志框架使用 Apache log4j 进行日志记录。

**编辑 `etc/hadoop/log4j.properties` 文件来定制 Hadoop 守护进程的日志配置(日志格式等)**。

## 9、Operating the Hadoop Cluster

**完成所有必要的配置之后，将文件分发到所有机器上的 `HADOOP_CONF_DIR` 目录**。这应该是所有机器上的相同目录。

通常，**建议 HDFS 和 YARN 作为单独的用户运行**。

在大多数安装中，HDFS 进程以 'HDFS' 的形式执行。YARN 通常使用 'yarn' 账户。

<font color="grey">Once all the necessary configuration is complete, distribute the files to the HADOOP_CONF_DIR directory on all the machines. This should be the same directory on all machines.</font>

<font color="grey">In general, it is recommended that HDFS and YARN run as separate users. In the majority of installations, HDFS processes execute as ‘hdfs’. YARN is typically using the ‘yarn’ account.</font>

### 9.1、Hadoop Startup

<font color="grey">To start a Hadoop cluster you will need to start both the HDFS and YARN cluster.</font>

<font color="grey">The first time you bring up HDFS, it must be formatted. Format a new distributed filesystem as hdfs:</font>

启动 hadoop 集群，需要启动 HDFS 和 YARN 集群。

第一次启动 HDFS，需要先格式化：

	[hdfs]$ $HADOOP_HOME/bin/hdfs namenode -format <cluster_name>

<font color="grey">Start the HDFS NameNode with the following command on the designated node as hdfs:</font>

在指定为 hdfs 的节点上，启动 HDFS NameNode：

	[hdfs]$ $HADOOP_HOME/bin/hdfs --daemon start namenode

<font color="grey">Start a HDFS DataNode with the following command on each designated node as hdfs:</font>

在指定为 hdfs 的节点上，启动 HDFS DataNode：

	[hdfs]$ $HADOOP_HOME/bin/hdfs --daemon start datanode

<font color="grey">If `etc/hadoop/workers` and ssh trusted access is configured (see [Single Node Setup](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html)), all of the HDFS processes can be started with a utility script. As hdfs:</font>

如果配置了 `etc/hadoop/workers` 和 SSH 信任，所有 HDFS 进程都可以使用一个脚本启动：

	[hdfs]$ $HADOOP_HOME/sbin/start-dfs.sh

<font color="grey">Start the YARN with the following command, run on the designated ResourceManager as yarn:</font>

使用以下命令启动 YARN ，并在指定的 ResourceManager 上作为 YARN 运行：

	[yarn]$ $HADOOP_HOME/bin/yarn --daemon start resourcemanager

<font color="grey">Run a script to start a NodeManager on each designated host as yarn:</font>

在每个指定的主机上，作为 yarn 启动一个 NodeManager

	[yarn]$ $HADOOP_HOME/bin/yarn --daemon start nodemanager

<font color="grey">Start a standalone WebAppProxy server. Run on the WebAppProxy server as yarn. If multiple servers are used with load balancing it should be run on each of them:</font>

启动一个独立的 WebAppProxy 服务器。作为 yarn 在 WebAppProxy 服务器上运行。如果使用多个服务器进行负载平衡，则应该在每个服务器上运行：

	[yarn]$ $HADOOP_HOME/bin/yarn --daemon start proxyserver

<font color="grey">If etc/hadoop/workers and ssh trusted access is configured (see Single Node Setup), all of the YARN processes can be started with a utility script. As yarn:</font>

如果配置了 `etc/hadoop/workers` 和 SSH 信任，所有 YARN 进程都可以使用一个脚本启动：

	[yarn]$ $HADOOP_HOME/sbin/start-yarn.sh

<font color="grey">Start the MapReduce JobHistory Server with the following command, run on the designated server as mapred:</font>

用下面的命令启动 MapReduce JobHistory Server，在指定的服务器上以 mapred 的形式运行:

	mapred]$ $HADOOP_HOME/bin/mapred --daemon start historyserver

### 9.2、Hadoop Shutdown

<font color="grey">Stop the NameNode with the following command, run on the designated NameNode as hdfs:</font>

	[hdfs]$ $HADOOP_HOME/bin/hdfs --daemon stop namenode

<font color="grey">Run a script to stop a DataNode as hdfs:</font>

	[hdfs]$ $HADOOP_HOME/bin/hdfs --daemon stop datanode

<font color="grey">If etc/hadoop/workers and ssh trusted access is configured (see Single Node Setup), all of the HDFS processes may be stopped with a utility script. As hdfs:</font>

	[hdfs]$ $HADOOP_HOME/sbin/stop-dfs.sh

<font color="grey">Stop the ResourceManager with the following command, run on the designated ResourceManager as yarn:</font>

	[yarn]$ $HADOOP_HOME/bin/yarn --daemon stop resourcemanager

<font color="grey">Run a script to stop a NodeManager on a worker as yarn:</font>

	[yarn]$ $HADOOP_HOME/bin/yarn --daemon stop nodemanager

<font color="grey">If etc/hadoop/workers and ssh trusted access is configured (see Single Node Setup), all of the YARN processes can be stopped with a utility script. As yarn:</font>

	[yarn]$ $HADOOP_HOME/sbin/stop-yarn.sh

<font color="grey">Stop the WebAppProxy server. Run on the WebAppProxy server as yarn. If multiple servers are used with load balancing it should be run on each of them:</font>

	[yarn]$ $HADOOP_HOME/bin/yarn stop proxyserver

<font color="grey">Stop the MapReduce JobHistory Server with the following command, run on the designated server as mapred:</font>

	[mapred]$ $HADOOP_HOME/bin/mapred --daemon stop historyserver

## 10、Web Interfaces

Once the Hadoop cluster is up and running check the web-ui of the components as described below:

Daemon | Web Interface | Notes
---|:---|:---
NameNode | http://nn_host:port/ | Default HTTP port is 9870.
ResourceManager | http://rm_host:port/ | Default HTTP port is 8088.
MapReduce JobHistory Server | http://jhs_host:port/ | Default HTTP port is 19888.