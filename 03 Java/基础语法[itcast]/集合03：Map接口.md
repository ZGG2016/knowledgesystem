# 集合03：Map接口

## 一、Map接口

将键映射到值的对象，一个映射不能包含重复的键，每个键最多只能映射到一个值。

Map接口和Collection接口的不同

	Map是双列的，Collection是单列的
	Map的键唯一，Collection的子体系Set是唯一的
	Map集合的数据结构值针对键有效，跟值无关，Collection集合的数据结构是针对元素有效

### 1、成员方法 

添加功能

	V put(K key,V value):添加元素。这个其实还有另一个功能?先不告诉你，等会讲
	如果键是第一次存储，就直接存储元素，返回null
	如果键不是第一次存在，就用值把以前的值替换掉，返回以前的值

删除功能

	void clear():移除所有的键值对元素
	V remove(Object key)：根据键删除键值对元素，并把值返回

判断功能

	boolean containsKey(Object key)：判断集合是否包含指定的键
	boolean containsValue(Object value):判断集合是否包含指定的值
	boolean isEmpty()：判断集合是否为空

长度功能

	int size()：返回集合中的键值对的对数

```java
import java.util.HashMap;
import java.util.Map;

public class MapDemo {
	public static void main(String[] args) {
		// 创建集合对象
		Map<String, String> map = new HashMap<String, String>();

		// 添加元素
		// V put(K key,V value):添加元素。这个其实还有另一个功能?先不告诉你，等会讲
		// System.out.println("put:" + map.put("文章", "马伊俐"));
		// System.out.println("put:" + map.put("文章", "姚笛")); //返回null,或上一个值

		map.put("邓超", "孙俪");
		map.put("黄晓明", "杨颖");
		map.put("周杰伦", "蔡依林");
		map.put("刘恺威", "杨幂");

		// void clear():移除所有的键值对元素
		// map.clear();

		// V remove(Object key)：根据键删除键值对元素，并把值返回
		// System.out.println("remove:" + map.remove("黄晓明"));
		// System.out.println("remove:" + map.remove("黄晓波"));

		// boolean containsKey(Object key)：判断集合是否包含指定的键
		// System.out.println("containsKey:" + map.containsKey("黄晓明"));
		// System.out.println("containsKey:" + map.containsKey("黄晓波"));

		// boolean isEmpty()：判断集合是否为空
		// System.out.println("isEmpty:"+map.isEmpty());
		
		//int size()：返回集合中的键值对的对数
		System.out.println("size:"+map.size());

		// 输出集合名称
		System.out.println("map:" + map);
	}
}
```
获取功能

	Set<Map.Entry<K,V>> entrySet():???
	V get(Object key):根据键获取值
	Set<K> keySet():获取集合中所有键的集合
	Collection<V> values():获取集合中所有值的集合

```java
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class MapDemo2 {
	public static void main(String[] args) {
		// 创建集合对象
		Map<String, String> map = new HashMap<String, String>();

		// 创建元素并添加元素
		map.put("邓超", "孙俪");
		map.put("黄晓明", "杨颖");
		map.put("周杰伦", "蔡依林");
		map.put("刘恺威", "杨幂");

		// V get(Object key):根据键获取值
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
### 2、遍历

**方式1：根据键找值**

```java
package cn.itcast_01;

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

## 二、HashMap类

键是哈希表结构，可以保证键的唯一性。并允许使用 null 值和 null 键。

### 1、HashMap案例

HashMap<Integer,String>

```java
package cn.itcast_02;

import java.util.HashMap;
import java.util.Set;

/*
 * HashMap<Integer,String>
 * 键：Integer
 * 值：String
 */
public class HashMapDemo2 {
	public static void main(String[] args) {
		// 创建集合对象
		HashMap<Integer, String> hm = new HashMap<Integer, String>();

		// 创建元素并添加元素
		// Integer i = new Integer(27);
		// Integer i = 27;
		// String s = "林青霞";
		// hm.put(i, s);

		hm.put(27, "林青霞");
		hm.put(30, "风清扬");
		hm.put(28, "刘意");
		hm.put(29, "林青霞");

		// 下面的写法是八进制，但是不能出现8以上的单个数据
		// hm.put(003, "hello");
		// hm.put(006, "hello");
		// hm.put(007, "hello");
		// hm.put(008, "hello");

		// 遍历
		Set<Integer> set = hm.keySet();
		for (Integer key : set) {
			String value = hm.get(key);
			System.out.println(key + "---" + value);
		}

		// 下面这种方式仅仅是集合的元素的字符串表示
		// System.out.println("hm:" + hm);
	}
}

```

