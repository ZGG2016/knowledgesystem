# 类：Arrays、Integer、Character

## 一、Arrays类

针对数组进行操作的工具类。提供了排序，查找等功能。

### 1、成员方法

public static String toString(int[] a) 把数组转成字符串

public static void sort(int[] a) 对数组进行排序

public static int binarySearch(int[] a,int key) 二分查找
   

```
import java.util.Arrays;

public class ArraysDemo {
	public static void main(String[] args) {
		//定义一个数组
		int[] arr = { 24, 69, 80, 57, 13 };

		//public static String toString(int[] a) 把数组转成字符串
		System.out.println("排序前：" + Arrays.toString(arr));

		//public static void sort(int[] a)  对数组进行排序
		Arrays.sort(arr);
		System.out.println("排序后：" + Arrays.toString(arr));

		//[13, 24, 57, 69, 80]
		//public static int binarySearch(int[] a,int key) 二分查找
		System.out.println("binarySearch:" + Arrays.binarySearch(arr, 57));
		System.out.println("binarySearch:" + Arrays.binarySearch(arr, 577));
	}
}
```

   public static String toString(int[] a)源码解析    
   
```
int[] arr = { 24, 69, 80, 57, 13 };
System.out.println("排序前：" + Arrays.toString(arr));

public static String toString(int[] a) {
	//a -- arr -- { 24, 69, 80, 57, 13 }

    if (a == null)
        return "null"; //说明数组对象不存在
    int iMax = a.length - 1; //iMax=4;
    if (iMax == -1)
        return "[]"; //说明数组存在,但是没有元素。

    StringBuilder b = new StringBuilder();
    b.append('['); //"["
    for (int i = 0; ; i++) {
        b.append(a[i]); //"[24, 69, 80, 57, 13"
        if (i == iMax)
        	//"[24, 69, 80, 57, 13]"
            return b.append(']').toString();
        b.append(", "); //"[24, 69, 80, 57, "
    }
}
```
   public static int binarySearch(int[] a,int key)源码解析    
```
int[] arr = {13, 24, 57, 69, 80};
System.out.println("binarySearch:" + Arrays.binarySearch(arr, 577));

public static int binarySearch(int[] a, int key) {
	//a -- arr -- {13, 24, 57, 69, 80}
	//key -- 577
    return binarySearch0(a, 0, a.length, key);
}

private static int binarySearch0(int[] a, int fromIndex, int toIndex,
                                 int key) {
    //a -- arr --  {13, 24, 57, 69, 80}
    //fromIndex -- 0
    //toIndex -- 5
    //key -- 577                           
                                 
                                 
    int low = fromIndex; //low=0
    int high = toIndex - 1; //high=4

    while (low <= high) {
        int mid = (low + high) >>> 1; //mid=2,mid=3,mid=4
        int midVal = a[mid]; //midVal=57,midVal=69,midVal=80

        if (midVal < key)
            low = mid + 1; //low=3,low=4,low=5
        else if (midVal > key)
            high = mid - 1;
        else
            return mid; // key found
    }
    return -(low + 1);  // key not found.
}
```
## 二、基本数据类型封装

将基本数据类型封装成对象的好处在于可以在对象中定义更多的功能方法操作该数据。

常用的操作之一：用于基本数据类型与字符串之间的转换。

基本类型和包装类的对应

	byte 			Byte
	short			Short
	int				Integer
	long			Long
	float			Float
	double			Double
	char			Character
	boolean			Boolean

```
public static void main(String[] args) {
		
	// public static String toBinaryString(int i)
	System.out.println(Integer.toBinaryString(100));
	// public static String toOctalString(int i)
	System.out.println(Integer.toOctalString(100));
	// public static String toHexString(int i)
	System.out.println(Integer.toHexString(100));

	// public static final int MAX_VALUE
	System.out.println(Integer.MAX_VALUE);
	// public static final int MIN_VALUE
	System.out.println(Integer.MIN_VALUE);
	}
```

## 三、Integer类

Integer 类在对象中包装了一个基本类型 int 的值。

该类提供了多个方法，能在 int 类型和 String 类型之间互相转换，
还提供了处理 int 类型时非常有用的其他一些常量和方法。

	static int MAX_VALUE 
			  值为 231－1 的常量，它表示 int 类型能够表示的最大值。 
	static int MIN_VALUE 
			  值为 －231 的常量，它表示 int 类型能够表示的最小值。 


### 1、构造方法

public Integer(int value)

