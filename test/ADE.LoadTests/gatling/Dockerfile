# Setup an environment to run gatling
# Based on https://github.com/denvazh/gatling
FROM openjdk:8-jdk-alpine

# Configuration
ENV GATLING_VERSION 3.5.1

# Set Working Directory and Create Some Structure
WORKDIR /opt
RUN mkdir -p gatling

# Install
RUN    apk update \
    && apk upgrade \
    && apk add wget bash libc6-compat \
    && mkdir -p /tmp/downloads \
    && wget -q -O /tmp/downloads/gatling-$GATLING_VERSION.zip https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/$GATLING_VERSION/gatling-charts-highcharts-bundle-$GATLING_VERSION-bundle.zip \
    && mkdir -p /tmp/archive && cd /tmp/archive \
    && unzip /tmp/downloads/gatling-$GATLING_VERSION.zip \
    && mv /tmp/archive/gatling-charts-highcharts-bundle-$GATLING_VERSION/* /opt/gatling/ \
    && rm -rf /tmp/*

# Switch to Gatling Direcotry
WORKDIR  /opt/gatling

# Remove Samples and Copy Ours
RUN rm -Rf /opt/gatling/user-files/resources/* && rm -Rf /opt/gatling/user-files/simulations/*
COPY ./simulations/ ./user-files/simulations/

# set directories below to be mountable from host
VOLUME ["/opt/gatling/conf", "/opt/gatling/results", "/opt/gatling/user-files/simulations/", "/opt/gatling/user-files/data/"]

# set environment variables
ENV PATH /opt/gatling/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV GATLING_HOME /opt/gatling
ENV JAVA_OPTS ""

ENTRYPOINT ["gatling.sh"]