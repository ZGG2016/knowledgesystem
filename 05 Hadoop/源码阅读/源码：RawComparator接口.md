# 源码：RawComparator接口

```java
package org.apache.hadoop.io;

import java.util.Comparator;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;
import org.apache.hadoop.io.serializer.DeserializerComparator;

/**
 * <p>
 * A {@link Comparator} that operates directly on byte representations of
 * objects. 直接操作 对象字节形式 的比较器
 * </p>
 * @param <T>
 * @see DeserializerComparator
 */
@InterfaceAudience.Public
@InterfaceStability.Stable

// 继承至Comparator接口(一个比较器)
public interface RawComparator<T> extends Comparator<T> {

  /**
   * Compare two objects in binary. 在二进制层面上，比较两个对象
   * b1[s1:l1] is the first object, and b2[s2:l2] is the second object.
   * 
   * @param b1 The first byte array. 第一个参与比较的字节数组
   *  第一个参与比较的字节数组的起始位置
   * @param s1 The position index in b1. The object under comparison's starting index.
   * 第一个参与比较的字节数组的偏移量
   * @param l1 The length of the object in b1. 
   * @param b2 The second byte array. 第二个参与比较的字节数组
   * 第二个参与比较的字节数组的起始位置
   * @param s2 The position index in b2. The object under comparison's starting index.
   * 第二个参与比较的字节数组的偏移量
   * @param l2 The length of the object under comparison in b2.
   * @return An integer result of the comparison. 整型结果
   */
  public int compare(byte[] b1, int s1, int l1, byte[] b2, int s2, int l2);

}
```