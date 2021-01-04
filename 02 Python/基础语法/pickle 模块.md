# pickle 模块

[TOC]

模块 pickle 实现了**对一个 Python 对象结构的二进制序列化和反序列化**。 

"pickling" 是将 Python 对象及其所拥有的层次结构转化为一个字节流的过程，而 "unpickling" 是相反的操作，会将（来自一个 [binary file](https://docs.python.org/zh-cn/3.8/glossary.html#term-binary-file) 或者 [bytes-like object](https://docs.python.org/zh-cn/3.8/glossary.html#term-bytes-like-object) 的）字节流转化回一个对象层次结构。 

pickling（和 unpickling）也被称为“序列化”，“编组”或者“平面化”。而为了避免混乱，此处采用术语 “封存 (pickling)” 和 “解封 (unpickling)”。

警告：pickle 模块**并不安全**。你只应该对你信任的数据进行 unpickle 操作。构建恶意的 pickle 数据来在解封时执行任意代码是可能的。绝对不要对不信任来源的数据和可能被篡改过的数据进行解封。

请考虑使用 [hmac](https://docs.python.org/zh-cn/3.8/library/hmac.html#module-hmac) 来对数据进行签名，确保数据没有被篡改。

**在你处理不信任数据时，更安全的序列化格式(如json)可能更为适合**。

## 1、与其他 Python 模块间的关系

### 1.1、与 marshal 间的关系

### 1.2、与 json 模块的比较

Pickle 协议和 JSON 有着本质的不同：

- JSON 是一个文本序列化格式（它输出 unicode 文本，尽管在大多数时候它会接着以 utf-8 编码），而 pickle 是一个二进制序列化格式；

- JSON 是我们可以直观阅读的，而 pickle 不是；

- JSON 是可互操作的，在 Python 系统之外广泛使用，而 pickle 则是 Python 专用的；

- 默认情况下，JSON 只能表示 Python 内置类型的子集，不能表示自定义的类；但 pickle 可以表示大量的 Python 数据类型（可以合理使用 Python 的对象内省功能自动地表示大多数类型，复杂情况可以通过实现 [specific object APIs](https://docs.python.org/zh-cn/3.8/library/pickle.html#pickle-inst) 来解决）。

- 不像 pickle，对一个不信任的 JSON 进行反序列化的操作本身不会造成任意代码执行漏洞。

json 模块:一个允许 JSON 序列化和反序列化的标准库模块。

## 2、数据流格式

pickle 所使用的数据格式**仅可用于 Python**。这样做的好处是没有外部标准给该格式强加限制，比如 JSON 或 XDR（不能表示共享指针）标准；但这也意味着非 Python 程序可能无法重新读取 pickle 封存的 Python 对象。

**默认情况下，pickle 格式使用相对紧凑的二进制来存储。如果需要让文件更小，可以高效地 压缩 由 pickle 封存的数据**。

**[pickletools](https://docs.python.org/zh-cn/3.8/library/pickletools.html#module-pickletools) 模块包含了相应的工具用于分析 pickle 生成的数据流**。pickletools 源码中包含了对 pickle 协议使用的操作码的大量注释。

当前共有 6 种不同的协议可用于封存操作。 使用的协议版本越高，读取所生成 pickle 对象所需的 Python 版本就要越新。

- v0 版协议是原始的“人类可读”协议，并且向后兼容早期版本的 Python。

- v1 版协议是较早的二进制格式，它也与早期版本的 Python 兼容。

- v2 版协议是在 Python 2.3 中引入的。它为存储 [new-style class](https://docs.python.org/zh-cn/3.8/glossary.html#term-new-style-class) 提供了更高效的机制。欲了解有关第 2 版协议带来的改进，请参阅 [PEP 307](https://www.python.org/dev/peps/pep-0307)。

- v3 版协议是在 Python 3.0 中引入的。 它显式地支持 bytes 字节对象，不能使用 Python 2.x 解封。这是 Python 3.0-3.7 的默认协议。

- v4 版协议添加于 Python 3.4。它支持存储非常大的对象，能存储更多种类的对象，还包括一些针对数据格式的优化。它是Python 3.8使用的默认协议。有关第 4 版协议带来改进的信息，请参阅 [PEP 3154](https://www.python.org/dev/peps/pep-3154)。

- 第 5 版协议是在 Python 3.8 中加入的。 它增加了对带外数据的支持，并可加速带内数据处理。 请参阅 [PEP 574](https://www.python.org/dev/peps/pep-0574) 了解第 5 版协议所带来的改进的详情。

注解：

序列化是一种比持久化更底层的概念，虽然 pickle 读取和写入的是文件对象，但它不处理持久对象的命名问题，也不处理对持久对象的并发访问（甚至更复杂）的问题。

pickle 模块可以将复杂对象转换为字节流，也可以将字节流转换为具有相同内部结构的对象。处理这些字节流最常见的做法是将它们写入文件，但它们也可以通过网络发送或存储在数据库中。[shelve](https://docs.python.org/zh-cn/3.8/library/shelve.html#module-shelve) 模块提供了一个简单的接口，用于在 DBM 类型的数据库文件上封存和解封对象。

## 3、模块接口

**要序列化某个包含层次结构的对象，只需调用 dumps() 函数即可。同样，要反序列化数据流，可以调用 loads() 函数**。

但是，如果要对序列化和反序列化**加以更多的控制，可以分别创建 Pickler 或 Unpickler 对象**。

### 3.1、pickle 模块包含了以下常量：

	pickle.HIGHEST_PROTOCOL

整数，可用的最高[协议版本](https://docs.python.org/zh-cn/3.8/library/pickle.html#pickle-protocols)。此值**可以作为协议值传递给 dump() 和 dumps() 函数，以及 Pickler 的构造函数**。

	pickle.DEFAULT_PROTOCOL

整数，用于 pickle 数据的**默认协议版本**。它可能小于 HIGHEST_PROTOCOL。当前默认协议是 v4，它在 Python 3.4 中首次引入，与之前的版本不兼容。

在 3.0 版更改: 默认协议版本是 3。

在 3.8 版更改: 默认协议版本是 4。

### 3.2、pickle 模块提供了以下方法，让封存过程更加方便：

	pickle.dump(obj, file, protocol=None, 
		        *, fix_imports=True, buffer_callback=None)

**将对象 obj 封存以后的对象写入已打开的 [file object](https://docs.python.org/zh-cn/3.8/glossary.html#term-file-object) file**。它等同于 Pickler(file, protocol).dump(obj)。

参数 file、protocol、fix_imports 和 buffer_callback 的含义与它们在 Pickler 的构造函数中的含义相同。

在 3.8 版更改: 加入了 buffer_callback 参数。

	pickle.dumps(obj, protocol=None, 
		         *, fix_imports=True, buffer_callback=None)

**将 obj 封存以后的对象作为 bytes 类型直接返回**，而不是将其写入到文件。

参数 protocol、fix_imports 和 buffer_callback 的含义与它们在 Pickler 的构造函数中的含义相同。

在 3.8 版更改: 加入了 buffer_callback 参数。

	pickle.load(file, *, fix_imports=True, 
				encoding="ASCII", errors="strict", buffers=None)

**从已打开的 file object 文件 中读取封存后的对象，重建其中特定对象的层次结构并返**回。它相当于 Unpickler(file).load()。

Pickle 协议版本是自动检测出来的，所以不需要参数来指定协议。封存对象以外的其他字节将被忽略。

参数 file、fix_imports、encoding、errors、strict 和 buffers 的含义与它们在 Unpickler 的构造函数中的含义相同。

在 3.8 版更改: 加入了 buffers 参数。

	pickle.loads(data, *, fix_imports=True, 
				encoding="ASCII", errors="strict", buffers=None)

**重建并返回一个对象的封存表示形式 data 的对象层级结构**。 data 必须为 bytes-like object。

Pickle 协议版本是自动检测出来的，所以不需要参数来指定协议。封存对象以外的其他字节将被忽略。

参数 file、fix_imports、encoding、errors、strict 和 buffers 的含义与它们在 Unpickler 的构造函数中的含义相同。

在 3.8 版更改: 加入了 buffers 参数。

### 3.3、pickle 模块定义了以下 3 个异常：

	exception pickle.PickleError

其他 pickle 异常的基类。它是 Exception 的一个子类。

	exception pickle.PicklingError

当 Pickler 遇到无法解封的对象时抛出此错误。它是 PickleError 的子类。

参考 可以被封存/解封的对象 来了解哪些对象可以被封存。

	exception pickle.UnpicklingError

当解封出错时抛出此异常，例如数据损坏或对象不安全。它是 PickleError 的子类。

注意，解封时可能还会抛出其他异常，包括（但不限于） AttributeError、EOFError、ImportError 和 IndexError。

### 3.4、pickle 模块包含了 3 个类，Pickler、Unpickler 和 PickleBuffer：

#### 3.4.1、class pickle.Pickler

	class pickle.Pickler(file, protocol=None, 
						*, fix_imports=True, buffer_callback=None)

它**接受一个二进制文件，用于写入 pickle 数据流**。

可选参数 **protocol 是一个整数，告知 pickler 使用指定的协议**，可选择的协议范围从 0 到 HIGHEST_PROTOCOL。如果没有指定，这一参数默认值为 DEFAULT_PROTOCOL。指定一个负数就相当于指定 HIGHEST_PROTOCOL。

**参数 file 必须有一个 write() 方法，该 write() 方法要能接收字节作为其唯一参数**。因此，它可以是一个打开的磁盘文件（用于写入二进制内容），也可以是一个 io.BytesIO 实例，也可以是满足这一接口的其他任何自定义对象。

如果 fix_imports 为 True 且 protocol 小于 3，pickle 将尝试将 Python 3 中的新名称映射到 Python 2 中的旧模块名称，因此 Python 2 也可以读取封存的数据流。

如果 buffer_callback **为 None（默认情况），缓冲区视图（buffer view）将会作为 pickle 流的一部分被序列化到文件中**。

如果 buffer_callback **不为 None，那它可以用缓冲区视图调用任意次**。如果某次调用返回了 False 值（例如 None），则给定的缓冲区是 [带外的](https://docs.python.org/zh-cn/3.8/library/pickle.html#pickle-oob)，否则缓冲区是带内的（例如保存在了 pickle 流里面）。

如果 buffer_callback 不是 None 且 protocol 是 None 或小于 5，就会出错。

在 3.8 版更改: 加入了 buffer_callback 参数。

	dump(obj)

**将 obj 封存后的内容写入已打开的文件对象**，该文件对象已经在构造函数中指定。

	persistent_id(obj)

默认无动作，**子类继承重载时使用**。

如果 persistent_id() 返回 None，obj 会被照常 pickle。如果返回其他值，Pickler 会将这个函数的返回值作为 obj 的持久化 ID（Pickler 本应得到序列化数据流并将其写入文件，若此函数有返回值，则得到此函数的返回值并写入文件）。

这个持久化 ID 的解释应当定义在 Unpickler.persistent_load() 中（该方法定义还原对象的过程，并返回得到的对象）。

注意，persistent_id() 的返回值本身不能拥有持久化 ID。

参阅 [持久化外部对象](https://docs.python.org/zh-cn/3.8/library/pickle.html#pickle-persistent) 获取详情和使用示例。

	dispatch_table

Pickler 对象的 dispatch 表是 copyreg.pickle() 中用到的 reduction 函数 的注册。

dispatch 表本身是一个 class 到其 reduction 函数的映射键值对。一个 reduction 函数只接受一个参数，就是其关联的 class，函数行为应当遵守 `__reduce__()` 接口规范。

Pickler 对象默认并没有 dispatch_table 属性，该对象默认使用 copyreg 模块中定义的全局 dispatch 表。如果要为特定 Pickler 对象自定义序列化过程，可以将 dispatch_table 属性设置为类字典对象（dict-like object）。另外，如果 Pickler 的子类设置了 dispatch_table 属性，则该子类的实例会使用这个表作为默认的 dispatch 表。

参阅 [Dispatch 表](https://docs.python.org/zh-cn/3.8/library/pickle.html#pickle-dispatch) 获取使用示例。

3.3 新版功能.

	reducer_override(self, obj)

可以在 Pickler 的子类中定义的特殊 reducer。此方法的优先级高于 dispatch_table 中的任何 reducer。它应该与 `__reduce__()` 方法遵循相同的接口，它也可以返回 NotImplemented，这将使用 dispatch_table 里注册的 reducer 来封存 obj。

参阅 [类型，函数和其他对象的自定义归约](https://docs.python.org/zh-cn/3.8/library/pickle.html#reducer-override) 获取详细的示例。

3.8 新版功能.

	fast

已弃用。设为 True 则启用快速模式。快速模式禁用了“备忘录” (memo) 的使用，即不生成多余的 PUT 操作码来加快封存过程。不应将其与自指 (self-referential) 对象一起使用，否则将导致 Pickler 无限递归。

如果需要进一步提高 pickle 的压缩率，请使用 [pickletools.optimize()](https://docs.python.org/zh-cn/3.8/library/pickletools.html#pickletools.optimize)。

#### 3.4.2、class pickle.Unpickler

	class pickle.Unpickler(file, *, fix_imports=True, 
		  			encoding="ASCII", errors="strict", buffers=None)

**接受一个二进制文件用于读取 pickle 数据流**。

Pickle **协议版本是自动检测出来的**，所以不需要参数来指定协议。

参数 file 必须有三个方法，read() 方法接受一个整数参数，readinto() 方法接受一个缓冲区作为参数，readline() 方法不需要参数，这与 [io.BufferedIOBase](https://docs.python.org/zh-cn/3.8/library/io.html#io.BufferedIOBase) 里定义的接口是相同的。因此 **file 可以是一个磁盘上用于二进制读取的文件，也可以是一个 [io.BytesIO](https://docs.python.org/zh-cn/3.8/library/io.html#io.BytesIO) 实例，也可以是满足这一接口的其他任何自定义对象**。

可选的参数是 fix_imports, encoding 和 errors，用于控制由Python 2 生成的 pickle 流的兼容性。

如果 fix_imports 为 True，则 pickle 将尝试将旧的 Python 2 名称映射到 Python 3 中对应的新名称。

encoding 和 errors 参数告诉 pickle 如何解码 Python 2 存储的 8 位字符串实例；这两个参数默认分别为 'ASCII' 和 'strict'。encoding 参数可置为 'bytes' 来将这些 8 位字符串实例读取为字节对象。读取 NumPy array 和 Python 2 存储的 datetime、date 和 time 实例时，请使用 encoding='latin1'。

如果 buffers 为 None（默认值），则反序列化所需的所有数据都必须包含在 pickle 流中。这意味着在实例化 Pickler 时（或调用 dump() 或 dumps() 时），参数 buffer_callback 为 None。

如果 buffers 不为 None，则每次 pickle 流引用 带外 缓冲区视图时，消耗的对象都应该是可迭代的启用缓冲区的对象。这样的缓冲区应该按顺序地提供给 Pickler 对象的 buffer_callback 方法。

在 3.8 版更改: 加入了 buffers 参数。

	load()

**从构造函数中指定的文件对象里读取封存好的对象，重建其中特定对象的层次结构并返回**。封存对象以外的其他字节将被忽略。

	persistent_load(pid)

默认抛出 UnpicklingError 异常。

如果定义了此方法，persistent_load() 应当返回持久化 ID pid 所指定的对象。 如果遇到无效的持久化 ID，则应当引发 UnpicklingError。

参阅 持久化外部对象 获取详情和使用示例。

	find_class(module, name)

如有必要，导入 module 模块并返回其中名叫 name 的对象，其中 module 和 name 参数都是 str 对象。注意，不要被这个函数的名字迷惑， find_class() 同样可以用来导入函数。

子类可以重载此方法，来控制加载对象的类型和加载对象的方式，从而尽可能降低安全风险。参阅 [限制全局变量](https://docs.python.org/zh-cn/3.8/library/pickle.html#pickle-restrict) 获取更详细的信息。

引发一个 [审计事件](https://docs.python.org/zh-cn/3.8/library/sys.html#auditing) pickle.find_class 附带参数 module、name。

#### 3.4.3、class pickle.PickleBuffer

	class pickle.PickleBuffer(buffer)

**缓冲区的包装器 (wrapper)，缓冲区中包含着可封存的数据**。buffer 必须是一个 buffer-providing 对象，比如 bytes-like object 或多维数组。

PickleBuffer 本身就可以生成缓冲区对象，因此**可以将其传递给需要缓冲区生成器的其他 API，比如 memoryview**。

PickleBuffer 对象**只能用 pickle 版本 5 及以上协议进行序列化**。它们符合 [带外序列化](https://docs.python.org/zh-cn/3.8/library/pickle.html#pickle-oob) 的条件。

3.8 新版功能.

	raw()

**返回该缓冲区底层内存区域的 memoryview**。 

返回的对象是一维的、C 连续布局的 [memoryview](https://docs.python.org/zh-cn/3.8/library/stdtypes.html#memoryview)，格式为 B (无符号字节)。 如果缓冲区既不是 C 连续布局也不是 Fortran 连续布局的，则抛出 BufferError 异常。

	release()

**释放**由 PickleBuffer 占用的底层缓冲区。

## 4、可以被封存/解封的对象

下列类型可以被封存：

- None、True 和 False

- 整数、浮点数、复数

- str、byte、bytearray

- 只包含可封存对象的集合，包括 tuple、list、set 和 dict

- 定义在模块最外层的函数（使用 [def](https://docs.python.org/zh-cn/3.8/reference/compound_stmts.html#def) 定义，[lambda](https://docs.python.org/zh-cn/3.8/reference/expressions.html#lambda) 函数则不可以）

- 定义在模块最外层的内置函数

- 定义在模块最外层的类

某些类实例，这些类的 [__dict__](https://docs.python.org/zh-cn/3.8/library/stdtypes.html#object.__dict__) 属性值或 [__getstate__()](https://docs.python.org/zh-cn/3.8/library/pickle.html#object.__getstate__) 函数的返回值可以被封存（详情参阅 封存类实例 这一段）。

尝试封存不能被封存的对象会抛出 **PicklingError** 异常，异常发生时，可能有部分字节已经被写入指定文件中。

尝试封存递归层级很深的对象时，可能会超出最大递归层级限制，此时会抛出 **RecursionError** 异常，可以通过 [sys.setrecursionlimit()](https://docs.python.org/zh-cn/3.8/library/sys.html#sys.setrecursionlimit)调整递归层级，不过请谨慎使用这个函数，因为可能会导致解释器崩溃。

注意，**函数（内置函数或用户自定义函数）在被封存时，引用的是函数全名**。这意味着只有函数所在的模块名，与函数名会被封存，函数体及其属性不会被封存。因此，在解封的环境中，函数所属的模块必须是可以被导入的，而且模块必须包含这个函数被封存时的名称，否则会抛出异常。

同样的，**类也只封存名称**，所以在解封环境中也有和函数相同的限制。注意，类体及其数据不会被封存，所以在下面的例子中类属性 attr 不会存在于解封后的环境中：

```python
class Foo:
    attr = 'A class attribute'

picklestring = pickle.dumps(Foo)
```

**这些限制决定了为什么必须在一个模块的最外层定义可封存的函数和类**。

类似的，**在封存类的实例时，其类体和类数据不会跟着实例一起被封存，只有实例数据会被封存**。这样设计是有目的的，在将来修复类中的错误、给类增加方法之后，仍然可以载入原来版本类实例的封存数据来还原该实例。如果你准备长期使用一个对象，可能会同时存在较多版本的类体，可以为对象添加版本号，这样就可以通过类的 `__setstate__()` 方法将老版本转换成新版本。

## 5、封存类实例

在本节中，我们描述了可用于定义、自定义和控制如何封存和解封类实例的通用流程。

通常，**使一个实例可被封存不需要附加任何代码**。Pickle 默认会通过 Python 的内省机制获得实例的类及属性。而当实例解封时，它的 [__init__()](https://docs.python.org/zh-cn/3.8/reference/datamodel.html#object.__init__) 方法通常 不会 被调用。

其默认动作是：先创建一个未初始化的实例，然后还原其属性。下面的代码展示了这种行为的实现机制：

```python
def save(obj):
    return (obj.__class__, obj.__dict__)

def load(cls, attributes):
    obj = cls.__new__(cls)
    obj.__dict__.update(attributes)
    return obj
```

类可以改变默认行为，只需定义以下一种或几种特殊方法：

	object.__getnewargs_ex__()

对于使用第 2 版或更高版协议的 pickle，实现了 `__getnewargs_ex__()` 方法的类**可以控制在解封时传给 [__new__()](https://docs.python.org/zh-cn/3.8/reference/datamodel.html#object.__new__) 方法的参数**。

本方法必须返回一对 (args, kwargs) 用于构建对象，其中 args 是表示位置参数的元组，而 kwargs 是表示命名参数的字典。它们会在解封时传递给 `__new__()` 方法。

如果类的 `__new__()` 方法只接受关键字参数，则应当实现这个方法。否则，为了兼容性，更推荐实现 `__getnewargs__()` 方法。

在 3.6 版更改: `__getnewargs_ex__()` 现在可用于第 2 和第 3 版协议。

	object.__getnewargs__()

这个方法与上一个 `__getnewargs_ex__()` 方法类似，但**仅支持位置参数**。它要求**返回一个 元组类型的 args，用于解封时传递给 `__new__()` 方法**。

如果定义了 `__getnewargs_ex__()`，那么 `__getnewargs__()` 就不会被调用。

在 3.6 版更改: 在 Python 3.6 前，第 2、3 版协议会调用 `__getnewargs__()`，更高版本协议会调用 `__getnewargs_ex__()`。

	object.__getstate__()

类还可以进一步控制其实例的封存过程。如果类定义了 `__getstate__()`，它就会被调用，其**返回的对象是被当做实例内容来封存的，否则封存的是实例的 [__dict__](https://docs.python.org/zh-cn/3.8/library/stdtypes.html#object.__dict__)。如果 `__getstate__()` 未定义，实例的 `__dict__` 会被照常封存**。

	object.__setstate__(state)

当解封时，如果类定义了 `__setstate__()`，就会在已解封状态下调用它。此时**不要求实例的 state 对象必须是字典**。没有定义此方法的话，先前封存的 state 对象必须是字典，且该字典内容会在解封时赋给新实例的 `__dict__`。

注解 如果 `__getstate__()` 返回 False，那么在解封时就不会调用 `__setstate__()` 方法。
参考 处理有状态的对象 一段获取如何使用 `__getstate__()` 和 `__setstate__()` 方法的更多信息。

注解：在解封时，实例的某些方法例如 `__getattr__()`, `__getattribute__()` 或 `__setattr__()` 可能会被调用。 由于这些方法可能要求某些内部不变量为真值，因此该类型应当实现 `__new__()` 以建立这样的不变量，因为当解封一个实例时 `__init__()` 并不会被调用。
可以看出，其实 pickle 并不直接调用上面的几个函数。事实上，这几个函数是复制协议的一部分，它们实现了 `__reduce__()` 这一特殊接口。**复制协议提供了统一的接口，用于在封存或复制对象的过程中取得所需数据**。

尽管这个协议功能很强，但是**直接在类中实现 `__reduce__()` 接口容易产生错误**。因此，设计类时应当尽可能的使用高级接口（比如 `__getnewargs_ex__()`、`__getstate__()` 和 `__setstate__()`）。后面仍然可以看到直接实现 `__reduce__()` 接口的状况，可能别无他法，可能为了获得更好的性能，或者两者皆有之。

	object.__reduce__()

该接口当前定义如下。`__reduce__()` 方法不带任何参数，并且应**返回字符串或最好返回一个元组（返回的对象通常称为“reduce 值”）**。

如果返回字符串，该字符串会被当做一个全局变量的名称。它应该是对象相对于其模块的本地名称，pickle 模块会搜索模块命名空间来确定对象所属的模块。这种行为常在单例模式使用。

如果返回的是元组，则应当包含 2 到 6 个元素，可选元素可以省略或设置为 None。每个元素代表的意义如下：

- 一个可调用对象，该对象会在创建对象的最初版本时调用。

- 可调用对象的参数，是一个元组。如果可调用对象不接受参数，必须提供一个空元组。

- 可选元素，用于表示对象的状态，将被传给前述的 `__setstate__()` 方法。 如果对象没有此方法，则这个元素必须是字典类型，并会被添加至 `__dict__` 属性中。

- 可选元素，一个返回连续项的迭代器（而不是序列）。这些项会被 obj.append(item) 逐个加入对象，或被 obj.extend(list_of_items) 批量加入对象。这个元素主要用于 list 的子类，也可以用于那些正确实现了 append() 和 extend() 方法的类。（具体是使用 append() 还是 extend() 取决于 pickle 协议版本以及待插入元素的项数，所以这两个方法必须同时被类支持。）

- 可选元素，一个返回连续键值对的迭代器（而不是序列）。这些键值对将会以 obj[key] = value 的方式存储于对象中。该元素主要用于 dict 子类，也可以用于那些实现了 `__setitem__()` 的类。

- 可选元素，一个带有 (obj, state) 签名的可调用对象。该可调用对象允许用户以编程方式控制特定对象的状态更新行为，而不是使用 obj 的静态 `__setstate__()` 方法。如果此处不是 None，则此可调用对象的优先级高于 obj 的 `__setstate__()`。

3.8 新版功能: 新增了元组的第 6 项，可选元素 (obj, state)。

	object.__reduce_ex__(protocol)

作为替代选项，也可以实现 `__reduce_ex__()` 方法。 此方法的唯一不同之处在于**它应接受一个整型参数用于指定协议版本**。 如果定义了这个函数，则会覆盖 `__reduce__()` 的行为。 此外，`__reduce__()` 方法会自动成为扩展版方法的同义词。 这个函数主要用于为以前的 Python 版本提供向后兼容的 reduce 值。

## 6、持久化外部对象

为了获取对象持久化的利益， pickle 模块**支持引用已封存数据流之外的对象**。 这样的对象是通过一个持久化 ID 来引用的，它应当是一个由字母数字类字符组成的字符串(对于第 0 版协议)或是一个任意对象 (用于任意新版协议)。

pickle 模块**不提供对持久化 ID 的解析工作，它将解析工作分配给用户定义的方法**，分别是 pickler 中的 persistent_id() 方法和 unpickler 中的 persistent_load() 方法。

**要通过持久化 ID 将外部对象封存，必须在 pickler 中实现 persistent_id() 方法**，该方法接受需要被封存的对象作为参数，返回一个 None 或返回该对象的持久化 ID。如果返回 None，该对象会被按照默认方式封存为数据流。如果返回字符串形式的持久化 ID，则会封存这个字符串并加上一个标记，这样 unpickler 才能将其识别为持久化 ID。

**要解封外部对象，Unpickler 必须实现 persistent_load() 方法**，接受一个持久化 ID 对象作为参数并返回一个引用的对象。

下面是一个全面的例子，展示了如何使用持久化 ID 来封存外部对象。

```python
# Simple example presenting how persistent ID can be used to pickle
# external objects by reference.

import pickle
import sqlite3
from collections import namedtuple

# Simple class representing a record in our database.
MemoRecord = namedtuple("MemoRecord", "key, task")

class DBPickler(pickle.Pickler):

    def persistent_id(self, obj):
        # Instead of pickling MemoRecord as a regular class instance, we emit a
        # persistent ID.
        if isinstance(obj, MemoRecord):
            # Here, our persistent ID is simply a tuple, containing a tag and a
            # key, which refers to a specific record in the database.
            return ("MemoRecord", obj.key)
        else:
            # If obj does not have a persistent ID, return None. This means obj
            # needs to be pickled as usual.
            return None


class DBUnpickler(pickle.Unpickler):

    def __init__(self, file, connection):
        super().__init__(file)
        self.connection = connection

    def persistent_load(self, pid):
        # This method is invoked whenever a persistent ID is encountered.
        # Here, pid is the tuple returned by DBPickler.
        cursor = self.connection.cursor()
        type_tag, key_id = pid
        if type_tag == "MemoRecord":
            # Fetch the referenced record from the database and return it.
            cursor.execute("SELECT * FROM memos WHERE key=?", (str(key_id),))
            key, task = cursor.fetchone()
            return MemoRecord(key, task)
        else:
            # Always raises an error if you cannot return the correct object.
            # Otherwise, the unpickler will think None is the object referenced
            # by the persistent ID.
            raise pickle.UnpicklingError("unsupported persistent object")


def main():
    import io
    import pprint

    # Initialize and populate our database.
    conn = sqlite3.connect(":memory:")
    cursor = conn.cursor()
    cursor.execute("CREATE TABLE memos(key INTEGER PRIMARY KEY, task TEXT)")
    tasks = (
        'give food to fish',
        'prepare group meeting',
        'fight with a zebra',
        )
    for task in tasks:
        cursor.execute("INSERT INTO memos VALUES(NULL, ?)", (task,))

    # Fetch the records to be pickled.
    cursor.execute("SELECT * FROM memos")
    memos = [MemoRecord(key, task) for key, task in cursor]
    # Save the records using our custom DBPickler.
    file = io.BytesIO()
    DBPickler(file).dump(memos)

    print("Pickled records:")
    pprint.pprint(memos)

    # Update a record, just for good measure.
    cursor.execute("UPDATE memos SET task='learn italian' WHERE key=1")

    # Load the records from the pickle data stream.
    file.seek(0)
    memos = DBUnpickler(file, conn).load()

    print("Unpickled records:")
    pprint.pprint(memos)


if __name__ == '__main__':
    main()
```

## 7、Dispatch 表

**如果想对某些类进行自定义封存，而又不想在类中增加用于封存的代码**，就可以创建带有特殊 dispatch 表的 pickler。

在 copyreg 模块的 copyreg.dispatch_table 中定义了全局 dispatch 表。因此，**可以使用 copyreg.dispatch_table 修改后的副本作为自有 dispatch 表**。

例如：

```python
f = io.BytesIO()
p = pickle.Pickler(f)
p.dispatch_table = copyreg.dispatch_table.copy()
p.dispatch_table[SomeClass] = reduce_SomeClass
```

**创建了一个带有自有 dispatch 表的 pickle.Pickler 实例，它可以对 SomeClass 类进行特殊处理**。另外，下列代码：

```python
class MyPickler(pickle.Pickler):
    dispatch_table = copyreg.dispatch_table.copy()
    dispatch_table[SomeClass] = reduce_SomeClass
f = io.BytesIO()
p = MyPickler(f)
```

完成了相同的操作，但所有 MyPickler 的实例都会共用同一份 dispatch 表。

使用 copyreg 模块实现的等效代码是：

```python
copyreg.pickle(SomeClass, reduce_SomeClass)
f = io.BytesIO()
p = pickle.Pickler(f)
```

## 8、处理有状态的对象

下面的示例展示了如何修改类在封存时的行为。

其中 TextReader 类打开了一个文本文件，每次调用其 readline() 方法则返回行号和该行的字符。 

在封存这个 TextReader 的实例时，除了 文件对象，其他属性都会被保存。当解封实例时，需要重新打开文件，然后从上次的位置开始继续读取。实现这些功能需要实现 `__setstate__()` 和 `__getstate__()` 方法。


```python
class TextReader:
    """Print and number lines in a text file."""

    def __init__(self, filename):
        self.filename = filename
        self.file = open(filename)
        self.lineno = 0

    def readline(self):
        self.lineno += 1
        line = self.file.readline()
        if not line:
            return None
        if line.endswith('\n'):
            line = line[:-1]
        return "%i: %s" % (self.lineno, line)

    def __getstate__(self):
        # Copy the object's state from self.__dict__ which contains
        # all our instance attributes. Always use the dict.copy()
        # method to avoid modifying the original state.
        state = self.__dict__.copy()
        # Remove the unpicklable entries.
        del state['file']
        return state

    def __setstate__(self, state):
        # Restore instance attributes (i.e., filename and lineno).
        self.__dict__.update(state)
        # Restore the previously opened file's state. To do so, we need to
        # reopen it and read from it until the line count is restored.
        file = open(self.filename)
        for _ in range(self.lineno):
            file.readline()
        # Finally, save the file.
        self.file = file
```

使用方法如下所示：

```sh
>>> reader = TextReader("hello.txt")
>>> reader.readline()
'1: Hello world!'
>>> reader.readline()
'2: I am line number two.'
>>> new_reader = pickle.loads(pickle.dumps(reader))
>>> new_reader.readline()
'3: Goodbye!'
```

## 9、类型，函数和其他对象的自定义归约

3.8 新版功能.

有时，dispatch_table 可能不够灵活。 特别是**当我们想要基于对象类型以外的其他规则来对封存进行定制，或是当我们想要对函数和类的封存进行定制的时候**。

对于那些情况，可能要**基于 Pickler 类进行子类化，并实现 reducer_override() 方法**。此方法可返回任意的归约元组 (参见 `__reduce__()`)。 它也可以选择返回 NotImplemented 来回退到传统行为。

如果同时定义了 dispatch_table 和 reducer_override()，则 reducer_override() 方法具有优先权。

注解：出于性能理由，可能不会为以下对象调用 reducer_override(): None, True, False, 以及 int, float, bytes, str, dict, set, frozenset, list 和 tuple 的具体实例。

以下是一个简单的例子，其中我们允许封存并重新构建一个给定的类:


```python
import io
import pickle

class MyClass:
    my_attribute = 1

class MyPickler(pickle.Pickler):
    def reducer_override(self, obj):
        """Custom reducer for MyClass."""
        if getattr(obj, "__name__", None) == "MyClass":
            return type, (obj.__name__, obj.__bases__,
                          {'my_attribute': obj.my_attribute})
        else:
            # For any other object, fallback to usual reduction
            return NotImplemented

f = io.BytesIO()
p = MyPickler(f)
p.dump(MyClass)

del MyClass

unpickled_class = pickle.loads(f.getvalue())

assert isinstance(unpickled_class, type)
assert unpickled_class.__name__ == "MyClass"
assert unpickled_class.my_attribute == 1
```

## 10、外部缓冲区

3.8 新版功能.

**在某些场景中，pickle 模块会被用来传输海量的数据**。因此，最小化内存复制次数以保证性能和节省资源是很重要的。 但是 pickle 模块的正常运作会将图类对象结构转换为字节序列流，因此在本质上就要从封存流中来回复制数据。

如果 provider (待传输对象类型的实现) 和 consumer (通信系统的实现) 都支持 pickle 第 5 版或更高版本所提供的外部传输功能，则此约束可以被撤销。

### 10.1、提供方 API

**大的待封存数据对象必须实现协议 5 及以上版本专属的 `__reduce_ex__()` 方法**，该方法将为任意大的数据返回一个 PickleBuffer 实例（而不是 bytes 对象等）。

PickleBuffer 对象会 表明 底层缓冲区可被用于外部数据传输。 那些对象仍将保持与 pickle 模块的正常用法兼容。 但是，使用方也可以选择告知 pickle 它们将自行处理那些缓冲区。

### 10.2、使用方 API

**当序列化一个对象图时，通信系统可以启用对所生成 PickleBuffer 对象的定制处理**。

发送端需要传递 buffer_callback 参数到 Pickler (或是到 dump() 或 dumps() 函数)，该回调函数将在封存对象图时附带每个所生成的 PickleBuffer 被调用。 由 buffer_callback 所累积的缓冲区的数据将不会被拷贝到 pickle 流，而是仅插入一个简单的标记。

接收端需要传递 buffers 参数到 Unpickler (或是到 load() 或 loads() 函数)，其值是一个由缓冲区组成的可迭代对象，它会被传递给 buffer_callback。 该可迭代对象应当按其被传递给 buffer_callback 时的顺序产生缓冲区。 这些缓冲区将提供对象重构造器所期望的数据，对这些数据的封存产生了原本的 PickleBuffer 对象。

在发送端和接受端之间，通信系统可以自由地实现它自己用于外部缓冲区的传输机制。潜在的优化包括使用共享内存或基于特定数据类型的压缩等。

### 10.3、示例

下面是一个小例子，我们实现了一个 [bytearray](https://docs.python.org/zh-cn/3.8/library/stdtypes.html#bytearray) 的子类，能够用于外部缓冲区封存:

```python
class ZeroCopyByteArray(bytearray):

    def __reduce_ex__(self, protocol):
        if protocol >= 5:
            return type(self)._reconstruct, (PickleBuffer(self),), None
        else:
            # PickleBuffer is forbidden with pickle protocols <= 4.
            return type(self)._reconstruct, (bytearray(self),)

    @classmethod
    def _reconstruct(cls, obj):
        with memoryview(obj) as m:
            # Get a handle over the original buffer object
            obj = m.obj
            if type(obj) is cls:
                # Original buffer object is a ZeroCopyByteArray, return it
                # as-is.
                return obj
            else:
                return cls(obj)
```

重构造器 (`_reconstruct` 类方法) 会在缓冲区的提供对象具有正确类型时返回该对象。 在此小示例中这是模拟零拷贝行为的便捷方式。

在使用方，我们可以按通常方式封存那些对象，它们在反序列化时将提供原始对象的一个副本:

```python
b = ZeroCopyByteArray(b"abc")
data = pickle.dumps(b, protocol=5)
new_b = pickle.loads(data)
print(b == new_b)  # True
print(b is new_b)  # False: a copy was made
```

但是如果我们传入 buffer_callback 然后在反序列化时给回累积的缓冲区，我们就能够取回原始对象:

```python
b = ZeroCopyByteArray(b"abc")
buffers = []
data = pickle.dumps(b, protocol=5, buffer_callback=buffers.append)
new_b = pickle.loads(data, buffers=buffers)
print(b == new_b)  # True
print(b is new_b)  # True: no copy was made
```

这个例子受限于 bytearray 会自行分配内存这一事实：你无法基于另一个对象的内存创建 bytearray 的实例。 但是，第三方数据类型例如 NumPy 数组则没有这种限制，允许在单独进程或系统间传输时使用零拷贝的封存（或是尽可能少地拷贝） 。

参见：[PEP 574](https://www.python.org/dev/peps/pep-0574) -- 带有外部数据缓冲区的 pickle 协议 5

## 11、限制全局变量

默认情况下，解封将会导入在 pickle 数据中找到的任何类或函数。 

对于许多应用来说，此行为是不可接受的，因为它会允许解封器导入并发起调用任意代码。只须考虑当这个手工构建的 pickle 数据流被加载时会做什么:

```sh
>>> import pickle
>>> pickle.loads(b"cos\nsystem\n(S'echo hello world'\ntR.")
hello world
0
```

在这个例子里，解封器导入 `os.system()` 函数，然后应用字符串参数 "echo hello world"。 虽然这个例子不具攻击性，但是不难想象别人能够通过此方式对你的系统造成损害。

出于这样的理由，你可能会希望通过定制 `Unpickler.find_class()` 来控制要解封的对象。与其名称所提示的不同，`Unpickler.find_class()`会在执行对任何全局对象（例如一个类或一个函数）的请求时被调用。因此可以完全禁止全局对象或是将它们限制在一个安全的子集中。

下面的例子是一个解封器，它只允许某一些安全的来自 builtins 模块的类被加载:

```python
import builtins
import io
import pickle

safe_builtins = {
    'range',
    'complex',
    'set',
    'frozenset',
    'slice',
}

class RestrictedUnpickler(pickle.Unpickler):

    def find_class(self, module, name):
        # Only allow safe classes from builtins.
        if module == "builtins" and name in safe_builtins:
            return getattr(builtins, name)
        # Forbid everything else.
        raise pickle.UnpicklingError("global '%s.%s' is forbidden" %
                                     (module, name))

def restricted_loads(s):
    """Helper function analogous to pickle.loads()."""
    return RestrictedUnpickler(io.BytesIO(s)).load()
```

我们这个解封器的一个示例用法所达成的目标:

```sh
>>> restricted_loads(pickle.dumps([1, 2, range(15)]))
[1, 2, range(0, 15)]
>>> restricted_loads(b"cos\nsystem\n(S'echo hello world'\ntR.")
Traceback (most recent call last):
  ...
pickle.UnpicklingError: global 'os.system' is forbidden
>>> restricted_loads(b'cbuiltins\neval\n'
...                  b'(S\'getattr(__import__("os"), "system")'
...                  b'("echo hello world")\'\ntR.')
Traceback (most recent call last):
  ...
pickle.UnpicklingError: global 'builtins.eval' is forbidden
```

正如我们这个例子所显示的，对于允许解封的对象你必须要保持谨慎。 因此如果要保证安全，你可以考虑其他选择，例如 [xmlrpc.client](https://docs.python.org/zh-cn/3.8/library/xmlrpc.client.html#module-xmlrpc.client) 中的编组 API 或是第三方解决方案。

## 12、性能

较新版本的 pickle 协议（第 2 版或更高）具有针对某些常见特性和内置类型的高效二进制编码格式。 此外，pickle 模块还拥有一个以 C 编写的透明优化器。

## 13、例子

对于最简单的代码，请使用 dump() 和 load() 函数。

```python
import pickle

# An arbitrary collection of objects supported by pickle.
data = {
    'a': [1, 2.0, 3, 4+6j],
    'b': ("character string", b"byte string"),
    'c': {None, True, False}
}

with open('data.pickle', 'wb') as f:
    # Pickle the 'data' dictionary using the highest protocol available.
    pickle.dump(data, f, pickle.HIGHEST_PROTOCOL)
```

以下示例读取之前封存的数据。

```python
import pickle

with open('data.pickle', 'rb') as f:
    # The protocol version used is detected automatically, so we do not
    # have to specify it.
    data = pickle.load(f)
```


------------------------------------------------

[英文官方文档](https://docs.python.org/3.8/library/pickle.html)

[中文官方文档](https://docs.python.org/zh-cn/3.8/library/pickle.htm)