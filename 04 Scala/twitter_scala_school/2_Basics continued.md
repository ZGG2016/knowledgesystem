	https://www.cnblogs.com/nethk/p/5609320.html
	https://blog.csdn.net/qshn2sky/article/details/54674316

1. 单例对象：由object关键字声明的类型，类似于Java的静态类,它的成员、方法都默认是静态的。

如果object的静态成员要被外界访问，则该成员不能被private修饰。
使用的时候，不需要new。University.newStudentNo
           
	object University{
      //private var studentNo = 0
      var studentNo = 0
      def newStudentNo = { studentNo += 1 studentNo }
    }

======================================================================================== 

2. 伴生对象 

如果有同样一个类与该object名字一样，则称该object为该类的伴生对象，相对应，该类为object的伴生类。

需要定义在同一个文件里;

可以互相访问对方的私有方法或域，如果不想被对方访问，需要用private[this]来修饰;

通常使用伴生对象作为一个Factories

	class A {
	    private val fieldB = 10
	    // bar是完全私有的，不可从外部访问
	    private[this] def bar:Int = fieldB * 5
	}
	
	object A {
	    def foo:Int = (new A).fieldB * 5
	}
	========
	class A {
	    private val fieldB = 10
	    def bar:Int = A.foo
	}
	
	object A {
	    def foo:Int = (new A).fieldB * 5
	}

===============================================================================

3. apply方法：

可以理解成构造方法  https://blog.csdn.net/bitcarmanlee/article/details/76736252

	class Foo(foo: String) {
	}
	object Foo {
	    def apply(foo: String) : Foo = {
	        new Foo(foo)
	    }
	}
	object Client {
	    def main(args: Array[String]): Unit = {
	        val foo = Foo("Hello")
	    }
	}
	============
	scala> class Bar {
	     |   def apply() = 0
	     | }
	defined class Bar
	
	scala> val bar = new Bar
	bar: Bar = Bar@47711479
	
	scala> bar()
	res8: Int = 0

================================================================================

4. 函数是对象

函数是Traits的集合。比如一个函数接收一个参数，那它就是Function1的实例化对象。而在Function1中定义了apply()方法，所以就可以像调用方法一样调用对象。

	scala> object addOne extends Function1[Int, Int] {
	     |   def apply(m: Int): Int = m + 1
	     | }
	defined module addOne
	
	scala> addOne(1)
	res2: Int = 2

在类中定义的方法是方法而不是函数。在repl中独立定义的方法是`Function*`的实例。
类继承Function

	scala> class AddOne extends Function1[Int, Int] {
	     |   def apply(m: Int): Int = m + 1
	     | }
	defined class AddOne
	
	scala> val plusOne = new AddOne()
	plusOne: AddOne = <function1>
	
	scala> plusOne(1)
	res0: Int = 2
	A nice short-hand for extends Function1[Int, Int] is extends (Int => Int)
	class AddOne extends (Int => Int) {
	  def apply(m: Int): Int = m + 1
	}

===============================================================================

5. 包

	package com.twitter.example
	
	object colorHolder {
	  val BLUE = "Blue"
	  val RED = "Red"
	}
	println("the color is: " + com.twitter.example.colorHolder.BLUE) //直接调用

你创建的object会成为系统的一部分

	scala> object colorHolder {
	     |   val Blue = "Blue"
	     |   val Red = "Red"
	     | }
defined module colorHolder

================================================================================

6. 模式匹配

	val times = 1
	
	times match {
	  case 1 => "one"
	  case 2 => "two"
	  case _ => "some other number"
	}

Matching with guards //进一步做判断

	times match {
	  case i if i == 1 => "one"
	  case i if i == 2 => "two"
	  case _ => "some other number"
	}

match处理不同类型的情况

	def bigger(o: Any): Any = {
	  o match {
	    case i: Int if i < 0 => i - 1
	    case i: Int => i + 1
	    case d: Double if d < 0.0 => d - 0.1
	    case d: Double => d + 0.1
	    case text: String => text + "s"
	  }
	}
	def calcType(calc: Calculator) = calc match {
	  case _ if calc.brand == "HP" && calc.model == "20B" => "financial"
	  case _ if calc.brand == "HP" && calc.model == "48G" => "scientific"
	  case _ if calc.brand == "HP" && calc.model == "30B" => "business"
	  case _ => "unknown"
	}

===============================================================================

7. 样例类

不用new对象

	scala> case class Calculator(brand: String, model: String)
	defined class Calculator
	
	scala> val hp20b = Calculator("HP", "20b")
	hp20b: Calculator = Calculator(hp,20b)

样本类基于构造函数的参数，自动地实现了相等性和易读的toString方法。

	scala> val hp20b = Calculator("HP", "20b")
	hp20b: Calculator = Calculator(hp,20b)
	
	scala> val hp20B = Calculator("HP", "20b")
	hp20B: Calculator = Calculator(hp,20b)
	
	scala> hp20b == hp20B
	res6: Boolean = true

被设计用在模式匹配中的

	val hp20b = Calculator("HP", "20B")
	val hp30b = Calculator("HP", "30B")
	
	def calcType(calc: Calculator) = calc match {
	  case Calculator("HP", "20B") => "financial"
	  case Calculator("HP", "48G") => "scientific"
	  case Calculator("HP", "30B") => "business"
	  case Calculator(ourBrand, ourModel) => "Calculator: %s %s is of unknown type".format(ourBrand, ourModel)
	}

最后一句也可以这样写

	case Calculator(_, _) => "Calculator of unknown type"

或者我们完全可以不将匹配对象指定为Calculator类型

  	case _ => "Calculator of unknown type"

或者我们也可以将匹配的值重新命名。

  	case c@Calculator(_, _) => "Calculator: %s of unknown type".format(c)

===============================================================================

8. 异常

Scala中的异常可以在try-catch-finally语法中通过模式匹配使用。

	try {
	  remoteCalculatorService.add(1, 2)
	} catch {
	  case e: ServerIsDownException => log.error(e, "the remote calculator service is unavailable. should have kept your trusty HP.")
	} finally {
	  remoteCalculatorService.close()
	}

try也是面向表达式的

	val result: Int = try {
	  remoteCalculatorService.add(1, 2)
	} catch {
	  case e: ServerIsDownException => {
	    log.error(e, "the remote calculator service is unavailable. should have kept your trusty HP.")
	    0
	  }
	} finally {
	  remoteCalculatorService.close()
	}


    