public Integer(String s)
		注意：这个字符串必须是由数字字符组成

```
public class IntegerDemo {
	public static void main(String[] args) {
		// 方式1
		int i = 100;
		Integer ii = new Integer(i);
		System.out.println("ii:" + ii);

		// 方式2
		String s = "100";
		// NumberFormatException
		// String s = "abc";
		Integer iii = new Integer(s);
		System.out.println("iii:" + iii);
	}
}

```

### 2、int类型和String类型的相互转换


int -- String：String.valueOf(number)

String -- int：Integer.parseInt(s)

```
public class IntegerDemo {
	public static void main(String[] args) {
		// int -- String
		int number = 100;
		// 方式1
		String s1 = "" + number;
		System.out.println("s1:" + s1);
		// 方式2
		String s2 = String.valueOf(number);
		System.out.println("s2:" + s2);
		// 方式3
		// int -- Integer -- String
		Integer i = new Integer(number);
		String s3 = i.toString();
		System.out.println("s3:" + s3);
		// 方式4
		// public static String toString(int i)
		String s4 = Integer.toString(number);
		System.out.println("s4:" + s4);
		System.out.println("-----------------");

		// String -- int
		String s = "100";
		// 方式1
		// String -- Integer -- int
		Integer ii = new Integer(s);
		// public int intValue()
		int x = ii.intValue();
		System.out.println("x:" + x);
		//方式2
		//public static int parseInt(String s)
		int y = Integer.parseInt(s);
		System.out.println("y:"+y);
	}
}

```

	public int intValue()
	public static int parseInt(String s)
	public static String toString(int i)
	public static Integer valueOf(int i)
	public static Integer valueOf(String s)

### 3、常用的基本进制转换

public static String toBinaryString(int i)
public static String toOctalString(int i)
public static String toHexString(int i)

十进制到其他进制

	public static String toString(int i,int radix)

其他进制到十进制

	public static int parseInt(String s,int radix)

### 4、自动装箱和自动拆箱

JDK1.5以后，JDK5的新特性

	自动装箱：把基本类型转换为包装类类型
	自动拆箱：把包装类类型转换为基本类型

简化了定义方式。

	Integer x = new Integer(4);可以直接写成
	Integer x = 4;  自动装箱。
	x  = x + 5;  自动拆箱。通过intValue方法。

需要注意：

	在使用时，Integer  x = null;就会出现NullPointerException。

```
package cn.itcast_05;

/*
 * 	在使用时，Integer  x = null;代码就会出现NullPointerException。
 * 	建议先判断是否为null，然后再使用。
 */
public class IntegerDemo {
	public static void main(String[] args) {
		// 定义了一个int类型的包装类类型变量i
		// Integer i = new Integer(100);
		Integer ii = 100;
		ii += 200;
		System.out.println("ii:" + ii);

		// 通过反编译后的代码
		// Integer ii = Integer.valueOf(100); //自动装箱
		// ii = Integer.valueOf(ii.intValue() + 200); //自动拆箱，再自动装箱
		// System.out.println((new StringBuilder("ii:")).append(ii).toString());

		Integer iii = null;
		// NullPointerException
		if (iii != null) {
			iii += 1000;
			System.out.println(iii);
		}
	}
}

```
### 5、面试题

Integer i = 1; i += 1;做了哪些事情

	Integer ii = Integer.valueOf(1); //自动装箱
	ii = Integer.valueOf(ii.intValue() + 1); //自动拆箱，再自动装箱

缓冲池(看程序写结果)
```
package cn.itcast_06;

/*
 * 看程序写结果
 * 
 * 注意：Integer的数据直接赋值，如果在-128到127之间，会直接从缓冲池里获取数据
 */
public class IntegerDemo {
	public static void main(String[] args){

		Integer i1 = new Integer(127);
		Integer i2 = new Integer(127);
		System.out.println(i1 == i2);      //false
		System.out.println(i1.equals(i2)); //true
		System.out.println("-----------");

		Integer i3 = new Integer(128); 
		Integer i4 = new Integer(128);
		System.out.println(i3 == i4); //false
		System.out.println(i3.equals(i4)); //true
		System.out.println("-----------");

		Integer i5 = 128;
		Integer i6 = 128;
		System.out.println(i5 == i6);   //false
		System.out.println(i5.equals(i6));//true
		System.out.println("-----------");

		Integer i7 = 127;
		Integer i8 = 127;
		System.out.println(i7 == i8);  //true
		System.out.println(i7.equals(i8)); //true

		// 通过查看源码，我们就知道了，针对-128到127之间的数据，做了一个数据缓冲池，如果数据是该范围内的，每次并不创建新的空间
		// Integer ii = Integer.valueOf(127);
	}
}

```

