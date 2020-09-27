# 集合03：ArrayList类

[TOC]

	public class ArrayList<E>
	extends AbstractList<E>
	implements List<E>, RandomAccess, Cloneable, Serializable

**List接口的大小可变数组的实现**。

实现了所有可选列表操作，并允许包括 null 在内的所有元素。

除了实现List接口外，此类还提供一些方法来**操作内部用来存储列表的数组的大小**。（此类大致上等同于 Vector 类，除了此类是不同步的。）

**每个ArrayList实例都有一个容量**。该容量是**指用来存储列表元素的数组的大小**。它总是至少等于列表的大小。随着向 ArrayList 中不断添加元素，其**容量也自动增长**。

**在添加大量元素前，应用程序可以使用 ensureCapacity 操作来增加 ArrayList 实例的容量。这可以减少递增式再分配的数量。**

**注意，此实现不是同步的**。如果多个线程同时访问一个 ArrayList 实例，而其中至少一个线程从结构上修改了列表，那么它必须保持外部同步。（结构上的修改是指任何添加或删除一个或多个元素的操作，或者显式调整底层数组的大小；仅仅设置元素的值不是结构上的修改。）

这一般通过对自然封装该列表的对象进行同步操作来完成。如果不存在这样的对象，则应该使用 Collections.synchronizedList 方法将该列表“包装”起来。这最好在创建时完成，以防止意外对列表进行不同步的访问：

    List list = Collections.synchronizedList(new ArrayList(...)); 

**此类的 iterator 和 listIterator 方法返回的迭代器是快速失败的：**

在创建迭代器之后，除非通过迭代器自身的 remove 或 add 方法从结构上对列表进行修改，否则在任何时间以任何方式对列表进行修改，迭代器都会 **抛出 ConcurrentModificationException**。因此，面对并发的修改，迭代器很快就会完全失败，而不是冒着在将来某个不确定时间发生任意不确定行为的风险。

## 构造方法

```java
public class ArrayListDemo01 {
    public static void main(String[] args) {
        // 1.构造方法

        ArrayList<String> al = new ArrayList<String>();  //默认容量是10
//        ArrayList<String> al2 = new ArrayList<String>(100);  //指定容量是100

        al.add("hello");
        al.add("world");
        al.add("java");
        System.out.println(al); //[hello, world, java]

        System.out.println("--------------------------");

        //构造一个包含指定 collection 的元素的列表，这些元素是按照该 collection 的迭代器返回它们的顺序排列的。
        ArrayList<String> al3 = new ArrayList<String>(al);
        System.out.println(al3);  //[hello, world, java]

    }
}
```
## 成员方法

