# 集合02：Set接口

## 一、Set接口

一个不包含重复元素的 collection。

存储字符串并遍历

```java
import java.util.HashSet;
import java.util.Set;

/*
 * Collection
 * 		|--List
 * 			有序(存储顺序和取出顺序一致),可重复
 * 		|--Set
 * 			无序(存储顺序和取出顺序不一致),唯一
 * 
 * HashSet：它不保证 set 的迭代顺序；特别是它不保证该顺序恒久不变。
 * 注意：虽然Set集合的元素无序，但是，作为集合来说，它肯定有它自己的存储顺序，
 * 而你的顺序恰好和它的存储顺序一致，这代表不了有序，你可以多存储一些数据，就能看到效果。
 */
public class SetDemo {
	public static void main(String[] args) {
		// 创建集合对象
		Set<String> set = new HashSet<String>();

		// 创建并添加元素
		set.add("hello");
		set.add("java");
		set.add("world");
		set.add("java");
		set.add("world");

		// 增强for
		for (String s : set) {
			System.out.println(s);
		}
	}
}

```

## 二、HashSet类

不保证 set 的迭代顺序。特别是它不保证该顺序恒久不变。

### 1、存储字符串并遍历 

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

### 2、存储自定义对象并遍历

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

### 3、LinkedHashSet类

元素有序唯一

	由链表保证元素有序。(存储和取出是一致)

	由哈希表保证元素唯一

```java
import java.util.LinkedHashSet;

public class LinkedHashSetDemo {
	public static void main(String[] args) {
		// 创建集合对象
		LinkedHashSet<String> hs = new LinkedHashSet<String>();

		// 创建并添加元素
		hs.add("hello");
		hs.add("world");
		hs.add("java");
		hs.add("world");
		hs.add("java");

		// 遍历
		for (String s : hs) {
			System.out.println(s);
		}
	}
}
```
## 三、TreeSet类

使用元素的自然顺序对元素进行排序，

或者根据创建 set 时提供的 Comparator 进行排序

具体取决于使用的构造方法:

	public TreeSet()
		构造一个新的空 set，该 set 根据其元素的自然顺序进行排序。
	public TreeSet(Comparator<? super E> comparator)
		构造一个新的空 TreeSet，它根据指定比较器进行排序。

TreeSet集合的特点：

	排序和唯一

### 1、自然顺序排序

#### （1）存储整数并遍历 

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
#### （2）存储自定义对象并遍历

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

### 2、比较器排序

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

### 3、add方法源码

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

