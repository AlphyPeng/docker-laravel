FROM php:8.2-apache

# Mag-install ng system dependencies at PHP extensions na kailangan ng Laravel
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# I-clear ang cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# I-install ang PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# I-enable ang Apache Rewrite Module para sa Laravel routing
RUN a2enmod rewrite

# Palitan ang Apache DocumentRoot para tumuro sa Laravel 'public' folder
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# Kopyahin ang composer mula sa opisyal na image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Itakda ang working directory
WORKDIR /var/www/html

# Kopyahin ang buong project files papunta sa container
COPY . /var/www/html

# Magbigay ng tamang permissions sa storage at bootstrap/cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache