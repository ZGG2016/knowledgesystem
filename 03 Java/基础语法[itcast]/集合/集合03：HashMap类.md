# 集合08：HashMap类

[TOC]

	public class HashMap<K,V>
	extends AbstractMap<K,V>
	implements Map<K,V>, Cloneable, Serializable

**基于哈希表的 Map 接口的实现。**

此实现提供所有可选的映射操作，并**允许使用 null 值和 null 键**。（除了非同步和允许使用 null 之外，HashMap 类与 Hashtable 大致相同。）此类**不保证映射的顺序**，特别是它不保证该顺序恒久不变。 

此实现假定哈希函数将元素适当地分布在各桶之间，可为基本操作（get 和 put）提供稳定的性能。迭代 collection 视图所需的时间与 HashMap 实例的“容量”（桶的数量）及其大小（键-值映射关系数）成比例。所以，如果迭代性能很重要，则不要将初始容量设置得太高（或将加载因子设置得太低）。 

HashMap 的实例有两个参数影响其性能：初始容量和加载因子。**容量 是哈希表中桶的数量**，初始容量只是哈希表在创建时的容量。**加载因子 是哈希表在其容量自动增加之前可以达到多满的一种尺度**。当哈希表中的条目数超出了加载因子与当前容量的乘积时，则要对该哈希表进行 rehash 操作（即重建内部数据结构），从而哈希表将具有大约两倍的桶数。 

通常，默认加载因子 (.75) 在时间和空间成本上寻求一种折衷。**加载因子过高虽然减少了空间开销，但同时也增加了查询成本**（在大多数 HashMap 类的操作中，包括 get 和 put 操作，都反映了这一点）。在设置初始容量时应该考虑到映射中所需的条目数及其加载因子，以便最大限度地减少 rehash 操作次数。如果初始容量大于最大条目数除以加载因子，则不会发生 rehash 操作。 

如果很多映射关系要存储在 HashMap 实例中，则相对于按需执行自动的 rehash 操作以增大表的容量来说，使用足够大的初始容量创建它将使得映射关系能更有效地存储。 

注意，此实现**不是同步的**。如果多个线程同时访问一个哈希映射，而其中至少一个线程从结构上修改了该映射，则它必须 保持外部同步。（结构上的修改是指添加或删除一个或多个映射关系的任何操作；仅改变与实例已经包含的键关联的值不是结构上的修改。）这一般通过对自然封装该映射的对象进行同步操作来完成。如果不存在这样的对象，则**应该使用 Collections.synchronizedMap 方法**来“包装”该映射。最好在创建时完成这一操作，以防止对映射进行意外的非同步访问，如下所示：

	Map m = Collections.synchronizedMap(new HashMap(...));

由所有此类的“collection 视图方法”所返回的迭代器都是快速失败 的：在迭代器创建之后，如果从结构上对映射进行修改，除非通过迭代器本身的 remove 方法，其他任何时间任何方式的修改，迭代器都将抛出 ConcurrentModificationException。因此，面对并发的修改，迭代器很快就会完全失败，而不冒在将来不确定的时间发生任意不确定行为的风险。 

注意，迭代器的快速失败行为不能得到保证，一般来说，存在非同步的并发修改时，不可能作出任何坚决的保证。快速失败迭代器尽最大努力抛出 ConcurrentModificationException。因此，编写依赖于此异常的程序的做法是错误的，正确做法是：迭代器的快速失败行为应该仅用于检测程序错误。

## 1、构造方法

```java
/*
* HashMap:构造方法
* */
public class HashMapDemo01 {
    public static void main(String[] args) {
        // 1.构造方法

        //构造一个具有默认初始容量 (16) 和默认加载因子 (0.75) 的空 HashMap。
        HashMap<Integer, String> hm = new HashMap<Integer, String>();
        //构造一个带指定初始容量和默认加载因子 (0.75) 的空 HashMap。
        HashMap<Integer, String> hm1 = new HashMap<Integer, String>(20);
        //构造一个带指定初始容量和加载因子的空 HashMap。
        HashMap<Integer, String> hm2 = new HashMap<Integer, String>(20, (float) 0.8);

        hm.put(27, "林青霞");
        hm.put(30, "风清扬");
        hm.put(28, "刘意");
        hm.put(29, "林青霞");

        //public HashMap(Map<? extends K,? extends V> m)
        // 构造一个映射关系与指定 Map 相同的新 HashMap。
        // 所创建的 HashMap 具有默认加载因子 (0.75) 和足以容纳指定 Map 中映射关系的初始容量。
        HashMap<Integer, String> hm3 = new HashMap<Integer, String>(hm);

        System.out.println(hm);
        System.out.println(hm3);
    }
}

```

