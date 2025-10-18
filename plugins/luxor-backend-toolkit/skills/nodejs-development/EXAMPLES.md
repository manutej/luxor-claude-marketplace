# Node.js Development Examples

Comprehensive code examples demonstrating Node.js patterns and use cases.

## Table of Contents

1. [HTTP Server Examples](#http-server-examples)
2. [Express.js REST API](#expressjs-rest-api)
3. [File Operations](#file-operations)
4. [Stream Processing](#stream-processing)
5. [Async Patterns](#async-patterns)
6. [CLI Tools](#cli-tools)
7. [Environment Variables](#environment-variables)
8. [Error Handling](#error-handling)
9. [Database Integration](#database-integration)
10. [Authentication & Authorization](#authentication--authorization)
11. [Middleware Patterns](#middleware-patterns)
12. [Testing Examples](#testing-examples)
13. [WebSocket Real-time](#websocket-real-time)
14. [Child Processes](#child-processes)
15. [Cluster Mode](#cluster-mode)
16. [Email Sending](#email-sending)
17. [File Upload](#file-upload)
18. [Caching Strategies](#caching-strategies)
19. [Rate Limiting](#rate-limiting)
20. [Deployment & Production](#deployment--production)

## HTTP Server Examples

### Basic HTTP Server

```javascript
const http = require('http');

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World\n');
});

const PORT = 3000;
server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}/`);
});
```

### HTTP Server with Routing

```javascript
const http = require('http');
const url = require('url');

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;
  const method = req.method;

  if (path === '/' && method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end('<h1>Welcome Home</h1>');
  } else if (path === '/api/data' && method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ message: 'API Data', timestamp: Date.now() }));
  } else if (path === '/api/data' && method === 'POST') {
    let body = '';

    req.on('data', chunk => {
      body += chunk.toString();
    });

    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        res.writeHead(201, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          success: true,
          received: data,
          timestamp: Date.now()
        }));
      } catch (err) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Invalid JSON' }));
      }
    });
  } else {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('404 Not Found');
  }
});

server.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

### HTTPS Server with SSL/TLS

```javascript
const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('server-key.pem'),
  cert: fs.readFileSync('server-cert.pem')
};

const server = https.createServer(options, (req, res) => {
  res.writeHead(200);
  res.end('Secure Hello World\n');
});

server.listen(443, () => {
  console.log('HTTPS server running on port 443');
});
```

## Express.js REST API

### Complete REST API Example

```javascript
const express = require('express');
const app = express();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// In-memory database
let users = [
  { id: 1, name: 'Alice', email: 'alice@example.com' },
  { id: 2, name: 'Bob', email: 'bob@example.com' }
];

let nextId = 3;

// Logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// GET all users
app.get('/api/users', (req, res) => {
  res.json(users);
});

// GET single user
app.get('/api/users/:id', (req, res) => {
  const user = users.find(u => u.id === parseInt(req.params.id));

  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  res.json(user);
});

// POST create user
app.post('/api/users', (req, res) => {
  const { name, email } = req.body;

  if (!name || !email) {
    return res.status(400).json({ error: 'Name and email required' });
  }

  const user = {
    id: nextId++,
    name,
    email
  };

  users.push(user);
  res.status(201).json(user);
});

// PUT update user
app.put('/api/users/:id', (req, res) => {
  const user = users.find(u => u.id === parseInt(req.params.id));

  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  const { name, email } = req.body;

  if (name) user.name = name;
  if (email) user.email = email;

  res.json(user);
});

// DELETE user
app.delete('/api/users/:id', (req, res) => {
  const index = users.findIndex(u => u.id === parseInt(req.params.id));

  if (index === -1) {
    return res.status(404).json({ error: 'User not found' });
  }

  users.splice(index, 1);
  res.status(204).end();
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
```

### Express Router Organization

```javascript
// routes/users.js
const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.json({ users: [] });
});

router.get('/:id', (req, res) => {
  res.json({ id: req.params.id });
});

router.post('/', (req, res) => {
  res.status(201).json(req.body);
});

module.exports = router;

// app.js
const express = require('express');
const usersRouter = require('./routes/users');

const app = express();

app.use('/api/users', usersRouter);

app.listen(3000);
```

## File Operations

### Read File Examples

```javascript
const fs = require('fs').promises;
const path = require('path');

// Read text file
async function readTextFile(filename) {
  try {
    const data = await fs.readFile(filename, 'utf8');
    console.log('File contents:', data);
    return data;
  } catch (err) {
    console.error('Error reading file:', err);
    throw err;
  }
}

// Read JSON file
async function readJSONFile(filename) {
  try {
    const data = await fs.readFile(filename, 'utf8');
    return JSON.parse(data);
  } catch (err) {
    if (err.code === 'ENOENT') {
      console.error('File not found');
    } else if (err instanceof SyntaxError) {
      console.error('Invalid JSON');
    }
    throw err;
  }
}

// Read multiple files concurrently
async function readMultipleFiles(filenames) {
  try {
    const promises = filenames.map(f => fs.readFile(f, 'utf8'));
    const results = await Promise.all(promises);
    return results;
  } catch (err) {
    console.error('Error reading files:', err);
    throw err;
  }
}

// Usage
readTextFile('example.txt');
readJSONFile('config.json').then(config => console.log(config));
readMultipleFiles(['file1.txt', 'file2.txt', 'file3.txt']);
```

### Write File Examples

```javascript
const fs = require('fs').promises;

// Write text file
async function writeTextFile(filename, content) {
  try {
    await fs.writeFile(filename, content, 'utf8');
    console.log('File written successfully');
  } catch (err) {
    console.error('Error writing file:', err);
    throw err;
  }
}

// Write JSON file (formatted)
async function writeJSONFile(filename, data) {
  try {
    const json = JSON.stringify(data, null, 2);
    await fs.writeFile(filename, json, 'utf8');
    console.log('JSON file written successfully');
  } catch (err) {
    console.error('Error writing JSON file:', err);
    throw err;
  }
}

// Append to file
async function appendToFile(filename, content) {
  try {
    await fs.appendFile(filename, content + '\n', 'utf8');
    console.log('Content appended successfully');
  } catch (err) {
    console.error('Error appending to file:', err);
    throw err;
  }
}

// Atomic write (write to temp file, then rename)
async function atomicWrite(filename, content) {
  const tempFile = `${filename}.tmp`;

  try {
    await fs.writeFile(tempFile, content, 'utf8');
    await fs.rename(tempFile, filename);
    console.log('File written atomically');
  } catch (err) {
    // Clean up temp file if it exists
    try {
      await fs.unlink(tempFile);
    } catch {}
    throw err;
  }
}

// Usage
writeTextFile('output.txt', 'Hello World');
writeJSONFile('data.json', { name: 'John', age: 30 });
appendToFile('log.txt', 'New log entry');
atomicWrite('config.json', JSON.stringify({ version: '1.0' }));
```

### Directory Operations

```javascript
const fs = require('fs').promises;
const path = require('path');

// List directory contents
async function listDirectory(dirPath) {
  try {
    const files = await fs.readdir(dirPath);
    console.log('Files:', files);
    return files;
  } catch (err) {
    console.error('Error reading directory:', err);
    throw err;
  }
}

// List with file types
async function listDirectoryDetailed(dirPath) {
  try {
    const entries = await fs.readdir(dirPath, { withFileTypes: true });

    const files = [];
    const directories = [];

    for (const entry of entries) {
      if (entry.isFile()) {
        files.push(entry.name);
      } else if (entry.isDirectory()) {
        directories.push(entry.name);
      }
    }

    return { files, directories };
  } catch (err) {
    console.error('Error:', err);
    throw err;
  }
}

// Create directory recursively
async function createDirectory(dirPath) {
  try {
    await fs.mkdir(dirPath, { recursive: true });
    console.log('Directory created');
  } catch (err) {
    console.error('Error creating directory:', err);
    throw err;
  }
}

// Remove directory recursively
async function removeDirectory(dirPath) {
  try {
    await fs.rm(dirPath, { recursive: true, force: true });
    console.log('Directory removed');
  } catch (err) {
    console.error('Error removing directory:', err);
    throw err;
  }
}

// Walk directory tree
async function walkDirectory(dirPath, callback) {
  const entries = await fs.readdir(dirPath, { withFileTypes: true });

  for (const entry of entries) {
    const fullPath = path.join(dirPath, entry.name);

    if (entry.isFile()) {
      await callback(fullPath, 'file');
    } else if (entry.isDirectory()) {
      await callback(fullPath, 'directory');
      await walkDirectory(fullPath, callback);
    }
  }
}

// Usage
walkDirectory('./src', async (filepath, type) => {
  console.log(`${type}: ${filepath}`);
});
```

## Stream Processing

### Reading Large Files with Streams

```javascript
const fs = require('fs');
const readline = require('readline');

// Process large file line by line
async function processLargeFile(filename) {
  const fileStream = fs.createReadStream(filename);

  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });

  let lineNumber = 0;

  for await (const line of rl) {
    lineNumber++;
    console.log(`Line ${lineNumber}: ${line}`);
  }

  console.log(`Processed ${lineNumber} lines`);
}

// Stream copy
function copyFile(source, destination) {
  return new Promise((resolve, reject) => {
    const readStream = fs.createReadStream(source);
    const writeStream = fs.createWriteStream(destination);

    readStream.pipe(writeStream);

    writeStream.on('finish', resolve);
    writeStream.on('error', reject);
    readStream.on('error', reject);
  });
}

// Usage
processLargeFile('large-log.txt');
copyFile('source.txt', 'destination.txt');
```

### Transform Streams

```javascript
const { Transform } = require('stream');
const fs = require('fs');

// Custom transform stream to uppercase text
class UpperCaseTransform extends Transform {
  _transform(chunk, encoding, callback) {
    this.push(chunk.toString().toUpperCase());
    callback();
  }
}

// Custom transform to filter lines
class LineFilterTransform extends Transform {
  constructor(pattern) {
    super();
    this.pattern = pattern;
    this.buffer = '';
  }

  _transform(chunk, encoding, callback) {
    this.buffer += chunk.toString();
    const lines = this.buffer.split('\n');
    this.buffer = lines.pop(); // Keep incomplete line in buffer

    for (const line of lines) {
      if (line.includes(this.pattern)) {
        this.push(line + '\n');
      }
    }

    callback();
  }

  _flush(callback) {
    if (this.buffer && this.buffer.includes(this.pattern)) {
      this.push(this.buffer + '\n');
    }
    callback();
  }
}

// Usage: Convert file to uppercase
fs.createReadStream('input.txt')
  .pipe(new UpperCaseTransform())
  .pipe(fs.createWriteStream('output.txt'));

// Usage: Filter log lines containing 'ERROR'
fs.createReadStream('app.log')
  .pipe(new LineFilterTransform('ERROR'))
  .pipe(fs.createWriteStream('errors.log'));
```

### CSV Processing with Streams

```javascript
const fs = require('fs');
const { Transform } = require('stream');
const readline = require('readline');

class CSVParser extends Transform {
  constructor() {
    super({ objectMode: true });
    this.headers = null;
  }

  _transform(line, encoding, callback) {
    const values = line.split(',').map(v => v.trim());

    if (!this.headers) {
      this.headers = values;
    } else {
      const obj = {};
      this.headers.forEach((header, index) => {
        obj[header] = values[index];
      });
      this.push(obj);
    }

    callback();
  }
}

async function processCSV(filename) {
  const fileStream = fs.createReadStream(filename);
  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });

  const parser = new CSVParser();

  parser.on('data', (obj) => {
    console.log('Row:', obj);
  });

  for await (const line of rl) {
    parser.write(line);
  }

  parser.end();
}

processCSV('data.csv');
```

## Async Patterns

### Promise.all vs Promise.allSettled

```javascript
// Promise.all - fails fast on first error
async function fetchAllData() {
  try {
    const [users, posts, comments] = await Promise.all([
      fetchUsers(),
      fetchPosts(),
      fetchComments()
    ]);

    return { users, posts, comments };
  } catch (err) {
    console.error('One of the requests failed:', err);
    throw err;
  }
}

// Promise.allSettled - waits for all, reports all results
async function fetchAllDataRobust() {
  const results = await Promise.allSettled([
    fetchUsers(),
    fetchPosts(),
    fetchComments()
  ]);

  const data = {};
  const errors = {};

  results.forEach((result, index) => {
    const names = ['users', 'posts', 'comments'];
    const name = names[index];

    if (result.status === 'fulfilled') {
      data[name] = result.value;
    } else {
      errors[name] = result.reason;
      console.error(`Failed to fetch ${name}:`, result.reason);
    }
  });

  return { data, errors };
}
```

### Retry Pattern

```javascript
async function retry(fn, maxAttempts = 3, delay = 1000) {
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (err) {
      if (attempt === maxAttempts) {
        throw err;
      }

      console.log(`Attempt ${attempt} failed, retrying in ${delay}ms...`);
      await new Promise(resolve => setTimeout(resolve, delay));

      // Exponential backoff
      delay *= 2;
    }
  }
}

// Usage
async function fetchWithRetry() {
  return retry(
    () => fetch('https://api.example.com/data'),
    3,
    1000
  );
}
```

### Rate Limiting / Throttling

```javascript
class RateLimiter {
  constructor(maxRequests, windowMs) {
    this.maxRequests = maxRequests;
    this.windowMs = windowMs;
    this.requests = [];
  }

  async waitIfNeeded() {
    const now = Date.now();

    // Remove old requests outside the window
    this.requests = this.requests.filter(time => now - time < this.windowMs);

    if (this.requests.length >= this.maxRequests) {
      const oldestRequest = this.requests[0];
      const waitTime = this.windowMs - (now - oldestRequest);

      if (waitTime > 0) {
        console.log(`Rate limit reached, waiting ${waitTime}ms...`);
        await new Promise(resolve => setTimeout(resolve, waitTime));
      }
    }

    this.requests.push(Date.now());
  }

  async execute(fn) {
    await this.waitIfNeeded();
    return fn();
  }
}

// Usage: 5 requests per second
const limiter = new RateLimiter(5, 1000);

async function makeRequests() {
  const urls = Array(20).fill('https://api.example.com/data');

  for (const url of urls) {
    await limiter.execute(() => fetch(url));
  }
}
```

### Parallel Processing with Concurrency Limit

```javascript
async function parallelLimit(tasks, limit) {
  const results = [];
  const executing = [];

  for (const [index, task] of tasks.entries()) {
    const promise = Promise.resolve().then(() => task()).then(
      result => {
        results[index] = { status: 'fulfilled', value: result };
      },
      error => {
        results[index] = { status: 'rejected', reason: error };
      }
    );

    results.push(null);
    executing.push(promise);

    if (executing.length >= limit) {
      await Promise.race(executing);
      executing.splice(executing.findIndex(p => p === promise), 1);
    }
  }

  await Promise.all(executing);
  return results;
}

// Usage: Process 100 items with max 5 concurrent operations
const tasks = Array(100).fill(0).map((_, i) =>
  () => processItem(i)
);

parallelLimit(tasks, 5);
```

## CLI Tools

### Basic CLI Tool

```javascript
#!/usr/bin/env node

const args = process.argv.slice(2);

if (args.length === 0) {
  console.log('Usage: mycli <command> [options]');
  console.log('Commands:');
  console.log('  hello [name]   - Say hello');
  console.log('  version        - Show version');
  process.exit(0);
}

const command = args[0];

switch (command) {
  case 'hello':
    const name = args[1] || 'World';
    console.log(`Hello, ${name}!`);
    break;

  case 'version':
    const pkg = require('./package.json');
    console.log(`Version: ${pkg.version}`);
    break;

  default:
    console.error(`Unknown command: ${command}`);
    process.exit(1);
}
```

### CLI with Commander.js

```javascript
#!/usr/bin/env node

const { program } = require('commander');
const pkg = require('./package.json');

program
  .name('mycli')
  .description('My awesome CLI tool')
  .version(pkg.version);

program
  .command('init')
  .description('Initialize a new project')
  .option('-t, --template <type>', 'template type', 'default')
  .action((options) => {
    console.log(`Initializing project with template: ${options.template}`);
  });

program
  .command('build')
  .description('Build the project')
  .option('-w, --watch', 'watch for changes')
  .option('-o, --output <dir>', 'output directory', 'dist')
  .action((options) => {
    console.log(`Building project...`);
    console.log(`Output directory: ${options.output}`);
    if (options.watch) {
      console.log('Watching for changes...');
    }
  });

program
  .command('deploy')
  .description('Deploy the project')
  .argument('<environment>', 'deployment environment')
  .option('--dry-run', 'perform a dry run')
  .action((environment, options) => {
    if (options.dryRun) {
      console.log(`[DRY RUN] Would deploy to ${environment}`);
    } else {
      console.log(`Deploying to ${environment}...`);
    }
  });

program.parse();
```

### Interactive CLI with Inquirer

```javascript
const inquirer = require('inquirer');
const fs = require('fs').promises;

async function createProject() {
  const answers = await inquirer.prompt([
    {
      type: 'input',
      name: 'name',
      message: 'Project name:',
      default: 'my-project'
    },
    {
      type: 'list',
      name: 'template',
      message: 'Choose a template:',
      choices: ['basic', 'express', 'react', 'vue']
    },
    {
      type: 'checkbox',
      name: 'features',
      message: 'Select features:',
      choices: [
        { name: 'TypeScript', value: 'typescript' },
        { name: 'ESLint', value: 'eslint' },
        { name: 'Prettier', value: 'prettier' },
        { name: 'Testing (Jest)', value: 'jest' }
      ]
    },
    {
      type: 'confirm',
      name: 'install',
      message: 'Install dependencies now?',
      default: true
    }
  ]);

  console.log('\nCreating project with configuration:');
  console.log(JSON.stringify(answers, null, 2));

  // Create project directory
  await fs.mkdir(answers.name);
  console.log(`Created directory: ${answers.name}`);

  // Create package.json
  const packageJson = {
    name: answers.name,
    version: '1.0.0',
    template: answers.template,
    features: answers.features
  };

  await fs.writeFile(
    `${answers.name}/package.json`,
    JSON.stringify(packageJson, null, 2)
  );

  console.log('Project created successfully!');
}

createProject();
```

## Environment Variables

### Using dotenv

```javascript
// .env file
// PORT=3000
// NODE_ENV=development
// DATABASE_URL=mongodb://localhost/myapp
// JWT_SECRET=your-secret-key
// API_KEY=abc123

// Load environment variables
require('dotenv').config();

const config = {
  port: process.env.PORT || 3000,
  env: process.env.NODE_ENV || 'development',
  database: {
    url: process.env.DATABASE_URL
  },
  jwt: {
    secret: process.env.JWT_SECRET
  },
  api: {
    key: process.env.API_KEY
  }
};

// Validate required environment variables
const requiredEnvVars = ['DATABASE_URL', 'JWT_SECRET'];

for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    console.error(`Missing required environment variable: ${envVar}`);
    process.exit(1);
  }
}

module.exports = config;
```

### Environment-specific Configuration

```javascript
// config/index.js
const development = {
  port: 3000,
  database: {
    host: 'localhost',
    port: 27017,
    name: 'myapp_dev'
  },
  logging: {
    level: 'debug'
  }
};

const production = {
  port: process.env.PORT,
  database: {
    url: process.env.DATABASE_URL
  },
  logging: {
    level: 'error'
  }
};

const test = {
  port: 3001,
  database: {
    host: 'localhost',
    port: 27017,
    name: 'myapp_test'
  },
  logging: {
    level: 'silent'
  }
};

const configs = {
  development,
  production,
  test
};

const env = process.env.NODE_ENV || 'development';

module.exports = configs[env];
```

## Error Handling

### Custom Error Classes

```javascript
// errors/AppError.js
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

class NotFoundError extends AppError {
  constructor(resource = 'Resource') {
    super(`${resource} not found`, 404);
  }
}

class ValidationError extends AppError {
  constructor(message = 'Validation failed') {
    super(message, 400);
  }
}

class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super(message, 401);
  }
}

class ForbiddenError extends AppError {
  constructor(message = 'Forbidden') {
    super(message, 403);
  }
}

module.exports = {
  AppError,
  NotFoundError,
  ValidationError,
  UnauthorizedError,
  ForbiddenError
};
```

### Error Handler Middleware

```javascript
const { AppError } = require('./errors/AppError');

// Async wrapper to catch errors in async route handlers
const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

// Error logging
function logError(err) {
  console.error({
    message: err.message,
    stack: err.stack,
    statusCode: err.statusCode,
    timestamp: new Date().toISOString()
  });
}

// Error handler middleware
function errorHandler(err, req, res, next) {
  logError(err);

  // Operational errors (expected)
  if (err.isOperational) {
    return res.status(err.statusCode).json({
      error: err.message
    });
  }

  // Programming errors or unknown errors
  res.status(500).json({
    error: process.env.NODE_ENV === 'production'
      ? 'Internal server error'
      : err.message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
}

// Usage in Express app
app.get('/api/users/:id', asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);

  if (!user) {
    throw new NotFoundError('User');
  }

  res.json(user);
}));

app.use(errorHandler);
```

## Database Integration

### MongoDB with Mongoose

```javascript
const mongoose = require('mongoose');

// Connect to MongoDB
async function connectDB() {
  try {
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });
    console.log('MongoDB connected');
  } catch (err) {
    console.error('MongoDB connection error:', err);
    process.exit(1);
  }
}

// Define schema
const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Name is required'],
    trim: true,
    minlength: 2,
    maxlength: 50
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email']
  },
  age: {
    type: Number,
    min: 0,
    max: 120
  },
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Add indexes
userSchema.index({ email: 1 });

// Add virtual property
userSchema.virtual('isAdult').get(function() {
  return this.age >= 18;
});

// Add instance method
userSchema.methods.getPublicProfile = function() {
  return {
    id: this._id,
    name: this.name,
    email: this.email
  };
};

// Add static method
userSchema.statics.findByEmail = function(email) {
  return this.findOne({ email });
};

const User = mongoose.model('User', userSchema);

// CRUD operations
async function createUser(userData) {
  const user = new User(userData);
  await user.save();
  return user;
}

async function getAllUsers() {
  return await User.find().select('-__v');
}

async function getUserById(id) {
  return await User.findById(id);
}

async function updateUser(id, updates) {
  return await User.findByIdAndUpdate(
    id,
    updates,
    { new: true, runValidators: true }
  );
}

async function deleteUser(id) {
  return await User.findByIdAndDelete(id);
}

// Complex queries
async function searchUsers(query) {
  const { name, minAge, maxAge, role, sort = 'createdAt' } = query;

  const filter = {};

  if (name) {
    filter.name = { $regex: name, $options: 'i' };
  }

  if (minAge || maxAge) {
    filter.age = {};
    if (minAge) filter.age.$gte = minAge;
    if (maxAge) filter.age.$lte = maxAge;
  }

  if (role) {
    filter.role = role;
  }

  return await User.find(filter).sort(sort);
}

module.exports = {
  connectDB,
  User,
  createUser,
  getAllUsers,
  getUserById,
  updateUser,
  deleteUser,
  searchUsers
};
```

### PostgreSQL with pg

```javascript
const { Pool } = require('pg');

// Create connection pool
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT || 5432,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000
});

// Test connection
pool.on('connect', () => {
  console.log('Connected to PostgreSQL');
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
  process.exit(-1);
});

// CRUD operations
async function createUser(name, email, age) {
  const query = {
    text: 'INSERT INTO users(name, email, age) VALUES($1, $2, $3) RETURNING *',
    values: [name, email, age]
  };

  const result = await pool.query(query);
  return result.rows[0];
}

async function getAllUsers() {
  const result = await pool.query('SELECT * FROM users ORDER BY created_at DESC');
  return result.rows;
}

async function getUserById(id) {
  const query = {
    text: 'SELECT * FROM users WHERE id = $1',
    values: [id]
  };

  const result = await pool.query(query);
  return result.rows[0];
}

async function updateUser(id, updates) {
  const { name, email, age } = updates;

  const query = {
    text: 'UPDATE users SET name = $1, email = $2, age = $3 WHERE id = $4 RETURNING *',
    values: [name, email, age, id]
  };

  const result = await pool.query(query);
  return result.rows[0];
}

async function deleteUser(id) {
  const query = {
    text: 'DELETE FROM users WHERE id = $1',
    values: [id]
  };

  await pool.query(query);
}

// Transaction example
async function transferMoney(fromAccountId, toAccountId, amount) {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    // Deduct from source account
    await client.query(
      'UPDATE accounts SET balance = balance - $1 WHERE id = $2',
      [amount, fromAccountId]
    );

    // Add to destination account
    await client.query(
      'UPDATE accounts SET balance = balance + $1 WHERE id = $2',
      [amount, toAccountId]
    );

    await client.query('COMMIT');
    console.log('Transfer successful');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Transfer failed:', err);
    throw err;
  } finally {
    client.release();
  }
}

module.exports = {
  pool,
  createUser,
  getAllUsers,
  getUserById,
  updateUser,
  deleteUser,
  transferMoney
};
```

## Authentication & Authorization

### JWT Authentication

```javascript
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = '7d';

// Hash password
async function hashPassword(password) {
  const saltRounds = 10;
  return await bcrypt.hash(password, saltRounds);
}

// Verify password
async function verifyPassword(password, hash) {
  return await bcrypt.compare(password, hash);
}

// Generate access token
function generateAccessToken(user) {
  return jwt.sign(
    {
      id: user.id,
      email: user.email,
      role: user.role
    },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );
}

// Generate refresh token
function generateRefreshToken(user) {
  return jwt.sign(
    { id: user.id },
    JWT_SECRET,
    { expiresIn: '30d' }
  );
}

// Verify token
function verifyToken(token) {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (err) {
    return null;
  }
}

// Authentication middleware
function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'No token provided' });
  }

  const token = authHeader.split(' ')[1];
  const decoded = verifyToken(token);

  if (!decoded) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }

  req.user = decoded;
  next();
}

// Role-based authorization middleware
function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    next();
  };
}

// Register route
app.post('/api/auth/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Check if user exists
    const existing = await User.findOne({ email });
    if (existing) {
      return res.status(400).json({ error: 'Email already registered' });
    }

    // Hash password
    const hashedPassword = await hashPassword(password);

    // Create user
    const user = await User.create({
      name,
      email,
      password: hashedPassword
    });

    // Generate tokens
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    res.status(201).json({
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      },
      accessToken,
      refreshToken
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Login route
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Verify password
    const isValid = await verifyPassword(password, user.password);
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Generate tokens
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    res.json({
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role
      },
      accessToken,
      refreshToken
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Protected route
app.get('/api/profile', authMiddleware, (req, res) => {
  res.json({ user: req.user });
});

// Admin-only route
app.get('/api/admin/users', authMiddleware, requireRole('admin'), async (req, res) => {
  const users = await User.find();
  res.json(users);
});

module.exports = {
  hashPassword,
  verifyPassword,
  generateAccessToken,
  generateRefreshToken,
  verifyToken,
  authMiddleware,
  requireRole
};
```

## Middleware Patterns

### Logging Middleware

```javascript
// Request logging
function requestLogger(req, res, next) {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log({
      method: req.method,
      url: req.url,
      status: res.statusCode,
      duration: `${duration}ms`,
      timestamp: new Date().toISOString()
    });
  });

  next();
}

app.use(requestLogger);
```

### Validation Middleware

```javascript
const { body, validationResult } = require('express-validator');

// Validation rules
const userValidationRules = [
  body('name')
    .trim()
    .notEmpty().withMessage('Name is required')
    .isLength({ min: 2, max: 50 }).withMessage('Name must be 2-50 characters'),

  body('email')
    .trim()
    .notEmpty().withMessage('Email is required')
    .isEmail().withMessage('Must be a valid email')
    .normalizeEmail(),

  body('password')
    .notEmpty().withMessage('Password is required')
    .isLength({ min: 8 }).withMessage('Password must be at least 8 characters')
    .matches(/\d/).withMessage('Password must contain a number')
    .matches(/[a-z]/).withMessage('Password must contain a lowercase letter')
    .matches(/[A-Z]/).withMessage('Password must contain an uppercase letter'),

  body('age')
    .optional()
    .isInt({ min: 0, max: 120 }).withMessage('Age must be between 0 and 120')
];

// Validation middleware
function validate(req, res, next) {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  next();
}

// Usage
app.post('/api/users', userValidationRules, validate, async (req, res) => {
  const user = await createUser(req.body);
  res.status(201).json(user);
});
```

### CORS Middleware

```javascript
const cors = require('cors');

// Basic CORS
app.use(cors());

// Custom CORS
const corsOptions = {
  origin: function (origin, callback) {
    const allowedOrigins = [
      'https://example.com',
      'https://app.example.com'
    ];

    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
};

app.use(cors(corsOptions));
```

## Testing Examples

### Unit Tests with Jest

```javascript
// sum.js
function sum(a, b) {
  return a + b;
}

module.exports = { sum };

// sum.test.js
const { sum } = require('./sum');

describe('sum function', () => {
  test('adds 1 + 2 to equal 3', () => {
    expect(sum(1, 2)).toBe(3);
  });

  test('adds positive numbers', () => {
    expect(sum(10, 20)).toBe(30);
  });

  test('adds negative numbers', () => {
    expect(sum(-5, -10)).toBe(-15);
  });

  test('adds mixed numbers', () => {
    expect(sum(-5, 10)).toBe(5);
  });
});
```

### API Integration Tests

```javascript
const request = require('supertest');
const app = require('./app');
const { connectDB, User } = require('./db');

beforeAll(async () => {
  await connectDB();
});

afterAll(async () => {
  await mongoose.connection.close();
});

beforeEach(async () => {
  await User.deleteMany({});
});

describe('User API', () => {
  describe('POST /api/users', () => {
    it('should create a new user', async () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'Password123'
      };

      const response = await request(app)
        .post('/api/users')
        .send(userData)
        .expect(201)
        .expect('Content-Type', /json/);

      expect(response.body).toHaveProperty('id');
      expect(response.body.name).toBe(userData.name);
      expect(response.body.email).toBe(userData.email);
      expect(response.body).not.toHaveProperty('password');
    });

    it('should return 400 for invalid data', async () => {
      const response = await request(app)
        .post('/api/users')
        .send({ name: 'John' })
        .expect(400);

      expect(response.body).toHaveProperty('errors');
    });
  });

  describe('GET /api/users/:id', () => {
    it('should return user by id', async () => {
      const user = await User.create({
        name: 'John Doe',
        email: 'john@example.com',
        password: 'hashed'
      });

      const response = await request(app)
        .get(`/api/users/${user.id}`)
        .expect(200);

      expect(response.body.name).toBe(user.name);
    });

    it('should return 404 for non-existent user', async () => {
      const response = await request(app)
        .get('/api/users/507f1f77bcf86cd799439011')
        .expect(404);
    });
  });
});
```

### Mocking in Tests

```javascript
// userService.js
const axios = require('axios');

async function getUserFromAPI(id) {
  const response = await axios.get(`https://api.example.com/users/${id}`);
  return response.data;
}

module.exports = { getUserFromAPI };

// userService.test.js
jest.mock('axios');
const axios = require('axios');
const { getUserFromAPI } = require('./userService');

describe('getUserFromAPI', () => {
  it('should fetch user data', async () => {
    const mockUser = { id: 1, name: 'John' };

    axios.get.mockResolvedValue({ data: mockUser });

    const user = await getUserFromAPI(1);

    expect(user).toEqual(mockUser);
    expect(axios.get).toHaveBeenCalledWith('https://api.example.com/users/1');
  });

  it('should handle errors', async () => {
    axios.get.mockRejectedValue(new Error('Network error'));

    await expect(getUserFromAPI(1)).rejects.toThrow('Network error');
  });
});
```

## WebSocket Real-time

### WebSocket Server

```javascript
const WebSocket = require('ws');
const http = require('http');
const express = require('express');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// Store connected clients
const clients = new Set();

wss.on('connection', (ws, req) => {
  console.log('New client connected');
  clients.add(ws);

  // Send welcome message
  ws.send(JSON.stringify({
    type: 'welcome',
    message: 'Connected to WebSocket server',
    clientCount: clients.size
  }));

  // Broadcast client count to all
  broadcast({
    type: 'clientCount',
    count: clients.size
  });

  // Handle messages
  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data);
      console.log('Received:', message);

      // Echo message to all clients
      broadcast({
        type: 'message',
        data: message,
        timestamp: Date.now()
      });
    } catch (err) {
      console.error('Invalid message:', err);
    }
  });

  // Handle disconnect
  ws.on('close', () => {
    console.log('Client disconnected');
    clients.delete(ws);

    broadcast({
      type: 'clientCount',
      count: clients.size
    });
  });

  // Handle errors
  ws.on('error', (err) => {
    console.error('WebSocket error:', err);
  });
});

// Broadcast to all connected clients
function broadcast(data) {
  const message = JSON.stringify(data);

  clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(message);
    }
  });
}

