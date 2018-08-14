
FROM currycan/centos:7.5.1804

LABEL maintainer "Platform/IIBU <zhangzhitao@fmsh.com.cn>"

ARG VERSION=6.3.2

RUN set -ex \
    && cd /tmp \
    && echo "===> Install apm-server..." \
    && wget -O apm-server.tar.gz http://195.154.164.217:8080/apm-server-${VERSION}.tar.gz \
    && tar -xf apm-server.tar.gz \
    && mv apm-server /usr/share/ \
    && groupadd -r apm-server \
    && useradd -r -g apm-server apm-server \
    && chown -R root:apm-server /usr/share/apm-server \
    && wget -O /usr/local/bin/docker-entrypoint.sh http://195.154.164.217:8080/source/apm-server/docker-entrypoint.sh \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && yum update -y \
    && rm -rf /tmp/* \
    && yum clean all

WORKDIR /usr/share/apm-server

ENV PATH=/usr/share/apm-server:$PATH ELASTIC_CONTAINER=true

VOLUME ["/usr/share/apm-server/data"]

EXPOSE 8200
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["-e"]
