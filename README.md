<div>
  <div align="center">
    <a href="https://bits.co.id">
      <img
        alt="Banten IT Solutions"
        src="https://bits.co.id/wp-content/uploads/Logo.png"
        width="150">
    </a>
  </div>

  <h1 align="center">Docker PHP-FPM 7.4 & Nginx 1.25 on Alpine Linux</h1>

  <h4 align="center">
    Lightweight & optimized <a href="https://www.docker.com/blog/how-to-rapidly-build-multi-architecture-images-with-buildx/">Multi-Arch Docker Images</a> (<code>x7.46_64</code>/<code>arm</code>/<code>arm64</code>) for <a href="http://nginx.org/en/CHANGES">Nginx 1.25.3</a> & <a href="https://www.php.net/manual/en/install.fpm.php">PHP-FPM</a> <a href="https://www.php.net/ChangeLog-7.4.php#PHP_7.4_3">7.4</a>) with essential extensions on top of latest Alpine Linux.
  </h4>

  <div align="center">
    <a href="https://hub.docker.com/r/bantenitsolutions/nginx-php/" title="Nginx PHP"><img src="https://img.shields.io/docker/pulls/bantenitsolutions/nginx-php.svg"></a> 
    <a href="https://hub.docker.com/r/bantenitsolutions/nginx-php/" title="Docker Image Version"><img src="https://img.shields.io/docker/v/bantenitsolutions/nginx-php/3.0"></a> 
    <a href="https://hub.docker.com/r/bantenitsolutions/nginx-php/tags" title="Docker Image Size"><img src="https://img.shields.io/docker/image-size/bantenitsolutions/nginx-php/3.0"></a> 
    <a href="https://hub.docker.com/r/bantenitsolutions/nginx-php/" title="Nginx 1.25.3"><img src="https://img.shields.io/badge/nginx-1.25.3-brightgreen.svg"></a> 
    <a href="https://hub.docker.com/r/bantenitsolutions/nginx-php/" title="PHP 7.4"><img src="https://img.shields.io/badge/php-7.4-brightgreen.svg"></a> 
    <a href="https://github.com/bitscoid/nginx-php/actions/workflows/build.yml" title="Docker Test Image"><img src="https://github.com/bitscoid/nginx-php/actions/workflows/build.yml/badge.svg?branch=master"></a> 
    <a href="https://bits.co.id" title="License MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg"></a> 
  </div>
</div>


## Description

Example PHP-FPM 7.4 & Nginx 1.25 container image for Docker, built on [Alpine Linux](https://www.alpinelinux.org/).

Repository: https://github.com/bitscoid/nginx-php

* Built on the lightweight and secure Alpine Linux distribution
* Multi-platform, supporting AMD4, ARMv6, ARMv7, ARM64
* Very small Docker image size (+/-74MB)
* Uses PHP 7.4 for the best performance, low CPU usage & memory footprint
* Optimized for 100 concurrent users
* Optimized to only use resources when there's traffic (by using PHP-FPM's `on-demand` process manager)
* The services Nginx, PHP-FPM and supervisord run under a non-privileged user (nobody) to make it more secure
* The logs of all the services are redirected to the output of the Docker container (visible with `docker logs -f <container name>`)

