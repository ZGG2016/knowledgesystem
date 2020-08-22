# 源码：InputSplit类

```java

package org.apache.hadoop.mapreduce;

import java.io.IOException;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;
import org.apache.hadoop.classification.InterfaceStability.Evolving;
import org.apache.hadoop.mapred.SplitLocationInfo;
import org.apache.hadoop.mapreduce.InputFormat;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.RecordReader;

/**
 * <code>InputSplit</code> represents the data to be processed by an 
 * individual {@link Mapper}. 
 * InputSplit 表示一个独立Mapper要处理的数据。
 * <p>Typically, it presents a byte-oriented view on the input and is the 
 * responsibility of {@link RecordReader} of the job to process this and present
 * a record-oriented view.
 * 一般的InputSplit 是字节样式输入，然后由RecordReader转化成记录样式。 
 * 
 * @see InputFormat
 * @see RecordReader
 */
 // 抽象类
@InterfaceAudience.Public
@InterfaceStability.Stable
public abstract class InputSplit {
  /**
   * 抽象方法
   * Get the size of the split, so that the input splits can be sorted by size.
   * 获取一个分片的大小，这样可以根据大小来排序输入分片。
   * 
   * @return the number of bytes in the split  // 分片中字节的数量，类型为long
   * @throws IOException
   * @throws InterruptedException
   */
  public abstract long getLength() throws IOException, InterruptedException;

  /**
   * 抽象方法
   * Get the list of nodes by name where the data for the split would be local.
   * The locations do not need to be serialized.
   * 获取一个分片所在结点的列表
   *
   * @return a new array of the node nodes.  结点的数组  类型为字符串数组
   * @throws IOException
   * @throws InterruptedException
   */
  public abstract 
    String[] getLocations() throws IOException, InterruptedException;
  
  /**
   * Gets info about which nodes the input split is stored on and how it is
   * stored at each location.
   * 获取分片存储的结点的信息，以及存储方式
   * @return list of <code>SplitLocationInfo</code>s describing how the split
   *    data is stored at each location. A null value indicates that all the
   *    locations have the data stored on disk.
   * @throws IOException
   */
  @Evolving
  public SplitLocationInfo[] getLocationInfo() throws IOException {
    return null;
  }
}
```