---
name: react-patterns
description: Modern React development with hooks, component patterns, state management, and performance optimization for building scalable applications
---

# React Patterns - Modern Development Guide

A comprehensive skill for mastering modern React development patterns, including React 18+ features, hooks, component composition, state management strategies, and performance optimization techniques for building scalable web applications.

## When to Use This Skill

Use this skill when:

- Building modern React applications with functional components and hooks
- Implementing complex state management with useReducer and Context API
- Optimizing React application performance with memoization techniques
- Creating reusable custom hooks for shared logic
- Working with Server Components and React Server Components (RSC)
- Managing forms, side effects, and asynchronous operations
- Refactoring class components to modern functional patterns
- Building type-safe React applications with proper patterns
- Implementing advanced component composition patterns
- Debugging React performance issues and unnecessary re-renders

## Core Concepts

### React Philosophy

Modern React emphasizes:

- **Functional Components**: Pure functions that return JSX
- **Hooks**: Composable state and side effect management
- **Declarative UI**: Describe what the UI should look like, React handles updates
- **Component Composition**: Build complex UIs from simple, reusable components
- **Unidirectional Data Flow**: Props flow down, events flow up
- **Immutability**: Never mutate state directly, always create new objects/arrays

### Component Types

1. **Presentational Components**: Focus on UI, receive data via props
2. **Container Components**: Handle logic, state, and side effects
3. **Server Components**: Render on the server, no client JavaScript
4. **Client Components**: Interactive components marked with `"use client"`
5. **Async Components**: Server components that can await data

## React Hooks Reference

### Built-in State Hooks

#### useState

Manage local component state for simple values.

**Syntax:**
```javascript
const [state, setState] = useState(initialValue);
```

**Basic Example:**
```javascript
import { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
      <button onClick={() => setCount(prev => prev + 1)}>Increment (functional)</button>
    </div>
  );
}
```

**Best Practices:**
- Use functional updates when new state depends on previous state
- Keep state as local as possible
- Don't store derived values in state
- Initialize with functions for expensive computations

**Multiple State Variables:**
```javascript
function Form() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [age, setAge] = useState(0);

  return (
    <form>
      <input value={name} onChange={e => setName(e.target.value)} />
      <input value={email} onChange={e => setEmail(e.target.value)} />
      <input type="number" value={age} onChange={e => setAge(Number(e.target.value))} />
    </form>
  );
}
```

**Lazy Initialization:**
```javascript
function ExpensiveComponent() {
  // Function only runs once on initial render
  const [state, setState] = useState(() => {
    const initialValue = expensiveComputation();
    return initialValue;
  });

  return <div>{state}</div>;
}
```

#### useReducer

Manage complex state logic with a reducer pattern (similar to Redux).

**Syntax:**
```javascript
const [state, dispatch] = useReducer(reducer, initialState, init?);
```

**Task Manager Example:**
```javascript
import { useReducer } from 'react';

function tasksReducer(tasks, action) {
  switch (action.type) {
    case 'added':
      return [...tasks, {
        id: action.id,
        text: action.text,
        done: false
      }];
    case 'changed':
      return tasks.map(t =>
        t.id === action.task.id ? action.task : t
      );
    case 'deleted':
      return tasks.filter(t => t.id !== action.id);
    default:
      throw Error('Unknown action: ' + action.type);
  }
}

function TaskApp() {
  const [tasks, dispatch] = useReducer(tasksReducer, []);

  function handleAddTask(text) {
    dispatch({
      type: 'added',
      id: Date.now(),
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
      <AddTask onAddTask={handleAddTask} />
      <TaskList
        tasks={tasks}
        onChangeTask={handleChangeTask}
        onDeleteTask={handleDeleteTask}
      />
    </>
  );
}
```

**When to use useReducer:**
- Multiple related state values
- Complex state update logic
- State transitions follow predictable patterns
- Need to optimize performance with many updates
- Want to separate state logic from component

#### useContext

Access context values without prop drilling.

