FROM currycan/centos:7.5.1804

LABEL maintainer "Platform/IIBU <zhangzhitao@fmsh.com.cn>"

RUN set -xe && \
    curl -L -b "oraclelicense=a" -O http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jre-8u181-linux-x64.rpm && \
    yum localinstall -y jre-8u181-linux-x64.rpm && \
    rm -f *.rpm && \
    yum update -y && \
    yum clean all

ENV JAVA_OPTS="\
    -Duser.timezone=GMT+08 \
    -Djava.security.egd=/dev/urandom \
    -Djava.library.path=/usr/local/lib \
    -server \
    -XX:ReservedCodeCacheSize=64m \
    -XX:TLABWasteTargetPercent=10 \
    -XX:+UseConcMarkSweepGC \
    -XX:+CMSParallelRemarkEnabled \
    -XX:+ParallelRefProcEnabled \
    -XX:+CMSClassUnloadingEnabled \
    -XX:CMSInitiatingOccupancyFraction=70 \
    -XX:+UseCMSInitiatingOccupancyOnly \
    -XX:ParallelGCThreads=8 \
    -XX:ConcGCThreads=4 \
    -Xss256k \
    -Xms2g \
    -Xmx2g \
    -XX:MaxDirectMemorySize=256m \
    -XX:MaxTenuringThreshold=3 \
    -XX:NewRatio=1 \
    -XX:SurvivorRatio=8 \
    -XX:+UnlockDiagnosticVMOptions \
    -XX:ParGCCardsPerStrideChunk=32768 \
    -XX:+AlwaysPreTouch \
    -XX:MetaspaceSize=256m \
    -XX:MaxMetaspaceSize=512m \
    -XX:+UseParallelGC \
    -XX:+UseParallelOldGC \
    -XX:+UseAdaptiveSizePolicy \
    -XX:+PrintGCDetails \
    -XX:+PrintTenuringDistribution \
    -XX:+PrintGCTimeStamps \
    -XX:+HeapDumpOnOutOfMemoryError \
    -XX:HeapDumpPath=/ \
    -Xloggc:/gc.log \
    -XX:+UseGCLogFileRotation \
    -XX:NumberOfGCLogFiles=5 \
    -XX:GCLogFileSize=10M"
   
