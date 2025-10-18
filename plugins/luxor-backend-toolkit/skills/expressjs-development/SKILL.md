---
name: expressjs-development
description: Comprehensive Express.js development skill covering routing, middleware, request/response handling, error handling, and building production-ready REST APIs
category: backend
tags: [expressjs, nodejs, rest-api, middleware, routing, backend, web-server]
version: 1.0.0
context7_library: /expressjs/express
context7_trust_score: 9
---

# Express.js Development Skill

This skill provides comprehensive guidance for building production-ready web applications and REST APIs using Express.js, covering routing, middleware, request/response handling, error handling, authentication, validation, and deployment best practices.

## When to Use This Skill

Use this skill when:
- Building RESTful APIs for web and mobile applications
- Creating backend services and microservices
- Developing web servers with server-side rendering
- Implementing API gateways and proxy servers
- Building real-time applications with WebSocket support
- Creating middleware-based request processing pipelines
- Developing authentication and authorization systems
- Implementing file upload and download services
- Building webhook handlers and integrations
- Creating serverless functions with Express

## Core Concepts

### Application Setup

Express applications are built by creating an instance of Express and configuring middleware and routes.

**Basic Express Application:**
```javascript
const express = require('express');
const app = express();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/', (req, res) => {
  res.send('Hello World!');
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

**Application with Configuration:**
```javascript
const express = require('express');
const app = express();

// App settings
app.set('port', process.env.PORT || 3000);
app.set('env', process.env.NODE_ENV || 'development');
app.set('trust proxy', 1); // Trust first proxy

// View engine setup (optional)
app.set('view engine', 'ejs');
app.set('views', './views');

// Static files
app.use(express.static('public'));

// Body parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

module.exports = app;
```

### Routing

Routing refers to how an application's endpoints (URIs) respond to client requests.

**Basic Routes:**
```javascript
const express = require('express');
const app = express();

// HTTP Methods
app.get('/users', (req, res) => {
  res.json({ message: 'Get all users' });
});

app.post('/users', (req, res) => {
  res.json({ message: 'Create user' });
});

app.put('/users/:id', (req, res) => {
  res.json({ message: `Update user ${req.params.id}` });
});

app.delete('/users/:id', (req, res) => {
  res.json({ message: `Delete user ${req.params.id}` });
});

// Multiple methods on same route
app.route('/users/:id')
  .get((req, res) => res.json({ message: 'Get user' }))
  .put((req, res) => res.json({ message: 'Update user' }))
  .delete((req, res) => res.json({ message: 'Delete user' }));
```

**Route Parameters:**
```javascript
// Single parameter
app.get('/users/:userId', (req, res) => {
  const { userId } = req.params;
  res.json({ userId });
});

// Multiple parameters
app.get('/users/:userId/posts/:postId', (req, res) => {
  const { userId, postId } = req.params;
  res.json({ userId, postId });
});

// Optional parameters with regex
app.get('/users/:userId/posts/:postId?', (req, res) => {
  // postId is optional
  res.json(req.params);
});

// Parameter validation
app.param('userId', (req, res, next, id) => {
  // Validate or transform parameter
  if (!id.match(/^\d+$/)) {
    return res.status(400).json({ error: 'Invalid user ID' });
  }
  req.userId = parseInt(id);
  next();
});
```

**Query Strings:**
```javascript
// GET /search?q=express&limit=10&page=2
app.get('/search', (req, res) => {
  const { q, limit = 20, page = 1 } = req.query;
  res.json({
    query: q,
    limit: parseInt(limit),
    page: parseInt(page)
  });
});
```

**Router Modules:**
```javascript
// routes/users.js
const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.json({ message: 'Get all users' });
});

router.get('/:id', (req, res) => {
  res.json({ message: `Get user ${req.params.id}` });
});

router.post('/', (req, res) => {
  res.json({ message: 'Create user' });
});

module.exports = router;

// app.js
const usersRouter = require('./routes/users');
app.use('/api/users', usersRouter);
```

### Middleware

Middleware functions have access to the request object (req), the response object (res), and the next middleware function in the application's request-response cycle.

**Application-Level Middleware:**
```javascript
// Executed for every request
app.use((req, res, next) => {
  console.log(`${req.method} ${req.path}`);
  next();
});

