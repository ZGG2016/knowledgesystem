# 类：Math、System、BigInteger、Date、DateForamt、Calender

## 一、正则表达式

指一个用来描述或者匹配一系列符合某个句法规则的字符串的单个字符串。
其实就是一种规则。有自己特殊的应用。


规则字符在java.util.regex Pattern类中

常见组成规则

	字符
	字符类
	预定义字符类
	边界匹配器
	数量词

### 1、判断功能
public boolean matches(String regex)
``` java
public static boolean checkQQ(String qq) {

	return qq.matches("[1-9]\\d{4,14}");
	}
```


### 2、分割功能

public String[] split(String regex)

根据给定正则表达式的匹配拆分此字符串。 
```java
public static void main(String[] args) {
		//定义一个年龄搜索范围
		String ages = "18-24";
		
		//定义规则
		String regex = "-";
		
		//调用方法
		String[] strArray = ages.split(regex);
		
		
		//如何得到int类型的呢?
		int startAge = Integer.parseInt(strArray[0]);
		int endAge = Integer.parseInt(strArray[1]);
		
		//键盘录入年龄
		Scanner sc = new Scanner(System.in);
		System.out.println("请输入你的年龄：");
		int age = sc.nextInt();
		
		if(age>=startAge && age<=endAge) {
			System.out.println("你就是我想找的");
		}else {
			System.out.println("不符合我的要求，gun");
		}
	}
```
### 3、替换功能

public String replaceAll(String regex,String replacement)

使用给定的 replacement 替换此字符串所有匹配给定的正则表达式的子字符串。 
```java
public static void main(String[] args) {
	// 定义一个字符串
	String s = "helloqq12345worldkh622112345678java";
		
	// 直接把数字干掉
	String regex = "\\d+";
	String ss = "";

	String result = s.replaceAll(regex, ss);
	System.out.println(result);
	}
```

### 4、获取功能

Pattern和Matcher类的使用
```java
*
 * 获取功能：
 * 获取下面这个字符串中由三个字符组成的单词
 * da jia ting wo shuo,jin tian yao xia yu,bu shang wan zi xi,gao xing bu?
 */
public class RegexDemo2 {
	public static void main(String[] args) {
		// 定义字符串
		String s = "da jia ting wo shuo,jin tian yao xia yu,bu shang wan zi xi,gao xing bu?";
		// 规则
		String regex = "\\b\\w{3}\\b";

		// 把规则编译成模式对象
		Pattern p = Pattern.compile(regex);
		// 通过模式对象得到匹配器对象
		Matcher m = p.matcher(s);
		// 调用匹配器对象的功能
		// 通过find方法就是查找有没有满足条件的子串
		// public boolean find()
		// boolean flag = m.find();
		// System.out.println(flag);
		// // 如何得到值呢?
		// // public String group()
		// String ss = m.group();
		// System.out.println(ss);
		//
		// // 再来一次
		// flag = m.find();
		// System.out.println(flag);
		// ss = m.group();
		// System.out.println(ss);

		while (m.find()) {
			System.out.println(m.group());
		}

		// 注意：一定要先find()，然后才能group()
		// IllegalStateException: No match found
		// String ss = m.group();
		// System.out.println(ss);
	}
}
```
## 二、Math类

Math 类包含用于执行基本数学运算的方法，如初等指数、对数、平方根和三角函数。 

### 1、成员方法