## 四、Character类

Character 类在对象中包装一个基本类型 char 的值。

此外，该类提供了几种方法，以确定字符的类别（小写字母，数字，等等），并将字符从大写转换成小写，反之亦然

### 1、构造方法

public Character(char value)
```
public class CharacterDemo {
	public static void main(String[] args) {
		// 创建对象
		// Character ch = new Character((char) 97);
		Character ch = new Character('a');
		System.out.println("ch:" + ch);
	}
}
```

### 2、成员方法
```
/*
 * public static boolean isUpperCase(char ch):判断给定的字符是否是大写字符
 * public static boolean isLowerCase(char ch):判断给定的字符是否是小写字符
 * public static boolean isDigit(char ch):判断给定的字符是否是数字字符
 * public static char toUpperCase(char ch):把给定的字符转换为大写字符
 * public static char toLowerCase(char ch):把给定的字符转换为小写字符
 */
public class CharacterDemo {
	public static void main(String[] args) {
		// public static boolean isUpperCase(char ch):判断给定的字符是否是大写字符
		System.out.println("isUpperCase:" + Character.isUpperCase('A'));
		System.out.println("isUpperCase:" + Character.isUpperCase('a'));
		System.out.println("isUpperCase:" + Character.isUpperCase('0'));
		System.out.println("-----------------------------------------");
		// public static boolean isLowerCase(char ch):判断给定的字符是否是小写字符
		System.out.println("isLowerCase:" + Character.isLowerCase('A'));
		System.out.println("isLowerCase:" + Character.isLowerCase('a'));
		System.out.println("isLowerCase:" + Character.isLowerCase('0'));
		System.out.println("-----------------------------------------");
		// public static boolean isDigit(char ch):判断给定的字符是否是数字字符
		System.out.println("isDigit:" + Character.isDigit('A'));
		System.out.println("isDigit:" + Character.isDigit('a'));
		System.out.println("isDigit:" + Character.isDigit('0'));
		System.out.println("-----------------------------------------");
		// public static char toUpperCase(char ch):把给定的字符转换为大写字符
		System.out.println("toUpperCase:" + Character.toUpperCase('A'));
		System.out.println("toUpperCase:" + Character.toUpperCase('a'));
		System.out.println("-----------------------------------------");
		// public static char toLowerCase(char ch):把给定的字符转换为小写字符
		System.out.println("toLowerCase:" + Character.toLowerCase('A'));
		System.out.println("toLowerCase:" + Character.toLowerCase('a'));
	}
}

```

### 3、案例
```
import java.util.Scanner;

/*
 * 统计一个字符串中大写字母字符，小写字母字符，数字字符出现的次数。(不考虑其他字符)
 * 
 * 分析：
 * 		A:定义三个统计变量。
 * 			int bigCont=0;
 * 			int smalCount=0;
 * 			int numberCount=0;
 * 		B:键盘录入一个字符串。
 * 		C:把字符串转换为字符数组。
 * 		D:遍历字符数组获取到每一个字符
 * 		E:判断该字符是
 * 			大写	bigCount++;
 * 			小写	smalCount++;
 * 			数字	numberCount++;
 * 		F:输出结果即可
 */
public class CharacterTest {
	public static void main(String[] args) {
		// 定义三个统计变量。
		int bigCount = 0;
		int smallCount = 0;
		int numberCount = 0;

		// 键盘录入一个字符串。
		Scanner sc = new Scanner(System.in);
		System.out.println("请输入一个字符串：");
		String line = sc.nextLine();

		// 把字符串转换为字符数组。
		char[] chs = line.toCharArray();

		// 历字符数组获取到每一个字符
		for (int x = 0; x < chs.length; x++) {
			char ch = chs[x];

			// 判断该字符
			if (Character.isUpperCase(ch)) {
				bigCount++;
			} else if (Character.isLowerCase(ch)) {
				smallCount++;
			} else if (Character.isDigit(ch)) {
				numberCount++;
			}
		}

		// 输出结果即可
		System.out.println("大写字母：" + bigCount + "个");
		System.out.println("小写字母：" + smallCount + "个");
		System.out.println("数字字符：" + numberCount + "个");
	}
}

```
