#! /bin/sh
username='xxx'
password='xxx'
check_root(){
    [[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix}sudo su${Font_color_suffix} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1
}
stop(){
    MotionPro -s
    killall vpnd
    echo MotionPro已停止
}
start(){
    route_gateway=`route -n | grep -i "UG" | awk '{print $2}'`
    route_interface=`route -n | grep -i "UG" | awk '{print $8}'`
    if [ `route -n | awk '$8=="tun0"{print $8}' | wc -l` -gt 0 ]
    then
        echo "MotionPro正在运行，若想停止服务，请执行 $0 stop"
    else
        if [ `ps -C vpnd --no-header |wc -l` -eq 0 ]
        then
            echo "Vpnd not running, starting"
            vpnd
        else
            echo "Vpnd was already started"
        fi
        MotionPro -h vpn1.tyut.edu.cn -u $username -p $password &
        sleep 5s
        curl 'http://202.207.240.67:801/eportal/?c=ACSetting&a=Login&wlanuserip=null&wlanacip=null&wlanacname=null&port=&iTermType=1&mac=123456789012&ip=000.000.000.000&redirect=null' -H 'Connection: keep-alive' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Origin: http://202.207.240.67' -H 'Upgrade-Insecure-Requests: 1' -H 'DNT: 1' -H 'Content-Type: application/x-www-form-urlencoded' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' -H 'Referer: http://202.207.240.67/a70.htm' -H 'Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,ja;q=0.7' -H "Cookie: divshowUID=$username; md5_login=$username%7C$password; PHPSESSID=sbtsjh237ps9q23qm3es6jfpa1" --data "DDDDD=$username&upass=$password&save_me=1" --compressed --insecure
        sleep 1s
        route del -net 0.0.0.0 gw 1.1.1.1 dev tun0
        route add -net 0.0.0.0 gw $route_gateway dev $route_interface
        route add -net 202.207.0.0 netmask 255.255.0.0 gw 1.1.1.1 dev tun0
        sleep 1s
        check
    fi
}
check(){
    if [ `route -n | awk '$8=="tun0"{print $8}' | wc -l` -gt 0 ]
    then
        host=202.207.240.243
        ping -c1 $host >> /dev/null
        if [ $? -eq 0 ]
        then
            echo VPN连接正常
        else
            echo VPN已连接，但无法连接至内网，要不试试 $0 restart
        fi
    else
        echo VPN未连接
    fi
}
restart(){
    stop
    sleep 3s
    start
}
main(){
    check_root
    case $1 in
        stop) stop ;;
        check) check ;;
        restart) restart ;;
        *) start ;;
    esac
}
main $1