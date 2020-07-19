# 多线程01：Thread、Runnable、synchronized

## 一、概述

### 1、进程

（1）**正在运行的程序**，是系统进行资源分配和调用的独立单位。

每一个进程都有它自己的内存空间和系统资源。

（2）多进程的意义

**提高CPU的使用率**

	单进程的计算机只能做一件事情，而我们现在的计算机都可以做多件事情。
	例如一边玩游戏(游戏进程)，一边听音乐(音乐进程)。
	
	也就是说：
		现在的计算机都是支持多进程的，可以在一个时间段内执行多个任务。
		并且可以提高CPU的使用率。
	
	问题：
		一边玩游戏，一边听音乐是同时进行的吗?
		不是。因为单CPU在某一个时间点上只能做一件事情。
		而我们在玩游戏，或者听音乐的时候，是CPU在做着程序间的高效切换让我们觉得是同时进行的。
		
### 2、线程

（1）在同一个进程内又可以执行多个任务，而这**每一个任务就可以看出是一个线程**。
	
**线程是程序的执行单元、执行路径。是程序使用CPU的最基本单位。**	

（2）举例

	扫雷游戏，迅雷下载等

（3）多线程

单线程：如果程序只有一条执行路径。

多线程：如果 **程序有多条执行路径**。

（4）多线程的意义

**提高应用程序的使用率**

	多线程的存在，不是提高程序的执行速度。其实是为了提高应用程序的使用率。
	
	程序的执行其实都是在抢CPU的资源，CPU的执行权。
	多个进程是在抢这个资源，而其中的某一个进程如果执行路径比较多，就会有更高的几率抢到CPU的执行权。
	我们是不敢保证哪一个线程能够在哪个时刻抢到，所以线程的执行有随机性。

### 3、并行和并发

并行是逻辑上同时发生，指在某 **一个时间段** 同时运行多个程序。

并发是物理上同时发生，指在某 **一个时间点** 同时运行多个程序。

### 4、Java程序的运行原理

由java命令启动JVM，JVM启动就相当于启动了一个进程。
接着有该进程创建了一个主线程去调用main方法。所以 main方法运行在主线程中。
 
jvm虚拟机的启动是单线程的还是多线程的?

	多线程的。
	原因是垃圾回收线程也要先启动，否则很容易会出现内存溢出。
 	现在的垃圾回收线程加上前面的主线程，最低启动了两个线程，所以，jvm的启动其实是多线程的。
	
## 二、Thread类

线程 是程序中的执行线程。Java 虚拟机允许应用程序并发地运行多个执行线程。 

每个线程都有一个优先级，高优先级线程的执行优先于低优先级线程。

每个线程都可以或不可以标记为一个守护程序。当某个线程中运行的代码创建一个新 Thread 对象时，该新线程的初始优先级被设定为创建线程的优先级，并且当且仅当创建线程是守护线程时，新线程才是守护程序。 


当 Java 虚拟机启动时，通常都会有单个非守护线程
（它通常会调用某个指定类的 main 方法）。
Java 虚拟机会继续执行线程，直到下列任一情况出现时为止： 

	调用了 Runtime 类的 exit 方法，并且安全管理器允许退出操作发生。 
	非守护线程的所有线程都已停止运行，无论是通过从对 run 方法的调用中返回，
		还是通过抛出一个传播到 run 方法之外的异常。 

### 1、创建多线程:方法1

继承Thread类

	A:自定义类MyThread继承Thread类。
	B:MyThread类里面重写run()?
	C:创建对象
	D:启动线程

为什么是run()方法呢?

	不是类中的所有代码都需要被线程执行的。
	而这个时候，为了区分哪些代码能够被线程执行，
	java提供了Thread类中的run()用来包含那些被线程执行的代码。

