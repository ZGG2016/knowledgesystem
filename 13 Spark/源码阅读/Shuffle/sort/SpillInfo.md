# SpillInfo

```java
package org.apache.spark.shuffle.sort;

import java.io.File;

import org.apache.spark.storage.TempShuffleBlockId;

/**
 * Metadata for a block of data written by {@link ShuffleExternalSorter}.
 */
final class SpillInfo {
  final long[] partitionLengths;
  final File file;
  final TempShuffleBlockId blockId;

  SpillInfo(int numPartitions, File file, TempShuffleBlockId blockId) {
    this.partitionLengths = new long[numPartitions];
    this.file = file;
    this.blockId = blockId;
  }
}

```