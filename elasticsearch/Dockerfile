FROM currycan/openjdk:8-jre

LABEL maintainer "Platform/IIBU <zhangzhitao@fmsh.com.cn>"

ARG VERSION=6.3.2

RUN set -ex \
    && cd /tmp \
    && echo "===> Install Elasticsearch..." \
    && wget -O elasticsearch.tar.gz http://195.154.164.217:8080/elasticsearch-${VERSION}.tar.gz \
    && tar -xf elasticsearch.tar.gz \
    && mv elasticsearch /usr/share/ \
    && groupadd -r elasticsearch \
    && useradd -r -g elasticsearch elasticsearch \
    && chown -R elasticsearch:elasticsearch /usr/share/elasticsearch \
    && wget -O /usr/local/bin/docker-entrypoint.sh http://195.154.164.217:8080/source/elasticsearch/docker-entrypoint.sh \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && yum update -y \
    && rm -rf /tmp/* \
    && yum clean all

WORKDIR /usr/share/elasticsearch

ENV PATH=/usr/share/elasticsearch/bin:$PATH \
    ES_HTTP_PORT="9200" \
    ES_TCP_PORT="9300"

# HEALTHCHECK --timeout=5s CMD wget -q -O - http://$HOSTNAME:$ES_HTTP_PORT/_cat/health

VOLUME ["/usr/share/elasticsearch/data","/usr/share/elasticsearch/logs"]

EXPOSE 9200 9300
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["eswrapper"]

# echo vm.max_map_count=262144 >> /etc/sysctl.conf
# sysctl -p
