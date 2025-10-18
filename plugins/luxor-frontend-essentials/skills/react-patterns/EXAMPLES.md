# React Patterns - Code Examples

Comprehensive collection of 20+ React component examples demonstrating modern patterns, hooks, and best practices.

## Table of Contents

1. [State Management Examples](#state-management-examples)
2. [Effect Examples](#effect-examples)
3. [Performance Examples](#performance-examples)
4. [Custom Hook Examples](#custom-hook-examples)
5. [Component Pattern Examples](#component-pattern-examples)
6. [Form Examples](#form-examples)
7. [Data Fetching Examples](#data-fetching-examples)
8. [Advanced Examples](#advanced-examples)

---

## State Management Examples

### 1. Shopping Cart with useState

```javascript
import { useState } from 'react';

function ShoppingCart() {
  const [cart, setCart] = useState([]);

  const addItem = (product) => {
    const existing = cart.find(item => item.id === product.id);

    if (existing) {
      setCart(cart.map(item =>
        item.id === product.id
          ? { ...item, quantity: item.quantity + 1 }
          : item
      ));
    } else {
      setCart([...cart, { ...product, quantity: 1 }]);
    }
  };

  const removeItem = (productId) => {
    setCart(cart.filter(item => item.id !== productId));
  };

  const updateQuantity = (productId, quantity) => {
    if (quantity === 0) {
      removeItem(productId);
    } else {
      setCart(cart.map(item =>
        item.id === productId ? { ...item, quantity } : item
      ));
    }
  };

  const total = cart.reduce((sum, item) => sum + item.price * item.quantity, 0);

  return (
    <div className="shopping-cart">
      <h2>Shopping Cart ({cart.length} items)</h2>

      {cart.length === 0 ? (
        <p>Your cart is empty</p>
      ) : (
        <>
          <ul>
            {cart.map(item => (
              <li key={item.id}>
                <div>
                  <h3>{item.name}</h3>
                  <p>${item.price}</p>
                </div>
                <div>
                  <button onClick={() => updateQuantity(item.id, item.quantity - 1)}>
                    -
                  </button>
                  <span>{item.quantity}</span>
                  <button onClick={() => updateQuantity(item.id, item.quantity + 1)}>
                    +
                  </button>
                  <button onClick={() => removeItem(item.id)}>Remove</button>
                </div>
              </li>
            ))}
          </ul>

          <div className="cart-total">
            <h3>Total: ${total.toFixed(2)}</h3>
            <button>Checkout</button>
          </div>
        </>
      )}
    </div>
  );
}

export default ShoppingCart;
```

### 2. Multi-Step Form with useReducer

```javascript
import { useReducer } from 'react';

const initialState = {
  step: 1,
  formData: {
    personalInfo: { name: '', email: '', phone: '' },
    address: { street: '', city: '', zipCode: '' },
    preferences: { newsletter: false, notifications: true }
  },
  errors: {}
};

function formReducer(state, action) {
  switch (action.type) {
    case 'UPDATE_FIELD':
      return {
        ...state,
        formData: {
          ...state.formData,
          [action.section]: {
            ...state.formData[action.section],
            [action.field]: action.value
          }
        }
      };

    case 'NEXT_STEP':
      return { ...state, step: state.step + 1 };

    case 'PREV_STEP':
      return { ...state, step: state.step - 1 };

    case 'SET_ERRORS':
      return { ...state, errors: action.errors };

    case 'RESET':
      return initialState;

    default:
      return state;
  }
}

function MultiStepForm() {
  const [state, dispatch] = useReducer(formReducer, initialState);

  const updateField = (section, field, value) => {
    dispatch({
      type: 'UPDATE_FIELD',
      section,
      field,
      value
    });
  };

  const validateStep = () => {
    const errors = {};
    const { step, formData } = state;

    if (step === 1) {
      if (!formData.personalInfo.name) errors.name = 'Name is required';
      if (!formData.personalInfo.email) errors.email = 'Email is required';
    } else if (step === 2) {
      if (!formData.address.city) errors.city = 'City is required';
    }

    dispatch({ type: 'SET_ERRORS', errors });
    return Object.keys(errors).length === 0;
  };

  const handleNext = () => {
    if (validateStep()) {
      dispatch({ type: 'NEXT_STEP' });
    }
  };

  const handleSubmit = () => {
    if (validateStep()) {
      console.log('Form submitted:', state.formData);
      dispatch({ type: 'RESET' });
    }
  };

  return (
    <div className="multi-step-form">
      <div className="progress">
        Step {state.step} of 3
      </div>

      {state.step === 1 && (
        <div>
          <h2>Personal Information</h2>
          <input
            value={state.formData.personalInfo.name}
            onChange={e => updateField('personalInfo', 'name', e.target.value)}
            placeholder="Name"
          />
          {state.errors.name && <span className="error">{state.errors.name}</span>}

          <input
            value={state.formData.personalInfo.email}
            onChange={e => updateField('personalInfo', 'email', e.target.value)}
            placeholder="Email"
          />
          {state.errors.email && <span className="error">{state.errors.email}</span>}

          <input
            value={state.formData.personalInfo.phone}
            onChange={e => updateField('personalInfo', 'phone', e.target.value)}
            placeholder="Phone"
          />
        </div>
      )}

      {state.step === 2 && (
        <div>
          <h2>Address</h2>
          <input
            value={state.formData.address.street}
            onChange={e => updateField('address', 'street', e.target.value)}
            placeholder="Street"
          />
          <input
            value={state.formData.address.city}
            onChange={e => updateField('address', 'city', e.target.value)}
            placeholder="City"
          />
          {state.errors.city && <span className="error">{state.errors.city}</span>}

          <input
            value={state.formData.address.zipCode}
            onChange={e => updateField('address', 'zipCode', e.target.value)}
            placeholder="Zip Code"
          />
        </div>
      )}

      {state.step === 3 && (
        <div>
          <h2>Preferences</h2>
          <label>
            <input
              type="checkbox"
              checked={state.formData.preferences.newsletter}
              onChange={e => updateField('preferences', 'newsletter', e.target.checked)}
            />
            Subscribe to newsletter
          </label>
          <label>
            <input
              type="checkbox"
              checked={state.formData.preferences.notifications}
              onChange={e => updateField('preferences', 'notifications', e.target.checked)}
            />
            Enable notifications
          </label>
        </div>
      )}

      <div className="buttons">
        {state.step > 1 && (
          <button onClick={() => dispatch({ type: 'PREV_STEP' })}>
            Previous
          </button>
        )}

        {state.step < 3 ? (
          <button onClick={handleNext}>Next</button>
        ) : (
          <button onClick={handleSubmit}>Submit</button>
        )}
      </div>
    </div>
  );
}

export default MultiStepForm;
```

### 3. Authentication Context

```javascript
import { createContext, useContext, useState, useEffect } from 'react';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if user is logged in on mount
    const token = localStorage.getItem('token');
    if (token) {
      fetchUser(token);
    } else {
      setLoading(false);
    }
  }, []);

  const fetchUser = async (token) => {
    try {
      const response = await fetch('/api/me', {
        headers: { Authorization: `Bearer ${token}` }
      });
      const userData = await response.json();
      setUser(userData);
    } catch (error) {
      console.error('Failed to fetch user:', error);
      localStorage.removeItem('token');
    } finally {
      setLoading(false);
    }
  };

  const login = async (email, password) => {
    try {
      const response = await fetch('/api/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password })
      });

      const { user, token } = await response.json();
      localStorage.setItem('token', token);
      setUser(user);
      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  };

  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
  };

  const register = async (name, email, password) => {
    try {
      const response = await fetch('/api/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, email, password })
      });

      const { user, token } = await response.json();
      localStorage.setItem('token', token);
      setUser(user);
      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  };

  const value = {
    user,
    login,
    logout,
    register,
    isAuthenticated: !!user
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}

// Usage Example
function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const { login } = useAuth();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    const result = await login(email, password);
    if (!result.success) {
      setError(result.error);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        value={email}
        onChange={e => setEmail(e.target.value)}
        placeholder="Email"
      />
      <input
        type="password"
        value={password}
        onChange={e => setPassword(e.target.value)}
        placeholder="Password"
      />
      {error && <div className="error">{error}</div>}
      <button type="submit">Login</button>
    </form>
  );
}

function ProtectedRoute({ children }) {
  const { isAuthenticated } = useAuth();

  if (!isAuthenticated) {
    return <LoginPage />;
  }

  return children;
}
```

---

## Effect Examples

### 4. Real-time Chat Component

```javascript
import { useState, useEffect, useRef } from 'react';

function ChatRoom({ roomId }) {
  const [messages, setMessages] = useState([]);
  const [inputValue, setInputValue] = useState('');
  const [isConnected, setIsConnected] = useState(false);
  const messagesEndRef = useRef(null);
  const wsRef = useRef(null);

  // WebSocket connection effect
  useEffect(() => {
    const ws = new WebSocket(`wss://api.example.com/chat/${roomId}`);
    wsRef.current = ws;

    ws.onopen = () => {
      console.log('Connected to chat');
      setIsConnected(true);
    };

    ws.onmessage = (event) => {
      const message = JSON.parse(event.data);
      setMessages(prev => [...prev, message]);
    };

    ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };

    ws.onclose = () => {
      console.log('Disconnected from chat');
      setIsConnected(false);
    };

    return () => {
      ws.close();
    };
  }, [roomId]);

  // Auto-scroll to bottom effect
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const sendMessage = (e) => {
    e.preventDefault();

    if (inputValue.trim() && wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify({
        type: 'message',
        content: inputValue,
        timestamp: Date.now()
      }));

      setInputValue('');
    }
  };

  return (
    <div className="chat-room">
      <div className="chat-header">
        <h2>Room: {roomId}</h2>
        <span className={isConnected ? 'connected' : 'disconnected'}>
          {isConnected ? '● Online' : '○ Offline'}
        </span>
      </div>

      <div className="messages">
        {messages.map((msg, index) => (
          <div key={index} className="message">
            <span className="author">{msg.author}</span>
            <p>{msg.content}</p>
            <span className="timestamp">
              {new Date(msg.timestamp).toLocaleTimeString()}
            </span>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      <form onSubmit={sendMessage} className="input-area">
        <input
          type="text"
          value={inputValue}
          onChange={e => setInputValue(e.target.value)}
          placeholder="Type a message..."
          disabled={!isConnected}
        />
        <button type="submit" disabled={!isConnected || !inputValue.trim()}>
          Send
        </button>
      </form>
    </div>
  );
}

export default ChatRoom;
```

### 5. Intersection Observer Hook

```javascript
import { useState, useEffect, useRef } from 'react';

function useIntersectionObserver(options = {}) {
  const [isIntersecting, setIsIntersecting] = useState(false);
  const targetRef = useRef(null);

  useEffect(() => {
    const target = targetRef.current;
    if (!target) return;

    const observer = new IntersectionObserver(([entry]) => {
      setIsIntersecting(entry.isIntersecting);
    }, options);

    observer.observe(target);

    return () => {
      observer.disconnect();
    };
  }, [options.threshold, options.root, options.rootMargin]);

  return [targetRef, isIntersecting];
}

// Lazy Loading Image Component
function LazyImage({ src, alt, placeholder }) {
  const [ref, isVisible] = useIntersectionObserver({ threshold: 0.1 });
  const [imageSrc, setImageSrc] = useState(placeholder);

  useEffect(() => {
    if (isVisible && imageSrc === placeholder) {
      setImageSrc(src);
    }
  }, [isVisible, src, imageSrc, placeholder]);

  return (
    <img
      ref={ref}
      src={imageSrc}
      alt={alt}
      style={{
        opacity: imageSrc === placeholder ? 0.5 : 1,
        transition: 'opacity 0.3s'
      }}
    />
  );
}

// Infinite Scroll Component
function InfiniteScrollList({ loadMore, hasMore }) {
  const [ref, isVisible] = useIntersectionObserver({ threshold: 1.0 });

  useEffect(() => {
    if (isVisible && hasMore) {
      loadMore();
    }
  }, [isVisible, hasMore, loadMore]);

  return (
    <div ref={ref} style={{ height: '50px', margin: '20px 0' }}>
      {hasMore ? 'Loading more...' : 'No more items'}
    </div>
  );
}

export { useIntersectionObserver, LazyImage, InfiniteScrollList };
```

### 6. Document Title Hook

```javascript
import { useEffect, useRef } from 'react';

function useDocumentTitle(title, retainOnUnmount = false) {
  const defaultTitle = useRef(document.title);

  useEffect(() => {
    document.title = title;

    return () => {
      if (!retainOnUnmount) {
        document.title = defaultTitle.current;
      }
    };
  }, [title, retainOnUnmount]);
}

// Usage Example
function ProductPage({ product }) {
  useDocumentTitle(`${product.name} - My Store`);

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
    </div>
  );
}

function NotificationBadge({ count }) {
  const title = count > 0
    ? `(${count}) New Messages`
    : 'My App';

  useDocumentTitle(title);

  return <div>You have {count} new messages</div>;
}

export default useDocumentTitle;
```

---

## Performance Examples

### 7. Optimized Todo List

```javascript
import { useState, useMemo, useCallback, memo } from 'react';

const TodoItem = memo(function TodoItem({ todo, onToggle, onDelete }) {
  console.log('Rendering TodoItem:', todo.id);

  return (
    <li className={todo.completed ? 'completed' : ''}>
      <input
        type="checkbox"
        checked={todo.completed}
        onChange={() => onToggle(todo.id)}
      />
      <span>{todo.text}</span>
      <button onClick={() => onDelete(todo.id)}>Delete</button>
    </li>
  );
});

function TodoList() {
  const [todos, setTodos] = useState([
    { id: 1, text: 'Learn React', completed: false },
    { id: 2, text: 'Build a project', completed: false },
    { id: 3, text: 'Master hooks', completed: false }
  ]);
  const [filter, setFilter] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');

  // Memoized filtered and searched todos
  const filteredTodos = useMemo(() => {
    console.log('Filtering todos...');

    let result = todos;

    // Apply search filter
    if (searchTerm) {
      result = result.filter(todo =>
        todo.text.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    // Apply completion filter
    if (filter === 'active') {
      result = result.filter(todo => !todo.completed);
    } else if (filter === 'completed') {
      result = result.filter(todo => todo.completed);
    }

    return result;
  }, [todos, filter, searchTerm]);

  // Memoized statistics
  const stats = useMemo(() => ({
    total: todos.length,
    active: todos.filter(t => !t.completed).length,
    completed: todos.filter(t => t.completed).length
  }), [todos]);

  // Memoized callbacks
  const handleToggle = useCallback((id) => {
    setTodos(prev => prev.map(todo =>
      todo.id === id ? { ...todo, completed: !todo.completed } : todo
    ));
  }, []);

  const handleDelete = useCallback((id) => {
    setTodos(prev => prev.filter(todo => todo.id !== id));
  }, []);

  const handleAdd = useCallback((text) => {
    const newTodo = {
      id: Date.now(),
      text,
      completed: false
    };
    setTodos(prev => [...prev, newTodo]);
  }, []);

  return (
    <div className="todo-list">
      <h1>Optimized Todo List</h1>

      <div className="stats">
        <span>Total: {stats.total}</span>
        <span>Active: {stats.active}</span>
        <span>Completed: {stats.completed}</span>
      </div>

      <input
        type="text"
        placeholder="Search todos..."
        value={searchTerm}
        onChange={e => setSearchTerm(e.target.value)}
      />

      <div className="filters">
        <button
          className={filter === 'all' ? 'active' : ''}
          onClick={() => setFilter('all')}
        >
          All
        </button>
        <button
          className={filter === 'active' ? 'active' : ''}
          onClick={() => setFilter('active')}
        >
          Active
        </button>
        <button
          className={filter === 'completed' ? 'active' : ''}
          onClick={() => setFilter('completed')}
        >
          Completed
        </button>
      </div>

      <ul>
        {filteredTodos.map(todo => (
          <TodoItem
            key={todo.id}
            todo={todo}
            onToggle={handleToggle}
            onDelete={handleDelete}
          />
        ))}
      </ul>

      <AddTodoForm onAdd={handleAdd} />
    </div>
  );
}

const AddTodoForm = memo(function AddTodoForm({ onAdd }) {
  const [text, setText] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    if (text.trim()) {
      onAdd(text);
      setText('');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="text"
        value={text}
        onChange={e => setText(e.target.value)}
        placeholder="Add new todo..."
      />
      <button type="submit">Add</button>
    </form>
  );
});

export default TodoList;
```

### 8. Virtual Scroll List

```javascript
import { useState, useMemo, useRef, useEffect } from 'react';

function VirtualScrollList({ items, itemHeight = 50, containerHeight = 500 }) {
  const [scrollTop, setScrollTop] = useState(0);
  const containerRef = useRef(null);

  const handleScroll = (e) => {
    setScrollTop(e.target.scrollTop);
  };

  // Calculate which items to render
  const { visibleItems, offsetY } = useMemo(() => {
    const startIndex = Math.floor(scrollTop / itemHeight);
    const endIndex = Math.ceil((scrollTop + containerHeight) / itemHeight);

    const visible = items.slice(startIndex, endIndex);
    const offset = startIndex * itemHeight;

    return {
      visibleItems: visible,
      offsetY: offset
    };
  }, [scrollTop, items, itemHeight, containerHeight]);

  const totalHeight = items.length * itemHeight;

  return (
    <div
      ref={containerRef}
      onScroll={handleScroll}
      style={{
        height: containerHeight,
        overflow: 'auto',
        position: 'relative'
      }}
    >
      <div style={{ height: totalHeight }}>
        <div
          style={{
            transform: `translateY(${offsetY}px)`,
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0
          }}
        >
          {visibleItems.map((item, index) => (
            <div
              key={item.id}
              style={{
                height: itemHeight,
                borderBottom: '1px solid #ccc',
                display: 'flex',
                alignItems: 'center',
                padding: '0 10px'
              }}
            >
              {item.content}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// Example usage with large dataset
function VirtualListDemo() {
  const items = useMemo(() =>
    Array.from({ length: 10000 }, (_, i) => ({
      id: i,
      content: `Item ${i + 1}`
    })),
    []
  );

  return (
    <div>
      <h2>Virtual Scroll List (10,000 items)</h2>
      <VirtualScrollList items={items} />
    </div>
  );
}

export default VirtualScrollList;
```

---

## Custom Hook Examples

### 9. useAsync Hook

```javascript
import { useState, useEffect, useCallback } from 'react';

function useAsync(asyncFunction, immediate = true) {
  const [status, setStatus] = useState('idle');
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);

  const execute = useCallback(
    async (...params) => {
      setStatus('pending');
      setData(null);
      setError(null);

      try {
        const response = await asyncFunction(...params);
        setData(response);
        setStatus('success');
        return response;
      } catch (err) {
        setError(err);
        setStatus('error');
        throw err;
      }
    },
    [asyncFunction]
  );

  useEffect(() => {
    if (immediate) {
      execute();
    }
  }, [execute, immediate]);

  return {
    execute,
    status,
    data,
    error,
    isIdle: status === 'idle',
    isPending: status === 'pending',
    isSuccess: status === 'success',
    isError: status === 'error'
  };
}

// Usage Example
function UserProfile({ userId }) {
  const fetchUser = useCallback(
    () => fetch(`/api/users/${userId}`).then(res => res.json()),
    [userId]
  );

  const {
    data: user,
    status,
    error,
    execute: refetch
  } = useAsync(fetchUser);

  if (status === 'pending') return <div>Loading...</div>;
  if (status === 'error') return <div>Error: {error.message}</div>;
  if (!user) return null;

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
      <button onClick={refetch}>Refresh</button>
    </div>
  );
}

export default useAsync;
```

### 10. useMediaQuery Hook

```javascript
import { useState, useEffect } from 'react';

function useMediaQuery(query) {
  const [matches, setMatches] = useState(
    () => window.matchMedia(query).matches
  );

  useEffect(() => {
    const mediaQuery = window.matchMedia(query);

    const handleChange = (e) => {
      setMatches(e.matches);
    };

    // Modern browsers
    if (mediaQuery.addEventListener) {
      mediaQuery.addEventListener('change', handleChange);
      return () => mediaQuery.removeEventListener('change', handleChange);
    }
    // Fallback for older browsers
    else {
      mediaQuery.addListener(handleChange);
      return () => mediaQuery.removeListener(handleChange);
    }
  }, [query]);

  return matches;
}

// Breakpoint Hooks
function useBreakpoint() {
  const isMobile = useMediaQuery('(max-width: 767px)');
  const isTablet = useMediaQuery('(min-width: 768px) and (max-width: 1023px)');
  const isDesktop = useMediaQuery('(min-width: 1024px)');

  return { isMobile, isTablet, isDesktop };
}

// Usage Example
function ResponsiveLayout() {
  const { isMobile, isTablet, isDesktop } = useBreakpoint();
  const prefersDark = useMediaQuery('(prefers-color-scheme: dark)');

  return (
    <div className={prefersDark ? 'dark-mode' : 'light-mode'}>
      {isMobile && <MobileLayout />}
      {isTablet && <TabletLayout />}
      {isDesktop && <DesktopLayout />}
    </div>
  );
}

export { useMediaQuery, useBreakpoint };
```

### 11. usePrevious Hook

```javascript
import { useRef, useEffect } from 'react';

function usePrevious(value) {
  const ref = useRef();

  useEffect(() => {
    ref.current = value;
  }, [value]);

  return ref.current;
}

// Usage Example
function Counter() {
  const [count, setCount] = useState(0);
  const prevCount = usePrevious(count);

  return (
    <div>
      <p>Current count: {count}</p>
      <p>Previous count: {prevCount}</p>
      <p>
        {count > prevCount ? '↑ Increased' :
         count < prevCount ? '↓ Decreased' :
         '− No change'}
      </p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
      <button onClick={() => setCount(count - 1)}>Decrement</button>
    </div>
  );
}

// Comparison Component
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const prevUserId = usePrevious(userId);

  useEffect(() => {
    if (userId !== prevUserId) {
      console.log(`User changed from ${prevUserId} to ${userId}`);
      fetchUser(userId).then(setUser);
    }
  }, [userId, prevUserId]);

  return user ? <div>{user.name}</div> : <div>Loading...</div>;
}

export default usePrevious;
```

### 12. useToggle Hook

```javascript
import { useState, useCallback } from 'react';

function useToggle(initialValue = false) {
  const [value, setValue] = useState(initialValue);

  const toggle = useCallback(() => {
    setValue(v => !v);
  }, []);

  const setTrue = useCallback(() => {
    setValue(true);
  }, []);

  const setFalse = useCallback(() => {
    setValue(false);
  }, []);

  return [value, { toggle, setTrue, setFalse, setValue }];
}

// Usage Examples
function Sidebar() {
  const [isOpen, { toggle, setFalse }] = useToggle(false);

  return (
    <>
      <button onClick={toggle}>Toggle Sidebar</button>
      <div className={`sidebar ${isOpen ? 'open' : ''}`}>
        <button onClick={setFalse}>Close</button>
        <nav>
          <a href="/">Home</a>
          <a href="/about">About</a>
          <a href="/contact">Contact</a>
        </nav>
      </div>
    </>
  );
}

function AccordionItem({ title, children }) {
  const [isExpanded, { toggle }] = useToggle(false);

  return (
    <div className="accordion-item">
      <button onClick={toggle}>
        {title}
        <span>{isExpanded ? '−' : '+'}</span>
      </button>
      {isExpanded && (
        <div className="accordion-content">
          {children}
        </div>
      )}
    </div>
  );
}

function Modal({ trigger }) {
  const [isVisible, { setTrue: open, setFalse: close }] = useToggle(false);

  return (
    <>
      <div onClick={open}>{trigger}</div>
      {isVisible && (
        <div className="modal-overlay" onClick={close}>
          <div className="modal-content" onClick={e => e.stopPropagation()}>
            <button onClick={close}>Close</button>
            <div>Modal Content</div>
          </div>
        </div>
      )}
    </>
  );
}

export default useToggle;
```

---

## Component Pattern Examples

### 13. Accordion Component (Compound Components)

```javascript
import { createContext, useContext, useState } from 'react';

const AccordionContext = createContext();

function Accordion({ children, allowMultiple = false }) {
  const [openItems, setOpenItems] = useState([]);

  const toggleItem = (id) => {
    setOpenItems(prev => {
      if (prev.includes(id)) {
        return prev.filter(item => item !== id);
      }

      if (allowMultiple) {
        return [...prev, id];
      }

      return [id];
    });
  };

  return (
    <AccordionContext.Provider value={{ openItems, toggleItem }}>
      <div className="accordion">{children}</div>
    </AccordionContext.Provider>
  );
}

function AccordionItem({ id, children }) {
  const { openItems } = useContext(AccordionContext);
  const isOpen = openItems.includes(id);

  return (
    <div className={`accordion-item ${isOpen ? 'open' : ''}`}>
      {children}
    </div>
  );
}

function AccordionHeader({ id, children }) {
  const { toggleItem } = useContext(AccordionContext);

  return (
    <button
      className="accordion-header"
      onClick={() => toggleItem(id)}
    >
      {children}
    </button>
  );
}

function AccordionPanel({ id, children }) {
  const { openItems } = useContext(AccordionContext);
  const isOpen = openItems.includes(id);

  if (!isOpen) return null;

  return (
    <div className="accordion-panel">
      {children}
    </div>
  );
}

// Compose the exports
Accordion.Item = AccordionItem;
Accordion.Header = AccordionHeader;
Accordion.Panel = AccordionPanel;

// Usage
function FAQPage() {
  return (
    <Accordion allowMultiple>
      <Accordion.Item id="1">
        <Accordion.Header id="1">
          What is React?
        </Accordion.Header>
        <Accordion.Panel id="1">
          React is a JavaScript library for building user interfaces.
        </Accordion.Panel>
      </Accordion.Item>

      <Accordion.Item id="2">
        <Accordion.Header id="2">
          What are hooks?
        </Accordion.Header>
        <Accordion.Panel id="2">
          Hooks are functions that let you use state and other React features.
        </Accordion.Panel>
      </Accordion.Item>
    </Accordion>
  );
}

export default Accordion;
```

### 14. Dropdown Menu (Render Props + Compound Components)

```javascript
import { createContext, useContext, useState, useRef, useEffect } from 'react';

const DropdownContext = createContext();

function Dropdown({ children }) {
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef(null);

  useEffect(() => {
    function handleClickOutside(event) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    }

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const toggle = () => setIsOpen(prev => !prev);
  const close = () => setIsOpen(false);
  const open = () => setIsOpen(true);

  return (
    <DropdownContext.Provider value={{ isOpen, toggle, close, open }}>
      <div ref={dropdownRef} className="dropdown">
        {children}
      </div>
    </DropdownContext.Provider>
  );
}

function DropdownTrigger({ children }) {
  const { toggle } = useContext(DropdownContext);

  return (
    <button onClick={toggle} className="dropdown-trigger">
      {children}
    </button>
  );
}

function DropdownMenu({ children }) {
  const { isOpen } = useContext(DropdownContext);

  if (!isOpen) return null;

  return (
    <div className="dropdown-menu">
      {children}
    </div>
  );
}

function DropdownItem({ onClick, children }) {
  const { close } = useContext(DropdownContext);

  const handleClick = () => {
    onClick?.();
    close();
  };

  return (
    <button onClick={handleClick} className="dropdown-item">
      {children}
    </button>
  );
}

Dropdown.Trigger = DropdownTrigger;
Dropdown.Menu = DropdownMenu;
Dropdown.Item = DropdownItem;

// Usage
function UserMenu() {
  const handleLogout = () => {
    console.log('Logging out...');
  };

  return (
    <Dropdown>
      <Dropdown.Trigger>
        User Menu ▼
      </Dropdown.Trigger>

      <Dropdown.Menu>
        <Dropdown.Item onClick={() => console.log('Profile')}>
          Profile
        </Dropdown.Item>
        <Dropdown.Item onClick={() => console.log('Settings')}>
          Settings
        </Dropdown.Item>
        <Dropdown.Item onClick={handleLogout}>
          Logout
        </Dropdown.Item>
      </Dropdown.Menu>
    </Dropdown>
  );
}

export default Dropdown;
```

---

## Form Examples

### 15. Advanced Form with Validation

```javascript
import { useState } from 'react';

function useForm(initialValues, validate) {
  const [values, setValues] = useState(initialValues);
  const [errors, setErrors] = useState({});
  const [touched, setTouched] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleChange = (name, value) => {
    setValues(prev => ({ ...prev, [name]: value }));

    // Clear error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: undefined }));
    }
  };

  const handleBlur = (name) => {
    setTouched(prev => ({ ...prev, [name]: true }));

    // Validate on blur
    const fieldErrors = validate({ [name]: values[name] });
    if (fieldErrors[name]) {
      setErrors(prev => ({ ...prev, [name]: fieldErrors[name] }));
    }
  };

  const handleSubmit = async (onSubmit) => {
    const validationErrors = validate(values);

    if (Object.keys(validationErrors).length > 0) {
      setErrors(validationErrors);
      setTouched(
        Object.keys(initialValues).reduce((acc, key) => {
          acc[key] = true;
          return acc;
        }, {})
      );
      return;
    }

    setIsSubmitting(true);

    try {
      await onSubmit(values);
    } catch (err) {
      console.error('Form submission error:', err);
    } finally {
      setIsSubmitting(false);
    }
  };

  const reset = () => {
    setValues(initialValues);
    setErrors({});
    setTouched({});
    setIsSubmitting(false);
  };

  return {
    values,
    errors,
    touched,
    isSubmitting,
    handleChange,
    handleBlur,
    handleSubmit,
    reset
  };
}

// Validation functions
const validateRegistrationForm = (values) => {
  const errors = {};

  if (!values.username) {
    errors.username = 'Username is required';
  } else if (values.username.length < 3) {
    errors.username = 'Username must be at least 3 characters';
  }

  if (!values.email) {
    errors.email = 'Email is required';
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(values.email)) {
    errors.email = 'Invalid email address';
  }

  if (!values.password) {
    errors.password = 'Password is required';
  } else if (values.password.length < 8) {
    errors.password = 'Password must be at least 8 characters';
  }

  if (values.password !== values.confirmPassword) {
    errors.confirmPassword = 'Passwords do not match';
  }

  if (!values.terms) {
    errors.terms = 'You must accept the terms and conditions';
  }

  return errors;
};

// Registration Form Component
function RegistrationForm() {
  const {
    values,
    errors,
    touched,
    isSubmitting,
    handleChange,
    handleBlur,
    handleSubmit,
    reset
  } = useForm(
    {
      username: '',
      email: '',
      password: '',
      confirmPassword: '',
      terms: false
    },
    validateRegistrationForm
  );

  const onSubmit = async (formValues) => {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));
    console.log('Form submitted:', formValues);
    alert('Registration successful!');
    reset();
  };

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault();
        handleSubmit(onSubmit);
      }}
      className="registration-form"
    >
      <h2>Register</h2>

      <div className="form-group">
        <label htmlFor="username">Username</label>
        <input
          id="username"
          type="text"
          value={values.username}
          onChange={(e) => handleChange('username', e.target.value)}
          onBlur={() => handleBlur('username')}
          className={touched.username && errors.username ? 'error' : ''}
        />
        {touched.username && errors.username && (
          <span className="error-message">{errors.username}</span>
        )}
      </div>

      <div className="form-group">
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          value={values.email}
          onChange={(e) => handleChange('email', e.target.value)}
          onBlur={() => handleBlur('email')}
          className={touched.email && errors.email ? 'error' : ''}
        />
        {touched.email && errors.email && (
          <span className="error-message">{errors.email}</span>
        )}
      </div>

      <div className="form-group">
        <label htmlFor="password">Password</label>
        <input
          id="password"
          type="password"
          value={values.password}
          onChange={(e) => handleChange('password', e.target.value)}
          onBlur={() => handleBlur('password')}
          className={touched.password && errors.password ? 'error' : ''}
        />
        {touched.password && errors.password && (
          <span className="error-message">{errors.password}</span>
        )}
      </div>

      <div className="form-group">
        <label htmlFor="confirmPassword">Confirm Password</label>
        <input
          id="confirmPassword"
          type="password"
          value={values.confirmPassword}
          onChange={(e) => handleChange('confirmPassword', e.target.value)}
          onBlur={() => handleBlur('confirmPassword')}
          className={touched.confirmPassword && errors.confirmPassword ? 'error' : ''}
        />
        {touched.confirmPassword && errors.confirmPassword && (
          <span className="error-message">{errors.confirmPassword}</span>
        )}
      </div>

      <div className="form-group checkbox">
        <label>
          <input
            type="checkbox"
            checked={values.terms}
            onChange={(e) => handleChange('terms', e.target.checked)}
            onBlur={() => handleBlur('terms')}
          />
          I accept the terms and conditions
        </label>
        {touched.terms && errors.terms && (
          <span className="error-message">{errors.terms}</span>
        )}
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Registering...' : 'Register'}
      </button>
    </form>
  );
}

export default RegistrationForm;
```

---

## Data Fetching Examples

### 16. Paginated Data Table

```javascript
import { useState, useEffect, useMemo } from 'react';

function PaginatedTable() {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(10);
  const [sortConfig, setSortConfig] = useState({ key: null, direction: 'asc' });
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/users');
      const result = await response.json();
      setData(result);
    } catch (error) {
      console.error('Failed to fetch data:', error);
    } finally {
      setLoading(false);
    }
  };

  // Filtered data
  const filteredData = useMemo(() => {
    if (!searchTerm) return data;

    return data.filter(item =>
      Object.values(item).some(value =>
        String(value).toLowerCase().includes(searchTerm.toLowerCase())
      )
    );
  }, [data, searchTerm]);

  // Sorted data
  const sortedData = useMemo(() => {
    if (!sortConfig.key) return filteredData;

    return [...filteredData].sort((a, b) => {
      const aValue = a[sortConfig.key];
      const bValue = b[sortConfig.key];

      if (aValue < bValue) {
        return sortConfig.direction === 'asc' ? -1 : 1;
      }
      if (aValue > bValue) {
        return sortConfig.direction === 'asc' ? 1 : -1;
      }
      return 0;
    });
  }, [filteredData, sortConfig]);

  // Paginated data
  const paginatedData = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    return sortedData.slice(startIndex, endIndex);
  }, [sortedData, currentPage, itemsPerPage]);

  const totalPages = Math.ceil(sortedData.length / itemsPerPage);

  const handleSort = (key) => {
    setSortConfig(prev => ({
      key,
      direction: prev.key === key && prev.direction === 'asc' ? 'desc' : 'asc'
    }));
  };

  const getSortIndicator = (key) => {
    if (sortConfig.key !== key) return '⇅';
    return sortConfig.direction === 'asc' ? '↑' : '↓';
  };

  if (loading) return <div>Loading...</div>;

  return (
    <div className="paginated-table">
      <div className="controls">
        <input
          type="text"
          placeholder="Search..."
          value={searchTerm}
          onChange={e => {
            setSearchTerm(e.target.value);
            setCurrentPage(1); // Reset to first page
          }}
        />

        <select
          value={itemsPerPage}
          onChange={e => {
            setItemsPerPage(Number(e.target.value));
            setCurrentPage(1);
          }}
        >
          <option value={5}>5 per page</option>
          <option value={10}>10 per page</option>
          <option value={25}>25 per page</option>
          <option value={50}>50 per page</option>
        </select>
      </div>

      <table>
        <thead>
          <tr>
            <th onClick={() => handleSort('id')}>
              ID {getSortIndicator('id')}
            </th>
            <th onClick={() => handleSort('name')}>
              Name {getSortIndicator('name')}
            </th>
            <th onClick={() => handleSort('email')}>
              Email {getSortIndicator('email')}
            </th>
            <th onClick={() => handleSort('role')}>
              Role {getSortIndicator('role')}
            </th>
          </tr>
        </thead>
        <tbody>
          {paginatedData.map(item => (
            <tr key={item.id}>
              <td>{item.id}</td>
              <td>{item.name}</td>
              <td>{item.email}</td>
              <td>{item.role}</td>
            </tr>
          ))}
        </tbody>
      </table>

      <div className="pagination">
        <button
          onClick={() => setCurrentPage(1)}
          disabled={currentPage === 1}
        >
          First
        </button>
        <button
          onClick={() => setCurrentPage(prev => Math.max(1, prev - 1))}
          disabled={currentPage === 1}
        >
          Previous
        </button>

        <span>
          Page {currentPage} of {totalPages}
        </span>

        <button
          onClick={() => setCurrentPage(prev => Math.min(totalPages, prev + 1))}
          disabled={currentPage === totalPages}
        >
          Next
        </button>
        <button
          onClick={() => setCurrentPage(totalPages)}
          disabled={currentPage === totalPages}
        >
          Last
        </button>
      </div>

      <div className="info">
        Showing {((currentPage - 1) * itemsPerPage) + 1} to{' '}
        {Math.min(currentPage * itemsPerPage, sortedData.length)} of{' '}
        {sortedData.length} entries
        {searchTerm && ` (filtered from ${data.length} total entries)`}
      </div>
    </div>
  );
}