**Syntax:**
```javascript
const value = useContext(SomeContext);
```

**Theme Context Example:**
```javascript
import { createContext, useContext, useState } from 'react';

const ThemeContext = createContext(null);

export function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light');

  const toggleTheme = () => {
    setTheme(prev => prev === 'light' ? 'dark' : 'light');
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
function Button() {
  const { theme, toggleTheme } = useTheme();

  return (
    <button
      onClick={toggleTheme}
      className={theme === 'dark' ? 'btn-dark' : 'btn-light'}
    >
      Toggle Theme
    </button>
  );
}
```

**Combining useReducer + useContext:**
```javascript
import { createContext, useContext, useReducer } from 'react';

const TasksContext = createContext(null);
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

// Usage in components
function TaskList() {
  const tasks = useTasks();
  const dispatch = useTasksDispatch();

  return (
    <ul>
      {tasks.map(task => (
        <li key={task.id}>
          {task.text}
          <button onClick={() => dispatch({ type: 'deleted', id: task.id })}>
            Delete
          </button>
        </li>
      ))}
    </ul>
  );
}
```

### Effect Hooks

#### useEffect

Synchronize component with external systems (APIs, DOM, subscriptions).

**Syntax:**
```javascript
useEffect(() => {
  // Effect logic
  return () => {
    // Cleanup logic
  };
}, [dependencies]);
```

**Data Fetching Example:**
```javascript
import { useState, useEffect } from 'react';

function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let ignore = false; // Prevent race conditions

    async function fetchUser() {
      try {
        setLoading(true);
        const response = await fetch(`/api/users/${userId}`);
        const data = await response.json();

        if (!ignore) {
          setUser(data);
        }
      } catch (err) {
        if (!ignore) {
          setError(err.message);
        }
      } finally {
        if (!ignore) {
          setLoading(false);
        }
      }
    }

    fetchUser();

    return () => {
      ignore = true; // Cleanup
    };
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  return <div>User: {user?.name}</div>;
}
```

**Subscription Example:**
```javascript
function ChatRoom({ roomId }) {
  const [messages, setMessages] = useState([]);

  useEffect(() => {
    const connection = createConnection(roomId);

    connection.on('message', (msg) => {
      setMessages(prev => [...prev, msg]);
    });

    connection.connect();

    return () => {
      connection.disconnect(); // Cleanup on unmount or roomId change
    };
  }, [roomId]);

  return (
    <div>
      {messages.map((msg, i) => (
        <div key={i}>{msg}</div>
      ))}
    </div>
  );
}
```

**Common Effect Patterns:**
```javascript
// Run once on mount
useEffect(() => {
  console.log('Component mounted');
}, []); // Empty dependency array

// Run on every render
useEffect(() => {
  console.log('Component rendered');
}); // No dependency array

// Run when specific values change
useEffect(() => {
  console.log('userId changed:', userId);
}, [userId]); // Dependency array with values

// Cleanup on unmount
useEffect(() => {
  const timer = setTimeout(() => {
    console.log('Delayed action');
  }, 1000);

  return () => clearTimeout(timer);
}, []);
```

#### useLayoutEffect

Synchronous version of useEffect, runs before browser paint.

**Use Cases:**
- Measuring DOM elements
- Synchronous DOM mutations
- Preventing visual flickering

**Example:**
```javascript
import { useLayoutEffect, useRef, useState } from 'react';

function Tooltip() {
  const ref = useRef(null);
  const [tooltipHeight, setTooltipHeight] = useState(0);

  useLayoutEffect(() => {
    const { height } = ref.current.getBoundingClientRect();
    setTooltipHeight(height); // Synchronous update before paint
  }, []);

  return (
    <div ref={ref}>
      Tooltip content (height: {tooltipHeight}px)
    </div>
  );
}
```

### Performance Hooks

#### useMemo

Cache expensive computations between renders.

**Syntax:**
```javascript
const cachedValue = useMemo(() => computeExpensiveValue(a, b), [a, b]);
```