I can help you with [Web & App Development, Containerization, Kubernetes, Monitoring, Infrastructure as Code.](https://bits.co.id).

## Goal of this project
The goal of this container image is to provide an example for running Nginx and PHP-FPM in a container which follows
the best practices and is easy to understand and modify to your needs.

## Nginx & PHP Version

    # php -v
    PHP 7.4.0 (cli) (built: Nov 30 2023 23:39:07) (NTS)
    Copyright (c) The PHP Group
    Zend Engine v4.3.0, Copyright (c) Zend Technologies
        with Zend OPcache v7.4.0, Copyright (c), by Zend Technologies
        
    # nginx -v
    nginx version: nginx/1.24.0

## PHP Modules

    # php -m
    [PHP Modules]
    Core
    ctype
    curl
    date
    dom
    exif
    fileinfo
    filter
    ftp
    gd
    hash
    iconv
    igbinary
    imap
    intl
    json
    ldap
    libxml
    mbstring
    memcached
    msgpack
    mysqlnd
    openssl
    pcre
    PDO
    pdo_mysql
    pdo_sqlite
    Phar
    posix
    random
    readline
    redis
    Reflection
    session
    SimpleXML
    soap
    sockets
    sodium
    SPL
    sqlite3
    standard
    tokenizer
    xml
    xmlreader
    xmlwriter
    Zend OPcache
    zip
    zlib
    
    [Zend Modules]
    Zend OPcache
    
    # php -r "echo sprintf(\"GD SUPPORT %s\n\", json_encode(gd_info()));"
    GD SUPPORT {"GD Version":"bundled (2.1.0 compatible)","FreeType Support":true,"FreeType Linkage":"with freetype","GIF Read Support":true,"GIF Create Support":true,"JPEG Support":true,"PNG Support":true,"WBMP Support":true,"XPM Support":false,"XBM Support":true,"WebP Support":true,"BMP Support":true,"AVIF Support":false,"TGA Read Support":true,"JIS-mapped Japanese Font Support":false}

## Usage

Start the Docker container:

    docker run -p 80:80 bantenitsolutions/nginx-php

See the PHP info on http://localhost

Or mount your own code to be served by PHP-FPM & Nginx

    docker run -p 80:80 -v ~/app:/var/www/bits bantenitsolutions/nginx-php

For example, use this docker image to deploy a **Laravel 10** project.

Dockerfile:

```dockerfile
FROM bitscoid/nginx-php

# copy source code
COPY . /var/www/bits

# run.sh will replace default web root from /var/www/bits to $WEBROOT
ENV WEBROOT /var/www/bits/public

# run.sh will use redis as session store with docker container name $PHP_REDIS_SESSION_HOST
ENV REDIS_HOST redis

# download required node/php packages, 
# some node modules need gcc/g++ to build
RUN cd /var/www/bits \
    # install node modules
    && npm install \
    # install php composer packages
    && composer install \
    # clean
    && npm run dev \
    # set .env
    && cp .env.test .env \
    # change /var/www/bits user/group
    && chown -Rf nobody:nobody /var/www/bits
```

You may check [run.sh](https://github.com/bitscoid/nginx-php/blob/master/run.sh) for more information about what it can do.


### Develop with this image

Another example to develop with this image for a **Laravel 10** project, you may modify the `docker-compose.yml` of your project.

Make sure you have correct environment parameters set:

```yaml
# For more information: https://laravel.com/docs/sail
version: '3'
services:
    laravel.test:
        image: 'bantenitsolutions/nginx-php:latest'
        ports:
            - '80:80'
        environment:
            WEBROOT: '/var/www/bits/public'
            PHP_MEM_LIMIT: '2048'
            PHP_POST_MAX_SIZE: '128'
            PHP_UPLOAD_MAX_FILESIZE: '128'
            REDIS_HOST: '127.0.0.1'
            #RUN_SCRIPTS: '1'
        extra_hosts:
            - 'host.docker.internal:host-gateway'
        volumes:
            - './app:/var/www/bits'
        networks:
            - sail
        depends_on:
            - mysql
            - redis
    mysql:
        image: 'bantenitsolutions/mariadb-lite:latest'
        ports:
            - '3306:3306'
        restart: 'always'
        environment:
            MYSQL_USER: 'bits_user'
            MYSQL_PASS: 'bits_pass'
            MYSQL_NAME: 'bits_name'
        volumes:
            - './db:/var/lib/mysql'
        networks:
            - sail
    redis:
        image: 'redis:alpine'
        ports:
            - '6379:6379'
        volumes:
            - 'sail-redis:/data'
        networks:
            - sail
        healthcheck:
            test: ["CMD", "redis-cli", "ping"]
            retries: 3
            timeout: 5s
networks:
    sail:
        driver: bridge
```

## Configuration
In nginx and php directory you'll find the default configuration files for Nginx, PHP and PHP-FPM.
If you want to extend or customize that you can do so by mounting a configuration file in the correct folder;

Nginx Configuration:

    docker run -v "./server/nginx/nginx.conf:/etc/nginx/http.d/default.conf" bantenitsolutions/nginx-php

Nginx Default Site:

    docker run -v "./server/nginx/http.d/default.conf:/etc/nginx/http.d/default.conf" bantenitsolutions/nginx-php

PHP Configuration:

    docker run -v "./server/php/php.ini:/usr/local/etc/php/php.ini" bantenitsolutions/nginx-php

PHP-FPM Configuration:

    docker run -v "./server/php/www.conf:/usr/local/etc/php-fpm.d/www.conf" bantenitsolutions/nginx-php

## Documentation
Add extra PHP modules

You may use this image as the base image to build your own. For example, to add mongodb module:
Create a Dockerfile

    FROM bantenitsolutions/nginx-php
    RUN apk add --no-cache --update --virtual .phpize-deps $PHPIZE_DEPS \
        && apk add --no-cache --update --virtual .all-deps $PHP_MODULE_DEPS \
        && pecl install mongodb \
        && docker-php-ext-enable mongodb \
        && rm -rf /tmp/pear \
        && apk del .all-deps .phpize-deps \
        && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

Build Image

    docker build -t my-nginx-php .
