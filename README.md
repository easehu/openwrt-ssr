ShadowsocksR-libev for OpenWrt
===


简介
---

 本项目是 [shadowsocksr-libev][1] 在 OpenWrt 上的移植  
 
 各平台预编译IPK请在本项目releases页面下载

特性
---

软件包包含 [shadowsocksr-libev][1] 的可执行文件,以及luci控制界面  

支持SSR客户端、服务端模式（服务端支持部分混淆模式、支持多端口）；支持SOCK5代理

支持两种运行模式：IP路由模式和GFW列表模式（GFWList）

可以和[Shadowsocks][5]共存，在openwrt上可以通过luci界面切换使用[Shadowsocks][6]或ShadowsocksR

集成[KcpTun加速][4]，此功能对路由器性能要求较高，需下载对应的二进制文件到路由器指定目录，请酌情使用

客户端兼容运行SS或SSR的服务器，使用SS服务器时，传输协议需设置为origin，混淆插件需设置为plain

所有进程自动守护，崩溃后自动重启

运行模式介绍
---
【IP路由模式】
 - 所有国内IP网段不走代理，国外IP网段走代理；
 - 白名单模式：缺省都走代理，列表中IP网段不走代理

优点：国内外分流清晰明确；适合线路好SSR服务器，通过代理可提高访问国外网站的速度；

缺点：开启BT下载时，如连接国外的IP，会损耗SSR服务器的流量；如果SSR服务器线路不好，通过代理访问国外网站的速度不如直连

【GFW列表模式】
 - 只有在GFW列表中的网站走代理；其他都不走代理；
 - 黑名单模式：缺省都不走代理，列表中网站走代理

优点：目标明确，只有访问列表中网站才会损耗SSR服务器流量

缺点：GFW列表并不能100%涵盖被墙站点，而且有些国外站点直连速度远不如走代理 


编译
---

 - 从 OpenWrt 的 [SDK][S] 编译（编译环境：Ubuntu 64位系统），如果是第一次编译，还需下载OpenWrt所需依赖软件
   ```bash
   sudo apt-get install gawk libncurses5-dev libz-dev zlib1g-dev  git ccache
   ```
 
 - 下载路由器对应平台的SDK

   ```bash
   # 以 ar71xx 平台为例
   tar xjf OpenWrt-SDK-15.05-ar71xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64.tar.bz2
   cd OpenWrt-SDK-*
   # 安装 feeds
   ./scripts/feeds update packages
   ./scripts/feeds install libpcre
   # 获取 Makefile
   git clone https://github.com/ywb94/openwrt-ssr.git package/openwrt-ssr
   # 选择要编译的包 
   #luci ->3. Applications-> luci-app-shadowsocksR         原始版本
   #luci ->3. Applications-> luci-app-shadowsocksR-GFW     GFWList版本
   #V1.1.6以后版本取消发布单独的客户端和服务端，如有需要，请修改makefile或采用V1.1.5版本
   make menuconfig
   
   #如果没有安装po2lmo，则安装（可选）
   pushd package/openwrt-ssr/tools/po2lmo
   make && sudo make install
   popd
   #编译语言文件（可选）
   po2lmo ./package/openwrt-ssr/files/luci/i18n/shadowsocksr.zh-cn.po ./package/openwrt-ssr/files/luci/i18n/shadowsocksr.zh-cn.lmo
   
   # 开始编译
   make V=99
   ```
 - LEDE编译补充
 
   LEDE是OpenWRT的另一个版本，LEDE的SDK采用xz压缩，需先用xz -d解压下载的SDK包，再按上述命令操作
   
   使用LEDE的SDK编译，可能会提示找不到zlib和openssl文件，请运行如下命令
 
   ```bash
   ./scripts/feeds update
   ./scripts/feeds install zlib
   ./scripts/feeds install libopenssl
   ```
   
   
安装
--- 
本软件包依赖库：libopenssl、libpthread、ipset、ip、iptables-mod-tproxy、libpcre、dnsmasq-full，GFW版本还需依赖dnsmasq-full，opkg会自动安装上述库文件

软件编译后可生成两个软件包，分别是luci-app-shadowsocksR（原始版本）、luci-app-shadowsocksR-GFW（GFW版本），用户根据需要选择其中一个安装即可

原始版本只支持IP路由模式，对现有OpenWRT系统改动较少；本地dns域名解析存在污染，由远端SSR服务器重新进行二次DNS解析；可和其他DNS处理软件一起使用；

GFW版本支持IP路由模式和GFW列表模式，需卸载原有的dnsmasq，会接管OpenWRT的域名处理，避免域名污染并实现准确分流；SSR服务器侧需开启UDP转发；

提醒：如果安装GFW版本，请停用当前针对域名污染的其他处理软件，不要占用UDP 5353端口，并做好必要的数据备份，比如/etc/dnsmasq.conf文件，安装过程会覆盖此文件，如提示文件冲突，请先将此文件改名后再安装

将编译成功的luci-app-shadowsocksR*_all.ipk通过winscp上传到路由器的/tmp目录，执行命令：

   ```bash
   #刷新opkg列表
   opkg update
   
   #删除dnsmasq（GFW版本第一次安装需手动卸载dnsmasq，其他情况下不需要）
   opkg remove dnsmasq 
   
   #安装软件包
   opkg install /tmp/luci-app-shadowsocksR*_all.ipk 
   ```
如要启用KcpTun，需从本项目releases页面或相关网站（[网站1][4]、[网站2][7]）下载路由器平台对应的二进制文件，并将文件名改为ssr-kcptun，放入/usr/bin目录

