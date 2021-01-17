# Spillable-Memory-Channel

```sh
# 测试transactionCapacity
[root@zgg flume-1.9.0]# vi jobs/flume-spillable-memory-channel.conf
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
a1.channels.c1.type = SPILLABLEMEMORY
a1.channels.c1.memoryCapacity = 200
a1.channels.c1.overflowCapacity = 500
a1.channels.c1.transactionCapacity = 100
a1.channels.c1.checkpointDir = /opt/flume-1.9.0/file-channel/checkpoint
a1.channels.c1.dataDirs = /opt/flume-1.9.0/file-channel/data


# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

[root@zgg data]# cat memorychan.txt 
aaaaaaaaaaa
bbbbbbbbbbb
ccccccccccc
ddddddddddd
eeeeeeeeeee
....
[root@zgg data]# wc -l memorychan.txt 
364 memorychan.txt

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-spillable-memory-channel.conf --name a1 -Dflume.root.logger=INFO,console
```

运行中出现了问题：[https://blog.csdn.net/iteye_14608/article/details/82473931](https://blog.csdn.net/iteye_14608/article/details/82473931)