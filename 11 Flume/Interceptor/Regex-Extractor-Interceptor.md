# Regex-Extractor-Interceptor


```sh
[root@zgg flume-1.9.0]# vi jobs/flume-regex-extractor-Interceptor.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = exec
a1.sources.r1.command = tail -F /root/data/test.txt

a1.sources.r1.interceptors = i1
a1.sources.r1.interceptors.i1.type = regex_extractor
a1.sources.r1.interceptors.i1.regex = (L[a-z]+)
a1.sources.r1.interceptors.i1.serializers = s
a1.sources.r1.interceptors.i1.serializers.s.type = org.apache.flume.interceptor.RegexExtractorInterceptorPassThroughSerializer
a1.sources.r1.interceptors.i1.serializers.s.name = firstlinestring

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
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-regex-extractor-Interceptor.conf --name a1 -Dflume.root.logger=INFO,console
....
# 输出日志中的 header 中添加了 secondstring-perline=Line
2021-01-24 18:40:15,414 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{secondstring-perline=Line} body: 46 69 72 73 74 20 4C 69 6E 65 20                First Line  }
2021-01-24 18:40:15,415 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:95)] Event: { headers:{secondstring-perline=Line} body: 53 65 63 6F 6E 64 20 4C 69 6E 65                Second Line }
```