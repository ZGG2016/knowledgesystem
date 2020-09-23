# 增强for、静态导入、可变参数

[TOC]

## 1、增强for

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
### 1.1、增强for遍历ArrayList

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

## 2、静态导入

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

## 3、可变参数

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