// Heartbeat to keep connections alive
setInterval(() => {
  clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.ping();
    }
  });
}, 30000);

server.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

### Chat Application

```javascript
const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8080 });

const rooms = new Map();

class ChatRoom {
  constructor(name) {
    this.name = name;
    this.clients = new Map();
  }

  addClient(ws, username) {
    this.clients.set(ws, username);
    this.broadcast({
      type: 'userJoined',
      username,
      userCount: this.clients.size
    });
  }

  removeClient(ws) {
    const username = this.clients.get(ws);
    this.clients.delete(ws);

    if (username) {
      this.broadcast({
        type: 'userLeft',
        username,
        userCount: this.clients.size
      });
    }
  }

  broadcast(data, exclude = null) {
    const message = JSON.stringify(data);

    this.clients.forEach((username, client) => {
      if (client !== exclude && client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    });
  }

  sendMessage(ws, username, text) {
    this.broadcast({
      type: 'message',
      username,
      text,
      timestamp: Date.now()
    });
  }
}

wss.on('connection', (ws) => {
  let currentRoom = null;
  let username = null;

  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data);

      switch (message.type) {
        case 'join':
          username = message.username;
          currentRoom = message.room;

          if (!rooms.has(currentRoom)) {
            rooms.set(currentRoom, new ChatRoom(currentRoom));
          }

          const room = rooms.get(currentRoom);
          room.addClient(ws, username);

          ws.send(JSON.stringify({
            type: 'joined',
            room: currentRoom,
            users: Array.from(room.clients.values())
          }));
          break;

        case 'message':
          if (currentRoom && username) {
            rooms.get(currentRoom).sendMessage(ws, username, message.text);
          }
          break;
      }
    } catch (err) {
      console.error('Error:', err);
    }
  });

  ws.on('close', () => {
    if (currentRoom && rooms.has(currentRoom)) {
      const room = rooms.get(currentRoom);
      room.removeClient(ws);

      if (room.clients.size === 0) {
        rooms.delete(currentRoom);
      }
    }
  });
});
```

