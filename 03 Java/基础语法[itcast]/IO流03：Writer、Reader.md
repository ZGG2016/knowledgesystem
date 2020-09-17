# IO流03：Writer、Reader

## 一、编解码

编码：把看得懂的变成看不懂的

解码：把看不懂的变成看得懂的

```java
import java.io.UnsupportedEncodingException;
import java.util.Arrays;

/*
 * String(byte[] bytes, String charsetName):通过指定的字符集解码字节数组
 * byte[] getBytes(String charsetName):使用指定的字符集合把字符串编码为字节数组
 * 
 * 编码:把看得懂的变成看不懂的
 * String -- byte[]
 * 
 * 解码:把看不懂的变成看得懂的
 * byte[] -- String
 * 
 * 编码问题简单，只要编码解码的格式是一致的。
 */
public class StringDemo {
	public static void main(String[] args) throws UnsupportedEncodingException {
		String s = "你好";

		// String -- byte[]
		byte[] bys = s.getBytes(); // [-60, -29, -70, -61]
		// byte[] bys = s.getBytes("GBK");// [-60, -29, -70, -61]
		// byte[] bys = s.getBytes("UTF-8");// [-28, -67, -96, -27, -91, -67]
		System.out.println(Arrays.toString(bys));

		// byte[] -- String
		String ss = new String(bys); // 你好
		// String ss = new String(bys, "GBK"); // 你好
		// String ss = new String(bys, "UTF-8"); // ???
		System.out.println(ss);
	}
}

```


由于字节流操作中文不是特别方便，容易出现编解码错误，所以，java就提供了转换流。

字符流=字节流+编码表。

	计算机只能识别二进制数据，早期由来是电信号。
	为了方便应用计算机，让它可以识别各个国家的文字。
	就将各个国家的文字用数字来表示，并一一对应，形成一张表。

	ASCII：美国标准信息交换码。
		用一个字节的7位可以表示。
	ISO8859-1：拉丁码表。欧洲码表
		用一个字节的8位表示。
	GB2312：中国的中文编码表。
	GBK：中国的中文编码表升级，融合了更多的中文文字符号。
	GB18030：GBK的取代版本
	BIG-5码 ：通行于台湾、香港地区的一个繁体字编码方案，俗称“大五码”。
	Unicode：国际标准码，融合了多种文字。
		所有文字都用两个字节来表示,Java语言使用的就是unicode
	UTF-8：最多用三个字节来表示一个字符。能用一个字节表示就用一个字节表示。

	UTF-8不同，它定义了一种“区间规则”，这种规则可以和ASCII编码保持最大程度的兼容：
	它将Unicode编码为00000000-0000007F的字符，用单个字节来表示，
	它将Unicode编码为00000080-000007FF的字符用两个字节表示，
	它将Unicode编码为00000800-0000FFFF的字符用3字节表示。

## 二、Writer

### 1、Writer

public abstract class Writer
extends Object
implements Appendable, Closeable, Flushable

写入字符流的抽象类。子类必须实现的方法仅有 write(char[], int, int)、flush() 和 close()。

#### （1）构造方法

	protected Writer()
		创建一个新的字符流 writer，其关键部分将同步 writer 自身。 

	protected Writer(Object lock)
		创建一个新的字符流 writer，其关键部分将同步给定的对象。

### 2、OutputStreamWriter 字符输出流

	public class OutputStreamWriter 
	extends Writer 

是 **字符流通向字节流** 的桥梁：可使用指定的 charset 将要写入流中的字符编码成字节。
它使用的 **字符集可以由名称指定或显式给定，否则将接受平台默认的字符集**。 

每次调用 write() 方法都会导致在给定字符（或字符集）上 **调用编码转换器**。
在写入底层输出流之前，得到的这些字节将在缓冲区中累积。可以指定此缓冲区
的大小，不过，默认的缓冲区对多数用途来说已足够大。注意，传递给 write() 
方法的字符没有缓冲。 

