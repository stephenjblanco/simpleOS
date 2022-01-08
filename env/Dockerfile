FROM ubuntu:20.04

LABEL maintainer="sjblanc0000@gmail.com"
LABEL version="0.0"
LABEL description="Custom Docker image for building simpleOS."

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install make
RUN apt-get install binutils-i686-linux-gnu -y

VOLUME /root/env
WORKDIR /root/env