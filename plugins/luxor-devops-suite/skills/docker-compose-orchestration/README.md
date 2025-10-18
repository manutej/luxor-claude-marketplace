# Docker Compose Orchestration

A comprehensive skill for managing multi-container applications with Docker Compose, covering service orchestration, networking, volumes, health checks, and production deployment strategies.

## Overview

Docker Compose is a tool for defining and running multi-container Docker applications. With Compose, you use a YAML file to configure your application's services, networks, and volumes. Then, with a single command, you create and start all the services from your configuration.

This skill provides comprehensive knowledge for:
- Building and orchestrating multi-container applications
- Configuring service dependencies and startup order
- Managing networks and inter-service communication
- Implementing persistent storage with volumes
- Setting up health checks and monitoring
- Deploying to development, staging, and production environments

## What is Docker Compose?

Docker Compose simplifies the management of multi-container Docker applications by:

1. **Declarative Configuration**: Define your entire application stack in a single YAML file
2. **Service Management**: Start, stop, and rebuild services with simple commands
3. **Automatic Networking**: Services can communicate using service names
4. **Volume Management**: Persistent data across container restarts
5. **Environment Control**: Different configurations for dev, staging, and production
6. **Dependency Handling**: Control service startup order and dependencies

## Core Concepts

### Services
A service is a container configuration that defines:
- Which Docker image to use
- Port mappings
- Environment variables
- Volume mounts
- Networks to connect to
- Resource limits
- Health checks

### Networks
Networks enable communication between containers:
- **Bridge Networks**: Default network type for isolated communication
- **Custom Networks**: Better isolation and service discovery
- **Host Networks**: Use host's networking stack
- **Overlay Networks**: Multi-host networking for swarm mode

### Volumes
Volumes provide persistent storage:
- **Named Volumes**: Managed by Docker, persisted across containers
- **Bind Mounts**: Map host directories to container paths
- **tmpfs Mounts**: In-memory storage for temporary data

## Basic Compose File Structure

```yaml
version: "3.8"

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html
    networks:
      - frontend

  app:
    build: ./app
    environment:
      - DATABASE_URL=postgresql://db:5432/myapp
    depends_on:
      - db
    networks:
      - frontend
      - backend

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_PASSWORD=secret
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend

networks:
  frontend:
  backend:

volumes:
  db-data:
```

## Common Use Cases

### 1. Full-Stack Web Applications
Orchestrate frontend, backend, and database services together:
```yaml
services:
  frontend:    # React/Vue/Angular
  backend:     # Node.js/Python/Java
  database:    # PostgreSQL/MySQL/MongoDB
  cache:       # Redis/Memcached
  reverse-proxy: # NGINX/Traefik
```

### 2. Microservices Architecture
Manage multiple independent services:
```yaml
services:
  auth-service:
  user-service:
  order-service:
  payment-service:
  notification-service:
  api-gateway:
  message-broker:
  database:
```

### 3. Development Environments
Create reproducible dev environments:
```yaml
services:
  app:         # Application with hot reload
  db:          # Database
  adminer:     # Database UI
  mailhog:     # Email testing
  redis:       # Caching
```

### 4. Data Processing Pipelines
Build ETL and data processing systems:
```yaml
services:
  producer:    # Data source
  kafka:       # Message queue
  consumer:    # Data processor
  database:    # Data storage
  analytics:   # Data visualization
```

## Essential Commands

### Starting and Stopping
```bash
docker compose up              # Start services
docker compose up -d           # Start in background
docker compose down            # Stop and remove
docker compose stop            # Stop services
docker compose restart         # Restart services
```

### Building and Pulling
```bash
docker compose build           # Build all images
docker compose pull            # Pull all images
docker compose build --no-cache  # Clean build
```

### Viewing and Monitoring
```bash
docker compose ps              # List containers
docker compose logs -f         # Follow logs
docker compose top             # Running processes
docker compose events          # Real-time events
```

### Executing Commands
```bash
docker compose exec web sh     # Interactive shell
docker compose run --rm app test  # Run one-off command
```

## Service Configuration Options

### Image and Build
```yaml
services:
  web:
    image: nginx:alpine        # Use existing image
    # OR
    build:
      context: ./app           # Build from Dockerfile
      dockerfile: Dockerfile.prod
      args:
        NODE_ENV: production
```

### Ports and Networking
```yaml
services:
  web:
    ports:
      - "8080:80"              # Host:Container
    expose:
      - "8080"                 # Internal only
    networks:
      - frontend
      - backend
```

### Environment Variables
```yaml
services:
  app:
    environment:
      - NODE_ENV=production
      - API_KEY=secret
    env_file:
      - .env
      - .env.production
```

### Volumes and Storage
```yaml
services:
  db:
    volumes:
      - db-data:/var/lib/postgresql/data    # Named volume
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql  # Bind mount
      - type: tmpfs                          # In-memory
        target: /tmp
```

### Dependencies
```yaml
services:
  web:
    depends_on:
      db:
        condition: service_healthy
      cache:
        condition: service_started
```

### Health Checks
```yaml
services:
  web:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### Resource Limits
```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

## Environment-Specific Configurations

### Development (compose.override.yaml)
```yaml
services:
  app:
    build:
      target: development
    volumes:
      - ./src:/app/src        # Hot reload
    ports:
      - "3000:3000"           # Expose for debugging
    environment:
      - DEBUG=*
```

### Production (compose.prod.yaml)
```yaml
services:
  app:
    image: myapp:${VERSION}
    restart: always
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '2'
          memory: 2G
```

### Usage
```bash
# Development (auto-loads compose.override.yaml)
docker compose up

# Production
docker compose -f compose.yaml -f compose.prod.yaml up -d

# Staging
docker compose -f compose.yaml -f compose.staging.yaml up -d
```

