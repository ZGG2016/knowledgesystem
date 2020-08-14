# copy

## 1、copy — Shallow and deep copy operations

Source code: [Lib/copy.py](https://github.com/python/cpython/blob/3.8/Lib/copy.py)

*Assignment statements in Python do not copy objects, they create bindings between a target and an object. For collections that are mutable or contain mutable items, a copy is sometimes needed so one can change one copy without changing the other. This module provides generic shallow and deep copy operations (explained below).*

Python 里的赋值语句并不会赋值对象，它们会创建一个目标和一个对象的绑定。

```python
a = 3   # 为3创建了一个引用
b = a   # 并不是把 a 赋值给 b，而是为 3 创建了另一个引用

```

对于 **易变** 的集合，或包含了易变的元素，copy 就是需要的，这样就可用不在改变其他副本的情况下，改变这个副本。

【可变对象包括：字典(dict), 集合(set), 列表(list). 】
【不可变对象包含 整型(int), 字符串(string), 浮点型(float), 元组(tuple)】

```python
import copy
list_copy = [1,2,3,[4,5]]

c = copy.copy(list_copy)
dc = copy.deepcopy(list_copy)

# 分开执行

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

```python
import copy

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

这个模块有浅拷贝和深拷贝。

	copy.copy(x)  返回 x 的浅拷贝。		

	copy.deepcopy(x[, memo])  返回 x 的深拷贝。


	exception copy.error
		Raised for module specific errors.

*The difference between shallow and deep copying is only relevant for compound objects (objects that contain other objects, like lists or class instances):*

*A shallow copy constructs a new compound object and then (to the extent possible) inserts references into it to the objects found in the original.*

*A deep copy constructs a new compound object and then, recursively, inserts copies into it of the objects found in the original.*

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

*Two problems often exist with deep copy operations that don’t exist with shallow copy operations:*

*Recursive objects (compound objects that, directly or indirectly, contain a reference to themselves) may cause a recursive loop.*

*Because deep copy copies everything it may copy too much, such as data which is intended to be shared between copies.*

有两个问题，存在于深拷贝，而不存在于浅拷贝：

- 递归对象(直接或间接包含对自身引用的复合对象)可能导致递归循环。

- 因为深拷贝复制了它能复制的所有内容，比如打算在副本之间共享的数据。(不必要的复制)

*The deepcopy() function avoids these problems by:*

*keeping a memo dictionary of objects already copied during the current copying pass; and*

*letting user-defined classes override the copying operation or the set of components copied.*

deepcopy() 避免上述问题，通过：

- 在复制过程中，保留复制对象的  memo dictionary （？？）

- 让用户定义的类重写 copy 操作，或复制的组件集。

*This module does not copy types like module, method, stack trace, stack frame, file, socket, window, array, or any similar types. It does “copy” functions and classes (shallow and deeply), by returning the original object unchanged; this is compatible with the way these are treated by the pickle module.*

本模块不复制 module, method, stack trace, stack frame, file, socket, window, array, or any similar types。它通过不改变地返回原始对象来（浅层或深层地）“复制”函数和类；

*Shallow copies of dictionaries can be made using dict.copy(), and of lists by assigning a slice of the entire list, for example, copied_list = original_list[:].*

字典的浅拷贝使用 `dict.copy()`。

列表的浅拷贝使用切片:copied_list = original_list[:]

*Classes can use the same interfaces to control copying that they use to control pickling. See the description of module pickle for information on these methods. In fact, the copy module uses the registered pickle functions from the copyreg module.*

类复制使用 pickle

*In order for a class to define its own copy implementation, it can define special methods __copy__() and __deepcopy__(). The former is called to implement the shallow copy operation; no additional arguments are passed. The latter is called to implement the deep copy operation; it is passed one argument, the memo dictionary. If the __deepcopy__() implementation needs to make a deep copy of a component, it should call the deepcopy() function with the component as first argument and the memo dictionary as second argument.*

想要给一个类定义它自己的拷贝操作实现，可以通过定义特殊方法 __copy__() 和 __deepcopy__()。 调用前者以实现浅层拷贝操作，该方法不用传入额外参数。 调用后者以实现深层拷贝操作；它应传入一个参数即 memo 字典。 如果 __deepcopy__() 实现需要创建一个组件的深层拷贝，它应当调用 deepcopy() 函数并以该组件作为第一个参数，而将 memo 字典作为第二个参数。
