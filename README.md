# TYUT-novpn  
  
在服务器上搭建MotionPro客户端，连接到tyut校园网  
Please read this document completely when you first use or upgrade script's version.  
[DEMO](https://jxgl.yyyxqz.cn:8000)  
  
# 下载与安装  
ps:请全程在root环境下执行  
  
pps:仅在Ubuntu 18.04 LTS及Centos 7上测试过，若出现安装及使用bug，请及时通过issue反馈。  
  
## 下载  
克隆本仓库  
```
git clone https://github.com/bla58351/tyut-novpn.git && cd tyut-novpn
```  
  
## 安装 && 使用  
  
执行`./tyut.sh start`,按步骤即可食用。  
  
# usage  
  
`./tyut.sh [OPTION]`  
`stop`:断开连接  
`restart`:重新连接  
`reset`:重新设置个人信息  
  
# bug反馈  
若发现脚本使用时存在问题，如：服务器失联、连接失败等，可以发issue提交bug  
  
# License  
MIT  
