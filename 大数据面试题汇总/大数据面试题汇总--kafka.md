# 大数据面试题汇总--kafka

[TOC]

## Flume和kafka的区别

Flume 是一个分布式的海量日志采集、传输系统，可以使用拦截器Interceptor屏蔽或过滤数据。
【基础组件有source、channel、sink】

Kafka 是一个分布式消息系统，用作中间件，缓存数据。

【生产者发布数据到一个或者多个 topic，消费者订阅一个或多个 topic ，并且对发布给他们的流式数据进行处理。】

Flume 不支持副本策略。当 Flume 的一个节点宕机了，会丢失这些数据，而 kafka 则支持副本策略。

比较流行 flume+kafka 模式，如果为了利用 flume 写 hdfs 的能力，也可以采用 kafka+flume 的方式。

扩展阅读：[flume，kafka区别、协同与详解](https://my.oschina.net/u/2996334/blog/3059293)

[flume和kafka区别](https://www.leiue.com/flume-vs-kafka)

## kafka如何记录（存储）数据

(1)假设实验环境中Kafka集群只有一个broker，xxx/message-folder为数据文件存储根目录

创建2个topic名称分别为report_push、launch_info, partitions数量都为partitions=4

存储路径和目录规则为：xxx/message-folder

	  |--report_push-0
	  |--report_push-1
	  |--report_push-2
	  |--report_push-3
	  |--launch_info-0
	  |--launch_info-1
	  |--launch_info-2
	  |--launch_info-3

在Kafka文件存储中，同一个topic下有多个不同partition，每个partition为一个目录。

partiton命名规则为 `topic名称+有序序号`，第一个partiton序号从0开始，序号最大值为partitions数量减1。

(2)每个partition(目录)相当于一个巨型文件被平均分配到多个大小相等segment file中。

![kafka01](./image/kafka01.png)

(3)segment file组成：由index file和data file组成，此2个文件一一对应，成对出现，分别表示为segment索引文件、数据文件.

![kafka02](./image/kafka02.png)

(4)以上图中一对segment file文件为例，说明segment中index<—->data file对应关系物理结构如下：

说明：index中的1,0。对应log中的文件个数和offset

![kafka03](./image/kafka03.png)

其中以索引文件中元数据3,497为例，依次在数据文件中表示第3个message(在全局partiton表示第368772个message)、以及该消息的物理偏移地址为497。

以下具体说明message物理结构例如以下：

![kafka04](./image/kafka04.png)

> message参数说明

关键字 | 解释说明
---|:---
8 byte offset | 在parition(分区)内的每条消息都有一个有序的id号，这个id号被称为偏移(offset),它可以唯一确定每条消息在parition(分区)内的位置。即offset表示partiion的第多少message
4 byte message size | message大小
4 byte CRC32 | 用crc32校验message
1 byte “magic" | 表示本次发布Kafka服务程序协议版本号
1 byte “attributes" | 表示为独立版本、或标识压缩类型、或编码类型。
4 byte key length | 表示key的长度,当key为-1时，K byte key字段不填
K byte key | 可选
value bytes payload	 | 表示实际消息数据。


原文链接：[Kafka文件的存储机制](https://blog.csdn.net/silentwolfyh/article/details/55095146)

## 解释kafka的lead和follower

如果 Kafka topic 的分区有 N 个副本，这 N 个副本中，其中一个为 leader ，其他都为 follower ，leader 处理分区的所有读写请求，follower 可以作为普通的消费者从 leader 中消费消息并应用到自己的日志中，也允许 follower 从 leader 拉取批量日志应用到自己的日志。

follower 的日志完全等同于 leader 的日志，即相同的顺序、相同的偏移量和消息（当然，在任何一个时间点上，leader 比 follower 多几条消息，尚未同步到follower）

如果 leader 故障了，那么就需要从 follower 中选举新的 leader，但是 follower 
自己可能落后或崩溃，所以我们必须选择一个最新的 follower。

一台服务器可能同时是一个分区的leader，另一个分区的follower。

leader 选举：

Kafka 的 leader 选举是通过在 zookeeper 上创建 controller临时节点来实现的，并在该节点中写入当前 broker 的信息 

    {“version”:1,”brokerid”:1,”timestamp”:”1512018424988”} 

利用 Zookeeper 的强一致性特性，一个节点只能被一个客户端创建成功，创建成功的 broker 即为 leader，即先到先得原则，leader 也就是集群中的 controller，负责集群中所有大小事务。 

当 leader 和 zookeeper 失去连接时，临时节点会删除，而其他 broker 会监听该节点的变化，当节点删除时，其他 broker 会收到事件通知，重新发起 leader 选举。

## kafka数据倾斜

一般由于生产者的分区分的不均匀，可以从 Producer 入手，弄清楚 Producer 生成的 Msg，是如何选择传输到哪个 Partition 的。再根据实际情况，设置 key ，可以设置 key 为随机数。

## kafka分区

Topic 是发布的消息的类别名，一个 topic 可以有零个，一个或多个消费者订阅该主题的消息。

对于每个 topic，Kafka 集群都会维护一个分区 log，就像下图中所示：

![spark10](./image/spark10.png)

每一个分区都是一个顺序的、不可变的消息队列， 并且可以持续的添加。分区中的消息都被分了一个序列号，称之为偏移量(offset)，在每个分区中此偏移量都是唯一的。

Kafka集群保持所有的消息，直到它们过期（无论消息是否被消费）。实际上消费者所持有的仅有的元数据就是这个offset（偏移量）。

也就是说offset由消费者来控制：正常情况当消费者消费消息的时候，偏移量也线性的的增加。但是实际偏移量由消费者控制，消费者可以将偏移量重置为更早的位置，重新读取消息。

可以看到这种设计对消费者来说操作自如，一个消费者的操作不会影响其它消费者对此log的处理。

Kafka中采用分区的设计有几个目的。一是可以处理更多的消息，不受单台服务器的限制。Topic拥有多个分区意味着它可以不受限的处理更多的数据。第二，分区可以作为并行处理的单元。

## Kafka元数据存在哪

MetadataCache 组件

在每个 Broker 的 KafkaServer 对象中都会创建 MetadataCache 组件, 负责缓存所有的 metadata 信息;
```scala
val metadataCache: MetadataCache = new MetadataCache(config.brokerId)
```

所有的metadata信息存储在map里, key是topic, value又是一个map, 其中key是parition id, value是PartitionStateInfo

```scala
private val cache: mutable.Map[String, mutable.Map[Int, PartitionStateInfo]] =
    new mutable.HashMap[String, mutable.Map[Int, PartitionStateInfo]]()
```

原文链接：[MetadataCache](https://zhuanlan.zhihu.com/p/50839869)

## Kafka用途

### 1、kafka作为一个消息系统

kafka中消费者组有两个概念：队列：消费者组允许同名的消费者组成员瓜分处理。发布订阅：允许你广播消息给多个消费者组（不同名）。

有比传统的消息系统更强的顺序保证。

通过并行topic的parition —— kafka提供了顺序保证和负载均衡。每个partition仅由同一个消费者组中的一个消费者消费到。并确保消费者是该partition的唯一消费者，并按顺序消费数据。每个topic有多个分区，则需要对多个消费者做负载均衡，但请注意，相同的消费者组中不能有比分区更多的消费者，否则多出的消费者一直处于空等待，不会收到消息。

### 2、kafka作为一个存储系统

任何允许发布消息而不消费消息的消息队列都可以有效地充当未被消费的消息的存储系统。

写入到kafka的数据将写到磁盘并复制到集群中保证容错性。并允许生产者等待消息应答，直到消息完全写入。

kafka的磁盘结构 - 无论你服务器上有50KB或50TB，执行是相同的。

client来控制读取数据的位置。你还可以认为kafka是一种专用于高性能，低延迟，提交日志存储，复制，和传播特殊用途的分布式文件系统。

### 3、流处理

在kafka中，流处理持续获取输入topic的数据，进行处理加工，然后写入输出topic。例如，一个零售APP，接收销售和出货的输入流，统计数量或调整价格后输出。

可以直接使用producer和consumer API进行简单的处理。对于复杂的转换，Kafka提供了更强大的Streams API。可构建聚合计算或连接流到一起的复杂应用程序。

Sterams API在Kafka中的核心：使用producer和consumer API作为输入，利用Kafka做状态存储，使用相同的组机制在stream处理器实例之间进行容错保障。