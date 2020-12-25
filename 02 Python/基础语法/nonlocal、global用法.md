# nonlocal、global用法

[TOC]

## 1、nonlocal

	nonlocal_stmt ::=  "nonlocal" identifier ("," identifier)*

使得所列出的名称指向 之前在最近的包含作用域中 绑定的 除全局变量以外 的变量。 

这种功能很重要，因为绑定的默认行为是先搜索局部命名空间。这个语句**允许被封装的代码重新绑定局部作用域以外且非全局（模块）作用域当中的变量**。

语句中列出的名称必须指向 之前存在于包含作用域之中 的绑定。

语句中列出的名称不得与 之前存在于局部作用域中 的绑定 相冲突。

```python
def outerf():
    a = "python"
    
    def innerf():
        a = "java" 
        print("inner a = " +a)
        print(id(a))
    
    innerf()
    print("------------")

    print("outer a = " +a)
    print(id(a))
    
outerf()
# inner a = java
# 1988139156960
# ------------
# outer a = python
# 1988149086504

``` 

```python
def outerf():
    a = "python"
    
    def innerf():
        nonlocal a
        a = "java" 
        print("inner a = " +a)
        print(id(a))
    
    innerf()
    print("------------")

    print("outer a = " +a)
    print(id(a))
    
outerf()

# inner a = java
# 1988139156960
# ------------
# outer a = java
# 1988139156960

########################################
def outerf():
    a = 1
    
    def innerf():
        nonlocal a  # 没有这条语句，会报错
        a += 1 
        print(a)
        print(id(a))
    
    innerf()
    print("------------")

    print(a)
    print(id(a))
    
outerf()
# 2
# 140721512342192
# ------------
# 2
# 140721512342192
```

## 2、global

	global_stmt ::=  "global" identifier ("," identifier)*

作用于整个当前代码块的声明。 

它意味着**所列出的标识符将被解读为全局变量**。 

要给全局变量赋值不可能不用到 global 关键字，不过自由变量也可以指向全局变量，而不必声明为全局变量。

在 global 语句中列出的名称，不得在同一代码块内 该 global 语句之前 的位置中使用。

在 global 语句中列出的名称不得被定义为正式形参，不也得出现于 for 循环的控制目标、class 定义、函数定义、import 语句或变量标注之中。

CPython implementation detail: 

	当前的实现并未强制要求所有的上述限制，但程序不应当滥用这样的自由，因为未来的实现可能会改为强制要求，并静默地改变程序的含义。

程序员注意事项: 

	global 是对解析器的指令。 

	它仅对与 global 语句同时被解析的代码起作用。

	特别地，包含在提供给内置 exec() 函数字符串或代码对象中的 global 语句并不会影响 包含 该函数调用的代码块，而包含在这种字符串中的代码也不会受到包含该函数调用的代码中的 global 语句影响。 

	这同样适用于 eval() 和 compile() 函数。

```python
a = "python"
def f():
    a = "java"
    print("inner a = " +a)
    print(id(a))

f()
print("------------")
print("outer a = " +a)
print(id(a))

# inner a = java
# 1988139156960
# ------------
# outer a = python
# 1988149086504
```

```python
a = "python"
def f():
    global a
    a = "java"
    print("inner a = " +a)
    print(id(a))

f()
print("------------")
print("outer a = " +a)
print(id(a))

# inner a = java
# 1988139156960
# ------------
# outer a = java
# 1988139156960

################################
a = "python"
def f1():
    global a
    a = "java"
    print("f1 a = " +a)
    print(id(a))

def f2():
    print("f2 a = " +a)
    print(id(a))

f1()
f2()

# f1 a = java
# 1988139156960
# f2 a = java
# 1988139156960

#############################

a = 1
def f1():
    global a
    a += 1
    print(a)
    print(id(a))

def f2():
    print(a)
    print(id(a))

f1()
print("-----------")
f2()

# 2
# 140721512342192
# -----------
# 2
# 140721512342192

```

[英文官方文档](https://docs.python.org/3.8/reference/simple_stmts.html#the-nonlocal-statement)

[中文官方文档](https://docs.python.org/zh-cn/3.8/reference/simple_stmts.html#nonlocal)