####（1）构造方法

	public OutputStreamWriter(OutputStream out)
		创建使用默认字符编码的 OutputStreamWriter

	public OutputStreamWriter(OutputStream out,String charsetName)
		throws UnsupportedEncodingException
		创建使用指定字符集的 OutputStreamWriter

```java
public class OutputStreamWriterDemo {
	public static void main(String[] args) throws IOException {
		// 创建对象
		// OutputStreamWriter osw = new OutputStreamWriter(new FileOutputStream(
		// "osw.txt")); // 默认GBK
		// OutputStreamWriter osw = new OutputStreamWriter(new FileOutputStream(
		// "osw.txt"), "GBK"); // 指定GBK
		OutputStreamWriter osw = new OutputStreamWriter(new FileOutputStream(
				"osw.txt"), "UTF-8"); // 指定UTF-8
		// 写数据
		osw.write("中国");

		// 释放资源
		osw.close();
	}
}
```

####（2）成员方法

	public void write(int c):写一个字符
	public void write(char[] cbuf,int off,int len):写一个字符数组的一部分
	public void write(String str,int off,int len):写一个字符串的一部分
	public void flush() throws IOException 刷新该流的缓冲
	public void close()throws IOException 关闭此流，但要先刷新它。
	
	父类方法：
	public void write(char[] cbuf):写一个字符数组
	public void write(String str):写一个字符串
	


```java
public class OutputStreamWriterDemo {
	public static void main(String[] args) throws IOException {
		// 创建对象
		OutputStreamWriter osw = new OutputStreamWriter(new FileOutputStream(
				"osw2.txt"));

		// 写数据
		// public void write(int c):写一个字符
		// osw.write('a');
		// osw.write(97);
		// 为什么数据没有进去呢?
		// 原因是：字符 = 2字节
		// 文件中数据存储的基本单位是字节。
		// void flush()

		// public void write(char[] cbuf):写一个字符数组
		// char[] chs = {'a','b','c','d','e'};
		// osw.write(chs);

		// public void write(char[] cbuf,int off,int len):写一个字符数组的一部分
		// osw.write(chs,1,3);

		// public void write(String str):写一个字符串
		// osw.write("我爱林青霞");

		// public void write(String str,int off,int len):写一个字符串的一部分
		osw.write("我爱林青霞", 2, 3);

		// 刷新缓冲区
		osw.flush();
		// osw.write("我爱林青霞", 2, 3);

		// 释放资源
		osw.close();
		// java.io.IOException: Stream closed
		// osw.write("我爱林青霞", 2, 3);
	}
}

```

面试题：close()和flush()的区别?

	A:close()关闭流对象，但是先刷新一次缓冲区。关闭之后，流对象不可以继续再使用了。
	B:flush()仅仅刷新缓冲区,刷新之后，流对象还可以继续使用。

### 3、FileWriter

	public class FileWriter
	extends OutputStreamWriter

用来 **写入字符文件的便捷类**。此类的构造方法假定默认字符编码和默认字节缓冲区大小
都是可接受的。要自己指定这些值，可以先在 FileOutputStream 上构造一个 
OutputStreamWriter。 

FileWriter 用于写入字符流。要写入原始字节流，请考虑使用 FileOutputStream。

#### （1）构造方法

	public FileWriter(File file)throws IOException
		根据给定的 File 对象构造一个 FileWriter 对象。 

	public FileWriter(File file,boolean append)throws IOException
		根据给定的 File 对象构造一个 FileWriter 对象。如果第二个参数为 true，则将字节写入文件末尾处，而不是写入文件开始处。 

	public FileWriter(String fileName)throws IOException
		根据给定的文件名构造一个 FileWriter 对象。 

	public FileWriter(String fileName,boolean append)throws IOException
		根据给定的文件名以及指示是否附加写入数据的 boolean 值来构造 FileWriter 对象。 

#### （2）成员方法

全部继承至父类OutputStreamWriter。

### 4、BufferedWriter 字符缓冲输出流

	public class BufferedWriter
	extends Writer

