# HDFS Architecture 架构

[TOC]

v3.2.1

## 一、Introduction

HDFS 是运行在通用硬件(commodity hardware)上的分布式文件系统。它和现有的分布式文件系统有很多共同点。但同时，它和其他的分布式文件系统的区别也是很明显的。HDFS 是一个 **高度容错性** 的系统，适合 **部署在廉价的机器**上。HDFS能提供 **高吞吐量的数据访问**，非常适合大规模数据集上的应用。HDFS 放宽了一部分POSIX约束，来实现 **流式读取文件** 系统数据的目的。HDFS 在最开始是作为 Apache Nutch 搜索引擎项目的基础架构而开发的。HDFS 是 Apache Hadoop Core 项目的一部分。

## 二、Assumptions and Goals

### Hardware Failure 硬件错误

硬件错误是常态而不是异常。HDFS 可能由成百上千的服务器所构成，每个服务器上存储着文件系统的部分数据。我们面对的现实是构成系统的组件数目是巨大的，而且任一组件都有可能失效，这意味着总是有一部分 HDFS 的组件是不工作的。因此 **错误检测和快速自动的恢复是 HDFS 最核心的架构目标**。

### Streaming Data Access 流式数据访问

运行在 HDFS 上的应用程序和普通的应用程序不同，需要流式访问它们的数据集。HDFS的设计中 **更多的考虑到了数据批处理，而不是用户交互处理。相对于数据访问的低延迟问题，HDFS 更关心的在于数据访问的高吞吐量**。POSIX标准设置的很多硬性约束对HDFS应用系统不是必需的。为了提高数据的吞吐量，在一些关键方面对POSIX的语义做了一些修改。

### Large Data Sets 大规模数据集

运行在HDFS上的应用程序具有很大的数据集。HDFS上的一个典型文件大小一般都在G字节至T字节。因此，HDFS被调节以支持大文件存储。它应该能提供高的数据传输带宽，能在一个集群里扩展到数百个节点。一个单一的HDFS实例应该能支撑数以千万计的文件。

### Simple Coherency Model 简单的一致性模型

HDFS 应用程序需要一个 **一次写入多次读取** 的文件访问模型。**一个文件经过创建、写入和关闭之后就不需要改变, 除了追加和截断。** 在文件末尾追加内容是支持的，但不能在任意位置更新。这一假设简化了数据一致性问题，并且使高吞吐量的数据访问成为可能。MapReduce应用程序或者网络爬虫应用程序都非常适合这个模型。

### “Moving Computation is Cheaper than Moving Data” “移动计算比移动数据更划算”

一个应用请求的计算，离它操作的数据越近就越高效，在数据达到海量级别的时候更是如此。因为这样就能 **降低网络阻塞的影响，提高系统数据的吞吐量**。将计算移动到数据附近，比之将数据移动到应用所在显然更好。HDFS为应用提供了将它们自己移动到数据附近的接口。

### Portability Across Heterogeneous Hardware and Software Platforms 异构软硬件平台间的可移植性

HDFS在设计的时候就考虑到平台的可移植性。这种特性方便了HDFS作为大规模数据应用平台的推广。

## 三、NameNode and DataNodes

HDFS 采用主从架构。一个 HDFS 集群是由一个 Namenode 和一定数目的 Datanodes 组成。Namenode 是一个中心服务器，负责 **管理文件系统的名字空间(namespace)以及客户端对文件的访问**。集群中的 Datanode 一般是一个节点一个，负责 **管理它所在节点上的存储**。HDFS暴露了文件系统的名字空间，用户能够以文件的形式在上面存储数据。从内部看，一个文件其实被分成一个或多个 blocks，这些 **blocks 存储在一组 Datanode 上** 。Namenode **操作文件系统的名字空间**，比如打开、关闭、重命名文件或目录。它也 **负责确定 blocks 到具体 Datanode 节点的映射**。Datanode **负责处理文件系统客户端的读写请求**。**在 Namenode 的统一调度下进行 blocks 的创建、删除和复制**。

