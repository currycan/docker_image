
FROM currycan/centos:7.5.1804

LABEL maintainer "Platform/IIBU <zhangzhitao@fmsh.com.cn>"

RUN groupadd vsftpd; useradd -g vsftpd vsftpd; usermod -aG vsftpd vsftpd 

ARG GOSU_VERSION=1.10
# $(dpkg --print-architecture)
ARG OS=amd64
RUN set -x; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$OS"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$OS.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    chmod +x /usr/local/bin/gosu; \
    gosu nobody true

RUN set -ex; yum -y update; \
    yum install -y vsftpd db4-utils db4 ftp; \
    yum clean all; rm -rf /var/cache/yum/*

ARG version=1.0.0

RUN set -ex; \
    curl -so /entrypoint.sh https://raw.githubusercontent.com/currycan/docker_image/master/vsftpd/run-vsftpd.sh; \
    curl -so /etc/pam.d/vsftpd_virtual https://raw.githubusercontent.com/currycan/docker_image/master/vsftpd/vsftpd_virtual; \
    curl -so /etc/vsftpd/vsftpd.conf https://raw.githubusercontent.com/currycan/docker_image/master/vsftpd/vsftpd.conf; \
    chmod +x /entrypoint.sh

VOLUME /home/vsftpd /var/log/vsftpd

EXPOSE 20 21

ENTRYPOINT ["/entrypoint.sh"]

CMD ["vsftpd"]