```java
public class MyThread extends Thread{
	
	public void run(){
	
		for(int i=0;i<200;i++){
			System.out.println(i);
		}
	}
}

public class MyThreadDemo{
	public static void main(String[] Args){
		// 创建两个线程对象
		MyThread th1 = new MyThread();
		MyThread th2 = new MyThread();

		th1.start();
		th1.start();
		
		// MyThread my = new MyThread();
		// // IllegalThreadStateException:非法的线程状态异常
		// // 为什么呢?因为这个相当于是my线程被调用了两次。而不是两个线程启动。
		// my.start();
		// my.start();
	}
}
```

面试题：run()和start()的区别

	run():仅仅是封装被线程执行的代码，直接调用是普通方法
	start():首先启动了线程，然后再由jvm去调用该线程的run()方法。

### 2、获取线程对象的名称、带参构造

获取线程对象的名称

	public final String getName():获取线程的名称。

设置线程对象的名称

	public final void setName(String name):设置线程的名称

带参构造

	public Thread(String name)
	
获取main方法所在的线程对象的名称

	Thread.currentThread().getName()

```java
public class MyThread extends Thread {

	public MyThread() {
	}
	
	public MyThread(String name){
		super(name);
	}

	@Override
	public void run() {
		for (int x = 0; x < 100; x++) {
			System.out.println(getName() + ":" + x);
		}
	}
}

public class MyThreadDemo {
	public static void main(String[] args) {
		// 创建线程对象
		//无参构造+setXxx()
		// MyThread my1 = new MyThread();
		// MyThread my2 = new MyThread();
		// //调用方法设置名称
		// my1.setName("林青霞");
		// my2.setName("刘意");
		// my1.start();
		// my2.start();
		
		//带参构造方法给线程起名字
		// MyThread my1 = new MyThread("林青霞");
		// MyThread my2 = new MyThread("刘意");
		// my1.start();
		// my2.start();
		
		//我要获取main方法所在的线程对象的名称，该怎么办呢?
		//遇到这种情况,Thread类提供了一个很好玩的方法:
		//public static Thread currentThread():返回当前正在执行的线程对象
		System.out.println(Thread.currentThread().getName());
	}
}
```

	名称为什么是：Thread-? 编号

```java
	class Thread {
		private char name[];

		public Thread() {
			init(null, null, "Thread-" + nextThreadNum(), 0);
		}
		
		private void init(ThreadGroup g, Runnable target, String name,
						  long stackSize) {
			init(g, target, name, stackSize, null);
		}
		
		 private void init(ThreadGroup g, Runnable target, String name,
						  long stackSize, AccessControlContext acc) {
			//大部分代码被省略了
			this.name = name.toCharArray();
		}
		
		public final void setName(String name) {
			this.name = name.toCharArray();
		}
		
		
		private static int threadInitNumber; //0,1,2
		private static synchronized int nextThreadNum() {
			return threadInitNumber++; //return 0,1
		}
		
		public final String getName() {
			return String.valueOf(name);
		}
	}

	class MyThread extends Thread {
		public MyThread() {
			super();
		}
	}
```
### 3、线程调度

假如我们的计算机只有一个 CPU，那么 CPU 在某一个时刻只能执行一条指令，**线程只有得到 CPU时间片，也就是使用权，才可以执行指令。** 那么Java是如何对线程进行调用的呢？

线程有两种调度模型：

	分时调度模型：
		所有线程轮流使用 CPU 的使用权，平均分配每个线程占用 CPU 的时间片
	抢占式调度模型：
		优先让优先级高的线程使用CPU，
		如果线程的优先级相同，那么会随机选择一个，优先级高的线程获取的 CPU 时间片相对多一些。 

**Java使用的是抢占式调度模型。**

### 4、线程优先级

获取线程对象的优先级

	public final int getPriority():返回线程对象的优先级

设置线程对象的优先级

	public final void setPriority(int newPriority)：更改线程的优先级。 

注意：

	线程默认优先级是5。
	线程优先级的范围是：1-10。
	线程优先级高仅仅表示线程获取的 CPU时间片的几率高，但是要在次数比较多，或者多次运行的时候才能看到比较好的效果。


