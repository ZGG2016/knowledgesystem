# Failover-Sink-Processor

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-failover-sink-processor.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1 k2
a1.sinkgroups = g1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = exec
a1.sources.r1.command = tail -F /root/data/test.txt

# Describe the sink
a1.sinks.k1.type = file_roll
a1.sinks.k1.sink.directory = /root/data/file_roll-01
a1.sinks.k1.sink.rollInterval = 10

a1.sinks.k2.type = file_roll
a1.sinks.k2.sink.directory = /root/data/file_roll-02
a1.sinks.k2.sink.rollInterval = 10

a1.sinkgroups.g1.processor.type = failover
a1.sinkgroups.g1.sinks = k1 k2
a1.sinkgroups.g1.processor.priority.k1 = 20
a1.sinkgroups.g1.processor.priority.k2 = 10
a1.sinkgroups.g1.processor.maxpenalty = 10000

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 1000

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1
a1.sinks.k2.channel = c1

----------------------------------------------------
# 数据文件 test.txt
zhangsan red
lisi black

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-failover-sink-processor.conf --name a1 -Dflume.root.logger=INFO,console

# 查看输出。
[root@zgg data]# ll -R file_roll-01
file_roll-01:
总用量 1
-rw-r--r--. 1 root root 24 1月  24 20:11 1611490290274-1
[root@zgg data]# ll -R file_roll-02
file_roll-02:
总用量 0

[root@zgg data]# cat file_roll-01/1611490290274-1
zhangsan red
lisi black
```