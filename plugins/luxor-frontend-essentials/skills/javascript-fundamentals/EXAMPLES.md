# JavaScript Fundamentals - Detailed Examples

This document provides comprehensive, real-world examples demonstrating JavaScript fundamentals in action. Each example includes detailed explanations, use cases, and best practices.

## Table of Contents

1. [Data Processing and Transformation](#data-processing-and-transformation)
2. [Async Data Fetching](#async-data-fetching)
3. [State Management](#state-management)
4. [Form Validation](#form-validation)
5. [Event Handling](#event-handling)
6. [Caching and Memoization](#caching-and-memoization)
7. [API Client](#api-client)
8. [Observer Pattern](#observer-pattern)
9. [Debouncing and Throttling](#debouncing-and-throttling)
10. [Error Handling](#error-handling)
11. [Data Structures](#data-structures)
12. [Functional Programming](#functional-programming)
13. [Module Patterns](#module-patterns)
14. [Class-Based Patterns](#class-based-patterns)
15. [Advanced Async Patterns](#advanced-async-patterns)

---

## Data Processing and Transformation

### Example 1: Complex Data Transformation Pipeline

**Use Case**: Transform raw API data into a structured format for display in a UI.

```javascript
// Raw API data
const rawUserData = [
  {
    id: 1,
    first_name: 'John',
    last_name: 'Doe',
    email: 'john@example.com',
    created_at: '2023-01-15T10:30:00Z',
    status: 'active',
    role: 'admin',
    posts_count: 42,
    last_login: '2024-01-20T15:45:00Z'
  },
  {
    id: 2,
    first_name: 'Jane',
    last_name: 'Smith',
    email: 'jane@example.com',
    created_at: '2023-03-22T08:15:00Z',
    status: 'inactive',
    role: 'user',
    posts_count: 15,
    last_login: '2023-12-10T09:20:00Z'
  },
  {
    id: 3,
    first_name: 'Bob',
    last_name: 'Johnson',
    email: 'bob@example.com',
    created_at: '2023-06-10T14:20:00Z',
    status: 'active',
    role: 'editor',
    posts_count: 28,
    last_login: '2024-01-22T11:30:00Z'
  }
];

/**
 * Transform user data for UI display
 * - Convert snake_case to camelCase
 * - Format dates
 * - Calculate derived properties
 * - Filter sensitive data
 */
function transformUserData(users) {
  return users
    .filter(user => user.status === 'active')
    .map(user => {
      const createdDate = new Date(user.created_at);
      const lastLoginDate = new Date(user.last_login);
      const now = new Date();

      // Calculate days since last login
      const daysSinceLogin = Math.floor(
        (now - lastLoginDate) / (1000 * 60 * 60 * 24)
      );

      return {
        id: user.id,
        fullName: `${user.first_name} ${user.last_name}`,
        email: user.email,
        role: user.role,
        postsCount: user.posts_count,
        memberSince: createdDate.toLocaleDateString('en-US', {
          year: 'numeric',
          month: 'long',
          day: 'numeric'
        }),
        lastActive: daysSinceLogin === 0
          ? 'Today'
          : daysSinceLogin === 1
          ? 'Yesterday'
          : `${daysSinceLogin} days ago`,
        isActive: user.status === 'active',
        // Add badge based on role and activity
        badge: user.role === 'admin'
          ? 'Administrator'
          : user.posts_count > 30
          ? 'Power User'
          : 'Member'
      };
    })
    .sort((a, b) => b.postsCount - a.postsCount); // Sort by activity
}

// Transform the data
const transformedUsers = transformUserData(rawUserData);

console.log(transformedUsers);
/* Output:
[
  {
    id: 1,
    fullName: 'John Doe',
    email: 'john@example.com',
    role: 'admin',
    postsCount: 42,
    memberSince: 'January 15, 2023',
    lastActive: '2 days ago',
    isActive: true,
    badge: 'Administrator'
  },
  {
    id: 3,
    fullName: 'Bob Johnson',
    email: 'bob@example.com',
    role: 'editor',
    postsCount: 28,
    memberSince: 'June 10, 2023',
    lastActive: 'Today',
    isActive: true,
    badge: 'Member'
  }
]
*/

/**
 * Group users by role
 */
function groupUsersByRole(users) {
  return users.reduce((groups, user) => {
    const role = user.role;
    if (!groups[role]) {
      groups[role] = [];
    }
    groups[role].push(user);
    return groups;
  }, {});
}

const groupedUsers = groupUsersByRole(transformedUsers);
console.log(groupedUsers);
/* Output:
{
  admin: [{ id: 1, fullName: 'John Doe', ... }],
  editor: [{ id: 3, fullName: 'Bob Johnson', ... }]
}
*/

/**
 * Calculate statistics
 */
function calculateUserStats(users) {
  return {
    total: users.length,
    totalPosts: users.reduce((sum, user) => sum + user.postsCount, 0),
    averagePosts: users.reduce((sum, user) => sum + user.postsCount, 0) / users.length,
    mostActive: users.reduce((max, user) =>
      user.postsCount > max.postsCount ? user : max
    ),
    roleDistribution: Object.entries(groupUsersByRole(users))
      .map(([role, userList]) => ({
        role,
        count: userList.length,
        percentage: ((userList.length / users.length) * 100).toFixed(1)
      }))
  };
}

const stats = calculateUserStats(transformedUsers);
console.log(stats);
```

**Key Concepts Demonstrated**:
- Array methods chaining (filter, map, sort)
- Reduce for grouping and aggregation
- Date manipulation
- String interpolation
- Conditional logic
- Data transformation patterns

---

## Async Data Fetching

### Example 2: Advanced API Integration with Retry Logic

**Use Case**: Fetch data from multiple endpoints with error handling, retries, and parallel execution.

```javascript
/**
 * Fetch with automatic retry on failure
 */
async function fetchWithRetry(url, options = {}, retries = 3, delay = 1000) {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url, options);

      // Check if response is OK
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      return await response.json();
    } catch (error) {
      const isLastAttempt = i === retries - 1;

      if (isLastAttempt) {
        throw new Error(`Failed after ${retries} attempts: ${error.message}`);
      }

      console.log(`Attempt ${i + 1} failed. Retrying in ${delay}ms...`);

      // Exponential backoff
      await new Promise(resolve => setTimeout(resolve, delay * (i + 1)));
    }
  }
}

/**
 * Fetch data from multiple endpoints in parallel
 */
async function fetchDashboardData(userId) {
  try {
    // Start all requests in parallel
    const [user, posts, comments, stats] = await Promise.all([
      fetchWithRetry(`/api/users/${userId}`),
      fetchWithRetry(`/api/users/${userId}/posts`),
      fetchWithRetry(`/api/users/${userId}/comments`),
      fetchWithRetry(`/api/users/${userId}/stats`)
    ]);

    return {
      user,
      posts,
      comments,
      stats,
      loadedAt: new Date().toISOString()
    };
  } catch (error) {
    console.error('Failed to load dashboard data:', error);
    throw error;
  }
}

/**
 * Fetch data with timeout
 */
async function fetchWithTimeout(url, timeout = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  try {
    const response = await fetch(url, {
      signal: controller.signal
    });
    clearTimeout(timeoutId);
    return await response.json();
  } catch (error) {
    clearTimeout(timeoutId);
    if (error.name === 'AbortError') {
      throw new Error(`Request timeout after ${timeout}ms`);
    }
    throw error;
  }
}

/**
 * Fetch with caching
 */
class CachedFetcher {
  constructor(cacheDuration = 5 * 60 * 1000) { // 5 minutes default
    this.cache = new Map();
    this.cacheDuration = cacheDuration;
  }

  async fetch(url, options = {}) {
    const cacheKey = `${url}-${JSON.stringify(options)}`;
    const cached = this.cache.get(cacheKey);

    // Return cached data if valid
    if (cached && Date.now() - cached.timestamp < this.cacheDuration) {
      console.log('Returning cached data for:', url);
      return cached.data;
    }

    // Fetch fresh data
    console.log('Fetching fresh data for:', url);
    const response = await fetch(url, options);
    const data = await response.json();

    // Update cache
    this.cache.set(cacheKey, {
      data,
      timestamp: Date.now()
    });

    return data;
  }

  clearCache() {
    this.cache.clear();
  }

  invalidate(url) {
    for (const key of this.cache.keys()) {
      if (key.startsWith(url)) {
        this.cache.delete(key);
      }
    }
  }
}

// Usage
const fetcher = new CachedFetcher();

async function loadUserProfile(userId) {
  try {
    const user = await fetcher.fetch(`/api/users/${userId}`);
    console.log('User loaded:', user);
    return user;
  } catch (error) {
    console.error('Failed to load user:', error);
    throw error;
  }
}

/**
 * Batch requests to avoid rate limits
 */
class BatchFetcher {
  constructor(batchSize = 5, delay = 100) {
    this.batchSize = batchSize;
    this.delay = delay;
  }

  async fetchAll(urls) {
    const results = [];

    // Process in batches
    for (let i = 0; i < urls.length; i += this.batchSize) {
      const batch = urls.slice(i, i + this.batchSize);

      console.log(`Processing batch ${i / this.batchSize + 1}...`);

      const batchResults = await Promise.all(
        batch.map(url => fetchWithRetry(url))
      );

      results.push(...batchResults);

      // Delay between batches (except for last batch)
      if (i + this.batchSize < urls.length) {
        await new Promise(resolve => setTimeout(resolve, this.delay));
      }
    }

    return results;
  }
}

// Usage: Fetch 100 user profiles in batches of 10
async function loadAllUserProfiles(userIds) {
  const urls = userIds.map(id => `/api/users/${id}`);
  const batcher = new BatchFetcher(10, 200);

  try {
    const users = await batcher.fetchAll(urls);
    console.log(`Loaded ${users.length} users`);
    return users;
  } catch (error) {
    console.error('Failed to load users:', error);
    throw error;
  }
}
```

**Key Concepts Demonstrated**:
- Async/await patterns
- Promise.all for parallel execution
- Retry logic with exponential backoff
- AbortController for timeouts
- Caching strategies
- Batch processing
- Error handling in async code

---

## State Management

### Example 3: Observable State Manager

**Use Case**: Centralized state management with subscriptions, similar to Redux or MobX.

```javascript
/**
 * Observable state manager with middleware support
 */
class StateManager {
  constructor(initialState = {}, options = {}) {
    this.state = initialState;
    this.listeners = new Set();
    this.middleware = [];
    this.history = options.enableHistory ? [initialState] : null;
    this.maxHistorySize = options.maxHistorySize || 50;
  }

  /**
   * Get current state (immutable copy)
   */
  getState() {
    return JSON.parse(JSON.stringify(this.state));
  }

  /**
   * Update state
   */
  setState(updates) {
    const prevState = this.getState();

    // Apply updates
    const nextState = typeof updates === 'function'
      ? updates(prevState)
      : { ...prevState, ...updates };

    // Run middleware
    let finalState = nextState;
    for (const mw of this.middleware) {
      finalState = mw(finalState, prevState);
    }

    // Update state
    this.state = finalState;

    // Add to history
    if (this.history) {
      this.history.push(finalState);
      if (this.history.length > this.maxHistorySize) {
        this.history.shift();
      }
    }

    // Notify listeners
    this.listeners.forEach(listener => {
      listener(finalState, prevState);
    });

    return finalState;
  }

  /**
   * Subscribe to state changes
   */
  subscribe(listener) {
    this.listeners.add(listener);

    // Return unsubscribe function
    return () => {
      this.listeners.delete(listener);
    };
  }

  /**
   * Add middleware
   */
  use(middleware) {
    this.middleware.push(middleware);
  }

  /**
   * Get state history
   */
  getHistory() {
    return this.history ? [...this.history] : null;
  }

  /**
   * Undo last change
   */
  undo() {
    if (!this.history || this.history.length <= 1) {
      return false;
    }

    this.history.pop(); // Remove current state
    const previousState = this.history[this.history.length - 1];
    this.state = previousState;

    // Notify listeners
    this.listeners.forEach(listener => {
      listener(this.state, previousState);
    });

    return true;
  }

  /**
   * Reset to initial state
   */
  reset() {
    const initialState = this.history ? this.history[0] : {};
    this.setState(initialState);
  }
}

// Example: Shopping cart state management
const cartStore = new StateManager(
  {
    items: [],
    total: 0,
    discount: 0,
    tax: 0
  },
  { enableHistory: true }
);

// Add logging middleware
cartStore.use((nextState, prevState) => {
  console.log('State changed:', {
    prev: prevState,
    next: nextState
  });
  return nextState;
});

// Add validation middleware
cartStore.use((nextState, prevState) => {
  if (nextState.total < 0) {
    console.error('Total cannot be negative');
    return prevState;
  }
  return nextState;
});

// Subscribe to changes
const unsubscribe = cartStore.subscribe((state, prevState) => {
  console.log('Cart updated:', state);
  updateCartUI(state);
});

// Actions
function addToCart(item) {
  cartStore.setState(state => {
    const existingItem = state.items.find(i => i.id === item.id);

    const items = existingItem
      ? state.items.map(i =>
          i.id === item.id
            ? { ...i, quantity: i.quantity + 1 }
            : i
        )
      : [...state.items, { ...item, quantity: 1 }];

    const total = items.reduce((sum, i) => sum + (i.price * i.quantity), 0);

    return {
      ...state,
      items,
      total: total - state.discount + state.tax
    };
  });
}

function removeFromCart(itemId) {
  cartStore.setState(state => {
    const items = state.items.filter(i => i.id !== itemId);
    const total = items.reduce((sum, i) => sum + (i.price * i.quantity), 0);

    return {
      ...state,
      items,
      total: total - state.discount + state.tax
    };
  });
}

function applyDiscount(discountAmount) {
  cartStore.setState(state => ({
    ...state,
    discount: discountAmount,
    total: state.items.reduce((sum, i) => sum + (i.price * i.quantity), 0)
           - discountAmount
           + state.tax
  }));
}

// Usage
addToCart({ id: 1, name: 'Product 1', price: 29.99 });
addToCart({ id: 2, name: 'Product 2', price: 49.99 });
applyDiscount(10);
removeFromCart(1);

// Undo last action
cartStore.undo();

// View history
console.log('State history:', cartStore.getHistory());

// Cleanup
unsubscribe();

function updateCartUI(state) {
  // Update UI with new state
  console.log('Updating UI with:', state);
}
```

**Key Concepts Demonstrated**:
- Class-based architecture
- Subscription pattern
- Immutability
- Middleware pattern
- State history and undo
- Functional updates

---

## Form Validation

### Example 4: Comprehensive Form Validator

**Use Case**: Validate complex forms with custom rules, async validation, and error messages.

```javascript
/**
 * Form validation system with custom rules and async support
 */
class FormValidator {
  constructor() {
    this.rules = this.createDefaultRules();
    this.customRules = new Map();
  }

  /**
   * Built-in validation rules
   */
  createDefaultRules() {
    return {
      required: {
        validate: value => {
          if (typeof value === 'string') {
            return value.trim().length > 0;
          }
          return value !== null && value !== undefined;
        },
        message: 'This field is required'
      },

      email: {
        validate: value => {
          const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
          return emailRegex.test(value);
        },
        message: 'Please enter a valid email address'
      },

      minLength: {
        validate: (value, min) => value.length >= min,
        message: (value, min) => `Must be at least ${min} characters`
      },

      maxLength: {
        validate: (value, max) => value.length <= max,
        message: (value, max) => `Must be no more than ${max} characters`
      },

      min: {
        validate: (value, min) => Number(value) >= min,
        message: (value, min) => `Must be at least ${min}`
      },

      max: {
        validate: (value, max) => Number(value) <= max,
        message: (value, max) => `Must be no more than ${max}`
      },

      pattern: {
        validate: (value, pattern) => new RegExp(pattern).test(value),
        message: 'Invalid format'
      },

      url: {
        validate: value => {
          try {
            new URL(value);
            return true;
          } catch {
            return false;
          }
        },
        message: 'Please enter a valid URL'
      },

      phone: {
        validate: value => {
          const phoneRegex = /^\+?[\d\s-()]{10,}$/;
          return phoneRegex.test(value);
        },
        message: 'Please enter a valid phone number'
      },

      match: {
        validate: (value, matchValue) => value === matchValue,
        message: 'Values do not match'
      }
    };
  }

  /**
   * Add custom validation rule
   */
  addRule(name, validateFn, message) {
    this.customRules.set(name, {
      validate: validateFn,
      message
    });
  }

  /**
   * Validate a single field
   */
  async validateField(value, rules) {
    const errors = [];

    for (const rule of rules) {
      let ruleName, ruleArg, customMessage;

      if (typeof rule === 'string') {
        ruleName = rule;
      } else if (typeof rule === 'object') {
        ruleName = rule.rule;
        ruleArg = rule.arg;
        customMessage = rule.message;
      }

      // Get rule definition
      const ruleDef = this.rules[ruleName] || this.customRules.get(ruleName);

      if (!ruleDef) {
        console.warn(`Unknown validation rule: ${ruleName}`);
        continue;
      }

      // Run validation
      const isValid = await ruleDef.validate(value, ruleArg);

      if (!isValid) {
        const message = customMessage ||
          (typeof ruleDef.message === 'function'
            ? ruleDef.message(value, ruleArg)
            : ruleDef.message);

        errors.push(message);
        break; // Stop at first error
      }
    }

    return errors;
  }

  /**
   * Validate entire form
   */
  async validate(formData, schema) {
    const errors = {};
    const validationPromises = [];

    for (const [field, rules] of Object.entries(schema)) {
      const value = formData[field];

      validationPromises.push(
        this.validateField(value, rules).then(fieldErrors => {
          if (fieldErrors.length > 0) {
            errors[field] = fieldErrors;
          }
        })
      );
    }

    await Promise.all(validationPromises);

    return {
      isValid: Object.keys(errors).length === 0,
      errors
    };
  }
}

// Create validator instance
const validator = new FormValidator();

// Add custom async rule (check if email is available)
validator.addRule(
  'emailAvailable',
  async (email) => {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 500));
    const takenEmails = ['taken@example.com', 'admin@example.com'];
    return !takenEmails.includes(email);
  },
  'This email is already registered'
);

// Add custom password strength rule
validator.addRule(
  'strongPassword',
  (password) => {
    const hasUpperCase = /[A-Z]/.test(password);
    const hasLowerCase = /[a-z]/.test(password);
    const hasNumbers = /\d/.test(password);
    const hasSpecialChar = /[!@#$%^&*]/.test(password);

    return hasUpperCase && hasLowerCase && hasNumbers && hasSpecialChar;
  },
  'Password must contain uppercase, lowercase, numbers, and special characters'
);

// Define validation schema
const registrationSchema = {
  username: [
    'required',
    { rule: 'minLength', arg: 3, message: 'Username too short' },
    { rule: 'maxLength', arg: 20 },
    { rule: 'pattern', arg: '^[a-zA-Z0-9_]+$', message: 'Only letters, numbers, and underscores allowed' }
  ],
  email: [
    'required',
    'email',
    'emailAvailable' // Async validation
  ],
  password: [
    'required',
    { rule: 'minLength', arg: 8 },
    'strongPassword'
  ],
  confirmPassword: [
    'required'
    // Match validation handled separately
  ],
  age: [
    'required',
    { rule: 'min', arg: 18, message: 'Must be at least 18 years old' },
    { rule: 'max', arg: 120 }
  ],
  website: [
    'url'
  ],
  phone: [
    'phone'
  ]
};

// Validate form
async function handleRegistration(formData) {
  // Add password match validation
  if (formData.password !== formData.confirmPassword) {
    return {
      isValid: false,
      errors: {
        confirmPassword: ['Passwords do not match']
      }
    };
  }

  const result = await validator.validate(formData, registrationSchema);

  if (result.isValid) {
    console.log('Form is valid! Submitting...', formData);
    // Submit form
  } else {
    console.log('Form has errors:', result.errors);
    // Display errors
    displayErrors(result.errors);
  }

  return result;
}

// Test the validator
async function testValidation() {
  const testData = {
    username: 'john_doe',
    email: 'john@example.com',
    password: 'SecurePass123!',
    confirmPassword: 'SecurePass123!',
    age: '25',
    website: 'https://johndoe.com',
    phone: '+1-555-123-4567'
  };

  const result = await handleRegistration(testData);
  console.log('Validation result:', result);
}

function displayErrors(errors) {
  for (const [field, messages] of Object.entries(errors)) {
    console.error(`${field}: ${messages.join(', ')}`);
  }
}

// Run test
testValidation();
```

**Key Concepts Demonstrated**:
- Class-based validation system
- Async validation
- Custom rules
- Schema-based validation
- Error message generation
- Promise.all for parallel validation

---

## Event Handling

### Example 5: Custom Event Emitter with Advanced Features

**Use Case**: Event system for component communication with namespaces, wildcards, and once handlers.

```javascript
/**
 * Advanced event emitter with namespaces and wildcards
 */
class EventEmitter {
  constructor() {
    this.events = new Map();
    this.onceEvents = new Set();
    this.maxListeners = 10;
  }

  /**
   * Add event listener
   */
  on(event, listener, priority = 0) {
    if (!this.events.has(event)) {
      this.events.set(event, []);
    }

    const listeners = this.events.get(event);

    // Check max listeners
    if (listeners.length >= this.maxListeners) {
      console.warn(`Max listeners (${this.maxListeners}) exceeded for event: ${event}`);
    }

    // Add listener with priority
    listeners.push({ listener, priority });

    // Sort by priority (higher first)
    listeners.sort((a, b) => b.priority - a.priority);

    return this;
  }

  /**
   * Add one-time listener
   */
  once(event, listener) {
    const onceWrapper = (...args) => {
      listener(...args);
      this.off(event, onceWrapper);
    };

    this.onceEvents.add(onceWrapper);
    this.on(event, onceWrapper);

    return this;
  }

  /**
   * Remove listener
   */
  off(event, listenerToRemove) {
    if (!this.events.has(event)) {
      return this;
    }

    const listeners = this.events.get(event);
    const filtered = listeners.filter(
      ({ listener }) => listener !== listenerToRemove
    );

    if (filtered.length === 0) {
      this.events.delete(event);
    } else {
      this.events.set(event, filtered);
    }

    this.onceEvents.delete(listenerToRemove);

    return this;
  }

  /**
   * Emit event
   */
  emit(event, ...args) {
    const listeners = this.events.get(event);

    if (!listeners || listeners.length === 0) {
      return false;
    }

    listeners.forEach(({ listener }) => {
      try {
        listener(...args);
      } catch (error) {
        console.error(`Error in event listener for "${event}":`, error);
      }
    });

    return true;
  }

  /**
   * Emit event with wildcard support
   */
  emitPattern(pattern, ...args) {
    const regex = new RegExp(
      '^' + pattern.replace(/\*/g, '.*').replace(/\?/g, '.') + '$'
    );

    let emitted = false;

    for (const [event] of this.events) {
      if (regex.test(event)) {
        this.emit(event, ...args);
        emitted = true;
      }
    }

    return emitted;
  }

  /**
   * Remove all listeners for event or all events
   */
  removeAllListeners(event) {
    if (event) {
      this.events.delete(event);
    } else {
      this.events.clear();
      this.onceEvents.clear();
    }

    return this;
  }

  /**
   * Get listener count
   */
  listenerCount(event) {
    const listeners = this.events.get(event);
    return listeners ? listeners.length : 0;
  }

  /**
   * Get all event names
   */
  eventNames() {
    return Array.from(this.events.keys());
  }

  /**
   * Set max listeners
   */
  setMaxListeners(n) {
    this.maxListeners = n;
    return this;
  }
}

// Example: Application event bus
const appEvents = new EventEmitter();

// User events
appEvents.on('user:login', (user) => {
  console.log('User logged in:', user.name);
  // Update UI, analytics, etc.
});

appEvents.on('user:logout', () => {
  console.log('User logged out');
  // Clear session, redirect, etc.
});

appEvents.on('user:update', (user) => {
  console.log('User updated:', user);
  // Refresh UI
});

// Priority listeners (higher priority runs first)
appEvents.on('data:save', () => {
  console.log('Validating data...'); // Default priority: 0
});

appEvents.on('data:save', () => {
  console.log('Preparing data...'); // Runs first (priority: 10)
}, 10);

appEvents.on('data:save', () => {
  console.log('Saving to server...'); // Runs last (priority: -10)
}, -10);

// One-time listener
appEvents.once('app:initialized', () => {
  console.log('App initialized (this will only run once)');
});

// Wildcard pattern listeners
appEvents.on('api:*', (endpoint, data) => {
  console.log(`API call to ${endpoint}:`, data);
});

// Emit events
appEvents.emit('user:login', { id: 1, name: 'John Doe' });
appEvents.emit('data:save');
appEvents.emit('app:initialized');
appEvents.emit('app:initialized'); // Won't trigger (once listener)

// Emit with pattern
appEvents.emitPattern('api:*', '/users', { method: 'GET' });
appEvents.emit('api:users', '/users', { method: 'GET' });

// Check listener count
console.log('user:login listeners:', appEvents.listenerCount('user:login'));

// Remove specific listener
const updateHandler = (user) => console.log('Update:', user);
appEvents.on('user:update', updateHandler);
appEvents.off('user:update', updateHandler);

// Remove all listeners for event
appEvents.removeAllListeners('user:login');

/**
 * Example: Component event system
 */
class Component extends EventEmitter {
  constructor(name) {
    super();
    this.name = name;
    this.state = {};
  }

  setState(updates) {
    const prevState = { ...this.state };
    this.state = { ...this.state, ...updates };

    this.emit('stateChange', this.state, prevState);

    // Emit specific property changes
    for (const key of Object.keys(updates)) {
      this.emit(`change:${key}`, updates[key], prevState[key]);
    }
  }

  destroy() {
    this.emit('destroy');
    this.removeAllListeners();
  }
}

// Usage
const userComponent = new Component('UserProfile');

userComponent.on('stateChange', (newState, oldState) => {
  console.log('State changed:', { old: oldState, new: newState });
});

userComponent.on('change:name', (newName, oldName) => {
  console.log(`Name changed from "${oldName}" to "${newName}"`);
});

userComponent.setState({ name: 'John', age: 30 });
userComponent.setState({ name: 'Jane' });
```

**Key Concepts Demonstrated**:
- Event-driven architecture
- Observer pattern
- Priority queues
- Wildcard matching
- Error handling in callbacks
- Component lifecycle events

---

## Caching and Memoization

### Example 6: Advanced Memoization with TTL and Cache Strategies

**Use Case**: Optimize expensive function calls with intelligent caching.

```javascript
/**
 * Memoization with Time-To-Live and cache strategies
 */
class Memoizer {
  constructor(options = {}) {
    this.cache = new Map();
    this.ttl = options.ttl || null; // Time to live in milliseconds
    this.maxSize = options.maxSize || Infinity;
    this.strategy = options.strategy || 'LRU'; // LRU or LFU
    this.accessCount = new Map(); // For LFU strategy
    this.accessOrder = []; // For LRU strategy
  }

  /**
   * Generate cache key
   */
  generateKey(args) {
    return JSON.stringify(args);
  }

  /**
   * Check if cache entry is valid
   */
  isValid(entry) {
    if (!this.ttl) return true;
    return Date.now() - entry.timestamp < this.ttl;
  }

  /**
   * Evict entries based on strategy
   */
  evict() {
    if (this.cache.size < this.maxSize) return;

    if (this.strategy === 'LRU') {
      // Remove least recently used
      const keyToRemove = this.accessOrder.shift();
      this.cache.delete(keyToRemove);
    } else if (this.strategy === 'LFU') {
      // Remove least frequently used
      let minCount = Infinity;
      let keyToRemove = null;

      for (const [key, count] of this.accessCount) {
        if (count < minCount) {
          minCount = count;
          keyToRemove = key;
        }
      }

      this.cache.delete(keyToRemove);
      this.accessCount.delete(keyToRemove);
    }
  }

  /**
   * Update access tracking
   */
  trackAccess(key) {
    if (this.strategy === 'LRU') {
      // Move to end (most recently used)
      const index = this.accessOrder.indexOf(key);
      if (index > -1) {
        this.accessOrder.splice(index, 1);
      }
      this.accessOrder.push(key);
    } else if (this.strategy === 'LFU') {
      // Increment access count
      this.accessCount.set(key, (this.accessCount.get(key) || 0) + 1);
    }
  }

  /**
   * Memoize a function
   */
  memoize(fn) {
    return (...args) => {
      const key = this.generateKey(args);
      const cached = this.cache.get(key);

      // Return cached value if valid
      if (cached && this.isValid(cached)) {
        console.log('Cache hit for:', args);
        this.trackAccess(key);
        return cached.value;
      }

      // Calculate new value
      console.log('Cache miss for:', args);
      const value = fn(...args);

      // Evict if necessary
      this.evict();

      // Cache new value
      this.cache.set(key, {
        value,
        timestamp: Date.now()
      });

      this.trackAccess(key);

      return value;
    };
  }

  /**
   * Clear cache
   */
  clear() {
    this.cache.clear();
    this.accessCount.clear();
    this.accessOrder = [];
  }

  /**
   * Get cache statistics
   */
  getStats() {
    return {
      size: this.cache.size,
      maxSize: this.maxSize,
      strategy: this.strategy,
      ttl: this.ttl,
      entries: Array.from(this.cache.entries()).map(([key, entry]) => ({
        key,
        age: Date.now() - entry.timestamp,
        accessCount: this.accessCount.get(key) || 0
      }))
    };
  }
}

// Example 1: Fibonacci with memoization
const fibMemoizer = new Memoizer({ strategy: 'LRU', maxSize: 100 });

const fibonacci = fibMemoizer.memoize((n) => {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
});

console.log(fibonacci(40)); // Fast with memoization
console.log(fibonacci(40)); // Instant (cached)

// Example 2: API calls with TTL
const apiMemoizer = new Memoizer({
  ttl: 5 * 60 * 1000, // 5 minutes
  maxSize: 50,
  strategy: 'LFU'
});

const fetchUser = apiMemoizer.memoize(async (userId) => {
  console.log(`Fetching user ${userId} from API...`);
  const response = await fetch(`/api/users/${userId}`);
  return response.json();
});

// First call - fetches from API
await fetchUser(1);

// Second call within TTL - returns cached
await fetchUser(1);

// After TTL expires - fetches again
setTimeout(async () => {
  await fetchUser(1);
}, 5 * 60 * 1000 + 100);

// Example 3: Expensive calculations with per-function memoization
function createMemoizedCalculator() {
  const memoizer = new Memoizer({ maxSize: 1000 });

  return {
    // Expensive prime check
    isPrime: memoizer.memoize((n) => {
      if (n <= 1) return false;
      if (n <= 3) return true;
      if (n % 2 === 0 || n % 3 === 0) return false;

      for (let i = 5; i * i <= n; i += 6) {
        if (n % i === 0 || n % (i + 2) === 0) return false;
      }

      return true;
    }),

    // Expensive factorial
    factorial: memoizer.memoize((n) => {
      if (n <= 1) return 1;
      return n * calculator.factorial(n - 1);
    }),

    // Get cache stats
    getStats: () => memoizer.getStats()
  };
}

const calculator = createMemoizedCalculator();

console.log(calculator.isPrime(97)); // Slow first time
console.log(calculator.isPrime(97)); // Instant (cached)

console.log(calculator.factorial(20)); // Calculates and caches all factorials up to 20
console.log(calculator.factorial(25)); // Only needs to calculate 21-25

console.log('Cache stats:', calculator.getStats());

/**
 * Simple decorator-based memoization
 */
function memoize(fn, options = {}) {
  const cache = new Map();
  const ttl = options.ttl || null;

  return function(...args) {
    const key = JSON.stringify(args);
    const cached = cache.get(key);

    if (cached) {
      if (!ttl || Date.now() - cached.timestamp < ttl) {
        return cached.value;
      }
    }

    const value = fn.apply(this, args);
    cache.set(key, { value, timestamp: Date.now() });
    return value;
  };
}

// Usage
const expensiveOperation = memoize((x, y) => {
  console.log('Computing...');
  return x ** y;
}, { ttl: 60000 }); // 1 minute TTL

console.log(expensiveOperation(2, 10)); // Computing... 1024
console.log(expensiveOperation(2, 10)); // 1024 (cached)
```

**Key Concepts Demonstrated**:
- Memoization techniques
- Cache eviction strategies (LRU, LFU)
- TTL (Time To Live) implementation
- Performance optimization
- Map and Set data structures
- Decorator pattern

---

## API Client

### Example 7: Robust API Client with Interceptors

**Use Case**: Production-ready API client with authentication, retries, and request/response interceptors.

```javascript
/**
 * Advanced API client with interceptors and retry logic
 */
class ApiClient {
  constructor(baseURL, options = {}) {
    this.baseURL = baseURL;
    this.defaultHeaders = options.headers || {};
    this.timeout = options.timeout || 30000;
    this.retries = options.retries || 3;
    this.retryDelay = options.retryDelay || 1000;

    // Interceptors
    this.requestInterceptors = [];
    this.responseInterceptors = [];
    this.errorInterceptors = [];
  }

  /**
   * Add request interceptor
   */
  useRequestInterceptor(interceptor) {
    this.requestInterceptors.push(interceptor);
    return this;
  }

  /**
   * Add response interceptor
   */
  useResponseInterceptor(interceptor) {
    this.responseInterceptors.push(interceptor);
    return this;
  }

  /**
   * Add error interceptor
   */
  useErrorInterceptor(interceptor) {
    this.errorInterceptors.push(interceptor);
    return this;
  }

  /**
   * Build full URL
   */
  buildURL(endpoint, params) {
    const url = new URL(endpoint, this.baseURL);

    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          url.searchParams.append(key, value);
        }
      });
    }

    return url.toString();
  }

  /**
   * Apply request interceptors
   */
  async applyRequestInterceptors(config) {
    let modifiedConfig = { ...config };

    for (const interceptor of this.requestInterceptors) {
      modifiedConfig = await interceptor(modifiedConfig);
    }

    return modifiedConfig;
  }

  /**
   * Apply response interceptors
   */
  async applyResponseInterceptors(response) {
    let modifiedResponse = response;

    for (const interceptor of this.responseInterceptors) {
      modifiedResponse = await interceptor(modifiedResponse);
    }

    return modifiedResponse;
  }

  /**
   * Apply error interceptors
   */
  async applyErrorInterceptors(error) {
    let modifiedError = error;

    for (const interceptor of this.errorInterceptors) {
      modifiedError = await interceptor(modifiedError);
    }

    return modifiedError;
  }

  /**
   * Make HTTP request with retry logic
   */
  async request(endpoint, options = {}) {
    const {
      method = 'GET',
      params,
      data,
      headers = {},
      timeout = this.timeout,
      retries = this.retries
    } = options;

    const url = this.buildURL(endpoint, params);

    // Apply request interceptors
    const config = await this.applyRequestInterceptors({
      url,
      method,
      headers: { ...this.defaultHeaders, ...headers },
      body: data ? JSON.stringify(data) : undefined
    });

    // Retry logic
    for (let attempt = 0; attempt < retries; attempt++) {
      try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), timeout);

        const response = await fetch(config.url, {
          method: config.method,
          headers: config.headers,
          body: config.body,
          signal: controller.signal
        });

        clearTimeout(timeoutId);

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        // Parse response
        const contentType = response.headers.get('content-type');
        let responseData;

        if (contentType && contentType.includes('application/json')) {
          responseData = await response.json();
        } else {
          responseData = await response.text();
        }

        // Apply response interceptors
        const finalResponse = await this.applyResponseInterceptors({
          data: responseData,
          status: response.status,
          statusText: response.statusText,
          headers: response.headers,
          config
        });

        return finalResponse.data;

      } catch (error) {
        const isLastAttempt = attempt === retries - 1;

        if (isLastAttempt) {
          // Apply error interceptors
          const modifiedError = await this.applyErrorInterceptors(error);
          throw modifiedError;
        }

        // Wait before retry (exponential backoff)
        const delay = this.retryDelay * Math.pow(2, attempt);
        console.log(`Attempt ${attempt + 1} failed. Retrying in ${delay}ms...`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }

  /**
   * Convenience methods
   */
  get(endpoint, options = {}) {
    return this.request(endpoint, { ...options, method: 'GET' });
  }

  post(endpoint, data, options = {}) {
    return this.request(endpoint, { ...options, method: 'POST', data });
  }

  put(endpoint, data, options = {}) {
    return this.request(endpoint, { ...options, method: 'PUT', data });
  }

  patch(endpoint, data, options = {}) {
    return this.request(endpoint, { ...options, method: 'PATCH', data });
  }

  delete(endpoint, options = {}) {
    return this.request(endpoint, { ...options, method: 'DELETE' });
  }
}

// Create API client
const api = new ApiClient('https://api.example.com', {
  timeout: 10000,
  retries: 3,
  headers: {
    'Content-Type': 'application/json'
  }
});

// Add authentication interceptor
api.useRequestInterceptor(async (config) => {
  const token = localStorage.getItem('authToken');

  if (token) {
    config.headers['Authorization'] = `Bearer ${token}`;
  }

  console.log('Request:', config.method, config.url);
  return config;
});

// Add response logging interceptor
api.useResponseInterceptor(async (response) => {
  console.log('Response:', response.status, response.data);
  return response;
});

// Add error handling interceptor
api.useErrorInterceptor(async (error) => {
  console.error('Request failed:', error.message);

  if (error.message.includes('HTTP 401')) {
    // Handle unauthorized - refresh token or redirect to login
    console.log('Unauthorized - redirecting to login');
    // redirectToLogin();
  }

  return error;
});

// Usage examples
async function exampleUsage() {
  try {
    // GET request
    const users = await api.get('/users', {
      params: { page: 1, limit: 10 }
    });
    console.log('Users:', users);

    // POST request
    const newUser = await api.post('/users', {
      name: 'John Doe',
      email: 'john@example.com'
    });
    console.log('Created user:', newUser);

    // PUT request
    const updatedUser = await api.put('/users/1', {
      name: 'Jane Doe'
    });
    console.log('Updated user:', updatedUser);

    // DELETE request
    await api.delete('/users/1');
    console.log('User deleted');

  } catch (error) {
    console.error('API call failed:', error);
  }
}

exampleUsage();
```

**Key Concepts Demonstrated**:
- HTTP client implementation
- Interceptor pattern
- Retry logic with exponential backoff
- AbortController for timeouts
- Promise chaining
- Error handling
- URL building and query parameters

---

## Observer Pattern

### Example 8: Reactive Data System

**Use Case**: Build a reactive system where UI components automatically update when data changes.

```javascript
/**
 * Reactive observable system
 */
class Observable {
  constructor(value) {
    this._value = value;
    this._observers = new Set();
  }

  get value() {
    return this._value;
  }

  set value(newValue) {
    if (this._value !== newValue) {
      const oldValue = this._value;
      this._value = newValue;
      this.notify(newValue, oldValue);
    }
  }

  subscribe(observer) {
    this._observers.add(observer);

    // Return unsubscribe function
    return () => this._observers.delete(observer);
  }

  notify(newValue, oldValue) {
    this._observers.forEach(observer => {
      observer(newValue, oldValue);
    });
  }
}

/**
 * Computed observable (derives value from other observables)
 */
class Computed {
  constructor(computeFn, dependencies = []) {
    this.computeFn = computeFn;
    this.dependencies = dependencies;
    this._observers = new Set();
    this._value = this.compute();

    // Subscribe to dependencies
    dependencies.forEach(dep => {
      dep.subscribe(() => {
        const oldValue = this._value;
        this._value = this.compute();
        this.notify(this._value, oldValue);
      });
    });
  }

  get value() {
    return this._value;
  }

  compute() {
    return this.computeFn();
  }

  subscribe(observer) {
    this._observers.add(observer);
    return () => this._observers.delete(observer);
  }

  notify(newValue, oldValue) {
    this._observers.forEach(observer => {
      observer(newValue, oldValue);
    });
  }
}

// Example: Shopping cart with reactive totals
const cartItems = new Observable([]);
const taxRate = new Observable(0.1);
const discountCode = new Observable(null);

// Computed values
const subtotal = new Computed(() => {
  return cartItems.value.reduce((sum, item) => sum + (item.price * item.quantity), 0);
}, [cartItems]);

const discount = new Computed(() => {
  const code = discountCode.value;
  if (!code) return 0;

  const discounts = {
    'SAVE10': 0.10,
    'SAVE20': 0.20,
    'WELCOME': 0.15
  };

  return subtotal.value * (discounts[code] || 0);
}, [subtotal, discountCode]);

const tax = new Computed(() => {
  return (subtotal.value - discount.value) * taxRate.value;
}, [subtotal, discount, taxRate]);

const total = new Computed(() => {
  return subtotal.value - discount.value + tax.value;
}, [subtotal, discount, tax]);

// Subscribe to changes
subtotal.subscribe((newValue, oldValue) => {
  console.log(`Subtotal: $${oldValue.toFixed(2)} -> $${newValue.toFixed(2)}`);
});

total.subscribe((newValue, oldValue) => {
  console.log(`Total: $${oldValue.toFixed(2)} -> $${newValue.toFixed(2)}`);
  updateCartUI(newValue);
});

// Cart operations
function addItem(item) {
  cartItems.value = [...cartItems.value, { ...item, quantity: 1 }];
}

function removeItem(itemId) {
  cartItems.value = cartItems.value.filter(item => item.id !== itemId);
}

function updateQuantity(itemId, quantity) {
  cartItems.value = cartItems.value.map(item =>
    item.id === itemId ? { ...item, quantity } : item
  );
}

function applyDiscount(code) {
  discountCode.value = code;
}

function updateCartUI(total) {
  console.log(`Updating UI - Total: $${total.toFixed(2)}`);
}

// Test the reactive system
addItem({ id: 1, name: 'Product 1', price: 29.99 });
addItem({ id: 2, name: 'Product 2', price: 49.99 });
updateQuantity(1, 2);
applyDiscount('SAVE20');
removeItem(2);

/**
 * Example 2: Reactive form validation
 */
class ReactiveForm {
  constructor(schema) {
    this.schema = schema;
    this.fields = {};
    this.errors = {};

    // Create observables for each field
    for (const fieldName of Object.keys(schema)) {
      this.fields[fieldName] = new Observable('');
      this.errors[fieldName] = new Observable([]);

      // Validate on change
      this.fields[fieldName].subscribe((value) => {
        this.validateField(fieldName, value);
      });
    }

    // Computed: overall form validity
    this.isValid = new Computed(() => {
      return Object.values(this.errors).every(error => error.value.length === 0);
    }, Object.values(this.errors));
  }

  validateField(fieldName, value) {
    const rules = this.schema[fieldName];
    const errors = [];

    for (const rule of rules) {
      const isValid = rule.validate(value);
      if (!isValid) {
        errors.push(rule.message);
        break; // Stop at first error
      }
    }

    this.errors[fieldName].value = errors;
  }

  setValue(fieldName, value) {
    if (this.fields[fieldName]) {
      this.fields[fieldName].value = value;
    }
  }

  getValue(fieldName) {
    return this.fields[fieldName]?.value;
  }

  getValues() {
    const values = {};
    for (const [fieldName, observable] of Object.entries(this.fields)) {
      values[fieldName] = observable.value;
    }
    return values;
  }
}

// Define validation rules
const loginForm = new ReactiveForm({
  email: [
    {
      validate: (value) => value.length > 0,
      message: 'Email is required'
    },
    {
      validate: (value) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value),
      message: 'Invalid email format'
    }
  ],
  password: [
    {
      validate: (value) => value.length > 0,
      message: 'Password is required'
    },
    {
      validate: (value) => value.length >= 8,
      message: 'Password must be at least 8 characters'
    }
  ]
});

// Subscribe to validation errors
loginForm.errors.email.subscribe((errors) => {
  console.log('Email errors:', errors);
});

loginForm.isValid.subscribe((valid) => {
  console.log('Form is valid:', valid);
});

// Simulate user input
loginForm.setValue('email', 'test');
loginForm.setValue('email', 'test@example.com');
loginForm.setValue('password', '12345');
loginForm.setValue('password', '12345678');
```

**Key Concepts Demonstrated**:
- Observer pattern
- Reactive programming
- Computed values
- Dependency tracking
- Subscription management
- Form validation

---

## Debouncing and Throttling

### Example 9: Performance Optimization Utilities

**Use Case**: Optimize high-frequency events like scroll, resize, and user input.

```javascript
/**
 * Advanced debounce implementation with leading/trailing edge
 */
function debounce(fn, delay, options = {}) {
  let timeoutId;
  let lastCallTime = 0;
  const leading = options.leading || false;
  const trailing = options.trailing !== false; // Default true
  const maxWait = options.maxWait;

  function debounced(...args) {
    const now = Date.now();
    const timeSinceLastCall = now - lastCallTime;

    // Clear existing timeout
    if (timeoutId) {
      clearTimeout(timeoutId);
    }

    // Leading edge
    if (leading && timeSinceLastCall > delay) {
      lastCallTime = now;
      return fn.apply(this, args);
    }

    // Set new timeout for trailing edge
    if (trailing) {
      timeoutId = setTimeout(() => {
        lastCallTime = Date.now();
        fn.apply(this, args);
      }, delay);
    }

    // MaxWait - ensure function runs at least once per maxWait period
    if (maxWait && timeSinceLastCall >= maxWait) {
      lastCallTime = now;
      if (timeoutId) {
        clearTimeout(timeoutId);
      }
      return fn.apply(this, args);
    }
  }

  debounced.cancel = function() {
    if (timeoutId) {
      clearTimeout(timeoutId);
      timeoutId = null;
    }
  };

  debounced.flush = function() {
    if (timeoutId) {
      clearTimeout(timeoutId);
      fn.apply(this, arguments);
    }
  };

  return debounced;
}

/**
 * Advanced throttle implementation
 */
function throttle(fn, limit, options = {}) {
  let inThrottle;
  let lastFn;
  let lastRan;
  const leading = options.leading !== false; // Default true
  const trailing = options.trailing !== false; // Default true

  function throttled(...args) {
    if (!inThrottle) {
      if (leading) {
        fn.apply(this, args);
      }
      lastRan = Date.now();
      inThrottle = true;

      setTimeout(() => {
        inThrottle = false;
        if (trailing && lastFn) {
          throttled.apply(this, lastFn);
          lastFn = null;
        }
      }, limit);
    } else {
      lastFn = args;
    }
  }

  throttled.cancel = function() {
    inThrottle = false;
    lastFn = null;
  };

  return throttled;
}

/**
 * Request Animation Frame throttle (for smooth animations)
 */
function rafThrottle(fn) {
  let rafId = null;
  let lastArgs;

  function throttled(...args) {
    lastArgs = args;

    if (!rafId) {
      rafId = requestAnimationFrame(() => {
        fn.apply(this, lastArgs);
        rafId = null;
      });
    }
  }

  throttled.cancel = function() {
    if (rafId) {
      cancelAnimationFrame(rafId);
      rafId = null;
    }
  };

  return throttled;
}

// Example 1: Search with debounce
const searchAPI = async (query) => {
  console.log('Searching for:', query);
  // Simulate API call
  await new Promise(resolve => setTimeout(resolve, 500));
  return [`Result 1 for ${query}`, `Result 2 for ${query}`];
};

const debouncedSearch = debounce(async (query) => {
  const results = await searchAPI(query);
  console.log('Search results:', results);
}, 300);

// Simulate rapid typing
console.log('--- Debounced Search ---');
debouncedSearch('j');
debouncedSearch('ja');
debouncedSearch('jav');
debouncedSearch('java');
debouncedSearch('javasc');
debouncedSearch('javascript');
// Only the last call ('javascript') will execute after 300ms

// Example 2: Scroll tracking with throttle
let scrollCount = 0;

const trackScroll = () => {
  scrollCount++;
  console.log('Scroll position:', window.scrollY, `(call #${scrollCount})`);
  // Update UI, lazy load images, etc.
};

const throttledScroll = throttle(trackScroll, 100);

// Simulate scroll events
console.log('\n--- Throttled Scroll ---');
for (let i = 0; i < 20; i++) {
  setTimeout(() => throttledScroll(), i * 10);
}
// Will execute approximately every 100ms instead of 20 times

// Example 3: Window resize with RAF throttle
const handleResize = () => {
  console.log('Window resized:', window.innerWidth, 'x', window.innerHeight);
  // Recalculate layout, reposition elements, etc.
};

const rafThrottledResize = rafThrottle(handleResize);

window.addEventListener('resize', rafThrottledResize);

// Example 4: Form autosave with debounce and maxWait
const saveForm = (data) => {
  console.log('Saving form data:', data);
  // API call to save data
};

const autoSave = debounce(saveForm, 2000, {
  leading: false,
  trailing: true,
  maxWait: 10000 // Force save every 10 seconds
});

// Simulate user typing
let formData = '';
const typeInterval = setInterval(() => {
  formData += 'x';
  autoSave(formData);

  if (formData.length >= 50) {
    clearInterval(typeInterval);
  }
}, 100);

// Will save after user stops typing for 2s, but at least every 10s

/**
 * Example 5: Button click protection
 */
function createProtectedButton(handler, delay = 1000) {
  let lastClick = 0;

  return function(...args) {
    const now = Date.now();

    if (now - lastClick >= delay) {
      lastClick = now;
      return handler.apply(this, args);
    } else {
      console.log('Please wait before clicking again');
    }
  };
}

const submitForm = (data) => {
  console.log('Submitting form:', data);
  // API call
};

const protectedSubmit = createProtectedButton(submitForm, 2000);

// Rapid clicks
protectedSubmit({ name: 'John' });
setTimeout(() => protectedSubmit({ name: 'John' }), 500);  // Blocked
setTimeout(() => protectedSubmit({ name: 'John' }), 1000); // Blocked
setTimeout(() => protectedSubmit({ name: 'John' }), 2100); // Allowed

/**
 * Example 6: Network request batching
 */
class RequestBatcher {
  constructor(batchFn, delay = 50) {
    this.batchFn = batchFn;
    this.delay = delay;
    this.queue = [];
    this.timeoutId = null;
  }

  add(request) {
    return new Promise((resolve, reject) => {
      this.queue.push({ request, resolve, reject });

      if (this.timeoutId) {
        clearTimeout(this.timeoutId);
      }

      this.timeoutId = setTimeout(() => {
        this.flush();
      }, this.delay);
    });
  }

  async flush() {
    if (this.queue.length === 0) return;

    const batch = this.queue.splice(0);
    const requests = batch.map(item => item.request);

    try {
      const results = await this.batchFn(requests);

      batch.forEach((item, index) => {
        item.resolve(results[index]);
      });
    } catch (error) {
      batch.forEach(item => {
        item.reject(error);
      });
    }
  }
}

// Usage: Batch user data requests
const batchFetchUsers = async (userIds) => {
  console.log('Fetching users in batch:', userIds);
  // Single API call for multiple users
  return userIds.map(id => ({ id, name: `User ${id}` }));
};

const userBatcher = new RequestBatcher(batchFetchUsers, 100);

// Multiple calls get batched
async function loadUserData() {
  const [user1, user2, user3] = await Promise.all([
    userBatcher.add(1),
    userBatcher.add(2),
    userBatcher.add(3)
  ]);

  console.log('Users loaded:', user1, user2, user3);
}

loadUserData();
```

**Key Concepts Demonstrated**:
- Debounce implementation
- Throttle implementation
- RequestAnimationFrame optimization
- Leading/trailing edge options
- MaxWait guarantees
- Request batching
- Performance optimization techniques

---

## Error Handling

### Example 10: Robust Error Handling System

**Use Case**: Production-ready error handling with logging, retries, and user-friendly messages.

```javascript
/**
 * Custom error classes
 */
class AppError extends Error {
  constructor(message, statusCode = 500, isOperational = true) {
    super(message);
    this.name = this.constructor.name;
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.timestamp = new Date().toISOString();

    Error.captureStackTrace(this, this.constructor);
  }
}

class ValidationError extends AppError {
  constructor(message, field = null) {
    super(message, 400);
    this.field = field;
    this.errors = [];
  }

  addError(field, message) {
    this.errors.push({ field, message });
  }
}

class AuthenticationError extends AppError {
  constructor(message = 'Authentication required') {
    super(message, 401);
  }
}

class AuthorizationError extends AppError {
  constructor(message = 'Insufficient permissions') {
    super(message, 403);
  }
}

class NotFoundError extends AppError {
  constructor(resource = 'Resource') {
    super(`${resource} not found`, 404);
    this.resource = resource;
  }
}

class NetworkError extends AppError {
  constructor(message = 'Network request failed', originalError = null) {
    super(message, 0);
    this.originalError = originalError;
  }
}

/**
 * Error handler with logging and recovery
 */
class ErrorHandler {
  constructor(options = {}) {
    this.logger = options.logger || console;
    this.errorListeners = new Set();
    this.errorCounts = new Map();
    this.maxErrorCount = options.maxErrorCount || 10;
    this.errorWindow = options.errorWindow || 60000; // 1 minute
  }

  /**
   * Handle error with appropriate action
   */
  handle(error, context = {}) {
    // Track error frequency
    this.trackError(error);

    // Log error
    this.log(error, context);

    // Notify listeners
    this.notify(error, context);

    // Determine if error is recoverable
    if (error.isOperational) {
      return this.handleOperationalError(error, context);
    } else {
      return this.handleProgrammerError(error, context);
    }
  }

  /**
   * Track error frequency
   */
  trackError(error) {
    const key = `${error.name}:${error.message}`;
    const now = Date.now();

    if (!this.errorCounts.has(key)) {
      this.errorCounts.set(key, []);
    }

    const timestamps = this.errorCounts.get(key);
    timestamps.push(now);

    // Remove old timestamps
    const cutoff = now - this.errorWindow;
    const filtered = timestamps.filter(ts => ts > cutoff);
    this.errorCounts.set(key, filtered);

    // Check if error threshold exceeded
    if (filtered.length >= this.maxErrorCount) {
      this.logger.error(
        `Error threshold exceeded for: ${key} (${filtered.length} in ${this.errorWindow}ms)`
      );
    }
  }

  /**
   * Log error with context
   */
  log(error, context) {
    const logData = {
      name: error.name,
      message: error.message,
      statusCode: error.statusCode,
      timestamp: error.timestamp || new Date().toISOString(),
      stack: error.stack,
      context,
      isOperational: error.isOperational
    };

    if (error.statusCode >= 500) {
      this.logger.error('Server Error:', logData);
    } else if (error.statusCode >= 400) {
      this.logger.warn('Client Error:', logData);
    } else {
      this.logger.info('Error:', logData);
    }
  }

  /**
   * Handle operational errors (expected, recoverable)
   */
  handleOperationalError(error, context) {
    return {
      success: false,
      error: {
        message: this.getUserFriendlyMessage(error),
        code: error.statusCode,
        field: error.field,
        errors: error.errors
      }
    };
  }

  /**
   * Handle programmer errors (unexpected, not recoverable)
   */
  handleProgrammerError(error, context) {
    this.logger.error('CRITICAL: Programmer error detected', {
      error,
      context
    });

    // In production, you might want to:
    // 1. Send alert to monitoring service
    // 2. Gracefully shut down the process
    // 3. Let process manager restart the app

    return {
      success: false,
      error: {
        message: 'An unexpected error occurred',
        code: 500
      }
    };
  }

  /**
   * Get user-friendly error message
   */
  getUserFriendlyMessage(error) {
    const messages = {
      ValidationError: 'Please check your input and try again',
      AuthenticationError: 'Please sign in to continue',
      AuthorizationError: "You don't have permission to perform this action",
      NotFoundError: `${error.resource} could not be found`,
      NetworkError: 'Unable to connect. Please check your internet connection',
      default: 'An error occurred. Please try again'
    };

    return error.message || messages[error.name] || messages.default;
  }

  /**
   * Subscribe to errors
   */
  onError(listener) {
    this.errorListeners.add(listener);
    return () => this.errorListeners.delete(listener);
  }

  /**
   * Notify error listeners
   */
  notify(error, context) {
    this.errorListeners.forEach(listener => {
      try {
        listener(error, context);
      } catch (listenerError) {
        this.logger.error('Error in error listener:', listenerError);
      }
    });
  }
}

// Create global error handler
const errorHandler = new ErrorHandler({
  maxErrorCount: 5,
  errorWindow: 30000 // 30 seconds
});

// Subscribe to errors for monitoring
errorHandler.onError((error, context) => {
  // Send to monitoring service (e.g., Sentry, LogRocket)
  console.log('Sending error to monitoring service:', error.name);
});

/**
 * Example usage in async functions
 */
async function fetchUserProfile(userId) {
  try {
    if (!userId) {
      throw new ValidationError('User ID is required', 'userId');
    }

    const response = await fetch(`/api/users/${userId}`);

    if (response.status === 404) {
      throw new NotFoundError('User');
    }

    if (response.status === 401) {
      throw new AuthenticationError();
    }

    if (response.status === 403) {
      throw new AuthorizationError();
    }

    if (!response.ok) {
      throw new AppError(`HTTP ${response.status}`, response.status);
    }

    const user = await response.json();
    return { success: true, data: user };

  } catch (error) {
    if (error instanceof AppError) {
      return errorHandler.handle(error, { userId });
    }

    // Wrap unexpected errors
    const wrappedError = new AppError(
      error.message,
      500,
      false // Not operational
    );

    return errorHandler.handle(wrappedError, { userId, originalError: error });
  }
}

/**
 * Retry with exponential backoff
 */
async function retryWithBackoff(fn, maxRetries = 3, baseDelay = 1000) {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      const isLastAttempt = attempt === maxRetries - 1;

      if (isLastAttempt) {
        throw error;
      }

      // Only retry on network errors or 5xx errors
      if (
        !(error instanceof NetworkError) &&
        !(error.statusCode >= 500 && error.statusCode < 600)
      ) {
        throw error;
      }

      const delay = baseDelay * Math.pow(2, attempt);
      console.log(`Attempt ${attempt + 1} failed. Retrying in ${delay}ms...`);

      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}

/**
 * Circuit breaker pattern
 */
class CircuitBreaker {
  constructor(fn, options = {}) {
    this.fn = fn;
    this.failureThreshold = options.failureThreshold || 5;
    this.resetTimeout = options.resetTimeout || 60000;
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.failureCount = 0;
    this.nextAttempt = Date.now();
  }

  async execute(...args) {
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        throw new AppError('Circuit breaker is OPEN', 503);
      }
      this.state = 'HALF_OPEN';
    }

    try {
      const result = await this.fn(...args);
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  onSuccess() {
    this.failureCount = 0;
    this.state = 'CLOSED';
  }

  onFailure() {
    this.failureCount++;

    if (this.failureCount >= this.failureThreshold) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.resetTimeout;
      console.log(`Circuit breaker opened. Retry after ${this.resetTimeout}ms`);
    }
  }

  getState() {
    return {
      state: this.state,
      failureCount: this.failureCount,
      nextAttempt: this.nextAttempt
    };
  }
}

// Usage
const unreliableAPI = async () => {
  if (Math.random() > 0.5) {
    throw new NetworkError('API timeout');
  }
  return { data: 'Success!' };
};

const protectedAPI = new CircuitBreaker(unreliableAPI, {
  failureThreshold: 3,
  resetTimeout: 5000
});

async function testCircuitBreaker() {
  for (let i = 0; i < 10; i++) {
    try {
      const result = await protectedAPI.execute();
      console.log(`Call ${i + 1}: Success`, result);
    } catch (error) {
      console.log(`Call ${i + 1}: Failed -`, error.message);
    }

    await new Promise(resolve => setTimeout(resolve, 1000));
  }
}

testCircuitBreaker();
```

**Key Concepts Demonstrated**:
- Custom error classes
- Error tracking and monitoring
- User-friendly error messages
- Retry logic with exponential backoff
- Circuit breaker pattern
- Error recovery strategies
- Logging and alerting

---

## Data Structures

### Example 11: Custom Data Structures

**Use Case**: Implement efficient data structures for specific use cases.

```javascript
/**
 * Linked List implementation
 */
class Node {
  constructor(value) {
    this.value = value;
    this.next = null;
  }
}

class LinkedList {
  constructor() {
    this.head = null;
    this.tail = null;
    this.length = 0;
  }

  append(value) {
    const node = new Node(value);

    if (!this.head) {
      this.head = node;
      this.tail = node;
    } else {
      this.tail.next = node;
      this.tail = node;
    }

    this.length++;
    return this;
  }

  prepend(value) {
    const node = new Node(value);
    node.next = this.head;
    this.head = node;

    if (!this.tail) {
      this.tail = node;
    }

    this.length++;
    return this;
  }

  find(value) {
    let current = this.head;

    while (current) {
      if (current.value === value) {
        return current;
      }
      current = current.next;
    }

    return null;
  }

  remove(value) {
    if (!this.head) return null;

    if (this.head.value === value) {
      const removed = this.head;
      this.head = this.head.next;

      if (!this.head) {
        this.tail = null;
      }

      this.length--;
      return removed.value;
    }

    let current = this.head;

    while (current.next) {
      if (current.next.value === value) {
        const removed = current.next;
        current.next = removed.next;

        if (removed === this.tail) {
          this.tail = current;
        }

        this.length--;
        return removed.value;
      }

      current = current.next;
    }

    return null;
  }

  toArray() {
    const array = [];
    let current = this.head;

    while (current) {
      array.push(current.value);
      current = current.next;
    }

    return array;
  }

  reverse() {
    let prev = null;
    let current = this.head;
    this.tail = this.head;

    while (current) {
      const next = current.next;
      current.next = prev;
      prev = current;
      current = next;
    }

    this.head = prev;
    return this;
  }
}

/**
 * Queue implementation
 */
class Queue {
  constructor() {
    this.items = [];
  }

  enqueue(item) {
    this.items.push(item);
  }

  dequeue() {
    return this.items.shift();
  }

  peek() {
    return this.items[0];
  }

  isEmpty() {
    return this.items.length === 0;
  }

  size() {
    return this.items.length;
  }

  clear() {
    this.items = [];
  }
}

/**
 * Stack implementation
 */
class Stack {
  constructor() {
    this.items = [];
  }

  push(item) {
    this.items.push(item);
  }

  pop() {
    return this.items.pop();
  }

  peek() {
    return this.items[this.items.length - 1];
  }

  isEmpty() {
    return this.items.length === 0;
  }

  size() {
    return this.items.length;
  }

  clear() {
    this.items = [];
  }
}

/**
 * Priority Queue implementation
 */
class PriorityQueue {
  constructor(compareFn = (a, b) => a.priority - b.priority) {
    this.items = [];
    this.compareFn = compareFn;
  }

  enqueue(item, priority = 0) {
    const element = { item, priority };
    let added = false;

    for (let i = 0; i < this.items.length; i++) {
      if (this.compareFn(element, this.items[i]) < 0) {
        this.items.splice(i, 0, element);
        added = true;
        break;
      }
    }

    if (!added) {
      this.items.push(element);
    }
  }

  dequeue() {
    return this.items.shift()?.item;
  }

  peek() {
    return this.items[0]?.item;
  }

  isEmpty() {
    return this.items.length === 0;
  }

  size() {
    return this.items.length;
  }
}

/**
 * LRU Cache implementation
 */
class LRUCache {
  constructor(capacity) {
    this.capacity = capacity;
    this.cache = new Map();
  }

  get(key) {
    if (!this.cache.has(key)) {
      return undefined;
    }

    // Move to end (most recently used)
    const value = this.cache.get(key);
    this.cache.delete(key);
    this.cache.set(key, value);

    return value;
  }

  put(key, value) {
    // Remove if exists
    if (this.cache.has(key)) {
      this.cache.delete(key);
    }

    // Add to end
    this.cache.set(key, value);

    // Evict least recently used if over capacity
    if (this.cache.size > this.capacity) {
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
  }

  clear() {
    this.cache.clear();
  }

  size() {
    return this.cache.size;
  }
}

/**
 * Trie (Prefix Tree) implementation
 */
class TrieNode {
  constructor() {
    this.children = new Map();
    this.isEndOfWord = false;
    this.data = null;
  }
}

class Trie {
  constructor() {
    this.root = new TrieNode();
  }

  insert(word, data = null) {
    let node = this.root;

    for (const char of word) {
      if (!node.children.has(char)) {
        node.children.set(char, new TrieNode());
      }
      node = node.children.get(char);
    }

    node.isEndOfWord = true;
    node.data = data;
  }

  search(word) {
    let node = this.root;

    for (const char of word) {
      if (!node.children.has(char)) {
        return false;
      }
      node = node.children.get(char);
    }

    return node.isEndOfWord;
  }

  startsWith(prefix) {
    let node = this.root;

    for (const char of prefix) {
      if (!node.children.has(char)) {
        return false;
      }
      node = node.children.get(char);
    }

    return true;
  }

  autocomplete(prefix) {
    let node = this.root;
    const results = [];

    // Navigate to prefix node
    for (const char of prefix) {
      if (!node.children.has(char)) {
        return results;
      }
      node = node.children.get(char);
    }

    // DFS to find all words
    const dfs = (currentNode, currentWord) => {
      if (currentNode.isEndOfWord) {
        results.push({
          word: prefix + currentWord,
          data: currentNode.data
        });
      }

      for (const [char, childNode] of currentNode.children) {
        dfs(childNode, currentWord + char);
      }
    };

    dfs(node, '');
    return results;
  }

  delete(word) {
    const deleteHelper = (node, word, index) => {
      if (index === word.length) {
        if (!node.isEndOfWord) {
          return false;
        }

        node.isEndOfWord = false;
        return node.children.size === 0;
      }

      const char = word[index];
      const childNode = node.children.get(char);

      if (!childNode) {
        return false;
      }

      const shouldDeleteChild = deleteHelper(childNode, word, index + 1);

      if (shouldDeleteChild) {
        node.children.delete(char);
        return node.children.size === 0 && !node.isEndOfWord;
      }

      return false;
    };

    deleteHelper(this.root, word, 0);
  }
}

// Example usage
console.log('--- Linked List ---');
const list = new LinkedList();
list.append(1).append(2).append(3);
console.log(list.toArray()); // [1, 2, 3]
list.prepend(0);
console.log(list.toArray()); // [0, 1, 2, 3]
list.reverse();
console.log(list.toArray()); // [3, 2, 1, 0]

console.log('\n--- Priority Queue ---');
const pq = new PriorityQueue();
pq.enqueue('Task 1', 3);
pq.enqueue('Task 2', 1);
pq.enqueue('Task 3', 2);
console.log(pq.dequeue()); // Task 2 (priority 1)
console.log(pq.dequeue()); // Task 3 (priority 2)

console.log('\n--- LRU Cache ---');
const cache = new LRUCache(3);
cache.put('a', 1);
cache.put('b', 2);
cache.put('c', 3);
console.log(cache.get('a')); // 1
cache.put('d', 4); // Evicts 'b'
console.log(cache.get('b')); // undefined

console.log('\n--- Trie ---');
const trie = new Trie();
trie.insert('apple', { type: 'fruit' });
trie.insert('app', { type: 'software' });
trie.insert('application', { type: 'software' });
console.log(trie.search('app')); // true
console.log(trie.startsWith('ap')); // true
console.log(trie.autocomplete('app')); // All words starting with 'app'
```

**Key Concepts Demonstrated**:
- Data structure implementation
- Linked lists and traversal
- Queue and stack operations
- Priority queues
- LRU cache eviction
- Trie for prefix search
- Algorithm complexity

This comprehensive examples file now contains 11 detailed real-world examples. Let me continue adding more examples to reach our target.

<function_calls>
<invoke name="Read">
<parameter name="file_path">/Users/manu/Library/Application Support/Claude/skills/javascript-fundamentals/EXAMPLES.md
---

## Functional Programming

### Example 12: Functional Programming Patterns

**Use Case**: Implement functional programming concepts for cleaner, more maintainable code.

```javascript
/**
 * Pure Functions and Immutability
 */

// Impure function (modifies external state)
let counter = 0;
function impureIncrement() {
  counter++;
  return counter;
}

// Pure function (no side effects)
function pureIncrement(value) {
  return value + 1;
}

/**
 * Function Composition
 */
const compose = (...fns) => x => fns.reduceRight((acc, fn) => fn(acc), x);
const pipe = (...fns) => x => fns.reduce((acc, fn) => fn(acc), x);

// Example functions
const double = x => x * 2;
const addOne = x => x + 1;
const square = x => x * x;

const composedFn = compose(square, addOne, double);
console.log(composedFn(3)); // square(addOne(double(3))) = square(7) = 49

const pipedFn = pipe(double, addOne, square);
console.log(pipedFn(3)); // square(addOne(double(3))) = square(7) = 49

/**
 * Currying
 */
const curry = (fn) => {
  return function curried(...args) {
    if (args.length >= fn.length) {
      return fn.apply(this, args);
    } else {
      return function(...args2) {
        return curried.apply(this, args.concat(args2));
      };
    }
  };
};

const add = (a, b, c) => a + b + c;
const curriedAdd = curry(add);

console.log(curriedAdd(1)(2)(3)); // 6
console.log(curriedAdd(1, 2)(3)); // 6
console.log(curriedAdd(1)(2, 3)); // 6

/**
 * Partial Application
 */
const partial = (fn, ...presetArgs) => {
  return (...laterArgs) => fn(...presetArgs, ...laterArgs);
};

const multiply = (a, b, c) => a * b * c;
const multiplyBy2 = partial(multiply, 2);
const multiplyBy2And3 = partial(multiply, 2, 3);

console.log(multiplyBy2(3, 4)); // 24
console.log(multiplyBy2And3(4)); // 24

/**
 * Map, Filter, Reduce Patterns
 */
const users = [
  { name: 'John', age: 30, active: true },
  { name: 'Jane', age: 25, active: false },
  { name: 'Bob', age: 35, active: true },
  { name: 'Alice', age: 28, active: true }
];

// Functional chain
const result = users
  .filter(user => user.active)
  .map(user => ({ ...user, category: user.age >= 30 ? 'senior' : 'junior' }))
  .reduce((acc, user) => {
    acc[user.category] = (acc[user.category] || 0) + 1;
    return acc;
  }, {});

console.log(result); // { senior: 1, junior: 2 }

/**
 * Transducers (composable reducers)
 */
const mapping = transform => reducer => {
  return (acc, value) => reducer(acc, transform(value));
};

const filtering = predicate => reducer => {
  return (acc, value) => predicate(value) ? reducer(acc, value) : acc;
};

const append = (acc, value) => {
  acc.push(value);
  return acc;
};

const transduce = (transform, reducer, initial, collection) => {
  const transformedReducer = transform(reducer);
  return collection.reduce(transformedReducer, initial);
};

const numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

const xform = compose(
  filtering(x => x % 2 === 0),
  mapping(x => x * 2)
);

const result2 = transduce(xform, append, [], numbers);
console.log(result2); // [4, 8, 12, 16, 20]

/**
 * Lazy Evaluation
 */
function* lazyMap(iterable, fn) {
  for (const item of iterable) {
    yield fn(item);
  }
}

function* lazyFilter(iterable, predicate) {
  for (const item of iterable) {
    if (predicate(item)) {
      yield item;
    }
  }
}

function take(iterable, n) {
  const result = [];
  let count = 0;
  for (const item of iterable) {
    if (count >= n) break;
    result.push(item);
    count++;
  }
  return result;
}

const largeArray = Array.from({ length: 1000000 }, (_, i) => i);

// Lazy evaluation - only processes what's needed
const lazyResult = take(
  lazyMap(
    lazyFilter(largeArray, x => x % 2 === 0),
    x => x * 2
  ),
  5
);

console.log(lazyResult); // [0, 4, 8, 12, 16]

/**
 * Monads - Maybe/Option Pattern
 */
class Maybe {
  constructor(value) {
    this.value = value;
  }

  static of(value) {
    return new Maybe(value);
  }

  isNothing() {
    return this.value === null || this.value === undefined;
  }

  map(fn) {
    return this.isNothing() ? this : Maybe.of(fn(this.value));
  }

  flatMap(fn) {
    return this.isNothing() ? this : fn(this.value);
  }

  getOrElse(defaultValue) {
    return this.isNothing() ? defaultValue : this.value;
  }
}

const user = {
  name: 'John',
  address: {
    city: 'NYC'
  }
};

const getCity = user =>
  Maybe.of(user)
    .map(u => u.address)
    .map(addr => addr.city)
    .getOrElse('Unknown');

console.log(getCity(user)); // "NYC"
console.log(getCity({})); // "Unknown"
```

**Key Concepts Demonstrated**:
- Pure functions
- Immutability
- Function composition
- Currying and partial application
- Transducers
- Lazy evaluation with generators
- Monad pattern

---

## Module Patterns

### Example 13: Advanced Module Patterns

**Use Case**: Organize code into reusable, maintainable modules.

```javascript
/**
 * Revealing Module Pattern with Dependencies
 */
const DataService = (function(http) {
  // Private state
  const cache = new Map();
  const config = {
    baseUrl: 'https://api.example.com',
    timeout: 5000
  };

  // Private methods
  function buildUrl(endpoint) {
    return `${config.baseUrl}${endpoint}`;
  }

  function getCacheKey(url, params) {
    return `${url}:${JSON.stringify(params)}`;
  }

  // Public API
  async function get(endpoint, params = {}) {
    const url = buildUrl(endpoint);
    const cacheKey = getCacheKey(url, params);

    if (cache.has(cacheKey)) {
      return cache.get(cacheKey);
    }

    const data = await http.get(url, params);
    cache.set(cacheKey, data);
    return data;
  }

  async function post(endpoint, data) {
    const url = buildUrl(endpoint);
    return await http.post(url, data);
  }

  function clearCache() {
    cache.clear();
  }

  function configure(options) {
    Object.assign(config, options);
  }

  // Reveal public interface
  return {
    get,
    post,
    clearCache,
    configure
  };
})(HttpClient); // Inject dependency

/**
 * Namespace Pattern
 */
const MyApp = MyApp || {};

MyApp.Utils = {
  formatDate(date) {
    return new Date(date).toLocaleDateString();
  },

  formatCurrency(amount) {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD'
    }).format(amount);
  }
};

MyApp.Models = {
  User: class {
    constructor(data) {
      this.id = data.id;
      this.name = data.name;
      this.email = data.email;
    }

    toJSON() {
      return {
        id: this.id,
        name: this.name,
        email: this.email
      };
    }
  }
};

/**
 * Plugin Pattern
 */
class Application {
  constructor() {
    this.plugins = [];
    this.state = {};
  }

  use(plugin) {
    plugin.install(this);
    this.plugins.push(plugin);
    return this;
  }

  setState(key, value) {
    this.state[key] = value;
  }

  getState(key) {
    return this.state[key];
  }
}

// Plugin definition
const LoggerPlugin = {
  install(app) {
    app.log = function(message) {
      console.log(`[${new Date().toISOString()}]`, message);
    };

    app.error = function(message) {
      console.error(`[${new Date().toISOString()}]`, message);
    };
  }
};

const ValidationPlugin = {
  install(app) {
    app.validate = function(data, rules) {
      const errors = {};

      for (const [field, rule] of Object.entries(rules)) {
        if (!rule(data[field])) {
          errors[field] = `Invalid ${field}`;
        }
      }

      return {
        isValid: Object.keys(errors).length === 0,
        errors
      };
    };
  }
};

// Usage
const app = new Application();
app.use(LoggerPlugin);
app.use(ValidationPlugin);

app.log('Application started');
const result = app.validate(
  { email: 'test@example.com' },
  { email: val => val.includes('@') }
);

/**
 * Dependency Injection Container
 */
class Container {
  constructor() {
    this.services = new Map();
    this.singletons = new Map();
  }

  register(name, factory, singleton = false) {
    this.services.set(name, { factory, singleton });
  }

  get(name) {
    const service = this.services.get(name);

    if (!service) {
      throw new Error(`Service "${name}" not found`);
    }

    if (service.singleton) {
      if (!this.singletons.has(name)) {
        this.singletons.set(name, service.factory(this));
      }
      return this.singletons.get(name);
    }

    return service.factory(this);
  }
}

// Register services
const container = new Container();

container.register('config', () => ({
  apiUrl: 'https://api.example.com',
  timeout: 5000
}), true);

container.register('http', (c) => {
  const config = c.get('config');
  return {
    get: async (url) => {
      // HTTP GET implementation
    },
    post: async (url, data) => {
      // HTTP POST implementation
    }
  };
});

container.register('userService', (c) => {
  const http = c.get('http');
  return {
    fetchUser: async (id) => {
      return await http.get(`/users/${id}`);
    }
  };
});

// Usage
const userService = container.get('userService');
```

**Key Concepts Demonstrated**:
- Revealing module pattern
- Namespace pattern
- Plugin architecture
- Dependency injection
- Service container
- Singleton pattern

---

## Class-Based Patterns

### Example 14: Object-Oriented Design Patterns

**Use Case**: Implement OOP design patterns using ES6 classes.

```javascript
/**
 * Abstract Factory Pattern
 */
class Button {
  render() {
    throw new Error('render() must be implemented');
  }
}

class WindowsButton extends Button {
  render() {
    return '<button class="windows">Windows Button</button>';
  }
}

class MacButton extends Button {
  render() {
    return '<button class="mac">Mac Button</button>';
  }
}

class Checkbox {
  render() {
    throw new Error('render() must be implemented');
  }
}

class WindowsCheckbox extends Checkbox {
  render() {
    return '<input type="checkbox" class="windows" />';
  }
}

class MacCheckbox extends Checkbox {
  render() {
    return '<input type="checkbox" class="mac" />';
  }
}

class GUIFactory {
  createButton() {
    throw new Error('createButton() must be implemented');
  }

  createCheckbox() {
    throw new Error('createCheckbox() must be implemented');
  }
}

class WindowsFactory extends GUIFactory {
  createButton() {
    return new WindowsButton();
  }

  createCheckbox() {
    return new WindowsCheckbox();
  }
}

class MacFactory extends GUIFactory {
  createButton() {
    return new MacButton();
  }

  createCheckbox() {
    return new MacCheckbox();
  }
}

// Usage
const platform = 'mac';
const factory = platform === 'windows' ? new WindowsFactory() : new MacFactory();
const button = factory.createButton();
const checkbox = factory.createCheckbox();

console.log(button.render());
console.log(checkbox.render());

/**
 * Builder Pattern
 */
class QueryBuilder {
  constructor(table) {
    this.table = table;
    this.conditions = [];
    this.orderByFields = [];
    this.limitValue = null;
    this.selectFields = ['*'];
  }

  select(...fields) {
    this.selectFields = fields;
    return this;
  }

  where(field, operator, value) {
    this.conditions.push({ field, operator, value });
    return this;
  }

  orderBy(field, direction = 'ASC') {
    this.orderByFields.push({ field, direction });
    return this;
  }

  limit(value) {
    this.limitValue = value;
    return this;
  }

  build() {
    let query = `SELECT ${this.selectFields.join(', ')} FROM ${this.table}`;

    if (this.conditions.length > 0) {
      const whereClause = this.conditions
        .map(c => `${c.field} ${c.operator} '${c.value}'`)
        .join(' AND ');
      query += ` WHERE ${whereClause}`;
    }

    if (this.orderByFields.length > 0) {
      const orderClause = this.orderByFields
        .map(o => `${o.field} ${o.direction}`)
        .join(', ');
      query += ` ORDER BY ${orderClause}`;
    }

    if (this.limitValue !== null) {
      query += ` LIMIT ${this.limitValue}`;
    }

    return query;
  }
}

// Usage
const query = new QueryBuilder('users')
  .select('id', 'name', 'email')
  .where('active', '=', true)
  .where('age', '>', 18)
  .orderBy('name', 'ASC')
  .limit(10)
  .build();

console.log(query);

/**
 * Strategy Pattern
 */
class PaymentStrategy {
  pay(amount) {
    throw new Error('pay() must be implemented');
  }
}

class CreditCardPayment extends PaymentStrategy {
  constructor(cardNumber, cvv) {
    super();
    this.cardNumber = cardNumber;
    this.cvv = cvv;
  }

  pay(amount) {
    console.log(`Paying $${amount} with credit card ${this.cardNumber}`);
    return { success: true, method: 'credit_card', amount };
  }
}

class PayPalPayment extends PaymentStrategy {
  constructor(email) {
    super();
    this.email = email;
  }

  pay(amount) {
    console.log(`Paying $${amount} via PayPal (${this.email})`);
    return { success: true, method: 'paypal', amount };
  }
}

class BitcoinPayment extends PaymentStrategy {
  constructor(walletAddress) {
    super();
    this.walletAddress = walletAddress;
  }

  pay(amount) {
    console.log(`Paying $${amount} with Bitcoin to ${this.walletAddress}`);
    return { success: true, method: 'bitcoin', amount };
  }
}

class ShoppingCart {
  constructor() {
    this.items = [];
    this.paymentStrategy = null;
  }

  addItem(item) {
    this.items.push(item);
  }

  getTotal() {
    return this.items.reduce((sum, item) => sum + item.price, 0);
  }

  setPaymentStrategy(strategy) {
    this.paymentStrategy = strategy;
  }

  checkout() {
    if (!this.paymentStrategy) {
      throw new Error('Payment strategy not set');
    }

    const total = this.getTotal();
    return this.paymentStrategy.pay(total);
  }
}

// Usage
const cart = new ShoppingCart();
cart.addItem({ name: 'Book', price: 29.99 });
cart.addItem({ name: 'Laptop', price: 999.99 });

cart.setPaymentStrategy(new CreditCardPayment('1234-5678-9012-3456', '123'));
cart.checkout();

/**
 * Decorator Pattern
 */
class Coffee {
  cost() {
    return 5;
  }

  description() {
    return 'Simple coffee';
  }
}

class CoffeeDecorator {
  constructor(coffee) {
    this.coffee = coffee;
  }

  cost() {
    return this.coffee.cost();
  }

  description() {
    return this.coffee.description();
  }
}

class MilkDecorator extends CoffeeDecorator {
  cost() {
    return this.coffee.cost() + 1;
  }

  description() {
    return `${this.coffee.description()}, milk`;
  }
}

class SugarDecorator extends CoffeeDecorator {
  cost() {
    return this.coffee.cost() + 0.5;
  }

  description() {
    return `${this.coffee.description()}, sugar`;
  }
}

class VanillaDecorator extends CoffeeDecorator {
  cost() {
    return this.coffee.cost() + 1.5;
  }

  description() {
    return `${this.coffee.description()}, vanilla`;
  }
}

// Usage
let myCoffee = new Coffee();
console.log(myCoffee.description(), '-', `$${myCoffee.cost()}`);

myCoffee = new MilkDecorator(myCoffee);
myCoffee = new SugarDecorator(myCoffee);
myCoffee = new VanillaDecorator(myCoffee);

console.log(myCoffee.description(), '-', `$${myCoffee.cost()}`);
// "Simple coffee, milk, sugar, vanilla - $8"
```

**Key Concepts Demonstrated**:
- Abstract factory pattern
- Builder pattern
- Strategy pattern
- Decorator pattern
- Inheritance and composition
- Interface abstraction

---

## Advanced Async Patterns

### Example 15: Advanced Asynchronous Programming

**Use Case**: Handle complex async scenarios with race conditions, cancellation, and coordination.

```javascript
/**
 * Promise Race with Timeout
 */
function withTimeout(promise, timeout, errorMessage = 'Operation timed out') {
  return Promise.race([
    promise,
    new Promise((_, reject) =>
      setTimeout(() => reject(new Error(errorMessage)), timeout)
    )
  ]);
}

// Usage
async function fetchWithTimeout(url) {
  try {
    const data = await withTimeout(
      fetch(url).then(r => r.json()),
      5000,
      'Request took too long'
    );
    return data;
  } catch (error) {
    console.error('Error:', error.message);
    throw error;
  }
}

/**
 * Async Queue with Concurrency Limit
 */
class AsyncQueue {
  constructor(concurrency = 1) {
    this.concurrency = concurrency;
    this.running = 0;
    this.queue = [];
  }

  async add(fn) {
    return new Promise((resolve, reject) => {
      this.queue.push({ fn, resolve, reject });
      this.run();
    });
  }

  async run() {
    if (this.running >= this.concurrency || this.queue.length === 0) {
      return;
    }

    this.running++;
    const { fn, resolve, reject } = this.queue.shift();

    try {
      const result = await fn();
      resolve(result);
    } catch (error) {
      reject(error);
    } finally {
      this.running--;
      this.run();
    }
  }
}

// Usage: Process 100 tasks with max 5 concurrent
const queue = new AsyncQueue(5);

const tasks = Array.from({ length: 100 }, (_, i) => () =>
  new Promise(resolve =>
    setTimeout(() => resolve(`Task ${i} complete`), Math.random() * 1000)
  )
);

const results = await Promise.all(tasks.map(task => queue.add(task)));
console.log('All tasks completed:', results.length);

/**
 * Cancellable Promise
 */
class CancellablePromise {
  constructor(executor) {
    let cancelFn;

    this.promise = new Promise((resolve, reject) => {
      cancelFn = () => {
        reject(new Error('Promise cancelled'));
      };

      executor(
        value => {
          if (this.cancelled) return;
          resolve(value);
        },
        reason => {
          if (this.cancelled) return;
          reject(reason);
        }
      );
    });

    this.cancel = () => {
      this.cancelled = true;
      cancelFn();
    };
  }

  then(onFulfilled, onRejected) {
    return this.promise.then(onFulfilled, onRejected);
  }

  catch(onRejected) {
    return this.promise.catch(onRejected);
  }
}

// Usage
const cancellable = new CancellablePromise((resolve) => {
  setTimeout(() => resolve('Done!'), 5000);
});

cancellable.then(result => console.log(result));

setTimeout(() => {
  cancellable.cancel();
  console.log('Promise cancelled');
}, 1000);

/**
 * Async Iterators
 */
class AsyncIterableRange {
  constructor(start, end, delay = 100) {
    this.start = start;
    this.end = end;
    this.delay = delay;
  }

  async *[Symbol.asyncIterator]() {
    for (let i = this.start; i <= this.end; i++) {
      await new Promise(resolve => setTimeout(resolve, this.delay));
      yield i;
    }
  }
}

// Usage
async function processAsyncRange() {
  const range = new AsyncIterableRange(1, 5, 200);

  for await (const num of range) {
    console.log('Processing:', num);
  }

  console.log('Complete!');
}

processAsyncRange();

/**
 * Parallel Promise Map with Progress
 */
async function parallelMap(items, fn, concurrency = 5, onProgress) {
  const results = new Array(items.length);
  let completed = 0;

  const queue = items.map((item, index) => async () => {
    const result = await fn(item, index);
    results[index] = result;
    completed++;

    if (onProgress) {
      onProgress({
        completed,
        total: items.length,
        percentage: (completed / items.length) * 100
      });
    }

    return result;
  });

  const asyncQueue = new AsyncQueue(concurrency);
  await Promise.all(queue.map(task => asyncQueue.add(task)));

  return results;
}

// Usage
const urls = Array.from({ length: 20 }, (_, i) => `/api/item/${i}`);

const data = await parallelMap(
  urls,
  async (url) => {
    const response = await fetch(url);
    return response.json();
  },
  5,
  (progress) => {
    console.log(`Progress: ${progress.percentage.toFixed(1)}%`);
  }
);

/**
 * Retry with Jitter
 */
async function retryWithJitter(fn, maxRetries = 3, baseDelay = 1000) {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxRetries - 1) {
        throw error;
      }

      // Exponential backoff with jitter
      const jitter = Math.random() * 1000;
      const delay = Math.min(baseDelay * Math.pow(2, attempt) + jitter, 30000);

      console.log(`Retry ${attempt + 1}/${maxRetries} in ${delay.toFixed(0)}ms`);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}

/**
 * Promise Pool
 */
class PromisePool {
  constructor(concurrency) {
    this.concurrency = concurrency;
    this.running = 0;
    this.queue = [];
  }

  async run(tasks) {
    const results = [];

    for (const task of tasks) {
      if (this.running >= this.concurrency) {
        await Promise.race(this.queue);
      }

      const promise = task().then(
        result => {
          this.running--;
          this.queue = this.queue.filter(p => p !== promise);
          return result;
        },
        error => {
          this.running--;
          this.queue = this.queue.filter(p => p !== promise);
          throw error;
        }
      );

      this.running++;
      this.queue.push(promise);
      results.push(promise);
    }

    return Promise.all(results);
  }
}

// Usage
const pool = new PromisePool(3);
const poolTasks = Array.from({ length: 10 }, (_, i) => () =>
  new Promise(resolve =>
    setTimeout(() => resolve(`Result ${i}`), Math.random() * 2000)
  )
);

const poolResults = await pool.run(poolTasks);
console.log('Pool results:', poolResults);
```

**Key Concepts Demonstrated**:
- Promise timeout
- Concurrency control
- Cancellable promises
- Async iterators
- Progress tracking
- Retry with jitter
- Promise pooling
- Advanced async patterns

---

## Summary

This comprehensive examples file demonstrates JavaScript fundamentals through 15 detailed, production-ready examples covering:

1. **Data Processing**: Complex transformations, filtering, and aggregation
2. **Async Data Fetching**: Retry logic, caching, batching, and parallel execution
3. **State Management**: Observable pattern with subscriptions and computed values
4. **Form Validation**: Schema-based validation with async support
5. **Event Handling**: Custom event emitter with priorities and wildcards
6. **Caching**: Memoization with TTL and LRU/LFU strategies
7. **API Client**: Interceptors, retries, and timeout handling
8. **Observer Pattern**: Reactive data system with dependencies
9. **Debouncing/Throttling**: Performance optimization for high-frequency events
10. **Error Handling**: Custom errors, logging, circuit breaker
11. **Data Structures**: Linked lists, queues, stacks, tries, LRU cache
12. **Functional Programming**: Composition, currying, transducers, monads
13. **Module Patterns**: Revealing module, namespaces, dependency injection
14. **OOP Patterns**: Factory, builder, strategy, decorator
15. **Advanced Async**: Cancellation, async queues, iterators, promise pools

Each example is designed to be practical, well-commented, and ready for real-world use.
