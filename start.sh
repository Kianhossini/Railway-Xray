#!/bin/sh

# configs
AUUID=c0b3ef90-3402-11ec-8d3d-0242ac130003
CADDYIndexPage=https://github.com/AYJCSGM/mikutap/archive/master.zip
CONFIGCADDY=https://raw.githubusercontent.com/Kianhossini/Railway-Xray/main/etc/Caddyfile
CONFIGXRAY=https://raw.githubusercontent.com/Kianhossini/Railway-Xray/main/etc/xray.json
ParameterSSENCYPT=chacha20-ietf-poly1305
StoreFiles=https://raw.githubusercontent.com/Kianhossini/Railway-Xray/main/etc/StoreFiles
PORT=8080

# prepare filesystem
mkdir -p /etc/caddy/ /usr/share/caddy && \
echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt

# download files
wget $CADDYIndexPage -O /tmp/index.zip && \
unzip -qo /tmp/index.zip -d /tmp/web && \
mv /tmp/web/*/* /usr/share/caddy/

wget -qO- $CONFIGCADDY | \
sed -e "1c :$PORT" \
    -e "s/\$AUUID/$AUUID/g" \
    -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" \
    >/etc/caddy/Caddyfile

wget -qO- $CONFIGXRAY | \
sed -e "s/\$AUUID/$AUUID/g" \
    -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" \
    >/xray.json

# fetch and prepare store files
mkdir -p /usr/share/caddy/$AUUID && \
wget -O /usr/share/caddy/$AUUID/StoreFiles $StoreFiles && \
wget -P /usr/share/caddy/$AUUID -i /usr/share/caddy/$AUUID/StoreFiles

# generate download page
for file in $(ls /usr/share/caddy/$AUUID); do
  [ "$file" != "StoreFiles" ] && \
  echo "<a href=\"$file\" download>$file</a><br>" >>/usr/share/caddy/$AUUID/ClickToDownloadStoreFiles.html
done

# start services
tor &
/xray -config /xray.json &
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
