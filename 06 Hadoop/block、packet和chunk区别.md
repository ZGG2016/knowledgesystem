# block、packet和chunk区别

在客户端向HDFS写数据的过程中，会涉及到如下三个单元：block、packet 与 chunk；

    block ：数据以 block 的形式存储在 DataNode，默认128MB，可通过 dfs.blocksize 属性设置。

    packet：在写数据中，以 packet 为单位写入，默认是64K，可通过 dfs.client-write-packet-size 属性设置。

    chunk：在写数据中，会进行校验，它并不是通过一个 packet 进行一次校验而是以 chunk 为单位进行校验（512byte），可通过 dfs.bytes-per-checksum 属性设置。

## 写过程中的三层buffer

写过程中会以chunk、packet及packet queue三个粒度做三层缓存；

![hdfs06](https://s1.ax1x.com/2020/06/27/N6QS4e.png)

首先，当数据流入DFSOutputStream时，DFSOutputStream内会有一个chunk大小的buf，当数据写满这个buf（或遇到强制flush），会计算checksum值，然后填塞进packet；

当一个chunk填塞进入packet后，仍然不会立即发送，而是累积到一个packet填满后，将这个packet放入dataqueue队列；

进入dataqueue队列的packet会被另一线程按序取出发送到datanode；（注：生产者消费者模型，阻塞生产者的条件是dataqueue与ackqueue之和超过一个block的packet上限）

来源：[HDFS写详解 block、packet与chunk](https://www.jianshu.com/p/0fe0b1d2ff09)
