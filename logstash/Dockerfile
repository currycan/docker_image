FROM currycan/openjdk:8-jre

LABEL maintainer "Platform/IIBU <zhangzhitao@fmsh.com.cn>"

ARG VERSION=6.3.2

RUN set -ex \
    && cd /tmp \
    && echo "===> Install Logstash..." \
    && wget -O logstash.tar.gz http://195.154.164.217:8080/logstash-${VERSION}.tar.gz \
    && tar -xf logstash.tar.gz \
    && mv logstash /usr/share/ \
    && groupadd -r logstash \
    && useradd -r -g logstash logstash \
    && chown -R logstash:root /usr/share/logstash \
    && wget -O /usr/local/bin/docker-entrypoint.sh http://195.154.164.217:8080/source/logstash/docker-entrypoint.sh \
    && wget -O /usr/local/bin/env2yaml http://195.154.164.217:8080/source/logstash/env2yaml \
    && chmod +x /usr/local/bin/* \
    && yum update -y \
    && rm -rf /tmp/* \
    && yum clean all

WORKDIR /usr/share/logstash

ENV PATH /usr/share/logstash/bin:$PATH

VOLUME ["/usr/share/logstash/data","/usr/share/logstash/pipeline"]

EXPOSE 9600 5044 5045
CMD ["docker-entrypoint.sh"]
