# Java 面试题--多线程

[TOC]

## run()和start()的区别

都是 Thread 类中的方法。

run()是子类在继承 Thread 类时需要重写，封装了要被线程执行的代码，直接调用是普通方法。
[Thread 类的run()方法是 Thread 类实现 Runable 接口重写的方法]

start()是用来启动了线程，然后再由jvm去调用该线程的run()方法。

## 线程的生命周期

![java33](https://s1.ax1x.com/2020/07/07/UFx5y4.png)


![java36](https://s1.ax1x.com/2020/07/07/UkdNWj.png)

## 为什么wait(),notify(),notifyAll()等方法都定义在Object类中

Object类下：

	wait()：在其他线程调用此对象的 notify() 方法或 notifyAll() 方法前，导致当前线程等待
	notify()：唤醒在此对象监视器上等待的单个线程。
	notifyAll()：唤醒在此对象监视器上等待的所有线程。线程通过调用其中一个wait方法，在对象的监视器上等待。 


 因为这些方法的调用是依赖于锁对象的，而同步代码块的锁对象是任意对象。而Object类是所有类的基类，所以，定义在这里面。

## sleep()和wait()方法的区别

sleep() 是Thread类中的方法。作用是在指定的毫秒数内让当前正在执行的线程休眠（暂停执行），该线程不丢失任何监视器的所属权(不释放锁)。 必须指时间。

wait() 是Object类中的方法，作用是使当前线程等待，直到其他线程调用此对象的 notify() 方法或 notifyAll() 方法。可以不指定等待时间(毫秒)，也可以指定等待时间;释放锁。

## 同步有几种方式，分别是什么?

两种。

(1)同步代码块：把同步关键字synchronized加在代码块上。锁对象是任意对象。

(2)同步方法：把同步关键字synchronized加在方法上。锁对象是this。

[锁对象Lock]

## 多线程有几种实现方案，分别是哪几种?

两种。

(1)继承Thread类

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
	}
}
```

(2)实现Runnable接口

```java
public class MyRunnable implements Runnable {

	@Override
	public void run() {
		for (int x = 0; x < 100; x++) {
			System.out.println(Thread.currentThread().getName() + ":" + x);
		}
	}

}

public class MyRunnableDemo {
	public static void main(String[] args) {
		// 创建MyRunnable类的对象
		MyRunnable my = new MyRunnable();

		Thread t1 = new Thread(my, "林青霞");
		Thread t2 = new Thread(my, "刘意");

		t1.start();
		t2.start();
	}
}
```

(3)扩展一种：实现Callable接口。这个得和线程池结合。

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

## 创建线程的两种方式以及区别

(1)继承Thread类：

- 因为已经继承Thread类，所以不能继承其他父类。

- 若要两个线程之间共享变量时，需要在声明为static变量。

- 代码简单，直接通过Thread的构造方法创建线程，且访问当前线程时，直接调用this.即可获得当前线程。

(2)实现Runnable接口：

- 线程只是实现了Runnable接口，还可以继承其他类和实现其他接口；(避免由于Java单继承带来的局限性。)

- 可以多个线程之间共享同一个目标对象，非常适合多个线程处理同一份资源的情况；(适合多个相同程序的代码去处理同一个资源的情况，把线程同程序的代码，数据有效分离，较好的体现了面向对象的设计思想。)

- 代码稍微复杂一些，若要访问当前线程，必须使用Thread.currentThread()方法。
