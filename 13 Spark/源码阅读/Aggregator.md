# Aggregator

```java
package org.apache.spark

import org.apache.spark.annotation.DeveloperApi
import org.apache.spark.util.collection.ExternalAppendOnlyMap

/**
 * :: DeveloperApi ::
 * A set of functions used to aggregate data. 聚合数据的函数集合
 * 
 *                       创建聚合初始值的函数
 * @param createCombiner function to create the initial value of the aggregation.
 *                      合并一个新值到聚合结果的函数
 * @param mergeValue function to merge a new value into the aggregation result.
 *                         从多个 mergeValue function 中，合并输出的函数。
 * @param mergeCombiners function to merge outputs from multiple mergeValue function.
 */
@DeveloperApi
case class Aggregator[K, V, C] (
    createCombiner: V => C,
    mergeValue: (C, V) => C,
    mergeCombiners: (C, C) => C) {

  def combineValuesByKey(
      iter: Iterator[_ <: Product2[K, V]],
      context: TaskContext): Iterator[(K, C)] = {
    val combiners = new ExternalAppendOnlyMap[K, V, C](createCombiner, mergeValue, mergeCombiners)
    combiners.insertAll(iter)
    updateMetrics(context, combiners)
    combiners.iterator
  }

  def combineCombinersByKey(
      iter: Iterator[_ <: Product2[K, C]],
      context: TaskContext): Iterator[(K, C)] = {
  	//ExternalAppendOnlyMap：一个仅能追加的 map ，当空间不够时，将有序内容写入到磁盘。
    val combiners = new ExternalAppendOnlyMap[K, C, C](identity, mergeCombiners, mergeCombiners)
    combiners.insertAll(iter)
    updateMetrics(context, combiners)
    combiners.iterator
  }

  /** Update task metrics after populating the external map. */
  // 填充 external map 后更新任务指标
  private def updateMetrics(context: TaskContext, map: ExternalAppendOnlyMap[_, _, _]): Unit = {
    Option(context).foreach { c =>
    	//通过操作累加器实现
      c.taskMetrics().incMemoryBytesSpilled(map.memoryBytesSpilled)
      c.taskMetrics().incDiskBytesSpilled(map.diskBytesSpilled)
      c.taskMetrics().incPeakExecutionMemory(map.peakMemoryUsedBytes)
    }
  }
}

```