## Child Processes

### Executing Commands

```javascript
const { exec, execFile, spawn } = require('child_process');
const util = require('util');

const execPromise = util.promisify(exec);

// exec - run shell command
async function runShellCommand(command) {
  try {
    const { stdout, stderr } = await execPromise(command);
    console.log('Output:', stdout);
    if (stderr) console.error('Errors:', stderr);
    return stdout;
  } catch (err) {
    console.error('Command failed:', err);
    throw err;
  }
}

// execFile - run executable directly (safer)
async function runExecutable(file, args) {
  return new Promise((resolve, reject) => {
    execFile(file, args, (err, stdout, stderr) => {
      if (err) {
        reject(err);
        return;
      }
      resolve({ stdout, stderr });
    });
  });
}

// spawn - for long-running processes or large output
function runLongProcess(command, args) {
  const child = spawn(command, args);

  child.stdout.on('data', (data) => {
    console.log(`stdout: ${data}`);
  });

  child.stderr.on('data', (data) => {
    console.error(`stderr: ${data}`);
  });

  child.on('close', (code) => {
    console.log(`Process exited with code ${code}`);
  });

  child.on('error', (err) => {
    console.error('Failed to start process:', err);
  });

  return child;
}

// Usage examples
runShellCommand('ls -la');
runExecutable('node', ['--version']);
runLongProcess('npm', ['install']);
```

