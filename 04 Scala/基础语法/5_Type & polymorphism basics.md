## 静态类型

Scala 藉由静态类型 (Static Types) 的实现的方式, 使得编译器形成一过滤器，使不合理的程序不能编译通过。但它不能保证每一个合理的程序都可以编译通过。

	https://blog.csdn.net/featuresoft/article/details/53446382


## Scala中的类型

- 参数化多态性 粗略地说，就是泛型编程
- （局部）类型推断 粗略地说，就是为什么你不需要这样写代码val i: Int = 12: Int
- 存在量化 粗略地说，为一些没有名称的类型进行定义
- 视窗 我们将下周学习这些；粗略地说，就是将一种类型的值“强制转换”为另一种类型

	[https://blog.csdn.net/u013007900/article/details/79212647](https://blog.csdn.net/u013007900/article/details/79212647)
	[https://www.cnblogs.com/LazyJoJo/p/6410509.html](https://www.cnblogs.com/LazyJoJo/p/6410509.html)

## 参数化多态性

粗略地说，就是泛型编程。

在Java或者C++里面，像列表（List）这些数据结构，在编写的时候，都不需要指定其中元素的类型，而是构造的时候指定，这一特性就称为泛型。

	List<String> strList = new ArrayList<String>();
	strList.add("one");
	strList.add("two");
	strList.add("three");
	
	String one = strList.get(0); 
	// 泛型拿数据不必进行类型转换，不使用泛型的话需要对类型进行转换
	
scala中的泛型称为类型参数化(type parameterlization)。语法跟java不一样，使用[]表示类型。

(1) 方法的泛型

	def position[A](xs: List[A], value: A): Int = {
		xs.indexOf(value)
	}
	position(List(1,2,3), 1) // 0
	position(List("one", "two", "three"), "two") // 1


使用泛型实现的map方法：

	def map[A, B](list:List[A], func: A => B) = list.map(func)
	
	map(List(1,2,3), { num: Int => num + "2" }) // List[String] = List(12, 22, 32)
	map(List(1,2,3), { num: Int => num * 2 }) // List[Int] = List(2, 4, 6) 

(2) 类的泛型

	class Pair[K, V] (val key: K, val value: V)

	继承该类
	class SimplePair[T] (key: T, value: T) extends Pair[T, T](key, value)
	class SimplePair[T] (key: T, value: T) extends Pair(key, value)

	这样，类名在声明或者新建实例的时候也需要写明泛型的类型：

	val p1: Pair[Int, String] = new Pair[Int, String](1, "abc")
	val p2 = new Pair(1, "abc") //可以猜到的类型和泛型设定都被省略掉了

秩1多态性????

## 变性 Variance

变性（Variance）允许你表达类层次结构和多态类型之间的关系。

					    含义	                 Scala标记
	协变covariant	    C[T’]是 C[T] 的子类	 [+T]
	逆变contravariant	C[T] 是 C[T’]的子类	 [-T]
	不变invariant	    C[T] 和 C[T’]无关	 [T]

示例

	scala> class Covariant[+A]
	defined class Covariant
	
	scala> val cv: Covariant[AnyRef] = new Covariant[String]
	cv: Covariant[AnyRef] = Covariant@4035acf6
	//AnyRef是所有引用类型的基类。除了值类型，所有类型都继承自AnyRef 
	scala> val cv: Covariant[String] = new Covariant[AnyRef]
	<console>:6: error: type mismatch;
	 found   : Covariant[AnyRef]
	 required: Covariant[String]
	       val cv: Covariant[String] = new Covariant[AnyRef]
	                                   ^
	scala> class Contravariant[-A]
	defined class Contravariant
	
	scala> val cv: Contravariant[String] = new Contravariant[AnyRef]
	cv: Contravariant[AnyRef] = Contravariant@49fa7ba
	 
	scala> val fail: Contravariant[AnyRef] = new Contravariant[String]
	<console>:6: error: type mismatch;
	 found   : Contravariant[String]
	 required: Contravariant[AnyRef]
	       val fail: Contravariant[AnyRef] = new Contravariant[String]

AnyRef和AnyVal:

[https://blog.csdn.net/bdmh/article/details/50069737](https://blog.csdn.net/bdmh/article/details/50069737)


协变类型参数一般作为函数的结果； 
逆变类型参数一般作为传入方法的参数； 
不变参类型参数可以在任意地方出现。

逆变协变并不会被继承，父类声明为逆变或协变，子类如果想要保持，任需要声明

## 边界

对类型边界的限定分为上边界和下边界（对类进行限制）：

	 上边界：表达了泛型的类型必须是"某种类型"或某种类型的"子类"，语法为“<:”,
	 下边界：表达了泛型的类型必须是"某种类型"或某种类型的"父类"，语法为“>:”,

示例

	class A
	class B extends A
	class C extends B
	class D extends C
	class E extends D
	
	class T1[T >: B]
	class T2[T <: B]
	class T3[T >: D <: B]
	class T4[T <: B with Ordered[T]]    // 可以使用with关键字对多个特征进行限定
	                                    // 在继承B的同时还要求有可排序的性质
	
	new T1[A]
	//new T1[C] 不能通过编译
	
	//new T2[A] 不能通过编译
	new T2[C]
	
	//new T3[A] 不能通过编译
	new T3[C]
	new T3[D]
	//new T3[E] 不能通过编译

视图界定（View Bound)：类型变量界定建立在类继承层次结构的基础上，但有时候这种限定不能满足实际要求。如果希望跨越类继承层次结构时，可以使用视图界定来实现的，其后面的原理是通过隐式转换来实现。视图界定利用<%符号来实现。

	//使用的是类型变量界定
	case class Student[T,S <: Comparable[S]](var name:T,var height:S)
	object ViewBound extends App{
	
	  val s= Student("john","170")
	  //下面这条语句不合法，这是因为
	  //Int类型没有实现Comparable接口
	  val s2= Student("john",170)
	}

上面这个问题可以通过视图界定来解决，代码如下：

	//利用<%符号对泛型S进行限定
	//它的意思是S可以是Comparable类继承层次结构
	//中实现了Comparable接口的类
	//也可以是能够经过隐式转换得到的类,该类实现了
	//Comparable接口
	case class Student[T,S <% Comparable[S]](var name:T,var height:S)
	
	
	object ViewBound extends App{
	  val s= Student("john","170")
	  //下面这条语句在视图界定中是合法的
	  val s2= Student("john",170)
	}

"T:classTag":相当于动态类型，你使用时传入什么类型就是什么类型。

	class Maximum[T:Ordering](val x:T,val y:T){
	  def bigger(implicit ord:Ordering[T])={
	    if(ord.compare(x, y)>0)x else y
	  }
	}

	...
	println(new Maximum(3,5).bigger)
    println(new Maximum("Scala","Java").bigger)
	...

## 类型推断

在Scala中所有类型推断是局部的 。Scala一次分析一个表达式。例如：

	scala> def id[T](x: T) = x
	id: [T](x: T)T
	
	scala> val x = id(322)
	x: Int = 322
	
	scala> val x = id("hey")
	x: java.lang.String = hey
	
	scala> val x = id(Array(1,2,3,4))
	x: Array[Int] = Array(1, 2, 3, 4)

类型信息都保存完好，Scala编译器为我们进行了类型推断。请注意我们并不需要明确指定返回类型。

## 量化


？？？