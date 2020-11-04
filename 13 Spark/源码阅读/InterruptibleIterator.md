# InterruptibleIterator

```java
package org.apache.spark

import org.apache.spark.annotation.DeveloperApi

/**
 * 封装一个已存在的迭代器，提供 kill 任务功能。
 * 通过检查 TaskContext 中的中断标记，来起作用。
 *
 * :: DeveloperApi ::
 * An iterator that wraps around an existing iterator to provide task killing functionality.
 * It works by checking the interrupted flag in [[TaskContext]].
 */
@DeveloperApi
class InterruptibleIterator[+T](val context: TaskContext, val delegate: Iterator[T])
  extends Iterator[T] {

  def hasNext: Boolean = {
    // TODO(aarondav/rxin): Check Thread.interrupted instead of context.interrupted if interrupt
    // is allowed. The assumption is that Thread.interrupted does not have a memory fence in read
    // (just a volatile field in C), while context.interrupted is a volatile in the JVM, which
    // introduces an expensive read fence.
    context.killTaskIfInterrupted()
    delegate.hasNext
  }

  def next(): T = delegate.next()
}

```