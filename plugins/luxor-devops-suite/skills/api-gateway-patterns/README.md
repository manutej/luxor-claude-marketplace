# API Gateway Patterns

Production-grade API gateway patterns using Kong and industry best practices for microservices architectures.

## Overview

This skill provides comprehensive guidance on implementing, configuring, and operating API gateways in production environments. It covers routing strategies, authentication mechanisms, rate limiting, load balancing, caching, security, and observability patterns.

## What You'll Learn

### Core Gateway Concepts

- **API Gateway Architecture**: Understanding the reverse proxy pattern, API composition, and cross-cutting concerns
- **Kong Fundamentals**: Control plane, data plane, plugin system, and entity relationships
- **Service Mesh Integration**: How gateways fit into modern microservices architectures
- **Protocol Support**: HTTP/HTTPS, gRPC, WebSocket, GraphQL

### Routing Strategies

- **Path-Based Routing**: Route by URL paths (/users, /orders, /products)
- **Header-Based Routing**: Version selection, A/B testing, canary deployments
- **Method-Based Routing**: CQRS pattern with separate read/write services
- **Host-Based Routing**: Multi-tenancy, subdomain routing
- **Weighted Routing**: Gradual traffic shifting for deployments

### Authentication & Authorization

- **API Key Authentication**: Simple token-based auth for internal APIs
- **JWT (JSON Web Tokens)**: Stateless authentication with claims verification
- **OAuth 2.0**: Full OAuth flows for third-party integrations
- **OpenID Connect (OIDC)**: Enterprise SSO with Google, Okta, Auth0, Azure AD
- **mTLS (Mutual TLS)**: Certificate-based service-to-service authentication

### Rate Limiting & Quotas

- **Global Rate Limiting**: Protect entire API from abuse
- **Consumer-Specific Limits**: Tiered pricing (free, premium, enterprise)
- **Endpoint-Specific Limits**: Different limits for different operations
- **Sliding Window Limiting**: Prevent burst attacks
- **Quota Management**: Long-term usage tracking (monthly, yearly)

### Load Balancing

- **Round-Robin**: Even distribution across instances
- **Weighted Load Balancing**: Proportional distribution based on capacity
- **Consistent Hashing**: Session affinity for stateful services
- **Least Connections**: Optimal for long-lived connections
- **Health Checks**: Active and passive health monitoring

### Traffic Control

- **Circuit Breakers**: Prevent cascading failures
- **Request Timeouts**: Protect against slow backends
- **Retry Logic**: Handle transient failures with backoff
- **Request Size Limiting**: Prevent memory exhaustion
- **Traffic Shaping**: Smooth traffic spikes

### Transformation & Translation

- **Request Header Manipulation**: Add, modify, remove headers
- **Response Transformation**: Modify response headers and bodies
- **Request Body Transformation**: Transform payloads before forwarding
- **GraphQL to REST**: Expose REST APIs as GraphQL
- **Protocol Translation**: HTTP to gRPC, WebSocket support

### Caching Strategies

- **Response Caching**: In-memory and Redis-based caching
- **Conditional Caching**: Cache based on status codes and headers
- **Cache Invalidation**: TTL-based and event-driven purging
- **Multi-Tier Caching**: Gateway and backend cache coordination
- **Surrogate-Key Invalidation**: Tag-based granular cache control

### Security

- **CORS**: Cross-origin resource sharing configuration
- **IP Restriction**: Whitelist/blacklist by IP address
- **Bot Detection**: Identify and block malicious bots
- **Request Validation**: Schema-based input validation
- **WAF Integration**: Web application firewall for OWASP Top 10

### Observability

- **Request Logging**: Structured logging to multiple destinations
- **Distributed Tracing**: Zipkin, Jaeger, OpenTelemetry integration
- **Metrics Collection**: Prometheus metrics for monitoring
- **Health Checks**: Kubernetes probes and status endpoints
- **Error Tracking**: Sentry integration and custom error logging

### Multi-Environment Deployment

