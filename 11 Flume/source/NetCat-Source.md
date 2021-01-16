# NetCat-Source

[TOC]

## 1、NetCat TCP Source

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-netcattcp-source.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = netcat
a1.sources.r1.bind = localhost
a1.sources.r1.port = 44444
a1.sources.r1.max-line-length = 10

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

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-netcattcp-source.conf --name a1 -Dflume.root.logger=INFO,console
....
# telnet 输入后，产生如下日志输出：
2021-01-15 14:17:42,594 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{} body: 61 61 0D                                        aa. }
2021-01-15 14:19:01,148 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{} body: 62 62 0D                                        bb. }

# 打开另一个shell，输入：
# 注意出的 FAILED，前面设置了一行10个字节
[root@zgg kafka_2.12-2.6.0]# telnet localhost 44444
Trying ::1...
telnet: connect to address ::1: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
aaaaaaaaaaaaaaaaaaaa
FAILED: Event exceeds the maximum length (10 chars, including newline)
Connection closed by foreign host.

# 重新输入
[root@zgg kafka_2.12-2.6.0]# telnet localhost 44444
Trying ::1...
telnet: connect to address ::1: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
aa
OK
bb
OK   
```