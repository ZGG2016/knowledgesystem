# 如何从根源上解决 HDFS 小文件问题

## 一、HAR files

为了缓解大量小文件带给namenode内存的压力，Hadoop 0.18.0引入了Hadoop Archives
(HAR files)，其本质就是在HDFS之上构建一个分层文件系统。通过执行hadoop archive 
命令就可以创建一个HAR文件。在命令行下，用户可使用一个以har://开头的URL就可以
访问HAR文件中的小文件。使用HAR files可以减少HDFS中的文件数量。

下图为HAR文件的文件结构，可以看出来访问一个指定的小文件需要访问两层索引文件
才能获取小文件在HAR文件中的存储位置，因此，访问一个HAR文件的效率可能会比直
接访问HDFS文件要低。对于一个mapreduce任务来说，如果使用HAR文件作为其输入，
仍旧是其中每个小文件对应一个map task，效率低下。所以，HAR files最好是用于文件归档。

![smallfile01](https://s1.ax1x.com/2020/07/16/UrUo6I.png)


## 二、Sequence Files

除了HAR files，另一种可选是SequenceFile，其核心是以文件名为key，文件内容为
value组织小文件。10000个100KBde 小文件，可以编写程序将这些文件放到一个
SequenceFile文件，然后就以数据流的方式处理这些文件，也可以使用MapReduce进行
处理。一个SequenceFile是可分割的，所以MapReduce可将文件切分成块，每一块独立
操作。不像HAR，SequenceFile支持压缩。在大多数情况下，以block为单位进行压缩是
最好的选择，因为一个block包含多条记录，压缩作用在block智商，比reduce压缩方
（一条一条记录进行压缩）的压缩比高。

把已有的数据转存为SequenceFile比较慢。比起先写小文件，再将小文件写入
SequenceFile，一个更好的选择是直接将数据写入一个SequenceFile文件，省去小文件
作为中间媒介。

下图为SequenceFile的文件结构。HAR files可以列出所有keys，但是SequenceFile是
做不到的，因此，在访问时，只能从文件头顺序访问    

![smallfile02](https://s1.ax1x.com/2020/07/16/UrUTXt.png)

## 三、HBase

除了上面的方法，其实我们还可以将小文件存储到类似于 HBase 的 KV 数据库里面，
也可以将 Key 设置为小文件的文件名，Value 设置为小文件的内容，相比使用 
SequenceFile存储小文件，使用 HBase 的时候我们可以对文件进行修改，甚至能拿到
所有的历史修改版本。

原文链接：[HDFS无法高效存储大量小文件，如何处理好小文件？](https://blog.csdn.net/zyd94857/article/details/79946773)
[如何从根源上解决 HDFS 小文件问题](https://blog.csdn.net/b6ecl1k7BS8O/article/details/83005862?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-5.nonecase&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-5.nonecase)
