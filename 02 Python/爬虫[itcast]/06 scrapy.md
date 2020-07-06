# scrapy

Scrapy是用纯Python实现一个为了爬取网站数据、提取结构性数据而编写的应用框架。

安装：pip install Scrapy

官方文档：https://docs.scrapy.org/en/latest/

中文文档：https://docs.pythontab.com/scrapy/scrapy0.24/
         http://scrapy-chs.readthedocs.io/zh_CN/latest/index.html

## 1 架构图

![scrapy01](https://s1.ax1x.com/2020/06/14/NS4hcT.png)


Scrapy Engine(引擎): 负责Spider、ItemPipeline、Downloader、Scheduler中间的通讯，信号、数据传递等。

Scheduler(调度器): 它负责接受引擎发送过来的Request请求，并按照一定的方式进行整理排列，入队，当引擎需要时，交还给引擎。

Downloader（下载器）：负责下载Scrapy Engine(引擎)发送的所有Requests请求，并将其获取到的Responses交还给Scrapy Engine(引擎)，由引擎交给Spider来处理，

Spider（爬虫）：它负责处理所有Responses,从中分析提取数据，获取Item字段需要的数据，并将需要跟进的URL提交给引擎，再次进入Scheduler(调度器)，

Item Pipeline(管道)：它负责处理Spider中获取到的Item，并进行进行后期处理（详细分析、过滤、存储等）的地方.

Downloader Middlewares（下载中间件）：你可以当作是一个可以自定义扩展下载功能的组件。

Spider Middlewares（Spider中间件）：你可以理解为是一个可以自定扩展和操作引擎和Spider中间通信的功能组件（比如进入Spider的Responses;和从Spider出去的Requests）

## 2 思路

制作 Scrapy 爬虫 一共需要4步：

    新建项目 (scrapy startproject xxx)：新建一个新的爬虫项目
    明确目标 （编写items.py）：明确你想要抓取的目标
    制作爬虫 （spiders/xxspider.py）：制作爬虫开始爬取网页
    存储内容 （pipelines.py）：设计管道存储爬取内容

## 3 应用案例

### 新建项目(scrapy startproject)

在开始爬取之前，选择一个目录，运行下列命令，创建一个新的Scrapy项目。

    scrapy startproject spider_scrapy01

其中， spider_scrapy01 为项目名称，可以看到将会创建一个 spider_scrapy01 文件夹，目录结构大致如下：

![scrapy02](https://s1.ax1x.com/2020/06/14/NS5i4I.png)


各个主要文件的作用：

    scrapy.cfg ：项目的配置文件

    spider_scrapy01/ ：项目的Python模块，将会从这里引用代码

    spider_scrapy01/items.py ：项目的目标文件

    spider_scrapy01/pipelines.py ：项目的管道文件

    spider_scrapy01/settings.py ：项目的设置文件

    spider_scrapy01/spiders/ ：存储爬虫代码目录

### 明确目标(spider_scrapy01/items.py)

抓取：http://www.itcast.cn/channel/teacher.shtml 网站里的所有讲师的姓名、职称和个人信息。

打开spider_scrapy01目录下的items.py

Item 定义结构化数据字段，用来保存爬取到的数据，有点像Python中的dict，但是提供了一些额外的保护减少错误。

可以通过继承一个 scrapy.Item 类， 并且定义类型为 scrapy.Field的类属性来定义一个Item子类（可以理解成类似于ORM的映射关系）。

接下来，创建一个SpiderScrapy01Item 类，和构建item模型（model）。
```python 
import scrapy

class SpiderScrapy01Item(scrapy.Item):
# define the fields for your item here like:
# name = scrapy.Field()
name = scrapy.Field()
title = scrapy.Field()
info = scrapy.Field()
```

### 制作爬虫 （spiders/itcast.py）

爬虫功能要分两步：爬数据、解析数据

在当前目录下输入命令，执行如下命令，将在mySpider/spider目录下创建一个名为itcast的爬虫，并指定爬取域的范围：
```python
scrapy genspider itcast "itcast.cn"
```

打开 spider_scrapy01/spider目录里的 itcast.py，默认增加了下列代码:

```python
import scrapy
from spider_scrapy01 import items

class ItcastSpider(scrapy.Spider):
    name = 'itcast'
    allowed_domains = ['itcast.cn']
    start_urls = ['http://www.itcast.cn/channel/teacher.shtml']

    def parse(self, response):

        teacher_list = response.xpath('//div[@class="li_txt"]')
        # 所有老师信息的列表集合
        teacherItem = []

        for each in teacher_list:
            # Item对象用来保存数据的
            item = items.SpiderScrapy01Item()
            # name, extract() 将匹配出来的结果转换为Unicode字符串
            # 不加extract() 结果为xpath匹配对象
            name = each.xpath('./h3/text()').extract()
            # title
            title = each.xpath('./h4/text()').extract()
            # info
            info = each.xpath('./p/text()').extract()

            # print(name[0])
            # print(title[0])
            # print(info[0])

            item['name'] = name[0]
            item['title'] = title[0]
            item['info'] = info[0]

            teacherItem.append(item)

            #将获取的数据交给pipelines
            #yield item

        return teacherItem
```

###  保存数据

scrapy保存信息的最简单的方法主要有四种，-o 输出指定格式的文件，，命令如下：
```python
# json格式，默认为Unicode编码
scrapy crawl itcast -o teachers.json

# 也可以保存为其他格式

# csv 逗号表达式，可用Excel打开
scrapy crawl itcast -o teachers.csv

# xml格式
scrapy crawl itcast -o teachers.xml
```

### 查看结果

执行完后，会出现 teachers.json 文件，打开后，在json.cn 打开如下所示：
```
    [
    {
        "name":"王老师",
        "title":"高级讲师",
        "info":"毕业于中国科学院大学，硕士学位，有国外留学经历。拥有多年的产品从业经验，从事行业包括"互联网金融"、"互联网教育"、"电商"等领域。有产品运营、数据分析、销售管理等工作经验，对于产品设计、体验、交互、项目管理等有很强的理解。善于引导学生思考，激发学习兴趣。"
    },
    {
        "name":"孙老师",
        "title":"高级讲师",
        "info":"互联网高级产品管理师、PMP资格认证，近10年的互联网产品和团队管理工作经历，曾担任工信部及大型电商产品负责人，大学生创新创业大赛评委，对产品的设计、交互、数据分析、用户增长等拥有资深造诣和分享经验，对教育、电商、金融等行业领域有深刻研究。"
    },
    ......
```
### pycharm下配置启动文件

![scrapy03](https://s1.ax1x.com/2020/06/14/NSTr2q.png)

![scrapy04](https://s1.ax1x.com/2020/06/14/NSTDGn.png)


最后启动start.py即可。

## 4  Item Pipeline组件

当Item在Spider中被收集之后，它将会被传递到Item Pipeline，这些Item Pipeline组件按定义的顺序处理Item。

每个Item Pipeline都是实现了简单方法的Python类，比如决定此Item是丢弃而存储。以下是item pipeline的一些典型应用：

    验证爬取的数据(检查item包含某些字段，比如说name字段)
    查重(并丢弃)
    将爬取结果保存到文件或者数据库中

item写入JSON文件

以下pipeline将所有(从所有'spider'中)爬取到的item，存储到一个独立地items.json 文件，每行包含一个序列化为'JSON'格式的'item':

```python
import json

# pipeline将所有(从所有'spider'中)爬取到的item，存储到一个独立地items.json 文件，
# 每行包含一个序列化为'JSON'格式的'item':
class ItcastjsonPipelins(object):

    def __init__(self):
        self.file = open('teachers.json','wb')

    def process_item(self,item,spider):
        content = json.dumps(dict(item),ensure_ascii=False) +"\n"
        self.file.write(content.encode("utf-8"))
        return item

    def close_spider(self,spider):
        self.file.close()
```

启用一个Item Pipeline组件

为了启用Item Pipeline组件，必须将它的类添加到 settings.py文件ITEM_PIPELINES 配置，就像下面这个例子:
```python
# Configure item pipelines
# See http://scrapy.readthedocs.org/en/latest/topics/item-pipeline.html
ITEM_PIPELINES = {
	#'mySpider.pipelines.SomePipeline': 300,
	"mySpider.pipelines.ItcastJsonPipeline":300
}
```

分配给每个类的整型值，确定了他们运行的顺序，item按数字从低到高的顺序，通过pipeline，通常将这些数字定义在0-1000范围内（0-1000随意设置，数值越低，组件的优先级越高）

重新启动爬虫,查看当前目录是否生成teacher.json
