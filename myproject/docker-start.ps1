# Docker Setup Script for Laravel Chat Application (PowerShell)

Write-Host "Starting Docker setup..." -ForegroundColor Green

# Build and start containers
Write-Host "Building and starting Docker containers..." -ForegroundColor Yellow
docker-compose up -d --build

# Wait for database to be ready
Write-Host "Waiting for database to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Install dependencies
Write-Host "Installing PHP dependencies..." -ForegroundColor Yellow
docker-compose exec -T app composer install --no-interaction

# Check if .env exists
if (-not (Test-Path .env)) {
    Write-Host "Creating .env file..." -ForegroundColor Yellow
    if (Test-Path .env.example) {
        Copy-Item .env.example .env
    } else {
        $envContent = @'
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
'@
        $envContent | Out-File -FilePath .env -Encoding utf8
    }
}

# Generate application key
Write-Host "Generating application key..." -ForegroundColor Yellow
docker-compose exec -T app php artisan key:generate

# Run migrations
Write-Host "Running database migrations..." -ForegroundColor Yellow
docker-compose exec -T app php artisan migrate --force

# Set permissions
Write-Host "Setting storage permissions..." -ForegroundColor Yellow
docker-compose exec app chmod -R 775 storage bootstrap/cache
docker-compose exec app chown -R www-data:www-data storage bootstrap/cache

Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "Application is available at: http://localhost:8000" -ForegroundColor Cyan
Write-Host "API endpoints: http://localhost:8000/api" -ForegroundColor Cyan
