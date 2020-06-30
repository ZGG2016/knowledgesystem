# 虚拟机配置NAT网络模式

### 1、配置VMware的NET网络模式

⑴关闭目前需要更改配置的虚拟机。

⑵点击 编辑虚拟机设置——网络适配器——NAT模式（N）——确定

![linux01](https://s1.ax1x.com/2020/06/30/NopRbV.png)

⑶在VMware虚拟机任务栏——编辑（E）——虚拟网络编辑器——VMnet8——取消勾选的 “使用本地DHCP服务将IP地址分配给虚拟机”——把子网IP 改为：192.168.137.0（因为此网段为window分配给VMnet8的网段）——确定

![linux02](https://s1.ax1x.com/2020/06/30/Nop2D0.png)

## 2、配置window的internet连接共享

我的电脑——空白处右键属性——控制面板主页——网络和internet——网络和共享中心——更改适配器设置——以太网（或叫本地网络）右键属性——共享——选择家庭网络连接（H）：VMware Network Adapter VMnet8——勾选：允许其他网络用户通过此计算机的internet连接来连接——确定

![linux03](https://s1.ax1x.com/2020/06/30/Nop6vn.png)

### 3、手动配置Centos7系统里的网络配置

进入linux系统，编辑网络配置：

vi /etc/sysconfig/network-scripts/ifcfg-ens33(文件名可能不一样)

配置如下：

      TYPE=Ethernet
      BOOTPROTO=static
      DEFROUTE=yes
      PEERDNS=yes
      PEERROUTES=yes
      IPADDR=192.168.137.20   #（192.168.137.0网段内）
      NETMASK=255.255.255.0
      GATEWAY=192.168.137.1   #网关需要与IP在一个网段内
      DNS1=192.168.137.1
      IPV4_FAILURE_FATAL=no
      IPV6INIT=yes
      IPV6_AUTOCONF=yes
      IPV6_DEFROUTE=yes
      IPV6_PEERDNS=yes
      IPV6_PEERROUTES=yes
      IPV6_FAILURE_FATAL=no
      IPV6_ADDR_GEN_MODE=stable-privacy
      NAME=ens33
      UUID=11a44a88-05c9-4d92-a834-644d7561fb97
      DEVICE=ens33
      ONBOOT=yes

重点几项：

    BOOTPROTO=static #以静态方式获取IP
    IPADDR=192.168.137.10 #IP地址为192.168.137.10（192.168.137.0网段内）
    NETMASK=255.255.255.0
    GATEWAY=192.168.137.1 #网关需要与IP在一个网段内
    DNS1=192.168.137.1
    ONBOOT=yes #开机启动网卡

重启网卡：`systemctl restart network`
开机启动网卡：`systemctl enable network`

### 4、测试

`ip a #查看网卡信息`
`ping www.baidu.com #能PING通就是联网成功`

### 5、问题

（1）出现“ping: www.baidu.com: 未知的名称或服务”，改一下网关

（2）主机ping不通虚拟机

![linux04](https://s1.ax1x.com/2020/06/30/Nopygs.png)

NAT模式下，确定vmnet8虚拟网卡启用，通过vmnet8和虚拟机通讯，vmnet8和虚拟机为同一网段。所以，设置：

![linux04](https://s1.ax1x.com/2020/06/30/Nopguq.png)


参考：[VMware虚拟机中Centos7网络配置及ping不通思路](https://blog.51cto.com/bestlope/1977074)
