# React Development Skill

A comprehensive guide to building modern React applications with hooks, components, state management, and performance optimization.

## Overview

React is a JavaScript library for building user interfaces. It lets you create reusable components that manage their own state, then compose them to build complex UIs. This skill covers everything you need to know to build production-ready React applications using modern patterns and best practices from the official React documentation.

## Quick Start

### Installation

Create a new React app using Vite (recommended):

```bash
npm create vite@latest my-react-app -- --template react
cd my-react-app
npm install
npm run dev
```

Or using Create React App:

```bash
npx create-react-app my-react-app
cd my-react-app
npm start
```

### Your First Component

```jsx
import { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);

  return (
    <div>
      <h1>Count: {count}</h1>
      <button onClick={() => setCount(count + 1)}>
        Increment
      </button>
    </div>
  );
}

export default Counter;
```

## What's Included

This skill provides comprehensive coverage of:

### 1. Core React Concepts
- **Components**: Building blocks of React applications
- **JSX**: JavaScript XML syntax for describing UI
- **Props**: Passing data between components
- **State**: Component memory and dynamic data
- **Events**: Handling user interactions
- **Conditional Rendering**: Showing/hiding UI elements
- **Lists and Keys**: Rendering collections of data

### 2. React Hooks
All essential hooks with practical examples:
- `useState` - Managing component state
- `useEffect` - Handling side effects and lifecycle
- `useContext` - Consuming context values
- `useReducer` - Managing complex state logic
- `useMemo` - Memoizing expensive calculations
- `useCallback` - Memoizing callback functions
- `useRef` - Referencing DOM elements and mutable values

### 3. State Management Patterns
- **Local State**: Component-specific state with useState
- **Lifting State Up**: Sharing state between components
- **Context API**: Global state without prop drilling
- **Reducer Pattern**: Scalable state management with useReducer
- **Reducer + Context**: Combining patterns for complex applications

### 4. Performance Optimization
- **React.memo**: Preventing unnecessary re-renders
- **useMemo**: Caching expensive computations
- **useCallback**: Memoizing event handlers
- **Lazy Loading**: Code splitting and dynamic imports
- **Virtual Scrolling**: Handling large lists efficiently

### 5. Custom Hooks
Learn to create reusable hooks for:
- Data fetching
- Form handling
- Window dimensions
- Online/offline status
- Local storage
- Debouncing and throttling

## Key Features

### Based on Official Documentation
This skill is built from Context7 research of the official React documentation (react.dev) with a trust score of 10, ensuring:
- Accurate and up-to-date information
- Best practices from the React core team
- Modern patterns using functional components and hooks
- Production-ready code examples

### Comprehensive Examples
Over 20 detailed examples covering:
- Task management with reducer + context
- Video player with refs and effects
- Form handling with custom hooks
- Infinite scroll implementation
- Debounced search
- Drag and drop
- Multi-step forms
- Modal dialogs with portals

### Real-World Patterns
Learn patterns used in production applications:
- Authentication context
- Theme management
- Data fetching and caching
- Error handling
- Loading states
- Optimistic updates

## React Ecosystem

### Essential Tools

**Build Tools:**
- **Vite**: Fast development server and build tool (recommended)
- **Create React App**: Official React scaffolding tool
- **Next.js**: React framework for production
- **Remix**: Full-stack React framework

**Routing:**
- **React Router**: Client-side routing library
- **TanStack Router**: Type-safe routing

**State Management:**
- **Context API**: Built-in React solution (covered in this skill)
- **Redux Toolkit**: Predictable state container
- **Zustand**: Lightweight state management
- **Jotai**: Atomic state management
- **Recoil**: Experimental state library from Meta

**Data Fetching:**
- **React Query (TanStack Query)**: Powerful data fetching and caching
- **SWR**: React hooks for data fetching
- **Apollo Client**: GraphQL client
- **Fetch API**: Built-in browser API (covered in this skill)

**Form Libraries:**
- **React Hook Form**: Performant form library
- **Formik**: Popular form library
- **Custom hooks**: Build your own (covered in this skill)

**Styling:**
- **CSS Modules**: Scoped CSS
- **Styled Components**: CSS-in-JS
- **Tailwind CSS**: Utility-first CSS
- **Emotion**: CSS-in-JS library
- **Sass/SCSS**: CSS preprocessor

**Testing:**
- **Jest**: JavaScript testing framework
- **React Testing Library**: Testing React components
- **Vitest**: Vite-native testing framework
- **Playwright**: End-to-end testing