### Worker Processes

```javascript
// parent.js
const { fork } = require('child_process');

const child = fork('./worker.js');

child.on('message', (msg) => {
  console.log('Message from child:', msg);
});

child.send({ task: 'compute', data: [1, 2, 3, 4, 5] });

child.on('exit', (code) => {
  console.log(`Child exited with code ${code}`);
});

// worker.js
process.on('message', (msg) => {
  console.log('Message from parent:', msg);

  if (msg.task === 'compute') {
    const result = msg.data.reduce((sum, num) => sum + num, 0);
    process.send({ result });
    process.exit(0);
  }
});
```

## Cluster Mode

### Using Node.js Cluster

```javascript
const cluster = require('cluster');
const http = require('http');
const numCPUs = require('os').cpus().length;

if (cluster.isMaster) {
  console.log(`Master ${process.pid} is running`);

  // Fork workers
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }

  // Listen for dying workers
  cluster.on('exit', (worker, code, signal) => {
    console.log(`Worker ${worker.process.pid} died`);
    console.log('Starting a new worker');
    cluster.fork();
  });

  // Listen for online workers
  cluster.on('online', (worker) => {
    console.log(`Worker ${worker.process.pid} is online`);
  });

} else {
  // Workers can share any TCP connection
  const server = http.createServer((req, res) => {
    res.writeHead(200);
    res.end(`Process ${process.pid} handled request\n`);
  });

  server.listen(8000);
  console.log(`Worker ${process.pid} started`);
}
```

