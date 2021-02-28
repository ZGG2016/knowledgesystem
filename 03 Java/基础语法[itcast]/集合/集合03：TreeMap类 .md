# 集合10：TreeMap类 

[TOC]

    public class TreeMap<K,V>
    extends AbstractMap<K,V>
    implements NavigableMap<K,V>, Cloneable, Serializable

**基于红黑树（Red-Black tree）的 NavigableMap 实现**。

该映射**根据其键的自然顺序进行排序，或者根据创建映射时提供的 Comparator 进行排序**。，具体取决于使用的构造方法。 

此实现为 containsKey、get、put 和 remove 操作提供受保证的 log(n) 时间开销。这些算法是 Cormen、Leiserson 和 Rivest 的 Introduction to Algorithms 中的算法的改编。 

注意，如果要正确实现 Map 接口，则有序映射所保持的顺序（无论是否明确提供了比较器）都必须与 equals 一致。（关于与 equals 一致 的精确定义，请参阅 Comparable 或 Comparator）。

这是因为 Map 接口是按照 equals 操作定义的，但有序映射使用它的 compareTo（或 compare）方法对所有键进行比较，因此从有序映射的观点来看，此方法认为相等的两个键就是相等的。

即使排序与 equals 不一致，有序映射的行为仍然是定义良好的，只不过没有遵守 Map 接口的常规协定。 

注意，此实现**不是同步的**。如果多个线程同时访问一个映射，并且其中至少一个线程从结构上修改了该映射，则其必须 外部同步。（结构上的修改是指添加或删除一个或多个映射关系的操作；仅改变与现有键关联的值不是结构上的修改。）这一般是通过对自然封装该映射的对象执行同步操作来完成的。如果不存在这样的对象，则应该**使用 Collections.synchronizedSortedMap 方法**来“包装”该映射。最好在创建时完成这一操作，以防止对映射进行意外的不同步访问，如下所示：

	SortedMap m = Collections.synchronizedSortedMap(new TreeMap(...));

collection（由此类所有的“collection 视图方法”返回）的 iterator 方法返回的迭代器都是快速失败 的：在迭代器创建之后，如果从结构上对映射进行修改，除非通过迭代器自身的 remove 方法，否则在其他任何时间以任何方式进行修改都将导致迭代器抛出 ConcurrentModificationException。因此，对于并发的修改，迭代器很快就完全失败，而不会冒着在将来不确定的时间发生不确定行为的风险。 

注意，迭代器的快速失败行为无法得到保证，一般来说，当存在不同步的并发修改时，不可能作出任何肯定的保证。快速失败迭代器尽最大努力抛出 ConcurrentModificationException。因此，编写依赖于此异常的程序的做法是错误的，正确做法是：迭代器的快速失败行为应该仅用于检测 bug。 

此类及其视图中的方法返回的所有 Map.Entry 对都表示生成它们时的映射关系的快照。它们不支持 Entry.setValue 方法。（不过要注意的是，使用 put 更改相关映射中的映射关系是有可能的。） 


## 1、构造方法

```java
/*
* TreeMap:构造方法
* */
public class TreeMapDemo01 {
    public static void main(String[] args) {
        // 1.构造方法。具体描述见api

        //（1）public TreeMap()使用键的自然顺序构造一个新的、空的树映射。
        TreeMap<String, String> tm1 = new TreeMap<String, String>();
/*
  （2）public TreeMap(Map<? extends K,? extends V> m)
      构造一个与给定映射具有相同映射关系的新的树映射，该映射根据其键的自然顺序 进行排序。
  （3）public TreeMap(SortedMap<K,? extends V> m)
      构造一个与指定有序映射具有相同映射关系和相同排序顺序的新的树映射。
 */

    //public TreeMap(Comparator<? super K> comparator)
    // 构造一个新的、空的树映射，该映射根据给定比较器进行排序。

        TreeMap<String, String> tm2 = new TreeMap<String, String>(
                new Comparator<String>() {
                    @Override
                    public int compare(String o1, String o2) {
                        return o1.length()-o2.length();
                    }
                }
        );

        // 创建元素并添加元素
        tm1.put("c", "你好");
        tm1.put("bbb", "世界");
        tm1.put("aa", "爪哇");
        tm1.put("ddd", "爪哇EE");

        tm2.put("aaaa", "你好");
        tm2.put("b", "世界");
        tm2.put("ccc", "爪哇");
        tm2.put("dd", "爪哇EE");

        System.out.println(tm1); //{aa=爪哇, bbb=世界, c=你好, ddd=爪哇EE}
        System.out.println("----------------");
        System.out.println(tm2); //{b=世界, dd=爪哇EE, ccc=爪哇, aaaa=你好}

    }
}

```

