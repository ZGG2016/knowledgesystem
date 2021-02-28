# 集合02：List接口

[TOC]

## 1、List接口

	public interface List<E>
	extends Collection<E>

有序(进来顺序和出去顺序一致)的集合

可以对列表中每个元素的插入位置进行精确地控制。用户可以**根据元素的整数索引**(在列表中的位置，从0开始)访问元素，并搜索列表中的元素。
	
	void add(int index,E element)
	boolean addAll(int index,Collection<? extends E> c)
	E set(int index,E element)
	E get(int index)


与 set 不同，列表通常**允许重复的元素**。更确切地讲，列表通常允许满足 e1.equals(e2) 的元素对 e1 和 e2，并且如果列表本身允许 null 元素的话，通常它们允许多个 null 元素。

List 接口在 iterator、add、remove、equals 和 hashCode 方法的协定上加了一些其他约定，**超过了 Collection 接口中指定的约定**。为方便起见，这里也包括了其他继承方法的声明。

List 接口提供了**特殊的迭代器，称为 ListIterator**，除了允许 Iterator 接口提供的正常操作外，该迭代器还**允许元素插入和替换，以及双向访问**。还提供了一个方法来获取**从列表中指定位置开始的列表迭代器**。

List 接口提供了两种搜索指定对象的方法。从性能的观点来看，应该小心使用这些方法。在很多实现中，它们将执行**高开销**的线性搜索。

注意：尽管列表允许把自身作为元素包含在内，但建议要特别小心：在这样的列表上，equals 和 hashCode 方法不再是定义良好的。 

**方法测试**

```java
/*
* List接口：测试特有成员方法
*        根据索引，增删改查
* */
public class ListDemo01 {
    public static void main(String[] args) {
        // 创建集合对象
        List<String> list = new ArrayList<String>();

        // 添加元素
        list.add("hello");
        list.add("world");
        list.add("java");

        /*
        * 1. void add(int index,Object element):
        *    在指定位置添加元素
        * */
         list.add(1, "android");//没有问题
         //IndexOutOfBoundsException
//         list.add(11, "javaee");//有问题
         list.add(3, "javaee"); //没有问题
//         list.add(4, "javaee"); //有问题

        /*
        * 2. Object get(int index):获取指定位置的元素
        *
        * */
         System.out.println("get:" + list.get(1));
         //IndexOutOfBoundsException
//         System.out.println("get:" + list.get(11));

        /*
        * 3. Object remove(int index)：
        *     根据索引删除元素，返回被删除的元素
        * */
         System.out.println("remove:" + list.remove(1));
         //IndexOutOfBoundsException
         //System.out.println("remove:" + list.remove(11));

        /*
        * 4. Object set(int index,Object element):
        *     根据索引修改元素，返回被修改的元素
        * */
        System.out.println("set:" + list.set(1, "javaee"));

        /*
        * 5.int indexOf(Object o)
        *     返回此列表中第一次出现的指定元素的索引；如果此列表不包含该元素，则返回 -1。
        * */
        System.out.println("set:" + list.indexOf("test"));  //-1
        System.out.println("set:" + list.indexOf("hello")); //0

        /*
        * 6. int lastIndexOf(Object o)
        *  返回此列表中最后出现的指定元素的索引；如果列表不包含此元素，则返回 -1。
        * */
        System.out.println("set:" + list.lastIndexOf("hello")); //0

        // 创建集合对象
        List<String> list2 = new ArrayList<String>();

        // 添加元素
        list2.add("aaaa");
        list2.add("bbbb");
        list2.add("cccc");

        /*
        * 1.boolean addAll(int index,Collection<? extends E> c)
        *   将指定 collection 中的所有元素都插入到列表中的指定位置（可选操作）。
        *   将当前处于该位置的元素（如果有的话）和所有后续元素向右移动（增加其索引）。
        *   新元素将按照它们通过指定 collection 的迭代器所返回的顺序出现在此列表中。
        * */
        list.addAll(1,list2); //list:[hello, aaaa, bbbb, cccc, world, java]

        System.out.println("list:" + list);
    }
}

```

```java
/*
* List：List特有遍历功能：
*      1.size()和get()方法结合使用
*      2.ListIterator迭代器
* */
public class ListDemo03 {
    public static void main(String[] args) {
        // 创建集合对象
        List<String> list = new ArrayList<String>();
        list.add("hello");
        list.add("world");
        list.add("java");

        //ListIterator迭代器
        ListIterator lit = list.listIterator();
        while (lit.hasNext()) {
            String s = (String) lit.next();
            System.out.println(s);
        }

        //size()和get()方法结合
        for (int x = 0; x < list.size(); x++) {
            String s = (String) list.get(x);
            System.out.println(s);
        }

//---------------------------------------------------------------------------

        //存储自定义对象并遍历
        // 创建集合对象
        List<Student> list2 = new ArrayList<Student>();
        Student s1 = new Student("林黛玉", 18);
        Student s2 = new Student("刘姥姥", 88);
        Student s3 = new Student("王熙凤", 38);
        list2.add(s1);
        list2.add(s2);
        list2.add(s3);

        // 迭代器遍历
        ListIterator lit2 = list2.listIterator();
        while (lit2.hasNext()) {
            Student s = (Student) lit2.next();
            System.out.println(s.getName() + "---" + s.getAge());
        }
        System.out.println("--------");

        // 普通for循环
        for (int x = 0; x < list2.size(); x++) {
            Student s = (Student) list2.get(x);
            System.out.println(s.getName() + "---" + s.getAge());
        }
    }
}

```

