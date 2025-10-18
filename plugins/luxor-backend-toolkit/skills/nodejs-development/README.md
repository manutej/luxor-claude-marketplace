# Node.js Development Skill

A comprehensive skill for building modern Node.js applications covering backend APIs, CLI tools, microservices, and real-time applications.

## Overview

Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine that enables server-side JavaScript execution. It uses an event-driven, non-blocking I/O model that makes it lightweight and efficient for building scalable network applications.

This skill provides comprehensive guidance on:

- Event-driven architecture and the event loop
- Asynchronous programming patterns (callbacks, promises, async/await)
- Stream processing for efficient data handling
- File system operations and path management
- HTTP/HTTPS server creation and request handling
- Process management and environment configuration
- Security best practices and error handling
- Performance optimization and testing strategies

## Why Node.js?

Node.js excels at:

1. **I/O-Intensive Applications**: Non-blocking I/O makes it perfect for applications with many concurrent connections
2. **Real-time Applications**: WebSockets and Server-Sent Events enable real-time bidirectional communication
3. **API Development**: Fast, lightweight, and perfect for RESTful APIs and GraphQL servers
4. **Microservices**: Small footprint and quick startup time ideal for microservice architecture
5. **Developer Productivity**: JavaScript everywhere (frontend and backend) reduces context switching
6. **Rich Ecosystem**: npm provides access to over 1 million packages
7. **Streaming Data**: Built-in stream support for handling large files and data processing

## Getting Started

### Installation

#### Using Official Installer

1. Visit [nodejs.org](https://nodejs.org/)
2. Download the LTS (Long Term Support) version
3. Run the installer for your platform

#### Using Node Version Manager (Recommended)

**macOS/Linux (nvm):**

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Install Node.js LTS
nvm install --lts

# Use specific version
nvm use 18

# Set default version
nvm alias default 18
```

**Windows (nvm-windows):**

```bash
# Download installer from: https://github.com/coreybutler/nvm-windows/releases
# Then install Node.js
nvm install lts
nvm use lts
```

### Verify Installation

```bash
node --version
npm --version
```

### Your First Node.js Program

Create a file `hello.js`:

```javascript
console.log('Hello, Node.js!');
```

Run it:

```bash
node hello.js
```

### Creating a Project

```bash
# Create project directory
mkdir my-nodejs-app
cd my-nodejs-app

# Initialize package.json
npm init -y

# Install dependencies
npm install express

# Create main file
touch index.js
```

### Basic HTTP Server

```javascript
// index.js
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

Run the server:

```bash
node index.js
```

Visit `http://localhost:3000` in your browser.

### Express.js Hello World

```javascript
const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

## Core Concepts

### Event Loop

The event loop is what allows Node.js to perform non-blocking I/O operations despite JavaScript being single-threaded. It's the mechanism that handles asynchronous callbacks.

**Key Points:**
- JavaScript is single-threaded but uses asynchronous callbacks
- The event loop continuously checks for tasks to execute
- I/O operations are offloaded to the system kernel when possible
- Callbacks are executed when operations complete

### Non-Blocking I/O

Node.js uses non-blocking I/O calls, allowing it to support thousands of concurrent connections without the overhead of thread management.

```javascript
// Blocking (synchronous)
const data = fs.readFileSync('file.txt'); // Waits for file read
console.log(data);

// Non-blocking (asynchronous)
fs.readFile('file.txt', (err, data) => {
  if (err) throw err;
  console.log(data);
});
console.log('This executes immediately');
```

### Module System

Node.js uses modules to organize code into reusable components. It supports both CommonJS (traditional) and ES Modules (modern).

**CommonJS:**
```javascript
// Export
module.exports = { add, subtract };

// Import
const math = require('./math');
```

**ES Modules:**
```javascript
// Export
export { add, subtract };

// Import
import { add, subtract } from './math.js';
```

### NPM (Node Package Manager)

NPM is the world's largest software registry. It allows you to install, share, and manage dependencies.

```bash
# Install package
npm install express

# Install as dev dependency
npm install --save-dev jest

# Install globally
npm install -g nodemon

# Uninstall package
npm uninstall express

# Update packages
npm update

# List installed packages
npm list

# Check for outdated packages
npm outdated
```

## Common Use Cases

### 1. REST API Development

Build RESTful APIs with Express.js:

```javascript
const express = require('express');
const app = express();

app.use(express.json());

app.get('/api/users', (req, res) => {
  res.json({ users: [] });
});

app.post('/api/users', (req, res) => {
  const user = req.body;
  res.status(201).json(user);
});

app.listen(3000);
```

### 2. Real-time Applications

Use WebSockets for real-time communication:

```javascript
const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8080 });