export default PaginatedTable;
```

---

## Advanced Examples

### 17. Dark Mode Implementation

```javascript
import { createContext, useContext, useState, useEffect } from 'react';

const ThemeContext = createContext();

export function ThemeProvider({ children }) {
  const [theme, setTheme] = useState(() => {
    // Check localStorage first
    const saved = localStorage.getItem('theme');
    if (saved) return saved;

    // Check system preference
    if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return 'dark';
    }

    return 'light';
  });

  useEffect(() => {
    // Save to localStorage
    localStorage.setItem('theme', theme);

    // Apply to document
    document.documentElement.setAttribute('data-theme', theme);
  }, [theme]);

  // Listen for system theme changes
  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');

    const handleChange = (e) => {
      // Only auto-switch if user hasn't manually set preference
      if (!localStorage.getItem('theme')) {
        setTheme(e.matches ? 'dark' : 'light');
      }
    };

    mediaQuery.addEventListener('change', handleChange);
    return () => mediaQuery.removeEventListener('change', handleChange);
  }, []);

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

// Theme Toggle Component
function ThemeToggle() {
  const { theme, toggleTheme } = useTheme();

  return (
    <button onClick={toggleTheme} className="theme-toggle">
      {theme === 'light' ? '🌙 Dark' : '☀️ Light'}
    </button>
  );
}

