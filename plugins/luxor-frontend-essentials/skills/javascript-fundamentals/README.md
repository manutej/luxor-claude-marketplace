# JavaScript Fundamentals

A comprehensive Claude Code skill for mastering core JavaScript concepts, modern ES6+ features, asynchronous programming patterns, and industry best practices.

## Overview

JavaScript is the language of the web and has evolved significantly since its creation. This skill provides a complete reference for:

- Core language features and syntax
- Modern ES6+ enhancements
- Asynchronous programming patterns
- Common design patterns
- Best practices for production code
- Performance optimization techniques
- Memory management strategies

Whether you're building frontend applications, Node.js backends, or full-stack solutions, understanding JavaScript fundamentals is essential for writing maintainable, performant code.

## What's Included

### SKILL.md (20KB+)
The main skill documentation containing:

- **Core Concepts**: Variables, scope, data types, functions, objects, arrays, closures, prototypes, and classes
- **Modern JavaScript (ES6+)**: Destructuring, spread/rest operators, template literals, optional chaining, nullish coalescing, and modules
- **Asynchronous Patterns**: Event loop, callbacks, promises, async/await, and error handling strategies
- **Common Patterns**: Module pattern, factory pattern, singleton, observer, and memoization
- **Best Practices**: Naming conventions, error handling, performance optimization, code organization, and memory management
- **Quick Reference**: Cheat sheets for array methods, object methods, and common gotchas

### EXAMPLES.md (15KB+)
Deep-dive examples with real-world scenarios:

- Practical implementations of core concepts
- Complex async patterns and data fetching
- State management solutions
- Form validation and data processing
- API integration examples
- Performance optimization techniques
- Testing patterns and strategies

### README.md (This File)
Overview, setup guidance, and learning resources

## Who Should Use This Skill

This skill is designed for:

- **Developers New to JavaScript**: Comprehensive introduction to language fundamentals
- **Experienced Developers**: Quick reference for syntax, patterns, and best practices
- **Code Reviewers**: Standards and patterns for evaluating JavaScript code quality
- **Technical Interviewers**: Common concepts and patterns tested in interviews
- **Educators/Mentors**: Teaching material with clear explanations and examples
- **Full-Stack Developers**: Essential JavaScript knowledge for both frontend and backend

## Prerequisites

To get the most from this skill:

- Basic programming knowledge (variables, loops, conditionals)
- Understanding of HTML and web basics (for frontend examples)
- Familiarity with command line and text editors
- Optional: Node.js installed for running examples locally

## Quick Start

### 1. Understanding Variable Declarations

JavaScript has three ways to declare variables:

```javascript
// const - cannot be reassigned (use by default)
const userName = 'John';

// let - can be reassigned (use when needed)
let counter = 0;
counter++;

// var - function-scoped (avoid in modern code)
var oldStyle = 'legacy';
```

**Rule of Thumb**: Start with `const`, use `let` when you need to reassign, avoid `var`.

### 2. Working with Functions

```javascript
// Function declaration
function add(a, b) {
  return a + b;
}

// Arrow function (modern syntax)
const multiply = (a, b) => a * b;

// Function with default parameters
const greet = (name = 'Guest') => `Hello, ${name}!`;
```

### 3. Array Operations

```javascript
const numbers = [1, 2, 3, 4, 5];

// Transform data
const doubled = numbers.map(n => n * 2);

// Filter data
const evenNumbers = numbers.filter(n => n % 2 === 0);

// Calculate aggregate
const sum = numbers.reduce((total, n) => total + n, 0);
```

### 4. Async/Await Pattern

```javascript
// Modern async code
async function fetchUserData(userId) {
  try {
    const response = await fetch(`/api/users/${userId}`);
    const user = await response.json();
    return user;
  } catch (error) {
    console.error('Failed to fetch user:', error);
    throw error;
  }
}
```

### 5. Destructuring and Spread

