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

