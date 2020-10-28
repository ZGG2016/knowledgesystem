# RDDOperationScope

## 1、柯里化函数（Curried functions）

**首先要了解scala的柯里化特性**

有时会有这样的需求：允许别人一会在你的函数上应用一些参数，然后又应用另外的一些参数。

例如一个乘法函数，在一个场景需要选择乘数，而另一个场景需要选择被乘数。

（1）直接传入两个参数

```java
scala> def multiply(m:Int)(n:Int)=m*n
multiply: (m: Int)(n: Int)Int

scala> multiply(2)(3)
res12: Int = 6
```

（2）填上第一个参数并且部分应用第二个参数（柯里化）

```java
scala> val timesTwo = multiply(2)_
timesTwo: Int => Int = <function1>

scala> timesTwo(3)
res13: Int = 6
```

（3）对任何多参数函数执行柯里化。例如之前的 adder 函数。

```java
scala> val curriedAdd = (adder _).curried
curriedAdd: Int => (Int => Int) = <function1>

scala> val addTwo = curriedAdd(2)
addTwo: Int => Int = <function1>

scala> addTwo(4)
res14: Int = 6
```

## 2、RDDOperationScope类源码

记录RDD的操作历史和父子lineage关系，并解决SparkUI界面展示的问题。

```java
package org.apache.spark.rdd

import java.util.concurrent.atomic.AtomicInteger

import com.fasterxml.jackson.annotation.{JsonIgnore, JsonInclude, JsonPropertyOrder}
import com.fasterxml.jackson.annotation.JsonInclude.Include
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.scala.DefaultScalaModule
import com.google.common.base.Objects

import org.apache.spark.SparkContext
import org.apache.spark.internal.Logging

/**
 * scope：作用域
 *
 * A general, named code block representing an operation that instantiates RDDs.
 * 一个通用的、被命名了的代码块，用来表示实例化RDD的操作。
 *
 * All RDDs instantiated in the corresponding code block will store a pointer to this object.
 * Examples include, but will not be limited to, existing RDD operations, such as textFile,
 * reduceByKey, and treeAggregate.
 * 所有被实例化的RDD，将存储一个指针，用来指向这个对象(RDDOperationScope)。
 * 包含但不仅限于textFile,reduceByKey等.
 * 【每个实例化的RDD都对应一个RDDOperationScope对象】
 *
 * An operation scope may be nested in other scopes. For instance, a SQL query may enclose
 * scopes associated with the public RDD APIs it uses under the hood.
 * 
 * scope 间可以嵌套。一个sql查询的scope封装在一个公共的RDD APIs中。
 * 
 * There is no particular relationship between an operation scope and a stage or a job.
 * A scope may live inside one stage (e.g. map) or span across multiple jobs (e.g. take).
 *
 * operation scope 和 stage、job 间没有必然联系。一个 scope 可以在一个 stage 中(如map)，或跨越多个jobs(如take)
 */
@JsonInclude(Include.NON_NULL)
@JsonPropertyOrder(Array("id", "name", "parent"))
private[spark] class RDDOperationScope(
    val name: String,
    val parent: Option[RDDOperationScope] = None, //父rdd的scope
    val id: String = RDDOperationScope.nextScopeId().toString) {

  // 写
  def toJson: String = {
    RDDOperationScope.jsonMapper.writeValueAsString(this)
  }

  /**
   * Return a list of scopes that this scope is a part of, including this scope itself. 返回一个包含这个scope所在的 scopes 列表
   * The result is ordered from the outermost scope (eldest ancestor) to this scope. 返回结果是有序的，从最老到最新。
   */
  @JsonIgnore
  def getAllScopes: Seq[RDDOperationScope] = {
  	// 递归获取
    parent.map(_.getAllScopes).getOrElse(Seq.empty) ++ Seq(this)
  } // 将父和本身的序列连接作为结果

  // id、name、parent都相同才equal
  override def equals(other: Any): Boolean = {
    other match {
      case s: RDDOperationScope =>
        id == s.id && name == s.name && parent == s.parent
      case _ => false
    }
  }

  override def hashCode(): Int = Objects.hashCode(id, name, parent)

  override def toString: String = toJson
}

/**
 * 工具方法集合：构造RDD scopes的层次表示
 *
 * A collection of utility methods to construct a hierarchical representation of RDD scopes.
 * An RDD scope tracks the series of operations that created a given RDD.
 * RDD scope 会追踪对这个rdd的一系列操作
 */
private[spark] object RDDOperationScope extends Logging {
  private val jsonMapper = new ObjectMapper().registerModule(DefaultScalaModule)
  
  // AtomicInteger 是一个被原子更新的int值
  // AtomicInteger is used in applications such as atomically
  //incremented counters, and cannot be used as a replacement for an Integer.
  private val scopeCounter = new AtomicInteger(0)

  // 读
  def fromJson(s: String): RDDOperationScope = {
    jsonMapper.readValue(s, classOf[RDDOperationScope])
  }

  // 获取一个全局的唯一operation scope ID
  /** Return a globally unique operation scope ID. */
  def nextScopeId(): Int = scopeCounter.getAndIncrement

  /**
     * Atomically increments by one the current value.
     * 将当前值原子递增1
     * @return the previous value
     */
  // public final int getAndIncrement() {
  //     return unsafe.getAndAddInt(this, valueOffset, 1);
  //}


  /**
   * 执行一个body，为了所有在这个body中创建的RDD具有相同scope。
   * Execute the given body such that all RDDs created in this body will have the same scope.
   * The name of the scope will be the first method name in the stack trace that is not the
   * same as this method's.
   * 在 stack trace 中，不是 withScope 的第一个方法名是这个 scope 的名字。
   *
   * Note: Return statements are NOT allowed in body.
   * 这个body中是没有返回语句的
   */
  private[spark] def withScope[T](  // 柯里化
      sc: SparkContext,
      allowNesting: Boolean = false)(body: => T): T = { // 默认不允许嵌套
    val ourMethodName = "withScope"

    // 确定当前scope的名字
    val callerMethodName = Thread.currentThread.getStackTrace()
      //删除方法名不是withScope的方法[注意dropWhile方法的特性]
      .dropWhile(_.getMethodName != ourMethodName)
      //找到方法名不是withScope的方法
      .find(_.getMethodName != ourMethodName)
      .map(_.getMethodName)
      .getOrElse {
        // Log a warning just in case, but this should almost certainly never happen
        logWarning("No valid method name for this RDD operation scope!")
        "N/A"
      }
    withScope[T](sc, callerMethodName, allowNesting, ignoreParent = false)(body)
  }
  
  /**
    * dropWhile：
    *   去除符合条件的元素，直到不符合条件，返回去除后的集合。
    *   找到不符合条件的项就停止，后面的就不再处理。
    * 
    * scala> var n = List(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
    * n: List[Int] = List(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
    *
    * scala> n.dropWhile(_ %2 != 0)
    * res3: List[Int] = List(2, 3, 4, 5, 6, 7, 8, 9, 10)
    *
    * scala> n.dropWhile(_ !=2)
    * res2: List[Int] = List(2, 3, 4, 5, 6, 7, 8, 9, 10)
    */

  /**
   * Execute the given body such that all RDDs created in this body will have the same scope.
   *
   * If nesting is allowed, any subsequent calls to this method in the given body will instantiate
   * child scopes that are nested within our scope. Otherwise, these calls will take no effect.
   *
   * 如果允许嵌套，在这个body中，withScope方法的之后的调用将实例化 子scopes，
   * 它是在我们的scope之中。否则，这些调用不会有任何影响。
   *
   * Additionally, the caller of this method may optionally ignore the configurations and scopes
   * set by the higher level caller. In this case, this method will ignore the parent caller's
   * intention to disallow nesting, and the new scope instantiated will not have a parent. This
   * is useful for scoping physical operations in Spark SQL, for instance.
   *
   * 这个方法的调用者可选地忽略更高一层的配置和scopes。
   * 这种情况下，这个方法会忽略父调用者的不允许嵌套的设置，
   *     实例化的新的scope将不会有一个父。
   * 在Spark SQL中，scoping物理操作是很有用的。
   *
   * Note: Return statements are NOT allowed in body.
   * 这个body中是没有返回语句的
   */
  private[spark] def withScope[T]( //柯里化
      sc: SparkContext,
      name: String,  //当前scope的名字
      allowNesting: Boolean, // 默认不允许嵌套
      ignoreParent: Boolean)(body: => T): T = {  // ignoreParent = false

    // Save the old scope to restore it later
    // 保存旧的scope，以便之后恢复
    
    //"spark.rdd.scope"
    val scopeKey = SparkContext.RDD_SCOPE_KEY 
    
    // Override覆盖
    //"spark.rdd.scope.noOverride"
    val noOverrideKey = SparkContext.RDD_SCOPE_NO_OVERRIDE_KEY 


    // getLocalProperty：获取这个线程中的本地属性

    // 取scopeKey这个键对应的值
    val oldScopeJson = sc.getLocalProperty(scopeKey)
    val oldScope = Option(oldScopeJson).map(RDDOperationScope.fromJson)
    val oldNoOverride = sc.getLocalProperty(noOverrideKey)

    //设置当前的新的本地属性
    try {
      if (ignoreParent) {  // 忽略父的设置，不覆盖
        // Ignore all parent settings and scopes and start afresh with our own root scope
        //setLocalProperty：设置本地属性，会影响此线程下提交的job（hashtable.put(key, value)）
        sc.setLocalProperty(scopeKey, new RDDOperationScope(name).toJson)
      } else if (sc.getLocalProperty(noOverrideKey) == null) { // 即OverrideKey
        // Otherwise, set the scope only if the higher level caller allows us to do so 只有更高层调用者允许这样做，才设置。【不忽略父的设置】
        sc.setLocalProperty(scopeKey, new RDDOperationScope(name, oldScope).toJson)
      }
      // Optionally disallow the child body to override our scope
      // 不允许嵌套时，才不覆盖
      if (!allowNesting) {
        sc.setLocalProperty(noOverrideKey, "true")
      }
      body
    } finally {
      // Remember to restore any state that was modified before exiting
      // 在退出前，恢复修改前的状态
      sc.setLocalProperty(scopeKey, oldScopeJson)
      sc.setLocalProperty(noOverrideKey, oldNoOverride)

      // body执行时,每次withScope的调用都没执行finally,是个进栈的过程;
      // 但是body执行完成后,finally再执行,是个出栈的过程
    }
  }
}

```

-----------------------------------------------------------------------------

**withScope 使用示例：**

利用柯里化，把不同算子的共用部分进行统一封装，在另一个参数body中设置具体实现。

```java
/**
   * Return a new RDD by applying a function to all elements of this RDD.
   */
  def map[U: ClassTag](f: T => U): RDD[U] = withScope {
    val cleanF = sc.clean(f)
    new MapPartitionsRDD[U, T](this, (context, pid, iter) => iter.map(cleanF))
  }
```

**withScope源码：**

```java
/**
   * 在一个scope内执行一个代码块，
   * 例如，所有在这个body中创建的新RDD将是相同scope的一部分。
   * 
   * Execute a block of code in a scope such that all new RDDs created in this body will
   * be part of the same scope. For more detail, see {{org.apache.spark.rdd.RDDOperationScope}}.
   *
   * Note: Return statements are NOT allowed in the given body.
   */
  private[spark] def withScope[U](body: => U): U = RDDOperationScope.withScope[U](sc)(body)
```

