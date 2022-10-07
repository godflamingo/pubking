#!/bin/sh
mkdir -p /usr/share/caddy/ /usr/share/caddy/letsencrypt/ /usr/share/caddy/cert/
#安装acme：
curl https://get.acme.sh | sh
#添加软链接：
ln -s  /root/.acme.sh/acme.sh /usr/local/bin/acme.sh
#切换CA机构： 
acme.sh --set-default-ca --server letsencrypt
#申请证书： 
acme.sh --issue -d kaddybug-production.up.railway.app -k ec-256 --webroot /usr/share/caddy/letsencrypt
acme.sh --list
#安装证书： 
acme.sh --installcert -d kaddybug-production.up.railway.app --ecc \
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
envsubst '\$APP_ID,\$APP_PATH,\$port' < /usfig/config1.json > /usfig/config.json
/usfig/usfig -config /usfig/config.json &
echo /best100/page.html
cat /best100/page.html
rm -rf /etc/nginx/sites-enabled/default
/bin/bash -c "envsubst '\$PORT,\$APP_PATH,\$domainName' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'