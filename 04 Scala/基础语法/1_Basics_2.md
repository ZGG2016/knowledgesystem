1.类

	scala> class Calculator {  //没有构造器
	     |   val brand: String = "HP"
	     |   def add(m: Int, n: Int): Int = m + n  //方法是获取类状态的函数
	     | }
	scala> val cal = new Calculator   //*****
	calc: Calculator = Calculator@e75a11
	
	scala> calc.add(1, 2)
	res1: Int = 3
	
	scala> calc.brand
	res2: String = "HP"

//没有构造器

	class Calculator(brand: String) {
	  /**
	   * A constructor. 不是特殊的方法，仅被用来初始化状态
	   */
	  val color: String = if (brand == "TI") {
	    "blue"
	  } else if (brand == "HP") {
	    "black"
	  } else {
	    "white"
	  }
	
	  // An instance method.
	  def add(m: Int, n: Int): Int = m + n
	}
	scala> val calc = new Calculator("HP")    //*****
	calc: Calculator = Calculator@1e64cc4d
	
	scala> calc.color
	res0: String = black

==============================================================
2.面向表达式

scala是面向表达式的。most things are expressions rather than statements.
区分：表达式和语句
	
	https://m.aliyun.com/yunqi/articles/90820

==============================================================
3.函数与方法的区别

从定义上和使用方法上   
	
	http://lib.csdn.net/article/scala/27004
定义：

	函数：val f = (x)=>x+2
	方法：def f(m:Int,n:Int):Int = m+n

使用：方法可以作为表达式的一部分，但方法不能作为最终表达式，函数可以作为最终表达式；

     参数列表对方法是可选的，对函数是必须的（函数参数列表可以为空）；
     方法名意味着方法调用，函数名只代表函数本身；
     在需要函数的地方可以提供一个方法（自动转换） 

==============================================================
4.继承

	class ScientificCalculator(brand: String) extends Calculator(brand) {
	  def log(m: Double, base: Double) = math.log(m) / math.log(base)
	}

See Also Effective Scala points out that a Type alias is better than extends if the subclass isn’t actually different from the superclass. A Tour of Scala describes Subclassing.

	class EvenMoreScientificCalculator(brand: String) extends ScientificCalculator(brand) {
	  def log(m: Int): Double = log(m, math.exp(1))
	}

重载方法

==============================================================
5.抽像类

	scala> abstract class Shape {
	     |   def getArea():Int    // subclass should define this
	     | }
	defined class Shape
	
	scala> class Circle(r: Int) extends Shape {
	     |   def getArea():Int = { r * r * 3 }
	     | }
	defined class Circle
	
	scala> val s = new Shape
	<console>:8: error: class Shape is abstract; cannot be instantiated
	       val s = new Shape
	               ^
	
	scala> val c = new Circle(2)
	c: Circle = Circle@65c0035b

==============================================================
6.Traits

域和行为(fields/behavior)的集合,可以被继承或者mixin（？？）
	trait Car {
	  val brand: String
	}
	
	trait Shiny {
	  val shineRefraction: Int
	}
	class BMW extends Car {
	  val brand = "BMW"
	}
	One class can extend several traits using the with keyword:
	
	class BMW extends Car with Shiny {
	  val brand = "BMW"
	  val shineRefraction = 12
	}

Traits和抽象类的选择：

(1)优先选择Traits。因为一个可以继承多个Traits，但只能继承一个抽象类

(2)如果需要构造器参数，那么选择抽象类

	(https://stackoverflow.com/questions/1991042/what-is-the-advantage-of-using-abstract-classes-instead-of-traits
	https://stackoverflow.com/questions/2005681/difference-between-abstract-class-and-trait
	https://www.artima.com/pins1ed/traits.html#12.7
	)

==============================================================
7.类型

给方法一个任意类型的参数

	def remove[K](key: K)











