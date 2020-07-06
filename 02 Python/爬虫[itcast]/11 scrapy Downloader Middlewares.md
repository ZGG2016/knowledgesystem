# Downloader Middlewares

通常防止爬虫被反主要有以下几个策略：

- 动态设置User-Agent（随机切换User-Agent，模拟不同用户的浏览器信息）

- 禁用Cookies（也就是不启用cookies middleware，不向Server发送cookies，有些网站通过cookie的使用发现爬虫行为）
  可以通过COOKIES_ENABLED 控制 CookiesMiddleware 开启或关闭

- 设置延迟下载（防止访问过于频繁，设置为 2秒 或更高） DOWNLOAD_DELAY = 3

- Google Cache 和 Baidu Cache：如果可能的话，使用谷歌/百度等搜索引擎服务器页面缓存获取页面数据。

- 使用IP地址池：VPN和代理IP，现在大部分网站都是根据IP来ban的。

- 使用 Crawlera（专用于爬虫的代理组件）:正确配置和设置下载中间件后，项目所有的request都是通过crawlera发出。
```python
  DOWNLOADER_MIDDLEWARES = {
      'scrapy_crawlera.CrawleraMiddleware': 600
  }

  CRAWLERA_ENABLED = True
  CRAWLERA_USER = '注册/购买的UserKey'
  CRAWLERA_PASS = '注册/购买的Password'
```
## 1 设置下载中间件（Downloader Middlewares）

下载中间件是处于引擎(crawler.engine)和下载器(crawler.engine.download())之间的一层组件，可以有多个下载中间件被加载运行。

    当引擎传递请求给下载器的过程中，下载中间件可以对请求进行处理 （例如增加http header信息，增加proxy信息等）；

    在下载器完成http请求，传递响应给引擎的过程中， 下载中间件可以对响应进行处理（例如进行gzip的解压等）

要激活下载器中间件组件，**将其加入到 DOWNLOADER_MIDDLEWARES 设置中**。 该设置是一个字典(dict)，键为中间件类的路径，值为其中间件的顺序(order)。

这里是一个例子:
```python
DOWNLOADER_MIDDLEWARES = {
    'mySpider.middlewares.MyDownloaderMiddleware': 543,
}
```

编写下载器中间件十分简单。每个中间件组件是一个定义了以下一个或多个方法的Python类:
```python
class scrapy.contrib.downloadermiddleware.DownloaderMiddleware
```

##### process_request(self, request, spider)
当每个request通过下载中间件时，该方法被调用。

process_request() 必须返回以下其中之一：一个 None 、一个 Response 对象、一个 Request 对象或 raise IgnoreRequest:

- 如果其返回 None ，Scrapy将继续处理该request，执行其他的中间件的相应方法，直到合适的下载器处理函数(download handler)被调用， 该request被执行(其response被下载)。

- 如果其返回 Response 对象，Scrapy将不会调用 任何 其他的 process_request() 或 process_exception() 方法，或相应地下载函数； 其将返回该response。 已安装的中间件的 process_response() 方法则会在每个response返回时被调用。

- 如果其返回 Request 对象，Scrapy则停止调用 process_request方法并重新调度返回的request。当新返回的request被执行后， 相应地中间件链将会根据下载的response被调用。

- 如果其raise一个 IgnoreRequest 异常，则安装的下载中间件的 process_exception() 方法会被调用。如果没有任何一个方法处理该异常， 则request的errback(Request.errback)方法会被调用。如果没有代码处理抛出的异常， 则该异常被忽略且不记录(不同于其他异常那样)。

参数:

    request (Request 对象) – 处理的request
    spider (Spider 对象) – 该request对应的spider

##### process_response(self, request, response, spider)

当下载器完成http请求，传递响应给引擎的时候调用

process_response() 必须返回以下其中之一: 返回一个 Response 对象、 返回一个 Request 对象或raise一个 IgnoreRequest 异常。

- 如果其返回一个 Response (可以与传入的response相同，也可以是全新的对象)， 该response会被在链中的其他中间件的 process_response() 方法处理。

- 如果其返回一个 Request 对象，则中间件链停止， 返回的request会被重新调度下载。处理类似于 process_request() 返回request所做的那样。

- 如果其抛出一个 IgnoreRequest 异常，则调用request的errback(Request.errback)。 如果没有代码处理抛出的异常，则该异常被忽略且不记录(不同于其他异常那样)。

参数:

    request (Request 对象) – response所对应的request
    response (Response 对象) – 被处理的response
    spider (Spider 对象) – response所对应的spider

## 2 使用案例

