# 集合04：TreeSet类

[TOC]

	public class TreeSet<E>
	extends AbstractSet<E>
	implements NavigableSet<E>, Cloneable, Serializable

**基于 TreeMap 的 NavigableSet 实现。使用元素的自然顺序对元素进行排序，或者根据创建 set 时提供的 Comparator 进行排序，具体取决于使用的构造方法。**

此实现为基本操作（add、remove 和 contains）提供受保证的 log(n) 时间开销。 

注意，如果要正确实现 Set 接口，则 set 维护的顺序（无论是否提供了显式比较器）必须与 equals 一致。（关于与 equals 一致 的精确定义，请参阅 Comparable 或 Comparator。）

这是因为 Set 接口是按照 equals 操作定义的，但 TreeSet 实例使用它的 compareTo（或 compare）方法对所有元素进行比较，因此从 set 的观点来看，此方法认为相等的两个元素就是相等的。即使 set 的顺序与 equals 不一致，其行为也是定义良好的；它只是违背了 Set 接口的常规协定。 

注意，此实现**不是同步的**。如果多个线程同时访问一个 TreeSet，而其中至少一个线程修改了该 set，那么它必须 外部同步。这一般是通过对自然封装该 set 的对象执行同步操作来完成的。如果不存在这样的对象，则应该**使用 Collections.synchronizedSortedSet 方法**来“包装”该 set。此操作最好在创建时进行，以防止对 set 的意外非同步访问： 

	SortedSet s = Collections.synchronizedSortedSet(new TreeSet(...));

此类的 iterator 方法返回的迭代器是快速失败 的：在创建迭代器之后，如果从结构上对 set 进行修改，除非通过迭代器自身的 remove 方法，否则在其他任何时间以任何方式进行修改都将导致迭代器抛出 ConcurrentModificationException。因此，对于并发的修改，迭代器很快就完全失败，而不会冒着在将来不确定的时间发生不确定行为的风险。 

注意，迭代器的快速失败行为无法得到保证，一般来说，存在不同步的并发修改时，不可能作出任何肯定的保证。快速失败迭代器尽最大努力抛出 ConcurrentModificationException。因此，编写依赖于此异常的程序的做法是错误的，正确做法是：迭代器的快速失败行为应该仅用于检测 bug。 

## 1、自然顺序排序

### 1.1、存储整数并遍历 

```java
public class TreeSetDemo {
	public static void main(String[] args) {
		// 创建集合对象
		// 自然顺序进行排序
		TreeSet<Integer> ts = new TreeSet<Integer>();

		// 创建元素并添加
		// 20,18,23,22,17,24,19,18,24
		ts.add(20);
		ts.add(18);
		ts.add(23);
		ts.add(22);
		ts.add(17);
		ts.add(24);
		ts.add(19);
		ts.add(18);
		ts.add(24);

		// 遍历
		for (Integer i : ts) {
			System.out.println(i);
		}
	}
}
```
### 1.2、存储自定义对象并遍历

```java
/*
 * 如果一个类的元素要想能够进行自然排序，就必须实现自然排序接口Comparable，
 * 重写compareTo方法
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
		// return 0;
		// return 1;
		// return -1;

		// 这里返回什么，其实应该根据我的排序规则来做
		// 按照年龄排序,主要条件
		int num = this.age - s.age;
		// 次要条件
		// 年龄相同的时候，还得去看姓名是否也相同
		// 如果年龄和姓名都相同，才是同一个元素
		int num2 = num == 0 ? this.name.compareTo(s.name) : num;
		return num2;
		
		//比较name的compareTo方法：String类中的
		//public int compareTo(String anotherString)按字典顺序比较两个字符串。
	}
}
```

```java
import java.util.TreeSet;

/*
 * 
 * A:排序规则
 * 		自然排序，按照年龄从小到大排序；先年龄再姓名
 * B:元素唯一规则
 * 		成员变量值都相同即为同一个元素
 */
public class TreeSetDemo2 {
	public static void main(String[] args) {
		// 创建集合对象
		TreeSet<Student> ts = new TreeSet<Student>();

		// 创建元素
		Student s1 = new Student("linqingxia", 27);
		Student s2 = new Student("zhangguorong", 29);
		Student s3 = new Student("wanglihong", 23);
		Student s4 = new Student("linqingxia", 27);
		Student s5 = new Student("liushishi", 22);
		Student s6 = new Student("wuqilong", 40);
		Student s7 = new Student("fengqingy", 22);

		// 添加元素
		ts.add(s1);
		ts.add(s2);
		ts.add(s3);
		ts.add(s4);
		ts.add(s5);
		ts.add(s6);
		ts.add(s7);

		// 遍历
		for (Student s : ts) {
			System.out.println(s.getName() + "---" + s.getAge());
		}
	}
}

```

