# sample 和 takeSample 区别

sample:

	对RDD抽样，返回其子集，返回一个RDD。

	有放回抽样，使用泊松分布。无放回抽样，使用伯努利分布

	def sample(
      withReplacement: Boolean,
      fraction: Double,
      seed: Long = Utils.random.nextLong): RDD[T]

takeSample:

    返回一个固定大小的RDD的子集，返回一个数组。

    底层调用了sample方法进行抽样，如果抽样的样本数量小于目标值，再次抽样

    此方法只有在结果数组很小时使用，因为所有的数据都会载入到driver的内存

    def takeSample(
      withReplacement: Boolean,
      num: Int,
      seed: Long = Utils.random.nextLong): Array[T] 