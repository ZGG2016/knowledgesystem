# Kafka-Channel

和 Flume sink 一起使用：这是一种以低延迟，容错的方式将 events 从 Kafka 发送到 Flume sink，如 HDFS、HBase 或 Solr

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-kafka-channel.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = netcat
a1.sources.r1.bind = localhost
a1.sources.r1.port = 44444

# Describe the sink
a1.sinks.k1.type = hdfs
a1.sinks.k1.hdfs.path = /flume-out/kafka-channel/%y%m%d-%H%M
a1.sinks.k1.hdfs.fileType = DataStream
a1.sinks.k1.hdfs.filePrefix = events-
a1.sinks.k1.hdfs.round = true
a1.sinks.k1.hdfs.roundValue = 5
a1.sinks.k1.hdfs.roundUnit = second
a1.sinks.k1.hdfs.useLocalTimeStamp = true

# Use a channel which buffers events in memory
a1.channels.c1.type = org.apache.flume.channel.kafka.KafkaChannel
a1.channels.c1.kafka.bootstrap.servers = zgg:9092
a1.channels.c1.kafka.topic = kafkachannel
a1.channels.c1.kafka.consumer.group.id = flumekafkachannel.g.id

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-kafka-channel.conf --name a1 -Dflume.root.logger=INFO,console
....

# 打开另一个shell，输入：
[root@zgg data]# telnet localhost 44444
Trying ::1...
telnet: connect to address ::1: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
aaaaaaaaaaaaaaaa
OK
bbbbbbbbbbbbbbbb
OK

# hdfs上查看
[root@zgg kafka_2.12-2.6.0]# hadoop fs -ls /flume-out/kafka-channel
Found 2 items
drwxr-xr-x   - root supergroup          0 2021-01-17 13:34 /flume-out/kafka-channel/210117-1333
drwxr-xr-x   - root supergroup          0 2021-01-17 13:35 /flume-out/kafka-channel/210117-1335

[root@zgg kafka_2.12-2.6.0]# hadoop fs -text /flume-out/kafka-channel/210117-1333/events-.1610861638678
.....
aaaaaaaaaaaaaaaa

[root@zgg kafka_2.12-2.6.0]# hadoop fs -text /flume-out/kafka-channel/210117-1335/events-.1610861702273
.....
bbbbbbbbbbbbbbbb

# 启动一个消费者查看
[root@zgg kafka_2.12-2.6.0]# bin/kafka-console-consumer.sh --bootstrap-server zgg:9092 --topic kafkachannel --from-beginning 
"aaaaaaaaaaaaaaaa
"bbbbbbbbbbbbbbbb
```