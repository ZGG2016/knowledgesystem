# json模块

[TOC]

## 1、json简介

json 是轻量级的文本数据交换格式。

语法规则：

- 数据在 名称/值对 中

- 数据由逗号分隔

- 大括号 {} 保存对象

- 中括号 [] 保存数组，数组可以包含多个对象

名称/值对：

	key : value （字段名称是字符串）

	"name" : "菜鸟教程"

值可以是：

- 数字（整数或浮点数）: { "age":30 }

- 字符串（在双引号中）

- 逻辑值（true 或 false）

- 数组（在中括号中）：

		{
	    	"sites": [
	        	{ "name":"菜鸟教程" , "url":"www.runoob.com" }, 
	        	{ "name":"google" , "url":"www.google.com" }, 
	        	{ "name":"微博" , "url":"www.weibo.com" }
	    	]
		}

		访问：myObj.sites[0]

- 对象（在大括号中）: 

		{"网站":
			{ "name":"菜鸟教程" , "url":"www.runoob.com" }
		}

		访问：myObj["网站"]   或  访问：myObj.网站

- null

[更多描述](https://www.runoob.com/json/json-tutorial.html)

## 2、模块方法

### 2.1、json.dump

	json.dump(obj, fp, *, skipkeys=False, ensure_ascii=True, 
		      check_circular=True, allow_nan=True, cls=None, 
		      indent=None, separators=None, default=None, 
		      sort_keys=False, **kw)

使用这个[转换表](https://docs.python.org/zh-cn/3.8/library/json.html#py-to-json-table) **将 obj 序列化为 JSON 格式化流形式的 fp** (支持 `.write()` 的 [file-like object](https://docs.python.org/zh-cn/3.8/glossary.html#term-file-like-object))。

如果 **skipkeys 是 true** （默认为 False），那么那些**不是基本对象（包括 str, int、float、bool、None）的字典的键会被跳过**；否则引发一个 TypeError。

json 模块**始终产生 str 对象而非 bytes 对象**。因此，fp.write() 必须支持 str 输入。

如果 **ensure_ascii 是 true** （即默认值），输出保证**将所有输入的非 ASCII 字符转义**。如果 ensure_ascii 是 false，这些字符会原样输出。

如果 check_circular 是为假值 (默认为 True)，那么容器类型的循环引用检验会被跳过并且循环引用会引发一个 OverflowError (或者更糟的情况)。

如果 **allow_nan 是 false**（默认为 True），那么在对严格 JSON 规格范围外的 **float 类型值（`nan`、`inf` 和 `-inf`）进行序列化时会引发一个 ValueError**。如果 allow_nan 是 true，则使用它们的 JavaScript 等价形式（`NaN`、`Infinity` 和 `-Infinity`）。

如果 **indent 是一个非负整数或者字符串**，那么 JSON 数组元素和对象成员会**被美化输出为该值指定的缩进等级**。 **如果缩进等级为零、负数或者 ""，则只会添加换行符**。 **None (默认值) 选择最紧凑的表达**。 **使用一个正整数会让每一层缩进同样数量的空格**。 **如果 indent 是一个字符串 (比如 "\t")，那个字符串会被用于缩进每一层**。

**当被指定时，separators 应当是一个 (item_separator, key_separator) 元组**。当 indent 为 None 时，默认值取 (`, `,`: `)，否则取 (`,`,`: `)。为了得到最紧凑的 JSON 表达式，你应该指定其为 (`,`,`:`) 以消除空白字符。

**当 default 被指定时，其应该是一个函数**，每当某个对象无法被序列化时它会被调用。它应该**返回该对象的一个可以被 JSON 编码的版本**或者引发一个 TypeError。如果没有被指定，则会直接引发 TypeError。

如果 **sort_keys 是 true**（默认为 False），那么**字典的输出会以键的顺序排序**。

为了使用一个**自定义的 JSONEncoder 子类**（比如：覆盖了 default() 方法来序列化额外的类型），**通过 cls 关键字参数来指定**；否则将使用 JSONEncoder。

在 3.6 版更改: 所有可选形参现在都是 仅限关键字参数。

注解：与 pickle 和 marshal 不同，JSON 不是一个具有框架的协议，所以**尝试多次使用同一个 fp 调用 dump() 来序列化多个对象会产生一个不合规的 JSON 文件**。

### 2.2、json.dumps

	json.dumps(obj, *, skipkeys=False, ensure_ascii=True, 
		       check_circular=True, allow_nan=True, cls=None, 
		       indent=None, separators=None, default=None, 
		       sort_keys=False, **kw)

使用这个转换表**将 obj 序列化为 JSON 格式的 str**。 

其参数的含义与 dump() 中的相同。

注解：**JSON 中的键-值对中的键永远是 str 类型的**。当一个对象被转化为 JSON 时，字典中所有的键都会被强制转换为字符串。这所造成的结果是字典被转换为 JSON 然后转换回字典时可能和原来的不相等。换句话说，如果 x 具有非字符串的键，则有 `loads(dumps(x)) != x`。

------------------------------------------------------------------------------------

```sh
>>> import json
>>> json.dumps(['foo', {'bar': ('baz', None, 1.0, 2)}])
'["foo", {"bar": ["baz", null, 1.0, 2]}]'

>>> print(json.dumps("\"foo\bar"))
"\"foo\bar"

>>> print(json.dumps('\u1234'))
"\u1234"

>>> print(json.dumps('\\'))
"\\"

>>> print(json.dumps({"c": 0, "b": 0, "a": 0}, sort_keys=True))
{"a": 0, "b": 0, "c": 0}

>>> from io import StringIO
>>> io = StringIO()
>>> json.dump(['streaming API'], io)
>>> io.getvalue()
'["streaming API"]'
```

紧凑编码：

```sh
>>> import json
>>> json.dumps([1, 2, 3, {'4': 5, '6': 7}], separators=(',', ':'))
'[1,2,3,{"4":5,"6":7}]'
```

美化输出：

```sh
>>> import json
>>> print(json.dumps({'4': 5, '6': 7}, sort_keys=True, indent=4))
{
    "4": 5,
    "6": 7
}
```

------------------------------------------------------------------------------------


### 2.3、json.load

	json.load(fp, *, cls=None, object_hook=None,
	 		  parse_float=None, parse_int=None, 
	 		  parse_constant=None, object_pairs_hook=None, **kw)

使用这个转换表**将 fp (一个支持 `.read()` 并包含一个 JSON 文档的 text file 或者 binary file) 反序列化为一个 Python 对象**。

object_hook 是一个可选的函数，它会被调用于每一个解码出的对象字面量（即一个 dict）。object_hook 的返回值会取代原本的 dict。这一特性**能够被用于实现自定义解码器**（如 JSON-RPC 的类型提示)。

object_pairs_hook 是一个可选的函数，它会被调用于每一个有序列表对解码出的对象字面量。 object_pairs_hook 的返回值将会取代原本的 dict 。这一特性能够被用于实现自定义解码器。**如果 object_hook 也被定义，object_pairs_hook 优先**。

parse_float ，如果指定，将与每个要解码 JSON 浮点数的字符串一同调用。**默认状态下，相当于 float(num_str)**。可以用于对 JSON 浮点数使用其它数据类型和语法分析程序（比如 decimal.Decimal ）。

parse_int ，如果指定，将与每个要解码 JSON 整数的字符串一同调用。**默认状态下，相当于 int(num_str)** 。可以用于对 JSON 整数使用其它数据类型和语法分析程序 （比如 float ）。

parse_constant ，**如果指定，将要与以下字符串中的一个一同调用： '-Infinity' ，'Infinity' ，'NaN'** 。如果遇到无效的 JSON 数字则可以使用它引发异常。

在 3.1 版更改: parse_constant 不再调用 'null' ， 'true' ， 'false' 。

**要使用自定义的 JSONDecoder 子类，用 cls 指定他**；否则使用 JSONDecoder 。额外的关键词参数会通过类的构造函数传递。

如果反序列化的数据不是有效 JSON 文档，引发 JSONDecodeError 错误。

在 3.6 版更改: 所有可选形参现在都是 仅限关键字参数。

在 3.6 版更改: fp 现在可以是 [binary file](https://docs.python.org/zh-cn/3.8/glossary.html#term-binary-file) 。输入编码应当是 UTF-8 ，UTF-16 或者 UTF-32 。

### 2.4、json.loads

	json.loads(s, *, cls=None, object_hook=None, 
		      parse_float=None, parse_int=None, 
		      parse_constant=None, object_pairs_hook=None, **kw)

使用这个转换表**将 s (一个包含 JSON 文档的 str, bytes 或 bytearray 实例) 反序列化为 Python 对象**。

自 Python 3.1 以来，除了*encoding*被忽略和弃用，其他参数的含义与 load() 中相同。

如果反序列化的数据不是有效 JSON 文档，引发 JSONDecodeError 错误。

在 3.6 版更改: s 现在可以为 bytes 或 bytearray 类型。 输入编码应为 UTF-8, UTF-16 或 UTF-32。

------------------------------------------------------------------------------------

```sh
>>> import json
>>> json.loads('["foo", {"bar":["baz", null, 1.0, 2]}]')
['foo', {'bar': ['baz', None, 1.0, 2]}]
>>> json.loads('"\\"foo\\bar"')
'"foo\x08ar'
>>> from io import StringIO
>>> io = StringIO('["streaming API"]')
>>> json.load(io)
['streaming API']
```

特殊 JSON 对象解码：

```sh
>>> import json
>>> def as_complex(dct):
...     if '__complex__' in dct:
...         return complex(dct['real'], dct['imag'])
...     return dct
...
>>> json.loads('{"__complex__": true, "real": 1, "imag": 2}',
...     object_hook=as_complex)
(1+2j)
>>> import decimal
>>> json.loads('1.1', parse_float=decimal.Decimal)
Decimal('1.1')
```


------------------------------------------------------------------------------------

## 3、编码器和解码器

### 3.1、json.JSONDecoder

	class json.JSONDecoder(*, object_hook=None, parse_float=None, 
							parse_int=None, parse_constant=None, 
							strict=True, object_pairs_hook=None)

简单的JSON解码器。

默认情况下，解码执行以下翻译:

JSON   |  Python
---|:---
object | dict
array  | list
string | str
number (int)  | int
number (real) |float
true  | True
false | False
null  | None


它还将“NaN”、“Infinity”和“-Infinity”理解为它们对应的“float”值，这超出了JSON规范。

object_hook ，如果指定，会**被每个解码的 JSON 对象的结果调用，并且返回值会替代给定 dict** 。它可被用于**提供自定义反序列化**（比如去支持 JSON-RPC 类的暗示）。

如果指定了 object_pairs_hook 则它**将被调用并传入以对照值有序列表进行解码的每个 JSON 对象的结果。 object_pairs_hook 的结果值将被用来替代 dict**。 这一特性可被用于**实现自定义解码器**。 如果还定义了 object_hook，则 object_pairs_hook 的优先级更高。

parse_float ，如果指定，将与每个要解码 JSON 浮点数的字符串一同调用。**默认状态下，相当于 float(num_str)** 。可以用于对 JSON 浮点数使用其它数据类型和语法分析程序 （比如 decimal.Decimal ）。

parse_int ，如果指定，将与每个要解码 JSON 整数的字符串一同调用。**默认状态下，相当于 int(num_str)** 。可以用于对 JSON 整数使用其它数据类型和语法分析程序 （比如 float ）。

parse_constant ，如果指定，**将要与以下字符串中的一个一同调用： '-Infinity' ， 'Infinity' ， 'NaN'** 。如果遇到无效的 JSON 数字则可以使用它引发异常。

如果 strict 为 false （默认为 True ），那么**控制字符将被允许在字符串内**。在此上下文中的控制字符编码在范围 0--31 内的字符，包括 '\t' (制表符）， '\n' ， '\r' 和 '\0' 。

如果反序列化的数据不是有效 JSON 文档，引发 JSONDecodeError 错误。

在 3.6 版更改: 所有形参现在都是 仅限关键字参数。

	decode(s)

返回 s 的 Python 表示形式（包含一个 JSON 文档的 str 实例）。

如果给定的 JSON 文档无效则将引发 JSONDecodeError。

	raw_decode(s)

从 s 中解码出 JSON 文档（以 JSON 文档开头的一个 str 对象）并返回一个 Python 表示形式为 2 元组以及指明该文档在 s 中结束位置的序号。

这可以用于从一个字符串解码JSON文档，该字符串的末尾可能有无关的数据。

### 3.2、json.JSONEncoder

	class json.JSONEncoder(*, skipkeys=False, ensure_ascii=True, 
							check_circular=True, allow_nan=True, 
							sort_keys=False, indent=None, separators=None, default=None)

用于Python数据结构的可扩展JSON编码器。

默认支持以下对象和类型：

Python  | JSON
---|:---
dict  |  object
list, tuple  |  array
str  |  string
int, float, int 和 float 派生的枚举  |  number
True  |  true
False  |  false
None  |  null

**为了将其拓展至识别其他对象，需要子类化，并实现 default() 方法，另一种返回 o 的可序列化对象的方法，如果可行的话**，否则它应该调用超类实现（来引发 TypeError ）。

如果 **skipkeys 为假值（默认），则尝试对不是 str, int, float 或 None 的键进行编码**，将会引发 TypeError。 如果 skipkeys 为真值，这些条目将被直接跳过。

如果 **ensure_ascii 是 true**（即默认值），输出保证**将所有输入的非 ASCII 字符转义**。如果 ensure_ascii 是 false，这些字符会原样输出。

如果 **check_circular 为 true** （默认），那么列表，字典，和自定义编码的对象在编码期间会**被检查重复循环引用**，防止无限递归（无限递归将导致 OverflowError ）。否则，这样进行检查。

如果 **allow_nan 为 true** （默认），那么**NaN ， Infinity ，和 -Infinity 进行编码**。此行为不符合 JSON 规范，但与大多数的基于 Javascript 的编码器和解码器一致。否则，它将是一个 ValueError 来编码这些浮点数。

如果 **sort_keys 为 true** （默认为： False ），那么**字典的输出是按照键排序**；这对回归测试很有用，以确保可以每天比较 JSON 序列化。

如果 **indent 是一个非负整数或者字符串，那么 JSON 数组元素和对象成员会被美化输出为该值指定的缩进等级。 如果缩进等级为零、负数或者 ""，则只会添加换行符。 None (默认值) 选择最紧凑的表达。 使用一个正整数会让每一层缩进同样数量的空格。 如果 indent 是一个字符串 (比如 "\t")，那个字符串会被用于缩进每一层**。

当被指定时，separators 应当是一个 (item_separator, key_separator) 元组。当 indent 为 None 时，默认值取 (`, `, `: `)，否则取 (`,`, `: `)。为了得到最紧凑的 JSON 表达式，你应该指定其为 (`,`, `:`) 以消除空白字符。

在 3.4 版更改: 现当 indent 不是 None 时，采用 (`,`, `: `) 作为默认值。

当 **default 被指定时，其应该是一个函数，每当某个对象无法被序列化时它会被调用**。它应该返回该对象的一个可以被 JSON 编码的版本或者引发一个 TypeError。如果没有被指定，则会直接引发 TypeError。

在 3.6 版更改: 所有形参现在都是 仅限关键字参数。

	default(o)

在子类中实现这种方法使其返回 o 的可序列化对象，或者调用基础实现（引发 TypeError ）。

比如说，为了支持任意迭代器，你可以像这样实现默认设置:

```python
def default(self, o):
   try:
       iterable = iter(o)
   except TypeError:
       pass
   else:
       return list(iterable)
   # Let the base class default method raise the TypeError
   return json.JSONEncoder.default(self, o)
encode(o)
```

返回 Python o 数据结构的 JSON 字符串表达方式。例如:

```sh
>>> json.JSONEncoder().encode({"foo": ["bar", "baz"]})
'{"foo": ["bar", "baz"]}'
iterencode(o)
```

编码给定对象 o ，并且让每个可用的字符串表达方式。例如:

```python
for chunk in json.JSONEncoder().iterencode(bigobject):
    mysocket.write(chunk)
```

-------------------------------------------------------------------------------

扩展 JSONEncoder：

```sh
>>> import json
>>> class ComplexEncoder(json.JSONEncoder):
...     def default(self, obj):
...         if isinstance(obj, complex):
...             return [obj.real, obj.imag]
...         # Let the base class default method raise the TypeError
...         return json.JSONEncoder.default(self, obj)
...
>>> json.dumps(2 + 1j, cls=ComplexEncoder)
'[2.0, 1.0]'
>>> ComplexEncoder().encode(2 + 1j)
'[2.0, 1.0]'
>>> list(ComplexEncoder().iterencode(2 + 1j))
['[2.0', ', 1.0', ']']
```

-------------------------------------------------------------------------------

[英文官方文档](https://docs.python.org/3.8/library/json.html)

[中文官方文档](https://docs.python.org/zh-cn/3.8/library/json.html)