真正的比较是依赖于元素的compareTo()方法，而这个方法是定义在 Comparable里面的。
所以，你要想重写该方法，就必须是先 Comparable接口。这个接口表示的就是自然排序。
```

### 4、TreeSet集合保证元素排序和唯一性的原理:

	唯一性：是根据比较的返回是否是0来决定。
	排序：
		A:自然排序(元素具备比较性)
			让元素所属的类 实现自然排序接口 Comparable
		B:比较器排序(集合具备比较性)
			让集合的构造方法接收一个比较器接口的子类对象 Comparator

![java38](https://s1.ax1x.com/2020/07/08/UVPlKP.png)

### 5、Comparable 、 Comparator

（1）Comparable接口

public interface Comparable<T>

此接口强行对实现它的每个类的对象进行整体排序。这种排序被称为 **类的自然排序**，
类的 compareTo 方法被称为它的自然比较方法。

实现此接口的对象列表（和数组）可以通过 Collections.sort（和 Arrays.sort）
进行自动排序。**实现此接口的对象可以用作有序映射中的键或有序集合中的元素，
无需指定比较器。**

int compareTo(T o)

	比较此对象与指定对象的顺序。
	返回：
		负整数、零或正整数，根据此对象是小于、等于还是大于指定对象。 
	抛出： 
		ClassCastException - 如果指定对象的类型不允许它与此对象进行比较。

（2）Comparator接口

public interface Comparator<T>

强行对某个对象 collection 进行整体排序的 **比较器**。
可以将 Comparator 传递给 sort 方法（如 Collections.sort 或 Arrays.sort），从而允许在排序顺序上实现精确控制。
还可以使用 Comparator 来控制某些数据结构（如有序 set或有序映射）的顺序，
或者 **为那些没有自然顺序的对象 collection 提供排序**

int compare(T o1,T o2)

	比较用来排序的两个参数。
	返回：
		根据第一个参数小于、等于或大于第二个参数分别返回负整数、零或正整数。 
	抛出： 
		ClassCastException - 如果参数的类型不允许此 Comparator 对它们进行比较。
		
boolean equals(Object obj)

	指示某个其他对象是否“等于”此 Comparator。
	返回：
		仅当指定的对象也是一个 Comparator，并且强行实施与此 Comparator 相同的排序时才返回 true。

==========================================
总结：

1:登录注册案例(理解)

2:Set集合(理解)
	(1)Set集合的特点
		无序,唯一
	(2)HashSet集合(掌握)
		A:底层数据结构是哈希表(是一个元素为链表的数组)
		B:哈希表底层依赖两个方法：hashCode()和equals()
		  执行顺序：
			首先比较哈希值是否相同
				相同：继续执行equals()方法
					返回true：元素重复了，不添加
					返回false：直接把元素添加到集合
				不同：就直接把元素添加到集合
		C:如何保证元素唯一性的呢?
			由hashCode()和equals()保证的
		D:开发的时候，代码非常的简单，自动生成即可。
		E:HashSet存储字符串并遍历
		F:HashSet存储自定义对象并遍历(对象的成员变量值相同即为同一个元素)
	(3)TreeSet集合
		A:底层数据结构是红黑树(是一个自平衡的二叉树)
		B:保证元素的排序方式
			a:自然排序(元素具备比较性)
				让元素所属的类实现Comparable接口
			b:比较器排序(集合具备比较性)
				让集合构造方法接收Comparator的实现类对象
		C:把我们讲过的代码看一遍即可
	(4)案例：
		A:获取无重复的随机数
		B:键盘录入学生按照总分从高到底输出
		
3:Collection集合总结(掌握)
	Collection
		|--List	有序,可重复
			|--ArrayList
				底层数据结构是数组，查询快，增删慢。
				线程不安全，效率高
			|--Vector
				底层数据结构是数组，查询快，增删慢。
				线程安全，效率低
			|--LinkedList
				底层数据结构是链表，查询慢，增删快。
				线程不安全，效率高
		|--Set	无序,唯一
			|--HashSet
				底层数据结构是哈希表。
				如何保证元素唯一性的呢?
					依赖两个方法：hashCode()和equals()
					开发中自动生成这两个方法即可
				|--LinkedHashSet
					底层数据结构是链表和哈希表
					由链表保证元素有序
					由哈希表保证元素唯一
			|--TreeSet
				底层数据结构是红黑树。
				如何保证元素排序的呢?
					自然排序
					比较器排序
				如何保证元素唯一性的呢?
					根据比较的返回值是否是0来决定
					
4:针对Collection集合我们到底使用谁呢?(掌握)
	唯一吗?
		是：Set
			排序吗?
				是：TreeSet
				否：HashSet
		如果你知道是Set，但是不知道是哪个Set，就用HashSet。
			
		否：List
			要安全吗?
				是：Vector
				否：ArrayList或者LinkedList
					查询多：ArrayList
					增删多：LinkedList
		如果你知道是List，但是不知道是哪个List，就用ArrayList。
	
	如果你知道是Collection集合，但是不知道使用谁，就用ArrayList。
	
	如果你知道用集合，就用ArrayList。
	
5:在集合中常见的数据结构(掌握)
	ArrayXxx:底层数据结构是数组，查询快，增删慢
	LinkedXxx:底层数据结构是链表，查询慢，增删快
	HashXxx:底层数据结构是哈希表。依赖两个方法：hashCode()和equals()
	TreeXxx:底层数据结构是二叉树。两种方式排序：自然排序和比较器排序
		