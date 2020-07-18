# IO流01：异常、File类

## 一、异常

异常就是Java程序在运行过程中出现的错误。

JVM的默认处理方案:

	把异常的名称，错误原因及异常出现的位置等信息输出在了控制台
	程序停止执行


## 二、分类

![java39](https://s1.ax1x.com/2020/07/12/U85kIe.png)

	程序的异常：Throwable
		严重问题：Error 我们不处理。这种问题一般都是很严重的，比如说内存溢出。
		问题：Exception
			编译期问题:不是RuntimeException的异常 必须进行处理的，因为你不处理，编译就不能通过。
			运行期问题:RuntimeException	这种问题我们也不处理，因为是你的问题，
			           而且这个问题出现肯定是我们的代码不够严谨，需要修正代码的。

Error：

	IOError：当发生严重的 I/O 错误时，抛出此错误。
	VirtualMachineError：当 Java 虚拟机崩溃或用尽了它继续操作所需的资源时，抛出该错误。
		OutOfMemoryError：因为内存溢出或没有可用的内存提供给垃圾回收器时，Java
		        	     虚拟机无法分配一个对象，这时抛出该异常。 
		StackOverflowError：当应用程序递归太深而发生堆栈溢出时，抛出该错误。

Exception:
	
	运行期问题RuntimeException:
		索引越界异常 IndexOutOfBoundsException
		当出现异常的运算条件(除数为0) ArithmeticException 
		空指针异常 NullPointerException
		类型转换异常 ClassCastException
		非法参数异常 IllegalArgumentException
		数组下标越界 ArrayIndexOutOfBoundsException 

	编译期问题：
		ClassNotFoundException：加载类时,但没有找到具有指定名称的类的定义
		TimeoutException：阻塞操作超时时，抛出该异常。
		IOException：当发生某种 I/O 异常时，抛出此异常。此类是失败或中断的 I/O 操作生成的异常的通用类。 
			FileNotFoundException：当试图打开指定路径名表示的文件失败时，抛出此异常。 
			EOFException：当输入过程中意外到达文件或流的末尾时，抛出此异常。 

编译时异常、运行时异常区别

	编译时异常
		Java程序必须显示处理，否则程序就会发生错误，无法通过编译
	运行时异常
		无需显示处理，也可以和编译时异常一样处理


```java
public class ExceptionDemo {
	public static void main(String[] args) {
		//第一阶段
		int a = 10;
		// int b = 2;
		int b = 0;   //ArithmeticException
		System.out.println(a / b);
		
		//第二阶段
		System.out.println("over");
	}
}
```

## 三、处理异常

### 1、try...catch

**一个异常**

try...catch...finally的处理格式：

	try {
		可能出现问题的代码;
	}catch(异常名 变量) {
		针对问题的处理;
	}finally {
		释放资源;
	}

变形格式：

	try {
		可能出现问题的代码;
	}catch(异常名 变量) {
		针对问题的处理;
	}

注意：

	A:try里面的代码越少越好
	B:catch里面必须有内容，哪怕是给出一个简单的提示。
	  不然会直接输出“over”，不知道try中的语句出了什么问题。

```java
public class ExceptionDemo {
	public static void main(String[] args) {
		// 第一阶段
		int a = 10;
		// int b = 2;
		int b = 0;

		try {
			System.out.println(a / b);
		} catch (ArithmeticException ae) {
			System.out.println("除数不能为0");
		}

		// 第二阶段
		System.out.println("over");
	}
}
```
**多个异常的处理**

	try{
		...
	}catch(异常类名 变量名) {
		...
	}
	catch(异常类名 变量名) {
		...
	}
		...

注意事项：

	1:能明确的尽量明确，不要用大的来处理。
	2:平级关系的异常谁前谁后无所谓，如果出现了子父关系，父必须在后面。

注意：

	一旦try里面出了问题，就会在这里把问题给抛出去，然后和catch里面的问题
	进行匹配，一旦有匹配的，就执行catch里面的处理，然后结束了try...catch
	继续执行后面的语句。

```java

public class ExceptionDemo2 {
	public static void main(String[] args) {
		// method1();

		// method2();

		method3();

	
	}

	public static void method3() {
		int a = 10;
		int b = 0;
		int[] arr = { 1, 2, 3 };

		// 爷爷在最后
		try {
			System.out.println(a / b);
			System.out.println(arr[3]);
			System.out.println("这里出现了一个异常，你不太清楚是谁，该怎么办呢?");
		} catch (ArithmeticException e) {
			System.out.println("除数不能为0");
		} catch (ArrayIndexOutOfBoundsException e) {
			System.out.println("你访问了不该的访问的索引");
		} catch (Exception e) {
			System.out.println("出问题了");
		}

		// 爷爷在前面是不可以的
		// try {
		// System.out.println(a / b);
		// System.out.println(arr[3]);
		// System.out.println("这里出现了一个异常，你不太清楚是谁，该怎么办呢?");
		// } catch (Exception e) {  //Exception会捕获所有问题，确定不了具体的问题
		// System.out.println("出问题了");
		// } catch (ArithmeticException e) {
		// System.out.println("除数不能为0");
		// } catch (ArrayIndexOutOfBoundsException e) {
		// System.out.println("你访问了不该的访问的索引");
		// }

		System.out.println("over");
	}

	// 两个异常的处理，只匹配到第一个，arr[3]
	public static void method2() {
		int a = 10;
		int b = 0;
		int[] arr = { 1, 2, 3 };

		try {
			System.out.println(arr[3]);
			System.out.println(a / b);
			// System.out.println(arr[3]);
		} catch (ArithmeticException e) {
			System.out.println("除数不能为0");
		} catch (ArrayIndexOutOfBoundsException e) {
			System.out.println("你访问了不该的访问的索引");
		}

		System.out.println("over");
	}

	// 两个异常，依次匹配
	public static void method1() {
		int a = 10;
		int b = 0;
		try {
			System.out.println(a / b);
		} catch (ArithmeticException e) {
			System.out.println("除数不能为0");
		}

		int[] arr = { 1, 2, 3 };
		try {
			System.out.println(arr[3]);
		} catch (ArrayIndexOutOfBoundsException e) {
			System.out.println("你访问了不该的访问的索引");
		}

		System.out.println("over");
	}

}
```

JDK7出现了一个新的多个异常处理方案：

	try{

	}catch(异常名1 | 异常名2 | ...  变量 ) {
	...
	}

注意：这个方法虽然简洁，但是也不够好。

	A:处理方式是一致的。(实际开发中，好多时候可能就是针对同类型的问题，给出同一个处理)
	B:多个异常间必须是平级关系。

```java
public class ExceptionDemo3 {
	public static void main(String[] args) {
		method();
	}

	public static void method() {
		int a = 10;
		int b = 0;
		int[] arr = { 1, 2, 3 };

		// JDK7的处理方案
		try {
			System.out.println(a / b);
			System.out.println(arr[3]);
		} catch (ArithmeticException | ArrayIndexOutOfBoundsException e) {
			System.out.println("出问题了");
		}

		System.out.println("over");
	}

}
```

### 2、Throwable中的方法

在try里面发现问题后，jvm会帮我们生成一个异常对象，然后把这个对象抛出，
和catch里面的类进行匹配。如果该对象是某个类型的，就会执行该catch里面的处理信息。

异常中要了解的几个方法：

	public String getMessage():异常的消息字符串		
	public String toString():返回异常的简单信息描述
		此对象的类的 name(全路径名)
		": "（冒号和一个空格） 
		调用此对象 getLocalizedMessage()方法的结果 (默认返回的是getMessage()的内容)
	printStackTrace() 获取异常类名和异常信息，以及异常出现在程序中的位置。返回值void。把信息输出在控制台。

```java
public class ExceptionDemo {
	public static void main(String[] args) {
		String s = "2014-11-20";
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		try {
			Date d = sdf.parse(s); // 创建了一个ParseException对象，然后抛出去，和catch里面进行匹配
			System.out.println(d);
		} catch (ParseException e) { // ParseException e = new ParseException();
			// ParseException
			// e.printStackTrace();

			// getMessage()
			// System.out.println(e.getMessage());
			// Unparseable date: "2014-11-20"

			// toString()
			// System.out.println(e.toString());
			// java.text.ParseException: Unparseable date: "2014-11-20"
			
			e.printStackTrace();
			//跳转到某个指定的页面(index.html)
		}
		
		System.out.println("over");
	}
}

```

### 3、throws 抛出

定义功能方法时，需要把出现的问题暴露出来让调用者去处理。
那么就通过throws在方法上标识。

格式：
	throws 异常类名
	
注意：

	这个格式必须跟在方法的括号后面。
	尽量不要在main方法上抛出异常。

小结：

	编译期异常抛出，将来调用者必须处理。
	运行期异常抛出，将来调用可以不用处理。

```java
public class ExceptionDemo {
	public static void main(String[] args) {
		System.out.println("今天天气很好");
		try {
			method();
		} catch (ParseException e) {
			e.printStackTrace();
		}
		System.out.println("但是就是不该有雾霾");

		method2();
	}

	// 运行期异常的抛出
	public static void method2() throws ArithmeticException {
		int a = 10;
		int b = 0;
		System.out.println(a / b);
	}

	// 编译期异常的抛出
	// 在方法声明上抛出，是为了告诉调用者，你注意了，我有问题。
	public static void method() throws ParseException {
		String s = "2014-11-20";
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		Date d = sdf.parse(s);
		System.out.println(d);
	}
}

```

### 4、throw

在功能方法内部出现某种情况，程序不能继续运行，需要进行跳转时，
就用throw把异常对象抛出。抛出的应该是异常的对象。

throws和throw的区别(面试题)

	throws
		用在方法声明后面，跟的是异常类名
		可以跟多个异常类名，用逗号隔开
		表示抛出异常，由该方法的调用者来处理
		throws表示出现异常的一种可能性，并不一定会发生这些异常
	throw
		用在方法体内，跟的是异常对象名
		只能抛出一个异常对象名
		表示抛出异常，由方法体内的语句处理
		throw则是抛出了异常，执行throw则一定抛出了某种异常

```java
public class ExceptionDemo {
	public static void main(String[] args) {
		// method();
		
		try {
			method2();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static void method() {
		int a = 10;
		int b = 0;
		if (b == 0) {
			throw new ArithmeticException();
		} else {
			System.out.println(a / b);
		}
	}

	public static void method2() throws Exception {
		int a = 10;
		int b = 0;
		if (b == 0) {
			throw new Exception();
		} else {
			System.out.println(a / b);
		}
	}
}

```
选择异常处理的原则：

	如果该功能内部可以将问题处理,用try,
	如果处理不了,交由调用者处理,这是用throws
	
	区别:
		后续程序需要继续运行就try
		后续程序不需要继续运行就throws

### 5、finally

格式

	try...catch...finally...

finally的特点

	被finally控制的语句体一定会执行

	特殊情况：在执行到finally之前jvm退出了(比如System.exit(0))

finally的作用

	用于释放资源，在IO流操作和数据库操作中会见到

```java
public class FinallyDemo {
	public static void main(String[] args) {
		String s = "2014-11-20";
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

		Date d = null;
		try {
			// System.out.println(10 / 0);
			d = sdf.parse(s);
		} catch (ParseException e) {
			e.printStackTrace();
			System.exit(0);
		} finally {
			System.out.println("这里的代码是可以执行的");
		}

		System.out.println(d);
	}
}
```

#### finally相关的面试题

（1）final,finally和finalize的区别

	final：最终的意思，可以修饰类，成员变量，成员方法
			修饰类，类不能被继承
			修饰变量，变量是常量
			修饰方法，方法不能被重写
	finally：是异常处理的一部分，用于释放资源。
			一般来说，代码肯定会执行，特殊情况：在执行到finally之前jvm退出了
	finalize：是Object类的一个方法，用于垃圾回收

（2）如果catch里面有return语句，请问finally的代码还会执行吗?如果会，请问是在return前还是return后。
	
	会，前。
	准确的说，应该是在中间。

```java
public class FinallyDemo2 {
	public static void main(String[] args) {
		System.out.println(getInt());
	}

	public static int getInt() {
		int a = 10;
		try {
			System.out.println(a / 0);
			a = 20;
		} catch (ArithmeticException e) {
			a = 30;
			return a;
			/*
			 * return a在程序执行到这一步的时候，这里不是return a而是return 30;这个返回路径就形成了。
			 * 但是呢，它发现后面还有finally，所以继续执行finally的内容，a=40
			 * 再次回到以前的返回路径，继续走return 30;
			 */
		} finally {
			a = 40;
			return a;//如果这样结果就是40了。
		}
		// return a;
	}
}

```

try...catch...finally的格式变形

	A:try...catch...finally
	B:try...catch
	C:try...catch...catch...
	D:try...catch...catch...finally
	E:try...finally
		这种做法的目前是为了释放资源。


### 6、自定义异常

```java
package cn.itcast_08;

/*
 * java不可能对所有的情况都考虑到，所以，在实际的开发中，我们可能需要自己定义异常。
 * 而我们自己随意的写一个类，是不能作为异常类来看的，要想你的类是一个异常类，就必须继承自Exception或者RuntimeException
 * 
 * 两种方式：
 * A:继承Exception
 * B:继承RuntimeException
 */
public class MyException extends Exception {
	public MyException() {
	}

	public MyException(String message) {
		super(message);
	}
}

// public class MyException extends RuntimeException {
//
// }

```
```java
public class Teacher {
	public void check(int score) throws MyException {
		if (score > 100 || score < 0) {
			throw new MyException("分数必须在0-100之间");
		} else {
			System.out.println("分数没有问题");
		}
	}

	// 针对MyException继承自RuntimeException
	// public void check(int score) {
	// if (score > 100 || score < 0) {
	// throw new MyException();
	// } else {
	// System.out.println("分数没有问题");
	// }
	// }
}
```

```java
import java.util.Scanner;

/*
 * 自定义异常测试类
 */
public class StudentDemo {
	public static void main(String[] args) {
		Scanner sc = new Scanner(System.in);
		System.out.println("请输入学生成绩：");
		int score = sc.nextInt();

		Teacher t = new Teacher();
		try {
			t.check(score);
		} catch (MyException e) {
			e.printStackTrace();
		}
	}
}
```

### 7、异常注意事项

- 子类重写父类方法时，子类的方法必须抛出相同的异常或父类异常的子类。(父亲坏了,儿子不能比父亲更坏)

- 如果父类抛出了多个异常,子类重写父类时,只能抛出相同的异常或者是他的子集,
子类不能抛出父类没有的异常

- 如果被重写的方法没有异常抛出,那么子类的方法绝对不可以抛出异常,
如果子类方法内有异常发生,那么子类只能try,不能throws

## 二、File类

文件和目录路径名的抽象表示形式

构造方法

	public File(String pathname) 根据一个路径得到File对象
	public File(String parent,String child) 根据一个目录和一个子文件/目录得到File对象
	public File(File parent,String child) 根据一个父File对象和一个子文件/目录得到File对象

```java
public class FileDemo {
	public static void main(String[] args) {
		// File(String pathname)：根据一个路径得到File对象
		// 把e:\\demo\\a.txt封装成一个File对象
		File file = new File("E:\\demo\\a.txt");

		// File(String parent, String child):根据一个目录和一个子文件/目录得到File对象
		File file2 = new File("E:\\demo", "a.txt");

		// File(File parent, String child):根据一个父File对象和一个子文件/目录得到File对象
		File file3 = new File("e:\\demo");
		File file4 = new File(file3, "a.txt");

		// 以上三种方式其实效果一样
	}
}
```

### 1、成员方法:创建功能

```java
import java.io.File;
import java.io.IOException;

/*
 *创建功能：
 *public boolean createNewFile():创建文件 如果存在这样的文件，就不创建了
 *public boolean mkdir():创建文件夹 如果存在这样的文件夹，就不创建了
 *public boolean mkdirs():创建文件夹,如果父文件夹不存在，会帮你创建出来
 *
 *骑白马的不一定是王子，可能是班长。
 *注意：你到底要创建文件还是文件夹，你最清楚，方法不要调错了。
 */
public class FileDemo {
	public static void main(String[] args) throws IOException {
		// 需求：我要在e盘目录下创建一个文件夹demo
		File file = new File("e:\\demo");
		System.out.println("mkdir:" + file.mkdir());

		// 需求:我要在e盘目录demo下创建一个文件a.txt
		File file2 = new File("e:\\demo\\a.txt");
		System.out.println("createNewFile:" + file2.createNewFile());

		// 需求：我要在e盘目录test下创建一个文件b.txt
		// Exception in thread "main" java.io.IOException: 系统找不到指定的路径。
		// 注意：要想在某个目录下创建内容，该目录首先必须存在。
		// File file3 = new File("e:\\test\\b.txt");
		// System.out.println("createNewFile:" + file3.createNewFile());

		// 需求:我要在e盘目录test下创建aaa目录
		// File file4 = new File("e:\\test\\aaa");
		// System.out.println("mkdir:" + file4.mkdir());

		// File file5 = new File("e:\\test");
		// File file6 = new File("e:\\test\\aaa");
		// System.out.println("mkdir:" + file5.mkdir());
		// System.out.println("mkdir:" + file6.mkdir());

		// 其实我们有更简单的方法
		File file7 = new File("e:\\aaa\\bbb\\ccc\\ddd");
		System.out.println("mkdirs:" + file7.mkdirs());

		// 看下面的这个东西：
		File file8 = new File("e:\\liuyi\\a.txt");
		System.out.println("mkdirs:" + file8.mkdirs());
	}
}

```

### 2、成员方法:删除功能

```java

import java.io.File;
import java.io.IOException;

/*
 * 删除功能:public boolean delete()
 * 注意：
 * 		A:如果你创建文件或者文件夹忘了写盘符路径，那么，默认在项目路径下。
 * 		B:Java中的删除不走回收站。
 * 		C:要删除一个文件夹，请注意该文件夹内不能包含文件或者文件夹
 */
public class FileDemo {
	public static void main(String[] args) throws IOException {
		// 创建文件
		// File file = new File("e:\\a.txt");
		// System.out.println("createNewFile:" + file.createNewFile());

		// 我不小心写成这个样子了
		File file = new File("a.txt");
		System.out.println("createNewFile:" + file.createNewFile());

		// 继续玩几个
		File file2 = new File("aaa\\bbb\\ccc");
		System.out.println("mkdirs:" + file2.mkdirs());

		// 删除功能：我要删除a.txt这个文件
		File file3 = new File("a.txt");
		System.out.println("delete:" + file3.delete());

		// 删除功能：我要删除ccc这个文件夹
		File file4 = new File("aaa\\bbb\\ccc");
		System.out.println("delete:" + file4.delete());

		// 删除功能：我要删除aaa文件夹
		// File file5 = new File("aaa");
		// System.out.println("delete:" + file5.delete());

		File file6 = new File("aaa\\bbb");
		File file7 = new File("aaa");
		System.out.println("delete:" + file6.delete());
		System.out.println("delete:" + file7.delete());
	}
}
```

### 3、成员方法:重命名功能

```java
import java.io.File;

/*
 * 重命名功能:public boolean renameTo(File dest)
 * 		如果路径名相同，就是改名。
 * 		如果路径名不同，就是改名并剪切。
 * 
 * 路径以盘符开始：绝对路径	c:\\a.txt
 * 路径不以盘符开始：相对路径	a.txt
 */
public class FileDemo {
	public static void main(String[] args) {
		// 创建一个文件对象
		// File file = new File("林青霞.jpg");
		// // 需求：我要修改这个文件的名称为"东方不败.jpg"
		// File newFile = new File("东方不败.jpg");
		// System.out.println("renameTo:" + file.renameTo(newFile));

		File file2 = new File("东方不败.jpg");
		File newFile2 = new File("e:\\林青霞.jpg");
		System.out.println("renameTo:" + file2.renameTo(newFile2));
	}
}

```

### 4、成员方法:判断功能

```java
import java.io.File;

/*
 * 判断功能:
 * public boolean isDirectory():判断是否是目录
 * public boolean isFile():判断是否是文件
 * public boolean exists():判断是否存在
 * public boolean canRead():判断是否可读
 * public boolean canWrite():判断是否可写
 * public boolean isHidden():判断是否隐藏
 */
public class FileDemo {
	public static void main(String[] args) {
		// 创建文件对象
		File file = new File("a.txt");

		System.out.println("isDirectory:" + file.isDirectory());// false
		System.out.println("isFile:" + file.isFile());// true
		System.out.println("exists:" + file.exists());// true
		System.out.println("canRead:" + file.canRead());// true
		System.out.println("canWrite:" + file.canWrite());// true
		System.out.println("isHidden:" + file.isHidden());// false
	}
}

```

### 5、成员方法:获取功能

```java
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

/*
 * 获取功能：
 * public String getAbsolutePath()：获取绝对路径
 * public String getPath():获取相对路径
 * public String getName():获取名称
 * public long length():获取长度。字节数
 * public long lastModified():获取最后一次的修改时间，毫秒值
 */
public class FileDemo {
	public static void main(String[] args) {
		// 创建文件对象
		File file = new File("demo\\test.txt");

		System.out.println("getAbsolutePath:" + file.getAbsolutePath());
		System.out.println("getPath:" + file.getPath());
		System.out.println("getName:" + file.getName());
		System.out.println("length:" + file.length());
		System.out.println("lastModified:" + file.lastModified());

		// 1416471971031
		Date d = new Date(1416471971031L);
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		String s = sdf.format(d);
		System.out.println(s);
	}
}

```

```java
import java.io.File;

/*
 * 获取功能：
 * public String[] list():获取指定目录下的所有文件或者文件夹的名称数组
 * public File[] listFiles():获取指定目录下的所有文件或者文件夹的File数组
 */
public class FileDemo {
	public static void main(String[] args) {
		// 指定一个目录
		File file = new File("e:\\");

		// public String[] list():获取指定目录下的所有文件或者文件夹的名称数组
		String[] strArray = file.list();
		for (String s : strArray) {
			System.out.println(s);
		}
		System.out.println("------------");

		// public File[] listFiles():获取指定目录下的所有文件或者文件夹的File数组
		File[] fileArray = file.listFiles();
		for (File f : fileArray) {
			System.out.println(f.getName());
		}
	}
}

```

### 6、成员方法:文件名称过滤器

	public String[] list(FilenameFilter filter)
	public File[] listFiles(FilenameFilter filter)

```java
import java.io.File;
import java.io.FilenameFilter;

/*
 * 判断E盘目录下是否有后缀名为.jpg的文件，如果有，就输出此文件名称
 * A:先获取所有的，然后遍历的时候，依次判断，如果满足条件就输出。
 * B:获取的时候就已经是满足条件的了，然后输出即可。
 * 
 * 要想实现这个效果，就必须学习一个接口：文件名称过滤器
 * public String[] list(FilenameFilter filter)
 * public File[] listFiles(FilenameFilter filter)
 *
 * public interface FilenameFilter
 * 		实现此接口的类实例可用于过滤器文件名。
 * 		boolean accept(File dir,String name)
 *                 测试指定文件是否应该包含在某一文件列表中。 
 *			参数：
 *			dir - 被找到的文件所在的目录。
 *			name - 文件的名称。 
 *			返回：
 *			当且仅当该名称应该包含在文件列表中时返回 true；否则返回 false。
 *
 */
public class FileDemo2 {
	public static void main(String[] args) {
		// 封装e判断目录
		File file = new File("e:\\");

		// 获取该目录下所有文件或者文件夹的String数组
		// public String[] list(FilenameFilter filter)
		String[] strArray = file.list(new FilenameFilter() {
			@Override
			public boolean accept(File dir, String name) {
				return new File(dir, name).isFile() && name.endsWith(".jpg");
			}
		});

		// 遍历
		for (String s : strArray) {
			System.out.println(s);
		}
	}
}

```