## 2、成员方法

```java
/*
* TreeMap:成员方法
* */
public class TreeMapDemo02 {
    public static void main(String[] args) {
        // 2.成员方法。具体描述见api
        TreeMap<Integer, String> tm1 = new TreeMap<Integer, String>();
        TreeMap<String, String> tm2 = new TreeMap<String, String>(
                new Comparator<String>() {
                    @Override
                    public int compare(String o1, String o2) {
                        return o1.length()-o2.length();
                    }
                }
        );
        for(int i=0;i<10;i++){
            tm1.put(i,"hello"+i);
        }

        //逆序输出
        /*
         * public NavigableSet<K> descendingKeySet()
         *       返回此映射中所包含键的逆序 NavigableSet 视图
         *
         * public NavigableMap<K,V> descendingMap()
         *       返回此映射中所包含映射关系的逆序视图。
         * */
        NavigableSet<Integer> nbs = tm1.descendingKeySet();
        System.out.println("descendingKeySet:");
        for(Integer nb:nbs){
            System.out.println(nb+":"+tm1.get(nb));
            //9:hello9
            //8:hello8
            //7:hello7
            //...
        }

        System.out.println("---------------------------");

        NavigableMap<Integer, String>  nm = tm1.descendingMap();
        Set<Integer> ss = nm.keySet();
        System.out.println("descendingMap:");
        for(Integer s:ss){
            System.out.println(s+":"+tm1.get(s));
        }
        System.out.println("---------------------------");

        //获取元素1
        /*
        * public Map.Entry<K,V> ceilingEntry(K key)
        *       返回：最小键大于等于 key 的条目；如果不存在这样的键，则返回 null
        * public K ceilingKey(K key)
        *       返回大于等于给定键的最小键；如果不存在这样的键，则返回 null。
        * public Map.Entry<K,V> higherEntry(K key)
        *       返回：最小键大于 key 的条目；如果不存在这样的键，则返回 null
        * public K higherKey(K key)
        *       返回严格大于给定键的最小键；如果不存在这样的键，则返回 null。
        * */
        Map.Entry<Integer, String> ce = tm1.ceilingEntry(5);
        System.out.println("ceilingEntry:"+ce); //5=hello5

        Integer ck = tm1.ceilingKey(5);
        System.out.println("ceilingKey:"+ck); //5

        Map.Entry<Integer, String> he = tm1.higherEntry(5);
        System.out.println("higherEntry:"+he); //6=hello6

        Integer hk = tm1.higherKey(5);
        System.out.println("higherKey:"+hk); //6

        //获取元素2
        /*
        * public Map.Entry<K,V> firstEntry()
        *       返回一个与此映射中的最小键关联的键-值映射关系；如果映射为空，则返回 null
        * public Map.Entry<K,V> floorEntry(K key)
        *       返回一个键-值映射关系，它与小于等于给定键的最大键关联；如果不存在这样的键，则返回 null。
        * public K floorKey(K key)从接口 NavigableMap 复制的描述
        *       返回小于等于给定键的最大键；如果不存在这样的键，则返回 null。
        * public Map.Entry<K,V> higherEntry(K key)
        * public K higherKey(K key)
        * public K firstKey()
        * public Map.Entry<K,V> lastEntry()
        * public K lastKey()
        * */
        Map.Entry<Integer, String> fme = tm1.firstEntry();
        System.out.println("firstEntry:"+fme);  //0=hello0
        System.out.println("firstKey:"+tm1.firstKey()); //0
        System.out.println("lastEntry:"+tm1.lastEntry()); //9=hello9
        System.out.println("lastKey:"+tm1.lastKey()); //9
//        System.out.println("lastKey:"+tm2.lastKey());//java.util.NoSuchElementException

        System.out.println("---------------------------");

        //移除元素
        /*
        * public Map.Entry<K,V> pollFirstEntry()
        *       移除并返回与此映射中的最小键关联的键-值映射关系；如果映射为空，则返回 null。
        * public Map.Entry<K,V> pollLastEntry()
        *       移除并返回与此映射中的最大键关联的键-值映射关系；如果映射为空，则返回 null。
        * public V remove(Object key)
        *        如果此 TreeMap 中存在该键的映射关系，则将其删除。
         * */

        Map.Entry<Integer, String> pme1 = tm1.pollFirstEntry();
        System.out.println("pollLastEntry:"+pme1); //pollLastEntry:0=hello0
//pollFirstEntry:{1=hello1, 2=hello2, 3=hello3, 4=hello4, 5=hello5, 6=hello6, 7=hello7, 8=hello8, 9=hello9}
        System.out.println("pollFirstEntry:"+tm1);

        Map.Entry<Integer, String> pme2 = tm1.pollLastEntry();
        System.out.println("pollLastEntry:"+pme2); //pollLastEntry:9=hello9
        //pollLastEntry:{1=hello1, 2=hello2, 3=hello3, 4=hello4, 5=hello5, 6=hello6, 7=hello7, 8=hello8}
        System.out.println("pollLastEntry:"+tm1);

        String rmp = tm1.remove(0);
        System.out.println("remove:"+rmp);
        System.out.println("---------------------------");

        //取其子集
        /*
        public NavigableMap<K,V> subMap(K fromKey,boolean fromInclusive,
                                K toKey,boolean toInclusive)
                    返回此映射的部分视图，其键的范围从 fromKey 到 toKey。
        public SortedMap<K,V> subMap(K fromKey,K toKey)
                    返回此映射的部分视图，其键值的范围从 fromKey（包括）到 toKey（不包括）。（
        public SortedMap<K,V> tailMap(K fromKey)
                    返回此映射的部分视图，其键大于等于 fromKey。
        public NavigableMap<K,V> tailMap(K fromKey,boolean inclusive)
                    返回此映射的部分视图，其键大于（或等于，如果 inclusive 为 true）fromKey。
        public SortedMap<K,V> headMap(K toKey)
                    返回此映射的部分视图，其键值严格小于 toKey。
        public NavigableMap<K,V> headMap(K toKey,boolean inclusive)
                    返回此映射的部分视图，其键小于（或等于，如果 inclusive 为 true）toKey。
        * */
        NavigableMap<Integer, String> sm = tm1.subMap(0,true,3,false);
        Set<Integer> ssm = sm.keySet();
        System.out.println("subMap:");
        for(Integer s:ssm){
            System.out.println(s+":"+tm1.get(s));
            //subMap:
            //1:hello1
            //2:hello2
        }
        System.out.println("---------------------------");


        //public Comparator<? super K> comparator()
        //返回对此映射中的键进行排序的比较器；如果此映射使用键的自然顺序，则返回 null。
        Comparator c1 = tm1.comparator();
        Comparator c2 = tm2.comparator();
        System.out.println("comparator:"+c1+":"+c2); //null:javabase.map.TreeMapDemo02$1@4c98385c

        System.out.println("---------------------------");
    }
}

```

