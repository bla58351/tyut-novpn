#!/bin/bash

username="XXX"
password="XXX"

ping 202.207.240.147 -c1 >>/root/code/check.log 2>&1;

if [ $? -ne 0 ];then
	curl 'http://202.207.240.67:801/eportal/?c=ACSetting&a=Login&wlanuserip=null&wlanacip=null&wlanacname=null&port=&iTermType=1&mac=123456789012&ip=000.000.000.000&redirect=null' -H 'Connection: keep-alive' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Origin: http://202.207.240.67' -H 'Upgrade-Insecure-Requests: 1' -H 'DNT: 1' -H 'Content-Type: application/x-www-form-urlencoded' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' -H 'Referer: http://202.207.240.67/a70.htm' -H 'Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,ja;q=0.7' -H "Cookie: divshowUID=$username; md5_login=$username%7C$password; PHPSESSID=sbtsjh237ps9q23qm3es6jfpa1" --data "DDDDD=$username&upass=$password&save_me=1" --compressed --insecure
fi

# 使用方法：
# chmod +x check.sh
# crontab -e 
# 编辑crontab配置如下：
# */5 * * * * /root/code/check.sh
