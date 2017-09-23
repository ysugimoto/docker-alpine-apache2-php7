FROM alpine:3.6
MAINTAINER Yoshiaki Sugimoto <sugimoto@wnotes.net>

# Packages
RUN apk update && \
    apk add libressl-dev apache2 apache2-dev wget gcc g++ make ca-certificates libxml2 libxml2-dev curl curl-dev zlib zlib-dev && \
    update-ca-certificates

# Download and build PHP
RUN cd tmp/ && \
    wget -O php-7.1.9.tar.gz http://jp2.php.net/get/php-7.1.9.tar.gz/from/this/mirror && \
    tar xvfz php-7.1.9.tar.gz && \
    cd php-7.1.9 && \
    ./configure --enable-mbstring --enable-inrl --with-curl=/usr/lib --with-apxs2=/usr/bin/apxs --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-zlib=shared && \
    make && make install

# PHP settings
RUN cp tmp/php-7.1.9/php.ini-development /usr/local/lib/php.ini && \
    sed -i 's/;mbstring\.language = Japanese/mbstring\.language = Japanese/g' /usr/local/lib/php.ini && \
    sed -i 's/;mbstring\.internal_encoding =/mbstring\.internal_encoding = UTF-8/g' /usr/local/lib/php.ini && \
    sed -i 's/;date\.timezone =/date\.timezone = Asia\/Tokyo/g' /usr/local/lib/php.ini

# Apache settings
RUN sed -i 's/^#ServerName .*/ServerName localhost:80/g' /etc/apache2/httpd.conf && \
    sed -i 's/^LoadModule php7_module.*/LoadModule php7_module modules\/libphp7\.so/g' /etc/apache2/httpd.conf && \
    sed -i 's/^#LoadModule rewrite_module.*/LoadModule rewrite_module modules\/mod_rewrite\.so/g' /etc/apache2/httpd.conf && \
    sed -i 's/^#LoadModule deflate_module.*/LoadModule deflate_module modules\/mod_deflate\.so/g' /etc/apache2/httpd.conf && \
    sed -i 's/DirectoryIndex index\.html/DirectoryIndex index\.php/g' /etc/apache2/httpd.conf && \
    sed -i 's/\/var\/www\/localhost\/htdocs/\/var\/www\/localhost\/htdocs\/public/g' /etc/apache2/httpd.conf && \
    sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/httpd.conf && \
    echo "AddType application/x-httpd-php .php" >> /etc/apache2/httpd.conf && \
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