**Example:**
```javascript
import { useMemo } from 'react';

function TodoList({ todos, filter }) {
  // Only recompute when todos or filter changes
  const visibleTodos = useMemo(() => {
    console.log('Filtering todos...');
    return todos.filter(todo => {
      if (filter === 'all') return true;
      if (filter === 'active') return !todo.done;
      if (filter === 'completed') return todo.done;
      return true;
    });
  }, [todos, filter]);

  return (
    <ul>
      {visibleTodos.map(todo => (
        <li key={todo.id}>{todo.text}</li>
      ))}
    </ul>
  );
}
```

**When to use useMemo:**
- Expensive calculations (filtering, sorting large arrays)
- Preventing unnecessary re-renders of child components
- Stabilizing object/array references passed as dependencies

**Anti-pattern (unnecessary):**
```javascript
// ❌ Don't use for simple calculations
const sum = useMemo(() => a + b, [a, b]); // Overkill

// ✅ Just compute directly
const sum = a + b;
```

#### useCallback

Memoize function references between renders.

**Syntax:**
```javascript
const cachedFn = useCallback(() => {
  // Function logic
}, [dependencies]);
```

**Example:**
```javascript
import { useState, useCallback, memo } from 'react';

const TodoItem = memo(function TodoItem({ todo, onChange, onDelete }) {
  console.log('TodoItem rendered:', todo.id);

  return (
    <li>
      <input
        type="checkbox"
        checked={todo.done}
        onChange={() => onChange(todo)}
      />
      {todo.text}
      <button onClick={() => onDelete(todo.id)}>Delete</button>
    </li>
  );
});

function TodoList() {
  const [todos, setTodos] = useState([]);

  // Memoize handlers to prevent TodoItem re-renders
  const handleChange = useCallback((todo) => {
    setTodos(prev => prev.map(t =>
      t.id === todo.id ? { ...t, done: !t.done } : t
    ));
  }, []);

  const handleDelete = useCallback((id) => {
    setTodos(prev => prev.filter(t => t.id !== id));
  }, []);

  return (
    <ul>
      {todos.map(todo => (
        <TodoItem
          key={todo.id}
          todo={todo}
          onChange={handleChange}
          onDelete={handleDelete}
        />
      ))}
    </ul>
  );
}
```

**When to use useCallback:**
- Passing callbacks to memoized child components
- Function is a dependency of useEffect or other hooks
- Optimizing expensive event handlers

#### React.memo

Memoize entire component to prevent unnecessary re-renders.

**Syntax:**
```javascript
const MemoizedComponent = memo(function Component(props) {
  // Component logic
}, arePropsEqual?);
```

**Example:**
```javascript
import { memo } from 'react';

const ExpensiveComponent = memo(function ExpensiveComponent({ data, onClick }) {
  console.log('ExpensiveComponent rendered');

  return (
    <div>
      {data.map(item => (
        <div key={item.id} onClick={() => onClick(item)}>
          {item.name}
        </div>
      ))}
    </div>
  );
});

// With custom comparison
const CustomMemoComponent = memo(
  function CustomMemoComponent({ user }) {
    return <div>{user.name}</div>;
  },
  (prevProps, nextProps) => {
    // Return true if props are equal (skip re-render)
    return prevProps.user.id === nextProps.user.id;
  }
);
```

### Ref Hooks

#### useRef

Create mutable reference that persists across renders.

**Syntax:**
```javascript
const ref = useRef(initialValue);
```

**DOM Reference Example:**
```javascript
import { useRef } from 'react';

function VideoPlayer({ src, isPlaying }) {
  const videoRef = useRef(null);

  useEffect(() => {
    if (isPlaying) {
      videoRef.current.play();
    } else {
      videoRef.current.pause();
    }
  }, [isPlaying]);

  return <video ref={videoRef} src={src} />;
}
```