export default ThemeToggle;
```

### 18. File Upload with Progress

```javascript
import { useState, useRef } from 'react';

function FileUpload({ onUploadComplete }) {
  const [files, setFiles] = useState([]);
  const [uploading, setUploading] = useState(false);
  const fileInputRef = useRef(null);

  const handleFileSelect = (e) => {
    const selectedFiles = Array.from(e.target.files);

    const filesWithProgress = selectedFiles.map(file => ({
      file,
      progress: 0,
      status: 'pending', // pending, uploading, completed, error
      id: Math.random().toString(36).substr(2, 9)
    }));

    setFiles(prev => [...prev, ...filesWithProgress]);
  };

  const uploadFile = async (fileData) => {
    const formData = new FormData();
    formData.append('file', fileData.file);

    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();

      xhr.upload.addEventListener('progress', (e) => {
        if (e.lengthComputable) {
          const progress = Math.round((e.loaded / e.total) * 100);

          setFiles(prev => prev.map(f =>
            f.id === fileData.id
              ? { ...f, progress, status: 'uploading' }
              : f
          ));
        }
      });

      xhr.addEventListener('load', () => {
        if (xhr.status === 200) {
          setFiles(prev => prev.map(f =>
            f.id === fileData.id
              ? { ...f, status: 'completed', progress: 100 }
              : f
          ));
          resolve(xhr.response);
        } else {
          reject(new Error('Upload failed'));
        }
      });

      xhr.addEventListener('error', () => {
        setFiles(prev => prev.map(f =>
          f.id === fileData.id
            ? { ...f, status: 'error' }
            : f
        ));
        reject(new Error('Upload failed'));
      });

      xhr.open('POST', '/api/upload');
      xhr.send(formData);
    });
  };

  const handleUpload = async () => {
    setUploading(true);

    try {
      const pendingFiles = files.filter(f => f.status === 'pending');

      await Promise.all(pendingFiles.map(file => uploadFile(file)));

      onUploadComplete?.();
    } catch (error) {
      console.error('Upload error:', error);
    } finally {
      setUploading(false);
    }
  };

  const removeFile = (id) => {
    setFiles(prev => prev.filter(f => f.id !== id));
  };

  const formatFileSize = (bytes) => {
    if (bytes === 0) return '0 Bytes';

    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));

    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
  };

  return (
    <div className="file-upload">
      <input
        ref={fileInputRef}
        type="file"
        multiple
        onChange={handleFileSelect}
        style={{ display: 'none' }}
      />

      <button onClick={() => fileInputRef.current?.click()}>
        Select Files
      </button>

      {files.length > 0 && (
        <>
          <div className="file-list">
            {files.map(({ id, file, progress, status }) => (
              <div key={id} className="file-item">
                <div className="file-info">
                  <span className="file-name">{file.name}</span>
                  <span className="file-size">{formatFileSize(file.size)}</span>
                </div>

                <div className="file-progress">
                  <div
                    className={`progress-bar ${status}`}
                    style={{ width: `${progress}%` }}
                  />
                </div>

                <div className="file-status">
                  {status === 'pending' && 'Pending'}
                  {status === 'uploading' && `${progress}%`}
                  {status === 'completed' && '✓ Completed'}
                  {status === 'error' && '✗ Failed'}
                </div>

                {status !== 'uploading' && (
                  <button onClick={() => removeFile(id)}>Remove</button>
                )}
              </div>
            ))}
          </div>

          <button
            onClick={handleUpload}
            disabled={uploading || !files.some(f => f.status === 'pending')}
          >
            {uploading ? 'Uploading...' : 'Upload All'}
          </button>
        </>
      )}
    </div>
  );
}

