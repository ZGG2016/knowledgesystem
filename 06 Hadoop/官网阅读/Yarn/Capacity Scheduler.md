# Hadoop: Capacity Scheduler

## 1、Purpose

CapacityScheduler是一种可插拔的Hadoop调度器，它允许多租户安全地共享一个大型集群，从而在资源分配有限的条件下适时的为应用程序分配资源。

## 2、Overview

CapacityScheduler旨在以一种操作友好的方式 **在共享的多租户集群运行将 Hadoop applications** ，同时最大化吞吐量和集群利用率。

传统上，每个组织都有自己的私有计算资源集，这些资源能够在峰值或接近峰值条件下，满足SLA。但这通常会降低资源的平均利用率、增加管理多个独立集群(每个组织一个)的开销。因为可以不再创建私有集群，所以组织间共享集群是较为划算的方式。然而，组织会更关心共享集群的方式，因为他们担心其他人占用对他们SLA至关重要的资源。

CapacityScheduer 的作用就是 **实现共享一个大规模集群，同时给予每个组织一定的资源容量保证**。 设计思路是 基于各自计算需求，在各组织间共享可用的 Hadoop 集群资源，并且共同为Hadoop集群提供硬件资源(collectively fund the cluster)。这样就有一个额外的好处就是，组织可用使用其他组织空置的容量。那么组织在成本效益上就有了弹性空间。

跨组织的共享集群需要 **支持多租户**，因为必须为每个组织提供一定的资源容量和安全保障，以确保共享集群不会受到个别的危险应用、用户或者二者组合的影响。CapacityScheduler 提供了一个措施以保证某个应用、用户或者队列 **不会占用和自身需求不相称的资源量**。为了保证集群的公平和稳定，CapacityScheduler还会 **限制初始化/挂起的应用程序的数量**。

CapacityScheduler提供了 **队列** 的抽象概念。由管理员创建，**反映共享集群的资源使用情况**。

为了进一步控制和预测共享资源的使用，CapacityScheduler支持 **层级队列**， 它允许 **其他队列使用当前的空闲资源之前，资源优先在该组织的多个子队列间共享使用**。 这就为一个组织的多个应用间共享空闲资源提供了 affinity。

## 3、Features

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

## 4、Configuration

参考：[hadoop 2.7.2 yarn中文文档—— Capacity Scheduler](https://blog.csdn.net/han_zw/article/details/84812506)

### 4.1、Setting up ResourceManager to use CapacityScheduler

### 4.2、Setting up queues

### 4.3、Queue Properties

### 4.4、Setup for application priority.

### 4.5、Capacity Scheduler container preemption

### 4.6、Reservation Properties

### 4.7、Configuring ReservationSystem with CapacityScheduler

### 4.8、Dynamic Auto-Creation and Management of Leaf Queues

### 4.9、Other Properties

### 4.10、Reviewing the configuration of the CapacityScheduler

## 5、Changing Queue Configuration

### 5.1、Changing queue configuration via file

#### 5.1.1、Deleting queue via file

### 5.2、Changing queue configuration via API

## 6、Updating a Container (Experimental - API may change in the future)