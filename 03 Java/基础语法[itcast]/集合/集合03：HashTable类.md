# 集合11：HashTable类

[TOC]

	public class Hashtable<K,V>
	extends Dictionary<K,V>
	implements Map<K,V>, Cloneable, Serializable

此类**实现一个哈希表**，该哈希表将键映射到相应的值。

**任何非 null 对象都可以用作键或值**。

为了成功地在哈希表中存储和获取对象，**用作键的对象必须实现 hashCode 方法和 equals 方法**。

Hashtable 的实例有两个参数影响其性能：初始容量和加载因子。

**容量是哈希表中桶的数量**，初始容量就是哈希表创建时的容量。注意，哈希表的状态为open：在发生“哈希冲突”的情况下，单个桶会存储多个条目，这些条目必须按顺序搜索。

**加载因子是对哈希表在其容量自动增加之前可以达到多满的一个尺度**。初始容量和加载因子这两个参数只是对该实现的提示。关于何时以及是否调用 rehash 方法的具体细节则依赖于该实现。

通常，默认加载因子(.75)在时间和空间成本上寻求一种折衷。加载因子过高虽然减少了空间开销，但同时也增加了查找某个条目的时间（在大多数 Hashtable 操作中，包括 get 和 put 操作，都反映了这一点）。

初始容量主要控制空间消耗与执行 rehash 操作所需要的时间损耗之间的平衡。如果初始容量大于 Hashtable 所包含的最大条目数除以加载因子，则永远 不会发生 rehash 操作。但是，将初始容量设置太高可能会浪费空间。

如果很多条目要存储在一个 Hashtable 中，那么与根据需要执行自动 rehashing 操作来增大表的容量的做法相比，**使用足够大的初始容量创建哈希表或许可以更有效地插入条目**。

下面这个示例创建了一个数字的哈希表。它将数字的名称用作键： 

	Hashtable<String, Integer> numbers = new Hashtable<String, Integer>();
	numbers.put("one", 1);
	numbers.put("two", 2);
	numbers.put("three", 3);

	//要获取一个数字，可以使用以下代码： 

	Integer n = numbers.get("two");
	if (n != null) {
		System.out.println("two = " + n);
	}
   
由所有类的“collection 视图方法”返回的 collection 的 iterator 方法返回的迭代器都是快速失败 的：在创建 Iterator 之后，如果从结构上对 Hashtable 进行修改，除非通过 Iterator 自身的 remove 方法，否则在任何时间以任何方式对其进行修改，Iterator 都将抛出ConcurrentModificationException。因此，面对并发的修改，Iterator 很快就会完全失败，而不冒在将来某个不确定的时间发生任意不确定行为的风险。由 Hashtable 的键和元素方法返回的 Enumeration 不 是快速失败的。 

注意，迭代器的快速失败行为无法得到保证，因为一般来说，不可能对是否出现不同步并发修改做出任何硬性保证。快速失败迭代器会尽最大努力抛出 ConcurrentModificationException。因此，为提高这类迭代器的正确性而编写一个依赖于此异常的程序是错误做法：迭代器的快速失败行为应该仅用于检测程序错误。 

**Hashtable 是同步的**

```java
/*
* Hashtable：方法及遍历
* */
public class HashTableDemo01 {
    public static void main(String[] args){
        Hashtable<String, Integer> num = new Hashtable<String, Integer>();
        num.put("one", 1);
        num.put("two", 2);
        num.put("three", 3);

        //public Enumeration<V> elements()返回此哈希表中的值的枚举。
        Enumeration<Integer> val = num.elements();
        while(val.hasMoreElements()){
            System.out.println(val.nextElement());
            //2
            //1
            //3
        }
        System.out.println("------------------------------");

        //public Enumeration<K> keys()返回此哈希表中的键的枚举。
        Enumeration<String> k = num.keys();
        while(k.hasMoreElements()){
            System.out.println(k.nextElement());
            //two
            //one
            //three
        }
        System.out.println("------------------------------");

        //public String toString()返回此 Hashtable 对象的字符串表示形式，
        // 其形式为 ASCII 字符 ", " （逗号加空格）分隔开的、括在括号中的一组条目。
        // 每个条目都按以下方式呈现：键，一个等号 = 和相关元素，其中 toString 方法用于将键和元素转换为字符串。
        System.out.println(num.toString());//{two=2, one=1, three=3}
        System.out.println("------------------------------");


        Set<String> ss = num.keySet();
        for(String s : ss){
            System.out.println(s+":"+num.get(s));
        }
        //two:2
        //one:1
        //three:3
        System.out.println("------------------------------");

        Set<Map.Entry<String, Integer>> sse = num.entrySet();
        for(Map.Entry<String, Integer> se:sse){
            System.out.println(se.getKey()+":"+se.getValue());
        }
    }
}

```