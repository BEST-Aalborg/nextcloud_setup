FROM nextcloud:18-fpm

RUN sed -i s/opcache.memory_consumption.*[0-9]*/opcache.memory_consumption=384/ /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN echo "memory_limit=512M" > /usr/local/etc/php/php.ini

RUN apt-get update
RUN apt-get install --yes smbclient libsmbclient-dev
RUN pecl install smbclient
RUN docker-php-ext-enable smbclient
RUN rm -rf /var/lib/apt/lists/*
