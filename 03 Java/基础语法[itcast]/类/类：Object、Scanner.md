# 类：Object、Scanner

[TOC]

## 1、Object类

### 1.1、概述

	类 Object 是类层次结构的根类。每个类都使用 Object 作为超类。
	
	每个类(包括数组)都直接或者间接的继承自Object类。

### 1.2、构造方法

public Object()

**为什么子类的构造方法默认访问的是父类的无参构造方法：**
	
	因为所有类的根类Object只有一个无参构造。

### 1.3、成员方法

	public int hashCode()  

返回该对象的哈希码值

注意：哈希值是根据哈希算法计算出来的一个值，这个值和地址值有关，但是不是实际地址值。你可以理解为地址值。
		  
	public final Class getClass()

返回此 Object 的运行时 类（返回对象的字节码文件对象）

	Class类的方法：
		public String getName()：以 String 的形式返回此 Class 对象所表示的实体(接口、数组对象、基本类型、void类)名称。

```java
public static void main(String[] args) {
	Student s1 = new Student();
	System.out.println(s1.hashCode());   11299397
	Student s2 = new Student();
	System.out.println(s2.hashCode());  24446859
	Student s3 = s1;
	System.out.println(s3.hashCode());   11299397
	System.out.println("-----------");

	Student s = new Student();
	Class c = s.getClass();
	String str = c.getName();
	System.out.println(str);   cn.itcast_01.Student
		
	//链式编程
	String str2  = s.getClass().getName();
	System.out.println(str2);
	}
```

	public String toString()

返回该对象的字符串表示。
	
	Integer类下的一个静态方法：
		public static String toHexString(int i)：把一个整数转成一个十六进制表示的字符串
	
注意：

	这个结构信息的组成是没有任何意义的。所以，建议所有子类都重写该方法。怎么重写呢：
		把该类的所有成员变量值组成返回即可。
	
		重写的最终版方案就是自动生成toString()方法。
	
	直接输出一个对象的名称，其实就是调用该对象的toString()方法。

```java
public static void main(String[] args) {
	Student s = new Student();
	System.out.println(s.hashCode());
	System.out.println(s.getClass().getName());
	System.out.println("--------------------");
	System.out.println(s.toString());  cn.itcast_02.Student@42552c
	System.out.println("--------------------");
	 /*toString()方法的值等价于它
	  getClass().getName() + '@' + Integer.toHexString(hashCode())
	  this.getClass().getName()+'@'+Integer.toHexString(this.hashCode())

	  cn.itcast_02.Student@42552c
	  cn.itcast_02.Student@42552c
	*/
	System.out.println(s.getClass().getName() + '@'
		+ Integer.toHexString(s.hashCode()));

	System.out.println(s.toString());

	 //直接输出对象的名称
	System.out.println(s);
	}
...	
@Override
public String toString() {
	return "Student [name=" + name + ", age=" + age + "]";
}	
	
```

	public boolean equals(Object obj)

指示其他某个对象是否与此对象“相等”。 默认情况下比较的是地址值。
	
```java
public static void main(String[] args) {
	Student s1 = new Student("林青霞", 27);
	Student s2 = new Student("林青霞", 27);
	System.out.println(s1 == s2); // false
	System.out.println(s1.equals(s2)); // obj = s2; //false
```
	
比较地址值一般来说意义不大，所以我们要重写该方法。一般都是用来比较对象的成员变量值是否相同。

```java
@Override
public boolean equals(Object obj) {
	Student s = (Student)obj;  
 	if(this.name.equals(s.name) && this.age == s.age) {
 		return true;
 	}else {
 		return false;
 	}
}
```	
		
重写的代码优化：提高效率，提高程序的健壮性。
	
```java
@Override
public boolean equals(Object obj){
	if(this == obj){    //地址值相同直接返回
		return true;
	}
	if(!(obj instanceof Student)){  //传进来的对象和当前对象不同时
		return false;
	}
	Student s = (Student)obj;
	//System.out.println("同一个对象，还需要向下转型并比较吗?");
	return this.name.equals(s.name) && this.age == s.age;
}

```
	
最终版：其实还是自动生成。

```java
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Student other = (Student) obj;
		if (age != other.age)
			return false;
		if (name == null) {
			if (other.name != null)
				return false;
		} else if (!name.equals(other.name))
			return false;
		return true;
	}
```	
   
看源码：

```
	public boolean equals(Object obj) {
		this - s1
		obj - s2
		return (this == obj);
	}

==和equals区别：

	==:
		基本类型：比较的就是值是否相同
		引用类型：比较的就是地址值是否相同
	equals:
		引用类型：默认情况下，比较的是地址值。
		不过，我们可以根据情况自己重写该方法。一般重写都是自动生成，比较对象的成员变量值是否相同
```

	protected void finalize()

