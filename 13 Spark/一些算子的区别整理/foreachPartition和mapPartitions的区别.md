# foreachPartition和mapPartitions的区别

foreachPartition：

	应用一个函数到这个RDD的每个分区上。

	无返回值。一般用在程序末尾，比如，要将数据存储到mysql、es或hbase等存储系统中

	属于action运算

	def foreachPartition(f: Iterator[T] => Unit): Unit 

mapPartitions：

	对这个rdd的每个分区使用函数操作。

	返回一个新的rdd，继续在返回RDD上做其他的操作。虽然也可以存储数据，但是必须依赖action操作来触发它。

	属于Transformation运算。

	def mapPartitions[U: ClassTag](
      	f: Iterator[T] => Iterator[U],
      	preservesPartitioning: Boolean = false): RDD[U] 

可以类比map和foreach