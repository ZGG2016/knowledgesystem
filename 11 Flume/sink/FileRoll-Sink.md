# FileRoll-Sink

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-fileroll-sink.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = netcat
a1.sources.r1.bind = zgg
a1.sources.r1.port = 33333

# Describe the sink
a1.sinks.k1.type = file_roll
a1.sinks.k1.sink.directory = /root/data/file_roll
a1.sinks.k1.sink.rollInterval = 10

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 100

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

# 创建 file_roll/ 目录，并赋予权限
# 一开始，直接跑了任务，结果报错`Unable to deliver event. Exception follows.org.apache.flume.EventDeliveryException: Failed to open file /root/data/file_roll/1611199962760-1 while delivering event`
[root@zgg data]# mkdir file_roll
[root@zgg data]# chmod 777 file_roll

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-fileroll-sink.conf --name a1 -Dflume.root.logger=INFO,console

# 输入数据
[root@zgg flume-1.9.0]# telnet localhost 33333
Trying ::1...
telnet: connect to address ::1: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
aaaaaaaaaaa
OK
bbbbbbbbbb
OK

# 查看 file_roll/ 目录
[root@zgg file_roll]# ll
总用量 8
-rw-r--r--. 1 root root  0 1月  21 11:38 1611200321705-1
-rw-r--r--. 1 root root 13 1月  21 11:39 1611200321705-2
-rw-r--r--. 1 root root  0 1月  21 11:39 1611200321705-3
-rw-r--r--. 1 root root 12 1月  21 11:39 1611200321705-4
[root@zgg file_roll]# cat 1611200321705-2
aaaaaaaaaaa
[root@zgg file_roll]# cat 1611200321705-4
bbbbbbbbbb
```