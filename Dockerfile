FROM alpine:3.18

RUN apk update && \
    apk add --no-cache wget unzip curl sed tor caddy bash && \
    wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip && \
    mv xray /usr/local/bin/xray && \
    chmod +x /usr/local/bin/xray && \
    rm -rf Xray-linux-64.zip geosite.dat geoip.dat

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/bin/sh", "/start.sh"]