HashMap<String,Student>

```java
package cn.itcast_02;

import java.util.HashMap;
import java.util.Set;

/*
 * HashMap<String,Student>
 * 键：String	学号
 * 值：Student 学生对象
 */
public class HashMapDemo3 {
	public static void main(String[] args) {
		// 创建集合对象
		HashMap<String, Student> hm = new HashMap<String, Student>();

		// 创建学生对象
		Student s1 = new Student("周星驰", 58);
		Student s2 = new Student("刘德华", 55);
		Student s3 = new Student("梁朝伟", 54);
		Student s4 = new Student("刘嘉玲", 50);

		// 添加元素
		hm.put("9527", s1);
		hm.put("9522", s2);
		hm.put("9524", s3);
		hm.put("9529", s4);

		// 遍历
		Set<String> set = hm.keySet();
		for (String key : set) {
			// 注意了：这次值不是字符串了
			// String value = hm.get(key);
			Student value = hm.get(key);
			System.out.println(key + "---" + value.getName() + "---"
					+ value.getAge());
		}
	}
}

```

```java
package cn.itcast_02;

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
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + age;
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		return result;
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

HashMap<Student,String>

```java
package cn.itcast_02;

import java.util.HashMap;
import java.util.Set;

/*
 * HashMap<Student,String>
 * 键：Student
 * 		要求：如果两个对象的成员变量值都相同，则为同一个对象。
 * 值：String
 */
public class HashMapDemo4 {
	public static void main(String[] args) {
		// 创建集合对象
		HashMap<Student, String> hm = new HashMap<Student, String>();

		// 创建学生对象
		Student s1 = new Student("貂蝉", 27);
		Student s2 = new Student("王昭君", 30);
		Student s3 = new Student("西施", 33);
		Student s4 = new Student("杨玉环", 35);
		Student s5 = new Student("貂蝉", 27);

		// 添加元素
		hm.put(s1, "8888");
		hm.put(s2, "6666");
		hm.put(s3, "5555");
		hm.put(s4, "7777");
		hm.put(s5, "9999");

		// 遍历
		Set<Student> set = hm.keySet();
		for (Student key : set) {
			String value = hm.get(key);
			System.out.println(key.getName() + "---" + key.getAge() + "---"
					+ value);
		}
	}
}
```
### 2、LinkedHashMap类

Map 接口的哈希表和链接列表实现，具有可预知的迭代顺序。

```java
import java.util.LinkedHashMap;
import java.util.Set;

/*
 * LinkedHashMap:是Map接口的哈希表和链接列表实现，具有可预知的迭代顺序。
 * 由哈希表保证键的唯一性
 * 由链表保证键盘的有序(存储和取出的顺序一致)
 */
public class LinkedHashMapDemo {
	public static void main(String[] args) {
		// 创建集合对象
		LinkedHashMap<String, String> hm = new LinkedHashMap<String, String>();

		// 创建并添加元素
		hm.put("2345", "hello");
		hm.put("1234", "world");
		hm.put("3456", "java");
		hm.put("1234", "javaee");
		hm.put("3456", "android");

		// 遍历
		Set<String> set = hm.keySet();
		for (String key : set) {
			String value = hm.get(key);
			System.out.println(key + "---" + value);
		}
	}
}

```

## 三、TreeMap类 

键是红黑树结构，可以保证键的排序和唯一性

### 1、示例

HashMap<String,String>

```java

import java.util.Set;
import java.util.TreeMap;

/*
 * TreeMap:是基于红黑树的Map接口的实现。
 * 
 * HashMap<String,String>
 * 键：String
 * 值：String
 */
