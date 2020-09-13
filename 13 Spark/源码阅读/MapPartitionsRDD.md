# MapPartitionsRDD

```java
package org.apache.spark.rdd

import scala.reflect.ClassTag

import org.apache.spark.{Partition, TaskContext}

/**
 * 将函数作用在父rdd的每个分区产生的rdd
 *
 * An RDD that applies the provided function to every partition of the parent RDD.
 *
 * @param prev the parent RDD.   父rdd
 * @param f The function used to map a tuple of (TaskContext, partition index, input iterator) to 
 *          an output iterator.
 *
 * 将 (TaskContext, partition index, input iterator) 映射成一个输出迭代器的函数
 *
 * @param preservesPartitioning Whether the input function preserves the partitioner, which should
 *                              be `false` unless `prev` is a pair RDD and the input function
 *                              doesn't modify the keys.
 * 
 * 是否保留父rdd的分区信息
 *
 * @param isFromBarrier Indicates whether this RDD is transformed from an RDDBarrier, a stage
 *                      containing at least one RDDBarrier shall be turned into a barrier stage.
 *
 * 表示这个rdd是否从一个RDDBarrier转换而来。
 * 至少包含一个RDDBarrier的stage将被转成一个barrier stage
 *
 * @param isOrderSensitive whether or not the function is order-sensitive. If it's order
 *                         sensitive, it may return totally different result when the input order
 *                         is changed. Mostly stateful functions are order-sensitive.
 * 
 * 函数是否对顺序敏感。如果是，那么当输入顺序变化了，计算结果就会完全不同。
 * 大多数状态函数是顺序敏感
 *
 */
private[spark] class MapPartitionsRDD[U: ClassTag, T: ClassTag](
    var prev: RDD[T],
    f: (TaskContext, Int, Iterator[T]) => Iterator[U],  // (TaskContext, partition index, iterator)
    preservesPartitioning: Boolean = false,
    isFromBarrier: Boolean = false,
    isOrderSensitive: Boolean = false)
// Construct an RDD with just a one-to-one dependency on one parent  没有shuffle
  extends RDD[U](prev) { 

// firstParent:Returns the first parent RDD
// 如果保留父rdd的分区信息，就取出，否则就是None
  override val partitioner = if (preservesPartitioning) firstParent[T].partitioner else None
// partitions:Get the array of partitions of this RDD
  override def getPartitions: Array[Partition] = firstParent[T].partitions

  override def compute(split: Partition, context: TaskContext): Iterator[U] =
    f(context, split.index, firstParent[T].iterator(split, context))

  override def clearDependencies() {
    super.clearDependencies()  // 移除和这个rdd相关的所有依赖
    prev = null
  }

  @transient protected lazy override val isBarrier_ : Boolean =
    isFromBarrier || dependencies.exists(_.rdd.isBarrier())

  // 获取rdd输出的确定性级别
  override protected def getOutputDeterministicLevel = {
  	// 如果是顺序敏感的，同时父rdd是UNORDERED，那么当前rdd的输出INDETERMINATE
    if (isOrderSensitive && prev.outputDeterministicLevel == DeterministicLevel.UNORDERED) {
      DeterministicLevel.INDETERMINATE
    } else {
    // 否则，调用 rdd.getOutputDeterministicLevel()函数，如下
      super.getOutputDeterministicLevel
    }
  }
}

```

RDD下的outputDeterministicLevel、getOutputDeterministicLevel

