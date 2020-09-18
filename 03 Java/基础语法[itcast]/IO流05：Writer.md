# IO流3：Writer

[TOC]

## 1、Writer

	public abstract class Writer
	extends Object
	implements Appendable, Closeable, Flushable

**写入字符流的抽象类**。

子类必须实现的方法仅有 `write(char[], int, int)`、`flush()` 和 `close()`。

直接已知子类： 

	BufferedWriter, OutputStreamWriter,

### 1.1、构造方法

具体描述见API

### 1.2、成员方法

具体描述见API

## 2、OutputStreamWriter

	public class OutputStreamWriter 
	extends Writer 

是 **字符流通向字节流的桥梁**：

可**使用指定的 charset 将要写入流中的字符编码成字节。**

它使用的 **字符集可以由名称指定或显式给定，否则将接受平台默认的字符集**。 【见构造方法】

每次调用 write() 方法都会导致**在给定字符（或字符集）上调用编码转换器。
在写入底层输出流之前，得到的这些字节将在缓冲区中累积**。可以指定此缓冲区
的大小，不过，默认的缓冲区对多数用途来说已足够大。
【先对字符\字符集编码，再将编码后得到的字节写入缓冲区，最后写入底层输出流。】

注意，传递给 write() 方法的**字符**没有缓冲。 

为了获得最高效率，可考虑将 OutputStreamWriter 包装到 BufferedWriter 中，以避免频繁调用转换器。例如： 

	Writer out = new BufferedWriter(new OutputStreamWriter(System.out));

直接已知子类：FileWriter 

### 2.1、构造方法         

> 创建使用**默认字符编码**的 OutputStreamWriter。 

	public OutputStreamWriter(OutputStream out)

> 创建使用**指定字符集**的 OutputStreamWriter。 
 
	public OutputStreamWriter(OutputStream out,String charsetName)
                   throws UnsupportedEncodingException
             
    其中，charsetName - 受支持 charset 的名称 


```java
public class OutputStreamWriterDemo {
    public static void main(String[] args) throws IOException {
        
        // 1、构造方法
        //OutputStreamWriter osw = new OutputStreamWriter(new FileOutputStream("osw.txt"));
        OutputStreamWriter osw = new OutputStreamWriter(new FileOutputStream(
         "osw.txt"), "GBK");

        osw.write("中国");
        
        osw.close();
    }
}
```

### 2.2、成员方法

具体描述见API

方法使用：

```java
public class OutputStreamWriterDemo {
    public static void main(String[] args) throws IOException {

        OutputStreamWriter osw = new OutputStreamWriter(new FileOutputStream(
         "osw.txt"), "GBK");


        //2、成员方法

        //获取默认的字符编码【创建对象时没有指定】
//        OutputStreamWriter osw = new OutputStreamWriter(new FileOutputStream("osw.txt"));
//        System.out.println(osw.getEncoding());  //UTF8 依赖于编辑器设置的编码方式

        osw.write('a'); //写一个字符

        char[] chs = {'a','b','c','d','e'};
        osw.write(chs);     //写一个字符数组 ， 父类方法
        osw.write(chs,1,3); //写一个字符数组的一部分

        osw.write("我爱林青霞");       // 写一个字符串 ， 父类方法
        osw.write("我爱林青霞", 2, 3); // 写一个字符串的一部分

        osw.append('z');           //追加一个字符 ， 父类方法
        osw.append("追加示例");     //追加一个字符序列 ， 父类方法
        osw.append("追加示例",0,2); //追加一个字符序列的一部分 ， 父类方法


        // 刷新缓冲区
        //osw.flush();
        // osw.write("我爱林青霞", 2, 3);  //可以写成功

        // 释放资源
        osw.close();
        // java.io.IOException: Stream closed
        // osw.write("我爱林青霞", 2, 3);  //报错
    }
}

```

flush()和close()的作用：

```java
public class OutputStreamWriterDemo {
    public static void main(String[] args) throws IOException {

        OutputStreamWriter osw = new OutputStreamWriter(new FileOutputStream(
         "osw.txt"), "GBK");

        //3、flush()和close()的作用
        // 执行如下语句，内容并不会写入到文件。因为，内容并不是直接写入到文件，而是先进入缓冲区，
        // 经过flush()或close()后，才写入到文件。
        osw.write('a');
    }
}
```
面试题：close()和flush()的区别

	A:close()关闭流对象，但是先刷新一次缓冲区。关闭之后，流对象不可以继续再使用了。
	B:flush()仅仅刷新缓冲区，刷新之后，流对象还可以继续使用。

