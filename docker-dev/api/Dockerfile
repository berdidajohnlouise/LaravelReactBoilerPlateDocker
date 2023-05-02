FROM php:7.4-fpm

# Install dependencies for the operating system software
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libmagickwand-dev --no-install-recommends \
    zip \
    vim \
    git \
    curl \
    && pecl install imagick \
	&& docker-php-ext-enable imagick

# Install extensions for php
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install gd
# RUN docker-php-ext-install imagick


# Install composer (php package manager)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


# Expose port 9000 and start php-fpm server (for FastCGI Process Manager)
EXPOSE 9000
CMD ["php-fpm"]