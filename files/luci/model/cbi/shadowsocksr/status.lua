-- Copyright (C) 2017 yushi studio <ywb94@qq.com>
-- Licensed to the public under the GNU General Public License v3.

local m, s, o
local redir_run=0
local sock5_run=0
local server_run=0
local kcptun_run=0
local tunnel_run=0
local shadowsocksr = "shadowsocksr"

local ipkg = require "luci.model.ipkg"
local IPK_name="luci-app-shadowsocksR"
local package_info = ipkg.info(IPK_name) 
local IPK_Version=translate("Unknown")
local KeyTemp=""

for key,value in pairs(package_info) do
KeyTemp= KeyTemp .. key 
end

if KeyTemp == "" then
 IPK_name="luci-app-shadowsocksR-Client"
 package_info = ipkg.info(IPK_name) 
 for key,value in pairs(package_info) do
 KeyTemp= KeyTemp .. key 
 end
 if KeyTemp == "" then
  IPK_name="luci-app-shadowsocksR-Server"
  package_info = ipkg.info(IPK_name) 
  for key,value in pairs(package_info) do
  KeyTemp= KeyTemp .. key 
  end
 if KeyTemp == "" then
 package_info=""
 end
 end
end



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
m.help = help_txt and true or false   
m.helptxt = help_txt or "" 


s=m:field(DummyValue,"redir_run",translate("Global Client")) 
s.cfgvalue = function(self, section)   
local t =  translate("Not Running")
if redir_run == 1 then
t =  translate("Running")
end	
return t   
end   

s=m:field(DummyValue,"server_run",translate("Global Server")) 
s.cfgvalue = function(self, section)   
local t =  translate("Not Running")
if server_run == 1 then
t =  translate("Running")
end	
return t   
end   

s=m:field(DummyValue,"sock5_run",translate("SOCKS5 Proxy")) 
s.cfgvalue = function(self, section)   
local t =  translate("Not Running")
if sock5_run == 1 then
t =  translate("Running")
end	
return t   
end   



s=m:field(DummyValue,"tunnel_run",translate("UDP Tunnel")) 
s.cfgvalue = function(self, section)   
local t =  translate("Not Running")
if tunnel_run == 1 then
t =   translate("Running")
end	
return t   
end   

s=m:field(DummyValue,"kcptun_run",translate("KcpTun")) 
s.cfgvalue = function(self, section)   
local t =  translate("Not Running")
if kcptun_run == 1 then
t =  translate("Running")
end	
return t   
end   

s=m:field(DummyValue,"version",translate("IPK Version")) 
s.cfgvalue = function(self, section)   
local t = IPK_Version
if   package_info ~= "" then
t=package_info[IPK_name]["Version"]
end
return t   
end   

s=m:field(DummyValue,"install_time",translate("IPK Installation Time")) 
s.cfgvalue = function(self, section)   
local t = translate("Unknown")
if   package_info ~= "" then
t=os.date("%Y-%m-%d %H:%M:%S",package_info[IPK_name]["Installed-Time"])
end
return t   
end   

s=m:field(DummyValue,"kcp_version",translate("KcpTun Version")) 
s.cfgvalue = function(self, section)   
local t = kcptun_version
return t   
end   

s=m:field(DummyValue,"project",translate("Project")) 
s.cfgvalue = function(self, section)   
local t = "https://github.com/ywb94/openwrt-ssr"
return t   
end   

return m