```java
public class ThreadPriority extends Thread {
	@Override
	public void run() {
		for (int x = 0; x < 100; x++) {
			System.out.println(getName() + ":" + x);
		}
	}
}

public class ThreadPriorityDemo {
	public static void main(String[] args) {
		ThreadPriority tp1 = new ThreadPriority();
		ThreadPriority tp2 = new ThreadPriority();
		ThreadPriority tp3 = new ThreadPriority();

		tp1.setName("东方不败");
		tp2.setName("岳不群");
		tp3.setName("林平之");

		// 获取默认优先级
		// System.out.println(tp1.getPriority());
		// System.out.println(tp2.getPriority());
		// System.out.println(tp3.getPriority());

		// 设置线程优先级
		//IllegalArgumentException:非法参数异常。
		// tp1.setPriority(100000);
		
		//设置正确的线程优先级
		tp1.setPriority(10);
		tp2.setPriority(1);

		tp1.start();
		tp2.start();
		tp3.start();
	}
}

```

### 5、线程休眠

线程休眠

	public static void sleep(long millis)

```java
public class ThreadSleep extends Thread {
	@Override
	public void run() {
		for (int x = 0; x < 100; x++) {
			System.out.println(getName() + ":" + x + ",日期：" + new Date());
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
}

public class ThreadSleepDemo {
	public static void main(String[] args) {
		ThreadSleep ts1 = new ThreadSleep();
		ThreadSleep ts2 = new ThreadSleep();
		ThreadSleep ts3 = new ThreadSleep();

		ts1.setName("林青霞");
		ts2.setName("林志玲");
		ts3.setName("林志颖");

		ts1.start();
		ts2.start();
		ts3.start();
	}
}
```

### 6、线程加入

public final void join():等待该线程终止。

```java
public class ThreadJoin extends Thread {
	@Override
	public void run() {
		for (int x = 0; x < 100; x++) {
			System.out.println(getName() + ":" + x);
		}
	}
}


public class ThreadJoinDemo {
	public static void main(String[] args) {
		ThreadJoin tj1 = new ThreadJoin();
		ThreadJoin tj2 = new ThreadJoin();
		ThreadJoin tj3 = new ThreadJoin();

		tj1.setName("李渊");
		tj2.setName("李世民");
		tj3.setName("李元霸");

		tj1.start();
		try {
			tj1.join();  //该线程执行完后，才能执行后面的线程。
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		
		tj2.start();
		tj3.start();
	}
}
```

### 7、线程礼让


public static void yield():

暂停当前正在执行的线程对象，并执行其他线程。 
让多个线程的执行更和谐，但是不能靠它保证一人一次。


```java
public class ThreadYield extends Thread {
	@Override
	public void run() {
		for (int x = 0; x < 100; x++) {
			System.out.println(getName() + ":" + x);
			Thread.yield();
		}
	}
}


public class ThreadYieldDemo {
	public static void main(String[] args) {
		ThreadYield ty1 = new ThreadYield();
		ThreadYield ty2 = new ThreadYield();

		ty1.setName("林青霞");
		ty2.setName("刘意");

		ty1.start();
		ty2.start();
	}
}
```
### 8、线程守护

public final void setDaemon(boolean on):

将该线程标记为守护线程或用户线程。
当正在运行的线程都是守护线程时，Java 虚拟机退出。
该方法必须在启动线程前调用。 

```java
public class ThreadDaemon extends Thread {
	@Override
	public void run() {
		for (int x = 0; x < 100; x++) {
			System.out.println(getName() + ":" + x);
		}
	}
}

public class ThreadDaemonDemo {
	public static void main(String[] args) {
		ThreadDaemon td1 = new ThreadDaemon();
		ThreadDaemon td2 = new ThreadDaemon();

		td1.setName("关羽");
		td2.setName("张飞");

		// 设置守护线程
		td1.setDaemon(true);
		td2.setDaemon(true);

		td1.start();
		td2.start();

		Thread.currentThread().setName("刘备");
		for (int x = 0; x < 5; x++) {
			System.out.println(Thread.currentThread().getName() + ":" + x);
		}
	}
}
```
### 9、线程中断

