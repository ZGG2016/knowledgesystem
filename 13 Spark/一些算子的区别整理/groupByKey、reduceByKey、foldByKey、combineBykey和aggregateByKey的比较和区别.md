# groupByKey、reduceByKey、foldByKey、combineBykey、aggregateByKey和countByKey的比较和区别

## 1、groupByKey：

	根据每个key分组value，所有的value构成一个序列来返回。所以没有聚合函数。

	不能保证组内元素有序。

	groupByKey不应该使用map端的combine。因为map端的combine不会减少shuffle的数据量，
    还会要求把所有map端的数据插入到hash table里，导致老生代有很多对象。

    groupByKey操作会把所有的键值对放到内存，如果一个key有太多的value，那么会 OutOfMemoryError

	如果你分组是为了执行聚合操作(如sum、average)，那么最好使用 aggregateByKey 或 reduceByKey。

	def groupByKey(partitioner: Partitioner): RDD[(K, Iterable[V])]

	def groupByKey(numPartitions: Int): RDD[(K, Iterable[V])]

## 2、reduceByKey：

	使用一个 reduce 函数合并每个 key 的值。

	在每个 mapper 上执行本地的合并。

	底层调用的combineByKeyWithClassTag函数。

	它的0值就是v本身

	func既是分区内操作，也是分区间操作。

	def reduceByKey(func: (V, V) => V): RDD[(K, V)]

	def reduceByKey(func: (V, V) => V, numPartitions: Int): RDD[(K, V)]

	def reduceByKey(partitioner: Partitioner, func: (V, V) => V): RDD[(K, V)]

## 3、foldByKey：

	使用一个函数和一个中性的"0值"合并每个key对应的values。

	类似reduceByKey，只不过此函数可以自定义"0值"。

	def foldByKey(
      zeroValue: V,
      partitioner: Partitioner)(func: (V, V) => V): RDD[(K, V)] 

    def foldByKey(zeroValue: V, numPartitions: Int)(func: (V, V) => V): RDD[(K, V)]

    def foldByKey(zeroValue: V)(func: (V, V) => V): RDD[(K, V)]

## 4、aggregateByKey：

	使用聚合函数和一个中性的"0值"聚合每个key对应的values。

	底层调用的combineByKeyWithClassTag函数。

	和reduceByKey类似，但更具灵活性，可以自定义0值、在分区内和分区间的聚合操作

	def aggregateByKey[U: ClassTag](zeroValue: U, partitioner: Partitioner)(seqOp: (U, V) => U,
      combOp: (U, U) => U): RDD[(K, U)]

    def aggregateByKey[U: ClassTag](zeroValue: U, numPartitions: Int)(seqOp: (U, V) => U,
      combOp: (U, U) => U): RDD[(K, U)] 

    def aggregateByKey[U: ClassTag](zeroValue: U)(seqOp: (U, V) => U,
      combOp: (U, U) => U): RDD[(K, U)] 

## 5、combineBykey：

	使用一系列的自定义的聚合函数 合并每个key的value.

	底层调用的combineByKeyWithClassTag函数。

	与aggregateByKey类似，不过在aggregateByKey中的第一个参数是zero value，而此函数的第一个参数需要提供一个初始化函数，通过第一个函数完成分区内计算，通过第二个函数完成分区间计算。

	def combineByKey[C](
      createCombiner: V => C,
      mergeValue: (C, V) => C,
      mergeCombiners: (C, C) => C,
      partitioner: Partitioner,          // 分区器
      mapSideCombine: Boolean = true,   //是否在map端本地合并，默认true
      serializer: Serializer = null): RDD[(K, C)]

    def combineByKey[C](
      createCombiner: V => C,
      mergeValue: (C, V) => C,
      mergeCombiners: (C, C) => C,
      numPartitions: Int): RDD[(K, C)]

## 6、countByKey

	统计相同的key的元素有多少个，并将结果收集到本地map，即返回一个map.
   
	只有当结果map是少量的时候，才使用这个方法。因为所有的数据会加载到driver的内存中。

	底层会调用collect，所以不再需要action操作。

	def countByKey(): Map[K, Long]