// Executed for specific path
app.use('/api', (req, res, next) => {
  req.startTime = Date.now();
  next();
});

// Multiple middleware functions
app.use(
  express.json(),
  express.urlencoded({ extended: true }),
  cookieParser()
);
```

**Router-Level Middleware:**
```javascript
const router = express.Router();

// Middleware for all routes in this router
router.use((req, res, next) => {
  console.log('Router middleware');
  next();
});

// Middleware for specific route
router.get('/users',
  authMiddleware,
  validationMiddleware,
  (req, res) => {
    res.json({ users: [] });
  }
);
```

**Built-in Middleware:**
```javascript
// Parse JSON bodies
app.use(express.json());

// Parse URL-encoded bodies
app.use(express.urlencoded({ extended: true }));

// Serve static files
app.use(express.static('public'));
app.use('/uploads', express.static('uploads'));
```

**Third-Party Middleware:**
```javascript
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');

// Security headers
app.use(helmet());

// CORS
app.use(cors({
  origin: 'https://example.com',
  credentials: true
}));

// Logging
app.use(morgan('combined'));

// Compression
app.use(compression());
```

**Custom Middleware:**
```javascript
// Request logging middleware
function requestLogger(req, res, next) {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`${req.method} ${req.path} ${res.statusCode} ${duration}ms`);
  });

  next();
}

// Authentication middleware
function requireAuth(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
}

// Request validation middleware
function validateUser(req, res, next) {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({
      error: 'Email and password are required'
    });
  }

  if (!email.includes('@')) {
    return res.status(400).json({ error: 'Invalid email' });
  }

  next();
}

app.use(requestLogger);
app.post('/login', validateUser, loginHandler);
app.get('/protected', requireAuth, protectedHandler);
```

### Request Object

The request object represents the HTTP request and has properties for query strings, parameters, body, headers, etc.

**Request Properties:**
```javascript
app.post('/api/users/:id', (req, res) => {
  // Route parameters
  const { id } = req.params;

  // Query string
  const { sort, filter } = req.query;

  // Request body
  const { name, email } = req.body;

  // Headers
  const userAgent = req.get('User-Agent');
  const contentType = req.get('Content-Type');

  // Request info
  const method = req.method;
  const path = req.path;
  const url = req.url;
  const baseUrl = req.baseUrl;
  const protocol = req.protocol;
  const hostname = req.hostname;
  const ip = req.ip;

  // Cookies (requires cookie-parser)
  const { sessionId } = req.cookies;

  res.json({ id, name, email });
});
```

**Request Methods:**
```javascript
app.post('/upload', (req, res) => {
  // Check content type
  if (req.is('application/json')) {
    // Handle JSON
  }

  // Check accept header
  if (req.accepts('json')) {
    res.json({ data: 'json response' });
  } else if (req.accepts('html')) {
    res.send('<html>html response</html>');
  }

  // Get header value
  const auth = req.get('Authorization');

  // Get range header
  const range = req.range(1000);
});
```

### Response Object

The response object represents the HTTP response that an Express app sends when it gets an HTTP request.

**Sending Responses:**
```javascript
app.get('/api/data', (req, res) => {
  // Send JSON
  res.json({ message: 'Success', data: [] });

  // Send string
  res.send('Hello World');

  // Send status
  res.sendStatus(200); // Equivalent to res.status(200).send('OK')

  // Send file
  res.sendFile('/path/to/file.pdf');

  // Download file
  res.download('/path/to/file.pdf', 'document.pdf');

  // Render view
  res.render('index', { title: 'Home' });

  // Redirect
  res.redirect('/login');
  res.redirect(301, 'https://example.com');

  // End response
  res.end();
});
```

**Setting Status and Headers:**
```javascript
app.get('/api/resource', (req, res) => {
  // Set status code
  res.status(201).json({ created: true });

  // Set headers
  res.set('Content-Type', 'application/json');
  res.set({
    'X-API-Version': '1.0',
    'X-Rate-Limit': '100'
  });

  // Set cookie
  res.cookie('name', 'value', {
    maxAge: 900000,
    httpOnly: true,
    secure: true,
    sameSite: 'strict'
  });

  // Clear cookie
  res.clearCookie('name');

  res.json({ success: true });
});
```

**Response Formats:**
```javascript
app.get('/api/users/:id', (req, res) => {
  const user = { id: 1, name: 'John' };

  res.format({
    'text/plain': () => {
      res.send(`${user.name}`);
    },
    'text/html': () => {
      res.send(`<p>${user.name}</p>`);
    },
    'application/json': () => {
      res.json(user);
    },
    default: () => {
      res.status(406).send('Not Acceptable');
    }
  });
});
```

### Error Handling

Error-handling middleware functions have four arguments: (err, req, res, next).

**Error-Handling Middleware:**
```javascript
// 404 handler
app.use((req, res, next) => {
  res.status(404).json({ error: 'Not found' });
});

