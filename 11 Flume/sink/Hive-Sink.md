# Hive-Sink

[TOC]

hive 表必须是事务表、分区表、分桶表，stored as orc。

把 `$HIVE_HOME/hcatalog/share/hcatalog/` 下面 jar 包复制到 `$FLUME_HOME/lib/` 下面。

```sql
-- 先建一个hive表(一个分区)
create table weblogs (id int,msg string)
    partitioned by (send_time string)
    clustered by (id) into 5 buckets
    stored as orc TBLPROPERTIES ('transactional'='true');
```

```sh
# 监控 hivesinktest/ 目录，每分钟产生一个新文件就读取到表的一个分区中
[root@zgg flume-1.9.0]# vi jobs/flume-hive-sink.conf
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = spooldir
a1.sources.r1.spoolDir = /root/data/hivesinktest/
a1.sources.r1.fileHeader = true

# Describe the sink
a1.sinks.k1.type = hive
a1.sinks.k1.hive.metastore = thrift://zgg:9083
a1.sinks.k1.hive.database = default
a1.sinks.k1.hive.table = weblogs
a1.sinks.k1.hive.partition = %Y-%m-%d-%H-%M
a1.sinks.k1.hive.autoCreatePartitions = true
a1.sinks.k1.useLocalTimeStamp = true
a1.sinks.k1.callTimeout = 60000
a1.sinks.k1.batchSize = 100
a1.sinks.k1.round = true
# 如果执行flume任务后，第二个分区的目录一直创建不了，数据进不来，
# 就是这个属性和下一行的属性的设置原因
# 它控制了分区目录的创建周期，可以设的小点
a1.sinks.k1.roundValue = 1    
a1.sinks.k1.roundUnit = minute
a1.sinks.k1.serializer = DELIMITED
a1.sinks.k1.serializer.delimiter = "\t"
a1.sinks.k1.serializer.serdeSeparator = '\t'
a1.sinks.k1.serializer.fieldnames = id,msg


# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 200

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1

----------------------------------------------------

# 启动 Flume 任务
[root@zgg flume-1.9.0]# bin/flume-ng agent --conf conf --conf-file jobs/flume-hive-sink.conf --name a1 -Dflume.root.logger=INFO,console

# 数据文件
[root@zgg data]# cat weblogs-01.txt
1       "11111111111"
2       "22222222222"
[root@zgg data]# cat weblogs-02.txt
3       "33333333333"
4       "44444444444"

# 在不同时间，分别执行如下命令将数据文件复制到监控目录 hivesinktest/ 下 
[root@zgg data]# cp weblogs-01.txt hivesinktest/
[root@zgg data]# cp weblogs-02.txt hivesinktest/



# 查看结果
hive> select * from weblogs;
OK
1       "11111111111"   2021-01-21-11-05
2       "22222222222"   2021-01-21-11-05
4       "44444444444"   2021-01-21-11-09
3       "33333333333"   2021-01-21-11-09

# hdfs warehouse
[root@zgg data]# hadoop fs -ls /user/hive/warehouse/weblogs
Found 2 items
drwxr-xr-x   - root supergroup          0 2021-01-21 11:05 /user/hive/warehouse/weblogs/send_time=2021-01-21-11-05
drwxr-xr-x   - root supergroup          0 2021-01-21 11:09 /user/hive/warehouse/weblogs/send_time=2021-01-21-11-09

[root@zgg data]# hadoop fs -ls /user/hive/warehouse/weblogs/send_time=2021-01-21-11-05
Found 1 items
drwxr-xr-x   - root supergroup          0 2021-01-21 11:05 /user/hive/warehouse/weblogs/send_time=2021-01-21-11-05/delta_0000801_0000900

[root@zgg data]# hadoop fs -ls /user/hive/warehouse/weblogs/send_time=2021-01-21-11-05/delta_0000801_0000900
Found 5 items
-rw-r--r--   1 root supergroup          1 2021-01-21 11:05 /user/hive/warehouse/weblogs/send_time=2021-01-21-11-05/delta_0000801_0000900/_orc_acid_version
-rw-r--r--   1 root supergroup        750 2021-01-21 11:09 /user/hive/warehouse/weblogs/send_time=2021-01-21-11-05/delta_0000801_0000900/bucket_00000
-rw-r--r--   1 root supergroup         16 2021-01-21 11:09 /user/hive/warehouse/weblogs/send_time=2021-01-21-11-05/delta_0000801_0000900/bucket_00000_flush_length
-rw-r--r--   1 root supergroup        757 2021-01-21 11:09 /user/hive/warehouse/weblogs/send_time=2021-01-21-11-05/delta_0000801_0000900/bucket_00004
-rw-r--r--   1 root supergroup         16 2021-01-21 11:09 /user/hive/warehouse/weblogs/send_time=2021-01-21-11-05/delta_0000801_0000900/bucket_00004_flush_length
```