## 2、ListIterator接口

	public interface ListIterator<E>
	extends Iterator<E>

List迭代器，继承了Iterator迭代器。

允许程序员按任一方向遍历列表、迭代期间修改列表，并获得迭代器在列表中的当前位置。

ListIterator 没有当前元素，它的光标位置始终位于调用 previous() 所返回的元素和调用 next() 所返回的元素之间。

长度为 n 的列表的迭代器有 n+1 个可能的指针位置，如下面的插入符举例说明：

	            Element(0)   Element(1)   Element(2)   ... Element(n-1)
	当前位置:  ^            ^            ^            ^                  ^

注意：

	remove() 和 set(Object) 方法不是根据光标位置定义的，它们是根据对调用 next() 或 previous() 所返回的最后一个元素的操作定义的。 
	
	ListIterator可以实现逆向遍历，但是必须先正向遍历，才能逆向遍历，所以一般无意义，不使用。


```java
/*
 * List：ListIterator迭代器方法测试
 * */
public class ListDemo04 {
    public static void main(String[] args) {
        List<String> list = new ArrayList<String>();
        list.add("hello");
        list.add("world");
        list.add("java");

        /*
        * int nextIndex()
        *     返回对 next 的后续调用所返回元素的索引。（如果列表迭代器在列表的结尾，则返回列表的大小）。
         * */

        ListIterator lit = list.listIterator(); // 子类对象
        while (lit.hasNext()) {
            String s = (String) lit.next();
            System.out.println(s+":"+lit.nextIndex());
            //hello:1
            //world:2
            //java:3
        }

        System.out.println("-----------------");

//         System.out.println(lit.previous()+":"+lit.previousIndex()); // java:1
//         System.out.println(lit.previous()+":"+lit.previousIndex()); // world:0
//         System.out.println(lit.previous()+":"+lit.previousIndex()); // hello:-1
//        // NoSuchElementException
//        // System.out.println(lit.previous());

        /*
         * previousIndex():
         *     返回对 previous 的后续调用所返回元素的索引。（如果列表迭代器在列表的开始，则返回 -1）。
         * */
        while (lit.hasPrevious()) {
            String s = (String) lit.previous();
            System.out.println(s+":"+lit.previousIndex());
            //java:1
            //world:0
            //hello:-1
        }
        System.out.println("-----------------");

        /*
        * void set(E e)
        *      用指定元素替换 next 或 previous 返回的最后一个元素（可选操作）。
        * 只有在最后一次调用 next 或 previous 后既没有调用 ListIterator.remove
        * 也没有调用 ListIterator.add 时才可以进行该调用。
        * */
        lit.set("aaa");
        ListIterator lit3 = list.listIterator();
        while (lit3.hasNext()) {
            String s = (String) lit3.next();
            System.out.println(s+":"+lit3.nextIndex());
            //aaa:1
            //world:2
            //java:3
        }
        System.out.println("-----------------");

        /*
        * void remove()
        *     从列表中移除由 next 或 previous 返回的最后一个元素（可选操作）。
        * 对于每个 next 或 previous 调用，只能执行一次此调用。
        * 只有在最后一次调用 next 或 previous 之后，尚未调用 ListIterator.add 时才可以执行该调用。
         * */

        lit.remove();
        ListIterator lit2 = list.listIterator();
        while (lit2.hasNext()) {
            String s = (String) lit2.next();
            System.out.println(s+":"+lit2.nextIndex());
            //world:1
            //java:2
        }
        System.out.println("-----------------");

        /*
        * void add(E e)
        *    将指定的元素插入列表（可选操作）。
        * 该元素直接插入到 next 返回的下一个元素的前面（如果有），或者 previous 返回的下一个元素之后（如果有）
        * */
        lit.add("addobject");
        ListIterator lit4 = list.listIterator();
        while (lit4.hasNext()) {
            String s = (String) lit4.next();
            System.out.println(s+":"+lit4.nextIndex());
            //addobject:1
            //world:2
            //java:3
        }
    }
}
```

```java
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
public class ListDemo05 {
    public static void main(String[] args) {
        List<String> list = new ArrayList<String>();
        list.add("hello");
        list.add("world");
        list.add("java");

        // 迭代器遍历
//         Iterator it = list.iterator();
//         while (it.hasNext()) {
//            String s = (String) it.next();
//            if ("world".equals(s)) {
//                list.add("javaee");  //ConcurrentModificationException
//            }
//         }

        // 方式1：迭代器迭代元素，迭代器修改元素
        // 而Iterator迭代器却没有添加功能，所以我们使用其子接口ListIterator
         ListIterator lit = list.listIterator();
         while (lit.hasNext()) {
            String s = (String) lit.next();
            if ("world".equals(s)) {
                lit.add("javaee");
            }
         }

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

## 3、数据结构

![java31](https://s1.ax1x.com/2020/07/06/UPPf4x.png)

![java32](https://s1.ax1x.com/2020/07/06/UPPWU1.png)

## 4、List子类面试题

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