// Error handler (must be last)
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

**Async Error Handling:**
```javascript
// Async wrapper utility
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Using async wrapper
app.get('/api/users/:id', asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);

  if (!user) {
    const error = new Error('User not found');
    error.status = 404;
    throw error;
  }

  res.json(user);
}));

// Custom error classes
class AppError extends Error {
  constructor(message, status) {
    super(message);
    this.status = status;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

class NotFoundError extends AppError {
  constructor(message = 'Resource not found') {
    super(message, 404);
  }
}

class ValidationError extends AppError {
  constructor(message = 'Validation failed') {
    super(message, 400);
  }
}
```

## API Reference

### Express Application Methods

**app.use([path], middleware)**
- Mounts middleware at the specified path
- If path is not specified, middleware is executed for every request

**app.METHOD(path, [middleware...], handler)**
- Routes HTTP requests (GET, POST, PUT, DELETE, etc.)
- Multiple middleware functions can be specified

**app.route(path)**
- Returns an instance of a single route for chaining HTTP verbs

**app.listen(port, [hostname], [backlog], [callback])**
- Binds and listens for connections on the specified host and port

**app.param(name, callback)**
- Adds callback triggers to route parameters

**app.set(name, value)**
- Assigns setting name to value

**app.get(name)**
- Returns the value of setting name

### Router Methods

**router.use([path], middleware)**
- Mounts middleware for the router

**router.METHOD(path, [middleware...], handler)**
- Routes HTTP requests within the router

**router.route(path)**
- Returns a route instance for chaining

**router.param(name, callback)**
- Adds parameter callbacks

### Request Properties

- **req.body**: Contains parsed request body (requires body-parser)
- **req.params**: Route parameters
- **req.query**: Parsed query string
- **req.headers**: Request headers
- **req.cookies**: Cookies (requires cookie-parser)
- **req.method**: HTTP method
- **req.path**: Request path
- **req.url**: Full URL
- **req.ip**: Remote IP address
- **req.protocol**: Request protocol (http or https)

### Request Methods

- **req.get(header)**: Returns header value
- **req.is(type)**: Checks if content type matches
- **req.accepts(types)**: Checks if types are acceptable
- **req.range(size)**: Parses range header

### Response Methods

- **res.json(obj)**: Sends JSON response
- **res.send(body)**: Sends response
- **res.status(code)**: Sets status code
- **res.sendStatus(code)**: Sets status and sends status message
- **res.set(field, value)**: Sets response header
- **res.cookie(name, value, options)**: Sets cookie
- **res.clearCookie(name)**: Clears cookie
- **res.redirect([status], path)**: Redirects to path
- **res.render(view, locals)**: Renders view template
- **res.sendFile(path)**: Sends file
- **res.download(path, filename)**: Downloads file

## Workflow Patterns

### REST API Design

