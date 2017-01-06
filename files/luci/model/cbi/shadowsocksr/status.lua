-- Copyright (C) 2017 yushi studio <ywb94@qq.com>
-- Licensed to the public under the GNU General Public License v3.

local IPK_Version="1.1.7"
local m, s, o
local redir_run=0
local reudp_run=0
local sock5_run=0
local server_run=0
local kcptun_run=0
local tunnel_run=0
local shadowsocksr = "shadowsocksr"
-- html constants
font_blue = [[<font color="blue">]]
font_off = [[</font>]]
bold_on  = [[<strong>]]
bold_off = [[</strong>]]

local fs = require "nixio.fs"
local sys = require "luci.sys"
local kcptun_version=translate("Unknown")
local kcp_file="/usr/bin/ssr-kcptun"
if not fs.access(kcp_file)  then
 kcptun_version=translate("Not exist")
else
 if not fs.access(kcp_file, "rwx", "rx", "rx") then
   fs.chmod(kcp_file, 755)
 end
 kcptun_version=sys.exec(kcp_file .. " -v | awk '{printf $3}'")
 if not kcptun_version or kcptun_version == "" then
     kcptun_version = translate("Unknown")
 end
        
end

local icount=sys.exec("ps -w | grep ssr-reudp |grep -v grep| wc -l")
if tonumber(icount)>0 then
reudp_run=1
else
icount=sys.exec("ps -w | grep ssr-retcp |grep \"\\-u\"|grep -v grep| wc -l")
if tonumber(icount)>0 then
reudp_run=1
end
end


if luci.sys.call("pidof ssr-redir >/dev/null") == 0 then
redir_run=1
end	

if luci.sys.call("pidof ssr-local >/dev/null") == 0 then
sock5_run=1
end	

if luci.sys.call("pidof ssr-kcptun >/dev/null") == 0 then
kcptun_run=1
end	

if luci.sys.call("pidof ssr-server >/dev/null") == 0 then
server_run=1
end	

if luci.sys.call("pidof ssr-tunnel >/dev/null") == 0 then
tunnel_run=1
end	


m = SimpleForm("Version", translate("Running Status"))
m.reset = false
m.submit = false

s=m:field(DummyValue,"redir_run",translate("Global Client")) 
s.rawhtml  = true
if redir_run == 1 then
s.value =font_blue .. bold_on .. translate("Running") .. bold_off .. font_off
else
s.value = translate("Not Running")
end

s=m:field(DummyValue,"server_run",translate("Global SSR Server")) 
s.rawhtml  = true
if server_run == 1 then
s.value =font_blue .. bold_on .. translate("Running") .. bold_off .. font_off
else
s.value = translate("Not Running")
end

s=m:field(DummyValue,"reudp_run",translate("UDP Relay")) 
s.rawhtml  = true
if reudp_run == 1 then
s.value =font_blue .. bold_on .. translate("Running") .. bold_off .. font_off
else
s.value = translate("Not Running")
end

s=m:field(DummyValue,"sock5_run",translate("SOCKS5 Proxy")) 
s.rawhtml  = true
if sock5_run == 1 then
s.value =font_blue .. bold_on .. translate("Running") .. bold_off .. font_off
else
s.value = translate("Not Running")
end

s=m:field(DummyValue,"tunnel_run",translate("DNS Tunnel")) 
s.rawhtml  = true
if tunnel_run == 1 then
s.value =font_blue .. bold_on .. translate("Running") .. bold_off .. font_off
else
s.value = translate("Not Running")
end


s=m:field(DummyValue,"kcptun_run",translate("KcpTun")) 
s.rawhtml  = true
if kcptun_run == 1 then
s.value =font_blue .. bold_on .. translate("Running") .. bold_off .. font_off
else
s.value = translate("Not Running")
end


s=m:field(DummyValue,"version",translate("IPK Version")) 
s.rawhtml  = true
s.value =IPK_Version

s=m:field(DummyValue,"google",translate("Google Connectivity")) 
s.template = "shadowsocksr/check"

s=m:field(DummyValue,"baidu",translate("Baidu Connectivity")) 
s.template = "shadowsocksr/check"


s=m:field(DummyValue,"kcp_version",translate("KcpTun Version")) 
s.rawhtml  = true
s.value =kcptun_version


s=m:field(DummyValue,"project",translate("Project")) 
s.rawhtml  = true
s.value =bold_on .. [[<a href="]] .. "https://github.com/ywb94/openwrt-ssr" .. [[" >]]
	.. "https://github.com/ywb94/openwrt-ssr" .. [[</a>]] .. bold_off
	
return m
