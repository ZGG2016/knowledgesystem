# 集合04：Vector类

[TOC]

	public class Vector<E>
	extends AbstractList<E>
	implements List<E>, RandomAccess, Cloneable, Serializable

Vector类可以实现**可增长的对象数组**。与数组一样，它可以**使用整数索引进行访问**。

但是，Vector 的大小可以根据需要增大或缩小，以适应创建 Vector 后进行添加或移除项的操作。 

每个向量会试图通过维护 capacity 和 capacityIncrement 来优化存储管理。capacity 始终至少应与向量的大小相等；这个值通常比后者大些，**因为随着将组件添加到向量中，其存储将按 capacityIncrement的大小增加存储块。应用程序可以在插入大量组件前增加向量的容量；这样就减少了增加的重分配的量(public void ensureCapacity(int minCapacity))**。 

由 Vector 的 iterator 和 listIterator 方法所返回的迭代器是快速失败的：如果在迭代器创建后的任意时间从结构上修改了向量（通过迭代器自身的 remove 或 add 方法之外的任何其他方式），则迭代器将抛出 ConcurrentModificationException。因此，面对并发的修改，迭代器很快就完全失败，而不是冒着在将来不确定的时间任意发生不确定行为的风险。

Vector 的 **elements 方法返回的 Enumeration 不是快速失败的**。 

Vector 是**同步的**。 

## 构造方法

```java
/*
* Vector：构造方法
* */
public class VectorDemo01 {
    public static void main(String[] args) {
        // 1.构造方法

        //构造一个空向量，使其内部数据数组的大小为 10，其标准容量增量为零。
        Vector<String> v1 = new Vector<String>();
        //使用指定的初始容量和等于零的容量增量构造一个空向量。
        Vector<String> v2 = new Vector<String>(20);
        //使用指定的初始容量和容量增量构造一个空的向量。
        Vector<String> v3 = new Vector<String>(20,10);

        //public int capacity() 返回此向量的当前容量。
        System.out.println(v1.capacity()+":"+v2.capacity()+":"+v3.capacity());  //10:20:20
        //public int size()返回此向量中的组件数。
        System.out.println(v1.size()+":"+v2.size()+":"+v3.size());  //0:0:0

        for(int i=0;i<30;i++){
            v1.addElement("hello"+i);
            v2.addElement("hello"+i);
            v3.addElement("hello"+i);
        }

        System.out.println(v1.capacity()+":"+v2.capacity()+":"+v3.capacity()); //40:40:30
        System.out.println(v1.size()+":"+v2.size()+":"+v3.size());  //30:30:30

    }
}


```

## 成员方法

```java
/*
 * ArrayList：特有方法测试
 * */
public class VectorDemo02 {
    public static void main(String[] args) {
        // 创建集合对象
        Vector<String> v = new Vector<String>();

        //public void addElement(E obj)
        // 将指定的组件添加到此向量的末尾，将其大小增加 1。如果向量的大小比容量大，则增大其容量。
        v.addElement("hello");
        v.addElement("world");
        v.addElement("java");
        v.addElement("java");

        System.out.println(v);  //[hello, world, java, java]

        //public E elementAt(int index)返回指定索引处的组件。
        System.out.println("elementAt:" + v.elementAt(2));  //elementAt:java

        //public E firstElement()返回此向量的第一个组件（位于索引 0) 处的项）。
        System.out.println("firstElement:" + v.firstElement());  //firstElement:hello

        //public E lastElement()返回此向量的最后一个组件。索引 size() - 1 处。
        System.out.println("lastElement:" + v.lastElement());  //lastElement:java

        //public int indexOf(Object o,int index)
        // 返回此向量中第一次出现的指定元素的索引，从 index 处正向搜索，如果未找到该元素，则返回 -1。
        System.out.println("indexOf:" + v.indexOf("java",1));  //indexOf:2

        //public int lastIndexOf(Object o,int index)
        // 返回此向量中最后一次出现的指定元素的索引，从 index 处逆向搜索，如果未找到该元素，则返回 -1。
        System.out.println("lastIndexOf:" + v.lastIndexOf("world",2));  //lastIndexOf:1

        //public boolean removeElement(Object obj)从此向量中移除变量的第一个（索引最小的）匹配项。
        System.out.println("removeElement:"+v.removeElement("java")); //removeElement:true
        System.out.println("removeElement:"+v.removeElement("aaaa")); //removeElement:false
        System.out.println("after removeElement:"+v); //after removeElement:[hello, world, java]

        //public void removeElementAt(int index)删除指定索引处的组件。
        v.removeElementAt(0);
        System.out.println("after removeElementAt:"+v); //after removeElementAt:[world, java]

        //public void removeAllElements()从此向量中移除全部组件，并将其大小设置为零。
        v.removeAllElements();
        System.out.println("after removeAllElements:"+v); //after removeAllElements:[]

        //public void insertElementAt(E obj,int index)
        // 将指定对象作为此向量中的组件插入到指定的 index 处。
        v.insertElementAt("aaaa",0);
        v.insertElementAt("bbbb",1);
        v.insertElementAt("cccc",2);
        System.out.println("after insertElementAt:"+v); //after insertElementAt:[aaaa, bbbb, cccc]

        //public void setElementAt(E obj,int index)
        // 将此向量指定 index 处的组件设置为指定的对象。丢弃该位置以前的组件。
        v.setElementAt("dddd",2);
        System.out.println("setElementAt:"+v.elementAt(2)); //setElementAt:dddd

    }
}


```

## 遍历

```java
/*
 * ArrayList：遍历
 *      Enumeration
 *      elementAt()、size()
 * */
public class VectorDemo03 {
    public static void main(String[] args) {
        // 创建集合对象
        Vector<String> v = new Vector<String>();

        //public void addElement(E obj)
        // 将指定的组件添加到此向量的末尾，将其大小增加 1。如果向量的大小比容量大，则增大其容量。
        v.addElement("hello");
        v.addElement("world");
        v.addElement("java");
        v.addElement("java");

        //遍历

        //public Enumeration<E> elements()
        // 返回此向量的组件的枚举。返回的 Enumeration 对象将生成此向量中的所有项。
        // 生成的第一项为索引 0 处的项，然后是索引 1 处的项，依此类推。
        Enumeration<String> e = v.elements();
        while(e.hasMoreElements()){
            System.out.println(e.nextElement());

        }

        for (int x = 0; x < v.size(); x++) {
            String s = (String) v.elementAt(x);
            System.out.println(s);

        }
    }
}


```

## Enumeration

	public interface Enumeration<E>

实现 Enumeration 接口的对象，它生成一系列元素，一次生成一个。

连续调用 nextElement 方法将返回一系列的连续元素。 

注：

	此接口的功能与 Iterator 接口的功能是重复的。

	此外，Iterator 接口添加了一个可选的移除操作，并使用较短的方法名。

	新的实现应该优先考虑使用 Iterator 接口而不是 Enumeration 接口。 
