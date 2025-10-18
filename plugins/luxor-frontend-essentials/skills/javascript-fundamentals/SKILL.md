---
name: javascript-fundamentals
description: Core JavaScript language features, patterns, and best practices including ES6+ syntax, async/await, closures, prototypes, and modern development patterns
category: frontend
tags: [javascript, es6, async, closures, prototypes, programming]
version: 1.0.0
---

# JavaScript Fundamentals

A comprehensive guide to core JavaScript concepts, modern ES6+ features, asynchronous programming patterns, and industry best practices for building robust applications.

## When to Use This Skill

This skill is essential when:

- **Writing JavaScript Code**: Building web applications, Node.js backends, or any JavaScript-based project
- **Code Reviews**: Evaluating code quality, identifying anti-patterns, suggesting improvements
- **Teaching/Mentoring**: Explaining JavaScript concepts, debugging issues, pair programming
- **Refactoring Legacy Code**: Modernizing codebases with ES6+ features and better patterns
- **Architecture Design**: Choosing appropriate patterns and structures for your application
- **Performance Optimization**: Understanding memory management, event loops, and efficient patterns
- **Debugging**: Tracing execution flow, understanding scope chains, and async behavior
- **Interview Preparation**: Mastering fundamental concepts tested in technical interviews

## Core Concepts

### Variables and Scope

JavaScript has three ways to declare variables, each with different scoping rules:

**var**: Function-scoped, hoisted, can be redeclared
```javascript
function varExample() {
  var x = 1;
  if (true) {
    var x = 2; // Same variable!
    console.log(x); // 2
  }
  console.log(x); // 2
}
```

**let**: Block-scoped, not hoisted to usable state, cannot be redeclared
```javascript
function letExample() {
  let x = 1;
  if (true) {
    let x = 2; // Different variable
    console.log(x); // 2
  }
  console.log(x); // 1
}
```

**const**: Block-scoped, must be initialized, reference cannot be reassigned
```javascript
const PI = 3.14159;
// PI = 3; // Error: Assignment to constant variable

const user = { name: 'John' };
user.name = 'Jane'; // OK - modifying object properties
// user = {}; // Error - reassigning reference
```

**Best Practice**: Use `const` by default, `let` when reassignment is needed, avoid `var`.

### Data Types

JavaScript has 7 primitive types and objects:

**Primitives**:
- `String`: Text data
- `Number`: Integers and floating-point numbers
- `BigInt`: Arbitrary precision integers
- `Boolean`: true/false
- `undefined`: Uninitialized variable
- `null`: Intentional absence of value
- `Symbol`: Unique identifiers

**Objects**: Collections of key-value pairs, including arrays, functions, dates, etc.

```javascript
// Type checking
typeof "hello"        // "string"
typeof 42             // "number"
typeof true           // "boolean"
typeof undefined      // "undefined"
typeof null           // "object" (historical bug!)
typeof {}             // "object"
typeof []             // "object"
typeof function(){}   // "function"

// Better array checking
Array.isArray([])     // true
Array.isArray({})     // false

// Null checking
value === null        // true only for null
value == null         // true for null AND undefined
```

### Functions

Functions are first-class citizens in JavaScript - they can be assigned to variables, passed as arguments, and returned from other functions.

**Function Declaration**:
```javascript
function greet(name) {
  return `Hello, ${name}!`;
}
```

**Function Expression**:
```javascript
const greet = function(name) {
  return `Hello, ${name}!`;
};
```

**Arrow Function** (ES6+):
```javascript
const greet = (name) => `Hello, ${name}!`;

// Multiple parameters
const add = (a, b) => a + b;

// Single parameter (parentheses optional)
const double = x => x * 2;

// Multiple statements (need braces and explicit return)
const complexFunction = (x, y) => {
  const result = x + y;
  return result * 2;
};
```

**Key Differences**:
- Arrow functions don't have their own `this` binding
- Arrow functions cannot be used as constructors
- Arrow functions don't have `arguments` object
- Function declarations are hoisted, expressions are not