**Complete REST API Example:**
```javascript
const express = require('express');
const router = express.Router();

// GET /api/users - List all users
router.get('/', asyncHandler(async (req, res) => {
  const { page = 1, limit = 10, sort = 'createdAt' } = req.query;

  const users = await User.find()
    .sort(sort)
    .limit(parseInt(limit))
    .skip((parseInt(page) - 1) * parseInt(limit))
    .select('-password');

  const total = await User.countDocuments();

  res.json({
    data: users,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit)
    }
  });
}));

// GET /api/users/:id - Get single user
router.get('/:id', asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id).select('-password');

  if (!user) {
    throw new NotFoundError('User not found');
  }

  res.json({ data: user });
}));

// POST /api/users - Create user
router.post('/',
  validateUser,
  asyncHandler(async (req, res) => {
    const { email, password, name } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      throw new ValidationError('Email already exists');
    }

    const user = await User.create({ email, password, name });

    res.status(201).json({
      data: user.toJSON(),
      message: 'User created successfully'
    });
  })
);

// PUT /api/users/:id - Update user
router.put('/:id',
  requireAuth,
  validateUserUpdate,
  asyncHandler(async (req, res) => {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).select('-password');

    if (!user) {
      throw new NotFoundError('User not found');
    }

    res.json({
      data: user,
      message: 'User updated successfully'
    });
  })
);

// DELETE /api/users/:id - Delete user
router.delete('/:id',
  requireAuth,
  asyncHandler(async (req, res) => {
    const user = await User.findByIdAndDelete(req.params.id);

    if (!user) {
      throw new NotFoundError('User not found');
    }

    res.json({ message: 'User deleted successfully' });
  })
);

module.exports = router;
```

### Authentication

**JWT Authentication:**
```javascript
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// Register
router.post('/register',
  validateRegistration,
  asyncHandler(async (req, res) => {
    const { email, password, name } = req.body;

    // Check if user exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      throw new ValidationError('Email already registered');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user = await User.create({
      email,
      password: hashedPassword,
      name
    });

    // Generate token
    const token = jwt.sign(
      { userId: user._id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(201).json({
      data: {
        user: user.toJSON(),
        token
      }
    });
  })
);

// Login
router.post('/login',
  validateLogin,
  asyncHandler(async (req, res) => {
    const { email, password } = req.body;

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      throw new ValidationError('Invalid credentials');
    }

    // Verify password
    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) {
      throw new ValidationError('Invalid credentials');
    }

    // Generate token
    const token = jwt.sign(
      { userId: user._id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      data: {
        user: user.toJSON(),
        token
      }
    });
  })
);

// Refresh token
router.post('/refresh',
  asyncHandler(async (req, res) => {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      throw new ValidationError('Refresh token required');
    }

    const decoded = jwt.verify(refreshToken, process.env.REFRESH_SECRET);

    const token = jwt.sign(
      { userId: decoded.userId, email: decoded.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({ data: { token } });
  })
);

// Auth middleware
function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new AuthenticationError('No token provided');
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    throw new AuthenticationError('Invalid token');
  }
}

// Role-based authorization
function requireRole(...roles) {
  return async (req, res, next) => {
    const user = await User.findById(req.user.userId);

    if (!user || !roles.includes(user.role)) {
      throw new ForbiddenError('Insufficient permissions');
    }

    next();
  };
}
```

### Validation

**Input Validation with express-validator:**
```javascript
const { body, param, query, validationResult } = require('express-validator');

// Validation middleware
const validate = (validations) => {
  return async (req, res, next) => {
    await Promise.all(validations.map(validation => validation.run(req)));

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    next();
  };
};

// User validation rules
const userValidationRules = {
  create: validate([
    body('email')
      .isEmail()
      .normalizeEmail()
      .withMessage('Invalid email address'),
    body('password')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters')
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
      .withMessage('Password must contain uppercase, lowercase, and number'),
    body('name')
      .trim()
      .isLength({ min: 2, max: 50 })
      .withMessage('Name must be between 2 and 50 characters')
  ]),

  update: validate([
    param('id')
      .isMongoId()
      .withMessage('Invalid user ID'),
    body('email')
      .optional()
      .isEmail()
      .normalizeEmail(),
    body('name')
      .optional()
      .trim()
      .isLength({ min: 2, max: 50 })
  ]),

  list: validate([
    query('page')
      .optional()
      .isInt({ min: 1 })
      .toInt(),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .toInt()
  ])
};

// Using validation
router.post('/users', userValidationRules.create, createUser);
router.put('/users/:id', userValidationRules.update, updateUser);
router.get('/users', userValidationRules.list, listUsers);
```

