# Avro-Source

[TOC]

## 1、基本功能测试

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-avro-source.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = avro
a1.sources.r1.bind = zgg
a1.sources.r1.port = 44444

# Describe the sink
a1.sinks.k1.type = hdfs
a1.sinks.k1.hdfs.path = /flume-out/avro-source/%y%m%d-%H%M
a1.sinks.k1.hdfs.fileType = DataStream
a1.sinks.k1.hdfs.filePrefix = events-
a1.sinks.k1.hdfs.round = true
a1.sinks.k1.hdfs.roundValue = 2
a1.sinks.k1.hdfs.roundUnit = minute
a1.sinks.k1.hdfs.useLocalTimeStamp = true

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 100

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-avro-source.conf --name a1 -Dflume.root.logger=INFO,console
....
2021-01-14 12:53:18,246 (lifecycleSupervisor-1-1) [INFO - org.apache.flume.source.AvroSource.start(AvroSource.java:219)] Avro source r1 started.

# 启动 Avro 客户端，读取日志数据
[root@zgg flume-1.9.0]# bin/flume-ng avro-client -c conf -H zgg -p 44444 -F /root/data/hadoop-root-namenode-zgg.log

# hdfs 上查看结果
[root@zgg data]# hadoop fs -ls /flume-out/avro-source/210114-1254
Found 5 items
-rw-r--r--   1 root supergroup      17155 2021-01-14 12:55 /flume-out/avro-source/210114-1254/events-.1610600107071
-rw-r--r--   1 root supergroup       1108 2021-01-14 12:55 /flume-out/avro-source/210114-1254/events-.1610600107072
-rw-r--r--   1 root supergroup       1111 2021-01-14 12:55 /flume-out/avro-source/210114-1254/events-.1610600107073
-rw-r--r--   1 root supergroup       1101 2021-01-14 12:55 /flume-out/avro-source/210114-1254/events-.1610600107074
-rw-r--r--   1 root supergroup        877 2021-01-14 12:55 /flume-out/avro-source/210114-1254/events-.1610600107075

[root@zgg data]# hadoop fs -text /flume-out/avro-source/210114-1254/events-.1610600107075
2021-01-14 12:56:08,202 INFO sasl.SaslDataTransferClient: SASL encryption trust check: localHostTrusted = false, remoteHostTrusted = false
.....
```