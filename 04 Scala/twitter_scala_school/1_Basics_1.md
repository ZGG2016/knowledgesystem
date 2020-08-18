1.

	scala> 1 + 1
	res0: Int = 2

res0是表达式的计算结果，其类型是int,值是2

==========================================================

2.val和var区别

	scala> val two = 1 + 1
	two: Int = 2  //自定义一个名字

这里的res0(two)和2具有一种绑定关系。如果要改变这种绑定关系，可以定义为var

	scala> var name = "steve"
	name: java.lang.String = steve
	
	scala> name = "marius"
	name: java.lang.String = marius

===============================================================
3.函数

	scala> def addOne(m: Int): Int = m + 1
	addOne: (m: Int)Int

需要为函数指定参数和参数类型，然后解释器会回传给你。

	scala> def three() = 1 + 2
	three: ()Int
	
	scala> three()
	res2: Int = 3
	
	scala> three
	res3: Int = 3

不指定参数，就只会回传一个返回值类型。调用函数只需要一个函数名。

===============================================================
4.匿名函数

	scala> (x: Int) => x + 1
	res2: (Int) => Int = <function1>

和常规函数相比，没有了def和函数名和返回值类型

	scala> val addOne = (x: Int) => x + 1
	addOne: (Int) => Int = <function1>

也可以将匿名函数传给一个常量。

	def timesTwo(i: Int): Int = {
	  println("hello world")
	  i * 2
	}

当函数体有多个语句时，使用{}

	scala> { i: Int =>
	  println("hello world")
	  i * 2
	}
	res0: (Int) => Int = <function1>

对于匿名函数而言，将整个函数使用{}包起来。这常见于将匿名函数作为参数传递的情景。

===============================================================

5.Partial application（部分应用）

	scala> def adder(m: Int, n: Int) = m + n
	adder: (m: Int,n: Int)Int
	
	scala> val add2 = adder(2, _:Int)
	add2: (Int) => Int = <function1>
	
	scala> add2(3)
	res50: Int = 5

对一个函数参数使用下划线，会返回另一个函数，可以理解成未命名的参数。`_:Int`这里必须指定类型、同函数里的一致,并可以在任意位置。

	val add2 = adder(_:Int,"a")   //错误
	    println(add2(3))
	  }
	def adder(m: String, n: Int) = m + n
	  
	val add2 = adder(_:String,3)   //正确
	    println(add2(“3”))
	  }
	
	def adder(m: String, n: Int) = m + n

(???Scala uses the underscore to mean different things in different contexts,
but you can usually think of it as an unnamed magical wildcard. )

===============================================================
6.Curried functions(柯里化函数)

	scala> def multiply(m: Int)(n: Int): Int = m * n
	multiply: (m: Int)(n: Int)Int
	
	scala> multiply(2)(3)
	res0: Int = 6

直接传参数

	scala> val timesTwo = multiply(2) _
	timesTwo: (Int) => Int = <function1>
	scala> timesTwo(3)
	res1: Int = 6

先给一个参数，后面再给一个参数（柯里化）

	scala> val curriedAdd = (adder _).curried
	curriedAdd: Int => (Int => Int) = <function1>
	scala> val addTwo = curriedAdd(2)
	addTwo: Int => Int = <function1>
	scala> addTwo(4)
	res22: Int = 6

把一个包含多个参数的函数柯里化

===============================================================
7.变长参数

	def capitalizeAll(args: String*) = {
	  args.map { arg =>
	    arg.capitalize
	  }
	}
	
	scala> capitalizeAll("rarity", "applejack")
	res2: Seq[String] = ArrayBuffer(Rarity, Applejack)

必须是同一类型
