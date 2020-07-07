# 多线程02：Lock、线程组、线程池

## 一、Lock 接口

虽然我们可以理解同步代码块和同步方法的锁对象问题，
但是我们并没有直接看到在哪里加上了锁，在哪里释放了锁，
为了更清晰的表达如何加锁和释放锁，JDK5以后提供了一个新的锁对象Lock

成员方法：

	void lock()  获取锁。
	void unlock() 释放锁。  

实现类：ReentrantLock

示例：

```java
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class SellTicket implements Runnable {

	// 定义票
	private int tickets = 100;

	// 定义锁对象
	private Lock lock = new ReentrantLock();

	@Override
	public void run() {
		while (true) {
			try {
				// 加锁
				lock.lock();
				if (tickets > 0) {
					try {
						Thread.sleep(100);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
					System.out.println(Thread.currentThread().getName()
							+ "正在出售第" + (tickets--) + "张票");
				}
			} finally {
				// 释放锁
				lock.unlock();
			}
		}
	}

}
```
### 1、死锁问题

同步弊端：

	效率低。因为要判断是不是有锁。
	如果出现了同步嵌套，就容易产生死锁问题

死锁问题：

	指两个或者两个以上的线程在执行的过程中，因争夺资源产生的一种互相等待现象。

死锁举例：

通过设置线程(生产者)和获取线程(消费者)针对同一个学生对象进行操作。

```java
public class MyLock {
	// 创建两把锁对象
	public static final Object objA = new Object();
	public static final Object objB = new Object();
}

public class DieLock extends Thread {

	private boolean flag;

	public DieLock(boolean flag) {
		this.flag = flag;
	}

	@Override
	public void run() {
		if (flag) {
			synchronized (MyLock.objA) {
				System.out.println("if objA"); 
				//当线程1走到这里，要等待释放锁MyLock.objB
				//而此锁在else语句中未释放。
				synchronized (MyLock.objB) { 
					System.out.println("if objB");
				}
			}
		} else {
			synchronized (MyLock.objB) {
				System.out.println("else objB");
				//当线程2走到这里，要等待释放锁MyLock.objA
				//而此锁在if语句中未释放。出现两部分都在等待锁释放。
				synchronized (MyLock.objA) {  
					System.out.println("else objA");
				}
			}
		}
	}
}

public class DieLockDemo {
	public static void main(String[] args) {
		DieLock dl1 = new DieLock(true);
		DieLock dl2 = new DieLock(false);

		dl1.start();
		dl2.start();
	}
}
```

### 2、线程间通信

针对同一个资源的操作有不同种类的线程。例如，卖票有进的，也有出的。

示例：

