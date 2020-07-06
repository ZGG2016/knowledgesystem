# scrapy shell

Scrapy终端是一个交互终端，我们可以在未启动spider的情况下尝试及调试代码，也可以用来测试XPath或CSS表达式，查看他们的工作方式，方便我们爬取的网页中提取的数据。

如果安装了 IPython ，Scrapy终端将使用 IPython (替代标准Python终端)。 IPython 终端与其他相比更为强大，提供智能的自动补全，高亮输出，及其他特性。（推荐安装IPython）

##### 启动Scrapy Shell

进入项目的根目录，执行下列命令来启动shell:
```python
scrapy shell "http://www.itcast.cn/channel/teacher.shtml"
```

![Scrapy06](https://s1.ax1x.com/2020/06/15/NCLpRg.jpg)

Scrapy Shell根据下载的页面会自动创建一些方便使用的对象，例如 Response 对象，以及 Selector 对象 (对HTML及XML内容)。

当shell载入后，将得到一个包含response数据的本地 response 变量，输入 response.body将输出response的包体，输出 response.headers 可以看到response的包头。

输入 response.selector 时， 将获取到一个response 初始化的类 Selector 的对象，此时可以通过使用 response.selector.xpath()或response.selector.css() 来对 response 进行查询。

Scrapy也提供了一些快捷方式, 例如 response.xpath()或response.css()同样可以生效（如之前的案例）。

##### Selectors选择器

Scrapy Selectors 内置 XPath 和 CSS Selector 表达式机制

Selector有四个基本的方法，最常用的还是xpath:

    xpath(): 传入xpath表达式，返回该表达式所对应的所有节点的selector list列表
    extract(): 序列化该节点为Unicode字符串并返回list
    css(): 传入CSS表达式，返回该表达式所对应的所有节点的selector list列表，语法同 BeautifulSoup4
    re(): 根据传入的正则表达式对数据进行提取，返回Unicode字符串list列表

XPath表达式的例子及对应的含义:

    /html/head/title: 选择<HTML>文档中 <head> 标签内的 <title> 元素
    /html/head/title/text(): 选择上面提到的 <title> 元素的文字
    //td: 选择所有的 <td> 元素
    //div[@class="mine"]: 选择所有具有 class="mine" 属性的 div 元素

##### 尝试Selector

我们用腾讯社招的网站http://hr.tencent.com/position.php?&start=0#a举例：

    # 启动
    scrapy shell "http://hr.tencent.com/position.php?&start=0#a"

    # 返回 xpath选择器对象列表
    response.xpath('//title')
    [<Selector xpath='//title' data=u'<title>\u804c\u4f4d\u641c\u7d22 | \u793e\u4f1a\u62db\u8058 | Tencent \u817e\u8baf\u62db\u8058</title'>]

    # 使用 extract()方法返回 Unicode字符串列表
    response.xpath('//title').extract()
    [u'<title>\u804c\u4f4d\u641c\u7d22 | \u793e\u4f1a\u62db\u8058 | Tencent \u817e\u8baf\u62db\u8058</title>']

    # 打印列表第一个元素，终端编码格式显示
    print response.xpath('//title').extract()[0]
    <title>职位搜索 | 社会招聘 | Tencent 腾讯招聘</title>

    # 返回 xpath选择器对象列表
    response.xpath('//title/text()')
    <Selector xpath='//title/text()' data=u'\u804c\u4f4d\u641c\u7d22 | \u793e\u4f1a\u62db\u8058 | Tencent \u817e\u8baf\u62db\u8058'>

    # 返回列表第一个元素的Unicode字符串
    response.xpath('//title/text()')[0].extract()
    u'\u804c\u4f4d\u641c\u7d22 | \u793e\u4f1a\u62db\u8058 | Tencent \u817e\u8baf\u62db\u8058'

    # 按终端编码格式显示
    print response.xpath('//title/text()')[0].extract()
    职位搜索 | 社会招聘 | Tencent 腾讯招聘

    response.xpath('//*[@class="even"]')
    职位名称:

    print site[0].xpath('./td[1]/a/text()').extract()[0]
    TEG15-运营开发工程师（深圳）
    职位名称详情页:

    print site[0].xpath('./td[1]/a/@href').extract()[0]
    position_detail.php?id=20744&keywords=&tid=0&lid=0
    职位类别:

    print site[0].xpath('./td[2]/text()').extract()[0]
    技术类