public class TreeMapDemo {
	public static void main(String[] args) {
		// 创建集合对象
		TreeMap<String, String> tm = new TreeMap<String, String>();

		// 创建元素并添加元素
		tm.put("hello", "你好");
		tm.put("world", "世界");
		tm.put("java", "爪哇");
		tm.put("world", "世界2");
		tm.put("javaee", "爪哇EE");

		// 遍历集合
		Set<String> set = tm.keySet();
		for (String key : set) {
			String value = tm.get(key);
			System.out.println(key + "---" + value);
		}
	}
}
```

HashMap<Student,String>

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
}

import java.util.Comparator;
import java.util.Set;
import java.util.TreeMap;

/*
 * TreeMap<Student,String>
 * 键:Student
 * 值：String
 */
public class TreeMapDemo2 {
	public static void main(String[] args) {
		// 创建集合对象
		TreeMap<Student, String> tm = new TreeMap<Student, String>(
				new Comparator<Student>() {
					@Override
					public int compare(Student s1, Student s2) {
						// 主要条件
						int num = s1.getAge() - s2.getAge();
						// 次要条件
						int num2 = num == 0 ? s1.getName().compareTo(
								s2.getName()) : num;
						return num2;
					}
				});

		// 创建学生对象
		Student s1 = new Student("潘安", 30);
		Student s2 = new Student("柳下惠", 35);
		Student s3 = new Student("唐伯虎", 33);
		Student s4 = new Student("燕青", 32);
		Student s5 = new Student("唐伯虎", 33);

		// 存储元素
		tm.put(s1, "宋朝");
		tm.put(s2, "元朝");
		tm.put(s3, "明朝");
		tm.put(s4, "清朝");
		tm.put(s5, "汉朝");

		// 遍历
		Set<Student> set = tm.keySet();
		for (Student key : set) {
			String value = tm.get(key);
			System.out.println(key.getName() + "---" + key.getAge() + "---"
					+ value);
		}
	}
}

```

### 2、练习

```java

import java.util.Scanner;
import java.util.Set;
import java.util.TreeMap;

/*
 * 需求 ："aababcabcdabcde",获取字符串中每一个字母出现的次数要求结果:a(5)b(4)c(3)d(2)e(1)
 * 
 * 分析：
 * 		A:定义一个字符串(可以改进为键盘录入)
 * 		B:定义一个TreeMap集合
 * 			键:Character
 * 			值：Integer
 * 		C:把字符串转换为字符数组
 * 		D:遍历字符数组，得到每一个字符
 * 		E:拿刚才得到的字符作为键到集合中去找值，看返回值
 * 			是null:说明该键不存在，就把该字符作为键，1作为值存储
 * 			不是null:说明该键存在，就把值加1，然后重写存储该键和值
 * 		F:定义字符串缓冲区变量
 * 		G:遍历集合，得到键和值，进行按照要求拼接
 * 		H:把字符串缓冲区转换为字符串输出
 * 
 * 录入：linqingxia
 * 结果：result:a(1)g(1)i(3)l(1)n(2)q(1)x(1)
 */
public class TreeMapDemo {
	public static void main(String[] args) {
		// 定义一个字符串(可以改进为键盘录入)
		Scanner sc = new Scanner(System.in);
		System.out.println("请输入一个字符串：");
		String line = sc.nextLine();

		// 定义一个TreeMap集合
		TreeMap<Character, Integer> tm = new TreeMap<Character, Integer>();
		
		//把字符串转换为字符数组
		char[] chs = line.toCharArray();
		
		//遍历字符数组，得到每一个字符
		for(char ch : chs){
			//拿刚才得到的字符作为键到集合中去找值，看返回值
			Integer i =  tm.get(ch);
			
			//是null:说明该键不存在，就把该字符作为键，1作为值存储
			if(i == null){
				tm.put(ch, 1);
			}else {
				//不是null:说明该键存在，就把值加1，然后重写存储该键和值
				i++;
				tm.put(ch,i);
			}
		}
		
		//定义字符串缓冲区变量
		StringBuilder sb=  new StringBuilder();
		
		//遍历集合，得到键和值，进行按照要求拼接
		Set<Character> set = tm.keySet();
		for(Character key : set){
			Integer value = tm.get(key);
			sb.append(key).append("(").append(value).append(")");
		}
		
		//把字符串缓冲区转换为字符串输出
		String result = sb.toString();
		System.out.println("result:"+result);
	}
}

```

