# for 语句

**用于对序列（例如字符串、元组或列表）或其他可迭代对象中的元素进行迭代**:

	for_stmt ::=  "for" target_list "in" expression_list ":" suite
	              ["else" ":" suite]          

**expression_list 会被求值一次，产生一个可迭代对象**。 

系统将为 expression_list 的结果创建一个迭代器，然后将为迭代器所提供的每一项执行一次子句体，具体次序与迭代器的返回顺序一致。 

每一项会按标准赋值规则 (参见 [赋值语句](https://docs.python.org/zh-cn/3.8/reference/simple_stmts.html#assignment)) 被依次赋值给目标列表，然后子句体将被执行。 

**当所有项被耗尽时 (这会在序列为空或迭代器引发 StopIteration 异常时立刻发生)，else 子句的子句体如果存在将会被执行，并终止循环**。

第一个子句体中的 [break](https://docs.python.org/zh-cn/3.8/reference/simple_stmts.html#break) 语句在执行时，将终止循环，且不执行 else 子句体。 

第一个子句体中的 [continue](https://docs.python.org/zh-cn/3.8/reference/simple_stmts.html#continue)语句在执行时，将跳过子句体中的剩余部分，并转往下一项继续执行，或者在没有下一项时转往 else 子句执行。

**for 循环会对目标列表中的变量进行赋值。 这将覆盖之前对这些变量的所有赋值，包括在 for 循环体中的赋值**:

```python
for i in range(10): # 1、2、3...依次赋值给 i
    print(i)
    i = 5             # this will not affect the for-loop
                      # because i will be overwritten with the next
                      # index in the range
```

目标列表中的名称在循环结束时不会被删除，但如果序列为空，则它们根本不会被循环所赋值。

提示：内置函数 [range()](https://docs.python.org/zh-cn/3.8/library/stdtypes.html#range) 会返回一个可迭代的整数序列，适用于模拟 Pascal 中的 `for i := a to b do` 这种效果；例如 list(range(3)) 会返回列表 [0, 1, 2]。

注解：

当序列在循环中被修改时会有一个微妙的问题（这**只可能发生于可变序列中，例如列表**）。

【序列在循环中】会有一个内部计数器被用来跟踪下一个要使用的项，每次迭代都会使计数器递增。当计数器值达到序列长度时循环就会终止。

这意味着**如果语句体从序列中删除了当前（或之前）的一项，下一项就会被跳过（因为其标号将变成已被处理的当前项的标号）**。 

类似地，如果语句体在序列当前项的前面插入一个新项，当前项会在循环的下一轮中再次被处理。这会导致麻烦的程序错误，**避免此问题的办法是对整个序列使用切片来创建一个临时副本**，例如

```python
for x in a[:]:
    if x < 0: a.remove(x)
```

------------------------------------------------------

```python
# 当所有项被耗尽时，else 子句的子句体如果存在将会被执行，并终止循环。
>>> for i in [1,2,3]:
...     print(i)
... else:
...     print("this is else clause")
...
1
2
3
this is else clause

# for 循环会对目标列表中的变量进行赋值。 
# 这将覆盖之前对这些变量的所有赋值，包括在 for 循环体中的赋值
>>> for i in [1,2,3]:
...     print(i)
...     i = 5
...
1
2
3  

# 如果语句体从序列中删除了当前（或之前）的一项，下一项就会被跳过（因为其标号将变成已被处理的当前项的标号）
>>> lst = [2,-1,4,-2,5]
>>> for i in lst:
...     if i<0:
...             lst.remove(i)
...     print(i)
...
2
-1
-2

>>> for i in lst[:]:
...     if i<0:
...             lst.remove(i)
...     print(i)
...
2
4
5
```

------------------------------------------------

[英文官方文档](https://docs.python.org/3.8/reference/compound_stmts.html#the-for-statement)

[中文官方文档](https://docs.python.org/zh-cn/3.8/reference/compound_stmts.html#for)