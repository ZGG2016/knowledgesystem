# IO流4：Reader

[TOC]

## 1、Reader

	public abstract class Reader
	extends Object
	implements Readable, Closeable

用于读取字符流的抽象类。

子类必须实现的方法只有 `read(char[], int, int) 和 close()`。但是，多数子类将重写此处定义的一些方法，以提供更高的效率和/或其他功能。 

直接已知子类： BufferedReader、InputStreamReader

### 1.1、构造方法

具体描述见API

### 1.2、成员方法

具体描述见API

## 2、InputStreamReader

	public class InputStreamReader
	extends Reader

是**字节流通向字符流的桥梁**。

它使用指定的 **charset 读取字节并将其解码为字符**。它使用的字符集可以由名称指定或显式给定，或者可以接受平台默认的字符集。 

**每次调用 InputStreamReader 中的一个 read() 方法都会导致从底层输入流读取一个或多个字节**。要启用从字节到字符的有效转换，可以提前从底层流读取更多的字节，使其超过满足当前读取操作所需的字节。 

为了达到最高效率，可要考虑在 BufferedReader 内包装 InputStreamReader。例如： 

	BufferedReader in = new BufferedReader(new InputStreamReader(System.in));

直接已知子类： FileReader 

### 2.1、构造方法

> 创建一个使用**默认字符集**的 InputStreamReader。

	public InputStreamReader(InputStream in)
		
> 创建使用**指定字符集**的 InputStreamReader。

	public InputStreamReader(InputStream in,String charsetName)
		throws UnsupportedEncodingException

	charsetName - 受支持的 charset 的名称 

```java
public class InputStreamReaderDemo {
    public static void main(String[] args) throws IOException {
        // 1.构造方法

        // InputStreamReader isr = new InputStreamReader(new FileInputStream(
        // "osw.txt"));
         InputStreamReader isr = new InputStreamReader(new FileInputStream(
                 "osw.txt"), "GBK");
        // 一次读取一个字符
        int ch = 0;
        while ((ch = isr.read()) != -1) {
            System.out.print((char) ch);
        }
        
        isr.close();
    }
}
```

其他具体描述见API

### 2.2、成员方法

具体描述见API

方法使用：

	read()：返回作为整数读取的字符。范围在 0 到 65535 之间 (0x00-0xffff)，如果已到达流的末尾，则返回 -1 。

	read(char[] cbuf)：返回的是读取的字符数。如果已到达流的末尾，则返回 -1 

```java
public class InputStreamReaderDemo {
    public static void main(String[] args) throws IOException {
         InputStreamReader isr = new InputStreamReader(new FileInputStream(
                 "osw.txt"), "GBK");

         // 2.成员方法的基本使用

        int ch = isr.read(); // 一次读取一个字符
        //a
        System.out.println("读单个字符："+(char) ch);
        System.out.println(ch);  //97

        char[] chs1 = new char[1024];
        int n1 = isr.read(chs1,0,3); //将字符读入字符数组中的一部分。
        //3
        System.out.println("读的字符数："+ n1);
        //[a, b, c,  ,  , ...]
        System.out.println("读字符到字符数组的一部分："+ Arrays.toString(chs1));

        char[] chs2 = new char[1024];
        int n2 = isr.read(chs2);  //将字符读入字符数组   ，  父类方法
        //20
        System.out.println("读的字符数："+ n2);
        //接着上个读取：[d, e, b, c, d, 我, 爱, 林, 青, 霞, 林, 青, 霞, z, 追, 加, 示, 例, 追, 加,  ...]
        System.out.println("读字符到字符数组："+ Arrays.toString(chs2));

        //判断此流是否支持 mark() 操作。默认实现始终返回 false。子类应重写此方法。
        System.out.println(isr.markSupported());  //false

        isr.close();
    }
}

```

```java
public class InputStreamReaderDemo {
    public static void main(String[] args) throws IOException {
         InputStreamReader isr = new InputStreamReader(new FileInputStream(
                 "osw.txt"), "GBK");

        // 3.循环读取
        // (1)利用 一次读取一个字符
//        int nch1 = 0;
//        while((nch1=isr.read())!=-1){
//            System.out.println((char)nch1);
//        }
        
        // (2)利用 一次读取到一个字符数组
        int nch2 = 0;
        char[] chs3 = new char[1024];
        while((nch2=isr.read(chs3))!=-1){
            System.out.println(new String(chs3, 0, nch2));
        }

        //判断此流是否已经准备好用于读取。如果其输入缓冲区不为空，或者可从底层字节流读取字节，
        // 则 InputStreamReader 已做好被读取准备。
        System.out.println(isr.ready()); //false

        isr.close();
    }
}
```

## 3、FileReader

	public class FileReader
	extends InputStreamReader

用来**读取字符文件的便捷类**。

此类的构造方法假定默认字符编码和默认字节缓冲区大小都是适当的。要自己指定这些值，可以先在 FileInputStream 上构造一个 InputStreamReader。 

FileReader 用于读取字符流。要读取原始字节流，请考虑使用 FileInputStream。 

### 3.1、构造方法

具体描述见API

### 3.2、成员方法

全部是继承的方法。

```java
public class FileReaderDemo {
    public static void main(String[] args) throws IOException {
//        FileReader fr = new FileReader(new File("fw.txt"));
        FileReader fr = new FileReader("fw.txt");

        //只测试read

//        int nch1 = 0;
//        while ((nch1=fr.read())!=-1){
//            System.out.println((char)nch1);
//        }

        int nch2 = 0;
        char[] chs = new char[1024];
        while((nch2=fr.read(chs))!=-1){
            System.out.println(new String(chs, 0, nch2));
        }

        fr.close();
    }
}
```

