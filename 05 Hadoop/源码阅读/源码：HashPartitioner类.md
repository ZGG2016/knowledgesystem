# 源码：HashPartitioner类

```java

package org.apache.hadoop.mapreduce.lib.partition;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;
import org.apache.hadoop.mapreduce.Partitioner;

/** Partition keys by their {@link Object#hashCode()}. */
/** 根据Object#hashCode()返回的值进行划分key*/
@InterfaceAudience.Public
@InterfaceStability.Stable
public class HashPartitioner<K, V> extends Partitioner<K, V> {

  /** Use {@link Object#hashCode()} to partition. */
  public int getPartition(K key, V value,
                          int numReduceTasks) {
    return (key.hashCode() & Integer.MAX_VALUE) % numReduceTasks;
  } 
//public static final int   MAX_VALUE = 0x7fffffff;

}

```
