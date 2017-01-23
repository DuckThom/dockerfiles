FROM php:7.1-cli

MAINTAINER Thomas Wiringa <thomas.wiringa@gmail.com>

ENV GIT_BRANCH 'master'

# Add Node 6.x
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

# Add Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install packages
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    git \
    cron \
    unzip \
    wget \
    nodejs \
    yarn \
 && apt-get clean -y \
 && apt-get autoremove -y

# Clear the existing html folder
RUN rm -rf /var/www/html \
 && mkdir -p /var/www/html \
 && chown -R www-data /var/www

# Add a cron job to run the artisan scheduler
RUN echo '* * * * * www-data php /var/www/html/artisan schedule:run >> /dev/null 2>&1' > /etc/cron.d/artisan-schedule \
 && chmod 0644 /etc/cron.d/artisan-schedule \
 && touch /var/log/cron.log

# Install PHP extensions
RUN docker-php-ext-install \
    mbstring \
    pdo_mysql \
    tokenizer \
    opcache

# This is the setup script which will clone or pull the repo from github
ADD ./docker-entrypoint.sh /docker-entrypoint.sh

# Set the user id of www-data to 1000
RUN usermod -u 1000 www-data

# Run everything as www-data from here
USER www-data

# Set the entry directory
WORKDIR /var/www/html

VOLUME /var/www/html

ENTRYPOINT ["/docker-entrypoint.sh"]