**Storing Mutable Values:**
```javascript
function Timer() {
  const intervalRef = useRef(null);
  const [count, setCount] = useState(0);

  function start() {
    if (intervalRef.current) return; // Already running

    intervalRef.current = setInterval(() => {
      setCount(c => c + 1);
    }, 1000);
  }

  function stop() {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
  }

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={start}>Start</button>
      <button onClick={stop}>Stop</button>
    </div>
  );
}
```

**Previous Value Pattern:**
```javascript
function usePrevious(value) {
  const ref = useRef();

  useEffect(() => {
    ref.current = value;
  }, [value]);

  return ref.current;
}

// Usage
function Counter({ count }) {
  const prevCount = usePrevious(count);

  return (
    <div>
      <p>Current: {count}</p>
      <p>Previous: {prevCount}</p>
    </div>
  );
}
```

### Transition Hooks (React 18+)

#### useTransition

Mark state updates as non-urgent, keeping UI responsive.

**Syntax:**
```javascript
const [isPending, startTransition] = useTransition();
```

**Example:**
```javascript
import { useState, useTransition } from 'react';

function SearchResults() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [isPending, startTransition] = useTransition();

  function handleChange(e) {
    const value = e.target.value;
    setQuery(value); // Urgent update (input value)

    startTransition(() => {
      // Non-urgent update (search results)
      const filtered = performExpensiveSearch(value);
      setResults(filtered);
    });
  }

  return (
    <div>
      <input value={query} onChange={handleChange} />
      {isPending && <div>Searching...</div>}
      <ul>
        {results.map(result => (
          <li key={result.id}>{result.name}</li>
        ))}
      </ul>
    </div>
  );
}
```

#### useDeferredValue

Defer updating part of the UI.

**Syntax:**
```javascript
const deferredValue = useDeferredValue(value);
```

**Example:**
```javascript
import { useState, useDeferredValue, memo } from 'react';

const SlowList = memo(function SlowList({ items }) {
  // Intentionally slow rendering
  return (
    <ul>
      {items.map(item => (
        <li key={item.id}>{item.name}</li>
      ))}
    </ul>
  );
});

function App() {
  const [text, setText] = useState('');
  const deferredText = useDeferredValue(text);

  return (
    <>
      <input value={text} onChange={e => setText(e.target.value)} />
      <SlowList items={filterItems(deferredText)} />
    </>
  );
}
```

### Server Action Hooks (RSC)

#### useActionState

Manage server action state and pending status.

**Syntax:**
```javascript
const [state, formAction, isPending] = useActionState(serverAction, initialState);
```

**Example:**
```javascript
"use client";

import { useActionState } from 'react';
import { updateName } from './actions';

function UpdateNameForm() {
  const [state, submitAction, isPending] = useActionState(
    updateName,
    { error: null }
  );

  return (
    <form action={submitAction}>
      <input type="text" name="name" disabled={isPending} />
      {state.error && <span className="error">{state.error}</span>}
      <button type="submit" disabled={isPending}>
        {isPending ? 'Updating...' : 'Update'}
      </button>
    </form>
  );
}
```

**Server Action (actions.js):**
```javascript
"use server";

export async function updateName(prevState, formData) {
  const name = formData.get('name');

  if (!name) {
    return { error: 'Name is required' };
  }

  try {
    await db.users.updateName(name);
    return { error: null };
  } catch (err) {
    return { error: 'Failed to update name' };
  }
}
```

## Custom Hooks Patterns

Custom hooks let you extract and reuse stateful logic across components.

### Naming Convention

Always prefix custom hooks with `use`:
```javascript
useCustomHook // ✅ Correct
customHook    // ❌ Wrong
```

### Data Fetching Hook

