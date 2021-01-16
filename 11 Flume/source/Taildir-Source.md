# Taildir-Source

[TOC]

## 1、基本功能测试

```sh
# 数据文件分布
[root@zgg data]# ls -R taildirtest
taildirtest:
dir1  dir2

taildirtest/dir1:
spool.csv

taildirtest/dir2:
spool.csv  spool.txt

# 文件内容
[root@zgg data]# cat taildirtest/dir2/spool.csv
1,aa,25
2,bb,20
3,cc,12
[root@zgg data]# cat taildirtest/dir2/spool.txt
4,dd,44
5,ee,65
6,ff,12
[root@zgg data]# cat taildirtest/dir1/spool.csv
1,aa,25
2,bb,20
3,cc,12

[root@zgg flume-1.9.0]# vi jobs/flume-taildir-source.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = TAILDIR
a1.sources.r1.positionFile = /opt/flume-1.9.0/jobs/taildir_position.json
a1.sources.r1.filegroups = f1 f2
a1.sources.r1.filegroups.f1 = /root/data/taildirtest/dir1/spool.csv
a1.sources.r1.headers.f1.headerKey1 = csv
a1.sources.r1.filegroups.f2 = /root/data/taildirtest/dir2/spool.*
a1.sources.r1.headers.f2.headerKey1 = csv
a1.sources.r1.headers.f2.headerKey2 = txt
a1.sources.r1.fileHeader = true
a1.sources.r1.maxBatchCount = 1000

# Describe the sink
a1.sinks.k1.type = hdfs
a1.sinks.k1.hdfs.path = /flume-out/taildir-source/%y%m%d-%H%M
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
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-taildir-source.conf --name a1 -Dflume.root.logger=INFO,console

# hdfs 上查看
[root@zgg data]# hadoop fs -ls /flume-out/taildir-source
Found 1 items
drwxr-xr-x   - root supergroup          0 2021-01-14 18:12 /flume-out/taildir-source/210114-1812

[root@zgg data]# hadoop fs -ls /flume-out/taildir-source/210114-1812
Found 1 items
-rw-r--r--   1 root supergroup         72 2021-01-14 18:12 /flume-out/taildir-source/210114-1812/events-.1610619129314

[root@zgg data]# hadoop fs -text /flume-out/taildir-source/210114-1812/events-.1610619129314
....
1,aa,25
2,bb,20
3,cc,12
1,aa,25
2,bb,20
3,cc,12
4,dd,44
5,ee,65
6,ff,12

# 查看 taildir_position.json
[root@zgg jobs]# cat taildir_position.json
[{"inode":18020743,"pos":24,"file":"/root/data/taildirtest/dir1/spool.csv"},{"inode":33719370,"pos":24,"file":"/root/data/taildirtest/dir2/spool.csv"},{"inode":33719371,"pos":24,"file":"/root/data/taildirtest/dir2/spool.txt"}]

# 此时上述 Flume 任务正在运行，现在向 dir1/spool.csv 追加一行数据。
[root@zgg data]# echo "4,dd,56" >>taildirtest/dir1/spool.csv

# 此任务会输出几行日志，然后查看 hdfs 的目录的结果
# 没有新建文件夹
[root@zgg data]# hadoop fs -ls /flume-out/taildir-source
Found 1 items
drwxr-xr-x   - root supergroup          0 2021-01-14 18:13 /flume-out/taildir-source/210114-1812

[root@zgg data]# hadoop fs -ls /flume-out/taildir-source/210114-1812
Found 2 items
-rw-r--r--   1 root supergroup         72 2021-01-14 18:12 /flume-out/taildir-source/210114-1812/events-.1610619129314
-rw-r--r--   1 root supergroup          8 2021-01-14 18:14 /flume-out/taildir-source/210114-1812/events-.1610619235541

[root@zgg data]# hadoop fs -text /flume-out/taildir-source/210114-1812/events-.1610619235541
.....
4,dd,56

# 查看 taildir_position.json，dir1/spool.csv 的 pos 更新了
[root@zgg jobs]# cat taildir_position.json
[{"inode":18020743,"pos":32,"file":"/root/data/taildirtest/dir1/spool.csv"},{"inode":33719370,"pos":24,"file":"/root/data/taildirtest/dir2/spool.csv"},{"inode":33719371,"pos":24,"file":"/root/data/taildirtest/dir2/spool.txt"}]

# 停止上述flume任务，再往 dir1/spool.csv 追加数据
[root@zgg data]# echo "5,ff,66" >>taildirtest/dir1/spool.csv  

# 再次启动上述任务，查看 hdfs 目录
# 新建了一个文件夹
[root@zgg data]# hadoop fs -ls /flume-out/taildir-source
Found 2 items
drwxr-xr-x   - root supergroup          0 2021-01-14 18:14 /flume-out/taildir-source/210114-1812
drwxr-xr-x   - root supergroup          0 2021-01-14 18:16 /flume-out/taildir-source/210114-1816

[root@zgg data]# hadoop fs -ls /flume-out/taildir-source/210114-1816
Found 1 items
-rw-r--r--   1 root supergroup          8 2021-01-14 18:17 /flume-out/taildir-source/210114-1816/events-.1610619412013

[root@zgg data]# hadoop fs -text /flume-out/taildir-source/210114-1816/events-.1610619412013
....
5,ff,66

# 查看 taildir_position.json，dir1/spool.csv 的 pos 增加到了 40，
# 在原来的基础上偏移了 8 个位置
[root@zgg jobs]# cat taildir_position.json
[{"inode":18020743,"pos":40,"file":"/root/data/taildirtest/dir1/spool.csv"},{"inode":33719370,"pos":24,"file":"/root/data/taildirtest/dir2/spool.csv"},{"inode":33719371,"pos":24,"file":"/root/data/taildirtest/dir2/spool.txt"}]
```