wss.on('connection', (ws) => {
  ws.on('message', (message) => {
    // Broadcast to all clients
    wss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    });
  });
});
```

### 3. CLI Tools

Create command-line tools:

```javascript
#!/usr/bin/env node

const args = process.argv.slice(2);
const command = args[0];

switch (command) {
  case 'help':
    console.log('Available commands: help, version');
    break;
  case 'version':
    console.log('v1.0.0');
    break;
  default:
    console.log('Unknown command');
}
```

### 4. File Processing

Process files efficiently with streams:

```javascript
const fs = require('fs');

const readStream = fs.createReadStream('large-file.txt');
const writeStream = fs.createWriteStream('output.txt');

readStream.pipe(writeStream);

writeStream.on('finish', () => {
  console.log('File processing complete');
});
```

## Project Structure

A typical Node.js project structure:

```
my-app/
├── node_modules/          # Dependencies
├── src/                   # Source code
│   ├── controllers/       # Route handlers
│   ├── models/            # Data models
│   ├── routes/            # API routes
│   ├── middleware/        # Custom middleware
│   ├── utils/             # Utility functions
│   └── config/            # Configuration files
├── tests/                 # Test files
├── public/                # Static files
├── .env                   # Environment variables (not committed)
├── .gitignore             # Git ignore file
├── package.json           # Project metadata and dependencies
├── package-lock.json      # Locked dependency versions
└── index.js               # Entry point
```

## Environment Configuration

Use environment variables for configuration:

**.env file:**
```
PORT=3000
NODE_ENV=development
DATABASE_URL=mongodb://localhost/myapp
JWT_SECRET=your-secret-key
```

**Load with dotenv:**
```javascript
require('dotenv').config();

const port = process.env.PORT || 3000;
const dbUrl = process.env.DATABASE_URL;
```

## Development Tools

### Essential Tools

1. **nodemon** - Auto-restart on file changes
   ```bash
   npm install -g nodemon
   nodemon index.js
   ```

2. **ESLint** - Code linting
   ```bash
   npm install --save-dev eslint
   npx eslint --init
   ```

3. **Prettier** - Code formatting
   ```bash
   npm install --save-dev prettier
   npx prettier --write .
   ```

4. **Jest** - Testing framework
   ```bash
   npm install --save-dev jest
   npm test
   ```

### package.json Scripts

```json
{
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js",
    "test": "jest",
    "lint": "eslint .",
    "format": "prettier --write ."
  }
}
```

Run scripts:
```bash
npm start
npm run dev
npm test
```

## Best Practices

### 1. Error Handling

Always handle errors properly:

```javascript
// Async/await
try {
  const data = await fetchData();
} catch (err) {
  console.error('Error:', err);
}

// Promises
fetchData()
  .then(data => process(data))
  .catch(err => console.error('Error:', err));

