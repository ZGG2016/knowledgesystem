# Request Response

## Request

Request 部分源码：
```python
class Request(object_ref):

    def __init__(self, url, callback=None, method='GET', headers=None, body=None,
                 cookies=None, meta=None, encoding='utf-8', priority=0,
                 dont_filter=False, errback=None):

        self._encoding = encoding  # this one has to be set first
        self.method = str(method).upper()
        self._set_url(url)
        self._set_body(body)
        assert isinstance(priority, int), "Request priority not an integer: %r" % priority
        self.priority = priority

        assert callback or not errback, "Cannot use errback without a callback"
        self.callback = callback
        self.errback = errback

        self.cookies = cookies or {}
        self.headers = Headers(headers or {}, encoding=encoding)
        self.dont_filter = dont_filter

        self._meta = dict(meta) if meta else None

    @property
    def meta(self):
        if self._meta is None:
            self._meta = {}
        return self._meta
```
其中，比较常用的参数：

    url: 就是需要请求，并进行下一步处理的url

    callback: 指定该请求返回的Response，由那个函数来处理。

    method: 请求一般不需要指定，默认GET方法，可设置为"GET", "POST", "PUT"等，且保证字符串大写

    headers: 请求时，包含的头文件。一般不需要。内容一般如下：
            # 自己写过爬虫的肯定知道
            Host: media.readthedocs.org
            User-Agent: Mozilla/5.0 (Windows NT 6.2; WOW64; rv:33.0) Gecko/20100101 Firefox/33.0
            Accept: text/css,*/*;q=0.1
            Accept-Language: zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3
            Accept-Encoding: gzip, deflate
            Referer: http://scrapy-chs.readthedocs.org/zh_CN/0.24/
            Cookie: ga=GA1.2.1612165614.1415584110;
            Connection: keep-alive
            If-Modified-Since: Mon, 25 Aug 2014 21:59:35 GMT
            Cache-Control: max-age=0

    meta: 比较常用，在不同的请求之间传递数据使用的。字典dict型

            request_with_cookies = Request(
                url="http://www.example.com",
                cookies={'currency': 'USD', 'country': 'UY'},
                meta={'dont_merge_cookies': True}
            )

    encoding: 使用默认的 'utf-8' 就行。

    dont_filter: 表明该请求不由调度器过滤。这是当你想使用多次执行相同的请求,忽略重复的过滤器。默认为False。

    errback: 指定错误处理函数

## Response
```python
class Response(object_ref):
    def __init__(self, url, status=200, headers=None, body='', flags=None, request=None):
        self.headers = Headers(headers or {})
        self.status = int(status)
        self._set_body(body)
        self._set_url(url)
        self.request = request
        self.flags = [] if flags is None else list(flags)

    @property
    def meta(self):
        try:
            return self.request.meta
        except AttributeError:
            raise AttributeError("Response.meta not available, this response " \
                "is not tied to any request")
```
参数：
```
status: 响应码
_set_body(body)： 响应体
_set_url(url)：响应url
self.request = request
```

## 发送POST请求

可以使用 **yield scrapy.FormRequest(url, formdata, callback)**方法发送POST请求。

**如果希望程序执行一开始就发送POST请求，可以重写Spider类的start_requests(self) 方法，并且不再调用start_urls里的url。**
```python
class mySpider(scrapy.Spider):
    # start_urls = ["http://www.example.com/"]

    def start_requests(self):
        url = 'http://www.renren.com/PLogin.do'

        # FormRequest 是Scrapy发送POST请求的方法
        yield scrapy.FormRequest(
            url = url,
            formdata = {"email" : "mr_mao_hacker@163.com", "password" : "axxxxxxxe"},
            callback = self.parse_page
        )
    def parse_page(self, response):
        # do something
```

## 模拟登陆

使用FormRequest.from_response()方法模拟用户登录

通常网站通过 实现对某些表单字段（如数据或是登录界面中的认证令牌等）的预填充。

使用Scrapy抓取网页时，如果想要预填充或重写像用户名、用户密码这些表单字段， 可以使用 FormRequest.from_response() 方法实现。

下面是使用这种方法的爬虫例子:
```python
import scrapy

class LoginSpider(scrapy.Spider):
    name = 'example.com'
    start_urls = ['http://www.example.com/users/login.php']

    def parse(self, response):
        return scrapy.FormRequest.from_response(
            response,
            formdata={'username': 'john', 'password': 'secret'},
            callback=self.after_login
        )

    def after_login(self, response):
        # check login succeed before going on
        if "authentication failed" in response.body:
            self.log("Login failed", level=log.ERROR)
            return

        # continue scraping with authenticated session...
```

## 知乎爬虫案例参考：

zhihuSpider.py爬虫代码

```python
#!/usr/bin/env python
# -*- coding:utf-8 -*-
from scrapy.spiders import CrawlSpider, Rule
from scrapy.selector import Selector
from scrapy.linkextractors import LinkExtractor
from scrapy import Request, FormRequest
from zhihu.items import ZhihuItem

class ZhihuSipder(CrawlSpider) :
    name = "zhihu"
    allowed_domains = ["www.zhihu.com"]
    start_urls = [
        "http://www.zhihu.com"
    ]
    rules = (
        Rule(LinkExtractor(allow = ('/question/\d+#.*?', )), callback = 'parse_page', follow = True),
        Rule(LinkExtractor(allow = ('/question/\d+', )), callback = 'parse_page', follow = True),
    )

    headers = {
    "Accept": "*/*",
    "Accept-Encoding": "gzip,deflate",
    "Accept-Language": "en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4",
    "Connection": "keep-alive",
    "Content-Type":" application/x-www-form-urlencoded; charset=UTF-8",
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36",
    "Referer": "http://www.zhihu.com/"
    }

    #重写了爬虫类的方法, 实现了自定义请求, 运行成功后会调用callback回调函数
    def start_requests(self):
        return [Request("https://www.zhihu.com/login", meta = {'cookiejar' : 1}, callback = self.post_login)]

    def post_login(self, response):
        print 'Preparing login'
        #下面这句话用于抓取请求网页后返回网页中的_xsrf字段的文字, 用于成功提交表单
        xsrf = Selector(response).xpath('//input[@name="_xsrf"]/@value').extract()[0]
        print xsrf
        #FormRequeset.from_response是Scrapy提供的一个函数, 用于post表单
        #登陆成功后, 会调用after_login回调函数
        return [FormRequest.from_response(response,   #"http://www.zhihu.com/login",
                            meta = {'cookiejar' : response.meta['cookiejar']},
                            headers = self.headers,  #注意此处的headers
                            formdata = {
                            '_xsrf': xsrf,
                            'email': '1095511864@qq.com',
                            'password': '123456'
                            },
                            callback = self.after_login,
                            dont_filter = True
                            )]

    def after_login(self, response) :
        for url in self.start_urls :
            yield self.make_requests_from_url(url)

    def parse_page(self, response):
        problem = Selector(response)
        item = ZhihuItem()
        item['url'] = response.url
        item['name'] = problem.xpath('//span[@class="name"]/text()').extract()
        print item['name']
        item['title'] = problem.xpath('//h2[@class="zm-item-title zm-editable-content"]/text()').extract()
        item['description'] = problem.xpath('//div[@class="zm-editable-content"]/text()').extract()
        item['answer']= problem.xpath('//div[@class=" zm-editable-content clearfix"]/text()').extract()
        return item
```
Item类设置
```python
from scrapy.item import Item, Field

class ZhihuItem(Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    url = Field()  #保存抓取问题的url
    title = Field()  #抓取问题的标题
    description = Field()  #抓取问题的描述
    answer = Field()  #抓取问题的答案
    name = Field()  #个人用户的名称
```

setting.py 设置抓取间隔
```python
BOT_NAME = 'zhihu'

SPIDER_MODULES = ['zhihu.spiders']
NEWSPIDER_MODULE = 'zhihu.spiders'
DOWNLOAD_DELAY = 0.25   #设置下载间隔为250ms
```
