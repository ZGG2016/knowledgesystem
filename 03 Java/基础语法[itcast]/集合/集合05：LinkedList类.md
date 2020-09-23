# 集合05：LinkedList类

[TOC]

	public class LinkedList<E>
	extends AbstractSequentialList<E>
	implements List<E>, Deque<E>, Cloneable, Serializable

**List 接口的链表实现**。

实现所有可选的列表操作，并且**允许所有元素（包括 null）**。

除了实现 List 接口外，LinkedList 类还为在列表的开头及结尾 get、remove 和 insert 元素提供了统一的命名方法。这些操作允许**将链表用作堆栈、队列或双端队列**。

此类实现 Deque 接口，为 add、poll 提供先进先出队列操作，以及其他堆栈和双端队列操作。

**所有操作都是按照双重链表的需要执行的**。在列表中编索引的操作将从开头或结尾遍历列表（从靠近指定索引的一端）。

注意，此实现**不是同步的**。如果多个线程同时访问一个链接列表，而其中至少一个线程从结构上修改了该列表，则它必须保持外部同步。（结构修改指添加或删除一个或多个元素的任何操作；仅设置元素的值不是结构修改。）

这一般通过对自然封装该列表的对象进行同步操作来完成。如果不存在这样的对象，则应该使用 Collections.synchronizedList 方法来“包装”该列表。

最好在创建时完成这一操作，以防止对列表进行意外的不同步访问，如下所示： 

	List list = Collections.synchronizedList(new LinkedList(...));

此类的 iterator 和 listIterator 方法返回的迭代器是快速失败 的：在迭代器创建之后，如果从结构上对列表进行修改，除非通过迭代器自身的 remove 或 add 方法，其他任何时间任何方式的修改，迭代器都将抛出 ConcurrentModificationException。因此，面对并发的修改，迭代器很快就会完全失败，而不冒将来不确定的时间任意发生不确定行为的风险。 

## 构造方法

具体描述见API

## 成员方法

具体描述见API

可以使用LinkedList实现堆栈、队列或双端队列

**示例：用LinkedList模拟栈数据结构**

```java
/*
* LinkedList:用LinkedList模拟栈数据结构
* */
public class LinkedListDemo01 {
    public static void main(String[] args){

        MyStack ms = new MyStack();

        ms.add("hello");
        ms.add("world");
        ms.add("java");

        while(!ms.isEmpty()){
            System.out.println(ms.get());
        }
    }
    public static class MyStack {
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
}

```