### Database Integration

**MongoDB with Mongoose:**
```javascript
const mongoose = require('mongoose');

// Connect to database
async function connectDB() {
  try {
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });
    console.log('MongoDB connected');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
}

// User model
const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true
  },
  password: {
    type: String,
    required: true
  },
  name: {
    type: String,
    required: true
  },
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
  }
}, {
  timestamps: true
});

userSchema.methods.toJSON = function() {
  const user = this.toObject();
  delete user.password;
  return user;
};

const User = mongoose.model('User', userSchema);

// CRUD operations
router.get('/users', asyncHandler(async (req, res) => {
  const users = await User.find().select('-password');
  res.json({ data: users });
}));

router.post('/users', asyncHandler(async (req, res) => {
  const user = await User.create(req.body);
  res.status(201).json({ data: user });
}));

router.put('/users/:id', asyncHandler(async (req, res) => {
  const user = await User.findByIdAndUpdate(
    req.params.id,
    req.body,
    { new: true, runValidators: true }
  );
  res.json({ data: user });
}));

router.delete('/users/:id', asyncHandler(async (req, res) => {
  await User.findByIdAndDelete(req.params.id);
  res.json({ message: 'User deleted' });
}));
```

### Testing

**API Testing with Jest and Supertest:**
```javascript
const request = require('supertest');
const app = require('../app');
const User = require('../models/User');

describe('User API', () => {
  beforeEach(async () => {
    await User.deleteMany({});
  });

  describe('POST /api/users', () => {
    it('should create a new user', async () => {
      const userData = {
        email: 'test@example.com',
        password: 'Password123',
        name: 'Test User'
      };

      const response = await request(app)
        .post('/api/users')
        .send(userData)
        .expect(201);

      expect(response.body.data).toHaveProperty('email', userData.email);
      expect(response.body.data).not.toHaveProperty('password');
    });

    it('should return 400 for invalid email', async () => {
      const response = await request(app)
        .post('/api/users')
        .send({
          email: 'invalid-email',
          password: 'Password123',
          name: 'Test'
        })
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });
  });

  describe('GET /api/users/:id', () => {
    it('should return user by id', async () => {
      const user = await User.create({
        email: 'test@example.com',
        password: 'hashed',
        name: 'Test User'
      });

      const response = await request(app)
        .get(`/api/users/${user._id}`)
        .expect(200);

      expect(response.body.data).toHaveProperty('email', user.email);
    });

    it('should return 404 for non-existent user', async () => {
      const response = await request(app)
        .get('/api/users/507f1f77bcf86cd799439011')
        .expect(404);

      expect(response.body).toHaveProperty('error');
    });
  });

  describe('Authentication', () => {
    it('should require authentication for protected routes', async () => {
      await request(app)
        .get('/api/protected')
        .expect(401);
    });

    it('should allow access with valid token', async () => {
      const token = jwt.sign({ userId: '123' }, process.env.JWT_SECRET);

      await request(app)
        .get('/api/protected')
        .set('Authorization', `Bearer ${token}`)
        .expect(200);
    });
  });
});
```

## Best Practices

### Security

**Security Headers with Helmet:**
```javascript
const helmet = require('helmet');

// Use helmet for security headers
app.use(helmet());

// Custom configuration
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", 'data:', 'https:']
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));
```

**CORS Configuration:**
```javascript
const cors = require('cors');

// Allow all origins (development only)
app.use(cors());

// Production configuration
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || 'https://example.com',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400 // 24 hours
}));

// Dynamic origin validation
app.use(cors({
  origin: (origin, callback) => {
    const allowedOrigins = ['https://example.com', 'https://app.example.com'];

    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  }
}));
```

