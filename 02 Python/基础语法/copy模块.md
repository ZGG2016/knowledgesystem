# copy模块

[TOC]

## 1、copy — Shallow and deep copy operations

Python 里的赋值语句并不会赋值对象，它们会创建一个目标和对象的绑定关系。

```python
a = 3   # 为3创建了一个引用
b = a   # 并不是把 a 赋值给 b，而是为 3 创建了另一个引用

print(id(a)) # 140721682473680
print(id(b)) # 140721682473680
```

对于**可变的集合，或包含了可变元素的集合**，就需要副本，这样改变操作作用于其副本，进而避免改变原对象。

	可变对象：字典(dict), 集合(set), 列表(list)
	不可变对象包含：整型(int), 字符串(string), 浮点型(float), 元组(tuple)


这个模块有浅拷贝和深拷贝。

	copy.copy(x)  返回 x 的浅拷贝。		

	copy.deepcopy(x[, memo])  返回 x 的深拷贝。

	exception copy.error
		Raised for module specific errors.

**两者不同之处仅和复合对象(包含其他对象的对象，如列表、类实例)相关：**

- 浅拷贝：构造一个新的复合对象，为原始对象中的对象创建一个引用。

- 深拷贝：构造一个新的复合对象，然后，递归地，为原始对象中的对象创建一个副本。

```python
import copy

# 对不可变对象效果一样

a = 5

ca = copy.copy(a)
dca = copy.deepcopy(a)

print(id(a))  # 140721698988816
print(id(ca)) # 140721698988816
print(id(dca)) # 140721698988816

a = 6

ca = copy.copy(a)
dca = copy.deepcopy(a)

print(id(a)) # 140721698988848 
print(id(ca)) # 140721698988848 
print(id(dca)) # 140721698988848 
```

```python
import copy

# 修改可变对象中的不可变元素，效果一样

list_copy = [1,2,3,[4,5]]

c = copy.copy(list_copy)
dc = copy.deepcopy(list_copy)

# 分开执行copy

list_copy[3][0] = 6
print(list_copy)  # [1, 2, 3, [6, 5]]
print(c)   # [1, 2, 3, [6, 5]]
print(dc)  # [1, 2, 3, [4, 5]]

c[3][0] = 6
print(list_copy)  # [1, 2, 3, [6, 5]]
print(c)   # [1, 2, 3, [6, 5]]
print(dc)  # [1, 2, 3, [4, 5]]

dc[3][0] = 6
print(list_copy) # [1, 2, 3, [4, 5]]
print(c)   # [1, 2, 3, [4, 5]]
print(dc)  # [1, 2, 3, [6, 5]]
```

```python
import copy

# 修改可变对象中的可变元素，效果不一样

list_copy = [1,2,3,[4,5]]

c = copy.copy(list_copy)
dc = copy.deepcopy(list_copy)

# 分开执行copy

# list_copy[0] = 6
# print(list_copy)   # [6, 2, 3, [4, 5]]
# print(c)   # [1, 2, 3, [4, 5]]
# print(dc)  # [1, 2, 3, [4, 5]]

# c[0] = 6
# print(list_copy)  # [1, 2, 3, [4, 5]]
# print(c)    # [6, 2, 3, [4, 5]]
# print(dc)   # [1, 2, 3, [4, 5]]
# 

dc[0] = 6   
print(list_copy)    # [1, 2, 3, [4, 5]]
print(c)   # [1, 2, 3, [4, 5]]
print(dc)  # [6, 2, 3, [4, 5]]
```

**深拷贝有两个问题，但问题而不存在于浅拷贝：**

- 递归对象(直接或间接包含对自身引用的复合对象)可能导致递归循环。

- 因为深拷贝复制了它能复制的所有内容，因此可能会过多复制(如本应该在副本之间共享的数据)。

深拷贝为避免上述问题，通过：

- 在复制过程中，保留复制对象的 memo 字典 （？？）

