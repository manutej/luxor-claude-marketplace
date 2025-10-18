---
name: react-development
description: Comprehensive React development with hooks, components, state management, context, effects, and performance optimization based on official React documentation
category: frontend
tags: [react, hooks, components, state-management, context, effects, jsx]
version: 1.0.0
context7_library: /reactjs/react.dev
context7_trust_score: 10
---

# React Development Skill

This skill provides comprehensive guidance for building modern React applications using hooks, components, state management, context, effects, and performance optimization techniques based on official React documentation from react.dev.

## When to Use This Skill

Use this skill when:
- Building single-page applications (SPAs) with React
- Creating reusable UI components and component libraries
- Managing complex application state with hooks and context
- Implementing forms, data fetching, and side effects
- Optimizing React application performance
- Building interactive user interfaces with dynamic data
- Migrating class components to functional components with hooks
- Implementing global state management without external libraries
- Creating custom hooks for reusable logic
- Building accessible and performant web applications

## Core Concepts

### Components

Components are the building blocks of React applications. They let you split the UI into independent, reusable pieces.

**Functional Components (Modern Approach):**
```jsx
function Welcome(props) {
  return <h1>Hello, {props.name}</h1>;
}

// Arrow function syntax
const Greeting = ({ name, age }) => {
  return (
    <div>
      <h2>{name}</h2>
      <p>Age: {age}</p>
    </div>
  );
};
```

**Component Composition:**
```jsx
function App() {
  return (
    <div>
      <Welcome name="Sara" />
      <Welcome name="Cahal" />
      <Welcome name="Edite" />
    </div>
  );
}
```

### JSX

JSX is a syntax extension for JavaScript that looks similar to HTML. It produces React elements.

**JSX Fundamentals:**
```jsx
// Embedding expressions
const name = 'Josh Perez';
const element = <h1>Hello, {name}</h1>;

// JSX attributes
const image = <img src={user.avatarUrl} alt={user.name} />;

// JSX children
const container = (
  <div>
    <h1>Welcome</h1>
    <p>Get started with React</p>
  </div>
);

// Conditional rendering
const greeting = (
  <div>
    {isLoggedIn ? <UserGreeting /> : <GuestGreeting />}
  </div>
);

// Lists and keys
const numbers = [1, 2, 3, 4, 5];
const listItems = numbers.map((number) =>
  <li key={number.toString()}>{number}</li>
);
```

### Props

Props are arguments passed into React components. They are passed to components via HTML attributes.

**Passing and Using Props:**
```jsx
function Product({ name, price, inStock }) {
  return (
    <div className="product">
      <h3>{name}</h3>
      <p>${price}</p>
      {inStock ? <span>In Stock</span> : <span>Out of Stock</span>}
    </div>
  );
}

// Usage
<Product name="Laptop" price={999} inStock={true} />
```

**Props with Children:**
```jsx
function Card({ title, children }) {
  return (
    <div className="card">
      <h2>{title}</h2>
      <div className="card-content">
        {children}
      </div>
    </div>
  );
}

// Usage
<Card title="Welcome">
  <p>This is the card content</p>
  <button>Click me</button>
</Card>
```

**Default Props:**
```jsx
function Button({ text = 'Click me', variant = 'primary' }) {
  return <button className={variant}>{text}</button>;
}
```

### State

State is a component's memory. It lets components remember information and respond to user interactions.

**Local Component State:**
```jsx
import { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
      <button onClick={() => setCount(count - 1)}>Decrement</button>
      <button onClick={() => setCount(0)}>Reset</button>
    </div>
  );
}
```

## React Hooks

Hooks let you use state and other React features in functional components.

### useState

The useState hook lets you add state to functional components.

**Basic Usage:**
```jsx
import { useState } from 'react';

function Form() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log({ name, email });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="Name"
      />
      <input
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
        type="email"
      />
      <button type="submit">Submit</button>
    </form>
  );
}
```

**State with Objects:**
```jsx
function UserProfile() {
  const [user, setUser] = useState({
    name: '',
    age: 0,
    email: ''
  });

  const updateField = (field, value) => {
    setUser(prev => ({
      ...prev,
      [field]: value
    }));
  };

  return (
    <div>
      <input
        value={user.name}
        onChange={(e) => updateField('name', e.target.value)}
      />
      <input
        type="number"
        value={user.age}
        onChange={(e) => updateField('age', parseInt(e.target.value))}
      />
      <input
        type="email"
        value={user.email}
        onChange={(e) => updateField('email', e.target.value)}
      />
    </div>
  );
}
```

