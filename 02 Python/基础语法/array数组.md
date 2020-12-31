# array数组

[TOC]

此模块定义了一种对象类型，可以**紧凑地表示基本类型值的数组：字符、整数、浮点数等**。

数组**属于序列类型，其行为与列表非常相似**，不同之处在于**其中存储的对象类型是受限的**。 

**类型在对象创建时使用单个字符的 类型码 来指定**。 已定义的类型码如下：

类型码  |   C 类型  |   Python 类型  |   以字节表示的最小尺寸  |   注释
---|:---|:---|:---|:---
'b'  |   signed char  |   int  |   1  |   
'B'  |   unsigned char  |   int  |   1  |   
'u'  |   Py_UNICODE  |   Unicode 字符  |   2  |   (1)
'h'  |   signed short  |   int  |   2  |   
'H'  |   unsigned short  |   int  |   2  |   
'i'  |   signed int  |   int  |   2  |   
'I'  |   unsigned int  |   int  |   2  |   
'l'  |   signed long  |   int  |   4  |   
'L'  |   unsigned long  |   int  |   4  |   
'q'  |   signed long long  |   int  |   8  |   
'Q'  |   unsigned long long  |   int  |   8  |   
'f'  |   float  |   float  |   4  |   
'd'  |   double  |   float  |   8  |   

注释:

'u' 类型码对应于 Python 中已过时的 unicode 字符 (Py_UNICODE 即 wchar_t)。 根据系统平台的不同，它可能是 16 位或 32 位。

'u' 将与其它的 Py_UNICODE API 一起被移除。

Deprecated since version 3.3, will be removed in version 4.0.

值的实际表示会由机器的架构决定（严格地说是由 C 实现决定）。 **实际大小可通过 itemsize 属性来获取**。

## 1、class array.array()

这个模块定义了以下类型：

	class array.array(typecode[, initializer])