![hdfs01](https://s1.ax1x.com/2020/06/25/NBsjNn.png)

Namenode 和 Datanode 被设计成可以在普通的商用机器上运行。这些机器一般运行着 GNU/Linux 操作系统(OS)。HDFS 采用 Java 语言开发，因此 **任何支持 Java 的机器都可以部署 Namenode 或 Datanode** 。由于采用了可移植性极强的 Java 语言，使得 HDFS 可以部署到多种类型的机器上。**一个典型的部署场景是一台机器上只运行一个 Namenode 实例，而集群中的其它机器分别运行一个 Datanode 实例** 。这种架构并不排斥在一台机器上运行多个Datanode，只不过这样的情况比较少见。

集群中单一 Namenode 的结构大大简化了系统的架构。**Namenode 是所有HDFS元数据的仲裁者和管理者**，这样，用户数据永远不会流过Namenode。

## 四、The File System Namespace

HDFS 支持传统的 **层级组织结构**。用户或者应用程序可以创建目录，然后将文件保存在这些目录里。文件系统名字空间的层次结构和大多数现有的文件系统类似： **用户可以创建、删除、移动或重命名文件**。当前，HDFS 不支持用户磁盘配额和访问权限控制，也不支持硬链接和软链接。但是HDFS架构并不妨碍实现这些特性。

HDFS 遵循文件系统的命名规则，一些路径和名称被保留，如 /.reserved and .snapshot。透明加密和快照等特性使用保留路径。

Namenode 负责维护文件系统的名字空间，**任何对文件系统名字空间或属性的修改都将被Namenode记录下来** 。**应用程序可以设置HDFS保存的文件的副本数目**。文件副本的数目称为文件的副本系数，这个信息也是由Namenode保存的。

## 五、Data Replication

HDFS 被设计成能够在一个大集群中跨机器可靠地存储超大文件。它将每个文件存储成一系列的 blocks。**为了容错**，文件的所有数据块都会有副本。**每个文件的 blocks 大小和副本系数都是可配置的**。

**除了最后一个，文件中所有的 blocks 都是同样大小的**。 在为可变长的 block 添加 append and hsync 属性后，用户可以启动一个新的block，而不需要按照配置的 block 大小填充最后一个块。

应用程序可以指定某个文件的副本数目。副本系数可以在文件创建的时候指定，也可以在之后改变。HDFS中的文件都是一次性写入的(除了追加和截断)，并且严格要求 **在任何时候只能有一个写入者**。

Namenode 全权管理数据块的复制，它 **周期性地从集群中的每个Datanode接收心跳信号和块状态报告(Blockreport)**。接收到心跳信号意味着该Datanode节点工作正常。块状态报告包含了一个该Datanode上所有 blocks 的列表。

![hdfs02](https://s1.ax1x.com/2020/06/25/NDPy2d.png)

### 副本存放: 最最开始的一步

副本的存放是 HDFS 可靠性和性能的关键。优化的副本存放策略是 HDFS 区分于其他大部分分布式文件系统的重要特性。这种特性需要做大量的调优，并需要经验的积累。HDFS 采用一种称为 **机架感知(rack-aware)的策略** 来改进数据的可靠性、可用性和网络带宽的利用率。目前实现的副本存放策略只是在这个方向上的第一步。实现这个策略的短期目标是验证它在生产环境下的有效性，观察它的行为，为实现更先进的策略打下测试和研究的基础。

大型 HDFS 实例一般运行在 **跨越多个机架的计算机组成的集群** 上，**不同机架上的两台机器之间的通讯需要经过交换机**。在大多数情况下，同一个机架内的两台机器间的带宽会比不同机架的两台机器间的带宽大。

通过一个机架感知的过程，Namenode 可以确定每个 Datanode 所属的机架id。一个简单但没有优化的策略就是 **将副本存放在不同的机架上**。这样可以有效防止当整个机架失效时数据的丢失，并且允许读数据的时候充分利用多个机架的带宽。这种策略设置可以将副本均匀分布在集群中，有利于当组件失效情况下的负载均衡。但是，因为这种策略的一个写操作需要传输数据块到多个机架，这 **增加了写的代价**。

在大多数情况下，**副本系数是3**，HDFS 的存放策略是 **将一个副本存放在本地机架的节点上，一个副本放在同一机架的另一个节点上，最后一个副本放在不同机架的节点上**。这种策略减少了机架间的数据传输，这就提高了写操作的效率。机架的错误远远比节点的错误少，所以这个策略不会影响到数据的可靠性和可用性。于此同时，因为数据块只放在两个（不是三个）不同的机架上，所以此策略减少了读取数据时需要的网络传输总带宽。在这种策略下，副本并不是均匀分布在不同的机架上。三分之一的副本在一个节点上，三分之二的副本在一个机架上，其他副本均匀分布在剩下的机架中，这一策略在不损害数据可靠性和读取性能的情况下改进了写的性能。

**如果副本因子超过3，第四个副本和剩余副本就随机放置，但保证每个机架的副本数量小于最大值((replicas - 1) / racks + 2)**

因为 NameNode 不允许 datanode 对同一个块有多个副本，所以 **创建的最大副本数就是当时datanode的总数**。

在HDFS中添加了对存储类型和存储策略的支持之后，NameNode 除了考虑上面描述的机架感知之外，还会考虑副本的放置。NameNode 首先基于机架感知选择节点，然后检查候选节点是否具有与文件关联策略所需的存储空间。如果候选节点没有存储类型，NameNode 将查找另一个节点。如果在第一个路径中找不到足够多的节点来放置副本，NameNode将在第二个路径中查找具有回退存储类型的节点。

当前，这里介绍的默认副本存放策略正在开发的过程中。

### Replica Selection 副本选择

为了降低整体的带宽消耗和读取延时，HDFS会尽量读取 **离它最近的副本**。如果在读取程序的同一个机架上有一个副本，那么就读取该副本。如果一个HDFS集群跨越多个数据中心，那么客户端也将首先读本地数据中心的副本。

### Safemode 安全模式

Namenode启动后会进入一个称为安全模式的特殊状态。**处于安全模式的Namenode是不会进行 blocks 的复制的**。Namenode 从所有的 Datanode 接收 **心跳信号和块状态报告**。块状态报告包括了某个Datanode所有的 blocks 列表。每个 blocks 都有一个指定的最小副本数。当 Namenode 检测确认某个 blocks 的副本数目达到这个最小值，那么该 blocks 就会被认为是副本安全(safely replicated)的；在一定百分比（这个参数可配置）的 blocks 被 Namenode 检测确认是安全之后（加上一个额外的30秒等待时间），Namenode将退出安全模式状态。接下来它会确定还有哪些 blocks 的副本没有达到指定数目，并将这些 blocks 复制到其他Datanode上。

## 六、The Persistence of File System Metadata

Namenode 上保存着 HDFS 的名字空间。**对于任何对文件系统元数据产生修改的操作，Namenode 都会使用一种称为 EditLog 的事务日志记录下来** 。例如，在 HDFS 中创建一个文件，Namenode 就会在 Editlog 中插入一条记录来表示；同样地，修改文件的副本系数也将往 Editlog 插入一条记录。Namenode在本地操作系统的文件系统中存储这个 Editlog。**整个文件系统的名字空间，包括数据块到文件的映射、文件系统的属性等，都存储在一个称为 FsImage 的文件中，这个文件也是放在 Namenode 所在的本地文件系统上。**

Namenode 在内存中保存着整个文件系统的名字空间和文件数据块映射(file Blockmap)的映像。**当 Namenode 启动，或触发 checkpoint 时，它从硬盘中读取 Editlog 和 FsImage，将所有 Editlog 中的事务作用在内存中的 FsImage 上，并将这个新版本的 FsImage 从内存中保存到本地磁盘上，然后删除旧的Editlog，因为这个旧的Editlog的事务都已经作用在 FsImage 上了。这个过程称为一个检查点(checkpoint)。** 通过获取文件系统元数据的快照并将其保存到 FsImage 中，使得 HDFS 对文件系统元数据具有一致的视图。尽管读取一个 FsImage 是高效的，但是直接对一个 FsImage 进行增量编辑是低效的。我们 **不会每次编辑都修改 FsImage，而是将编辑记录保存在 Editlog 中，在 checkpoint 期间，便会把 Editlog 的变化作用在 FsImage。** checkpoint 可以在 **给定的时间间隔(dfs.namenode.checkpoint.period，以秒表示)** 被触发，或者在给定的 **文件系统事务数量达到一定的累计值(dfs.namenode.checkpoint.txns)**。如果这两种属性都设置了，将会使用设置的第一个阈值来触发 checkpoint。

Datanode 将 HDFS 数据以文件的形式存储在本地文件系统中，它并不知道有关 HDFS 文件的信息。它把 **每个 HDFS block 存储在本地文件系统的一个单独的文件中**。Datanode 并不在同一个目录创建所有的文件，实际上，它用试探的方法来确定每个目录的最佳文件数目，并且在适当的时候创建子目录。在同一个目录中创建所有的本地文件并不是最优的选择，这是因为本地文件系统可能无法高效地在单个目录中支持大量的文件。**当一个 Datanode 启动时，它会扫描本地文件系统，产生一个这些本地文件对应的所有 HDFS 数据块的列表，然后作为报告发送到 Namenode，这个报告就是块状态报告(Blockreport)**。

## 七、The Communication Protocols

所有的HDFS通讯协议都是建立在TCP/IP协议之上。客户端通过一个可配置的TCP端口连接到 Namenode，通过 ClientProtocol 协议与 Namenode 交互。而 Datanode 使用 DatanodeProtocol 协议与 Namenode 交互。一个远程过程调用(RPC)模型被抽象出来封装 ClientProtocol 和 Datanodeprotocol 协议。在设计上，Namenode 不会主动发起RPC，而是响应来自客户端或 Datanode 的 RPC 请求。

## 八、Robustness

HDFS的主要目标就是即使在出错的情况下也要保证数据存储的可靠性。**常见的三种出错情况是：Namenode出错, Datanode出错和网络割裂(network partitions)**。

### Data Disk Failure, Heartbeats and Re-Replication 磁盘数据错误，心跳检测和重新复制

每个 Datanode 节点周期性地向 Namenode 发送心跳信号。网络割裂可能导致一部分 Datanode 跟 Namenode 失去联系。Namenode 通过心跳信号的缺失来检测这一情况，并将这些近期不再发送心跳信号 Datanode 标记为宕机，不会再将新的 IO 请求发给它们。任何存储在宕机 Datanode 上的数据将不再有效。**Datanode 的宕机可能会引起一些数据块的副本系数低于指定值，Namenode 不断地检测这些需要复制的数据块，一旦发现就启动复制操作**。在下列情况下，可能需要重新复制：**某个 Datanode 节点失效，某个副本遭到损坏，Datanode 上的硬盘错误，或者文件的副本系数增大**。

保守地说，标记 datanode 为宕机的时间很长(默认超过10分钟)，以避免由于 datanode 的状态变化而导致频繁复制。对于性能敏感的工作负载，用户可以通过设置缩短 datanode 为宕机的时间，并避免将数据读取 和/或 写入宕机的节点。

### Cluster Rebalancing 集群均衡

HDFS 的架构支持 **数据均衡策略**。如果某个 Datanode 节点上的空闲空间低于特定的临界点，按照均衡策略系统就会自动地将数据从这个 Datanode 移动到其他空闲的 Datanode。当对某个文件的请求突然增加，那么就自动创建该文件新的副本，并且同时重新平衡集群中的其他数据。这些均衡策略目前还没有实现。

### Data Integrity 数据完整性

从某个 Datanode 获取的 block 有可能是损坏的，原因可能是 Datanode 的存储设备错误、网络错误或者软件bug。HDFS 客户端软件实现了对 HDFS 文件内容的 **校验和(checksum)检查。当客户端创建一个新的 HDFS 文件，会计算这个文件每个数据块的校验和，并将校验和作为一个单独的隐藏文件保存在同一个HDFS名字空间下。当客户端获取文件内容后，它会检验从 Datanode 获取的数据 跟相应的校验和文件中的校验和 是否匹配，如果不匹配，客户端可以选择从其他 Datanode 获取该数据块的副本。**

### Metadata Disk Failure 元数据磁盘错误

FsImage 和 Editlog 是 HDFS 的核心数据结构。如果这些文件损坏了，整个 HDFS 实例都将失效。因而，**Namenode 可以配置成支持维护多个 FsImage 和 Editlog 的副本**。任何对 FsImage 或者 Editlog 的修改，都将同步到它们的副本上。这种多副本的同步操作可能会降低 Namenode 每秒处理的名字空间事务数量。然而这个代价是可以接受的，因为即使 HDFS 的应用是数据密集的，它们的元数据也是非密集的。当 Namenode 重启的时候，它会选取最近的完整的 FsImage 和 Editlog 来使用。

提高抗故障弹性另一个的措施就是 **通过设置多个 NameNodes 实现高可用性，要么基于 NFS 实现共享存储，要么使用一个分布式的 Edit log(Journal)。后者是推荐的方法**。

### Snapshots 快照

快照支持某一特定时刻的数据的备份。利用快照，可以让 HDFS 在数据损坏时恢复到过去一个已知正确的时间点。

## 九、Data Organization

### Data Blocks

HDFS 被设计成支持大文件，适用 HDFS 的是那些需要处理大规模的数据集的应用程序。这些应用程序都是只写入数据一次，但却读取一次或多次，并且读取速度应能满足流式读取的需要。HDFS 支持文件的“一次写入多次读取”语义。一个典型的 **数据块大小是 128MB**。因而，an HDFS file is chopped up into 128 MB chunks, and if possible, each chunk will reside on a different DataNode.

## Replication Pipelining

当客户端向 HDFS 文件写入数据的时候，假设该文件的副本系数设置为3，**Namenode 使用副本目标选择算法获取一个 Datanode 列表。这个列表包含了持有 block 副本的 datanodes。然后客户端开始向第一个 Datanode 传输数据，第一个Datanode一小部分一小部分地接收数据，将每一部分写入本地仓库，并同时传输该部分到列表中第二个 Datanode 节点。第二个Datanode也是这样，一小部分一小部分地接收数据，写入本地仓库，并同时传给第三个 Datanode。最后，第三个 Datanode 接收数据并存储在本地。** 因此，Datanode 能流水线式地从前一个节点接收数据，并在同时转发给下一个节点，数据以流水线的方式从前一个 Datanode 复制到下一个。

## 十、Accessibility

HDFS给应用提供了多种访问方式。用户可以通过Java API接口访问，也可以通过C语言的封装API访问，还可以通过浏览器的方式访问HDFS中的文件。 **通过使用NFS 网关，可以将 HDFS 挂载为客户端本地文件系统的一部分。**

### DFSShell

HDFS 以文件和目录的形式组织用户数据。它提供了一个命令行的接口(DFSShell)让用户与HDFS中的数据进行交互。命令的语法和用户熟悉的其他shell(例如 bash, csh)工具类似。下面是一些动作/命令的示例：

动作|命令
---|:--:
创建一个名为 /foodir 的目录|bin/hadoop dfs -mkdir /foodir
移除一个名为 /foodir 的目录|bin/hadoop fs -rm -R /foodir
查看名为 /foodir/myfile.txt 的文件内容|bin/hadoop dfs -cat /foodir/myfile.txt

DFSShell 可以用在那些通过脚本语言和文件系统进行交互的应用程序上。

### DFSAdmin

DFSAdmin 命令用来管理HDFS集群。这些命令只有HDSF的管理员才能使用。下面是一些动作/命令的示例：

动作|命令
---|:--:
将集群置于安全模式|bin/hadoop dfsadmin -safemode enter
显示Datanode列表|bin/hadoop dfsadmin -report
使Datanode节点 失效或生效|bin/hadoop dfsadmin -refreshNodes

### 浏览器接口

一个典型的HDFS安装会在一个可配置的TCP端口开启一个Web服务器用于暴露HDFS的名字空间。用户可以用浏览器来浏览HDFS的名字空间和查看文件的内容。

## 十一、Space Reclamation 存储空间回收

### 文件的删除和恢复

**启用trash后，当用户或应用程序通过 FS Shell 删除某个文件时，这个文件并没有立刻从HDFS中删除。实际上，HDFS会将这个文件重命名转移到/trash目录**。只要文件还在/trash目录中，该文件就可以被迅速地恢复。（每个用户都有自己的trash目录/user/<username>/.Trash）。文件在/trash中保存的时间是可配置的，当超过这个时间时，Namenode就会将该文件从名字空间中删除。删除文件会使得该文件相关的数据块被释放。注意，从用户删除文件到HDFS空闲空间的增加之间会有一定时间的延迟。

在配置的时间间隔内，HDFS 会在trash 目录下为文件创建 checkpoints(/user/<username>/.Trash/<date>)，当它们失效时，就会删除旧的 checkpoints。See expunge command of FS shell about checkpointing of trash.

在trash中的生命周期结束后，NameNode 就会从名字空间删除文件。删除文件会释放与该文件关联的块。注意，在用户删除文件的时间和HDFS中空闲空间相应增加的时间之间可能存在明显的时间延迟。

下面就是如何删除文件的实例：

```
$ hadoop fs -mkdir -p delete/test1
$ hadoop fs -mkdir -p delete/test2
$ hadoop fs -ls delete/
Found 2 items
drwxr-xr-x   - hadoop hadoop          0 2015-05-08 12:39 delete/test1
drwxr-xr-x   - hadoop hadoop          0 2015-05-08 12:40 delete/test2
```
```
$ hadoop fs -rm -r delete/test1
Moved: hdfs://localhost:8020/user/hadoop/delete/test1 to trash at: hdfs://localhost:8020/user/hadoop/.Trash/Current
```
```
$ hadoop fs -rm -r -skipTrash delete/test2
Deleted delete/test2
```
```
$ hadoop fs -ls .Trash/Current/user/hadoop/delete/
Found 1 items\
drwxr-xr-x   - hadoop hadoop          0 2015-05-08 12:39 .Trash/Current/user/hadoop/delete/test1
```
### 减少副本系数

当一个文件的副本系数被减小后，Namenode 会选择过剩的副本删除。下次心跳检测时会将该信息传递给Datanode。Datanode遂即移除相应的 blocks，集群中的空闲空间加大。同样，在调用setReplication API结束和集群中空闲空间增加间会有一定的延迟。
