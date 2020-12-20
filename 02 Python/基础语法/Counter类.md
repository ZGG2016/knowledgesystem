# Counter类

collections 是 Python 内建的一个集合模块，提供了许多有用的集合类，如 Counter。

## 1、Counter

	class Counter(Dict[_T, int], Generic[_T]):

Counter 是 Dict 的子类。用于计数可哈希的对象。

它是一个集合，键是元素，值对应元素的计数，计数可以是任何整数值，包括0和负数。

```python
from collections import Counter

c1 = Counter()
print(c1)  # 输出：Counter()

# a new counter from an iterable
c2 = Counter('gallahad') 
print(c2)  # 输出：Counter({'a': 3, 'l': 2, 'g': 1, 'h': 1, 'd': 1})  # 默认排了序

# a new counter from a mapping
c3 = Counter({'red': 4, 'blue': 2}) 
print(c3)  # 输出：Counter({'red': 4, 'blue': 2})

# a new counter from keyword args
c4 = Counter(cats=4, dogs=8) 
print(c4)  # 输出：Counter({'dogs': 8, 'cats': 4})

c5 = Counter(cats=-2, dogs=8) 
c6 = Counter(cats=0, dogs=8)
print(c5)  # 输出：Counter({'dogs': 8, 'cats': -2})
print(c6)  # 输出：Counter({'dogs': 8, 'cats': 0})

```

### 1.1、特性

Counter 对象有一个字典接口，如果使用了 Counter 中没有包含的键，就返回一个0，而不是弹出一个KeyError :

```python
c3 = Counter({'red': 4, 'blue': 2}) 
print(c3)             # 输出：Counter({'red': 4, 'blue': 2})
print(c3['red'])      # 输出： 4
print(c3['black'])    # 输出： 0

```

设置一个键的值为0，不会从计数器中移除它，需要使用 del 来删除:

```python
c4 = Counter(cats=4, dogs=8) 
print(c4)  # 输出：Counter({'dogs': 8, 'cats': 4})

c4['cats'] = 0
print(c4)  # 输出：Counter({'dogs': 8, 'cats': 0})

del c4['cats']
print(c4)  # 输出：Counter({'dogs': 8})
```
3.1 新版功能.

在 3.7 版更改: 作为 dict 的子类，Counter 继承了记住插入顺序的功能。

Counter 对象进行数学运算时同样会保持顺序。结果会先按每个元素在运算符左边的出现时间排序，然后再按其在运算符右边的出现时间排序。

### 1.2、方法

计数器对象除了字典方法以外，还提供了三个其他的方法：

**elements()**

返回一个迭代器，按照传入参数的顺序，依次输出指定次数的元素

如果一个元素的计数值小于1，将会忽略它。

```python
c = Counter(a=4, b=2, c=0, d=-2)
for e in c.elements():
    print(e,end=',')  # 输出：a,a,a,a,b,b,

```
**most_common([n])**

返回一个列表，其中包含 n 个最常见的元素及出现次数，按常见程度由高到低排序。

如果 n 被省略或为 None，将返回计数器中的 所有 元素。 计数值相等的元素按首次出现的顺序排序：

```python
print(Counter('abracadabra').most_common(3))  # 输出：[('a', 5), ('b', 2), ('r', 2)]
```
**subtract([iterable-or-mapping])**	

从 迭代对象 或 映射对象 减去元素。像 dict.update() 但是是减去，而不是替换。输入和输出都可以是0或者负数。

```python
c = Counter(a=4, b=2, c=0, d=-2)
d = Counter(a=1, b=2, c=3, d=4)
c.subtract(d)
print(c)  # 输出：Counter({'a': 3, 'b': 0, 'c': -3, 'd': -6})
```

注意：

	3.2 新版功能.

	通常字典方法都可用于 Counter 对象，除了有两个方法工作方式与字典并不相同。

	fromkeys(iterable)
	这个类方法没有在 Counter 中实现。

	update([iterable-or-mapping])
	从 迭代对象 计数元素或者 从另一个 映射对象 (或计数器) 添加。 像 dict.update() 但是是加上，而不是替换。另外，迭代对象 应该是序列元素，而不是一个 (key, value) 对。

### 1.3、Counter 对象的常用案例

	sum(c.values())                 # total of all counts
	c.clear()                       # reset all counts
	list(c)                         # list unique elements
	set(c)                          # convert to a set
	dict(c)                         # convert to a regular dictionary
	c.items()                       # convert to a list of (elem, cnt) pairs
	Counter(dict(list_of_pairs))    # convert from a list of (elem, cnt) pairs
	c.most_common()[:-n-1:-1]       # n least common elements
	+c                              # remove zero and negative counts

```python
c = Counter('gallahad') 

print(sum(c.values()))   # 输出： 8        
print(list(c))  # 输出：['g', 'a', 'l', 'h', 'd']
print(set(c))   # 输出：{'h', 'l', 'd', 'a', 'g'}
print(dict(c))  # 输出：{'g': 1, 'a': 3, 'l': 2, 'h': 1, 'd': 1}
print(c.items())# 输出：dict_items([('g', 1), ('a', 3), ('l', 2), ('h', 1), ('d', 1)])
print(c.most_common()[:-4:-1])  # 输出：[('d', 1), ('h', 1), ('g', 1)]
print(c.most_common()[1:3:])  # 输出：[('l', 2), ('g', 1)]
c.clear()
print(c)  # 输出：Counter()
```

### 1.4、数学操作

提供了几个数学操作，可以结合 Counter 对象，以生产 multisets (计数器中大于0的元素）。 

加和减，结合计数器，通过加上或者减去元素的相应计数。交集和并集返回相应计数的最小或最大值。

每种操作都可以接受带符号的计数，但是输出会忽略掉结果为零或者小于零的计数。

	>>>
	c = Counter(a=3, b=1)
	d = Counter(a=1, b=2)
	c + d                       # add two counters together:  c[x] + d[x]
	Counter({'a': 4, 'b': 3})
	c - d                       # subtract (keeping only positive counts)
	Counter({'a': 2})
	c & d                       # intersection:  min(c[x], d[x]) 
	Counter({'a': 1, 'b': 1})
	c | d                       # union:  max(c[x], d[x])
	Counter({'a': 3, 'b': 2})


单目加和减（一元操作符）意思是从空计数器加或者减去。

	>>>
	c = Counter(a=2, b=-4)
	+c
	Counter({'a': 2})
	-c
	Counter({'b': 4})

3.3 新版功能: 添加了对一元加，一元减和位置集合操作的支持。

### 1.5、注解

计数器主要是为了表达运行的正的计数而设计；但是，小心不要预先排除负数或者其他类型。

为了帮助这些用例，这一节记录了最小范围和类型限制。

- Counter 类是一个字典的子类，不限制键和值。值用于表示计数，但你实际上 可以 存储任何其他值。

- most_common() 方法在值需要排序的时候用。

- 原地操作比如 c[key] += 1 ， 值类型只需要支持加和减。 所以分数，小数，和十进制都可以用，负值也可以支持。这两个方法 update() 和 subtract() 的输入和输出也一样支持负数和0。

- Multiset多集合方法只为正值的使用情况设计。输入可以是负数或者0，但只输出计数为正的值。没有类型限制，但值类型需要支持加，减和比较操作。

- elements() 方法要求正整数计数。忽略0和负数计数。

------------------------------------------------

[英文官方文档](https://docs.python.org/3.8/library/collections.html#collections.Counter)

[中文官方文档](https://docs.python.org/zh-cn/3.8/library/collections.html#collections.Counter)