# React Patterns Skill

A comprehensive skill for modern React development covering hooks, component patterns, state management, and performance optimization.

## Overview

This skill provides complete guidance for building scalable React applications using modern patterns and best practices. It covers React 18+ features, including Server Components, Suspense, and Concurrent Features.

## What's Included

### Core Topics

1. **React Hooks** - Complete reference for all built-in hooks
   - State hooks (useState, useReducer, useContext)
   - Effect hooks (useEffect, useLayoutEffect)
   - Performance hooks (useMemo, useCallback, memo)
   - Ref hooks (useRef, useImperativeHandle)
   - Transition hooks (useTransition, useDeferredValue)
   - Server action hooks (useActionState)

2. **Custom Hooks** - Reusable patterns for common scenarios
   - Data fetching hooks
   - Form management hooks
   - Browser API hooks (localStorage, windowSize, onlineStatus)
   - Utility hooks (debounce, previous value, etc.)

3. **Component Patterns** - Advanced composition techniques
   - Compound components
   - Render props
   - Higher-Order Components (HOC)
   - Container/Presenter pattern

4. **Performance Optimization** - Techniques to improve app speed
   - Memoization strategies
   - Code splitting and lazy loading
   - Virtualization for large lists
   - Avoiding common pitfalls

5. **Server Components** - React Server Components (RSC)
   - Server vs Client components
   - Composition patterns
   - Data fetching strategies
   - Server actions

6. **State Management** - Strategies for different scales
   - Local state patterns
   - Lifted state
   - Context API
   - useReducer + Context for complex state

## Quick Start

### Installation

This skill is already installed in your Claude skills directory. Use it by invoking React-related development tasks.

### Basic Usage

The skill provides guidance for:

```javascript
// State management
const [count, setCount] = useState(0);

// Side effects
useEffect(() => {
  // Effect logic
  return () => {
    // Cleanup
  };
}, [dependencies]);

// Performance optimization
const memoizedValue = useMemo(() => computeExpensive(a, b), [a, b]);
const memoizedCallback = useCallback(() => doSomething(a, b), [a, b]);

// Custom hooks
const { data, loading, error } = useFetch('/api/users');
```

## Key Features

### Comprehensive Hook Coverage

Every built-in React hook is documented with:
- Complete syntax reference
- Multiple real-world examples
- Best practices and use cases
- Common pitfalls to avoid

### Custom Hook Library

Pre-built custom hooks for common scenarios:
- `useFetch` - Data fetching with loading and error states
- `useFormInput` - Form field management
- `useLocalStorage` - Persistent state
- `useDebounce` - Debounced values
- `useWindowSize` - Responsive breakpoints
- `useOnlineStatus` - Network status detection

### Design Patterns

Modern React patterns including:
- Compound components for flexible APIs
- Render props for code sharing
- Container/Presenter separation
- HOCs for cross-cutting concerns

### Performance Strategies

Proven optimization techniques:
- React.memo for component memoization
- useMemo for expensive calculations
- useCallback for stable function references
- Code splitting with React.lazy
- Virtualization for large datasets

### Server Components

Complete guide to React Server Components:
- Understanding Server vs Client components
- Async Server Components
- Composition patterns
- Server Actions with useActionState

## When to Use This Skill

Use this skill when you need to:

- Build new React applications from scratch
- Refactor existing React code to modern patterns
- Implement complex state management
- Optimize React application performance
- Create reusable custom hooks
- Understand React Server Components
- Debug React-specific issues
- Learn best practices and patterns

## Examples Included

The skill includes 15+ complete code examples:

1. **Counter with useState** - Basic state management
2. **Task Manager with useReducer** - Complex state logic
3. **Theme Context** - Global state with Context API
4. **Data Fetching with useEffect** - Async operations
5. **Chat Room Subscription** - Effect cleanup
6. **Todo List with Filters** - useMemo optimization
7. **Memoized Callbacks** - useCallback with React.memo
8. **Video Player** - useRef for DOM manipulation
9. **Search with Transitions** - useTransition for responsiveness
10. **Custom useFetch Hook** - Reusable data fetching
11. **Form Management Hook** - Input handling
12. **Compound Tabs Component** - Advanced composition
13. **Virtualized List** - Performance for large datasets
14. **Server Component** - RSC data fetching
15. **Server Action Form** - useActionState integration

## File Structure

```
react-patterns/
├── SKILL.md          # Complete skill documentation (25KB+)
├── README.md         # This file (10KB)
└── EXAMPLES.md       # Additional examples (20KB)
```

## Best Practices Covered

### Component Design
- Single Responsibility Principle
- Composition over inheritance
- Proper prop handling
- Type safety considerations

### State Management
- Keep state local when possible
- Lift state only when needed
- Avoid derived state
- Use reducers for complex logic

