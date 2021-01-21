# Hbase-Sink

[TOC]

```sh
# 先创建一个表
hbase(main):004:0> create 'student','info';
```

查看类 Serializer 源码理解各个属性。

## 1、SimpleHBase2EventSerializer 测试

```sh
# telnet 发送数据到到表中
[root@zgg flume-1.9.0]# vi jobs/flume-hbase-sink.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = netcat
a1.sources.r1.bind = zgg
a1.sources.r1.port = 44444

# Describe the sink
a1.sinks.k1.type = hbase2
a1.sinks.k1.table = student
a1.sinks.k1.columnFamily = info
a1.sinks.k1.serializer = org.apache.flume.sink.hbase2.SimpleHBase2EventSerializer
a1.sinks.k1.serializer.payloadColumn = name   # 指定数据写入的列

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 200

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-hbase-sink.conf --name a1 -Dflume.root.logger=INFO,console


# 生成数据
[root@zgg ~]# telnet zgg 44444
Trying 192.168.1.6...
Connected to zgg.
Escape character is '^]'.
zhangsan
OK
lisi
OK

# 表中查看
hbase(main):047:0> scan 'student'
ROW                                COLUMN+CELL                                                                                      
 default5e5f1683-f82e-43a3-8e9f-8c column=info:name, timestamp=1611219691916, value=lisi\x0D                                        
 7c37dc679b                                                                                                                         
 default65496376-d745-4756-9337-4a column=info:name, timestamp=1611219666873, value=zhangsan\x0D                                    
 8ffbb0964e                                                                                                                         
 incRow                            column=info:iCol, timestamp=1611219691927, value=\x00\x00\x00\x00\x00\x00\x00\x02                
3 row(s)
```

## 2、RegexHbaseEventSerializer 测试

RegexHbaseEventSerializer 基于给定的正则分解 event body ，并将每个部分写入不同的列中。

info 列族下包含的列有：名字（name）、性别（sex）

给出的数据格式为：行键，名字，性别

	01,zhangsan,male
	02,lisi,male

```sh
[root@zgg flume-1.9.0]# vi jobs/flume-hbase-sink-serializer.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = exec
a1.sources.r1.command = tail -F /root/data/hbase-sink.txt

# Describe the sink
a1.sinks.k1.type = hbase2
a1.sinks.k1.table = student
a1.sinks.k1.columnFamily = info
a1.sinks.k1.serializer = org.apache.flume.sink.hbase2.RegexHBase2EventSerializer
a1.sinks.k1.serializer.enableWal = true
a1.sinks.k1.serializer.regex = ^([0-9]+),([a-z]+),([a-z]+)$
a1.sinks.k1.serializer.colNames = ROW_KEY,name,sex
a1.sinks.k1.serializer.rowKeyIndex = 0  # 指定第一列为rowkey

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 200

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-hbase-sink-serializer.conf --name a1 -Dflume.root.logger=INFO,console


hbase(main):063:0> scan 'student'
ROW                                COLUMN+CELL                                                                                      
 01                                column=info:name, timestamp=1611220733749, value=zhangsan                                        
 01                                column=info:sex, timestamp=1611220733749, value=male                                             
 02                                column=info:name, timestamp=1611220733749, value=lisi                                            
 02                                column=info:sex, timestamp=1611220733749, value=male                                             
2 row(s)

````