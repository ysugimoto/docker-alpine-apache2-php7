FROM alpine:3.4
MAINTAINER Yoshiaki Sugimoto <sugimoto@wnotes.net>

# Packages
RUN apk update && \
    apk add openssl openssl-dev apache2 apache2-dev wget gcc g++ make ca-certificates libxml2 libxml2-dev procpus && \
    update-ca-certificates

# Download and build PHP
RUN cd tmp/ && \
    wget https://downloads.php.net/~davey/php-7.1.0RC1.tar.gz && \
    tar xvfz php-7.1.0RC1.tar.gz && \
    cd php-7.1.0RC1 && \
    ./configure --enable-mbsting --with-apxs2=/usr/bin/apxs && \
    make && make install && \
    cp php.ini-development /etc/php.ini

# Apache settings
RUN sed -i 's/^#ServerName .*/ServerName localhost:80/g' /etc/apache2/httpd.conf && \
    sed -i 's/^LoadModule php7_module.*/LoadModule php7_module modules\/libphp7\.so/g' /etc/apache2/httpd.conf && \
    mkdir -p /var/www/localhost/htdocs && \
    chown apache:apache /var/log/apache2 && \
    chown apache:apache /var/www/localhost/htdocs && \
    mkdir /run/apache2 && \
    chown apache:apache /run/apache2

RUN apk add procps

# run script
ADD scripts/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 80
ENTRYPOINT ["/init.sh"]
