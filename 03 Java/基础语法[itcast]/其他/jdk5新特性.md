# jdk5新特性

- 自动装箱和拆箱
- 泛型
- 增强for循环
- 静态导入
- 可变参数
- 枚举

## 一、枚举

指将变量的值一一列出来,变量的值只限于列举出来的值的范围内。

回想单例设计模式：单例类是一个类只有一个实例。那么多例类就是一个类有多个实例，
但不是无限个数的实例，而是有限个数的实例。这才能是枚举类。

### 1、Enum类

	public abstract class Enum<E extends Enum<E>>
	extends Object
	implements Comparable<E>, Serializable

这是所有 Java 语言枚举类型的公共基本类。 

```java
public enum Direction {
	FRONT, BEHIND, LEFT, RIGHT;
}


```

```java
public enum Direction2 {
	FRONT("前"), BEHIND("后"), LEFT("左"), RIGHT("右");

	private String name;

	private Direction2(String name) {
		this.name = name;
	}

	public String getName() {
		return name;
	}

	// @Override
	// public String toString() {
	// return "我爱林青霞";
	// }
}

```

```java
public enum Direction3 {
	FRONT("前") {
		@Override
		public void show() {
			System.out.println("前");
		}
	},
	BEHIND("后") {
		@Override
		public void show() {
			System.out.println("后");
		}
	},
	LEFT("左") {
		@Override
		public void show() {
			System.out.println("左");
		}
	},
	RIGHT("右") {
		@Override
		public void show() {
			System.out.println("右");
		}
	};

	private String name;

	private Direction3(String name) {
		this.name = name;
	}

	public String getName() {
		return name;
	}

	public abstract void show();
}
```

```java
package cn.itcast_02;

public class DirectionDemo {
	public static void main(String[] args) {
		Direction d = Direction.FRONT;
		System.out.println(d); // FRONT
		// public String toString()返回枚举常量的名称，它包含在声明中。
		System.out.println("-------------");
		Direction2 d2 = Direction2.FRONT;
		System.out.println(d2);
		System.out.println(d2.getName());
		System.out.println("-------------");
		Direction3 d3 = Direction3.FRONT;
		System.out.println(d3);
		System.out.println(d3.getName());
		d3.show();
		System.out.println("--------------");

		Direction3 dd = Direction3.FRONT;
		dd = Direction3.LEFT;

		switch (dd) {
		case FRONT:
			System.out.println("你选择了前");
			break;
		case BEHIND:
			System.out.println("你选择了后");
			break;
		case LEFT:
			System.out.println("你选择了左");
			break;
		case RIGHT:
			System.out.println("你选择了右");
			break;
		}
	}
}
```

#### 1、注意事项

- 定义枚举类要用关键字enum
- 所有枚举类都是Enum的子类
- 枚举类的第一行上必须是枚举项，最后一个枚举项后的分号是可以省略的，
	但是如果枚举类有其他的东西，这个分号就不能省略。建议不要省略
- 枚举类可以有构造器，但必须是private的，它默认的也是private的。
	枚举项的用法比较特殊：枚举(“”);
- 枚举类也可以有抽象方法，但是枚举项必须重写该方法
- 枚举在switch语句中的使用

#### 2、成员方法

	public final int compareTo(E o)
		比较此枚举与指定对象的顺序。在该对象小于、等于或大于指定对象时，
		分别返回负整数、零或正整数。

	public final String name()
		返回此枚举常量的名称，在其枚举声明中对其进行声明。 

	public final int ordinal()
		返回枚举常量的序数
		（它在枚举声明中的位置，其中初始常量序数为零）。 

	public String toString()
		返回枚举常量的名称，它包含在声明中。可以重写此方法。

	public final boolean equals(Object other)
		当指定对象等于此枚举常量时，返回 true。 

	public static <T extends Enum<T>> T valueOf(Class<T> enumType,String name)
		返回带指定名称的指定枚举类型的枚举常量。
		
```java
package cn.itcast_02;

public class EnumMethodDemo {
	public static void main(String[] args) {
		// int compareTo(E o)
		Direction2 d21 = Direction2.FRONT;
		Direction2 d22 = Direction2.BEHIND;
		Direction2 d23 = Direction2.LEFT;
		Direction2 d24 = Direction2.RIGHT;
		System.out.println(d21.compareTo(d21));
		System.out.println(d21.compareTo(d24));
		System.out.println(d24.compareTo(d21));
		System.out.println("---------------");
		// String name()
		System.out.println(d21.name());
		System.out.println(d22.name());
		System.out.println(d23.name());
		System.out.println(d24.name());
		System.out.println("--------------");
		// int ordinal()
		System.out.println(d21.ordinal());
		System.out.println(d22.ordinal());
		System.out.println(d23.ordinal());
		System.out.println(d24.ordinal());
		System.out.println("--------------");
		// String toString()
		System.out.println(d21.toString());
		System.out.println(d22.toString());
		System.out.println(d23.toString());
		System.out.println(d24.toString());
		System.out.println("--------------");
		// <T> T valueOf(Class<T> type,String name)
		Direction2 d = Enum.valueOf(Direction2.class, "FRONT");
		System.out.println(d.getName());
		System.out.println("----------------");
		// values()
		// 此方法虽然在JDK文档中查找不到，但每个枚举类都具有该方法，它遍历枚举类的所有枚举值非常方便
		Direction2[] dirs = Direction2.values();
		for (Direction2 d2 : dirs) {
			System.out.println(d2);
			System.out.println(d2.getName());
		}
	}
}

```