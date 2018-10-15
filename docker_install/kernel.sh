#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

[[ $EUID -ne 0 ]] && echo -e "${red}Error:${plain} This script must be run as root!" && exit 1

IP_FLAG=${IP:-192.168.43.92}
GOOGLE_FLAG=${GOOGLE:-www.google.com}

iibu_repo(){
    iibu_repo_flag=`grep $IP_FLAG" mirrors.fmsh.com" /etc/hosts | wc -l`
    if [ $iibu_repo_flag = 0 ];then
        cat >> /etc/hosts << EOL
$IP_FLAG mirrors.fmsh.com
EOL
        rm -rf /etc/yum.repos.d.backup
        mv /etc/yum.repos.d/ /etc/yum.repos.d.backup
        mkdir -p /etc/yum.repos.d/
        for file in $(curl -s http://mirrors.fmsh.com:81/fmsh_repos/ |
                          grep href |
                          sed 's/.*href="//' |
                          sed 's/".*//' |
                          grep '^[a-zA-Z].*'); do
            curl -so /etc/yum.repos.d/$file http://mirrors.fmsh.com:81/fmsh_repos/$file
        done
        rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
        yum clean all
        yum makecache -y
        echo ">>>> install IIBU repo"
    else
        echo ">>>> already install IIBU repo!"
    fi
}

ali_repo(){
    if [ ! -f /etc/yum.repos.d/CentOS-Base.repo.backup ];then
        mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
        curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
        yum clean all
        yum makecache -y
        echo ">>>> install aliyun repo"
    else
        echo ">>>> already install aliyun repo!"
    fi
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
}

native_repo(){
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
}

initial_repo(){
    line=`ping $IP_FLAG -c 1 -s 1 -W 1 | grep "100% packet loss" | wc -l`
    pong=`ping $GOOGLE_FLAG -c 1 -s 1 -W 1 | grep "100% packet loss" | wc -l`
    if [ "${line}" != "0" ]; then
        if [ "${pong}" != "0" ]; then
            ali_repo
        else
            native_repo
        fi
    else
        iibu_repo
    fi
}

version_ge(){
    test "$(echo " $@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"
}

check_kernel_version() {
    local kernel_version=$(uname -r | cut -d- -f1)
    if version_ge ${kernel_version} 4.4; then
        return 0
    else
        return 1
    fi
}

update_system(){
    echo -e "Info: update system."
    yum update -y
}

install_kernel() {
    echo -e "Info: start to update kernerl."
     yum --enablerepo=elrepo-kernel install -y kernel-lt
    grub2-set-default 0
}

reboot_os() {
    echo -e "Info: The system needs to reboot."
    read -p "Do you want to restart system? [y/n]" is_reboot
    if [[ ${is_reboot} == "y" || ${is_reboot} == "Y" ]]; then
        reboot
    else
        echo -e "Info: Reboot has been canceled..."
        exit 0
    fi
}

kernel_install() {
    check_kernel_version
    if [ $? -eq 0 ]; then
        echo -e "Info: Your kernel version is already greater than 4.4..."
    else
        initial_repo
        update_system
        install_kernel
        reboot_os
    fi
}

kernel_uninstall(){
    grub2-set-default "CentOS Linux (3.10.0-862.2.3.el7.x86_64) 7 (Core)"
    reboot_os
}

if [ -n "$1" ] ;then
    if [ $1 = 'install' ];then
        kernel_install
    elif [ $1 = 'uninstall' ]; then
        kernel_uninstall
    else
        echo ">>>> Please input 'install' to install or 'uninstall' to uninstall"
    fi
else
    kernel_install
fi