## 3、遍历

```java
/*
 * TreeMap:遍历
 * */
public class TreeMapDemo03 {
    public static void main(String[] args) {
        TreeMap<String, String> tm = new TreeMap<String, String>();
        tm.put("hello", "你好");
        tm.put("world", "世界");
        tm.put("java", "爪哇");
        tm.put("javaee", "爪哇EE");

        // 1.正序
        Set<String> set = tm.keySet();
        for (String key : set) {
            String value = tm.get(key);
            System.out.println(key + "---" + value);
        }
        System.out.println("---------------------------");

        //2.正序
        Set<Map.Entry<String, String>> mes = tm.entrySet();
        for(Map.Entry<String, String> me:mes){
            System.out.println(me.getKey()+":"+me.getValue());
        }
        System.out.println("---------------------------");

        //3.逆序
        NavigableSet<String> nbs = tm.descendingKeySet();
        for(String nb:nbs){
            System.out.println(nb+":"+tm.get(nb));
        }

        System.out.println("---------------------------");

        //4.逆序
        NavigableMap<String, String> nm = tm.descendingMap();
        Set<String> ss = nm.keySet();
        for(String s:ss){
            System.out.println(s+":"+tm.get(s));
        }
    }
}

```

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
## 4、练习

```java

import java.util.Scanner;
import java.util.Set;
import java.util.TreeMap;

/*
 * 需求 ："aababcabcdabcde",获取字符串中每一个字母出现的次数要求结果:a(5)b(4)c(3)d(2)e(1)
 * 
 * 分析：
 *      A:定义一个字符串(可以改进为键盘录入)
 *      B:定义一个TreeMap集合
 *          键:Character
 *          值：Integer
 *      C:把字符串转换为字符数组
 *      D:遍历字符数组，得到每一个字符
 *      E:拿刚才得到的字符作为键到集合中去找值，看返回值
 *          是null:说明该键不存在，就把该字符作为键，1作为值存储
 *          不是null:说明该键存在，就把值加1，然后重写存储该键和值
 *      F:定义字符串缓冲区变量
 *      G:遍历集合，得到键和值，进行按照要求拼接
 *      H:把字符串缓冲区转换为字符串输出
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