#!/bin/bash

# Docker Setup Script for Laravel Chat Application

echo "Starting Docker setup..."

# Build and start containers
echo "Building and starting Docker containers..."
docker-compose up -d --build

# Wait for database to be ready
echo "Waiting for database to be ready..."
sleep 10

# Install dependencies
echo "Installing PHP dependencies..."
docker-compose exec -T app composer install --no-interaction

# Check if .env exists
if [ ! -f .env ]; then
    echo "Creating .env file..."
    if [ -f .env.example ]; then
        cp .env.example .env
    else
        cat > .env << EOF
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8000

LOG_CHANNEL=stack
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=root

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"
EOF
    fi
fi

# Generate application key
echo "Generating application key..."
docker-compose exec -T app php artisan key:generate

# Run migrations
echo "Running database migrations..."
docker-compose exec -T app php artisan migrate --force

# Set permissions
echo "Setting storage permissions..."
docker-compose exec -T app chmod -R 775 storage bootstrap/cache
docker-compose exec -T app chown -R www-data:www-data storage bootstrap/cache

echo "Setup complete!"
echo "Application is available at: http://localhost:8000"
echo "API endpoints: http://localhost:8000/api"
