FROM php:7.4-fpm

USER root

WORKDIR /var/www

# Install dependencies
RUN apt-get update \
	# gd
	&& apt-get install -y --no-install-recommends build-essential  openssl nginx libfreetype6-dev libjpeg-dev libpng-dev libwebp-dev zlib1g-dev libzip-dev gcc g++ make vim unzip curl git jpegoptim optipng pngquant gifsicle locales libonig-dev nodejs npm  \
	&& docker-php-ext-configure gd  \
	&& docker-php-ext-install gd \
	# gmp
	&& apt-get install -y --no-install-recommends libgmp-dev \
	&& docker-php-ext-install gmp \
	# pdo_mysql
	&& docker-php-ext-install pdo_mysql mbstring \
	# pdo
	&& docker-php-ext-install pdo \
	# opcache
	&& docker-php-ext-enable opcache \
	# zip
	&& docker-php-ext-install zip \
	&& apt-get autoclean -y \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/pear/

RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests supervisor

# Install SSH for Container
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN mkdir /root/.ssh
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5x75K4NEIgfSgM9IuQ/LoPEPDOjze1tqZef/WO/KZ+vbg8laQZKREqg9cVBNq9I7dqMsd7y14ZaawEUWOdYH/UHs2xo7iWzE3zne25Gfb8EN/0+rUEjzBAZ/TuNySwJ5YsmiDq3P3OCf1eJgCxLqAF/jz4k4sZQR5GIGSzpw/WrgC4RpQGANSmxUcxL2M9mH7y9jGBhJCuDonHTjcOrVWzH4YT8Tx5CkrWYa8HxkXGM1UWjAzZBxIv8LgDWu28QZR1Ij1rrXtgd4opQ/14Tw6P9D2AxDRL7mir0AoRQE8VvAQ+Zk3FAMi341m5XGrTgweTgl+OZ+YRawg51G9xs8Jm2fl9+mSPmReezeckisn4liqBjpIgCKyo0ozV3Zdo1ntgZoGwa2E8K3N0IyxYhHBxb+mu90qzmczvkkQxkOl5NK1oWWXWH3mzyi60VeGFfr/KpCYNRl3+czWOI298thSZT+zch0hPrr3cPwZmvMYxcMIKZg9J0ONrJXiv+4QqGs= lablab13@DESKTOP-C74LCR0" >> /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed -ie 's/Port 22/#Port 22/g' /etc/ssh/sshd_config
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Copy Environment Variables
RUN touch /var/log/supervisord.log
RUN touch /var/log/client.log
RUN touch /var/log/laravel.log

COPY ./docker-prod/supervisor/conf /etc/supervisord/conf.d/

COPY ./docker-prod/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

RUN mkdir /var/www/api
RUN mkdir /var/www/client

RUN touch /var/www/api/.env
# Copy files
COPY ./api /var/www/api
COPY ./client /var/www/client
COPY ./client/package.json /var/www

COPY ./docker-prod/php/local.ini /usr/local/etc/php/local.ini
COPY ./docker-prod/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./docker-prod/nginx/site.conf /etc/nginx/conf.d/site.conf

ARG mode

RUN chmod +rwx /var/www

RUN chmod -R 777 /var/www


# setup npm
RUN npm install -g npm@latest

# RUN npm install


# setup composer and laravel
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer install --working-dir="/var/www/api"

RUN composer dump-autoload --working-dir="/var/www/api"

RUN npm install


ENV HOST 0.0.0.0
EXPOSE 80
EXPOSE 22

COPY ./docker-prod/post_deploy.sh /var/www
COPY ./docker-prod/pre_deploy.sh /var/www

RUN ["chmod","+x","pre_deploy.sh"]

RUN ["chmod", "+x", "post_deploy.sh"]

RUN if [[ -z "$mode" ]] ; then echo Arugment not provided ; else ./pre_deploy.sh ${mode} ; fi

CMD [ "sh", "./post_deploy.sh"]

CMD ["/usr/bin/supervisord"]