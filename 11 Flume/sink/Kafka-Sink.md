# Kafka-Sink

```sh
# 分别往 kafkasinktest/ 目录下复制文件，kafka 消费者读取

[root@zgg flume-1.9.0]# vi jobs/flume-kafka-sink.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = spooldir
a1.sources.r1.spoolDir = /root/data/kafkasinktest
a1.sources.r1.fileHeader = true

# Describe the sink
a1.sinks.k1.type = org.apache.flume.sink.kafka.KafkaSink
a1.sinks.k1.kafka.bootstrap.servers = zgg:9092
a1.sinks.k1.kafka.topic = kafkasink
a1.sinks.k1.flumeBatchSize = 10
a1.sinks.k1.serializer.class = kafka.serializer.StringEncoder

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 200

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

# 数据文件
[root@zgg data]# cat weblogs-01.txt
1       "11111111111"
2       "22222222222"
3       "33333333333"
4       "44444444444"
5       "55555555555"
6       "66666666666"
7       "77777777777"
8       "88888888888"
9       "99999999999"
0       "00000000000"
[root@zgg data]# cat weblogs-02.txt
.....

# 分别执行如下命令将数据文件复制到监控目录 kafkasinktest/ 下 
[root@zgg data]# cp weblogs-01.txt kafkasinktest/
[root@zgg data]# cp weblogs-02.txt kafkasinktest/

# 建立 topic :kafkasink
[root@zgg kafka_2.12-2.6.0]# bin/kafka-topics.sh --create --zookeeper zgg:2181 --replication-factor 1 --partitions 1 --topic kafkasink
Created topic kafkasink.

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-kafka-sink.conf --name a1 -Dflume.root.logger=INFO,console

# 再启动一个 kafka 消费者
[root@zgg kafka_2.12-2.6.0]# bin/kafka-console-consumer.sh --bootstrap-server zgg:9092 --topic kafkasink --from-beginning
1       "11111111111"
2       "22222222222"
3       "33333333333"
4       "44444444444"
5       "55555555555"
6       "66666666666"
7       "77777777777"
8       "88888888888"
9       "99999999999"
0       "00000000000"
1       "11111111111"
2       "22222222222"
3       "33333333333"
4       "44444444444"
5       "55555555555"
6       "66666666666"
7       "77777777777"
8       "88888888888"
9       "99999999999"
0       "00000000000"
```

## 2、同时使用Kafka Source和Kafka Sink测试

`kafka.topic` 属性的部分描述：

If the event header contains a “topic” field, the event will be published to that topic overriding the topic configured here.【如果event header包含了topic字段，事件将被发布到到覆盖这里配置的topic的topic】

【topicHeader属性的作用还不太理解】

```sh
# 分别往 kafkasinktest/ 目录下复制文件，kafka 消费者读取
[root@zgg flume-1.9.0]# vi jobs/flume-kafka-sink-02.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
# 此source发出去的事件的header中包含了topic字段，所以这个topic字段的值会覆盖下面的kafkasink，
# 即数据仍然被写入到这个topic字段的值的topic（kafkasource）中
# 下面的一行日志是 Kafka-Source 示例的日志输出： 
# 	  headers:{topic=kafkasource, partition=0, offset=2, timestamp=1611228723642}
a1.sources.r1.type = org.apache.flume.source.kafka.KafkaSource
a1.sources.r1.kafka.bootstrap.servers = zgg:9092
a1.sources.r1.kafka.topics = kafkasource

# Describe the sink
a1.sinks.k1.type = org.apache.flume.sink.kafka.KafkaSink
a1.sinks.k1.kafka.bootstrap.servers = zgg:9092
a1.sinks.k1.kafka.topic = kafkasink
a1.sinks.k1.flumeBatchSize = 10
a1.sinks.k1.serializer.class = kafka.serializer.StringEncoder

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 200

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

# 建立 topic :kafkasink
[root@zgg kafka_2.12-2.6.0]# bin/kafka-topics.sh --create --zookeeper zgg:2181 --replication-factor 1 --partitions 1 --topic kafkasink
Created topic kafkasink.

# 建立 topic :kafkasource
[root@zgg kafka_2.12-2.6.0]# bin/kafka-topics.sh --create --zookeeper zgg:2181 --replication-factor 1 --partitions 1 --topic kafkasource
Created topic kafkasource.

# 发出输入数据
[root@zgg kafka_2.12-2.6.0]# bin/kafka-console-producer.sh --broker-list zgg:9092 --topic kafkasource
>aaaaaaaaaaaa

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-kafka-sink-02.conf --name a1 -Dflume.root.logger=INFO,console

# 启动一个针对 kafkasink 的 kafka 消费者
[root@zgg kafka_2.12-2.6.0]# bin/kafka-console-consumer.sh --bootstrap-server zgg:9092 --topic kafkasink --from-beginning

# 启动一个针对 kafkasource 的 kafka 消费者
[root@zgg kafka_2.12-2.6.0]# bin/kafka-console-consumer.sh --bootstrap-server zgg:9092 --topic kafkasource --from-beginning
aaaaaaaaaaaa
```

如何解决：[https://blog.csdn.net/qq_40309183/article/details/103922558](https://blog.csdn.net/qq_40309183/article/details/103922558)