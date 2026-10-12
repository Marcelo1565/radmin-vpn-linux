FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV WINEDEBUG=-all
ENV NOVNC_PATH=/usr/share/novnc

RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg \
    gcc make mingw-w64 pkg-config \
    libgtk-4-dev upx-ucl \
    python3 \
    xvfb x11vnc websockify novnc \
    iproute2 iptables iputils-ping \
    procps sudo cabextract winbind \
    fonts-liberation \
 && mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://dl.winehq.org/wine-builds/winehq.key \
    -o /etc/apt/keyrings/winehq-archive.key \
 && curl -fsSL https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources \
    -o /etc/apt/sources.list.d/winehq.sources \
 && apt-get update \
 && apt-get install -y --install-recommends winehq-stable \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/radmin

COPY . /opt/radmin/

RUN printf '#!/bin/sh\nif [ "$1" = "-v" ]; then exit 0; fi\nif [ "$#" -eq 0 ]; then exit 0; fi\nexec "$@"\n' \
      > /usr/local/bin/sudo \
 && chmod +x /usr/local/bin/sudo \
 && chmod +x /opt/radmin/run_datacenter.sh \
 && chmod +x /opt/radmin/docker-entrypoint.sh \
 && make

EXPOSE 6080

ENTRYPOINT ["/opt/radmin/docker-entrypoint.sh"]
