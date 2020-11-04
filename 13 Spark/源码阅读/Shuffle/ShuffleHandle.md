# ShuffleHandle

```java
package org.apache.spark.shuffle

import org.apache.spark.annotation.DeveloperApi

/**
 * ShuffleManager 用来给 tasks 传递 shuffle 信息
 *
 * An opaque handle to a shuffle, used by a ShuffleManager to pass information about it to tasks.  
 *
 * @param shuffleId ID of the shuffle
 */
@DeveloperApi
abstract class ShuffleHandle(val shuffleId: Int) extends Serializable {}

```