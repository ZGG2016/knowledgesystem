# IO流02：InputStream

[TOC]

## 1、InputStream

	public abstract class InputStream
	extends Object
	implements Closeable

此抽象类是表示 **字节输入流的所有类的超类**

需要定义 InputStream 子类的应用程序必须总是提供返回下一个输入字节的方法。

### 1.1、构造方法

具体描述见API

### 1.2、成员方法

具体描述见API

## 2、FileInputStream

	public class FileInputStream
	extends InputStreamFileInputStream 

**从文件系统中的某个文件中获得输入字节**。哪些文件可用取决于主机环境。 

FileInputStream 用于读取诸如图像数据之类的原始字节流。要读取字符流，请考虑使用 FileReader。 

### 2.1、构造方法

具体描述见API

### 2.2、成员方法

具体描述见API

```java
public class FileInputStreamDemo {
    public static void main(String[] args) throws IOException {

        // 1.构造方法

//        FileInputStream fis = new FileInputStream(new File("fos.txt"));
        FileInputStream fis = new FileInputStream("fos.txt");

        // 2.成员方法的基本使用

        //返回下一次对此输入流调用的方法可以不受阻塞地从此输入流读取（或跳过）的估计剩余字节数。
//        System.out.println(fis.available()); //103
//
//        int n1 = fis.read();  // 一次读取一个字节
//        System.out.println("读的字节："+n1);
//        System.out.println("读的字节为："+(char)n1);
//
//        //跳过和丢弃此输入流中数据的 n 个字节
//        //传入要跳过的字符数 ，返回实际跳过的字符数
//        long i = fis.skip(3);
//        System.out.println((char)fis.read());  //b
//
//        System.out.println(fis.available()); //98
//
//        byte[] bys1 = new byte[1024];
//        int n2 = fis.read(bys1);  // 一次读入一个字节数组
//        System.out.println("读入的字节数："+ n2);
//        System.out.println("读入一个字节数组："+ Arrays.toString(bys1));
//
//        byte[] bys2 = new byte[1024];
//        int n3 = fis.read(bys2,0,3);  // 一次读入一个字节数组的一部分
//        System.out.println("读入的字节数："+ n3);
//        System.out.println("读入一个字节数组的一部分："+ Arrays.toString(bys2));

        //3.循环读取

        int by = 0;
        while ((by = fis.read()) != -1) {
            System.out.print((char) by);
        }

        // 数组的长度一般是1024或者1024的整数倍
        byte[] bys = new byte[1024];
        int len = 0;
        while ((len = fis.read(bys)) != -1) {   // 一次读取1024个字节
            System.out.print(new String(bys, 0, len));
        }

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

## 3、BufferedInputStream

-------------------------------------------------------------------------

字节流一次读写一个数组的速度明显比一次读写一个字节的速度快很多，
这是加入了数组这样的缓冲区效果，java本身在设计的时候，
也考虑到了这样的设计思想(装饰设计模式后面讲解)，所以提供了字节缓冲区流。

	字节缓冲输出流：BufferedOutputStream
	字节缓冲输入流：BufferedInputStream

-------------------------------------------------------------------------

	public class BufferedInputStream
	extends FilterInputStreamBuffered

为另一个输入流添加一些功能，即**缓冲输入**以及**支持 mark 和 reset 方法的能力**。

在创建 BufferedInputStream 时，会创建一个**内部缓冲区数组**。在读取或跳过流中的字节时，可根据需要从包含的输入流再次填充该内部缓冲区，一次填充多个字节。

mark 操作记录输入流中的某个点，reset操作使得在从包含的输入流中获取新字节之前，再次读取自最后一次 mark 操作后读取的所有字节。 

### 3.1、构造方法

具体描述见API

### 3.2、成员方法

具体描述见API

```java
public class BufferedInputStreamDemo {
    public static void main(String[] args) throws IOException {

        // 1.构造方法

        BufferedInputStream bis = new BufferedInputStream(new FileInputStream(
                "bos.txt"));
//        BufferedInputStream bis = new BufferedInputStream(new FileInputStream(
//                "bos.txt"),2);

        // 2.成员方法的基本使用

        //返回下一次对此输入流调用的方法可以不受阻塞地从此输入流读取（或跳过）的估计剩余字节数。
//        System.out.println(bis.available()); //23
//
//        int n1 = bis.read();  // 一次读取一个字节
//        System.out.println("读的字节："+n1);  //97
//        System.out.println("读的字节为："+(char)n1);  //a
//
//        //跳过和丢弃此输入流中数据的 n 个字节
//        //传入要跳过的字符数 ，返回实际跳过的字符数
//        long i = bis.skip(3);
//        System.out.println((char)bis.read());  //b
//
//        System.out.println(bis.available()); //18
//
//        byte[] bys1 = new byte[1024];
//        int n2 = bis.read(bys1);  // 一次读入一个字节数组   , 父类方法
//        System.out.println("读入的字节数："+ n2);  //18
//        //[99, 100, 101, 104, 101, 108, 108, 111, 13, 10, 98, 99, 100, 104, 101, 108, 13, 10, 0,
//        System.out.println("读入一个字节数组："+ Arrays.toString(bys1));
//
//        byte[] bys2 = new byte[1024];
//        int n3 = bis.read(bys2,0,3);  // 一次读入一个字节数组的一部分
//        System.out.println("读入的字节数："+ n3);
//        System.out.println("读入一个字节数组的一部分："+ Arrays.toString(bys2));

        // 3.循环读取

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