# Express.js Development

A comprehensive skill for building production-ready web applications and REST APIs using Express.js.

## Overview

Express.js is a minimal and flexible Node.js web application framework that provides a robust set of features for web and mobile applications. This skill covers everything from basic server setup to advanced patterns for authentication, validation, error handling, and deployment.

## What You'll Learn

- **Routing**: HTTP methods, route parameters, query strings, router modules
- **Middleware**: Application-level, router-level, error-handling, built-in, and third-party middleware
- **Request/Response**: Working with request objects, sending responses, headers, cookies
- **Error Handling**: Synchronous and asynchronous error handling patterns
- **Authentication**: JWT-based authentication and authorization
- **Validation**: Input validation and sanitization
- **Database Integration**: MongoDB with Mongoose, SQL databases
- **Testing**: Unit and integration testing with Jest and Supertest
- **Security**: Helmet, CORS, rate limiting, input sanitization
- **Performance**: Compression, caching, optimization techniques
- **Deployment**: Production best practices and deployment strategies

## Installation

### Prerequisites

- Node.js (v14 or higher)
- npm or yarn package manager

### Basic Setup

```bash
# Create a new project
mkdir my-express-app
cd my-express-app

# Initialize package.json
npm init -y

# Install Express
npm install express

# Install development dependencies
npm install --save-dev nodemon
```

### Recommended Packages

```bash
# Essential middleware
npm install cors helmet morgan compression

# Authentication
npm install jsonwebtoken bcryptjs

# Validation
npm install express-validator

# Environment variables
npm install dotenv

# Database (MongoDB)
npm install mongoose

# Database (PostgreSQL)
npm install pg sequelize

# Testing
npm install --save-dev jest supertest

# Security
npm install express-rate-limit express-mongo-sanitize xss-clean
```

## Quick Start

### 1. Create Basic Server

Create `server.js`:

```javascript
const express = require('express');
const app = express();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'Hello Express!' });
});

app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### 2. Run the Server

```bash
# Run directly
node server.js

# Or with nodemon (auto-restart)
npx nodemon server.js
```

### 3. Test the API

```bash
# Using curl
curl http://localhost:3000/
curl http://localhost:3000/api/health

# Using HTTPie
http localhost:3000/
http localhost:3000/api/health
```

## Project Structure

### Basic Structure

```
my-express-app/
├── src/
│   ├── controllers/
│   │   ├── authController.js
│   │   └── userController.js
│   ├── middleware/
│   │   ├── auth.js
│   │   └── validation.js
│   ├── models/
│   │   └── User.js
│   ├── routes/
│   │   ├── auth.js
│   │   └── users.js
│   ├── utils/
│   │   ├── errors.js
│   │   └── asyncHandler.js
│   └── app.js
├── tests/
│   ├── auth.test.js
│   └── users.test.js
├── .env
├── .gitignore
├── package.json
└── server.js
```

### Production Structure

```
my-express-app/
├── src/
│   ├── api/
│   │   ├── controllers/
│   │   ├── middleware/
│   │   ├── routes/
│   │   └── validators/
│   ├── config/
│   │   ├── database.js
│   │   ├── logger.js
│   │   └── environment.js
│   ├── models/
│   ├── services/
│   ├── utils/
│   └── app.js
├── tests/
│   ├── integration/
│   └── unit/
├── logs/
├── .env.example
├── .env
├── .gitignore
├── jest.config.js
├── package.json
└── server.js
```

## Core Concepts

### Routing

Routes define how your application responds to client requests at particular endpoints.

```javascript
const express = require('express');
const router = express.Router();

// GET request
router.get('/users', (req, res) => {
  res.json({ users: [] });
});

// POST request
router.post('/users', (req, res) => {
  const { name, email } = req.body;
  res.status(201).json({ message: 'User created' });
});

// Route parameters
router.get('/users/:id', (req, res) => {
  const { id } = req.params;
  res.json({ userId: id });
});

// Query strings
router.get('/search', (req, res) => {
  const { q, limit = 10 } = req.query;
  res.json({ query: q, limit });
});

module.exports = router;
```

### Middleware

Middleware functions have access to the request and response objects and can modify them or end the request-response cycle.

```javascript
// Application-level middleware
app.use((req, res, next) => {
  console.log(`${req.method} ${req.path}`);
  next();
});

// Built-in middleware
app.use(express.json());
app.use(express.static('public'));

// Third-party middleware
const cors = require('cors');
app.use(cors());

// Custom middleware
function authenticate(req, res, next) {
  const token = req.headers.authorization;
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  // Verify token
  next();
}

app.get('/protected', authenticate, (req, res) => {
  res.json({ message: 'Protected data' });
});
```

### Error Handling

Express provides a built-in error handling mechanism using middleware with four arguments.

```javascript
// Async error wrapper
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Route with error handling
app.get('/users/:id', asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);
  if (!user) {
    const error = new Error('User not found');
    error.status = 404;
    throw error;
  }
  res.json({ user });
}));

