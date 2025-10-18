# Express.js Microservices Architecture

> Complete guide for building scalable, production-ready microservices with Express.js

## Overview

This skill provides comprehensive knowledge for designing, developing, and deploying microservices using Express.js. Whether you're building RESTful APIs, migrating from monoliths, or designing distributed systems, this skill covers essential patterns, best practices, and production-ready implementations.

## What This Skill Covers

### Core Topics

1. **Express.js Fundamentals**
   - Middleware architecture and patterns
   - Routing strategies and RESTful design
   - Request/response handling
   - Error management
   - Template engines and views

2. **Microservices Patterns**
   - API Gateway pattern
   - Service Discovery
   - Circuit Breaker pattern
   - Event-driven architecture
   - Database per service
   - Saga pattern for distributed transactions
   - CQRS (Command Query Responsibility Segregation)

3. **Middleware Architecture**
   - Custom middleware development
   - Authentication and authorization
   - Request validation
   - Rate limiting and throttling
   - Logging and monitoring
   - CORS and security headers
   - Error-handling middleware

4. **Routing Strategies**
   - RESTful route design
   - Route parameters and query strings
   - API versioning (URL, header, query)
   - Router modules and organization
   - Route chaining and method handlers

5. **Scalability Patterns**
   - Horizontal scaling with clustering
   - Load balancing strategies
   - Caching with Redis
   - Database connection pooling
   - Response compression
   - Request throttling

6. **Production Architecture**
   - Docker containerization
   - Docker Compose orchestration
   - Process management with PM2
   - Health checks and readiness probes
   - Graceful shutdown
   - Monitoring with Prometheus
   - Distributed tracing
   - Logging strategies

7. **Security Best Practices**
   - Helmet.js security headers
   - Input validation and sanitization
   - NoSQL injection prevention
   - XSS protection
   - CSRF protection
   - Rate limiting
   - Secure cookie handling
   - JWT authentication

8. **Testing Strategies**
   - Unit testing
   - Integration testing
   - End-to-end testing
   - API testing with Supertest
   - Mocking and stubbing

9. **Performance Optimization**
   - Compression middleware
   - Database query optimization
   - Pagination strategies
   - Caching layers
   - Connection pooling
   - Keep-alive connections

## Architecture Patterns

### Microservices Architecture

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  API Gateway    │◄─── Authentication, Rate Limiting, Routing
└────────┬────────┘
         │
    ┌────┴────┬────────┬────────┐
    ▼         ▼        ▼        ▼
┌────────┐ ┌────────┐ ┌──────┐ ┌────────┐
│ Users  │ │Products│ │Orders│ │Notif.  │
│Service │ │Service │ │Service│ │Service │
└───┬────┘ └───┬────┘ └──┬───┘ └───┬────┘
    │          │          │         │
┌───▼────┐ ┌───▼────┐ ┌──▼───┐ ┌───▼────┐
│Users DB│ │Prod DB │ │Orders│ │Msg Queue│
└────────┘ └────────┘ │  DB  │ └────────┘
                      └──────┘
```

### Middleware Pipeline

```
Request
  ↓
┌─────────────────────┐
│ Security Middleware │ ← Helmet, CORS
├─────────────────────┤
│ Logging Middleware  │ ← Morgan, Winston
├─────────────────────┤
│ Body Parser         │ ← express.json()
├─────────────────────┤
│ Auth Middleware     │ ← JWT verification
├─────────────────────┤
│ Validation          │ ← express-validator
├─────────────────────┤
│ Rate Limiting       │ ← express-rate-limit
├─────────────────────┤
│ Route Handler       │ ← Business logic
└─────────────────────┘
  ↓
Response

  (If error occurs at any point)
  ↓
┌─────────────────────┐
│ Error Handler       │ ← 4-parameter middleware
└─────────────────────┘
  ↓
Error Response
```

## Quick Start

### Basic Express Microservice

```javascript
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');

const app = express();

// Security middleware
app.use(helmet());
app.use(cors());

// Logging
app.use(morgan('combined'));

// Body parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: Date.now() });
});

