# Java 面试题

## java中方法重写与重载的区别

方法重写(Override)：

	发生在子类继承父类的情况下。
	在子类中，出现和父类中一模一样的方法声明的现象。完全相同的返回值类型、方法名、参数个数以及参数类型。

	当父类中方法的访问权限修饰符为private或final时，在子类是不能被重写的。


方法重载(Overload)：

	发生在同一个类中。
	出现的方法名相同，参数列表不同的现象。（参数列表不同指的是参数个数、参数类型或者参数的顺序不同。）
	方法重载能改变返回值类型，因为它和返回值类型无关。

## 列出常见的运行异常

编译时异常和运行时异常区别：

	编译时异常
		Java程序必须显示处理，否则程序就会发生错误，无法通过编译（编辑器中显示的错误）
	运行时异常
		可以编译通过、但在运行出现。代码不够严谨，需要修正代码的

RuntimeException:

	索引越界异常 IndexOutOfBoundsException
	当出现异常的运算条件(除数为0) ArithmeticException 
	空指针异常 NullPointerException
	类型转换异常 ClassCastException
	非法参数异常 IllegalArgumentException
	数组下标越界 ArrayIndexOutOfBoundsException 

## float f = 4.2,书写是否正确

错误，double占用8个字节的存储空间，float占用4个字节,double转float截取，可以会损失精度。

	浮点数默认是double，要么 float f = 4.2f; 要么 double f = 4.2;

	//长整型用L、l标记;浮点数单精度用F、f标记
	int i = 100000000000000; //错误，超出了int的范围
	long i = 100000000000000L; //正确
	long i = 100; //正确
	long i = 100L; //正确。最好加L

## 用过哪些java设计模式，写线程安全的单例模式

	•创建型模式（5种）：工厂方法模式，抽象工厂模式，单例模式，建造者模式，原型模式。
	•结构型模式（7种）：适配器模式，装饰器模式，代理模式，外观模式，桥接模式，组合模式，
						享元模式。
	•行为型模式（11种）：策略模式、模板方法模式、观察者模式、迭代子模式、责任链模式、
						命令模式、备忘录模式、状态模式、访问者模式、中介者模式、解释器模式。

单例设计模式：确保类在内存中只有一个对象，该实例必须自动创建，并且对外提供。

```java
// 饿汉式:类一加载就创建对象
public class Student{
	private student{}

	private static Student s = new Student();

	public static Student getStudent(){
		return s;
	}

}
```

```java
// 懒汉式:用的时候再创建对象
public class Student{
	private student{}

	private static Student s = null;

	public synchronized static Student getStudent(){

		if (s == null){
			return new Student();
		}
		return s;
		
	}

}
```

简单工厂模式：定义一个具体的工厂类负责创建一些类的实例。

```java
public class AnimalFactory {

	private AnimalFactory() {}  // 私有

	public static Animal createAnimal(String type) {  // 静态
		if ("dog".equals(type)) {
			return new Dog();
		} else if ("cat".equals(type)) {
			return new Cat();
		} else {
			return null;
		}
	}
}

```

工厂方法模式：抽象工厂类负责定义创建对象的接口，具体对象的创建工作由继承抽象工厂的具体类实现。

```java
public interface Factory {
	public abstract Animal createAnimal();
}

public class DogFactory implements Factory {

	@Override
	public Animal createAnimal() {
		return new Dog();
	}

}
```

模版方法模式:定义一个算法的骨架，而将具体的算法延迟到子类中来实现。

装饰模式:使用被装饰类的一个子类的实例，在客户端将这个子类的实例交给装饰类。是继承的替代方案。

## java 多线程

【中点健康云】