**一个包含由 typecode 限制类型的条目的新数组，并由可选的 initializer 值进行初始化，该值必须为一个列表、[bytes-like object](https://docs.python.org/zh-cn/3.8/glossary.html#term-bytes-like-object) 或包含正确类型元素的可迭代对象**。

如果给定一个列表或字符串，该 initializer 会被传给新数组的 fromlist(), frombytes() 或 fromunicode() 方法（见下文），以将初始条目添加到数组中。 否则会将可迭代对象作为 initializer 传给 extend() 方法。

引发一个 [审计事件](https://docs.python.org/zh-cn/3.8/library/sys.html#auditing) `array.__new__` 附带参数 typecode, initializer。

array.typecodes：一个包含所有可用类型码的字符串。

数组对象**支持普通的序列操作，如索引、切片、拼接和重复等**。 

当使用切片赋值时，所赋的值必须为具有相同类型码的数组对象，所有其他情况都将引发 TypeError。

数组对象**也实现了缓冲区接口**，可以用于所有支持 bytes-like object 的场合。

## 2、array的方法

	array.typecode

用于创建数组的类型码字符。

	array.itemsize

在内部表示中，一个数组项的字节长度。

	array.append(x)

**添加一个值为 x 的新项到数组末尾**。

	array.buffer_info()

返回一个元组 (address, length) ，给出存放数组内容的缓冲区的当前内存地址和长度。

以字节表示的内存缓冲区大小可通过 `array.buffer_info()[1] * array.itemsize` 来计算。

这在使用需要内存地址的低层级（因此不够安全） I/O 接口时会很有用，例如某些 ioctl() 操作。只要数组存在，并且没有应用改变长度的操作，返回数值就是有效的。

注解：当在 C 或 C++ 编写的代码中使用数组对象时（这是有效使用此类信息的唯一方式），使用数组对象所支持的缓冲区接口更为适宜。 此方法仅保留用作向下兼容，应避免在新代码中使用。 缓冲区接口的文档参见 [缓冲协议](https://docs.python.org/zh-cn/3.8/c-api/buffer.html#bufferobjects)。

--------------------------------------------------------

```sh
>>> from array import array

>>> arr = array('b',[1,2,3,4,5])
>>> print(arr)
array('b', [1, 2, 3, 4, 5])

>>> print(arr.itemsize)
1

>>> arr.append(6)
>>> print(arr)
array('b', [1, 2, 3, 4, 5, 6])

>>> print(arr.buffer_info())
(2849015194032, 6)

>>> arr[0]
1
>>> arr[0:2]
array('b', [1, 2])
```

--------------------------------------------------------

	array.byteswap()

“字节对调”所有数组项。 此方法只支持大小为 1, 2, 4 或 8 字节的值，对于其他值类型将引发 RuntimeError。 它适用于从不同字节序机器所生成的文件中读取数据的情况。

	array.count(x)

**返回 x 在数组中的出现次数**。

	array.extend(iterable)

**将来自 iterable 的项添加到数组末尾**。 如果 iterable 是另一个数组，它必须具有 完全 相同的类型码，否则将引发 TypeError。 

如果 iterable 不是一个数组，则它必须为**可迭代对象，并且其元素必须为可添加到数组的适当类型**。

--------------------------------------------------------

```sh
>>> print(arr)
array('b', [1, 2, 3, 4, 5, 6])

>>> a = array('b',(1,2,3))

>>> arr.extend(a)
>>> print(arr)
array('b', [1, 2, 3, 4, 5, 6, 1, 2, 3])

>>> arr.extend((1,2,3))
>>> print(arr)
array('b', [1, 2, 3, 4, 5, 6, 1, 2, 3, 1, 2, 3])

>>> arr.extend(("a","b"))
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: an integer is required (got type str)

>>> print(arr.count(1))
3
```

--------------------------------------------------------

	array.index(x)

**返回最小的 i ，使得 i 为 x 在数组中首次出现的序号**。

	array.insert(i, x)

**将值 x 作为新项，插入数组的 i 位置之前**。 负值将被视为相对于数组末尾的位置。

	array.pop([i])

**从数组中移除序号为 i 的项并将其返回**。 可选参数值默认为 -1，因此默认将移除并返回末尾项。

	array.remove(x)

**从数组中移除首次出现的 x**。

	array.reverse()

**反转数组中各项的顺序**。

--------------------------------------------------------

```sh
>>> print(arr)
array('b', [1, 2, 3, 4, 5, 6])

>>> print(arr.index(1))
0
>>> print(arr.index(2))
1

>>> arr.insert(1,10)
>>> print(arr)
array('b', [1, 10, 2, 3, 4, 5, 6])

>>> arr.pop(1)
10
>>> print(arr)
array('b', [1, 2, 3, 4, 5, 6])

>>> arr.remove(1)
>>> print(arr)
array('b', [2, 3, 4, 5, 6])

>>> arr.reverse()
>>> print(arr)
array('b', [6, 5, 4, 3, 2])
```

--------------------------------------------------------

	array.frombytes(s)

**添加来自字符串的项**，将字符串解读为机器值的数组（相当于使用 fromfile() 方法从文件中读取数据）。

3.2 新版功能: fromstring() 重命名为 frombytes() 以使其含义更清晰。

	array.tobytes()

**将数组转换为一个机器值数组，并返回其字节表示**（即相当与通过 tofile 方法写入到文件的字节序列。）

3.2 新版功能: tostring() 被重命名为 tobytes() 以使其含义更清晰。

--------------------------------------------------------

```sh
>>> arr = array('u',"abcdef")
>>> print(arr)
array('u', 'abcdef')

>>> arrb = arr.tobytes()
>>> print(arrb)
b'a\x00b\x00c\x00d\x00e\x00f\x00'

>>> arrr = array('u',"g")
>>> arrr.frombytes(arrb)
>>> print(arrr)
array('u', 'gabcdef')
```

--------------------------------------------------------

	array.fromfile(f, n)

**从 file object f 中读取 n 项（解读为机器值）并将它们添加到数组末尾**。 

如果可读取数据少于 n 项则将引发 EOFError，但有效的项仍然会被插入数组。 f 必须为一个真实的内置文件对象，不支持带有 read() 方法的其它对象。

	array.fromlist(list)

**添加来自 list 的项**。 这等价于 `for x in list: a.append(x)`，区别在于如果发生类型错误，数组将不会被改变。

	array.tolist()

**将数组转换为包含相同项的普通列表**。

--------------------------------------------------------

```sh
>>> print(arr)
array('b', [1, 2, 3, 4, 5, 6])

>>> arr.fromlist([1,2,3])
>>> print(arr)
array('b', [1, 2, 3, 4, 5, 6, 1, 2, 3])

>>> arr.tolist()
['a', 'b', 'c', 'd', 'e', 'f']
```

--------------------------------------------------------

	array.fromstring()

frombytes() 的已弃用别名。

Deprecated since version 3.2, will be removed in version 3.9.

	array.tostring()

tobytes() 的已弃用别名。

Deprecated since version 3.2, will be removed in version 3.9.

	array.fromunicode(s)

**使用来自给定 Unicode 字符串的数组扩展数组**。 

数组必须是类型为 'u' 的数组，否则将引发 ValueError。 

请使用 `array.frombytes(unicodestring.encode(enc))` 来将 Unicode 数据添加到其他类型的数组。

	array.tounicode()

**将数组转换为一个 Unicode 字符串**。 

数组必须是类型为 'u' 的数组，否则将引发 ValueError。 

请使用 `array.tobytes().decode(enc)` 来从其他类型的数组生成 Unicode 字符串。

当一个数组对象被打印或转换为字符串时，它会表示为 `array(typecode, initializer)`。 如果数组为空则 initializer 会被省略，否则如果 typecode 为 'u' 则它是一个字符串，否则它是一个数字列表。 

使用 eval() 保证能将字符串转换回具有相同类型和值的数组，只要 array 类已通过 `from array import array` 被引入。 例如:

```python
array('l')
array('u', 'hello \u2641')
array('l', [1, 2, 3, 4, 5])
array('d', [1.0, 2.0, 3.14])
```

--------------------------------------------------------

```sh
>>> arrs = array('u',"abcd")
>>> print(arrs)
array('u', 'abcd')

>>> arrs.tounicode()
'abcd'

>>> arrs.fromunicode("ef")
>>> print(arrs)
array('u', 'abcdef')


```

--------------------------------------------------------


[英文官方文档](https://docs.python.org/3.8/library/array.html)

[中文官方文档](https://docs.python.org/zh-cn/3.8/library/array.html)