**TypeScript:**
- **TypeScript**: Static type checking for React
- **PropTypes**: Runtime type checking (covered in this skill)

### Development Tools

**Browser Extensions:**
- **React Developer Tools**: Inspect React component hierarchy
- **Redux DevTools**: Debug Redux state (if using Redux)

**Linting and Formatting:**
- **ESLint**: JavaScript linting
- **Prettier**: Code formatting
- **eslint-plugin-react-hooks**: Lint rules for hooks

## Project Structure

A typical React project structure:

```
my-react-app/
├── public/
│   └── index.html
├── src/
│   ├── components/
│   │   ├── Button.jsx
│   │   ├── Card.jsx
│   │   └── Modal.jsx
│   ├── contexts/
│   │   ├── ThemeContext.jsx
│   │   └── AuthContext.jsx
│   ├── hooks/
│   │   ├── useWindowSize.js
│   │   ├── useFetch.js
│   │   └── useLocalStorage.js
│   ├── pages/
│   │   ├── Home.jsx
│   │   ├── About.jsx
│   │   └── Dashboard.jsx
│   ├── utils/
│   │   └── helpers.js
│   ├── App.jsx
│   ├── App.css
│   └── main.jsx
├── package.json
└── vite.config.js
```

## Best Practices

### Component Organization

**Keep Components Small and Focused:**
```jsx
// ❌ Bad - too many responsibilities
function UserDashboard() {
  // Fetching user data
  // Managing authentication
  // Handling form submission
  // Rendering complex UI
}

// ✅ Good - single responsibility
function UserProfile({ user }) {
  return <div>{user.name}</div>;
}

function UserSettings({ settings, onUpdate }) {
  return <form>...</form>;
}

function UserDashboard() {
  const user = useUser();
  return (
    <>
      <UserProfile user={user} />
      <UserSettings settings={user.settings} />
    </>
  );
}
```

### State Management

**Use the Right Tool:**
- Local state (useState) for component-specific data
- Context for global/widely-shared data (theme, auth)
- Reducer for complex state logic
- External libraries for very complex applications

**Keep State Minimal:**
```jsx
// ❌ Bad - derived state
const [items, setItems] = useState([]);
const [itemCount, setItemCount] = useState(0);

// ✅ Good - calculate from existing state
const [items, setItems] = useState([]);
const itemCount = items.length;
```

### Performance

**Measure Before Optimizing:**
Use React DevTools Profiler to identify performance bottlenecks before adding memoization.

**Optimize Renders:**
```jsx
// Use React.memo for expensive components
const ExpensiveList = memo(function ExpensiveList({ items }) {
  return items.map(item => <Item key={item.id} data={item} />);
});

// Use useCallback for stable references
const handleClick = useCallback(() => {
  doSomething(id);
}, [id]);

// Use useMemo for expensive calculations
const sortedItems = useMemo(() => {
  return items.sort((a, b) => a.price - b.price);
}, [items]);
```

### Code Quality

**Use TypeScript or PropTypes:**
```jsx
import PropTypes from 'prop-types';

function User({ name, age, isAdmin }) {
  return <div>{name}</div>;
}

User.propTypes = {
  name: PropTypes.string.isRequired,
  age: PropTypes.number,
  isAdmin: PropTypes.bool
};
```

**Handle Errors Gracefully:**
```jsx
function DataDisplay() {
  const { data, loading, error } = useFetch('/api/data');

  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!data) return <EmptyState />;

  return <DataList data={data} />;
}
```

**Clean Up Effects:**
```jsx
useEffect(() => {
  const subscription = api.subscribe(id);

  return () => {
    subscription.unsubscribe();
  };
}, [id]);
```

## Common Patterns

### Container/Presentational Pattern

Separate data fetching logic from presentation:

```jsx
// Container component
function UserContainer({ userId }) {
  const { data, loading, error } = useFetch(`/api/users/${userId}`);

  if (loading) return <Spinner />;
  if (error) return <Error error={error} />;

  return <UserPresentation user={data} />;
}

// Presentational component
function UserPresentation({ user }) {
  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}
```

### Compound Components Pattern

Create flexible, composable components:

```jsx
function Select({ children, value, onChange }) {
  return (
    <select value={value} onChange={onChange}>
      {children}
    </select>
  );
}

Select.Option = function Option({ value, children }) {
  return <option value={value}>{children}</option>;
};

// Usage
<Select value={selected} onChange={setSelected}>
  <Select.Option value="1">Option 1</Select.Option>
  <Select.Option value="2">Option 2</Select.Option>
</Select>
```

### Render Props Pattern