- 让用户定义的类重写复制操作，或复制的组件集。

本模块不复制模块、方法、栈追踪(stack trace)、栈帧(stack frame)、文件、套接字、窗口、数组以及任何类似的类型。它通过不改变地返回原始对象来(浅层或深层地)"复制"函数和类；这与 [pickle](https://docs.python.org/zh-cn/3.8/library/pickle.html#module-pickle) 模块处理这类问题的方式是相似的。

**字典的浅拷贝使用 [dict.copy()](https://docs.python.org/zh-cn/3.8/library/stdtypes.html#dict.copy)。**

**列表的浅拷贝使用切片:`copied_list = original_list[:]`**

```python
# 字典
d = {'a':1,'b':2}

cd = d.copy()

print(id(d))  # 3119656249384
print(id(cd)) # 3119656043936

print(cd)     # {'a': 1, 'b': 2}

# 修改值
d['b'] = 3

# 未影响cd
print(d)     # {'a': 1, 'b': 3}
print(cd)    # {'a': 1, 'b': 2}


# 复合对象
d2 = {'a':1,'b':[2,3]}

cd2 = d2.copy()

print(id(d2))  # 3119656248016
print(id(cd2)) # 3119673130368

print(cd2)    # {'a': 1, 'b': [2, 3]}

# 修改值
d2['b'][0] = 4

# 影响cd2
print(d2)    # {'a': 1, 'b': [4, 3]}
print(cd2)   # {'a': 1, 'b': [4, 3]}


cd = d.deepcopy()
print(cd)  # AttributeError: 'dict' object has no attribute 'deepcopy'

# -------------------------------

# 使用 = 复制

cd3 = d
print(cd3)  # {'a': 1, 'b': 2}

d['b'] = 3
print(d)    # {'a': 1, 'b': 3}
print(cd)   # {'a': 1, 'b': 3}

cd3 = d2
print(cd3)  # {'a': 1, 'b': [2, 3]}

d2['b'][0] = 4
print(d2)   # {'a': 1, 'b': [4, 3]}
print(cd3)  # {'a': 1, 'b': [4, 3]}
```

```python
# 列表
l = [1,2,3]

cl = l[:]

print(id(l))  # 3119656091336
print(id(cl)) # 3119656091464

print(cl)     # [1, 2, 3]

# 追加值
l.append(4)

# 未影响cl
print(l)  # [1, 2, 3, 4]
print(cl) # [1, 2, 3]


# 复合对象
l2 = [1,2,3,[4,5]]
cl2 = l[:]

print(id(l2))  # 3119656088840
print(id(cl2)) # 3119656164040

print(cl2)   # [1, 2, 3, [4, 5]]

# 修改值
l2[3][0]=6

# 影响cl2
print(l2)    # [1, 2, 3, [6, 5]]
print(cl2)   # [1, 2, 3, [6, 5]]
```

类可以使用与控制序列化(pickling)操作相同的接口来控制复制操作，关于这些方法的描述信息请参考 pickle 模块。实际上，copy 模块使用的正是从 [copyreg](https://docs.python.org/zh-cn/3.8/library/copyreg.html#module-copyreg) 模块中注册的 pickle 函数。

**可以通过定义特殊方法 `__copy__()` 和 `__deepcopy__()`，给一个类定义它自己的拷贝操作实现**。调用前者以实现浅层拷贝操作，该方法不用传入额外参数。 调用后者以实现深层拷贝操作；它应传入一个参数即 memo 字典。 如果 `__deepcopy__()` 实现需要创建一个组件的深层拷贝，它应当调用 `deepcopy()` 函数，并以该组件作为第一个参数，而将 memo 字典作为第二个参数。

--------------------------------------------------------------

[英文官方文档](https://docs.python.org/3.8/library/copy.html)

[中文官方文档](https://docs.python.org/zh-cn/3.8/library/copy.html)