**State with Arrays:**
```jsx
function TodoList() {
  const [todos, setTodos] = useState([]);
  const [input, setInput] = useState('');

  const addTodo = () => {
    setTodos(prev => [...prev, { id: Date.now(), text: input }]);
    setInput('');
  };

  const removeTodo = (id) => {
    setTodos(prev => prev.filter(todo => todo.id !== id));
  };

  return (
    <div>
      <input value={input} onChange={(e) => setInput(e.target.value)} />
      <button onClick={addTodo}>Add</button>
      <ul>
        {todos.map(todo => (
          <li key={todo.id}>
            {todo.text}
            <button onClick={() => removeTodo(todo.id)}>Delete</button>
          </li>
        ))}
      </ul>
    </div>
  );
}
```

### useEffect

The useEffect hook lets you perform side effects in functional components.

**Basic Side Effects:**
```jsx
import { useState, useEffect } from 'react';

function DocumentTitle() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    document.title = `Count: ${count}`;
  }, [count]);

  return (
    <button onClick={() => setCount(count + 1)}>
      Clicked {count} times
    </button>
  );
}
```

**Data Fetching:**
```jsx
function UserData({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let cancelled = false;

    async function fetchUser() {
      try {
        setLoading(true);
        const response = await fetch(`/api/users/${userId}`);
        const data = await response.json();

        if (!cancelled) {
          setUser(data);
          setError(null);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err.message);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    fetchUser();

    return () => {
      cancelled = true;
    };
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return <div>{user?.name}</div>;
}
```

**Event Listeners and Cleanup:**
```jsx
function WindowSize() {
  const [size, setSize] = useState({
    width: window.innerWidth,
    height: window.innerHeight
  });

  useEffect(() => {
    function handleResize() {
      setSize({
        width: window.innerWidth,
        height: window.innerHeight
      });
    }

    window.addEventListener('resize', handleResize);

    // Cleanup function
    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, []); // Empty dependency array = run once on mount

  return <div>{size.width} x {size.height}</div>;
}
```

**Timers and Intervals:**
```jsx
function Timer() {
  const [seconds, setSeconds] = useState(0);
  const [isRunning, setIsRunning] = useState(false);

  useEffect(() => {
    if (!isRunning) return;

    const interval = setInterval(() => {
      setSeconds(s => s + 1);
    }, 1000);

    return () => clearInterval(interval);
  }, [isRunning]);

  return (
    <div>
      <p>Seconds: {seconds}</p>
      <button onClick={() => setIsRunning(!isRunning)}>
        {isRunning ? 'Pause' : 'Start'}
      </button>
      <button onClick={() => setSeconds(0)}>Reset</button>
    </div>
  );
}
```

### useContext

The useContext hook lets you read and subscribe to context from your component.

**Creating and Using Context:**
```jsx
import { createContext, useContext, useState } from 'react';

const ThemeContext = createContext('light');

function App() {
  const [theme, setTheme] = useState('light');

  return (
    <ThemeContext.Provider value={theme}>
      <Toolbar />
      <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
        Toggle Theme
      </button>
    </ThemeContext.Provider>
  );
}

function Toolbar() {
  return (
    <div>
      <ThemedButton />
    </div>
  );
}

function ThemedButton() {
  const theme = useContext(ThemeContext);

  return (
    <button className={theme}>
      I am styled by {theme} theme
    </button>
  );
}
```

**Multiple Contexts:**
```jsx
const ThemeContext = createContext('light');
const UserContext = createContext(null);

function App() {
  const [theme, setTheme] = useState('light');
  const [currentUser, setCurrentUser] = useState({ name: 'John', role: 'admin' });

  return (
    <ThemeContext.Provider value={theme}>
      <UserContext.Provider value={currentUser}>
        <Dashboard />
      </UserContext.Provider>
    </ThemeContext.Provider>
  );
}

function Dashboard() {
  const theme = useContext(ThemeContext);
  const user = useContext(UserContext);

  return (
    <div className={theme}>
      <h1>Welcome, {user.name}</h1>
      <p>Role: {user.role}</p>
    </div>
  );
}
```

### useReducer

The useReducer hook is an alternative to useState for managing complex state logic.

