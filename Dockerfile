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

#!/bin/sh

# تنظیمات اولیه
AUUID=c0b3ef90-3402-11ec-8d3d-0242ac130003
PORT=8080
PARAM=chacha20-ietf-poly1305

# دانلود فایل‌ها
mkdir -p /etc/caddy /usr/share/caddy /etc/xray

# محتوای ساده HTML
echo "Xray Running - Powered by Railway" > /usr/share/caddy/index.html

# Caddyfile
cat <<EOF >/etc/caddy/Caddyfile
:$PORT
root * /usr/share/caddy
file_server
reverse_proxy /$AUUID-vmess localhost:10000
EOF

# پیکربندی Xray
cat <<EOF >/etc/xray/config.json
{
  "inbounds": [{
    "port": 10000,
    "protocol": "vmess",
    "settings": {
      "clients": [{
        "id": "$AUUID"
      }]
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": {
        "path": "/$AUUID-vmess"
      }
    }
  }],
  "outbounds": [{
    "protocol": "freedom"
  }]
}
EOF

# اجرای سرویس‌ها
tor &
xray -config /etc/xray/config.json &
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