(1) 创建middlewares.py文件

Scrapy代理IP、Uesr-Agent的切换都是通过DOWNLOADER_MIDDLEWARES进行控制，我们在settings.py同级目录下创建middlewares.py文件，包装所有请求。
```python
# middlewares.py

#!/usr/bin/env python
# -*- coding:utf-8 -*-

import random
import base64

from settings import USER_AGENTS
from settings import PROXIES

# 随机的User-Agent
class RandomUserAgent(object):
    def process_request(self, request, spider):
        useragent = random.choice(USER_AGENTS)

        request.headers.setdefault("User-Agent", useragent)

class RandomProxy(object):
    def process_request(self, request, spider):
        proxy = random.choice(PROXIES)

        if proxy['user_passwd'] is None:
            # 没有代理账户验证的代理使用方式
            request.meta['proxy'] = "http://" + proxy['ip_port']
        else:
            # 对账户密码进行base64编码转换
            base64_userpasswd = base64.b64encode(proxy['user_passwd'])
            # 对应到代理服务器的信令格式里
            request.headers['Proxy-Authorization'] = 'Basic ' + base64_userpasswd
            request.meta['proxy'] = "http://" + proxy['ip_port']
```

为什么HTTP代理要使用base64编码：

HTTP代理的原理很简单，就是通过HTTP协议与代理服务器建立连接，协议信令中包含要连接到的远程主机的IP和端口号，如果有需要身份验证的话还需要加上授权信息，服务器收到信令后首先进行身份验证，通过后便与远程主机建立连接，连接成功之后会返回给客户端200，表示验证通过，就这么简单，下面是具体的信令格式：

    CONNECT 59.64.128.198:21 HTTP/1.1
    Host: 59.64.128.198:21
    Proxy-Authorization: Basic bGV2I1TU5OTIz
    User-Agent: OpenFetion

其中Proxy-Authorization是身份验证信息，Basic后面的字符串是用户名和密码组合后进行base64编码的结果，也就是对username:password进行base64编码。

HTTP/1.0 200 Connection established
OK，客户端收到收面的信令后表示成功建立连接，接下来要发送给远程主机的数据就可以发送给代理服务器了，代理服务器建立连接后会在根据IP地址和端口号对应的连接放入缓存，收到信令后再根据IP地址和端口号从缓存中找到对应的连接，将数据通过该连接转发出去。

(2) 修改settings.py配置USER_AGENTS和PROXIES

添加USER_AGENTS：
```python
　　USER_AGENTS = [
    "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Win64; x64; Trident/5.0; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET CLR 2.0.50727; Media Center PC 6.0)",
    "Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; WOW64; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET CLR 1.0.3705; .NET CLR 1.1.4322)",
    "Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 5.2; .NET CLR 1.1.4322; .NET CLR 2.0.50727; InfoPath.2; .NET CLR 3.0.04506.30)",
    "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN) AppleWebKit/523.15 (KHTML, like Gecko, Safari/419.3) Arora/0.3 (Change: 287 c9dfb30)",
    "Mozilla/5.0 (X11; U; Linux; en-US) AppleWebKit/527+ (KHTML, like Gecko, Safari/419.3) Arora/0.6",
    "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.2pre) Gecko/20070215 K-Ninja/2.1.1",
    "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9) Gecko/20080705 Firefox/3.0 Kapiko/3.0",
    "Mozilla/5.0 (X11; Linux i686; U;) Gecko/20070322 Kazehakase/0.4.5"
    ]
```

添加代理IP设置PROXIES：

免费代理IP可以网上搜索，或者付费购买一批可用的私密代理IP：
```python
PROXIES = [
    {'ip_port': '111.8.60.9:8123', 'user_passwd': 'user1:pass1'},
    {'ip_port': '101.71.27.120:80', 'user_passwd': 'user2:pass2'},
    {'ip_port': '122.96.59.104:80', 'user_passwd': 'user3:pass3'},
    {'ip_port': '122.224.249.122:8088', 'user_passwd': 'user4:pass4'},
]
```
除非特殊需要，禁用cookies，防止某些网站根据Cookie来封锁爬虫。

    COOKIES_ENABLED = False

设置下载延迟

    DOWNLOAD_DELAY = 3

最后设置setting.py里的DOWNLOADER_MIDDLEWARES，添加自己编写的下载中间件类。

    DOWNLOADER_MIDDLEWARES = {
        #'mySpider.middlewares.MyCustomDownloaderMiddleware': 543,
        'mySpider.middlewares.RandomUserAgent': 1,
        'mySpider.middlewares.ProxyMiddleware': 100
    }
