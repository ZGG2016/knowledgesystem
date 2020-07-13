# IO流02：OutputStream、InputStream

IO流用来处理设备之间的数据传输：上传文件、下载文件

Java对数据的操作是通过流的方式

Java用于操作流的对象都在IO包中

什么情况下使用哪种流呢?

	如果数据所在的文件通过windows自带的记事本打开并能读懂里面的内容，就用字符流。其他用字节流。
	如果你什么都不知道，就用字节流。

## 一、分类

流向：

	输入流	读取数据
	输出流	写出数据

数据类型：

	字节流

		字节输入流	读取数据	InputStream
		字节输出流	写出数据	OutputStream

	字符流

		字符输入流	读取数据	Reader
		字符输出流	写出数据	Writer

注意：一般我们在探讨IO流的时候，如果没有明确说明按哪种分类来说，
**默认情况下是按照数据类型来分的**。

## 二、OutputStream

### 1、OutputStream

	public abstract class OutputStream
	extends Object
	implements Closeable, Flushable

此抽象类是表示 **输出字节流的所有类的超类**。输出流接受输出字节并将这些字节发送到某个接收器。 

需要定义 OutputStream 子类的应用程序 **必须始终提供至少一种可写入一个输出字节的方法**。

#### （1）构造方法

	public OutputStream()
	
#### （2）成员方法

	public void close() throws IOException
		关闭此输出流并释放与此流有关的所有系统资源。
		close 的常规协定是：该方法将关闭输出流。关闭的流不能执行输出操作，也不能重新打开。

	public void write(byte[] b) throws IOException
		将 b.length 个字节从指定的 byte 数组写入此输出流。write(b) 的常规协定是：应该与调用 write(b, 0, b.length) 的效果完全相同。 
	
	public void write(byte[] b, int off, int len) throws IOException
		将指定 byte 数组中从偏移量 off 开始的 len 个字节写入此输出流。
		write(b, off, len) 的常规协定是：将数组 b 中的某些字节按顺序写入输出流；元素 b[off] 是此操作写入的第一个字节，b[off+len-1] 是此操作写入的最后一个字节。 
		OutputStream 的 write 方法对每个要写出的字节调用一个参数的 write 方法。建议子类重写此方法并提供更有效的实现。 
	
	public abstract void write(int b) throws IOException 
		将指定的字节写入此输出流。
		write 的常规协定是：向输出流写入一个字节。要写入的字节是参数 b 的八个低位。b 的 24 个高位将被忽略。 
		OutputStream 的子类必须提供此方法的实现。 

### 2、FileOutputStream

	public class FileOutputStream 
	extends OutputStream

文件输出流是用于 **将数据写入 File** 或 FileDescriptor 的输出流。

FileOutputStream 用于写入诸如图像数据之类的原始字节的流。要写入字符流，请考虑使用 FileWriter。 

#### （1）构造方法

	public FileOutputStream(File file) throws FileNotFoundException
		创建一个向指定 File 对象表示的文件中写入数据的文件输出流。
		
	public FileOutputStream(File file,boolean append) throws FileNotFoundException
		创建一个向指定 File 对象表示的文件中写入数据的文件输出流。
		如果第二个参数为 true，则将字节写入文件末尾处，而不是写入文件开始处。
	
	public FileOutputStream(String name) throws FileNotFoundException
		创建一个向具有指定名称的文件中写入数据的输出文件流。	
		
	public FileOutputStream(String name,boolean append) throws FileNotFoundException
		创建一个向具有指定 name 的文件中写入数据的输出文件流。
		如果第二个参数为 true，则将字节写入文件末尾处，而不是写入文件开始处。	

```java
public class FileOutputStreamDemo {
	public static void main(String[] args) throws IOException {
		// 创建字节输出流对象
		// FileOutputStream(File file)
		// File file = new File("fos.txt");
		// FileOutputStream fos = new FileOutputStream(file);
		// FileOutputStream(String name)
		FileOutputStream fos = new FileOutputStream("fos.txt");
		/*
		 * 创建字节输出流对象了做了几件事情：
		 * A:调用系统功能去创建文件
		 * B:创建fos对象
		 * C:把fos对象指向这个文件
		 */
		
		//写数据
		fos.write("hello,IO".getBytes());
		fos.write("java".getBytes());
		
		//释放资源
		//关闭此文件输出流并释放与此流有关的所有系统资源。
		fos.close();
		/*
		 * 为什么一定要close()呢?
		 * A:让流对象变成垃圾，这样就可以被垃圾回收器回收了
		 * B:通知系统去释放跟该文件相关的资源
		 */
		//java.io.IOException: Stream Closed
		//fos.write("java".getBytes());
	}
}

```

