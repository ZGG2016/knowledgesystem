# Avro-Sink


```sh
[root@zgg flume-1.9.0]# vi jobs/flume-avro-sink.conf
#########a1 agent#####
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = netcat
a1.sources.r1.bind = zgg
a1.sources.r1.port = 44444

# Describe the sink
a1.sinks.k1.type = avro
a1.sinks.k1.hostname = zgg
a1.sinks.k1.port = 55555

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 100

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1


#########a2 agent#####
# Name the components on this agent
a2.sources = r2
a2.sinks = k2
a2.channels = c2

# Describe/configure the source
a2.sources.r2.type = avro
a2.sources.r2.bind = zgg
a2.sources.r2.port = 55555  # 和 a1 的 sink 监听同一端口 

# Describe the sink
a2.sinks.k2.type = logger

# Use a channel which buffers events in memory
a2.channels.c2.type = memory
a2.channels.c2.capacity = 1000
a2.channels.c2.transactionCapacity = 100

# Bind the source and sink to the channel
a2.sources.r2.channels = c2
a2.sinks.k2.channel = c2

----------------------------------------------------

# 启动 Flume 任务 -- a2
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-avro-sink.conf --name a2 -Dflume.root.logger=INFO,console
.....
# a1 启动后，输出如下日志
2021-01-21 11:20:23,183 (New I/O server boss #5) [INFO - org.apache.avro.ipc.NettyServer$NettyServerAvroHandler.handleUpstream(NettyServer.java:171)] [id: 0x2ed6473d, /192.168.1.6:41908 => /192.168.1.6:55555] OPEN
2021-01-21 11:20:23,184 (New I/O worker #1) [INFO - org.apache.avro.ipc.NettyServer$NettyServerAvroHandler.handleUpstream(NettyServer.java:171)] [id: 0x2ed6473d, /192.168.1.6:41908 => /192.168.1.6:55555] BOUND: /192.168.1.6:55555
2021-01-21 11:20:23,184 (New I/O worker #1) [INFO - org.apache.avro.ipc.NettyServer$NettyServerAvroHandler.handleUpstream(NettyServer.java:171)] [id: 0x2ed6473d, /192.168.1.6:41908 => /192.168.1.6:55555] CONNECTED: /192.168.1.6:41908

# 输入数据后，输出如下日志，
2021-01-21 11:20:38,886 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{} body: 61 61 61 61 61 61 61 61 61 61 61 61 61 0D       aaaaaaaaaaaaa. }


# 启动 Flume 任务 -- a1
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-avro-sink.conf --name a1

# 输入数据
[root@zgg data]# telnet zgg 44444      
Trying 192.168.1.6...
Connected to zgg.
Escape character is '^]'.
aaaaaaaaaaaaa
OK
```