**Basic Reducer Pattern:**
```jsx
import { useReducer } from 'react';

function counterReducer(state, action) {
  switch (action.type) {
    case 'increment':
      return { count: state.count + 1 };
    case 'decrement':
      return { count: state.count - 1 };
    case 'reset':
      return { count: 0 };
    default:
      throw new Error(`Unknown action: ${action.type}`);
  }
}

function Counter() {
  const [state, dispatch] = useReducer(counterReducer, { count: 0 });

  return (
    <div>
      <p>Count: {state.count}</p>
      <button onClick={() => dispatch({ type: 'increment' })}>+</button>
      <button onClick={() => dispatch({ type: 'decrement' })}>-</button>
      <button onClick={() => dispatch({ type: 'reset' })}>Reset</button>
    </div>
  );
}
```

**Complex State Management (Task List Pattern from Context7):**
```jsx
function tasksReducer(tasks, action) {
  switch (action.type) {
    case 'added': {
      return [...tasks, {
        id: action.id,
        text: action.text,
        done: false
      }];
    }
    case 'changed': {
      return tasks.map(t => {
        if (t.id === action.task.id) {
          return action.task;
        } else {
          return t;
        }
      });
    }
    case 'deleted': {
      return tasks.filter(t => t.id !== action.id);
    }
    default: {
      throw Error('Unknown action: ' + action.type);
    }
  }
}

function TaskApp() {
  const [tasks, dispatch] = useReducer(tasksReducer, initialTasks);

  function handleAddTask(text) {
    dispatch({
      type: 'added',
      id: nextId++,
      text: text,
    });
  }

  function handleChangeTask(task) {
    dispatch({
      type: 'changed',
      task: task
    });
  }

  function handleDeleteTask(taskId) {
    dispatch({
      type: 'deleted',
      id: taskId
    });
  }

  return (
    <>
      <h1>Prague itinerary</h1>
      <AddTask onAddTask={handleAddTask} />
      <TaskList
        tasks={tasks}
        onChangeTask={handleChangeTask}
        onDeleteTask={handleDeleteTask}
      />
    </>
  );
}

let nextId = 3;
const initialTasks = [
  { id: 0, text: 'Visit Kafka Museum', done: true },
  { id: 1, text: 'Watch a puppet show', done: false },
  { id: 2, text: 'Lennon Wall pic', done: false }
];
```

### useMemo

The useMemo hook lets you cache the result of expensive calculations.

**Memoizing Expensive Calculations:**
```jsx
import { useMemo, useState } from 'react';

function ProductList({ products, category }) {
  const [sortOrder, setSortOrder] = useState('asc');

  const filteredAndSortedProducts = useMemo(() => {
    console.log('Filtering and sorting products...');

    const filtered = products.filter(p => p.category === category);

    return filtered.sort((a, b) => {
      if (sortOrder === 'asc') {
        return a.price - b.price;
      }
      return b.price - a.price;
    });
  }, [products, category, sortOrder]);

  return (
    <div>
      <button onClick={() => setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')}>
        Sort: {sortOrder}
      </button>
      <ul>
        {filteredAndSortedProducts.map(product => (
          <li key={product.id}>{product.name} - ${product.price}</li>
        ))}
      </ul>
    </div>
  );
}
```

**Preventing Object Recreation:**
```jsx
function SearchResults({ query }) {
  const searchOptions = useMemo(() => ({
    query,
    limit: 10,
    caseSensitive: false
  }), [query]);

  // searchOptions object only recreated when query changes
  const results = useSearch(searchOptions);

  return <ResultsList results={results} />;
}
```

### useCallback

The useCallback hook lets you cache a function definition between re-renders.

**Memoizing Event Handlers:**
```jsx
import { useCallback, useState } from 'react';

function ProductPage({ productId }) {
  const [items, setItems] = useState([]);

  const handleAddToCart = useCallback(() => {
    setItems(prevItems => [...prevItems, productId]);
  }, [productId]);

  return <AddToCartButton onAdd={handleAddToCart} />;
}

// Memoized child component
const AddToCartButton = memo(({ onAdd }) => {
  console.log('Button rendered');
  return <button onClick={onAdd}>Add to Cart</button>;
});
```

**Optimizing Child Components:**
```jsx
function TodoList() {
  const [todos, setTodos] = useState(initialTodos);

  const handleToggle = useCallback((id) => {
    setTodos(prevTodos =>
      prevTodos.map(todo =>
        todo.id === id ? { ...todo, done: !todo.done } : todo
      )
    );
  }, []);

  const handleDelete = useCallback((id) => {
    setTodos(prevTodos => prevTodos.filter(todo => todo.id !== id));
  }, []);

  return (
    <ul>
      {todos.map(todo => (
        <TodoItem
          key={todo.id}
          todo={todo}
          onToggle={handleToggle}
          onDelete={handleDelete}
        />
      ))}
    </ul>
  );
}
```

