# read、readline、readlines、writeline和writelines的区别

[TOC]

## 1、读

```python
    @abstractmethod
    def read(self, n: int = -1) -> AnyStr:
        pass

    @abstractmethod
    def readline(self, limit: int = -1) -> AnyStr:
        pass

    @abstractmethod
    def readlines(self, hint: int = -1) -> List[AnyStr]:
        pass
```

数据：

	Sample data warehouse
	Enhanced slowly changing
	Recommended best practices


```python
# 读全部字节
with open('data.txt','r') as f:
    tmp = f.read()
    print(tmp)
    print(type(tmp))
# Sample data warehouse
# Enhanced slowly changing
# Recommended best practices
# <class 'str'>


# 读10个字节
with open('data.txt','r') as f:
    tmp = f.read(10)
    print(tmp)
    print(type(tmp))
# Sample dat
# <class 'str'>


# 读取文件中的一行，返回读取的一行数据，字符串。
with open('data.txt','r') as f:
    tmp = f.readline() 
    print(tmp)
    print(type(tmp))
# Sample data warehouse
# <class 'str'>

# 读取文件中的所有行，返回所有行为元素组成的列表。
with open('data.txt','r') as f:
    tmp = f.readlines() 
    print(tmp)
    print(type(tmp))
# ['Sample data warehouse\n', 'Enhanced slowly changing\n', 'Recommended best practices']
# <class 'list'>
```

所以：

- read([n])：从文件当前位置起读取 n 个字节，若无参数，则表示读取至文件结束为止，返回字符串对象

- readline()：读取文件中的一行，返回读取的一行数据，字符串形式。

- readlines()：读取文件中的所有行，返回所有行为元素组成的列表。

另外，使用 linecache 模块读文件的第 n 行：

```python
import linecache
# 读第二行
sline = linecache.getline('data.txt',2)
print(sline)
```

## 2、写

```python
    @abstractmethod
    def write(self, s: AnyStr) -> int:
        pass

    @abstractmethod
    def writelines(self, lines: List[AnyStr]) -> None:
        pass
```

```python
# 写入一个字符串，返回写入的字符数，总是等于字符串的长度
with open('data.txt','w') as f:
    tmp1 = f.write("aaa")
    print(tmp1)
    print(type(tmp1))

    tmp2 = f.write("bbb")
    print(tmp2)
    print(type(tmp2))
# 3
# <class 'int'>
# 3
# <class 'int'>
# 文件内容：
#     aaabbb


# 必须是字符串
with open('data.txt','w') as f:
    tmp = f.write(['aaa'])
    print(tmp)
    print(type(tmp))
# TypeError: write() argument must be str, not list

#################################################################

# 写入一个字符串，返回Node，类型为NoneType
with open('data.txt','w') as f:
    tmp1 = f.writelines("aaa")
    print(tmp1)
    print(type(tmp1))
    
    tmp2 = f.writelines("bbb")
    print(tmp2)
    print(type(tmp2))
# None
# <class 'NoneType'>
# None
# <class 'NoneType'>
# 文件内容：
#     aaabbb


# 参数需要是可迭代类型
with open('data.txt','w') as f:
    tmp = f.writelines(123)
    print(tmp)
    print(type(tmp))
# TypeError: 'int' object is not iterable


# 写入一个列表
with open('data.txt','w') as f:
    tmp = f.writelines(["aaa"])
    print(tmp)
    print(type(tmp))
# None
# <class 'NoneType'>
# 文件内容：
#     aaa


# 写入一个字典
with open('data.txt','w') as f:
    tmp1 = f.writelines({"a":"123","b":"456"})
    print(tmp1)
    print(type(tmp1))
# None
# <class 'NoneType'>
# None
# <class 'NoneType'>
# 文件内容：
#     ab


# 可迭代类型里面的元素必须是字符串
with open('data.txt','w') as f:
    tmp = f.writelines([123])
    print(tmp)
    print(type(tmp))
# TypeError: write() argument must be str, not int
```

所以：

- write()：写入字符串的所有字节，返回写入的字符数。必须是字符串。

- writelines()：参数需要是可迭代类型，可以是字符串，可以是列表，但其元素必须是字符串。返回None。相当与`for line in list: f.write(line)`。注意，写入字典时，只写入键。