- **Environment Separation**: Dev, staging, production configurations
- **Blue-Green Deployments**: Zero-downtime deployments
- **Canary Releases**: Gradual rollout with monitoring
- **Feature Flags**: Dynamic feature enabling/disabling
- **Multi-Region**: Geographic routing and failover

## Quick Start

### Installation

**Docker:**
```bash
docker run -d --name kong \
  -e "KONG_DATABASE=off" \
  -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
  -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
  -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
  -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
  -e "KONG_ADMIN_LISTEN=0.0.0.0:8001" \
  -p 8000:8000 \
  -p 8443:8443 \
  -p 8001:8001 \
  kong:latest
```

**Docker Compose:**
```yaml
version: '3.8'

services:
  kong:
    image: kong:latest
    environment:
      KONG_DATABASE: "off"
      KONG_PROXY_ACCESS_LOG: /dev/stdout
      KONG_ADMIN_ACCESS_LOG: /dev/stdout
      KONG_PROXY_ERROR_LOG: /dev/stderr
      KONG_ADMIN_ERROR_LOG: /dev/stderr
      KONG_ADMIN_LISTEN: 0.0.0.0:8001
      KONG_DECLARATIVE_CONFIG: /etc/kong/kong.yaml
    ports:
      - "8000:8000"   # Proxy
      - "8443:8443"   # Proxy SSL
      - "8001:8001"   # Admin API
    volumes:
      - ./kong.yaml:/etc/kong/kong.yaml
```

**Kubernetes:**
```bash
kubectl create -f https://bit.ly/k4k8s
```

### Basic Configuration

Create a simple service and route:

```yaml
# kong.yaml
_format_version: "3.0"

services:
  - name: example-service
    url: http://httpbin.org

routes:
  - name: example-route
    service: example-service
    paths:
      - /httpbin
```

Apply configuration:
```bash
# Using Admin API
curl -i -X POST http://localhost:8001/services \
  --data name=example-service \
  --data url=http://httpbin.org

curl -i -X POST http://localhost:8001/services/example-service/routes \
  --data 'paths[]=/httpbin' \
  --data name=example-route

# Using decK (declarative)
deck sync -s kong.yaml
```

Test the gateway:
```bash
curl http://localhost:8000/httpbin/get
```

### Adding Authentication

Add API key authentication:

```yaml
plugins:
  - name: key-auth
    route: example-route
    config:
      key_names:
        - apikey

consumers:
  - username: test-user

keyauth_credentials:
  - consumer: test-user
    key: my-secret-api-key
```

Apply and test:
```bash
deck sync -s kong.yaml

# Request without key (401)
curl http://localhost:8000/httpbin/get

# Request with key (200)
curl -H "apikey: my-secret-api-key" http://localhost:8000/httpbin/get
```

### Adding Rate Limiting

Protect your API with rate limits:

```yaml
plugins:
  - name: rate-limiting
    route: example-route
    config:
      minute: 5
      hour: 100
      policy: local
```

Apply and test:
```bash
deck sync -s kong.yaml

# First 5 requests succeed
for i in {1..6}; do
  curl -H "apikey: my-secret-api-key" http://localhost:8000/httpbin/get
done
# 6th request returns 429 Too Many Requests
```

## Common Patterns

### Microservices Gateway

Route requests to multiple backend services:

```yaml
services:
  - name: users-service
    url: http://users-api:8001
  - name: orders-service
    url: http://orders-api:8002
  - name: products-service
    url: http://products-api:8003

routes:
  - name: users-route
    service: users-service
    paths:
      - /api/users
    strip_path: true

  - name: orders-route
    service: orders-service
    paths:
      - /api/orders
    strip_path: true

  - name: products-route
    service: products-service
    paths:
      - /api/products
    strip_path: true

plugins:
  - name: jwt
    # Global authentication
  - name: rate-limiting
    # Global rate limiting
  - name: prometheus
    # Metrics collection
```

### API Versioning

Support multiple API versions:

```yaml
# Version 1 (stable)
services:
  - name: api-v1
    url: http://api-v1:8001

routes:
  - name: api-v1-route
    service: api-v1
    paths:
      - /v1
    strip_path: true

# Version 2 (latest)
services:
  - name: api-v2
    url: http://api-v2:8002

routes:
  - name: api-v2-route
    service: api-v2
    paths:
      - /v2
    strip_path: true

# Version 2 via header
routes:
  - name: api-v2-header
    service: api-v2
    paths:
      - /api
    headers:
      X-API-Version:
        - "2"
```

### Load Balancing with Health Checks

Distribute load across multiple instances:

```yaml
upstreams:
  - name: api-upstream
    algorithm: round-robin
    healthchecks:
      active:
        type: http
        http_path: /health
        healthy:
          interval: 5
          successes: 2
        unhealthy:
          interval: 5
          http_failures: 3
          timeouts: 3

targets:
  - upstream: api-upstream
    target: api-1:8001
    weight: 100
  - upstream: api-upstream
    target: api-2:8001
    weight: 100
  - upstream: api-upstream
    target: api-3:8001
    weight: 100

services:
  - name: api-service
    host: api-upstream
    port: 80
    protocol: http

routes:
  - name: api-route
    service: api-service
    paths:
      - /api
```

### Secure Public API

Complete security stack for public APIs:

```yaml
services:
  - name: public-api
    url: https://api.internal:8001
    protocol: https

routes:
  - name: public-api-route
    service: public-api
    paths:
      - /api
    protocols:
      - https

plugins:
  # Authentication
  - name: oauth2
    route: public-api-route
    config:
      scopes:
        - read
        - write
      enable_authorization_code: true

  # Rate limiting (tiered)
  - name: rate-limiting
    route: public-api-route
    config:
      minute: 60
      hour: 1000

  # CORS
  - name: cors
    route: public-api-route
    config:
      origins:
        - https://app.example.com
      methods:
        - GET
        - POST
        - PUT
        - DELETE
      credentials: true

  # IP restriction (admin endpoints)
  - name: ip-restriction
    route: admin-route
    config:
      allow:
        - 10.0.0.0/8

  # Bot detection
  - name: bot-detection
    route: public-api-route

  # Request validation
  - name: request-validator
    route: public-api-route

  # Logging
  - name: http-log
    route: public-api-route
    config:
      http_endpoint: http://logstash:5000

  # Monitoring
  - name: prometheus
    route: public-api-route
```

## Advanced Use Cases

### Canary Deployment

Gradually shift traffic to new version:

```yaml
upstreams:
  - name: api-upstream
    algorithm: round-robin

targets:
  # Stable version (90%)
  - upstream: api-upstream
    target: api-v1:8001
    weight: 900

  # Canary version (10%)
  - upstream: api-upstream
    target: api-v2:8002
    weight: 100

# Monitor errors, latency in v2
# Gradually increase v2 weight: 100 → 300 → 500 → 900 → 1000
# Decrease v1 weight: 900 → 700 → 500 → 100 → 0
```

### Multi-Tenant SaaS

Isolate tenants with custom policies:

```yaml
# Tenant routing
routes:
  - name: tenant-a
    hosts:
      - tenant-a.api.example.com
    service: tenant-a-service

  - name: tenant-b
    hosts:
      - tenant-b.api.example.com
    service: tenant-b-service

# Per-tenant rate limiting
consumers:
  - username: tenant-a
    custom_id: tenant-a-001

plugins:
  - name: rate-limiting
    consumer: tenant-a
    config:
      minute: 1000  # Premium tier

consumers:
  - username: tenant-b
    custom_id: tenant-b-002

plugins:
  - name: rate-limiting
    consumer: tenant-b
    config:
      minute: 100  # Free tier

# Add tenant context to requests
plugins:
  - name: request-transformer
    config:
      add:
        headers:
          - "X-Tenant-ID:$(consumer_custom_id)"
```

### Mobile Backend Gateway

Optimized for mobile apps:

