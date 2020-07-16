# 源码：RecordReader类

```java

package org.apache.hadoop.mapreduce;

import java.io.Closeable;
import java.io.IOException;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;

/**
 * The record reader breaks the data into key/value pairs for input to the
 * {@link Mapper}.
 * 记录阅读器的作用是将数据划分为键值对形式交予Mapper处理。
 *
 * @param <KEYIN>
 * @param <VALUEIN>
 */
// 抽象类
@InterfaceAudience.Public
@InterfaceStability.Stable
public abstract class RecordReader<KEYIN, VALUEIN> implements Closeable {

  /**
   * 抽象方法
   * Called once at initialization.
   * 仅在初始化时调用
   * @param split the split that defines the range of records to read
   *        划分的split，它定义了读取记录的范围（逻辑分片，一个起始位置和一个偏移量）
   * @param context the information about the task
   * @throws IOException
   * @throws InterruptedException
   */
  public abstract void initialize(InputSplit split,
                                  TaskAttemptContext context
                                  ) throws IOException, InterruptedException;

  /**
   * 抽象方法
   * Read the next key, value pair. 判断是否还能读取到键值对
   * @return true if a key/value pair was read 如果读到键值对，返回true
   * @throws IOException
   * @throws InterruptedException
   */
  public abstract 
  boolean nextKeyValue() throws IOException, InterruptedException;

  /**
   * 抽象方法
   * Get the current key  获取当前key
   * @return the current key or null if there is no current key 没有，返回null
   * @throws IOException
   * @throws InterruptedException
   */
  public abstract
  KEYIN getCurrentKey() throws IOException, InterruptedException;
  
  /**
   * 抽象方法
   * Get the current value. 获取当前value
   * @return the object that was read
   * @throws IOException
   * @throws InterruptedException
   */
  public abstract 
  VALUEIN getCurrentValue() throws IOException, InterruptedException;
  
  /**
   * 抽象方法
   * The current progress of the record reader through its data.
   * 读取数据的进度，数值在0.0和1.0之间
   * @return a number between 0.0 and 1.0 that is the fraction of the data read
   * @throws IOException
   * @throws InterruptedException
   */
  public abstract float getProgress() throws IOException, InterruptedException;
  
  /**
   * 抽象方法
   * Close the record reader. 关闭阅读器
   */
  public abstract void close() throws IOException;
}

```
