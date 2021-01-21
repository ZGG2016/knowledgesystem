# Hdfs-Sink

[TOC]

## 1、基本功能测试

```python
# read_file.py  

# 每 120 秒往 spooldirtest/ 目录写一个文件，每个文件 100 行。
import time
with open("/root/data/hadoop-root-namenode-zgg.log") as f:
    
    all_lines = f.readlines()
    lines_num = len(all_lines)
    for i in range(0,lines_num/100):
        res_file = open("/root/data/spooldirtest/file-0%s.txt" % (str(i)),"w")
        for j in range(i,i+100):
            res_file.writelines(all_lines[j])
    
        res_file.close()
        time.sleep(120)
```

```sh
# spooldir 监控 spooldirtest/ 目录，每新增一个文件就读取一个。
[root@zgg flume-1.9.0]# vi jobs/flume-hdfs-sink.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = spooldir
a1.sources.r1.spoolDir = /root/data/spooldirtest
a1.sources.r1.fileHeader = true

# Describe the sink
a1.sinks.k1.type = hdfs
a1.sinks.k1.hdfs.path = /flume-out/hdfs-sink
a1.sinks.k1.hdfs.fileType = DataStream
# 根据在读取100个事件中的第一个事件的那一分钟建一个文件
a1.sinks.k1.hdfs.filePrefix = log_%Y%m%d_%H%M 
a1.sinks.k1.hdfs.fileSuffix = .log
# 这里禁用了基于文件大小滚动
a1.sinks.k1.hdfs.rollSize = 0
# 这里禁用了基于时间间隔滚动
a1.sinks.k1.hdfs.rollInterval = 0
a1.sinks.k1.hdfs.rollCount = 100    # 读满100个事件，关闭此文件
a1.sinks.k1.hdfs.batchSize = 200
a1.sinks.k1.hdfs.round = true
a1.sinks.k1.hdfs.roundValue = 2
a1.sinks.k1.hdfs.roundUnit = minute
a1.sinks.k1.hdfs.useLocalTimeStamp = true

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 1000

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

# 再启动 python 脚本
[root@zgg python_script]# python read_file.py 


# 先启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-hdfs-sink.conf --name a1 -Dflume.root.logger=INFO,console
.....
# 启动 python 脚本后，会出现类似这种日志
2021-01-20 21:38:05,815 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.hdfs.BucketWriter.open(BucketWriter.java:246)] Creating /flume-out/hdfs-sink/log_20210120_2138.1611149885728.log.tmp
2021-01-20 21:38:09,806 (Thread-8) [INFO - org.apache.hadoop.hdfs.protocol.datatransfer.sasl.SaslDataTransferClient.checkTrustAndSend(SaslDataTransferClient.java:239)] SASL encryption trust check: localHostTrusted = false, remoteHostTrusted = false
# 任务会一直卡在这里，此时，hdfs 目录下的结果文件一直都是 .tmp 结尾。
# 这是因为 hdfs.closeTries 属性的默认值是0，0表示 sink 会尝试重命名文件，直到在文件被最终重命名（没有重试次数的限制，即一直尝试重命名）
# 所以任务会一直卡在这里。
# 此时，只需中断任务即可。
# 经测试，在配置文件添加一行配置 `a1.sinks.k1.hdfs.idleTimeout = 120` 可以不需要中断任务，就能查看结果文件

# 此时，查看hdfs目录
[root@zgg spooldirtest]# hadoop fs -ls /flume-out/hdfs-sink
Found 2 items
-rw-r--r--   1 root supergroup      12486 2021-01-20 21:48 /flume-out/hdfs-sink/log_20210120_2138.1611149885728.log
-rw-r--r--   1 root supergroup      12565 2021-01-20 21:48 /flume-out/hdfs-sink/log_20210120_2140.1611150007942.log

# 将文件 get 下来，查看行数。没问题。
[root@zgg spooldirtest]# wc -l log_20210120_2138
100 log_20210120_2138
[root@zgg spooldirtest]# wc -l log_20210120_2140
100 log_20210120_2140 
```

## 2、滚动阈值测试

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-hdfs-sink-02.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = spooldir
a1.sources.r1.spoolDir = /root/data/spooldirtest
a1.sources.r1.fileHeader = true