安装后强烈建议重启路由器，因为luci有缓存机制，在升级或新装IPK后，如不重启有时会出现一些莫名其妙的问题；另GFW版本会安装、修改、调用dnsmasq-full，安装后最好能重启路由器

配置
---

   软件包通过luci配置， 支持的配置项如下:  
   
   客户端服务器配置：

   键名           | 数据类型   | 说明
   ---------------|------------|-----------------------------------------------
   auth_enable    | 布尔型     | 一次验证开关[0.关闭 1.开启],需要服务端同时支持
   server         | 主机类型   | 服务器地址, 可以是 IP 或者域名，推荐使用IP地址
   server_port    | 数值       | 服务器端口号, 小于 65535   
   local_port     | 数值       | 本地绑定的端口号, 小于 65535
   timeout        | 数值       | 超时时间（秒）, 默认 60   
   password       | 字符串     | 服务端设置的密码
   encrypt_method | 字符串     | 加密方式, [详情参考][2]
   protocol       | 字符串     | 传输协议，默认"origin"[详情参考][3]
   obfs           | 字符串     | 混淆插件，默认"plain" [详情参考][3]
   obfs_param     | 字符串     | 混淆插件参数 [详情参考][3]
   fast_open      | 布尔型     | TCP快速打开 [详情参考][3]
   kcp_enable     | 布尔型     | KcpTun开启开关
   kcp_port       | 数值       | KcpTun服务器端口号, 小于 65535
   kcp_password   | 字符串     | KcpTun密码，留空表示"it's a secrect"
   kcp_param      | 字符串     | KcpTun参数[详情参考][4]
   
   客户端其他配置：
   
   名称                        | 含义
   ----------------------------|-----------------------------------------------------------
   全局服务器                  | 选择要连接的SSR TCP代理服务器
   UDP中继服务器               | 选择要连接的SSR UDP代理服务器
   启用进程监控                | 启用后可对所有进程进行监控，发现崩溃自动重启
   运行模式                    | 两种运行模式选择（GFW版本特有）
   启用隧道（DNS）转发         | 开启DNS隧道（原始版本特有）
   隧道（DNS）本地端口         | DNS隧道本地端口（原始版本特有，GFW固定为5353）
   隧道（DNS）转发地址         | DNS请求转发的服务器，一般设置为google的dns地址
   SOCKS5代理-服务器           | 用于SOCKS代理的SSR服务器
   SOCKS5代理-本地端口         | 用于SOCKS代理的本地端口（注意此端口不能和SSR服务器配置中的本地端口相同）
   访问控制-被忽略IP列表       | IP路由模式时有效，用于指定存放国内IP网段的文件，这些网段不经过代理
   访问控制-额外被忽略IP       | IP路由模式时有效，用于添加额外的不经过代理的目的IP地址
   访问控制-强制走代理IP       | 用于添加需要经过代理的目的IP地址
   路由器访问控制              | 用于控制路由器本身是否走代理，适用于路由器挂载BT下载的情况
   内网访问控制                | 可以控制内网中哪些IP能走代理，哪些不能走代理，可以指定下面列表内或列表外IP
   内网主机列表                | 内网IP列表，可以指定多个
   
   
   服务端配置：

   键名           | 数据类型   | 说明
   ---------------|------------|-----------------------------------------------
   enable         | 布尔型     | 是否启用此服务器配置
   server         | 字符串     | 服务器本机IP地址, 一般为0.0.0.0
   server_port    | 数值       | 服务器监听端口号, 小于 65535
   timeout        | 数值       | 超时时间（秒）, 默认 60
   password       | 字符串     | 服务端设置的密码
   encrypt_method | 字符串     | 加密方式, [详情参考][2]
   protocol       | 字符串     | 传输协议，默认"origin"[详情参考][3]
   obfs           | 字符串     | 混淆插件，默认"plain" [详情参考][3]
   obfs_param     | 字符串     | 混淆插件参数 [详情参考][3]
   fast_open      | 布尔型     | TCP快速打开 [详情参考][3]
   
   在某些openwrt上的kcptun启用压缩后存在问题，因此在界面上加上了“--nocomp”参数，缺省为非压缩，请在服务端也使用非压缩模式
   
   如要打开kcptun的日志，可以在kcptun参数栏填入"--nocomp --log /var/log/kcptun.log"，日志会保存在指定文件中
   
   IP路由模式的数据文件为/etc/china_ssr.txt,包含国内所有IP网段，一般无需更新，如要更新，在openwrt上执行"get_chinaip"命令即可，注意：如果刷新必须等待命令运行完成，否则可能损坏数据库
   
   FGW列表模式的数据文件为/etc/dnsmasq.ssr/gfw_list.conf，包含所有被墙网站，如需更新，请自行寻找替换此文件
   


问题和建议反馈
---
请点击本页面上的“Issues”反馈使用问题或建议

截图  
---
客户端：

![luci000](http://iytc.net/img/ssr8.jpg)

服务端：

![luci000](http://iytc.net/img/ssr82.jpg)

状态页面：

![luci000](http://iytc.net/img/ssr84.jpg)

  [1]: https://github.com/breakwa11/shadowsocks-libev
  [2]: https://github.com/shadowsocks/luci-app-shadowsocks/wiki/Encrypt-method
  [3]: https://github.com/breakwa11/shadowsocks-rss/wiki/config.json
  [4]: https://github.com/xtaci/kcptun
  [5]: https://github.com/shadowsocks/openwrt-shadowsocks
  [6]: https://github.com/shadowsocks/luci-app-shadowsocks  
  [7]: https://github.com/bettermanbao/openwrt-kcptun/releases 
  [S]: https://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
