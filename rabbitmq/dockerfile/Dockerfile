FROM rabbitmq:3.7-management

LABEL maintainer "Platform/IIBU <zhangzhitao@fmsh.com.cn>"
LABEL base="rabbitmq:3.7-management"

RUN set -ex && \
    buildDeps=" \
        wget \
        unzip \
    " && \
    apt-get update && \
    apt-get install -y ${buildDeps} --no-install-recommends && \
    wget --no-check-certificate -O /usr/local/bin/cluster_entrypoint.sh https://raw.githubusercontent.com/currycan/rabbitmq/master/source/rabbitmq/cluster_entrypoint.sh && \
    chmod +x /usr/local/bin/cluster_entrypoint.sh && \
    wget --no-check-certificate -O /usr/local/bin/docker-entrypoint.sh https://raw.githubusercontent.com/currycan/rabbitmq/master/source/rabbitmq/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    wget --no-check-certificate -O /usr/local/bin/rabbitmq-dump-queue https://raw.githubusercontent.com/currycan/rabbitmq/master/source/rabbitmq/rabbitmq-dump-queue && \
    chmod +x /usr/local/bin/rabbitmq-dump-queue && \
    apt-get purge -y --auto-remove $buildDeps && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/* && \

    rabbitmq-plugins enable --offline rabbitmq_federation && \
    rabbitmq-plugins enable --offline rabbitmq_federation_management && \
    rabbitmq-plugins enable --offline rabbitmq_shovel && \
    rabbitmq-plugins enable --offline rabbitmq_shovel_management

# COPY source/rabbitmq /usr/local/bin

ENV TZ=Asia/Shanghai \
    RABBITMQ_NODE_IP_ADDRESS=0.0.0.0 \
    RABBITMQ_NODE_PORT=5672 \
    RABBITMQ_SASL_LOGS=/var/lib/rabbitmq/logs \
    RABBITMQ_LOG_BASE=/var/lib/rabbitmq/logs \
    # RABBITMQ_LOGS=/var/lib/rabbitmq/logs/RABBITMQ_NODENAME.log \
    RABBITMQ_DEFAULT_USER=user \
    RABBITMQ_DEFAULT_PASS=password \
    RABBITMQ_DEFAULT_VHOST=/

ENTRYPOINT ["cluster_entrypoint.sh","docker-entrypoint.sh"]

EXPOSE 4369 5671 5672 15672 25672
CMD ["rabbitmq-server"]
