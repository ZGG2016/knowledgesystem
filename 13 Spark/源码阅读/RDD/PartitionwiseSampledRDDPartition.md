# PartitionwiseSampledRDDPartition

```java
package org.apache.spark.rdd

import java.util.Random

import scala.reflect.ClassTag

import org.apache.spark.{Partition, TaskContext}
import org.apache.spark.util.Utils
import org.apache.spark.util.random.RandomSampler

private[spark]
class PartitionwiseSampledRDDPartition(val prev: Partition, val seed: Long)
  extends Partition with Serializable {
  override val index: Int = prev.index
}

/**
 * 抽样后，返回的RDD
 *
 * 使用RandomSampler实例在分区内抽样
 *
 * An RDD sampled from its parent RDD partition-wise. For each partition of the parent RDD,
 * a user-specified [[org.apache.spark.util.random.RandomSampler]] instance is used to obtain
 * a random sample of the records in the partition. The random seeds assigned to the samplers
 * are guaranteed to have different values.
 *
 * @param prev RDD to be sampled  要被抽样的RDD
 * @param sampler a random sampler   RandomSampler实例
 * @param preservesPartitioning whether the sampler preserves the partitioner of the parent RDD   子RDD是否和父RDD的分区一致。
 * @param seed random seed
 * @tparam T input RDD item type
 * @tparam U sampled RDD item type
 */
private[spark] class PartitionwiseSampledRDD[T: ClassTag, U: ClassTag](
    prev: RDD[T],
    sampler: RandomSampler[T, U],
    preservesPartitioning: Boolean,
    @transient private val seed: Long = Utils.random.nextLong)
  extends RDD[U](prev) {

  //true，分区数不变；false，None
  @transient override val partitioner = if (preservesPartitioning) prev.partitioner else None

  override def getPartitions: Array[Partition] = {
    val random = new Random(seed)
    // firstParent：Returns the first parent RDD
    //partitions:获得这个rdd的所有分区，数组形式返回
    //map：对每个分区操作，new一个PartitionwiseSampledRDDPartition对象
    firstParent[T].partitions.map(x => new PartitionwiseSampledRDDPartition(x, random.nextLong()))
  }

  //传入一个分区，取它在第一个父rdd的位置，Seq的形式返回
  override def getPreferredLocations(split: Partition): Seq[String] =
  // preferredLocations：Get the preferred locations of a partition
    firstParent[T].preferredLocations(split.asInstanceOf[PartitionwiseSampledRDDPartition].prev)


  override def compute(splitIn: Partition, context: TaskContext): Iterator[U] = {
    val split = splitIn.asInstanceOf[PartitionwiseSampledRDDPartition]
    val thisSampler = sampler.clone
    thisSampler.setSeed(split.seed)
    //对一个分区，取一个随机样本
    //过滤出来能被抽样的项
    thisSampler.sample(firstParent[T].iterator(split.prev, context))
  }
}

/**
 * // take a random sample
 * def sample(items: Iterator[T]): Iterator[U] =
 *     items.filter(_ => sample > 0).asInstanceOf[Iterator[U]]
 *
 * filter:过滤迭代器，返回满足条件的所有元素
 *
 * //是否抽样下一项。返回下一项将被抽样的次数。如果未被抽样，则返回0。
 * def sample(): Int
 */

```