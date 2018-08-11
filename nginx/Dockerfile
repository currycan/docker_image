FROM currycan/centos:7.5.1804

LABEL maintainer "Platform/IIBU <zhangzhitao@fmsh.com.cn>"

RUN set -xe && \
    yum install http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm -y && \
    yum update -y && \
    yum install -y nginx && \
    yum clean all && \
    mkdir -p /usr/share/nginx/config && \
    mv /etc/nginx/nginx.conf /usr/share/nginx/config/nginx.conf && \
    ln -sf /etc/nginx/nginx.conf /usr/share/nginx/config/nginx.conf

# USER 1001

EXPOSE 80 443

STOPSIGNAL SIGTERM

VOLUME /usr/share/nginx/html/ /etc/nginx/conf.d/ /usr/share/nginx/config/

CMD ["nginx", "-g", "daemon off;"]