### 3、嵌套

**HashMap嵌套HashMap**

```java
import java.util.HashMap;
import java.util.Set;

/*
 * HashMap嵌套HashMap
 * 
 * 传智播客
 * 		jc	基础班
 * 				陈玉楼		20
 * 				高跃		22
 * 		jy	就业班
 * 				李杰		21
 * 				曹石磊		23
 * 
 * 先存储元素，然后遍历元素
 */
public class HashMapDemo2 {
	public static void main(String[] args) {
		// 创建集合对象
		HashMap<String, HashMap<String, Integer>> czbkMap = new HashMap<String, HashMap<String, Integer>>();

		// 创建基础班集合对象
		HashMap<String, Integer> jcMap = new HashMap<String, Integer>();
		// 添加元素
		jcMap.put("陈玉楼", 20);
		jcMap.put("高跃", 22);
		// 把基础班添加到大集合
		czbkMap.put("jc", jcMap);

		// 创建就业班集合对象
		HashMap<String, Integer> jyMap = new HashMap<String, Integer>();
		// 添加元素
		jyMap.put("李杰", 21);
		jyMap.put("曹石磊", 23);
		// 把基础班添加到大集合
		czbkMap.put("jy", jyMap);
		
		//遍历集合
		Set<String> czbkMapSet = czbkMap.keySet();
		for(String czbkMapKey : czbkMapSet){
			System.out.println(czbkMapKey);
			HashMap<String, Integer> czbkMapValue = czbkMap.get(czbkMapKey);
			Set<String> czbkMapValueSet = czbkMapValue.keySet();
			for(String czbkMapValueKey : czbkMapValueSet){
				Integer czbkMapValueValue = czbkMapValue.get(czbkMapValueKey);
				System.out.println("\t"+czbkMapValueKey+"---"+czbkMapValueValue);
			}
		}
	}
}

```

**HashMap嵌套ArrayList**

```java
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;

/*
 *需求：
 *假设HashMap集合的元素是ArrayList。有3个。
 *每一个ArrayList集合的值是字符串。
 *元素我已经完成，请遍历。
 *结果：
 *		 三国演义
 *		 	吕布
 *		 	周瑜
 *		 笑傲江湖
 *		 	令狐冲
 *		 	林平之
 *		 神雕侠侣
 *		 	郭靖
 *		 	杨过  
 */
public class HashMapIncludeArrayListDemo {
	public static void main(String[] args) {
		// 创建集合对象
		HashMap<String, ArrayList<String>> hm = new HashMap<String, ArrayList<String>>();

		// 创建元素集合1
		ArrayList<String> array1 = new ArrayList<String>();
		array1.add("吕布");
		array1.add("周瑜");
		hm.put("三国演义", array1);

		// 创建元素集合2
		ArrayList<String> array2 = new ArrayList<String>();
		array2.add("令狐冲");
		array2.add("林平之");
		hm.put("笑傲江湖", array2);

		// 创建元素集合3
		ArrayList<String> array3 = new ArrayList<String>();
		array3.add("郭靖");
		array3.add("杨过");
		hm.put("神雕侠侣", array3);
		
		//遍历集合
		Set<String> set = hm.keySet();
		for(String key : set){
			System.out.println(key);
			ArrayList<String> value = hm.get(key);
			for(String s : value){
				System.out.println("\t"+s);
			}
		}
	}
}

```

**ArrayList嵌套HashMap**