### Objects and Arrays

**Object Creation**:
```javascript
// Object literal
const person = {
  name: 'John',
  age: 30,
  greet() {
    return `Hello, I'm ${this.name}`;
  }
};

// Accessing properties
person.name           // Dot notation
person['name']        // Bracket notation (dynamic keys)

// Adding/modifying properties
person.email = 'john@example.com';
person.age = 31;

// Deleting properties
delete person.email;
```

**Array Methods**:
```javascript
const numbers = [1, 2, 3, 4, 5];

// Transformation
numbers.map(n => n * 2)           // [2, 4, 6, 8, 10]
numbers.filter(n => n > 2)        // [3, 4, 5]
numbers.reduce((sum, n) => sum + n, 0) // 15

// Iteration
numbers.forEach(n => console.log(n));

// Search
numbers.find(n => n > 3)          // 4
numbers.findIndex(n => n > 3)     // 3
numbers.includes(3)               // true

// Mutation (modify original)
numbers.push(6)                   // Add to end
numbers.pop()                     // Remove from end
numbers.unshift(0)                // Add to start
numbers.shift()                   // Remove from start
numbers.splice(2, 1)              // Remove 1 item at index 2

// Non-mutating
numbers.slice(1, 3)               // [2, 3]
numbers.concat([6, 7])            // [1, 2, 3, 4, 5, 6, 7]
[...numbers, 6, 7]                // Spread operator
```

### Closures

A closure is a function that has access to variables in its outer (enclosing) lexical scope, even after the outer function has returned.

```javascript
function createCounter() {
  let count = 0; // Private variable

  return {
    increment() {
      return ++count;
    },
    decrement() {
      return --count;
    },
    getCount() {
      return count;
    }
  };
}

const counter = createCounter();
console.log(counter.increment()); // 1
console.log(counter.increment()); // 2
console.log(counter.getCount());  // 2
// count is not directly accessible
```

**Use Cases**:
- Data privacy/encapsulation
- Factory functions
- Event handlers
- Callbacks maintaining state
- Module pattern implementation

### Prototypes and Inheritance

JavaScript uses prototypal inheritance. Every object has an internal `[[Prototype]]` link to another object.

```javascript
// Constructor function
function Animal(name) {
  this.name = name;
}

// Add method to prototype
Animal.prototype.speak = function() {
  return `${this.name} makes a sound`;
};

const dog = new Animal('Dog');
console.log(dog.speak()); // "Dog makes a sound"

// Inheritance
function Dog(name, breed) {
  Animal.call(this, name); // Call parent constructor
  this.breed = breed;
}

// Set up prototype chain
Dog.prototype = Object.create(Animal.prototype);
Dog.prototype.constructor = Dog;

Dog.prototype.bark = function() {
  return `${this.name} barks!`;
};

const myDog = new Dog('Buddy', 'Golden Retriever');
console.log(myDog.speak()); // "Buddy makes a sound" (inherited)
console.log(myDog.bark());  // "Buddy barks!" (own method)
```

### Classes (ES6+)

Classes provide syntactic sugar over prototypal inheritance:

```javascript
class Animal {
  constructor(name) {
    this.name = name;
  }

  speak() {
    return `${this.name} makes a sound`;
  }

  // Static method
  static create(name) {
    return new Animal(name);
  }
}

class Dog extends Animal {
  constructor(name, breed) {
    super(name); // Call parent constructor
    this.breed = breed;
  }

  speak() {
    return `${super.speak()} - Woof!`;
  }

  // Getter
  get info() {
    return `${this.name} is a ${this.breed}`;
  }

  // Setter
  set nickname(value) {
    this._nickname = value;
  }
}

