# Java 面试题--JVM

## jvm 运行时数据区

![jvm01](./image/jvm01.png)

程序计数器：

	当前线程所执行的字节码的行号指示器(在当前线程下的程序执行到哪了)。

	字节码解释器工作是就是通过改变这个计数器的值来选取下一条需要执行指令的字节码指令，分支、循环、跳转、异常处理、线程恢复等基础功能都需要依赖计数器完成

	线程执行一个Java方法，计数器记录的是正在执行的虚拟机字节码指令的地址；
	如果是 Native 方法，这个计数器的值则为 (Undefined)。

	唯一的不会出现任何 OutOfMemoryError 的区域。

	内存空间小，线程私有。

虚拟机栈：

	描述的是 Java 方法执行的内存模型：每个方法在执行时都会创建一个栈帧(Stack Frame)，用于存储局部变量表、操作数栈、动态链接、方法出口等信息。每一个方法从调用直至执行结束，就对应着一个栈帧从虚拟机栈中入栈到出栈的过程。

	局部变量表：存放了编译期可知的各种基本类型(boolean、byte、char、short、int、float、long、double)、
	对象引用(reference 类型)和 
	returnAddress 类型(指向了一条字节码指令的地址)

	StackOverflowError：线程请求的栈深度大于虚拟机所允许的深度。
	OutOfMemoryError：如果虚拟机栈可以动态扩展，而扩展时无法申请到足够的内存

	线程私有，生命周期和线程一致

本地方法栈：

	和虚拟机栈作用类似，但为虚拟机使用到的 Native 方法服务。

	也会有 StackOverflowError 和 OutOfMemoryError 异常。

堆：

	存放对象实例和数组。

	从内存回收角度：分为新生代和老生代。再细致分，Eden、From Survivor、to Survivor。

	从内存分配角度，内部会划分出多个线程私有的分配缓冲区(Thread Local Allocation Buffer, TLAB)

	可以位于物理上不连续的空间，但是逻辑上要连续。

	OutOfMemoryError：如果堆中没有内存完成实例分配，并且堆也无法再扩展时，抛出该异常。

	JVM 所管理的内存中最大的一块，在虚拟机启动时创建，线程共享。

方法区：

	存储被虚拟机加载后的类信息、常量、静态常量、即时编译器编译后的代码等数据。

	不需要连续的内存空间。 可以选择固定大小，也可以扩展。 可以选择不实现垃圾收集。

	当方法区无法满足内存分配需求时，会 OutOfMemoryError 异常。

	各线程共享的内存区域。

[即时编译器](https://www.jianshu.com/p/cda61079c7ef)

运行时常量池：

	方法区的一部分。

	存放编译期生成字面量和符号引用。

	运行期间，也可以存放新的常量进入常量池。

	无法申请到内存时，抛出 OutOfMemoryError。

[直接内存](https://www.cnblogs.com/blknemo/p/13296028.html)：

	既不是虚拟机运行时数据区的一部分，也不是java虚拟机规范中定义的内存区域。

	在 JDK 1.4 中新加入 NIO (New Input/Output) 类，引入了一种基于通道(Channel)和缓存(Buffer)的 I/O 方式，它可以使用 Native 函数库直接分配堆外内存，然后通过一个存储在 Java 堆中的 DirectByteBuffer 对象作为这块内存的引用进行操作。可以避免在 Java 堆和 Native 堆中来回的数据耗时操作。

	OutOfMemoryError：如果忽略直接内存，使得内存区域总和大于物理内存限制，从而导致动态扩展时出现该异常。

[JVM内存实例](https://www.baidu.com/link?url=RsqdoYTO4hR3fL3HcrkoPeYCRbooB1bGChu9F9n_jsTP1DSVP4Scs6nh_mcmzwzJWJ7J2qAbBbq46rm5I7ZJga&wd=&eqid=9f7eb66b0001a911000000025f2bc2c8)
