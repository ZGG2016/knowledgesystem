# Kafka-Source

[TOC]

## 1、基本功能测试

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-Kafka-source.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = org.apache.flume.source.kafka.KafkaSource
a1.sources.r1.kafka.bootstrap.servers = zgg:9092
a1.sources.r1.kafka.topics = kafkasource

# Describe the sink
a1.sinks.k1.type = logger

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 5000
a1.channels.c1.transactionCapacity = 1000

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

# 启动 kafka
bin/kafka-server-start.sh config/server.properties >logs/kafka.log 2>1 & 

# 创建 topic
bin/kafka-topics.sh --create --zookeeper zgg:2181 --replication-factor 1 --partitions 1 --topic kafkasource

# 启动kafka生产者
[root@zgg kafka_2.12-2.6.0]# bin/kafka-console-producer.sh --broker-list zgg:9092 --topic kafkasource
>aaaaaaaaaaaaaaa
>bbbbbbbbbbbbbbb
>

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-Kafka-source.conf --name a1 -Dflume.root.logger=INFO,console
....
2021-01-15 13:33:04,687 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{topic=kafkasource, partition=0, offset=0, timestamp=1610688782833} body: 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61    aaaaaaaaaaaaaaa }
2021-01-15 13:33:13,856 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{topic=kafkasource, partition=0, offset=1, timestamp=1610688792860} body: 62 62 62 62 62 62 62 62 62 62 62 62 62 62 62    bbbbbbbbbbbbbbb }

# 再创建一个 topic
[root@zgg kafka_2.12-2.6.0]# bin/kafka-topics.sh --create --zookeeper zgg:2181 --replication-factor 1 --partitions 1 --topic kafkasource02
Created topic kafkasource02.

# 修改下 topic 的匹配规则
[root@zgg flume-1.9.0]# vi jobs/flume-Kafka-source.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = org.apache.flume.source.kafka.KafkaSource
a1.sources.r1.kafka.bootstrap.servers = zgg:9092
# a1.sources.r1.kafka.topics = kafkasource,kafkasource02
a1.sources.r1.kafka.topics = kafkasource[0-9][0-9]
a1.sources.r1..kafka.consumer.group.id = kafkasource.g.id

# Describe the sink
a1.sinks.k1.type = logger

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 5000
a1.channels.c1.transactionCapacity = 1000

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

[root@zgg kafka_2.12-2.6.0]# bin/kafka-console-producer.sh --broker-list zgg:9092 --topic kafkasource
>aaaaaaaaaaaaaaaa
>

[root@zgg kafka_2.12-2.6.0]# bin/kafka-console-producer.sh --broker-list zgg:9092 --topic kafkasource02
>bbbbbbbbbbbbbb
>

# 启动 Flume 任务，查看输出
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-Kafka-source.conf --name a1 -Dflume.root.logger=INFO,console
.....
2021-01-15 13:53:49,203 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{topic=kafkasource02, partition=0, offset=6, timestamp=1610690023222} body: 62 62 62 62 62 62 62 62 62 62 62 62 62 62       bbbbbbbbbbbbbb }
```