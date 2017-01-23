#!/bin/bash

DIRECTORY=/var/www/html

setup_env () {
    APP_ENV=${APP_ENV:-production}
    APP_DEBUG=${APP_DEBUG:-false}
    APP_URL=${APP_URL:-https://wiringa.nl}
    APP_KEY=${APP_KEY:-SECRET}

    DB_DRIVER=${DB_DRIVER:-mysql}
    DB_HOST=${DB_HOST:-db}
    DB_DATABASE=${DB_DATABASE:-wiringa}
    DB_USERNAME=${DB_USERNAME:-wiringa}
    DB_PASSWORD=${DB_PASSWORD:-password}
    DB_PORT=${DB_PORT:-3306}

    CACHE_DRIVER=${CACHE_DRIVER:-file}
    SESSION_DRIVER=${SESSION_DRIVER:-database}
    QUEUE_DRIVER=${QUEUE_DRIVER:-sync}

    MAIL_DRIVER=${MAIL_DRIVER:-mailgun}
    MAIL_USERNAME=${MAIL_USERNAME:-null}
    MAIL_PASSWORD=${MAIL_PASSWORD:-null}
    MAIL_ADDRESS=${MAIL_ADDRESS:-null}
    MAIL_NAME=${MAIL_NAME:-null}
    MAIL_ENCRYPTION=${MAIL_ENCRYPTION:-null}

    GITHUB_TOKEN=${GITHUB_TOKEN:-null}

    MAILGUN_DOMAIN=${MAILGUN_DOMAIN}
    MAILGUN_SECRET=${MAILGUN_SECRET}

    ANALYTICS_VIEW_ID=${ANALYTICS_VIEW_ID}


    # configure env file

    sed 's,{{APP_ENV}},'"${APP_ENV}"',g' -i /var/www/html/.env
    sed 's,{{APP_DEBUG}},'"${APP_DEBUG}"',g' -i /var/www/html/.env
    sed 's,{{APP_URL}},'"${APP_URL}"',g' -i /var/www/html/.env
    sed 's,{{APP_KEY}},'${APP_KEY}',g' -i /var/www/html/.env

    sed 's,{{DB_DRIVER}},'"${DB_DRIVER}"',g' -i /var/www/html/.env
    sed 's,{{DB_HOST}},'"${DB_HOST}"',g' -i /var/www/html/.env
    sed 's,{{DB_DATABASE}},'"${DB_DATABASE}"',g' -i /var/www/html/.env
    sed 's,{{DB_USERNAME}},'"${DB_USERNAME}"',g' -i /var/www/html/.env
    sed 's,{{DB_PASSWORD}},'"${DB_PASSWORD}"',g' -i /var/www/html/.env
    sed 's,{{DB_PORT}},'"${DB_PORT}"',g' -i /var/www/html/.env

    sed 's,{{CACHE_DRIVER}},'"${CACHE_DRIVER}"',g' -i /var/www/html/.env
    sed 's,{{SESSION_DRIVER}},'"${SESSION_DRIVER}"',g' -i /var/www/html/.env
    sed 's,{{QUEUE_DRIVER}},'"${QUEUE_DRIVER}"',g' -i /var/www/html/.env

    sed 's,{{MAIL_DRIVER}},'"${MAIL_DRIVER}"',g' -i /var/www/html/.env
    sed 's,{{MAIL_USERNAME}},'${MAIL_USERNAME}',g' -i /var/www/html/.env
    sed 's,{{MAIL_PASSWORD}},'${MAIL_PASSWORD}',g' -i /var/www/html/.env
    sed 's,{{MAIL_ADDRESS}},'${MAIL_ADDRESS}',g' -i /var/www/html/.env
    sed 's,{{MAIL_NAME}},'${MAIL_NAME}',g' -i /var/www/html/.env
    sed 's,{{MAIL_ENCRYPTION}},'${MAIL_ENCRYPTION}',g' -i /var/www/html/.env

    sed 's,{{GITHUB_TOKEN}},'"${GITHUB_TOKEN}"',g' -i /var/www/html/.env

    sed 's,{{MAILGUN_DOMAIN}},'"${MAINGUN_DOMAIN}"',g' -i /var/www/html/.env
    sed 's,{{MAILGUN_SECRET}},'"${MAILGUN_SECRET}"',g' -i /var/www/html/.env

    sed 's,{{ANALYTICS_VIEW_ID}},'"${ANALYTICS_VIEW_ID}"',g' -i /var/www/html/.env
}

if [ -d "$DIRECTORY/.git" ]; then
    # Pull if the directory already exists
    cd "$DIRECTORY"

    echo "Pulling repository..."

    git pull origin "$GIT_BRANCH"
else
    echo "Cloning repository..."

    # Clone if it does not
    git clone https://github.com/Wiringa-Technische-Groothandel/webshop "$DIRECTORY"

    cd "$DIRECTORY"

    cp .env.docker .env

    setup_env
fi

echo "Downloading composer..."

EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --quiet || exit 1

rm composer-setup.php &&

# Install composer modules (Excluding dev dependencies)
echo "Installing composer modules..."
php composer.phar install --no-dev

echo "Removing composer.phar..."
rm composer.phar

# Install (new) node modules and (re-)compile assets
echo "Installing node modules..."
yarn && node_modules/.bin/gulp --production

# (Re)cache the routes and config
echo "(Re)building artisan cache..."
php artisan route:cache
php artisan config:cache
php artisan optimize

# Run the PHP process
echo "Streaming Laravel log file"
exec tail -f storage/logs/*.log
