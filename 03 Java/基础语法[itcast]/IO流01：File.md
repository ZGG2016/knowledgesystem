# IO流01：File

[TOC]

## 1、File类

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

### 1.1、成员方法:创建功能

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

### 1.2、成员方法:删除功能

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

### 1.3、成员方法:重命名功能

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

### 1.4、成员方法:判断功能

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

### 1.5、成员方法:获取功能

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

### 1.6、成员方法:文件名称过滤器

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


