# 如何从根源上解决 HDFS 小文件问题

## 一、HAR files

为了缓解大量小文件带给 namenode 内存的压力，Hadoop 0.18.0 引入了 Hadoop Archives(HAR files) 。

HAR files 本质就是在 HDFS 之上构建一个分层文件系统。通过执行`hadoop archive` 
命令就可以创建一个 HAR 文件。

在命令行下，用户可使用一个以 `har://` 开头的 URL 就可以访问 HAR 文件中的小文件。使用 `HAR files` 可以减少 HDFS 中的文件数量。

下图为 HAR 文件的文件结构：

![smallfile01](https://s1.ax1x.com/2020/07/16/UrUo6I.png)

可以看出来访问一个指定的小文件**需要访问两层索引文件才能获取小文件在 HAR 文件中的存储位置**，因此，访问一个 HAR 文件的效率可能会比直接访问 HDFS 文件要低。

对于一个 mapreduce 任务来说，**如果使用 HAR 文件作为其输入，
仍旧是其中每个小文件对应一个 map task，效率低下**。所以，HAR files 最好是用于文件归档。


## 二、Sequence Files

除了 HAR files，另一种可选是 SequenceFile，其核心是以**文件名为 key，文件内容为value** 组织小文件。

10000 个 100KB 的小文件，可以编写程序将这些文件放到一个
SequenceFile 文件，然后就以数据流的方式处理这些文件，也可以使用 MapReduce 进行
处理。

一个 **SequenceFile 是可分割的**，所以 MapReduce 可将文件切分成块，每一块独立
操作。

不像 HAR，SequenceFile **支持压缩**。在大多数情况下，以 block 为单位进行压缩是
最好的选择，因为一个 block 包含多条记录，压缩作用在 block 之上，比 reduce 压缩
（一条一条记录进行压缩）的压缩比高。

**把已有的数据转存为 SequenceFile 比较慢**。比起先写小文件，再将小文件写入
SequenceFile，一个更好的选择是直接将数据写入一个 SequenceFile 文件，省去小文件
作为中间媒介。

下图为 SequenceFile 的文件结构。HAR files 可以列出所有 keys，但是 SequenceFile 是做不到的，因此，**在访问时，只能从文件头顺序访问**：    

![smallfile02](https://s1.ax1x.com/2020/07/16/UrUTXt.png)

## 三、HBase

除了上面的方法，其实我们还可以将小文件存储到类似于 HBase 的 KV 数据库里面，
也可以将 Key 设置为小文件的文件名，Value 设置为小文件的内容，相比使用 
SequenceFile存储小文件，使用 HBase 的时候我们可以对文件进行修改，甚至能拿到
所有的历史修改版本。

原文链接：

[HDFS无法高效存储大量小文件，如何处理好小文件？](https://blog.csdn.net/zyd94857/article/details/79946773)

[如何从根源上解决 HDFS 小文件问题](https://blog.csdn.net/b6ecl1k7BS8O/article/details/83005862?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-5.nonecase&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-5.nonecase)
