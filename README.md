ShadowsocksR-libev for OpenWrt
===


简介
---

 本项目是 [shadowsocksr-libev][1] 在 OpenWrt 上的移植  
 
 各平台预编译IPK请在release页面下载

特性
---

软件包包含 [shadowsocksr-libev][1] 的可执行文件,以及luci控制界面  

支持SSR客户端、服务端模式（目前支持部分混淆模式、支持多端口）

支持自动分流，国内IP不走代理，国外IP段走透明代理，不需要再安装chnroute、gfwlist等软件

支持本地域名污染情况下的远程服务器解析，多数情况下无需对dns进行处理

可以和[Shadowsocks][5]共存，在openwrt可以通过luci界面切换使用[Shadowsocks][6]或ShadowsocksR

集成[KcpTun加速][4]，此功能对路由器性能要求较高，需下载对应的二进制文件到指定目录，请根据情况使用

客户端兼容运行SS或SSR的服务器，使用SS服务器时，传输协议需设置为origin，混淆插件需设置为plain

所有进程自动守护，崩溃后自动重启


编译
---

 - 从 OpenWrt 的 [SDK][S] 编译（编译环境：Ubuntu 64位系统），如果是第一次编译，还需下载OpenWrt所需要的软件
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
本软件包依赖库：libopenssl、libpthread、ipset、ip、iptables-mod-tproxy、libpcre，opkg会自动安装

软件编译后可生成三个软件包，分别是luci-app-shadowsocksR（含客户端和服务端）、luci-app-shadowsocksR-client（只含客户端）、luci-app-shadowsocksR-Server（只含服务端），用户根据需要或路由器空间大小选择其中一个安装即可

先将编译成功的luci-app-shadowsocksR*_all.ipk通过winscp上传到路由器的/tmp目录，执行命令：

   ```
   #opkg update
   #opkg install /tmp/luci-app-shadowsocksR*_all.ipk 
   ```

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
   
   安装启用后自动分流国内、外流量，如需更新国内IP数据库在openwrt上执行"get_chinaip"命令即可：
   ```
    # get_chinaip  
                                                                                                           
      Connecting to ftp.apnic.net (202.12.29.205:80)                                                                                      

         
   ```
   注：此数据库一般无需刷新，如果刷新必须等待上面的命令运行完成，否则可能损坏数据库

问题和建议反馈
---
请点击本页面上的“Issues”反馈使用问题或建议

截图  
---

![luci000](http://iytc.net/img/ssr3.jpg)


  [1]: https://github.com/breakwa11/shadowsocks-libev
  [2]: https://github.com/shadowsocks/luci-app-shadowsocks/wiki/Encrypt-method
  [3]: https://github.com/breakwa11/shadowsocks-rss/wiki/config.json
  [4]: https://github.com/xtaci/kcptun
  [5]: https://github.com/shadowsocks/openwrt-shadowsocks
  [6]: https://github.com/shadowsocks/luci-app-shadowsocks  
  [S]: https://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