将文本写入字符输出流，缓冲各个字符，从而提供单个字符、数组和字符串的高效写入。 

可以指定缓冲区的大小，或者接受默认的大小。在大多数情况下，默认值就足够大了。

####（1）构造方法

	public BufferedWriter(Writer out)

		创建一个使用默认大小输出缓冲区的缓冲字符输出流。 

	public BufferedWriter(Writer out,int sz)
		创建一个使用给定大小输出缓冲区的新缓冲字符输出流。 

####（2）成员方法

	public void write(int c) throws IOException
		写入单个字符。 
	public void write(char[] cbuf,int off,int len)throws IOException
		写入字符数组的某一部分。 
	public void write(String s,int off,int len)throws IOException
		写入字符串的某一部分。 

```java
public class BufferedWriterDemo {
	public static void main(String[] args) throws IOException {
		// BufferedWriter(Writer out)
		// BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(
		// new FileOutputStream("bw.txt")));

		BufferedWriter bw = new BufferedWriter(new FileWriter("bw.txt"));

		bw.write("hello");
		bw.write("world");
		bw.write("java");
		bw.flush();

		bw.close();
	}
}
```
	public void newLine():写入一个行分隔符

```java
private static void write() throws IOException {
		// 创建字符缓冲输出流对象
		BufferedWriter bw = new BufferedWriter(new FileWriter("bw2.txt"));
		for (int x = 0; x < 10; x++) {
			bw.write("hello" + x);
			// bw.write("\r\n");
			bw.newLine();
			bw.flush();
		}
		bw.close();
	}
```

## 三、Reader

### 1、Reader

	public abstract class Reader
	extends Object
	implements Readable, Closeable

用于读取字符流的抽象类。子类必须实现的方法只有 read(char[], int, int) 和 close()。

#### （1）构造方法

	protected Reader()
		创建一个新的字符流 reader，其重要部分将同步其自身的 reader。 

	protected Reader(Object lock)
		创建一个新的字符流 reader，其重要部分将同步给定的对象。 

### 2、InputStreamReader 字符输入流

	public class InputStreamReader
	extends Reader

是 **字节流通向字符流** 的桥梁：它使用指定的 charset 读取字节并将其解码为字符。
它使用的字符集 **可以由名称指定或显式给定，或者可以接受平台默认的字符集**。 

每次调用 InputStreamReader 中的一个 read() 方法都会导致从底层输入流读取
一个或多个字节。要启用从字节到字符的有效转换，可以提前从底层流读取更多的
字节，使其超过满足当前读取操作所需的字节。 

####（1）构造方法

	public InputStreamReader(InputStream in)
		创建一个使用默认字符集的 InputStreamReader。

	public InputStreamReader(InputStream in,String charsetName)
		throws UnsupportedEncodingException
		创建使用指定字符集的 InputStreamReader。

```java
public class InputStreamReaderDemo {
	public static void main(String[] args) throws IOException {
		// 创建对象
		// InputStreamReader isr = new InputStreamReader(new FileInputStream(
		// "osw.txt"));

		// InputStreamReader isr = new InputStreamReader(new FileInputStream(
		// "osw.txt"), "GBK");

		InputStreamReader isr = new InputStreamReader(new FileInputStream(
				"osw.txt"), "UTF-8");

		// 读取数据
		// 一次读取一个字符
		int ch = 0;
		while ((ch = isr.read()) != -1) {
			System.out.print((char) ch);
		}

		// 释放资源
		isr.close();
	}
}

```
####（2）成员方法

	public int read():一次读取一个字符
	public int read(char[] chs):一次读取一个字符数组
	public void close()throws IOException 关闭该流并释放与之关联的所有资源
	