## 2、byteOffsetHeader 配置测试

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-taildir-header-source.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = TAILDIR
a1.sources.r1.positionFile = /opt/flume-1.9.0/jobs/taildir_position.json
a1.sources.r1.filegroups = f1 f2
a1.sources.r1.filegroups.f1 = /root/data/taildirtest/dir1/spool.csv
a1.sources.r1.headers.f1.headerKey1 = csv
a1.sources.r1.filegroups.f2 = /root/data/taildirtest/dir2/spool.*
a1.sources.r1.headers.f2.headerKey1 = csv
a1.sources.r1.headers.f2.headerKey2 = txt
a1.sources.r1.fileHeader = true
a1.sources.r1.maxBatchCount = 1000
a1.sources.r1.byteOffsetHeader = true

# Describe the sink
a1.sinks.k1.type = logger

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 100

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

--------------------------------------------------------

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-taildir-header-source.conf --name a1 -Dflume.root.logger=INFO,console
.....
2021-01-14 18:43:55,463 (lifecycleSupervisor-1-2) [INFO - org.apache.flume.instrumentation.MonitoredCounterGroup.start(MonitoredCounterGroup.java:95)] Component type: SOURCE, name: r1 started
2021-01-14 18:43:55,476 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{byteoffset=0, file=/root/data/taildirtest/dir1/spool.csv, headerKey1=csv} body: 31 2C 61 61 2C 32 35                            1,aa,25 }
2021-01-14 18:43:55,477 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{byteoffset=8, file=/root/data/taildirtest/dir1/spool.csv, headerKey1=csv} body: 32 2C 62 62 2C 32 30                            2,bb,20 }
2021-01-14 18:43:55,477 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{byteoffset=16, file=/root/data/taildirtest/dir1/spool.csv, headerKey1=csv} body: 33 2C 63 63 2C 31 32                            3,cc,12 }
2021-01-14 18:43:55,477 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{byteoffset=0, file=/root/data/taildirtest/dir2/spool.csv, headerKey1=csv, headerKey2=txt} body: 31 2C 61 61 2C 32 35                            1,aa,25 }
2021-01-14 18:43:55,477 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{byteoffset=8, file=/root/data/taildirtest/dir2/spool.csv, headerKey1=csv, headerKey2=txt} body: 32 2C 62 62 2C 32 30                            2,bb,20 }
2021-01-14 18:43:55,478 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{byteoffset=16, file=/root/data/taildirtest/dir2/spool.csv, headerKey1=csv, headerKey2=txt} body: 33 2C 63 63 2C 31 32                            3,cc,12 }
2021-01-14 18:43:55,478 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{byteoffset=0, file=/root/data/taildirtest/dir2/spool.txt, headerKey1=csv, headerKey2=txt} body: 34 2C 64 64 2C 34 34                            4,dd,44 }
2021-01-14 18:43:55,478 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{byteoffset=8, file=/root/data/taildirtest/dir2/spool.txt, headerKey1=csv, headerKey2=txt} body: 35 2C 65 65 2C 36 35                            5,ee,65 }
2021-01-14 18:43:55,478 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{byteoffset=16, file=/root/data/taildirtest/dir2/spool.txt, headerKey1=csv, headerKey2=txt} body: 36 2C 66 66 2C 31 32                            6,ff,12 }
....

# 查看 taildir_position.json。
# 注意日志输出的 byteoffset 指标和下面的 pos 指标
[root@zgg jobs]# cat taildir_position.json
[{"inode":18020744,"pos":24,"file":"/root/data/taildirtest/dir1/spool.csv"},{"inode":33719373,"pos":24,"file":"/root/data/taildirtest/dir2/spool.csv"},{"inode":33719372,"pos":24,"file":"/root/data/taildirtest/dir2/spool.txt"}]
```