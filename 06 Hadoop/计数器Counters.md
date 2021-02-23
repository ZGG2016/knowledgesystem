# 计数器Counters

Counter 是一个全局的计数，可由 MapReduce framework 或 applications 定义。每个 Counter 可以是任何的 Enum 类型。一个特定的 Enum 的 Counters 被打包成 Counters.Group 的组。

用户可自定义计数器。在 map 或 reduce 中通过 `Counters.incrCounter(Enum, long)` 或 `Counters.incrCounter(String, String, long)` 更新。

例如，我们有一个文件，其中包含如下内容：

	hello you
	hello me

它被 WordCount 程序执行后显示如下日志：

     //Counter表示计数器，19表示有19个计数器（下面一共4计数器组）
	 Counters: 19 
   	 File Output Format Counters  // 文件输出格式化计数器组
     Bytes Written=19         // reduce输出到hdfs的字节数，一共19个字节
   	 FileSystemCounters       // 文件系统计数器组
     FILE_BYTES_READ=481
     HDFS_BYTES_READ=38
     FILE_BYTES_WRITTEN=81316
     HDFS_BYTES_WRITTEN=19
   	 File Input Format Counters   // 文件输入格式化计数器组
     Bytes Read=19                // map从hdfs读取的字节数
   	 Map-Reduce Framework         // MapReduce框架
     Map output materialized bytes=49
     Map input records=2     // map读入的记录行数，读取两行记录,”hello you”,”hello me”
     Reduce shuffle bytes=0  // 规约分区的字节数
     Spilled Records=8
     Map output bytes=35
     Total committed heap usage (bytes)=266469376
     SPLIT_RAW_BYTES=105
     Combine input records=0  // 合并输入的记录数
     Reduce input records=4   // reduce从map端接收的记录行数
     Reduce input groups=3  // reduce函数接收的key数量，即归并后的k2数量
     Combine output records=0 // 合并输出的记录数
     Reduce output records=3  // reduce输出的记录行数。<helllo,{1,1}>,<you,{1}>,<me,{1}>
     Map output records=4     // map输出的记录行数，输出4行记录	

在上述中，计数器有19个，分为四个组：

	File Output Format Counters
	FileSystemCounters
	File Input Format Counters
	Map-Reduce Framkework