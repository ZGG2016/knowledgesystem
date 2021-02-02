# flume调优

## 1、FileChannel 优化

通过配置 `dataDirs` 指向多个路径，每个路径对应不同的硬盘，增大 Flume 吞吐量。

`checkpointDir` 和 `backupCheckpointDir` 也尽量配置在不同硬盘对应的目录中，保证
checkpoint 坏掉后，可以快速使用 backupCheckpointDir 恢复数据。

## 2、HDFS 小文件处理

hdfs.rollInterval、hdfs.rollSize、hdfs.rollCount

官方默认的这三个参数配置写入 HDFS 后会产生小文件。

基于以上 hdfs.rollInterval=3600，hdfs.rollSize=134217728，hdfs.rollCount=0 几个参数综合作用，效果如下：

	（1）文件在达到 128M 时会滚动生成新文件

	（2）文件创建超 3600 秒时会滚动生成新文件

## 3、内存优化

1）问题描述：如果启动消费 Flume 抛出如下异常`ERROR hdfs.HDFSEventSink: process failed java.lang.OutOfMemoryError: GC overhead limit exceeded`

2）解决方案步骤：

（1）在 hadoop102 服务器的 `/opt/module/flume/conf/flume-env.sh` 文件中增加如下配置

	export JAVA_OPTS="-Xms100m -Xmx2000m -Dcom.sun.management.jmxremote"

（2）同步配置到 hadoop103、hadoop104 服务器

	[atguigu@hadoop102 conf]$ xsync flume-env.sh

3）Flume 内存参数设置及优化

JVM heap 一般设置为 4G 或更高，部署在单独的服务器上（4 核 8 线程 16G 内存）。

-Xmx 与 -Xms 最好设置一致，减少内存抖动带来的性能影响，如果设置不一致容易导致
频繁 fullgc。 

-Xms 表示 JVM Heap(堆内存)最小尺寸，初始分配；

-Xmx 表示 JVM Heap(堆内存)最大允许的尺寸，按需分配。

如果不设置一致，容易在初始化时，由于内存不够，频繁触发 fullgc。

原文地址：

[https://www.bilibili.com/video/BV1L4411K7hW?p=42](https://www.bilibili.com/video/BV1L4411K7hW?p=42)

[https://www.bilibili.com/video/BV1L4411K7hW?p=43](https://www.bilibili.com/video/BV1L4411K7hW?p=43)