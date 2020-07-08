# 集合01：List接口

## 一、对象数组

数组既可以存储基本数据类型，也可以存储引用类型。
它存储引用类型的时候的数组就叫对象数组。

### 案例：
```java
/ 
   我有5个学生，请把这个5个学生的信息存储到数组中，并遍历数组，获取得到每一个学生信息。
  		 学生：Student
  		 成员变量：name,age
  		 构造方法：无参,带参
  		 成员方法：getXxx()/setXxx()
  		 存储学生的数组?自己想想应该是什么样子的?
   分析：
   		A:创建学生类。
   		B:创建学生数组(对象数组)。
   		C:创建5个学生对象，并赋值。
   		D:把C步骤的元素，放到数组中。
   		E:遍历学生数组。
  /
public class ObjectArrayDemo {
	public static void main(String[] args) {
		// 创建学生数组(对象数组)。
		Student[] students = new Student[5];
		// for (int x = 0; x < students.length; x++) {
		// System.out.println(students[x]);
		// }
		// System.out.println("---------------------");

		// 创建5个学生对象，并赋值。
		Student s1 = new Student("林青霞", 27);
		Student s2 = new Student("风清扬", 30);
		Student s3 = new Student("刘意", 30);
		Student s4 = new Student("赵雅芝", 60);
		Student s5 = new Student("王力宏", 35);

		// 把C步骤的元素，放到数组中。
		students[0] = s1;
		students[1] = s2;
		students[2] = s3;
		students[3] = s4;
		students[4] = s5;

		// 看到很相似，就想循环改
		// for (int x = 0; x < students.length; x++) {
		// students[x] = s + "" + (x + 1);
		// }
		// 这个是有问题的

		// 遍历
		for (int x = 0; x < students.length; x++) {
			//System.out.println(students[x]);
			
			Student s = students[x];
			System.out.println(s.getName()+"---"+s.getAge());
		}
	}
}

```

```java
public class Student {
	// 成员变量
	private String name;
	private int age;

	// 构造方法
	public Student() {
		super();
	}

	public Student(String name, int age) {
		super();
		this.name = name;
		this.age = age;
	}

	// 成员方法
	// getXxx()/setXxx()
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getAge() {
		return age;
	}

	public void setAge(int age) {
		this.age = age;
	}

	@Override
	public String toString() {
		return "Student [name=" + name + ", age=" + age + "]";
	}
}

```

内存图解