public final void stop():

让线程停止。方法过时了，但是还可以使用。

public void interrupt():

中断线程。把线程的状态终止，并抛出一个InterruptedException。

```java
public class ThreadStop extends Thread {
	@Override
	public void run() {
		System.out.println("开始执行：" + new Date());

		// 休息10秒钟
		try {
			Thread.sleep(10000);
		} catch (InterruptedException e) {
			// e.printStackTrace();
			System.out.println("线程被终止了");
		}

		System.out.println("结束执行：" + new Date());
	}
}

public class ThreadStopDemo {
	public static void main(String[] args) {
		ThreadStop ts = new ThreadStop();
		ts.start();

		try {
			Thread.sleep(3000);
			// ts.stop();
			ts.interrupt();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
}
```

### 10、面试题：线程的生命周期

![java33](https://s1.ax1x.com/2020/07/07/UFx5y4.png)

## 三、Runnable接口

### 1、创建多线程:方法2

实现Runnable接口

	A:自定义类MyRunnable实现Runnable接口
	B:重写run()方法
	C:创建MyRunnable类的对象
	D:创建Thread类的对象，并把C步骤的对象作为构造参数传递
	

```java
public class MyRunnable implements Runnable {

	@Override
	public void run() {
		for (int x = 0; x < 100; x++) {
			// 由于实现接口的方式就不能直接使用Thread类的方法了,但是可以间接的使用
			System.out.println(Thread.currentThread().getName() + ":" + x);
		}
	}

}

public class MyRunnableDemo {
	public static void main(String[] args) {
		// 创建MyRunnable类的对象
		MyRunnable my = new MyRunnable();

		// 创建Thread类的对象，并把C步骤的对象作为构造参数传递
		// Thread(Runnable target)
		// Thread t1 = new Thread(my);
		// Thread t2 = new Thread(my);
		// t1.setName("林青霞");
		// t2.setName("刘意");

		// Thread(Runnable target, String name)
		Thread t1 = new Thread(my, "林青霞");
		Thread t2 = new Thread(my, "刘意");

		t1.start();
		t2.start();
	}
}
```

实现接口方式的好处

	可以避免由于Java单继承带来的局限性。
	适合多个相同程序的代码去处理同一个资源的情况，把线程同程序的代码，数据有效分离，较好的体现了面向对象的设计思想。

总结

![java34](https://s1.ax1x.com/2020/07/07/UFxIOJ.png)

## 四、案例

需求：

	某电影院目前正在上映贺岁大片，共有100张票，而它有3个售票窗口售票，
	请设计一个程序模拟该电影院售票。

### 1、继承Thread类

```java
public class SellTicket extends Thread {

	// 为了让多个线程对象共享这100张票，我们其实应该用静态修饰
	private static int tickets = 100;

	@Override
	public void run() {

		// 是为了模拟一直有票
		while (true) {
			if (tickets > 0) {
				System.out.println(getName() + "正在出售第" + (tickets--) + "张票");
			}
		}
	}
}

public class SellTicketDemo {
	public static void main(String[] args) {
		// 创建三个线程对象
		SellTicket st1 = new SellTicket();
		SellTicket st2 = new SellTicket();
		SellTicket st3 = new SellTicket();

		// 给线程对象起名字
		st1.setName("窗口1");
		st2.setName("窗口2");
		st3.setName("窗口3");

		// 启动线程
		st1.start();
		st2.start();
		st3.start();
	}
}
```
**出现了一张票卖了两次的情况**

### 2、实现Runnable接口

```java
public class SellTicket implements Runnable {
	// 定义100张票
	private int tickets = 100;

	@Override
	public void run() {
		while (true) {
			if (tickets > 0) {
				System.out.println(Thread.currentThread().getName() + "正在出售第"
						+ (tickets--) + "张票");
			}
		}
	}
}

public class SellTicketDemo {
	public static void main(String[] args) {
		// 创建资源对象
		SellTicket st = new SellTicket();

		// 创建三个线程对象
		Thread t1 = new Thread(st, "窗口1");
		Thread t2 = new Thread(st, "窗口2");
		Thread t3 = new Thread(st, "窗口3");

		// 启动线程
		t1.start();
		t2.start();
		t3.start();
	}
}
```

```java
//为模拟真实情况，每次卖票延迟100毫秒
public class SellTicket implements Runnable {
	// 定义100张票
	private int tickets = 100;

	@Override
	public void run() {
		while (true) {
			// t1,t2,t3三个线程
			// 这一次的tickets = 1;
			if (tickets > 0) {
				// 为了模拟更真实的场景，我们稍作休息
				try {
					Thread.sleep(100); //t1进来了并休息，t2进来了并休息，t3进来了并休息，
				} catch (InterruptedException e) {
					e.printStackTrace();
				}

				System.out.println(Thread.currentThread().getName() + "正在出售第"
						+ (tickets--) + "张票");
				//窗口1正在出售第1张票,tickets=0
				//窗口2正在出售第0张票,tickets=-1
				//窗口3正在出售第-1张票,tickets=-2
			}
		}
	}
}
```
出现了以下两种情况：

	相同的票出现多次：
		CPU的一次操作必须是原子性的
	还出现了负数的票:
		随机性和延迟导致的
	
	输出结果：
		窗口3正在出售第3张票
		窗口1正在出售第3张票
		窗口2正在出售第2张票
		窗口1正在出售第1张票
		窗口3正在出售第0张票
		窗口2正在出售第-1张票

为什么出现问题?(也是我们判断是否有问题的标准)

	是否是多线程环境
	是否有共享数据
	是否有多条语句操作共享数据

如何解决这个线程安全问题呢?

	我们来回想一下我们的程序有没有上面的问题呢?
		A:是否是多线程环境	是
		B:是否有共享数据	是
		C:是否有多条语句操作共享数据	是
	
	由此可见我们的程序出现问题是正常的，因为它满足出问题的条件。
	接下来才是我们要想想如何解决问题呢?
	A和B的问题我们改变不了，我们只能想办法去把C改变一下。
	
	思想：
		把多条语句操作共享数据的代码给包成一个整体，让某个线程在执行的时候，
		别人不能来执行。[把多个语句操作共享数据的代码给锁起来，
		让任意时刻只能有一个线程执行即可。]
	
	问题是我们不知道怎么包啊?其实我也不知道，但是Java给我们提供了：同步机制。

### 3、同步机制synchronized

#### （1）同步代码块

	synchronized(对象){
		需要同步的代码;
	}
	
	A:对象是什么呢?
		任意对象
	B:需要同步的代码是哪些呢?
		把多条语句操作 共享数据的代码的部分给包起来
	
	注意：
		同步可以解决安全问题的根本原因就在那个对象上。该对象如同锁的功能。
		多个线程必须是同一把锁。

```java
public class SellTicket implements Runnable {
	// 定义100张票
	private int tickets = 100;
	// 定义同一把锁
	private Object obj = new Object();
	
	@Override
	public void run() {
		while (true) {
			// t1,t2,t3都能走到这里
			// 假设t1抢到CPU的执行权，t1就要进来
			// 假设t2抢到CPU的执行权，t2就要进来,发现门是关着的，进不去。所以就等着。
			// 门(开,关)
			synchronized (obj) { // 发现这里的代码将来是会被锁上的，所以t1进来后，就锁了。(关)
				if (tickets > 0) {
					try {
						Thread.sleep(100); // t1就睡眠了
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
					System.out.println(Thread.currentThread().getName()
							+ "正在出售第" + (tickets--) + "张票");
					//窗口1正在出售第100张票
				}
			}//t1就出来可，然后就开门。(开)
		}
	}
}
```

同步的前提

	多个线程
	多个线程使用的是同一个锁对象

同步的好处

	同步的出现解决了多线程的安全问题。

同步的弊端

	当线程相当多时，因为每个线程都会去判断同步上的锁，这是很耗费资源的，
	无形中会降低程序的运行效率。



同步代码块的锁对象是任意对象。

```java
package cn.itcast_11;

public class SellTicket implements Runnable {

	// 定义100张票
	private static int tickets = 100;

	// 定义同一把锁
	private Demo d = new Demo();
	
	//同步代码块用任意对象做锁
	@Override
	public void run() {
		while (true) {
			synchronized (d) {
				if (tickets > 0) {
					try {
						Thread.sleep(100);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
					System.out.println(Thread.currentThread().getName()
							+ "正在出售第" + (tickets--) + "张票 ");
				}
			}
		}
	}	
}

class Demo {}

```


#### （2）同步方法

把同步关键字加在方法上。

同步方法是this

```java
package cn.itcast_11;

public class SellTicket implements Runnable {

	// 定义100张票
	private static int tickets = 100;

	// 定义同一把锁
	private int x = 0;

	@Override
	public void run() {
		while (true) {
			if(x%2==0){
				synchronized (this) {
					if (tickets > 0) {
						try {
							Thread.sleep(100);
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
						System.out.println(Thread.currentThread().getName()
								+ "正在出售第" + (tickets--) + "张票 ");
					}
				}
			}else {
				
				sellTicket();
				
			}
			x++;
		}
	}

	
	//如果一个方法一进去就看到了代码被同步了，那么我就再想能不能把这个同步加在方法上呢?
	 private synchronized void sellTicket() {
		if (tickets > 0) {
		try {
				Thread.sleep(100);
		} catch (InterruptedException e) {
				e.printStackTrace();
		}
		System.out.println(Thread.currentThread().getName()
					+ "正在出售第" + (tickets--) + "张票 ");
		}
	}
	
}

```

#### （3）同步静态方法

静态方法的锁对象是类的字节码文件对象。(反射会讲)

```java
package cn.itcast_11;

public class SellTicket implements Runnable {

	// 定义100张票
	private static int tickets = 100;
	private int x = 0;
	
	@Override
	public void run() {
		while (true) {
			if(x%2==0){
				synchronized (SellTicket.class) {
					if (tickets > 0) {
						try {
							Thread.sleep(100);
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
						System.out.println(Thread.currentThread().getName()
								+ "正在出售第" + (tickets--) + "张票 ");
					}
				}
			}else {				
				sellTicket();				
			}
			x++;
		}
	}

	
	private static synchronized void sellTicket() {
		if (tickets > 0) {
		try {
				Thread.sleep(100);
		} catch (InterruptedException e) {
				e.printStackTrace();
		}
		System.out.println(Thread.currentThread().getName()
					+ "正在出售第" + (tickets--) + "张票 ");
		}
	}
}

```

## 五、以前的线程安全的类

	A:StringBuffer
	B:Vector
	C:Hashtable
	D:如何把一个线程不安全的集合类变成一个线程安全的集合类
		用Collections工具类的方法即可，synchronizedList。

```java
import java.util.ArrayList;
import java.util.Collections;
import java.util.Hashtable;
import java.util.List;
import java.util.Vector;

public class ThreadDemo {
	public static void main(String[] args) {
		// 线程安全的类
		StringBuffer sb = new StringBuffer();
		Vector<String> v = new Vector<String>();
		Hashtable<String, String> h = new Hashtable<String, String>();

		// Vector是线程安全的时候才去考虑使用的，但是我还说过即使要安全，我也不用你
		// 那么到底用谁呢?
		// public static <T> List<T> synchronizedList(List<T> list)
		List<String> list1 = new ArrayList<String>();// 线程不安全
		List<String> list2 = Collections
				.synchronizedList(new ArrayList<String>()); // 线程安全
	}
}

```