```java
/*
 * 成员变量：
 * 		public static final double PI
 * 		public static final double E
 * 成员方法：
 * 		public static int abs(int a)：绝对值
 *		public static double ceil(double a):向上取整
 *		public static double floor(double a):向下取整
 *		public static int max(int a,int b):最大值 (min自学)
 *		public static double pow(double a,double b):a的b次幂
 *		public static double random():随机数 [0.0,1.0)
 *		public static int round(float a) 四舍五入(参数为double的自学)
 *		public static double sqrt(double a):正平方根
 */
public class MathDemo {
	public static void main(String[] args) {
		// public static final double PI
		System.out.println("PI:" + Math.PI);
		// public static final double E
		System.out.println("E:" + Math.E);
		System.out.println("--------------");

		// public static int abs(int a)：绝对值
		System.out.println("abs:" + Math.abs(10));
		System.out.println("abs:" + Math.abs(-10));
		System.out.println("--------------");

		// public static double ceil(double a):向上取整
		System.out.println("ceil:" + Math.ceil(12.34));
		System.out.println("ceil:" + Math.ceil(12.56));
		System.out.println("--------------");

		// public static double floor(double a):向下取整
		System.out.println("floor:" + Math.floor(12.34));
		System.out.println("floor:" + Math.floor(12.56));
		System.out.println("--------------");

		// public static int max(int a,int b):最大值
		System.out.println("max:" + Math.max(12, 23));
		// 需求：我要获取三个数据中的最大值
		// 方法的嵌套调用
		System.out.println("max:" + Math.max(Math.max(12, 23), 18));
		// 需求：我要获取四个数据中的最大值
		System.out.println("max:"
				+ Math.max(Math.max(12, 78), Math.max(34, 56)));
		System.out.println("--------------");

		// public static double pow(double a,double b):a的b次幂
		System.out.println("pow:" + Math.pow(2, 3));
		System.out.println("--------------");

		// public static double random():随机数 [0.0,1.0)
		System.out.println("random:" + Math.random());
		// 获取一个1-100之间的随机数
		System.out.println("random:" + ((int) (Math.random() * 100) + 1));
		System.out.println("--------------");

		// public static int round(float a) 四舍五入(参数为double的自学)
		System.out.println("round:" + Math.round(12.34f));
		System.out.println("round:" + Math.round(12.56f));
		System.out.println("--------------");
		
		//public static double sqrt(double a):正平方根
		System.out.println("sqrt:"+Math.sqrt(4));
	}
}
```

### 2、案例

```java
package cn.itcast_02;

import java.util.Scanner;

/*
 * 需求：请设计一个方法，可以实现获取任意范围内的随机数。
 * 
 * 分析：
 * 		A:键盘录入两个数据。
 * 			int strat;
 * 			int end;
 * 		B:想办法获取在start到end之间的随机数
 * 			我写一个功能实现这个效果，得到一个随机数。(int)
 * 		C:输出这个随机数
 */
public class MathDemo {
	public static void main(String[] args) {
		Scanner sc = new Scanner(System.in);
		System.out.println("请输入开始数：");
		int start = sc.nextInt();
		System.out.println("请输入结束数：");
		int end = sc.nextInt();

		for (int x = 0; x < 100; x++) {
			// 调用功能
			int num = getRandom(start, end);
			// 输出结果
			System.out.println(num);
		}
	}

	/*
	 * 写一个功能 两个明确： 返回值类型：int 参数列表：int start,int end
	 */
	public static int getRandom(int start, int end) {
		// 回想我们讲过的1-100之间的随机数
		// int number = (int) (Math.random() * 100) + 1;
		// int number = (int) (Math.random() * end) + start;
		// 发现有问题了，怎么办呢?
		int number = (int) (Math.random() * (end - start + 1)) + start;
		return number;
	}
}

```

## 三、Random类

此类用于产生随机数

如果用相同的种子创建两个 Random 实例，则对每个实例进行相同的方法调用序列，
它们将生成并返回相同的数字序列。

```java

import java.util.Random;

/*
 * Random:产生随机数的类
 * 
 * 构造方法：
 * 		public Random():没有给种子，用的是默认种子，是当前时间的毫秒值
 *		public Random(long seed):给出指定的种子
 *
 *		给定种子后，每次得到的随机数是相同的。
 *
 * 成员方法：
 * 		public int nextInt()：返回的是int范围内的随机数
 *		public int nextInt(int n):返回的是[0,n)范围的内随机数
 */
public class RandomDemo {
	public static void main(String[] args) {
		// 创建对象
		// Random r = new Random();
		Random r = new Random(1111);

		for (int x = 0; x < 10; x++) {
			// int num = r.nextInt();
			int num = r.nextInt(100) + 1;
			System.out.println(num);
		}
	}
}

```

## 四、System类

System 类包含一些有用的类字段和方法。它不能被实例化。
 
### 1、成员方法

public static void gc()
```java
/*
 * 	public static void gc()：运行垃圾回收器。 
 */
public class SystemDemo {
	public static void main(String[] args) {
		Person p = new Person("赵雅芝", 60);
		System.out.println(p);

		p = null; // 让p不再指定堆内存
		System.gc();  //默认调用的Object.finalize()。依次释放子类、父类的资源
	}
}
```
```java
public class Person {
	private String name;
	private int age;

	public Person() {
		super();
	}

	public Person(String name, int age) {
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
	public String toString() {
		return "Person [name=" + name + ", age=" + age + "]";
	}

	@Override
	protected void finalize() throws Throwable {
		System.out.println("当前的对象被回收了" + this);
		super.finalize();
	}

}

```
public static void exit(int status):终止当前正在运行的 Java 虚拟机。参数用作状态码；根据惯例，非 0 的状态码表示异常终止。 

