# range 对象

range 类型表示**不可变的数字序列**，通常**用于在 for 循环中循环指定的次数**。

	class range(stop)
	class range(start, stop[, step])

构造方法的**参数必须为整数**（可以是内置的 int 或任何实现了 `__index__` 特殊方法的对象）。

如果省略 step 参数，其默认值为 1。 **如果省略 start 参数，其默认值为 0**，如果 step 为零，则会引发 ValueError。

**如果 step 为正值，确定 range `r` 内容的公式为 `r[i] = start + step*i`** 其中 `i >= 0` 且 `r[i] < stop`。

**如果 step 为负值，确定 range 内容的公式仍然为 `r[i] = start + step*i`**，但限制条件改为 `i >= 0` 且 `r[i] > stop`。

如果 r[0] 不符合值的限制条件，则该 range 对象为空。

range 对象确实**支持负索引，但是会将其解读为从正索引所确定的序列的末尾开始索引**。

元素绝对值大于 `sys.maxsize` 的 range 对象是被允许的，但某些特性 (例如 len()) 可能引发 OverflowError。

一些 range 对象的例子:

```python
>>> list(range(10)) 
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
>>> list(range(1, 11))
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
>>> list(range(0, 30, 5))
[0, 5, 10, 15, 20, 25]
>>> list(range(0, 10, 3))
[0, 3, 6, 9]
>>> list(range(0, -10, -1))  # r[i] = start + step*i
[0, -1, -2, -3, -4, -5, -6, -7, -8, -9]
>>> list(range(0))
[]
>>> list(range(1, 0))
[]
```

range 对象**实现了 [一般](https://docs.python.org/zh-cn/3.8/library/stdtypes.html#typesseq-common) 序列的所有操作，但拼接和重复除外**（这是由于 range 对象只能表示符合严格模式的序列，而重复和拼接通常都会违反这样的模式）。

**start**

	start 形参的值 (如果该形参未提供则为 0)

**stop**

	stop 形参的值

**step**

	step 形参的值 (如果该形参未提供则为 1)

range 类型相比常规 list 或 tuple 的**优势在于一个 range 对象总是占用固定数量的（较小）内存，不论其所表示的范围有多大**（因为它只保存了 start, stop 和 step 值，并会根据需要计算具体单项或子范围的值）。

range 对象实现了 [collections.abc.Sequence](https://docs.python.org/zh-cn/3.8/library/collections.abc.html#collections.abc.Sequence) ABC，提供如包含检测、元素索引查找、切片等特性，并支持负索引 (参见 [序列类型 --- list, tuple, range](https://docs.python.org/zh-cn/3.8/library/stdtypes.html#typesseq)):

```python
>>>r = range(0, 20, 2)
>>>r
range(0, 20, 2)
>>>11 in r
False
>>>10 in r
True
>>>r.index(10)
5
>>>r[5]
10
>>>r[:5]
range(0, 10, 2)
>>>r[-1]
18
```

**使用 == 和 != 检测 range 对象是否相等是将其作为序列来比较**。 也就是说，如果两个 range 对象表示相同的值序列就认为它们是相等的。（请注意比较结果相等的两个 range 对象可能会具有不同的 start, stop 和 step 属性，例如 `range(0) == range(2, 1, 3)` 而 `range(0, 3, 2) == range(0, 4, 2)`。）

参见：[linspace recipe](http://code.activestate.com/recipes/579000/) 演示了如何实现一个延迟求值版本的适合浮点数应用的 range 对象。

------------------------------------------------

[英文官方文档](https://docs.python.org/3.8/library/stdtypes.html#range)

[中文官方文档](https://docs.python.org/zh-cn/3.8/library/stdtypes.html#range)