### useRef

The useRef hook lets you reference a value that's not needed for rendering.

**Accessing DOM Elements:**
```jsx
import { useRef } from 'react';

function TextInput() {
  const inputRef = useRef(null);

  function handleClick() {
    inputRef.current.focus();
  }

  return (
    <>
      <input ref={inputRef} />
      <button onClick={handleClick}>Focus input</button>
    </>
  );
}
```

**Storing Mutable Values:**
```jsx
function Stopwatch() {
  const [time, setTime] = useState(0);
  const intervalRef = useRef(null);

  function handleStart() {
    intervalRef.current = setInterval(() => {
      setTime(t => t + 1);
    }, 10);
  }

  function handleStop() {
    clearInterval(intervalRef.current);
  }

  return (
    <div>
      <p>Time: {(time / 100).toFixed(2)}s</p>
      <button onClick={handleStart}>Start</button>
      <button onClick={handleStop}>Stop</button>
    </div>
  );
}
```

**Video Player Control (Context7 Pattern):**
```jsx
import { useRef, useState } from 'react';

function VideoPlayer({ src, isPlaying }) {
  const ref = useRef(null);

  useEffect(() => {
    if (isPlaying) {
      ref.current.play();
    } else {
      ref.current.pause();
    }
  }, [isPlaying]);

  return <video ref={ref} src={src} loop playsInline />;
}

function App() {
  const [isPlaying, setIsPlaying] = useState(false);

  return (
    <>
      <button onClick={() => setIsPlaying(!isPlaying)}>
        {isPlaying ? 'Pause' : 'Play'}
      </button>
      <VideoPlayer
        isPlaying={isPlaying}
        src="https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4"
      />
    </>
  );
}
```

## State Management Patterns

### Local State Pattern

Use local state for component-specific data that doesn't need to be shared.

```jsx
function LoginForm() {
  const [formData, setFormData] = useState({
    username: '',
    password: '',
    rememberMe: false
  });
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleChange = (field) => (e) => {
    const value = e.target.type === 'checkbox' ? e.target.checked : e.target.value;
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const validate = () => {
    const newErrors = {};
    if (!formData.username) newErrors.username = 'Required';
    if (!formData.password) newErrors.password = 'Required';
    return newErrors;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const newErrors = validate();

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    setIsSubmitting(true);
    try {
      await login(formData);
    } catch (error) {
      setErrors({ submit: error.message });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={formData.username}
        onChange={handleChange('username')}
        placeholder="Username"
      />
      {errors.username && <span>{errors.username}</span>}

      <input
        type="password"
        value={formData.password}
        onChange={handleChange('password')}
        placeholder="Password"
      />
      {errors.password && <span>{errors.password}</span>}

      <label>
        <input
          type="checkbox"
          checked={formData.rememberMe}
          onChange={handleChange('rememberMe')}
        />
        Remember me
      </label>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Logging in...' : 'Log in'}
      </button>

      {errors.submit && <div>{errors.submit}</div>}
    </form>
  );
}
```

### Context API Pattern

Use Context for global or widely-shared state like themes, user authentication, or preferences.

**Theme Context with Provider:**
```jsx
import { createContext, useContext, useState } from 'react';

const ThemeContext = createContext(null);

export function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light');

  const toggleTheme = () => {
    setTheme(prevTheme => prevTheme === 'light' ? 'dark' : 'light');
  };

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
}

// Usage
function App() {
  return (
    <ThemeProvider>
      <Page />
    </ThemeProvider>
  );
}

function Page() {
  const { theme, toggleTheme } = useTheme();

  return (
    <div className={`page-${theme}`}>
      <button onClick={toggleTheme}>Toggle Theme</button>
    </div>
  );
}
```

### Reducer + Context Pattern (Context7 Best Practice)

Combine useReducer with Context for scalable state management.

