# ZooKeeper：分布式应用程序的分布式协调服务

ZooKeeper 是一种 **应用于分布式应用程序的、开源的分布式协调服务**。 它提供了一组简单的原语，即 **分布式应用程序可以构建更高级别的服务，如同步服务、配置维护、组服务和命名服务**[groups and naming]。 它是易于编程的，并 **使用了传统的文件系统目录树结构** [uses a data model styled after the familiar directory tree structure of file systems]。运行在 Java 中，但提供 Java 和 C 的接口。

协调服务是很难正确实现的。很容易出现资源竞争、死锁等错误。 ZooKeeper 的目的就是缓解分布式应用程序从开始就执行协调服务的责任。

## Design Goals 设计目标

**ZooKeeper is simple.** ZooKeeper 允许分布式进程通过 **共享的层级命名空间**[namespace]来相互协调，这个命名空间与标准文件系统类似。**命名空间由 znodes 组成，而 znodes 类似于标准文件系统的文件和目录。** 与专为存储设计的标准文件系统不同的是， **ZooKeeper 数据保存在内存中**，这意味着 ZooKeeper可以实现高吞吐量和低延迟。

ZooKeeper 对实现高性能、高可用性、严格有序的访问非常重要。 ZooKeeper 的高性能意味着它可以应用在大规模分布式系统中、可靠性意味着可以避免单点故障。严格有序意味着可以在客户端实现复杂的同步原语。

**ZooKeeper is replicated. **  就像它所协调的分布式进程一样，**ZooKeeper 本身也是要在一组称为 ensemble 的主机上复制。**

![zk04](https://s1.ax1x.com/2020/06/27/NcQFLq.jpg)

运行 ZooKeeper 服务的服务器必须知道彼此。它们维护着一个内存中的状态映像、和处于持久化存储中的事务日志和快照[They maintain an in-memory image of state, along with a transaction logs and snapshots in a persistent store.]。**只要大多数服务可用，ZooKeeper 服务就可用**。

客户端连接到一个 ZooKeeper 服务器。 意味着客户端和ZooKeeper 服务器建立一个 TCP 连接，通过它可以发送请求、获取响应、获取监听事件并发送心跳。 如果 TCP 连接中断，客户端将会连接到其他服务器。

**ZooKeeper is ordered.**  ZooKeeper **用数字来标记每次的事务操作顺序**。后续操作可以使用这个数字来实现更高级的抽象，例如同步原语。

**Zookeeper is fast.** ZooKeeper 在 **读数据时非常快**。 ZooKeeper 应用程序在数千台机器上运行，当在读取次数是写入次数的10倍时，性能最好。

## Data model and the hierarchical namespace

https://s1.ax1x.com/2020/06/27/NcQPQs.jpg
https://s1.ax1x.com/2020/06/27/NcQpWQ.jpg
https://s1.ax1x.com/2020/06/27/NcQ9zj.jpg
https://s1.ax1x.com/2020/06/27/NcQiyn.jpg
