# lzo支持

环境为伪分布。

1、下载相关文件：

lzo-2.10.tar.gz：[https://www.oberhumer.com/opensource/lzo/](https://www.oberhumer.com/opensource/lzo/)

hadoop-lzo-master.zip：[https://github.com/twitter/hadoop-lzo/archive/master.zip](https://github.com/twitter/hadoop-lzo/archive/master.zip)

2、Configure LZO to build a shared library (required) and use a package-specific prefix (optional but recommended): 

```sh
[root@zgg opt]# tar -zxvf lzo-2.10.tar.gz 
....
[root@zgg opt]# cd lzo-2.10
[root@zgg lzo-2.10]# ./configure --enable-shared --prefix /usr/local/lzo-2.10
```

3、Build and install LZO: 

```sh
[root@zgg lzo-2.10]# make && sudo make install
```

如果是集群环境，编译完 lzo 包之后，将 `/usr/local/lzo-2.10`目录下生成的所有文件打包，并同步到集群其他节点。

4、安装 hadoop-lzo

```sh
[root@zgg opt]# unzip hadoop-lzo-master.zip
....
[root@zgg opt]# vi /etc/profile
....
export C_INCLUDE_PATH=/usr/local/lzo-2.10/include
export LIBRARY_PATH=/usr/local/lzo-2.10/lib
....
[root@zgg opt]# source /etc/profile
[root@zgg opt]# cd hadoop-lzo-master

[root@zgg hadoop-lzo-master]# mvn clean package
....
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  16:46 min
[INFO] Finished at: 2021-01-10T14:08:16+08:00
[INFO] ------------------------------------------------------------------------

[root@zgg hadoop-lzo-master]# cd target/
[root@zgg target]# ls
antrun   generated-sources                       hadoop-lzo-0.4.21-SNAPSHOT-sources.jar  native
apidocs  hadoop-lzo-0.4.21-SNAPSHOT.jar          javadoc-bundle-options                  test-classes
classes  hadoop-lzo-0.4.21-SNAPSHOT-javadoc.jar  maven-archiver

# 将`hadoop-lzo-0.4.21-SNAPSHOT.jar`复制到 .../common 目录下
[root@zgg hadoop-lzo-master]# cp target/hadoop-lzo-0.4.21-SNAPSHOT.jar /opt/hadoop-3.2.1/share/hadoop/common
```

如果是集群环境，需要将`hadoop-lzo-0.4.21-SNAPSHOT.jar`同步到集群其他节点。

5、配置 Hadoop 属性

hadoop-env.sh：

```sh
export LD_LIBRARY_PATH=/usr/local/lzo-2.10/lib
```

core-site.xml

```xml
<property>
	<!-- 配置支持 LZO 压缩 -->
	<name>io.compression.codecs</name>
	<value>
		com.hadoop.compression.lzo.LzoCodec,
		com.hadoop.compression.lzo.LzopCodec
	</value>
</property>
<property>
 	<name>io.compression.codec.lzo.class</name>
 	<value>com.hadoop.compression.lzo.LzoCodec</value>
</property>
```
mapred-site.xml

```xml
<property>
	<!-- 启用map任务输出的压缩 -->
    <name>mapreduce.map.output.compress</name>
    <value>true</value>
</property>
<property>
	<!-- map任务输出的压缩类型 -->
    <name>mapred.map.output.compression.codec</name>
    <value>com.hadoop.compression.lzo.LzopCodec</value>
</property>

<property>
	<!-- 启用job输出的压缩 -->
    <name>mapreduce.output.fileoutputformat.compress</name>
    <value>true</value>
</property>
<property>
	<!-- job输出的压缩类型，这里是LzopCodec -->
    <name>mapreduce.output.fileoutputformat.compress.codec</name>
    <value>com.hadoop.compression.lzo.LzopCodec</value>
</property>
<property>
    <name>mapred.child.env</name>
    <value>LD_LIBRARY_PATH=/usr/local/lzo-2.10/lib</value>
</property>
```

如果是集群环境，需要将这些配置同步到集群其他节点。

6、测试

```sh
# 安装lzop
yum install lzop

# 压缩文件
lzop  wc.txt

# 测试wordcount
[root@zgg target]# hadoop jar /opt/hadoop-3.2.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.2.1.jar wordcount /in/wc.txt.lzo /out/wc
....
【一个分片，未切片】
2021-01-10 15:54:36,249 INFO mapreduce.JobSubmitter: number of splits:1

[root@zgg target]# hadoop fs -ls /out/wc    
Found 2 items
-rw-r--r--   1 root supergroup          0 2021-01-10 16:36 /out/wc/_SUCCESS
-rw-r--r--   1 root supergroup         91 2021-01-10 16:36 /out/wc/part-r-00000.lzo
```

7、LZO 创建索引

LZO 压缩文件的可切片特性依赖于其索引，故我们需要手动为 LZO 压缩文件创建索引。若无索引，则 LZO 文件的切片只有一个。

```sh
# 数据文件的目录是hdfs上的目录
# 【com.hadoop.compression.lzo.DistributedLzoIndexer】
[root@zgg target]# hadoop jar /opt/hadoop-lzo-master/target/hadoop-lzo-0.4.21-SNAPSHOT.jar com.hadoop.compression.lzo.LzoIndexer /in/wc.txt.lzo 
2021-01-10 16:41:23,817 INFO lzo.GPLNativeCodeLoader: Loaded native gpl library from the embedded binaries
2021-01-10 16:41:23,820 INFO lzo.LzoCodec: Successfully loaded & initialized native-lzo library [hadoop-lzo rev 5dbdddb8cfb544e58b4e0b9664b9d1b66657faf5]
2021-01-10 16:41:24,573 INFO lzo.LzoIndexer: [INDEX] LZO Indexing file /in/wc.txt.lzo, size 0.00 GB...
2021-01-10 16:41:24,659 INFO sasl.SaslDataTransferClient: SASL encryption trust check: localHostTrusted = false, remoteHostTrusted = false
2021-01-10 16:41:24,736 INFO sasl.SaslDataTransferClient: SASL encryption trust check: localHostTrusted = false, remoteHostTrusted = false
2021-01-10 16:41:24,802 INFO lzo.LzoIndexer: Completed LZO Indexing in 0.23 seconds (0.00 MB/s).  Index size is 0.01 KB.

# 查看
[root@zgg data]# hadoop fs -ls /in
Found 2 items
-rw-r--r--   1 root supergroup        124 2021-01-10 16:13 /in/lzo/wc.txt.lzo
-rw-r--r--   1 root supergroup          8 2021-01-10 16:13 /in/lzo/wc.txt.lzo.index

# 测试
# 【输入路径也必须包含索引文件】
[root@zgg target]# hadoop jar /opt/hadoop-3.2.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.2.1.jar wordcount /in/lzo /out/wc
....
2021-01-10 16:43:41,854 INFO mapreduce.JobSubmitter: number of splits:2
....

[root@zgg target]# hadoop fs -ls /out/wc
Found 2 items
-rw-r--r--   1 root supergroup          0 2021-01-10 16:44 /out/wc/_SUCCESS
-rw-r--r--   1 root supergroup        102 2021-01-10 16:44 /out/wc/part-r-00000.lzo

[root@zgg target]# hadoop fs -text /out/wc/part-r-00000.lzo
2021-01-10 16:44:47,453 INFO sasl.SaslDataTransferClient: SASL encryption trust check: localHostTrusted = false, remoteHostTrusted = false
2021-01-10 16:44:47,521 INFO lzo.GPLNativeCodeLoader: Loaded native gpl library from the embedded binaries
2021-01-10 16:44:47,557 INFO lzo.LzoCodec: Successfully loaded & initialized native-lzo library [hadoop-lzo rev 5dbdddb8cfb544e58b4e0b9664b9d1b66657faf5]
2021-01-10 16:44:47,562 INFO compress.CodecPool: Got brand-new decompressor [.lzo]
,       1
flink   170
hadoop  510
hello   340
spark   170
```

参考地址：

[https://www.cnblogs.com/caoshouling/p/14091113.html](https://www.cnblogs.com/caoshouling/p/14091113.html)

[https://github.com/twitter/hadoop-lzo](https://github.com/twitter/hadoop-lzo)