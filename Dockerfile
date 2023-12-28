FROM php:8.3.1-fpm-alpine3.18

LABEL Maintainer="Nurul Imam <bits.co.id>" \
    Description="Nginx & PHP-FPM v8.3 with some popular extensions of Alpine Linux."

LABEL org.opencontainers.image.vendor="Nurul Imam" \
    org.opencontainers.image.url="https://github.com/bitscoid/nginx-php" \
    org.opencontainers.image.source="https://github.com/bitscoid/nginx-php" \
    org.opencontainers.image.title="Nginx & PHP-FPM v8.3 Alpine" \
    org.opencontainers.image.description="Nginx & PHP-FPM v8.3 with some popular extensions of Alpine Linux." \
    org.opencontainers.image.version="3.0" \
    org.opencontainers.image.documentation="https://github.com/bitscoid/nginx-php"

# Configure PHP-FPM
RUN rm /usr/local/etc/php-fpm.conf.default && rm /usr/local/etc/php-fpm.d/www.conf.default
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
RUN sed -ie 's/memory_limit\ =\ 128M/memory_limit\ =\ 1024M/g' /usr/local/etc/php/php.ini
RUN sed -ie 's/\;date\.timezone\ =/date\.timezone\ =\ Asia\/Jakarta/g' /usr/local/etc/php/php.ini
RUN sed -ie 's/upload_max_filesize\ =\ 2M/upload_max_filesize\ =\ 64M/g' /usr/local/etc/php/php.ini
RUN sed -ie 's/post_max_size\ =\ 8M/post_max_size\ =\ 64M/g' /usr/local/etc/php/php.ini
COPY php/www.conf /usr/local/etc/php-fpm.d/www.conf

# Install Packages
RUN apk --no-cache --update add \
    bash \
    curl \
    nginx \
    supervisor \
    && curl http://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer \
    && apk add --no-cache --update libavif aom-libs freetype libxpm libxext libxt libx11 libxcb \
    libxdmcp libbsd libdav1d libsm libice libjpeg-turbo libmd libwebp libxau \
    libstdc++ shadow linux-headers \
    zip unzip coreutils libpng libmemcached-libs krb5-libs icu-libs \
    icu c-client libzip openldap-clients imap libcap tzdata sqlite \
    && set -xe \
    && apk add --no-cache --update --virtual .phpize-deps $PHPIZE_DEPS \
    && apk add --no-cache --update --virtual .all-deps gcc make libc-dev zlib-dev \
    libmemcached-dev cyrus-sasl-dev libpng-dev libxml2-dev krb5-dev curl-dev icu-dev \
    libzip-dev openldap-dev imap-dev libjpeg-turbo-dev freetype-dev libwebp-dev \
    && docker-php-ext-configure gd --with-jpeg --with-freetype --with-webp \
    && docker-php-ext-install exif gd imap intl ldap opcache pdo pdo_mysql soap sockets zip \
    && printf "\n\n\n\n" | pecl install -o -f redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable sockets \
    && pecl install msgpack && docker-php-ext-enable msgpack \
    && pecl install igbinary && docker-php-ext-enable igbinary \
    && printf "\n\n\n\n\n\n\n\n\n\n" | pecl install memcached \
    && docker-php-ext-enable memcached \
    && rm -rf /tmp/pear \
    && apk del .all-deps .phpize-deps \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Configure Nginx
RUN rm /etc/nginx/nginx.conf && rm /etc/nginx/http.d/default.conf
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/http.d/default.conf /etc/nginx/http.d/default.conf

# Configure Supervisord
COPY supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup Document Root
RUN rm -rf /var/www/html && rm -rf /var/www/localhost
RUN mkdir -p /var/www/bits
COPY app/index.php /var/www/bits/index.php
WORKDIR /var/www/bits
EXPOSE 80 443

# Script Installation
COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Make sure files/folders run under the nobody user
RUN chown -R nobody:nobody /var/www/bits /run /var/lib/nginx /var/log/nginx /usr/local/bin/composer /etc/nginx/http.d /usr/local/etc/php

# Switch to non-root user
USER nobody

# Run Script
CMD ["/run.sh"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1