FROM currycan/centos:7.5.1804

LABEL maintainer "Platform/IIBU <zhangzhitao@fmsh.com.cn>"

RUN set -xe && \
    yum install http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm -y && \
    yum update -y && \
    yum install -y nginx && \
    yum clean all && \
    mkdir -p /nginx/config/ && \
    mv /etc/nginx/nginx.conf /nginx/config/nginx.conf && \
    ln -sf /nginx/config/nginx.conf /etc/nginx/nginx.conf

# USER 1001

EXPOSE 80 443

STOPSIGNAL SIGTERM

VOLUME /nginx/html/ /etc/nginx/conf.d/ /nginx/config/

CMD ["nginx", "-g", "daemon off;"]
