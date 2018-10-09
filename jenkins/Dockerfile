FROM currycan/openjdk:8-jre

LABEL maintainer "Platform/IIBU <zhangzhitao@fmsh.com.cn>"

RUN set -ex; yum update -y; \
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org; \
    rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm; \
    yum install -y subversion ansible git libtool-ltdl; \
    curl -o /etc/yum.repos.d/wandisco-svn.repo https://raw.githubusercontent.com/currycan/docker_image/master/jenkins/wandisco-svn.repo; \
    yum --disablerepo="*" --enablerepo="WandiscoSVN" install -y subversion; \
    yum clean all

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG JENKINS_HOME=/var/jenkins_home
ARG TINI_VERSION=v0.18.0
ARG JENKINS_VERSION

ENV JENKINS_VERSION ${JENKINS_VERSION:-2.138.1}
ENV JENKINS_HOME $JENKINS_HOME
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $JENKINS_HOME; \
    chown ${uid}:${gid} $JENKINS_HOME; \
    groupadd -g ${gid} ${group}; \
    useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Use tini as subreaper in Docker container to adopt zombie processes
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
ADD http://ftp.yz.yamagata-u.ac.jp/pub/misc/jenkins/war-stable/${JENKINS_VERSION}/jenkins.war /usr/share/jenkins/jenkins.war

# will be used by attached slave agents:
ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

# from a derived Dockerfile, can use `RUN plugins.sh plugins.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle
RUN set -ex; \
    mkdir -p /usr/share/jenkins/ref/init.groovy.d/; \
    curl -so /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy https://raw.githubusercontent.com/jenkinsci/docker/master/init.groovy; \
    curl -so /usr/local/bin/jenkins-support https://raw.githubusercontent.com/jenkinsci/docker/master/jenkins-support; \
    curl -so /usr/local/bin/jenkins.sh https://raw.githubusercontent.com/jenkinsci/docker/master/jenkins.sh; \
    curl -so /bin/tini https://raw.githubusercontent.com/jenkinsci/docker/master/tini-shim.sh; \
    curl -so /usr/local/bin/plugins.sh https://raw.githubusercontent.com/jenkinsci/docker/master/plugins.sh; \
    curl -so /usr/local/bin/install-plugins.sh https://raw.githubusercontent.com/jenkinsci/docker/master/install-plugins.sh; \
    chown -R ${user} $JENKINS_HOME /usr/share/jenkins/ref; \
    chmod +x /usr/local/bin/*; chmod +x /bin/tini; chmod +x /sbin/tini

USER ${user}

# for main web interface:
EXPOSE ${http_port} ${agent_port}

VOLUME $JENKINS_HOME

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]
