# 官网：Job Scheduling

[TOC]

## 1、Overview

*Spark has several facilities for scheduling resources between computations. First, recall that, as described in the [cluster mode overview](http://spark.apache.org/docs/latest/cluster-overview.html), each Spark application (instance of SparkContext) runs an independent set of executor processes. The cluster managers that Spark runs on provide facilities for [scheduling across applications](http://spark.apache.org/docs/latest/job-scheduling.html#scheduling-across-applications). Second, within each Spark application, multiple “jobs” (Spark actions) may be running concurrently if they were submitted by different threads. This is common if your application is serving requests over the network. Spark includes a [fair scheduler](http://spark.apache.org/docs/latest/job-scheduling.html#scheduling-within-an-application) to schedule resources within each SparkContext.*

Spark 有多种在计算程序间调度资源的工具。

首先，在 cluster mode overview 中描述的，每个应用程序(SparkContext实例)运行在一组独立的 executor 进程。集群管理器来提供在多个应用程序间调度资源的工具。

然后，在每个 Spark 应用程序中，如果你通过多个线程提交，那么多个 jobs (Spark actions) 可能就会同时运行。如果你的应用程序服务于多个网络请求，那这种情况是非常常见。 Spark 提供了 fair scheduler 在每个 SparkContext 间来调度资源。

## 2、Scheduling Across Applications

*When running on a cluster, each Spark application gets an independent set of executor JVMs that only run tasks and store data for that application. If multiple users need to share your cluster, there are different options to manage allocation, depending on the cluster manager.*

当运行在一个集群时，每个 Spark 应用程序都会获得一组独立的 executor JVMs，用来运行那个应用程序的任务和存储数据。如果多个用户共享你的集群，就会多种选项来管理资源分配，具体方式取决于集群管理器。

*The simplest option, available on all cluster managers, is static partitioning of resources. With this approach, each application is given a maximum amount of resources it can use and holds onto them for its whole duration. This is the approach used in Spark’s [standalone](http://spark.apache.org/docs/latest/spark-standalone.html) and [YARN](http://spark.apache.org/docs/latest/running-on-yarn.html) modes, as well as the [coarse-grained Mesos mode](http://spark.apache.org/docs/latest/running-on-mesos.html#mesos-run-modes). Resource allocation can be configured as follows, based on the cluster type:*

最简单的一种方式就是资源的静态分区，即为每个应用程序赋予一个最大的资源量。这个方式均存在于 standalone 、 YARN 、Mesos。 可按如下进行资源分配的配置：


*Standalone mode: By default, applications submitted to the standalone mode cluster will run in FIFO (first-in-first-out) order, and each application will try to use all available nodes. You can limit the number of nodes an application uses by setting the spark.cores.max configuration property in it, or change the default for applications that don’t set this setting through spark.deploy.defaultCores. Finally, in addition to controlling cores, each application’s spark.executor.memory setting controls its memory use.*

- Standalone mode：默认，应用程序按照 FIFO 方法执行，每个应用程序会尝试使用所有可用节点。可以通过设置 `spark.cores.max` 来限制使用节点的数量，或者通过设置 `spark.deploy.defaultCores` 来改变默认值。通过设置 `spark.executor.memory` 来控制使用的内存。

*Mesos: To use static partitioning on Mesos, set the spark.mesos.coarse configuration property to true, and optionally set spark.cores.max to limit each application’s resource share as in the standalone mode. You should also set spark.executor.memory to control the executor memory.*

YARN: The --num-executors option to the Spark YARN client controls how many executors it will allocate on the cluster (spark.executor.instances as configuration property), while --executor-memory (spark.executor.memory configuration property) and --executor-cores (spark.executor.cores configuration property) control the resources per executor. For more information, see the [YARN Spark Properties](http://spark.apache.org/docs/latest/running-on-yarn.html).*

- YARN:  Spark YARN client 的 `--num-executors` 控制分配到集群的 executors 的数量( `spark.executor.instances` 作为配置属性)。`--executor-memory` (spark.executor.memory configuration property) 和 `--executor-cores` (spark.executor.cores configuration property) 控制每个 executor 占用的资源量。

*A second option available on Mesos is dynamic sharing of CPU cores. In this mode, each Spark application still has a fixed and independent memory allocation (set by spark.executor.memory), but when the application is not running tasks on a machine, other applications may run tasks on those cores. This mode is useful when you expect large numbers of not overly active applications, such as shell sessions from separate users. However, it comes with a risk of less predictable latency, because it may take a while for an application to gain back cores on one node when it has work to do. To use this mode, simply use a mesos:// URL and set spark.mesos.coarse to false.*

*Note that none of the modes currently provide memory sharing across applications. If you would like to share data this way, we recommend running a single server application that can serve multiple requests by querying the same RDDs.*

注意：现在没有哪种模式可以实现在应用程序间共享内存。如果你向按照这种方法共享数据，推荐运行一个 single  server application，它可以通过查询相同的 RDDs 服务于多个请求。

### 2.1、Dynamic Resource Allocation

*Spark provides a mechanism to dynamically adjust the resources your application occupies based on the workload. This means that your application may give resources back to the cluster if they are no longer used and request them again later when there is demand. This feature is particularly useful if multiple applications share resources in your Spark cluster.*

Spark 提供了一种根据工作负载，动态调整应用程序占用的资源量。意味着如果它们不再被使用，或当有需要时再请求它们时，应用程序可能会将资源归还给集群。这种特性非常适应于多个应用程序共享集群资源的情况。

This feature is disabled by default and available on all coarse-grained cluster managers, i.e. [standalone mode](http://spark.apache.org/docs/latest/spark-standalone.html), [YARN mode](http://spark.apache.org/docs/latest/running-on-yarn.html) , and [Mesos coarse-grained mode](http://spark.apache.org/docs/latest/running-on-mesos.html#mesos-run-modes)*

默认是关闭的

#### 2.1.1、Configuration and Setup

*There are two requirements for using this feature. First, your application must set spark.dynamicAllocation.enabled to true. Second, you must set up an external shuffle service on each worker node in the same cluster and set spark.shuffle.service.enabled to true in your application. The purpose of the external shuffle service is to allow executors to be removed without deleting shuffle files written by them (more detail described [below](http://spark.apache.org/docs/latest/job-scheduling.html#graceful-decommission-of-executors)). The way to set up this service varies across cluster managers:*

使用这种特性有两点要求：

- `spark.dynamicAllocation.enabled = true` 

- 在同一集群的每个 worker 节点设置外部 shuffle 服务。 `spark.shuffle.service.enabled = true`。设置外部 shuffle 服务目的是在移除 executor 的时候，能够保留 executor 输出的 shuffle 文件

这个服务的设置方式如下：

- standalone mode： `spark.shuffle.service.enabled = true` 后，启动 workers.

- Mesos coarse-grained mode

- YARN mode: 根据如下描述

*In standalone mode, simply start your workers with spark.shuffle.service.enabled set to true.*

*In Mesos coarse-grained mode, run $SPARK_HOME/sbin/start-mesos-shuffle-service.sh on all slave nodes with spark.shuffle.service.enabled set to true. For instance, you may do so through Marathon.*

*In YARN mode, follow the instructions [here](http://spark.apache.org/docs/latest/running-on-yarn.html#configuring-the-external-shuffle-service).*

*All other relevant configurations are optional and under the spark.dynamicAllocation.* and spark.shuffle.service.* namespaces. For more detail, see the [configurations page](http://spark.apache.org/docs/latest/configuration.html#dynamic-allocation).*

#### 2.1.2、Resource Allocation Policy

*At a high level, Spark should relinquish executors when they are no longer used and acquire executors when they are needed. Since there is no definitive way to predict whether an executor that is about to be removed will run a task in the near future, or whether a new executor that is about to be added will actually be idle, we need a set of heuristics to determine when to remove and request executors.*

Spark 应该在不使用 executors 时候丢弃，使用的时候获取。

但并没有一个确定的方式来预测： 将被移除的 executor 接下来是否会运行一个任务，或将被添加的 executor 是否会被闲置。

我们需要试探着决定什么时候移除、请求 executors。

##### 2.1.2.1、Request Policy

*A Spark application with dynamic allocation enabled requests additional executors when it has pending tasks waiting to be scheduled. This condition necessarily implies that the existing set of executors is insufficient to simultaneously saturate all tasks that have been submitted but not yet finished.*

一个启用了动态分配的 Spark 应用程序当有等待的任务需要调度的时候，会请求额外的执行器。在这种情况下，意味着已有的 executors 已经不足以同时执行所有未完成的任务。

*Spark requests executors in rounds. The actual request is triggered when there have been pending tasks for spark.dynamicAllocation.schedulerBacklogTimeout seconds, and then triggered again every spark.dynamicAllocation.sustainedSchedulerBacklogTimeout seconds thereafter if the queue of pending tasks persists. Additionally, the number of executors requested in each round increases exponentially from the previous round. For instance, an application will add 1 executor in the first round, and then 2, 4, 8 and so on executors in the subsequent rounds.*

Spark 会循环请求 executors 。只有在 `spark.dynamicAllocation.schedulerBacklogTimeout` 秒后，才会触发真正的请求，然后如果等待的任务一直在队列中，就会每 `spark.dynamicAllocation.sustainedSchedulerBacklogTimeout` 秒都会触发一次。

每次循环请求到的 executors 的数量都会比上次请求的到的数量有所增加。 1，2，4，8

*The motivation for an exponential increase policy is twofold. First, an application should request executors cautiously in the beginning in case it turns out that only a few additional executors is sufficient. This echoes the justification for TCP slow start. Second, the application should be able to ramp up its resource usage in a timely manner in case it turns out that many executors are actually needed.*

采用指数级增长策略的原因有两个：首先，请求一开始就应该谨慎地请求 executors ，以防只有几个额外的 executors 就能满足需求。这与TCP缓慢启动的理由是一致的。其次，应用程序应该能够及时地增加其资源使用，以防实际需要许多 executors。

##### 2.1.2.2、Remove Policy

*The policy for removing executors is much simpler. A Spark application removes an executor when it has been idle for more than spark.dynamicAllocation.executorIdleTimeout seconds. Note that, under most circumstances, this condition is mutually exclusive with the request condition, in that an executor should not be idle if there are still pending tasks to be scheduled.*

当 executors 空闲时间超过 `spark.dynamicAllocation.executorIdleTimeout` 秒时，Spark 应用程序将删除它。 请注意，在大多数情况下，此条件与请求条件是互斥的，因为如果仍有等待调度的任务，则 executor 不应空闲。

#### 2.1.3、Graceful Decommission of Executors

*Before dynamic allocation, a Spark executor exits either on failure or when the associated application has also exited. In both scenarios, all state associated with the executor is no longer needed and can be safely discarded. With dynamic allocation, however, the application is still running when an executor is explicitly removed. If the application attempts to access state stored in or written by the executor, it will have to perform a recompute the state. Thus, Spark needs a mechanism to decommission an executor gracefully by preserving its state before removing it.*

在没启用动态分配前，当出现故障或应用程序退出时，a Spark executor 就会退出。executor 中所有状态都不在需要了，可以被安全的删除。

在启用动态分配后，an executor 被删除后，应用程序仍会继续运行。如果应用程序尝试获取状态，那么就需要再次计算状态了。

因此 Spark 需要一个机制，来保证在删除 executor 前，保存它的状态后优雅停止。

*This requirement is especially important for shuffles. During a shuffle, the Spark executor first writes its own map outputs locally to disk, and then acts as the server for those files when other executors attempt to fetch them. In the event of stragglers, which are tasks that run for much longer than their peers, dynamic allocation may remove an executor before the shuffle completes, in which case the shuffle files written by that executor must be recomputed unnecessarily.*

这个要求对 shuffles 来说是非常重要的。在 shuffles 期间，executor 会首先将它的 map 输出写入本地硬盘，然后当其他 executor 想要获取它们时，它会充当一个服务器的角色。

在一些任务的运行时间比同辈要长的事件中，会 shuffle 完成前动态分配会删除 an executor ，在这种情况下，写入那个 executor 的 shuffle files 就必须再次计算。
【运行时间长的任务在用到运行时间短的任务产生的输出文件时，可能这个文件已经被删除了】

*The solution for preserving shuffle files is to use an external shuffle service, also introduced in Spark 1.2. This service refers to a long-running process that runs on each node of your cluster independently of your Spark applications and their executors. If the service is enabled, Spark executors will fetch shuffle files from the service instead of from each other. This means any shuffle state written by an executor may continue to be served beyond the executor’s lifetime.*

外部 shuffle 服务的作用就是保存 shuffle files。它在每个节点运行一个 long-running process。服务启动后， executors 从服务取 shuffle files 文件，而不再是互相取。这就意味着由 executor 写入的任意 shuffle 状态在 executors 生命周期结束后会持续服务。

*In addition to writing shuffle files, executors also cache data either on disk or in memory. When an executor is removed, however, all cached data will no longer be accessible. To mitigate this, by default executors containing cached data are never removed. You can configure this behavior with spark.dynamicAllocation.cachedExecutorIdleTimeout. In future releases, the cached data may be preserved through an off-heap storage similar in spirit to how shuffle files are preserved through the external shuffle service.*

为了写入 shuffle files，executors 也会缓存数据到硬盘或内存。然而当 executors 被移除后，所有的缓存数据都不再可访问。为了减轻这个问题，通过配置 `spark.dynamicAllocation.cachedExecutorIdleTimeout`， 包含缓存数据的 executors 永远不会被移除。

或许在未来的版本中，可能会采用类似外部 shuffle 服务的方法，将缓存数据保存在 off-heap 存储中以解决这一问题。

## 3、Scheduling Within an Application

*Inside a given Spark application (SparkContext instance), multiple parallel jobs can run simultaneously if they were submitted from separate threads. By “job”, in this section, we mean a Spark action (e.g. save, collect) and any tasks that need to run to evaluate that action. Spark’s scheduler is fully thread-safe and supports this use case to enable applications that serve multiple requests (e.g. queries for multiple users).*

在指定的 Spark 应用程序内部（对应同一 SparkContext 实例），如果从不同的线程提交，那么就会同时运行多个并行任务。

在本节中，job 指的是 Spark action (例如save、collect)和 action 触发的运行的任何任务。

Spark 调度器是完全线程安全的，并且能够支持 Spark 应用同时处理多个请求（比如：来自不同用户的查询）。

*By default, Spark’s scheduler runs jobs in FIFO fashion. Each job is divided into “stages” (e.g. map and reduce phases), and the first job gets priority on all available resources while its stages have tasks to launch, then the second job gets priority, etc. If the jobs at the head of the queue don’t need to use the whole cluster, later jobs can start to run right away, but if the jobs at the head of the queue are large, then later jobs may be delayed significantly.*

默认，Spark 使用 FIFO 调度策略来调度 jobs 。每个 job 被划分为多个 stage （例如：map 阶段和 reduce 阶段），第一个 job 会优先使用所有可用资源，然后是第二个 job ，依次类推。

如果前面的 job 不需要使用全部的集群资源，则后续的 job 可以立即启动运行。

如果队列头部的 job 非常大，后面的 job 就可能会延迟很久。

*Starting in Spark 0.8, it is also possible to configure fair sharing between jobs. Under fair sharing, Spark assigns tasks between jobs in a “round robin” fashion, so that all jobs get a roughly equal share of cluster resources. This means that short jobs submitted while a long job is running can start receiving resources right away and still get good response times, without waiting for the long job to finish. This mode is best for multi-user settings.*


Spark 0.8 开始，Spark 支持各个作业间的公平共享。在公平共享下，Spark 以轮询的方式在 jobs 间分配任务，为了所有的 jobs 能获得大致相等的集群资源。

这意味着，一个长的 job 在运行时，短的 job 会立马开始接收资源，不需要等待长的 job 完成。这种模式特别适合于多用户配置。

要启用公平调度器，只需设置一下 SparkContext 中 spark.scheduler.mode 属性为 FAIR 即可 :

```scala
val conf = new SparkConf().setMaster(...).setAppName(...)
conf.set("spark.scheduler.mode", "FAIR")
val sc = new SparkContext(conf)
```

### 3.1、Fair Scheduler Pools

*The fair scheduler also supports grouping jobs into pools, and setting different scheduling options (e.g. weight) for each pool. This can be useful to create a “high-priority” pool for more important jobs, for example, or to group the jobs of each user together and give users equal shares regardless of how many concurrent jobs they have instead of giving jobs equal shares. This approach is modeled after the [Hadoop Fair Scheduler](http://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/FairScheduler.html).*

公平调度器支持将 jobs 分组放入 pool ，然后给每个 pool 配置不同的选项（如：权重）。就能实现为比较重要的 jobs 创建一个“高优先级” pool ，或者也可以将每个用户的 jobs 分到一组，让各用户平均共享集群资源，不用考虑每个用户有多少 jobs.

Spark 公平调度的实现方式基本都是模仿 Hadoop Fair Scheduler 来实现的。

*Without any intervention, newly submitted jobs go into a default pool, but jobs’ pools can be set by adding the spark.scheduler.pool “local property” to the SparkContext in the thread that’s submitting them. This is done as follows:*

新提交的 jobs 都会进入到默认 pool 中，不过 jobs 进入哪个 pool 可用通过添加 `spark.scheduler.pool` 来设置

```scala
// Assuming sc is your SparkContext variable
sc.setLocalProperty("spark.scheduler.pool", "pool1")
```

*After setting this local property, all jobs submitted within this thread (by calls in this thread to RDD.save, count, collect, etc) will use this pool name. The setting is per-thread to make it easy to have a thread run multiple jobs on behalf of the same user. If you’d like to clear the pool that a thread is associated with, simply call:*


设置此本地属性后，在此线程中提交的所有 jobs（即：在该线程中调用 action 算子，如：RDD.save/count/collect 等）将使用此 pool 名称。设置为 per-thread，可以方便地让一个线程代表同一用户运行多个 jobs 。

如果您想要清除线程关联的池，只需调用:

```scala
sc.setLocalProperty("spark.scheduler.pool", null)
```

### 3.2、Default Behavior of Pools

*By default, each pool gets an equal share of the cluster (also equal in share to each job in the default pool), but inside each pool, jobs run in FIFO order. For example, if you create one pool per user, this means that each user will get an equal share of the cluster, and that each user’s queries will run in order instead of later queries taking resources from that user’s earlier ones.*

默认情况下，每个 pool 获得相同的集群份额(与默认 pool 中的每个 job 的份额相同)，但是在每个 pool 中，jobs 按 FIFO 顺序运行。例如，如果为每个用户创建一个 pool ，这意味着每个用户将获得相同的集群份额，并且每个用户的查询将按顺序运行，而不是前一个查询完成、释放资源后，后面的查询再获取资源。

### 3.3、Configuring Pool Properties

*Specific pools’ properties can also be modified through a configuration file. Each pool supports three properties:*

可以修改 pool 属性，主要有以下三个属性：

*schedulingMode: This can be FIFO or FAIR, to control whether jobs within the pool queue up behind each other (the default) or share the pool’s resources fairly.*

- schedulingMode:  FIFO or FAIR

*weight: This controls the pool’s share of the cluster relative to other pools. By default, all pools have a weight of 1. If you give a specific pool a weight of 2, for example, it will get 2x more resources as other active pools. Setting a high weight such as 1000 also makes it possible to implement priority between pools—in essence, the weight-1000 pool will always get to launch tasks first whenever it has jobs active.*

- weight:  控制一个 pool 获取资源的比例。 默认所有 pool 权重都是 1。如果指定一个 pool 的权重为2，那么它就能获取相比其他 pool 两倍的资源。

*minShare: Apart from an overall weight, each pool can be given a minimum shares (as a number of CPU cores) that the administrator would like it to have. The fair scheduler always attempts to meet all active pools’ minimum shares before redistributing extra resources according to the weights. The minShare property can, therefore, be another way to ensure that a pool can always get up to a certain number of resources (e.g. 10 cores) quickly without giving it a high priority for the rest of the cluster. By default, each pool’s minShare is 0.
The pool properties can be set by creating an XML file, similar to conf/fairscheduler.xml.template, and either putting a file named fairscheduler.xml on the classpath, or setting spark.scheduler.allocation.file property in your SparkConf.*

- minShare： 每个 pool 的能获取最小资源份额。公平调度器总是会尝试优先满足所有活跃 pool 的最小资源分配值，然后再根据各个 pool 的 weight 来分配剩下的资源。因此，minShare 属性能够确保每个资源池都能至少获得一定量的集群资源。minShare 的默认值是 0。

```scala
conf.set("spark.scheduler.allocation.file", "/path/to/file")
```

*The format of the XML file is simply a <pool> element for each pool, with different elements within it for the various settings. For example:*

```xml
<?xml version="1.0"?>
<allocations>
  <pool name="production">
    <schedulingMode>FAIR</schedulingMode>
    <weight>1</weight>
    <minShare>2</minShare>
  </pool>
  <pool name="test">
    <schedulingMode>FIFO</schedulingMode>
    <weight>2</weight>
    <minShare>3</minShare>
  </pool>
</allocations>
```

*A full example is also available in conf/fairscheduler.xml.template. Note that any pools not configured in the XML file will simply get default values for all settings (scheduling mode FIFO, weight 1, and minShare 0).*



### 3.4、Scheduling using JDBC Connections

*To set a Fair Scheduler pool for a JDBC client session, users can set the spark.sql.thriftserver.scheduler.pool variable:*

从 JDBC client session 获取 Fair Scheduler pool

```sh
SET spark.sql.thriftserver.scheduler.pool=accounting;
```

### 3.5、Concurrent Jobs in PySpark

*PySpark, by default, does not support to synchronize PVM threads with JVM threads and launching multiple jobs in multiple PVM threads does not guarantee to launch each job in each corresponding JVM thread. Due to this limitation, it is unable to set a different job group via sc.setJobGroup in a separate PVM thread, which also disallows to cancel the job via sc.cancelJobGroup later.*

在默认情况下，PySpark 不支持同步 PVM 线程和 JVM 线程，并且在多个 PVM 线程中启动多个 jobs 并不保证启动每个对应 JVM 线程中的每个 job 。由于此限制，无法在单独的 PVM 线程中通过 sc.setJobGroup 设置不同的作业组，该线程也不允许稍后通过 sc.cancelJobGroup 取消作业。

*In order to synchronize PVM threads with JVM threads, you should set PYSPARK_PIN_THREAD environment variable to true. This pinned thread mode allows one PVM thread has one corresponding JVM thread.*

设置 `PYSPARK_PIN_THREAD = true`，可以实现同步 PVM 线程和 JVM 线程。 这就允许一个 PVM 线程对应一个 JVM 线程。

*However, currently it cannot inherit the local properties from the parent thread although it isolates each thread with its own local properties. To work around this, you should manually copy and set the local properties from the parent thread to the child thread when you create another thread in PVM.*

但是，目前，它不能从父线程继承本地属性，尽管它用自己的本地属性隔离了每个线程。在 PVM 中创建另一个线程时，要解决这个问题，应该手动将父线程的本地属性复制并设置到子线程。

*Note that PYSPARK_PIN_THREAD is currently experimental and not recommended for use in production.*