# Multi-stage build for Akaunting - Laravel-based accounting software
FROM node:18-alpine AS frontend-build

WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./
COPY webpack.mix.js ./
COPY tailwind.config.js ./

# Install frontend dependencies (including dev dependencies for build)
RUN npm ci --silent

# Copy frontend source files
COPY resources/ resources/
COPY public/ public/

# Build production assets
RUN npm run production

# PHP Application Stage
FROM php:8.2-fpm-alpine AS application

# Install system dependencies
RUN apk add --no-cache \
    curl \
    git \
    libpng-dev \
    oniguruma-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libpng-dev \
    icu-dev \
    gd-dev \
    tidyhtml-dev \
    imagemagick-dev \
    postgresql-dev \
    libffi-dev \
    linux-headers

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        ctype \
        curl \
        dom \
        fileinfo \
        intl \
        gd \
        json \
        mbstring \
        openssl \
        tokenizer \
        xml \
        zip \
        tidy \
        pdo_mysql \
        pdo_pgsql \
    && pecl install imagick \
    && docker-php-ext-enable imagick

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files first for better caching
COPY composer.json composer.lock ./

# Install PHP dependencies in production mode
RUN composer install --prefer-dist --no-interaction --no-scripts --no-progress --no-ansi --no-dev --optimize-autoloader

# Copy application files
COPY . .

# Copy built frontend assets from frontend-build stage
COPY --from=frontend-build /app/public/js public/js
COPY --from=frontend-build /app/public/css public/css
COPY --from=frontend-build /app/public/mix-manifest.json public/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Copy PHP-FPM configuration
COPY docker/php-fpm.conf /usr/local/etc/php-fpm.d/zz-custom.conf

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=1m --retries=3 \
    CMD php -v || exit 1

# Start PHP-FPM
CMD ["php-fpm"]