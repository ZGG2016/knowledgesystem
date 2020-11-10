# Hadoop:Fair Scheduler

## 1、Purpose

FairScheduler 是一个允许 YARN 应用程序公平共享集群资源的可拔插的调度器。

## 2、Introduction

公平调度是一个给所有应用程序分配资源的方法，**随着时间的推移，所有应用程序平等分享资源**。下一代Hadoop可调度多种资源类型。默认的，the Fair Scheduler bases scheduling fairness decisions only on memory. It can be configured to schedule with both memory and CPU, using the notion of Dominant Resource Fairness developed by Ghodsi et al. **当只有一个应用程序运行时，该应用程序可以使用整个集群资源，当其他应用程序提交之后，释放一部分资源给新提交的应用程序，所以每个应用程序最终会得到大致相同的资源量**。不像hadoop的默认调度器由应用程序组成的队列构成，这让短生命周期的应用程序在合理的时间内执行完，而不是长时间存活阻塞调度系统(while not starving long-lived apps)。它还是一个在一定数量的 **用户间共享集群的合理方法**。最后，公平分享也可以 **结合应用程序优先级 —— 优先级决定了每个应用程序应该获得的资源比重**。

应用程序在调度器组织下进入队列，**不同队列间公平的共享资源**。默认，所有用户共享一个叫做 default 的队列。 **应用程序既可以通过指定一个队列来确定被提交到哪个队列，也可以通过包含在请求中的用户名来分配队列。** 对于每个队列，使用一个 **调度策略** 为运行中的应用程序共享资源。默认是 **基于内存的公平共享**，但是也可以配置FIFO和多资源的Dominant Resource Fairness。队列可以 **编排成层级结构** 以便分配资源，并且可以通过配置权重按特定比例来分享集群资源。

另外为了公平共享，Fairscheduler  **为队列分配了最小共享份额**，这对确保了特定用户、组、产品应用始终获得足够的资源。当队列包含应用程序时，它至少能获得最小共享份额，**但是当队列占用的资源有空余时，那么空余的资源会分配给其他运行中的应用程序**。这既保证了队列的容量，又可以 在这些队列不包含应用程序时高效的利用资源。

FairScheduler默认让所有应用程序都运行，但也能通过 **配置文件限制每个用户、队列的运行的应用程序数量**。这就很好的预防了用户一次提交几百应用程序或要提升性能的情况（如果一次运行过多app会引起创建过多的中间数据，或者过多的上下文切换）。限制应用程序数量不会引起后续的应用程序提交失败，只会在调度器的队列中等待，直到某些用户较早提交的应用程序结束。


## 3、Hierarchical queues with pluggable policies

Fair Scheduler **支持层级队列。所有队列都从属于一个叫做“root”的队列**。以一种典型的公平调度的方式在root列的子队列中分配可用资源。然后，子队列将获得的资源采用相同的方式分配到他们的子队列中。**应用程序只在叶子队列上调度**。将队列指定为其他队列的子队列的方法是：在公平调度的配置文件中，将队列作为他们双亲的子元素。

队列名称以其双亲的名称作为开头，用句点（"."）作为分隔符。所以root队列下的名为"queue1"的队列会被称为“root.queue1”，位于“parent1”队列下的“queue2”队列会被称为"root.parent1.queue2"。当提到队列时，名称中的root部分是可选的，所以queue1可以被称为"queue1"，queue2可以被称为“parent1.queue2”。

另外，FairScheduler **为不同队列设置个性化的策略**，以用户指定的方式共享队列的资源。个性化策略可以通过继承 org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.SchedulingPolicy 来实现。内置的策略主要有FifoPolicy, FairSharePolicy (默认的), 以及DominantResourceFairnessPolicy。

## 4、Automatically placing applications in queues

Fairscheduler 允许 **管理员配置策略，以将提交的应用程序放置到相应的队列中**。放置方式依赖于提交的用户、组以及应用程序传过来的申请中的队列信息。一个策略由一组规则组成，这些规则对进来的应用程序进行一系列的分类。每个规则要么放置应用程序到一个队列，或者拒绝它，又或者继续交由下一个规则。关于如何配置这些策略可以参考下面分配文件格式。

参考：[hadoop 2.7.2 yarn中文文档——Fair Scheduler](https://blog.csdn.net/han_zw/article/details/84815512)

[Yarn 调度器Scheduler详解](https://blog.csdn.net/suifeng3051/article/details/49508261)

## 5、Installation

## 6、Configuration

### 6.1、Properties that can be placed in yarn-site.xml

### 6.2、Allocation file format

### 6.3、Queue Access Control Lists

### 6.4、Reservation Access Control Lists

### 6.5、Configuring ReservationSystem

## 7、Administration

### 7.1、Modifying configuration at runtime

### 7.2、Monitoring through web UI

### 7.3、Moving applications between queues

### 7.4、Dumping Fair Scheduler state