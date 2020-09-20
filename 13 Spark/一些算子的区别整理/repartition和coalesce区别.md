# repartition和coalesce区别

coalesce：

	作用是减少rdd的分区到指定的 `numPartitions` 个数。

	默认不做shuffle【shuffle = false】

	如果减少的分区过大(如，直接减少到1个)，需要设置shuffle = true

	想要合并到更多的分区，需要设置shuffle = true（如，100到1000）
	【shuffle会让数据分布更均匀】

	def coalesce(numPartitions: Int, shuffle: Boolean = false,
               partitionCoalescer: Option[PartitionCoalescer] = Option.empty)
              (implicit ord: Ordering[T] = null)
      : RDD[T]

repartition：

	改变当前rdd的分区数，到numPartitions值。【所以，可增大，可减少】

	如果想要减少分区数，优先使用coalesce，可避免shuffle.

	def repartition(numPartitions: Int)(implicit ord: Ordering[T] = null): RDD[T]