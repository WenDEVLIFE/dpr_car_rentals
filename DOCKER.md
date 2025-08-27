# Docker Setup for DPR Car Rentals Flutter App (Simple APK Server)

This setup creates a simple web server to download your Flutter APK.

## Prerequisites

- Docker installed
- Flutter development environment set up

## Quick Start (3 Easy Steps)

### Step 1: Build your Flutter APK
```bash
flutter build apk --release
```

### Step 2: Copy APK to project root
```bash
cp build/app/outputs/flutter-apk/app-release.apk .
```

### Step 3: Build and run Docker container
```bash
# Build the image
docker build -t dpr-car-rental .

# Run the container  
docker run -d -p 8080:80 --name dpr-car-rental-app dpr-car-rental
```

## Access Your App

Once running, visit: **http://localhost:8080**

You'll see a download page with a button to download your APK.

## Using Docker Compose (Alternative)

```bash
docker-compose up -d --build
```

## Docker Image Details

### Multi-stage Build Process:

1. **Build Stage**: 
   - Uses Ubuntu 22.04 as base image
   - Installs Java 11 and Android SDK
   - Installs Flutter SDK (version 3.24.3)
   - Builds the Flutter Android APK
   
2. **Production Stage**:
   - Uses lightweight nginx:alpine image
   - Serves the APK file for download
   - Provides a simple web interface for APK download

### Key Features:

- **Android APK Build**: Creates a release APK ready for installation
- **Simple Download Interface**: Web page to download the APK
- **Optimized for Mobile**: Builds for Android platform
- **Health Checks**: Built-in health monitoring
- **Lightweight Serving**: Uses nginx for efficient file serving

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