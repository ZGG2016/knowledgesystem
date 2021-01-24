## Avro-Event-Serializer

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-avro-event-serializer.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = exec
a1.sources.r1.command = tail -F /root/data/test.txt

# Describe the sink
a1.sinks.k1.type = hdfs
a1.sinks.k1.hdfs.path = /flume-out/serializer
a1.sinks.k1.serializer = org.apache.flume.sink.hdfs.AvroEventSerializer$Builder
a1.sinks.k1.serializer.compressionCodec = lzo
a1.sinks.k1.serializer.schemaURL = hdfs://zgg:9000/in/user.avsc

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 100

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------
# 数据文件 test.txt
zhangsan red
lisi black

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-avro-event-serializer.conf --name a1 -Dflume.root.logger=INFO,console

# 查看结果
[root@zgg ~]# hadoop fs -text /flume-out/serializer/FlumeData.1611489124400
2021-01-24 19:53:30,237 INFO sasl.SaslDataTransferClient: SASL encryption trust check: localHostTrusted = false, remoteHostTrusted = false
1611489125661   7a 68 61 6e 67 73 61 6e 20 72 65 64
1611489125664   6c 69 73 69 20 62 6c 61 63 6b
```
