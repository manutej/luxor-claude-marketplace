# Express.js Examples

Comprehensive code examples demonstrating real-world Express.js patterns and use cases.

## Table of Contents

1. [Basic Server Setup](#1-basic-server-setup)
2. [Routing Patterns](#2-routing-patterns)
3. [Middleware Examples](#3-middleware-examples)
4. [Authentication & Authorization](#4-authentication--authorization)
5. [Input Validation](#5-input-validation)
6. [Database Integration](#6-database-integration)
7. [File Uploads](#7-file-uploads)
8. [Cookies & Sessions](#8-cookies--sessions)
9. [CORS Configuration](#9-cors-configuration)
10. [Rate Limiting](#10-rate-limiting)
11. [API Versioning](#11-api-versioning)
12. [Error Handling](#12-error-handling)
13. [Logging](#13-logging)
14. [Testing](#14-testing)
15. [Security Best Practices](#15-security-best-practices)
16. [WebSocket Integration](#16-websocket-integration)
17. [Email Service](#17-email-service)
18. [Pagination](#18-pagination)
19. [Search & Filtering](#19-search--filtering)
20. [Deployment](#20-deployment)

---

## 1. Basic Server Setup

### Simple Express Server

```javascript
// server.js
const express = require('express');
const app = express();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Basic route
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to Express API',
    version: '1.0.0'
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Route not found'
  });
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
```

### Modular Server Setup

```javascript
// src/app.js
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');

const app = express();

// Security middleware
app.use(helmet());

// CORS
app.use(cors());

// Logging
app.use(morgan('combined'));

// Body parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/users', require('./routes/users'));
app.use('/api/posts', require('./routes/posts'));

// Error handling
app.use(require('./middleware/errorHandler'));

module.exports = app;

// server.js
const app = require('./src/app');
const config = require('./src/config');

app.listen(config.port, () => {
  console.log(`Server running on port ${config.port}`);
});
```

---

## 2. Routing Patterns

### Basic Router Module

```javascript
// routes/users.js
const express = require('express');
const router = express.Router();

// GET all users
router.get('/', (req, res) => {
  res.json({ users: [] });
});

// GET user by ID
router.get('/:id', (req, res) => {
  const { id } = req.params;
  res.json({ userId: id });
});

// POST create user
router.post('/', (req, res) => {
  const { name, email } = req.body;
  res.status(201).json({ name, email });
});

// PUT update user
router.put('/:id', (req, res) => {
  const { id } = req.params;
  const updates = req.body;
  res.json({ id, ...updates });
});

// DELETE user
router.delete('/:id', (req, res) => {
  const { id } = req.params;
  res.json({ message: `User ${id} deleted` });
});

module.exports = router;
```

### Nested Routes

```javascript
// routes/posts.js
const express = require('express');
const router = express.Router();

// Comments router
const commentsRouter = express.Router({ mergeParams: true });

// POST comment on post
commentsRouter.post('/', (req, res) => {
  const { postId } = req.params;
  const { text } = req.body;
  res.status(201).json({ postId, text });
});

// GET comments for post
commentsRouter.get('/', (req, res) => {
  const { postId } = req.params;
  res.json({ postId, comments: [] });
});

// Mount comments router
router.use('/:postId/comments', commentsRouter);

// Post routes
router.get('/', (req, res) => {
  res.json({ posts: [] });
});

router.get('/:postId', (req, res) => {
  const { postId } = req.params;
  res.json({ postId });
});

module.exports = router;
```

### Route Parameter Validation

```javascript
// routes/users.js
const express = require('express');
const router = express.Router();

// Parameter validation middleware
router.param('userId', (req, res, next, id) => {
  // Validate ID format
  if (!id.match(/^[0-9a-fA-F]{24}$/)) {
    return res.status(400).json({
      error: 'Invalid user ID format'
    });
  }

  // Attach validated ID
  req.userId = id;
  next();
});

// Use validated parameter
router.get('/:userId', async (req, res) => {
  const user = await User.findById(req.userId);
  res.json({ user });
});

module.exports = router;
```

### Route Chaining

```javascript
const router = express.Router();

router.route('/users/:id')
  .get((req, res) => {
    res.json({ message: 'Get user' });
  })
  .put((req, res) => {
    res.json({ message: 'Update user' });
  })
  .delete((req, res) => {
    res.json({ message: 'Delete user' });
  });

module.exports = router;
```

---

## 3. Middleware Examples

### Request Logger

```javascript
// middleware/logger.js
function requestLogger(req, res, next) {
  const start = Date.now();

  // Log when response finishes
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(
      `${req.method} ${req.originalUrl} ${res.statusCode} ${duration}ms`
    );
  });

  next();
}

module.exports = requestLogger;

// Usage
app.use(requestLogger);
```

### Request ID Middleware

```javascript
// middleware/requestId.js
const { v4: uuidv4 } = require('uuid');

function requestId(req, res, next) {
  req.id = req.get('X-Request-ID') || uuidv4();
  res.set('X-Request-ID', req.id);
  next();
}

module.exports = requestId;
```

### Timing Middleware

```javascript
// middleware/timing.js
function timing(req, res, next) {
  const start = process.hrtime.bigint();

  res.on('finish', () => {
    const end = process.hrtime.bigint();
    const duration = Number(end - start) / 1000000; // Convert to ms
    res.set('X-Response-Time', `${duration.toFixed(2)}ms`);
  });

  next();
}

module.exports = timing;
```

### Conditional Middleware

```javascript
// middleware/conditional.js
function conditionalMiddleware(condition, middleware) {
  return (req, res, next) => {
    if (condition(req)) {
      return middleware(req, res, next);
    }
    next();
  };
}

// Usage
app.use(conditionalMiddleware(
  req => req.path.startsWith('/api'),
  requireAuth
));
```

### Error Async Wrapper

```javascript
// utils/asyncHandler.js
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

module.exports = asyncHandler;

// Usage
router.get('/users', asyncHandler(async (req, res) => {
  const users = await User.find();
  res.json({ data: users });
}));
```

---

## 4. Authentication & Authorization

### JWT Authentication

```javascript
// middleware/auth.js
const jwt = require('jsonwebtoken');

function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      error: 'No token provided'
    });
  }

  const token = authHeader.substring(7);

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({
      error: 'Invalid or expired token'
    });
  }
}

module.exports = { authenticate };
```

### Complete Auth System

```javascript
// routes/auth.js
const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const asyncHandler = require('../utils/asyncHandler');

const router = express.Router();

// Register
router.post('/register',
  [
    body('email').isEmail().normalizeEmail(),
    body('password').isLength({ min: 8 }),
    body('name').trim().notEmpty()
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, password, name } = req.body;

    // Check existing user
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        error: 'Email already registered'
      });
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
        user: {
          id: user._id,
          email: user.email,
          name: user.name
        },
        token
      }
    });
  })
);

// Login
router.post('/login',
  [
    body('email').isEmail(),
    body('password').notEmpty()
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, password } = req.body;

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({
        error: 'Invalid credentials'
      });
    }

    // Verify password
    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) {
      return res.status(401).json({
        error: 'Invalid credentials'
      });
    }

    // Generate token
    const token = jwt.sign(
      { userId: user._id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      data: {
        user: {
          id: user._id,
          email: user.email,
          name: user.name
        },
        token
      }
    });
  })
);

// Get current user
router.get('/me',
  authenticate,
  asyncHandler(async (req, res) => {
    const user = await User.findById(req.user.userId).select('-password');
    res.json({ data: user });
  })
);

module.exports = router;
```

### Role-Based Authorization

```javascript
// middleware/authorize.js
function authorize(...roles) {
  return async (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        error: 'Authentication required'
      });
    }

    const user = await User.findById(req.user.userId);

    if (!user || !roles.includes(user.role)) {
      return res.status(403).json({
        error: 'Insufficient permissions'
      });
    }

    next();
  };
}

module.exports = authorize;

// Usage
router.delete('/users/:id',
  authenticate,
  authorize('admin', 'moderator'),
  deleteUser
);
```

### API Key Authentication

```javascript
// middleware/apiKey.js
function validateApiKey(req, res, next) {
  const apiKey = req.get('X-API-Key');

  if (!apiKey) {
    return res.status(401).json({
      error: 'API key required'
    });
  }

  if (!isValidApiKey(apiKey)) {
    return res.status(401).json({
      error: 'Invalid API key'
    });
  }

  next();
}

async function isValidApiKey(key) {
  const apiKey = await ApiKey.findOne({ key, active: true });
  return !!apiKey;
}

module.exports = validateApiKey;
```

---

## 5. Input Validation

### Express Validator

```javascript
// validators/userValidator.js
const { body, param, query } = require('express-validator');

const userValidator = {
  create: [
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
      .withMessage('Name must be between 2 and 50 characters'),
    body('age')
      .optional()
      .isInt({ min: 18, max: 120 })
      .withMessage('Age must be between 18 and 120')
  ],

  update: [
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
  ],

  list: [
    query('page')
      .optional()
      .isInt({ min: 1 })
      .toInt()
      .withMessage('Page must be a positive integer'),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .toInt()
      .withMessage('Limit must be between 1 and 100'),
    query('sort')
      .optional()
      .isIn(['name', 'email', 'createdAt'])
      .withMessage('Invalid sort field')
  ]
};

module.exports = userValidator;
```

### Validation Middleware

```javascript
// middleware/validate.js
const { validationResult } = require('express-validator');

function validate(req, res, next) {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation failed',
      details: errors.array().map(err => ({
        field: err.param,
        message: err.msg,
        value: err.value
      }))
    });
  }

  next();
}

module.exports = validate;

// Usage
router.post('/users',
  userValidator.create,
  validate,
  createUser
);
```

### Custom Validators

```javascript
// validators/custom.js
const { body } = require('express-validator');
const User = require('../models/User');

const customValidators = {
  uniqueEmail: body('email').custom(async (email) => {
    const user = await User.findOne({ email });
    if (user) {
      throw new Error('Email already exists');
    }
    return true;
  }),

  strongPassword: body('password').custom((password) => {
    if (!/[A-Z]/.test(password)) {
      throw new Error('Password must contain uppercase letter');
    }
    if (!/[a-z]/.test(password)) {
      throw new Error('Password must contain lowercase letter');
    }
    if (!/[0-9]/.test(password)) {
      throw new Error('Password must contain number');
    }
    if (!/[!@#$%^&*]/.test(password)) {
      throw new Error('Password must contain special character');
    }
    return true;
  }),

  matchingPasswords: body('confirmPassword').custom((value, { req }) => {
    if (value !== req.body.password) {
      throw new Error('Passwords do not match');
    }
    return true;
  })
};

module.exports = customValidators;
```

---

## 6. Database Integration

### MongoDB with Mongoose

```javascript
// config/database.js
const mongoose = require('mongoose');

async function connectDB() {
  try {
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });
    console.log('MongoDB connected successfully');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
}

// Handle connection events
mongoose.connection.on('disconnected', () => {
  console.log('MongoDB disconnected');
});

mongoose.connection.on('error', (err) => {
  console.error('MongoDB error:', err);
});

module.exports = connectDB;

// models/User.js
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  password: {
    type: String,
    required: true
  },
  name: {
    type: String,
    required: true,
    trim: true
  },
  role: {
    type: String,
    enum: ['user', 'admin', 'moderator'],
    default: 'user'
  },
  active: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Virtual field
userSchema.virtual('fullName').get(function() {
  return `${this.firstName} ${this.lastName}`;
});

// Instance method
userSchema.methods.toJSON = function() {
  const user = this.toObject();
  delete user.password;
  return user;
};

// Static method
userSchema.statics.findByEmail = function(email) {
  return this.findOne({ email });
};

// Index
userSchema.index({ email: 1 });

module.exports = mongoose.model('User', userSchema);

// controllers/userController.js
const User = require('../models/User');
const asyncHandler = require('../utils/asyncHandler');

exports.getUsers = asyncHandler(async (req, res) => {
  const { page = 1, limit = 10, sort = 'createdAt' } = req.query;

  const users = await User.find({ active: true })
    .select('-password')
    .sort(sort)
    .limit(parseInt(limit))
    .skip((parseInt(page) - 1) * parseInt(limit));

  const total = await User.countDocuments({ active: true });

  res.json({
    data: users,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit)
    }
  });
});

exports.createUser = asyncHandler(async (req, res) => {
  const user = await User.create(req.body);
  res.status(201).json({ data: user });
});

exports.updateUser = asyncHandler(async (req, res) => {
  const user = await User.findByIdAndUpdate(
    req.params.id,
    req.body,
    { new: true, runValidators: true }
  ).select('-password');

  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  res.json({ data: user });
});

exports.deleteUser = asyncHandler(async (req, res) => {
  const user = await User.findByIdAndDelete(req.params.id);

  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  res.json({ message: 'User deleted successfully' });
});
```

### PostgreSQL with Sequelize

```javascript
// config/database.js
const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    dialect: 'postgres',
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  }
);

async function connectDB() {
  try {
    await sequelize.authenticate();
    console.log('PostgreSQL connected successfully');
    await sequelize.sync({ alter: process.env.NODE_ENV === 'development' });
  } catch (error) {
    console.error('Database connection error:', error);
    process.exit(1);
  }
}

module.exports = { sequelize, connectDB };

// models/User.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const User = sequelize.define('User', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true
    }
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  role: {
    type: DataTypes.ENUM('user', 'admin', 'moderator'),
    defaultValue: 'user'
  },
  active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  timestamps: true,
  tableName: 'users'
});

// Instance method
User.prototype.toJSON = function() {
  const values = { ...this.get() };
  delete values.password;
  return values;
};

module.exports = User;
```

---

## 7. File Uploads

### Multer Configuration

```javascript
// middleware/upload.js
const multer = require('multer');
const path = require('path');

// Storage configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// File filter
const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|pdf/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);

  if (extname && mimetype) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Only JPEG, PNG, GIF, and PDF allowed.'));
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB
  }
});

module.exports = upload;

// routes/upload.js
const express = require('express');
const upload = require('../middleware/upload');
const router = express.Router();

// Single file upload
router.post('/single', upload.single('file'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }

  res.json({
    message: 'File uploaded successfully',
    file: {
      filename: req.file.filename,
      originalname: req.file.originalname,
      size: req.file.size,
      path: req.file.path
    }
  });
});

// Multiple files upload
router.post('/multiple', upload.array('files', 5), (req, res) => {
  if (!req.files || req.files.length === 0) {
    return res.status(400).json({ error: 'No files uploaded' });
  }

  const files = req.files.map(file => ({
    filename: file.filename,
    originalname: file.originalname,
    size: file.size,
    path: file.path
  }));

  res.json({
    message: 'Files uploaded successfully',
    files
  });
});

// Multiple fields
router.post('/fields',
  upload.fields([
    { name: 'avatar', maxCount: 1 },
    { name: 'gallery', maxCount: 5 }
  ]),
  (req, res) => {
    res.json({
      message: 'Files uploaded successfully',
      avatar: req.files.avatar,
      gallery: req.files.gallery
    });
  }
);

module.exports = router;
```

### Image Upload with Sharp

```javascript
// middleware/imageUpload.js
const multer = require('multer');
const sharp = require('sharp');
const path = require('path');
const fs = require('fs').promises;

const upload = multer({
  storage: multer.memoryStorage(),
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (extname && mimetype) {
      cb(null, true);
    } else {
      cb(new Error('Only images allowed'));
    }
  },
  limits: { fileSize: 5 * 1024 * 1024 }
});

async function processImage(req, res, next) {
  if (!req.file) return next();

  const filename = `${Date.now()}-${req.file.originalname}`;

  try {
    await sharp(req.file.buffer)
      .resize(800, 600, { fit: 'inside', withoutEnlargement: true })
      .jpeg({ quality: 90 })
      .toFile(`uploads/${filename}`);

    // Create thumbnail
    await sharp(req.file.buffer)
      .resize(200, 200, { fit: 'cover' })
      .jpeg({ quality: 80 })
      .toFile(`uploads/thumbnails/${filename}`);

    req.processedImage = {
      filename,
      path: `uploads/${filename}`,
      thumbnail: `uploads/thumbnails/${filename}`
    };

    next();
  } catch (error) {
    next(error);
  }
}

module.exports = { upload, processImage };
```

---

## 8. Cookies & Sessions

### Cookie Management

```javascript
// app.js
const cookieParser = require('cookie-parser');
app.use(cookieParser(process.env.COOKIE_SECRET));

// routes/cookies.js
const express = require('express');
const router = express.Router();

// Set cookie
router.get('/set', (req, res) => {
  res.cookie('user', 'john', {
    maxAge: 900000, // 15 minutes
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict'
  });

  res.json({ message: 'Cookie set' });
});

// Read cookie
router.get('/read', (req, res) => {
  const { user } = req.cookies;
  res.json({ user });
});

// Clear cookie
router.get('/clear', (req, res) => {
  res.clearCookie('user');
  res.json({ message: 'Cookie cleared' });
});

module.exports = router;
```

### Session Management

```javascript
// app.js
const session = require('express-session');
const MongoStore = require('connect-mongo');

app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  store: MongoStore.create({
    mongoUrl: process.env.MONGODB_URI,
    ttl: 24 * 60 * 60 // 1 day
  }),
  cookie: {
    maxAge: 24 * 60 * 60 * 1000, // 1 day
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict'
  }
}));

// routes/session.js
router.post('/login', (req, res) => {
  const { username, password } = req.body;

  // Validate credentials
  if (isValidCredentials(username, password)) {
    req.session.user = {
      username,
      loggedInAt: new Date()
    };

    res.json({ message: 'Logged in successfully' });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

router.get('/profile', (req, res) => {
  if (!req.session.user) {
    return res.status(401).json({ error: 'Not authenticated' });
  }

  res.json({ user: req.session.user });
});

router.post('/logout', (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      return res.status(500).json({ error: 'Logout failed' });
    }
    res.clearCookie('connect.sid');
    res.json({ message: 'Logged out successfully' });
  });
});
```

---

## 9. CORS Configuration

```javascript
// config/cors.js
const cors = require('cors');

// Basic CORS
const basicCors = cors();

// Custom CORS
const customCors = cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  exposedHeaders: ['X-Total-Count'],
  credentials: true,
  maxAge: 86400 // 24 hours
});

// Dynamic CORS
const dynamicCors = cors({
  origin: (origin, callback) => {
    const allowedOrigins = [
      'http://localhost:3000',
      'https://example.com',
      'https://app.example.com'
    ];

    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
});

// Conditional CORS
function conditionalCors(req, res, next) {
  if (req.path.startsWith('/api/public')) {
    return cors()(req, res, next);
  }
  next();
}

module.exports = { basicCors, customCors, dynamicCors, conditionalCors };
```

---

## 10. Rate Limiting

```javascript
// middleware/rateLimiter.js
const rateLimit = require('express-rate-limit');
const RedisStore = require('rate-limit-redis');
const redis = require('redis');

// Basic rate limiter
const basicLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  message: 'Too many requests from this IP',
  standardHeaders: true,
  legacyHeaders: false
});

// Strict rate limiter for auth
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  skipSuccessfulRequests: true,
  message: 'Too many login attempts'
});

// Redis-based rate limiter
const redisClient = redis.createClient();

const redisLimiter = rateLimit({
  store: new RedisStore({
    client: redisClient,
    prefix: 'rl:'
  }),
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 1000
});

// Custom key generator (per user)
const userLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 100,
  keyGenerator: (req) => {
    return req.user?.id || req.ip;
  },
  handler: (req, res) => {
    res.status(429).json({
      error: 'Rate limit exceeded',
      retryAfter: req.rateLimit.resetTime
    });
  }
});

// Slow down instead of blocking
const slowDown = require('express-slow-down');

const speedLimiter = slowDown({
  windowMs: 15 * 60 * 1000,
  delayAfter: 50,
  delayMs: 500
});

module.exports = {
  basicLimiter,
  authLimiter,
  redisLimiter,
  userLimiter,
  speedLimiter
};

// Usage
app.use('/api/', basicLimiter);
app.use('/api/login', authLimiter);
app.use('/api/register', authLimiter);
```

---

## 11. API Versioning

### URL Versioning

```javascript
// app.js
const v1Routes = require('./routes/v1');
const v2Routes = require('./routes/v2');

app.use('/api/v1', v1Routes);
app.use('/api/v2', v2Routes);

// routes/v1/index.js
const express = require('express');
const router = express.Router();

router.use('/users', require('./users'));
router.use('/posts', require('./posts'));

module.exports = router;

// routes/v2/index.js
const express = require('express');
const router = express.Router();

router.use('/users', require('./users'));
router.use('/posts', require('./posts'));

module.exports = router;
```

### Header Versioning

```javascript
// middleware/apiVersion.js
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

module.exports = apiVersion;

// Usage
app.get('/api/users', apiVersion('1.0'), getUsersV1);
app.get('/api/users', apiVersion('2.0'), getUsersV2);
app.get('/api/users', (req, res) => {
  res.status(400).json({ error: 'Unsupported API version' });
});
```

### Accept Header Versioning

```javascript
// middleware/acceptVersion.js
function acceptVersion(version) {
  return (req, res, next) => {
    const accept = req.get('Accept');

    if (accept && accept.includes(`application/vnd.api.v${version}+json`)) {
      next();
    } else {
      next('route');
    }
  };
}

// Usage
app.get('/api/users',
  acceptVersion('1'),
  getUsersV1
);

app.get('/api/users',
  acceptVersion('2'),
  getUsersV2
);
```

---

## 12. Error Handling

### Custom Error Classes

```javascript
// utils/errors.js
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

class ValidationError extends AppError {
  constructor(message = 'Validation failed') {
    super(message, 400);
  }
}

class AuthenticationError extends AppError {
  constructor(message = 'Authentication required') {
    super(message, 401);
  }
}

class ForbiddenError extends AppError {
  constructor(message = 'Forbidden') {
    super(message, 403);
  }
}

class NotFoundError extends AppError {
  constructor(message = 'Resource not found') {
    super(message, 404);
  }
}

class ConflictError extends AppError {
  constructor(message = 'Resource conflict') {
    super(message, 409);
  }
}

module.exports = {
  AppError,
  ValidationError,
  AuthenticationError,
  ForbiddenError,
  NotFoundError,
  ConflictError
};
```

### Error Handler Middleware

```javascript
// middleware/errorHandler.js
const { AppError } = require('../utils/errors');

function errorHandler(err, req, res, next) {
  let error = { ...err };
  error.message = err.message;

  // Log error
  console.error(err);

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map(e => e.message).join(', ');
    error = new AppError(message, 400);
  }

  // Mongoose duplicate key
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    error = new AppError(`${field} already exists`, 409);
  }

  // Mongoose cast error
  if (err.name === 'CastError') {
    error = new AppError('Invalid ID format', 400);
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    error = new AppError('Invalid token', 401);
  }

  if (err.name === 'TokenExpiredError') {
    error = new AppError('Token expired', 401);
  }

  // Multer errors
  if (err.name === 'MulterError') {
    if (err.code === 'LIMIT_FILE_SIZE') {
      error = new AppError('File too large', 400);
    }
  }

  res.status(error.statusCode || 500).json({
    error: {
      message: error.message || 'Server error',
      ...(process.env.NODE_ENV === 'development' && {
        stack: err.stack,
        details: err
      })
    }
  });
}

// 404 handler
function notFoundHandler(req, res, next) {
  res.status(404).json({
    error: {
      message: 'Route not found',
      path: req.originalUrl
    }
  });
}

module.exports = { errorHandler, notFoundHandler };
```

---

## 13. Logging

### Winston Logger

```javascript
// config/logger.js
const winston = require('winston');
const path = require('path');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'api' },
  transports: [
    new winston.transports.File({
      filename: path.join('logs', 'error.log'),
      level: 'error',
      maxsize: 5242880, // 5MB
      maxFiles: 5
    }),
    new winston.transports.File({
      filename: path.join('logs', 'combined.log'),
      maxsize: 5242880,
      maxFiles: 5
    })
  ]
});

// Console logging in development
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.simple()
    )
  }));
}

module.exports = logger;

// middleware/requestLogger.js
const logger = require('../config/logger');

function requestLogger(req, res, next) {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;

    logger.info({
      method: req.method,
      url: req.originalUrl,
      status: res.statusCode,
      duration: `${duration}ms`,
      ip: req.ip,
      userAgent: req.get('user-agent')
    });
  });

  next();
}

module.exports = requestLogger;
```

### Morgan HTTP Logger

```javascript
// config/morgan.js
const morgan = require('morgan');
const logger = require('./logger');

// Custom token
morgan.token('id', (req) => req.id);

// Custom format
const format = ':id :method :url :status :response-time ms - :res[content-length]';

// Stream to Winston
const stream = {
  write: (message) => logger.http(message.trim())
};

const morganMiddleware = morgan(format, { stream });

module.exports = morganMiddleware;
```

---

## 14. Testing

### Jest Configuration

```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'node',
  coveragePathIgnorePatterns: ['/node_modules/'],
  testMatch: ['**/__tests__/**/*.js', '**/?(*.)+(spec|test).js'],
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/**/*.test.js',
    '!src/**/*.spec.js'
  ],
  setupFilesAfterEnv: ['./tests/setup.js']
};

// tests/setup.js
const mongoose = require('mongoose');

beforeAll(async () => {
  await mongoose.connect(process.env.TEST_DATABASE_URL);
});

afterAll(async () => {
  await mongoose.connection.close();
});

afterEach(async () => {
  const collections = mongoose.connection.collections;
  for (const key in collections) {
    await collections[key].deleteMany();
  }
});
```

### API Tests

```javascript
// tests/auth.test.js
const request = require('supertest');
const app = require('../src/app');
const User = require('../src/models/User');

describe('Authentication', () => {
  describe('POST /api/auth/register', () => {
    it('should register a new user', async () => {
      const userData = {
        email: 'test@example.com',
        password: 'Password123!',
        name: 'Test User'
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(201);

      expect(response.body.data).toHaveProperty('token');
      expect(response.body.data.user).toHaveProperty('email', userData.email);
      expect(response.body.data.user).not.toHaveProperty('password');

      const user = await User.findOne({ email: userData.email });
      expect(user).toBeTruthy();
    });

    it('should return 400 for invalid email', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'invalid-email',
          password: 'Password123!',
          name: 'Test'
        })
        .expect(400);

      expect(response.body).toHaveProperty('errors');
    });

    it('should return 400 for duplicate email', async () => {
      await User.create({
        email: 'existing@example.com',
        password: 'hashed',
        name: 'Existing'
      });

      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'existing@example.com',
          password: 'Password123!',
          name: 'New User'
        })
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });
  });

  describe('POST /api/auth/login', () => {
    beforeEach(async () => {
      await request(app)
        .post('/api/auth/register')
        .send({
          email: 'test@example.com',
          password: 'Password123!',
          name: 'Test User'
        });
    });

    it('should login with valid credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'test@example.com',
          password: 'Password123!'
        })
        .expect(200);

      expect(response.body.data).toHaveProperty('token');
      expect(response.body.data.user).toHaveProperty('email', 'test@example.com');
    });

    it('should return 401 for invalid credentials', async () => {
      await request(app)
        .post('/api/auth/login')
        .send({
          email: 'test@example.com',
          password: 'WrongPassword'
        })
        .expect(401);
    });
  });

  describe('GET /api/auth/me', () => {
    let token;

    beforeEach(async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'test@example.com',
          password: 'Password123!',
          name: 'Test User'
        });

      token = response.body.data.token;
    });

    it('should return current user with valid token', async () => {
      const response = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${token}`)
        .expect(200);

      expect(response.body.data).toHaveProperty('email', 'test@example.com');
    });

    it('should return 401 without token', async () => {
      await request(app)
        .get('/api/auth/me')
        .expect(401);
    });
  });
});
```

### Unit Tests

```javascript
// tests/unit/validators.test.js
const { validateEmail, validatePassword } = require('../../src/utils/validators');

describe('Validators', () => {
  describe('validateEmail', () => {
    it('should validate correct email', () => {
      expect(validateEmail('test@example.com')).toBe(true);
    });

    it('should reject invalid email', () => {
      expect(validateEmail('invalid-email')).toBe(false);
      expect(validateEmail('test@')).toBe(false);
      expect(validateEmail('@example.com')).toBe(false);
    });
  });

  describe('validatePassword', () => {
    it('should validate strong password', () => {
      expect(validatePassword('Password123!')).toBe(true);
    });

    it('should reject weak password', () => {
      expect(validatePassword('short')).toBe(false);
      expect(validatePassword('nouppercase123!')).toBe(false);
      expect(validatePassword('NOLOWERCASE123!')).toBe(false);
      expect(validatePassword('NoNumbers!')).toBe(false);
    });
  });
});
```

---

## 15. Security Best Practices

```javascript
// app.js - Security Setup
const express = require('express');
const helmet = require('helmet');
const mongoSanitize = require('express-mongo-sanitize');
const xss = require('xss-clean');
const hpp = require('hpp');
const cors = require('cors');
const rateLimit = require('express-rate-limit');

const app = express();

// Security headers
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

// CORS
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(','),
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});
app.use('/api', limiter);

// Body parsing with size limits
app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: true, limit: '10kb' }));

// Data sanitization against NoSQL injection
app.use(mongoSanitize());

// Data sanitization against XSS
app.use(xss());

// Prevent HTTP parameter pollution
app.use(hpp({
  whitelist: ['sort', 'filter']
}));

// Disable X-Powered-By header
app.disable('x-powered-by');

module.exports = app;
```

---

## 16. WebSocket Integration

```javascript
// server.js
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: process.env.CLIENT_URL,
    methods: ['GET', 'POST']
  }
});

// Socket.io middleware
io.use((socket, next) => {
  const token = socket.handshake.auth.token;
  if (isValidToken(token)) {
    socket.userId = getUserIdFromToken(token);
    next();
  } else {
    next(new Error('Authentication error'));
  }
});

// Socket.io events
io.on('connection', (socket) => {
  console.log('User connected:', socket.userId);

  socket.on('join-room', (roomId) => {
    socket.join(roomId);
    io.to(roomId).emit('user-joined', socket.userId);
  });

  socket.on('send-message', (data) => {
    io.to(data.roomId).emit('new-message', {
      userId: socket.userId,
      message: data.message,
      timestamp: new Date()
    });
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.userId);
  });
});

server.listen(3000);
```

---

## 17. Email Service

```javascript
// services/emailService.js
const nodemailer = require('nodemailer');

class EmailService {
  constructor() {
    this.transporter = nodemailer.createTransporter({
      host: process.env.SMTP_HOST,
      port: process.env.SMTP_PORT,
      secure: true,
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS
      }
    });
  }

  async sendEmail({ to, subject, html, text }) {
    const mailOptions = {
      from: process.env.EMAIL_FROM,
      to,
      subject,
      html,
      text
    };

    return await this.transporter.sendMail(mailOptions);
  }

  async sendWelcomeEmail(user) {
    return await this.sendEmail({
      to: user.email,
      subject: 'Welcome!',
      html: `<h1>Welcome ${user.name}!</h1>`,
      text: `Welcome ${user.name}!`
    });
  }

  async sendPasswordReset(user, token) {
    const resetUrl = `${process.env.CLIENT_URL}/reset-password/${token}`;

    return await this.sendEmail({
      to: user.email,
      subject: 'Password Reset',
      html: `<p>Reset your password: <a href="${resetUrl}">${resetUrl}</a></p>`,
      text: `Reset your password: ${resetUrl}`
    });
  }
}

module.exports = new EmailService();
```

---

## 18. Pagination

```javascript
// middleware/paginate.js
function paginate(model) {
  return async (req, res, next) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    try {
      const total = await model.countDocuments();
      const data = await model.find()
        .limit(limit)
        .skip(skip)
        .sort(req.query.sort || '-createdAt');

      req.paginatedResults = {
        data,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit),
          hasNext: page * limit < total,
          hasPrev: page > 1
        }
      };

      next();
    } catch (error) {
      next(error);
    }
  };
}