## 4、BufferedReader

	public class BufferedReader
	extends Reader

**从字符输入流中读取文本，缓冲各个字符**，从而实现字符、数组和行的**高效读取**。 

可以指定缓冲区的大小，或者可使用默认的大小。大多数情况下，默认值就足够大了。 

通常，Reader 所作的每个读取请求都会导致对底层字符或字节流进行相应的读取请求。因此，建议用 BufferedReader 包装所有其 read() 操作可能开销很高的 Reader（如 FileReader 和 InputStreamReader）。例如， 

	BufferedReader in = new BufferedReader(new FileReader("foo.in"));

**将缓冲指定文件的输入。**

**如果没有缓冲，则每次调用 read() 或 readLine() 都会导致从文件中读取字节，并将其转换为字符后返回**，而这是极其低效的。 

通过用合适的 BufferedReader 替代每个 DataInputStream，可以对将 DataInputStream 用于文字输入的程序进行本地化。 

### 4.1、构造方法

具体描述见API

### 4.2、成员方法

具体描述见API

```java
public class BufferedReaderDemo {
    public static void main(String[] args) throws IOException {

        // 1.构造方法

//        BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream("bw.txt")));

        BufferedReader br = new BufferedReader(new FileReader("bw.txt"));

        // 2.成员方法的基本使用
//        int ch = br.read();  // 一次读取一个字符
//        System.out.println("读的一个字符：" + ch);  //97
//        System.out.println("读的一个字符：" + (char)ch);  //a

        //传入要跳过的字符数 ，返回实际跳过的字符数 
//        long i = br.skip(1);
//        System.out.println((char)br.read());

//        char[] chs1 = new char[1024];
//        int n1 = br.read(chs1,0,3); //将字符读入字符数组中的一部分。
//        //3
//        System.out.println("读的字符数："+ n1);
//        System.out.println("读字符到字符数组的一部分："+ Arrays.toString(chs1)); //[a, b, c,  ,  ...]
//
//        String s = br.readLine();  //读取一个文本行
//        System.out.println("读的一个文本行："+ s); //aabcdebcd我爱林青霞林青霞z追加示例追加hello0

//        char[] chs2 = new char[1024];
//        int n2 = br.read(chs2); //将字符读入字符数组，父类方法
//        //3
//        System.out.println("读的字符数："+ n2);
//        System.out.println("读字符到字符数组："+ Arrays.toString(chs2));

        // 3.循环读取

        // 利用 一次读取一个字符
//        int nch1 = 0;
//        while ((nch1=br.read())!=-1){
//            System.out.println((char)nch1);
//        }

        // 利用 一次读取到一个字符数组
//        int nch2 = 0;
//        char[] chs = new char[1024];
//        while((nch2=br.read(chs))!=-1){
//            System.out.println(new String(chs, 0, nch2));
//        }

        //利用 一次读取一行
        String line = null;
        while((line=br.readLine())!=null){
            System.out.println(line);
        }

    }
}
```

## 5、LineNumberReader

	public class LineNumberReader extends BufferedReader

**跟踪行号的缓冲字符输入流**。

此类定义了方法 `setLineNumber(int)`和 `getLineNumber()`，可分别用于设置和获取当前行号。 

默认情况下，行编号从 0 开始。该行号随数据读取在每个行结束符处递增，并且可以通过调用 setLineNumber(int) 更改行号。

但要注意的是，setLineNumber(int) 不会实际更改流中的当前位置；它只更改将由 getLineNumber() 返回的值。 

可认为行在遇到以下符号之一时结束：换行符（'\n'）、回车符（'\r'）、回车后紧跟换行符。 

### 5.1、构造方法

具体描述见API

### 5.2、成员方法

具体描述见API

```java
public class LineNumberReaderDemo {
    public static void main(String[] args) throws IOException {
        LineNumberReader lnr = new LineNumberReader(new FileReader("bos.txt"));
        // 其父是BufferReader，所有可以使用其父的所有方法
        //这里只测试readLine()

        String line = null;
        while((line=lnr.readLine())!=null){
            int n = lnr.getLineNumber();
            if(n==10){
                lnr.setLineNumber(11);
            }
            System.out.println("这是第 "+lnr.getLineNumber()+" 行的数据：");
            System.out.println(line);
            //这是第 8 行的数据：
            //ahel
            //这是第 9 行的数据：
            //ahel
            //这是第 11 行的数据：
            //ahel
        }
    }
}

```

## 6、InputStreamReader、FileReader、BufferedReader、LineNumberReader区别与联系

继承关系:

	Reader --> InputStreamReader -->  FileReader
	       --> BufferedReader --> LineNumberReader

InputStreamReader：

	是*字节流通向字符流的桥梁*。

	它使用指定的 charset 读取字节并将其解码为字符。

	为了达到最高效率，可要考虑在 BufferedReader 内包装 InputStreamReader。

FileReader：

	读取字符文件的便捷类

BufferedReader：

	从字符输入流中读取文本，*缓冲*各个字符，从而实现字符、数组和行的*高效读取*

LineNumberReader：*跟踪行号*的*缓冲*字符输入流。可以设置获取行号。BufferedReader的子类

所以：

	BufferedReader的效率要比FileReader高。因为BufferedReader使用了缓存。

而，

	在创建BufferedReader对象时，是需要一个Reader对象的。所以，也离不开FileReader。

所以，可以使用这种方式`BufferedReader br = new BufferedReader(new FileReader("bw.txt"));`来写入字符流。