FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# for php-fpm
RUN mkdir -p /run/php

COPY setup.sh /setup.sh

RUN chmod +x /setup.sh

WORKDIR /var/www/html

ENTRYPOINT ["/setup.sh"]