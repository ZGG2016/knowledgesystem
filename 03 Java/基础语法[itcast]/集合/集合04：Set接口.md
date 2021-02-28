# 集合04：Set接口

[TOC]

	public interface Set<E>
	extends Collection<E>

一个**不包含重复元素**的 collection。

更确切地讲，set 不包含满足 e1.equals(e2) 的元素对 e1 和 e2，并且**最多包含一个 null 元素**。

正如其名称所暗示的，此接口模仿了数学上的 set 抽象。 

在所有构造方法以及 add、equals 和 hashCode 方法的协定上，Set 接口还加入了其他规定，这些规定超出了从 Collection 接口所继承的内容。出于方便考虑，它还包括了其他继承方法的声明（这些声明的规范已经专门针对 Set 接口进行了修改，但是没有包含任何其他的规定）。 

对这些构造方法的其他规定是（不要奇怪），所有构造方法必须创建一个不包含重复元素的 set（正如上面所定义的）。 

注：**如果将可变对象用作 set 元素，那么必须极其小心**。如果对象是 set 中某个元素，以一种影响 equals 比较的方式改变对象的值，那么 set 的行为就是不确定的。此项禁止的一个特殊情况是不允许某个 set 包含其自身作为元素。 

某些 set 实现对其所包含的元素有所限制。例如，某些实现禁止 null 元素，而某些则对其元素的类型所有限制。试图添加不合格的元素会抛出未经检查的异常，通常是 NullPointerException 或 ClassCastException。

试图查询不合格的元素是否存在可能会抛出异常，也可能简单地返回 false；某些实现会采用前一种行为，而某些则采用后者。概括地说，试图对不合格元素执行操作时，如果完成该操作后不会导致在 set 中插入不合格的元素，则该操作可能抛出一个异常，也可能成功，这取决于实现的选择。此接口的规范中将这样的异常标记为“可选”。 

```java
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

        // boolean add(E e)如果 set 中尚未存在指定的元素，则添加此元素（可选操作）。
        //如果 set 尚未包含指定的元素，则返回 true
        //如果此 set 已经包含该元素，则该调用不改变此 set 并返回 false。
        set.add("hello");
        set.add("java");
        set.add("world");
        System.out.println("add:"+set.add("python")); //add:true
        System.out.println("add:"+set.add("java")); //add:false

        //boolean remove(Object o)如果 set 中存在指定的元素，则将其移除（可选操作）。
        //如果此 set 包含指定的对象，则返回 true
        System.out.println("remove:"+set.remove("python")); //remove:true

        //boolean contains(Object o)如果 set 包含指定的元素，则返回 true。
        System.out.println("contains:"+set.contains("hello"));  //contains:true
        System.out.println("contains:"+set.contains("aaaaa"));  //contains:false

        //int size()返回 set 中的元素数（其容量）。
        System.out.println("size:"+set.size());  //size:3

        //boolean isEmpty()如果 set 不包含元素，则返回 true。
        System.out.println("isEmpty:"+set.isEmpty());  //isEmpty:false

        ArrayList<String> al = new ArrayList<String>();
        al.add("hello");
        al.add("world");
        al.add("scala");

        //boolean containsAll(Collection<?> c)
        // 如果此 set 包含指定 collection 的所有元素，则返回 true。
        System.out.println("containsAll:"+set.containsAll(al)); //containsAll:false

        //boolean addAll(Collection<? extends E> c)  并集
        // 如果 set 中没有指定 collection 中的所有元素，则将其添加到此 set 中（可选操作）。
//        System.out.println("addAll:"+set.addAll(al)); //addAll:true
//        System.out.println("addAll:"+set); //addAll:[java, world, scala, hello]

        //boolean retainAll(Collection<?> c)  交集
        // 仅保留 set 中那些包含在指定 collection 中的元素（可选操作）。
//        System.out.println("retainAll:"+set.retainAll(al)); //retainAll:true
//        System.out.println("retainAll:"+set); //retainAll:[world, hello]

        //boolean removeAll(Collection<?> c)  不对称差集
        // 移除 set 中那些包含在指定 collection 中的元素（可选操作）。
//        System.out.println("removeAll:"+set.removeAll(al)); //removeAll:true
//        System.out.println("removeAll:"+set); //removeAll:[java]

//-------------------------------------------------------------------------------------------
        //遍历

        // 1.增强for
        for (String s : set) {
            System.out.println(s);
            //java
            //world
            //hello
        }
        System.out.println("-----------------------");

        // 2.迭代器
        Iterator<String> its = set.iterator();
        while(its.hasNext()){
            System.out.println(its.next());
        }
        System.out.println("-----------------------");

        //3.转数组
        String[] ss = set.toArray(new String[0]);
        for(String s:ss){
            System.out.println(s);
        }
        System.out.println("-----------------------");

    }
}

```