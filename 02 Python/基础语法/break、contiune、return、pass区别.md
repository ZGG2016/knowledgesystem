# break、contiune、return、pass区别

## 1、break 语句

	break_stmt ::=  "break"

在语法上只会出现于 for 或 while 循环所嵌套的代码，但不会出现于该循环内部的函数或类定义所嵌套的代码。

它会**终结最近的外层循环**，如果循环有可选的 else 子句，也会跳过该子句。

如果一个 for 循环被 break 所终结，该循环的控制目标会保持其当前值。

当 break 将控制流传出一个带有 finally 子句的 try 语句时，**该 finally 子句会先被执行然后再真正离开该循环**。

循环语句可能带有 else 子句；它会在循环耗尽了可迭代对象 (使用 for) 或循环条件变为假值 (使用 while) 时被执行，但不会在循环被 break 语句终止时被执行。 以下搜索素数的循环就是这样的一个例子:

```sh
>>> for n in range(2, 10):
...     for x in range(2, n):
...         if n % x == 0:
...             print(n, 'equals', x, '*', n//x)
...             break
...     else:
...         # loop fell through without finding a factor
...         print(n, 'is a prime number')
...
2 is a prime number
3 is a prime number
4 equals 2 * 2
5 is a prime number
6 equals 2 * 3
7 is a prime number
8 equals 2 * 4
9 equals 3 * 3
```

（是的，这是正确的代码。仔细看： else 子句属于 for 循环， 不属于 if 语句。）

当和循环一起使用时，else 子句与 try 语句中的 else 子句的共同点多于 if 语句中的同类子句: try 语句中的 else 子句会在未发生异常时执行，而循环中的 else 子句则会在未发生 break 时执行。 有关 try 语句和异常的更多信息，请参阅 [处理异常](https://docs.python.org/zh-cn/3.8/tutorial/errors.html#tut-handling)。

## 2、continue 语句

	continue_stmt ::=  "continue"

在语法上只会出现于 for 或 while 循环所嵌套的代码中，但不会出现于该循环内部的函数或类定义中。 

它会**继续执行最近的外层循环的下一个轮次**。

当 continue 将控制流传出一个带有 finally 子句的 try 语句时，**该 finally 子句会先被执行然后再真正开始循环的下一个轮次**。

```sh
>>> for num in range(2, 10):
...     if num % 2 == 0:
...         print("Found an even number", num)
...         continue
...     print("Found an odd number", num)
Found an even number 2
Found an odd number 3
Found an even number 4
Found an odd number 5
Found an even number 6
Found an odd number 7
Found an even number 8
Found an odd number 9
```

##  3、return 语句

	return_stmt ::=  "return" [expression_list]

在语法上只会出现于函数定义所嵌套的代码，不会出现于类定义所嵌套的代码。

如果提供了表达式列表，它将被求值，否则以 None 替代。

return 会**离开当前函数调用，并以表达式列表 (或 None) 作为返回值**。

当 return 将控制流传出一个带有 finally 子句的 try 语句时，**该 finally 子句会先被执行然后再真正离开该函数**。

**在一个生成器函数中，return 语句表示生成器已完成并将导致 StopIteration 被引发**。返回值（如果有的话）会被当作一个参数用来构建 StopIteration 并成为 StopIteration.value 属性。

在一个异步生成器函数中，一个空的 return 语句表示异步生成器已完成并将导致 StopAsyncIteration 被引发。 一个非空的 return 语句在异步生成器函数中会导致语法错误。

## 4、pass 语句

	pass_stmt ::=  "pass"

一个空操作，当它被执行时，什么都不发生。

```sh
>>> while True:
...     pass  # Busy-wait for keyboard interrupt (Ctrl+C)
...
```

通常用于创建最小的类:

```sh
>>> class MyEmptyClass:
...     pass
... 
```

另一个可以使用的场合是在你编写新的代码时作为一个函数或条件子句体的占位符，允许你保持在更抽象的层次上进行思考。 pass 会被静默地忽略:

```sh
>>> def initlog(*args):
...     pass   # Remember to implement this!
...
```

例如:

```python
def f(arg): pass    # a function that does nothing (yet)

class C: pass       # a class with no methods (yet)
```

[中文官方文档](https://docs.python.org/zh-cn/3.8/tutorial/controlflow.html#break-and-continue-statements-and-else-clauses-on-loops)