## 2、比较器排序

```java
import java.util.Comparator;
import java.util.TreeSet;

/*
 * 需求：请按照姓名的长度排序
 * 
 */
public class TreeSetDemo {
	public static void main(String[] args) {
		// 创建集合对象
		// public TreeSet(Comparator comparator) //比较器排序（方法1）
		// TreeSet<Student> ts = new TreeSet<Student>(new MyComparator());

		// 如果一个方法的参数是接口，那么真正要的是接口的实现类的对象
		// 而匿名内部类就可以实现这个东西（方法2）
		TreeSet<Student> ts = new TreeSet<Student>(new Comparator<Student>() {
			@Override
			public int compare(Student s1, Student s2) {
				// 姓名长度
				int num = s1.getName().length() - s2.getName().length();
				// 姓名内容
				int num2 = num == 0 ? s1.getName().compareTo(s2.getName())
						: num;
				// 年龄
				int num3 = num2 == 0 ? s1.getAge() - s2.getAge() : num2;
				return num3;
			}
		});

		// 创建元素
		Student s1 = new Student("linqingxia", 27);
		Student s2 = new Student("zhangguorong", 29);
		Student s3 = new Student("wanglihong", 23);
		Student s4 = new Student("linqingxia", 27);
		Student s5 = new Student("liushishi", 22);
		Student s6 = new Student("wuqilong", 40);
		Student s7 = new Student("fengqingy", 22);
		Student s8 = new Student("linqingxia", 29);

		// 添加元素
		ts.add(s1);
		ts.add(s2);
		ts.add(s3);
		ts.add(s4);
		ts.add(s5);
		ts.add(s6);
		ts.add(s7);
		ts.add(s8);

		// 遍历
		for (Student s : ts) {
			System.out.println(s.getName() + "---" + s.getAge());
		}
	}
}

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
}

import java.util.Comparator;

public class MyComparator implements Comparator<Student> {

	@Override
	public int compare(Student s1, Student s2) {
		// int num = this.name.length() - s.name.length();
		// this -- s1
		// s -- s2
		// 姓名长度
		int num = s1.getName().length() - s2.getName().length();
		// 姓名内容
		int num2 = num == 0 ? s1.getName().compareTo(s2.getName()) : num;
		// 年龄
		int num3 = num2 == 0 ? s1.getAge() - s2.getAge() : num2;
		return num3;
	}
}
```

## 3、add方法源码

```java
interface Collection {...}

interface Set extends Collection {...}

interface NavigableMap {

}

class TreeMap implements NavigableMap {
	 public V put(K key, V value) {
        Entry<K,V> t = root;
        if (t == null) {
            compare(key, key); // type (and possibly null) check
			//为空，就创建根节点
            root = new Entry<>(key, value, null);
            size = 1;
            modCount++;
            return null;
        }
        int cmp;
        Entry<K,V> parent;
        // split comparator and comparable paths
        Comparator<? super K> cpr = comparator;
        if (cpr != null) {  //构造方法是比较器的
            do {
                parent = t;
                cmp = cpr.compare(key, t.key);
                if (cmp < 0)
                    t = t.left;
                else if (cmp > 0)
                    t = t.right;
                else
                    return t.setValue(value);
            } while (t != null);
        }
        else {  //无参构造时
            if (key == null)
                throw new NullPointerException();
            Comparable<? super K> k = (Comparable<? super K>) key;
            do {
                parent = t;
                cmp = k.compareTo(t.key);
                if (cmp < 0)
                    t = t.left;
                else if (cmp > 0)
                    t = t.right;
                else
                    return t.setValue(value);
            } while (t != null);
        }
        Entry<K,V> e = new Entry<>(key, value, parent);
        if (cmp < 0)
            parent.left = e;
        else
            parent.right = e;
        fixAfterInsertion(e);
        size++;
        modCount++;
        return null;
    }
}

class TreeSet implements Set {
	private transient NavigableMap<E,Object> m;
	
	public TreeSet() {
		 this(new TreeMap<E,Object>());
	}

	public boolean add(E e) {
        return m.put(e, PRESENT)==null;
    }
}

//真正的比较是依赖于元素的compareTo()方法，而这个方法是定义在 Comparable里面的。
//所以，你要想重写该方法，就必须是先 Comparable接口。这个接口表示的就是自然排序。
```

## 4、TreeSet集合保证元素排序和唯一性的原理:

	唯一性：是根据比较的返回是否是0来决定。
	排序：
		A:自然排序(元素具备比较性)
			让元素所属的类 实现自然排序接口 Comparable
		B:比较器排序(集合具备比较性)
			让集合的构造方法接收一个比较器接口的子类对象 Comparator

![java38](https://s1.ax1x.com/2020/07/08/UVPlKP.png)