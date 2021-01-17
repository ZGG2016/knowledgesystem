# Memory-Channel

[TOC]


```sh
# 测试transactionCapacity
[root@zgg flume-1.9.0]# vi jobs/flume-memory-capacity-channel.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = exec
a1.sources.r1.command = tail -F /root/memorychan.txt

# Describe the sink
a1.sinks.k1.type = logger

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 5
a1.channels.c1.transactionCapacity = 3

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

[root@zgg ~]# cat memorychan.txt
aaaaaaaaaaa
bbbbbbbbbbb
ccccccccccc
ddddddddddd

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-memory-capacity-channel.conf --name a1 -Dflume.root.logger=INFO,console
.....
Incompatible source and channel settings defined. source’s batch size is greater than the channels transaction capacity. Source: r1, batch size = 20, channel c1, transaction capacity = 3
# exec source 的 batchSize 的含义是 The max number of lines to read and send to the channel at a time【一次读取并发送给channel的最大行数】，默认是20
# 所以 exec source 一次读取并发送给 channel 的最大事件数量是20，
# 而在 memory channel 设置的 transactionCapacity 参数为3，
#   即在一次事务中，从 source 中获取事件的数量是3，所以会报错。
# 应该设置，transactionCapacity大于batchSize。
# 即，在一次事务中，从 source 中获取事件的数量 大于 source 一次发送的数量。

# 修改配置文件
[root@zgg flume-1.9.0]# vi jobs/flume-memory-capacity-channel.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = exec
a1.sources.r1.command = tail -F /root/memorychan.txt
a1.sources.r1.batchSize = 4

# Describe the sink
a1.sinks.k1.type = logger

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 5
a1.channels.c1.transactionCapacity = 5

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

# 启动任务，日志输出为：
2021-01-17 11:11:42,255 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{} body: 61 61 61 61 61 61 61 61 61 61 61                aaaaaaaaaaa }
2021-01-17 11:11:42,255 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{} body: 62 62 62 62 62 62 62 62 62 62 62                bbbbbbbbbbb }
2021-01-17 11:11:42,255 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{} body: 63 63 63 63 63 63 63 63 63 63 63                ccccccccccc }
2021-01-17 11:11:42,255 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{} body: 64 64 64 64 64 64 64 64 64 64 64                ddddddddddd }

# 如果 capacity 的值小于 transactionCapacity 的值，会出现如下错误：
# java.lang.IllegalStateException: Transaction Capacity of Memory Channel cannot be higher than the capacity.
```