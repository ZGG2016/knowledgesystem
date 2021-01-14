# Spooldir-Source

## 1、基本功能测试

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-spooldir-source.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = spooldir
a1.sources.r1.spoolDir = /root/data/spooldirtest
a1.sources.r1.fileHeader = true

# Describe the sink
a1.sinks.k1.type = hdfs
a1.sinks.k1.hdfs.path = /flume-out/spooldir-source/%y%m%d-%H%M
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
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-spooldir-source.conf --name a1 -Dflume.root.logger=INFO,console

# 往复制一个文件
[root@zgg data]# cp apps.txt spooldirtest/

# hdfs 上查看结果
[root@zgg data]# hadoop fs -ls /flume-out/spooldir-source/210114-1518
Found 1 items
-rw-r--r--   1 root supergroup        254 2021-01-14 15:19 /flume-out/spooldir-source/210114-1518/events-.1610608752157
[root@zgg data]# hadoop fs -text /flume-out/spooldir-source/210114-1518/events-.1610608752157
.....
1,'QQ APP','http://im.qq.com/','CN'
2,'微博 APP','http://weibo.com/','CN'
3,'淘宝 APP','https://www.taobao.com/','CN'
4,'FACEBOOK APP','https://www.facebook.com/','USA'
5,'GOOGLE','https://www.google.com/','USA'
6,'LINE','https://www.line.com/','JP'

# 查看 spooldirtest/ 目录
[root@zgg data]# ls spooldirtest/
apps.txt.COMPLETED
```

## 2、includePattern、ignorePattern 配置测试

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-spooldir-pattern-source.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = spooldir
a1.sources.r1.spoolDir = /root/data/spooldirtest
a1.sources.r1.fileHeader = true
a1.sources.r1.includePattern = .+.txt
a1.sources.r1.ignorePattern = .+.csv

# Describe the sink
a1.sinks.k1.type = hdfs
a1.sinks.k1.hdfs.path = /flume-out/spooldir-source/%y%m%d-%H%M
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
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-spooldir-pattern-source.conf --name a1 -Dflume.root.logger=INFO,console

# 数据文件
[root@zgg data]# cat spool.csv
1,aa,25
2,bb,20
3,cc,12
[root@zgg data]# cat spool.txt
4,dd,44
5,ee,65
6,ff,12

# 往 spooldirtest/ 复制
[root@zgg data]# cp spool.csv spool.txt spooldirtest/

# 查看 spooldirtest/ 目录
[root@zgg data]# ls spooldirtest/
apps.txt.COMPLETED  spool.csv  spool.txt.COMPLETED
```

## 3、deserializer 配置测试

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-spooldir-deserializer-source.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = spooldir
a1.sources.r1.spoolDir = /root/data/spooldirtest
a1.sources.r1.fileHeader = true
a1.sources.r1.deserializer = Avro 
a1.sources.r1.deserializer.schemaType = HASH

# Describe the sink
a1.sinks.k1.type = logger

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 100

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

# 数据文件
# [root@zgg data]# cat users.avro
# Objavro.schematype": "record", "namespace": "example.avro", "name": "User", "fields": [{"type": "string", "name": "name"}, {"type": ["string", "null"], "name": "favorite_color"}, {"type": {"items": "int", "type": "array"}, "name": "favorite_numbers"}]}avro.codenullnB;{/0
#       Alyss(BenrednB;{/]0;root@zgg:~/data

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-spooldir-deserializer-source.conf --name a1 -Dflume.root.logger=INFO,console
....
2021-01-14 15:45:53,848 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{file=/root/data/spooldirtest/users.avro, flume.avro.schema.hash=613aba24037ec69a} body: 0C 41 6C 79 73 73 61 02 08 06 12 1E 28 00       .Alyssa.....(. }
2021-01-14 15:45:53,848 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{file=/root/data/spooldirtest/users.avro, flume.avro.schema.hash=613aba24037ec69a} body: 06 42 65 6E 00 06 72 65 64 00                   .Ben..red. }

```