```java
public class InputStreamReaderDemo {
	public static void main(String[] args) throws IOException {
		// 创建对象
		InputStreamReader isr = new InputStreamReader(new FileInputStream(
				"StringDemo.java"));

		// 一次读取一个字符
		// int ch = 0;
		// while ((ch = isr.read()) != -1) {
		// System.out.print((char) ch);
		// }

		// 一次读取一个字符数组
		char[] chs = new char[1024];
		int len = 0;
		while ((len = isr.read(chs)) != -1) {
			System.out.print(new String(chs, 0, len));
		}

		// 释放资源
		isr.close();
	}
}

```
	public String readLine()：一次读取一行数据
	包含该行内容的字符串，不包含任何行终止符，如果已到达流末尾，则返回 null

```java
private static void read() throws IOException {
		// 创建字符缓冲输入流对象
		BufferedReader br = new BufferedReader(new FileReader("bw2.txt"));

		// public String readLine()：一次读取一行数据
		// String line = br.readLine();
		// System.out.println(line);
		// line = br.readLine();
		// System.out.println(line);

		// 最终版代码
		String line = null;
		while ((line = br.readLine()) != null) {
			System.out.println(line);
		}
		
		//释放资源
		br.close();
	}
```

### 3、FileReader

	public class FileReader
	extends InputStreamReader

用来读取字符文件的便捷类。此类的构造方法假定默认字符编码和默认字节缓冲区大小
都是适当的。要自己指定这些值，可以先在 FileInputStream 上构造一个 InputStreamReader。 

FileReader 用于读取字符流。要读取原始字节流，请考虑使用 FileInputStream。 

#### （1）构造方法

	public FileReader(File file)throws FileNotFoundException
		在给定从中读取数据的 File 的情况下创建一个新 FileReader。 

	public FileReader(String fileName)throws FileNotFoundException
		在给定从中读取数据的文件名的情况下创建一个新 FileReader。 		   

#### （2）成员方法

全部继承至父类InputStreamReader。

### 4、BufferedReader 字符缓冲输入流

	public class BufferedReader
	extends Reader

从字符输入流中读取文本，缓冲各个字符，从而实现字符、数组和行的高效读取。 

可以指定缓冲区的大小，或者可使用默认的大小。大多数情况下，默认值就足够大了

#### （1）构造方法

	public BufferedReader(Reader in)
		创建一个使用默认大小输入缓冲区的缓冲字符输入流。

	public BufferedReader(Reader in,int sz)
		创建一个使用指定大小输入缓冲区的缓冲字符输入流。

#### （2）成员方法

	public int read()throws IOException
		读取单个字符。 

	public int read(char[] cbuf,int off,int len)throws IOException
		将字符读入数组的某一部分。 

```java
public class BufferedReaderDemo {
	public static void main(String[] args) throws IOException {
		// 创建字符缓冲输入流对象
		BufferedReader br = new BufferedReader(new FileReader("bw.txt"));

		// 方式1
		// int ch = 0;
		// while ((ch = br.read()) != -1) {
		// System.out.print((char) ch);
		// }

		// 方式2
		char[] chs = new char[1024];
		int len = 0;
		while ((len = br.read(chs)) != -1) {
			System.out.print(new String(chs, 0, len));
		}

		// 释放资源
		br.close();
	}
}

```
### 5、LineNumberReader

	public class LineNumberReader
	extends BufferedReader

跟踪行号的缓冲字符输入流。此类定义了方法 setLineNumber(int) 和 getLineNumber()，它们可分别用于设置和获取当前行号。 

默认情况下，行编号从 0 开始。


## 四、练习

```java
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;

/*
 * 需求：把当前项目目录下的a.txt内容复制到当前项目目录下的b.txt中
 * 
 * 数据源：
 * 		a.txt -- 读取数据 -- 字符转换流 -- InputStreamReader
 * 目的地：
 * 		b.txt -- 写出数据 -- 字符转换流 -- OutputStreamWriter
 */
public class CopyFileDemo {
	public static void main(String[] args) throws IOException {
		// 封装数据源
		InputStreamReader isr = new InputStreamReader(new FileInputStream(
				"a.txt"));
		// 封装目的地
		OutputStreamWriter osw = new OutputStreamWriter(new FileOutputStream(
				"b.txt"));

		// 读写数据
		// 方式1
		// int ch = 0;
		// while ((ch = isr.read()) != -1) {
		// osw.write(ch);
		// }

		// 方式2
		char[] chs = new char[1024];
		int len = 0;
		while ((len = isr.read(chs)) != -1) {
			osw.write(chs, 0, len);
			// osw.flush();
		}

		// 释放资源
		osw.close();
		isr.close();
	}
}

```