// Error handling middleware (must be last)
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    error: {
      message: err.message,
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    }
  });
});
```

## Environment Setup

### Environment Variables

Create `.env` file:

```env
NODE_ENV=development
PORT=3000
DATABASE_URL=mongodb://localhost/myapp
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001
```

### Load Environment Variables

```javascript
require('dotenv').config();

const PORT = process.env.PORT || 3000;
const DB_URL = process.env.DATABASE_URL;
const JWT_SECRET = process.env.JWT_SECRET;
```

### Environment-Specific Configuration

```javascript
const config = {
  development: {
    port: 3000,
    db: 'mongodb://localhost/myapp-dev',
    logLevel: 'debug'
  },
  production: {
    port: process.env.PORT,
    db: process.env.DATABASE_URL,
    logLevel: 'error'
  }
};

const environment = process.env.NODE_ENV || 'development';
module.exports = config[environment];
```

## Common Patterns

### REST API Endpoint Structure

```
GET    /api/users          - List all users
GET    /api/users/:id      - Get single user
POST   /api/users          - Create user
PUT    /api/users/:id      - Update user (full update)
PATCH  /api/users/:id      - Update user (partial update)
DELETE /api/users/:id      - Delete user
```

### Response Format

```javascript
// Success response
{
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "message": "User retrieved successfully"
}

// List response with pagination
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 100,
    "pages": 10
  }
}

// Error response
{
  "error": {
    "message": "User not found",
    "code": "USER_NOT_FOUND"
  }
}
```

### Status Codes

- **200 OK**: Successful GET, PUT, PATCH
- **201 Created**: Successful POST
- **204 No Content**: Successful DELETE
- **400 Bad Request**: Invalid request data
- **401 Unauthorized**: Authentication required
- **403 Forbidden**: Insufficient permissions
- **404 Not Found**: Resource not found
- **422 Unprocessable Entity**: Validation failed
- **500 Internal Server Error**: Server error

## Testing

### Setup Testing Environment

```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'node',
  coveragePathIgnorePatterns: ['/node_modules/'],
  testMatch: ['**/__tests__/**/*.js', '**/?(*.)+(spec|test).js']
};
```

### Basic Test Example

```javascript
const request = require('supertest');
const app = require('../src/app');

describe('User API', () => {
  describe('GET /api/users', () => {
    it('should return all users', async () => {
      const response = await request(app)
        .get('/api/users')
        .expect(200);

      expect(response.body).toHaveProperty('data');
      expect(Array.isArray(response.body.data)).toBe(true);
    });
  });

  describe('POST /api/users', () => {
    it('should create a new user', async () => {
      const userData = {
        name: 'Test User',
        email: 'test@example.com'
      };

      const response = await request(app)
        .post('/api/users')
        .send(userData)
        .expect(201);

      expect(response.body.data).toHaveProperty('id');
      expect(response.body.data.email).toBe(userData.email);
    });
  });
});
```

## Deployment

### Production Checklist

- [ ] Set NODE_ENV=production
- [ ] Use environment variables for sensitive data
- [ ] Enable security middleware (helmet, CORS)
- [ ] Implement rate limiting
- [ ] Set up logging
- [ ] Configure error handling
- [ ] Use compression
- [ ] Set up monitoring
- [ ] Configure SSL/TLS
- [ ] Set up database connection pooling

### PM2 Deployment

```bash
# Install PM2
npm install -g pm2

# Start application
pm2 start server.js --name "my-app"

# Start with environment
pm2 start server.js --name "my-app" --env production

# Monitor
pm2 monit

# View logs
pm2 logs

# Auto-restart on file changes
pm2 start server.js --watch
```

### Docker Deployment

```dockerfile
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["node", "server.js"]
```

## Resources

### Official Documentation

- [Express.js Official Docs](https://expressjs.com/)
- [Express.js API Reference](https://expressjs.com/en/4x/api.html)

### Recommended Middleware

- **helmet**: Security headers
- **cors**: Cross-Origin Resource Sharing
- **morgan**: HTTP request logger
- **compression**: Response compression
- **express-rate-limit**: Rate limiting
- **express-validator**: Request validation
- **cookie-parser**: Cookie parsing
- **multer**: File upload handling

### Related Technologies

- **MongoDB + Mongoose**: NoSQL database
- **PostgreSQL + Sequelize**: SQL database
- **Redis**: Caching
- **Passport.js**: Authentication strategies
- **Socket.io**: Real-time communication
- **GraphQL**: Alternative to REST

## Next Steps

1. Read through SKILL.md for comprehensive concepts and patterns
2. Explore EXAMPLES.md for practical implementations
3. Build a simple REST API following the examples
4. Implement authentication and authorization
5. Add validation and error handling
6. Write tests for your API
7. Deploy to production

## Support

For issues or questions:
- Express.js GitHub: https://github.com/expressjs/express
- Stack Overflow: Use tag `express`
- Express.js Gitter: https://gitter.im/expressjs/express

## License

This skill documentation is provided as-is for educational purposes.
