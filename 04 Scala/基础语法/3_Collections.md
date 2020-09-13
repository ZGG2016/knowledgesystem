1.

数组：preserve order,、可以重复、可变

	scala> val numbers = Array(1, 2, 3, 4, 5, 1, 2, 3, 4, 5)
	numbers: Array[Int] = Array(1, 2, 3, 4, 5, 1, 2, 3, 4, 5)
	
	scala> numbers(3) = 10

=============================================================================================

2.列表：preserve order,、可以重复、不可变(List一旦创建，已有元素的值不能改变)

	scala> val numbers = List(1, 2, 3, 4, 5, 1, 2, 3, 4, 5)
	numbers: List[Int] = List(1, 2, 3, 4, 5, 1, 2, 3, 4, 5)
	
	scala> numbers(3) = 10
	<console>:9: error: value update is not a member of List[Int]
	              numbers(3) = 10

=============================================================================================

3.set:不可重复、not preserve order

	scala> val numbers = Set(1, 2, 3, 4, 5, 1, 2, 3, 4, 5)
	numbers: scala.collection.immutable.Set[Int] = Set(5, 1, 2, 3, 4)

=============================================================================================

4.元组

	scala> val hostPort = ("localhost", 80)
	hostPort: (String, Int) = (localhost, 80)
	
	scala> 1 -> 2
	res0: (Int, Int) = (1,2)

通过索引取值，从1开始

	scala> hostPort._1
	res0: String = localhost

在模式匹配中使用

	hostPort match {
	  case ("localhost", port) => ...
	  case (host, port) => ...
	}

=============================================================================================

5.Map

	创建Map(1->2)
	   Map((1,2))

可以包含自身或者一个函数

	Map(1 -> Map("foo" -> "bar"))
	Map("timesTwo" -> { timesTwo(_) })

=============================================================================================

6.Option

可能包含值也可能不包含值的容器

	trait Option[T] {
	  def isDefined: Boolean
	  def get: T
	  def getOrElse(t: T): T
	}

map由键取值，返回该类型

	scala> val numbers = Map("one" -> 1, "two" -> 2)
	numbers: scala.collection.immutable.Map[java.lang.String,Int] = Map(one -> 1, two -> 2)
	
	scala> numbers.get("two")
	res0: Option[Int] = Some(2)
	
	scala> numbers.get("three")
	res1: Option[Int] = None

现在返回的类型是Option，想要获得int类型

	scala> numbers.get("one").getOrElse(0)
	res11: Int = 1

=============================================================================================

7.Functional Combinators

map:会自动把方法转成函数

	scala> def timesTwo(i: Int): Int = i * 2
	timesTwo: (i: Int)Int
	scala> numbers.map(timesTwo)
	res0: List[Int] = List(2, 4, 6, 8)

foreach:没有返回值

	scala> val doubled = numbers.foreach((i: Int) => i * 2)
	doubled: Unit = ()

filter：去掉不满足条件的

	scala> def isEven(i: Int): Boolean = i % 2 == 0
	isEven: (i: Int)Boolean
	
	scala> numbers.filter(isEven)
	res2: List[Int] = List(2, 4)

zip：将两个列表组成pair对，仍是列表

	scala> List(1, 2, 3).zip(List("a", "b", "c"))
	res0: List[(Int, String)] = List((1,a), (2,b), (3,c)

partition：基于一个函数划分列表成几个部分，得到一个元组

	scala> val numbers = List(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	scala> numbers.partition(_ % 2 == 0)
	res0: (List[Int], List[Int]) = (List(2, 4, 6, 8, 10),List(1, 3, 5, 7, 9))

find：返回满足条件的第一个元素

	scala> numbers.find((i: Int) => i > 5)
	res0: Option[Int] = Some(6)

drop：删除指定元组

	scala> numbers.drop(5)
	res0: List[Int] = List(6, 7, 8, 9, 10)

dropWhile：删除满足条件的第一个元素

	scala> numbers.dropWhile(_ % 2 != 0)
	res0: List[Int] = List(2, 3, 4, 5, 6, 7, 8, 9, 10)

foldLeft：累加的过程

	scala> numbers.foldLeft(0)((m: Int, n: Int) => m + n)
	res0: Int = 55

	{m的初始值为0，n是1.m保存上一步m+n的值，n为numbers的值}

	scala> numbers.foldLeft(0) { (m: Int, n: Int) => println("m: " + m + " n: " + n); m + n }
	=======
	m: 0 n: 1
	m: 1 n: 2
	m: 3 n: 3
	m: 6 n: 4
	m: 10 n: 5
	m: 15 n: 6
	m: 21 n: 7
	m: 28 n: 8
	m: 36 n: 9
	m: 45 n: 10
	res0: Int = 55

foldRight：和foldLeft相反

	scala> numbers.foldRight(0) { (m: Int, n: Int) => println("m: " + m + " n: " + n); m + n }
	m: 10 n: 0
	m: 9 n: 10
	m: 8 n: 19
	m: 7 n: 27
	m: 6 n: 34
	m: 5 n: 40
	m: 4 n: 45
	m: 3 n: 49
	m: 2 n: 52
	m: 1 n: 54
	res0: Int = 55

flatten：把多个维度转成1个维度

	scala> List(List(1, 2), List(3, 4)).flatten

flatMap：先map后flat

	scala> val nestedNumbers = List(List(1, 2), List(3, 4))
	nestedNumbers: List[List[Int]] = List(List(1, 2), List(3, 4))

	scala> nestedNumbers.flatMap(x => x.map(_ * 2))
	res0: List[Int] = List(2, 4, 6, 8)
	res0: List[Int] = List(1, 2, 3, 4)

自定义：

	def ourMap(numbers: List[Int], fn: Int => Int): List[Int] = {
	  numbers.foldRight(List[Int]()) { (x: Int, xs: List[Int]) =>
	    fn(x) :: xs
	  }
	}
	
	scala> ourMap(numbers, timesTwo(_))
	res0: List[Int] = List(2, 4, 6, 8, 10, 12, 14, 16, 18, 20)


