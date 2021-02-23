# WritableComparable接口、WritableComparator类

	Writable接口   ---
			    ---> WritableComparable接口
	Comparable接口 ---


	Comparator接口 --- RawComparator接口 ---
						---> WritableComparator类
			Configurable接口  ---


## 一

### WritableComparable接口

通过 Comparators ，WritableComparables可以实现互相比较。

Hadoop Map-Reduce 框架中的所有类型的 key 都要实现这个接口。

**当自定义数据类型时要实现这个接口。**

### Comparable接口

	public interface Comparable<T>

此接口强行对实现它的每个类的对象进行整体排序。这种排序被称为 **类的自然排序**，类的 compareTo 方法被称为它的自然比较方法。

实现此接口的对象列表（和数组）可以通过 Collections.sort（和 Arrays.sort）
进行自动排序。**实现此接口的对象可以用作有序映射中的键或有序集合中的元素，
无需指定比较器。**

	int compareTo(T o)

比较此对象与指定对象的顺序。
	
返回：负整数、零或正整数，根据此对象是小于、等于还是大于指定对象。 

抛出：ClassCastException - 如果指定对象的类型不允许它与此对象进行比较。


## 二

### WritableComparator类

默认是自然排序。

自定义排序规则需要重写compare(WritableComparable,WritableComparable)方法。

一个优化比较操作密集的方法就是重写compare(byte[],int,int,byte[],int,int)
提供了静态实用方法来帮助优化此方法的实现。

### Comparator接口

	public interface Comparator<T>

强行对某个对象 collection 进行整体排序的 **比较器**。
可以将 Comparator 传递给 sort 方法（如 Collections.sort 或 Arrays.sort），从而允许在排序顺序上实现精确控制。
还可以使用 Comparator 来控制某些数据结构（如有序 set或有序映射）的顺序，
或者 **为那些没有自然顺序的对象 collection 提供排序**

	int compare(T o1,T o2)

比较用来排序的两个参数。
	
返回：根据第一个参数小于、等于或大于第二个参数分别返回负整数、零或正整数。 
	
抛出： ClassCastException - 如果参数的类型不允许此 Comparator 对它们进行比较。
		
	boolean equals(Object obj)

指示某个其他对象是否“等于”此 Comparator。
	
返回：仅当指定的对象也是一个 Comparator，并且强行实施与此 Comparator 相同的排序时才返回 true。



