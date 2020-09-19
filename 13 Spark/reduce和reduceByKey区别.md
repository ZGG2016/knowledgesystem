# reduce和reduceByKey区别

reduce：

	action算子

	使用二元运算符 reduce RDD中的元素。

	操作对象是普通RDD

	计算逻辑是： 先在每个分区内使用二元运算符计算，再合并每个分区的结果。底层调用了reduceLeft方法来从左到右地作用在每个元素上

	构造：def reduce(f: (T, T) => T): T 

reduceByKey：

	transformation算子

	使用一个 reduce 函数合并每个 key 的值。

	在发生结果到 reducer 前， 它会在每个 mapper 上执行本地的合并。

	操作对象是pair RDD

	计算逻辑是：底层调用了combineByKeyWithClassTag，内部使用了createCombiner、mergeValue和mergeCombiners计算结果。

	构造：
		def reduceByKey(func: (V, V) => V): RDD[(K, V)]
		def reduceByKey(func: (V, V) => V, numPartitions: Int): RDD[(K, V)]
		def reduceByKey(partitioner: Partitioner, func: (V, V) => V): RDD[(K, V)]  