## 3、FileWriter

	public class FileWriter
	extends OutputStreamWriter

用来 **写入字符文件的便捷类**。

此类的构造方法假定默认字符编码和默认字节缓冲区大小
都是可接受的。要自己指定这些值，可以先在 FileOutputStream 上构造一个 
OutputStreamWriter。 

文件是否可用或是否可以被创建取决于底层平台。特别是某些平台一次只允许一个 FileWriter（或其他文件写入对象）打开文件进行写入。在这种情况下，如果所涉及的文件已经打开，则此类中的构造方法将失败。

FileWriter 用于写入字符流。要写入原始字节流，请考虑使用 FileOutputStream。

### 3.1、构造方法

具体描述见API

### 3.2、成员方法

全部是继承的方法。

```java
public class FileWriterDemo {
    public static void main(String[] args) throws IOException {

        //FileWriter fw = new FileWriter(new File("fw.txt"));
        FileWriter fw = new FileWriter("fw.txt");

        // 只测试写入一个字符串
        // 文件内容：fw-demo1 fw-demo2 append
        fw.write("fw-demo1");  //写入
        fw.write(" fw-demo2");
        fw.append(" append");   //追加

        fw.close();
    }
}
```
## 4、BufferedWriter

	public class BufferedWriter extends Writer

**将文本写入字符输出流，缓冲各个字符**，从而提供单个字符、数组和字符串的高效写入。 

【字符缓冲输出流】

可以指定缓冲区的大小，或者接受默认的大小。在大多数情况下，默认值就足够大了。 

该类**提供了 newLine() 方法**，它使用平台自己的行分隔符概念，此概念由系统属性 line.separator 定义。并非所有平台都使用新行符 ('\n') 来终止各行。因此调用此方法来终止每个输出行要优于直接写入新行符。 

### 4.1、构造方法

具体描述见API

### 4.2、成员方法

具体描述见API

```java
public class BufferedWriterDemo {
    public static void main(String[] args) throws IOException{

        //1、构造方法

        // BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(
        // new FileOutputStream("bw.txt")));
        BufferedWriter bw = new BufferedWriter(new FileWriter("bw.txt"));

        //2、成员方法

        bw.write('a'); //写一个字符

        char[] chs = {'a','b','c','d','e'};
        bw.write(chs); //写一个字符数组  ， 父类方法
        bw.write(chs,1,3); //写一个字符数组的一部分

        bw.write("我爱林青霞"); // 写一个字符串  ， 父类方法
        bw.write("我爱林青霞", 2, 3); // 写一个字符串的一部分

        bw.append('z'); //追加一个字符 ， 父类方法
        bw.append("追加示例"); //追加一个字符序列 ， 父类方法
        bw.append("追加示例",0,2); //追加一个字符序列的一部分 ， 父类方法

        for (int x = 0; x < 10; x++) {
            bw.write("hello" + x);
            // bw.write("\r\n");
            bw.newLine();
            //bw.flush();
        }

        bw.close();
    }
}
```

## 5、BufferedWriter、OutputStreamWriter、FileWriter区别

继承关系：

	Writer --> OutputStreamWriter -->  FileWriter
	       --> BufferedWriter

FileWriter：写入字符文件的便捷类。

BufferedWriter：将文本写入字符输出流，缓冲各个字符，提供更高效的写入。

OutputStreamWriter：字符流通向字节流的桥梁。

	每次调用write方法都会先对给定字符（或字符集）编码，成为字节；这些字节在缓冲区累计；最后写入底层输出流。

所以：

	BufferedWriter的效率要比FileWriter高。因为BufferedWriter使用了缓存会在缓存满了以后才输出到文件中。而FileWriter是每写一次数据，就会输出到文件。

而，

	在创建BufferedWriter对象时，是需要一个Writer对象的。所以，也离不开FileWriter。

所以，可以使用这种方式`BufferedWriter bw = new BufferedWriter(new FileWriter("bw.txt"));`来写入字符流。