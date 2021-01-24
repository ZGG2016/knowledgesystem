# “Flume Event”-Avro-Event-Serializer

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-fevent-avro-serializer.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = exec
a1.sources.r1.command = tail -F /root/data/test.txt

# Describe the sink
a1.sinks.k1.type = file_roll
a1.sinks.k1.sink.directory = /root/data/file_roll
a1.sinks.k1.sink.serializer = avro_event
a1.sinks.k1.sink.serializer.compressionCodec = snappy

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
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-fevent-avro-serializer.conf --name a1 -Dflume.root.logger=INFO,console

# 查看结果
[root@zgg file_roll]# head -10 1611488482810-1
Objavro.schematype":"record","name":"Event","fields":[{"name":"headers","type":{"type":"map","values":"string"}},{"name":"body","type":"bytes"}]}avro.codenullUOzhangsan redlisi blackUO;root@zgg:~/data/file_roll
```