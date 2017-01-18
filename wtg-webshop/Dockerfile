FROM php:7.1-fpm

MAINTAINER Thomas Wiringa <thomas.wiringa@gmail.com>

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    git \
    cron \
    unzip \
    wget \
    nodejs \
 && apt-get clean -y \
 && apt-get autoremove -y

RUN mkdir -p /var/www/html \
 && chown -R www-data /var/www

RUN echo '* * * * * www-data php /var/www/html/artisan schedule:run >> /dev/null 2>&1' > /etc/cron.d/artisan-schedule \
 && chmod 0644 /etc/cron.d/artisan-schedule \
 && touch /var/log/cron.log

RUN docker-php-ext-install \
    mbstring \
    pdo_mysql \
    tokenizer \
    opcache

ADD ./wiringa.ini /usr/local/etc/php/conf.d
ADD ./wiringa.pool.conf /usr/local/etc/php-fpm.d/

WORKDIR /var/www/html

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php -r "if (hash_file('SHA384', 'composer-setup.php') === '55d6ead61b29c7bdee5cccfb50076874187bd9f21f65d8991d46ec5cc90518f447387fb9f76ebae1fbbacf329e583e30') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
 && php composer-setup.php \
 && php -r "unlink('composer-setup.php');" \
 && mv composer.phar /bin/composer

RUN npm install --global yarn

USER www-data

RUN rm -rf /var/www/html/*

RUN git clone https://github.com/Wiringa-Technische-Groothandel/webshop /var/www/html

RUN cp .env.docker .env

RUN composer install --no-dev -o \
 && rm -rf bootstrap/cache/*

RUN yarn \
 && node_modules/.bin/gulp --production

VOLUME /var/www

EXPOSE 9000

CMD ["php-fpm"]
