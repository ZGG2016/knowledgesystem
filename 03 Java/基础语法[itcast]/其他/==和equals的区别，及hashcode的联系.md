# ==和equals的区别，及hashcode的联系

## 1、==和equals的区别：

- ==：关系操作符

如果作用于**基本数据类型**的变量，则比较其存储的**值**是否相等

如果作用于**引用类型**的变量，则比较的是所指向的**对象的地址**

- equals方法：基类Object中的实例方法

注意：equals方法**不能作用于基本数据类型的变量**

如果没有对equals方法进行重写的类，则比较的是引用类型的变量所指向的**对象的地址**；

对equals方法进行了重写的类，要具体分析，如：

	String： 先比较引用是否相同,  if (this == anObject)
		     再判断类型是否一致,  if (anObject instanceof String) 
             最后比较内容是否一致

    Integer： 
    		判断类型，再比较内容
        	public boolean equals(Object obj) {
            	if (obj instanceof Integer) {
                	return value == ((Integer)obj).intValue();
            	}
            	return false;
        	}


```java
public class test {
    public static void main(String[] args) {

        /* 未重写equals，调用的是Object类中的equals方法
         * public boolean equals(Object obj) {
         *		return (this == obj);
         * }
         */    
        
        StringBuilder sb1 = new StringBuilder("aaa");
        StringBuilder sb2 = new StringBuilder("aaa");

        System.out.println(sb1==sb2);  //false
        System.out.println(sb1.equals(sb2)); //false

        /* String重写了equals
         *
         * 先 比较引用是否相同,  if (this == anObject)
		 * 再 判断类型是否一致,  if (anObject instanceof String) 
         * 最后 比较内容是否一致
         *
         **/
        String s1 = new String("aaa");
        String s2 = new String("aaa");

        System.out.println(s1==s2); //false
        System.out.println(s1.equals(s2)); //true

        int a1 = 1;
        int a2 = 1;
        System.out.println(a1==a2); //true
//        System.out.println(a1.equals(a2));

    }
}
```

## 2、int和Integer的比较

```java
public class test {
    public static void main(String[] args) {

        /*
        * 由于Integer变量实际上是对一个Integer对象的引用，
        * 所以两个通过new生成的Integer变量永远是不相等的（因为new生成的是两个对象，其内存地址不同）。
        * */
        Integer a = new Integer(80);
        Integer b = new Integer(80);
        System.out.println(a==b); //false
        System.out.println(a.equals(b));  //true
        System.out.println("---------------------------------");

        /*
        * 对于两个非new生成的Integer对象，进行比较时，
        * 如果两个变量的值在区间-128到127之间，则比较结果为true，
        * 如果两个变量的值不在此区间，则比较结果为false。
        *
        *
        * Integer c = 100; 相当于 Integer c = Integer.valueOf(100)； 【自动装箱】
        *     public static Integer valueOf(int i) {
        *          //low = -128; high = 127; Integer cache[] = new Integer[(high - low) + 1];
        *           if (i >= IntegerCache.low && i <= IntegerCache.high)
        *              //在这个范围内，就直接从数组cache里取出来
        *              //This method will always cache values in the range -128 to 127
        *               return IntegerCache.cache[i + (-IntegerCache.low)];
        *           // 不在这个范围，就new一个Integer对象
        *           return new Integer(i);
        *      }
        * */
        Integer c = 100;
        Integer d = 100;
        System.out.println(c==d); //true
        System.out.println(c.equals(d));  //true

        c = 200;
        d = 200;
        System.out.println(c==d); //false
        System.out.println(c.equals(d));  //true
        System.out.println("---------------------------------");

        /*
        * Integer变量和int变量比较时，只要两个变量的值是相等的，则结果为true
        * 因为包装类Integer和基本数据类型int比较时，java会自动拆包装为int，
        * 然后进行比较，实际上就变为两个int变量的比较
        * */
        Integer e = 90;
        int ei = 90;
        System.out.println(e==ei); //true
        System.out.println(e.equals(ei));  //true
        System.out.println("---------------------------------");

        /*
        * 非new生成的Integer变量和new Integer()生成的变量比较时，结果为false。
        * 因为非new生成的Integer变量(没超范围情况下)指向的是java常量池中的对象，
        * 而new Integer()生成的变量指向堆中新建的对象，两者在内存中的地址不同
        * */
        Integer f1 = 70;
        Integer f2 = new Integer(70);
        System.out.println(f1==f2); //false
        System.out.println(f1.equals(f2));  //true
    }

}

```

## 3、==、equals和hashcode的联系

hashcode 是基类 Object 中的实例 native 方法，因此对所有继承于Object的类都会有该方法。 【native方法暗示这些方法是有实现体的，但并不提供实现体，因为其实现体是由非java语言在外面实现的】

- 如果 x.equals(y) 返回 “true”，那么 x 和 y 的 hashCode() 必须相等 ；
- 如果 x.equals(y) 返回 “false”，那么 x 和 y 的 hashCode() 有可能相等，也有可能不等 ；
- 如果 x 和 y 的 hashCode() 不相等，那么 x.equals(y) 一定返回 “false” ；
- 一般来讲，equals 这个方法是给用户调用的，而 hashcode 方法一般用户不会去调用 ；

[==、equals和hashcode的联系](https://blog.csdn.net/justloveyou_/article/details/52464440)