## Email Sending

### Using Nodemailer

```javascript
const nodemailer = require('nodemailer');

// Create transporter
const transporter = nodemailer.createTransporter({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  secure: true,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASSWORD
  }
});

// Send email
async function sendEmail(to, subject, html) {
  try {
    const info = await transporter.sendMail({
      from: '"My App" <noreply@myapp.com>',
      to,
      subject,
      html
    });

    console.log('Message sent:', info.messageId);
    return info;
  } catch (err) {
    console.error('Error sending email:', err);
    throw err;
  }
}

// Send welcome email
async function sendWelcomeEmail(user) {
  const html = `
    <h1>Welcome ${user.name}!</h1>
    <p>Thanks for signing up.</p>
  `;

  await sendEmail(user.email, 'Welcome to My App', html);
}

// Send password reset email
async function sendPasswordResetEmail(user, resetToken) {
  const resetUrl = `https://myapp.com/reset-password?token=${resetToken}`;

  const html = `
    <h1>Password Reset</h1>
    <p>Click the link below to reset your password:</p>
    <a href="${resetUrl}">Reset Password</a>
    <p>This link expires in 1 hour.</p>
  `;

  await sendEmail(user.email, 'Password Reset Request', html);
}

module.exports = {
  sendEmail,
  sendWelcomeEmail,
  sendPasswordResetEmail
};
```

## File Upload

### Multer File Upload

```javascript
const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;