```javascript
// Object destructuring
const user = { name: 'John', age: 30, city: 'NYC' };
const { name, age } = user;

// Array destructuring
const [first, second, ...rest] = [1, 2, 3, 4, 5];

// Spread operator
const newUser = { ...user, email: 'john@example.com' };
const allNumbers = [...numbers, 6, 7, 8];
```

## Key Concepts to Master

### 1. Scope and Closures

Understanding how JavaScript manages variable access and creates private data:

```javascript
function createCounter() {
  let count = 0; // Private variable

  return {
    increment: () => ++count,
    decrement: () => --count,
    getCount: () => count
  };
}

const counter = createCounter();
counter.increment(); // 1
counter.increment(); // 2
```

**Why It Matters**: Closures enable data privacy, module patterns, and function factories.

### 2. Asynchronous JavaScript

The event loop and async patterns are crucial for modern web development:

```javascript
// Promise-based async code
fetchUser(1)
  .then(user => fetchPosts(user.id))
  .then(posts => console.log(posts))
  .catch(error => console.error(error));

// Modern async/await syntax
async function loadData() {
  try {
    const user = await fetchUser(1);
    const posts = await fetchPosts(user.id);
    console.log(posts);
  } catch (error) {
    console.error(error);
  }
}
```

**Why It Matters**: Nearly all web operations (API calls, file I/O, timers) are asynchronous.

### 3. Array and Object Manipulation

Mastering built-in methods for data transformation:

```javascript
const users = [
  { name: 'John', age: 30, active: true },
  { name: 'Jane', age: 25, active: false },
  { name: 'Bob', age: 35, active: true }
];

// Chain operations
const activeUserNames = users
  .filter(user => user.active)
  .map(user => user.name)
  .join(', ');
// "John, Bob"

// Calculate aggregate
const averageAge = users.reduce((sum, user) => sum + user.age, 0) / users.length;
```

**Why It Matters**: Modern JavaScript development relies heavily on functional array methods.

### 4. Modern ES6+ Features

Leveraging modern syntax for cleaner code:

```javascript
// Template literals
const message = `Hello, ${name}! You are ${age} years old.`;

// Optional chaining
const city = user?.address?.city;

// Nullish coalescing
const displayName = username ?? 'Guest';

// Spread operator
const combined = { ...defaults, ...userOptions };
```

**Why It Matters**: ES6+ features make code more readable, maintainable, and less error-prone.

### 5. Error Handling

Robust error handling for production code:

```javascript
// Custom error classes
class ValidationError extends Error {
  constructor(message, field) {
    super(message);
    this.name = 'ValidationError';
    this.field = field;
  }
}

// Try-catch with specific error types
try {
  validateInput(data);
} catch (error) {
  if (error instanceof ValidationError) {
    console.error(`Validation failed for ${error.field}`);
  } else {
    console.error('Unexpected error:', error);
  }
}
```

**Why It Matters**: Proper error handling prevents crashes and provides better user experience.

## Common Use Cases

### 1. API Integration

```javascript
class ApiClient {
  constructor(baseURL) {
    this.baseURL = baseURL;
  }

  async get(endpoint) {
    const response = await fetch(`${this.baseURL}${endpoint}`);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return response.json();
  }

  async post(endpoint, data) {
    const response = await fetch(`${this.baseURL}${endpoint}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return response.json();
  }
}

const api = new ApiClient('https://api.example.com');
const users = await api.get('/users');
```

### 2. State Management

```javascript
class Store {
  constructor(initialState = {}) {
    this.state = initialState;
    this.listeners = [];
  }

  getState() {
    return { ...this.state };
  }

  setState(updates) {
    this.state = { ...this.state, ...updates };
    this.listeners.forEach(listener => listener(this.state));
  }

  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }
}

const store = new Store({ count: 0 });
const unsubscribe = store.subscribe(state => console.log(state));
store.setState({ count: 1 });
```

### 3. Form Validation

```javascript
const validators = {
  required: value => value.trim() !== '' || 'This field is required',
  email: value => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value) || 'Invalid email',
  minLength: min => value => value.length >= min || `Minimum ${min} characters`,
  maxLength: max => value => value.length <= max || `Maximum ${max} characters`
};