**Rate Limiting:**
```javascript
const rateLimit = require('express-rate-limit');

// General API rate limiter
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP',
  standardHeaders: true,
  legacyHeaders: false
});

app.use('/api/', apiLimiter);

// Strict rate limiter for authentication
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  skipSuccessfulRequests: true
});

app.use('/api/login', authLimiter);
app.use('/api/register', authLimiter);

// Custom key generator
const customLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 100,
  keyGenerator: (req) => {
    return req.user?.id || req.ip;
  }
});
```

**Input Sanitization:**
```javascript
const mongoSanitize = require('express-mongo-sanitize');
const xss = require('xss-clean');

// Prevent NoSQL injection
app.use(mongoSanitize());

// Prevent XSS attacks
app.use(xss());

// Custom sanitization middleware
function sanitizeInput(req, res, next) {
  if (req.body) {
    Object.keys(req.body).forEach(key => {
      if (typeof req.body[key] === 'string') {
        req.body[key] = req.body[key].trim();
      }
    });
  }
  next();
}

app.use(sanitizeInput);
```

### Performance

**Response Compression:**
```javascript
const compression = require('compression');

// Enable compression
app.use(compression({
  level: 6,
  threshold: 1024,
  filter: (req, res) => {
    if (req.headers['x-no-compression']) {
      return false;
    }
    return compression.filter(req, res);
  }
}));
```

**Caching:**
```javascript
// Simple in-memory cache
const cache = new Map();

function cacheMiddleware(duration) {
  return (req, res, next) => {
    const key = req.originalUrl;
    const cached = cache.get(key);

    if (cached && Date.now() < cached.expiry) {
      return res.json(cached.data);
    }

    res.originalJson = res.json;
    res.json = (data) => {
      cache.set(key, {
        data,
        expiry: Date.now() + duration * 1000
      });
      res.originalJson(data);
    };

    next();
  };
}

// Use cache
app.get('/api/users', cacheMiddleware(60), getUsers);

// Redis cache
const redis = require('redis');
const client = redis.createClient();

async function redisCache(duration) {
  return async (req, res, next) => {
    const key = `cache:${req.originalUrl}`;

    const cached = await client.get(key);
    if (cached) {
      return res.json(JSON.parse(cached));
    }

    res.originalJson = res.json;
    res.json = async (data) => {
      await client.setEx(key, duration, JSON.stringify(data));
      res.originalJson(data);
    };

    next();
  };
}
```

**Request Timeout:**
```javascript
function timeout(ms) {
  return (req, res, next) => {
    req.setTimeout(ms, () => {
      res.status(408).json({ error: 'Request timeout' });
    });
    next();
  };
}

app.use(timeout(30000)); // 30 seconds
```

### Error Handling

**Centralized Error Handling:**
```javascript
// Custom error classes
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

class ValidationError extends AppError {
  constructor(message) {
    super(message, 400);
  }
}

class AuthenticationError extends AppError {
  constructor(message) {
    super(message, 401);
  }
}

class NotFoundError extends AppError {
  constructor(message) {
    super(message, 404);
  }
}

// Error handler
function errorHandler(err, req, res, next) {
  let error = { ...err };
  error.message = err.message;

  // Log error
  console.error(err);

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map(e => e.message).join(', ');
    error = new ValidationError(message);
  }

  // Mongoose duplicate key
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    error = new ValidationError(`${field} already exists`);
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    error = new AuthenticationError('Invalid token');
  }

  if (err.name === 'TokenExpiredError') {
    error = new AuthenticationError('Token expired');
  }

  res.status(error.statusCode || 500).json({
    error: {
      message: error.message || 'Server error',
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    }
  });
}

app.use(errorHandler);
```

### Logging

**Morgan and Winston:**
```javascript
const morgan = require('morgan');
const winston = require('winston');

// Winston logger
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple()
  }));
}

// Morgan HTTP logging
app.use(morgan('combined', {
  stream: {
    write: (message) => logger.info(message.trim())
  }
}));

// Custom logging middleware
app.use((req, res, next) => {
  logger.info({
    method: req.method,
    url: req.url,
    ip: req.ip,
    userAgent: req.get('user-agent')
  });
  next();
});
```