## 2、成员方法

HashMap<Integer,String>

```java
package cn.itcast_02;

import java.util.HashMap;
import java.util.Set;

/*
 * HashMap<Integer,String>
 * 键：Integer
 * 值：String
 */
public class HashMapDemo2 {
	public static void main(String[] args) {
		// 创建集合对象
		HashMap<Integer, String> hm = new HashMap<Integer, String>();

		// 创建元素并添加元素
		// Integer i = new Integer(27);
		// Integer i = 27;
		// String s = "林青霞";
		// hm.put(i, s);

		hm.put(27, "林青霞");
		hm.put(30, "风清扬");
		hm.put(28, "刘意");
		hm.put(29, "林青霞");

		// 下面的写法是八进制，但是不能出现8以上的单个数据
		// hm.put(003, "hello");
		// hm.put(006, "hello");
		// hm.put(007, "hello");
		// hm.put(008, "hello");

		// 遍历
		Set<Integer> set = hm.keySet();
		for (Integer key : set) {
			String value = hm.get(key);
			System.out.println(key + "---" + value);
		}

		// 下面这种方式仅仅是集合的元素的字符串表示
		// System.out.println("hm:" + hm);
	}
}

```

HashMap<String,Student>

```java
package cn.itcast_02;

import java.util.HashMap;
import java.util.Set;

/*
 * HashMap<String,Student>
 * 键：String	学号
 * 值：Student 学生对象
 */
public class HashMapDemo3 {
	public static void main(String[] args) {
		// 创建集合对象
		HashMap<String, Student> hm = new HashMap<String, Student>();

		// 创建学生对象
		Student s1 = new Student("周星驰", 58);
		Student s2 = new Student("刘德华", 55);
		Student s3 = new Student("梁朝伟", 54);
		Student s4 = new Student("刘嘉玲", 50);

		// 添加元素
		hm.put("9527", s1);
		hm.put("9522", s2);
		hm.put("9524", s3);
		hm.put("9529", s4);

		// 遍历
		Set<String> set = hm.keySet();
		for (String key : set) {
			// 注意了：这次值不是字符串了
			// String value = hm.get(key);
			Student value = hm.get(key);
			System.out.println(key + "---" + value.getName() + "---"
					+ value.getAge());
		}
	}
}

```

```java
package cn.itcast_02;

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
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + age;
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		return result;
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

HashMap<Student,String>

```java
package cn.itcast_02;

import java.util.HashMap;
import java.util.Set;

/*
 * HashMap<Student,String>
 * 键：Student
 * 		要求：如果两个对象的成员变量值都相同，则为同一个对象。
 * 值：String
 */
public class HashMapDemo4 {
	public static void main(String[] args) {
		// 创建集合对象
		HashMap<Student, String> hm = new HashMap<Student, String>();

		// 创建学生对象
		Student s1 = new Student("貂蝉", 27);
		Student s2 = new Student("王昭君", 30);
		Student s3 = new Student("西施", 33);
		Student s4 = new Student("杨玉环", 35);
		Student s5 = new Student("貂蝉", 27);

		// 添加元素
		hm.put(s1, "8888");
		hm.put(s2, "6666");
		hm.put(s3, "5555");
		hm.put(s4, "7777");
		hm.put(s5, "9999");

		// 遍历
		Set<Student> set = hm.keySet();
		for (Student key : set) {
			String value = hm.get(key);
			System.out.println(key.getName() + "---" + key.getAge() + "---"
					+ value);
		}
	}
}
```