function validateForm(formData, rules) {
  const errors = {};

  for (const [field, fieldRules] of Object.entries(rules)) {
    for (const rule of fieldRules) {
      const result = rule(formData[field]);
      if (result !== true) {
        errors[field] = result;
        break;
      }
    }
  }

  return { isValid: Object.keys(errors).length === 0, errors };
}

const result = validateForm(
  { email: 'test@example.com', password: '12345' },
  {
    email: [validators.required, validators.email],
    password: [validators.required, validators.minLength(8)]
  }
);
```

### 4. Debouncing and Throttling

```javascript
// Debounce - delay execution until after calls stop
function debounce(fn, delay) {
  let timeoutId;
  return function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn.apply(this, args), delay);
  };
}

// Usage: Search as user types
const searchInput = document.querySelector('#search');
const handleSearch = debounce((query) => {
  console.log('Searching for:', query);
}, 300);

searchInput.addEventListener('input', (e) => handleSearch(e.target.value));

// Throttle - execute at most once per time period
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

// Usage: Handle scroll events
window.addEventListener('scroll', throttle(() => {
  console.log('Scroll position:', window.scrollY);
}, 100));
```

## Learning Path

### Beginner Path

1. **Variables and Data Types**: Understand const, let, primitives, and objects
2. **Functions**: Master function declarations, expressions, and arrow functions
3. **Arrays and Objects**: Learn array methods and object manipulation
4. **Control Flow**: if/else, switch, loops (for, while, forEach)
5. **Basic DOM Manipulation**: Select elements, add event listeners

### Intermediate Path

1. **Closures**: Understand scope chains and private data
2. **Prototypes and Classes**: Inheritance and object-oriented patterns
3. **Async Basics**: Callbacks, promises, async/await
4. **ES6+ Features**: Destructuring, spread, template literals
5. **Error Handling**: Try-catch, custom errors, validation

### Advanced Path

1. **Design Patterns**: Module, factory, singleton, observer
2. **Performance Optimization**: Memoization, debouncing, throttling
3. **Memory Management**: Garbage collection, WeakMap, avoiding leaks
4. **Advanced Async**: Promise.all, race, parallel vs sequential
5. **Functional Programming**: Pure functions, composition, immutability

## Performance Considerations

### 1. Avoid Premature Optimization

Focus on writing clear, maintainable code first. Optimize when you have:
- Measured performance bottlenecks
- Clear metrics showing the issue
- User-facing impact

### 2. Common Optimizations

```javascript
// Use const/let instead of var (faster in modern engines)
const value = 10;

// Cache array length in loops
const len = array.length;
for (let i = 0; i < len; i++) { }

// Use built-in methods (optimized by engines)
array.forEach(item => { }); // Better than manual loop

// Avoid creating functions in loops
// Bad
for (let i = 0; i < 10; i++) {
  setTimeout(() => console.log(i), 100); // Creates 10 functions
}

// Good
function logValue(i) {
  console.log(i);
}
for (let i = 0; i < 10; i++) {
  setTimeout(() => logValue(i), 100);
}
```

### 3. Memory Management

```javascript
// Clear timers and intervals
const id = setInterval(() => { }, 1000);
clearInterval(id);

// Remove event listeners when done
const handler = () => { };
element.addEventListener('click', handler);
element.removeEventListener('click', handler);

// Set large objects to null when finished
let largeData = fetchLargeDataset();
// Use data...
largeData = null; // Eligible for garbage collection
```

## Testing Your JavaScript Code

### Unit Testing Example

```javascript
// Function to test
function calculateTotal(items, taxRate = 0.1) {
  const subtotal = items.reduce((sum, item) => sum + item.price, 0);
  return subtotal * (1 + taxRate);
}