module.exports = paginate;

// Usage
router.get('/users',
  paginate(User),
  (req, res) => {
    res.json(req.paginatedResults);
  }
);
```

---

## 19. Search & Filtering

```javascript
// controllers/searchController.js
exports.search = asyncHandler(async (req, res) => {
  const {
    q,
    category,
    minPrice,
    maxPrice,
    inStock,
    sort = '-createdAt',
    page = 1,
    limit = 10
  } = req.query;

  // Build query
  const query = {};

  if (q) {
    query.$or = [
      { name: { $regex: q, $options: 'i' } },
      { description: { $regex: q, $options: 'i' } }
    ];
  }

  if (category) {
    query.category = category;
  }

  if (minPrice || maxPrice) {
    query.price = {};
    if (minPrice) query.price.$gte = parseFloat(minPrice);
    if (maxPrice) query.price.$lte = parseFloat(maxPrice);
  }

  if (inStock !== undefined) {
    query.inStock = inStock === 'true';
  }

  // Execute query
  const skip = (parseInt(page) - 1) * parseInt(limit);

  const [products, total] = await Promise.all([
    Product.find(query)
      .sort(sort)
      .limit(parseInt(limit))
      .skip(skip),
    Product.countDocuments(query)
  ]);

  res.json({
    data: products,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit)
    }
  });
});
```

---

## 20. Deployment

### PM2 Ecosystem File

```javascript
// ecosystem.config.js
module.exports = {
  apps: [{
    name: 'api',
    script: './server.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'development'
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: './logs/pm2-error.log',
    out_file: './logs/pm2-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    max_memory_restart: '1G',
    autorestart: true,
    watch: false,
    ignore_watch: ['node_modules', 'logs'],
    max_restarts: 10,
    min_uptime: '10s'
  }]
};
```

### Dockerfile

```dockerfile
FROM node:16-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD node healthcheck.js

# Start application
CMD ["node", "server.js"]
```

### Docker Compose

```yaml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=mongodb://mongo:27017/myapp
      - REDIS_URL=redis://redis:6379
    depends_on:
      - mongo
      - redis
    restart: unless-stopped

  mongo:
    image: mongo:5
    volumes:
      - mongo-data:/data/db
    restart: unless-stopped

  redis:
    image: redis:alpine
    restart: unless-stopped

volumes:
  mongo-data:
```

---

## Summary

These examples cover the essential patterns and use cases for Express.js development:

- Server setup and configuration
- Routing and route organization
- Middleware implementation
- Authentication and authorization
- Input validation
- Database integration
- File uploads
- Sessions and cookies
- CORS and security
- Rate limiting
- API versioning
- Error handling
- Logging
- Testing
- Real-time features
- Email services
- Pagination and search
- Deployment strategies

Each example is production-ready and follows Express.js best practices.
