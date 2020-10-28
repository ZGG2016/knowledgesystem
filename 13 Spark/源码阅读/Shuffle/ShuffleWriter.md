# ShuffleWriter

```java
package org.apache.spark.shuffle

import java.io.IOException

import org.apache.spark.scheduler.MapStatus

/**
 * 把一个 map 任务的输出记录写入到 shuffle 系统
 * Obtained inside a map task to write out records to the shuffle system.
 */
private[spark] abstract class ShuffleWriter[K, V] {
  /** Write a sequence of records to this task's output */
  @throws[IOException]
  def write(records: Iterator[Product2[K, V]]): Unit

  /** Close this writer, passing along whether the map completed */
  def stop(success: Boolean): Option[MapStatus]
}


```