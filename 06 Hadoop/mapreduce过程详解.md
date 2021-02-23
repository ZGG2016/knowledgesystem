# mapreduce过程详解

![mapreduce01](https://s1.ax1x.com/2020/06/22/NGO3ZD.jpg)

(1)InputFormat 读入文件，其中，FileSplit 将其切分成多个逻辑 InputSplit 实例，经过 RecordReader[LineRecordReader] 将 InputSplit 转化成键值对形式。

一个 InputSplit 实例由一个 Mapper 任务处理。

(2)mapper 类通过 Job.setMapperClass(Class) 传给 Job，然后为这个任务的 InputSplit 中每个键值对调用 map 方法处理。

(3)通过调用 context.write(WritableComparable, Writable) 收集 map 方法输出的键值对。然后写到 outputcollector 收集器中。

(4)经过 outputcollector 收集器后，写入到环形缓存区中。

在环形缓冲区中会做几件事情:

	A:分区：hashpartitioner，(key.hashCode() & Integer.MAX_VALUE) % numReduceTasks;
	        相同的结果进入相同的分区 （一个分区，一个reduce任务）
	
	B:排序：快速排序法
	排序的时候的两个依据是分区号和key。
	同一个分区中是按照key进行排序的。
	
结果：数据按照 partition 为单位聚集在一起，同一 partition 内的按照 key 有序。

(5)对中间过程的输出进行本地的聚集，即 combine，以降低从 Mapper 到 Reducer 数据传输量。【可选步骤】【在环形缓存区中执行】

(6)每次环形缓冲区容量达80%时，就会新建一个溢出文件(磁盘上)。在将中间输出结果写磁盘的过程中，可以进行压缩，这样的话，写入磁盘的速度会加快。

(7)在溢写到磁盘之后会进行归并排序，将多个小文件合并成大文件的。所以合并之后的大文件还是分区、有序的。

(8)reduce 端从 map 端按照相同的分区复制数据，放到内存中，超过阈值会溢写。

(9)取数据的同时，会按照相同的分区，再将取过来的数据进行归并排序，大文件的内容按照 key 有序进行排序。如果前面进行了压缩，此阶段需要解压缩。

(10)会调用 groupingcomparator 进行分组，之后的 reduce 中会按照这个分组，每次取出一组数据，调用 reduce 中自定义的方法进行处理。（一个分组，一个reduce方法）

(11)调用 outputformat 会将内容写入到文件中。


参考：

[hadoop权威指南]()

[MapReduce中各个阶段的分析](https://blog.csdn.net/wyqwilliam/article/details/84669579)

[MapReduce Tutorial](https://hadoop.apache.org/docs/stable/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html#Reducer)

[环形缓冲区1](https://blog.csdn.net/FullStackDeveloper0/article/details/83104370)

[环形缓冲区2](https://www.baidu.com/link?url=jpDE7w3mSR9fQYYrYnc1UlvBDXY9JTfSSlt2rX0leLuzQKVk8rJvVASlygomKIw-UBeoXbuL4M8P1Df7JPaCZq&wd=&eqid=f84db88600050676000000025f33f2ed)