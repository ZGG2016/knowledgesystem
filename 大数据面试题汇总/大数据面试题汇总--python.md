# 大数据面试题汇总--python

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


原文链接：[](https://www.jianshu.com/p/157d0af12603)
