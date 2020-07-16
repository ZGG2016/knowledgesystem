# 源码：InputFormat类
```java
package org.apache.hadoop.mapreduce;

import java.io.IOException;
import java.util.List;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;

/** 
 * <code>InputFormat</code> describes the input-specification for a 
 * Map-Reduce job. InputFormat 为 MapReduce Job 描述输入的细节规范。
 * 
 * <p>The Map-Reduce framework relies on the <code>InputFormat</code> of the
 * job to:<p>
 * <ol>
 *   <li>
 *   Validate the input-specification of the job. 
 *   检查 Job 输入的有效性
 *   <li>
 *   Split-up the input file(s) into logical {@link InputSplit}s, each of 
 *   which is then assigned to an individual {@link Mapper}.
 *   把输入文件切分成多个逻辑InputSplit实例，并分别分发每个InputSplit给一个 Mapper。
 *   </li>
 *   <li>
 *   Provide the {@link RecordReader} implementation to be used to glean
 *   input records from the logical <code>InputSplit</code> for processing by 
 *   the {@link Mapper}.
 *   提供RecordReader，RecordReader从逻辑InputSplit中获得输入记录，交由Mapper处理。
 *   </li>
 * </ol>
 * 
 * <p>The default behavior of file-based {@link InputFormat}s, typically 
 * sub-classes of {@link FileInputFormat}, is to split the 
 * input into <i>logical</i> {@link InputSplit}s based on the total size, in 
 * bytes, of the input files. However, the {@link FileSystem} blocksize of  
 * the input files is treated as an upper bound for input splits. A lower bound 
 * on the split size can be set via 
 * <a href="{@docRoot}/../hadoop-mapreduce-client/hadoop-mapreduce-client-core/mapred-default.xml#mapreduce.input.fileinputformat.split.minsize">
 * mapreduce.input.fileinputformat.split.minsize</a>.</p>
 * 基于文件的InputFormat（通常是 FileInputFormat的子类）默认行为是按照输入
 * 文件的字节大小，把输入数据切分成逻辑InputSplit 。InputSplit的上限是文件
 * 系统的block的大小，下限通过mapreduce.input.fileinputformat.split.minsize 设置
 * 
 * <p>Clearly, logical splits based on input-size is insufficient for many 
 * applications since record boundaries are to respected. In such cases, the
 * application has to also implement a {@link RecordReader} on whom lies the
 * responsibility to respect record-boundaries and present a record-oriented
 * view of the logical <code>InputSplit</code> to the individual task.
 *
 * 考虑到边界情况，对于很多应用程序来说，很明显按照输入文件大小进行逻辑分片
 * 是不能满足需求的。在这种情况下，应用程序需要实现一个RecordReader来处理记录
 * 的边界并为每个任务提供一个逻辑分块的面向记录的视图。
 *
 * @see InputSplit
 * @see RecordReader
 * @see FileInputFormat
 */
@InterfaceAudience.Public
@InterfaceStability.Stable
public abstract class InputFormat<K, V> {

  /** 
   * Logically split the set of input files for the job.  
   *  job 输入文件的逻辑分片集合
   * <p>Each {@link InputSplit} is then assigned to an individual {@link Mapper}
   * for processing.</p>
   *   每个InputSplit都会被分配单独一个Mapper处理。
   * <p><i>Note</i>: The split is a <i>logical</i> split of the inputs and the
   * input files are not physically split into chunks. For e.g. a split could
   * be <i>&lt;input-file-path, start, offset&gt;</i> tuple. The InputFormat
   * also creates the {@link RecordReader} to read the {@link InputSplit}.
   * 分片是输入的逻辑分片，不是将输入文件物理的划分成块。例如：一个分片可能是
   * (input-file-path, start, offset)元组。InputFormat创建RecordReader来读取
   * InputSplit。
   *
   * @param context job configuration.
   * @return an array of {@link InputSplit}s for the job.
   * 返回一个 InputSplit 数组。
   */
  public abstract 
    List<InputSplit> getSplits(JobContext context
                               ) throws IOException, InterruptedException;
  
  /**
   * Create a record reader for a given split. The framework will call
   * {@link RecordReader#initialize(InputSplit, TaskAttemptContext)} before
   * the split is used.
   * 为给定的一个分片，创建一个记录阅读器。在分片被使用之前，框架将会调用 
   * RecordReader#initialize(InputSplit, TaskAttemptContext) 方法进行初始化。
   *
   * @param split the split to be read  待读取的分片
   * @param context the information about the task
   * @return a new record reader
   * @throws IOException
   * @throws InterruptedException
   */
  public abstract 
    RecordReader<K,V> createRecordReader(InputSplit split,
                                         TaskAttemptContext context
                                        ) throws IOException, 
                                                 InterruptedException;

}
```