```java
package cn.itcast_04;

import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

/*
 * 由于我们常见的操作都是使用本地默认编码，所以，不用指定编码。
 * 而转换流的名称有点长，所以，Java就提供了其子类供我们使用。
 * OutputStreamWriter = FileOutputStream + 编码表(GBK)
 * FileWriter = FileOutputStream + 编码表(GBK)
 * 
 * InputStreamReader = FileInputStream + 编码表(GBK)
 * FileReader = FileInputStream + 编码表(GBK)
 * 
 /*
 * 需求：把当前项目目录下的a.txt内容复制到当前项目目录下的b.txt中
 * 
 * 数据源：
 * 		a.txt -- 读取数据 -- 字符转换流 -- InputStreamReader -- FileReader
 * 目的地：
 * 		b.txt -- 写出数据 -- 字符转换流 -- OutputStreamWriter -- FileWriter
 */
public class CopyFileDemo2 {
	public static void main(String[] args) throws IOException {
		// 封装数据源
		FileReader fr = new FileReader("a.txt");
		// 封装目的地
		FileWriter fw = new FileWriter("b.txt");

		// 一次一个字符
		// int ch = 0;
		// while ((ch = fr.read()) != -1) {
		// fw.write(ch);
		// }

		// 一次一个字符数组
		char[] chs = new char[1024];
		int len = 0;
		while ((len = fr.read(chs)) != -1) {
			fw.write(chs, 0, len);
			fw.flush();
		}

		// 释放资源
		fw.close();
		fr.close();
	}
}

```

```java
package cn.itcast_06;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

/*
 * 需求：把当前项目目录下的a.txt内容复制到当前项目目录下的b.txt中
 * 
 * 数据源：
 * 		a.txt -- 读取数据 -- 字符转换流 -- InputStreamReader -- FileReader -- BufferedReader
 * 目的地：
 * 		b.txt -- 写出数据 -- 字符转换流 -- OutputStreamWriter -- FileWriter -- BufferedWriter
 */
public class CopyFileDemo {
	public static void main(String[] args) throws IOException {
		// 封装数据源
		BufferedReader br = new BufferedReader(new FileReader("a.txt"));
		// 封装目的地
		BufferedWriter bw = new BufferedWriter(new FileWriter("b.txt"));

		// 两种方式其中的一种一次读写一个字符数组
		char[] chs = new char[1024];
		int len = 0;
		while ((len = br.read(chs)) != -1) {
			bw.write(chs, 0, len);
			bw.flush();
		}

		// 释放资源
		bw.close();
		br.close();
	}
}

```

```java
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

/*
 * 需求：把当前项目目录下的a.txt内容复制到当前项目目录下的b.txt中
 * 
 * 数据源：
 * 		a.txt -- 读取数据 -- 字符转换流 -- InputStreamReader -- FileReader -- BufferedReader
 * 目的地：
 * 		b.txt -- 写出数据 -- 字符转换流 -- OutputStreamWriter -- FileWriter -- BufferedWriter
 */
public class CopyFileDemo2 {
	public static void main(String[] args) throws IOException {
		// 封装数据源
		BufferedReader br = new BufferedReader(new FileReader("a.txt"));
		// 封装目的地
		BufferedWriter bw = new BufferedWriter(new FileWriter("b.txt"));

		// 读写数据
		String line = null;
		while ((line = br.readLine()) != null) {
			bw.write(line);
			bw.newLine();
			bw.flush();
		}

		// 释放资源
		bw.close();
		br.close();
	}
}

```

## 五、IO流小结

