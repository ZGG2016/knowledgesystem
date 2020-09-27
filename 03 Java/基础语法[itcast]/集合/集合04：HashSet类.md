# 集合04：HashSet类

[TOC]

	public class HashSet<E>
	extends AbstractSet<E>
	implements Set<E>, Cloneable, Serializable

此类实现 Set 接口，**由哈希表（实际上是一个 HashMap 实例）支持**。

它**不保证 set 的迭代顺序**；特别是它不保证该顺序恒久不变。此类**允许使用 null 元素**。 

此类为基本操作提供了稳定性能，这些基本操作包括 add、remove、contains 和 size，假定哈希函数将这些元素正确地分布在桶中。对此 set 进行迭代所需的时间与 HashSet 实例的大小（元素的数量）和底层 HashMap 实例（桶的数量）的“容量”的和成比例。因此，**如果迭代性能很重要，则不要将初始容量设置得太高（或将加载因子设置得太低）。**

注意，此实现**不是同步的**。如果多个线程同时访问一个哈希 set，而其中至少一个线程修改了该 set，那么它必须保持外部同步。这通常是通过对自然封装该 set 的对象执行同步操作来完成的。如果不存在这样的对象，则**应该使用 Collections.synchronizedSet 方法**来“包装” set。最好在创建时完成这一操作，以防止对该 set 进行意外的不同步访问：

	Set s = Collections.synchronizedSet(new HashSet(...));

此类的 iterator 方法返回的迭代器是快速失败 的：在创建迭代器之后，如果对 set 进行修改，除非通过迭代器自身的 remove 方法，否则在任何时间以任何方式对其进行修改，Iterator 都将抛出 ConcurrentModificationException。因此，面对并发的修改，迭代器很快就会完全失败，而不冒将来在某个不确定时间发生任意不确定行为的风险。 

注意，迭代器的快速失败行为无法得到保证，因为一般来说，不可能对是否出现不同步并发修改做出任何硬性保证。快速失败迭代器在尽最大努力抛出 ConcurrentModificationException。因此，为提高这类迭代器的正确性而编写一个依赖于此异常的程序是错误做法：迭代器的快速失败行为应该仅用于检测 bug。 

## 1、存储字符串并遍历 

```java
public class HashSetDemo {
	public static void main(String[] args) {
		// 创建集合对象
		HashSet<String> hs = new HashSet<String>();

		// 创建并添加元素
		hs.add("hello");
		hs.add("world");
		hs.add("java");
		hs.add("world");

		// 遍历集合
		for (String s : hs) {
			System.out.println(s);
		}
	}
}
```

**add方法源码**

问题：HashSet如何保证元素唯一性

```java
interface Collection {
	...
}

interface Set extends Collection {
	...
}

class HashSet implements Set {
	private static final Object PRESENT = new Object();
	private transient HashMap<E,Object> map;
	
	public HashSet() {
		map = new HashMap<>();
	}
	
	public boolean add(E e) { //e=hello,world
        return map.put(e, PRESENT)==null;
    }
}

class HashMap implements Map {
	public V put(K key, V value) { //key=e=hello,world
	
		//看哈希表是否为空，如果空，就开辟空间
        if (table == EMPTY_TABLE) {
            inflateTable(threshold);
        }
        
        //判断对象是否为null
        if (key == null)
            return putForNullKey(value);
        
        int hash = hash(key); //和对象的hashCode()方法相关
        
        //在哈希表中查找hash值
        int i = indexFor(hash, table.length);
        for (Entry<K,V> e = table[i]; e != null; e = e.next) {
        	//这次的e其实是第一次的world
            Object k;
            if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {
                V oldValue = e.value;
                e.value = value;
                e.recordAccess(this);
                return oldValue;
                //走这里其实是没有添加元素
            }
        }

        modCount++;
        addEntry(hash, key, value, i); //把元素添加
        return null;
    }
    
    transient int hashSeed = 0;
    
    final int hash(Object k) { //k=key=e=hello,
        int h = hashSeed;
        if (0 != h && k instanceof String) {
            return sun.misc.Hashing.stringHash32((String) k);
        }

        h ^= k.hashCode(); //这里调用的是对象的hashCode()方法

        // This function ensures that hashCodes that differ only by
        // constant multiples at each bit position have a bounded
        // number of collisions (approximately 8 at default load factor).
        h ^= (h >>> 20) ^ (h >>> 12);
        return h ^ (h >>> 7) ^ (h >>> 4);
    }
}

//=============================
hs.add("hello");
hs.add("world");
hs.add("java");
hs.add("world");
```

通过查看add方法的源码，我们知道这个方法底层依赖 两个方法：hashCode()和equals()。

	步骤：

	首先比较哈希值
		如果相同，继续走，比较地址值或者走equals()
		如果不同,就直接添加到集合中	

	按照方法的步骤来说：	
		先看hashCode()值是否相同
		相同:继续走equals()方法
			返回true：	说明元素重复，就不添加
			返回false：说明元素不重复，就添加到集合
		不同：就直接把元素添加到集合
		
	如果类没有重写这两个方法，默认使用的Object()。一般来说不同相同。
	而String类重写了hashCode()和equals()方法，所以，它就可以把内容相同的字符串去掉。只留下一个。

## 2、存储自定义对象并遍历

需求：存储自定义对象，并保证元素的唯一性

要求：如果两个对象的成员变量值都相同，则为同一个元素。

```java
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
	public int hashCode() {  //自动重写
		final int prime = 31;
		int result = 1;
		result = prime * result + age;
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) { //自动重写
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

	// @Override
	// public int hashCode() {
	// // 不足参考下图[java37]
	// // return 0;   
	// // 因为成员变量值影响了哈希值，所以我们把成员变量值相加即可
	// // return this.name.hashCode() + this.age;
	// // 看下面
	// // s1:name.hashCode()=40,age=30
	// // s2:name.hashCode()=20,age=50
	// // 尽可能的区分,我们可以把它们乘以一些整数
	// return this.name.hashCode() + this.age * 15;
	// }
	//
	// @Override
	// public boolean equals(Object obj) {
	// // System.out.println(this + "---" + obj);
	// if (this == obj) {
	// return true;
	// }
	//
	// if (!(obj instanceof Student)) {
	// return false;
	// }
	//
	// Student s = (Student) obj;
	// return this.name.equals(s.name) && this.age == s.age;
	// }
	//
	// @Override
	// public String toString() {
	// return "Student [name=" + name + ", age=" + age + "]";
	// }

}


public class HashSetDemo2 {
	public static void main(String[] args) {
		// 创建集合对象
		HashSet<Student> hs = new HashSet<Student>();

		// 创建学生对象
		Student s1 = new Student("林青霞", 27);
		Student s2 = new Student("柳岩", 22);
		Student s3 = new Student("王祖贤", 30);
		Student s4 = new Student("林青霞", 27);
		Student s5 = new Student("林青霞", 20);
		Student s6 = new Student("范冰冰", 22);

		// 添加元素
		hs.add(s1);
		hs.add(s2);
		hs.add(s3);
		hs.add(s4);
		hs.add(s5);
		hs.add(s6);

		// 遍历集合
		for (Student s : hs) {
			System.out.println(s.getName() + "---" + s.getAge());
		}
	}
}
```

![java37](https://s1.ax1x.com/2020/07/08/UVP1Df.png)