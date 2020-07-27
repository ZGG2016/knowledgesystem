# 官网：Cluster Mode Overview

[TOC]

**V3.0.0**

*This document gives a short overview of how Spark runs on clusters, to make it easier to understand the components involved. Read through the [application submission guide](http://spark.apache.org/docs/latest/submitting-applications.html) to learn about launching applications on a cluster.*

## 1、Components

*Spark applications run as independent sets of processes on a cluster, coordinated by the SparkContext object in your main program (called the driver program).*

Spark applications 在集群上作为独立的进程组来运行，在你的主程序（称之为驱动程序）中通过 SparkContext 来协调。

*Specifically, to run on a cluster, the SparkContext can connect to several types of cluster managers (either Spark’s own standalone cluster manager, Mesos or YARN), which allocate resources across applications. Once connected, Spark acquires executors on nodes in the cluster, which are processes that run computations and store data for your application. Next, it sends your application code (defined by JAR or Python files passed to SparkContext) to the executors. Finally, SparkContext sends tasks to the executors to run.*

首先，SparkContext 连接集群管理器(standalone\Mesos\YARN)，用来在应用程序间分配资源。

然后，连接成功后，Spark 获得节点上的 executors ，这些进程可以执行计算并且为你的应用程序存储数据。

然后，将你的应用程序代码(由JAR或python文件传递到SparkContext)发送到 executors。

最后，SparkContext 发送任务给 executors 运行。

![spark07](./image/spark07.png)

*There are several useful things to note about this architecture:*

有几个关于架构需要注意的地方 :

*Each application gets its own executor processes, which stay up for the duration of the whole application and run tasks in multiple threads. This has the benefit of isolating applications from each other, on both the scheduling side (each driver schedules its own tasks) and executor side (tasks from different applications run in different JVMs). However, it also means that data cannot be shared across different Spark applications (instances of SparkContext) without writing it to an external storage system.*

(1) 每个应用程序获取到它自己的 executor 进程，在整个应用程序生命周期内都会占用自己的这些进程，并且在多个线程中运行任务。

这样做的优点是，在调度方面和 executor 方面，把应用程序互相隔离。 在调度方面，每个驱动调度它自己的任务，在 executor 方面，不同应用程序的任务运行在不同的 JVM 中。

然而，这也意味着，若是不把数据写到外部存储系统的话，数据就不能被不同的 Spark 应用程序（SparkContext 的实例）之间共享。

*Spark is agnostic to the underlying cluster manager. As long as it can acquire executor processes, and these communicate with each other, it is relatively easy to run it even on a cluster manager that also supports other applications (e.g. Mesos/YARN).*

(2) Spark 是不知道底层的集群管理器是哪一种。只要它能够获得 executor 进程，并且它们之间可以通信，那么即便在一个也支持其它应用程序的集群管理器（例如，Mesos / YARN）上来运行它也是相对简单的。[比如，yarn同时为hadoop\spark服务]

*The driver program must listen for and accept incoming connections from its executors throughout its lifetime (e.g., see spark.driver.port in the network config section). As such, the driver program must be network addressable from the worker nodes.*

(3) driver 程序必须在自己生命周期内监听、接受来自它的 executors 的连接请求(（例如，see [spark.driver.port in the network config section](http://spark.apache.org/docs/latest/configuration.html#networking
)。)。同样的，驱动程序必须可以从 worker 节点上网络寻址（就是网络没问题）。


*Because the driver schedules tasks on the cluster, it should be run close to the worker nodes, preferably on the same local area network. If you’d like to send requests to the cluster remotely, it’s better to open an RPC to the driver and have it submit operations from nearby than to run a driver far away from the worker nodes.*

(4) 因为驱动会调度集群上的任务，更好的方式应该是在相同的局域网中，靠近 worker 的节点上运行。如果远程向集群发送请求，倒不如打开一个至 driver 的 RPC ，让它就近提交操作而不是从很远的 worker 节点上运行一个驱动。


## 2、Cluster Manager Types

*The system currently supports several cluster managers:*

- *[Standalone](http://spark.apache.org/docs/latest/spark-standalone.html) – a simple cluster manager included with Spark that makes it easy to set up a cluster.*内置的

- *[Apache Mesos](http://spark.apache.org/docs/latest/running-on-mesos.html) – a general cluster manager that can also run Hadoop MapReduce and service applications.*

- *[Hadoop YARN](http://spark.apache.org/docs/latest/running-on-yarn.html) – the resource manager in Hadoop 2.*

- *[Kubernetes](http://spark.apache.org/docs/latest/running-on-kubernetes.html) – an open-source system for automating deployment, scaling, and management of containerized applications.* 自动化部署、扩展和管理容器化应用程序的开源系统。

*A third-party project (not supported by the Spark project) exists to add support for [Nomad](https://github.com/hashicorp/nomad-spark) as a cluster manager.*


## 3、Submitting Applications

*Applications can be submitted to a cluster of any type using the spark-submit script. The [application submission guide](http://spark.apache.org/docs/latest/submitting-applications.html) describes how to do this.*

## 4、Monitoring

*Each driver program has a web UI, typically on port 4040, that displays information about running tasks, executors, and storage usage. Simply go to http://<driver-node>:4040 in a web browser to access this UI. The [monitoring guide](http://spark.apache.org/docs/latest/monitoring.html) also describes other monitoring options.*

每个驱动程序都有一个 web UI，端口为4040，展示运行中的任务、executors、存储的使用情况。

`http://<driver-node>:4040`

## 5、Job Scheduling

*Spark gives control over resource allocation both across applications (at the level of the cluster manager) and within applications (if multiple computations are happening on the same SparkContext). The [job scheduling overview](http://spark.apache.org/docs/latest/job-scheduling.html) describes this in more detail.*


## 6、Glossary

The following table summarizes terms you’ll see used to refer to cluster concepts:

Term | Meaning
---|:---
Application | User program built on Spark. Consists of a driver program and executors on the cluster.
Application jar | A jar containing the user's Spark application. In some cases users will want to create an "uber jar" containing their application along with its dependencies. The user's jar should never include Hadoop or Spark libraries, however, these will be added at runtime.用户的 Jar 不要包括 Hadoop 或者 Spark 库，然而，它们将会在运行时被添加。
Driver program | The process running the main() function of the application and creating the SparkContext
Cluster manager | An external service for acquiring resources on the cluster (e.g. standalone manager, Mesos, YARN)
Deploy mode | Distinguishes where the driver process runs. In "cluster" mode, the framework launches the driver inside of the cluster. In "client" mode, the submitter launches the driver outside of the cluster.
Worker node | Any node that can run application code in the cluster
Executor | A process launched for an application on a worker node, that runs tasks and keeps data in memory or disk storage across them. Each application has its own executors.
Task | A unit of work that will be sent to one executor
Job | A parallel computation consisting of multiple tasks that gets spawned in response to a Spark action (e.g. save, collect); you'll see this term used in the driver's logs.
Stage | Each job gets divided into smaller sets of tasks called stages that depend on each other (similar to the map and reduce stages in MapReduce); you'll see this term used in the driver's logs.