FROM debian:stretch
LABEL maintainer="Dash Developers <dev@dash.org>"
LABEL description="Dockerised PigeonCore, built from Travis"

RUN apt-get update && apt-get -y upgrade && apt-get clean && rm -fr /var/cache/apt/*

COPY bin/* /usr/bin/