### Performance
- Measure before optimizing
- Use React DevTools Profiler
- Memoize expensive operations
- Optimize re-renders

### Effects
- One concern per effect
- Always specify dependencies
- Clean up side effects
- Handle race conditions

### Code Organization
- Logical file structure
- Separation of concerns
- Reusable components
- Custom hooks for shared logic

## Common Patterns

### Data Fetching

```javascript
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let ignore = false;

    async function fetchUser() {
      const response = await fetch(`/api/users/${userId}`);
      const data = await response.json();

      if (!ignore) {
        setUser(data);
        setLoading(false);
      }
    }

    fetchUser();

    return () => {
      ignore = true;
    };
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  return <div>{user.name}</div>;
}
```

### Form Handling

```javascript
function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  function handleSubmit(e) {
    e.preventDefault();
    // Handle login
  }

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        value={email}
        onChange={e => setEmail(e.target.value)}
      />
      <input
        type="password"
        value={password}
        onChange={e => setPassword(e.target.value)}
      />
      <button type="submit">Login</button>
    </form>
  );
}
```

### Global State

```javascript
const ThemeContext = createContext();

function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light');

  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

function useTheme() {
  return useContext(ThemeContext);
}
```

## Anti-Patterns to Avoid

### 1. Mutating State
```javascript
// ❌ Wrong
items.push(newItem);
setItems(items);

// ✅ Correct
setItems([...items, newItem]);
```

### 2. Missing Dependencies
```javascript
// ❌ Wrong
useEffect(() => {
  console.log(userId);
}, []);

// ✅ Correct
useEffect(() => {
  console.log(userId);
}, [userId]);
```

### 3. Conditional Hooks
```javascript
// ❌ Wrong
if (condition) {
  const [state, setState] = useState(0);
}

// ✅ Correct
const [state, setState] = useState(0);
```

## Troubleshooting Guide

### Infinite Re-renders
- Check useEffect dependencies
- Avoid setting state in render
- Use functional updates

### Stale Closures
- Use functional updates
- Add dependencies to effects
- Use useRef for mutable values

### Memory Leaks
- Clean up effects
- Cancel ongoing requests
- Clear timers/intervals

### Performance Issues
- Use React DevTools Profiler
- Memoize expensive computations
- Avoid anonymous functions in render
- Implement virtualization for large lists

## Resources

### Official Documentation
- [React Docs](https://react.dev) - Official React documentation
- [React Hooks](https://react.dev/reference/react) - Complete hooks API reference
- [Server Components](https://react.dev/reference/rsc) - RSC documentation

### Tools
- [React DevTools](https://react.dev/learn/react-developer-tools) - Browser extension
- [Create React App](https://create-react-app.dev) - Quick start tool
- [Vite](https://vitejs.dev) - Fast build tool

### Learning Resources
- [React Patterns](https://patterns.dev/react) - Design patterns
- [React TypeScript Cheatsheet](https://react-typescript-cheatsheet.netlify.app/) - TypeScript guide
- [React Testing Library](https://testing-library.com/react) - Testing guide

## Version Information

- **Skill Version**: 1.0.0
- **Last Updated**: October 2025
- **React Version**: 18+
- **Compatibility**: React 18+, Next.js 13+, TypeScript

## Contributing

This skill is maintained as part of Claude's skill library. For suggestions or improvements, please provide feedback through your Claude interface.

## License

This skill documentation is provided as-is for educational and development purposes.

---

## Quick Reference

### Import Statements
```javascript
import { useState, useEffect, useContext, useReducer } from 'react';
import { memo, useMemo, useCallback, useRef } from 'react';
import { useTransition, useDeferredValue } from 'react';
import { lazy, Suspense } from 'react';
```

### Common Hooks
```javascript
const [state, setState] = useState(initialValue);
const [state, dispatch] = useReducer(reducer, initialState);
const value = useContext(Context);
const memoizedValue = useMemo(() => compute(), [deps]);
const memoizedCallback = useCallback(() => {}, [deps]);
const ref = useRef(initialValue);
```

### Effect Patterns
```javascript
// Mount only
useEffect(() => { /* ... */ }, []);

// Every render
useEffect(() => { /* ... */ });

// When deps change
useEffect(() => { /* ... */ }, [dep1, dep2]);

// With cleanup
useEffect(() => {
  // Setup
  return () => {
    // Cleanup
  };
}, [deps]);
```

### Performance Patterns
```javascript
// Memoize component
const MemoComponent = memo(Component);

// Memoize value
const value = useMemo(() => expensive(), [deps]);

// Memoize callback
const callback = useCallback(() => {}, [deps]);

// Lazy load
const Component = lazy(() => import('./Component'));
```
