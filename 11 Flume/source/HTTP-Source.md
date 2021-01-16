# HTTP-Source

[TOC]

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-http-source.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = http
a1.sources.r1.bind = zgg
a1.sources.r1.port = 44444

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
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-http-source.conf --name a1 -Dflume.root.logger=INFO,console
.....
# 发送数据完成后，日志输出：
2021-01-16 12:19:43,691 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{name=meituan, version=v2} body: 68 65 6C 6C 6F 77 6F 72 6C 64                   helloworld }

# 发送数据
curl -X POST -d'[{"headers":{"name":"meituan","version":"v2"},"body":"helloworld"}]'  http://zgg:44444
````