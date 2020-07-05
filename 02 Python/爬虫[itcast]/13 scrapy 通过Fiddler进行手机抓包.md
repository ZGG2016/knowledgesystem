# 通过Fiddler进行手机抓包

通过Fiddler抓包工具，可以抓取手机的网络通信，但前提是手机和电脑处于同一局域网内（WI-FI或热点），然后进行以下设置。

## 用Fiddler对Android应用进行抓包

1、打开Fiddler设置

![scrapy11](https://s1.ax1x.com/2020/06/20/NlTOJS.png)

2、在Connections里设置允许连接远程计算机，确认后重新启动Fiddler

![scrapy12](https://s1.ax1x.com/2020/06/20/NlTXRg.png)

3、在命令提示符下输入ipconfig查看本机IP

![scrapy13](https://s1.ax1x.com/2020/06/20/NlTLi8.png)

4、打开Android设备的“设置”->“WLAN”，找到你要连接的网络，在上面长按，然后选择“修改网络”，弹出网络设置对话框，然后勾选“显示高级选项”。

![scrapy14](https://s1.ax1x.com/2020/06/20/NlHk7t.png)

5、手机安装证书

第一种：手机下载证书。打开手机的浏览器，输入：【IP:8888】下载证书。

第二种：直接在Fiddler中，进行证书导出至桌面，再将证书通过工具或其他方法直接传到手机sd卡内，直接安装

6、案例

案例见代码部分（咪咕爬取）


## 用Fiddler对iPhone手机应用进行抓包

基本流程差不多，只是手机设置不太一样：

iPhone手机：点击设置 > 无线局域网 > 无线网络 > HTTP代理 > 手动：

代理地址(电脑IP)：192.168.xx.xxx

端口号：8888
