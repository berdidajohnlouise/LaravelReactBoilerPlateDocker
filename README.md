# Laravel Nuxt Vuejs Running PHP-fpm 7.4

## Development Build Setup

```bash
# Installation must have docker running on your PC
$ mkdir mysql
$ docker-compose up -d --build

# Running client 
# For Windows  
$ winpty docker-compose exec client bash
$ npm run dev

# For Other OS
$ docker-compose exec client bash


# Running API
# For Windows
$ winpty docker-compose exec api bash
root@28403d451029:/var/www/html/api# cp .env.local .env
root@28403d451029:/var/www/html/api# php artisan migrate --seed
root@28403d451029:/var/www/html/api# php artisan optimize:clear

```

# Setting up HOST

```bash
# Set Host

# On mac open /etc/host
# Add 
# IP-address website.test

# For Windows C:/Windows/System32/drivers/etc/hosts
# Add 
# IP-Address website.test

```

# Browser Access

```bash
URI: http://website.test:81

PHPMYADMIN: http://website.test:7000/
Credentials: 
Server: mysql
Username: dbuser
Pass: dbpassword

API URI: http://website.test/api/v1
```