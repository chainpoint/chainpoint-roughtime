FROM rust:1.29.0-stretch

LABEL MAINTAINER="Glenn Rempe <glenn@tierion.com>"

ENV TZ=UTC

# gosu : https://github.com/tianon/gosu
RUN apt-get update && apt-get install -y git gosu vim

# Tini : https://github.com/krallin/tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
#ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
#RUN gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 && gpg --verify /tini.asc
RUN chown root:root /tini && chmod 755 /tini

RUN useradd -ms /bin/bash roughenough

WORKDIR /

RUN git clone https://github.com/int08h/roughenough.git

WORKDIR /roughenough

# PIN Versions:
# 1.0.4 : 363943e525d8f3448b769e92be0c0afa25e3cfbc
RUN git reset --hard 363943e525d8f3448b769e92be0c0afa25e3cfbc

RUN cargo build --release

EXPOSE 2002/udp

ENTRYPOINT ["gosu", "roughenough:roughenough", "/tini", "--"]
CMD ["/roughenough/target/release/server", "/roughenough/roughenough.cfg"]
