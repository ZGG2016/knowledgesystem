# 源码：Writable接口

```java
package org.apache.hadoop.io;

import java.io.DataOutput;
import java.io.DataInput;
import java.io.IOException;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;

/**
 * A serializable object which implements a simple, efficient, serialization 
 * protocol, based on {@link DataInput} and {@link DataOutput}.
 * 这是一个序列化对象。基于 DataInput 和 DataOutput，它实现了一个简单、高效、
 * 序列化协议。
 *
 * <p>Any <code>key</code> or <code>value</code> type in the Hadoop Map-Reduce
 * framework implements this interface.</p>
 *  Hadoop Map-Reduce 中的任何 key 或 value 类型都要实现这个接口
 *
 * <p>Implementations typically implement a static <code>read(DataInput)</code>
 * method which constructs a new instance, calls {@link #readFields(DataInput)} 
 * and returns the instance.</p>
 * 它的实现类要重写静态的read方法，这个方法通过调用 readFields 
 * 方法来返回一个新的实例对象。
 *
 * <p>Example:</p>
 * <p><blockquote><pre>
 *     public class MyWritable implements Writable {
 *       // Some data     
 *       private int counter;
 *       private long timestamp;
 *       
 *       public void write(DataOutput out) throws IOException {
 *         out.writeInt(counter);
 *         out.writeLong(timestamp);
 *       }
 *       
 *       public void readFields(DataInput in) throws IOException {
 *         counter = in.readInt();
 *         timestamp = in.readLong();
 *       }
 *       
 *       public static MyWritable read(DataInput in) throws IOException {
 *         MyWritable w = new MyWritable();
 *         w.readFields(in);
 *         return w;
 *       }
 *     }
 * </pre></blockquote></p>
 */
@InterfaceAudience.Public
@InterfaceStability.Stable
public interface Writable {  //接口
  /** 
   * Serialize the fields of this object to <code>out</code>.
   *  将此对象写到输出流
   * @param out <code>DataOuput</code> to serialize this object into.
   * @throws IOException
   */
  void write(DataOutput out) throws IOException;

  /** 
   * Deserialize the fields of this object from <code>in</code>.  
   *  从输入流中读取此对象
   * <p>For efficiency, implementations should attempt to re-use storage in the 
   * existing object where possible.</p>
   * 
   * @param in <code>DataInput</code> to deseriablize this object from.
   * @throws IOException
   */
  void readFields(DataInput in) throws IOException;
}

/*
 * 子接口：
 *  Counter, CounterGroup, CounterGroupBase<T>, InputSplit, 
 *  InputSplitWithLocationInfo, WritableComparable<T>
 *
 * 实现类：
 *  BooleanWritable, BytesWritable, ByteWritable, LongWritable,
 *  ArrayWritable,FileSplit....
 */

```

