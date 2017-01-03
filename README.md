ShadowsocksR-libev for OpenWrt
===


简介
---

 本项目是 [shadowsocksr-libev][1] 在 OpenWrt 上的移植  
 
 各平台预编译IPK请在本项目releases页面下载

特性
---

软件包包含 [shadowsocksr-libev][1] 的可执行文件,以及luci控制界面  

支持SSR客户端、服务端模式（服务端支持部分混淆模式、支持多端口）

支持GFWList，列表中的网站走透明代理，其他网站不走代理

可以和[Shadowsocks][5]共存，在openwrt可以通过luci界面切换使用[Shadowsocks][6]或ShadowsocksR

集成[KcpTun加速][4]，此功能对路由器性能要求较高，需下载对应的二进制文件到路由器指定目录，请酌情使用

客户端兼容运行SS或SSR的服务器，使用SS服务器时，传输协议需设置为origin，混淆插件需设置为plain

所有进程自动守护，崩溃后自动重启


编译
---

 - 从 OpenWrt 的 [SDK][S] 编译（编译环境：Ubuntu 64位系统），如果是第一次编译，还需下载OpenWrt所需依赖软件
   ```bash
   sudo apt-get install build-essential asciidoc binutils bzip2 gawk gettext  git libncurses5-dev libz-dev patch unzip zlib1g-dev  subversion git ccache
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
   #luci ->3. Applications-> luci-app-shadowsocksR         包含客户端和服务端
   #luci ->3. Applications-> luci-app-shadowsocksR-Client  只包含客户端
   #luci ->3. Applications-> luci-app-shadowsocksR-Server  只包含服务端
   #luci ->3. Applications-> luci-app-shadowsocksR-GFW     GFWList模式
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
   
安装
--- 
本软件包依赖库：libopenssl、libpthread、ipset、ip、iptables-mod-tproxy、libpcre、dnsmasq-full，opkg会自动安装

软件编译后可生成四个软件包，分别是luci-app-shadowsocksR（含客户端和服务端）、luci-app-shadowsocksR-client（只含客户端）、luci-app-shadowsocksR-Server（只含服务端）、luci-app-shadowsocksR-GFW（GFW模式），用户根据需要或路由器空间大小选择其中一个安装即可

先将编译成功的luci-app-shadowsocksR*_all.ipk通过winscp上传到路由器的/tmp目录，执行命令：

   ```bash
   #刷新opkg列表
   opkg update
   
   #删除dnsmasq（GFW模式第一次安装需手动卸载dnsmasq，并安装dnsmasq-full，其他情况可选）
   opkg remove dnsmasq && opkg install dnsmasq-full
   
   #安装软件包
   opkg install /tmp/luci-app-shadowsocksR*_all.ipk 
   ```
要启用KcpTun，需从本项目releases页面或相关网站（[网站1][4]、[网站2][7]）下载路由器平台对应的二进制文件，并将文件名改为ssr-kcptun，放入/usr/bin目录

安装后强烈建议重启路由器，因为luci有缓存机制，在升级或新装IPK后，如不重启有时会出现一些莫名其妙的问题

配置
---

   软件包通过luci配置， 支持的键如下:  
   
   客户端：

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
   
   服务端：

   键名           | 数据类型   | 说明
   ---------------|------------|-----------------------------------------------
   server         | 字符串     | 服务器本机IP地址, 一般为0.0.0.0
   server_port    | 数值       | 服务器监听端口号, 小于 65535
   timeout        | 数值       | 超时时间（秒）, 默认 60
   password       | 字符串     | 服务端设置的密码
   encrypt_method | 字符串     | 加密方式, [详情参考][2]
   protocol       | 字符串     | 传输协议，默认"origin"[详情参考][3]
   obfs           | 字符串     | 混淆插件，默认"plain" [详情参考][3]
   obfs_param     | 字符串     | 混淆插件参数 [详情参考][3]
   fast_open      | 布尔型     | TCP快速打开 [详情参考][3]
   
   某些openwrt上的kcptun在启用压缩后存在问题，因此在界面上缺省加上了“--nocomp”参数，缺省为非压缩，请在服务端也使用非压缩模式
   
   如要打开kcptun的日志，可以在kcptun参数栏填入"--nocomp --log /var/log/kcptun.log"，日志会保存在指定文件中
   

问题和建议反馈
---
请点击本页面上的“Issues”反馈使用问题或建议

截图  
---
客户端：
![luci000](http://iytc.net/img/ssr7.jpg)

服务端：
![luci000](http://iytc.net/img/ssr62.jpg)

  [1]: https://github.com/breakwa11/shadowsocks-libev
  [2]: https://github.com/shadowsocks/luci-app-shadowsocks/wiki/Encrypt-method
  [3]: https://github.com/breakwa11/shadowsocks-rss/wiki/config.json
  [4]: https://github.com/xtaci/kcptun
  [5]: https://github.com/shadowsocks/openwrt-shadowsocks
  [6]: https://github.com/shadowsocks/luci-app-shadowsocks  
  [7]: https://github.com/bettermanbao/openwrt-kcptun/releases 
  [S]: https://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