```java
  /**
   * Returns the deterministic level of this RDD's output. Please refer to [[DeterministicLevel]]
   * for the definition.
   *
   * By default, an reliably checkpointed RDD, or RDD without parents(root RDD) is DETERMINATE. For
   * RDDs with parents, we will generate a deterministic level candidate per parent according to
   * the dependency. The deterministic level of the current RDD is the deterministic level
   * candidate that is deterministic least. Please override [[getOutputDeterministicLevel]] to
   * provide custom logic of calculating output deterministic level.
   */
  // TODO: make it public so users can set deterministic level to their custom RDDs.
  // TODO: this can be per-partition. e.g. UnionRDD can have different deterministic level for
  // different partitions.
  private[spark] final lazy val outputDeterministicLevel: DeterministicLevel.Value = {
    if (isReliablyCheckpointed) {
      DeterministicLevel.DETERMINATE
    } else {
      getOutputDeterministicLevel
    }
  }

  /**
   * outputDeterministicLevel：
   * 默认情况下，
   *    对于一个可靠的、checkpointed 的rdd，或者没有父的rdd，输出是DETERMINATE。
   *    对于有父的rdd，根据依赖关系，为每个父生成一个确定性级别候选。那么当前rdd的确定性级别是确定性最小的候选确定性级别。（???）
   * 
   */

  @DeveloperApi
  protected def getOutputDeterministicLevel: DeterministicLevel.Value = {
    val deterministicLevelCandidates = dependencies.map {
      // The shuffle is not really happening, treat it like narrow dependency and assume the output
      // deterministic level of current RDD is same as parent.
   // shuffle并不会真的发生，把它当作窄依赖，假定当前rdd的输出层级和父rdd的相同。
      case dep: ShuffleDependency[_, _, _] if dep.rdd.partitioner.exists(_ == dep.partitioner) =>
        dep.rdd.outputDeterministicLevel

      case dep: ShuffleDependency[_, _, _] =>
        if (dep.rdd.outputDeterministicLevel == DeterministicLevel.INDETERMINATE) {
          // If map output was indeterminate, shuffle output will be indeterminate as well
        //如果map输出是indeterminate，shuffle输出将也是indeterminate
          DeterministicLevel.INDETERMINATE
        } else if (dep.keyOrdering.isDefined && dep.aggregator.isDefined) {
          // if aggregator specified (and so unique keys) and key ordering specified - then
          // consistent ordering.
      // 如果指定了aggregator和key ordering ，那么就一直有序
          DeterministicLevel.DETERMINATE
        } else {
          // In Spark, the reducer fetches multiple remote shuffle blocks at the same time, and
          // the arrival order of these shuffle blocks are totally random. Even if the parent map
          // RDD is DETERMINATE, the reduce RDD is always UNORDERED.
   // spark中，reducer同时获取多个远程shuffle块，这些块的到达顺序完全随机。
   // 即使父rdd是DETERMINATE，那么reduce RDD总是UNORDERED。
          DeterministicLevel.UNORDERED
        }

      // For narrow dependency, assume the output deterministic level of current RDD is same as
      // parent.
      // 对窄依赖，假定当前rdd的输出层级和父rdd的相同。
      case dep => dep.rdd.outputDeterministicLevel
    }

// 候选集是空，输出级别就是DETERMINATE。
    if (deterministicLevelCandidates.isEmpty) {
      // By default we assume the root RDD is determinate.
      DeterministicLevel.DETERMINATE
    } else {
      deterministicLevelCandidates.maxBy(_.id) //（???）
    }
  }

```

```java
/**
 * The deterministic level of RDD's output (i.e. what `RDD#compute` returns). This explains how
 * the output will diff when Spark reruns the tasks for the RDD. There are 3 deterministic levels:
 * 1. DETERMINATE: The RDD output is always the same data set in the same order after a rerun.
 * 2. UNORDERED: The RDD output is always the same data set but the order can be different
 *               after a rerun.
 * 3. INDETERMINATE. The RDD output can be different after a rerun.
 *
 * Note that, the output of an RDD usually relies on the parent RDDs. When the parent RDD's output
 * is INDETERMINATE, it's very likely the RDD's output is also INDETERMINATE.
 */
private[spark] object DeterministicLevel extends Enumeration {
  val DETERMINATE, UNORDERED, INDETERMINATE = Value
}


/**
 * RDD 输出的确定性级别(如：RDD.compute 返回的)。
 *
 * 这个表明了：当spark在同一RDD上再次运行任务时，输出是如何不同。有以下三种层级：
 *
 *    1. DETERMINATE: 再次运行后，RDD 的输出总是相同的数据集，以相同的顺序。
 *    2. UNORDERED: 再次运行后，RDD 的输出总是相同的数据集，但顺序可能不同。
 *    3. INDETERMINATE：再次运行后，RDD 的输出不同。
 *
 * 注意：由于rdd的输出通常依赖于父rdds，当父rdd的输出是INDETERMINATE，那么这个rdd的输出
 *       很可能也是INDETERMINATE。
 */

```