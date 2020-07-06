# 模拟登录

注意：模拟登陆时，必须保证 **settings.py里的 COOKIES_ENABLED (Cookies中间件) 处于开启状态**
COOKIES_ENABLED = True 或 # COOKIES_ENABLED = False

## 策略一：直接POST数据（比如需要登陆的账户信息)

只要是需要提供post数据的，就可以用这种方法。下面示例里post的数据是账户密码：
```python
import scrapy

class Renren1Spider(scrapy.Spider):
    name = "renren1"
    allowed_domains = ["renren.com"]

    def start_requests(self):
        url = 'http://www.renren.com/PLogin.do'
        # FormRequest 是Scrapy发送POST请求的方法
        yield scrapy.FormRequest(
                url = url,
                formdata = {"email" : "mr_mao_hacker@163.com", "password" : "axxxxxxxe"},
                callback = self.parse_page)

    def parse_page(self, response):
        with open("mao2.html", "w") as filename:
            filename.write(response.body)
```

## 策略二：标准的模拟登陆步骤

正统模拟登录方法：

首先发送登录页面的get请求，获取到页面里的登录必须的参数（比如说zhihu登陆界面的 xsrf）

然后和账户密码一起post到服务器，登录成功

```python
import scrapy

class Renren2Spider(scrapy.Spider):
    name = "renren2"
    allowed_domains = ["renren.com"]
    start_urls = (
        "http://www.renren.com/PLogin.do",
    )

    # 处理start_urls里的登录url的响应内容，提取登陆需要的参数（如果需要的话)
    def parse(self, response):
        # 提取登陆需要的参数
        #_xsrf = response.xpath("//_xsrf").extract()[0]

        # 发送请求参数，并调用指定回调函数处理
        yield scrapy.FormRequest.from_response(
                response,
                formdata = {"email" : "mr_mao_hacker@163.com", "password" : "axxxxxxxe"},#, "_xsrf" = _xsrf},
                callback = self.parse_page
            )

    # 获取登录成功状态，访问需要登录后才能访问的页面
    def parse_page(self, response):
        url = "http://www.renren.com/422167102/profile"
        yield scrapy.Request(url, callback = self.parse_newpage)

    # 处理响应内容
    def parse_newpage(self, response):
        with open("xiao.html", "w") as filename:
            filename.write(response.body)
```

## 策略三：直接使用保存登陆状态的Cookie模拟登陆

如果实在没办法了，可以用这种方法模拟登录，虽然麻烦一点，但是成功率100%

```python
import scrapy

class RenrenSpider(scrapy.Spider):
    name = "renren"
    allowed_domains = ["renren.com"]
    start_urls = (
        'http://www.renren.com/111111',
        'http://www.renren.com/222222',
        'http://www.renren.com/333333',
    )

    cookies = {
    "anonymid" : "ixrna3fysufnwv",
    "_r01_" : "1",
    "ap" : "327550029",
    "JSESSIONID" : "abciwg61A_RvtaRS3GjOv",
    "depovince" : "GW",
    "springskin" : "set",
    "jebe_key" : "f6fb270b-d06d-42e6-8b53-e67c3156aa7e%7Cc13c37f53bca9e1e7132d4b58ce00fa3%7C1484060607478%7C1%7C1486198628950",
    "t" : "691808127750a83d33704a565d8340ae9",
    "societyguester" : "691808127750a83d33704a565d8340ae9",
    "id" : "327550029",
    "xnsid" : "f42b25cf",
    "loginfrom" : "syshome"
    }

    # 可以重写Spider类的start_requests方法，附带Cookie值，发送POST请求
    def start_requests(self):
        for url in self.start_urls:
            yield scrapy.FormRequest(url, cookies = self.cookies, callback = self.parse_page)

    # 处理响应内容
    def parse_page(self, response):
        print "===========" + response.url
        with open("deng.html", "w") as filename:
            filename.write(response.body)
```
