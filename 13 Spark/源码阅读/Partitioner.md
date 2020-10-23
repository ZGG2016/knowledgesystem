# Partitioner

**spark-2.4.4-bin-hadoop2.7**

Partitioner.scala

```java

package org.apache.spark

import java.io.{IOException, ObjectInputStream, ObjectOutputStream}

import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer
import scala.math.log10
import scala.reflect.ClassTag
import scala.util.hashing.byteswap32

import org.apache.spark.rdd.{PartitionPruningRDD, RDD}
import org.apache.spark.serializer.JavaSerializer
import org.apache.spark.util.{CollectionsUtils, Utils}
import org.apache.spark.util.random.SamplingUtils

/**
 * An object that defines how the elements in a key-value pair RDD are partitioned by key.
 *
 * 一个定义了键值对 RDD 中的元素是如何根据 key 分区的对象。
 *
 * Maps each key to a partition ID, from 0 to `numPartitions - 1`.
 * 
 * 一个 key 对应一个 partition ID，从 0 到 `numPartitions - 1` （给每个分区编号）
 *
 * Note that, partitioner must be deterministic, i.e. it must return the same partition id given
 * the same partition key.
 *
 * partitioner 必须是确定的，例如，如果给定相同的分区编号，必须返回相同的分区。
 */
abstract class Partitioner extends Serializable {
  def numPartitions: Int  //RDD的分区数
  def getPartition(key: Any): Int  //根据key获取分区编号，从 0 到 `numPartitions - 1`
}

object Partitioner {
  /**
   * Choose a partitioner to use for a cogroup-like operation between a number of RDDs.
   *
   * If spark.default.parallelism is set, we'll use the value of SparkContext defaultParallelism
   * as the default partitions number, otherwise we'll use the max number of upstream partitions.
   *
   * 给定了 spark.default.parallelism ，
   * 就使用它作为默认分区数，否则，使用上游分区的最大数量。
   *
   * When available, we choose the partitioner from rdds with maximum number of partitions. If this
   * partitioner is eligible (number of partitions within an order of maximum number of partitions
   * in rdds), or has partition number higher than default partitions number - we use this
   * partitioner.
   *
   * 在使用时，选择具有最大分区数的rdds的partitioner，
   * 如果这个符合条件，或者分区数大于默认分区数，那么就使用它。
   *
   * 否则，就使用默认分区数来 new HashPartitioner
   *
   * Otherwise, we'll use a new HashPartitioner with the default partitions number.
   *
   * Unless spark.default.parallelism is set, the number of partitions will be the same as the
   * number of partitions in the largest upstream RDD, as this should be least likely to cause
   * out-of-memory errors.
   *
   * 除非设置了 spark.default.parallelism ，
   * 否则分区数和最大的上游RDD的分区数相同。 这种情况应该最不可能导致内存不足错误。
   *
   * We use two method parameters (rdd, others) to enforce callers passing at least 1 RDD.
   */
  def defaultPartitioner(rdd: RDD[_], others: RDD[_]*): Partitioner = {
    //++ 用于连接集合
    val rdds = (Seq(rdd) ++ others)

    //过滤掉未分区的RDD  ？？？
    //partitioner要存在，且分区数大于0，才返回true
    val hasPartitioner = rdds.filter(_.partitioner.exists(_.numPartitions > 0))

    /**
     * // Returns true if this option is nonempty '''and''' the predicate
     * // $p returns true when applied to this $option's value.
     * //Otherwise, returns false.
     *
     *  @param  p   the predicate to test
     *
     * @inline final def exists(p: A => Boolean): Boolean =
     *    !isEmpty && p(this.get)
     *
     */

    //取出具有最大分区数的RDD ？？？
    val hasMaxPartitioner: Option[RDD[_]] = if (hasPartitioner.nonEmpty) {
      Some(hasPartitioner.maxBy(_.partitions.length))
    } else {
      None
    }

    /**
     * 
     * final def partitions: Array[Partition] 获得这个RDD的分区的数组
     *
     */

    // 若配置了 spark.default.parallelism，那么就取这个。
    // 否则，选择具有最大分区数的rdds 的并行度，
    val defaultNumPartitions = if (rdd.context.conf.contains("spark.default.parallelism")) {
      rdd.context.defaultParallelism
    } else {
      rdds.map(_.partitions.length).max
    }

    // If the existing max partitioner is an eligible one, or its partitions number is larger
    // than the default number of partitions, use the existing partitioner.
    // 如果已存在的最大分区器是合法的，或者它的分区数大于默认分区数，就使用已存在的分区器。
    if (hasMaxPartitioner.nonEmpty && (isEligiblePartitioner(hasMaxPartitioner.get, rdds) ||
        defaultNumPartitions < hasMaxPartitioner.get.getNumPartitions)) {
      hasMaxPartitioner.get.partitioner.get
    } else {
      new HashPartitioner(defaultNumPartitions)
    }
  }

  /**
   * Returns true if the number of partitions of the RDD is either greater than or is less than and
   * within a single order of magnitude of the max number of upstream partitions, otherwise returns
   * false.
   *
   * 如果RDD的分区数量大于或小于上游分区的最大数量，并在一个数量级内，则返回true，否则返回false。
   */
  private def isEligiblePartitioner(
     hasMaxPartitioner: RDD[_],
     rdds: Seq[RDD[_]]): Boolean = {
    //取具有最大分区数的RDD的分区数
    val maxPartitions = rdds.map(_.partitions.length).max
    log10(maxPartitions) - log10(hasMaxPartitioner.getNumPartitions) < 1
  }
}

/**
 * A [[org.apache.spark.Partitioner]] that implements hash-based partitioning using
 * Java's `Object.hashCode`.  使用 hashCode 分区
 *
 * Java arrays have hashCodes that are based on the arrays' identities rather than their contents, 
 * so attempting to partition an RDD[Array[_]] or RDD[(Array[_], _)] using a HashPartitioner will 
 * produce an unexpected or incorrect result.
 *
 * java 数组的 hashCodes 不是基于它的内容计算的，而是identities，
 * 所以使用 HashPartitioner 分区 数组RDD会有错误结果。
 */
class HashPartitioner(partitions: Int) extends Partitioner {
  require(partitions >= 0, s"Number of partitions ($partitions) cannot be negative.")

  def numPartitions: Int = partitions

  def getPartition(key: Any): Int = key match {
    case null => 0
    //分区编号的计算方法：
    //先使用key的哈希码值对传入的分区数取余。
    //然后如果余数小于0，那么分区编号就是这个余数和分区数的加和。否则就是这个余数。
    case _ => Utils.nonNegativeMod(key.hashCode, numPartitions)
  }

 /**
  * //Calculates 'x' modulo 'mod', takes to consideration sign of x,
  * //i.e. if 'x' is negative, than 'x' % 'mod' is negative too
  * //so function return (x % mod) + mod in that case.
  *
  * def nonNegativeMod(x: Int, mod: Int): Int = {
  *    val rawMod = x % mod
  *    rawMod + (if (rawMod < 0) mod else 0)
  *}
  */

 //首先传入的也是HashPartitioner，再比较分区数相不相同
  override def equals(other: Any): Boolean = other match {
    case h: HashPartitioner =>
      h.numPartitions == numPartitions
    case _ =>
      false
  }

  override def hashCode: Int = numPartitions  //？？？
}

/**
 * 根据范围，将有序记录划分到大致相等的范围中。
 *  (每个分区的数量大致相同)
 * 范围是通过对传入的RDD的内容进行采样来确定的。 
 *
 * 【在range分区中，会存储一个边界的数组，比如[1,100,200,300,400]，然后对比传进来的key，返回对应的分区id】
 *
 * Range分区最核心的算法了，大概描述下，
 * 就是遍历每个paritiion，对里面的数据进行抽样，
 * 把抽样的数据进行排序，并按照对应的权重确定边界。
 *
 * A [[org.apache.spark.Partitioner]] that partitions sortable records by range into roughly
 * equal ranges. The ranges are determined by sampling the content of the RDD passed in.
 * 
 * @note The actual number of partitions created by the RangePartitioner might not be the same
 * as the `partitions` parameter, in the case where the number of sampled records is less than
 * the value of `partitions`.
 *
 * 在抽样记录的数目小于 partitions 参数值的情况下，RangePartitioner 创建的实际分区数可能和 partitions 参数值不同。
 */
class RangePartitioner[K : Ordering : ClassTag, V](
    partitions: Int,
    rdd: RDD[_ <: Product2[K, V]],
    private var ascending: Boolean = true,
    val samplePointsPerPartitionHint: Int = 20)
  extends Partitioner {

  // A constructor declared in order to maintain backward compatibility for Java, when we add the
  // 4th constructor parameter samplePointsPerPartitionHint. See SPARK-22160.
  // This is added to make sure from a bytecode point of view, there is still a 3-arg ctor.
  // 构造参数，为了兼容java
  def this(partitions: Int, rdd: RDD[_ <: Product2[K, V]], ascending: Boolean) = {
    this(partitions, rdd, ascending, samplePointsPerPartitionHint = 20)
  }

  // We allow partitions = 0, which happens when sorting an empty RDD under the default settings.
  // 在默认设置下，当排序一个空 RDD 时，允许partitions = 0
  require(partitions >= 0, s"Number of partitions cannot be negative but found $partitions.")
  require(samplePointsPerPartitionHint > 0,
    s"Sample points per partition must be greater than 0 but found $samplePointsPerPartitionHint")

  private var ordering = implicitly[Ordering[K]]

  // An array of upper bounds for the first (partitions - 1) partitions
  private var rangeBounds: Array[K] = {
    if (partitions <= 1) {
      Array.empty
    } else {
      // This is the sample size we need to have roughly balanced output partitions, capped at 1M.
      // Cast to double to avoid overflowing ints or longs
      // 这是我们需要大致平衡的输出到分区的样本大小，上限为1M。
      val sampleSize = math.min(samplePointsPerPartitionHint.toDouble * partitions, 1e6)
      // Assume the input partitions are roughly balanced and over-sample a little bit.
      //每个分区的样本大小
      // 每个分区的采样数为平均值的三倍
      val sampleSizePerPartition = math.ceil(3.0 * sampleSize / rdd.partitions.length).toInt
      //通过在每个分区上的水塘采样绘制输入RDD。
      //返回一个元组： (总的样本数，Array(分区id,分区样本数,样本内容))
      //rdd.map(_._1) 取到的是原RDD的key组成的rdd
      val (numItems, sketched) = RangePartitioner.sketch(rdd.map(_._1), sampleSizePerPartition)

      if (numItems == 0L) {
        Array.empty
      } else {
        // If a partition contains much more than the average number of items, we re-sample from it
        // to ensure that enough items are collected from that partition.
        //如果一个分区包含的样本数超过了平均样本数，需要再次重新抽样。
        // ？？？
        val fraction = math.min(sampleSize / math.max(numItems, 1L), 1.0)
        val candidates = ArrayBuffer.empty[(K, Float)]
        val imbalancedPartitions = mutable.Set.empty[Int]
        sketched.foreach { case (idx, n, sample) =>
          if (fraction * n > sampleSizePerPartition) {
            imbalancedPartitions += idx
          } else {
            // The weight is 1 over the sampling probability.
            val weight = (n.toDouble / sample.length).toFloat
            for (key <- sample) {
              candidates += ((key, weight))  //？？？
            }
          }
        }
        if (imbalancedPartitions.nonEmpty) {
          // Re-sample imbalanced partitions with the desired sampling probability.
          //PartitionPruningRDD：An RDD used to prune RDD partitions/partitions
          val imbalanced = new PartitionPruningRDD(rdd.map(_._1), imbalancedPartitions.contains)
          val seed = byteswap32(-rdd.id - 1)
          //重新抽样
          val reSampled = imbalanced.sample(withReplacement = false, fraction, seed).collect()
          val weight = (1.0 / fraction).toFloat
          candidates ++= reSampled.map(x => (x, weight))
        }
        //确定边界
        RangePartitioner.determineBounds(candidates, math.min(partitions, candidates.size))
      }
    }
  }

  // 分区数：要加1
  def numPartitions: Int = rangeBounds.length + 1

  private var binarySearch: ((Array[K], K) => Int) = CollectionsUtils.makeBinarySearch[K]

  //由key取分区编号
  def getPartition(key: Any): Int = {
    val k = key.asInstanceOf[K]
    var partition = 0
    if (rangeBounds.length <= 128) {
      // If we have less than 128 partitions naive search
      //没有超过128，
      //如果编号没有超过边界数组的长度，同时key大于对应的分区边界，那么编号加1
      while (partition < rangeBounds.length && ordering.gt(k, rangeBounds(partition))) {
        partition += 1
      }
    } else {  // 超过128 ，从边界数组里二分查找
      // Determine which binary search method to use only once.
      partition = binarySearch(rangeBounds, k)
      // binarySearch either returns the match location or -[insertion point]-1
      //二分查找的返回值要么是匹配到的位置，要么是-[insertion point]-1
      if (partition < 0) {
        partition = -partition-1
      }
      if (partition > rangeBounds.length) {
        partition = rangeBounds.length
      }
    }
    if (ascending) {
      partition
    } else {
      rangeBounds.length - partition
    }
  }

//首先需要同是RangePartitioner，然后边界数组里的原始相同，且排序相似相同。
  override def equals(other: Any): Boolean = other match {
    case r: RangePartitioner[_, _] =>
      r.rangeBounds.sameElements(rangeBounds) && r.ascending == ascending
    case _ =>
      false
  }

  override def hashCode(): Int = {
    val prime = 31
    var result = 1
    var i = 0
    while (i < rangeBounds.length) {
      result = prime * result + rangeBounds(i).hashCode
      i += 1
    }
    result = prime * result + ascending.hashCode
    result
  }

  @throws(classOf[IOException])
  private def writeObject(out: ObjectOutputStream): Unit = Utils.tryOrIOException {
    val sfactory = SparkEnv.get.serializer
    sfactory match {
      case js: JavaSerializer => out.defaultWriteObject()
      case _ =>
        out.writeBoolean(ascending)
        out.writeObject(ordering)
        out.writeObject(binarySearch)

        val ser = sfactory.newInstance()
        Utils.serializeViaNestedStream(out, ser) { stream =>
          stream.writeObject(scala.reflect.classTag[Array[K]])
          stream.writeObject(rangeBounds)
        }
    }
  }

  @throws(classOf[IOException])
  private def readObject(in: ObjectInputStream): Unit = Utils.tryOrIOException {
    val sfactory = SparkEnv.get.serializer
    sfactory match {
      case js: JavaSerializer => in.defaultReadObject()
      case _ =>
        ascending = in.readBoolean()
        ordering = in.readObject().asInstanceOf[Ordering[K]]
        binarySearch = in.readObject().asInstanceOf[(Array[K], K) => Int]

        val ser = sfactory.newInstance()
        Utils.deserializeViaNestedStream(in, ser) { ds =>
          implicit val classTag = ds.readObject[ClassTag[Array[K]]]()
          rangeBounds = ds.readObject[Array[K]]()
        }
    }
  }
}

private[spark] object RangePartitioner {

  /**
   * 通过在每个分区上的水塘采样绘制输入RDD。
   * Sketches the input RDD via reservoir sampling on each partition.
   * 
   * @param rdd the input RDD to sketch
   * @param sampleSizePerPartition max sample size per partition
   * @return (total number of items, an array of (partitionId, number of items, sample))  总的样本数，(分区id,分区样本数,样本)
   */
  def sketch[K : ClassTag](
      rdd: RDD[K],
      sampleSizePerPartition: Int): (Long, Array[(Int, Long, Array[K])]) = {
    //  /** A unique ID for this RDD (within its SparkContext). */
    //  val id: Int = sc.newRddId()
    val shift = rdd.id
    // val classTagK = classTag[K] // to avoid serializing the entire partitioner object
    val sketched = rdd.mapPartitionsWithIndex { (idx, iter) =>
      val seed = byteswap32(idx ^ (shift << 16))
      //采样后的结果 ：样本和样本数量
      val (sample, n) = SamplingUtils.reservoirSampleAndCount(
        iter, sampleSizePerPartition, seed)
      Iterator((idx, n, sample))
    }.collect()
    //把每个分区中的样本数加和。
    val numItems = sketched.map(_._2).sum  //_._2 
    (numItems, sketched)  // sketched:  (idx, n, sample)
  }
  /**
   * 返回输入大小的水塘采样实现
   * def reservoirSampleAndCount[T: ClassTag](
   *   input: Iterator[T],k: Int, seed: Long = Random.nextLong()): (Array[T], Long) =
   * 参数：
   *    input:input size
   *    k:reservoir size
   *    seed：random seed
   * 返回值：(samples, input size)  
   *
   */

  /**
   * 确定从候选对象进行范围划分的界限，并使用权重表示每个候选对象所代表的项数
   * Determines the bounds for range partitioning from candidates with weights indicating how many
   * items each represents. Usually this is 1 over the probability used to sample this candidate.
   *  
   * @param candidates unordered candidates with weights 带有权重的未排序的候选集
   * @param partitions number of partitions
   * @return selected bounds
   */
  def determineBounds[K : Ordering : ClassTag](
      candidates: ArrayBuffer[(K, Float)], // Float代表候选对象对应的权重
      partitions: Int): Array[K] = {
    val ordering = implicitly[Ordering[K]]
    //根据第一个值排序，返回排序后的candidates
    val ordered = candidates.sortBy(_._1)
    //候选集大小
    val numCandidates = ordered.size
    //权重总和，权重表示每个候选对象所代表的项数
    val sumWeights = ordered.map(_._2.toDouble).sum
    //每个分区理论的大小
    val step = sumWeights / partitions
    var cumWeight = 0.0
    var target = step
    val bounds = ArrayBuffer.empty[K]
    var i = 0
    var j = 0
    var previousBound = Option.empty[K]
    while ((i < numCandidates) && (j < partitions - 1)) {
      //取出第i个候选对象及其权重
      val (key, weight) = ordered(i)
      cumWeight += weight
      //累积的项数大于等于理论大小，更新边界。否则，继续取下个候选对象。
      if (cumWeight >= target) {
        // Skip duplicate values.
        // 比较当前候选对象和当前边界
        if (previousBound.isEmpty || ordering.gt(key, previousBound.get)) {
          bounds += key  //当前候选对象添加进去最终的ArrayBuffer
          target += step //进入下个分区，下个分区的理论大小
          j += 1
          previousBound = Some(key) //更新当前边界
        }
      }
      i += 1
    }
    bounds.toArray
  }
}
```

[参考1](https://www.jianshu.com/p/56579d1793fa)、[参考2](https://blog.csdn.net/wayne_2015/article/details/70242618)、[参考3](https://www.jianshu.com/p/b74b9663a36c)