### API Versioning

**URL Versioning:**
```javascript
// Version 1 routes
const v1Router = express.Router();
v1Router.get('/users', getUsersV1);
app.use('/api/v1', v1Router);

// Version 2 routes
const v2Router = express.Router();
v2Router.get('/users', getUsersV2);
app.use('/api/v2', v2Router);
```

**Header Versioning:**
```javascript
function apiVersion(version) {
  return (req, res, next) => {
    const requestedVersion = req.get('API-Version') || '1.0';

    if (requestedVersion === version) {
      next();
    } else {
      next('route');
    }
  };
}

app.get('/api/users', apiVersion('1.0'), getUsersV1);
app.get('/api/users', apiVersion('2.0'), getUsersV2);
```

## Examples

### 1. Basic Express Server

```javascript
const express = require('express');
const app = express();

app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'Hello Express!' });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### 2. Complete REST API

```javascript
const express = require('express');
const mongoose = require('mongoose');
const app = express();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Models
const Product = mongoose.model('Product', {
  name: { type: String, required: true },
  price: { type: Number, required: true },
  description: String,
  inStock: { type: Boolean, default: true }
});

// Routes
app.get('/api/products', async (req, res, next) => {
  try {
    const products = await Product.find();
    res.json({ data: products });
  } catch (error) {
    next(error);
  }
});

app.get('/api/products/:id', async (req, res, next) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }
    res.json({ data: product });
  } catch (error) {
    next(error);
  }
});

app.post('/api/products', async (req, res, next) => {
  try {
    const product = await Product.create(req.body);
    res.status(201).json({ data: product });
  } catch (error) {
    next(error);
  }
});

app.put('/api/products/:id', async (req, res, next) => {
  try {
    const product = await Product.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }
    res.json({ data: product });
  } catch (error) {
    next(error);
  }
});

app.delete('/api/products/:id', async (req, res, next) => {
  try {
    const product = await Product.findByIdAndDelete(req.params.id);
    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }
    res.json({ message: 'Product deleted' });
  } catch (error) {
    next(error);
  }
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: err.message });
});

// Start server
mongoose.connect('mongodb://localhost/shop')
  .then(() => {
    app.listen(3000, () => console.log('Server running'));
  });
```

### 3. Authentication System

```javascript
const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const app = express();

app.use(express.json());

const users = new Map(); // In-memory storage

// Register
app.post('/api/register', async (req, res) => {
  const { email, password, name } = req.body;

  if (users.has(email)) {
    return res.status(400).json({ error: 'Email already exists' });
  }

  const hashedPassword = await bcrypt.hash(password, 10);

  users.set(email, {
    email,
    password: hashedPassword,
    name,
    id: Date.now().toString()
  });

  res.status(201).json({ message: 'User created' });
});

// Login
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;

  const user = users.get(email);
  if (!user) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  const isValid = await bcrypt.compare(password, user.password);
  if (!isValid) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  const token = jwt.sign(
    { userId: user.id, email: user.email },
    'secret-key',
    { expiresIn: '24h' }
  );

  res.json({ token });
});

// Protected route
app.get('/api/profile', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'No token' });
  }

  try {
    const decoded = jwt.verify(token, 'secret-key');
    const user = Array.from(users.values()).find(u => u.id === decoded.userId);

    res.json({
      email: user.email,
      name: user.name
    });
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

app.listen(3000);
```

See EXAMPLES.md for 15+ additional examples covering file uploads, CORS, rate limiting, WebSockets, testing, deployment, and more.

## Summary

This Express.js development skill covers:

1. **Core Concepts**: Application setup, routing, middleware, request/response handling, error handling
2. **API Reference**: Complete reference for Express methods and properties
3. **Workflow Patterns**: REST API design, authentication, validation, database integration, testing
4. **Best Practices**: Security (helmet, CORS, rate limiting), performance (compression, caching), error handling, logging, API versioning
5. **Real-world Examples**: Complete implementations for common use cases

The patterns and examples are based on Express.js best practices (Trust Score: 9) and represent modern Node.js backend development standards.