```java
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;

/*
 ArrayList集合嵌套HashMap集合并遍历。
 需求：
 假设ArrayList集合的元素是HashMap。有3个。
 每一个HashMap集合的键和值都是字符串。
 元素我已经完成，请遍历。
 结果：
 周瑜---小乔
 吕布---貂蝉

 郭靖---黄蓉
 杨过---小龙女

 令狐冲---任盈盈
 林平之---岳灵珊
 */
public class ArrayListIncludeHashMapDemo {
	public static void main(String[] args) {
		// 创建集合对象
		ArrayList<HashMap<String, String>> array = new ArrayList<HashMap<String, String>>();

		// 创建元素1
		HashMap<String, String> hm1 = new HashMap<String, String>();
		hm1.put("周瑜", "小乔");
		hm1.put("吕布", "貂蝉");
		// 把元素添加到array里面
		array.add(hm1);

		// 创建元素1
		HashMap<String, String> hm2 = new HashMap<String, String>();
		hm2.put("郭靖", "黄蓉");
		hm2.put("杨过", "小龙女");
		// 把元素添加到array里面
		array.add(hm2);

		// 创建元素1
		HashMap<String, String> hm3 = new HashMap<String, String>();
		hm3.put("令狐冲", "任盈盈");
		hm3.put("林平之", "岳灵珊");
		// 把元素添加到array里面
		array.add(hm3);

		// 遍历
		for (HashMap<String, String> hm : array) {
			Set<String> set = hm.keySet();
			for (String key : set) {
				String value = hm.get(key);
				System.out.println(key + "---" + value);
			}
		}
	}
}

```

**多层嵌套**

```java

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;

/*
 * 为了更符合要求：
 * 		这次的数据就看成是学生对象。
 * 
 * 传智播客
 * 		bj	北京校区
 * 			jc	基础班
 * 					林青霞		27
 * 					风清扬		30
 * 			jy	就业班	
 * 					赵雅芝		28
 * 					武鑫		29
 * 		sh	上海校区
 * 			jc	基础班
 * 					郭美美		20
 * 					犀利哥		22
 * 			jy	就业班	
 * 					罗玉凤		21
 * 					马征		23
 * 		gz	广州校区
 * 			jc	基础班
 * 					王力宏		30
 * 					李静磊		32
 * 			jy	就业班	
 * 					郎朗		31
 * 					柳岩		33
 * 		xa	西安校区
 * 			jc	基础班
 * 					范冰冰		27
 * 					刘意		30
 * 			jy	就业班	
 * 					李冰冰		28
 * 					张志豪		29
 */
public class HashMapDemo {
	public static void main(String[] args) {
		// 创建大集合
		HashMap<String, HashMap<String, ArrayList<Student>>> czbkMap = new HashMap<String, HashMap<String, ArrayList<Student>>>();

		// 北京校区数据
		HashMap<String, ArrayList<Student>> bjCzbkMap = new HashMap<String, ArrayList<Student>>();
		ArrayList<Student> array1 = new ArrayList<Student>();
		Student s1 = new Student("林青霞", 27);
		Student s2 = new Student("风清扬", 30);
		array1.add(s1);
		array1.add(s2);
		ArrayList<Student> array2 = new ArrayList<Student>();
		Student s3 = new Student("赵雅芝", 28);
		Student s4 = new Student("武鑫", 29);
		array2.add(s3);
		array2.add(s4);
		bjCzbkMap.put("基础班", array1);
		bjCzbkMap.put("就业班", array2);
		czbkMap.put("北京校区", bjCzbkMap);

		// 晚上可以自己练习一下
		// 上海校区数据自己做
		// 广州校区数据自己做

		// 西安校区数据
		HashMap<String, ArrayList<Student>> xaCzbkMap = new HashMap<String, ArrayList<Student>>();
		ArrayList<Student> array3 = new ArrayList<Student>();
		Student s5 = new Student("范冰冰", 27);
		Student s6 = new Student("刘意", 30);
		array3.add(s5);
		array3.add(s6);
		ArrayList<Student> array4 = new ArrayList<Student>();
		Student s7 = new Student("李冰冰", 28);
		Student s8 = new Student("张志豪", 29);
		array4.add(s7);
		array4.add(s8);
		xaCzbkMap.put("基础班", array3);
		xaCzbkMap.put("就业班", array4);
		czbkMap.put("西安校区", xaCzbkMap);

		// 遍历集合
		Set<String> czbkMapSet = czbkMap.keySet();
		for (String czbkMapKey : czbkMapSet) {
			System.out.println(czbkMapKey);
			HashMap<String, ArrayList<Student>> czbkMapValue = czbkMap
					.get(czbkMapKey);
			Set<String> czbkMapValueSet = czbkMapValue.keySet();
			for (String czbkMapValueKey : czbkMapValueSet) {
				System.out.println("\t" + czbkMapValueKey);
				ArrayList<Student> czbkMapValueValue = czbkMapValue
						.get(czbkMapValueKey);
				for (Student s : czbkMapValueValue) {
					System.out.println("\t\t" + s.getName() + "---"
							+ s.getAge());
				}
			}
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

```