当垃圾回收器确定不存在对该对象的更多引用时，由对象的垃圾回收器调用此方法。用于垃圾回收，但是什么时候回收不确定。

	protected Object clone()

创建并返回此对象的一个副本。

	A:重写该方法，实现Cloneable 接口
	```
	@Override
	protected Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
	```
	Cloneable:此类实现了 Cloneable 接口，以指示 Object.clone() 方法可以合法地对该类实例进行按字段复制。 
	这个接口是标记接口，告诉我们实现该接口的类就可以实现对象的复制了。
	```
	public static void main(String[] args) throws CloneNotSupportedException {
		//创建学生对象
		Student s = new Student();
		s.setName("林青霞");
		s.setAge(27);
		
		//克隆学生对象
		Object obj = s.clone();
		Student s2 = (Student)obj;
		System.out.println("---------");
		
		System.out.println(s.getName()+"---"+s.getAge());
		System.out.println(s2.getName()+"---"+s2.getAge());
		
		//以前的做法
		Student s3 = s;
		System.out.println(s3.getName()+"---"+s3.getAge());
		System.out.println("---------");
		
		//其实是有区别的  clone后的对象的改变不会影响原对象。
		s3.setName("刘意");
		s3.setAge(30);
		System.out.println(s.getName()+"---"+s.getAge()); //刘意---30
		System.out.println(s2.getName()+"---"+s2.getAge()); //林青霞---27
		System.out.println(s3.getName()+"---"+s3.getAge()); //刘意---30
		
	}
	```
## 2、两个注意问题

	A:直接输出一个对象名称，其实默认调用了该对象的toString()方法。
	
	B:面试题 
	==和equals()的区别?
		A:==
			基本类型：比较的是值是否相同
			引用类型：比较的是地址值是否相同
		B:equals()
			只能比较引用类型。默认情况下，比较的是地址值是否相同。
			但是，我们可以根据自己的需要重写该方法。

## 2、Scanner类

JDK5以后用于获取用户的键盘输入

### 2.1、构造方法

	public Scanner(InputStream source)
	
	Scanner sc = new Scanner(System.in);

System类下有一个静态的字段：

	public static final InputStream in; 标准的输入流，对应着键盘录入。
	InputStream is = System.in;
	
```java
	class Demo {
		public static final int x = 10;
		public static final Student s = new Student();
	}
	int y = Demo.x;
	Student s = Demo.s;
```
### 2.2、成员方法基本格式

	hasNextXxx() 
	
判断是否还有下一个输入项，其中Xxx可以是Int,Double等。如果需要判断是否包含下一个字符串，则可以省略Xxx

	nextXxx()  

获取下一个输入项。Xxx的含义和上个方法中的Xxx相同

注意：

	默认情况下，Scanner使用空格，回车等作为分隔符。
	InputMismatchException：输入的和你想要的不匹配

```java
public static void main(String[] args) {
	// 创建对象
	Scanner sc = new Scanner(System.in);

	// 获取数据
	if (sc.hasNextInt()) {
		int x = sc.nextInt();
		System.out.println("x:" + x);
	} else {
		System.out.println("你输入的数据有误");
	}
}
```

	public int nextInt() 

获取下一个int类型的输入项

	public String nextLine() 

获取下一个String类型的值

```java
public static void main(String[] args) {
	// 创建对象
	Scanner sc = new Scanner(System.in);

	// 获取两个int类型的值
	// int a = sc.nextInt();
	// int b = sc.nextInt();
	// System.out.println("a:" + a + ",b:" + b);
	// System.out.println("-------------------");

	// 获取两个String类型的值
	// String s1 = sc.nextLine();
	// String s2 = sc.nextLine();
	// System.out.println("s1:" + s1 + ",s2:" + s2);
	// System.out.println("-------------------");

	// 先获取一个字符串，在获取一个int值
	// String s1 = sc.nextLine();
	// int b = sc.nextInt();
	// System.out.println("s1:" + s1 + ",b:" + b);
	// System.out.println("-------------------");

	// 先获取一个int值，在获取一个字符串   字符串没赋给s2
	// int a = sc.nextInt();
	// String s2 = sc.nextLine();
	// System.out.println("a:" + a + ",s2:" + s2);
	// System.out.println("-------------------");

	int a = sc.nextInt();
	Scanner sc2 = new Scanner(System.in);
	String s = sc2.nextLine();
	System.out.println("a:" + a + ",s:" + s);
	}
```

出现问题了：

	先获取一个数值，再获取一个字符串，会出现问题。
	主要原因：输入一个整型后，点击了换行(\n)，那么这个换行符被赋给了s2。
		
如何解决呢?

	A:先获取一个数值后，在创建一个新的键盘录入对象获取字符串。
	B:把所有的数据都先按照字符串获取，然后要什么，你就对应的转换为什么。

