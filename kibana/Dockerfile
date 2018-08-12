FROM currycan/openjdk:8-jre

LABEL maintainer "Platform/IIBU <zhangzhitao@fmsh.com.cn>"

ARG VERSION=6.3.2

RUN set -ex \
    && cd /tmp \
    && echo "===> Install Kibana..." \
    && wget -O kibana.tar.gz http://195.154.164.217:8080/kibana-${VERSION}.tar.gz \
    && tar -xf kibana.tar.gz \
    && mv kibana /usr/share/ \
    && groupadd -r kibana \
    && useradd -r -g kibana kibana \
    && chown -R kibana:root /usr/share/kibana \
    && wget -O /usr/local/bin/docker-entrypoint.sh http://195.154.164.217:8080/source/kibana/docker-entrypoint.sh \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && yum update -y \
    && rm -rf /tmp/* \
    && yum clean all

WORKDIR /usr/share/kibana

ENV PATH /usr/share/kibana/bin:$PATH

VOLUME ["/usr/share/elasticsearch/data"]

EXPOSE 5601
CMD ["docker-entrypoint.sh"]
