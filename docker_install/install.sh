#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

IP_FLAG=${IP:-192.168.43.92}
GOOGLE_FLAG=${GOOGLE:-www.google.com}

[[ $EUID -ne 0 ]] && echo -e "Error: This script must be run as root" && exit 1

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
    echo ">>>> install IIBU repo"
    mkdir -p /etc/docker/
    cat << EOF > /etc/docker/daemon.json
{
    "registry-mirrors": [
        "https://registry.docker-cn.com",
        "https://8trm4p9x.mirror.aliyuncs.com",
        "http://010a79c4.m.daocloud.io",
        "https://docker.mirrors.ustc.edu.cn/"
    ],
    "insecure-registries": ["192.168.39.0/24","192.168.43.0/24","harbor.iibu.com"],
    "storage-driver": "overlay2",
    "exec-opts": ["native.cgroupdriver=cgroupfs"],
    "max-concurrent-downloads": 10,
    "log-driver": "json-file",
    "log-level": "warn",
    "log-opts": {
       "max-size": "10m",
       "max-file": "3"
    }
}
EOF
    echo ">>>> IIBU docker deamon"
}

ali_repo(){
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
    curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    yum clean all
    yum makecache -y
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    echo "install aliyun repo"
    mkdir -p /etc/docker/
    cat << EOF > /etc/docker/daemon.json
{
    "insecure-registries": ["harbor.iibu.com"],
    "storage-driver": "overlay2",
    "exec-opts": ["native.cgroupdriver=cgroupfs"],
    "max-concurrent-downloads": 10,
    "log-driver": "json-file",
    "log-level": "warn",
    "log-opts": {
       "max-size": "10m",
       "max-file": "3"
    }
}
EOF
    echo ">>>> aliyun docker deamon"
}

native_repo(){
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum clean all
    yum makecache -y
    echo "install native repo"
    mkdir -p /etc/docker/
    cat << EOF > /etc/docker/daemon.json
{
    "insecure-registries": ["harbor.iibu.com"],
    "storage-driver": "overlay2",
    "exec-opts": ["native.cgroupdriver=cgroupfs"],
    "max-concurrent-downloads": 10,
    "log-driver": "json-file",
    "log-level": "warn",
    "log-opts": {
       "max-size": "10m",
       "max-file": "3"
    }
}
EOF
    echo ">>>> native docker deamon"
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
        cat >> /etc/hosts << EOL
$IP mirrors.fmsh.com
EOL
        iibu_repo
    fi
}

uninstall(){
    if type docker >/dev/null 2>&1; then
    yum remove docker -y \
               docker-client \
               docker-client-latest \
               docker-common \
               docker-latest \
               docker-latest-logrotate \
               docker-logrotate \
               docker-selinux \
               docker-engine-selinux \
               docker-engine
    systemctl disable docker
    rm -f /etc/systemd/system/multi-user.target.wants/docker.service 
   fi
} 

install(){
    yum -y install vim wget net-tools telnet epel-release lrzsz lsof bash-completion
    yum install -y python-pip
    pip install -U pip
    pip install -U docker-compose
    yum install -y docker-ce
    systemctl enable docker && systemctl start docker
    # \curl -o /usr/local/bin/docker-compose http://mirrors.fmsh.com:81/others/docker-compose
    # chmod +x /usr/local/bin/docker-compose
    cat <<EOF >  /etc/sysctl.d/docker.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
    sysctl --system
    systemctl daemon-reload && systemctl restart docker
    docker info
    docker-compose version
    echo "All done"
}

docker_install() {
    initial_repo
    uninstall
    install
}

if [ -n "$1" ] ;then
    if [ $1 = 'install' ];then
        docker_install
    elif [ $1 = 'uninstall' ]; then
        uninstall
    else
        echo "Please input 'install' to install or 'uninstall' to uninstall"
    fi
else
    docker_install
fi