Share code between components using a prop whose value is a function:

```jsx
function DataProvider({ url, render }) {
  const { data, loading, error } = useFetch(url);

  return render({ data, loading, error });
}

// Usage
<DataProvider
  url="/api/users"
  render={({ data, loading, error }) => {
    if (loading) return <Spinner />;
    if (error) return <Error error={error} />;
    return <UserList users={data} />;
  }}
/>
```

### Higher-Order Components (HOC)

Wrap components to add functionality:

```jsx
function withAuth(Component) {
  return function AuthenticatedComponent(props) {
    const { user, loading } = useAuth();

    if (loading) return <Spinner />;
    if (!user) return <Redirect to="/login" />;

    return <Component {...props} user={user} />;
  };
}

// Usage
const ProtectedDashboard = withAuth(Dashboard);
```

## Migration Guide

### From Class Components to Hooks

**Class Component:**
```jsx
class Counter extends React.Component {
  constructor(props) {
    super(props);
    this.state = { count: 0 };
  }

  componentDidMount() {
    document.title = `Count: ${this.state.count}`;
  }

  componentDidUpdate() {
    document.title = `Count: ${this.state.count}`;
  }

  render() {
    return (
      <button onClick={() => this.setState({ count: this.state.count + 1 })}>
        {this.state.count}
      </button>
    );
  }
}
```

**Functional Component with Hooks:**
```jsx
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    document.title = `Count: ${count}`;
  }, [count]);

  return (
    <button onClick={() => setCount(count + 1)}>
      {count}
    </button>
  );
}
```

## Debugging Tips

### Common Issues

**1. Stale Closures:**
```jsx
// Problem
function Component() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCount(count + 1); // Always uses initial count (0)
    }, 1000);
    return () => clearInterval(interval);
  }, []); // Empty deps cause stale closure

  // Solution
  useEffect(() => {
    const interval = setInterval(() => {
      setCount(c => c + 1); // Uses updater function
    }, 1000);
    return () => clearInterval(interval);
  }, []);
}
```

**2. Infinite Loops:**
```jsx
// Problem
useEffect(() => {
  setData(fetchData()); // Causes infinite loop
});

// Solution
useEffect(() => {
  async function fetch() {
    const result = await fetchData();
    setData(result);
  }
  fetch();
}, []); // Add dependency array
```

**3. Missing Dependencies:**
```jsx
// Problem
useEffect(() => {
  fetchUser(userId);
}, []); // Missing userId dependency

// Solution
useEffect(() => {
  fetchUser(userId);
}, [userId]); // Include all dependencies
```

### React DevTools

Use React DevTools to:
- Inspect component hierarchy
- View props and state
- Profile component performance
- Debug context values
- Track component updates

## Learning Resources

### Official Documentation
- [React.dev](https://react.dev) - Official React documentation
- [React GitHub](https://github.com/facebook/react) - Source code and issues

### Tutorials
- React.dev Tutorial - Interactive tic-tac-toe tutorial
- React.dev Learn - Step-by-step guide to React concepts

### Community
- [React Discord](https://discord.gg/react) - Official React community
- [Stack Overflow](https://stackoverflow.com/questions/tagged/reactjs) - Q&A
- [Reddit r/reactjs](https://reddit.com/r/reactjs) - Discussions

### Video Courses
- [React - The Complete Guide (Udemy)](https://www.udemy.com/course/react-the-complete-guide-incl-redux/)
- [Epic React by Kent C. Dodds](https://epicreact.dev/)
- [React for Beginners by Wes Bos](https://reactforbeginners.com/)

## Next Steps

After mastering the basics, explore:

1. **Advanced Patterns**: Error boundaries, portals, refs forwarding
2. **Performance**: Code splitting, lazy loading, memoization
3. **TypeScript**: Add type safety to your React applications
4. **Testing**: Write tests with React Testing Library
5. **State Management**: Redux, Zustand, or other libraries
6. **Data Fetching**: React Query or SWR
7. **Server-Side Rendering**: Next.js or Remix
8. **React Native**: Build mobile apps with React

## Contributing

This skill is based on Context7 research of official React documentation. For updates or improvements, refer to the latest React documentation at react.dev.

## License

This skill documentation is provided as-is for educational purposes. React is MIT licensed.

## Summary

This React development skill provides:
- Comprehensive coverage of React fundamentals
- Modern patterns using hooks and functional components
- Performance optimization techniques
- Real-world examples and best practices
- Based on official React documentation (Trust Score: 10)
- Over 20 practical examples
- Complete ecosystem overview

Start building amazing React applications today!
