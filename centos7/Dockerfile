FROM centos:7.5.1804

LABEL maintainer "Platform/IIBU <zhangzhitao@fmsh.com.cn>"

RUN set -xe && \
    \cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup && \
    curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && \
    yum makecache -y && yum update -y  && \
    yum -y install vim wget initscripts unzip net-tools telnet bash-completion lrzsz glibc-common kde-l10n-Chinese && \
    localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 && \
    yum clean all && \
    rm -rf /var/cache/yum/*

ENV TZ=Asia/Shanghai \
    LC_ALL=zh_CN.utf8

CMD ["/bin/bash"]
