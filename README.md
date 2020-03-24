# tyut-novpn
在服务器上搭建MotionPro客户端，达到免连VPN访问tyut校园内网的目的  
[TOC]
# 一、安装
ps:请全程在root环境下执行

## 一、安装MotionPro
前往[下载页](http://client.arraynetworks.com.cn:8080/zh/troubleshooting)下载服务器对应系统的`MotionPro客户端`  
然后用`xftp`、`winscp`等ftp工具将下载的安装包传到服务器上  
ssh连接服务器,执行`chmod +x ./MotionPro_Linux_Ubuntu_x64_v1.2.6.sh && ./MotionPro_Linux_Ubuntu_x64_v1.2.6.sh`(注意以下载的文件名为准)

## 二、安装依赖
```
# Debian/Ubuntu 执行
apt install -y sudo vim git curl
# CentOS 执行
yum install -y sudo vim git curl
```

## 三、安装脚本
执行`git clone https://github.com/bla58351/tyut-novpn.git && chmod +x tyut-novpn/connect.sh`  
然后，本脚本就应该在`tyut-novpn`目录下了

# 二、使用脚本

## 一、准备工作
使用`vim`编辑`connect.sh`内的`username='xxx'`和`password='xxx'`，将`xxx`改为自己登录校园网的用户名(username)及密码(password)  

## 二、建立连接
执行`nohup ./connect.sh & `(建议)。可能会有断开ssh的现象，直接重连即可  
之后执行`./connect.sh check`，若结果为`VPN连接正常`，则连接已经成功

# 三、脚本全部命令
`./connect.sh`: 直接连接到VPN  
`./connect.sh check`: 检测VPN及校园内网连接状态  
`./connect.sh stop`: 断开VPN连接  
`./connect.sh restart`: 重新连接VPN

# 四、未来计划
[x] 搭建http服务，以支持直接访问  
[x] 将MotionPro安装包集成在内
[x] 一键部署脚本

# 五、bug反馈
若发现脚本使用时存在问题，如：服务器失联、连接失败等，可以发issue提交bug
