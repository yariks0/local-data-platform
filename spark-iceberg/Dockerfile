FROM python:3.11-bullseye

RUN apt update && \
    apt install -y --no-install-recommends sudo curl vim unzip openjdk-11-jdk tini \
    build-essential software-properties-common ssh && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

## Download spark and hadoop dependencies and install

# Optional env variables
ENV SPARK_HOME=${SPARK_HOME:-"/opt/spark"}
ENV HADOOP_HOME=${HADOOP_HOME:-"/opt/hadoop"}
ENV SPARK_VERSION=3.5.3
ENV SPARK_MAJOR_VERSION=3.5
ENV ICEBERG_VERSION=1.4.3
ENV HADOOP_VERSION=3.3.6

RUN mkdir -p ${HADOOP_HOME} && mkdir -p ${SPARK_HOME}
WORKDIR ${SPARK_HOME}

# Download spark
RUN curl https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz -o spark-${SPARK_VERSION}-bin-hadoop3.tgz \
    && tar xvzf spark-${SPARK_VERSION}-bin-hadoop3.tgz --directory /opt/spark --strip-components 1 \
    && rm -rf spark-${SPARK_VERSION}-bin-hadoop3.tgz

# Download postgres
RUN curl https://jdbc.postgresql.org/download/postgresql-42.2.24.jar -o postgresql-42.2.24.jar \
    && cp postgresql-42.2.24.jar /opt/spark/jars \
    && rm postgresql-42.2.24.jar

# Download iceberg spark runtime
RUN curl https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-${SPARK_MAJOR_VERSION}_2.12/${ICEBERG_VERSION}/iceberg-spark-runtime-${SPARK_MAJOR_VERSION}_2.12-${ICEBERG_VERSION}.jar -Lo /opt/spark/jars/iceberg-spark-runtime-${SPARK_MAJOR_VERSION}_2.12-${ICEBERG_VERSION}.jar

RUN curl -L https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - && \
    mv hadoop-${HADOOP_VERSION}/* ${HADOOP_HOME}

# Configure Hadoop AWS Jars to be available to hive
# temporal fix because of spark3.5.1 depends on voln 3.4.0 hadoop version 
# RUN ln -s ${HADOOP_HOME}/share/hadoop/tools/lib/*aws* ${SPARK_HOME}/jars
RUN curl https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar -Lo /opt/spark/jars/hadoop-aws-3.3.4.jar
RUN curl https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar -Lo /opt/spark/jars/aws-java-sdk-bundle-1.12.262.jar

RUN mkdir -p /home/iceberg/localwarehouse /home/iceberg/notebooks /home/iceberg/warehouse /home/iceberg/spark-events /home/iceberg

COPY spark-defaults.conf /opt/spark/conf

ENV PATH="/opt/spark/sbin:/opt/spark/bin:$PATH"
ENV SPARK_HOME="/opt/spark"
ENV SPARK_NO_DAEMONIZE=true

RUN chmod u+x /opt/spark/sbin/* && \
    chmod u+x /opt/spark/bin/*

COPY entrypoint.sh .

RUN chmod u+x /opt/spark/entrypoint.sh

ENTRYPOINT ["tini", "--", "/opt/spark/entrypoint.sh"]
