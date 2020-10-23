# aggregate 和 aggregateByKey 区别


aggregateByKey：

	使用聚合函数和一个中性的"0值"聚合每个key对应的values。操作的是键值对RDD中的value

	这个函数会返回的结果类型U和rdd的value类型V不同。
   
    因此，需要一个操作将V合并到U，再使用另一个操作合并两个U。
   
    前一个操作用来在一个分区内合并value，后一个操作用来在分区间合并value。

    可以指定分区数。

    def aggregateByKey[U: ClassTag](zeroValue: U)(seqOp: (U, V) => U,
      combOp: (U, U) => U)

    def aggregateByKey[U: ClassTag](zeroValue: U, numPartitions: Int)(seqOp: (U, V) => U,
      combOp: (U, U) => U)

    def aggregateByKey[U: ClassTag](zeroValue: U, partitioner: Partitioner)(seqOp: (U, V) => U,
      combOp: (U, U) => U)

aggregate：

	聚合每个分区的元素，然后使用一个聚合函数和一个中性的"0值"聚合这些分区的结果。操作的是RDD
   
    这个函数会返回结果的类型U和rdd的T类型不同。
   
    因此，需要一个操作将T合并到U，再使用另一个操作合并两个U。 

    def aggregate[U: ClassTag](zeroValue: U)(seqOp: (U, T) => U, combOp: (U, U) => U)