# Describe the sink
a1.sinks.k1.type = hdfs
a1.sinks.k1.hdfs.path = /flume-out/hdfs-sink
a1.sinks.k1.hdfs.fileType = DataStream
a1.sinks.k1.hdfs.filePrefix = log_%Y%m%d_%H%M 
a1.sinks.k1.hdfs.fileSuffix = .log
# 这里禁用了基于时间间隔滚动
a1.sinks.k1.hdfs.rollInterval = 0
# 经上面的测试，100行数据的文件大于12486kb
# 这里文件大小阈值设为10000kb，事件数阈值设为100.
# 测试：先达到哪个条件就完成写入（应该是先达到文件大小阈值）
a1.sinks.k1.hdfs.rollSize = 10000
a1.sinks.k1.hdfs.rollCount = 100   
a1.sinks.k1.hdfs.batchSize = 200
a1.sinks.k1.hdfs.round = true
a1.sinks.k1.hdfs.roundValue = 2
a1.sinks.k1.hdfs.roundUnit = minute
a1.sinks.k1.hdfs.useLocalTimeStamp = true
a1.sinks.k1.hdfs.idleTimeout = 120

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 1000

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

-----------------------------------------------------------

# 这里，脚本只取了200行
# 任务执行完成后，hdfs上查看
[root@zgg data]# hadoop fs -ls /flume-out/hdfs-sink
Found 6 items
-rw-r--r--   1 root supergroup      10085 2021-01-20 22:23 /flume-out/hdfs-sink/log_20210120_2222.1611152637396.log
-rw-r--r--   1 root supergroup       2401 2021-01-20 22:26 /flume-out/hdfs-sink/log_20210120_2222.1611152637397.log
-rw-r--r--   1 root supergroup      10167 2021-01-20 22:25 /flume-out/hdfs-sink/log_20210120_2224.1611152759770.log
-rw-r--r--   1 root supergroup         96 2021-01-20 22:28 /flume-out/hdfs-sink/log_20210120_2224.1611152759771.log
-rw-r--r--   1 root supergroup       2302 2021-01-20 22:28 /flume-out/hdfs-sink/log_20210120_2226.1611152760003.log
-rw-r--r--   1 root supergroup          2 2021-01-20 22:31 /flume-out/hdfs-sink/log_20210120_2228.1611152923467.log

# get 到本地文件后，查看行数
[root@zgg data]# wc -l log_20210120_2224.1611152759770.log
82 log_20210120_2224.1611152759770.log

[root@zgg data]# wc -l log_20210120_2222.1611152637396.log
81 log_20210120_2222.1611152637396.log

[root@zgg data]# wc -l log_20210120_2222.1611152637397.log
19 log_20210120_2222.1611152637397.log

[root@zgg data]# wc -l log_20210120_2224.1611152759771.log
1 log_20210120_2224.1611152759771.log

[root@zgg data]# wc -l log_20210120_2226.1611152760003.log
17 log_20210120_2226.1611152760003.log

[root@zgg data]# wc -l log_20210120_2228.1611152923467.log
2 log_20210120_2228.1611152923467.log

# 问题：文件的大小超过了100左右kb，总行数多了2行。
```

## 3、压缩

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-hdfs-sink-03.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = netcat
a1.sources.r1.bind = localhost
a1.sources.r1.port = 44444

# Describe the sink
a1.sinks.k1.type = hdfs
a1.sinks.k1.hdfs.path = /flume-out/hdfs-sink
a1.sinks.k1.hdfs.fileType = CompressedStream
a1.sinks.k1.hdfs.filePrefix = log_%Y%m%d_%H%M 
a1.sinks.k1.hdfs.fileSuffix = .lzo
a1.sinks.k1.hdfs.codeC = lzop
a1.sinks.k1.hdfs.round = true
a1.sinks.k1.hdfs.roundValue = 2
a1.sinks.k1.hdfs.roundUnit = minute
a1.sinks.k1.hdfs.useLocalTimeStamp = true
a1.sinks.k1.hdfs.idleTimeout = 120

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 1000

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

---------------------------------------------------------------

# 启动任务后，产生数据
[root@zgg data]# telnet localhost 44444
Trying ::1...
telnet: connect to address ::1: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
aaaaaaaaaaaa
OK
bbbbbbbbb
OK

# hdfs 上查看结果
[root@zgg python_script]# hadoop fs -text /flume-out/hdfs-sink/log_20210120_2250.1611154258736.lzo
......
aaaaaaaaaaaa
bbbbbbbbb
```