# 1-Spark #

## rdd流程图，宽窄依赖，怎么用代码实现，（先执行哪个后执行哪个） ##  

![](https://i.imgur.com/Fvyu1DB.png)
	
	=========================================
	宽依赖：父RDD的一个分区可以被子RDD的多个分区使用
	窄依赖：父RDD的每个分区只能被子RDD的一个分区使用
	
	=========================================
	代码实现？？？

## rdd任务调度过程 ##

	1.首先在driver程序中启动sparkcontext，在其初始化过程中会创建dag scheduler和task scheduler，
	  向资源管理器注册申请运行executor资源，资源管理器分配资源并启动executor进程，executor会将运行
	  情况通过心跳发送到资源管理器。
	2.sparkcontext构建dag图，将dag图划分成多个stage，dag scheduler将taskset发送到task scheduler,
	  executor向sparkcontext申请task,Task Scheduler将Task发放给Executor运行同时SparkContext将应
	  用程序代码发放给Executor。 
	3.Task在Executor上运行，运行完毕释放所有资源。

## SparkStreaming怎么设置的 ##

	？？？

## RDD的懒加载怎么回事，RDD怎么更新，RDD都有什么***作，区别是啥 ##

## spark是怎么工作的，和Hadoop区别，能不能替代Hadoop ##

## stage是如何划分的 ##

## groupbykey,reducebyke有什么区别 ##

## 混洗是干啥的，如何解决数据倾斜 ##

## 分区的算法，池塘抽样等。 ##

## 如何优化参数 ##