```javascript
import { useState, useEffect } from 'react';

export function useFetch(url) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let ignore = false;

    async function fetchData() {
      try {
        setLoading(true);
        setError(null);

        const response = await fetch(url);
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }

        const result = await response.json();

        if (!ignore) {
          setData(result);
        }
      } catch (err) {
        if (!ignore) {
          setError(err.message);
        }
      } finally {
        if (!ignore) {
          setLoading(false);
        }
      }
    }

    fetchData();

    return () => {
      ignore = true;
    };
  }, [url]);

  return { data, loading, error };
}

// Usage
function UserProfile({ userId }) {
  const { data: user, loading, error } = useFetch(`/api/users/${userId}`);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  return <div>{user.name}</div>;
}
```

### Form Input Hook

```javascript
import { useState } from 'react';

export function useFormInput(initialValue = '') {
  const [value, setValue] = useState(initialValue);

  function handleChange(e) {
    setValue(e.target.value);
  }

  function reset() {
    setValue(initialValue);
  }

  return {
    value,
    onChange: handleChange,
    reset
  };
}

// Usage
function LoginForm() {
  const email = useFormInput('');
  const password = useFormInput('');

  function handleSubmit(e) {
    e.preventDefault();
    console.log('Email:', email.value);
    console.log('Password:', password.value);
    email.reset();
    password.reset();
  }

  return (
    <form onSubmit={handleSubmit}>
      <input type="email" {...email} placeholder="Email" />
      <input type="password" {...password} placeholder="Password" />
      <button type="submit">Login</button>
    </form>
  );
}
```

### Local Storage Hook

```javascript
import { useState, useEffect } from 'react';

export function useLocalStorage(key, initialValue) {
  const [value, setValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(error);
      return initialValue;
    }
  });

  useEffect(() => {
    try {
      window.localStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error(error);
    }
  }, [key, value]);

  return [value, setValue];
}

// Usage
function Settings() {
  const [theme, setTheme] = useLocalStorage('theme', 'light');
  const [language, setLanguage] = useLocalStorage('language', 'en');

  return (
    <div>
      <select value={theme} onChange={e => setTheme(e.target.value)}>
        <option value="light">Light</option>
        <option value="dark">Dark</option>
      </select>
      <select value={language} onChange={e => setLanguage(e.target.value)}>
        <option value="en">English</option>
        <option value="es">Spanish</option>
      </select>
    </div>
  );
}
```

### Debounce Hook

```javascript
import { useState, useEffect } from 'react';

export function useDebounce(value, delay = 500) {
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

// Usage
function SearchComponent() {
  const [searchTerm, setSearchTerm] = useState('');
  const debouncedSearchTerm = useDebounce(searchTerm, 500);

  useEffect(() => {
    if (debouncedSearchTerm) {
      // Perform search
      console.log('Searching for:', debouncedSearchTerm);
    }
  }, [debouncedSearchTerm]);

  return (
    <input
      type="text"
      value={searchTerm}
      onChange={e => setSearchTerm(e.target.value)}
      placeholder="Search..."
    />
  );
}
```

### Window Size Hook

```javascript
import { useState, useEffect } from 'react';

export function useWindowSize() {
  const [windowSize, setWindowSize] = useState({
    width: undefined,
    height: undefined,
  });

  useEffect(() => {
    function handleResize() {
      setWindowSize({
        width: window.innerWidth,
        height: window.innerHeight,
      });
    }

    handleResize(); // Set initial size
    window.addEventListener('resize', handleResize);

    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return windowSize;
}

// Usage
function ResponsiveComponent() {
  const { width, height } = useWindowSize();

  return (
    <div>
      <p>Window width: {width}px</p>
      <p>Window height: {height}px</p>
      {width < 768 ? <MobileView /> : <DesktopView />}
    </div>
  );
}
```

### Online Status Hook

```javascript
import { useState, useEffect } from 'react';

export function useOnlineStatus() {
  const [isOnline, setIsOnline] = useState(navigator.onLine);

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

  return (
    <div className={isOnline ? 'online' : 'offline'}>
      {isOnline ? '✅ Online' : '❌ Offline'}
    </div>
  );
}
```

## Component Patterns

### Compound Components

Build components that work together while sharing implicit state.

