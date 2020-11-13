# Getting Started

[TOC]

## 1、Installation and Configuration

<font color="grey">You can install a stable release of Hive by downloading a tarball, or you can download the source code and build Hive from that.</font>

可以下载 tar 包来安装 Hive 稳定版本，或者下载二进制源码，自己编译。

**Running HiveServer2 and Beeline**

### 1.1、Requirements

- Java 1.7

	Hive1.2 及更新版本要求 Java1.7 或更新版本。Hive0.14 到 1.1 要求 Java1.6，建议用户使用 Java1.8。

- Hadoop2.x(首选)，1.x(在Hive2.0.0 及更新版本不再支持)

	Hive0.13 之前的版本也支持 Hadoop0.20.x、0.23.x。

- Hive 通常用于生产的 Linux 和 Windows 环境中。Mac 是一种常用的开发环境。本文中的说明适用于 Linux 和 Ma c。在 Windows 上使用它需要稍微不同的步骤。

<font color="grey">Note:  Hive versions 1.2 onward require Java 1.7 or newer. Hive versions 0.14 to 1.1 work with Java 1.6 as well. Users are strongly advised to start moving to Java 1.8 (see HIVE-8607).</font>  

<font color="grey">Hadoop 2.x (preferred), 1.x (not supported by Hive 2.0.0 onward).</font>

<font color="grey">Hive versions up to 0.13 also supported Hadoop 0.20.x, 0.23.x.</font>

<font color="grey">Hive is commonly used in production Linux and Windows environment. Mac is a commonly used development environment. The instructions in this document are applicable to Linux and Mac. Using it on Windows would require slightly different steps.</font>

### 1.2、Installing Hive from a Stable Release