const myDog = new Dog('Buddy', 'Golden Retriever');
console.log(myDog.speak());     // "Buddy makes a sound - Woof!"
console.log(myDog.info);        // "Buddy is a Golden Retriever"
myDog.nickname = 'Bud';
```

## Modern JavaScript (ES6+)

### Destructuring

Extract values from arrays or properties from objects:

```javascript
// Array destructuring
const [first, second, ...rest] = [1, 2, 3, 4, 5];
console.log(first);  // 1
console.log(second); // 2
console.log(rest);   // [3, 4, 5]

// Object destructuring
const user = { name: 'John', age: 30, city: 'NYC' };
const { name, age } = user;
console.log(name); // "John"

// Renaming
const { name: userName, age: userAge } = user;

// Default values
const { country = 'USA' } = user;

// Nested destructuring
const data = {
  user: { name: 'John', address: { city: 'NYC' } }
};
const { user: { address: { city } } } = data;

// Function parameters
function greet({ name, age = 0 }) {
  return `${name} is ${age} years old`;
}
greet({ name: 'John', age: 30 }); // "John is 30 years old"
```

### Spread and Rest Operators

**Spread** (`...`) expands elements:
```javascript
// Arrays
const arr1 = [1, 2, 3];
const arr2 = [...arr1, 4, 5]; // [1, 2, 3, 4, 5]
const combined = [...arr1, ...arr2];

// Objects
const obj1 = { a: 1, b: 2 };
const obj2 = { ...obj1, c: 3 }; // { a: 1, b: 2, c: 3 }

// Function arguments
Math.max(...arr1); // 3

// Shallow copy
const copy = [...arr1];
const objCopy = { ...obj1 };
```

**Rest** (`...`) collects elements:
```javascript
// Function parameters
function sum(...numbers) {
  return numbers.reduce((total, n) => total + n, 0);
}
sum(1, 2, 3, 4); // 10

// With other parameters
function multiply(multiplier, ...numbers) {
  return numbers.map(n => n * multiplier);
}
multiply(2, 1, 2, 3); // [2, 4, 6]
```

### Template Literals

Multi-line strings and string interpolation:

```javascript
const name = 'John';
const age = 30;

// String interpolation
const greeting = `Hello, ${name}!`;

// Expressions
const message = `In 5 years, you'll be ${age + 5}`;

// Multi-line
const multiline = `
  This is a
  multi-line
  string
`;

// Tagged templates
function highlight(strings, ...values) {
  return strings.reduce((result, str, i) => {
    return result + str + (values[i] ? `<mark>${values[i]}</mark>` : '');
  }, '');
}

const html = highlight`Hello, ${name}! You are ${age} years old.`;
// "Hello, <mark>John</mark>! You are <mark>30</mark> years old."
```

### Optional Chaining and Nullish Coalescing

**Optional Chaining** (`?.`): Safely access nested properties:
```javascript
const user = {
  name: 'John',
  address: {
    city: 'NYC'
  }
};

// Without optional chaining
const city = user && user.address && user.address.city;

// With optional chaining
const city = user?.address?.city; // "NYC"
const zip = user?.address?.zip;   // undefined (no error!)

// With methods
user.getName?.(); // Only calls if method exists

// With arrays
const firstItem = arr?.[0];
```

**Nullish Coalescing** (`??`): Default values for null/undefined:
```javascript
// || returns right side for ANY falsy value
const value1 = 0 || 'default';     // "default"
const value2 = '' || 'default';    // "default"
const value3 = false || 'default'; // "default"

// ?? only for null/undefined
const value4 = 0 ?? 'default';     // 0
const value5 = '' ?? 'default';    // ""
const value6 = false ?? 'default'; // false
const value7 = null ?? 'default';  // "default"
const value8 = undefined ?? 'default'; // "default"
```

### Modules

**Exporting**:
```javascript
// Named exports
export const PI = 3.14159;
export function add(a, b) {
  return a + b;
}
export class Calculator {
  // ...
}

// Export multiple
const multiply = (a, b) => a * b;
const divide = (a, b) => a / b;
export { multiply, divide };

// Default export (one per file)
export default class App {
  // ...
}

