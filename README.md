# docker-alpine-apache2-php7

Development env for PHP7 + Apache2.

## Usage

```
git clone git@github.com:ysugimoto/docker-alpine-apache2-php7.git
cd docker-alpine-apache2-php7
dokcer build -t [tag] .
docker run -d -p 9999:80 -v /path/to/your/php7-project:/var/www/localhost/htdocs [tag]
```

This container image will compile *PHP7.1.0RC1* and apache2 manualy.

If you want to use some PHP modules, please edit `Dockerfile` and rebuild it.

