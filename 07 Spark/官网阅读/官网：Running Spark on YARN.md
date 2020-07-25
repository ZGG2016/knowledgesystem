# 官网：Running Spark on YARN

[TOC]

*Support for running on [YARN](http://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/YARN.html) (Hadoop NextGen) was added to Spark in version 0.6.0, and improved in subsequent releases.*

## 1、Security

*Security in Spark is OFF by default. This could mean you are vulnerable to attack by default. Please see [Spark Security](http://spark.apache.org/docs/latest/security.html) and the specific security sections in this doc before running Spark.*

默认情况下，Spark 的安全模式是关闭的。

## 2、Launching Spark on YARN

*Ensure that HADOOP_CONF_DIR or YARN_CONF_DIR points to the directory which contains the (client side) configuration files for the Hadoop cluster. These configs are used to write to HDFS and connect to the YARN ResourceManager. The configuration contained in this directory will be distributed to the YARN cluster so that all containers used by the application use the same configuration. If the configuration references Java system properties or environment variables not managed by YARN, they should also be set in the Spark application’s configuration (driver, executors, and the AM when running in client mode).*

对于 hadoop 集群，确保 HADOOP_CONF_DIR or YARN_CONF_DIR 指向了包含配置文件的目录，其作用就是向 HDFS 写数据、连接 YARN ResourceManager。

配置会被分发到 YARN 集群，所以该应用程序所有的 containers 使用相同的配置。

如果配置引用了 Java 系统属性或者未由 YARN 管理的环境变量，则还应在 Spark 应用程序的配置中设置 (driver, executors, and the AM when running in client mode).。

*There are two deploy modes that can be used to launch Spark applications on YARN. In cluster mode, the Spark driver runs inside an application master process which is managed by YARN on the cluster, and the client can go away after initiating the application. In client mode, the driver runs in the client process, and the application master is only used for requesting resources from YARN.*

两种部署模式：

- cluster mode： Spark driver 运行在 YARN 管理下的 application master 进程，客户端在初始化程序后离开。

- client mode： driver 运行在客户端进程，应用程序 master 仅被用来向 YARN 请求资源。

*Unlike other cluster managers supported by Spark in which the master’s address is specified in the --master parameter, in YARN mode the ResourceManager’s address is picked up from the Hadoop configuration. Thus, the --master parameter is yarn.*

与 Spark standalone 和 Mesos 不同的是，在这两种模式中，master 的地址在 --master 参数中指定，在 YARN 模式下，ResourceManager 的地址从 Hadoop 配置中选取。因此，--master 参数是 yarn。

*To launch a Spark application in cluster mode:*

集群模式下启动：

```sh
$ ./bin/spark-submit 
	--class path.to.your.Class 
	--master yarn 
	--deploy-mode cluster 
	[options] <app jar> [app options]
```
*For example:*

```sh
$ ./bin/spark-submit --class org.apache.spark.examples.SparkPi \
    --master yarn \
    --deploy-mode cluster \
    --driver-memory 4g \
    --executor-memory 2g \
    --executor-cores 1 \
    --queue thequeue \
    examples/jars/spark-examples*.jar \
    10
```
*The above starts a YARN client program which starts the default Application Master. Then SparkPi will be run as a child thread of Application Master. The client will periodically poll the Application Master for status updates and display them in the console. The client will exit once your application has finished running. Refer to the “Debugging your Application” section below for how to see driver and executor logs.*

上面就启动了一个 YARN 客户端程序，它启动了默认的 Application Master。然后 SparkPi 会作为 Application Master 的子线程运行。客户端周期地拉取 Application Master，以获取状态的更新并在控制台中显示它们。 应用程序运行完后，客户端就会退出。

*To launch a Spark application in client mode, do the same, but replace cluster with client. The following shows how you can run spark-shell in client mode:*

客户端模式下启动：

```sh
$ ./bin/spark-shell --master yarn --deploy-mode client
```

### 2.1、Adding Other JARs

*In cluster mode, the driver runs on a different machine than the client, so SparkContext.addJar won’t work out of the box with files that are local to the client. To make files on the client available to SparkContext.addJar, include them with the --jars option in the launch command.*

在集群模式下，driver 在与客户端不同的机器上运行，因此 SparkContext.addJar 将不会立即使用客户端本地的文件运行。要使客户端上的文件可用于 SparkContext.addJar，请在启动命令中使用 `--jars` 选项来包含这些文件。

```sh
$ ./bin/spark-submit --class my.main.Class \
    --master yarn \
    --deploy-mode cluster \
    --jars my-other-jar.jar,my-other-other-jar.jar \
    my-main-jar.jar \
    app_arg1 app_arg2
```

## 3、Preparations

*Running Spark on YARN requires 【a binary distribution of Spark which is built with YARN support】. Binary distributions can be downloaded from the [downloads page](https://spark.apache.org/downloads.html) of the project website. To build Spark yourself, refer to [Building Spark](http://spark.apache.org/docs/latest/building-spark.html).*


*To make Spark runtime jars accessible from YARN side, you can specify spark.yarn.archive or spark.yarn.jars. For details please refer to [Spark Properties](http://spark.apache.org/docs/latest/running-on-yarn.html#spark-properties). If neither spark.yarn.archive nor spark.yarn.jars is specified, Spark will create a zip file with all jars under $SPARK_HOME/jars and upload it to the distributed cache.*

通过指定 `spark.yarn.archive` 或者 `spark.yarn.jars` ，使得 jars 可以从 YARN 端访问。

如果既没有指定 `spark.yarn.archive` 也没有指定 `spark.yarn.jars`，Spark 将在 $SPARK_HOME/jars 目录下创建一个包含所有 jar 的 zip 文件，并将其上传到分布式缓存中。


## 4、Configuration

*Most of the configs are the same for Spark on YARN as for other deployment modes. See the [configuration page](http://spark.apache.org/docs/latest/configuration.html) for more information on those. These are configs that are specific to Spark on YARN.*

## 5、Debugging your Application

*In YARN terminology, executors and application masters run inside “containers”. YARN has two modes for handling container logs after an application has completed. If log aggregation is turned on (with the yarn.log-aggregation-enable config), container logs are copied to HDFS and deleted on the local machine. These logs can be viewed from anywhere on the cluster with the yarn logs command.*

executors 和 application masters 运行在 containers 中。 在 application 完成后，YARN 有两种处理 container 日志的模式。

如果日志聚合(`yarn.log-aggregation-enable`)启动， container 日志会被复制到 HDFS ，并删除本地机器中的。这些日志就可以使用 yarn 日志命令从集群任意位置访问。

	yarn logs -applicationId <app ID>

*will print out the contents of all log files from all containers from the given application. You can also view the container log files directly in HDFS using the HDFS shell or API. The directory where they are located can be found by looking at your YARN configs (yarn.nodemanager.remote-app-log-dir and yarn.nodemanager.remote-app-log-dir-suffix). The logs are also available on the Spark Web UI under the Executors Tab. You need to have both the Spark history server and the MapReduce history server running and configure yarn.log.server.url in yarn-site.xml properly. The log URL on the Spark history server UI will redirect you to the MapReduce history server to show the aggregated logs.*

上述命令会打印所有和给定应用程序相关的日志文件内容。也可以使用 HDFS shell or API 在 HDFS 中直接查看日志文件。

通过 `yarn.nodemanager.remote-app-log-dir` 和 `yarn.nodemanager.remote-app-log-dir-suffix`，可以找到日志文件的目录。

这些日志也可以在 Spark Web UI 的 Executors Tab 下访问。但需要 Spark history server 和 MapReduce history server 同时运行，并在 `yarn-site.xml` 里配置 `yarn.log.server.url` 属性。

*When log aggregation isn’t turned on, logs are retained locally on each machine under YARN_APP_LOGS_DIR, which is usually configured to /tmp/logs or $HADOOP_HOME/logs/userlogs depending on the Hadoop version and installation. Viewing logs for a container requires going to the host that contains them and looking in this directory. Subdirectories organize log files by application ID and container ID. The logs are also available on the Spark Web UI under the Executors Tab and doesn’t require running the MapReduce history server.*

当未启用日志聚合时，日志将保留在每台计算机上的本地 YARN_APP_LOGS_DIR 目录下，通常配置为 `/tmp/logs` 或者 `$HADOOP_HOME/logs/userlogs` ，具体取决于 Hadoop 版本和安装。

查看一个容器的日志需要到包含它们的主机的此目录中查看。子目录下的日志文件根据应用程序 ID 和容器 ID 组织。日志还可以在 Spark Web UI 的 Executors Tab 下找到，并且不需要运行 MapReduce history server。

*To review per-container launch environment, increase yarn.nodemanager.delete.debug-delay-sec to a large value (e.g. 36000), and then access the application cache through yarn.nodemanager.local-dirs on the nodes on which containers are launched. This directory contains the launch script, JARs, and all environment variables used for launching each container. This process is useful for debugging classpath problems in particular. (Note that enabling this requires admin privileges on cluster settings and a restart of all node managers. Thus, this is not applicable to hosted clusters).*

要查看每个容器的启动环境，要设置 `yarn.nodemanager.delete.debug-delay-sec` 为一个较大的值（例如 36000），然后通过节点上的 `yarn.nodemanager.local-dirs` 访问应用程序缓存，节点是容器启动的节点。

此目录包含启动脚本、JARs、和用于启动每个容器的所有的环境变量。这个过程对于调试 classpath 问题特别有用。

（请注意，启用此功能需要集群设置的管理员权限并且还需要重新启动所有的 node managers，因此这不适用于托管集群）。

*To use a custom log4j configuration for the application master or executors, here are the options:*

要为 application master 或者 executors 使用自定义的 log4j 配置，请选择以下选项:

*upload a custom log4j.properties using spark-submit, by adding it to the --files list of files to be uploaded with the application.*

- 使用 spark-submit 上传一个自定义的 log4j.properties，通过将添加到要与应用程序一起上传的文件的 –files 列表中。

*add -Dlog4j.configuration=<location of configuration file> to spark.driver.extraJavaOptions (for the driver) or spark.executor.extraJavaOptions (for executors). Note that if using a file, the file: protocol should be explicitly provided, and the file needs to exist locally on all the nodes.*

- 添加 `-Dlog4j.configuration=<location of configuration file>` 到 `spark.driver.extraJavaOptions`(for the driver) 或 `spark.executor.extraJavaOptions`(for executors)。注意：如果使用了文件，应明确提供 file: protocol。文件需要存在于本地的所有节点。

*update the $SPARK_CONF_DIR/log4j.properties file and it will be automatically uploaded along with the other configurations. Note that other 2 options has higher priority than this option if multiple options are specified.*

- 更新 `$SPARK_CONF_DIR/log4j.properties `
文件，并且它将与其他配置一起自动上传。注意：如果指定了多个选项，其他 2 个选项的优先级高于此选项。


*Note that for the first option, both executors and the application master will share the same log4j configuration, which may cause issues when they run on the same node (e.g. trying to write to the same log file).*

注意：对于第一个选项，executors 和 application master 将共享相同的 log4j 配置，当它们运行在同一个节点上时，可能会导致问题（例如，试图写入相同的日志文件）。

*If you need a reference to the proper location to put log files in the YARN so that YARN can properly display and aggregate them, use spark.yarn.app.container.log.dir in your log4j.properties. For example, log4j.appender.file_appender.File=${spark.yarn.app.container.log.dir}/spark.log. For streaming applications, configuring RollingFileAppender and setting file location to YARN’s log directory will avoid disk overflow caused by large log files, and logs can be accessed using YARN’s log utility.*

为了 YARN 可以正确显示和聚合日志文件，需要将日志文件的正确位置放在 YARN 中,在 log4j.properties 中设置 `spark.yarn.app.container.log.dir`。

例如，`log4j.appender.file_appender.File=${spark.yarn.app.container.log.dir}/spark.log`

对于流应用程序，配置 RollingFileAppender 并将文件位置设置为 YARN 的日志目录 将避免由于大型日志文件导致的磁盘溢出，并且可以使用 YARN 的日志实用程序访问日志。

*To use a custom metrics.properties for the application master and executors, update the $SPARK_CONF_DIR/metrics.properties file. It will automatically be uploaded with other configurations, so you don’t need to specify it manually with --files.*

要为 application master 和 executors 使用一个自定义的 `metrics.properties`，请更新 `$SPARK_CONF_DIR/metrics.properties` 文件。它将自动与其他配置一起上传，因此您不需要使用 --files 手动指定它。

### 5.1、Spark Properties

[Spark Properties](http://spark.apache.org/docs/latest/running-on-yarn.html#spark-properties)

### 5.2、Available patterns for SHS custom executor log URL

[Available patterns for SHS custom executor log URL](http://spark.apache.org/docs/latest/running-on-yarn.html#Available-patterns-for-SHS-custom-executor-log-URL)

*For example, suppose you would like to point log url link to Job History Server directly instead of let NodeManager http server redirects it, you can configure spark.history.custom.executor.log.url as below:*

例如，如果你想直接给 Job History Server 指定一个日志 url 连接，而不是让 NodeManager http server 再重定向，你可以配置 `spark.history.custom.executor.log.url`

*<JHS_HOST>:<JHS_PORT>/jobhistory/logs/:////?start=-4096*

*NOTE: you need to replace <JHS_POST> and <JHS_PORT> with actual value.*

## 6、Resource Allocation and Configuration Overview

*Please make sure to have read the Custom Resource Scheduling and Configuration Overview section on the [configuration page](http://spark.apache.org/docs/latest/configuration.html). This section only talks about the YARN specific aspects of resource scheduling.*

*YARN needs to be configured to support any resources the user wants to use with Spark. Resource scheduling on YARN was added in YARN 3.1.0. See the YARN documentation for more information on configuring resources and properly setting up isolation. Ideally the resources are setup isolated so that an executor can only see the resources it was allocated. If you do not have isolation enabled, the user is responsible for creating a discovery script that ensures the resource is not shared between executors.*

*YARN currently supports any user defined resource type but has built in types for GPU (yarn.io/gpu) and FPGA (yarn.io/fpga). For that reason, if you are using either of those resources, Spark can translate your request for spark resources into YARN resources and you only have to specify the spark.{driver/executor}.resource. configs. If you are using a resource other then FPGA or GPU, the user is responsible for specifying the configs for both YARN (spark.yarn.{driver/executor}.resource.) and Spark (spark.{driver/executor}.resource.).*

*For example, the user wants to request 2 GPUs for each executor. The user can just specify spark.executor.resource.gpu.amount=2 and Spark will handle requesting yarn.io/gpu resource type from YARN.*

*If the user has a user defined YARN resource, lets call it acceleratorX then the user must specify spark.yarn.executor.resource.acceleratorX.amount=2 and spark.executor.resource.acceleratorX.amount=2.*

*YARN does not tell Spark the addresses of the resources allocated to each container. For that reason, the user must specify a discovery script that gets run by the executor on startup to discover what resources are available to that executor. You can find an example scripts in examples/src/main/scripts/getGpusResources.sh. The script must have execute permissions set and the user should setup permissions to not allow malicious users to modify it. The script should write to STDOUT a JSON string in the format of the ResourceInformation class. This has the resource name and an array of resource addresses available to just that executor.*

## 7、Important notes

*Whether core requests are honored in scheduling decisions depends on which scheduler is in use and how it is configured.*

- core request 在调度决策中是否得到执行取决于使用的调度程序及其配置方式。

*In cluster mode, the local directories used by the Spark executors and the Spark driver will be the local directories configured for YARN (Hadoop YARN config yarn.nodemanager.local-dirs). If the user specifies spark.local.dir, it will be ignored. In client mode, the Spark executors will use the local directories configured for YARN while the Spark driver will use those defined in spark.local.dir. This is because the Spark driver does not run on the YARN cluster in client mode, only the Spark executors do.*

- 在集群模式中，Spark executors 和 Spark dirver 使用的本地目录是为 YARN（Hadoop YARN 配置 `yarn.nodemanager.local-dirs`）配置的本地目录。如果用户指定 `spark.local.dir`，它将被忽略。在客户端模式下，Spark executors 将使用为 YARN 配置的本地目录，Spark dirver 将使用 `spark.local.dir` 中定义的目录。这是因为 Spark drivers 不在 YARN 集群的 client 模式中运行，仅仅 Spark 的 executors 会这样做。

*The --files and --archives options support specifying file names with the # similar to Hadoop. For example, you can specify: --files localtest.txt#appSees.txt and this will upload the file you have locally named localtest.txt into HDFS but this will be linked to by the name appSees.txt, and your application should use the name as appSees.txt to reference it when running on YARN.*

- --files 和 --archives 支持用 # 指定文件名，与 Hadoop 相似。例如您可以指定：`--files localtest.txt#appSees.txt` 然后就会上传本地名为 localtest.txt 的文件到 HDFS 中去，但是会通过名称 appSees.txt 来链接，当你的应用程序在 YARN 上运行时，你应该使用名称 appSees.txt 来引用它。

*The --jars option allows the SparkContext.addJar function to work if you are using it with local files and running in cluster mode. It does not need to be used if you are using it with HDFS, HTTP, HTTPS, or FTP files.*

- --jars 选项允许你在集群模式下使用本地文件时运行 SparkContext.addJar 函数。如果你使用 HDFS，HTTP，HTTPS 或 FTP 文件，则不需要使用它。

## 8、Kerberos
### 8.1、YARN-specific Kerberos Configuration
### 8.2、Troubleshooting Kerberos

## 9、Configuring the External Shuffle Service

*To start the Spark Shuffle Service on each NodeManager in your YARN cluster, follow these instructions:*

为了在 YARN 集群中的每个 NodeManager 启动 Spark Shuffle 服务，需根据如下指示：

*Build Spark with the YARN profile. Skip this step if you are using a pre-packaged distribution.*

- 用 YARN profile 来构建 Spark。如果你使用了预包装的发布版可以跳过该步骤。

*Locate the spark-<version>-yarn-shuffle.jar. This should be under $SPARK_HOME/common/network-yarn/target/scala-<version> if you are building Spark yourself, and under yarn if you are using a distribution.*

- 定位 `spark-<version>-yarn-shuffle.jar`。如果是你自己构建的 Spark，它应该在 `$SPARK_HOME/common/network-yarn/target/scala-<version>` 下，如果你使用的是一个发布的版本，那么它应该在 yarn 下。

*Add this jar to the classpath of all NodeManagers in your cluster.*

- 添加这个 jar 到集群中所有的 NodeManager 的 classpath 中。

*In the yarn-site.xml on each node, add spark_shuffle to yarn.nodemanager.aux-services, then set yarn.nodemanager.aux-services.spark_shuffle.class to org.apache.spark.network.yarn.YarnShuffleService.*

- 在每个节点的 `yarn-site.xml` 文件中，添加 spark_shuffle 到 `yarn.nodemanager.aux-services`，然后设置 `yarn.nodemanager.aux-services.spark_shuffle.class` 为 `org.apache.spark.network.yarn.YarnShuffleService` 。

*Increase NodeManager's heap size by setting YARN_HEAPSIZE (1000 by default) in etc/hadoop/yarn-env.sh to avoid garbage collection issues during shuffle.*

- 通过在 `etc/hadoop/yarn-env.sh` 文件中设置 `YARN_HEAPSIZE` (默认值 1000) 增加 NodeManager's 堆大小，以避免在 shuffle 时产生的垃圾回收问题。

*Restart all NodeManagers in your cluster.*

- 重启集群中所有的 NodeManager。

*The following extra configuration options are available when the shuffle service is running on YARN:*

当 shuffle service 服务在 YARN 上运行时，可以使用以下额外的配置选项:

Property Name | Default | Meaning
---|:---|:---
spark.yarn.shuffle.stopOnFailure | false | Whether to stop the NodeManager when there's a failure in the Spark Shuffle Service's initialization. This prevents application failures caused by running containers on NodeManagers where the Spark Shuffle Service is not running. 判断在初始化中出现了问题是否停止 NodeManager

## 10、Launching your application with Apache Oozie

*Apache Oozie can launch Spark applications as part of a workflow. In a secure cluster, the launched application will need the relevant tokens to access the cluster’s services. If Spark is launched with a keytab, this is automatic. However, if Spark is to be launched without a keytab, the responsibility for setting up security must be handed over to Oozie.*

Apache Oozie 可以将启动 Spark 应用程序作为工作流的一部分。在安全集群中，启动的应用程序将需要相关的 tokens 来访问集群的服务。

如果 Spark 使用 keytab 启动，这是自动的。但是，如果 Spark 在没有 keytab 的情况下启动，则设置安全性的责任必须移交给 Oozie。

*The details of configuring Oozie for secure clusters and obtaining credentials for a job can be found on the [Oozie web site](http://oozie.apache.org/) in the “Authentication” section of the specific release’s documentation.*

*For Spark applications, the Oozie workflow must be set up for Oozie to request all tokens which the application needs, including:*

对于 Spark 应用程序，必须设置 Oozie 工作流以使 Oozie 请求应用程序需要的所有 tokens，包括：

- The YARN resource manager.
- The local Hadoop filesystem.
- Any remote Hadoop filesystems used as a source or destination of I/O.
- Hive —if used.
- HBase —if used.
- The YARN timeline server, if the application interacts with this.

*To avoid Spark attempting —and then failing— to obtain Hive, HBase and remote HDFS tokens, the Spark configuration must be set to disable token collection for the services.*

*The Spark configuration must include the lines:*

为了避免 Spark 尝试 - 然后失败 - 要获取 Hive、HBase 和远程的 HDFS tokens，必须将 Spark 配置中 收集 tokens 的选项设置为禁用。Spark 配置必须包含以下行：

	spark.security.credentials.hive.enabled   false
	spark.security.credentials.hbase.enabled  false

*The configuration option spark.kerberos.access.hadoopFileSystems must be unset.*

必须取消设置配置选项 `spark.yarn.access.hadoopFileSystems`.

## 11、Using the Spark History Server to replace the Spark Web UI

*It is possible to use the Spark History Server application page as the tracking URL for running applications when the application UI is disabled. This may be desirable on secure clusters, or to reduce the memory usage of the Spark driver. To set up tracking through the Spark History Server, do the following:*

应用程序 UI 被禁用时，可以使用 Spark History Server 应用程序页面作为用于跟踪运行的程序的 URL。这在安全的集群中是适合的，或者减少 Spark driver 的内存使用量。要通过 Spark History Server 设置跟踪，请执行以下操作：

*On the application side, set spark.yarn.historyServer.allowTracking=true in Spark’s configuration. This will tell Spark to use the history server’s URL as the tracking URL if the application’s UI is disabled.*

- 在应用程序方面，在 Spark 的配置中设置 `spark.yarn.historyServer.allowTracking=true`. 在 application's UI 是禁用的情况下，这将告诉 Spark 去使用 history server's URL 作为 racking URL。

*On the Spark History Server, add org.apache.spark.deploy.yarn.YarnProxyRedirectFilter to the list of filters in the spark.ui.filters configuration.*

- 在 Spark History Server 方面，添加 `org.apache.spark.deploy.yarn.YarnProxyRedirectFilter` 到 `spark.ui.filters` 配置的中的 filters 列表中去。

*Be aware that the history server information may not be up-to-date with the application’s state.*

注意：history server 信息可能不是应用程序状态的最新信息。