#### （2）成员方法
		
	public void write(byte[] b) throws IOException
		将 b.length 个字节从指定 byte 数组写入此文件输出流中。 

	public void write(byte[] b,int off,int len) throws IOException
		将指定 byte 数组中从偏移量 off 开始的 len 个字节写入此文件输出流。 
	
	public void write(int b) throws IOException
		将指定字节写入此文件输出流。实现 OutputStream 的 write 方法。 
		
	public void close() throws IOException
		关闭此文件输出流并释放与此流有关的所有系统资源。此文件输出流不能再用于写入字节。	

#### （3）示例

```java
public class FileOutputStreamDemo2 {
	public static void main(String[] args) throws IOException {
		// 创建字节输出流对象
		// OutputStream os = new FileOutputStream("fos2.txt"); // 多态
		FileOutputStream fos = new FileOutputStream("fos2.txt");

		// 调用write()方法
		//fos.write(97); //97 -- 底层二进制数据	-- 通过记事本打开 -- 找97对应的字符值 -- a
		// fos.write(57);
		// fos.write(55);
		
		//public void write(byte[] b):写一个字节数组
		byte[] bys={97,98,99,100,101};
		fos.write(bys);
		
		//public void write(byte[] b,int off,int len):写一个字节数组的一部分
		fos.write(bys,1,3);
		
		//释放资源
		fos.close();
	}
}

```

**数据的换行、追加**

```java
/*
 *  换行：
 * 		因为不同的系统针对不同的换行符号识别是不一样的?
 * 		windows:\r\n
 * 		linux:\n
 * 		Mac:\r
 * 		而一些常见的个高级记事本，是可以识别任意换行符号的。
 *
 * 追加：
 * 		利用带追加参数的构造方法
 */
public class FileOutputStreamDemo3 {
	public static void main(String[] args) throws IOException {
		// 创建字节输出流对象
		// FileOutputStream fos = new FileOutputStream("fos3.txt");
		// 创建一个向具有指定 name 的文件中写入数据的输出文件流。如果第二个参数为 true，则将字节写入文件末尾处，而不是写入文件开始处。
		FileOutputStream fos = new FileOutputStream("fos3.txt", true);

		// 写数据
		for (int x = 0; x < 10; x++) {
			fos.write(("hello" + x).getBytes());
			fos.write("\r\n".getBytes());
		}

		// 释放资源
		fos.close();
	}
}
```
**加入异常处理的字节输出流操作**

```java
public class FileOutputStreamDemo4 {
	public static void main(String[] args) {
		// 改进版
		// 为了在finally里面能够看到该对象就必须定义到外面，为了访问不出问题，还必须给初始化值
		FileOutputStream fos = null;
		try {
			// fos = new FileOutputStream("z:\\fos4.txt");
			fos = new FileOutputStream("fos4.txt");
			fos.write("java".getBytes());
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			// 如果fos不是null，才需要close()
			if (fos != null) {
				// 为了保证close()一定会执行，就放到这里了
				try {
					fos.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
	}
}

```
## 三、InputStream

### 1、InputStream

	public abstract class InputStream
	extends Object
	implements Closeable

此抽象类是表示 **字节输入流的所有类的超类**

需要定义 InputStream 子类的应用程序必须总是提供返回下一个输入字节的方法。 

#### （1）构造方法

	public InputStream()
	
#### （2）成员方法

	public abstract int read() throws IOException
		从输入流中读取数据的下一个字节。返回 0 到 255 范围内的 int 字节值。如果因为已经到达流末尾而没有可用的字节，则返回值 -1。
	public int read(byte[] b) throws IOException
		从输入流中读取一定数量的字节，并将其存储在缓冲区数组 b 中。以整数形式返回实际读取的字节数。
	public int read(byte[] b, int off, int len) throws IOException
		将输入流中最多 len 个数据字节读入 byte 数组。尝试读取 len 个字节，但读取的字节也可能小于该值。以整数形式返回实际读取的字节数。 
	close() 


### 2、FileInputStream

	public class FileInputStream
	extends InputStreamFileInputStream 

**从文件系统中的某个文件中获得输入字节**。哪些文件可用取决于主机环境。 

