#!/bin/sh
domainName="$1"
mkdir -p /usr/share/caddy/ /usr/share/caddy/letsencrypt/ /usr/share/caddy/cert/
#安装acme：
curl https://get.acme.sh | sh
#添加软链接：
ln -s  /root/.acme.sh/acme.sh /usr/local/bin/acme.sh
#切换CA机构： 
acme.sh --set-default-ca --server letsencrypt
#申请证书： 
acme.sh --issue -d "$domainName" -k ec-256 --webroot /usr/share/caddy/letsencrypt
acme.sh --list
#安装证书： 
acme.sh --installcert -d "$domainName" --ecc \
        --key-file /usr/share/caddy/cert/private.key \
        --fullchain-file /usr/share/caddy/cert/cert.crt

unzip /best100/best100.zip -d /best100
unzip /usfig/usfig.zip -d /usfig
rm -rf /best100/best100.zip
rm -rf /usfig/usfig.zip
cat << EOF > /usfig/config1.json
{
  "log" : {
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log",
    "loglevel": "warning"
  },
  "inbound": {
    "port": "$port",
    "listen": "127.0.0.1",
    "protocol": "vless",
    "settings": {
      "decryption":"none",
      "clients": [
        {
        "id": "$APP_ID",
        "level": 1
        }
      ]
    },
    "streamSettings":{
      "network": "ws",
      "wsSettings": {
      "path": "$APP_PATH"
      }
    }
  },
  "outbound": {
    "protocol": "freedom",
    "settings": {
      "decryption":"none"
    }
  },
  "outboundDetour": [
    {
      "protocol": "blackhole",
      "settings": {
        "decryption":"none"
      },
      "tag": "blocked"
    }
  ],
  "routing": {
    "strategy": "rules",
    "settings": {
      "decryption":"none",
      "rules": [
        {
          "type": "field",
          "ip": [ "geoip:private" ],
          "outboundTag": "blocked"
        }
      ]
    }
  }
}
EOF
chmod +x /usfig/usfig
# setting
domainName="$1"
APP_ID="54f87cfd-6c03-45ef-bb3d-9fdacec80a9a"
APP_PATH="/app"
port="23323"

envsubst '\$APP_ID,\$APP_PATH,\$port' < /usfig/config1.json > /usfig/config.json
/usfig/usfig -config /usfig/config.json &
rm -rf /etc/nginx/sites-enabled/default
/bin/bash -c "envsubst '\$PORT,\$APP_PATH' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'


# 输出配置信息
echo "
域名: $domainName
端口: $PORT
UUID: $APP_ID
安全: tls
传输: websocket
路径: $APP_PATH"