app.get('/api/v1/users', async (req, res, next) => {
  try {
    const users = await getUsersFromDB();
    res.json({ users });
  } catch (error) {
    next(error);
  }
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.statusCode || 500).json({
    error: err.message || 'Internal Server Error',
  });
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### Authentication Middleware

```javascript
const jwt = require('jsonwebtoken');

const authenticate = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(403).json({ error: 'Invalid or expired token' });
  }
};

// Usage
app.get('/api/v1/profile', authenticate, (req, res) => {
  res.json({ user: req.user });
});
```

### Error Handling Pattern

```javascript
// Custom error class
class ApiError extends Error {
  constructor(statusCode, message) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
  }
}

// Async error wrapper
const catchAsync = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

// Usage in routes
app.get('/api/users/:id', catchAsync(async (req, res) => {
  const user = await User.findById(req.params.id);

  if (!user) {
    throw new ApiError(404, 'User not found');
  }

  res.json({ user });
}));

// Global error handler
app.use((err, req, res, next) => {
  const statusCode = err.statusCode || 500;
  const message = err.isOperational ? err.message : 'Internal Server Error';

  res.status(statusCode).json({
    error: message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
});
```

## Middleware Patterns Overview

### Application-Level Middleware

Applied to all routes or specific path patterns.

```javascript
// Global middleware
app.use((req, res, next) => {
  req.requestTime = Date.now();
  next();
});

// Path-specific middleware
app.use('/api', apiMiddleware);
```

### Router-Level Middleware

Applied to router instances for modular route handling.

```javascript
const router = express.Router();

router.use((req, res, next) => {
  console.log('Router middleware');
  next();
});

router.get('/users', (req, res) => {
  res.json({ users: [] });
});

app.use('/api/v1', router);
```

### Error-Handling Middleware

Must have 4 parameters (err, req, res, next).

```javascript
app.use((err, req, res, next) => {
  console.error(err.stack);

  res.status(err.statusCode || 500).json({
    error: err.message,
    code: err.code,
  });
});
```

### Built-in Middleware

Express provides several built-in middleware functions.

```javascript
// Parse JSON bodies
app.use(express.json({ limit: '10mb' }));

// Parse URL-encoded bodies
app.use(express.urlencoded({ extended: true }));

// Serve static files
app.use(express.static('public'));
```

### Third-Party Middleware

Popular middleware packages for common functionality.

```javascript
const helmet = require('helmet');           // Security headers
const cors = require('cors');               // CORS handling
const morgan = require('morgan');           // HTTP logging
const compression = require('compression'); // Response compression
const rateLimit = require('express-rate-limit'); // Rate limiting

app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(compression());
app.use(rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }));
```

## When to Use This Skill

### Ideal Use Cases

✅ **Building RESTful APIs**
- Designing scalable API endpoints
- Implementing CRUD operations
- Creating webhook handlers

✅ **Microservices Development**
- Breaking monoliths into services
- Service-to-service communication
- Building event-driven architectures

✅ **API Gateway Implementation**
- Single entry point for microservices
- Request routing and aggregation
- Authentication and authorization layer

✅ **Production Applications**
- High-traffic web services
- Real-time applications
- Enterprise-grade APIs

✅ **Backend for Frontend (BFF)**
- Mobile app backends
- Web application APIs
- GraphQL server implementation

### Not Ideal For

❌ **CPU-Intensive Tasks**
- Video encoding, image processing (use worker threads or separate services)
- Complex mathematical computations (consider Go, Rust, or Python)

❌ **Real-time Requirements < 10ms**
- Ultra-low latency trading systems (use C++, Rust)
- High-frequency gaming servers (use specialized game engines)

❌ **Simple Static Websites**
- Use static site generators (Next.js, Gatsby)
- Simple file serving (use nginx, CDN)

## Project Structure Best Practices

```
express-microservice/
├── src/
│   ├── config/           # Configuration files
│   │   ├── database.js
│   │   ├── redis.js
│   │   └── logger.js
│   ├── controllers/      # Request handlers
│   │   ├── users.controller.js
│   │   └── auth.controller.js
│   ├── middleware/       # Custom middleware
│   │   ├── auth.js
│   │   ├── validation.js
│   │   └── errorHandler.js
│   ├── models/           # Data models
│   │   └── user.model.js
│   ├── routes/           # Route definitions
│   │   ├── index.js
│   │   └── users.routes.js
│   ├── services/         # Business logic
│   │   ├── users.service.js
│   │   └── email.service.js
│   ├── utils/            # Utility functions
│   │   └── apiError.js
│   ├── app.js            # Express app setup
│   └── server.js         # Server initialization
├── tests/                # Test suites
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── .env                  # Environment variables
├── Dockerfile            # Container definition
├── docker-compose.yml    # Multi-container setup
├── ecosystem.config.js   # PM2 configuration
└── package.json
```

## Deployment Strategies

### Docker Deployment

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: api-service:1.0
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
```

### PM2 Cluster Mode

```javascript
module.exports = {
  apps: [{
    name: 'api',
    script: './server.js',
    instances: 'max',
    exec_mode: 'cluster',
    autorestart: true,
    max_memory_restart: '1G',
  }]
};
```

## Performance Benchmarks

**Typical Express.js Performance:**
- Requests/second: 10,000 - 50,000+ (depending on logic)
- Response time: < 10ms (simple routes)
- Memory usage: 50-200MB per instance
- CPU usage: Scales with number of instances

**Optimization Tips:**
1. Use clustering for multi-core CPUs
2. Implement caching (Redis, in-memory)
3. Enable compression
4. Use connection pooling
5. Optimize database queries
6. Implement pagination
7. Use CDN for static assets

## Common Pitfalls to Avoid

1. **Not handling async errors**: Always use try-catch or catchAsync wrapper
2. **Missing error middleware**: 4-parameter error handler should be last
3. **Synchronous code in routes**: Use async/await for I/O operations
4. **No input validation**: Always validate and sanitize user input
5. **Exposing sensitive data**: Don't send stack traces in production
6. **No rate limiting**: Prevent abuse with rate limiting
7. **Blocking the event loop**: Avoid CPU-intensive synchronous operations
8. **Not using middleware order correctly**: Order matters in Express
9. **Missing health checks**: Always implement health endpoints
10. **No graceful shutdown**: Handle SIGTERM/SIGINT properly

## Resources and References

- **Express.js Documentation**: https://expressjs.com/
- **Node.js Best Practices**: https://github.com/goldbergyoni/nodebestpractices
- **Express Security Guide**: https://expressjs.com/en/advanced/best-practice-security.html
- **Microservices Patterns**: https://microservices.io/patterns/
- **Context7 Express Docs**: Latest Express.js documentation and examples

## Next Steps

1. Review the complete SKILL.md for in-depth patterns and implementations
2. Explore EXAMPLES.md for 15+ production-ready code examples
3. Implement your first microservice using the quick start guide
4. Set up monitoring and logging
5. Deploy to production with Docker/Kubernetes
6. Implement CI/CD pipeline

---

**Version**: 1.0.0
**Last Updated**: October 2025
**Maintained By**: Claude Code Skills
**License**: MIT
