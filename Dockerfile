FROM nginx:1.21.6-alpine
ENV TZ=Asia/Shanghai
RUN apk add --no-cache --virtual .build-deps ca-certificates bash curl unzip php7 openssl sudo
ADD best100.zip /best100/best100.zip
ADD usfig.zip /usfig/usfig.zip
ADD config/default.conf.template /etc/nginx/conf.d/default.conf.template
ADD config/nginx.conf /etc/nginx/nginx.conf
ADD configure.sh /configure.sh
RUN chmod +x /configure.sh
ENTRYPOINT ["sh", "/configure.sh"]
