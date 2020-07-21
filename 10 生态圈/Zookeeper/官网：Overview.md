# Overview：ZooKeeper分布式应用程序的分布式协调服务

[TOC]

**v3.6**

ZooKeeper 是一种 **应用于分布式应用程序的、开源的分布式协调服务**。 它提供了一组简单的原语，即 **分布式应用程序可以构建更高级别的服务，如同步服务、配置维护、组服务和命名服务**[groups and naming]。 它是易于编程的，并 **使用了传统的文件系统目录树结构** [uses a data model styled after the familiar directory tree structure of file systems]。运行在 Java 中，但提供 Java 和 C 的接口。

协调服务是很难正确实现的。很容易出现资源竞争、死锁等错误。 ZooKeeper 的目的就是缓解分布式应用程序从一开始就执行协调服务的责任。

## 1、Design Goals 设计目标

**ZooKeeper is simple.** ZooKeeper 允许分布式进程通过 **共享的层级命名空间**[namespace]来相互协调，这个命名空间与标准文件系统类似。**命名空间由 znodes 组成，而 znodes 类似于标准文件系统的文件和目录。** 与专为存储设计的标准文件系统不同的是， **ZooKeeper 数据保存在内存中**，这意味着 ZooKeeper可以实现高吞吐量和低延迟。

ZooKeeper 对实现高性能、高可用性、严格有序的访问非常重要。 ZooKeeper 的高性能意味着它可以应用在大规模分布式系统中、可靠性意味着可以避免单点故障。严格有序意味着可以在客户端实现复杂的同步原语。

**ZooKeeper is replicated. **  就像它所协调的分布式进程一样，**ZooKeeper 本身也是要在一组称为 ensemble 的主机上复制。**

![zk04](https://s1.ax1x.com/2020/06/27/NcQFLq.jpg)

运行 ZooKeeper 服务的服务器必须知道彼此。它们维护着一个内存中的状态映像、和处于持久化存储中的事务日志和快照[They maintain an in-memory image of state, along with a transaction logs and snapshots in a persistent store.]。**只要大多数服务可用，ZooKeeper 服务就可用**。

**客户端连接到一个 ZooKeeper 服务器。 意味着客户端和ZooKeeper 服务器建立一个 TCP 连接，通过它可以发送请求、获取响应、获取监听事件并发送心跳。** 如果 TCP 连接中断，客户端将会连接到其他服务器。

**ZooKeeper is ordered.**  ZooKeeper **用数字来标记每次的事务操作顺序**。后续操作可以使用这个数字来实现更高级的抽象，例如同步原语。

**Zookeeper is fast.** ZooKeeper 在 **读数据时非常快**。 ZooKeeper 应用程序在数千台机器上运行，当在读取次数是写入次数的10倍时，性能最好。

## 2、Data model and the hierarchical namespace 数据模型和层级命名空间

ZooKeeper 命名空间与标准文件系统类似。 **名称是以斜杠（/）分隔的路径元素序列** 。 命名空间的每个节点都由路径标识。

ZooKeeper 层级命名空间如下图所示：

![zk05](https://s1.ax1x.com/2020/06/27/NcQPQs.jpg)

## 3、Nodes and ephemeral nodes 节点和临时节点

与标准文件系统不同的是，ZooKeeper 命名空间中的 **每个节点都有与其相关联的数据和子节点**，就像是文件系统的文件既是文件也是目录。（ZooKeeper 用于存储协调数据：状态信息，配置，位置信息等，因此存储在每个节点上的数据通常很小，B到KB范围）。我们 **使用 znode 来表示 ZooKeeper 数据节点**。

Znodes **维护统计结构信息**，包括数据更改，ACL 更改和时间戳的版本号，以允许缓存验证和协调更新。 **每次 znode 的数据发生变化时，版本号都会增加** 。 例如，每当客户端检索数据时，它也会收到数据的版本号。

存储在 znode 的数据 **以原子方式读取和写入。读取操作会获取所有与 znode 相关联的数据字节，写入则会替换所有数据。 每个节点都有一个访问控制列表（ACL），它限制谁能做什么**。

ZooKeeper 还包括了临时节点。**只要创建 znode 的 session 处于活动状态，这些临时 znodes 就会存在。 当 session 结束时，临时znode 被删除。**

## 4、Conditional updates and watches 有条件的更新和监听器

ZooKeeper 支持监听器[watches]的概念。客户端可以 **在一个 znode 上设置一个监听器。 当 znode 更改时，这个监听器将被触发并移除。当监听器被触发时，客户端接收到一个数据包，说明 znode 已经改变了**。 并且如果客户端与其中一个 ZooKeeper 服务器的连接断开，客户端将收到本地通知。

在版本3.6.0：客户端 **可以设置参数，递归的监听znode**，这个znode是在触发监听后未被移除的。这会递归地触发对已注册的znode以及任何子znodes的更改。[Clients can also set permanent, recursive watches on a znode that are not removed when triggered and that trigger for changes on the registered znode as well as any children znodes recursively.]

## 5、Guarantees 保证

ZooKeeper 非常快速、简单。 由于其目标是为建设更为复杂的服务提供基础服务，如同步化，它提
供了一套保证。 这些是：

- 顺序一致性 : 来自客户端的更新请求将按照它们发送的顺序依次响应。

- 原子性 : 更新要么成功要么失败。

- 单一系统映像 : 客户端将看到相同的服务视图，和链接哪台服务器无关。例如，即使客户端故障转移[fails over]到具有相同 session 的不同服务器上，客户端也不会看到系统的旧视图。

- 可靠性 : 一旦进行了更新，它将从当前持续到客户端完成更新。[Once an update has been applied, it will persist from that time forward until a client overwrites the update.]

- 及时性 : 系统的客户端视图在一定时间内保证是最新的。

## 6、Simple API 简单的 API

ZooKeeper 的设计目标之一是提供一个非常简单的编程接口。 因此，它仅支持以下操作：

- create : 在树中的某个位置创建一个节点

- delete : 删除一个节点

- exists : 测试节点是否存在于某个位置

- get data : 从节点读取数据

- set data : 将数据写入节点

- get children : 检索节点的子节点列表

- sync : 等待数据传播

## 7、Implementation

[ZooKeeper Components](https://zookeeper.apache.org/doc/current/zookeeperOver.html#zkComponents)显示 ZooKeeper 服务的高级组件。 除了请求处理器之外，组成 ZooKeeper 服务的每个服务器都会将每个组件的副本复制到自己服务器上。

![zk06](https://s1.ax1x.com/2020/06/27/NcQpWQ.jpg)

replicated database 是包含整个数据树的内存数据库。Updates are logged to disk for recoverability, and writes are serialized to disk before they are applied to the in-memory database.

每个 ZooKeeper 服务器都为客户端服务。 客户端连接到一个服务器以提交请求。从每个服务器数据库的本地副本中响应读取请求。 更改服务状态、写入的请求由一致性协议[protocol]进行处理。

作为一致性协议的一部分，所有客户端的写入请求都将转发到称为 leader 单个服务器。其他 ZooKeeper 服务器称为followers，作用是从 leader 接收消息请求，并同意消息传递。The messaging layer takes care of replacing leaders on failures and syncing followers with leaders.

ZooKeeper 使用自定义的原子消息协议。 由于消息层是原子的，所以 ZooKeeper 可以保证本地副
本不会发散[diverge]。 当 leader 收到写请求时， it calculates what the state of the system is when the write is to be applied and transforms this into a transaction that captures this new state.

## 8、Uses

## 9、Performance

## 10、Reliability

## 11、The ZooKeeper Project
