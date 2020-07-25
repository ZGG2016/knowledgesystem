# 官网：Submitting Applications

[TOC]

*The spark-submit script in Spark’s bin directory is used to launch applications on a cluster. It can use all of Spark’s supported [cluster managers](http://spark.apache.org/docs/latest/cluster-overview.html#cluster-manager-types) through a uniform interface so you don’t have to configure your application especially for each one.*

bin 目录下的 spark-submit 脚本用来启动应用程序。可以用在 Spark 所有支持的集群管理器，而不需要专门配置。


## 1、Bundling Your Application’s Dependencies

*If your code depends on other projects, you will need to package them alongside your application in order to distribute the code to a Spark cluster. To do this, create an assembly jar (or “uber” jar) containing your code and its dependencies. Both sbt and Maven have assembly plugins. When creating assembly jars, list Spark and Hadoop as provided dependencies; these need not be bundled since they are provided by the cluster manager at runtime. Once you have an assembled jar you can call the bin/spark-submit script as shown here while passing your jar.*

如果你的代码依赖其他的工程，你可以创建一个 jar (or “uber” jar)，来将你的代码和依赖一起打包。

无论是 sbt 还是 Maven 都有集成插件。

在创建 jar 包时，列出 Spark 和 Hadoop 提供的依赖项。它们不需要被打包，因为在运行时它们已经被 集群管理器提供了。如果您已经有一个 jar ,您就可以调用 bin/spark-submit 脚本（如下所示）来传递您的 jar。（？？）

*For Python, you can use the --py-files argument of spark-submit to add .py, .zip or .egg files to be distributed with your application. If you depend on multiple Python files we recommend packaging them into a .zip or .egg.*

对于 Python ，使用 spark-submit 的 --py-files 参数来添加 .py，.zip 和 .egg 文件。如果依赖了多个 Python 文件我们推荐将它们打包成一个 .zip 或者 .egg 文件。

## 2、Launching Applications with spark-submit

*Once a user application is bundled, it can be launched using the bin/spark-submit script. This script takes care of setting up the classpath with Spark and its dependencies, and can support different cluster managers and deploy modes that Spark supports:*

打包完程序后，就可以使用 `bin/spark-submit` 来启动。 这个脚本设置 Spark 及其依赖的 classpath，支撑不同的集群管理器和部署模式。

	./bin/spark-submit \
	  --class <main-class> \
	  --master <master-url> \
	  --deploy-mode <deploy-mode> \
	  --conf <key>=<value> \
	  ... # other options
	  <application-jar> \
	  [application-arguments]

*Some of the commonly used options are:*

- *class: The entry point for your application (e.g. org.apache.spark.examples.SparkPi)*程序入口

- *master: The [master URL](http://spark.apache.org/docs/latest/submitting-applications.html#master-urls) for the cluster (e.g. spark://23.195.26.187:7077)*
集群 MASTER URL

- *deploy-mode: Whether to deploy your driver on the worker nodes (cluster) or locally as an external client (client) (default: client) †* 部署模式：驱动在worker节点，或在本地作为外部客户端

- *conf: Arbitrary Spark configuration property in key=value format. For values that contain spaces wrap “key=value” in quotes (as shown). Multiple configurations should be passed as separate arguments. (e.g. --conf <key>=<value> --conf <key2>=<value2>)*  key=value 形式的配置属性。

- *application-jar: Path to a bundled jar including your application and all dependencies. The URL must be globally visible inside of your cluster, for instance, an hdfs:// path or a file:// path that is present on all nodes.* 包含程序和依赖的jar。 URL 必须全局可见。

- *application-arguments: Arguments passed to the main method of your main class, if any* 传给 main 方法的参数

*† A common deployment strategy is to submit your application from a gateway machine that is physically co-located with your worker machines (e.g. Master node in a standalone EC2 cluster). In this setup, client mode is appropriate. In client mode, the driver is launched directly within the spark-submit process which acts as a client to the cluster. The input and output of the application is attached to the console. Thus, this mode is especially suitable for applications that involve the REPL (e.g. Spark shell).*

一个常见的部署策略是从有个网关机器提交应用程序，这个网关机器是和你的 worker 机器位置在一起。（如：standalone EC2 集群下的 master 节点）。这种设置适合客户端模式。

在客户端模式中，驱动直接运行在一个充当集群客户端的 spark-submit 进程内。应用程序的输入和输出直接连到控制台。因此，这个模式特别适合那些涉及 REPL（例如，Spark shell）的应用程序。

*Alternatively, if your application is submitted from a machine far from the worker machines (e.g. locally on your laptop), it is common to use cluster mode to minimize network latency between the drivers and the executors. Currently, the standalone mode does not support cluster mode for Python applications.*

如果你的应用程序从远离 worker 机器的机器提交，（如你的本地笔记本），就适合用集群模式，来最小化驱动和 executors 的网络延迟。目前，Standalone 模式不支持集群模式的 Python 应用程序。

*For Python applications, simply pass a .py file in the place of <application-jar> instead of a JAR, and add Python .zip, .egg or .py files to the search path with --py-files.*

对于 Python 应用程序，给 application-jar 传递一个 .py 文件而不是一个 JAR，并且 --py-files 添加 Python .zip，.egg 或者 .py 文件。

*There are a few options available that are specific to the cluster manager that is being used. For example, with a [Spark standalone cluster](http://spark.apache.org/docs/latest/spark-standalone.html) with cluster deploy mode, you can also specify --supervise to make sure that the driver is automatically restarted if it fails with a non-zero exit code. To enumerate all such options available to spark-submit, run it with --help. Here are a few examples of common options:*

这里有一些选项可用于特定的集群管理器中。例如，Spark standalone cluster 用集群部署模式，您也可以指定 --supervise 来确保驱动在 non-zero exit code 失败时可以自动重启。为了列出所有 spark-submit，可用的选项，用 --help. 来运行它。这里是一些常见选项的例子 :

```sh
# Run application locally on 8 cores
./bin/spark-submit \
  --class org.apache.spark.examples.SparkPi \
  --master local[8] \
  /path/to/examples.jar \
  100

# Run on a Spark standalone cluster in client deploy mode
./bin/spark-submit \
  --class org.apache.spark.examples.SparkPi \
  --master spark://207.184.161.138:7077 \
  --executor-memory 20G \
  --total-executor-cores 100 \
  /path/to/examples.jar \
  1000

# Run on a Spark standalone cluster in cluster deploy mode with supervise
./bin/spark-submit \
  --class org.apache.spark.examples.SparkPi \
  --master spark://207.184.161.138:7077 \
  --deploy-mode cluster \
  --supervise \
  --executor-memory 20G \
  --total-executor-cores 100 \
  /path/to/examples.jar \
  1000

# Run on a YARN cluster
export HADOOP_CONF_DIR=XXX
./bin/spark-submit \
  --class org.apache.spark.examples.SparkPi \
  --master yarn \
  --deploy-mode cluster \  # can be client for client mode
  --executor-memory 20G \
  --num-executors 50 \
  /path/to/examples.jar \
  1000

# Run a Python application on a Spark standalone cluster
./bin/spark-submit \
  --master spark://207.184.161.138:7077 \
  examples/src/main/python/pi.py \
  1000

# Run on a Mesos cluster in cluster deploy mode with supervise
./bin/spark-submit \
  --class org.apache.spark.examples.SparkPi \
  --master mesos://207.184.161.138:7077 \
  --deploy-mode cluster \
  --supervise \
  --executor-memory 20G \
  --total-executor-cores 100 \
  http://path/to/examples.jar \
  1000

# Run on a Kubernetes cluster in cluster deploy mode
./bin/spark-submit \
  --class org.apache.spark.examples.SparkPi \
  --master k8s://xx.yy.zz.ww:443 \
  --deploy-mode cluster \
  --executor-memory 20G \
  --num-executors 50 \
  http://path/to/examples.jar \
  1000
```

## 3、Master URLs

The master URL passed to Spark can be in one of the following formats:

Master URL | Meaning
---|:---
local | Run Spark locally with one worker thread (i.e. no parallelism at all).
local[K] | Run Spark locally with K worker threads (ideally, set this to the number of cores on your machine).
local[K,F] | Run Spark locally with K worker threads and F maxFailures (see [spark.task.maxFailures](http://spark.apache.org/docs/latest/configuration.html#scheduling) for an explanation of this variable)放弃某项任务之前的失败次数。
local[*] | Run Spark locally with as many worker threads as logical cores on your machine.
local[*,F] | Run Spark locally with as many worker threads as logical cores on your machine and F maxFailures.
spark://HOST:PORT | Connect to the given Spark [standalone cluster](http://spark.apache.org/docs/latest/spark-standalone.html) master. The port must be whichever one your master is configured to use, which is 7077 by default.
spark://HOST1:PORT1,HOST2:PORT2 | Connect to the given Spark standalone cluster with [standby masters with Zookeeper](http://spark.apache.org/docs/latest/spark-standalone.html#standby-masters-with-zookeeper). The list must have all the master hosts in the high availability cluster set up with Zookeeper. The port must be whichever each master is configured to use, which is 7077 by default.
mesos://HOST:PORT | Connect to the given [Mesos](http://spark.apache.org/docs/latest/running-on-mesos.html) cluster. The port must be whichever one your is configured to use, which is 5050 by default. Or, for a Mesos cluster using ZooKeeper, use mesos://zk://.... To submit with --deploy-mode cluster, the HOST:PORT should be configured to connect to the [MesosClusterDispatcher](http://spark.apache.org/docs/latest/running-on-mesos.html#cluster-mode).
yarn | Connect to a [YARN](http://spark.apache.org/docs/latest/running-on-yarn.html) cluster in client or cluster mode depending on the value of --deploy-mode. The cluster location will be found based on the HADOOP_CONF_DIR or YARN_CONF_DIR variable.
k8s://HOST:PORT | Connect to a [Kubernetes](http://spark.apache.org/docs/latest/running-on-kubernetes.html) cluster in cluster mode. Client mode is currently unsupported and will be supported in future releases. The HOST and PORT refer to the [Kubernetes API Server](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/). It connects using TLS by default. In order to force it to use an unsecured connection, you can use k8s://http://HOST:PORT.

## 4、Loading Configuration from a File

*The spark-submit script can load default [Spark configuration values](http://spark.apache.org/docs/latest/configuration.html) from a properties file and pass them on to your application. By default, it will read options from conf/spark-defaults.conf in the Spark directory. For more detail, see the section on [loading default configurations](http://spark.apache.org/docs/latest/configuration.html#loading-default-configurations).*

spark-submit 脚本默认从 `conf/spark-defaults.conf` 载入 Spark 配置值，再传给应用程序。

*Loading default Spark configurations this way can obviate the need for certain flags to spark-submit. For instance, if the spark.master property is set, you can safely omit the --master flag from spark-submit. In general, configuration values explicitly set on a SparkConf take the highest precedence, then flags passed to spark-submit, then values in the defaults file.*

加载默认的 Spark 配置，这种方式可以消除某些 spark-submit 标记。例如，如果在设置了 spark.master 属性，那就可以在 spark-submit 中安全的省略 --master 配置。

一般情况下，明确设置在 SparkConf 上的配置值的优先级最高，然后是传递给 spark-submit的值，最后才是 default value（默认文件）中的值。

*If you are ever unclear where configuration options are coming from, you can print out fine-grained debugging information by running spark-submit with the --verbose option.*

通过使用 --verbose 选项来运行 spark-submit 打印出细粒度的调试信息。

## 5、Advanced Dependency Management

*When using spark-submit, the application jar along with any jars included with the --jars option will be automatically transferred to the cluster. URLs supplied after --jars must be separated by commas. That list is included in the driver and executor classpaths. Directory expansion does not work with --jars.*

使用了 spark-submit ，应用程序及其 jar 自动传给集群。 `--jars` 后的 URLs 要用逗号分隔，这个列表会包含在驱动和 executor 的 classpaths，但它不支持目录。

*Spark uses the following URL scheme to allow different strategies for disseminating jars:*


*file: - Absolute paths and file:/ URIs are served by the driver’s HTTP file server, and every executor pulls the file from the driver HTTP server.*

- file: 绝对路径和 file:/ URI 通过驱动的 HTTP file server 提供服务，并且每个 executor 会从 驱动的 HTTP server 拉取这些文件。

*hdfs:, http:, https:, ftp: - these pull down files and JARs from the URI as expected*

- hdfs:, http:, https:, ftp: 从指定的 URI 拉取文件和 JAR

*local: - a URI starting with local:/ is expected to exist as a local file on each worker node. This means that no network IO will be incurred, and works well for large files/JARs that are pushed to each worker, or shared via NFS, GlusterFS, etc.*

- local： 一个用 local:/ 开头的 URL 需要在每个 worker 节点上作为一个本地文件存在。这样意味着没有网络 IO 发生，并且非常适用于那些已经被推送到每个 worker 或通过 NFS，GlusterFS 等共享的大型的 file/JAR。

*Note that JARs and files are copied to the working directory for each SparkContext on the executor nodes. This can use up a significant amount of space over time and will need to be cleaned up. With YARN, cleanup is handled automatically, and with Spark standalone, automatic cleanup can be configured with the spark.worker.cleanup.appDataTtl property.*

注意：那些 JAR 和文件被复制到工作目录，用于 executor 节点上的每个 SparkContext 。随着时间的推移，这会用完大部分的空间，所以需要清理。在 Spark On YARN 模式中，自动执行清理操作。在 Spark standalone 模式中，可以通过配置 `spark.worker.cleanup.appDataTtl` 属性后会执行自动清理。

*Users may also include any other dependencies by supplying a comma-delimited list of Maven coordinates with --packages. All transitive dependencies will be handled when using this command. Additional repositories (or resolvers in SBT) can be added in a comma-delimited fashion with the flag --repositories. (Note that credentials for password-protected repositories can be supplied in some cases in the repository URI, such as in https://user:password@host/.... Be careful when supplying credentials this way.) These commands can be used with pyspark, spark-shell, and spark-submit to include Spark Packages.*

*For Python, the equivalent --py-files option can be used to distribute .egg, .zip and .py libraries to executors.*

用户也可以通过使用 `--packages` 选项来提供一个逗号分隔的列表，来包含任何其它的依赖。在使用这个命令时所有可传递的依赖将被处理。

可以使用 `--repositories` 添加其它的 repository（或者在 SBT 中被解析的），同时也要用逗号分隔。
（注意，对于那些设置了密码保护的库，在一些情况下可以在库URL中提供验证信息，例如 https://user:password@host/...。以这种方式提供验证信息需要小心。）

这些命令可以与 pyspark、Spark-shell 和 Spark-submit 一起使用，以包含 Spark 包。

对于 Python 来说，使用 --py-files 选项分发 .egg，.zip 和 .py libraries 到 executor 中。

## 6、More Information

Once you have deployed your application, the [cluster mode overview](http://spark.apache.org/docs/latest/cluster-overview.html) describes the components involved in distributed execution, and how to monitor and debug applications.