FileInputStream 用于读取诸如图像数据之类的原始字节流。
要读取字符流，请考虑使用 FileReader。 

#### （1）构造方法

	public FileInputStream(File file) throws FileNotFoundException
		通过打开一个到实际文件的连接来创建一个 FileInputStream，该文件通过文件系统中的 File 对象 file 指定。

	public FileInputStream(String name) throws FileNotFoundException
		通过打开一个到实际文件的连接来创建一个 FileInputStream，该文件通过文件系统中的路径名 name 指定。

#### （2）成员方法

	public int read() throws IOException
		从此输入流中读取一个数据字节。

		返回：
			下一个数据字节；如果已到达文件末尾，则返回 -1。
			
	public int read(byte[] b) throws IOException
		从此输入流中将最多 b.length 个字节的数据读入一个 byte 数组中。
	
		返回：(实际读取的字节个数)
			读入缓冲区的字节总数，如果因为已经到达文件末尾而没有更多的数据，则返回 -1。 

	public int read(byte[] b,int off,int len) throws IOException
		从此输入流中将最多 len 个字节的数据读入一个 byte 数组中。

	close() 

#### （3）示例

```java
/*
 * read()
 */
public class FileInputStreamDemo {
	public static void main(String[] args) throws IOException {
		// FileInputStream(String name)
		// FileInputStream fis = new FileInputStream("fis.txt");
		FileInputStream fis = new FileInputStream("FileOutputStreamDemo.java");

		// 用循环改进
		// int by = fis.read();
		// while (by != -1) {
		// System.out.print((char) by);
		// by = fis.read();
		// }

		// 最终版代码
		int by = 0;
		// 读取，赋值，判断
		while ((by = fis.read()) != -1) {
			System.out.print((char) by);
		}

		// 释放资源
		fis.close();
	}
}

```

```java
/*
 * read(byte[] b)
 */

public class FileInputStreamDemo2 {
	public static void main(String[] args) throws IOException {
		// 创建字节输入流对象
		// FileInputStream fis = new FileInputStream("fis2.txt");
		FileInputStream fis = new FileInputStream("FileOutputStreamDemo.java");

		// 最终版代码
		// 数组的长度一般是1024或者1024的整数倍
		byte[] bys = new byte[1024];
		int len = 0;
		while ((len = fis.read(bys)) != -1) {
			System.out.print(new String(bys, 0, len));
		}

		// 释放资源
		fis.close();
	}
}
```
**异常情况分析**

```java
class test {
    public static void main(String[] args) throws IOException {
        // 创建字节输入流对象
        FileInputStream fis = new FileInputStream("fis2.txt");
        
//         第一次读取
         byte[] bys = new byte[5];
         int len = fis.read(bys);
         System.out.println(len);
         System.out.println(new String(bys));

        System.out.println("===========================");
        
        // // 第二次读取
         len = fis.read(bys);
         System.out.println(len);
         System.out.println(new String(bys));

        System.out.println("===========================");

        // // 第三次读取
         len = fis.read(bys);
         System.out.println(len);
         System.out.println(new String(bys));

        System.out.println("===========================");

        // // 第四次读取
         len = fis.read(bys);
         System.out.println(len);
         System.out.println(new String(bys));

        // 释放资源
        fis.close();
    }
}

```

输入为:
	
	fis2.txt
		hello
		world
		java

输出为：

	5
	hello
	===========================
	5

	wor
	===========================
	5
	ld
	j
	===========================
	3
	ava
	j

最后一次读取的时候，覆盖了上一次读取的字节数据的前三个字节，
而保留了最后两个字节。

