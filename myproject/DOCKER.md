# Docker Setup Guide

This guide will help you set up and run the Laravel Chat Application using Docker.

## Prerequisites

- Docker Desktop installed and running
- Docker Compose installed

## Quick Start

### 1. Build and Start Containers

```bash
docker-compose up -d --build
```

This will:
- Build the PHP-FPM application container
- Start MySQL database container
- Start Nginx web server container

### 2. Install Dependencies

```bash
# Enter the app container
docker-compose exec app bash

# Install PHP dependencies
composer install

# Exit container
exit
```

### 3. Configure Environment

```bash
# Copy .env.example to .env (if exists) or create .env file
docker-compose exec app cp .env.example .env

# Or create .env manually with these settings:
# DB_CONNECTION=mysql
# DB_HOST=db
# DB_PORT=3306
# DB_DATABASE=laravel
# DB_USERNAME=laravel
# DB_PASSWORD=root
```

### 4. Generate Application Key

```bash
docker-compose exec app php artisan key:generate
```

### 5. Run Migrations

```bash
docker-compose exec app php artisan migrate
```

### 6. Set Storage Permissions

```bash
docker-compose exec app chmod -R 775 storage bootstrap/cache
```

## Access the Application

- **Web Application**: http://localhost:8000
- **API Endpoints**: http://localhost:8000/api

## Useful Docker Commands

### View Logs
```bash
docker-compose logs -f app
docker-compose logs -f nginx
docker-compose logs -f db
```

### Stop Containers
```bash
docker-compose down
```

### Stop and Remove Volumes (including database data)
```bash
docker-compose down -v
```

### Rebuild Containers
```bash
docker-compose up -d --build
```

### Execute Commands in Container
```bash
docker-compose exec app php artisan migrate
docker-compose exec app composer install
docker-compose exec app php artisan cache:clear
```

### Access Container Shell
```bash
docker-compose exec app bash
```

## Database Access

- **Host**: localhost (from host machine) or `db` (from app container)
- **Port**: 3306
- **Database**: laravel (or your DB_DATABASE value)
- **Username**: laravel (or your DB_USERNAME value)
- **Password**: root (or your DB_PASSWORD value)

## Troubleshooting

### Permission Issues
```bash
docker-compose exec app chown -R www-data:www-data storage bootstrap/cache
docker-compose exec app chmod -R 775 storage bootstrap/cache
```

### Clear Cache
```bash
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear
```

### Rebuild Everything
```bash
docker-compose down -v
docker-compose up -d --build
docker-compose exec app composer install
docker-compose exec app php artisan key:generate
docker-compose exec app php artisan migrate
```

## Production Considerations

For production, you should:
1. Use environment-specific `.env` file
2. Set strong database passwords
3. Configure proper SSL/TLS
4. Use production-ready PHP-FPM settings
5. Set up proper backup strategies
6. Configure proper logging

