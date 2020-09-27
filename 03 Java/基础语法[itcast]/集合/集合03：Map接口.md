# 集合07：Map接口

[TOC]

## 1、Map接口

	public interface Map<K,V>

将键映射到值的对象。**一个映射不能包含重复的键**；每个键最多只能映射到一个值。 

Map 接口提供三种collection 视图，允许以**键集、值集或键-值映射关系集**的形式查看某个映射的内容。

映射顺序定义为迭代器在映射的collection视图上返回其元素的顺序。**某些映射实现可明确保证其顺序，如TreeMap类；另一些映射实现则不保证顺序，如HashMap类**。

注：将可变对象用作映射键时必须格外小心。

Map接口和Collection接口的不同：

	Map是双列的，Collection是单列的
	Map的键唯一，Collection的子体系Set是唯一的
	Map集合的数据结构值针对键有效，跟值无关，Collection集合的数据结构是针对元素有效

### 1.1、方法测试

```java
/*
* Map:基础方法测试
* */
public class MapDemo01 {
    public static void main(String[] args) {
        // 创建集合对象
        Map<String, String> map = new HashMap<String, String>();

        // 添加元素
        // V put(K key,V value):添加元素。如果此映射以前包含一个该键的映射关系，则用指定值替换旧值
        //返回以前与 key 关联的值，如果没有针对 key 的映射关系，则返回 null。
        System.out.println("put:" + map.put("文章", "马伊俐"));  //put:null
        System.out.println("put:" + map.put("文章", "姚笛")); //put:马伊俐

        map.put("邓超", "孙俪");
        map.put("黄晓明", "杨颖");
        map.put("周杰伦", "蔡依林");
        map.put("刘恺威", "杨幂");

        // void clear():移除所有的键值对元素
        // map.clear();

        // V remove(Object key)：根据键删除键值对元素，并把值返回
        //返回此映射中以前关联该键的值，如果此映射不包含该键的映射关系，则返回 null。
         System.out.println("remove:" + map.remove("黄晓明"));  //remove:杨颖
         System.out.println("remove:" + map.remove("黄晓波"));  //remove:null

        // boolean containsKey(Object key)：判断集合是否包含指定的键
         System.out.println("containsKey:" + map.containsKey("黄晓明")); //containsKey:false
         System.out.println("containsKey:" + map.containsKey("黄晓波")); //containsKey:false

        // boolean isEmpty()：判断集合是否为空
         System.out.println("isEmpty:"+map.isEmpty()); //isEmpty:false

        //int size()：返回集合中的键值对的对数
        System.out.println("size:"+map.size()); //size:4

        // 输出集合名称
        System.out.println("map:" + map); //map:{邓超=孙俪, 文章=姚笛, 周杰伦=蔡依林, 刘恺威=杨幂}

    }
}
```

```java
/*
 * Map:获取方法测试
 * */
public class MapDemo02 {
    public static void main(String[] args) {
        Map<String, String> map = new HashMap<String, String>();
        map.put("邓超", "孙俪");
        map.put("黄晓明", "杨颖");
        map.put("周杰伦", "蔡依林");
        map.put("刘恺威", "杨幂");

        // V get(Object key):返回指定键所映射的值；如果此映射不包含该键的映射关系，则返回 null。
        //如果此映射允许 null 值，则返回 null 值并不一定 表示该映射不包含该键的映射关系；
        // 也可能该映射将该键显示地映射到 null。使用 containsKey 操作可区分这两种情况。
        System.out.println("get:" + map.get("周杰伦"));
        System.out.println("get:" + map.get("周杰")); // 返回null
        System.out.println("----------------------");

        // Set<K> keySet():获取集合中所有键的集合
        Set<String> set = map.keySet();
        for (String key : set) {
            System.out.println(key);
        }
        System.out.println("----------------------");

        // Collection<V> values():获取集合中所有值的集合
        Collection<String> con = map.values();
        for (String value : con) {
            System.out.println(value);
        }
    }
}
```

### 1.2、遍历

**方式1：根据键找值**

```java
//package javabase.map.MapDemo02;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/*
 * Map集合的遍历。
 * Map -- 夫妻对
 * 思路：
 * 		A:把所有的丈夫给集中起来。
 * 		B:遍历丈夫的集合，获取得到每一个丈夫。
 * 		C:让丈夫去找自己的妻子。
 * 
 * 转换：
 * 		A:获取所有的键
 * 		B:遍历键的集合，获取得到每一个键
 * 		C:根据键去找值
 */
public class MapDemo3 {
	public static void main(String[] args) {
		// 创建集合对象
		Map<String, String> map = new HashMap<String, String>();

		// 创建元素并添加到集合
		map.put("杨过", "小龙女");
		map.put("郭靖", "黄蓉");
		map.put("杨康", "穆念慈");
		map.put("陈玄风", "梅超风");

		// 遍历
		// 获取所有的键
		Set<String> set = map.keySet();
		// 遍历键的集合，获取得到每一个键
		for (String key : set) {
			// 根据键去找值
			String value = map.get(key);
			System.out.println(key + "---" + value);
		}
	}
}
```

**方式2：根据键值对对象找键和值**

```java
//package javabase.map.MapDemo02;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/*
 * Map集合的遍历。
 * Map -- 夫妻对
 * 
 * 思路：
 * 		A:获取所有结婚证的集合
 * 		B:遍历结婚证的集合，得到每一个结婚证
 * 		C:根据结婚证获取丈夫和妻子
 * 
 * 转换：
 * 		A:获取所有键值对对象的集合
 * 		B:遍历键值对对象的集合，得到每一个键值对对象
 * 		C:根据键值对对象获取键和值
 * 
 * 这里面最麻烦的就是键值对对象如何表示呢?
 * 看看我们开始的一个方法：
 * 		Set<Map.Entry<K,V>> entrySet()：返回的是键值对对象的集合
 */
public class MapDemo4 {
	public static void main(String[] args) {
		// 创建集合对象
		Map<String, String> map = new HashMap<String, String>();

		// 创建元素并添加到集合
		map.put("杨过", "小龙女");
		map.put("郭靖", "黄蓉");
		map.put("杨康", "穆念慈");
		map.put("陈玄风", "梅超风");

		// 获取所有键值对对象的集合
		Set<Map.Entry<String, String>> set = map.entrySet();
		// 遍历键值对对象的集合，得到每一个键值对对象
		for (Map.Entry<String, String> me : set) {
			// 根据键值对对象获取键和值
			String key = me.getKey();
			String value = me.getValue();
			System.out.println(key + "---" + value);
		}
	}
}
```

## 2、Map.Entry<K,V>接口

public static interface Map.Entry<K,V>

映射项（键-值对）。

Map.entrySet 方法返回映射的 collection 视图，其中的元素属于此类。

获得映射项引用的唯一 方法是通过此 collection 视图的迭代器来实现。这些 Map.Entry 对象仅在迭代期间有效；更确切地讲，如果在迭代器返回项之后修改了底层映射，则某些映射项的行为是不确定的，除了通过 setValue 在映射项上执行操作之外。 

## 3、面试题

HashMap和Hashtable的区别

    Hashtable:线程安全，效率低。不允许null键和null值
    HashMap:线程不安全，效率高。允许null键和null值

List,Set,Map等接口是否都继承子Map接口

    List，Set不是继承自Map接口，它们继承自Collection接口
    Map接口本身就是一个顶层接口