export default FileUpload;
```

### 19. Drag and Drop List

```javascript
import { useState } from 'react';

function DragDropList({ initialItems }) {
  const [items, setItems] = useState(initialItems);
  const [draggedItem, setDraggedItem] = useState(null);

  const handleDragStart = (e, index) => {
    setDraggedItem(index);
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/html', e.target);
  };

  const handleDragOver = (e, index) => {
    e.preventDefault();

    if (draggedItem === null || draggedItem === index) return;

    const newItems = [...items];
    const draggedContent = newItems[draggedItem];

    newItems.splice(draggedItem, 1);
    newItems.splice(index, 0, draggedContent);

    setDraggedItem(index);
    setItems(newItems);
  };

  const handleDragEnd = () => {
    setDraggedItem(null);
  };

  return (
    <div className="drag-drop-list">
      <h2>Drag to Reorder</h2>
      <ul>
        {items.map((item, index) => (
          <li
            key={item.id}
            draggable
            onDragStart={(e) => handleDragStart(e, index)}
            onDragOver={(e) => handleDragOver(e, index)}
            onDragEnd={handleDragEnd}
            className={draggedItem === index ? 'dragging' : ''}
          >
            <span className="drag-handle">⋮⋮</span>
            <span className="item-content">{item.content}</span>
          </li>
        ))}
      </ul>
    </div>
  );
}

