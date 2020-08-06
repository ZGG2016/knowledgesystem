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

原文链接：[python面试题](https://www.jianshu.com/p/157d0af12603)
