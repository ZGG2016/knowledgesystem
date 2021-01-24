# Remove-Header-Interceptor

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-remove-header-interceptor.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = exec
a1.sources.r1.command = tail -F /root/data/test.txt

a1.sources.r1.interceptors = i1 i2 i3
a1.sources.r1.interceptors.i1.type = static        # 第一个是 static 拦截器，添加taskname
a1.sources.r1.interceptors.i1.preserveExisting = false
a1.sources.r1.interceptors.i1.key = taskname
a1.sources.r1.interceptors.i1.value = static-interceptor
a1.sources.r1.interceptors.i2.type = static        # 第二个是 static 拦截器，添加clustername
a1.sources.r1.interceptors.i2.preserveExisting = false
a1.sources.r1.interceptors.i2.key = clustername
a1.sources.r1.interceptors.i2.value = flume
a1.sources.r1.interceptors.i3.type = remove_header # 第三个是 remove_header 拦截器，删除clusterkname
a1.sources.r1.interceptors.i3.withName = clustername

# Describe the sink
a1.sinks.k1.type = logger

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 1000

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------
# 数据文件 test.txt
First Line
Second Line

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-remove-header-interceptor.conf --name a1 -Dflume.root.logger=INFO,console
....
# 输出日志中的 header 中添加 taskname 字段及其值，没有 clustername
2021-01-24 18:08:42,853 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{taskname=static-interceptor} body: 46 69 72 73 74 20 4C 69 6E 65 20                First Line  }
2021-01-24 18:08:42,854 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{taskname=static-interceptor} body: 53 65 63 6F 6E 64 20 4C 69 6E 65                Second Line }
```