![java41](https://s1.ax1x.com/2020/07/13/UJIoAf.png)

### 1、字符流复制5种方法

```java
package cn.itcast_01;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

/*
 * 复制文本文件
 * 
 * 分析：
 * 		复制数据，如果我们知道用记事本打开并能够读懂，就用字符流，否则用字节流。
 * 		通过该原理，我们知道我们应该采用字符流更方便一些。
 * 		而字符流有5种方式，所以做这个题目我们有5种方式。推荐掌握第5种。
 * 数据源：
 * 		c:\\a.txt -- FileReader -- BufferdReader
 * 目的地：
 * 		d:\\b.txt -- FileWriter -- BufferedWriter
 */
public class CopyFileDemo {
	public static void main(String[] args) throws IOException {
		String srcString = "c:\\a.txt";
		String destString = "d:\\b.txt";
		// method1(srcString, destString);
		// method2(srcString, destString);
		// method3(srcString, destString);
		// method4(srcString, destString);
		method5(srcString, destString);
	}

	// 字符缓冲流一次读写一个字符串
	private static void method5(String srcString, String destString)
			throws IOException {
		BufferedReader br = new BufferedReader(new FileReader(srcString));
		BufferedWriter bw = new BufferedWriter(new FileWriter(destString));

		String line = null;
		while ((line = br.readLine()) != null) {
			bw.write(line);
			bw.newLine();
			bw.flush();
		}

		bw.close();
		br.close();
	}

	// 字符缓冲流一次读写一个字符数组
	private static void method4(String srcString, String destString)
			throws IOException {
		BufferedReader br = new BufferedReader(new FileReader(srcString));
		BufferedWriter bw = new BufferedWriter(new FileWriter(destString));

		char[] chs = new char[1024];
		int len = 0;
		while ((len = br.read(chs)) != -1) {
			bw.write(chs, 0, len);
		}

		bw.close();
		br.close();
	}

	// 字符缓冲流一次读写一个字符
	private static void method3(String srcString, String destString)
			throws IOException {
		BufferedReader br = new BufferedReader(new FileReader(srcString));
		BufferedWriter bw = new BufferedWriter(new FileWriter(destString));

		int ch = 0;
		while ((ch = br.read()) != -1) {
			bw.write(ch);
		}

		bw.close();
		br.close();
	}

	// 基本字符流一次读写一个字符数组
	private static void method2(String srcString, String destString)
			throws IOException {
		FileReader fr = new FileReader(srcString);
		FileWriter fw = new FileWriter(destString);

		char[] chs = new char[1024];
		int len = 0;
		while ((len = fr.read(chs)) != -1) {
			fw.write(chs, 0, len);
		}

		fw.close();
		fr.close();
	}

	// 基本字符流一次读写一个字符
	private static void method1(String srcString, String destString)
			throws IOException {
		FileReader fr = new FileReader(srcString);
		FileWriter fw = new FileWriter(destString);

		int ch = 0;
		while ((ch = fr.read()) != -1) {
			fw.write(ch);
		}

		fw.close();
		fr.close();
	}
}

```

### 2、字节流复制4种方法

```java
package cn.itcast_01;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

/*
 * 复制图片
 * 
 * 分析：
 * 		复制数据，如果我们知道用记事本打开并能够读懂，就用字符流，否则用字节流。
 * 		通过该原理，我们知道我们应该采用字节流。
 * 		而字节流有4种方式，所以做这个题目我们有4种方式。推荐掌握第4种。
 * 
 * 数据源：
 * 		c:\\a.jpg -- FileInputStream -- BufferedInputStream
 * 目的地：
 * 		d:\\b.jpg -- FileOutputStream -- BufferedOutputStream
 */
public class CopyImageDemo {
	public static void main(String[] args) throws IOException {
		// 使用字符串作为路径
		// String srcString = "c:\\a.jpg";
		// String destString = "d:\\b.jpg";
		// 使用File对象做为参数
		File srcFile = new File("c:\\a.jpg");
		File destFile = new File("d:\\b.jpg");

		// method1(srcFile, destFile);
		// method2(srcFile, destFile);
		// method3(srcFile, destFile);
		method4(srcFile, destFile);
	}

	// 字节缓冲流一次读写一个字节数组
	private static void method4(File srcFile, File destFile) throws IOException {
		BufferedInputStream bis = new BufferedInputStream(new FileInputStream(
				srcFile));
		BufferedOutputStream bos = new BufferedOutputStream(
				new FileOutputStream(destFile));

		byte[] bys = new byte[1024];
		int len = 0;
		while ((len = bis.read(bys)) != -1) {
			bos.write(bys, 0, len);
		}

		bos.close();
		bis.close();
	}

	// 字节缓冲流一次读写一个字节
	private static void method3(File srcFile, File destFile) throws IOException {
		BufferedInputStream bis = new BufferedInputStream(new FileInputStream(
				srcFile));
		BufferedOutputStream bos = new BufferedOutputStream(
				new FileOutputStream(destFile));

		int by = 0;
		while ((by = bis.read()) != -1) {
			bos.write(by);
		}

		bos.close();
		bis.close();
	}

	// 基本字节流一次读写一个字节数组
	private static void method2(File srcFile, File destFile) throws IOException {
		FileInputStream fis = new FileInputStream(srcFile);
		FileOutputStream fos = new FileOutputStream(destFile);

		byte[] bys = new byte[1024];
		int len = 0;
		while ((len = fis.read(bys)) != -1) {
			fos.write(bys, 0, len);
		}

		fos.close();
		fis.close();
	}

	// 基本字节流一次读写一个字节
	private static void method1(File srcFile, File destFile) throws IOException {
		FileInputStream fis = new FileInputStream(srcFile);
		FileOutputStream fos = new FileOutputStream(destFile);

		int by = 0;
		while ((by = fis.read()) != -1) {
			fos.write(by);
		}

		fos.close();
		fis.close();
	}
}

```

```java
package cn.itcast_02;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

/*
 * 需求：把ArrayList集合中的字符串数据存储到文本文件
 * 
 * 分析：
 * 		通过题目的意思我们可以知道如下的一些内容，
 * 			ArrayList集合里存储的是字符串。
 * 			遍历ArrayList集合，把数据获取到。
 * 			然后存储到文本文件中。
 * 			文本文件说明使用字符流。
 * 
 * 数据源：
 * 		ArrayList<String> -- 遍历得到每一个字符串数据
 * 目的地：
 * 		a.txt -- FileWriter -- BufferedWriter
 */
public class ArrayListToFileDemo {
	public static void main(String[] args) throws IOException {
		// 封装数据与(创建集合对象)
		ArrayList<String> array = new ArrayList<String>();
		array.add("hello");
		array.add("world");
		array.add("java");

		// 封装目的地
		BufferedWriter bw = new BufferedWriter(new FileWriter("a.txt"));

		// 遍历集合
		for (String s : array) {
			// 写数据
			bw.write(s);
			bw.newLine();
			bw.flush();
		}

		// 释放资源
		bw.close();
	}
}

```

```java
package cn.itcast_02;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

/*
 * 需求：从文本文件中读取数据(每一行为一个字符串数据)到集合中，并遍历集合
 * 
 * 分析：
 * 		通过题目的意思我们可以知道如下的一些内容，
 * 			数据源是一个文本文件。
 * 			目的地是一个集合。
 * 			而且元素是字符串。
 * 
 * 数据源：
 * 		b.txt -- FileReader -- BufferedReader
 * 目的地：
 * 		ArrayList<String>
 */
public class FileToArrayListDemo {
	public static void main(String[] args) throws IOException {
		// 封装数据源
		BufferedReader br = new BufferedReader(new FileReader("b.txt"));
		// 封装目的地(创建集合对象)
		ArrayList<String> array = new ArrayList<String>();

		// 读取数据存储到集合中
		String line = null;
		while ((line = br.readLine()) != null) {
			array.add(line);
		}

		// 释放资源
		br.close();

		// 遍历集合
		for (String s : array) {
			System.out.println(s);
		}
	}
}

```

```java
package cn.itcast_03;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

/*
 * 需求：复制单极文件夹
 * 
 * 数据源：e:\\demo
 * 目的地：e:\\test
 * 
 * 分析：
 * 		A:封装目录
 * 		B:获取该目录下的所有文本的File数组
 * 		C:遍历该File数组，得到每一个File对象
 * 		D:把该File进行复制
 */
public class CopyFolderDemo {
	public static void main(String[] args) throws IOException {
		// 封装目录
		File srcFolder = new File("e:\\demo");
		// 封装目的地
		File destFolder = new File("e:\\test");
		// 如果目的地文件夹不存在，就创建
		if (!destFolder.exists()) {
			destFolder.mkdir();
		}

		// 获取该目录下的所有文本的File数组
		File[] fileArray = srcFolder.listFiles();

		// 遍历该File数组，得到每一个File对象
		for (File file : fileArray) {
			// System.out.println(file);
			// 数据源：e:\\demo\\e.mp3
			// 目的地：e:\\test\\e.mp3
			String name = file.getName(); // e.mp3
			File newFile = new File(destFolder, name); // e:\\test\\e.mp3

			copyFile(file, newFile);
		}
	}

	private static void copyFile(File file, File newFile) throws IOException {
		BufferedInputStream bis = new BufferedInputStream(new FileInputStream(
				file));
		BufferedOutputStream bos = new BufferedOutputStream(
				new FileOutputStream(newFile));

		byte[] bys = new byte[1024];
		int len = 0;
		while ((len = bis.read(bys)) != -1) {
			bos.write(bys, 0, len);
		}

		bos.close();
		bis.close();
	}
}

```

```java
package cn.itcast_05;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

/*
 * 需求：复制多极文件夹
 * 
 * 数据源：E:\JavaSE\day21\code\demos
 * 目的地：E:\\
 * 
 * 分析：
 * 		A:封装数据源File
 * 		B:封装目的地File
 * 		C:判断该File是文件夹还是文件
 * 			a:是文件夹
 * 				就在目的地目录下创建该文件夹
 * 				获取该File对象下的所有文件或者文件夹File对象
 * 				遍历得到每一个File对象
 * 				回到C
 * 			b:是文件
 * 				就复制(字节流)
 */
public class CopyFoldersDemo {
	public static void main(String[] args) throws IOException {
		// 封装数据源File
		File srcFile = new File("E:\\JavaSE\\day21\\code\\demos");
		// 封装目的地File
		File destFile = new File("E:\\");

		// 复制文件夹的功能
		copyFolder(srcFile, destFile);
	}

	private static void copyFolder(File srcFile, File destFile)
			throws IOException {
		// 判断该File是文件夹还是文件
		if (srcFile.isDirectory()) {
			// 文件夹
			File newFolder = new File(destFile, srcFile.getName());
			newFolder.mkdir();

			// 获取该File对象下的所有文件或者文件夹File对象
			File[] fileArray = srcFile.listFiles();
			for (File file : fileArray) {
				copyFolder(file, newFolder);
			}
		} else {
			// 文件
			File newFile = new File(destFile, srcFile.getName());
			copyFile(srcFile, newFile);
		}
	}

	private static void copyFile(File srcFile, File newFile) throws IOException {
		BufferedInputStream bis = new BufferedInputStream(new FileInputStream(
				srcFile));
		BufferedOutputStream bos = new BufferedOutputStream(
				new FileOutputStream(newFile));

		byte[] bys = new byte[1024];
		int len = 0;
		while ((len = bis.read(bys)) != -1) {
			bos.write(bys, 0, len);
		}

		bos.close();
		bis.close();
	}
}

```

用Reader模拟BufferedReader的readLine()功能

自定义类模拟LineNumberReader的特有功能
获取每次读取数据的行号