<font color="grey">Start by downloading the most recent stable release of Hive from one of the Apache download mirrors (see [Hive Releases](https://hive.apache.org/downloads.html)).</font>

<font color="grey">Next you need to unpack the tarball. This will result in the creation of a subdirectory named hive-x.y.z (where x.y.z is the release number):</font>

下载 Hive 的稳定版本，再解压，会产生子目录 `hive-x.y.z`：

	$ tar -xzvf hive-x.y.z.tar.gz

<font color="grey">Set the environment variable HIVE_HOME to point to the installation directory:</font>

配置环境变量：

	$ cd hive-x.y.z
	$ export HIVE_HOME={{pwd}}

<font color="grey">Finally, add $HIVE_HOME/bin to your PATH:</font>

	$ export PATH=$HIVE_HOME/bin:$PATH

### 1.3、Building Hive from Source

<font color="grey">The Hive GIT repository for the most recent Hive code is located here: git clone https://git-wip-us.apache.org/repos/asf/hive.git (the master branch).</font>

<font color="grey">All release versions are in branches named "branch-0.#" or "branch-1.#" or the upcoming "branch-2.#", with the exception of release 0.8.1 which is in "branch-0.8-r2". Any branches with other names are feature branches for works-in-progress. See Understanding Hive Branches for details.</font>

<font color="grey">As of 0.13, Hive is built using Apache Maven.</font>

#### 1.3.1、Compile Hive on master

<font color="grey">To build the current Hive code from the master branch:</font>

	  $ git clone https://git-wip-us.apache.org/repos/asf/hive.git
	  $ cd hive
	  $ mvn clean package -Pdist [-DskipTests -Dmaven.javadoc.skip=true]
	  $ cd packaging/target/apache-hive-{version}-SNAPSHOT-bin/apache-hive-{version}-SNAPSHOT-bin
	  $ ls
	  LICENSE
	  NOTICE
	  README.txt
	  RELEASE_NOTES.txt
	  bin/ (all the shell scripts)
	  lib/ (required jar files)
	  conf/ (configuration files)
	  examples/ (sample input and query files)
	  hcatalog / (hcatalog installation)
	  scripts / (upgrade scripts for hive-metastore)

<font color="grey">Here, {version} refers to the current Hive version.</font>

<font color="grey">If building Hive source using Maven (mvn), we will refer to the directory "/packaging/target/apache-hive-{version}-SNAPSHOT-bin/apache-hive-{version}-SNAPSHOT-bin" as <install-dir> for the rest of the page.</font>

#### 1.3.2、Compile Hive on branch-1

<font color="grey">In branch-1, Hive supports both Hadoop 1.x and 2.x.  You will need to specify which version of Hadoop to build against via a Maven profile.  To build against Hadoop 1.x use the profile hadoop-1; for Hadoop 2.x use hadoop-2.  For example to build against Hadoop 1.x, the above mvn command becomes:</font>

	$ mvn clean package -Phadoop-1,dist

#### 1.3.3、Compile Hive Prior to 0.13 on Hadoop 0.20

<font color="grey">Prior to Hive 0.13, Hive was built using Apache Ant.  To build an older version of Hive on Hadoop 0.20:</font>

	  $ svn co http://svn.apache.org/repos/asf/hive/branches/branch-{version} hive
	  $ cd hive
	  $ ant clean package
	  $ cd build/dist
	  # ls
	  LICENSE
	  NOTICE
	  README.txt
	  RELEASE_NOTES.txt
	  bin/ (all the shell scripts)
	  lib/ (required jar files)
	  conf/ (configuration files)
	  examples/ (sample input and query files)
	  hcatalog / (hcatalog installation)
	  scripts / (upgrade scripts for hive-metastore)

<font color="grey">If using Ant, we will refer to the directory "build/dist" as <install-dir>.</font>

#### 1.3.4、Compile Hive Prior to 0.13 on Hadoop 0.23

<font color="grey">To build Hive in Ant against Hadoop 0.23, 2.0.0, or other version, build with the appropriate flag; some examples below:</font>

	  $ ant clean package -Dhadoop.version=0.23.3 -Dhadoop-0.23.version=0.23.3 -Dhadoop.mr.rev=23
	  $ ant clean package -Dhadoop.version=2.0.0-alpha -Dhadoop-0.23.version=2.0.0-alpha -Dhadoop.mr.rev=23

### 1.4、Running Hive

<font color="grey">Hive uses Hadoop, so:</font>

Hive 需要使用 Hadoop ，所以：

- you must have Hadoop in your path OR
- export HADOOP_HOME=<hadoop-install-dir>

<font color="grey">In addition, you must use below HDFS commands to create /tmp and /user/hive/warehouse (aka hive.metastore.warehouse.dir) and set them chmod g+w before you can create a table in Hive.</font>

另外，还需要使用如下命令创建目录 `/tmp` 和 `/user/hive/warehouse`(即`hive.metastore.warehouse.dir`)，然后设置权限 `chmod g+w` ：

	  $ $HADOOP_HOME/bin/hadoop fs -mkdir       /tmp
	  $ $HADOOP_HOME/bin/hadoop fs -mkdir       /user/hive/warehouse
	  $ $HADOOP_HOME/bin/hadoop fs -chmod g+w   /tmp
	  $ $HADOOP_HOME/bin/hadoop fs -chmod g+w   /user/hive/warehouse

<font color="grey">You may find it useful, though it's not necessary, to set HIVE_HOME:</font>

设置 Hive 的环境变量：

	$ export HIVE_HOME=<hive-install-dir>

#### 1.4.1、Running Hive CLI

<font color="grey">To use the Hive [command line interface](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Cli) (CLI) from the shell:</font>

使用如下命令，启动 Hive 命令行：

	$ $HIVE_HOME/bin/hive

#### 1.4.2、Running HiveServer2 and Beeline

<font color="grey">Starting from Hive 2.1, we need to run the schematool command below as an initialization step. For example, we can use "derby" as db type.</font>

从 Hive2.1 开始，允许如下 `schematool` 命令，来初始化。这里使用 "derby" 作为数据库类型：

	$ $HIVE_HOME/bin/schematool -dbType <db type> -initSchema

<font color="grey">[HiveServer2](https://cwiki.apache.org/confluence/display/Hive/Setting+Up+HiveServer2) (introduced in Hive 0.11) has its own CLI called [Beeline](https://cwiki.apache.org/confluence/display/Hive/HiveServer2+Clients). HiveCLI is now deprecated in favor of Beeline, as it lacks the multi-user, security, and other capabilities of HiveServer2.  To run HiveServer2 and Beeline from shell:</font>

**HiveServer2(Hive0.11 引入)有自己的命令行界面，称为 `Beeline`** 。

HiveCLI 现在已被弃用，取而代之的是 `Beeline` ，因为它缺乏 HiveServer2 的多用户、安全性和其他功能。

从 shell 运行 HiveServer2 和 `Beeline` :

	$ $HIVE_HOME/bin/hiveserver2

	$ $HIVE_HOME/bin/beeline -u jdbc:hive2://$HS2_HOST:$HS2_PORT

<font color="grey">Beeline is started with the JDBC URL of the HiveServer2, which depends on the address and port where HiveServer2 was started.  By default, it will be (localhost:10000), so the address will look like jdbc:hive2://localhost:10000.</font>

<font color="grey">Or to start Beeline and HiveServer2 in the same process for testing purpose, for a similar user experience to HiveCLI:</font>

**Beeline 启动需要设置 HiveServer2 的 JDBC URL**，该 URL 依赖于 HiveServer2 的地址和端口。

默认情况下，它是 `(localhost:10000)`，因此地址看起来像 `jdbc:hive2://localhost:10000`。

或为了测试目的，在相同的进程中启动 Beeline 和 HiveServer2 ，以获得与 HiveCLI 类似的用户体验:

	$ $HIVE_HOME/bin/beeline -u jdbc:hive2://

#### 1.4.3、Running HCatalog

<font color="grey">To run the HCatalog server from the shell in Hive release 0.11.0 and later:</font>

从 0.11.0 版本开始，可以在 shell 中运行 `HCatalog server` :

	$ $HIVE_HOME/hcatalog/sbin/hcat_server.sh

<font color="grey">To use the HCatalog command line interface (CLI) in Hive release 0.11.0 and later:</font>

从 0.11.0 版本开始，可以使用 HCatalog 的命令行界面：

	$ $HIVE_HOME/hcatalog/bin/hcat

<font color="grey">For more information, see [HCatalog Installation from Tarball](https://cwiki.apache.org/confluence/display/Hive/HCatalog+InstallHCat) and [HCatalog CLI](https://cwiki.apache.org/confluence/display/Hive/HCatalog+InstallHCat) in the [HCatalog manual](https://cwiki.apache.org/confluence/display/Hive/HCatalog).</font>

#### 1.4.4、Running WebHCat (Templeton)

<font color="grey">To run the WebHCat server from the shell in Hive release 0.11.0 and later:</font>

从 0.11.0 版本开始，可以在 shell 中运行 `WebHCat server` :

	$ $HIVE_HOME/hcatalog/sbin/webhcat_server.sh

<font color="grey">For more information, see [WebHCat Installation](https://cwiki.apache.org/confluence/display/Hive/WebHCat+InstallWebHCat) in the [WebHCat manual](https://cwiki.apache.org/confluence/display/Hive/WebHCat).</font>

### 1.5、Configuration Management Overview

<font color="grey">Hive by default gets its configuration from <install-dir>/conf/hive-default.xml

The location of the Hive configuration directory can be changed by setting the HIVE_CONF_DIR environment variable.

Configuration variables can be changed by (re-)defining them in <install-dir>/conf/hive-site.xml

Log4j configuration is stored in <install-dir>/conf/hive-log4j.properties

Hive configuration is an overlay on top of Hadoop – it inherits the Hadoop configuration variables by default.</font>

- Hive 默认从 `<install-dir>/conf/hive-default.xml` 中获取配置。

- 可以通过设置 `HIVE_CONF_DIR` 来改变配置文件的目录。

- 配置文件中的变量可以在 `<install-dir>/conf/hive-site.xml` 中重新定义。

- Log4j 配置文件存储在 `<install-dir>/conf/hive-log4j.properties`。

- Hive 配置文件是覆盖在 Hadoop 之上的，默认继承 Hadoop 配置变量。

- Hive 配置可以通过以下方式操作:

	- 编辑 `hive-site.xml` ，并在其中定义任何想要的变量(包括 Hadoop 变量)

	- 使用 set 命令(请参阅下一节)

	- 调用 Hive 命令(已废弃)，Beeline 或 HiveServer2 使用语法:

		- $ bin/hive --hiveconf x1=y1 --hiveconf x2=y2 //设置变量x1和x2分别为y1和y2

		- $ bin/hiveserver2 --hiveconf x1=y1 --hiveconf x2=y2 //将服务端变量x1和x2分别设置为y1和y2

		- bin/beeline --hiveconf x1=y1 --hiveconf x2=y2 //将客户端变量x1和x2分别设置为y1和y2。

- 将 `HIVE_OPTS` 环境变量设置为 `--hiveconf x1=y1 --hiveconf x2=y2`，其作用与上面相同。

<font color="grey">Hive configuration can be manipulated by:

Editing hive-site.xml and defining any desired variables (including Hadoop variables) in it

Using the set command (see next section)

Invoking Hive (deprecated), Beeline or HiveServer2 using the syntax:

$ bin/hive --hiveconf x1=y1 --hiveconf x2=y2  //this sets the variables x1 and x2 to y1 and y2 respectively

$ bin/hiveserver2 --hiveconf x1=y1 --hiveconf x2=y2  //this sets server-side variables x1 and x2 to y1 and y2 respectively

$ bin/beeline --hiveconf x1=y1 --hiveconf x2=y2  //this sets client-side variables x1 and x2 to y1 and y2 respectively.

Setting the HIVE_OPTS environment variable to "--hiveconf x1=y1 --hiveconf x2=y2" which does the same as above.</font>

### 1.6、Runtime Configuration

<font color="grey">Hive queries are executed using map-reduce queries and, therefore, the behavior of such queries can be controlled by the Hadoop configuration variables.
The HiveCLI (deprecated) and Beeline command 'SET' can be used to set any Hadoop (or Hive) configuration variable. For example:</font>

因为 Hive 查询底层执行的是 MapReduce ，所以可以通过控制 Hadoop 的配置文件中的变量，来控制 Hive 查询的行为。

使用  HiveCLI(已废弃)和 Beeline  命令 `SET` 来设置 Hadoop (or Hive) 的变量：

    beeline> SET mapred.job.tracker=myhost.mycompany.com:50030;
    beeline> SET -v;

后者显示所有当前设置。没有 `-v` 选项，只显示与基本 Hadoop 配置不同的变量。

<font color="grey">The latter shows all the current settings. Without the -v option only the variables that differ from the base Hadoop configuration are displayed.</font>

### 1.7、Hive, Map-Reduce and Local-Mode

<font color="grey">Hive compiler generates map-reduce jobs for most queries. These jobs are then submitted to the Map-Reduce cluster indicated by the variable:</font>

对大多数查询来说，Hive 编译器会生成 map-reduce jobs。然后这些 jobs 被提交到变量所指示的 Map-Reduce 集群：

	mapred.job.tracker

虽然这个变量通常指向一个具有多节点的 Map-Reduce 集群，但 Hadoop 也提供了一个极好的选项，可以在用户的本地工作站运行 map-reduce jobs。

这对于在小数据集上运行查询非常有用，在这种情况下，本地模式执行通常比在大型集群快得多。

数据直接从 HDFS 透明地访问。相反，本地模式只运行一个 reducer ，处理较大的数据集时会非常慢，

<font color="grey">While this usually points to a map-reduce cluster with multiple nodes, Hadoop also offers a nifty option to run map-reduce jobs locally on the user's workstation. This can be very useful to run queries over small data sets – in such cases local mode execution is usually significantly faster than submitting jobs to a large cluster. Data is accessed transparently from HDFS. Conversely, local mode only runs with one reducer and can be very slow processing larger data sets.</font>

<font color="grey">Starting with release 0.7, Hive fully supports local mode execution. To enable this, the user can enable the following option:</font>

从版本 0.7 开始，Hive 完全支持本地模式执行。用户需要启用下面的选项：

	hive> SET mapreduce.framework.name=local;

另外，`mapred.local.dir` 应指向本地机器的一个有效路径(如`/tmp/<username>/mapred/local`)。

否则，用户将得到一个分配本地磁盘空间的异常。

<font color="grey">In addition, mapred.local.dir should point to a path that's valid on the local machine (for example /tmp/<username>/mapred/local). (Otherwise, the user will get an exception allocating local disk space.)</font>

<font color="grey">Starting with release 0.7, Hive also supports a mode to run map-reduce jobs in local-mode automatically. The relevant options are hive.exec.mode.local.auto, hive.exec.mode.local.auto.inputbytes.max, and hive.exec.mode.local.auto.tasks.max:</font>

从版本 0.7 开始，Hive 也支持自动地在本地运行 map-reduce jobs。相关选项有 `hive.exec.mode.local.auto` 、`hive.exec.mode.local.auto.inputbytes.max` 和 `hive.exec.mode.local.auto.tasks.max`：

	hive> SET hive.exec.mode.local.auto=false;

注意，这个特征默认是不启用的。

如果启用了，且满足下面的阈值，Hive 会分析每个查询中每个 map-reduce job 的大小，然后本地运行它：

- job 的总输入大小小于`hive.exec.mode.local.auto.inputbytes.max` (默认128MB)

- map-tasks 的总数量小于`hive.exec.mode.local.auto.tasks.max`(默认4)

- reduce-tasks 的总数量等于1或0

<font color="grey">Note that this feature is disabled by default. If enabled, Hive analyzes the size of each map-reduce job in a query and may run it locally if the following thresholds are satisfied:</font>

<font color="grey">The total input size of the job is lower than:
`hive.exec.mode.local.auto.inputbytes.max` (128MB by default)</font>

<font color="grey">The total number of map-tasks is less than: `hive.exec.mode.local.auto.tasks.max` (4 by default)</font>

<font color="grey">The total number of reduce tasks required is 1 or 0.</font>

因此，对于小规模数据集上的查询，或具有多个 map-reduce jobs 的查询，这些查询的后续 job 的输入要小得多(因为前一个 job 中进行了 reduce/filtering)，job 可以在本地运行。

请注意，Hadoop 服务器节点的运行环境和运行 Hive 客户端的机器间可能存在差异(因为 jvm 版本或软件库不同)。在本地模式下运行时，这可能会导致意外的行为/错误。

还要注意，本地模式执行是在一个单独的子 jvm (Hive 客户端的)中执行的。

如果用户愿意，这个子 jvm 的最大内存量可以通过 `hive.mapred.local.mem` 来控制。默认情况下为0，在这种情况下，Hive 让 Hadoop 决定子 jvm 的默认内存限制。

<font color="grey">So for queries over small data sets, or for queries with multiple map-reduce jobs where the input to subsequent jobs is substantially smaller (because of reduction/filtering in the prior job), jobs may be run locally.</font>

<font color="grey">Note that there may be differences in the runtime environment of Hadoop server nodes and the machine running the Hive client (because of different jvm versions or different software libraries). This can cause unexpected behavior/errors while running in local mode. Also note that local mode execution is done in a separate, child jvm (of the Hive client). If the user so wishes, the maximum amount of memory for this child jvm can be controlled via the option hive.mapred.local.mem. By default, it's set to zero, in which case Hive lets Hadoop determine the default memory limits of the child jvm.</font>

### 1.8、Hive Logging

<font color="grey">Hive uses log4j for logging. By default logs are not emitted to the console by the CLI. The default logging level is WARN for Hive releases prior to 0.13.0. Starting with Hive 0.13.0, the default logging level is INFO.</font>

<font color="grey">The logs are stored in the directory /tmp/<user.name>:</font>

	/tmp/<user.name>/hive.log

<font color="grey">Note: In local mode, prior to Hive 0.13.0 the log file name was ".log" instead of "hive.log". This bug was fixed in release 0.13.0 (see HIVE-5528 and HIVE-5676).
To configure a different log location, set hive.log.dir in $HIVE_HOME/conf/hive-log4j.properties. Make sure the directory has the sticky bit set (chmod 1777 <dir>).</font>

	hive.log.dir=<other_location>

<font color="grey">If the user wishes, the logs can be emitted to the console by adding the arguments shown below:</font>

	bin/hive --hiveconf hive.root.logger=INFO,console  //for HiveCLI (deprecated)
	
	bin/hiveserver2 --hiveconf hive.root.logger=INFO,console

<font color="grey">Alternatively, the user can change the logging level only by using:</font>

	bin/hive --hiveconf hive.root.logger=INFO,DRFA //for HiveCLI (deprecated)

	bin/hiveserver2 --hiveconf hive.root.logger=INFO,DRFA

<font color="grey">Another option for logging is TimeBasedRollingPolicy (applicable for Hive 1.1.0 and above, HIVE-9001) by providing DAILY option as shown below:</font>

	bin/hive --hiveconf hive.root.logger=INFO,DAILY //for HiveCLI (deprecated)

	bin/hiveserver2 --hiveconf hive.root.logger=INFO,DAILY

<font color="grey">Note that setting hive.root.logger via the 'set' command does not change logging properties since they are determined at initialization time.</font>

<font color="grey">Hive also stores query logs on a per Hive session basis in /tmp/<user.name>/, but can be configured in hive-site.xml with the hive.querylog.location property.  Starting with Hive 1.1.0, EXPLAIN EXTENDED output for queries can be logged at the INFO level by setting the hive.log.explain.output property to true.</font>

<font color="grey">Logging during Hive execution on a Hadoop cluster is controlled by Hadoop configuration. Usually Hadoop will produce one log file per map and reduce task stored on the cluster machine(s) where the task was executed. The log files can be obtained by clicking through to the Task Details page from the Hadoop JobTracker Web UI.</font>

<font color="grey">When using local mode (using mapreduce.framework.name=local), Hadoop/Hive execution logs are produced on the client machine itself. Starting with release 0.6 – Hive uses the hive-exec-log4j.properties (falling back to hive-log4j.properties only if it's missing) to determine where these logs are delivered by default. The default configuration file produces one log file per query executed in local mode and stores it under /tmp/<user.name>. The intent of providing a separate configuration file is to enable administrators to centralize execution log capture if desired (on a NFS file server for example). Execution logs are invaluable for debugging run-time errors.</font>

<font color="grey">For information about WebHCat errors and logging, see Error Codes and Responses and Log Files in the WebHCat manual.</font>

<font color="grey">Error logs are very useful to debug problems. Please send them with any bugs (of which there are many!) to hive-dev@hadoop.apache.org.</font>

<font color="grey">From Hive 2.1.0 onwards (with HIVE-13027), Hive uses Log4j2's asynchronous logger by default. Setting hive.async.log.enabled to false will disable asynchronous logging and fallback to synchronous logging. Asynchronous logging can give significant performance improvement as logging will be handled in a separate thread that uses the LMAX disruptor queue for buffering log messages. Refer to https://logging.apache.org/log4j/2.x/manual/async.html for benefits and drawbacks.</font>

#### 1.8.1、HiveServer2 Logs

#### 1.8.2、Audit Logs

#### 1.8.3、Perf Logger

## 2、DDL Operations

### 2.1、Creating Hive Tables

### 2.2、Browsing through Tables

### 2.3、Altering and Dropping Tables

### 2.4、Metadata Store

## 3、DML Operations

## 4、SQL Operations

### 4.1、Example Queries

#### 4.1.1、SELECTS and FILTERS

#### 4.1.2、GROUP BY

#### 4.1.3、JOIN

#### 4.1.4、MULTITABLE INSERT

#### 4.1.5、STREAMING

## 5、Simple Example Use Cases

### 5.1、MovieLens User Ratings

### 5.2、Apache Weblog Data