const app = express();

// Configure storage
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const uploadDir = './uploads';
    await fs.mkdir(uploadDir, { recursive: true });
    cb(null, uploadDir);
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
    cb(new Error('Only images and PDFs are allowed'));
  }
};

const upload = multer({
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB
  },
  fileFilter
});

// Single file upload
app.post('/api/upload', upload.single('file'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }

  res.json({
    message: 'File uploaded successfully',
    filename: req.file.filename,
    size: req.file.size,
    path: req.file.path
  });
});

// Multiple files upload
app.post('/api/upload-multiple', upload.array('files', 5), (req, res) => {
  if (!req.files || req.files.length === 0) {
    return res.status(400).json({ error: 'No files uploaded' });
  }

  const files = req.files.map(file => ({
    filename: file.filename,
    size: file.size,
    path: file.path
  }));

  res.json({
    message: 'Files uploaded successfully',
    files
  });
});

// Error handling
app.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ error: 'File too large' });
    }
    if (err.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({ error: 'Too many files' });
    }
  }

  res.status(500).json({ error: err.message });
});

app.listen(3000);
```

## Caching Strategies

### In-Memory Cache with node-cache

```javascript
const NodeCache = require('node-cache');
const cache = new NodeCache({
  stdTTL: 600, // 10 minutes default
  checkperiod: 120 // Check for expired keys every 2 minutes
});