// Test cases (using any testing framework)
test('calculates total with tax', () => {
  const items = [{ price: 10 }, { price: 20 }];
  expect(calculateTotal(items, 0.1)).toBe(33);
});

test('uses default tax rate', () => {
  const items = [{ price: 100 }];
  expect(calculateTotal(items)).toBe(110);
});

test('handles empty array', () => {
  expect(calculateTotal([])).toBe(0);
});
```

### Writing Testable Code

```javascript
// Hard to test (depends on global state)
function getTotalPrice() {
  return cart.items.reduce((sum, item) => sum + item.price, 0);
}

// Easy to test (pure function)
function calculateTotalPrice(items) {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// Test
const total = calculateTotalPrice([{ price: 10 }, { price: 20 }]);
expect(total).toBe(30);
```

## Common Pitfalls to Avoid

### 1. Not Understanding `this`

```javascript
const obj = {
  name: 'Object',
  regularMethod() {
    console.log(this.name); // 'Object'
  },
  arrowMethod: () => {
    console.log(this.name); // undefined (lexical this)
  }
};
```

### 2. Mutating Objects/Arrays

```javascript
// Bad - mutates original
function addItem(cart, item) {
  cart.items.push(item);
  return cart;
}

// Good - returns new object
function addItem(cart, item) {
  return {
    ...cart,
    items: [...cart.items, item]
  };
}
```

### 3. Not Handling Async Errors

```javascript
// Bad - uncaught promise rejection
async function fetchData() {
  const response = await fetch('/api/data');
  return response.json(); // Might fail!
}

// Good - proper error handling
async function fetchData() {
  try {
    const response = await fetch('/api/data');
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    console.error('Fetch failed:', error);
    throw error;
  }
}
```

### 4. Comparing Objects with ===

```javascript
const obj1 = { a: 1 };
const obj2 = { a: 1 };
obj1 === obj2; // false (different references)

// Use deep equality for value comparison
JSON.stringify(obj1) === JSON.stringify(obj2); // true (simple cases)
// Or use a library like lodash: _.isEqual(obj1, obj2)
```

### 5. Forgetting to Return in Array Methods

```javascript
// Bad - undefined values
const doubled = [1, 2, 3].map(n => {
  n * 2; // Missing return!
});

// Good
const doubled = [1, 2, 3].map(n => {
  return n * 2;
});

// Better - implicit return with arrow function
const doubled = [1, 2, 3].map(n => n * 2);
```

## Resources and Further Learning

### Official Documentation
- [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript) - Comprehensive JavaScript reference
- [ECMAScript Specification](https://tc39.es/ecma262/) - Official language specification
- [JavaScript.info](https://javascript.info/) - Modern tutorial from basics to advanced

### Books
- "Eloquent JavaScript" by Marijn Haverbeke
- "You Don't Know JS" series by Kyle Simpson
- "JavaScript: The Good Parts" by Douglas Crockford
- "Effective JavaScript" by David Herman

### Online Learning
- [freeCodeCamp](https://www.freecodecamp.org/) - Free interactive courses
- [Codecademy](https://www.codecademy.com/learn/introduction-to-javascript) - Structured lessons
- [Frontend Masters](https://frontendmasters.com/) - Advanced video courses

### Practice Platforms
- [LeetCode](https://leetcode.com/) - Coding challenges
- [CodeWars](https://www.codewars.com/) - JavaScript katas
- [Exercism](https://exercism.org/tracks/javascript) - Mentored practice

### Community
- Stack Overflow - Q&A for specific problems
- Reddit r/javascript - News and discussions
- JavaScript Weekly - Newsletter with latest updates

## Contributing

This skill is maintained as part of the Claude Code skills library. For updates or corrections, please refer to the skill versioning system.

## Version History

- **v1.0.0** - Initial release with comprehensive JavaScript fundamentals coverage

## License

This skill documentation is provided as-is for educational and reference purposes as part of the Claude Code ecosystem.
