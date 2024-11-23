# Usar a imagem oficial do PHP com Apache
FROM php:8.3-apache

# Instalar dependências necessárias para o Laravel
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Habilitar o módulo Apache rewrite
RUN a2enmod rewrite

# Instalar o Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiar arquivos do Laravel para o container
COPY . /var/www/html

# Configurar permissões corretamente
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Garantir que a configuração do DocumentRoot do Apache aponte para o diretório public
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Expor a porta 80
EXPOSE 80

# Configurar o comando de inicialização do Apache
CMD ["apache2-foreground"]