**Task Management with Reducer + Context:**
```jsx
import { createContext, useContext, useReducer } from 'react';

// Context for tasks data
const TasksContext = createContext(null);

// Context for dispatch function
const TasksDispatchContext = createContext(null);

export function TasksProvider({ children }) {
  const [tasks, dispatch] = useReducer(tasksReducer, initialTasks);

  return (
    <TasksContext.Provider value={tasks}>
      <TasksDispatchContext.Provider value={dispatch}>
        {children}
      </TasksDispatchContext.Provider>
    </TasksContext.Provider>
  );
}

export function useTasks() {
  return useContext(TasksContext);
}

export function useTasksDispatch() {
  return useContext(TasksDispatchContext);
}

function tasksReducer(tasks, action) {
  switch (action.type) {
    case 'added': {
      return [...tasks, {
        id: action.id,
        text: action.text,
        done: false
      }];
    }
    case 'changed': {
      return tasks.map(t => {
        if (t.id === action.task.id) {
          return action.task;
        }
        return t;
      });
    }
    case 'deleted': {
      return tasks.filter(t => t.id !== action.id);
    }
    default: {
      throw Error('Unknown action: ' + action.type);
    }
  }
}

const initialTasks = [
  { id: 0, text: 'Philosopher's Path', done: true },
  { id: 1, text: 'Visit the temple', done: false },
  { id: 2, text: 'Drink matcha', done: false }
];

// Component using the pattern
function AddTask() {
  const [text, setText] = useState('');
  const dispatch = useTasksDispatch();

  return (
    <>
      <input
        placeholder="Add task"
        value={text}
        onChange={e => setText(e.target.value)}
      />
      <button onClick={() => {
        setText('');
        dispatch({
          type: 'added',
          id: nextId++,
          text: text,
        });
      }}>Add</button>
    </>
  );
}

function TaskList() {
  const tasks = useTasks();
  return (
    <ul>
      {tasks.map(task => (
        <Task key={task.id} task={task} />
      ))}
    </ul>
  );
}

function Task({ task }) {
  const [isEditing, setIsEditing] = useState(false);
  const dispatch = useTasksDispatch();

  let taskContent;
  if (isEditing) {
    taskContent = (
      <>
        <input
          value={task.text}
          onChange={e => {
            dispatch({
              type: 'changed',
              task: {
                ...task,
                text: e.target.value
              }
            });
          }} />
        <button onClick={() => setIsEditing(false)}>
          Save
        </button>
      </>
    );
  } else {
    taskContent = (
      <>
        {task.text}
        <button onClick={() => setIsEditing(true)}>
          Edit
        </button>
      </>
    );
  }

  return (
    <label>
      <input
        type="checkbox"
        checked={task.done}
        onChange={e => {
          dispatch({
            type: 'changed',
            task: {
              ...task,
              done: e.target.checked
            }
          });
        }}
      />
      {taskContent}
      <button onClick={() => {
        dispatch({
          type: 'deleted',
          id: task.id
        });
      }}>
        Delete
      </button>
    </label>
  );
}

let nextId = 3;
```

## Custom Hooks

Custom hooks let you extract component logic into reusable functions.

### Basic Custom Hook

```jsx
import { useState, useEffect } from 'react';

function useWindowSize() {
  const [size, setSize] = useState({
    width: window.innerWidth,
    height: window.innerHeight
  });

  useEffect(() => {
    function handleResize() {
      setSize({
        width: window.innerWidth,
        height: window.innerHeight
      });
    }

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return size;
}

// Usage
function Component() {
  const { width, height } = useWindowSize();
  return <div>{width} x {height}</div>;
}
```

### Online Status Hook (Context7 Pattern)

```jsx
import { useState, useEffect } from 'react';

function useOnlineStatus() {
  const [isOnline, setIsOnline] = useState(true);

  useEffect(() => {
    function handleOnline() {
      setIsOnline(true);
    }

    function handleOffline() {
      setIsOnline(false);
    }

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  return isOnline;
}

// Usage
function StatusBar() {
  const isOnline = useOnlineStatus();
  return <h1>{isOnline ? '✅ Online' : '❌ Disconnected'}</h1>;
}
```

### Form Hook

