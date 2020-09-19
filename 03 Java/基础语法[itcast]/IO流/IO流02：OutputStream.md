# IO流01：OutputStream

[TOC]

IO流用来处理设备之间的数据传输：上传文件、下载文件

Java对数据的操作是通过流的方式

Java用于操作流的对象都在IO包中

什么情况下使用哪种流呢?

	如果数据所在的文件通过windows自带的记事本打开并能读懂里面的内容，就用字符流。其他用字节流。
	如果你什么都不知道，就用字节流。

## 1、分类

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

## 2、OutputStream

	public abstract class OutputStream
	extends Object implements Closeable, Flushable

此抽象类是表示**输出字节流**的所有类的**超类**。

输出流接受输出字节并将这些字节发送到某个接收器。 

需要定义 OutputStream 子类的应用程序必须始终提供至少一种可写入一个输出字节的方法。 

### 2.1、构造方法

具体描述见API

### 2.2、成员方法

这里的`public abstract void write(int b) throws IOException`是抽象方法

具体描述见API

## 3、FileOutputStream

	public class FileOutputStream extends OutputStream

文件输出流是用于**将数据写入 File 或 FileDescriptor**的输出流。

文件是否可用或能否可以被创建取决于基础平台。特别是某些平台一次只允许一个 FileOutputStream（或其他文件写入对象）打开文件进行写入。在这种情况下，如果所涉及的文件已经打开，则此类中的构造方法将失败。 

FileOutputStream 用于写入诸如图像数据之类的原始字节的流。要写入字符流，请考虑使用 FileWriter。 

### 3.1、构造方法

具体描述见API

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

### 3.2、成员方法

具体描述见API

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
 *              【追加指的是，第二次执行程序产生的结果会在第一次执行程序产生结果的后面】
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

## 4、BufferedOutputStream

-------------------------------------------------------------------------

字节流一次读写一个数组的速度明显比一次读写一个字节的速度快很多，
这是加入了数组这样的缓冲区效果，java本身在设计的时候，
也考虑到了这样的设计思想(装饰设计模式后面讲解)，所以提供了字节缓冲区流。

	字节缓冲输出流：BufferedOutputStream
	字节缓冲输入流：BufferedInputStream

-------------------------------------------------------------------------

	public class BufferedOutputStream
	extends FilterOutputStream

该类实现**缓冲的输出流**。

通过设置这种输出流，应用程序就可以将各个字节写入底层输出流中，而不必针对每次字节写入调用底层系统。

### 4.1、构造方法

具体描述见API

### 4.2、成员方法

具体描述见API

```java
public class BufferedOutputStreamDemo {
    public static void main(String[] args) throws IOException {

        // 1.构造方法
        BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream("bos.txt"));
//        BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream("bos.txt"),2);

        
        //2.成员方法

        //写一个字节
        bos.write(97);
        bos.write("\r\n".getBytes());  //数据的换行

        byte[] bys={97,98,99,100,101};

        //写一个字节数组
        bos.write(bys);   //父类方法
        bos.write(("hello").getBytes());
        bos.write("\r\n".getBytes());

        //写一个字节数组的一部分
        bos.write(bys,1,3);
        bos.write("hello".getBytes(),0,3);
        bos.write("\r\n".getBytes());

        //bos.flush();

        bos.close();

    }
}

```