```java
/*
* ArrayList：特有方法测试
* */
public class ArrayListDemo02 {
    public static void main(String[] args) throws Exception {
//        calTime1();
//        calTime2();

//        testClone();
//        testIndexOf();
        testtrimToSize();
    }

    /*
     * public void ensureCapacity(int minCapacity)
     *    在添加大量元素前，应用程序可以使用 ensureCapacity 操作来增加 ArrayList 实例的容量。
     *     这可以减少递增式再分配的数量。
     * */
    private static void calTime1(){
        ArrayList<String> al = new ArrayList<String>();  //默认容量是10
        long startTime = System.currentTimeMillis();
        for(int i=0;i<20000;i++){
            al.add("hello"+i);
        }
        long endTime = System.currentTimeMillis();
        System.out.println(endTime-startTime); //14
    }

    private static void calTime2(){
        ArrayList<String> al = new ArrayList<String>();
        al.ensureCapacity(20000);
        long startTime = System.currentTimeMillis();
        for(int i=0;i<20000;i++){
            al.add("hello"+i);
        }
        long endTime = System.currentTimeMillis();
        System.out.println(endTime-startTime); //6
    }

    //public Object clone()  返回此 ArrayList 实例的浅表副本。（不复制这些元素本身。）
    private static void testClone(){
        ArrayList<String> al = new ArrayList<String>();
        al.add("hello");
        al.add("world");
        al.add("java");
        System.out.println(al); //[hello, world, java]
        ArrayList<String> alc = (ArrayList<String>) al.clone();
        alc.add("aaa");
        System.out.println(alc);  //[hello, world, java, aaa]
        System.out.println(al);  //[hello, world, java]

    }

    /*
    * public int indexOf(Object o)
    *    返回此列表中首次出现的指定元素的索引，或如果此列表不包含元素，则返回 -1。
    *   更确切地讲，返回满足 (o==null ? get(i)==null : o.equals(get(i))) 的最低索引 i，如果不存在此类索引，则返回 -1。
     *
    * public int lastIndexOf(Object o)
    *   返回此列表中最后一次出现的指定元素的索引，或如果此列表不包含索引，则返回 -1。
    *   更确切地讲，返回满足 (o==null ? get(i)==null : o.equals(get(i))) 的最高索引 i，如果不存在此类索引，则返回 -1。
     * */
    private static void testIndexOf(){
        ArrayList<String> al = new ArrayList<String>();
        al.add("hello");
        al.add("world");
        al.add("java");
        al.add("hello");
        System.out.println(al); //[hello, world, java, hello]
        int i = al.indexOf("hello");
        int j = al.lastIndexOf("hello");
        int k = al.indexOf("aaa");
        System.out.println(i+":"+j+":"+k); //0:3:-1

    }

    //public void trimToSize()
    // 将此 ArrayList 实例的容量调整为列表的当前大小。应用程序可以使用此操作来最小化 ArrayList 实例的存储量。
    private static void testtrimToSize() throws Exception {
        ArrayList<String> al = new ArrayList<String>();
        al.add("hello");
        al.add("world");
        al.add("java");
        al.add("hello");
        System.out.println(getCapacity(al)); //10  默认
        al.trimToSize();
        System.out.println(getCapacity(al)); //4

    }
    private static int getCapacity(ArrayList<?> l) throws Exception {
        Field dataField = ArrayList.class.getDeclaredField("elementData");
        dataField.setAccessible(true);
        return ((Object[]) dataField.get(l)).length;
    }
}

```

## 遍历

```java
/*
* ArrayList：遍历
*    1.迭代器 （ListIterator、Iterator）
*    2.get()、size()
* */
public class ArrayListDemo03 {
    public static void main(String[] args) {
        ArrayList<String> al = new ArrayList<String>();
        al.add("hello");
        al.add("world");
        al.add("java");

        // 1.迭代器
        Iterator<String> it = al.iterator();
        while (it.hasNext()) {
            String s = (String) it.next();
            System.out.println(s);
        }

        System.out.println("-----------");

        // 2.get()、size()
        for (int x = 0; x < al.size(); x++) {
            String s = (String) al.get(x);
            System.out.println(s);
        }
//------------------------------------------------------------------------
        //存储自定义对象并遍历
        ArrayList<Student> al2 = new ArrayList<Student>();

        // 创建学生对象
        Student s1 = new Student("武松", 30);
        Student s2 = new Student("鲁智深", 40);
        Student s3 = new Student("林冲", 36);
        Student s4 = new Student("杨志", 38);

        // 添加元素
        al2.add(s1);
        al2.add(s2);
        al2.add(s3);
        al2.add(s4);

        // 1.迭代器
        Iterator<Student> it2 = al2.iterator();
        while (it2.hasNext()) {
            Student s = (Student) it2.next();
            System.out.println(s.getName() + "---" + s.getAge());
        }

        System.out.println("----------------");
        // 2.get()、size()
        for (int x = 0; x < al2.size(); x++) {
            // ClassCastException 注意，千万要搞清楚类型
            // String s = (String) array.get(x);
            // System.out.println(s);

            Student s = (Student) al2.get(x);
            System.out.println(s.getName() + "---" + s.getAge());
        }
    }
}

```

## 示例

**ArrayList去除集合中字符串的重复值(字符串的内容相同)**

```java
package cn.itcast_04;

import java.util.ArrayList;
import java.util.Iterator;

/*
 * 分析：
 *      A:创建集合对象
 *      B:添加多个字符串元素(包含内容相同的)
 *      C:创建新集合
 *      D:遍历旧集合,获取得到每一个元素
 *      E:拿这个元素到新集合去找，看有没有
 *          有：不搭理它
 *          没有：就添加到新集合
 *      F:遍历新集合
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
 *      我们必须思考哪里会出问题?
 *      通过简单的分析，我们知道问题出现在了判断上。
 *      而这个判断功能是集合自己提供的，所以我们如果想很清楚的知道它是如何判断的，就应该去看源码。
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