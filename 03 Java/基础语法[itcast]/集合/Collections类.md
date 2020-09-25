# Collections类 

	public class Collections
	extends Object

针对集合进行操作的工具类，都是静态方法。

面试题：

	Collection和Collections的区别:
	
		Collection:是单列集合的顶层接口，有子接口List和Set。
		Collections:是针对集合操作的工具类，有对集合进行排序和二分查找的方法。

### 1、Collections成员方法

```java

import java.util.Collections;
import java.util.List;
import java.util.ArrayList;

/*
 * 
 * 要知道的方法
 * public static <T> void sort(List<T> list)：排序 默认情况下是自然顺序。
 * public static <T> int binarySearch(List<?> list,T key):二分查找
 * public static <T> T max(Collection<?> coll):最大值
 * public static void reverse(List<?> list):反转
 * public static void shuffle(List<?> list):随机置换
 */
public class CollectionsDemo {
	public static void main(String[] args) {
		// 创建集合对象
		List<Integer> list = new ArrayList<Integer>();

		// 添加元素
		list.add(30);
		list.add(20);
		list.add(50);
		list.add(10);
		list.add(40);

		System.out.println("list:" + list);

		// public static <T> void sort(List<T> list)：排序 默认情况下是自然顺序。
		// Collections.sort(list);
		// System.out.println("list:" + list);
		// [10, 20, 30, 40, 50]

		// public static <T> int binarySearch(List<?> list,T key):二分查找
		// System.out
		// .println("binarySearch:" + Collections.binarySearch(list, 30));
		// System.out.println("binarySearch:"
		// + Collections.binarySearch(list, 300));

		// public static <T> T max(Collection<?> coll):最大值
		// System.out.println("max:"+Collections.max(list));

		// public static void reverse(List<?> list):反转
		// Collections.reverse(list);
		// System.out.println("list:" + list);
		
		//public static void shuffle(List<?> list):随机置换
		Collections.shuffle(list);
		System.out.println("list:" + list);
	}
}

```

### 2、Collections排序

```java
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/*
 * Collections可以针对ArrayList存储基本包装类的元素排序，存储自定义对象可不可以排序呢?
 */
public class CollectionsDemo {
	public static void main(String[] args) {
		// 创建集合对象
		List<Student> list = new ArrayList<Student>();

		// 创建学生对象
		Student s1 = new Student("林青霞", 27);
		Student s2 = new Student("风清扬", 30);
		Student s3 = new Student("刘晓曲", 28);
		Student s4 = new Student("武鑫", 29);
		Student s5 = new Student("林青霞", 27);

		// 添加元素对象
		list.add(s1);
		list.add(s2);
		list.add(s3);
		list.add(s4);
		list.add(s5);

		// 排序
		// 自然排序
		// Collections.sort(list);
		// 比较器排序
		// 如果同时有自然排序和比较器排序，以比较器排序为主
		Collections.sort(list, new Comparator<Student>() {
			@Override
			public int compare(Student s1, Student s2) {
				int num = s2.getAge() - s1.getAge();
				int num2 = num == 0 ? s1.getName().compareTo(s2.getName())
						: num;
				return num2;
			}
		});

		// 遍历集合
		for (Student s : list) {
			System.out.println(s.getName() + "---" + s.getAge());
		}
	}
}

package cn.itcast_02;

/**
 * @author Administrator
 * 
 */
public class Student implements Comparable<Student> {
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
	public int compareTo(Student s) {
		int num = this.age - s.age;
		int num2 = num == 0 ? this.name.compareTo(s.name) : num;
		return num2;
	}
}

```