![java28](https://s1.ax1x.com/2020/07/06/UC3eVx.png)

## 二、Collection接口

### 1、集合类

为什么出现集合类？

	我们学习的是面向对象语言，而面向对象语言对事物的描述是通过对象体现的，
	为了方便对多个对象进行操作，我们就必须把这多个对象进行存储。
	而要想存储多个对象，就不能是一个基本的变量，而应该是一个容器类型的变量，
	在我们目前所学过的知识里面，有哪些是容器类型的呢?
	数组和StringBuffer。但是呢?StringBuffer的结果是一个字符串，
	不一定满足我们的要求，所以我们只能选择数组，这就是对象数组。
	而对象数组又不能适应变化的需求，因为数组的长度是固定的，这个时候，
	为了适应变化的需求，Java就提供了集合类供我们使用。

数组和集合的区别

	A:长度区别
		数组的长度固定
		集合长度可变
	B:内容不同
		数组存储的是同一种类型的元素
		而集合可以存储不同类型的元素
	C:元素的数据类型问题	
		数组可以存储基本数据类型，也可以存储引用数据类型
		集合只能存储引用类型

集合类的特点

	集合只用于存储对象，集合长度是可变的，集合可以存储不同类型的对象。

### 2、Collection接口

Collection 层次结构中的根接口。Collection 表示一组对象，这些对象也称为 collection 的元素。
一些 collection 允许有重复的元素，而另一些则不允许。
一些 collection 是有序的，而另一些则是无序的。

![java30](https://s1.ax1x.com/2020/07/06/UCX6nx.png)

#### (1)成员方法

```java
/ 
   Collection的功能概述：
   1：添加功能
   		boolean add(Object obj):添加一个元素
   		boolean addAll(Collection c):添加一个集合的元素
   2:删除功能
   		void clear():移除所有元素
   		boolean remove(Object o):移除一个元素
   		boolean removeAll(Collection c):移除一个集合的元素(是一个还是所有)
   3:判断功能
   		boolean contains(Object o)：判断集合中是否包含指定的元素
   		boolean containsAll(Collection c)：判断集合中是否包含指定的集合元素(是一个还是所有)
   		boolean isEmpty()：判断集合是否为空
   4:获取功能
   		Iterator<E> iterator()(重点)
   5:长度功能
   		int size():元素的个数
   		面试题：数组有没有length()方法呢?字符串有没有length()方法呢?集合有没有length()方法呢?
   6:交集功能
   		boolean retainAll(Collection c):两个集合都有的元素?思考元素去哪了，返回的boolean又是什么意思呢?
   7：把集合转换为数组
   		Object[] toArray()
  /
public class CollectionDemo {
	public static void main(String[] args) {
		// 测试不带All的方法

		// 创建集合对象
		// Collection c = new Collection(); //错误，因为接口不能实例化
		Collection c = new ArrayList();

		// boolean add(Object obj):添加一个元素
		// System.out.println("add:"+c.add("hello"));
		c.add("hello");
		c.add("world");
		c.add("java");

		// void clear():移除所有元素
		// c.clear();

		// boolean remove(Object o):移除一个元素
		// System.out.println("remove:" + c.remove("hello"));
		// System.out.println("remove:" + c.remove("javaee"));

		// boolean contains(Object o)：判断集合中是否包含指定的元素
		// System.out.println("contains:"+c.contains("hello"));
		// System.out.println("contains:"+c.contains("android"));

		// boolean isEmpty()：判断集合是否为空
		// System.out.println("isEmpty:"+c.isEmpty());

		//int size():元素的个数
		System.out.println("size:"+c.size());
		
		System.out.println("c:" + c);
	}
}
```
  测试带All的方法  

```java
import java.util.ArrayList;
import java.util.Collection;

/ 
   boolean addAll(Collection c):添加一个集合的元素
   boolean removeAll(Collection c):移除一个集合的元素(是一个还是所有)
   boolean containsAll(Collection c)：判断集合中是否包含指定的集合元素(是一个还是所有)
   boolean retainAll(Collection c):两个集合都有的元素?思考元素去哪了，返回的boolean又是什么意思呢?
  /
public class CollectionDemo2 {
	public static void main(String[] args) {
		// 创建集合1
		Collection c1 = new ArrayList();
		c1.add("abc1");
		c1.add("abc2");
		c1.add("abc3");
		c1.add("abc4");

		// 创建集合2
		Collection c2 = new ArrayList();
//		c2.add("abc1");
//		c2.add("abc2");
//		c2.add("abc3");
//		c2.add("abc4");
		c2.add("abc5");
		c2.add("abc6");
		c2.add("abc7");

		// boolean addAll(Collection c):添加一个集合的元素
		// System.out.println("addAll:" + c1.addAll(c2));
		
		//boolean removeAll(Collection c):移除一个集合的元素(是一个还是所有)
		//只要有一个元素被移除了，就返回true。
		//System.out.println("removeAll:"+c1.removeAll(c2));

		//boolean containsAll(Collection c)：判断集合中是否包含指定的集合元素(是一个还是所有)
		//只有包含所有的元素，才叫包含
		// System.out.println("containsAll:"+c1.containsAll(c2));
		
		//boolean retainAll(Collection c):两个集合都有的元素?思考元素去哪了，返回的boolean又是什么意思呢?
		//假设有两个集合A，B。
		//A对B做交集，最终的结果保存在A中，B不变。
		//返回值表示的是A是否发生过改变。
		System.out.println("retainAll:"+c1.retainAll(c2));
		
		System.out.println("c1:" + c1);
		System.out.println("c2:" + c2);
	}
}

```
  集合遍历：转成数组  
```java

import java.util.ArrayList;
import java.util.Collection;

/ 
   集合的遍历。其实就是依次获取集合中的每一个元素。
   
   Object[] toArray():把集合转成数组，可以实现集合的遍历
  /
public class CollectionDemo3 {
	public static void main(String[] args) {
		// 创建集合对象
		Collection c = new ArrayList();

		// 添加元素
		c.add("hello"); // Object obj = "hello"; 向上转型
		c.add("world");
		c.add("java");

		// 遍历
		// Object[] toArray():把集合转成数组，可以实现集合的遍历
		Object[] objs = c.toArray();
		for (int x = 0; x < objs.length; x++) {
			// System.out.println(objs[x]);
			// 我知道元素是字符串，我在获取到元素的的同时，还想知道元素的长度。
			// System.out.println(objs[x] + "---" + objs[x].length());
			// 上面的实现不了，原因是Object中没有length()方法
			// 我们要想使用字符串的方法，就必须把元素还原成字符串
			// 向下转型
			String s = (String) objs[x];
			System.out.println(s + "---" + s.length());
		}
	}
}
```
  集合遍历：迭代器  
```java
package cn.itcast_03;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;

/ 
   Iterator iterator():迭代器，集合的专用遍历方式
   		Object next():获取元素,并移动到下一个位置。
   			NoSuchElementException：没有这样的元素，因为你已经找到最后了。
   		boolean hasNext():如果仍有元素可以迭代，则返回 true。（
  /
public class IteratorDemo {
	public static void main(String[] args) {
		// 创建集合对象
		Collection c = new ArrayList();

		// 创建并添加元素
		// String s = "hello";
		// c.add(s);
		c.add("hello");
		c.add("world");
		c.add("java");

		// Iterator iterator():迭代器，集合的专用遍历方式
		Iterator it = c.iterator(); // 实际返回的肯定是子类对象，这里是多态

		while (it.hasNext()) {
			// System.out.println(it.next());
			String s = (String) it.next();
			System.out.println(s);
		}
	}
}

```

  自定义对象遍历  
```java
//用集合存储5个学生对象，并把学生对象进行遍历。用迭代器遍历。

public class Student {
	// 成员变量
	private String name;
	private int age;

	// 构造方法
	public Student() {
		super();
	}

	public Student(String name, int age) {
		super();
		this.name = name;
		this.age = age;
	}

	// 成员方法
	// getXxx()/setXxx()
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getAge() {
		return age;
	}

	public void setAge(int age) {
		this.age = age;
	}

	@Override
	public String toString() {
		return "Student [name=" + name + ", age=" + age + "]";
	}
	
}
```
```java

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;

public class IteratorTest {
	public static void main(String[] args) {
		// 创建集合对象
		Collection c = new ArrayList();

		// 创建学生对象
		Student s1 = new Student("林青霞", 27);
		Student s2 = new Student("风清扬", 30);
		Student s3 = new Student("令狐冲", 33);
		Student s4 = new Student("武鑫", 25);
		Student s5 = new Student("刘晓曲", 22);

		// 把学生添加到集合中
		c.add(s1);
		c.add(s2);
		c.add(s3);
		c.add(s4);
		c.add(s5);

		// 遍历
		Iterator it = c.iterator();
		while (it.hasNext()) {
			// System.out.println(it.next());
			Student s = (Student) it.next();
			System.out.println(s.getName() + "---" + s.getAge());
		}
		
		// for循环改写
		// for(Iterator it = c.iterator();it.hasNext();){
		// Student s = (Student) it.next();
		// System.out.println(s.getName() + "---" + s.getAge());
		// }
	}
}

```
```
import java.util.ArrayList;
import java.util.Collection;

public class StudentDemo {
	public static void main(String[] args) {
		// 创建集合对象
		Collection c = new ArrayList();

		// 创建学生对象
		Student s1 = new Student("林青霞", 27);
		Student s2 = new Student("风清扬", 30);
		Student s3 = new Student("令狐冲", 33);
		Student s4 = new Student("武鑫", 25);
		Student s5 = new Student("刘晓曲", 22);

		// 把学生添加到集合
		c.add(s1);
		c.add(s2);
		c.add(s3);
		c.add(s4);
		c.add(s5);

		// 把集合转成数组
		Object[] objs = c.toArray();
		// 遍历数组
		for (int x = 0; x < objs.length; x++) {
			// System.out.println(objs[x]);

			Student s = (Student) objs[x];
			System.out.println(s.getName() + "---" + s.getAge());
		}
	}
}

```
#### (2)Iterator接口的使用讲解

![java29](https://s1.ax1x.com/2020/07/06/UCXsj1.png)

#### (3)Iterator接口的源码讲解

```
public interface Inteator {
	boolean hasNext();
	Object next(); 
}

public interface Iterable {
    Iterator iterator();
}

public interface Collection extends Iterable {
	Iterator iterator();
}

public interface List extends Collection {
	Iterator iterator();
}

public class ArrayList implements List {
	public Iterator iterator() {
        return new Itr();
    }
    
    private class Itr implements Iterator {
    	public boolean hasNext() {}
		public Object next(){} 
    }
}


Collection c = new ArrayList();
c.add("hello");
c.add("world");
c.add("java");
Iterator it = c.iterator();	 //new Itr();
while(it.hasNext()) {
	String s = (String)it.next();
	System.out.println(s);
}
```

### 3、List接口


有序的 collection（进来顺序和出去顺序一致）。此接口的用户可以对列表中每个元素的插入位置
进行精确地控制。用户可以根据元素的整数索引（在列表中的位置）访问元素，
并搜索列表中的元素。

与 set 不同，列表通常允许重复的元素。

#### (1)List案例

```java
import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;

/ 
   List集合存储字符串并遍历。
  /
public class ListDemo {
	public static void main(String[] args) {
		// 创建集合对象
		List list = new ArrayList();

		// 创建字符串并添加字符串
		list.add("hello");
		list.add("world");
		list.add("java");

		// 遍历集合
		Iterator it = list.iterator();
		while (it.hasNext()) {
			String s = (String) it.next();
			System.out.println(s);
		}
	}
}

```
```java
package cn.itcast_02;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/ 
   存储自定义对象并遍历
  /
public class ListDemo {
	public static void main(String[] args) {
		// 创建集合对象
		List list = new ArrayList();

		// 创建学生对象
		Student s1 = new Student("白骨精", 30);
		Student s2 = new Student("蜘蛛精", 40);
		Student s3 = new Student("观音姐姐", 22);

		// 把学生对象添加到集合对象中
		list.add(s1);
		list.add(s2);
		list.add(s3);

		// 遍历
		Iterator it = list.iterator();
		while (it.hasNext()) {
			Student s = (Student) it.next();
			System.out.println(s.getName() + "---" + s.getAge());
		}
	}
}
```
#### (2)特有成员方法

```java
package cn.itcast_03;

import java.util.ArrayList;
import java.util.List;

/ 
   List集合的特有功能：
   A:添加功能
   		void add(int index,Object element):在指定位置添加元素
   B:获取功能
   		Object get(int index):获取指定位置的元素
   C:列表迭代器
   		ListIterator listIterator()：List集合特有的迭代器
   D:删除功能
   		Object remove(int index)：根据索引删除元素,返回被删除的元素
   E:修改功能
   		Object set(int index,Object element):根据索引修改元素，返回被修饰的元素
  /
public class ListDemo {
	public static void main(String[] args) {
		// 创建集合对象
		List list = new ArrayList();

		// 添加元素
		list.add("hello");
		list.add("world");
		list.add("java");

		// void add(int index,Object element):在指定位置添加元素
		// list.add(1, "android");//没有问题
		// IndexOutOfBoundsException
		// list.add(11, "javaee");//有问题
		// list.add(3, "javaee"); //没有问题
		// list.add(4, "javaee"); //有问题

		// Object get(int index):获取指定位置的元素
		// System.out.println("get:" + list.get(1));
		// IndexOutOfBoundsException
		// System.out.println("get:" + list.get(11));

		// Object remove(int index)：根据索引删除元素,返回被删除的元素
		// System.out.println("remove:" + list.remove(1));
		// IndexOutOfBoundsException
		// System.out.println("remove:" + list.remove(11));

		// Object set(int index,Object element):根据索引修改元素，返回被修饰的元素
		System.out.println("set:" + list.set(1, "javaee"));

		System.out.println("list:" + list);
	}
}
```
#### (3)遍历

```java
package cn.itcast_03;

import java.util.ArrayList;
import java.util.List;

/ 
   List集合的特有遍历功能：
   		size()和get()方法结合使用
  /
public class ListDemo2 {
	public static void main(String[] args) {
		// 创建集合对象
		List list = new ArrayList();

		// 添加元素
		list.add("hello");
		list.add("world");
		list.add("java");

		for (int x = 0; x < list.size(); x++) {
			String s = (String) list.get(x);
			System.out.println(s);
		}
	}
}

```
```java
package cn.itcast_03;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/ 
   存储自定义对象并遍历,用普通for循环。(size()和get()结合)
  /
public class ListDemo3 {
	public static void main(String[] args) {
		// 创建集合对象
		List list = new ArrayList();

		// 创建学生对象
		Student s1 = new Student("林黛玉", 18);
		Student s2 = new Student("刘姥姥", 88);
		Student s3 = new Student("王熙凤", 38);

		// 把学生添加到集合中
		list.add(s1);
		list.add(s2);
		list.add(s3);

		// 遍历
		// 迭代器遍历
		Iterator it = list.iterator();
		while (it.hasNext()) {
			Student s = (Student) it.next();
			System.out.println(s.getName() + "---" + s.getAge());
		}
		System.out.println("--------");

		// 普通for循环
		for (int x = 0; x < list.size(); x++) {
			Student s = (Student) list.get(x);
			System.out.println(s.getName() + "---" + s.getAge());
		}
	}
}

```

#### (4)列表迭代器ListIterator

ListIterator listIterator()：List集合特有的迭代器

该迭代器继承了Iterator迭代器，所以，就可以直接使用hasNext()和next()方法。
   
特有功能：

	Object previous():获取上一个元素
	boolean hasPrevious():判断是否有元素
   
注意
	
	ListIterator可以实现逆向遍历，但是必须先正向遍历，才能逆向遍历，
	所以一般无意义，不使用。


```java
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;

public class ListIteratorDemo {
	public static void main(String[] args) {
		// 创建List集合对象
		List list = new ArrayList();
		list.add("hello");
		list.add("world");
		list.add("java");

		// ListIterator listIterator()
		ListIterator lit = list.listIterator(); // 子类对象
		// while (lit.hasNext()) {
		// String s = (String) lit.next();
		// System.out.println(s);
		// }
		// System.out.println("-----------------");
		
		// System.out.println(lit.previous());
		// System.out.println(lit.previous());
		// System.out.println(lit.previous());
		// NoSuchElementException
		// System.out.println(lit.previous());

		while (lit.hasPrevious()) {
			String s = (String) lit.previous();
			System.out.println(s);
		}
		System.out.println("-----------------");

		// 迭代器
		Iterator it = list.iterator();
		while (it.hasNext()) {
			String s = (String) it.next();
			System.out.println(s);
		}
		System.out.println("-----------------");

	}
}
```

** ConcurrentModificationException **

```java
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;

/*
 * 问题?
 * 		我有一个集合，如下，请问，我想判断里面有没有"world"这个元素，
 *      如果有，我就添加一个"javaee"元素，请写代码实现。
 * 
 * ConcurrentModificationException:
 *       当方法检测到对象的并发修改，但不允许这种修改时，抛出此异常。 
 * 产生的原因：
 * 		迭代器是依赖于集合而存在的，在判断成功后，集合的中新添加了元素，
 *      而迭代器却不知道，所以就报错了，这个错叫并发修改异常。
 * 		其实这个问题描述的是：迭代器遍历元素的时候，通过集合是不能修改元素的。
 * 如何解决呢?
 * 		A:迭代器迭代元素，迭代器修改元素
 * 			元素是跟在刚才迭代的元素后面的。
 * 		B:集合遍历元素，集合修改元素(普通for)
 * 			元素在最后添加的。
 */
public class ListIteratorDemo2 {
	public static void main(String[] args) {
		// 创建List集合对象
		List list = new ArrayList();
		// 添加元素
		list.add("hello");
		list.add("world");
		list.add("java");

		// 迭代器遍历
		// Iterator it = list.iterator();
		// while (it.hasNext()) {
		// String s = (String) it.next();
		// if ("world".equals(s)) {
		// list.add("javaee");
		// }
		// }

		// 方式1：迭代器迭代元素，迭代器修改元素
		// 而Iterator迭代器却没有添加功能，所以我们使用其子接口ListIterator
		// ListIterator lit = list.listIterator();
		// while (lit.hasNext()) {
		// String s = (String) lit.next();
		// if ("world".equals(s)) {
		// lit.add("javaee");
		// }
		// }

		// 方式2：集合遍历元素，集合修改元素(普通for)
		for (int x = 0; x < list.size(); x++) {
			String s = (String) list.get(x);
			if ("world".equals(s)) {
				list.add("javaee");
			}
		}

		System.out.println("list:" + list);
	}
}
```
#### (5)数据结构

![java31](https://s1.ax1x.com/2020/07/06/UPPf4x.png)

![java32](https://s1.ax1x.com/2020/07/06/UPPWU1.png)

#### (6)List子类面试题

	ArrayList:
		底层数据结构是数组，查询快，增删慢。
		线程不安全，效率高。
	Vector:
		底层数据结构是数组，查询快，增删慢。
		线程安全，效率低。
	LinkedList:
		底层数据结构是链表，查询慢，增删快。
		线程不安全，效率高。
		
	List有三个儿子，我们到底使用谁呢?
		看需求(情况)。
		
	要安全吗?
		要：Vector(即使要安全，也不用这个了，后面有替代的)
		不要：ArrayList或者LinkedList
			查询多：ArrayList
			增删多：LinkedList
			

### 4、ArrayList类

底层数据结构是数组，查询快，增删慢，线程不安全，效率高


**存储字符串并遍历**

```java
package cn.itcast_01;

import java.util.ArrayList;
import java.util.Iterator;

public class ArrayListDemo {
	public static void main(String[] args) {
		// 创建集合对象
		ArrayList array = new ArrayList();

		// 创建元素对象，并添加元素
		array.add("hello");
		array.add("world");
		array.add("java");

		// 遍历
		Iterator it = array.iterator();
		while (it.hasNext()) {
			String s = (String) it.next();
			System.out.println(s);
		}

		System.out.println("-----------");

		for (int x = 0; x < array.size(); x++) {
			String s = (String) array.get(x);
			System.out.println(s);
		}
	}
}
```
**存储自定义对象并遍历**
```java
public class ArrayListDemo2 {
	public static void main(String[] args) {
		// 创建集合对象
		ArrayList array = new ArrayList();

		// 创建学生对象
		Student s1 = new Student("武松", 30);
		Student s2 = new Student("鲁智深", 40);
		Student s3 = new Student("林冲", 36);
		Student s4 = new Student("杨志", 38);

		// 添加元素
		array.add(s1);
		array.add(s2);
		array.add(s3);
		array.add(s4);

		// 遍历
		Iterator it = array.iterator();
		while (it.hasNext()) {
			Student s = (Student) it.next();
			System.out.println(s.getName() + "---" + s.getAge());
		}

		System.out.println("----------------");

		for (int x = 0; x < array.size(); x++) {
			// ClassCastException 注意，千万要搞清楚类型
			// String s = (String) array.get(x);
			// System.out.println(s);

			Student s = (Student) array.get(x);
			System.out.println(s.getName() + "---" + s.getAge());
		}
	}
}
```

### 5、Vector类

底层数据结构是数组，查询快，增删慢，线程安全，效率低


```java
package cn.itcast_02;

import java.util.Enumeration;
import java.util.Vector;

/*
 * Vector的特有功能：
 * 1：添加功能
 * 		public void addElement(Object obj)		--	add()
 * 2：获取功能
 * 		public Object elementAt(int index)		--  get()
 * 		public Enumeration elements()			--	Iterator iterator()
 * 				boolean hasMoreElements()				hasNext()
 * 				Object nextElement()					next()
 * 
 * JDK升级的原因：
 * 		A:安全
 * 		B:效率
 * 		C:简化书写
 */
public class VectorDemo {
	public static void main(String[] args) {
		// 创建集合对象
		Vector v = new Vector();

		// 添加功能
		v.addElement("hello");
		v.addElement("world");
		v.addElement("java");

		// 遍历
		for (int x = 0; x < v.size(); x++) {
			String s = (String) v.elementAt(x);
			System.out.println(s);
		}

		System.out.println("------------------");

		Enumeration en = v.elements(); // 返回的是实现类的对象
		while (en.hasMoreElements()) {
			String s = (String) en.nextElement();
			System.out.println(s);
		}
	}
}

```

**ArrayList去除集合中字符串的重复值(字符串的内容相同)**

```java
package cn.itcast_04;

import java.util.ArrayList;
import java.util.Iterator;

/*
 * 分析：
 * 		A:创建集合对象
 * 		B:添加多个字符串元素(包含内容相同的)
 * 		C:创建新集合
 * 		D:遍历旧集合,获取得到每一个元素
 * 		E:拿这个元素到新集合去找，看有没有
 * 			有：不搭理它
 * 			没有：就添加到新集合
 * 		F:遍历新集合
 */
public class ArrayListDemo {
	public static void main(String[] args) {
		// 创建集合对象
		ArrayList array = new ArrayList();

		// 添加多个字符串元素(包含内容相同的)
		array.add("hello");
		array.add("world");
		array.add("java");
		array.add("world");
		array.add("java");
		array.add("world");
		array.add("world");
		array.add("world");
		array.add("world");
		array.add("java");
		array.add("world");

		// 创建新集合
		ArrayList newArray = new ArrayList();

		// 遍历旧集合,获取得到每一个元素
		Iterator it = array.iterator();
		while (it.hasNext()) {
			String s = (String) it.next();

			// 拿这个元素到新集合去找，看有没有
			if (!newArray.contains(s)) {
				newArray.add(s);
			}
		}

		// 遍历新集合
		for (int x = 0; x < newArray.size(); x++) {
			String s = (String) newArray.get(x);
			System.out.println(s);
		}
	}
}
```

```java
package cn.itcast_04;

import java.util.ArrayList;
import java.util.Iterator;

/*
 * 要求：不能创建新的集合，就在以前的集合上做。
 */
public class ArrayListDemo2 {
	public static void main(String[] args) {
		// 创建集合对象
		ArrayList array = new ArrayList();

		// 添加多个字符串元素(包含内容相同的)
		array.add("hello");
		array.add("world");
		array.add("java");
		array.add("world");
		array.add("java");
		array.add("world");
		array.add("world");
		array.add("world");
		array.add("world");
		array.add("java");
		array.add("world");

		// 由选择排序思想引入，我们就可以通过这种思想做这个题目
		// 拿0索引的依次和后面的比较，有就把后的干掉
		// 同理，拿1索引...
		for (int x = 0; x < array.size() - 1; x++) {
			for (int y = x + 1; y < array.size(); y++) {
				if (array.get(x).equals(array.get(y))) {
					array.remove(y);
					y--;
				}
			}
		}

		// 遍历集合
		Iterator it = array.iterator();
		while (it.hasNext()) {
			String s = (String) it.next();
			System.out.println(s);
		}
	}
}

```

**去除集合中自定义对象的重复值(对象的成员变量值都相同)**

```java
import java.util.ArrayList;
import java.util.Iterator;

/*
 * 
 * 我们按照和字符串一样的操作，发现出问题了。
 * 为什么呢?
 * 		我们必须思考哪里会出问题?
 * 		通过简单的分析，我们知道问题出现在了判断上。
 * 		而这个判断功能是集合自己提供的，所以我们如果想很清楚的知道它是如何判断的，就应该去看源码。
 * contains()方法的底层依赖的是equals()方法。
 * 而我们的学生类中没有equals()方法，这个时候，默认使用的是它父亲Object的equals()方法
 * Object()的equals()默认比较的是地址值，所以，它们进去了。因为new的东西，地址值都不同。
 * 按照我们自己的需求，比较成员变量的值，重写equals()即可。
 * 自动生成即可。
 */
public class ArrayListDemo3 {
	public static void main(String[] args) {
		// 创建集合对象
		ArrayList array = new ArrayList();

		// 创建学生对象
		Student s1 = new Student("林青霞", 27);
		Student s2 = new Student("林志玲", 40);
		Student s3 = new Student("凤姐", 35);
		Student s4 = new Student("芙蓉姐姐", 18);
		Student s5 = new Student("翠花", 16);
		Student s6 = new Student("林青霞", 27);
		Student s7 = new Student("林青霞", 18);

		// 添加元素
		array.add(s1);
		array.add(s2);
		array.add(s3);
		array.add(s4);
		array.add(s5);
		array.add(s6);
		array.add(s7);

		// 创建新集合
		ArrayList newArray = new ArrayList();

		// 遍历旧集合,获取得到每一个元素
		Iterator it = array.iterator();
		while (it.hasNext()) {
			Student s = (Student) it.next();

			// 拿这个元素到新集合去找，看有没有
			if (!newArray.contains(s)) {
				newArray.add(s);
			}
		}

		// 遍历新集合
		for (int x = 0; x < newArray.size(); x++) {
			Student s = (Student) newArray.get(x);
			System.out.println(s.getName() + "---" + s.getAge());
		}
	}
}
```
```java
package cn.itcast_04;

public class Student {
	private String name;
	private int age;

	public Student() {
		super();
	}

	public Student(String name, int age) {
		super();
		this.name = name;
		this.age = age;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getAge() {
		return age;
	}

	public void setAge(int age) {
		this.age = age;
	}

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

}

```

### 6、LinkedList类概述

底层数据结构是链表，查询慢，增删快，线程不安全，效率高

LinkedList类特有功能

	public void addFirst(E e)及addLast(E e)
	public E getFirst()及getLast()
	public E removeFirst()及public E removeLast()

#### (1)用LinkedList模拟栈数据结构的集合，并测试

```java

import java.util.LinkedList;

/**
 * 自定义的栈集合
 * 
 * @author 风清扬
 * @version V1.0
 */
public class MyStack {
	private LinkedList link;

	public MyStack() {
		link = new LinkedList();
	}

	public void add(Object obj) {
		link.addFirst(obj);
	}

	public Object get() {
		// return link.getFirst();
		return link.removeFirst();
	}

	public boolean isEmpty() {
		return link.isEmpty();
	}
}
```
```java
public class MyStackDemo {
	public static void main(String[] args) {
		// 创建集合对象
		MyStack ms = new MyStack();

		// 添加元素
		ms.add("hello");
		ms.add("world");
		ms.add("java");
		
		while(!ms.isEmpty()){
			System.out.println(ms.get());
		}
	}
}

```

## 二、泛型

```java
import java.util.ArrayList;
import java.util.Iterator;

/*
 * ArrayList存储字符串并遍历
 * 
 * 我们按照正常的写法来写这个程序， 结果确出错了。
 * 为什么呢?
 * 		因为我们开始存储的时候，存储了String和Integer两种类型的数据。
 * 		而在遍历的时候，我们把它们都当作String类型处理的，做了转换，所以就报错了。
 * 但是呢，它在编译期间却没有告诉我们。
 * 所以，我就觉得这个设计的不好。
 * 回想一下，我们的数组
 * 		String[] strArray = new String[3];
 * 		strArray[0] = "hello";
 * 		strArray[1] = "world";
 * 		strArray[2] = 10;
 * 集合也模仿着数组的这种做法，在创建对象的时候明确元素的数据类型。这样就不会在有问题了。
 * 而这种技术被称为：泛型。
 * 
 * 泛型：是一种把类型明确的工作推迟到创建对象或者调用方法的时候才去明确的特殊的类型。参数化类型，把类型当作参数一样的传递。
 * 格式：
 * 		<数据类型>
 * 		此处的数据类型只能是引用类型。
 * 好处：
 * 		A:把运行时期的问题提前到了编译期间
 * 		B:避免了强制类型转换
 * 		C:优化了程序设计，解决了黄色警告线
 */
public class GenericDemo {
	public static void main(String[] args) {
		// 创建
		ArrayList<String> array = new ArrayList<String>();

		// 添加元素
		array.add("hello");
		array.add("world");
		array.add("java");
		// array.add(new Integer(100));
		//array.add(10); // JDK5以后的自动装箱
		// 等价于：array.add(Integer.valueOf(10));

		// 遍历
		Iterator<String> it = array.iterator();
		while (it.hasNext()) {
			// ClassCastException
			// String s = (String) it.next();
			String s = it.next();
			System.out.println(s);
		}

		// 看下面这个代码
		// String[] strArray = new String[3];
		// strArray[0] = "hello";
		// strArray[1] = "world";
		// strArray[2] = 10;
	}
}
```

### 1、重写ArrayList遍历

```java
import java.util.ArrayList;
import java.util.Iterator;

public class ArrayListDemo {
	public static void main(String[] args) {
		// 用ArrayList存储字符串元素，并遍历。用泛型改进代码
		ArrayList<String> array = new ArrayList<String>();

		array.add("hello");
		array.add("world");
		array.add("java");

		Iterator<String> it = array.iterator();
		while (it.hasNext()) {
			String s = it.next();
			System.out.println(s);
		}
		System.out.println("-----------------");

		for (int x = 0; x < array.size(); x++) {
			String s = array.get(x);
			System.out.println(s);
		}
	}
}

```

```java
import java.util.ArrayList;
import java.util.Iterator;

/*
 * 需求：存储自定义对象并遍历。
 * 
 * A:创建学生类
 * B:创建集合对象
 * C:创建元素对象
 * D:把元素添加到集合
 * E:遍历集合
 */
public class ArrayListDemo2 {
	public static void main(String[] args) {
		// 创建集合对象
		// JDK7的新特性：泛型推断。
		// ArrayList<Student> array = new ArrayList<>();
		// 但是我不建议这样使用。
		ArrayList<Student> array = new ArrayList<Student>();

		// 创建元素对象
		Student s1 = new Student("曹操", 40); // 后知后觉
		Student s2 = new Student("蒋干", 30); // 不知不觉
		Student s3 = new Student("诸葛亮", 26);// 先知先觉

		// 添加元素
		array.add(s1);
		array.add(s2);
		array.add(s3);

		// 遍历
		Iterator<Student> it = array.iterator();
		while (it.hasNext()) {
			Student s = it.next();
			System.out.println(s.getName() + "---" + s.getAge());
		}
		System.out.println("------------------");

		for (int x = 0; x < array.size(); x++) {
			Student s = array.get(x);
			System.out.println(s.getName() + "---" + s.getAge());
		}
	}
}

```

### 2、泛型引入

```java
public class ObjectTool {
	private Object obj;

	public Object getObj() {
		return obj;
	}

	public void setObj(Object obj) { // Object obj = new Integer(30);
		this.obj = obj;
	}
}

```
```java
package cn.itcast_03;

/*
 * 早期的时候，我们使用Object来代表任意的类型。
 * 向上转型是没有任何问题的，但是在向下转型的时候其实隐含了类型转换的问题。
 * 也就是说这样的程序其实并不是安全的。所以Java在JDK5后引入了泛型，提高程序的安全性。
 */
public class ObjectToolDemo {
	public static void main(String[] args) {
		ObjectTool ot = new ObjectTool();

		// 正常使用
		ot.setObj(new Integer(27));
		Integer i = (Integer) ot.getObj();
		System.out.println("年龄是：" + i);

		ot.setObj(new String("林青霞"));
		String s = (String) ot.getObj();
		System.out.println("姓名是：" + s);

		System.out.println("---------");
		ot.setObj(new Integer(30));
		// ClassCastException
		String ss = (String) ot.getObj();
		System.out.println("姓名是：" + ss);
	}
}

```

### 3、泛型类

把泛型定义在类上

格式:public class 类名<泛型类型1,…>

注意:泛型类型必须是引用类型

```java
/*
 * 泛型类：把泛型定义在类上
 */
public class ObjectTool<T> {
	private T obj;

	public T getObj() {
		return obj;
	}

	public void setObj(T obj) {
		this.obj = obj;
	}
}
```

```java
package cn.itcast_04;

/*
 * 泛型类的测试
 */
public class ObjectToolDemo {
	public static void main(String[] args) {

		ObjectTool<String> ot = new ObjectTool<String>();
		// ot.setObj(new Integer(27)); //这个时候编译期间就过不去
		ot.setObj(new String("林青霞"));
		String s = ot.getObj();
		System.out.println("姓名是：" + s);

		ObjectTool<Integer> ot2 = new ObjectTool<Integer>();
		// ot2.setObj(new String("风清扬"));//这个时候编译期间就过不去
		ot2.setObj(new Integer(27));
		Integer i = ot2.getObj();
		System.out.println("年龄是：" + i);
	}
}

```
### 4、泛型方法

把泛型定义在方法上

格式:public <泛型类型> 返回类型 方法名(泛型类型 .)

```java
public class ObjectTool {
	public <T> void show(T t) {
		System.out.println(t);
	}
}
```

```java
public class ObjectToolDemo {
	public static void main(String[] args) {

		// 定义泛型方法后
		ObjectTool ot = new ObjectTool();
		ot.show("hello");
		ot.show(100);
		ot.show(true);
	}
}

```
### 5、泛型接口

把泛型定义在接口上

格式:public  interface 接口名<泛型类型1…>

```java
/*
 * 泛型接口：把泛型定义在接口上
 */
public interface Inter<T> {
	public abstract void show(T t);
}
```

```java
//实现类在实现接口的时候
//第一种情况：已经知道该是什么类型的了

//public class InterImpl implements Inter<String> {
//
//	@Override
//	public void show(String t) {
//		System.out.println(t);
//	}
// }

//第二种情况：还不知道是什么类型的
public class InterImpl<T> implements Inter<T> {

	@Override
	public void show(T t) {
		System.out.println(t);
	}
}
```

```java
public class InterDemo {
	public static void main(String[] args) {
		// 第一种情况的测试
		// Inter<String> i = new InterImpl();
		// i.show("hello");

		// // 第二种情况的测试
		Inter<String> i = new InterImpl<String>();
		i.show("hello");

		Inter<Integer> ii = new InterImpl<Integer>();
		ii.show(100);
	}
}
```

### 6、泛型通配符<?>

任意类型，如果没有明确，那么就是Object以及任意的Java类了

	? extends E
	向下限定，E及其子类
	
	? super E
	向上限定，E及其父类

```java
package cn.itcast_07;

import java.util.ArrayList;
import java.util.Collection;

/*
 * 泛型高级(通配符)
 * ?: 任意类型，如果没有明确，那么就是Object以及任意的Java类了
 * ? extends E: 向下限定，E及其子类
 * ? super E: 向上限定，E极其父类
 */
public class GenericDemo {
	public static void main(String[] args) {
		// 泛型如果明确的写的时候，前后必须一致
		Collection<Object> c1 = new ArrayList<Object>();
		// Collection<Object> c2 = new ArrayList<Animal>();
		// Collection<Object> c3 = new ArrayList<Dog>();
		// Collection<Object> c4 = new ArrayList<Cat>();

		// ?表示任意的类型都是可以的
		Collection<?> c5 = new ArrayList<Object>();
		Collection<?> c6 = new ArrayList<Animal>();
		Collection<?> c7 = new ArrayList<Dog>();
		Collection<?> c8 = new ArrayList<Cat>();

		// ? extends E:向下限定，E及其子类
		// Collection<? extends Animal> c9 = new ArrayList<Object>();
		Collection<? extends Animal> c10 = new ArrayList<Animal>();
		Collection<? extends Animal> c11 = new ArrayList<Dog>();
		Collection<? extends Animal> c12 = new ArrayList<Cat>();

		// ? super E:向上限定，E极其父类
		Collection<? super Animal> c13 = new ArrayList<Object>();
		Collection<? super Animal> c14 = new ArrayList<Animal>();
		// Collection<? super Animal> c15 = new ArrayList<Dog>();
		// Collection<? super Animal> c16 = new ArrayList<Cat>();
	}
}

class Animal {
}

class Dog extends Animal {
}

class Cat extends Animal {
}
```

### 7、增强for

JDK5的新特性：自动拆装箱,泛型,增强for,静态导入,可变参数,枚举

简化数组和Collection集合的遍历

格式：

	for(元素数据类型 变量 : 数组或者Collection集合) {
		使用变量即可，该变量就是元素
		}
	
好处：简化遍历

注意事项：增强for的目标要判断是否为null
把前面的集合代码的遍历用增强for改进
```java
package cn.itcast_01;

import java.util.ArrayList;
import java.util.List;
public class ForDemo {
	public static void main(String[] args) {
		// 定义一个int数组
		int[] arr = { 1, 2, 3, 4, 5 };
		for (int x = 0; x < arr.length; x++) {
			System.out.println(arr[x]);
		}
		System.out.println("---------------");
		// 增强for
		for (int x : arr) {
			System.out.println(x);
		}
		System.out.println("---------------");
		// 定义一个字符串数组
		String[] strArray = { "林青霞", "风清扬", "东方不败", "刘意" };
		// 增强for
		for (String s : strArray) {
			System.out.println(s);
		}
		System.out.println("---------------");
		// 定义一个集合
		ArrayList<String> array = new ArrayList<String>();
		array.add("hello");
		array.add("world");
		array.add("java");
		// 增强for
		for (String s : array) {
			System.out.println(s);
		}
		System.out.println("---------------");

		List<String> list = null;
		// NullPointerException
		// 这个s是我们从list里面获取出来的，在获取前，它肯定还好做一个判断
		// 说白了，这就是迭代器的功能
		if (list != null) {
			for (String s : list) {
				System.out.println(s);
			}
		}

		// 增强for其实是用来替代迭代器的
		//ConcurrentModificationException
		// for (String s : array) {
		// if ("world".equals(s)) {
		// array.add("javaee"); 
		// }
		// }
		// System.out.println("array:" + array);
	}
}
```
#### 增强for遍历ArrayList

```java
import java.util.ArrayList;
import java.util.Iterator;

/*
 * ArrayList存储字符串并遍历。要求加入泛型，并用增强for遍历。
 * A:迭代器
 * B:普通for
 * C:增强for
 */
public class ArrayListDemo {
	public static void main(String[] args) {
		// 创建集合对象
		ArrayList<String> array = new ArrayList<String>();

		// 创建并添加元素
		array.add("hello");
		array.add("world");
		array.add("java");

		// 遍历集合
		// 迭代器
		Iterator<String> it = array.iterator();
		while (it.hasNext()) {
			String s = it.next();
			System.out.println(s);
		}
		System.out.println("------------------");

		// 普通for
		for (int x = 0; x < array.size(); x++) {
			String s = array.get(x);
			System.out.println(s);
		}
		System.out.println("------------------");

		// 增强for
		for (String s : array) {
			System.out.println(s);
		}
	}
}

```

```java
import java.util.ArrayList;
import java.util.Iterator;

/*
 * 需求：ArrayList存储自定义对象并遍历。要求加入泛型，并用增强for遍历。
 * A:迭代器
 * B:普通for
 * C:增强for
 *  * 
 * 增强for是用来替迭代器。
 */
public class ArrayListDemo2 {
	public static void main(String[] args) {
		// 创建集合对象
		ArrayList<Student> array = new ArrayList<Student>();

		// 创建学生对象
		Student s1 = new Student("林青霞", 27);
		Student s2 = new Student("貂蝉", 22);
		Student s3 = new Student("杨玉环", 24);
		Student s4 = new Student("西施", 21);
		Student s5 = new Student("王昭君", 23);

		// 把学生对象添加到集合中
		array.add(s1);
		array.add(s2);
		array.add(s3);
		array.add(s4);
		array.add(s5);

		// 迭代器
		Iterator<Student> it = array.iterator();
		while (it.hasNext()) {
			Student s = it.next();
			System.out.println(s.getName() + "---" + s.getAge());
		}
		System.out.println("---------------");

		// 普通for
		for (int x = 0; x < array.size(); x++) {
			Student s = array.get(x);
			System.out.println(s.getName() + "---" + s.getAge());
		}
		System.out.println("---------------");

		// 增强for
		for (Student s : array) {
			System.out.println(s.getName() + "---" + s.getAge());
		}
	}
}
```

### 7、静态导入

格式：

	import static 包名….类名.方法名;

可以直接导入到方法的级别

注意事项

	方法必须是静态的
	如果有多个同名的静态方法，容易不知道使用谁?这个时候要使用，必须加前缀。由此可见，意义不大，所以一般不用，但是要能看懂。

```java
import static java.lang.Math.abs;
import static java.lang.Math.pow;
import static java.lang.Math.max;

//错误
//import static java.util.ArrayList.add;

public class StaticImportDemo {
	public static void main(String[] args) {

//		System.out.println(abs(-100));
		System.out.println(java.lang.Math.abs(-100));
		System.out.println(pow(2, 3));
		System.out.println(max(20, 30));
	}
	
	public static void abs(String s){
		System.out.println(s);
	}
}

```

### 7、可变参数

定义方法的时候不知道该定义多少个参数

格式

	修饰符 返回值类型 方法名(数据类型…  变量名){}

注意：

	这里的变量其实是一个数组
	如果一个方法有可变参数，并且有多个参数，那么，可变参数肯定是最后一个

```java
public class ArgsDemo {
	public static void main(String[] args) {

		result = sum(a, b, c, d, 40);
		System.out.println("result:" + result);

		result = sum(a, b, c, d, 40, 50);
		System.out.println("result:" + result);
	}

	public static int sum(int... a) {   //int... a  其实是数组

		int s = 0;
		for(int x : a){
			s +=x;
		}
		
		return s;
	}

}
```

Arrays工具类中的asList方法

```java
import java.util.Arrays;
import java.util.List;

/*
 * public static <T> List<T> asList(T... a):把数组转成集合
 * 
 * 注意事项：
 * 		虽然可以把数组转成集合，但是集合的长度不能改变。
 */
public class ArraysDemo {
	public static void main(String[] args) {
		// 定义一个数组
		// String[] strArray = { "hello", "world", "java" };
		// List<String> list = Arrays.asList(strArray);

		List<String> list = Arrays.asList("hello", "world", "java");
		// UnsupportedOperationException
		// list.add("javaee");
		// UnsupportedOperationException
		// list.remove(1);
		list.set(1, "javaee");

		for (String s : list) {
			System.out.println(s);
		}
	}
}

```

## 三、集合的嵌套遍历

```java
import java.util.ArrayList;

/*
 * 集合的嵌套遍历
 * 需求：
 * 		我们班有学生，每一个学生是不是一个对象。所以我们可以使用一个集合表示我们班级的学生。ArrayList<Student>
 * 		但是呢，我们旁边是不是还有班级，每个班级是不是也是一个ArrayList<Student>。
 * 		而我现在有多个ArrayList<Student>。也要用集合存储，怎么办呢?
 * 		就是这个样子的：ArrayList<ArrayList<Student>>
 */
public class ArrayListDemo {
	public static void main(String[] args) {
		// 创建大集合
		ArrayList<ArrayList<Student>> bigArrayList = new ArrayList<ArrayList<Student>>();

		// 创建第一个班级的学生集合
		ArrayList<Student> firstArrayList = new ArrayList<Student>();
		// 创建学生
		Student s1 = new Student("唐僧", 30);
		Student s2 = new Student("孙悟空", 29);
		Student s3 = new Student("猪八戒", 28);
		Student s4 = new Student("沙僧", 27);
		Student s5 = new Student("白龙马", 26);
		// 学生进班
		firstArrayList.add(s1);
		firstArrayList.add(s2);
		firstArrayList.add(s3);
		firstArrayList.add(s4);
		firstArrayList.add(s5);
		// 把第一个班级存储到学生系统中
		bigArrayList.add(firstArrayList);

		// 创建第二个班级的学生集合
		ArrayList<Student> secondArrayList = new ArrayList<Student>();
		// 创建学生
		Student s11 = new Student("诸葛亮", 30);
		Student s22 = new Student("司马懿", 28);
		Student s33 = new Student("周瑜", 26);
		// 学生进班
		secondArrayList.add(s11);
		secondArrayList.add(s22);
		secondArrayList.add(s33);
		// 把第二个班级存储到学生系统中
		bigArrayList.add(secondArrayList);

		// 创建第三个班级的学生集合
		ArrayList<Student> thirdArrayList = new ArrayList<Student>();
		// 创建学生
		Student s111 = new Student("宋江", 40);
		Student s222 = new Student("吴用", 35);
		Student s333 = new Student("高俅", 30);
		Student s444 = new Student("李师师", 22);
		// 学生进班
		thirdArrayList.add(s111);
		thirdArrayList.add(s222);
		thirdArrayList.add(s333);
		thirdArrayList.add(s444);
		// 把第三个班级存储到学生系统中
		bigArrayList.add(thirdArrayList);

		// 遍历集合
		for (ArrayList<Student> array : bigArrayList) {
			for (Student s : array) {
				System.out.println(s.getName() + "---" + s.getAge());
			}
		}
	}
}

```