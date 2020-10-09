#!/usr/bin/env bash
sh_ver="1.5"
MotionPro_ver="1.2.7"
MotionPro_file="/usr/bin/MotionPro"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
check_ip=202.207.240.243
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
script_path=$(readlink -f "$0")
check_root() {
    [[ $EUID != 0 ]] && echo -e "${Red_font_prefix}Ohhhhh!${Font_color_suffix}\nplease run it by ${Green_font_prefix}sudo $0 ${Font_color_suffix}(may need your password)" && exit 1
}
check_sys() {
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
        elif cat /etc/issue | grep -q -E -i "ubuntu"; then
        release="ubuntu"
        elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
        elif cat /proc/version | grep -q -E -i "ubuntu"; then
        release="ubuntu"
        elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    fi
    bit=$(uname -m)
}
install_motionpro() {
    echo -e "installing MotionPro"
    if [ ${release} == 'ubuntu' ]; then
        apt update && apt install -y curl
        system="Ubuntu"
    else
        yum install -y curl
        system="CentOS"
    fi
    if [ -f ./src/MotionPro_Linux_${system}_x64_v${MotionPro_ver}.sh ]; then
        sh ./src/MotionPro_Linux_${system}_x64_v${MotionPro_ver}.sh
        if [[ -f ${MotionPro_file} ]]; then
            echo -e "MotionPro installed\nplease run it again to configurate and run"
        else
            echo -e "${Red_font_prefix}MotionPro install failed${Font_color_suffix}" && exit 1
        fi
    else
        echo -e "${Red_font_prefix}MotionPro installer not found${Font_color_suffix}" && exit 1
    fi
}
add_route() {
    route del -net 0.0.0.0 gw 1.1.1.1 dev tun0
    route add -net 0.0.0.0 gw ${route_gateway} dev ${route_interface}
    route add -net 202.207.0.0 netmask 255.255.0.0 gw 1.1.1.1 dev tun0
    route add -net 219.226.0.0 netmask 255.255.0.0 gw 1.1.1.1 dev tun0
}
ac_login() {
    curl 'http://219.226.127.250:801/eportal/?c=ACSetting&a=Login&wlanuserip=null&wlanacip=null&wlanacname=null&port=&iTermType=1&mac=123456789012&ip=000.000.000.000&redirect=null' -H 'Connection: keep-alive' -H 'Content-Type: application/x-www-form-urlencoded' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36' -H "Cookie: divshowUID=${username}; md5_login=${username}%7C${password}; PHPSESSID=sbtsjh237ps9q23qm3es6jfpa1" --data "DDDDD=${username}&upass=${password}&save_me=1" --compressed --insecure
}
crontab() {
    check
    status=$?
    [[ ${status} -eq 2 ]] && restart
    [[ ${status} -eq 1 ]] && ac_login
}
stop() {
    MotionPro -s
    sleep 1s
    pkill -9 vpnd
    echo -e "MotionPro stopped"
    if [ ${release} == 'ubuntu' ]; then
        sed -i '/tyut crontab/d' /var/spool/cron/crontabs/root
    else
        sed -i '/tyut crontab/d' /var/spool/cron/root
    fi
    echo -e "cron deleted"
}
start() {
    route_gateway=$(route -n | grep -w "UG" | awk '{print $2}' | head -1)
    route_interface=$(route -n | grep -w "UG" | awk '{print $8}' | head -1)
    if [[ -f ${MotionPro_file} ]]; then
        if [[ -n ${username} && -n ${password} ]]; then
            if [ $(route -n | awk '$8=="tun0"{print $8}' | wc -l) -gt 0 ]; then
                echo -e "MotionPro is running"
            else
                if [ $(ps -C vpnd --no-header | wc -l) -eq 0 ]; then
                    echo -e "starting vpnd"
                    vpnd
                else
                    echo -e "vpnd is running"
                fi
                MotionPro -q -h vpn1.tyut.edu.cn -u $username -p $password
                if [ $? -eq 0 ]; then
                    sleep 1s
                    add_route
                    sleep 2s
                    ac_login
                    check
                else
                    echo -e "connection failed" && exit 1
                fi
                if [ ${release} == 'ubuntu' ]; then
                    echo "*/1 * * * * ${0} crontab >>/tmp/tyut.log 2>&1" >>/var/spool/cron/crontabs/root
                else
                    echo "*/1 * * * * ${0} crontab >>/tmp/tyut.log 2>&1" >>/var/spool/cron/root
                fi
                if [ $? -eq 0 ]; then
                    echo -e "cron added"
                else
                    echo -e "failed to add cron"
                fi
            fi
        else
            echo -e "starting configurate your campus account"
            read -p "set your campus account's username：" username
            read -s -p "set your campus account's password：" password
            echo -e "configurating ..."
            start
            [[ $? -eq 0 ]] && echo -e "configurate success"
            sed -i "2i\username=${username}\npassword=${password}" $script_path
        fi
    else
        echo -e "waiting for installing MotionPro"
        install_motionpro
    fi
}
check() {
    if [ $(route -n | awk '$8=="tun0"{print $8}' | wc -l) -gt 0 ]; then
        ping -c1 $check_ip >>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "vpn connected, and it seems ok" && return 0
        else
            echo -e "vpn connected, but can't connect the campus network" && return 1
        fi
    else
        echo -e "vpn not connect" && return 2
    fi
}
restart() {
    stop
    sleep 3s
    start
}
reset() {
    read -p "reset your campus account's username：" new_user
    read -s -p "reset your campus account's password：" new_password
    sed -i "/username=/d" $script_path
    sed -i "/password=/d" $script_path
    sed -i "2i\username=${new_user}\npassword=${new_password}" $script_path
    echo -e "campus account reseted"
}
echo_help() {
    echo -e "
A script that helps you to connect tyut's campus network.

usage, wiki or report bug: ${Green_font_prefix}https://github.com/bla58351/tyut-novpn${Font_color_suffix}
    "
}
main() {
    check_root
    check_sys
    [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "this script doesn't support the system!" && exit 1
    [[ ${bit} != "x86_64" ]] && echo -e "this script doesn't support non-x64 system" && exit 1
    case $1 in
        help)
            echo_help
        ;;
        stop)
            stop
        ;;
        check)
            check
        ;;
        restart)
            restart
        ;;
        crontab)
            crontab
        ;;
        start)
            start
        ;;
        reset)
            reset
        ;;
        *)
            echo_help
        ;;
    esac
}
main $1
