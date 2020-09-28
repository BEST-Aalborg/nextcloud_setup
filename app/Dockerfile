FROM nextcloud:19-fpm

RUN sed -i s/opcache.memory_consumption.*[0-9]*/opcache.memory_consumption=384/ /usr/local/etc/php/conf.d/opcache-recommended.ini

### Tune PHP-FPM ###
# Ref: https://docs.nextcloud.com/server/19/admin_manual/installation/server_tuning.html?highlight=memory%20limit#tune-php-fpm
RUN sed -i 's/pm.max_children.*/pm.max_children = 120/'          /usr/local/etc/php-fpm.d/www.conf
RUN sed -i 's/pm.start_servers.*/pm.start_servers = 12/'         /usr/local/etc/php-fpm.d/www.conf
RUN sed -i 's/pm.min_spare_servers.*/pm.min_spare_servers = 6/'  /usr/local/etc/php-fpm.d/www.conf
RUN sed -i 's/pm.max_spare_servers.*/pm.max_spare_servers = 18/' /usr/local/etc/php-fpm.d/www.conf


RUN echo "memory_limit=512M" > /usr/local/etc/php/php.ini

### Installs the missing packages for samba (Windows Share)
#RUN apt-get update && \
#    apt-get install --yes smbclient libsmbclient-dev && \
#    pecl install smbclient && \
#    docker-php-ext-enable smbclient && \
#    rm -rf /var/lib/apt/lists/*


