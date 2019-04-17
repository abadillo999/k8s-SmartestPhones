FROM ubuntu:xenial

RUN apt-get update && \
    apt-get install -y git && \
    apt-get install -y openjdk-8-jre openjdk-8-jdk maven

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre/
RUN echo ${JAVA_HOME}