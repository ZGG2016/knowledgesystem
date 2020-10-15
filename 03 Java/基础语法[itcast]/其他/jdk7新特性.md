# jdk7新特性

## 一、二进制字面量

JDK7开始，终于可以用二进制来表示整数（byte,short,int和long）。

好处是，可以使代码更容易被理解。语法非常简单，只要在二进制数值前面加 0b或者0B

举例：
	
	int x = ob110110


## 二、数字字面量可以出现下划线

为了增强对数值的阅读性，如我们经常把数据用逗号分隔一样。JDK7提供了_对数据分隔。

举例：

	int x = 100_1000;

注意事项：
 
	不能出现在进制标识和数值之间  int b = 0b_100_100;
	不能出现在数值开头和结尾  int c = 0b100_100_;
	不能出现在小数点旁边  float e = 12._34_56f;
 

## 三、switch 语句可以用字符串


## 四、泛型简化

ArrayList<String> array = new ArrayList<>();

## 五、异常的多个catch合并

## 六、try-with-resources 语句

格式：

	try(必须是java.lang.AutoCloseable的子类对象){…}

好处：

	资源自动释放，不需要close()了
	把需要关闭资源的部分都定义在这里就ok了
	主要是流体系的对象是这个接口的子类(看JDK7的API)


```java
try (FileReader fr = new FileReader("a.txt");
	FileWriter fw = new FileWriter("b.txt");) {
		int ch = 0;
		while ((ch = fr.read()) != -1) {
			fw.write(ch);
		}
	} catch (IOException e) {
		e.printStackTrace();
	}
```
