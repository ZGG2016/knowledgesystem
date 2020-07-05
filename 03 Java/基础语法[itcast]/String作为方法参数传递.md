# String、StringBuffer作为方法参数传递


????

```
/* 形式参数：
 * 		基本类型：形式参数的改变不影响实际参数
 * 		引用类型：形式参数的改变直接影响实际参数
 * 
 * 注意：
 * 		String作为参数传递，效果和基本类型作为参数传递是一样的。
 */
public class StringBufferDemo {
	public static void main(String[] args) {
		String s1 = "hello";
		String s2 = "world";
		System.out.println(s1 + "---" + s2);// hello---world
		change(s1, s2);
		System.out.println(s1 + "---" + s2);// hello---world

		StringBuffer sb1 = new StringBuffer("hello");
		StringBuffer sb2 = new StringBuffer("world");
		System.out.println(sb1 + "---" + sb2);// hello---world
		change(sb1, sb2);
		System.out.println(sb1 + "---" + sb2);// hello---worldworld

	}

	public static void change(StringBuffer sb1, StringBuffer sb2) {
		sb1 = sb2;
		sb2.append(sb1);
	}

	public static void change(String s1, String s2) {
		s1 = s2;
		s2 = s1 + s2;
	}
}

```

