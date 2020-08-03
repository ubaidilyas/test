#!/bin/sh
FROM docker.io/centos:8
ARG stage
ARG live
ARG stoken
ARG ltoken
RUN yum install -y epel-release jq which wget unzip openssl git && yum clean all -y
RUN wget https://github.com/go-acme/lego/releases/download/v3.8.0/lego_v3.8.0_linux_amd64.tar.gz
RUN tar xf lego_v3.8.0_linux_amd64.tar.gz
RUN mv lego /usr/local/bin/lego
RUN wget https://releases.hashicorp.com/consul/1.8.0/consul_1.8.0_linux_amd64.zip
RUN unzip consul_1.8.0_linux_amd64.zip 
RUN mv consul /usr/local/bin/consul
WORKDIR /usr/local
COPY centos.sh .
RUN chmod +x /centos.sh
ENTRYPOINT ["/centos.sh"]
CMD ["link", "token"]



