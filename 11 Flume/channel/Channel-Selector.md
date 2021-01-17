# Channel-Selector

[TOC]

## 1、Replicating Channel Selector 

将 source 发过来的 events 发往所有 channel

			-->  channel1  --> sink1
	source
			-->  channel2  --> sink2

	--------------------------------------------------

			-->  memory  --> logger
	netcat		
			-->  file  --> hdfs

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-replicating-selector.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1 k2
a1.channels = c1 c2

# Describe/configure the source
a1.sources.r1.type = netcat
a1.sources.r1.bind = localhost
a1.sources.r1.port = 44444
a1.sources.r1.selector.type = replicating

# sink1:k1
a1.sinks.k1.type = logger

# sink2:k2
a1.sinks.k2.type = hdfs
a1.sinks.k2.hdfs.path = /flume-out/replicating-selector/%y%m%d-%H%M
a1.sinks.k2.hdfs.fileType = DataStream
a1.sinks.k2.hdfs.filePrefix = events-
a1.sinks.k2.hdfs.round = true
a1.sinks.k2.hdfs.roundValue = 2
a1.sinks.k2.hdfs.roundUnit = minute
a1.sinks.k2.hdfs.useLocalTimeStamp = true

# channel1:c1: memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 5000
a1.channels.c1.transactionCapacity = 1000

# channel2:c2: file
a1.channels.c2.type = file
a1.channels.c2.checkpointDir = /opt/flume-1.9.0/file-channel/checkpoint
a1.channels.c2.checkpointInterval = 3000
a1.channels.c2.useDualCheckpoints = true
a1.channels.c2.backupCheckpointDir = /opt/flume-1.9.0/file-channel/checkpoint_backup
a1.channels.c2.dataDirs = /opt/flume-1.9.0/file-channel/data

# Bind the source and sink to the channel
a1.sources.r1.channels = c1 c2
a1.sinks.k1.channel = c1
a1.sinks.k2.channel = c2
----------------------------------------------------

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-replicating-selector.conf --name a1 -Dflume.root.logger=INFO,console
....
# -->  memory  --> logger
2021-01-17 17:20:58,750 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{} body: 61 61 61 61 61 61 61 61 61 61 61 61 61 0D       aaaaaaaaaaaaa. }
....
2021-01-17 17:21:02,753 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{} body: 62 62 62 62 62 62 62 62 62 62 62 62 62 62 0D    bbbbbbbbbbbbbb. }

# -->  file  --> hdfs
[root@zgg ~]# hadoop fs -text /flume-out/replicating-selector/210117-1720/events-.1610875262680
....
aaaaaaaaaaaaa
bbbbbbbbbbbbbb
```

## 2、Multiplexing Channel Selector

可以选择该发往哪些 channel

			-->  channel1  --> sink1
	source
			-->  channel2  --> sink2

	--------------------------------------------------

			-->  memory  --> logger
	http		
			-->  file    --> hdfs

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-multiplexing-selector.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1 k2
a1.channels = c1 c2

# Describe/configure the source
a1.sources.r1.type = http
a1.sources.r1.bind = zgg
a1.sources.r1.port = 44444
a1.sources.r1.selector.type = multiplexing
a1.sources.r1.selector.header = name
a1.sources.r1.selector.mapping.taobao = c1    # header=taobao的数据，进入c1
a1.sources.r1.selector.mapping.meituan = c2   # header=meituan的数据，进入c2
a1.sources.r1.selector.default = c1           # 默认进入c1

# sink1:k1
a1.sinks.k1.type = logger

# sink2:k2
a1.sinks.k2.type = hdfs
a1.sinks.k2.hdfs.path = /flume-out/multiplexing-selector/%y%m%d-%H%M
a1.sinks.k2.hdfs.fileType = DataStream
a1.sinks.k2.hdfs.filePrefix = events-
a1.sinks.k2.hdfs.round = true
a1.sinks.k2.hdfs.roundValue = 2
a1.sinks.k2.hdfs.roundUnit = minute
a1.sinks.k2.hdfs.useLocalTimeStamp = true

# channel1:c1: memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 5000
a1.channels.c1.transactionCapacity = 1000

# channel2:c2: file
a1.channels.c2.type = file
a1.channels.c2.checkpointDir = /opt/flume-1.9.0/file-channel/checkpoint
a1.channels.c2.checkpointInterval = 3000
a1.channels.c2.useDualCheckpoints = true
a1.channels.c2.backupCheckpointDir = /opt/flume-1.9.0/file-channel/checkpoint_backup
a1.channels.c2.dataDirs = /opt/flume-1.9.0/file-channel/data

# Bind the source and sink to the channel
a1.sources.r1.channels = c1 c2
a1.sinks.k1.channel = c1
a1.sinks.k2.channel = c2
----------------------------------------------------

# 发送数据
curl -X POST -d'[{"headers":{"name":"taobao"},"body":"this is taobao app"}]'  http://zgg:44444
curl -X POST -d'[{"headers":{"name":"meituan"},"body":"this is meituan app"}]'  http://zgg:44444

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-multiplexing-selector.conf --name a1 -Dflume.root.logger=INFO,console
....
# -->  memory  --> logger
2021-01-17 17:38:10,163 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{name=taobao} body: 74 68 69 73 20 69 73 20 74 61 6F 62 61 6F 20 61 this is taobao app }

# -->  file  --> hdfs
[root@zgg ~]# hadoop fs -text /flume-out/multiplexing-selector/210117-1738/events-.1610876308170
.....
this is meituan app
```

## 3、自定义 Selector

