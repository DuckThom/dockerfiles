FROM php:7.2-cli

RUN apt-get update -yqq
RUN apt-get install gnupg -yqq
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get install git nodejs libcurl4-gnutls-dev libicu-dev libvpx-dev libjpeg-dev libpng-dev libxpm-dev zlib1g-dev libfreetype6-dev libxml2-dev libexpat1-dev libbz2-dev libgmp3-dev unixodbc-dev libaspell-dev libsnmp-dev libpcre3-dev libtidy-dev -yqq
RUN docker-php-ext-install mbstring pdo_mysql curl json intl gd xml zip bz2 opcache soap
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug
