FROM php:8.0.7-alpine

ENV TZ Asia/Shanghai
# Available PHP_EXTENSIONS:
#
# pdo_mysql,zip,pcntl,mysqli,mbstring,exif,bcmath,calendar,
# sockets,gettext,shmop,sysvmsg,sysvsem,sysvshm,pdo_rebird,
# pdo_dblib,pdo_oci,pdo_odbc,pdo_pgsql,pgsql,oci8,odbc,dba,
# gd,intl,bz2,soap,xsl,xmlrpc,wddx,curl,readline,snmp,pspell,
# recode,tidy,gmp,imap,ldap,imagick,sqlsrv,mcrypt,opcache,
# redis,memcached,xdebug,swoole,pdo_sqlsrv,sodium,yaf,mysql,
# amqp,mongodb,event,rar,ast,yac,yar,yaconf,msgpack,igbinary,
# seaslog,varnish,xhprof,xlswriter,memcache,rdkafka,zookeeper,
# psr,phalcon,sdebug,ssh2,yaml,protobuf
ENV PHP_EXTENSIONS pdo_mysql,mysqli,mbstring,gd,curl,opcache,redis,zip,swoole,pcntl
ENV CONTAINER_PACKAGE_URL mirrors.aliyun.com

RUN if [ $CONTAINER_PACKAGE_URL ] ; then sed -i "s/dl-cdn.alpinelinux.org/${CONTAINER_PACKAGE_URL}/g" /etc/apk/repositories ; fi

COPY ./extensions /tmp/extensions
WORKDIR /tmp/extensions
RUN chmod +x install.sh \
    && sh install.sh \
    && rm -rf /tmp/extensions

ADD ./extensions/install-php-extensions  /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions

RUN apk --no-cache add tzdata \
    && cp "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone

# Fix: https://github.com/docker-library/php/issues/240
RUN apk add gnu-libiconv libstdc++ --no-cache --repository http://${CONTAINER_PACKAGE_URL}/alpine/edge/community/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# Install composer and change it's cache home
RUN curl -o /usr/bin/composer https://mirrors.aliyun.com/composer/composer.phar \
    && chmod +x /usr/bin/composer
ENV COMPOSER_HOME=/tmp/composer

# php image's www-data user uid & gid are 82, change them to 1000 (primary user)
RUN apk --no-cache add shadow && usermod -u 1000 www-data && groupmod -g 1000 www-data

WORKDIR /www
