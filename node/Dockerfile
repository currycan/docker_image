FROM currycan/centos:7.5.1804

LABEL maintainer "Platform/IIBU <zhangzhitao@fmsh.com.cn>"

RUN set -ex && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash && \
    source ~/.bashrc && \
    nvm install v8.11.3 && \
    npm install -g cnpm --registry=https://registry.npm.taobao.org
