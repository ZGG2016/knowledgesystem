# 源码：FileSplit类

```java
package org.apache.hadoop.mapreduce.lib.input;

import java.io.IOException;
import java.io.DataInput;
import java.io.DataOutput;

import org.apache.hadoop.mapred.SplitLocationInfo;
import org.apache.hadoop.mapreduce.InputFormat;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;
import org.apache.hadoop.classification.InterfaceStability.Evolving;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;

/** A section of an input file.  Returned by {@link
 * InputFormat#getSplits(JobContext)} and passed to
 * {@link InputFormat#createRecordReader(InputSplit,TaskAttemptContext)}. */

/** 输入文件的一部分。由InputFormat#getSplits(JobContext)返回。
 * 传递给 InputFormat#createRecordReader(InputSplit,TaskAttemptContext)
 */
@InterfaceAudience.Public
@InterfaceStability.Stable
//继承至InputSplit
public class FileSplit extends InputSplit implements Writable {
  private Path file;
  private long start;
  private long length;
  private String[] hosts;
  private SplitLocationInfo[] hostInfos;

  public FileSplit() {}

  /** Constructs a split with host information
   *  根据主机信息创建对象
   * @param file the file name
   * @param start the position of the first byte in the file to process
   * 文件中，要处理的第一个字节的位置。
   * @param length the number of bytes in the file to process
   * 文件中，要处理的字节的数量。 （起止位置和长度）
   * @param hosts the list of hosts containing the block, possibly null
   * 包含块的主机的列表，可能为null
   */
  public FileSplit(Path file, long start, long length, String[] hosts) {
    this.file = file;
    this.start = start;
    this.length = length;
    this.hosts = hosts;
  }
  
  /** Constructs a split with host and cached-blocks information
  *   根据主机信息和cached-blocks信息创建对象
  * @param file the file name
  * @param start the position of the first byte in the file to process
  * @param length the number of bytes in the file to process
  * @param hosts the list of hosts containing the block
  * @param inMemoryHosts the list of hosts containing the block in memory
  * 包含内存中的块的主机的列表  ？？
  */
 public FileSplit(Path file, long start, long length, String[] hosts,
     String[] inMemoryHosts) {
   this(file, start, length, hosts);
   hostInfos = new SplitLocationInfo[hosts.length];
   for (int i = 0; i < hosts.length; i++) {
     // because N will be tiny, scanning is probably faster than a HashSet
	 //因为N很小，所以扫描会比 HashSet 快
     boolean inMemory = false;
     for (String inMemoryHost : inMemoryHosts) {
       if (inMemoryHost.equals(hosts[i])) {  //比对两个包含主机信息的数组
         inMemory = true;
         break;
       }
     }
     hostInfos[i] = new SplitLocationInfo(hosts[i], inMemory);
   }
 }
 
  /** The file containing this split's data. */
  /** 包含分片数据的文件 */
  public Path getPath() { return file; }
  
  /** The position of the first byte in the file to process. */
  /** 要处理的第一个字节的位置。(起始位置) */
  public long getStart() { return start; }
  
  /** The number of bytes in the file to process. */
  /** 要处理的字节的数量。（长度） */
  @Override
  public long getLength() { return length; }

  @Override
  public String toString() { return file + ":" + start + "+" + length; }

  ////////////////////////////////////////////
  // Writable methods
  ////////////////////////////////////////////
  //写入
  @Override
  public void write(DataOutput out) throws IOException {
    Text.writeString(out, file.toString());
    out.writeLong(start);
    out.writeLong(length);
  }
  //读取
  @Override 
  public void readFields(DataInput in) throws IOException {
    file = new Path(Text.readString(in));
    start = in.readLong();
    length = in.readLong();
    hosts = null;
  }
  //所在主机的位置
  @Override
  public String[] getLocations() throws IOException {
    if (this.hosts == null) {
      return new String[]{};
    } else {
      return this.hosts;
    }
  }
  
  @Override
  @Evolving
  public SplitLocationInfo[] getLocationInfo() throws IOException {
    return hostInfos;
  }
}


```