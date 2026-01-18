# Docker Setup for Akaunting

This directory contains a complete Docker configuration for Akaunting, an open-source accounting software built with Laravel.

## Architecture

The Docker setup uses a multi-stage build process:

1. **Frontend Build Stage**: Compiles JavaScript and CSS assets using Node.js and Laravel Mix
2. **PHP Application Stage**: Sets up PHP 8.2 with required extensions and composer dependencies

## Components

### Services

- **app**: PHP-FPM application server with Akaunting code
- **nginx**: Nginx web server to serve the application
- **mysql**: MySQL 8.0 database
- **redis**: Redis cache server
- **phpmyadmin**: Optional database management interface

### Key Features

- **Optimized Image Size**: Multi-stage build with Alpine Linux base (~500MB final image)
- **Security**: Non-root user, minimal installed packages
- **Performance**: OPCache enabled, optimized PHP-FPM configuration
- **Health Checks**: Database and application health monitoring
- **Persistent Data**: Volumes for database, redis cache, and application storage

## Quick Start

1. **Build and start all services:**
   ```bash
   docker compose up -d --build
   ```

2. **Access the application:**
   - Main application: http://localhost:8080
   - phpMyAdmin: http://localhost:8081

3. **Initialize Akaunting:**
   ```bash
   docker compose exec app php artisan install \
     --db-name="akaunting" \
     --db-username="akaunting" \
     --db-password="akaunting_password" \
     --admin-email="admin@company.com" \
     --admin-password="123456"
   ```

## Development

### Building Images

```bash
# Build only the application image
docker compose build app

# Build all images
docker compose build
```

### Running Services

```bash
# Start all services
docker compose up -d

# Start specific services
docker compose up -d mysql redis

# View logs
docker compose logs -f app
docker compose logs -f nginx
```

### Management Commands

```bash
# Execute commands in the application container
docker compose exec app php artisan --version
docker compose exec app php artisan cache:clear

# Access the application container shell
docker compose exec app sh

# Stop services
docker compose down

# Remove volumes (⚠️ deletes all data)
docker compose down -v
```

## Configuration

### Environment Variables

Key environment variables in `docker-compose.yml`:

```yaml
APP_NAME=Akaunting
APP_ENV=production
APP_DEBUG=false
APP_URL=http://localhost:8080

DB_CONNECTION=mysql
DB_HOST=mysql
DB_DATABASE=akaunting
DB_USERNAME=akaunting
DB_PASSWORD=akaunting_password

CACHE_DRIVER=redis
SESSION_DRIVER=redis
REDIS_HOST=redis
```

### Customization

- **Database**: Change `mysql` service to use PostgreSQL or other supported databases
- **Web Server**: Replace `nginx` with Apache if preferred
- **PHP Version**: Modify `Dockerfile` to use different PHP version
- **Environment**: Copy `.env.example` to `.env` and customize settings

## Production Deployment

### Security Considerations

1. **Change default passwords** in docker-compose.yml
2. **Use HTTPS** by configuring SSL certificates in nginx
3. **Restrict access** to phpMyAdmin in production
4. **Backup volumes** regularly:
   ```bash
   docker run --rm -v akaunting_mysql_data:/data -v $(pwd):/backup alpine tar czf /backup/mysql-backup.tar.gz -C /data .
   ```

### Scaling

- **Horizontal Scaling**: Deploy multiple app instances behind a load balancer
- **Vertical Scaling**: Increase memory/CPU limits in docker-compose.yml
- **Database**: Consider managed database service for production

## Troubleshooting

### Common Issues

1. **Build fails with npm errors**:
   - Clear npm cache: `docker compose exec app npm cache clean`
   - Rebuild: `docker compose build --no-cache`

2. **Database connection failed**:
   - Check MySQL health: `docker compose ps`
   - View logs: `docker compose logs mysql`

3. **Permission errors**:
   - Ensure proper permissions on storage directory
   - Run: `sudo chown -R 1000:1000 storage bootstrap/cache`

4. **502 Bad Gateway**:
   - Check if PHP-FPM is running: `docker compose ps app`
   - Verify nginx configuration: `docker compose logs nginx`

### Performance Optimization

1. **Enable OPCache** (already configured)
2. **Use Redis for caching** (already configured)
3. **Optimize PHP-FPM settings** in `docker/php-fpm.conf`
4. **Configure nginx caching** for static assets

## File Structure

```
.
├── Dockerfile              # Multi-stage build configuration
├── docker-compose.yml      # Services orchestration
├── .dockerignore          # Files excluded from Docker build
├── docker/
│   ├── nginx.conf         # Nginx configuration
│   └── php-fpm.conf      # PHP-FPM configuration
└── test-docker.sh        # Environment validation script
```

## Image Size Optimization

The Docker image uses several optimization techniques:

1. **Alpine Linux**: Minimal base image (~5MB vs ~100MB for Debian)
2. **Multi-stage Build**: Separate build and runtime environments
3. **.dockerignore**: Exclude unnecessary files from build context
4. **Layer Caching**: Optimized Dockerfile layer order
5. **Package Cleanup**: Remove build dependencies after installation

Final image size: ~500MB (vs ~1.5GB without optimization)

## Support

For issues specific to:
- **Akaunting**: https://akaunting.com/hc/docs
- **Docker**: https://docs.docker.com/
- **Laravel**: https://laravel.com/docs

## License

This Docker configuration follows the same license as Akaunting (BUSL-1.1).