```jsx
function useForm(initialValues, onSubmit) {
  const [values, setValues] = useState(initialValues);
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleChange = (name, value) => {
    setValues(prev => ({ ...prev, [name]: value }));
    // Clear error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: null }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);

    try {
      await onSubmit(values);
    } catch (error) {
      setErrors({ submit: error.message });
    } finally {
      setIsSubmitting(false);
    }
  };

  const reset = () => {
    setValues(initialValues);
    setErrors({});
  };

  return {
    values,
    errors,
    isSubmitting,
    handleChange,
    handleSubmit,
    setErrors,
    reset
  };
}

// Usage
function ContactForm() {
  const { values, errors, isSubmitting, handleChange, handleSubmit } = useForm(
    { name: '', email: '', message: '' },
    async (data) => {
      await fetch('/api/contact', {
        method: 'POST',
        body: JSON.stringify(data)
      });
    }
  );

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={values.name}
        onChange={(e) => handleChange('name', e.target.value)}
      />
      {errors.name && <span>{errors.name}</span>}

      <input
        value={values.email}
        onChange={(e) => handleChange('email', e.target.value)}
      />
      {errors.email && <span>{errors.email}</span>}

      <textarea
        value={values.message}
        onChange={(e) => handleChange('message', e.target.value)}
      />
      {errors.message && <span>{errors.message}</span>}

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Sending...' : 'Send'}
      </button>
    </form>
  );
}
```

### Fetch Hook

```jsx
function useFetch(url, options = {}) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let cancelled = false;

    async function fetchData() {
      try {
        setLoading(true);
        const response = await fetch(url, options);

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }

        const result = await response.json();

        if (!cancelled) {
          setData(result);
          setError(null);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err.message);
          setData(null);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    fetchData();

    return () => {
      cancelled = true;
    };
  }, [url, JSON.stringify(options)]);

  return { data, loading, error };
}

// Usage
function UserProfile({ userId }) {
  const { data, loading, error } = useFetch(`/api/users/${userId}`);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return <div>{data.name}</div>;
}
```

### Local Storage Hook

```jsx
function useLocalStorage(key, initialValue) {
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(error);
      return initialValue;
    }
  });

  const setValue = (value) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(error);
    }
  };

  return [storedValue, setValue];
}

// Usage
function Settings() {
  const [theme, setTheme] = useLocalStorage('theme', 'light');
  const [fontSize, setFontSize] = useLocalStorage('fontSize', 16);

  return (
    <div>
      <select value={theme} onChange={(e) => setTheme(e.target.value)}>
        <option value="light">Light</option>
        <option value="dark">Dark</option>
      </select>

      <input
        type="number"
        value={fontSize}
        onChange={(e) => setFontSize(parseInt(e.target.value))}
      />
    </div>
  );
}
```

## Performance Optimization

### React.memo

Memoize components to prevent unnecessary re-renders.

```jsx
import { memo } from 'react';

const ExpensiveComponent = memo(function ExpensiveComponent({ data, onAction }) {
  console.log('Rendering expensive component');

  return (
    <div>
      {data.map(item => (
        <div key={item.id}>{item.name}</div>
      ))}
      <button onClick={onAction}>Action</button>
    </div>
  );
});

// With custom comparison
const CustomMemoComponent = memo(
  function Component({ user }) {
    return <div>{user.name}</div>;
  },
  (prevProps, nextProps) => {
    // Return true if props are equal (skip re-render)
    return prevProps.user.id === nextProps.user.id;
  }
);
```

### Lazy Loading

Load components on demand to reduce initial bundle size.

```jsx
import { lazy, Suspense } from 'react';

const HeavyComponent = lazy(() => import('./HeavyComponent'));
const AdminPanel = lazy(() => import('./AdminPanel'));

function App() {
  return (
    <div>
      <Suspense fallback={<div>Loading...</div>}>
        <HeavyComponent />
      </Suspense>
    </div>
  );
}

// Lazy loading with routes
function Dashboard() {
  const [showAdmin, setShowAdmin] = useState(false);

  return (
    <div>
      <button onClick={() => setShowAdmin(true)}>
        Show Admin Panel
      </button>

      {showAdmin && (
        <Suspense fallback={<Spinner />}>
          <AdminPanel />
        </Suspense>
      )}
    </div>
  );
}
```

### Code Splitting

Split your code into smaller chunks for better performance.

```jsx
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

const Home = lazy(() => import('./pages/Home'));
const About = lazy(() => import('./pages/About'));
const Dashboard = lazy(() => import('./pages/Dashboard'));

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<div>Loading page...</div>}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="/dashboard" element={<Dashboard />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}
```

### Virtual Scrolling

Render only visible items in large lists.