// Or
class App { }
export default App;
```

**Importing**:
```javascript
// Named imports
import { PI, add } from './math.js';
import { multiply as mult } from './math.js'; // Rename

// Default import
import App from './App.js';

// Mix default and named
import App, { PI, add } from './App.js';

// Import all
import * as Math from './math.js';
Math.PI;
Math.add(1, 2);

// Import for side effects only
import './polyfills.js';
```

## Asynchronous Patterns

### The Event Loop

JavaScript is single-threaded but handles async operations through the event loop:

1. **Call Stack**: Executes synchronous code
2. **Web APIs**: Browser/Node APIs (setTimeout, fetch, etc.)
3. **Callback Queue**: Completed async operations wait here
4. **Event Loop**: Moves callbacks from queue to stack when stack is empty

```javascript
console.log('1');

setTimeout(() => {
  console.log('2');
}, 0);

Promise.resolve().then(() => {
  console.log('3');
});

console.log('4');

// Output: 1, 4, 3, 2
// Microtasks (Promises) have priority over macrotasks (setTimeout)
```

### Callbacks

Traditional async pattern (can lead to "callback hell"):

```javascript
function fetchUser(userId, callback) {
  setTimeout(() => {
    callback(null, { id: userId, name: 'John' });
  }, 1000);
}

function fetchPosts(userId, callback) {
  setTimeout(() => {
    callback(null, [{ id: 1, title: 'Post 1' }]);
  }, 1000);
}

// Callback hell
fetchUser(1, (error, user) => {
  if (error) {
    console.error(error);
    return;
  }

  fetchPosts(user.id, (error, posts) => {
    if (error) {
      console.error(error);
      return;
    }

    console.log(user, posts);
  });
});
```

### Promises

Promises represent eventual completion (or failure) of an async operation:

```javascript
// Creating a promise
const promise = new Promise((resolve, reject) => {
  setTimeout(() => {
    const success = true;
    if (success) {
      resolve('Success!');
    } else {
      reject(new Error('Failed!'));
    }
  }, 1000);
});

// Using a promise
promise
  .then(result => {
    console.log(result); // "Success!"
    return result.toUpperCase();
  })
  .then(upperResult => {
    console.log(upperResult); // "SUCCESS!"
  })
  .catch(error => {
    console.error(error);
  })
  .finally(() => {
    console.log('Cleanup');
  });

// Promise utilities
Promise.all([promise1, promise2, promise3])
  .then(results => {
    // All resolved: [result1, result2, result3]
  });

Promise.race([promise1, promise2])
  .then(result => {
    // First to resolve
  });

Promise.allSettled([promise1, promise2])
  .then(results => {
    // All completed (resolved or rejected)
    // [{ status: 'fulfilled', value: ... }, { status: 'rejected', reason: ... }]
  });

Promise.any([promise1, promise2])
  .then(result => {
    // First to fulfill (resolve)
  });