```javascript
import { createContext, useContext, useState } from 'react';

const TabsContext = createContext();

export function Tabs({ children, defaultValue }) {
  const [activeTab, setActiveTab] = useState(defaultValue);

  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
}

export function TabList({ children }) {
  return <div className="tab-list">{children}</div>;
}

export function Tab({ value, children }) {
  const { activeTab, setActiveTab } = useContext(TabsContext);
  const isActive = activeTab === value;

  return (
    <button
      className={`tab ${isActive ? 'active' : ''}`}
      onClick={() => setActiveTab(value)}
    >
      {children}
    </button>
  );
}

export function TabPanels({ children }) {
  return <div className="tab-panels">{children}</div>;
}

export function TabPanel({ value, children }) {
  const { activeTab } = useContext(TabsContext);

  if (activeTab !== value) return null;

  return <div className="tab-panel">{children}</div>;
}

// Usage
function App() {
  return (
    <Tabs defaultValue="tab1">
      <TabList>
        <Tab value="tab1">Tab 1</Tab>
        <Tab value="tab2">Tab 2</Tab>
        <Tab value="tab3">Tab 3</Tab>
      </TabList>

      <TabPanels>
        <TabPanel value="tab1">Content for Tab 1</TabPanel>
        <TabPanel value="tab2">Content for Tab 2</TabPanel>
        <TabPanel value="tab3">Content for Tab 3</TabPanel>
      </TabPanels>
    </Tabs>
  );
}
```

### Render Props

Share code between components using a prop whose value is a function.

```javascript
function DataFetcher({ url, render }) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(url)
      .then(res => res.json())
      .then(data => {
        setData(data);
        setLoading(false);
      });
  }, [url]);

  return render({ data, loading });
}

// Usage
function App() {
  return (
    <DataFetcher
      url="/api/users"
      render={({ data, loading }) => (
        loading ? <div>Loading...</div> : (
          <ul>
            {data?.map(user => (
              <li key={user.id}>{user.name}</li>
            ))}
          </ul>
        )
      )}
    />
  );
}
```

### Higher-Order Components (HOC)

Wrap components to enhance functionality.

```javascript
import { useEffect, useState } from 'react';

// HOC for data fetching
function withData(Component, url) {
  return function WithDataComponent(props) {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
      fetch(url)
        .then(res => res.json())
        .then(data => {
          setData(data);
          setLoading(false);
        });
    }, []);

    return <Component {...props} data={data} loading={loading} />;
  };
}

// Original component
function UserList({ data, loading }) {
  if (loading) return <div>Loading...</div>;

  return (
    <ul>
      {data?.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}

// Enhanced component
const UserListWithData = withData(UserList, '/api/users');

// Usage
function App() {
  return <UserListWithData />;
}
```

### Container/Presenter Pattern

Separate logic from presentation.

```javascript
// Container (logic)
function UserListContainer() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    fetchUsers().then(data => {
      setUsers(data);
      setLoading(false);
    });
  }, []);

  const filteredUsers = users.filter(user =>
    user.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <UserListPresenter
      users={filteredUsers}
      loading={loading}
      searchTerm={searchTerm}
      onSearchChange={setSearchTerm}
    />
  );
}

// Presenter (UI)
function UserListPresenter({ users, loading, searchTerm, onSearchChange }) {
  if (loading) return <div>Loading...</div>;

  return (
    <div>
      <input
        type="text"
        value={searchTerm}
        onChange={e => onSearchChange(e.target.value)}
        placeholder="Search users..."
      />
      <ul>
        {users.map(user => (
          <li key={user.id}>{user.name}</li>
        ))}
      </ul>
    </div>
  );
}
```

## Performance Optimization

### Identifying Performance Issues

Use React DevTools Profiler to identify:
- Components re-rendering unnecessarily
- Expensive render operations
- State update cascades

### Optimization Strategies

#### 1. Memoization