```jsx
function VirtualList({ items, height, itemHeight }) {
  const [scrollTop, setScrollTop] = useState(0);

  const startIndex = Math.floor(scrollTop / itemHeight);
  const endIndex = Math.min(
    startIndex + Math.ceil(height / itemHeight),
    items.length
  );

  const visibleItems = items.slice(startIndex, endIndex);

  const offsetY = startIndex * itemHeight;
  const totalHeight = items.length * itemHeight;

  return (
    <div
      style={{ height, overflow: 'auto' }}
      onScroll={(e) => setScrollTop(e.target.scrollTop)}
    >
      <div style={{ height: totalHeight, position: 'relative' }}>
        <div style={{ transform: `translateY(${offsetY}px)` }}>
          {visibleItems.map((item, index) => (
            <div
              key={startIndex + index}
              style={{ height: itemHeight }}
            >
              {item}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
```

## Best Practices from Context7 Research

### 1. Proper Dependency Arrays

Always include all dependencies in useEffect, useMemo, and useCallback.

```jsx
// ❌ Bad - missing dependencies
useEffect(() => {
  fetchData(userId);
}, []);

// ✅ Good - all dependencies included
useEffect(() => {
  fetchData(userId);
}, [userId]);
```

### 2. Cleanup Functions

Always cleanup side effects to prevent memory leaks.

```jsx
useEffect(() => {
  const subscription = api.subscribe(id);

  return () => {
    subscription.unsubscribe();
  };
}, [id]);
```

### 3. Separate Concerns

Split context for data and dispatch to optimize re-renders.

```jsx
// ✅ Good - separate contexts
const TasksContext = createContext(null);
const TasksDispatchContext = createContext(null);

// Components that only dispatch won't re-render when tasks change
function AddTask() {
  const dispatch = useTasksDispatch(); // No re-render when tasks change
  // ...
}
```

### 4. Avoid Inline Object Creation

Use useMemo or useCallback to prevent unnecessary re-renders.

```jsx
// ❌ Bad - new object on every render
<Component style={{ margin: 10 }} />

// ✅ Good - memoized object
const style = useMemo(() => ({ margin: 10 }), []);
<Component style={style} />
```

### 5. State Updater Functions

Use updater functions when new state depends on previous state.

```jsx
// ❌ Bad - may use stale state
setCount(count + 1);

// ✅ Good - uses current state
setCount(prevCount => prevCount + 1);
```

### 6. Extract Complex Logic

Move complex state logic to reducers or custom hooks.

```jsx
// ✅ Good - complex logic in reducer
function cartReducer(state, action) {
  switch (action.type) {
    case 'add_item':
      // Complex logic here
      return newState;
    case 'remove_item':
      // Complex logic here
      return newState;
    default:
      return state;
  }
}
```

### 7. Key Props for Lists

Always provide unique keys for list items.

```jsx
// ❌ Bad - using index as key
{items.map((item, index) => <div key={index}>{item}</div>)}

// ✅ Good - using unique ID
{items.map(item => <div key={item.id}>{item.text}</div>)}
```

### 8. Controlled Components

Prefer controlled components for form inputs.

```jsx
function Form() {
  const [value, setValue] = useState('');

  return (
    <input
      value={value}
      onChange={(e) => setValue(e.target.value)}
    />
  );
}
```

### 9. Error Boundaries

Implement error boundaries to catch and handle errors gracefully.

```jsx
class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Error caught:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return <h1>Something went wrong.</h1>;
    }

    return this.props.children;
  }
}

// Usage
<ErrorBoundary>
  <MyComponent />
</ErrorBoundary>
```

### 10. Prop Types or TypeScript

Use PropTypes or TypeScript for type checking.

```jsx
import PropTypes from 'prop-types';

function User({ name, age, email }) {
  return <div>{name} ({age})</div>;
}

User.propTypes = {
  name: PropTypes.string.isRequired,
  age: PropTypes.number.isRequired,
  email: PropTypes.string
};

User.defaultProps = {
  email: 'no-email@example.com'
};
```

## Additional Examples

### Example 1: Multi-Step Form

```jsx
function MultiStepForm() {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({
    personalInfo: {},
    address: {},
    preferences: {}
  });

  const updateFormData = (section, data) => {
    setFormData(prev => ({
      ...prev,
      [section]: { ...prev[section], ...data }
    }));
  };

  const nextStep = () => setStep(s => s + 1);
  const prevStep = () => setStep(s => s - 1);

  return (
    <div>
      {step === 1 && (
        <PersonalInfoStep
          data={formData.personalInfo}
          onNext={(data) => {
            updateFormData('personalInfo', data);
            nextStep();
          }}
        />
      )}
      {step === 2 && (
        <AddressStep
          data={formData.address}
          onNext={(data) => {
            updateFormData('address', data);
            nextStep();
          }}
          onPrev={prevStep}
        />
      )}
      {step === 3 && (
        <PreferencesStep
          data={formData.preferences}
          onSubmit={(data) => {
            updateFormData('preferences', data);
            submitForm({ ...formData, preferences: data });
          }}
          onPrev={prevStep}
        />
      )}
    </div>
  );
}
```