// Process-level error handling
process.on('uncaughtException', (err) => {
  console.error('Uncaught exception:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled rejection:', reason);
  process.exit(1);
});
```

### 2. Security

- Never commit secrets or API keys
- Use environment variables for sensitive data
- Validate and sanitize user input
- Use HTTPS in production
- Keep dependencies updated
- Use security headers (helmet.js)
- Implement rate limiting
- Use parameterized queries to prevent SQL injection

### 3. Performance

- Use asynchronous methods instead of synchronous
- Implement caching strategies
- Use connection pooling for databases
- Enable compression
- Optimize database queries
- Use clustering for multi-core systems
- Monitor memory usage and performance

### 4. Code Organization

- Follow the single responsibility principle
- Use modules to organize code
- Keep functions small and focused
- Use meaningful variable and function names
- Add comments for complex logic
- Follow a consistent coding style

## Debugging

### Using Node.js Inspector

```bash
# Start with inspector
node --inspect index.js

# Debug from the start
node --inspect-brk index.js
```

Open `chrome://inspect` in Chrome to debug.

### Using VS Code

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Launch Program",
      "program": "${workspaceFolder}/index.js"
    }
  ]
}
```

Press F5 to start debugging.

### Console Debugging

```javascript
console.log('Variable:', variable);
console.error('Error:', error);
console.table(arrayOfObjects);
console.time('operation');
// ... code to measure
console.timeEnd('operation');
```

## Testing

### Unit Testing with Jest

```javascript
// math.js
function add(a, b) {
  return a + b;
}
module.exports = { add };

// math.test.js
const { add } = require('./math');

test('adds 1 + 2 to equal 3', () => {
  expect(add(1, 2)).toBe(3);
});
```

### Integration Testing

```javascript
const request = require('supertest');
const app = require('./app');

describe('GET /api/users', () => {
  it('responds with json', async () => {
    const response = await request(app)
      .get('/api/users')
      .expect('Content-Type', /json/)
      .expect(200);
  });
});
```

## Deployment

### Popular Platforms

1. **Heroku**
   ```bash
   heroku create
   git push heroku main
   ```

2. **Vercel**
   ```bash
   npm install -g vercel
   vercel
   ```

3. **AWS (Elastic Beanstalk, Lambda)**
4. **Google Cloud Platform**
5. **DigitalOcean**
6. **Railway**
7. **Render**

### Production Checklist

- [ ] Set NODE_ENV=production
- [ ] Use process manager (PM2)
- [ ] Enable logging
- [ ] Set up monitoring
- [ ] Configure error tracking (Sentry)
- [ ] Use HTTPS
- [ ] Set up CI/CD
- [ ] Configure auto-scaling
- [ ] Set up database backups
- [ ] Implement health checks

### Using PM2

```bash
# Install PM2
npm install -g pm2

# Start application
pm2 start index.js

# Start with name
pm2 start index.js --name "my-app"

# Start in cluster mode
pm2 start index.js -i max

# Monitor
pm2 monit

# List processes
pm2 list

# Restart
pm2 restart my-app

# Stop
pm2 stop my-app

# View logs
pm2 logs

# Save process list
pm2 save

# Auto-start on boot
pm2 startup
```

## Resources

### Official Documentation
- [Node.js Documentation](https://nodejs.org/docs/)
- [NPM Documentation](https://docs.npmjs.com/)

### Popular Frameworks
- [Express.js](https://expressjs.com/) - Fast, unopinionated web framework
- [Fastify](https://www.fastify.io/) - High-performance web framework
- [NestJS](https://nestjs.com/) - Progressive TypeScript framework
- [Koa](https://koajs.com/) - Lightweight web framework

### Learning Resources
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [The Node.js Event Loop](https://nodejs.org/en/docs/guides/event-loop-timers-and-nexttick/)
- [Stream Handbook](https://github.com/substack/stream-handbook)

### Community
- [Node.js Discord](https://discord.gg/nodejs)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/node.js)
- [Reddit r/node](https://www.reddit.com/r/node/)

## Next Steps

1. Explore the SKILL.md file for comprehensive API reference and patterns
2. Review EXAMPLES.md for detailed code examples
3. Build a real project (REST API, CLI tool, or real-time app)
4. Learn TypeScript for better type safety
5. Explore advanced topics (worker threads, cluster mode, streams)
6. Contribute to open-source Node.js projects

## License

This skill is provided as-is for educational and development purposes.