```javascript
import { memo, useMemo, useCallback } from 'react';

const ExpensiveList = memo(function ExpensiveList({ items, onItemClick }) {
  console.log('Rendering ExpensiveList');

  return (
    <ul>
      {items.map(item => (
        <li key={item.id} onClick={() => onItemClick(item.id)}>
          {item.name}
        </li>
      ))}
    </ul>
  );
});

function App() {
  const [items, setItems] = useState([]);
  const [count, setCount] = useState(0);

  // Memoize expensive computation
  const sortedItems = useMemo(() => {
    console.log('Sorting items...');
    return [...items].sort((a, b) => a.name.localeCompare(b.name));
  }, [items]);

  // Memoize callback
  const handleItemClick = useCallback((id) => {
    console.log('Item clicked:', id);
  }, []);

  return (
    <div>
      <button onClick={() => setCount(c => c + 1)}>Count: {count}</button>
      <ExpensiveList items={sortedItems} onItemClick={handleItemClick} />
    </div>
  );
}
```

#### 2. Code Splitting

```javascript
import { lazy, Suspense } from 'react';

// Lazy load components
const HeavyComponent = lazy(() => import('./HeavyComponent'));
const Dashboard = lazy(() => import('./Dashboard'));

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <HeavyComponent />
    </Suspense>
  );
}

// Route-based splitting
import { BrowserRouter, Routes, Route } from 'react-router-dom';

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<div>Loading...</div>}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/dashboard" element={<Dashboard />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}
```

#### 3. Virtualization

```javascript
import { FixedSizeList } from 'react-window';

function VirtualizedList({ items }) {
  const Row = ({ index, style }) => (
    <div style={style}>
      {items[index].name}
    </div>
  );

  return (
    <FixedSizeList
      height={500}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {Row}
    </FixedSizeList>
  );
}
```

#### 4. Avoid Anonymous Functions

```javascript
// ❌ Bad - creates new function on every render
function List({ items }) {
  return (
    <ul>
      {items.map(item => (
        <li key={item.id} onClick={() => console.log(item.id)}>
          {item.name}
        </li>
      ))}
    </ul>
  );
}

// ✅ Good - use useCallback
function List({ items }) {
  const handleClick = useCallback((id) => {
    console.log(id);
  }, []);

  return (
    <ul>
      {items.map(item => (
        <li key={item.id} onClick={() => handleClick(item.id)}>
          {item.name}
        </li>
      ))}
    </ul>
  );
}
```

## Server Components (RSC)

React Server Components render on the server, reducing client bundle size.

### Server Component

```javascript
// app/users/page.js (Server Component by default)
async function UsersPage() {
  // Fetch data directly on server
  const users = await db.users.findAll();

  return (
    <div>
      <h1>Users</h1>
      <ul>
        {users.map(user => (
          <li key={user.id}>{user.name}</li>
        ))}
      </ul>
    </div>
  );
}

export default UsersPage;
```

### Client Component

```javascript
// components/Counter.js
"use client"; // Mark as client component

import { useState } from 'react';

export default function Counter() {
  const [count, setCount] = useState(0);

  return (
    <button onClick={() => setCount(c => c + 1)}>
      Count: {count}
    </button>
  );
}
```

### Composition Pattern

```javascript
// app/page.js (Server Component)
import Counter from '@/components/Counter'; // Client Component

async function HomePage() {
  const data = await fetchData(); // Server-side data fetching

  return (
    <div>
      <h1>{data.title}</h1>
      <p>{data.description}</p>
      <Counter /> {/* Interactive client component */}
    </div>
  );
}

export default HomePage;
```

## State Management Strategies

### Local State (useState)

Best for: Component-specific state

```javascript
function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

### Lifted State

Best for: Shared state between sibling components

```javascript
function Parent() {
  const [sharedValue, setSharedValue] = useState('');

  return (
    <>
      <ChildA value={sharedValue} onChange={setSharedValue} />
      <ChildB value={sharedValue} />
    </>
  );
}
```

### Context API

Best for: App-wide state (theme, auth, language)

```javascript
const AuthContext = createContext();