```

### Async/Await

Modern syntax for handling promises (ES2017+):

```javascript
async function fetchUserData(userId) {
  try {
    const user = await fetchUser(userId);
    const posts = await fetchPosts(user.id);
    const comments = await fetchComments(posts[0].id);

    return { user, posts, comments };
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
}

// Using the async function
fetchUserData(1)
  .then(data => console.log(data))
  .catch(error => console.error(error));

// Parallel execution
async function fetchAllData() {
  const [users, posts, comments] = await Promise.all([
    fetchUsers(),
    fetchPosts(),
    fetchComments()
  ]);

  return { users, posts, comments };
}

// Sequential vs Parallel
async function sequential() {
  const result1 = await operation1(); // Wait
  const result2 = await operation2(); // Then wait
  return [result1, result2];
}

async function parallel() {
  const [result1, result2] = await Promise.all([
    operation1(), // Start both
    operation2()  // simultaneously
  ]);
  return [result1, result2];
}
```

### Error Handling in Async Code

```javascript
// Try-catch with async/await
async function robustFetch(url) {
  try {
    const response = await fetch(url);

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    if (error.name === 'TypeError') {
      console.error('Network error:', error);
    } else {
      console.error('Error:', error);
    }
    throw error; // Re-throw or handle
  }
}

// Promise catch
fetchData()
  .then(data => processData(data))
  .catch(error => {
    // Catches errors from fetchData AND processData
    console.error(error);
  });

// Global error handlers
window.addEventListener('unhandledrejection', event => {
  console.error('Unhandled promise rejection:', event.reason);
  event.preventDefault();
});
```

## Common Patterns

### Module Pattern

Encapsulate private data and expose public API:

```javascript
const Calculator = (function() {
  // Private variables
  let history = [];

  // Private function
  function log(operation) {
    history.push(operation);
  }

  // Public API
  return {
    add(a, b) {
      const result = a + b;
      log(`${a} + ${b} = ${result}`);
      return result;
    },

    subtract(a, b) {
      const result = a - b;
      log(`${a} - ${b} = ${result}`);
      return result;
    },

    getHistory() {
      return [...history]; // Return copy
    },

    clearHistory() {
      history = [];
    }
  };
})();

Calculator.add(5, 3); // 8
console.log(Calculator.getHistory()); // ["5 + 3 = 8"]
```

### Revealing Module Pattern

Cleaner variation of module pattern:

```javascript
const UserManager = (function() {
  // Private
  let users = [];

  function findUserById(id) {
    return users.find(u => u.id === id);
  }

  function validateUser(user) {
    return user && user.name && user.email;
  }

  // Public methods
  function addUser(user) {
    if (validateUser(user)) {
      users.push(user);
      return true;
    }
    return false;
  }

  function getUser(id) {
    return findUserById(id);
  }

  function getAllUsers() {
    return [...users];
  }

  // Reveal public API
  return {
    add: addUser,
    get: getUser,
    getAll: getAllUsers
  };
})();
```

### Factory Pattern

Create objects without specifying exact class:

```javascript
function createUser(name, role) {
  const roles = {
    admin: {
      permissions: ['read', 'write', 'delete'],
      level: 3
    },
    editor: {
      permissions: ['read', 'write'],
      level: 2
    },
    viewer: {
      permissions: ['read'],
      level: 1
    }
  };

  const roleConfig = roles[role] || roles.viewer;

  return {
    name,
    role,
    ...roleConfig,

    hasPermission(permission) {
      return this.permissions.includes(permission);
    },

    toString() {
      return `${this.name} (${this.role})`;
    }
  };
}

const admin = createUser('Alice', 'admin');
const editor = createUser('Bob', 'editor');

console.log(admin.hasPermission('delete')); // true
console.log(editor.hasPermission('delete')); // false
```

### Singleton Pattern

Ensure only one instance exists:

```javascript
const Config = (function() {
  let instance;

  function createInstance() {
    return {
      apiUrl: 'https://api.example.com',
      timeout: 5000,
      retries: 3,

      get(key) {
        return this[key];
      },

      set(key, value) {
        this[key] = value;
      }
    };
  }

  return {
    getInstance() {
      if (!instance) {
        instance = createInstance();
      }
      return instance;
    }
  };
})();

const config1 = Config.getInstance();
const config2 = Config.getInstance();
console.log(config1 === config2); // true

// Modern ES6 class version
class Database {
  constructor() {
    if (Database.instance) {
      return Database.instance;
    }

    this.connection = null;
    Database.instance = this;
  }

  connect() {
    if (!this.connection) {
      this.connection = 'Connected to DB';
    }
    return this.connection;
  }
}

const db1 = new Database();
const db2 = new Database();
console.log(db1 === db2); // true
```

### Observer Pattern

Subscribe to and publish events:

```javascript
class EventEmitter {
  constructor() {
    this.events = {};
  }

  on(event, listener) {
    if (!this.events[event]) {
      this.events[event] = [];
    }
    this.events[event].push(listener);

    // Return unsubscribe function
    return () => this.off(event, listener);
  }

  off(event, listenerToRemove) {
    if (!this.events[event]) return;

    this.events[event] = this.events[event].filter(
      listener => listener !== listenerToRemove
    );
  }

  emit(event, ...args) {
    if (!this.events[event]) return;

    this.events[event].forEach(listener => {
      listener(...args);
    });
  }

  once(event, listener) {
    const onceWrapper = (...args) => {
      listener(...args);
      this.off(event, onceWrapper);
    };
    this.on(event, onceWrapper);
  }
}

// Usage
const emitter = new EventEmitter();

const unsubscribe = emitter.on('data', (data) => {
  console.log('Received:', data);
});

emitter.emit('data', { id: 1 }); // "Received: { id: 1 }"
unsubscribe();
emitter.emit('data', { id: 2 }); // Nothing logged
```

### Memoization

Cache function results for performance:

```javascript
function memoize(fn) {
  const cache = new Map();

  return function(...args) {
    const key = JSON.stringify(args);

    if (cache.has(key)) {
      console.log('Cached result');
      return cache.get(key);
    }

    const result = fn.apply(this, args);
    cache.set(key, result);
    return result;
  };
}

// Expensive function
function fibonacci(n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

const memoizedFib = memoize(fibonacci);
console.log(memoizedFib(40)); // Slow first time
console.log(memoizedFib(40)); // Instant (cached)

// With object methods
const calculator = {
  multiplier: 2,

  calculate: memoize(function(n) {
    return n * this.multiplier;
  })
};
```

## Best Practices

### Naming Conventions

```javascript
// Constants - UPPERCASE_SNAKE_CASE
const MAX_RETRIES = 3;
const API_BASE_URL = 'https://api.example.com';

// Variables and functions - camelCase
let userName = 'John';
function getUserData() { }

// Classes - PascalCase
class UserAccount { }
class HTTPHandler { }

// Private convention - prefix with underscore
class Widget {
  constructor() {
    this._privateProperty = 'internal';
  }

  _privateMethod() {
    // Implementation
  }
}

// Boolean variables - use is/has/can prefix
const isActive = true;
const hasPermission = false;
const canEdit = true;

// Functions - use verb prefix
function getUser() { }
function setConfig() { }
function validateInput() { }
function handleClick() { }
```

### Error Handling

```javascript
// Custom error classes
class ValidationError extends Error {
  constructor(message, field) {
    super(message);
    this.name = 'ValidationError';
    this.field = field;
  }
}

class NetworkError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.name = 'NetworkError';
    this.statusCode = statusCode;
  }
}

