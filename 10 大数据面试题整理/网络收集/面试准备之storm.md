# 面试准备之storm

## storm怎么完成对单词的计数？

	首先定义一个Spout，用来读取一行行单词，然后通过SplitedBolt对一行单词划分，new Values， 其构造函数的参数为(word,1)，然后emit；最后在CountBolt中将单词保存在hashmap中，如果word在map中，那么put word num,如果不在word nums+count。


## storm工作原理，使用其架构图讲解

![](https://i.imgur.com/8Dav9iC.jpg)

	（1）Storm集群中有两种节点，一种是控制节点(Nimbus节点)，另一种是工作节点(Supervisor
	节点)。 Nimbus在集群内分发代码，为每个工作结点指派任务和监控集群。 Supervisor管理运行
	在Supervisor节点上的每一个Worker进程的启动和终止。ZooKeeper用来协调Nimbus和
	Supervisor，如果Supervisor因故障出现问题而无法运行Topology，Nimbus会第一时间感知
	到，并重新分配Topology到其它可用的Supervisor上运行。

	（2）所有Topology任务在Storm客户端节点上提交，Nimbus节点首先将提交的Topology分成一个
	个的Task，并将Task和Supervisor相关的信息提交到 zookeeper集群上。 
	（3）Supervisor会去zookeeper集群上认领自己的Task，通知自己的Worker进程进行Task的处理。

	http://huangyongxing310.iteye.com/blog/2330404
	https://blog.csdn.net/suifeng3051/article/details/41682441
	https://blog.csdn.net/weiyongle1996/article/details/77142245?utm_source=gold_browser_extension


## storm实现可靠性