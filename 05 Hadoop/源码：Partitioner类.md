# 源码：Partitioner类

```java

package org.apache.hadoop.mapreduce;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;
import org.apache.hadoop.conf.Configurable;

/** 
 * Partitions the key space.Partitioner 用于划分key空间。
 * 
 * <p><code>Partitioner</code> controls the partitioning of the keys of the 
 * intermediate map-outputs. The key (or a subset of the key) is used to derive
 * the partition, typically by a hash function. The total number of partitions
 * is the same as the number of reduce tasks for the job. Hence this controls
 * which of the <code>m</code> reduce tasks the intermediate key (and hence the 
 * record) is sent for reduction.</p>
 * Partitioner 负责控制 Map 输出结果 key 的分割。
 * Key（或者一个key子集）通常使用 Hash 函数产生分区。
 * 分区的数目与一个作业的 Reducer 任务的数目是一样的。
 * 因此，它控制将中间过程的key（也就是这条记录）应该发送给m个reduce任务中
 * 的哪一个来进行reduce操作。 
 * 
 * Note: If you require your Partitioner class to obtain the Job's configuration
 * object, implement the {@link Configurable} interface.
 * 如果你想要Partitioner类获得job的配置对象，需要实现Configurable接口
 *
 * @see Reducer
 */
@InterfaceAudience.Public
@InterfaceStability.Stable
//抽象类
public abstract class Partitioner<KEY, VALUE> {
  
  /** 
   * Get the partition number for a given key (hence record) given the total 
   * number of partitions i.e. number of reduce-tasks for the job.
   *  给定分区总数(即reduce任务数)，获取给定键(因此记录)的分区号。
   * <p>Typically a hash function on a all or a subset of the key.</p>
   *
   * @param key the key to be partioned. 作为分区依据的key
   * @param value the entry value.
   * @param numPartitions the total number of partitions. 分区总数
   * @return the partition number for the <code>key</code>.
   */
  public abstract int getPartition(KEY key, VALUE value, int numPartitions);
  
}

```