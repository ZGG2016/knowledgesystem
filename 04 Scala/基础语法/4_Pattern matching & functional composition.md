定义两个函数

	scala> def f(s: String) = "f(" + s + ")"
	f: (String)java.lang.String
	
	scala> def g(s: String) = "g(" + s + ")"
	g: (String)java.lang.String
	{拼成两个字符串}

===================================================

compose：组成f(g(x))

	scala> val fComposeG = f _ compose g _
	fComposeG: (String) => java.lang.String = <function>

	scala> fComposeG("yay")
	res0: java.lang.String = f(g(yay))
	{先给g，结果给f}

===================================================

andThen：g(f(x))

	scala> val fAndThenG = f _ andThen g _
	fAndThenG: (String) => java.lang.String = <function>
	
	scala> fAndThenG("yay")
	res1: java.lang.String = g(f(yay))

===================================================
Currying vs Partial Application

	case子句：偏函数的子类
	多个case子句的集合：多个偏函数组合

对给定的输入参数类型，函数可接受该类型的任何值。换句话说，一个(Int) => String 的函数可以接收任意Int值，并返回一个字符串。

对给定的输入参数类型，偏函数只能接受该类型的某些特定的值。一个定义为(Int) => String 的偏函数可能不能接受所有Int值为输入。

	scala> val one: PartialFunction[Int, String] = { case 1 => "one" }
	one: PartialFunction[Int,String] = <function1>
	
	scala> one.isDefinedAt(1)
	res0: Boolean = true
	
	scala> one.isDefinedAt(2)
	res1: Boolean = false

	//isDefinedAt 是PartialFunction的一个方法，用来确定PartialFunction是否能接受一个给定的参数。

注意 偏函数PartialFunction 和我们前面提到的部分应用函数是无关的。

调用一个偏函数。

	scala> one(1)
	res2: String = one

PartialFunctions可以使用orElse组成新的函数，得到的PartialFunction反映了是否对给定参数进行了定义。

	scala> val two: PartialFunction[Int, String] = { case 2 => "two" }
	two: PartialFunction[Int,String] = <function1>
	
	scala> val three: PartialFunction[Int, String] = { case 3 => "three" }
	three: PartialFunction[Int,String] = <function1>
	
	scala> val wildcard: PartialFunction[Int, String] = { case _ => "something else" }
	wildcard: PartialFunction[Int,String] = <function1>
	
	scala> val partial = one orElse two orElse three orElse wildcard
	partial: PartialFunction[Int,String] = <function1>
	
	scala> partial(5)
	res24: String = something else
	
	scala> partial(3)
	res25: String = three
	
	scala> partial(2)
	res26: String = two
	
	scala> partial(1)
	res27: String = one

	scala> partial(0)

================================================================

case 

	scala> case class PhoneExt(name: String, ext: Int)
	defined class PhoneExt
	
	scala> val extensions = List(PhoneExt("steve", 100), PhoneExt("robey", 200))
	extensions: List[PhoneExt] = List(PhoneExt(steve,100), PhoneExt(robey,200))
	
	scala> extensions.filter { case PhoneExt(name, extension) => extension < 200 }
	res0: List[PhoneExt] = List(PhoneExt(steve,100))

filter使用一个函数。在这个例子中是一个谓词函数(PhoneExt) => Boolean。

PartialFunction是Function的子类型，所以filter也可以接收PartialFunction作为参数。