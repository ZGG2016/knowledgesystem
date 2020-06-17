# 1-Java2 #

![](https://i.imgur.com/CDtXJIj.png)

	Java虚拟机对基本类型的操作基本都是在栈上完成的。Java在处理一个语句的时候，首先它会先把用到的操作数压到栈中，
	然后再从栈中弹出进行计算，最后将结果再压回到栈中。任何对byte的操作也会如此。因此，Java对byte类型操作之前会
	将其压入到栈中。实际上，Java压入栈的不是byte类型，而是一个标准的int类型（32位，byte是8位），也就是说，Java
	虚拟机将我们短小可爱的byte类型压入栈之前，会先把它拉长成int类型再压栈。（不过事实上在压栈之前也是int类型）
	这样一来，我们不管是在栈里还是从栈里弹出的byte类型实际上都是用int的长度存储的。

	https://www.cnblogs.com/xiaobaoTribe/articles/6434318.html

![](https://i.imgur.com/6tXDLOM.png)

	在java中小数默认处理为double类型的.float f = (float) (5+5.5);

![](https://i.imgur.com/ewDyrGC.png)

![](https://i.imgur.com/aKOFotO.png)

![](https://i.imgur.com/aoJVm1X.png)

	对文件系统的操作
	https://www.cnblogs.com/sdlzspl/p/7267339.html

![](https://i.imgur.com/uMhjLYs.png)

	没有break，会依次执行；
	switch(A),括号中A的取值可以是byte、short、int、char、String，还有枚举类型

![](https://i.imgur.com/PTRZQAO.png)

![](https://i.imgur.com/WfNZoUX.png)

	静态变量被所有的对象所共享，在内存中只有一个副本

![](https://i.imgur.com/c75qw73.png)

![](https://i.imgur.com/VeN78CE.png)

![](https://i.imgur.com/F1LEMLs.png)

![](https://i.imgur.com/dMfWa0b.png)

	==与equals()的区别：
		==:比较引用类型比较的是地址值是否相同
		equals:比较引用类型默认也是比较地址值是否相同，而String类重写了equals()方法，比较的是内容是否相同。
	https://blog.csdn.net/zhouhuocleverset/article/details/61935578
	https://www.cnblogs.com/qiaoyanlin/p/6877628.html


https://wenku.baidu.com/view/bc19645276232f60ddccda38376baf1ffc4fe325.html?rec_flag=default&sxts=1537062893458
=========================================================================================================================

![](https://i.imgur.com/3q3KoEJ.png)
	
	start()、run()、stop()弃用、yield()、sleep()、interrupt()、get(set)Priority()

	start会启动一个新线程，在新线程中于运行run方法
	run直接在当前线程中运行run方法，不会启动一个新线程

![](https://i.imgur.com/2DilcNB.png)

	Java异常的基类为java.lang.Throwable，类Throwable，实现Serializable，其子类是error，exception
	RuntimeException和其它的Exception等继承Exception，具体的RuntimeException继承RuntimeException。

![](https://i.imgur.com/RZL2PAt.png)

![](https://i.imgur.com/HBPc41s.png)

![](https://i.imgur.com/lMIIrrJ.png)

![](https://i.imgur.com/saiIoDC.png)


	Collection、List、Set、Map接口

	LinekedList实现List
	AbstractSet实现Set
	HashSet继承自AbstractSet，实现Set

![](https://i.imgur.com/wOyglaq.png)

![](https://i.imgur.com/JsP2tY0.png)

![](https://i.imgur.com/9wtXXV4.jpg)

![](https://i.imgur.com/nKvdYxq.png)

![](https://i.imgur.com/mRaM2P7.png)

	BufferedWriter(Writer out)
	BufferedReader(Reader in)
	ObjectInputStream(InputStream in)

![](https://i.imgur.com/gm3DBaf.png)

![](https://i.imgur.com/qGvXPUx.png)

	static A
	static B
	I'm A class
	HelloA
	I'm B class
	HelloB

	对象的初始化顺序：（1）类加载之后，按从上到下（从父类到子类）执行被static修饰的语句；
					（2）当static语句执行完之后,再执行main方法；
					（3）如果有语句new了自身的对象，将从上到下执行构造代码块、构造器（两者可以说绑定在一起）。

![](https://i.imgur.com/GhohOCl.png)

	IOException!

	当用多个catch语句时，catch语句块在次序上有先后之分。从最前面的catch语句块依次先后进行异常类型匹配，
	这样如果父异常在子异常类之前，那么首先匹配的将是父异常类，子异常类将不会获得匹配的机会，也即子异常类
	型所在的catch语句块将是不可到达的语句。所以，一般将父类异常类即Exception老大放在catch语句块的最后一个。

![](https://i.imgur.com/UpEJjK5.png)

	good and gbc
	只是把方法区中的值改变了，并没有在方法区重新开辟一个区域。

![](https://i.imgur.com/Pdj1M73.png)

	D

	解析：考察的又是父类与子类的构造函数调用次序。在Java中，子类的构造过程中必须调用其父类的构造函数，
	是因为有继承关系存在时，子类要把父类的内容继承下来。但如果父类有多个构造函数时，该如何选择调用呢？
	
	第一个规则：子类的构造过程中，必须调用其父类的构造方法。一个类，如果我们不写构造方法，那么编译器会
	帮我们加上一个默认的构造方法（就是没有参数的构造方法），但是如果你自己写了构造方法，那么编译器就不
	会给你添加了，所以有时候当你new一个子类对象的时候，肯定调用了子类的构造方法，但是如果在子类构造方
	法中我们并没有显示的调用基类的构造方法，如：super();  这样就会调用父类没有参数的构造方法。    
	
	第二个规则：如果子类的构造方法中既没有显示的调用基类构造方法，而基类中又没有无参的构造方法，则编译
	出错，所以，通常我们需要显示的：super(参数列表)，来调用父类有参数的构造函数，此时无参的构造函数就
	不会被调用。
	
	总之，一句话：子类没有显示调用父类构造函数，不管子类构造函数是否带参数都默认调用父类无参的构造函数，若父类没有则编译出错。

![](https://i.imgur.com/jKPpyLa.png)

![](https://i.imgur.com/rxi0ZOV.png)

https://www.cnblogs.com/lanxuezaipiao/p/3371224.html
====================================================================================================================