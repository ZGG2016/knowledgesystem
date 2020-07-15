# 源码：WritableComparable接口

```java
package org.apache.hadoop.io;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;

/**
 * A {@link Writable} which is also {@link Comparable}. 
 * Writable 类似于 Comparable(自然排序接口)。
 * <p><code>WritableComparable</code>s can be compared to each other, typically 
 * via <code>Comparator</code>s. Any type which is to be used as a 
 * <code>key</code> in the Hadoop Map-Reduce framework should implement this
 * interface.</p>
 * 通常通过 Comparators ，WritableComparables可以实现互相比较。Hadoop Map-Reduce
 * 框架中的所有类型的 key 都要实现这个接口。
 *
 * <p>Note that <code>hashCode()</code> is frequently used in Hadoop to partition
 * keys. It's important that your implementation of hashCode() returns the same 
 * result across different instances of the JVM. Note also that the default 
 * <code>hashCode()</code> implementation in <code>Object</code> does <b>not</b>
 * satisfy this property.</p>
 * 在hadoop中，hashCode()方法用来对 keys 进行分区。在不同的 JVM 实例中，你实现的 
 * hashCode()方法返回相同的结果是非常重要的。在 Object 对象中实现hashCode()方法
 * 不满足这一属性。
 *
 * <p>Example:</p>
 * <p><blockquote><pre>
 *     public class MyWritableComparable implements WritableComparable<MyWritableComparable> {
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
 *       public int compareTo(MyWritableComparable o) {
 *         int thisValue = this.value;
 *         int thatValue = o.value;
 *         return (thisValue &lt; thatValue ? -1 : (thisValue==thatValue ? 0 : 1));
 *       }
 *
 *       public int hashCode() {
 *         final int prime = 31;
 *         int result = 1;
 *         result = prime * result + counter;
 *         result = prime * result + (int) (timestamp ^ (timestamp &gt;&gt;&gt; 32));
 *         return result
 *       }
 *     }
 * </pre></blockquote></p>
 */
@InterfaceAudience.Public
@InterfaceStability.Stable
public interface WritableComparable<T> extends Writable, Comparable<T> {
} //继承至Writable接口、Comparable接口

/*
 * 实现类有：
 *		BooleanWritable, BytesWritable, ByteWritable, DoubleWritable, 
 *		FloatWritable, ID, ID, IntWritable, JobID, JobID, LongWritable, 
 *		MD5Hash, NullWritable, Record, ShortWritable, TaskAttemptID, 
 *		TaskAttemptID, TaskID, TaskID, Text, VIntWritable, VLongWritable
 *
 */
```