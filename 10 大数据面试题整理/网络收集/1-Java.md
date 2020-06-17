# 1-Java #

## 位运算 ##

## 垃圾回收 ##

## 多线程 ##

https://www.cnblogs.com/wxd0108/p/5479442.html

## 设计模式 ##

## 容器 ##

## volatile ##

	

## HashMap、LinkedHashMap、TreeMap、Hashtable、HashSet和ConcurrentHashMap区别 ##

	HashMap：基于哈希表的Map接口的非同步实现；
			 允许使用null值和null键；
			 HashMap中不允许出现重复的键（Key）；
			 Hashmap是非线程安全的；
			 迭代器是fail-fast的
	HashSet：实现了Set接口；
			 底层采用HashMap来保存元素，而且只使用了HashMap的key来实现各种特性；
			 数据不是key-value键值对，其只是单值
	Hashtable:基于哈希表的Map接口的同步实现；
		 	  key和value都不允许为null;
			  线程安全;
			  较HashMap速度慢;
	LinkedHashMap:HashMap的一个子类，它保留插入顺序，帮助我们实现了有序的HashMap;
				  维护一个双向链表,修改Entry对象，Entry新增了其上一个元素before和下一个元素after的引用;
				  未重写父类HashMap的put方法;重写了父类HashMap的get方法
	TreeMap:有序的key-value集合，它是通过红黑树实现的;
		    该映射根据其键的自然顺序(字母排序)进行排序，或者根据创建映射时提供的 Comparator 进行排序;
			TreeMap是非线程安全的。 它的iterator 方法返回的迭代器是fail-fast的。
	ConcurrentHashMap:弱一致性，也就是说遍历过程中其他线程可能对链表结构做了调整;
					  基于分段锁设计来实现线程安全性，只有在同一个分段内才存在竞态关系，不同的分段锁之间没有锁竞争。

	https://blog.csdn.net/qq_33206732/article/details/80338354

## java内存管理 ##

![](https://i.imgur.com/JZRS0PO.png)

	程序计数器：线程独占，当前线程所执行的字节码的行号指示器。每个线程需要记录下执行到哪儿了，下次调度的时候可以继续执行，这个区是唯一不会发生oom的
	栈：线程独占，包含虚拟机栈和本地方法栈。存放局部变量
	堆：线程共享，存放由new创建的对象实例和数组。
	方法区：线程共享，用于存放被虚拟机加载的类，常量，静态变量

	https://blog.csdn.net/Liveor_Die/article/details/77895631
	https://www.cnblogs.com/fxjwind/p/4441799.html

## final关键字 ##

	1.用来修饰数据，包括成员变量和局部变量，该变量只能被赋值一次且它的值无法被改变。对于成员变量来讲，我们必须在声明时或者构造方法中对它赋值；编译异常
		final修饰引用变量，只是限定了引用变量的引用不可改变，即不能将value3再次引用另一个Value对象，但是引用的对象的值是可以改变的
	2.用来修饰方法参数，表示在变量的生存期中它的值不能被改变；
	3.修饰方法，表示该方法无法被重写；
	4.修饰类，表示该类无法被继承。

	https://www.cnblogs.com/dotgua/p/6357951.html

## int和Integer的区别 ##

	1、Integer是int的包装类，int则是java的一种基本数据类型 
	2、Integer变量必须实例化后才能使用，而int变量不需要 
	3、Integer实际是对象的引用，当new一个Integer时，实际上是生成一个指针指向此对象；而int则是直接存储数据值 
	4、Integer的默认值是null，int的默认值是0

	https://www.cnblogs.com/guodongdidi/p/6953217.html

## Java变量命名规范 ##

	名称必须以字母，下划线（_）或$符号开头，不能用数字

	除第一个字符外，后面可以用数字
	
	避开Java关键字， 如int， public，final

### String ###

	String []a = new String[10];

	则：a[0]~a[9] = null
	
	a.length = 10
	
	如果是int []a = new int[10];
	
	则：a[0]~a[9] = 0
	
	a.length = 10

## 基本数据类型 ##

提供了八种基本类型。六种数字类型（四个整数型，两个浮点型），一种字符类型，还有一种布尔型。

	int、short、long、byte、float、double
	char
	boolean
	============================================
	1.整型 byte（1字节） short （2个字节） int（4个字节） long （8个字节）
	2.浮点型 float（4个字节） double（8个字节）
	3.逻辑性 boolean（八分之一个字节）
	4.字符型 char（2个字节，一个字符能存储下一个中文汉字）

	============================================

	基本数据类型与包装类对应关系和默认值
		short        Short       （short）0
		int          Integer       0		
		long         Long          0L		
		char         Char         '\u0000'（什么都没有）		
		float        Float         t0.0f		
		double       Double        0.0d	
		boolean      Boolean       false

	============================================
	byte:
		最小值是-128（-2^7）；
		最大值是127（2^7-1）；	  
		例子：byte a = 100，byte b = -50。

	short：
		最小值是-32768（-2^15）；
		最大值是32767（2^15 - 1）；
		例子：short s = 1000，short r = -20000。
	
	int:
		最小值是-2,147,483,648（-2^31）；
		最大值是2,147,485,647（2^31 - 1）；

	long:
		最小值是-9,223,372,036,854,775,808（-2^63）；
		最大值是9,223,372,036,854,775,807（2^63 -1）；
		例子： long a = 100000L，int b = -200000L。

	float:
		-3.4*E38- 3.4*E38
		例子：float f1 = 234.5f。
		float f=6.26(错误  浮点数默认类型是double类型)
		float f=6.26F（转换正确，强制）
		double d=4.55(正确)

	double:
		浮点数的默认类型为double类型；
		例子：double d1 = 123.4。
	
	char:
		最小值是’\u0000’（即为0）；
		最大值是’\uffff’（即为65,535）