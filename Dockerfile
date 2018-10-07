# Copyright 2018 Tierion
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

##
## FIRST STAGE : BUILD BINARIES
##

FROM rust:1.29.1-stretch AS build-env

# Tini : https://github.com/krallin/tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
RUN gpg --no-tty --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 && \
    gpg --verify /tini.asc && \
    chown root:root /tini && \
    chmod 755 /tini

# Checkout the specific release tag of Roughenough
ENV ROUGHENOUGH_VERSION 1.0.6
RUN git clone https://github.com/int08h/roughenough.git && \
    cd /roughenough && \
    git fetch --all --tags --prune && \
    git checkout tags/${ROUGHENOUGH_VERSION} -b ${ROUGHENOUGH_VERSION} && \
    cargo build --release

##
## SECOND STAGE : PACKAGE BINARIES WITHOUT COMPILER TOOLS
##

FROM debian:9.5-slim

LABEL MAINTAINER="Glenn Rempe <glenn@tierion.com>"

# Install gosu : https://github.com/tianon/gosu
# and create roughenough user
RUN apt-get update && \
    apt-get install -y gosu && \
    useradd -ms /bin/bash roughenough

# Copy only binaries from build image to this dist image
COPY --from=build-env /tini /tini
COPY --from=build-env /roughenough/target/release/roughenough-server /usr/local/bin
COPY --from=build-env /roughenough/target/release/roughenough-client /usr/local/bin

WORKDIR /roughenough

EXPOSE 2002/udp

ENTRYPOINT ["gosu", "roughenough:roughenough", "/tini", "--"]

CMD ["roughenough-server", "/roughenough/roughenough.cfg"]
