FROM currycan/openjdk:8-jre

LABEL maintainer "Platform/IIBU <zhangzhitao@fmsh.com.cn>"

RUN set -ex; yum update -y; \
    yum install -y subversion git libltdl.so.7; \
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
ARG TINI_VERSION=v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
RUN set -ex; chmod +x /sbin/tini; mkdir -p /usr/share/jenkins/ref/init.groovy.d; \
    curl -so ${JENKINS_HOME}/tini_pub.gpg https://raw.githubusercontent.com/currycan/docker_image/master/jenkins/tini_pub.gpg; \
    curl -so /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy https://raw.githubusercontent.com/currycan/docker_image/master/jenkins/init.groovy;

# jenkins version being bundled in this docker image
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.121.1}

# jenkins.war checksum, download will be validated using it
ARG JENKINS_SHA=5bb075b81a3929ceada4e960049e37df5f15a1e3cfc9dc24d749858e70b48919

# Can be used to customize where jenkins.war get downloaded from
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
# see https://github.com/docker/docker/issues/8331
RUN set -ex; curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war; \
    echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c -

ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
RUN chown -R ${user} "$JENKINS_HOME" /usr/share/jenkins/ref

# for main web interface:
EXPOSE ${http_port}

# will be used by attached slave agents:
EXPOSE ${agent_port}

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

# from a derived Dockerfile, can use `RUN plugins.sh plugins.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle
RUN set -ex; \
    curl -so /usr/local/bin/jenkins-support https://raw.githubusercontent.com/currycan/docker_image/master/jenkins/jenkins-support; \
    curl -so /usr/local/bin/jenkins.sh https://raw.githubusercontent.com/currycan/docker_image/master/jenkins/jenkins.sh; \
    curl -so /bin/tini https://raw.githubusercontent.com/currycan/docker_image/master/jenkins/tini-shim.sh; \
    curl -so /usr/local/bin/plugins.sh https://raw.githubusercontent.com/currycan/docker_image/master/jenkins/plugins.sh; \
    curl -so /usr/local/bin/install-plugins.sh https://raw.githubusercontent.com/currycan/docker_image/master/jenkins/install-plugins.sh; \
    chmod +x /usr/local/bin/*; chmod +x /bin/tini;

USER ${user}

VOLUME $JENKINS_HOME

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]
