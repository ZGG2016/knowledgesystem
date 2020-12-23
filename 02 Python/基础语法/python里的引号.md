# python里的引号

## 1、多行注释

三个双引号、三个单引号是多行注释

```python

"""
print("aaaa")
print("bbbb")
"""

'''
print("aaaa")
print("bbbb")
'''

```

## 2、定义字符串

```python
# 普通定义字符串
s1 = "aaaa"
s2 = 'aaaa'
print(s1,s2)
# aaaa aaaa

# 单引号与双引号互相嵌套使用
s3 = "aa'bb'"
s4 = 'aa"bb"'
print(s3)
print(s4)
# aa'bb'
# aa"bb"

s5 = "aa"bb""  # 错误用法

# 格式控制
s6 = "zhangsan:%d" % 12 
s7 = 'zhangsan:%d' % 12 
print(s6)
print(s7)
# zhangsan:12
# zhangsan:12

# 转义
s8 = "let's go"
s9 = 'let\'s go'
# s10 = 'let's go' # 报错
print(s8)
print(s9)
# let's go
# let's go
```

```python
# 三引号定义字符串
s3 = """aaa\n
bbb\nccc\tddd
"""
print(s3)
# aaa
# 
# bbb
# ccc	ddd
```

三引号可以将复杂的字符串进行赋值。

Python 三引号允许一个字符串跨多行，字符串中可以包含换行符、制表符以及其他特殊字符。

三引号的语法是一对连续的单引号或者双引号（通常都是成对的用）。

三引号让程序员从引号和特殊字符串的泥潭里面解脱出来，自始至终保持一小块字符串的格式是所谓的WYSIWYG（所见即所得）格式的。

一个典型的用例是，当你需要一块HTML或者SQL时，这时当用三引号标记，使用传统的转义字符体系将十分费神。

```python
errHTML = '''
<HTML><HEAD><TITLE>
Friends CGI Demo</TITLE></HEAD>
<BODY><H3>ERROR</H3>
<B>%s</B><P>
<FORM><INPUT TYPE=button VALUE=Back
ONCLICK="window.history.back()"></FORM>
</BODY></HTML>
'''

cursor.execute('''
CREATE TABLE users (  
login VARCHAR(8), 
uid INTEGER,
prid INTEGER)
''')
```
