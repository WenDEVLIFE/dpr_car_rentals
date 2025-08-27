# Docker Setup for DPR Car Rentals Flutter App

This document explains how to build and run the DPR Car Rentals Flutter application using Docker.

## Prerequisites

- Docker installed on your system
- Docker Compose (optional, for easier management)

## Building the Docker Image

### Option 1: Using Docker directly

```bash
# Build the image
docker build -t dpr-car-rentals .

# Run the container
docker run -d -p 8080:80 --name dpr-car-rentals-app dpr-car-rentals
```

### Option 2: Using Docker Compose (Recommended)

```bash
# Build and run with docker-compose
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop the application
docker-compose down
```

## Accessing the Application

Once the container is running, you can access the application at:
- http://localhost:8080

## Docker Image Details

### Multi-stage Build Process:

1. **Build Stage**: 
   - Uses Ubuntu 22.04 as base image
   - Installs Flutter SDK (version 3.24.3)
   - Builds the Flutter web application
   
2. **Production Stage**:
   - Uses lightweight nginx:alpine image
   - Serves the built Flutter web app
   - Includes gzip compression for better performance

### Key Features:

- **Optimized for Production**: Multi-stage build reduces final image size
- **Web-ready**: Configured nginx server with proper routing for Flutter SPA
- **Health Checks**: Built-in health monitoring
- **Gzip Compression**: Enabled for better performance
- **Proper Caching**: Flutter dependencies are cached in separate layers

## Development

### Building for different environments:

```bash
# Development build
docker build --target build -t dpr-car-rentals:dev .

# Production build (default)
docker build -t dpr-car-rentals:prod .
```

### Environment Variables

You can customize the deployment by setting environment variables:

```bash
docker run -d \
  -p 8080:80 \
  -e NGINX_HOST=your-domain.com \
  -e NGINX_PORT=80 \
  --name dpr-car-rentals-app \
  dpr-car-rentals
```

## Troubleshooting

### Common Issues:

1. **Port already in use**: Change the host port in docker-compose.yml or docker run command
2. **Build failures**: Ensure you have a stable internet connection for downloading Flutter dependencies
3. **Container won't start**: Check logs with `docker logs dpr-car-rentals-app`

### Checking Container Status:

```bash
# Check running containers
docker ps

# View container logs
docker logs dpr-car-rentals-app

# Execute commands inside container
docker exec -it dpr-car-rentals-app sh
```

## Production Deployment

For production deployment, consider:

1. Using a reverse proxy (nginx, Traefik, etc.)
2. SSL/TLS certificates
3. Environment-specific configuration
4. Monitoring and logging
5. Backup strategies
6. Load balancing for multiple instances

### Example with SSL (nginx-proxy):

```yaml
version: '3.8'
services:
  dpr-car-rentals:
    build: .
    environment:
      - VIRTUAL_HOST=your-domain.com
      - LETSENCRYPT_HOST=your-domain.com
      - LETSENCRYPT_EMAIL=your-email@domain.com
    networks:
      - proxy

networks:
  proxy:
    external: true
```

## Security Considerations

- The container runs as non-root user in production
- Nginx is configured with security headers
- Only necessary ports are exposed
- No sensitive data is baked into the image

## Performance Optimization

- Multi-stage build minimizes image size
- Gzip compression reduces bandwidth usage
- Static assets are served efficiently by nginx
- Health checks ensure container reliability