// Usage
function App() {
  const items = [
    { id: 1, content: 'First item' },
    { id: 2, content: 'Second item' },
    { id: 3, content: 'Third item' },
    { id: 4, content: 'Fourth item' },
    { id: 5, content: 'Fifth item' }
  ];

  return <DragDropList initialItems={items} />;
}

export default DragDropList;
```

### 20. Notification System

```javascript
import { createContext, useContext, useState, useCallback } from 'react';

const NotificationContext = createContext();

export function NotificationProvider({ children }) {
  const [notifications, setNotifications] = useState([]);

  const addNotification = useCallback((message, type = 'info', duration = 3000) => {
    const id = Date.now() + Math.random();

    const notification = {
      id,
      message,
      type, // info, success, warning, error
      duration
    };

    setNotifications(prev => [...prev, notification]);

    if (duration > 0) {
      setTimeout(() => {
        removeNotification(id);
      }, duration);
    }

    return id;
  }, []);

  const removeNotification = useCallback((id) => {
    setNotifications(prev => prev.filter(n => n.id !== id));
  }, []);

  return (
    <NotificationContext.Provider value={{ addNotification, removeNotification }}>
      {children}
      <NotificationContainer notifications={notifications} onClose={removeNotification} />
    </NotificationContext.Provider>
  );
}

