# yarn原理

## 一、简介

YARN 把 资源管理 和 job 调度/监控 划分到不同的进程，即全局 ResourceManager (RM) 和 每个 application 都有的 ApplicationMaster (AM)。一个 application 要么是一个 job，要么是 a DAG of jobs。[job 换成了 application]

ResourceManager 和 NodeManager 构成了数据计算框架。

**ResourceManager** 的作用是 **为所有 application 裁决(arbitrates)资源**。

**NodeManager** 运行在集群中的节点上，每个节点都会有自己的NodeManager，作用是 **监控container的使用情况，并汇报给ResourceManager/Scheduler。**

**Container** 是 **具体执行application task（如map task、reduce task）的基本单位**。Container和集群节点的关系是：一个节点会运行多个Container，但一个Container不会跨节点。一个Container就是一组分配的 **系统资源(cpu, memory, disk, network)**。


**ApplicationMaster** 的作用就是 **向 ResourceManager 申请资源，并与 NodeManager 一起执行任务、监视任务，跟踪状态**。

![yarn02](https://s1.ax1x.com/2020/06/22/NJ6QmV.png)

ResourceManager 有两个组件： Scheduler 、 ApplicationsManager.

**Scheduler** 的作用是 **为运行的多个 application 分配资源**，但是受到容量和队列等因素的限制。它是一个纯调度器，不会执行监控，或追踪 application 的状态，也不会保证在 application 失败或硬件故障时，重启失败的任务。

Scheduler 执行调度是 **基于 application 的资源请求**，而不是基于 包含memory, cpu, disk, network资源的 Container 。

Scheduler是可插拔的，为集群中的各种队列、应用等划分集群资源。主要有两种Scheduler：**Capacity Scheduler 和 Fair Scheduler**。[The Scheduler has a pluggable policy which is responsible for partitioning the cluster resources among the various queues, applications etc.]

**ApplicationManager** 的作用是 **接收 job 的提交请求；为 application ApplicationMaster 的运行申请第一个 Container ，在遇到失败时重启 ApplicationMaster Container**。每个 application 的 ApplicationMaster 负责向 Scheduler 申请适当的 container资源，跟踪 application 的状态并监视进展。

## 二、执行流程

![yarn01](https://s1.ax1x.com/2020/06/22/NJcph4.png)

    客户端程序向ResourceManager提交应用并请求一个ApplicationMaster实例

    ResourceManager找到可以运行一个Container的NodeManager，并在这个Container中启动ApplicationMaster实例

    ApplicationMaster向ResourceManager进行注册，注册之后客户端就可以查询ResourceManager获得自己ApplicationMaster的详细信息，以后就可以和自己的ApplicationMaster直接交互了

    在平常的操作过程中，ApplicationMaster根据resource-request协议向ResourceManager发送resource-request请求

    当Container被成功分配之后，ApplicationMaster通过向NodeManager发送container-launch-specification信息来启动Container， container-launch-specification信息包含了能够让Container和ApplicationMaster交流所需要的资料

    应用程序的代码在启动的Container中运行，并把运行的进度、状态等信息通过application-specific协议发送给ApplicationMaster

    在应用程序运行期间，提交应用的客户端主动和ApplicationMaster交流获得应用的运行状态、进度更新等信息，交流的协议也是application-specific协议

    一但应用程序执行完成并且所有相关工作也已经完成，ApplicationMaster向ResourceManager取消注册然后关闭，用到所有的Container也归还给系统

[原文链接](https://blog.csdn.net/suifeng3051/article/details/49486927)

## 三、调度器

### 1、Capacity Scheduler

CapacityScheduler是一种可插拔的Hadoop调度器，它允许多租户安全地共享一个大型集群，从而在资源分配有限的条件下适时的为应用程序分配资源。

#### Overview

CapacityScheduler旨在以一种操作友好的方式 **在共享的多租户集群运行将 Hadoop applications** ，同时最大化吞吐量和集群利用率。

传统上，每个组织都有自己的私有计算资源集，这些资源能够在峰值或接近峰值条件下，满足SLA。但这通常会降低资源的平均利用率、增加管理多个独立集群(每个组织一个)的开销。因为可以不再创建私有集群，所以组织间共享集群是较为划算的方式。然而，组织会更关心共享集群的方式，因为他们担心其他人占用对他们SLA至关重要的资源。

CapacityScheduer 的作用就是 **实现共享一个大规模集群，同时给予每个组织一定的资源容量保证**。 设计思路是 基于各自计算需求，在各组织间共享可用的 Hadoop 集群资源，并且共同为Hadoop集群提供硬件资源(collectively fund the cluster)。这样就有一个额外的好处就是，组织可用使用其他组织空置的容量。那么组织在成本效益上就有了弹性空间。

跨组织的共享集群需要 **支持多租户**，因为必须为每个组织提供一定的资源容量和安全保障，以确保共享集群不会受到个别的危险应用、用户或者二者组合的影响。CapacityScheduler 提供了一个措施以保证某个应用、用户或者队列 **不会占用和自身需求不相称的资源量**。为了保证集群的公平和稳定，CapacityScheduler还会 **限制初始化/挂起的应用程序的数量**。

CapacityScheduler提供了 **队列** 的抽象概念。由管理员创建，**反映共享集群的资源使用情况**。

为了进一步控制和预测共享资源的使用，CapacityScheduler支持 **层级队列**， 它允许 **其他队列使用当前的空闲资源之前，资源优先在该组织的多个子队列间共享使用**。 这就为一个组织的多个应用间共享空闲资源提供了 affinity。

#### Features

CapacityScheduler支持如下特性：

- 层级队列：其他队列使用当前的空闲资源之前，资源优先在该组织的多个子队列间共享使用。

- 容量保证：队列能够占用一定的资源容量。所有提交到队列的应用程序都能够使用分配给队列的资源容量。管理员能够为每个队列配置分配的容量的软性限制和可选的硬性限制。

- 安全：每个队列都有严格的ACL 控制着用户能够提交到独立队列的应用程序。另外，安全保护机制能够确保用户不能查看和修改其他用户提交的应用程序。每个队列和系统都支持管理员角色。

- 弹性： 当队列占用的资源容量较低时，可以为其调度更多的空闲资源。

- 多租户：提供一些更全面的限制条件，阻止一个应用程序、用户、队列霸占整个队列或者集群的资源，确保集群不会压垮。

- 运维

    运行时配置：队列的定义和属性是能在运行时修改的，如容量，ACL。另外，为用户和管理员提供了控制台，进行查看系统中当前资源分配给哪些队列。管理员能够在运行时新增队列，但是不能在运行时删除，除非队列停止了，或没有挂起/运行的应用。

    清空(Drain)应用程序 ：管理员能够在运行时停止队列，以保证已有的应用程序快要结束时，不会有新的应用程序被提交。 **如果一个队列处在STOPPED状态，新的应用程序不能被提交到这个队列以及它的子队列。这个队列下已有的应用程序可以继续完成，这样队列可以优雅的退出** 。 管理员能够启动和停止队列。

- 基于资源的调度：资源密集型的应用程序可以配置比默认值更高的资源需求，并支持不同种类的资源的需求。目前，内存是支持的资源需求。

- 基于默认或用户定义的放置规则的队列映射接口：该特性允许用户基于某些默认放置规则将 job 映射到特定队列。例如，根据用户和组或应用程序名称。用户也可以定义自己的放置规则。

- 调度的优先级：该特性允许应用程序以不同的优先级被提交和调度。较高的整数值表示应用程序的优先级较高。目前，应用程序优先级仅 **支持FIFO排序策略**。

- 绝对资源配置：管理员可以为队列指定绝对资源，而不是提供基于百分比的值。这为管理员配置 给定队列所需的资源量提供了更好的控制。

- 动态自动创建和管理叶队列：这个特性支持自动创建叶队列和队列映射，队列映射目前支持基于用户组的队列映射，用于将应用程序放置到队列中。调度器还支持基于父队列上配置的策略对这些队列进行容量管理。

#### Configuration


参考：[hadoop 2.7.2 yarn中文文档—— Capacity Scheduler](https://blog.csdn.net/han_zw/article/details/84812506)

### 2、Fair Scheduler


参考：[hadoop 2.7.2 yarn中文文档——Fair Scheduler](https://blog.csdn.net/han_zw/article/details/84815512)
