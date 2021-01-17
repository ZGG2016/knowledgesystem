# File-Channel

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-file-channel.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = netcat
a1.sources.r1.bind = localhost
a1.sources.r1.port = 44444

# Describe the sink
a1.sinks.k1.type = logger

# Use a channel which buffers events in memory
a1.channels.c1.type = file
a1.channels.c1.checkpointDir = /opt/flume-1.9.0/file-channel/checkpoint
a1.channels.c1.checkpointInterval = 3000
a1.channels.c1.useDualCheckpoints = true
a1.channels.c1.backupCheckpointDir = /opt/flume-1.9.0/file-channel/checkpoint_backup
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

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-file-channel.conf --name a1 -Dflume.root.logger=INFO,console
....


[root@zgg data]# telnet localhost 44444
Trying ::1...
telnet: connect to address ::1: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
aaaaaaaaaaa
OK
bbbbbbbbbbb
OK
ccccccccccc
OK


[root@zgg file-channel]# ll -R
.:
总用量 0
drwxr-xr-x. 3 root root 123 1月  17 15:25 checkpoint
drwxr-xr-x. 2 root root 129 1月  17 15:25 checkpoint_backup
drwxr-xr-x. 2 root root  56 1月  17 15:25 data

./checkpoint:
总用量 7836
-rw-r--r--. 1 root root 8008232 1月  17 15:25 checkpoint
-rw-r--r--. 1 root root      25 1月  17 15:25 checkpoint.meta
-rw-r--r--. 1 root root      32 1月  17 15:25 inflightputs
-rw-r--r--. 1 root root      32 1月  17 15:25 inflighttakes
-rw-r--r--. 1 root root       0 1月  17 15:25 in_use.lock
drwxr-xr-x. 2 root root       6 1月  17 15:25 queueset

./checkpoint/queueset:
总用量 0

./checkpoint_backup:
总用量 7836
-rw-r--r--. 1 root root       0 1月  17 15:25 backupComplete
-rw-r--r--. 1 root root 8008232 1月  17 15:25 checkpoint
-rw-r--r--. 1 root root      25 1月  17 15:25 checkpoint.meta
-rw-r--r--. 1 root root      32 1月  17 15:25 inflightputs
-rw-r--r--. 1 root root      32 1月  17 15:25 inflighttakes
-rw-r--r--. 1 root root       0 1月  17 15:25 in_use.lock

./data:
总用量 1028
-rw-r--r--. 1 root root       0 1月  17 15:25 in_use.lock
-rw-r--r--. 1 root root 1048576 1月  17 15:25 log-1
-rw-r--r--. 1 root root      47 1月  17 15:25 log-1.meta
```