export function useNotification() {
  const context = useContext(NotificationContext);
  if (!context) {
    throw new Error('useNotification must be used within NotificationProvider');
  }
  return context;
}

function NotificationContainer({ notifications, onClose }) {
  return (
    <div className="notification-container">
      {notifications.map(notification => (
        <Notification
          key={notification.id}
          notification={notification}
          onClose={() => onClose(notification.id)}
        />
      ))}
    </div>
  );
}

function Notification({ notification, onClose }) {
  const { message, type } = notification;

  const getIcon = () => {
    switch (type) {
      case 'success': return '✓';
      case 'error': return '✗';
      case 'warning': return '⚠';
      default: return 'ℹ';
    }
  };

  return (
    <div className={`notification ${type}`}>
      <span className="icon">{getIcon()}</span>
      <span className="message">{message}</span>
      <button onClick={onClose} className="close">×</button>
    </div>
  );
}

// Usage Example
function MyComponent() {
  const { addNotification } = useNotification();

  const handleSuccess = () => {
    addNotification('Operation completed successfully!', 'success');
  };

  const handleError = () => {
    addNotification('Something went wrong!', 'error', 5000);
  };

  return (
    <div>
      <button onClick={handleSuccess}>Show Success</button>
      <button onClick={handleError}>Show Error</button>
    </div>
  );
}

export default NotificationProvider;
```

---

This collection provides practical, real-world examples covering the full spectrum of modern React development patterns. Each example is production-ready and demonstrates best practices for hooks, state management, performance optimization, and component composition.
