# BaseShuffleHandle

```java
package org.apache.spark.shuffle

import org.apache.spark.ShuffleDependency

/**
 * 获取注册的 shuffle 的参数
 * A basic ShuffleHandle implementation that just captures registerShuffle's parameters.
 */
private[spark] class BaseShuffleHandle[K, V, C](
    shuffleId: Int,
    val numMaps: Int,
    val dependency: ShuffleDependency[K, V, C])
  extends ShuffleHandle(shuffleId)
```

```java
package org.apache.spark.shuffle

import org.apache.spark.annotation.DeveloperApi

/**
 * An opaque handle to a shuffle, used by a ShuffleManager to pass information about it to tasks.
 *
 * @param shuffleId ID of the shuffle
 */
@DeveloperApi
abstract class ShuffleHandle(val shuffleId: Int) extends Serializable {}

```