FROM nginx:stable-alpine

ADD nginx.conf /etc/nginx/
ADD wiringa.conf /etc/nginx/sites-available/

RUN echo "upstream php-upstream { server php:9000; }" > /etc/nginx/conf.d/upstream.conf

CMD ["nginx"]

EXPOSE 80 443
