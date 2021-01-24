# Exec-Source

[TOC]

## 1、基本功能测试

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-exec-source.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = exec
a1.sources.r1.command = tail -F /root/data/hadoop-root-namenode-zgg.log

# Describe the sink
a1.sinks.k1.type = hdfs
a1.sinks.k1.hdfs.path = /flume-out/exec-source/%y%m%d-%H%M
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
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-exec-source.conf --name a1 -Dflume.root.logger=INFO,console

# hdfs 上查看结果
[root@zgg data]# hadoop fs -ls /flume-out/exec-source/210114-1346
Found 4 items
-rw-r--r--   1 root supergroup       1072 2021-01-14 13:46 /flume-out/avro-source/210114-1346/events-.1610603183169
-rw-r--r--   1 root supergroup        877 2021-01-14 13:46 /flume-out/avro-source/210114-1346/events-.1610603183170
-rw-r--r--   1 root supergroup       1072 2021-01-14 13:46 /flume-out/avro-source/210114-1346/events-.1610603216540
-rw-r--r--   1 root supergroup        877 2021-01-14 13:47 /flume-out/avro-source/210114-1346/events-.1610603216541

[root@zgg data]# hadoop fs -text /flume-out/exec-source/210114-1346/events-.1610603216541
2021-01-14 13:48:14,420 INFO sasl.SaslDataTransferClient: SASL encryption trust check: localHostTrusted = false, remoteHostTrusted = false
```

## 2、shell配置测试

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-exec-source-shell.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = exec
a1.sources.r1.shell = /bin/bash -c
a1.sources.r1.command = for i in /root/data/order-*.txt; do cat $i; done

# Describe the sink
a1.sinks.k1.type = hdfs
a1.sinks.k1.hdfs.path = /flume-out/exec-source/%y%m%d-%H%M
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

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-exec-source-shell.conf --name a1 -Dflume.root.logger=INFO,console

# hdfs 上查看结果
[root@zgg data]# hadoop fs -ls /flume-out/exec-source/210114-1352
Found 2 items
-rw-r--r--   1 root supergroup        139 2021-01-14 13:53 /flume-out/exec-source/210114-1352/events-.1610603629126
-rw-r--r--   1 root supergroup         90 2021-01-14 13:54 /flume-out/exec-source/210114-1352/events-.1610603629127
[root@zgg data]# hadoop fs -text /flume-out/exec-source/210114-1352/events-.1610603629126
....
1       bicycle 1000
2       truck   20000
1       cellphone       2000
....
```