### 4、面试题

HashMap和Hashtable的区别

	Hashtable:线程安全，效率低。不允许null键和null值
	HashMap:线程不安全，效率高。允许null键和null值

List,Set,Map等接口是否都继承子Map接口

	List，Set不是继承自Map接口，它们继承自Collection接口
	Map接口本身就是一个顶层接口

## 四、Collections类 

针对集合进行操作的工具类，都是静态方法。

面试题：
	Collection和Collections的区别?
		Collection:是单列集合的顶层接口，有子接口List和Set。
		Collections:是针对集合操作的工具类，有对集合进行排序和二分查找的方法。

### 1、Collections成员方法

```java

import java.util.Collections;
import java.util.List;
import java.util.ArrayList;

/*
 * 
 * 要知道的方法
 * public static <T> void sort(List<T> list)：排序 默认情况下是自然顺序。
 * public static <T> int binarySearch(List<?> list,T key):二分查找
 * public static <T> T max(Collection<?> coll):最大值
 * public static void reverse(List<?> list):反转
 * public static void shuffle(List<?> list):随机置换
 */
public class CollectionsDemo {
	public static void main(String[] args) {
		// 创建集合对象
		List<Integer> list = new ArrayList<Integer>();

		// 添加元素
		list.add(30);
		list.add(20);
		list.add(50);
		list.add(10);
		list.add(40);

		System.out.println("list:" + list);

		// public static <T> void sort(List<T> list)：排序 默认情况下是自然顺序。
		// Collections.sort(list);
		// System.out.println("list:" + list);
		// [10, 20, 30, 40, 50]

		// public static <T> int binarySearch(List<?> list,T key):二分查找
		// System.out
		// .println("binarySearch:" + Collections.binarySearch(list, 30));
		// System.out.println("binarySearch:"
		// + Collections.binarySearch(list, 300));

		// public static <T> T max(Collection<?> coll):最大值
		// System.out.println("max:"+Collections.max(list));

		// public static void reverse(List<?> list):反转
		// Collections.reverse(list);
		// System.out.println("list:" + list);
		
		//public static void shuffle(List<?> list):随机置换
		Collections.shuffle(list);
		System.out.println("list:" + list);
	}
}

```

### 2、Collections排序

```java
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/*
 * Collections可以针对ArrayList存储基本包装类的元素排序，存储自定义对象可不可以排序呢?
 */
public class CollectionsDemo {
	public static void main(String[] args) {
		// 创建集合对象
		List<Student> list = new ArrayList<Student>();

		// 创建学生对象
		Student s1 = new Student("林青霞", 27);
		Student s2 = new Student("风清扬", 30);
		Student s3 = new Student("刘晓曲", 28);
		Student s4 = new Student("武鑫", 29);
		Student s5 = new Student("林青霞", 27);

		// 添加元素对象
		list.add(s1);
		list.add(s2);
		list.add(s3);
		list.add(s4);
		list.add(s5);

		// 排序
		// 自然排序
		// Collections.sort(list);
		// 比较器排序
		// 如果同时有自然排序和比较器排序，以比较器排序为主
		Collections.sort(list, new Comparator<Student>() {
			@Override
			public int compare(Student s1, Student s2) {
				int num = s2.getAge() - s1.getAge();
				int num2 = num == 0 ? s1.getName().compareTo(s2.getName())
						: num;
				return num2;
			}
		});

		// 遍历集合
		for (Student s : list) {
			System.out.println(s.getName() + "---" + s.getAge());
		}
	}
}

package cn.itcast_02;

/**
 * @author Administrator
 * 
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
		int num = this.age - s.age;
		int num2 = num == 0 ? this.name.compareTo(s.name) : num;
		return num2;
	}
}

```