### Example 2: Infinite Scroll

```jsx
function InfiniteScroll() {
  const [items, setItems] = useState([]);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);

  const loadMore = useCallback(async () => {
    if (loading || !hasMore) return;

    setLoading(true);
    try {
      const newItems = await fetchItems(page);
      setItems(prev => [...prev, ...newItems]);
      setHasMore(newItems.length > 0);
      setPage(p => p + 1);
    } finally {
      setLoading(false);
    }
  }, [page, loading, hasMore]);

  useEffect(() => {
    const handleScroll = () => {
      if (
        window.innerHeight + window.scrollY >=
        document.documentElement.scrollHeight - 500
      ) {
        loadMore();
      }
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, [loadMore]);

  return (
    <div>
      {items.map(item => <Item key={item.id} data={item} />)}
      {loading && <div>Loading...</div>}
      {!hasMore && <div>No more items</div>}
    </div>
  );
}
```

### Example 3: Debounced Search

```jsx
function useDebounce(value, delay) {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);

  return debouncedValue;
}

function SearchComponent() {
  const [searchTerm, setSearchTerm] = useState('');
  const debouncedSearchTerm = useDebounce(searchTerm, 500);
  const [results, setResults] = useState([]);

  useEffect(() => {
    if (debouncedSearchTerm) {
      searchAPI(debouncedSearchTerm).then(setResults);
    } else {
      setResults([]);
    }
  }, [debouncedSearchTerm]);

  return (
    <div>
      <input
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
        placeholder="Search..."
      />
      <ul>
        {results.map(result => (
          <li key={result.id}>{result.title}</li>
        ))}
      </ul>
    </div>
  );
}
```

### Example 4: Modal with Portal

```jsx
import { createPortal } from 'react-dom';

function Modal({ isOpen, onClose, children }) {
  if (!isOpen) return null;

  return createPortal(
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <button className="close-button" onClick={onClose}>×</button>
        {children}
      </div>
    </div>,
    document.body
  );
}

// Usage
function App() {
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <div>
      <button onClick={() => setIsModalOpen(true)}>Open Modal</button>
      <Modal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)}>
        <h2>Modal Content</h2>
        <p>This is a modal dialog</p>
      </Modal>
    </div>
  );
}
```

### Example 5: Drag and Drop

```jsx
function DragDropList() {
  const [items, setItems] = useState([
    { id: 1, text: 'Item 1' },
    { id: 2, text: 'Item 2' },
    { id: 3, text: 'Item 3' }
  ]);

  const [draggedItem, setDraggedItem] = useState(null);

  const handleDragStart = (item) => {
    setDraggedItem(item);
  };

  const handleDragOver = (e) => {
    e.preventDefault();
  };

  const handleDrop = (targetItem) => {
    if (!draggedItem || draggedItem.id === targetItem.id) return;

    const draggedIndex = items.findIndex(i => i.id === draggedItem.id);
    const targetIndex = items.findIndex(i => i.id === targetItem.id);

    const newItems = [...items];
    newItems.splice(draggedIndex, 1);
    newItems.splice(targetIndex, 0, draggedItem);

    setItems(newItems);
    setDraggedItem(null);
  };

  return (
    <ul>
      {items.map(item => (
        <li
          key={item.id}
          draggable
          onDragStart={() => handleDragStart(item)}
          onDragOver={handleDragOver}
          onDrop={() => handleDrop(item)}
        >
          {item.text}
        </li>
      ))}
    </ul>
  );
}
```

## Summary

This React development skill covers:

1. **Core Concepts**: Components, JSX, Props, State
2. **Essential Hooks**: useState, useEffect, useContext, useReducer, useMemo, useCallback, useRef
3. **State Management**: Local state, Context API, Reducer + Context pattern
4. **Custom Hooks**: Reusable logic extraction patterns
5. **Performance**: Memoization, lazy loading, code splitting, virtual scrolling
6. **Best Practices**: From Context7 research including proper dependencies, cleanup, separation of concerns
7. **Real-world Examples**: Forms, infinite scroll, search, modals, drag-and-drop

The patterns and examples are based on official React documentation (Trust Score: 10) and represent modern React development practices focusing on functional components and hooks.