```yaml
services:
  - name: mobile-api
    url: http://mobile-backend:8001

routes:
  - name: mobile-v1
    service: mobile-api
    paths:
      - /mobile/v1
    strip_path: true

plugins:
  # Aggressive caching for mobile
  - name: proxy-cache
    route: mobile-v1
    config:
      strategy: redis
      cache_ttl: 3600
      vary_headers:
        - X-App-Version

  # Device-based rate limiting
  - name: rate-limiting
    route: mobile-v1
    config:
      limit_by: header
      header_name: X-Device-ID
      minute: 100

  # Response compression
  - name: response-transformer
    route: mobile-v1
    config:
      add:
        headers:
          - "Content-Encoding:gzip"

  # Request size limiting (protect uploads)
  - name: request-size-limiting
    route: mobile-upload
    config:
      allowed_payload_size: 10  # MB
```

### Distributed Tracing

Track requests across microservices:

```yaml
plugins:
  # Zipkin tracing
  - name: zipkin
    config:
      http_endpoint: http://zipkin:9411/api/v2/spans
      sample_ratio: 0.1  # Trace 10%
      include_credential: true

  # Or OpenTelemetry
  - name: opentelemetry
    config:
      endpoint: http://jaeger:14268/api/traces
      resource_attributes:
        service.name: api-gateway
        service.version: 1.0.0
      batch_span_processor:
        max_queue_size: 2048

  # Propagate trace context
  - name: request-transformer
    config:
      add:
        headers:
          - "X-Request-ID:$(uuid)"
          - "X-Trace-ID:$(traceid)"
```

## Best Practices

### Configuration Management

1. **Use Declarative Config**: Version control YAML files with Git
2. **Environment Separation**: Separate configs for dev/staging/prod
3. **Validate Before Deploy**: Test configs in staging first
4. **Atomic Updates**: Use decK for all-or-nothing deployments
5. **Backup Configs**: Regular backups of working configurations

### Security

1. **Always Use HTTPS**: Encrypt client-gateway and gateway-upstream
2. **Implement Authentication**: Never expose public APIs without auth
3. **Rate Limit Everything**: Protect against abuse and DDoS
4. **Validate Input**: Use request-validator plugin
5. **Rotate Secrets**: Regularly rotate API keys and certificates
6. **Least Privilege**: Minimal permissions for consumers
7. **Monitor Access**: Log and alert on suspicious activity

### Performance

1. **Enable Caching**: Cache responses aggressively
2. **Use Connection Pooling**: Reuse upstream connections
3. **Set Appropriate Timeouts**: Prevent resource exhaustion
4. **Optimize Plugins**: Only enable necessary plugins
5. **Monitor Latency**: Track request/response times
6. **Scale Horizontally**: Add Kong nodes for traffic growth

### Reliability

1. **Health Checks**: Monitor upstream service health
2. **Circuit Breakers**: Fail fast when dependencies down
3. **Retry Logic**: Handle transient failures automatically
4. **Load Balancing**: Distribute load across instances
5. **Graceful Degradation**: Serve cached or default responses
6. **Disaster Recovery**: Plan for Kong node failures

### Observability

1. **Structured Logging**: Use JSON logs for parsing
2. **Distributed Tracing**: Trace requests across services
3. **Metrics Collection**: Export Prometheus metrics
4. **Alerting**: Set up alerts for errors and latency
5. **Dashboards**: Visualize gateway performance
6. **Health Endpoints**: Expose /health and /metrics

## Troubleshooting

### Common Issues

**Gateway returns 502/503:**
- Check upstream service health
- Verify network connectivity to upstream
- Review timeout settings
- Check upstream health check config

**Authentication failing:**
- Verify consumer credentials are correct
- Check plugin configuration (key names, claims)
- Review request headers (Authorization, apikey)
- Ensure plugin is enabled on correct scope

**Rate limiting not working:**
- Verify policy setting (local vs cluster vs redis)
- Check Redis connectivity if using redis policy
- Review limit_by configuration
- Ensure consumer identification is working

