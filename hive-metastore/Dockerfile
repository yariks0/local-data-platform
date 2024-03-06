FROM azul/zulu-openjdk-debian:17

WORKDIR /opt

ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_VERSION=3.3.6
ENV METASTORE_HOME=/opt/hive
ENV METASTORE_VERSION=3.0.0
ENV LOG4J_VERSION=2.19.0
ENV LOG4J_LOCATION="https://repo1.maven.org/maven2/org/apache/logging/log4j"

RUN mkdir ${METASTORE_HOME}
RUN mkdir ${HADOOP_HOME}
RUN apt-get clean && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get -qqy install curl && \
    curl -L https://downloads.apache.org/hive/hive-standalone-metastore-${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | tar zxf - && \
    curl -L https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - && \
    mv apache-hive-metastore-${METASTORE_VERSION}-bin/* ${METASTORE_HOME} && \
    mv hadoop-${HADOOP_VERSION}/* ${HADOOP_HOME}

RUN apt-get install openssl libssl1.1 libexpat1 && \
    apt-get install -y libk5crypto3 libkrb5-3 libsqlite3-0

RUN curl -o ${METASTORE_HOME}/lib/postgresql-42.2.25.jre7.jar -L https://jdbc.postgresql.org/download/postgresql-42.2.25.jre7.jar

# Configure Hadoop AWS Jars to be available to hive
RUN ln -s ${HADOOP_HOME}/share/hadoop/tools/lib/*aws* ${METASTORE_HOME}/lib

COPY conf ${METASTORE_HOME}/conf

COPY scripts/entrypoint.sh ${METASTORE_HOME}/entrypoint.sh

# Remove vulnerable log4j version and install latest
RUN \
    rm -f ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-log4j12* && \
    rm -f ${HADOOP_HOME}/share/hadoop/common/lib/log4j* && \
    rm -f ${HADOOP_HOME}/share/hadoop/hdfs/lib/log4j*

RUN rm -f ${HADOOP_HOME}/share/hadoop/yarn/hadoop-yarn-applications-catalog-webapp-3.3.1.war && \
    rm -f ${METASTORE_HOME}/lib/log4j-*

RUN curl -o ${METASTORE_HOME}/lib/log4j-1.2-api-${LOG4J_VERSION}.jar ${LOG4J_LOCATION}/log4j-1.2-api/${LOG4J_VERSION}/log4j-1.2-api-${LOG4J_VERSION}.jar && \
    curl -o ${METASTORE_HOME}/lib/log4j-api-${LOG4J_VERSION}.jar ${LOG4J_LOCATION}/log4j-api/${LOG4J_VERSION}/log4j-api-${LOG4J_VERSION}.jar && \
    curl -o ${METASTORE_HOME}/lib/log4j-core-${LOG4J_VERSION}.jar ${LOG4J_LOCATION}/log4j-core/${LOG4J_VERSION}/log4j-core-${LOG4J_VERSION}.jar && \
    curl -o ${METASTORE_HOME}/lib/log4j-slf4j-impl-${LOG4J_VERSION}.jar ${LOG4J_LOCATION}/log4j-slf4j-impl/${LOG4J_VERSION}/log4j-slf4j-impl-${LOG4J_VERSION}.jar

# https://docs.oracle.com/javase/7/docs/technotes/guides/net/properties.html
# Java caches dns results forever, don't cache dns results forever:
RUN touch ${JAVA_HOME}/lib/security/java.security
RUN sed -i '/networkaddress.cache.ttl/d' ${JAVA_HOME}/lib/security/java.security
RUN sed -i '/networkaddress.cache.negative.ttl/d' ${JAVA_HOME}/lib/security/java.security
RUN echo 'networkaddress.cache.ttl=0' >> ${JAVA_HOME}/lib/security/java.security
RUN echo 'networkaddress.cache.negative.ttl=0' >> ${JAVA_HOME}/lib/security/java.security

# imagebuilder expects the directory to be created before VOLUME
RUN mkdir -p /var/lib/hive /.beeline ${HOME}/.beeline

# to allow running as non-root
RUN groupadd -r hive --gid=1000
RUN useradd -r -g hive --uid=1000 -d ${METASTORE_HOME} hive
RUN chown -R hive:hive ${METASTORE_HOME} ${HADOOP_HOME} /var/lib/hive /.beeline ${HOME}/.beeline /etc/passwd $(readlink -f ${JAVA_HOME}/lib/security/cacerts)
RUN chmod -R u+rwx,g+rwx ${METASTORE_HOME} ${HADOOP_HOME} /var/lib/hive /.beeline ${HOME}/.beeline /etc/passwd $(readlink -f ${JAVA_HOME}/lib/security/cacerts) && \
    chown hive:hive ${METASTORE_HOME}/entrypoint.sh && \
    chmod +x ${METASTORE_HOME}/entrypoint.sh

USER hive
WORKDIR $METASTORE_HOME
EXPOSE 9083

ENTRYPOINT ["sh", "-c", "/opt/hive/entrypoint.sh"]