// Cache wrapper for async functions
function cacheWrapper(key, ttl) {
  return function(target, propertyName, descriptor) {
    const originalMethod = descriptor.value;

    descriptor.value = async function(...args) {
      const cacheKey = `${key}:${JSON.stringify(args)}`;

      // Try to get from cache
      const cached = cache.get(cacheKey);
      if (cached !== undefined) {
        console.log('Cache hit:', cacheKey);
        return cached;
      }

      // Execute original method
      console.log('Cache miss:', cacheKey);
      const result = await originalMethod.apply(this, args);

      // Store in cache
      cache.set(cacheKey, result, ttl);

      return result;
    };

    return descriptor;
  };
}

// Manual caching
async function getUserData(userId) {
  const cacheKey = `user:${userId}`;

  // Check cache
  const cached = cache.get(cacheKey);
  if (cached) {
    return cached;
  }

  // Fetch from database
  const user = await User.findById(userId);

  // Store in cache for 5 minutes
  cache.set(cacheKey, user, 300);

  return user;
}

// Invalidate cache
function invalidateUserCache(userId) {
  cache.del(`user:${userId}`);
}

// Clear all cache
function clearCache() {
  cache.flushAll();
}

module.exports = {
  cache,
  getUserData,
  invalidateUserCache,
  clearCache
};
```

## Rate Limiting

### Express Rate Limit

```javascript
const rateLimit = require('express-rate-limit');

