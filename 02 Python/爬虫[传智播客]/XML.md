# XML

## 1 XML 和 HTML 的区别

数据格式|描述|设计目标
---|:--:|---:
XML|Extensible Markup Language （可扩展标记语言）|被设计为传输和存储数据，其焦点是数据的内容。
HTML|HyperText Markup Language （超文本标记语言）|显示数据以及如何更好显示数据。
HTML DOM|Document Object Model for HTML (文档对象模型)|通过 HTML DOM，可以访问所有的 HTML 元素，连同它们所包含的文本和属性。可以对其中的内容进行修改和删除，同时也可以创建新的元素。

## 2 XML文档示例

  <?xml version="1.0" encoding="utf-8"?>

  <bookstore>

    <book category="cooking">
      <title lang="en">Everyday Italian</title>  
      <author>Giada De Laurentiis</author>  
      <year>2005</year>  
      <price>30.00</price>
    </book>  

    <book category="children">
      <title lang="en">Harry Potter</title>  
      <author>J K. Rowling</author>  
      <year>2005</year>  
      <price>29.99</price>
    </book>  

    <book category="web">
      <title lang="en">XQuery Kick Start</title>  
      <author>James McGovern</author>  
      <author>Per Bothner</author>  
      <author>Kurt Cagle</author>  
      <author>James Linn</author>  
      <author>Vaidyanathan Nagarajan</author>  
      <year>2003</year>  
      <price>49.99</price>
    </book>

    <book category="web" cover="paperback">
      <title lang="en">Learning XML</title>  
      <author>Erik T. Ray</author>  
      <year>2003</year>  
      <price>39.95</price>
    </book>

  </bookstore>

## 3 HTML DOM 模型示例

HTML DOM 定义了访问和操作 HTML 文档的标准方法，以树结构方式表达 HTML 文档。

![XML01](https://s1.ax1x.com/2020/06/08/thktI0.gif)

## 4 XML的节点关系

    父（Parent）
    子（Children）
    同胞（Sibling）
    先辈（Ancestor）
    后代（Descendant）

## 5 XPath

XPath (XML Path Language) 是一门在 XML 文档中查找信息的语言，可用来在 XML 文档中对元素和属性进行遍历。

    XPath 开发工具：
    开源的XPath表达式编辑工具:XMLQuire(XML格式文件可用)
    Chrome插件 XPath Helper
    Firefox插件 XPath Checker

### 选取节点

XPath 使用路径表达式来选取 XML 文档中的节点或者节点集。这些路径表达式和我们在常规的电脑文件系统中看到的表达式非常相似。

下面列出了最常用的路径表达式：

表达式|描述
---|:--:
nodename|选取此节点的所有子节点。
/|从根节点选取。
//|从匹配选择的当前节点选择文档中的节点，而不考虑它们的位置。
.|选取当前节点。
..|选取当前节点的父节点。
@|选取属性。

在下面的表格中，我们已列出了一些路径表达式以及表达式的结果：

路径表达式|结果
---|:--:
bookstore|选取 bookstore 元素的所有子节点。
/bookstore|选取根元素 bookstore。注释：假如路径起始于正斜杠( / )，则此路径始终代表到某元素的绝对路径！
bookstore/book|选取属于 bookstore 的子元素的所有 book 元素。
//book|选取所有 book 子元素，而不管它们在文档中的位置。
bookstore//book|选择属于 bookstore 元素的后代的所有 book 元素，而不管它们位于 bookstore 之下的什么位置。
//@lang|选取名为 lang 的所有属性。

### 谓语（Predicates）

谓语用来查找某个特定的节点或者包含某个指定的值的节点，被嵌在方括号中。

在下面的表格中，我们列出了带有谓语的一些路径表达式，以及表达式的结果：

路径表达式|结果
---|:--:
/bookstore/book[1]|取属于 bookstore 子元素的第一个 book 元素。
/bookstore/book[last()]|选取属于 bookstore 子元素的最后一个 book 元素。
/bookstore/book[last()-1]|选取属于 bookstore 子元素的倒数第二个 book 元素。
/bookstore/book[position()<3]|选取最前面的两个属于 bookstore|元素的子元素的 book 元素。
//title[@lang]|选取所有拥有名为 lang 的属性的 title 元素。
//title[@lang=’eng’]|选取所有 title 元素，且这些元素拥有值为 eng 的 lang 属性。
/bookstore/book[price>35.00]|选取 bookstore 元素的所有 book 元素，且其中的 price 元素的值须大于 35.00。
/bookstore/book[price>35.00]/title|选取 bookstore 元素中的 book 元素的所有 title 元素，且其中的 price 元素的值须大于 35.00。

### 选取未知节点

XPath 通配符可用来选取未知的 XML 元素。

通配符|描述
---|:--:
*符|匹配任何元素节点。
@*符|匹配任何属性节点。
node()符|匹配任何类型的节点。

在下面的表格中，我们列出了一些路径表达式，以及这些表达式的结果：

路径表达式|结果
---|:--:
/bookstore/*|选取 bookstore 元素的所有子元素。
//*|选取文档中的所有元素。
//title[@*]|选取所有带有属性的 title 元素。

### 选取若干路径

通过在路径表达式中使用“|”运算符，您可以选取若干个路径。

在下面的表格中，我们列出了一些路径表达式，以及这些表达式的结果：

路径表达式|结果
---|:--:
//book/title | //book/price	选取 book 元素的所有 title 和 price 元素。
//title | //price	选取文档中的所有 title 和 price 元素。
/bookstore/book/title | //price	选取属于 bookstore 元素的 book 元素的所有 title 元素，以及文档中所有的 price 元素。

### XPath的运算符

下面列出了可用在 XPath 表达式中的运算符：

![xml02](https://s1.ax1x.com/2020/06/08/thE0b9.png)

这些就是XPath的语法内容，在运用到Python抓取时要先转换为xml。