## Networking Patterns

### Frontend-Backend Separation
```yaml
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access

services:
  web:
    networks:
      - frontend

  api:
    networks:
      - frontend
      - backend

  db:
    networks:
      - backend     # Isolated from frontend
```

### Service Discovery
Services can communicate using service names:
```yaml
services:
  api:
    environment:
      - DATABASE_URL=postgresql://db:5432/myapp
      - REDIS_URL=redis://cache:6379

  db:
    # Accessible as 'db' hostname

  cache:
    # Accessible as 'cache' hostname
```

## Volume Patterns

### Named Volumes
```yaml
volumes:
  db-data:         # Docker-managed
  uploads:
  cache:

services:
  db:
    volumes:
      - db-data:/var/lib/postgresql/data
```

### Bind Mounts (Development)
```yaml
services:
  app:
    volumes:
      - ./src:/app/src              # Source code
      - ./config:/app/config:ro     # Read-only config
      - /app/node_modules           # Preserve dependencies
```

### Shared Volumes
```yaml
services:
  app:
    volumes:
      - shared-uploads:/uploads

  worker:
    volumes:
      - shared-uploads:/uploads

volumes:
  shared-uploads:
```

## Health Check Strategies

### HTTP Endpoint
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost/health"]
  interval: 30s
  timeout: 10s
  retries: 3
```

### Database Check
```yaml
# PostgreSQL
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U postgres"]

# MySQL
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]

# MongoDB
healthcheck:
  test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
```

### Custom Script
```yaml
healthcheck:
  test: ["CMD", "node", "healthcheck.js"]
  interval: 30s
  timeout: 10s
  retries: 3
```

## Best Practices

### 1. Use Specific Image Tags
```yaml
# Good
image: postgres:15-alpine

# Avoid
image: postgres:latest
```

### 2. Define Health Checks
```yaml
services:
  db:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      interval: 10s
```

### 3. Separate Networks
```yaml
networks:
  frontend:
  backend:
    internal: true
```

### 4. Use Named Volumes
```yaml
volumes:
  db-data:    # Managed by Docker
  uploads:
```

### 5. Environment Files
```yaml
services:
  app:
    env_file:
      - .env              # Base configuration
      - .env.local        # Local overrides
```

### 6. Resource Limits
```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 2G
```

### 7. Logging Configuration
```yaml
logging:
  driver: json-file
  options:
    max-size: "10m"
    max-file: "3"
```

## Common Patterns

### NGINX Reverse Proxy
```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - app

  app:
    expose:
      - "3000"
```

### Database with Adminer
```yaml
services:
  db:
    image: postgres:15-alpine

  adminer:
    image: adminer:latest
    ports:
      - "8080:8080"
```

### Cache Layer
```yaml
services:
  app:
    environment:
      - REDIS_URL=redis://cache:6379

  cache:
    image: redis:alpine
    volumes:
      - cache-data:/data

volumes:
  cache-data:
```

## Scaling Services

```bash
# Scale specific service
docker compose up -d --scale worker=5

# Scale multiple services
docker compose up -d --scale worker=5 --scale consumer=3
```

```yaml
services:
  worker:
    # Will be scaled horizontally
    build: ./worker
    depends_on:
      - rabbitmq
```

## Troubleshooting

### Services Can't Communicate
```bash
# Check network configuration
docker compose config

# Verify service names
docker compose ps

# Test connectivity
docker compose exec service1 ping service2
```

### Volume Issues
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect project_volume-name

# Remove volumes
docker compose down -v
```

### Build Problems
```bash
# Clean build
docker compose build --no-cache

# View build output
docker compose build --progress=plain

# Force rebuild
docker compose up --build --force-recreate
```

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f web

# Last 100 lines
docker compose logs --tail=100 web
```

## Integration with CI/CD

### GitHub Actions Example
```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Deploy with Docker Compose
        run: |
          docker compose -f compose.yaml -f compose.prod.yaml pull
          docker compose -f compose.yaml -f compose.prod.yaml up -d
```

### GitLab CI Example
```yaml
deploy:
  stage: deploy
  script:
    - docker compose -f compose.yaml -f compose.prod.yaml pull
    - docker compose -f compose.yaml -f compose.prod.yaml up -d --remove-orphans
  only:
    - main
```

## When to Use Docker Compose

### Ideal For:
- Local development environments
- Single-host deployments
- Testing and CI/CD
- Small to medium applications
- Prototyping and demos
- Development team consistency

### Consider Alternatives For:
- Large-scale production clusters (use Kubernetes)
- Multi-host deployments (use Docker Swarm or Kubernetes)
- Complex orchestration requirements
- Auto-scaling needs
- Advanced load balancing

## Quick Start Example

1. Create `compose.yaml`:
```yaml
version: "3.8"

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html
```

2. Create HTML content:
```bash
mkdir html
echo "<h1>Hello from Docker Compose!</h1>" > html/index.html
```

3. Start the application:
```bash
docker compose up -d
```

4. Visit http://localhost

5. Stop the application:
```bash
docker compose down
```

## Resources

- Official Documentation: https://docs.docker.com/compose/
- Compose File Reference: https://docs.docker.com/compose/compose-file/
- Example Applications: https://github.com/docker/awesome-compose
- Docker Hub: https://hub.docker.com/
- Best Practices: https://docs.docker.com/develop/dev-best-practices/

## Getting Help

```bash
# Command help
docker compose --help
docker compose up --help

# Validate configuration
docker compose config

# View running containers
docker compose ps

# View logs
docker compose logs -f
```

---

For detailed examples, advanced patterns, and comprehensive configurations, see the full SKILL.md documentation.