function AuthProvider({ children }) {
  const [user, setUser] = useState(null);

  const login = async (credentials) => {
    const user = await api.login(credentials);
    setUser(user);
  };

  const logout = () => setUser(null);

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}
```

### useReducer + Context

Best for: Complex state logic with multiple actions

```javascript
const StateContext = createContext();
const DispatchContext = createContext();

function reducer(state, action) {
  switch (action.type) {
    case 'ADD_ITEM':
      return { ...state, items: [...state.items, action.payload] };
    case 'REMOVE_ITEM':
      return { ...state, items: state.items.filter(i => i.id !== action.payload) };
    default:
      return state;
  }
}

function StoreProvider({ children }) {
  const [state, dispatch] = useReducer(reducer, { items: [] });

  return (
    <StateContext.Provider value={state}>
      <DispatchContext.Provider value={dispatch}>
        {children}
      </DispatchContext.Provider>
    </StateContext.Provider>
  );
}
```

## Best Practices

### 1. Component Design

- Keep components small and focused (Single Responsibility)
- Extract reusable logic into custom hooks
- Prefer composition over inheritance
- Use prop spreading sparingly
- Define PropTypes or TypeScript types

### 2. State Management

- Keep state as local as possible
- Lift state only when necessary
- Avoid unnecessary state (derive from props when possible)
- Use reducers for complex state logic
- Batch state updates when possible

### 3. Performance

- Don't optimize prematurely - measure first
- Use React DevTools Profiler
- Memoize expensive computations
- Avoid creating objects/arrays in render
- Use key prop correctly for lists

### 4. Effects

- Keep effects focused (one concern per effect)
- Always specify dependencies
- Clean up effects (return cleanup function)
- Use AbortController for fetch requests
- Avoid race conditions with ignore flags

### 5. Code Organization

```
src/
├── components/
│   ├── common/         # Reusable UI components
│   ├── features/       # Feature-specific components
│   └── layout/         # Layout components
├── hooks/              # Custom hooks
├── context/            # Context providers
├── utils/              # Utility functions
├── services/           # API services
└── types/              # TypeScript types
```

## Common Anti-Patterns to Avoid

### 1. Mutating State

```javascript
// ❌ Wrong
const handleAdd = () => {
  items.push(newItem);
  setItems(items);
};

// ✅ Correct
const handleAdd = () => {
  setItems([...items, newItem]);
};
```

### 2. Missing Dependencies

```javascript
// ❌ Wrong
useEffect(() => {
  console.log(userId);
}, []); // Missing userId dependency

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
if (condition) {
  // Use state
}
```

### 4. Creating Components Inside Components

```javascript
// ❌ Wrong
function Parent() {
  function Child() { // Re-created on every render
    return <div>Child</div>;
  }
  return <Child />;
}

// ✅ Correct
function Child() {
  return <div>Child</div>;
}

function Parent() {
  return <Child />;
}
```

## Troubleshooting

### Common Issues

**Issue: Infinite re-render loop**
- Check useEffect dependencies
- Avoid setting state directly in render
- Use functional updates: `setState(prev => prev + 1)`

**Issue: Stale closure**
- Use functional updates in setState
- Add missing dependencies to useEffect
- Use useRef for mutable values

**Issue: Component not re-rendering**
- Check if state is being mutated (use immutable updates)
- Verify React.memo comparison function
- Ensure new reference for objects/arrays

**Issue: Memory leak warning**
- Clean up effects (return cleanup function)
- Cancel ongoing requests on unmount
- Clear timers/intervals

## Resources

- React Documentation: https://react.dev
- React Hooks: https://react.dev/reference/react
- React Server Components: https://react.dev/reference/rsc
- React DevTools: https://react.dev/learn/react-developer-tools
- Patterns: https://patterns.dev/react

---

**Skill Version**: 1.0.0
**Last Updated**: October 2025
**Skill Category**: Frontend Development, React, JavaScript
**Compatible With**: React 18+, Next.js 13+, TypeScript
