FROM alpine:edge

RUN apk update && \
    apk add --no-cache ca-certificates caddy tor wget unzip && \
    wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -O /tmp/xray.zip && \
    unzip /tmp/xray.zip -d /tmp/xray && \
    mv /tmp/xray/xray /xray && \
    chmod +x /xray && \
    rm -rf /tmp/*

ADD start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
