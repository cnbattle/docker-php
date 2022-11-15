FROM php:8.0-alpine

ENV TZ Asia/Shanghai
ENV PHP_EXTENSIONS pdo_mysql,mysqli,mbstring,gd,curl,opcache,redis,zip,swoole,mongodb

COPY ./default/extensions /tmp/extensions
WORKDIR /tmp/extensions
RUN chmod +x install.sh \
    && sh install.sh \
    && rm -rf /tmp/extensions

ADD ./default/extensions/install-php-extensions  /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions

RUN apk --no-cache add tzdata \
    && cp "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone

# Fix: https://github.com/docker-library/php/issues/240
RUN apk add gnu-libiconv libstdc++ --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# php image's www-data user uid & gid are 82, change them to 1000 (primary user)
RUN apk --no-cache add shadow && usermod -u 1000 www-data && groupmod -g 1000 www-data

WORKDIR /www