![java40](https://s1.ax1x.com/2020/07/13/UJVkLR.png)

#### （4）练习

```java
package cn.itcast_03;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

/*
 * 复制文本文件。
 * 
 * 数据源：从哪里来
 * a.txt	--	读取数据	--	FileInputStream	
 * 
 * 目的地：到哪里去
 * b.txt	--	写数据		--	FileOutputStream
 * 
 * java.io.FileNotFoundException: a.txt (系统找不到指定的文件。)
 * 
 * 这一次复制中文没有出现任何问题，为什么呢?
 * 上一次我们出现问题的原因在于我们每次获取到一个字节数据，就把该字节数据转换为了字符数据，然后输出到控制台。
 * 而这一次呢?确实通过IO流读取数据，写到文本文件，你读取一个字节，我就写入一个字节，你没有做任何的转换。
 * 它会自己做转换。
 */
public class CopyFileDemo {
	public static void main(String[] args) throws IOException {
		// 封装数据源
		FileInputStream fis = new FileInputStream("a.txt");
		// 封装目的地
		FileOutputStream fos = new FileOutputStream("b.txt");

		int by = 0;
		while ((by = fis.read()) != -1) {
			fos.write(by);
		}

		// 释放资源(先关谁都行)
		fos.close();
		fis.close();
	}
}

```

```java
/*
 * 需求：把c:\\a.txt内容复制到d:\\b.txt中
 * 
 * 数据源：
 * 		c:\\a.txt	--	读取数据	--	FileInputStream
 * 目的地：
 * 		d:\\b.txt	--	写出数据	--	FileOutputStream
 */
public class CopyFileDemo {
	public static void main(String[] args) throws IOException {
		// 封装数据源
		FileInputStream fis = new FileInputStream("c:\\a.txt");
		FileOutputStream fos = new FileOutputStream("d:\\b.txt");

		// 复制数据
		byte[] bys = new byte[1024];
		int len = 0;
		while ((len = fis.read(bys)) != -1) {
			fos.write(bys, 0, len);
		}

		// 释放资源
		fos.close();
		fis.close();
	}
}

```

#### （5）计算机中中文的存储

```java
/*
 * 计算机是如何识别什么时候该把两个字节转换为一个中文呢?
 * 在计算机中中文的存储分两个字节：
 * 		第一个字节肯定是负数。
 * 		第二个字节常见的是负数，可能有正数。但是没影响。
 */
public class StringDemo {
	public static void main(String[] args) {
		// String s = "abcde";
		// // [97, 98, 99, 100, 101]

		String s = "我爱你中国";
		// [-50, -46, -80, -82, -60, -29, -42, -48, -71, -6]

		byte[] bys = s.getBytes();
		System.out.println(Arrays.toString(bys));
	}
}
```

## 四、字节缓冲区流

字节流一次读写一个数组的速度明显比一次读写一个字节的速度快很多，
这是加入了数组这样的缓冲区效果，java本身在设计的时候，
也考虑到了这样的设计思想(装饰设计模式后面讲解)，所以提供了字节缓冲区流。

	字节缓冲输出流：BufferedOutputStream
	字节缓冲输入流：BufferedInputStream

###  1、BufferedOutputStream

	public class BufferedOutputStream
	extends FilterOutputStream

该类实现缓冲的输出流。通过设置这种输出流，应用程序就可以将各个字节写入
底层输出流中，而不必针对每次字节写入调用底层系统。

#### （1）构造方法

	public BufferedOutputStream(OutputStream out)
		创建一个新的缓冲输出流，以将数据写入指定的底层输出流。 

		参数：
			out - 底层输出流。


	public BufferedOutputStream(OutputStream out,int size)
		创建一个新的缓冲输出流，以将具有指定缓冲区大小的数据写入指定
		的底层输出流。 

		参数：
			out - 底层输出流。
			size - 缓冲区的大小。 

#### （2）成员方法

	public void write(int b) throws IOException
		将指定的字节写入此缓冲的输出流。 

		覆盖：
		类 FilterOutputStream 中的 write
 
	

	public void write(byte[] b,int off,int len)throws IOException
	
		将指定 byte 数组中从偏移量 off 开始的 len 个字节写入此缓冲的输出流。 
	
		一般来说，此方法将给定数组的字节存入此流的缓冲区中，根据需要将该缓冲
		区刷新，并转到底层输出流。但是，如果请求的长度至少与此流的缓冲区大小
		相同，则此方法将刷新该缓冲区并将各个字节直接写入底层输出流。因此多余
		的 BufferedOutputStream 将不必复制数据。 


		覆盖：
		类 FilterOutputStream 中的 write

```java
public class BufferedOutputStreamDemo {
	public static void main(String[] args) throws IOException {
		// BufferedOutputStream(OutputStream out)
		// FileOutputStream fos = new FileOutputStream("bos.txt");
		// BufferedOutputStream bos = new BufferedOutputStream(fos);
		// 简单写法
		BufferedOutputStream bos = new BufferedOutputStream(
				new FileOutputStream("bos.txt"));

		// 写数据
		bos.write("hello".getBytes());

		// 释放资源
		bos.close();
	}
}

```

### 2、BufferedInputStream

	public class BufferedInputStream
	extends FilterInputStream

BufferedInputStream 为另一个输入流添加一些功能，即缓冲输入以及支持 mark 
和 reset 方法的能力。在创建 BufferedInputStream 时，会创建一个内部缓冲区
数组。

#### （1）构造方法

	public BufferedInputStream(InputStream in)
		创建一个 BufferedInputStream 并保存其参数，即输入流 in，以便将来使用。
		创建一个内部缓冲区数组并将其存储在 buf 中。 

	public BufferedInputStream(InputStream in,int size)
		创建具有指定缓冲区大小的 BufferedInputStream 并保存其参数，即输入流 in，
		以便将来使用。创建一个长度为 size 的内部缓冲区数组并将其存储在 buf 中。 

#### （2）成员方法

	read() 
		参见 InputStream 的 read 方法的常规协定。 
	int read(byte[] b, int off, int len) 
		从此字节输入流中给定偏移量处开始将各字节读取到指定的 byte 数组中。 

```java
import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.IOException;

/*
 * 注意：虽然我们有两种方式可以读取，但是，请注意，这两种方式针对同一个对象在一个代码中只能使用一个。
 */
public class BufferedInputStreamDemo {
	public static void main(String[] args) throws IOException {
		// BufferedInputStream(InputStream in)
		BufferedInputStream bis = new BufferedInputStream(new FileInputStream(
				"bos.txt"));

		// 读取数据
		// int by = 0;
		// while ((by = bis.read()) != -1) {
		// System.out.print((char) by);
		// }
		// System.out.println("---------");

		byte[] bys = new byte[1024];
		int len = 0;
		while ((len = bis.read(bys)) != -1) {
			System.out.print(new String(bys, 0, len));
		}

		// 释放资源
		bis.close();
	}
}
```

## 五、字节流四种方式复制MP4及效率

```java
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

/*
 * 需求：把e:\\哥有老婆.mp4复制到当前项目目录下的copy.mp4中
 * 
 * 字节流四种方式复制文件：
 * 基本字节流一次读写一个字节：	共耗时：117235毫秒
 * 基本字节流一次读写一个字节数组： 共耗时：156毫秒
 * 高效字节流一次读写一个字节： 共耗时：1141毫秒
 * 高效字节流一次读写一个字节数组： 共耗时：47毫秒
 */
public class CopyMp4Demo {
	public static void main(String[] args) throws IOException {
		long start = System.currentTimeMillis();
		// method1("e:\\哥有老婆.mp4", "copy1.mp4");
		// method2("e:\\哥有老婆.mp4", "copy2.mp4");
		// method3("e:\\哥有老婆.mp4", "copy3.mp4");
		method4("e:\\哥有老婆.mp4", "copy4.mp4");
		long end = System.currentTimeMillis();
		System.out.println("共耗时：" + (end - start) + "毫秒");
	}

	// 高效字节流一次读写一个字节数组：
	public static void method4(String srcString, String destString)
			throws IOException {
		BufferedInputStream bis = new BufferedInputStream(new FileInputStream(
				srcString));
		BufferedOutputStream bos = new BufferedOutputStream(
				new FileOutputStream(destString));

		byte[] bys = new byte[1024];
		int len = 0;
		while ((len = bis.read(bys)) != -1) {
			bos.write(bys, 0, len);
		}

		bos.close();
		bis.close();
	}

	// 高效字节流一次读写一个字节：
	public static void method3(String srcString, String destString)
			throws IOException {
		BufferedInputStream bis = new BufferedInputStream(new FileInputStream(
				srcString));
		BufferedOutputStream bos = new BufferedOutputStream(
				new FileOutputStream(destString));

		int by = 0;
		while ((by = bis.read()) != -1) {
			bos.write(by);

		}

		bos.close();
		bis.close();
	}

	// 基本字节流一次读写一个字节数组
	public static void method2(String srcString, String destString)
			throws IOException {
		FileInputStream fis = new FileInputStream(srcString);
		FileOutputStream fos = new FileOutputStream(destString);

		byte[] bys = new byte[1024];
		int len = 0;
		while ((len = fis.read(bys)) != -1) {
			fos.write(bys, 0, len);
		}

		fos.close();
		fis.close();
	}

	// 基本字节流一次读写一个字节
	public static void method1(String srcString, String destString)
			throws IOException {
		FileInputStream fis = new FileInputStream(srcString);
		FileOutputStream fos = new FileOutputStream(destString);

		int by = 0;
		while ((by = fis.read()) != -1) {
			fos.write(by);
		}

		fos.close();
		fis.close();
	}
}

```