```java

/*
 * 分析：
 * 		资源类：Student	
 * 		设置学生数据:SetThread(生产者)
 * 		获取学生数据：GetThread(消费者)
 * 		测试类:StudentDemo
 * 
 */

public class Student {
	String name;
	int age;
}


public class SetThread implements Runnable {

	private Student s;

	public SetThread(Student s) {
		this.s = s;
	}

	@Override
	public void run() {
		// Student s = new Student();
		s.name = "林青霞";
		s.age = 27;
	}

}

public class GetThread implements Runnable {
	private Student s;

	public GetThread(Student s) {
		this.s = s;
	}

	@Override
	public void run() {
		// Student s = new Student();
		System.out.println(s.name + "---" + s.age);
	}

}
/*
 * 问题1：按照思路写代码，发现数据每次都是:null---0
 * 原因：我们在每个线程中都创建了新的资源,而我们要求的时候设置和获取线程的资源应该是同一个
 * 如何实现呢?
 * 		在外界把这个数据创建出来，通过构造方法传递给其他的类。
*/
public class StudentDemo {
	public static void main(String[] args) {
		//创建资源
		Student s = new Student();
		
		//设置和获取的类
		SetThread st = new SetThread(s);
		GetThread gt = new GetThread(s);

		//线程类
		Thread t1 = new Thread(st);
		Thread t2 = new Thread(gt);

		//启动线程
		t1.start();
		t2.start();
	}
}
```
```java
/* 
 * 问题2：为了数据的效果好一些，我加入了循环和判断，给出不同的值,这个时候产生了新的问题
 * 		A:同一个数据出现多次
 * 		B:姓名和年龄不匹配
 * 原因：
 * 		A:同一个数据出现多次
 * 			CPU的一点点时间片的执行权，就足够你执行很多次。
 * 		B:姓名和年龄不匹配
 * 			线程运行的随机性
 * 线程安全问题：
 * 		A:是否是多线程环境		是
 * 		B:是否有共享数据		是
 * 		C:是否有多条语句操作共享数据	是
 * 解决方案：
 * 		加锁。
 * 		注意：
 * 			A:不同种类的线程都要加锁。
 * 			B:不同种类的线程加的锁必须是同一把。
 */
public class GetThread implements Runnable {
	private Student s;

	public GetThread(Student s) {
		this.s = s;
	}

	@Override
	public void run() {
		while (true) {
			synchronized (s) {
				System.out.println(s.name + "---" + s.age);
			}
		}
	}
}

public class SetThread implements Runnable {

	private Student s;
	private int x = 0;

	public SetThread(Student s) {
		this.s = s;
	}

	@Override
	public void run() {
		while (true) {
			synchronized (s) {
				if (x % 2 == 0) {
					s.name = "林青霞";//刚走到这里，就被别人抢到了执行权
					s.age = 27;
				} else {
					s.name = "刘意"; //刚走到这里，就被别人抢到了执行权
					s.age = 30;
				}
				x++;
			}
		}
	}
}

```
![java35](https://s1.ax1x.com/2020/07/07/UkdaSs.png)

```java
/*
 * 问题3:虽然数据安全了，但是呢，一次一大片不好看，我就想依次的一次一个输出。
 * 
 * 如何实现呢?
 * 		通过Java提供的等待唤醒机制解决。
 * 
 * 等待唤醒：
 * 		Object类中提供了三个方法：
 * 			wait():等待
 * 			notify():唤醒单个线程
 * 			notifyAll():唤醒所有线程
 * 		为什么这些方法不定义在Thread类中呢?
 * 			这些方法的调用必须通过锁对象调用，而我们刚才使用的锁对象是任意锁对象。
 * 			所以，这些方法必须定义在Object类中。
 */

public class Student {
	String name;
	int age;
	boolean flag; // 默认情况是没有数据，如果是true，说明有数据
}

public class SetThread implements Runnable {

	private Student s;
	private int x = 0;

	public SetThread(Student s) {
		this.s = s;
	}

	@Override
	public void run() {
		while (true) {
			synchronized (s) {
				//判断有没有
				if(s.flag){
					try {
						s.wait(); //t1等着，释放锁
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
				
				if (x % 2 == 0) {
					s.name = "林青霞";
					s.age = 27;
				} else {
					s.name = "刘意";
					s.age = 30;
				}
				x++; //x=1
				
				//修改标记
				s.flag = true;
				//唤醒线程
				s.notify(); //唤醒t2,唤醒并不表示你立马可以执行，必须还得抢CPU的执行权。
			}
			//t1有，或者t2有
		}
	}
}


public class GetThread implements Runnable {
	private Student s;

	public GetThread(Student s) {
		this.s = s;
	}

	@Override
	public void run() {
		while (true) {
			synchronized (s) {
				if(!s.flag){
					try {
						s.wait(); //t2就等待了。立即释放锁。将来醒过来的时候，是从这里醒过来的时候
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
				
				System.out.println(s.name + "---" + s.age);
				//林青霞---27
				//刘意---30
				
				//修改标记
				s.flag = false;
				//唤醒线程
				s.notify(); //唤醒t1
			}
		}
	}
}

public class StudentDemo {
	public static void main(String[] args) {
		//创建资源
		Student s = new Student();
		
		//设置和获取的类
		SetThread st = new SetThread(s);
		GetThread gt = new GetThread(s);

		//线程类
		Thread t1 = new Thread(st);
		Thread t2 = new Thread(gt);

		//启动线程
		t1.start();
		t2.start();
	}
}
```
**线程的状态转换图**

![java36](https://s1.ax1x.com/2020/07/07/UkdNWj.png)

## 二、线程组

Java中使用ThreadGroup来表示线程组，它可以对一批线程进行分类管理，
Java允许程序直接对线程组进行控制。

Thread类的构造方法：

	Thread(ThreadGroup group, Runnable target, String name) 
    分配新的 Thread 对象，以便将 target 作为其运行对象，
	将指定的 name 作为其名称，并作为 group 所引用的线程组的一员。

Thread类的成员方法：

	public final ThreadGroup getThreadGroup()
	返回该线程所属的线程组。

	默认情况下，所有的线程都属于主线程组。

```java
public class MyRunnable implements Runnable {

	@Override
	public void run() {
		for (int x = 0; x < 100; x++) {
			System.out.println(Thread.currentThread().getName() + ":" + x);
		}
	}
}

public class ThreadGroupDemo {
	public static void main(String[] args) {
		// method1();

		// 我们如何修改线程所在的组呢?
		// 创建一个线程组
		// 创建其他线程的时候，把其他线程的组指定为我们自己新建线程组
		method2();

		// t1.start();
		// t2.start();
	}

	private static void method2() {
		// ThreadGroup(String name)
		ThreadGroup tg = new ThreadGroup("这是一个新的组");

		MyRunnable my = new MyRunnable();
		// Thread(ThreadGroup group, Runnable target, String name)
		Thread t1 = new Thread(tg, my, "林青霞");
		Thread t2 = new Thread(tg, my, "刘意");
		
		System.out.println(t1.getThreadGroup().getName());
		System.out.println(t2.getThreadGroup().getName());
		
		//通过组名称设置后台线程，表示该组的线程都是后台线程
		tg.setDaemon(true);
	}

	private static void method1() {
		MyRunnable my = new MyRunnable();
		Thread t1 = new Thread(my, "林青霞");
		Thread t2 = new Thread(my, "刘意");
		// 我不知道他们属于那个线程组,我想知道，怎么办
		// 线程类里面的方法：public final ThreadGroup getThreadGroup()
		ThreadGroup tg1 = t1.getThreadGroup();
		ThreadGroup tg2 = t2.getThreadGroup();
		// 线程组ThreadGroup里面的方法：public final String getName()
		String name1 = tg1.getName();
		String name2 = tg2.getName();
		System.out.println(name1);
		System.out.println(name2);
		// 通过结果我们知道了：线程默认情况下属于main线程组
		// 通过下面的测试，你应该能够看到，默任情况下，所有的线程都属于同一个组
		System.out.println(Thread.currentThread().getThreadGroup().getName());
	}
}

```

**等待唤醒案例优化**

```java
public class Student {
	private String name;
	private int age;
	private boolean flag; // 默认情况是没有数据，如果是true，说明有数据

	public synchronized void set(String name, int age) {
		// 如果有数据，就等待
		if (this.flag) {
			try {
				this.wait();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}

		// 设置数据
		this.name = name;
		this.age = age;

		// 修改标记
		this.flag = true;
		this.notify();
	}

	public synchronized void get() {
		// 如果没有数据，就等待
		if (!this.flag) {
			try {
				this.wait();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}

		// 获取数据
		System.out.println(this.name + "---" + this.age);

		// 修改标记
		this.flag = false;
		this.notify();
	}
}

public class SetThread implements Runnable {

	private Student s;
	private int x = 0;

	public SetThread(Student s) {
		this.s = s;
	}

	@Override
	public void run() {
		while (true) {
			if (x % 2 == 0) {
				s.set("林青霞", 27);
			} else {
				s.set("刘意", 30);
			}
			x++;
		}
	}
}

public class GetThread implements Runnable {
	private Student s;

	public GetThread(Student s) {
		this.s = s;
	}

	@Override
	public void run() {
		while (true) {
			s.get();
		}
	}
}

public class StudentDemo {
	public static void main(String[] args) {
		//创建资源
		Student s = new Student();
		
		//设置和获取的类
		SetThread st = new SetThread(s);
		GetThread gt = new GetThread(s);

		//线程类
		Thread t1 = new Thread(st);
		Thread t2 = new Thread(gt);

		//启动线程
		t1.start();
		t2.start();
	}
}
```

## 三、线程池

程序启动一个新线程成本是比较高的，因为它涉及到要与操作系统进行交互。
而使用线程池可以很好的提高性能，尤其是当程序中要创建大量生存期很短的线程时，
更应该考虑使用线程池。

线程池里的每一个线程代码结束后，并不会死亡，而是再次回到线程池中成为空闲状态，等待下一个对象来使用。

在JDK5之前，我们必须手动实现自己的线程池，从JDK5开始，Java内置支持线程池。

JDK5新增了一个 Executors 工厂类来产生线程池，有如下几个方法：

	public static ExecutorService newCachedThreadPool()
	public static ExecutorService newFixedThreadPool(int nThreads)
	public static ExecutorService newSingleThreadExecutor()

这些方法的返回值是 ExecutorService 对象，该对象表示一个线程池，
可以执行Runnable对象或者Callable对象代表的线程。它提供了如下方法：

	Future<?> submit(Runnable task)
	<T> Future<T> submit(Callable<T> task)

创建过程：

	A:创建一个线程池对象，控制要创建几个线程对象。
		public static ExecutorService newFixedThreadPool(int nThreads)
	B:这种线程池的线程可以执行：
		可以执行Runnable对象或者Callable对象代表的线程
		做一个类实现Runnable接口。
	C:调用如下方法即可
		Future<?> submit(Runnable task)
		<T> Future<T> submit(Callable<T> task)
	D:结束 shutdown

```java
public class MyRunnable implements Runnable {

	@Override
	public void run() {
		for (int x = 0; x < 100; x++) {
			System.out.println(Thread.currentThread().getName() + ":" + x);
		}
	}
}

public class ExecutorsDemo {
	public static void main(String[] args) {
		// 创建一个线程池对象，控制要创建几个线程对象。
		ExecutorService pool = Executors.newFixedThreadPool(2);

		// 可以执行Runnable对象或者Callable对象代表的线程
		pool.submit(new MyRunnable());
		pool.submit(new MyRunnable());

		//结束线程池
		pool.shutdown();
	}
}
```
### 1、Callable<V> 接口

类型参数：

	V - call 方法的结果类型

返回结果并且可能抛出异常的任务。实现者定义了一个不带任何参数的叫做 call 的方法。 

Callable 接口类似于 Runnable，两者都是为那些 其实例可能被另一个线程执行的类设计的。但是 Runnable 不会返回结果，并且无法抛出经过检查的异常。 

Executors 类包含一些从其他普通形式转换成 Callable 类的实用方法。 

	V call()
		   throws Exception计算结果，如果无法计算结果，则抛出一个异常。 

	返回：
		计算的结果

**创建多线程：方法3**

```java
import java.util.concurrent.Callable;

//Callable:是带泛型的接口。
//这里指定的泛型其实是call()方法的返回值类型。
public class MyCallable implements Callable {

	@Override
	public Object call() throws Exception {
		for (int x = 0; x < 100; x++) {
			System.out.println(Thread.currentThread().getName() + ":" + x);
		}
		return null;
	}
}

public class CallableDemo {
	public static void main(String[] args) {
		//创建线程池对象
		ExecutorService pool = Executors.newFixedThreadPool(2);
		
		//可以执行Runnable对象或者Callable对象代表的线程
		pool.submit(new MyCallable());
		pool.submit(new MyCallable());
		
		//结束
		pool.shutdown();
	}
}
```

### 2、Future<V> 接口

public interface Future<V> 

类型参数：

	V - 此 Future 的 get 方法所返回的结果类型 

	表示异步计算的结果。它提供了检查计算是否完成的方法，以等待计算的完成，
	并获取计算的结果。计算完成后只能使用 get 方法来获取结果，如有必要，
	计算完成前可以阻塞此方法。取消则由 cancel 方法来执行。还提供了其他方法，
	以确定任务是正常完成还是被取消了。一旦计算完成，就不能再取消计算。
	如果为了可取消性而使用 Future 但又不提供可用的结果，则可以声明 Future<?> 
	形式类型、并返回 null 作为底层任务的结果。 

成员方法

	boolean cancel(boolean mayInterruptIfRunning)试图取消对此任务的执行。

	V get() 如有必要，等待计算完成，然后获取其结果

**多线程计算求和**

```java
public class MyCallable implements Callable<Integer> {

	private int number;

	public MyCallable(int number) {
		this.number = number;
	}

	@Override
	public Integer call() throws Exception {
		int sum = 0;
		for (int x = 1; x <= number; x++) {
			sum += x;
		}
		return sum;
	}

}

public class CallableDemo {
	public static void main(String[] args) throws InterruptedException, ExecutionException {
		// 创建线程池对象
		ExecutorService pool = Executors.newFixedThreadPool(2);

		// 可以执行Runnable对象或者Callable对象代表的线程
		Future<Integer> f1 = pool.submit(new MyCallable(100));
		Future<Integer> f2 = pool.submit(new MyCallable(200));

		// V get()
		Integer i1 = f1.get();
		Integer i2 = f2.get();

		System.out.println(i1);
		System.out.println(i2);

		// 结束
		pool.shutdown();
	}
}
```

### 3、匿名内部类方式使用多线程

new Thread(){代码…}.start();

new Thread(new Runnable(){代码…}).start();

本质：是该类或者接口的子类对象。

```java

public class ThreadDemo {
	public static void main(String[] args) {
		// 继承Thread类来实现多线程
		new Thread() {
			public void run() {
				for (int x = 0; x < 100; x++) {
					System.out.println(Thread.currentThread().getName() + ":"
							+ x);
				}
			}
		}.start();

		// 实现Runnable接口来实现多线程
		new Thread(new Runnable() {
			@Override
			public void run() {
				for (int x = 0; x < 100; x++) {
					System.out.println(Thread.currentThread().getName() + ":"
							+ x);
				}
			}
		}) {
		}.start();

		// 更有难度的
		new Thread(new Runnable() {
			@Override
			public void run() {
				for (int x = 0; x < 100; x++) {
					System.out.println("hello" + ":" + x);
				}
			}
		}) {
			public void run() {
				for (int x = 0; x < 100; x++) {
					System.out.println("world" + ":" + x);
				}
			}
		}.start();  //执行的是 world 的代码部分
	}
}
```

## 二、定时器

定时器是一个应用十分广泛的线程工具，可用于调度多个定时任务以后台线程的方式执行。

可以让我们在指定的时间做某件事情，还可以重复的做某件事情。

在Java中，可以通过Timer和TimerTask类来实现定义调度的功能：

	Timer 定时
		public Timer()
		创建一个新计时器
		public void schedule(TimerTask task, long delay)
		安排在指定延迟后执行指定的任务。
		public void schedule(TimerTask task,long delay,long period)
		安排指定的任务从指定的延迟后开始进行重复的固定延迟执行。
		public void schedule(TimerTask task,Date time)
		安排在指定的时间执行指定的任务。如果此时间已过去，则安排立即执行该任务。 
	TimerTask 任务
		public abstract void run() 此计时器任务要执行的操作。
		public boolean cancel() 取消此计时器任务
```java
public class TimerDemo {
	public static void main(String[] args) {
		// 创建定时器对象
		Timer t = new Timer();
		// 3秒后执行爆炸任务
		// t.schedule(new MyTask(), 3000);
		//结束任务
		t.schedule(new MyTask(t), 3000);
	}
}

// 做一个任务
class MyTask extends TimerTask {

	private Timer t;
	
	public MyTask(){}
	
	public MyTask(Timer t){
		this.t = t;
	}
	
	@Override
	public void run() {
		System.out.println("beng,爆炸了");
		t.cancel();
	}
}
```

```java

public class TimerDemo2 {
	public static void main(String[] args) {
		// 创建定时器对象
		Timer t = new Timer();
		// 3秒后执行爆炸任务第一次，如果不成功，每隔2秒再继续炸
		t.schedule(new MyTask2(), 3000, 2000);
	}
}

// 做一个任务
class MyTask2 extends TimerTask {
	@Override
	public void run() {
		System.out.println("beng,爆炸了");
	}
}
```

## 三、面试题整理

	1:多线程有几种实现方案，分别是哪几种?
		两种。
		
		继承Thread类
		实现Runnable接口
		
		扩展一种：实现Callable接口。这个得和线程池结合。

	2:同步有几种方式，分别是什么?
		两种。
		
		同步代码块
		同步方法

	3:启动一个线程是run()还是start()?它们的区别?
		start();
		
		run():封装了被线程执行的代码,直接调用仅仅是普通方法的调用
		start():启动线程，并由JVM自动调用run()方法

	4:sleep()和wait()方法的区别
		sleep():必须指时间;不释放锁。
		wait():可以不指定时间，也可以指定时间;释放锁。

	5:为什么wait(),notify(),notifyAll()等方法都定义在Object类中
		因为这些方法的调用是依赖于锁对象的，而同步代码块的锁对象是任意锁。
		而Object代码任意的对象，所以，定义在这里面。

	6:线程的生命周期图
		新建 -- 就绪 -- 运行 -- 死亡
		新建 -- 就绪 -- 运行 -- 阻塞 -- 就绪 -- 运行 -- 死亡
		建议：画图解释。

