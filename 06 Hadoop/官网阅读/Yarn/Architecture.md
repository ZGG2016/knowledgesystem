# Architecture

v3.2.1

## 1、简介

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

## 2、[执行流程](https://blog.csdn.net/suifeng3051/article/details/49486927)

![yarn01](https://s1.ax1x.com/2020/06/22/NJcph4.png)

    客户端程序向ResourceManager提交应用并请求一个ApplicationMaster实例

    ResourceManager找到可以运行一个Container的NodeManager，并在这个Container中启动ApplicationMaster实例

    ApplicationMaster向ResourceManager进行注册，注册之后客户端就可以查询ResourceManager获得自己ApplicationMaster的详细信息，以后就可以和自己的ApplicationMaster直接交互了

    在平常的操作过程中，ApplicationMaster根据resource-request协议向ResourceManager发送resource-request请求

    当Container被成功分配之后，ApplicationMaster通过向NodeManager发送container-launch-specification信息来启动Container， container-launch-specification信息包含了能够让Container和ApplicationMaster交流所需要的资料

    应用程序的代码在启动的Container中运行，并把运行的进度、状态等信息通过application-specific协议发送给ApplicationMaster

    在应用程序运行期间，提交应用的客户端主动和ApplicationMaster交流获得应用的运行状态、进度更新等信息，交流的协议也是application-specific协议

    一但应用程序执行完成并且所有相关工作也已经完成，ApplicationMaster向ResourceManager取消注册然后关闭，用到所有的Container也归还给系统