public static long currentTimeMillis():返回以毫秒为单位的当前时间
```java
public static void main(String[] args) {
	// System.out.println("我们喜欢林青霞(东方不败)");
	// System.exit(0);
	// System.out.println("我们也喜欢赵雅芝(白娘子)");

	// System.out.println(System.currentTimeMillis());

	// 可以用来统计一段程序的运行时间
	long start = System.currentTimeMillis();
	for (int x = 0; x < 100000; x++) {
		System.out.println("hello" + x);
	}
	long end = System.currentTimeMillis();
	System.out.println("共耗时：" + (end - start) + "毫秒");
	}
```
public static void arraycopy(Object src,int srcPos,Object dest,int destPos,int length)
从指定源数组中复制一个数组，复制从指定的位置开始，到目标数组的指定位置结束。

```java
public static void main(String[] args) {
	// 定义数组
	int[] arr = { 11, 22, 33, 44, 55 };
	int[] arr2 = { 6, 7, 8, 9, 10 };

	System.arraycopy(arr, 1, arr2, 2, 2);

	System.out.println(Arrays.toString(arr));
	System.out.println(Arrays.toString(arr2));
	}
```


## 五、BigInteger类 

可以让超过Integer范围内的数据进行运算

### 1、构造方法

public BigInteger(String val)
```java
public class BigIntegerDemo {
	public static void main(String[] args) {
		// 这几个测试，是为了简单超过int范围内，Integer就不能再表示，所以就更谈不上计算了。
		// Integer i = new Integer(100);
		// System.out.println(i);
		// // System.out.println(Integer.MAX_VALUE);
		// Integer ii = new Integer("2147483647");
		// System.out.println(ii);
		// // NumberFormatException
		// Integer iii = new Integer("2147483648");
		// System.out.println(iii);

		// 通过大整数来创建对象
		BigInteger bi = new BigInteger("2147483648");
		System.out.println("bi:" + bi);
	}
}
```

### 2、成员方法
```java
package cn.itcast_02;

import java.math.BigInteger;

/*
 * public BigInteger add(BigInteger val):加
 * public BigInteger subtract(BigInteger val):减
 * public BigInteger multiply(BigInteger val):乘
 * public BigInteger divide(BigInteger val):除
 * public BigInteger[] divideAndRemainder(BigInteger val):返回商和余数的数组
 */
public class BigIntegerDemo {
	public static void main(String[] args) {
		BigInteger bi1 = new BigInteger("100");
		BigInteger bi2 = new BigInteger("50");

		// public BigInteger add(BigInteger val):加
		System.out.println("add:" + bi1.add(bi2));
		// public BigInteger subtract(BigInteger val):加
		System.out.println("subtract:" + bi1.subtract(bi2));
		// public BigInteger multiply(BigInteger val):加
		System.out.println("multiply:" + bi1.multiply(bi2));
		// public BigInteger divide(BigInteger val):加
		System.out.println("divide:" + bi1.divide(bi2));

		// public BigInteger[] divideAndRemainder(BigInteger val):返回商和余数的数组
		BigInteger[] bis = bi1.divideAndRemainder(bi2);
		System.out.println("商：" + bis[0]);
		System.out.println("余数：" + bis[1]);
	}
}
```


## 六、BigDecimal类

由于在运算的时候，float类型和double很容易丢失精度，所以，
为了能精确的表示、计算浮点数，Java提供了BigDecimal，不可变的、任意精度的有符号十进制数。

```java
public class BigDecimalDemo {
	public static void main(String[] args) {
		System.out.println(0.09 + 0.01);
		System.out.println(1.0 - 0.32);
		System.out.println(1.015 * 100);
		System.out.println(1.301 / 100);

		System.out.println(1.0 - 0.12);
	}
}
```

### 1、构造方法

public BigDecimal(String val)

```java
public class BigDecimalDemo {
	public static void main(String[] args) {
	
		BigDecimal bd1 = new BigDecimal("0.09");
		BigDecimal bd2 = new BigDecimal("0.01");
		System.out.println("add:" + bd1.add(bd2));
		System.out.println("-------------------");
	}
}
```

注意：

	public BigDecimal(double val)此构造方法的结果有一定的不可预知性。
	当 double 必须用作 BigDecimal 的源时，请注意，此构造方法提供了一个准确转换；
	它不提供与以下操作相同的结果：先使用 Double.toString(double) 方法，
	然后使用 BigDecimal(String) 构造方法，将 double 转换为 String。
	要获取该结果，请使用 static valueOf(double) 方法。 

