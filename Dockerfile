FROM alpine:edge

# نصب ابزارهای مورد نیاز
RUN apk update && \
    apk add --no-cache \
    bash curl unzip tor wget caddy sed busybox ca-certificates

# نصب Xray
RUN wget -O xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -q xray.zip && \
    mv xray /xray && chmod +x /xray && rm -rf xray.zip

# کپی اسکریپت شروع
ADD start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
