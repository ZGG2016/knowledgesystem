# 初始化Java对象的详细过程

## 一、一个类及其对象初始化的过程

### 1、什么时候需要初始化一个类

	首次创建某个对象时 —> Dog dog = new Dog();

	首次访问某个类的静态方法或者静态字段时 —> Dog.staticFields;

java解释器就会去找类的路径，定位已经编译好的Dog.class文件。

### 2、获得类的资源

	然后jvm就会载入Dog.class，生成一个class对象。这个时候如果有静态的方法或者变量，静态初始化动作都会被执行。
	这个时候要注意啦，静态初始化在程序运行过程中只会在Class对象首次加载的时候运行一次。这些资源都会放在jvm的方法区。

方法区:

	又叫静态区，跟堆一样，被所有的线程共享。
	方法区中包含的都是在整个程序中永远唯一的元素，包含所有的class和static变量。

### 3、初始化对象—>Dog dog = new Dog()

	（1）第一次创建Dog对象先执行上面的一二步
	（2）在堆上为Dog对象分配足够的存储空间，所有属性和方法都被设置成缺省值(数字为0，字符为null，布尔为false，而所有引用被设置成null）
	（3）执行构造函数检查是否有父类，如果有父类会先调用父类的构造函数，这里假设Dog没有父类，执行缺省值字段的赋值即方法的初始化动作。
	（4）执行构造函数。

## 二、有父类情况下的初始化

假设Dog extends Animal

1、执行第一步，找出Dog.class文件，接着在加载过程中发现他有一个基类(通过extends关键字)，于是先执行Animal类的第一二步，加载其静态变量和方法。加载结束之后再加载子类Dog的静态变量和方法。

如果Animal类还有父类就以此类推，最终的基类叫做根基类。

	ps：因为子类的static初始化可能会依赖于父类的静态资源，所以要先加载父类的静态资源。

2、接着要new Dog对象，先为Dog对象分配存储空间->到Dog的构造函数->创建缺省的属性。

这里其构造函数里面的第一行有个隐的super()，即父类构造函数，所以这时会跳转到父类Animal的构造函数。

	java会帮我们完成构造函数的补充，Dog实际隐式的构造函数如下
	Dog() {
	//创建缺省的属性和方法
	//调用父类的构造函数super()（可显式写出）
	//对缺省属性和方法分别进行赋值和初始化
	}


3、父类Animal执行构造函数前也是分配存储空间- >到其构造函数->创建缺省的属性->发现我已经没有父类了，这个时候就给它的缺省的属性赋值和方法的初始化。

4、接着执行构造函数余下的部分，结束后跳转到子类Dog的构造函数。

5、子类Dog对缺省属性和方法分别进行赋值和初始化，接着完成构造函数接下来的部分。

**为什么要执行父类Animal的构造方法才继续子类Dog的属性及方法赋值？**

- 因为子类Dog的非静态变量和方法的初始化有可能使用到其父类Animal的属性或方法，所以子类构造缺省的属性和方法之后不应该进行赋值，而要跳转到父类的构造方法完成父类对象的构造之后，才来对自己的属性和方法进行初始化。

- 这也是为什么子类的构造函数显示调用父类构造函数super()时要强制写在第一行的原因，程序需要跳转到父类构造函数完成父类对象的构造后才能执行子类构造函数的余下部分。

**为什么对属性和方法初始化之后再执行构造函数其他的部分？**

- 因为构造函数中的显式部分有可能使用到对象的属性和方法。

      Tips：其实这种初始化过程都是为了保证后面资源初始化用到的东西前面的已经初始化完毕了。

说了这么多还是来个例子吧。

这里注意main函数也是一个静态资源，执行Dog类的main函数就是调用Dog的静态资源。
```
//父类Animal
class Animal {  
/*8、执行初始化*/  
	private int i = 9;  
	protected int j;  

/*7、调用构造方法，创建缺省属性和方法，完成后发现自己没有父类*/  
	public Animal() {  
/*9、执行构造方法剩下的内容，结束后回到子类构造函数中*/  
		System.out.println("i = " + i + ", j = " + j);  
		j = 39;  
	}  

/*2、初始化根基类的静态对象和静态方法*/  
	private static int x1 = print("static Animal.x1 initialized");  
	static int print(String s) {  
		System.out.println(s);  
		return 47;  
	}
}  

//子类Dog
public class Dog extends Animal {  
/*10、初始化缺省的属性和方法*/
	private int k = print("Dog.k initialized");  

/*6、开始创建对象，即分配存储空间->创建缺省的属性和方法。
	* 遇到隐式或者显式写出的super()跳转到父类Animal的构造函数。
	* super()要写在构造函数第一行 */  
	public Dog() {
/*11、初始化结束执行剩下的语句*/
		System.out.println("k = " + k);  
		System.out.println("j = " + j);  
	}

/*3、初始化子类的静态对象静态方法，当然mian函数也是静态方法*/  
	private static int x2 = print("static Dog.x2 initialized");

/*1、要执行静态main，首先要加载Dog.class文件，加载过程中发现有父类Animal，
	*所以也要加载Animal.class文件，直至找到根基类，这里就是Animal*/       
	public static void main(String[] args) {  

/*4、前面步骤完成后执行main方法，输出语句*/
		System.out.println("Dog constructor");
/*5、遇到new Dog()，调用Dog对象的构造函数*/  
		Dog dog = new Dog();   
/*12、运行main函数余下的部分程序*/            
		System.out.println("Main Left");
	}
}
```
自己猜一下结果，输出为：

	static Animal.x1 initialized
	static Dog.x2 initialized
	Dog constructor
	Animal: animal.i = 9, animal.j = 0
	Dog.k initialized
	Dog：Dog.k = 47
	Dog: Animal.j = 39
	Main Left

[原文链接](https://blog.csdn.net/qq_25665807/article/details/74452181)