### 2、成员方法
```java
package cn.itcast_02;

import java.math.BigDecimal;

/*
 * public BigDecimal add(BigDecimal augend)
 * public BigDecimal subtract(BigDecimal subtrahend)
 * public BigDecimal multiply(BigDecimal multiplicand)
 * public BigDecimal divide(BigDecimal divisor)
 * public BigDecimal divide(BigDecimal divisor,int scale,int roundingMode):商，几位小数，如何舍取
 */
public class BigDecimalDemo {
	public static void main(String[] args) {
		// System.out.println(0.09 + 0.01);
		// System.out.println(1.0 - 0.32);
		// System.out.println(1.015 * 100);
		// System.out.println(1.301 / 100);

		BigDecimal bd1 = new BigDecimal("0.09");
		BigDecimal bd2 = new BigDecimal("0.01");
		System.out.println("add:" + bd1.add(bd2));
		System.out.println("-------------------");

		BigDecimal bd3 = new BigDecimal("1.0");
		BigDecimal bd4 = new BigDecimal("0.32");
		System.out.println("subtract:" + bd3.subtract(bd4));
		System.out.println("-------------------");

		BigDecimal bd5 = new BigDecimal("1.015");
		BigDecimal bd6 = new BigDecimal("100");
		System.out.println("multiply:" + bd5.multiply(bd6));
		System.out.println("-------------------");

		BigDecimal bd7 = new BigDecimal("1.301");
		BigDecimal bd8 = new BigDecimal("100");
		System.out.println("divide:" + bd7.divide(bd8));
		System.out.println("divide:"
				+ bd7.divide(bd8, 3, BigDecimal.ROUND_HALF_UP));
		System.out.println("divide:"
				+ bd7.divide(bd8, 8, BigDecimal.ROUND_HALF_UP));
	}
}

```

## 七、Date类 

表示特定的瞬间，精确到毫秒。 

注意：
	
	从 JDK 1.1 开始，应该使用 Calendar 类实现日期和时间字段之间转换，
	使用 DateFormat 类来格式化和解析日期字符串。Date 中的相应方法已废弃。 

### 1、构造方法

```java
import java.util.Date;

/*
 * Date:表示特定的瞬间，精确到毫秒。 
 * 
 * 构造方法：
 * 		Date():根据当前的默认毫秒值创建日期对象
 * 		Date(long date)：根据给定的毫秒值创建日期对象
 */
public class DateDemo {
	public static void main(String[] args) {
		// 创建对象
		Date d = new Date();
		System.out.println("d:" + d);

		// 创建对象
		// long time = System.currentTimeMillis();
		long time = 1000 * 60 * 60; // 1小时
		Date d2 = new Date(time);
		System.out.println("d2:" + d2);
	}
}

```

### 2、成员方法

```java
import java.util.Date;

/*
 * public long getTime():获取时间，以毫秒为单位
 * public void setTime(long time):设置时间
 * 
 * 从Date得到一个毫秒值
 * 		getTime()
 * 把一个毫秒值转换为Date
 * 		构造方法
 * 		setTime(long time)
 */
public class DateDemo {
	public static void main(String[] args) {
		// 创建对象
		Date d = new Date();

		// 获取时间
		long time = d.getTime();
		System.out.println(time);
		// System.out.println(System.currentTimeMillis());

		System.out.println("d:" + d);
		// 设置时间
		d.setTime(1000);
		System.out.println("d:" + d);
	}
}

```

## 八、DateFormat类 

DateFormat 是日期/时间格式化子类的抽象类，它以与语言无关的方式格式化并解析
日期或时间。是抽象类，所以使用其子类SimpleDateFormat

### 1、SimpleDateFormat构造方法

public SimpleDateFormat()

public SimpleDateFormat(String pattern)

### 2、成员方法

public final String format(Date date)

public Date parse(String source)

```java
package cn.itcast_03;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

/*
 * Date	 --	 String(格式化)
 * 		public final String format(Date date)
 * 
 * String -- Date(解析)
 * 		public Date parse(String source)
 * 
 * DateForamt:可以进行日期和字符串的格式化和解析，但是由于是抽象类，所以使用具体子类SimpleDateFormat。
 * 
 * SimpleDateFormat的构造方法：
 * 		SimpleDateFormat():默认模式
 * 		SimpleDateFormat(String pattern):给定的模式
 * 			这个模式字符串该如何写呢?
 * 			通过查看API，我们就找到了对应的模式
 * 			年 y
 * 			月 M	
 * 			日 d
 * 			时 H
 * 			分 m
 * 			秒 s
 * 
 * 			2014年12月12日 12:12:12
 */
public class DateFormatDemo {
	public static void main(String[] args) throws ParseException {
		// Date -- String
		// 创建日期对象
		Date d = new Date();
		// 创建格式化对象
		// SimpleDateFormat sdf = new SimpleDateFormat();
		// 给定模式
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy年MM月dd日 HH:mm:ss");
		// public final String format(Date date)
		String s = sdf.format(d);
		System.out.println(s);
		
		
		//String -- Date
		String str = "2008-08-08 12:12:12";
		//在把一个字符串解析为日期的时候，请注意格式必须和给定的字符串格式匹配
		SimpleDateFormat sdf2 = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		Date dd = sdf2.parse(str);
		System.out.println(dd);
	}
}
```
### 3、日期工具类

