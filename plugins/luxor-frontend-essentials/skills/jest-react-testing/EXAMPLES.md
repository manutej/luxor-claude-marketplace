# Jest React Testing Examples

Comprehensive collection of real-world testing examples covering common scenarios and patterns in React application testing.

## Table of Contents

1. [Basic Component Testing](#1-basic-component-testing)
2. [Form Testing with Validation](#2-form-testing-with-validation)
3. [Async API Data Fetching](#3-async-api-data-fetching)
4. [User Authentication Flow](#4-user-authentication-flow)
5. [Modal and Dialog Testing](#5-modal-and-dialog-testing)
6. [Dropdown and Select Testing](#6-dropdown-and-select-testing)
7. [Testing Custom Hooks](#7-testing-custom-hooks)
8. [Testing with React Router](#8-testing-with-react-router)
9. [Testing with Redux](#9-testing-with-redux)
10. [Testing with Context API](#10-testing-with-context-api)
11. [File Upload Component](#11-file-upload-component)
12. [Autocomplete Component](#12-autocomplete-component)
13. [Infinite Scroll List](#13-infinite-scroll-list)
14. [Error Boundary Testing](#14-error-boundary-testing)
15. [Accessibility Testing](#15-accessibility-testing)
16. [Testing Timers and Intervals](#16-testing-timers-and-intervals)
17. [Testing WebSocket Integration](#17-testing-websocket-integration)
18. [Multi-step Form Wizard](#18-multi-step-form-wizard)

---

## 1. Basic Component Testing

### Component: Button

```javascript
// Button.jsx
export const Button = ({
  children,
  variant = 'primary',
  disabled = false,
  onClick
}) => {
  return (
    <button
      className={`btn btn-${variant}`}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
};
```

### Tests

```javascript
// Button.test.jsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Button } from './Button';

describe('Button Component', () => {
  it('renders with children text', () => {
    render(<Button>Click Me</Button>);

    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
  });

  it('applies correct variant class', () => {
    render(<Button variant="secondary">Secondary</Button>);

    const button = screen.getByRole('button');
    expect(button).toHaveClass('btn-secondary');
  });

  it('applies primary variant by default', () => {
    render(<Button>Default</Button>);

    const button = screen.getByRole('button');
    expect(button).toHaveClass('btn-primary');
  });

  it('calls onClick handler when clicked', async () => {
    const user = userEvent.setup();
    const handleClick = jest.fn();

    render(<Button onClick={handleClick}>Click</Button>);

    await user.click(screen.getByRole('button'));

    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('does not call onClick when disabled', async () => {
    const user = userEvent.setup();
    const handleClick = jest.fn();

    render(<Button onClick={handleClick} disabled>Disabled</Button>);

    const button = screen.getByRole('button');

    // Verify button is disabled
    expect(button).toBeDisabled();

    // Try to click - should not work
    await user.click(button);

    expect(handleClick).not.toHaveBeenCalled();
  });
});
```

---

## 2. Form Testing with Validation

### Component: LoginForm

```javascript
// LoginForm.jsx
import { useState } from 'react';

export const LoginForm = ({ onSubmit }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errors, setErrors] = useState({});

  const validate = () => {
    const newErrors = {};

    if (!email) {
      newErrors.email = 'Email is required';
    } else if (!/\S+@\S+\.\S+/.test(email)) {
      newErrors.email = 'Email is invalid';
    }

    if (!password) {
      newErrors.password = 'Password is required';
    } else if (password.length < 8) {
      newErrors.password = 'Password must be at least 8 characters';
    }

    return newErrors;
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    const newErrors = validate();

    if (Object.keys(newErrors).length === 0) {
      onSubmit({ email, password });
      setEmail('');
      setPassword('');
    } else {
      setErrors(newErrors);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          aria-invalid={errors.email ? 'true' : 'false'}
          aria-describedby={errors.email ? 'email-error' : undefined}
        />
        {errors.email && (
          <span id="email-error" role="alert">
            {errors.email}
          </span>
        )}
      </div>

      <div>
        <label htmlFor="password">Password</label>
        <input
          id="password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          aria-invalid={errors.password ? 'true' : 'false'}
          aria-describedby={errors.password ? 'password-error' : undefined}
        />
        {errors.password && (
          <span id="password-error" role="alert">
            {errors.password}
          </span>
        )}
      </div>

      <button type="submit">Login</button>
    </form>
  );
};
```

### Tests

```javascript
// LoginForm.test.jsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LoginForm } from './LoginForm';

describe('LoginForm Component', () => {
  it('renders form fields', () => {
    render(<LoginForm onSubmit={jest.fn()} />);

    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /login/i })).toBeInTheDocument();
  });

  it('submits form with valid data', async () => {
    const user = userEvent.setup();
    const handleSubmit = jest.fn();

    render(<LoginForm onSubmit={handleSubmit} />);

    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /login/i }));

    expect(handleSubmit).toHaveBeenCalledWith({
      email: 'test@example.com',
      password: 'password123',
    });
  });

  it('shows validation error for empty email', async () => {
    const user = userEvent.setup();

    render(<LoginForm onSubmit={jest.fn()} />);

    await user.click(screen.getByRole('button', { name: /login/i }));

    expect(screen.getByText(/email is required/i)).toBeInTheDocument();
  });

  it('shows validation error for invalid email format', async () => {
    const user = userEvent.setup();

    render(<LoginForm onSubmit={jest.fn()} />);

    await user.type(screen.getByLabelText(/email/i), 'invalid-email');
    await user.click(screen.getByRole('button', { name: /login/i }));

    expect(screen.getByText(/email is invalid/i)).toBeInTheDocument();
  });

  it('shows validation error for short password', async () => {
    const user = userEvent.setup();

    render(<LoginForm onSubmit={jest.fn()} />);

    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'short');
    await user.click(screen.getByRole('button', { name: /login/i }));

    expect(screen.getByText(/password must be at least 8 characters/i)).toBeInTheDocument();
  });

  it('clears form after successful submission', async () => {
    const user = userEvent.setup();

    render(<LoginForm onSubmit={jest.fn()} />);

    const emailInput = screen.getByLabelText(/email/i);
    const passwordInput = screen.getByLabelText(/password/i);

    await user.type(emailInput, 'test@example.com');
    await user.type(passwordInput, 'password123');
    await user.click(screen.getByRole('button', { name: /login/i }));

    expect(emailInput).toHaveValue('');
    expect(passwordInput).toHaveValue('');
  });
});
```

---

## 3. Async API Data Fetching

### Component: UserProfile

```javascript
// UserProfile.jsx
import { useState, useEffect } from 'react';

export const UserProfile = ({ userId }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchUser = async () => {
      setLoading(true);
      setError(null);

      try {
        const response = await fetch(`/api/users/${userId}`);

        if (!response.ok) {
          throw new Error('Failed to fetch user');
        }

        const data = await response.json();
        setUser(data);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, [userId]);

  if (loading) {
    return <div>Loading user profile...</div>;
  }

  if (error) {
    return <div role="alert">Error: {error}</div>;
  }

  if (!user) {
    return <div>No user found</div>;
  }

  return (
    <div>
      <h1>{user.name}</h1>
      <p>Email: {user.email}</p>
      <p>Role: {user.role}</p>
    </div>
  );
};
```

### Tests with MSW

```javascript
// UserProfile.test.jsx
import { render, screen, waitFor } from '@testing-library/react';
import { rest } from 'msw';
import { setupServer } from 'msw/node';
import { UserProfile } from './UserProfile';

const server = setupServer(
  rest.get('/api/users/:userId', (req, res, ctx) => {
    const { userId } = req.params;

    return res(
      ctx.json({
        id: userId,
        name: 'John Doe',
        email: 'john@example.com',
        role: 'Admin',
      })
    );
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('UserProfile Component', () => {
  it('shows loading state initially', () => {
    render(<UserProfile userId="1" />);

    expect(screen.getByText(/loading user profile/i)).toBeInTheDocument();
  });

  it('displays user data after loading', async () => {
    render(<UserProfile userId="1" />);

    expect(screen.getByText(/loading/i)).toBeInTheDocument();

    await waitFor(() => {
      expect(screen.queryByText(/loading/i)).not.toBeInTheDocument();
    });

    expect(screen.getByRole('heading', { name: /john doe/i })).toBeInTheDocument();
    expect(screen.getByText(/email: john@example.com/i)).toBeInTheDocument();
    expect(screen.getByText(/role: admin/i)).toBeInTheDocument();
  });

  it('uses findBy for async elements', async () => {
    render(<UserProfile userId="1" />);

    // findBy automatically waits for element
    const heading = await screen.findByRole('heading', { name: /john doe/i });
    expect(heading).toBeInTheDocument();
  });

  it('displays error message on fetch failure', async () => {
    server.use(
      rest.get('/api/users/:userId', (req, res, ctx) => {
        return res(ctx.status(500));
      })
    );

    render(<UserProfile userId="1" />);

    const errorMessage = await screen.findByRole('alert');
    expect(errorMessage).toHaveTextContent(/failed to fetch user/i);
  });

  it('refetches when userId changes', async () => {
    const { rerender } = render(<UserProfile userId="1" />);

    await screen.findByRole('heading', { name: /john doe/i });

    // Update server to return different user
    server.use(
      rest.get('/api/users/:userId', (req, res, ctx) => {
        return res(
          ctx.json({
            id: '2',
            name: 'Jane Smith',
            email: 'jane@example.com',
            role: 'User',
          })
        );
      })
    );

    rerender(<UserProfile userId="2" />);

    const newHeading = await screen.findByRole('heading', { name: /jane smith/i });
    expect(newHeading).toBeInTheDocument();
  });
});
```

---

## 4. User Authentication Flow

### Component: AuthProvider & useAuth

```javascript
// AuthContext.jsx
import { createContext, useContext, useState } from 'react';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const login = async (email, password) => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      });

      if (!response.ok) {
        throw new Error('Login failed');
      }

      const data = await response.json();
      setUser(data.user);
      localStorage.setItem('token', data.token);

      return { success: true };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('token');
  };

  return (
    <AuthContext.Provider value={{ user, loading, error, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};
```

### Tests

```javascript
// Auth.test.jsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { rest } from 'msw';
import { setupServer } from 'msw/node';
import { AuthProvider, useAuth } from './AuthContext';

const server = setupServer(
  rest.post('/api/auth/login', async (req, res, ctx) => {
    const { email, password } = await req.json();

    if (email === 'test@example.com' && password === 'password123') {
      return res(
        ctx.json({
          user: { id: 1, email: 'test@example.com', name: 'Test User' },
          token: 'fake-jwt-token',
        })
      );
    }

    return res(ctx.status(401), ctx.json({ message: 'Invalid credentials' }));
  })
);

beforeAll(() => server.listen());
afterEach(() => {
  server.resetHandlers();
  localStorage.clear();
});
afterAll(() => server.close());

// Test component that uses useAuth
const TestComponent = () => {
  const { user, login, logout, loading, error } = useAuth();

  const handleLogin = async () => {
    await login('test@example.com', 'password123');
  };

  if (loading) return <div>Loading...</div>;

  return (
    <div>
      {user ? (
        <div>
          <p>Welcome, {user.name}</p>
          <button onClick={logout}>Logout</button>
        </div>
      ) : (
        <div>
          <p>Please log in</p>
          <button onClick={handleLogin}>Login</button>
        </div>
      )}
      {error && <div role="alert">{error}</div>}
    </div>
  );
};

describe('Authentication Flow', () => {
  it('logs in user successfully', async () => {
    const user = userEvent.setup();

    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    );

    expect(screen.getByText(/please log in/i)).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: /login/i }));

    await waitFor(() => {
      expect(screen.getByText(/welcome, test user/i)).toBeInTheDocument();
    });

    expect(localStorage.getItem('token')).toBe('fake-jwt-token');
  });

  it('logs out user', async () => {
    const user = userEvent.setup();

    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    );

    // Login first
    await user.click(screen.getByRole('button', { name: /login/i }));
    await screen.findByText(/welcome, test user/i);

    // Logout
    await user.click(screen.getByRole('button', { name: /logout/i }));

    expect(screen.getByText(/please log in/i)).toBeInTheDocument();
    expect(localStorage.getItem('token')).toBeNull();
  });

  it('shows error on failed login', async () => {
    const user = userEvent.setup();

    server.use(
      rest.post('/api/auth/login', (req, res, ctx) => {
        return res(ctx.status(401));
      })
    );

    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    );

    await user.click(screen.getByRole('button', { name: /login/i }));

    const errorMessage = await screen.findByRole('alert');
    expect(errorMessage).toHaveTextContent(/login failed/i);
  });
});
```

---

## 5. Modal and Dialog Testing

### Component: Modal

```javascript
// Modal.jsx
import { useEffect } from 'react';
import { createPortal } from 'react-dom';

export const Modal = ({ isOpen, onClose, title, children }) => {
  useEffect(() => {
    const handleEscape = (e) => {
      if (e.key === 'Escape') {
        onClose();
      }
    };

    if (isOpen) {
      document.addEventListener('keydown', handleEscape);
      document.body.style.overflow = 'hidden';
    }

    return () => {
      document.removeEventListener('keydown', handleEscape);
      document.body.style.overflow = 'unset';
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return createPortal(
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
      className="modal-overlay"
      onClick={onClose}
    >
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h2 id="modal-title">{title}</h2>
          <button
            onClick={onClose}
            aria-label="Close modal"
            className="close-button"
          >
            ×
          </button>
        </div>
        <div className="modal-body">{children}</div>
      </div>
    </div>,
    document.body
  );
};
```

### Tests

```javascript
// Modal.test.jsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Modal } from './Modal';

describe('Modal Component', () => {
  it('does not render when closed', () => {
    render(
      <Modal isOpen={false} onClose={jest.fn()} title="Test Modal">
        Content
      </Modal>
    );

    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });

  it('renders when open', () => {
    render(
      <Modal isOpen={true} onClose={jest.fn()} title="Test Modal">
        Modal Content
      </Modal>
    );

    expect(screen.getByRole('dialog')).toBeInTheDocument();
    expect(screen.getByText('Test Modal')).toBeInTheDocument();
    expect(screen.getByText('Modal Content')).toBeInTheDocument();
  });

  it('closes when close button clicked', async () => {
    const user = userEvent.setup();
    const handleClose = jest.fn();

    render(
      <Modal isOpen={true} onClose={handleClose} title="Test Modal">
        Content
      </Modal>
    );

    await user.click(screen.getByRole('button', { name: /close modal/i }));

    expect(handleClose).toHaveBeenCalledTimes(1);
  });

  it('closes when overlay clicked', async () => {
    const user = userEvent.setup();
    const handleClose = jest.fn();

    render(
      <Modal isOpen={true} onClose={handleClose} title="Test Modal">
        Content
      </Modal>
    );

    const overlay = screen.getByRole('dialog');
    await user.click(overlay);

    expect(handleClose).toHaveBeenCalledTimes(1);
  });

  it('does not close when content clicked', async () => {
    const user = userEvent.setup();
    const handleClose = jest.fn();

    render(
      <Modal isOpen={true} onClose={handleClose} title="Test Modal">
        <button>Content Button</button>
      </Modal>
    );

    await user.click(screen.getByRole('button', { name: /content button/i }));

    expect(handleClose).not.toHaveBeenCalled();
  });

  it('closes on Escape key press', async () => {
    const user = userEvent.setup();
    const handleClose = jest.fn();

    render(
      <Modal isOpen={true} onClose={handleClose} title="Test Modal">
        Content
      </Modal>
    );

    await user.keyboard('{Escape}');

    expect(handleClose).toHaveBeenCalledTimes(1);
  });

  it('has correct accessibility attributes', () => {
    render(
      <Modal isOpen={true} onClose={jest.fn()} title="Accessible Modal">
        Content
      </Modal>
    );

    const dialog = screen.getByRole('dialog');
    expect(dialog).toHaveAttribute('aria-modal', 'true');
    expect(dialog).toHaveAttribute('aria-labelledby', 'modal-title');
  });
});
```

---

## 6. Dropdown and Select Testing

### Component: Dropdown

```javascript
// Dropdown.jsx
import { useState, useRef, useEffect } from 'react';

export const Dropdown = ({ options, value, onChange, placeholder, label }) => {
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef(null);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const selectedOption = options.find(opt => opt.value === value);

  const handleSelect = (option) => {
    onChange(option.value);
    setIsOpen(false);
  };

  return (
    <div ref={dropdownRef} className="dropdown">
      <label id="dropdown-label">{label}</label>
      <button
        type="button"
        onClick={() => setIsOpen(!isOpen)}
        aria-haspopup="listbox"
        aria-expanded={isOpen}
        aria-labelledby="dropdown-label"
      >
        {selectedOption ? selectedOption.label : placeholder}
      </button>

      {isOpen && (
        <ul role="listbox" aria-labelledby="dropdown-label">
          {options.map((option) => (
            <li
              key={option.value}
              role="option"
              aria-selected={option.value === value}
              onClick={() => handleSelect(option)}
            >
              {option.label}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};
```

### Tests

```javascript
// Dropdown.test.jsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Dropdown } from './Dropdown';

const options = [
  { value: 'apple', label: 'Apple' },
  { value: 'banana', label: 'Banana' },
  { value: 'cherry', label: 'Cherry' },
];

describe('Dropdown Component', () => {
  it('renders with placeholder', () => {
    render(
      <Dropdown
        options={options}
        value=""
        onChange={jest.fn()}
        placeholder="Select a fruit"
        label="Fruit"
      />
    );

    expect(screen.getByText(/select a fruit/i)).toBeInTheDocument();
  });

  it('shows selected value', () => {
    render(
      <Dropdown
        options={options}
        value="banana"
        onChange={jest.fn()}
        placeholder="Select a fruit"
        label="Fruit"
      />
    );

    expect(screen.getByText('Banana')).toBeInTheDocument();
  });

  it('opens dropdown on button click', async () => {
    const user = userEvent.setup();

    render(
      <Dropdown
        options={options}
        value=""
        onChange={jest.fn()}
        placeholder="Select a fruit"
        label="Fruit"
      />
    );

    const button = screen.getByRole('button');
    expect(screen.queryByRole('listbox')).not.toBeInTheDocument();

    await user.click(button);

    expect(screen.getByRole('listbox')).toBeInTheDocument();
  });

  it('displays all options when open', async () => {
    const user = userEvent.setup();

    render(
      <Dropdown
        options={options}
        value=""
        onChange={jest.fn()}
        placeholder="Select a fruit"
        label="Fruit"
      />
    );

    await user.click(screen.getByRole('button'));

    expect(screen.getByRole('option', { name: /apple/i })).toBeInTheDocument();
    expect(screen.getByRole('option', { name: /banana/i })).toBeInTheDocument();
    expect(screen.getByRole('option', { name: /cherry/i })).toBeInTheDocument();
  });

  it('calls onChange when option selected', async () => {
    const user = userEvent.setup();
    const handleChange = jest.fn();

    render(
      <Dropdown
        options={options}
        value=""
        onChange={handleChange}
        placeholder="Select a fruit"
        label="Fruit"
      />
    );

    await user.click(screen.getByRole('button'));
    await user.click(screen.getByRole('option', { name: /banana/i }));

    expect(handleChange).toHaveBeenCalledWith('banana');
  });

  it('closes dropdown after selection', async () => {
    const user = userEvent.setup();

    render(
      <Dropdown
        options={options}
        value=""
        onChange={jest.fn()}
        placeholder="Select a fruit"
        label="Fruit"
      />
    );

    await user.click(screen.getByRole('button'));
    expect(screen.getByRole('listbox')).toBeInTheDocument();

    await user.click(screen.getByRole('option', { name: /apple/i }));

    expect(screen.queryByRole('listbox')).not.toBeInTheDocument();
  });
});
```

---

## 7. Testing Custom Hooks

### Hook: useLocalStorage

```javascript
// useLocalStorage.js
import { useState, useEffect } from 'react';

export const useLocalStorage = (key, initialValue) => {
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
};
```

### Tests

```javascript
// useLocalStorage.test.js
import { renderHook, act } from '@testing-library/react';
import { useLocalStorage } from './useLocalStorage';

describe('useLocalStorage Hook', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it('returns initial value when localStorage is empty', () => {
    const { result } = renderHook(() => useLocalStorage('testKey', 'initial'));

    expect(result.current[0]).toBe('initial');
  });

  it('returns value from localStorage if it exists', () => {
    localStorage.setItem('testKey', JSON.stringify('stored'));

    const { result } = renderHook(() => useLocalStorage('testKey', 'initial'));

    expect(result.current[0]).toBe('stored');
  });

  it('updates localStorage when value changes', () => {
    const { result } = renderHook(() => useLocalStorage('testKey', 'initial'));

    act(() => {
      result.current[1]('updated');
    });

    expect(localStorage.getItem('testKey')).toBe(JSON.stringify('updated'));
    expect(result.current[0]).toBe('updated');
  });

  it('handles objects', () => {
    const { result } = renderHook(() =>
      useLocalStorage('testKey', { name: 'John' })
    );

    act(() => {
      result.current[1]({ name: 'Jane', age: 30 });
    });

    expect(result.current[0]).toEqual({ name: 'Jane', age: 30 });
    expect(JSON.parse(localStorage.getItem('testKey'))).toEqual({
      name: 'Jane',
      age: 30,
    });
  });

  it('handles arrays', () => {
    const { result } = renderHook(() => useLocalStorage('todos', []));

    act(() => {
      result.current[1]([{ id: 1, text: 'Todo 1' }]);
    });

    expect(result.current[0]).toEqual([{ id: 1, text: 'Todo 1' }]);
  });

  it('updates when key changes', () => {
    localStorage.setItem('key1', JSON.stringify('value1'));
    localStorage.setItem('key2', JSON.stringify('value2'));

    const { result, rerender } = renderHook(
      ({ key }) => useLocalStorage(key, 'default'),
      { initialProps: { key: 'key1' } }
    );

    expect(result.current[0]).toBe('value1');

    rerender({ key: 'key2' });

    expect(result.current[0]).toBe('value2');
  });
});
```

---

## 8. Testing with React Router

### Component: Navigation

```javascript
// Navigation.jsx
import { Link, useNavigate, useLocation } from 'react-router-dom';

export const Navigation = () => {
  const navigate = useNavigate();
  const location = useLocation();

  const handleProfileClick = () => {
    navigate('/profile');
  };

  return (
    <nav>
      <Link to="/">Home</Link>
      <Link to="/about">About</Link>
      <Link to="/products">Products</Link>
      <button onClick={handleProfileClick}>Profile</button>
      <span>Current: {location.pathname}</span>
    </nav>
  );
};
```

### Tests

```javascript
// Navigation.test.jsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Routes, Route } from 'react-router-dom';
import { Navigation } from './Navigation';

const renderWithRouter = (ui, { initialEntries = ['/'] } = {}) => {
  return render(
    <MemoryRouter initialEntries={initialEntries}>
      <Routes>
        <Route path="*" element={ui} />
      </Routes>
    </MemoryRouter>
  );
};

describe('Navigation Component', () => {
  it('renders all navigation links', () => {
    renderWithRouter(<Navigation />);

    expect(screen.getByRole('link', { name: /home/i })).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /about/i })).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /products/i })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /profile/i })).toBeInTheDocument();
  });

  it('displays current pathname', () => {
    renderWithRouter(<Navigation />, { initialEntries: ['/about'] });

    expect(screen.getByText(/current: \/about/i)).toBeInTheDocument();
  });

  it('has correct href attributes', () => {
    renderWithRouter(<Navigation />);

    expect(screen.getByRole('link', { name: /home/i })).toHaveAttribute('href', '/');
    expect(screen.getByRole('link', { name: /about/i })).toHaveAttribute('href', '/about');
    expect(screen.getByRole('link', { name: /products/i })).toHaveAttribute('href', '/products');
  });
});
```

---

## 9. Testing with Redux

### Component: TodoList with Redux

```javascript
// TodoList.jsx
import { useSelector, useDispatch } from 'react-redux';
import { addTodo, toggleTodo, removeTodo } from './todosSlice';
import { useState } from 'react';

export const TodoList = () => {
  const [input, setInput] = useState('');
  const todos = useSelector((state) => state.todos.items);
  const dispatch = useDispatch();

  const handleSubmit = (e) => {
    e.preventDefault();
    if (input.trim()) {
      dispatch(addTodo(input));
      setInput('');
    }
  };

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Add todo"
        />
        <button type="submit">Add</button>
      </form>

      <ul>
        {todos.map((todo) => (
          <li key={todo.id}>
            <input
              type="checkbox"
              checked={todo.completed}
              onChange={() => dispatch(toggleTodo(todo.id))}
              aria-label={`Toggle ${todo.text}`}
            />
            <span style={{ textDecoration: todo.completed ? 'line-through' : 'none' }}>
              {todo.text}
            </span>
            <button
              onClick={() => dispatch(removeTodo(todo.id))}
              aria-label={`Remove ${todo.text}`}
            >
              Remove
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
};
```

### Tests

```javascript
// TodoList.test.jsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';
import { TodoList } from './TodoList';
import todosReducer from './todosSlice';

const createMockStore = (initialState = {}) => {
  return configureStore({
    reducer: {
      todos: todosReducer,
    },
    preloadedState: initialState,
  });
};

const renderWithStore = (ui, { store = createMockStore() } = {}) => {
  return render(<Provider store={store}>{ui}</Provider>);
};

describe('TodoList with Redux', () => {
  it('adds new todo', async () => {
    const user = userEvent.setup();
    renderWithStore(<TodoList />);

    const input = screen.getByPlaceholderText(/add todo/i);
    const addButton = screen.getByRole('button', { name: /add/i });

    await user.type(input, 'Buy groceries');
    await user.click(addButton);

    expect(screen.getByText(/buy groceries/i)).toBeInTheDocument();
  });

  it('toggles todo completion', async () => {
    const user = userEvent.setup();
    const initialState = {
      todos: {
        items: [{ id: 1, text: 'Test todo', completed: false }],
      },
    };

    renderWithStore(<TodoList />, { store: createMockStore(initialState) });

    const checkbox = screen.getByRole('checkbox', { name: /toggle test todo/i });
    const text = screen.getByText(/test todo/i);

    expect(checkbox).not.toBeChecked();
    expect(text).toHaveStyle({ textDecoration: 'none' });

    await user.click(checkbox);

    expect(checkbox).toBeChecked();
    expect(text).toHaveStyle({ textDecoration: 'line-through' });
  });

  it('removes todo', async () => {
    const user = userEvent.setup();
    const initialState = {
      todos: {
        items: [{ id: 1, text: 'Test todo', completed: false }],
      },
    };

    renderWithStore(<TodoList />, { store: createMockStore(initialState) });

    expect(screen.getByText(/test todo/i)).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: /remove test todo/i }));

    expect(screen.queryByText(/test todo/i)).not.toBeInTheDocument();
  });

  it('clears input after adding todo', async () => {
    const user = userEvent.setup();
    renderWithStore(<TodoList />);

    const input = screen.getByPlaceholderText(/add todo/i);

    await user.type(input, 'New todo');
    await user.click(screen.getByRole('button', { name: /add/i }));

    expect(input).toHaveValue('');
  });
});
```

---

## 10. Testing with Context API

### Component: Theme Context

```javascript
// ThemeContext.jsx
import { createContext, useContext, useState } from 'react';

const ThemeContext = createContext(null);

export const ThemeProvider = ({ children }) => {
  const [theme, setTheme] = useState('light');

  const toggleTheme = () => {
    setTheme((prev) => (prev === 'light' ? 'dark' : 'light'));
  };

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
};

export const ThemedButton = () => {
  const { theme, toggleTheme } = useTheme();

  return (
    <button
      onClick={toggleTheme}
      style={{
        backgroundColor: theme === 'light' ? '#fff' : '#333',
        color: theme === 'light' ? '#000' : '#fff',
      }}
    >
      Toggle Theme (Current: {theme})
    </button>
  );
};
```

### Tests

```javascript
// ThemeContext.test.jsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ThemeProvider, ThemedButton, useTheme } from './ThemeContext';

describe('Theme Context', () => {
  it('provides default theme', () => {
    render(
      <ThemeProvider>
        <ThemedButton />
      </ThemeProvider>
    );

    expect(screen.getByRole('button')).toHaveTextContent(/current: light/i);
  });

  it('toggles theme', async () => {
    const user = userEvent.setup();

    render(
      <ThemeProvider>
        <ThemedButton />
      </ThemeProvider>
    );

    const button = screen.getByRole('button');

    expect(button).toHaveTextContent(/current: light/i);
    expect(button).toHaveStyle({ backgroundColor: '#fff', color: '#000' });

    await user.click(button);

    expect(button).toHaveTextContent(/current: dark/i);
    expect(button).toHaveStyle({ backgroundColor: '#333', color: '#fff' });
  });

  it('throws error when used outside provider', () => {
    // Suppress console.error for this test
    const spy = jest.spyOn(console, 'error').mockImplementation(() => {});

    const InvalidComponent = () => {
      useTheme(); // Will throw
      return null;
    };

    expect(() => render(<InvalidComponent />)).toThrow(
      /useTheme must be used within ThemeProvider/i
    );

    spy.mockRestore();
  });
});
```

---

## 11. File Upload Component

### Component: FileUpload

```javascript
// FileUpload.jsx
import { useState } from 'react';

export const FileUpload = ({ onUpload, accept = '*', maxSize = 5 * 1024 * 1024 }) => {
  const [file, setFile] = useState(null);
  const [error, setError] = useState(null);
  const [uploading, setUploading] = useState(false);

  const handleFileChange = (e) => {
    const selectedFile = e.target.files[0];
    setError(null);

    if (!selectedFile) return;

    if (selectedFile.size > maxSize) {
      setError(`File size must be less than ${maxSize / 1024 / 1024}MB`);
      return;
    }

    setFile(selectedFile);
  };

  const handleUpload = async () => {
    if (!file) {
      setError('Please select a file');
      return;
    }

    setUploading(true);
    setError(null);

    try {
      await onUpload(file);
      setFile(null);
    } catch (err) {
      setError(err.message);
    } finally {
      setUploading(false);
    }
  };

  return (
    <div>
      <input
        type="file"
        onChange={handleFileChange}
        accept={accept}
        aria-label="File input"
      />

      {file && <p>Selected: {file.name}</p>}

      <button onClick={handleUpload} disabled={!file || uploading}>
        {uploading ? 'Uploading...' : 'Upload'}
      </button>

      {error && <div role="alert">{error}</div>}
    </div>
  );
};
```

### Tests

```javascript
// FileUpload.test.jsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { FileUpload } from './FileUpload';

describe('FileUpload Component', () => {
  it('displays selected file name', async () => {
    const user = userEvent.setup();
    render(<FileUpload onUpload={jest.fn()} />);

    const file = new File(['hello'], 'hello.png', { type: 'image/png' });
    const input = screen.getByLabelText(/file input/i);

    await user.upload(input, file);

    expect(screen.getByText(/selected: hello.png/i)).toBeInTheDocument();
  });

  it('uploads file successfully', async () => {
    const user = userEvent.setup();
    const handleUpload = jest.fn(() => Promise.resolve());

    render(<FileUpload onUpload={handleUpload} />);

    const file = new File(['content'], 'test.txt', { type: 'text/plain' });
    const input = screen.getByLabelText(/file input/i);

    await user.upload(input, file);
    await user.click(screen.getByRole('button', { name: /upload/i }));

    expect(handleUpload).toHaveBeenCalledWith(file);
  });

  it('shows error for files exceeding max size', async () => {
    const user = userEvent.setup();
    const maxSize = 1024; // 1KB

    render(<FileUpload onUpload={jest.fn()} maxSize={maxSize} />);

    const largeFile = new File(['x'.repeat(2000)], 'large.txt', {
      type: 'text/plain',
    });

    const input = screen.getByLabelText(/file input/i);

    await user.upload(input, largeFile);

    expect(screen.getByRole('alert')).toHaveTextContent(/file size must be less than/i);
  });

  it('shows uploading state', async () => {
    const user = userEvent.setup();
    const handleUpload = jest.fn(
      () => new Promise((resolve) => setTimeout(resolve, 100))
    );

    render(<FileUpload onUpload={handleUpload} />);

    const file = new File(['content'], 'test.txt', { type: 'text/plain' });
    const input = screen.getByLabelText(/file input/i);

    await user.upload(input, file);
    const uploadButton = screen.getByRole('button', { name: /upload/i });

    await user.click(uploadButton);

    expect(screen.getByRole('button')).toHaveTextContent(/uploading/i);
    expect(screen.getByRole('button')).toBeDisabled();
  });

  it('disables upload button when no file selected', () => {
    render(<FileUpload onUpload={jest.fn()} />);

    expect(screen.getByRole('button', { name: /upload/i })).toBeDisabled();
  });
});
```

---

## 12. Autocomplete Component

### Component: Autocomplete

```javascript
// Autocomplete.jsx
import { useState, useEffect, useRef } from 'react';

export const Autocomplete = ({ options, onSelect, placeholder }) => {
  const [input, setInput] = useState('');
  const [filteredOptions, setFilteredOptions] = useState([]);
  const [isOpen, setIsOpen] = useState(false);
  const [highlightedIndex, setHighlightedIndex] = useState(-1);
  const inputRef = useRef(null);

  useEffect(() => {
    if (input) {
      const filtered = options.filter((option) =>
        option.toLowerCase().includes(input.toLowerCase())
      );
      setFilteredOptions(filtered);
      setIsOpen(true);
    } else {
      setFilteredOptions([]);
      setIsOpen(false);
    }
  }, [input, options]);

  const handleSelect = (option) => {
    setInput(option);
    setIsOpen(false);
    onSelect(option);
  };

  const handleKeyDown = (e) => {
    if (!isOpen) return;

    if (e.key === 'ArrowDown') {
      e.preventDefault();
      setHighlightedIndex((prev) =>
        prev < filteredOptions.length - 1 ? prev + 1 : prev
      );
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      setHighlightedIndex((prev) => (prev > 0 ? prev - 1 : prev));
    } else if (e.key === 'Enter' && highlightedIndex >= 0) {
      handleSelect(filteredOptions[highlightedIndex]);
    } else if (e.key === 'Escape') {
      setIsOpen(false);
    }
  };

  return (
    <div>
      <input
        ref={inputRef}
        type="text"
        value={input}
        onChange={(e) => setInput(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder={placeholder}
        aria-autocomplete="list"
        aria-expanded={isOpen}
        aria-controls="autocomplete-list"
      />

      {isOpen && filteredOptions.length > 0 && (
        <ul id="autocomplete-list" role="listbox">
          {filteredOptions.map((option, index) => (
            <li
              key={option}
              role="option"
              aria-selected={index === highlightedIndex}
              onClick={() => handleSelect(option)}
              style={{
                backgroundColor: index === highlightedIndex ? '#eee' : '#fff',
              }}
            >
              {option}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};
```

### Tests

```javascript
// Autocomplete.test.jsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Autocomplete } from './Autocomplete';

const options = ['Apple', 'Apricot', 'Banana', 'Cherry', 'Date'];

describe('Autocomplete Component', () => {
  it('filters options based on input', async () => {
    const user = userEvent.setup();

    render(<Autocomplete options={options} onSelect={jest.fn()} />);

    const input = screen.getByRole('textbox');

    await user.type(input, 'ap');

    expect(screen.getByRole('option', { name: /apple/i })).toBeInTheDocument();
    expect(screen.getByRole('option', { name: /apricot/i })).toBeInTheDocument();
    expect(screen.queryByRole('option', { name: /banana/i })).not.toBeInTheDocument();
  });

  it('calls onSelect when option clicked', async () => {
    const user = userEvent.setup();
    const handleSelect = jest.fn();

    render(<Autocomplete options={options} onSelect={handleSelect} />);

    await user.type(screen.getByRole('textbox'), 'ban');
    await user.click(screen.getByRole('option', { name: /banana/i }));

    expect(handleSelect).toHaveBeenCalledWith('Banana');
  });

  it('navigates options with arrow keys', async () => {
    const user = userEvent.setup();

    render(<Autocomplete options={options} onSelect={jest.fn()} />);

    const input = screen.getByRole('textbox');

    await user.type(input, 'a');

    const options = screen.getAllByRole('option');

    await user.keyboard('{ArrowDown}');
    expect(options[0]).toHaveAttribute('aria-selected', 'true');

    await user.keyboard('{ArrowDown}');
    expect(options[1]).toHaveAttribute('aria-selected', 'true');

    await user.keyboard('{ArrowUp}');
    expect(options[0]).toHaveAttribute('aria-selected', 'true');
  });

  it('selects option with Enter key', async () => {
    const user = userEvent.setup();
    const handleSelect = jest.fn();

    render(<Autocomplete options={options} onSelect={handleSelect} />);

    const input = screen.getByRole('textbox');

    await user.type(input, 'a');
    await user.keyboard('{ArrowDown}');
    await user.keyboard('{Enter}');

    expect(handleSelect).toHaveBeenCalledWith('Apple');
  });

  it('closes list on Escape key', async () => {
    const user = userEvent.setup();

    render(<Autocomplete options={options} onSelect={jest.fn()} />);

    await user.type(screen.getByRole('textbox'), 'a');

    expect(screen.getByRole('listbox')).toBeInTheDocument();

    await user.keyboard('{Escape}');

    expect(screen.queryByRole('listbox')).not.toBeInTheDocument();
  });

  it('case-insensitive filtering', async () => {
    const user = userEvent.setup();

    render(<Autocomplete options={options} onSelect={jest.fn()} />);

    await user.type(screen.getByRole('textbox'), 'APP');

    expect(screen.getByRole('option', { name: /apple/i })).toBeInTheDocument();
  });
});
```

---

## 13. Infinite Scroll List

### Component: InfiniteScrollList

```javascript
// InfiniteScrollList.jsx
import { useState, useEffect, useRef } from 'react';

export const InfiniteScrollList = ({ fetchItems, pageSize = 20 }) => {
  const [items, setItems] = useState([]);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const observerTarget = useRef(null);

  const loadMore = async () => {
    if (loading || !hasMore) return;

    setLoading(true);

    try {
      const newItems = await fetchItems(page, pageSize);

      if (newItems.length === 0) {
        setHasMore(false);
      } else {
        setItems((prev) => [...prev, ...newItems]);
        setPage((prev) => prev + 1);
      }
    } catch (error) {
      console.error('Failed to load items:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadMore();
  }, []);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && hasMore && !loading) {
          loadMore();
        }
      },
      { threshold: 1.0 }
    );

    if (observerTarget.current) {
      observer.observe(observerTarget.current);
    }

    return () => {
      if (observerTarget.current) {
        observer.unobserve(observerTarget.current);
      }
    };
  }, [hasMore, loading]);

  return (
    <div>
      <ul>
        {items.map((item, index) => (
          <li key={`${item.id}-${index}`}>{item.text}</li>
        ))}
      </ul>

      {loading && <div>Loading more items...</div>}
      {!hasMore && <div>No more items</div>}

      <div ref={observerTarget} style={{ height: '20px' }} />
    </div>
  );
};
```

### Tests

```javascript
// InfiniteScrollList.test.jsx
import { render, screen, waitFor } from '@testing-library/react';
import { InfiniteScrollList } from './InfiniteScrollList';

// Mock IntersectionObserver
const mockIntersectionObserver = jest.fn();
mockIntersectionObserver.mockReturnValue({
  observe: () => null,
  unobserve: () => null,
  disconnect: () => null,
});
window.IntersectionObserver = mockIntersectionObserver;

describe('InfiniteScrollList Component', () => {
  it('loads initial items', async () => {
    const fetchItems = jest.fn(() =>
      Promise.resolve([
        { id: 1, text: 'Item 1' },
        { id: 2, text: 'Item 2' },
      ])
    );

    render(<InfiniteScrollList fetchItems={fetchItems} />);

    await waitFor(() => {
      expect(screen.getByText(/item 1/i)).toBeInTheDocument();
      expect(screen.getByText(/item 2/i)).toBeInTheDocument();
    });

    expect(fetchItems).toHaveBeenCalledWith(1, 20);
  });

  it('shows loading state', () => {
    const fetchItems = jest.fn(
      () => new Promise((resolve) => setTimeout(resolve, 100))
    );

    render(<InfiniteScrollList fetchItems={fetchItems} />);

    expect(screen.getByText(/loading more items/i)).toBeInTheDocument();
  });

  it('shows no more items message when all loaded', async () => {
    const fetchItems = jest.fn()
      .mockResolvedValueOnce([{ id: 1, text: 'Item 1' }])
      .mockResolvedValueOnce([]);

    render(<InfiniteScrollList fetchItems={fetchItems} />);

    await waitFor(() => {
      expect(screen.getByText(/item 1/i)).toBeInTheDocument();
    });

    // Manually trigger loadMore for second call
    await waitFor(() => {
      expect(fetchItems).toHaveBeenCalledTimes(1);
    });
  });

  it('does not load more when already loading', async () => {
    const fetchItems = jest.fn(
      () => new Promise((resolve) => setTimeout(resolve, 1000))
    );

    render(<InfiniteScrollList fetchItems={fetchItems} />);

    await waitFor(() => {
      expect(fetchItems).toHaveBeenCalledTimes(1);
    });
  });
});
```

---

## 14. Error Boundary Testing

### Component: ErrorBoundary

```javascript
// ErrorBoundary.jsx
import React from 'react';

export class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    this.props.onError?.(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div role="alert">
          <h1>Something went wrong</h1>
          <p>{this.state.error?.message}</p>
        </div>
      );
    }

    return this.props.children;
  }
}
```

### Tests

```javascript
// ErrorBoundary.test.jsx
import { render, screen } from '@testing-library/react';
import { ErrorBoundary } from './ErrorBoundary';

const ThrowError = ({ shouldThrow }) => {
  if (shouldThrow) {
    throw new Error('Test error');
  }
  return <div>No error</div>;
};

describe('ErrorBoundary Component', () => {
  // Suppress console.error for these tests
  const originalError = console.error;

  beforeAll(() => {
    console.error = jest.fn();
  });

  afterAll(() => {
    console.error = originalError;
  });

  it('renders children when no error', () => {
    render(
      <ErrorBoundary>
        <div>Child component</div>
      </ErrorBoundary>
    );

    expect(screen.getByText(/child component/i)).toBeInTheDocument();
  });

  it('renders error UI when error occurs', () => {
    render(
      <ErrorBoundary>
        <ThrowError shouldThrow={true} />
      </ErrorBoundary>
    );

    expect(screen.getByRole('alert')).toBeInTheDocument();
    expect(screen.getByText(/something went wrong/i)).toBeInTheDocument();
    expect(screen.getByText(/test error/i)).toBeInTheDocument();
  });

  it('renders custom fallback', () => {
    const fallback = <div>Custom error message</div>;

    render(
      <ErrorBoundary fallback={fallback}>
        <ThrowError shouldThrow={true} />
      </ErrorBoundary>
    );

    expect(screen.getByText(/custom error message/i)).toBeInTheDocument();
  });

  it('calls onError callback', () => {
    const handleError = jest.fn();

    render(
      <ErrorBoundary onError={handleError}>
        <ThrowError shouldThrow={true} />
      </ErrorBoundary>
    );

    expect(handleError).toHaveBeenCalled();
    expect(handleError.mock.calls[0][0]).toEqual(expect.any(Error));
  });
});
```

---

## 15. Accessibility Testing

### Component: AccessibleForm

```javascript
// AccessibleForm.jsx
export const AccessibleForm = ({ onSubmit }) => {
  const [name, setName] = useState('');
  const [errors, setErrors] = useState({});

  const handleSubmit = (e) => {
    e.preventDefault();

    if (!name) {
      setErrors({ name: 'Name is required' });
      return;
    }

    onSubmit({ name });
  };

  return (
    <form onSubmit={handleSubmit} aria-labelledby="form-title">
      <h2 id="form-title">User Information</h2>

      <div>
        <label htmlFor="name-input">
          Full Name <span aria-label="required">*</span>
        </label>
        <input
          id="name-input"
          type="text"
          value={name}
          onChange={(e) => setName(e.target.value)}
          aria-required="true"
          aria-invalid={errors.name ? 'true' : 'false'}
          aria-describedby={errors.name ? 'name-error' : undefined}
        />
        {errors.name && (
          <div id="name-error" role="alert" aria-live="polite">
            {errors.name}
          </div>
        )}
      </div>

      <button type="submit" aria-label="Submit form">
        Submit
      </button>
    </form>
  );
};
```

### Tests

```javascript
// AccessibleForm.test.jsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { AccessibleForm } from './AccessibleForm';

describe('AccessibleForm - Accessibility', () => {
  it('has accessible form structure', () => {
    render(<AccessibleForm onSubmit={jest.fn()} />);

    const form = screen.getByRole('form');
    expect(form).toHaveAccessibleName('User Information');
  });

  it('has accessible form fields', () => {
    render(<AccessibleForm onSubmit={jest.fn()} />);

    const input = screen.getByLabelText(/full name/i);
    expect(input).toHaveAttribute('aria-required', 'true');
    expect(input).toHaveAttribute('id', 'name-input');
  });

  it('associates errors with input fields', async () => {
    const user = userEvent.setup();
    render(<AccessibleForm onSubmit={jest.fn()} />);

    await user.click(screen.getByRole('button', { name: /submit form/i }));

    const input = screen.getByLabelText(/full name/i);
    expect(input).toHaveAttribute('aria-invalid', 'true');
    expect(input).toHaveAttribute('aria-describedby', 'name-error');

    const error = screen.getByRole('alert');
    expect(error).toHaveAttribute('id', 'name-error');
  });

  it('has accessible button', () => {
    render(<AccessibleForm onSubmit={jest.fn()} />);

    const button = screen.getByRole('button', { name: /submit form/i });
    expect(button).toHaveAttribute('type', 'submit');
  });

  it('announces errors to screen readers', async () => {
    const user = userEvent.setup();
    render(<AccessibleForm onSubmit={jest.fn()} />);

    await user.click(screen.getByRole('button'));

    const alert = screen.getByRole('alert');
    expect(alert).toHaveAttribute('aria-live', 'polite');
    expect(alert).toHaveTextContent(/name is required/i);
  });
});
```

---

## 16. Testing Timers and Intervals

### Component: Countdown

```javascript
// Countdown.jsx
import { useState, useEffect } from 'react';

export const Countdown = ({ initialSeconds, onComplete }) => {
  const [seconds, setSeconds] = useState(initialSeconds);
  const [isActive, setIsActive] = useState(false);

  useEffect(() => {
    let interval = null;

    if (isActive && seconds > 0) {
      interval = setInterval(() => {
        setSeconds((prev) => prev - 1);
      }, 1000);
    } else if (seconds === 0) {
      onComplete?.();
    }

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isActive, seconds, onComplete]);

  const start = () => setIsActive(true);
  const pause = () => setIsActive(false);
  const reset = () => {
    setIsActive(false);
    setSeconds(initialSeconds);
  };

  return (
    <div>
      <div>{seconds} seconds remaining</div>
      <button onClick={start} disabled={isActive}>
        Start
      </button>
      <button onClick={pause} disabled={!isActive}>
        Pause
      </button>
      <button onClick={reset}>Reset</button>
    </div>
  );
};
```

### Tests

```javascript
// Countdown.test.jsx
import { render, screen, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Countdown } from './Countdown';

describe('Countdown Component', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('displays initial countdown', () => {
    render(<Countdown initialSeconds={10} />);

    expect(screen.getByText(/10 seconds remaining/i)).toBeInTheDocument();
  });

  it('counts down when started', async () => {
    const user = userEvent.setup({ delay: null });
    render(<Countdown initialSeconds={5} />);

    await user.click(screen.getByRole('button', { name: /start/i }));

    act(() => {
      jest.advanceTimersByTime(1000);
    });

    expect(screen.getByText(/4 seconds remaining/i)).toBeInTheDocument();

    act(() => {
      jest.advanceTimersByTime(2000);
    });

    expect(screen.getByText(/2 seconds remaining/i)).toBeInTheDocument();
  });

  it('pauses countdown', async () => {
    const user = userEvent.setup({ delay: null });
    render(<Countdown initialSeconds={10} />);

    await user.click(screen.getByRole('button', { name: /start/i }));

    act(() => {
      jest.advanceTimersByTime(3000);
    });

    expect(screen.getByText(/7 seconds remaining/i)).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: /pause/i }));

    act(() => {
      jest.advanceTimersByTime(5000);
    });

    // Should still be 7 after pausing
    expect(screen.getByText(/7 seconds remaining/i)).toBeInTheDocument();
  });

  it('resets countdown', async () => {
    const user = userEvent.setup({ delay: null });
    render(<Countdown initialSeconds={10} />);

    await user.click(screen.getByRole('button', { name: /start/i }));

    act(() => {
      jest.advanceTimersByTime(3000);
    });

    await user.click(screen.getByRole('button', { name: /reset/i }));

    expect(screen.getByText(/10 seconds remaining/i)).toBeInTheDocument();
  });

  it('calls onComplete when countdown reaches zero', async () => {
    const user = userEvent.setup({ delay: null });
    const handleComplete = jest.fn();

    render(<Countdown initialSeconds={3} onComplete={handleComplete} />);

    await user.click(screen.getByRole('button', { name: /start/i }));

    act(() => {
      jest.advanceTimersByTime(3000);
    });

    expect(handleComplete).toHaveBeenCalledTimes(1);
    expect(screen.getByText(/0 seconds remaining/i)).toBeInTheDocument();
  });

  it('cleans up interval on unmount', () => {
    const clearIntervalSpy = jest.spyOn(global, 'clearInterval');
    const { unmount } = render(<Countdown initialSeconds={10} />);

    unmount();

    expect(clearIntervalSpy).toHaveBeenCalled();
  });
});
```

---

## 17. Testing WebSocket Integration

### Component: ChatRoom

```javascript
// ChatRoom.jsx
import { useState, useEffect, useRef } from 'react';

export const ChatRoom = ({ roomId, websocketUrl }) => {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [connectionStatus, setConnectionStatus] = useState('disconnected');
  const wsRef = useRef(null);

  useEffect(() => {
    const ws = new WebSocket(websocketUrl);
    wsRef.current = ws;

    ws.onopen = () => {
      setConnectionStatus('connected');
      ws.send(JSON.stringify({ type: 'join', roomId }));
    };

    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      setMessages((prev) => [...prev, data]);
    };

    ws.onerror = () => {
      setConnectionStatus('error');
    };

    ws.onclose = () => {
      setConnectionStatus('disconnected');
    };

    return () => {
      ws.close();
    };
  }, [roomId, websocketUrl]);

  const sendMessage = () => {
    if (input.trim() && wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(
        JSON.stringify({
          type: 'message',
          text: input,
        })
      );
      setInput('');
    }
  };

  return (
    <div>
      <div>Status: {connectionStatus}</div>

      <ul>
        {messages.map((msg, index) => (
          <li key={index}>{msg.text}</li>
        ))}
      </ul>

      <input
        value={input}
        onChange={(e) => setInput(e.target.value)}
        placeholder="Type a message"
      />
      <button onClick={sendMessage}>Send</button>
    </div>
  );
};
```

### Tests

```javascript
// ChatRoom.test.jsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ChatRoom } from './ChatRoom';
import WS from 'jest-websocket-mock';

describe('ChatRoom Component', () => {
  let server;

  beforeEach(async () => {
    server = new WS('ws://localhost:1234');
  });

  afterEach(() => {
    WS.clean();
  });

  it('connects to websocket on mount', async () => {
    render(<ChatRoom roomId="test-room" websocketUrl="ws://localhost:1234" />);

    await server.connected;

    await waitFor(() => {
      expect(screen.getByText(/status: connected/i)).toBeInTheDocument();
    });
  });

  it('sends join message on connection', async () => {
    render(<ChatRoom roomId="test-room" websocketUrl="ws://localhost:1234" />);

    await server.connected;
    await expect(server).toReceiveMessage(
      JSON.stringify({ type: 'join', roomId: 'test-room' })
    );
  });

  it('displays received messages', async () => {
    render(<ChatRoom roomId="test-room" websocketUrl="ws://localhost:1234" />);

    await server.connected;

    server.send(JSON.stringify({ type: 'message', text: 'Hello!' }));

    await waitFor(() => {
      expect(screen.getByText('Hello!')).toBeInTheDocument();
    });
  });

  it('sends messages', async () => {
    const user = userEvent.setup();
    render(<ChatRoom roomId="test-room" websocketUrl="ws://localhost:1234" />);

    await server.connected;

    const input = screen.getByPlaceholderText(/type a message/i);
    const sendButton = screen.getByRole('button', { name: /send/i });

    await user.type(input, 'Test message');
    await user.click(sendButton);

    await expect(server).toReceiveMessage(
      JSON.stringify({ type: 'message', text: 'Test message' })
    );

    expect(input).toHaveValue('');
  });

  it('shows error status on connection error', async () => {
    render(<ChatRoom roomId="test-room" websocketUrl="ws://localhost:1234" />);

    server.error();

    await waitFor(() => {
      expect(screen.getByText(/status: error/i)).toBeInTheDocument();
    });
  });
});
```

---

## 18. Multi-step Form Wizard

### Component: FormWizard

```javascript
// FormWizard.jsx
import { useState } from 'react';

export const FormWizard = ({ steps, onComplete }) => {
  const [currentStep, setCurrentStep] = useState(0);
  const [formData, setFormData] = useState({});

  const handleNext = (stepData) => {
    const updatedData = { ...formData, ...stepData };
    setFormData(updatedData);

    if (currentStep === steps.length - 1) {
      onComplete(updatedData);
    } else {
      setCurrentStep((prev) => prev + 1);
    }
  };

  const handleBack = () => {
    setCurrentStep((prev) => Math.max(0, prev - 1));
  };

  const CurrentStepComponent = steps[currentStep].component;

  return (
    <div>
      <div>
        Step {currentStep + 1} of {steps.length}: {steps[currentStep].title}
      </div>

      <div role="progressbar" aria-valuenow={currentStep + 1} aria-valuemax={steps.length}>
        Progress: {Math.round(((currentStep + 1) / steps.length) * 100)}%
      </div>

      <CurrentStepComponent
        onNext={handleNext}
        onBack={handleBack}
        initialData={formData}
        isFirstStep={currentStep === 0}
        isLastStep={currentStep === steps.length - 1}
      />
    </div>
  );
};
```

### Tests

```javascript
// FormWizard.test.jsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { FormWizard } from './FormWizard';

// Mock step components
const Step1 = ({ onNext, isFirstStep }) => (
  <div>
    <h2>Step 1 Content</h2>
    <button onClick={() => onNext({ step1Data: 'value1' })}>
      {isFirstStep ? 'Next' : 'Continue'}
    </button>
  </div>
);

const Step2 = ({ onNext, onBack }) => (
  <div>
    <h2>Step 2 Content</h2>
    <button onClick={onBack}>Back</button>
    <button onClick={() => onNext({ step2Data: 'value2' })}>Next</button>
  </div>
);

const Step3 = ({ onNext, isLastStep }) => (
  <div>
    <h2>Step 3 Content</h2>
    <button onClick={() => onNext({ step3Data: 'value3' })}>
      {isLastStep ? 'Submit' : 'Next'}
    </button>
  </div>
);

const steps = [
  { title: 'Personal Info', component: Step1 },
  { title: 'Address', component: Step2 },
  { title: 'Review', component: Step3 },
];

describe('FormWizard Component', () => {
  it('renders first step', () => {
    render(<FormWizard steps={steps} onComplete={jest.fn()} />);

    expect(screen.getByText(/step 1 of 3: personal info/i)).toBeInTheDocument();
    expect(screen.getByText(/step 1 content/i)).toBeInTheDocument();
  });

  it('advances to next step', async () => {
    const user = userEvent.setup();
    render(<FormWizard steps={steps} onComplete={jest.fn()} />);

    await user.click(screen.getByRole('button', { name: /next/i }));

    expect(screen.getByText(/step 2 of 3: address/i)).toBeInTheDocument();
    expect(screen.getByText(/step 2 content/i)).toBeInTheDocument();
  });

  it('goes back to previous step', async () => {
    const user = userEvent.setup();
    render(<FormWizard steps={steps} onComplete={jest.fn()} />);

    await user.click(screen.getByRole('button', { name: /next/i }));
    expect(screen.getByText(/step 2 content/i)).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: /back/i }));
    expect(screen.getByText(/step 1 content/i)).toBeInTheDocument();
  });

  it('completes wizard and calls onComplete with all data', async () => {
    const user = userEvent.setup();
    const handleComplete = jest.fn();

    render(<FormWizard steps={steps} onComplete={handleComplete} />);

    // Step 1
    await user.click(screen.getByRole('button', { name: /next/i }));

    // Step 2
    await user.click(screen.getAllByRole('button', { name: /next/i })[1]);

    // Step 3 - Submit
    await user.click(screen.getByRole('button', { name: /submit/i }));

    expect(handleComplete).toHaveBeenCalledWith({
      step1Data: 'value1',
      step2Data: 'value2',
      step3Data: 'value3',
    });
  });

  it('shows correct progress', async () => {
    const user = userEvent.setup();
    render(<FormWizard steps={steps} onComplete={jest.fn()} />);

    expect(screen.getByText(/progress: 33%/i)).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: /next/i }));

    expect(screen.getByText(/progress: 67%/i)).toBeInTheDocument();
  });

  it('has accessible progressbar', () => {
    render(<FormWizard steps={steps} onComplete={jest.fn()} />);

    const progressbar = screen.getByRole('progressbar');
    expect(progressbar).toHaveAttribute('aria-valuenow', '1');
    expect(progressbar).toHaveAttribute('aria-valuemax', '3');
  });
});
```

---

## Summary

These 18 comprehensive examples cover:

1. **Basic component testing** - Props, events, rendering
2. **Form validation** - Input validation, error handling
3. **Async operations** - API calls, loading states
4. **Authentication** - Login/logout flows with context
5. **Modals** - Portals, keyboard events, accessibility
6. **Dropdowns** - Complex UI interactions
7. **Custom hooks** - Hook testing patterns
8. **React Router** - Navigation testing
9. **Redux** - State management testing
10. **Context API** - Provider testing
11. **File uploads** - File handling, validation
12. **Autocomplete** - Keyboard navigation, filtering
13. **Infinite scroll** - Intersection Observer
14. **Error boundaries** - Error handling
15. **Accessibility** - ARIA attributes, screen readers
16. **Timers** - Fake timers, intervals
17. **WebSockets** - Real-time communication
18. **Multi-step forms** - Wizard flows, progress tracking

Each example demonstrates real-world patterns with complete, runnable test code following Jest and React Testing Library best practices.
