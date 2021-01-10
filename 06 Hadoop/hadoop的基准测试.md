# hadoop的基准测试

1、测试 HDFS 写性能

测试内容：向 HDFS 集群写 10 个 128M 的文件

```sh
[atguigu@hadoop102 mapreduce]$ hadoop jar /opt/module/hadoop-
2.7.2/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.7.2-
tests.jar TestDFSIO -write -nrFiles 10 -fileSize 128MB
19/05/02 11:45:23 INFO fs.TestDFSIO: ----- TestDFSIO ----- : write
19/05/02 11:45:23 INFO fs.TestDFSIO: Date & time: Thu May 02 11:45:23 CST 2019
19/05/02 11:45:23 INFO fs.TestDFSIO: Number of files: 10
19/05/02 11:45:23 INFO fs.TestDFSIO: Total MBytes processed: 1280.0
19/05/02 11:45:23 INFO fs.TestDFSIO: Throughput mb/sec: 10.69751115716984     【吞吐量】
19/05/02 11:45:23 INFO fs.TestDFSIO: Average IO rate mb/sec: 14.91699504852295【平均io速率】
19/05/02 11:45:23 INFO fs.TestDFSIO: IO rate std deviation: 11.160882132355928
19/05/02 11:45:23 INFO fs.TestDFSIO: Test exec time sec: 52.315
```

2、测试 HDFS 读性能

测试内容：读取 HDFS 集群 10 个 128M 的文件

```sh
[atguigu@hadoop102 mapreduce]$ hadoop jar /opt/module/hadoop-
2.7.2/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.7.2-
tests.jar TestDFSIO -read -nrFiles 10 -fileSize 128MB
19/05/02 11:56:36 INFO fs.TestDFSIO: ----- TestDFSIO ----- : read
19/05/02 11:56:36 INFO fs.TestDFSIO: Date & time: Thu May 02 11:56:36 CST 2019
19/05/02 11:56:36 INFO fs.TestDFSIO: Number of files: 10
19/05/02 11:56:36 INFO fs.TestDFSIO: Total MBytes processed: 1280.0
19/05/02 11:56:36 INFO fs.TestDFSIO: Throughput mb/sec: 16.001000062503905
19/05/02 11:56:36 INFO fs.TestDFSIO: Average IO rate mb/sec: 17.202795028686523
19/05/02 11:56:36 INFO fs.TestDFSIO: IO rate std deviation: 4.881590515873911
19/05/02 11:56:36 INFO fs.TestDFSIO: Test exec time sec: 49.116
19/05/02 11:56:36 INFO fs.TestDFSIO:
```

3、删除测试生成数据

```sh
[atguigu@hadoop102 mapreduce]$ hadoop jar /opt/module/hadoop-
2.7.2/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.7.2-tests.jar TestDFSIO -clean
```

4、使用 Sort 程序评测 MapReduce 计算能力

（1）使用 RandomWriter 来产生随机数，每个节点运行 10 个 Map 任务，每个 Map 产生大约 1G 大小的二进制随机数

```sh
[atguigu@hadoop102 mapreduce]$ hadoop jar /opt/module/hadoop-
2.7.2/share/hadoop/mapreduce/hadoop-mapreduce-examples-
2.7.2.jar randomwriter random-data
```

（2）执行 Sort 程序

```sh
[atguigu@hadoop102 mapreduce]$ hadoop jar /opt/module/hadoop-
2.7.2/share/hadoop/mapreduce/hadoop-mapreduce-examples-
2.7.2.jar sort random-data sorted-data
```

（3）验证数据是否真正排好序了

```sh
[atguigu@hadoop102 mapreduce]$
hadoop jar /opt/module/hadoop-
2.7.2/share/hadoop/mapreduce/hadoop-mapreduce-clientjobclient-2.7.2-tests.jar testmapredsort -sortInput random-data 
-sortOutput sorted-data
```