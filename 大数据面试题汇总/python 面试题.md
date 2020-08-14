# python面试题 

**1、利用切片操作，实现一个trim()函数，去除字符串首尾的空格，注意不要调用str的strip()方法.**

正解1：

```python
def trim(s):
    while s[:1] == ' ':   # 循环因为有多个空格
        s = s[1:]
    while s[-1:] == ' ':
        s = s[:-1]
    return s
```

正解2：

```python
def trim(s):
    if s[:1] == ' ':
        s = trim(s[1:])
    if s[-1:] == ' ':
        s = trim(s[:-1])
    return s
```
容易写错的方法：

```python
 def trim(s):
    while s[0] == ' ':
        s = s[1:]
    while s[-1] == ' ':
        s = s[:-1]
    return s
```

当s=''时，s[0]和s[-1]会报IndexError: string index out of range，但是s[:1]）和s[-1:]不会。


**2、请设计一个decorator，它可作用于任何函数上，并打印该函数的执行时间**

```python
import time, functools

def decorator(func):
    @functools.wraps(func)
    def wrapper(*args,**kw):
        start_time = time.time()
        ret = func(*args,**kw)
        end_time = time.time()
        print("%s executed  in %s ms" % (func.__name__,end_time-start_time))
        return ret
    return wrapper
```

**3、装饰器的实质是什么？或者说为什么装饰器要写2层嵌套函数，里层函数完全就已经实现了装饰的功能为什么不直接用里层函数名作为装饰器名称？**

    装饰器是要把原来的函数装饰成新的函数，并且返回这个函数本身的高阶函数

**4、删除一个list里面的重复元素**

```python
lst = [1,1,2,3,4,5,4]

print(list(set(lst)))

nlst = []
for item in lst:
    if item not in nlst:
        nlst.append(item)
print(nlst)

```

**7、利用map()函数，把用户输入的不规范的英文名字，变为首字母大写，其他小写的规范名字。输入：['adam', 'LISA', 'barT']，输出：['Adam', 'Lisa', 'Bart']**

    map() 函数语法：
        map(function, iterable, ...)
    
    参数
        function -- 函数
        iterable -- 一个或多个序列
    
    返回值
        Python 2.x 返回列表。
        Python 3.x 返回迭代器。


```python
def trans(x):
    return x[0].upper() + x[1:].lower()  # 字符串连接

lst = ['adam', 'LISA', 'barT']
rlt = map(trans,lst)
for i in rlt:
    print(i)
print(type(rlt))
"""
Adam
Lisa
Bart
<class 'map'>
"""
```
**5、解释一下python的and-or语法**

bool and a or b：bool是true，执行a，否则执行b

```python
a = 'a'
b = 'b'

print(True and a or b)
print(False and a or b)

"""
a
b

"""
```
但当b是假时，无论bool是true，还是false，都会执行b，可以这么解决：

```python
c = ''

print(True and c or b)
print(False and c or b)

print((True and [c] or [b])[0])
print((False and [c] or [b])[0])

"""
b
b

b
"""
```

因为 [b] 是一个非空列表，它永远不会为假。甚至 b 是 0 或 '' 或其它假值，列表[b]为真，因为它有一个元素。

**6、如何逆序迭代一个序列**

对字符串、列表、元组通用的
```python
def f1(s):
    for item in reversed(s):
        print(item,end=',')
    print()
    
def f2(s):
    for item in range(len(s)-1,-1,-1):
        print(s[item],end=',')
    print()
def f3(s):
    for item in s[::-1]:
        print(item,end=',')
    print()
```
```python
# range(stop)  
# range(start, stop[, step]) 顾头不顾尾
```

**7、Python里面如何拷贝一个对象**

copy模块下有两类拷贝：

    copy.copy(x)  返回 x 的浅拷贝。        
    copy.deepcopy(x[, memo])  返回 x 的深拷贝。

两者不同之处和复合对象(包含其他对象的对象，如列表、类实例)相关：

- 浅拷贝：构造一个新的复合对象，为原始对象中的对象创建一个引用。

- 深拷贝：构造一个新的复合对象，然后，递归地，为原始对象中的对象创建一个副本。

```python
import copy
list_copy = [1,2,3,[4,5]]

c = copy.copy(list_copy)
dc = copy.deepcopy(list_copy)

# 分开执行

list_copy[3][0] = 6
print(list_copy)  # [1, 2, 3, [6, 5]]
print(c)   # [1, 2, 3, [6, 5]]
print(dc)  
```

想要给一个类定义它自己的拷贝操作实现，可以通过定义特殊方法 __copy__() 和 __deepcopy__()。 

**8、Python里面search()和match()的区别**

re.match 

    尝试从字符串的起始位置匹配一个模式，如果不是起始位置匹配成功的话，match()就返回none。

re.search 

    扫描整个字符串并返回第一个成功的匹配。

**9、描述元类的概念。Python有没有接口？元类和Java的接口有什么异同？**

[元类](https://www.liaoxuefeng.com/wiki/1016959663602400/1017592449371072)允许你创建类或者修改类。换句话说，你可以把类看成是元类创建出来的“实例”。

Python没有接口。

Java接口中的的方法必须是抽象方法，要在其实现类中实现。而元类可以。

**python下多线程的限制以及多进程中传递参数的方式**

**python多线程与多进程的区别**

**Python是如何进行内存管理的**

**Python如何实现单例模式？其他23种设计模式python如何实现**

原文链接 ↑：[python面试题](https://www.jianshu.com/p/157d0af12603)
