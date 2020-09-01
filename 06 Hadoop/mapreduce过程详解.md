# mapreduce过程详解

![mapreduce01](https://s1.ax1x.com/2020/06/22/NGO3ZD.jpg)

(1)FileSplit读取输入文件后，将其切分成多个逻辑InputSplit实例，
经过RecordReader[LineRecordReader]将InputSplit转化成键值对形式。
一个InputSplit实例由一个Mapper任务处理。

(2)mapper类通过Job.setMapperClass(Class)传给Job，
然后为这个任务的 InputSplit 中每个键值对调用map方法处理。

(3)通过调用 context.write(WritableComparable, Writable)可以收集map方法输出的键值对。
然后写到outputcollector收集器中。

(4)经过outputcollector收集器之后会写入到环形缓缓区中。在环形缓冲区中会做几件事情:

	A:分区：hashpartitioner，(key.hashCode() & Integer.MAX_VALUE) % numReduceTasks;
	        相同的结果进入相同的分区
	B:排序：快速排序法
	排序的时候的两个依据是分区号和key两个作为依据的。
	同一个partition中是按照key进行排序的。
	
结果：数据按照partition为单位聚集在一起，同一partition内的按照key有序。

(5)对中间过程的输出进行本地的聚集，即combine，以降低从 Mapper 到 Reducer 数据传输量。【可选步骤】

(6)每次环形缓冲区容量达80%时，就会新建一个溢出文件(磁盘上)。
在将中间输出结果写磁盘的过程中，可以进行压缩，这样的话，写入磁盘的速度会加快。

(7)在溢写到磁盘之后会进行归并排序，将多个小文件合并成大文件的。
所以合并之后的大文件还是分区、有序的。

(8)reduce端从map端按照相同的分区复制数据，放到磁盘或内存中。

(9)取数据的同时，会按照相同的分区，再将取过来的数据进行归并排序，
大文件的内容按照key有序进行排序。如果前面进行了压缩，此阶段需要解压缩。

(10)如果在reduce前，想要将中间的键的分组规则与键的分组等价规则不同，
那么可以通过 Job.setSortComparatorClass(Class) 来指定一个Comparator，
控制中间结果的key如何被分组，所以结合两者可以实现按**值的二次排序**。
[If equivalence rules for grouping the intermediate keys are required to be 
different from those for grouping keys before reduction]

(11)会调用groupingcomparator进行分组，之后的reduce中会按照这个分组，
每次取出一组数据，调用reduce中自定义的方法进行处理。（一个分组，一个reduce方法）

(12)调用outputformat会将内容写入到文件中。


参考：

[hadoop权威指南]

[MapReduce中各个阶段的分析](https://blog.csdn.net/wyqwilliam/article/details/84669579)

[MapReduce Tutorial](https://hadoop.apache.org/docs/stable/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html#Reducer)

[环形缓冲区1](https://blog.csdn.net/FullStackDeveloper0/article/details/83104370)

[环形缓冲区2](https://www.baidu.com/link?url=jpDE7w3mSR9fQYYrYnc1UlvBDXY9JTfSSlt2rX0leLuzQKVk8rJvVASlygomKIw-UBeoXbuL4M8P1Df7JPaCZq&wd=&eqid=f84db88600050676000000025f33f2ed)