// Basic rate limit
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests, please try again later',
  standardHeaders: true,
  legacyHeaders: false
});

// Apply to all requests
app.use('/api/', limiter);

// Strict rate limit for authentication
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  skipSuccessfulRequests: true,
  message: 'Too many login attempts, please try again later'
});

app.post('/api/auth/login', authLimiter, loginHandler);

// Custom key generator (by user ID instead of IP)
const userLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 10,
  keyGenerator: (req) => {
    return req.user?.id || req.ip;
  }
});

app.use('/api/user/', authMiddleware, userLimiter);
```

## Deployment & Production

### PM2 Ecosystem File

```javascript
// ecosystem.config.js
module.exports = {
  apps: [{
    name: 'my-app',
    script: './index.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'development',
      PORT: 3000
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 8080
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    max_restarts: 10,
    min_uptime: '10s'
  }]
};
```

### Graceful Shutdown

```javascript
const express = require('express');
const app = express();

const server = app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

function gracefulShutdown() {
  console.log('Received shutdown signal, closing server gracefully...');

  server.close(async () => {
    console.log('HTTP server closed');

    try {
      // Close database connections
      await mongoose.connection.close();
      console.log('Database connection closed');

      // Close other connections (Redis, etc.)
      await redisClient.quit();
      console.log('Redis connection closed');

      console.log('Graceful shutdown complete');
      process.exit(0);
    } catch (err) {
      console.error('Error during shutdown:', err);
      process.exit(1);
    }
  });

  // Force shutdown after 30 seconds
  setTimeout(() => {
    console.error('Forced shutdown after timeout');
    process.exit(1);
  }, 30000);
}
```

### Health Check Endpoint

```javascript
app.get('/health', async (req, res) => {
  const health = {
    uptime: process.uptime(),
    timestamp: Date.now(),
    status: 'ok'
  };

  try {
    // Check database connection
    await mongoose.connection.db.admin().ping();
    health.database = 'connected';
  } catch (err) {
    health.database = 'disconnected';
    health.status = 'error';
  }

  const statusCode = health.status === 'ok' ? 200 : 503;
  res.status(statusCode).json(health);
});
```

This comprehensive examples file covers all major Node.js development patterns and use cases, providing production-ready code that developers can adapt for their projects.
