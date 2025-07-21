FROM php:7.4-apache

# Zainstaluj wymagane pakiety systemowe i rozszerzenia PHP
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libmcrypt-dev \
    libxslt1-dev \
    libcurl4-openssl-dev \
    libldap2-dev \
    libjpeg62-turbo-dev \
    libgd-dev \
    libc-client-dev \
    libkrb5-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install \
        gd \
        mysqli \
        pdo \
        pdo_mysql \
        zip \
        intl \
        opcache \
        xsl \
        curl \
        ldap \
        mbstring \
        imap \
        soap \
    && a2enmod rewrite

# Skopiuj własny plik konfiguracyjny OPcache (opcjonalnie)
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Włącz mod_remoteip
RUN a2enmod remoteip

# Skopiuj konfigurację remoteip (plik dodamy poniżej)
COPY remoteip.conf /etc/apache2/conf-available/remoteip.conf
RUN a2enconf remoteip

# Konfiguracja logowania PHP do stderr
RUN echo "log_errors = On" > /usr/local/etc/php/conf.d/90-log-errors.ini && \
    echo "error_log = /proc/self/fd/2" >> /usr/local/etc/php/conf.d/90-log-errors.ini && \
    echo "display_errors = Off" >> /usr/local/etc/php/conf.d/90-log-errors.ini

# Ustaw domyślną strefę czasową
ENV TZ=Europe/Warsaw
RUN echo "date.timezone=${TZ}" > /usr/local/etc/php/conf.d/timezone.ini