// Throw specific errors
function validateEmail(email) {
  if (!email.includes('@')) {
    throw new ValidationError('Invalid email format', 'email');
  }
  return true;
}

// Handle different error types
try {
  validateEmail('invalid');
} catch (error) {
  if (error instanceof ValidationError) {
    console.error(`Validation failed for ${error.field}: ${error.message}`);
  } else {
    console.error('Unexpected error:', error);
  }
}

// Async error handling
async function fetchWithRetry(url, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url);
      if (!response.ok) {
        throw new NetworkError('Request failed', response.status);
      }
      return await response.json();
    } catch (error) {
      if (i === retries - 1) throw error; // Last retry
      console.log(`Retry ${i + 1}/${retries}`);
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
    }
  }
}
```

### Performance Tips

```javascript
// 1. Avoid unnecessary operations in loops
// Bad
for (let i = 0; i < array.length; i++) { } // Length calculated each iteration

// Good
const len = array.length;
for (let i = 0; i < len; i++) { }

// Better - use built-in methods
array.forEach(item => { });

// 2. Debounce expensive operations
function debounce(fn, delay) {
  let timeoutId;
  return function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn.apply(this, args), delay);
  };
}

const expensiveSearch = debounce((query) => {
  // API call
}, 300);

// 3. Throttle high-frequency events
function throttle(fn, limit) {
  let inThrottle;
  return function(...args) {
    if (!inThrottle) {
      fn.apply(this, args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
}

window.addEventListener('scroll', throttle(() => {
  // Handle scroll
}, 100));

// 4. Use object/map for lookups
// Bad - O(n)
const colors = ['red', 'blue', 'green'];
colors.includes('blue'); // Linear search

// Good - O(1)
const colorSet = new Set(['red', 'blue', 'green']);
colorSet.has('blue'); // Constant time

// 5. Avoid memory leaks
// Bad - event listener not removed
element.addEventListener('click', handler);

// Good
const handler = () => { };
element.addEventListener('click', handler);
// Later...
element.removeEventListener('click', handler);

// 6. Use WeakMap for private data
const privateData = new WeakMap();

class MyClass {
  constructor() {
    privateData.set(this, { secret: 'value' });
  }

  getSecret() {
    return privateData.get(this).secret;
  }
}
// When instance is garbage collected, WeakMap entry is too
```

### Code Organization

```javascript
// 1. Single Responsibility Principle
// Bad - function does too much
function processUserData(userData) {
  // Validate
  // Transform
  // Save to database
  // Send email
  // Update UI
}

// Good - separate concerns
function validateUser(userData) { }
function transformUserData(userData) { }
function saveUser(userData) { }
function sendWelcomeEmail(user) { }
function updateUI(user) { }

// 2. Pure functions (no side effects)
// Bad - modifies input
function addToCart(cart, item) {
  cart.items.push(item);
  return cart;
}

// Good - returns new object
function addToCart(cart, item) {
  return {
    ...cart,
    items: [...cart.items, item]
  };
}

// 3. Avoid magic numbers
// Bad
if (user.role === 2) { }

// Good
const ROLES = {
  ADMIN: 1,
  EDITOR: 2,
  VIEWER: 3
};

if (user.role === ROLES.EDITOR) { }

// 4. Use default parameters
// Bad
function greet(name) {
  name = name || 'Guest';
  return `Hello, ${name}`;
}

// Good
function greet(name = 'Guest') {
  return `Hello, ${name}`;
}

// 5. Guard clauses for early returns
// Bad
function processOrder(order) {
  if (order) {
    if (order.items.length > 0) {
      if (order.total > 0) {
        // Process order
      }
    }
  }
}

// Good
function processOrder(order) {
  if (!order) return;
  if (order.items.length === 0) return;
  if (order.total <= 0) return;

  // Process order
}
```

### Memory Management

```javascript
// 1. Clear timers and intervals
const timerId = setTimeout(() => { }, 1000);
clearTimeout(timerId);

const intervalId = setInterval(() => { }, 1000);
clearInterval(intervalId);

// 2. Remove event listeners
const handler = () => { };
element.addEventListener('click', handler);
element.removeEventListener('click', handler);

// 3. Set references to null when done
let largeData = fetchLargeDataset();
// Use data...
largeData = null; // Allow garbage collection

// 4. Use WeakMap/WeakSet for caches
const cache = new WeakMap();
let obj = { data: 'value' };
cache.set(obj, 'cached value');
obj = null; // Cache entry automatically removed

// 5. Avoid global variables
// Bad
var globalUser = { };

// Good - use modules/closures
(function() {
  const user = { };
  // Use user locally
})();

// 6. Be careful with closures
function createHeavyObject() {
  const heavyData = new Array(1000000);

  // Bad - closure keeps heavyData in memory
  return function() {
    console.log(heavyData.length);
  };

  // Good - only capture what you need
  const length = heavyData.length;
  return function() {
    console.log(length);
  };
}
```

### Testing Considerations

```javascript
// 1. Write testable code - pure functions
// Testable
function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// Hard to test - depends on external state
function calculateTotal() {
  return cart.items.reduce((sum, item) => sum + item.price, 0);
}

// 2. Dependency injection
// Hard to test
class UserService {
  constructor() {
    this.api = new ApiClient();
  }
}

// Easy to test - inject dependencies
class UserService {
  constructor(apiClient) {
    this.api = apiClient;
  }
}

// 3. Avoid side effects
// Side effects
function processData(data) {
  console.log('Processing...'); // Side effect
  updateDatabase(data); // Side effect
  return transform(data);
}

// Pure
function transformData(data) {
  return transform(data);
}

// Separate side effects
function processData(data) {
  const transformed = transformData(data);
  console.log('Processing...');
  updateDatabase(transformed);
  return transformed;
}
```

## Quick Reference

### Array Methods Cheat Sheet

```javascript
const arr = [1, 2, 3, 4, 5];

// Transform
arr.map(x => x * 2)              // [2, 4, 6, 8, 10]
arr.filter(x => x > 2)           // [3, 4, 5]
arr.reduce((sum, x) => sum + x)  // 15

// Search
arr.find(x => x > 3)             // 4
arr.findIndex(x => x > 3)        // 3
arr.indexOf(3)                   // 2
arr.includes(3)                  // true
arr.some(x => x > 3)             // true
arr.every(x => x > 0)            // true

// Mutation
arr.push(6)                      // Add to end
arr.pop()                        // Remove from end
arr.unshift(0)                   // Add to start
arr.shift()                      // Remove from start
arr.splice(2, 1, 99)             // Remove/add at index

// Non-mutating
arr.slice(1, 3)                  // [2, 3]
arr.concat([6, 7])               // [1, 2, 3, 4, 5, 6, 7]
[...arr]                         // Copy
arr.join(', ')                   // "1, 2, 3, 4, 5"
arr.reverse()                    // [5, 4, 3, 2, 1] (mutates!)
arr.sort((a, b) => a - b)        // Sort (mutates!)
```

### Object Methods Cheat Sheet

```javascript
const obj = { a: 1, b: 2, c: 3 };

Object.keys(obj)                 // ['a', 'b', 'c']
Object.values(obj)               // [1, 2, 3]
Object.entries(obj)              // [['a', 1], ['b', 2], ['c', 3]]
Object.fromEntries([['a', 1]])   // { a: 1 }

Object.assign({}, obj, { d: 4 }) // { a: 1, b: 2, c: 3, d: 4 }
{ ...obj, d: 4 }                 // Same as above

Object.freeze(obj)               // Make immutable
Object.seal(obj)                 // Prevent add/remove properties
Object.preventExtensions(obj)    // Prevent adding properties

Object.hasOwnProperty.call(obj, 'a') // true
'a' in obj                       // true
obj.hasOwnProperty('a')          // true (not recommended)
```

### Common Gotchas

```javascript
// 1. Equality
0 == '0'          // true (type coercion)
0 === '0'         // false (strict)
null == undefined // true
null === undefined // false

// 2. Type coercion
'5' + 3           // "53" (string concatenation)
'5' - 3           // 2 (numeric subtraction)
+'5'              // 5 (unary plus converts to number)
!!'value'         // true (double negation to boolean)

// 3. this binding
const obj = {
  name: 'Object',
  regular: function() { console.log(this.name); },
  arrow: () => { console.log(this.name); }
};
obj.regular();    // "Object"
obj.arrow();      // undefined (arrow uses lexical this)

// 4. Falsy values
false, 0, -0, 0n, '', null, undefined, NaN

// 5. Array/Object comparison
[] === []         // false (different references)
{} === {}         // false (different references)

// 6. Floating point
0.1 + 0.2 === 0.3 // false (0.30000000000000004)
Math.abs(0.1 + 0.2 - 0.3) < Number.EPSILON // true

// 7. Hoisting
console.log(x);   // undefined (var hoisted)
var x = 5;

console.log(y);   // ReferenceError (let not hoisted to usable state)
let y = 5;
```

This comprehensive guide covers the essential JavaScript fundamentals needed for modern development. Practice these concepts regularly and refer to the EXAMPLES.md file for detailed implementation scenarios.