```java
package cn.itcast_04;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * 这是日期和字符串相互转换的工具类
 * 
 * @author 风清扬
 */
public class DateUtil {
	private DateUtil() {
	}

	/**
	 * 这个方法的作用就是把日期转成一个字符串
	 * 
	 * @param d
	 *            被转换的日期对象
	 * @param format
	 *            传递过来的要被转换的格式
	 * @return 格式化后的字符串
	 */
	public static String dateToString(Date d, String format) {
		// SimpleDateFormat sdf = new SimpleDateFormat(format);
		// return sdf.format(d);
		return new SimpleDateFormat(format).format(d);
	}

	/**
	 * 这个方法的作用就是把一个字符串解析成一个日期对象
	 * 
	 * @param s
	 *            被解析的字符串
	 * @param format
	 *            传递过来的要被转换的格式
	 * @return 解析后的日期对象
	 * @throws ParseException
	 */
	public static Date stringToDate(String s, String format)
			throws ParseException {
		return new SimpleDateFormat(format).parse(s);
	}
}

```



## 九、Calendar类 

Calendar 类是一个抽象类，它为特定瞬间与一组诸如 YEAR、MONTH、DAY_OF_MONTH、
HOUR 等 日历字段之间的转换提供了一些方法，并为操作日历字段
（例如获得下星期的日期）提供了一些方法。

### 1、成员方法

```java
package cn.itcast_01;

import java.util.Calendar;

/*
 * 
 * public int get(int field):返回给定日历字段的值。日历类中的每个日历字段都是静态的成员变量，并且是int类型。
 */
public class CalendarDemo {
	public static void main(String[] args) {
		// 其日历字段已由当前日期和时间初始化：
		Calendar rightNow = Calendar.getInstance(); // 子类对象

		// 获取年
		int year = rightNow.get(Calendar.YEAR);
		// 获取月
		int month = rightNow.get(Calendar.MONTH);
		// 获取日
		int date = rightNow.get(Calendar.DATE);

		System.out.println(year + "年" + (month + 1) + "月" + date + "日");
	}
}

/*
 * abstract class Person { public static Person getPerson() { return new
 * Student(); } }
 * 
 * class Student extends Person {
 * 
 * }
 */

```

```java
package cn.itcast_02;

import java.util.Calendar;

/*
 * public void add(int field,int amount):根据给定的日历字段和对应的时间，来对当前的日历进行操作。
 * public final void set(int year,int month,int date):设置当前日历的年月日
 */
public class CalendarDemo {
	public static void main(String[] args) {
		// 获取当前的日历时间
		Calendar c = Calendar.getInstance();

		// 获取年
		int year = c.get(Calendar.YEAR);
		// 获取月
		int month = c.get(Calendar.MONTH);
		// 获取日
		int date = c.get(Calendar.DATE);
		System.out.println(year + "年" + (month + 1) + "月" + date + "日");

		// // 三年前的今天
		// c.add(Calendar.YEAR, -3);
		// // 获取年
		// year = c.get(Calendar.YEAR);
		// // 获取月
		// month = c.get(Calendar.MONTH);
		// // 获取日
		// date = c.get(Calendar.DATE);
		// System.out.println(year + "年" + (month + 1) + "月" + date + "日");

		// 5年后的10天前
		c.add(Calendar.YEAR, 5);
		c.add(Calendar.DATE, -10);
		// 获取年
		year = c.get(Calendar.YEAR);
		// 获取月
		month = c.get(Calendar.MONTH);
		// 获取日
		date = c.get(Calendar.DATE);
		System.out.println(year + "年" + (month + 1) + "月" + date + "日");
		System.out.println("--------------");

		c.set(2011, 11, 11);
		// 获取年
		year = c.get(Calendar.YEAR);
		// 获取月
		month = c.get(Calendar.MONTH);
		// 获取日
		date = c.get(Calendar.DATE);
		System.out.println(year + "年" + (month + 1) + "月" + date + "日");
	}
}

```