**High latency:**
- Check upstream response times
- Review plugin overhead (disable plugins to isolate)
- Verify connection pooling settings
- Check DNS resolution times
- Review database performance (if using DB mode)

**Cache not working:**
- Verify cache strategy (memory vs redis)
- Check cache_control setting
- Review vary_headers configuration
- Ensure content_type is cacheable
- Check Redis connectivity (if using redis)

### Debugging Techniques

**Enable Debug Logging:**
```bash
# Set log level to debug
export KONG_LOG_LEVEL=debug
kong restart
```

**Check Admin API:**
```bash
# Verify service configuration
curl http://localhost:8001/services/my-service

# Check route configuration
curl http://localhost:8001/routes/my-route

# List enabled plugins
curl http://localhost:8001/plugins
```

**Test Upstream Directly:**
```bash
# Bypass gateway to test upstream
curl http://upstream-host:8001/endpoint
```

**Review Logs:**
```bash
# Proxy logs
tail -f /usr/local/kong/logs/access.log

# Error logs
tail -f /usr/local/kong/logs/error.log
```

## Tools & Resources

### Essential Tools

- **decK**: Declarative configuration management - https://docs.konghq.com/deck/
- **Insomnia**: API client with Kong integration - https://insomnia.rest/
- **Kong Manager**: GUI for Kong management (Enterprise) - https://docs.konghq.com/gateway/latest/kong-manager/
- **Konga**: Open-source Kong admin UI - https://pantsel.github.io/konga/

### Monitoring & Observability

- **Prometheus**: Metrics collection - https://prometheus.io/
- **Grafana**: Metrics visualization - https://grafana.com/
- **Zipkin**: Distributed tracing - https://zipkin.io/
- **Jaeger**: Distributed tracing - https://www.jaegertracing.io/
- **ELK Stack**: Logging (Elasticsearch, Logstash, Kibana) - https://www.elastic.co/

### Development Tools

- **Postman**: API testing - https://www.postman.com/
- **HTTPie**: CLI HTTP client - https://httpie.io/
- **curl**: Universal HTTP client
- **jq**: JSON processor for API responses - https://stedolan.github.io/jq/

### Learning Resources

- **Kong Docs**: https://docs.konghq.com/
- **Kong Plugin Hub**: https://docs.konghq.com/hub/
- **Kong University**: https://education.konghq.com/
- **Kong Blog**: https://konghq.com/blog/
- **Kong Community**: https://discuss.konghq.com/

## Architecture Patterns

### Single Gateway (Simple)
```
Clients → Kong Gateway → Backend Services
```

### Multi-Region (Global)
```
Clients → DNS/GeoDNS → Regional Kong Clusters → Regional Services
```

### Hybrid (Enterprise)
```
Control Plane (Config Management)
    ↓
Data Plane Nodes (Traffic Handling)
    ↓
Backend Services
```

### Service Mesh Integration
```
Clients → Kong (North-South) → Istio/Linkerd (East-West) → Services
```

## Performance Benchmarks

### Typical Performance (single Kong node)

- **Throughput**: 10,000-50,000 req/s (depends on plugins)
- **Latency**: 1-5ms added latency (minimal plugins)
- **CPU Usage**: 2-4 cores for 10,000 req/s
- **Memory**: 512MB-2GB (depends on cache size)

### Scaling Guidelines

- **0-1K req/s**: Single Kong node sufficient
- **1K-10K req/s**: 2-3 Kong nodes with load balancing
- **10K-50K req/s**: 5-10 Kong nodes, consider caching
- **50K+ req/s**: Horizontal scaling, CDN integration, regional deployment

## Next Steps

1. **Read SKILL.md**: Comprehensive patterns and examples
2. **Review EXAMPLES.md**: Detailed implementation examples
3. **Set Up Local Environment**: Install Kong locally
4. **Experiment with Plugins**: Try different plugin combinations
5. **Build Production Config**: Design gateway for your use case
6. **Monitor and Optimize**: Set up observability and tune performance

---

**Version**: 1.0.0
**Last Updated**: October 2025
**Maintainer**: API Gateway Patterns Team
