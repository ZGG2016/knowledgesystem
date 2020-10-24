# AccumulatorV2

```java
package org.apache.spark.util

import java.{lang => jl}
import java.io.ObjectInputStream
import java.util.{ArrayList, Collections}
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicLong

import org.apache.spark.{InternalAccumulator, SparkContext, TaskContext}
import org.apache.spark.internal.Logging
import org.apache.spark.scheduler.AccumulableInfo

private[spark] case class AccumulatorMetadata(
    id: Long,
    name: Option[String],
    countFailedValues: Boolean) extends Serializable


/**
 * 累加器的基类，可以累加类型为`IN`的输入，产生类型为`OUT`的输出。
 *
 * The base class for accumulators, that can accumulate inputs of type `IN`, and produce output of
 * type `OUT`.
 *
 * `OUT` 应该是一个能被原子的读取的类型(如, Int, Long)，
 *  或者是线程安全的(如,synchronized collections)，因此它会从其他线程中的读取。
 *
 * `OUT` should be a type that can be read atomically (e.g., Int, Long), or thread-safely
 * (e.g., synchronized collections) because it will be read from other threads.
 */
abstract class AccumulatorV2[IN, OUT] extends Serializable {
  private[spark] var metadata: AccumulatorMetadata = _
  private[this] var atDriverSide = true

  private[spark] def register(
      sc: SparkContext,
      name: Option[String] = None,
      countFailedValues: Boolean = false): Unit = {
  	//this代表要注册的累加器
  	//元数据是null，才能注册。
    if (this.metadata != null) {
      throw new IllegalStateException("Cannot register an Accumulator twice.")
    }
    //AccumulatorContext.newId()：为累加器创建一个全局唯一的id
    this.metadata = AccumulatorMetadata(AccumulatorContext.newId(), name, countFailedValues)
    AccumulatorContext.register(this)
    //如果累加器在这注册了，它应该在活跃的 context cleaner 中注册以便进行清理，以避免内存泄漏。
    //具体见AccumulatorContext
    sc.cleaner.foreach(_.registerAccumulatorForCleanup(this))
  }

  /**
   * 判断累加器是否被注册了。 要其元数据不为null,且累加器对象也是被定义了的
   *
   * 累加器在使用前必须要注册。
   *
   * Returns true if this accumulator has been registered.
   *
   * @note All accumulators must be registered before use, or it will throw exception.
   */
  final def isRegistered: Boolean =
    metadata != null && AccumulatorContext.get(metadata.id).isDefined

  private def assertMetadataNotNull(): Unit = {
    if (metadata == null) {
      throw new IllegalStateException("The metadata of this accumulator has not been assigned yet.")
    }
  }

  /**
   *  取这个累加器的id.
   * Returns the id of this accumulator, can only be called after registration.
   */
  final def id: Long = {
    assertMetadataNotNull()
    metadata.id
  }

  /**
   * 取这个累加器的名称
   * Returns the name of this accumulator, can only be called after registration.
   */
  final def name: Option[String] = {
    assertMetadataNotNull()

    //？？
    if (atDriverSide) {
      metadata.name.orElse(AccumulatorContext.get(id).flatMap(_.metadata.name))
    } else {
      metadata.name
    }
  }

  /**
   * 是否从失败的任务中累加值。
   *
   * Whether to accumulate values from failed tasks. This is set to true for system and time
   * metrics like serialization time or bytes spilled, and false for things with absolute values
   * like number of input rows.  This should be used for internal metrics only.
   */
  private[spark] final def countFailedValues: Boolean = {
    assertMetadataNotNull()
    metadata.countFailedValues
  }

  /**
   * Creates an [[AccumulableInfo]] representation of this [[AccumulatorV2]] with the provided
   * values.
   */

  //AccumulableInfo：Information about an [[org.apache.spark.Accumulable]] modified during a task or stage.
  private[spark] def toInfo(update: Option[Any], value: Option[Any]): AccumulableInfo = {
    val isInternal = name.exists(_.startsWith(InternalAccumulator.METRICS_PREFIX))
    new AccumulableInfo(id, name, update, value, isInternal, countFailedValues)
  }

  final private[spark] def isAtDriverSide: Boolean = atDriverSide

  /**
   * Returns if this accumulator is zero value or not. e.g. for a counter accumulator, 0 is zero
   * value; for a list accumulator, Nil is zero value.
   */
  //判断这个累加器是不是0值。
  def isZero: Boolean

  /**
   * 创建这个累加器的一个新的副本，它是0值。
   * 
   * Creates a new copy of this accumulator, which is zero value. i.e. call `isZero` on the copy
   * must return true.
   */
  def copyAndReset(): AccumulatorV2[IN, OUT] = {
    val copyAcc = copy()
    copyAcc.reset()  //重置这个累加器为0值
    copyAcc
  }

  /**
   * Creates a new copy of this accumulator.
   */
  def copy(): AccumulatorV2[IN, OUT]

  /**
   * Resets this accumulator, which is zero value. i.e. call `isZero` must
   * return true.
   */
  def reset(): Unit

  /**
   * Takes the inputs and accumulates.
   */
  def add(v: IN): Unit

  /**
   * 合并另一个相同类型的累加器到这个累加器，并更新其状态。
   *
   * Merges another same-type accumulator into this one and update its state, i.e. this should be
   * merge-in-place.
   */
  def merge(other: AccumulatorV2[IN, OUT]): Unit

  /**
   * Defines the current value of this accumulator  定义这个累加器的当前值
   */
  def value: OUT

  // Called by Java when serializing an object
  final protected def writeReplace(): Any = {
    if (atDriverSide) {
      if (!isRegistered) {
        throw new UnsupportedOperationException(
          "Accumulator must be registered before send to executor")
      }
      val copyAcc = copyAndReset()
      assert(copyAcc.isZero, "copyAndReset must return a zero value copy")
      val isInternalAcc = name.isDefined && name.get.startsWith(InternalAccumulator.METRICS_PREFIX)
      if (isInternalAcc) {
        // Do not serialize the name of internal accumulator and send it to executor.
        copyAcc.metadata = metadata.copy(name = None)
      } else {
        // For non-internal accumulators, we still need to send the name because users may need to
        // access the accumulator name at executor side, or they may keep the accumulators sent from
        // executors and access the name when the registered accumulator is already garbage
        // collected(e.g. SQLMetrics).
        copyAcc.metadata = metadata
      }
      copyAcc
    } else {
      this
    }
  }

  // Called by Java when deserializing an object
  private def readObject(in: ObjectInputStream): Unit = Utils.tryOrIOException {
    in.defaultReadObject()
    if (atDriverSide) {
      atDriverSide = false

      // Automatically register the accumulator when it is deserialized with the task closure.
      // This is for external accumulators and internal ones that do not represent task level
      // metrics, e.g. internal SQL metrics, which are per-operator.
      val taskContext = TaskContext.get()
      if (taskContext != null) {
        taskContext.registerAccumulator(this)
      }
    } else {
      atDriverSide = true
    }
  }

  override def toString: String = {
    // getClass.getSimpleName can cause Malformed class name error,
    // call safer `Utils.getSimpleName` instead
    if (metadata == null) {
      "Un-registered Accumulator: " + Utils.getSimpleName(getClass)
    } else {
      Utils.getSimpleName(getClass) + s"(id: $id, name: $name, value: $value)"
    }
  }
}


/**
 * 一个内部类，用于通过Spark本身跟踪累加器。
 * An internal class used to track accumulators by Spark itself.
 */
private[spark] object AccumulatorContext extends Logging {

  /**
   * This global map holds the original accumulator objects that are created on the driver.
   * It keeps weak references to these objects so that accumulators can be garbage-collected
   * once the RDDs and user-code that reference them are cleaned up.
   * TODO: Don't use a global map; these should be tied to a SparkContext (SPARK-13051).
   */
  /**
   * 这是一个全局的map，保存着原始的累加器对象，这个对象是在driver端创建的。
   * 它保持着对这些对象的弱引用。
   * 一旦RDD和用户代码清除了对累加器的引用，那么它们能被垃圾回收。
   *
   * key:累加器id；value:累加器对象的弱引用
   */

  //注册就是将累加器放入ConcurrentHashMap中
  private val originals = new ConcurrentHashMap[Long, jl.ref.WeakReference[AccumulatorV2[_, _]]]

  //AtomicLong：可以被原子更新的一个long值
  private[this] val nextId = new AtomicLong(0L)

  /**
   * 为一个新的累加器对象，创建一个全局唯一的ID。
   *
   * 一旦复制了这个累加器对象，这个ID就不再唯一了。
   *
   * Returns a globally unique ID for a new [[AccumulatorV2]].
   * Note: Once you copy the [[AccumulatorV2]] the ID is no longer unique.
   */
  //getAndIncrement：原子的增加1
  def newId(): Long = nextId.getAndIncrement

  /** Returns the number of accumulators registered. Used in testing. */
  //返回注册的累加器对象的数量
  def numAccums: Int = originals.size

  /**
   * Registers an [[AccumulatorV2]] created on the driver such that it can be used on the executors.
   *
   * All accumulators registered here can later be used as a container for accumulating partial
   * values across multiple tasks. This is what `org.apache.spark.scheduler.DAGScheduler` does.
   * Note: if an accumulator is registered here, it should also be registered with the active
   * context cleaner for cleanup so as to avoid memory leaks.
   *
   * If an [[AccumulatorV2]] with the same ID was already registered, this does nothing instead
   * of overwriting it. We will never register same accumulator twice, this is just a sanity check.
   */
   /**
   * 注册一个在driver端创建的累加器对象，为了能让它在executors上使用。
   *
   * 所有在这里注册的累加器可以被用作一个container，在多个任务间累加值。这就是DAGScheduler所做的。
   * 
   * 注意：如果累加器在这注册了，它应该在活跃的 context cleaner 中注册以便进行清理，以避免内存泄漏。
   * 
   * 如果想要注册的累加器，已被注册，那么就不能再注册了。
   * 
   */
  def register(a: AccumulatorV2[_, _]): Unit = {
  	//a.id：累加器id
    originals.putIfAbsent(a.id, new jl.ref.WeakReference[AccumulatorV2[_, _]](a))
  }

  /**
   * Unregisters the [[AccumulatorV2]] with the given ID, if any.  取消注册
   */
  def remove(id: Long): Unit = {
    originals.remove(id)
  }

  /**
   * 由id取累加器对象
   *
   * Returns the [[AccumulatorV2]] registered with the given ID, if any.
   */
  def get(id: Long): Option[AccumulatorV2[_, _]] = {
    val ref = originals.get(id)
    if (ref eq null) {
      None
    } else {
      // Since we are storing weak references, warn when the underlying data is not valid.
      //get：return the object to which this reference refers
      val acc = ref.get
      if (acc eq null) {
        logWarning(s"Attempted to access garbage collected accumulator $id")
      }
      Option(acc)
    }
  }

  /**
   * Clears all registered [[AccumulatorV2]]s. For testing only. 清楚所有注册了的累加器
   */
  def clear(): Unit = {
    originals.clear()
  }

  // Identifier for distinguishing SQL metrics from other accumulators
  private[spark] val SQL_ACCUM_IDENTIFIER = "sql"
}


/**
 * 一个AccumulatorV2累加器，用来计算64位整型的求和、个数和均值。
 *
 * An [[AccumulatorV2 accumulator]] for computing sum, count, and average of 64-bit integers.
 *
 * @since 2.0.0
 */
class LongAccumulator extends AccumulatorV2[jl.Long, jl.Long] {
  private var _sum = 0L
  private var _count = 0L

  /**
   * Returns false if this accumulator has had any values added to it or the sum is non-zero.
   *
   * @since 2.0.0
   */
  override def isZero: Boolean = _sum == 0L && _count == 0

  override def copy(): LongAccumulator = {
    val newAcc = new LongAccumulator
    newAcc._count = this._count
    newAcc._sum = this._sum
    newAcc
  }

  override def reset(): Unit = {
    _sum = 0L
    _count = 0L
  }

  /**
   * Adds v to the accumulator, i.e. increment sum by v and count by 1.
   * @since 2.0.0
   */
  override def add(v: jl.Long): Unit = {
    _sum += v
    _count += 1
  }

  /**
   * Adds v to the accumulator, i.e. increment sum by v and count by 1.
   * @since 2.0.0
   */
  def add(v: Long): Unit = {
    _sum += v
    _count += 1
  }

  /**
   * 返回添加到这个累加器的元素的数量
   * Returns the number of elements added to the accumulator.
   * @since 2.0.0
   */
  def count: Long = _count

  /**
   * 返回添加到这个累加器的元素的和
   * Returns the sum of elements added to the accumulator.
   * @since 2.0.0
   */
  def sum: Long = _sum

  /**
   * 返回添加到这个累加器的元素的均值
   * Returns the average of elements added to the accumulator.
   * @since 2.0.0
   */
  def avg: Double = _sum.toDouble / _count

  override def merge(other: AccumulatorV2[jl.Long, jl.Long]): Unit = other match {
    case o: LongAccumulator =>
      _sum += o.sum
      _count += o.count
    case _ =>
      throw new UnsupportedOperationException(
        s"Cannot merge ${this.getClass.getName} with ${other.getClass.getName}")
  }

  private[spark] def setValue(newValue: Long): Unit = _sum = newValue

  override def value: jl.Long = _sum
}


/**
 * 一个AccumulatorV2累加器，用来计算double类型的求和、个数和均值。
 * An [[AccumulatorV2 accumulator]] for computing sum, count, and averages for double precision
 * floating numbers.
 *
 * @since 2.0.0
 */
class DoubleAccumulator extends AccumulatorV2[jl.Double, jl.Double] {
  private var _sum = 0.0
  private var _count = 0L

  /**
   * Returns false if this accumulator has had any values added to it or the sum is non-zero.
   */
  override def isZero: Boolean = _sum == 0.0 && _count == 0

  override def copy(): DoubleAccumulator = {
    val newAcc = new DoubleAccumulator
    newAcc._count = this._count
    newAcc._sum = this._sum
    newAcc
  }

  override def reset(): Unit = {
    _sum = 0.0
    _count = 0L
  }

  /**
   * Adds v to the accumulator, i.e. increment sum by v and count by 1.
   * @since 2.0.0
   */
  override def add(v: jl.Double): Unit = {
    _sum += v
    _count += 1
  }

  /**
   * Adds v to the accumulator, i.e. increment sum by v and count by 1.
   * @since 2.0.0
   */
  def add(v: Double): Unit = {
    _sum += v
    _count += 1
  }

  /**
   * Returns the number of elements added to the accumulator.
   * @since 2.0.0
   */
  def count: Long = _count

  /**
   * Returns the sum of elements added to the accumulator.
   * @since 2.0.0
   */
  def sum: Double = _sum

  /**
   * Returns the average of elements added to the accumulator.
   * @since 2.0.0
   */
  def avg: Double = _sum / _count

  override def merge(other: AccumulatorV2[jl.Double, jl.Double]): Unit = other match {
    case o: DoubleAccumulator =>
      _sum += o.sum
      _count += o.count
    case _ =>
      throw new UnsupportedOperationException(
        s"Cannot merge ${this.getClass.getName} with ${other.getClass.getName}")
  }

  private[spark] def setValue(newValue: Double): Unit = _sum = newValue

  override def value: jl.Double = _sum
}


/**
 * 一个AccumulatorV2累加器，用来收集元素列表
 * An [[AccumulatorV2 accumulator]] for collecting a list of elements.
 *
 * @since 2.0.0
 */
class CollectionAccumulator[T] extends AccumulatorV2[T, java.util.List[T]] {
  private val _list: java.util.List[T] = Collections.synchronizedList(new ArrayList[T]())

  /**
   * Returns false if this accumulator instance has any values in it.
   */
  override def isZero: Boolean = _list.isEmpty

  override def copyAndReset(): CollectionAccumulator[T] = new CollectionAccumulator

  override def copy(): CollectionAccumulator[T] = {
    val newAcc = new CollectionAccumulator[T]
    _list.synchronized {
      newAcc._list.addAll(_list)
    }
    newAcc
  }

  override def reset(): Unit = _list.clear()

  override def add(v: T): Unit = _list.add(v)

  override def merge(other: AccumulatorV2[T, java.util.List[T]]): Unit = other match {
    case o: CollectionAccumulator[T] => _list.addAll(o.value)
    case _ => throw new UnsupportedOperationException(
      s"Cannot merge ${this.getClass.getName} with ${other.getClass.getName}")
  }

  override def value: java.util.List[T] = _list.synchronized {
    java.util.Collections.unmodifiableList(new ArrayList[T](_list))
  }

  private[spark] def setValue(newValue: java.util.List[T]): Unit = {
    _list.clear()
    _list.addAll(newValue)
  }
}


class LegacyAccumulatorWrapper[R, T](
    initialValue: R,
    param: org.apache.spark.AccumulableParam[R, T]) extends AccumulatorV2[T, R] {
  private[spark] var _value = initialValue  // Current value on driver

  @transient private lazy val _zero = param.zero(initialValue)

  override def isZero: Boolean = _value.asInstanceOf[AnyRef].eq(_zero.asInstanceOf[AnyRef])

  override def copy(): LegacyAccumulatorWrapper[R, T] = {
    val acc = new LegacyAccumulatorWrapper(initialValue, param)
    acc._value = _value
    acc
  }

  override def reset(): Unit = {
    _value = _zero
  }

  override def add(v: T): Unit = _value = param.addAccumulator(_value, v)

  override def merge(other: AccumulatorV2[T, R]): Unit = other match {
    case o: LegacyAccumulatorWrapper[R, T] => _value = param.addInPlace(_value, o.value)
    case _ => throw new UnsupportedOperationException(
      s"Cannot merge ${this.getClass.getName} with ${other.getClass.getName}")
  }

  override def value: R = _value
}

```