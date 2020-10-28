# PartitionedAppendOnlyMap

```java
package org.apache.spark.util.collection

import java.util.Comparator

import org.apache.spark.util.collection.WritablePartitionedPairCollection._

/**
 * WritablePartitionedPairCollection 的实现类。
 * 封装了一个 map，这个 map 的 key 是 (partition ID, K) 元组。
 *
 * Implementation of WritablePartitionedPairCollection that wraps a map in which the keys are tuples
 * of (partition ID, K)
 */
private[spark] class PartitionedAppendOnlyMap[K, V]
  extends SizeTrackingAppendOnlyMap[(Int, K), V] with WritablePartitionedPairCollection[K, V] {

  def partitionedDestructiveSortedIterator(keyComparator: Option[Comparator[K]])
    : Iterator[((Int, K), V)] = {
    val comparator = keyComparator.map(partitionKeyComparator).getOrElse(partitionComparator)
    destructiveSortedIterator(comparator)
  }

  def insert(partition: Int, key: K, value: V): Unit = {
    update((partition, key), value)
  }
}

```