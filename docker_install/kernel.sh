#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

[[ $EUID -ne 0 ]] && echo -e "${red}Error:${plain} This script must be run as root!" && exit 1

IP=${IP:-192.168.43.92}

iibu_repo(){
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
    echo "install IIBU repo"
}

ali_repo(){
    # mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
    # curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
    yum clean all
    yum makecache -y
    echo "install aliyun repo"
}

initial_repo(){
    line=`ping $IP -c 1 -s 1 -W 1 | grep "100% packet loss" | wc -l`
    if [ "${line}" != "0" ]; then
        ali_repo
    else
        cat >> /etc/hosts << EOL
$IP mirrors.fmsh.com
EOL
        iibu_repo
    fi
}

version_ge(){
    test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"
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
    is_reboot="y"
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
    grub2-set-default "CentOS Linux (3.10.0-514.el7.x86_64) 7 (Core)"
    reboot_os
}

if [ -n "$1" ] ;then
    if [ $1 = 'install' ];then
        kernel_install
    elif [ $1 = 'uninstall' ]; then
        kernel_uninstall
    else
        echo "Please input 'install' to install or 'uninstall' to uninstall"
    fi
else
    kernel_install
fi
