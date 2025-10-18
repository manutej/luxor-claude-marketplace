# Frontend Architecture Skill

A comprehensive guide to building scalable, maintainable frontend applications with modern architectural patterns.

## Overview

This skill covers essential frontend architecture concepts including component design, state management, design patterns, module systems, build optimization, and testing strategies. It provides practical examples and best practices for structuring large-scale applications.

## What You'll Learn

### Core Architecture Concepts

- **Component-Based Architecture** - Design principles for building modular, reusable components
- **Separation of Concerns** - Layered architecture for maintainability
- **Design Patterns** - MVC, MVVM, Flux, Observer, Factory, and Module patterns
- **State Management** - Strategies for managing application state at scale
- **Module Systems** - ES modules, code splitting, and lazy loading techniques

### Build and Performance

- **Build Tools** - Webpack and Vite configuration for optimal builds
- **Code Splitting** - Strategies for reducing initial bundle size
- **Tree Shaking** - Eliminating dead code from production bundles
- **Caching** - Browser caching, service workers, and HTTP caching strategies
- **Performance Optimization** - Techniques for fast load times and smooth runtime

### Testing and Quality

- **Testing Architecture** - Unit, integration, and E2E testing strategies
- **Test Patterns** - Utilities, mocks, and custom matchers
- **Testing Pyramid** - Balancing different types of tests

### Scalability

- **Folder Structure** - Feature-based organization for growing codebases
- **Naming Conventions** - Consistent patterns for files, components, and functions
- **Dependency Management** - Dependency injection and module boundaries

## Key Patterns

### Component Patterns

**Container vs Presentational Components**

Separate data fetching logic from UI rendering:

```typescript
// Presentational - Pure UI
function UserCard({ user, onEdit }: UserCardProps) {
  return (
    <div className="user-card">
      <h3>{user.name}</h3>
      <button onClick={onEdit}>Edit</button>
    </div>
  );
}

// Container - Data and logic
function UserCardContainer({ userId }: { userId: string }) {
  const { data: user } = useQuery(['user', userId], fetchUser);
  const navigate = useNavigate();

  return <UserCard user={user} onEdit={() => navigate(`/edit/${userId}`)} />;
}
```

**Composition**

Build complex components from simple ones:

```typescript
function Button({ children, ...props }: ButtonProps) {
  return <button className="btn" {...props}>{children}</button>;
}

function IconButton({ icon, ...props }: ButtonProps & { icon: string }) {
  return (
    <Button {...props}>
      <Icon name={icon} />
      {props.children}
    </Button>
  );
}
```

### State Management Patterns

**Unidirectional Data Flow**

```typescript
// Actions
const addItem = (item: CartItem) => ({ type: 'ADD_ITEM', payload: item });

// Reducer
function cartReducer(state: CartState, action: CartAction) {
  switch (action.type) {
    case 'ADD_ITEM':
      return { ...state, items: [...state.items, action.payload] };
    default:
      return state;
  }
}

// Component
function Cart() {
  const [state, dispatch] = useReducer(cartReducer, initialState);
  return <CartView items={state.items} onAdd={(item) => dispatch(addItem(item))} />;
}
```

**Local vs Global State**

```typescript
// Local state - component-specific
function SearchBar() {
  const [query, setQuery] = useState('');
  return <input value={query} onChange={e => setQuery(e.target.value)} />;
}

// Global state - application-wide
const UserContext = createContext<User | null>(null);

function App() {
  const [user, setUser] = useState<User | null>(null);
  return (
    <UserContext.Provider value={user}>
      <Router />
    </UserContext.Provider>
  );
}
```

### Design Patterns

**MVC (Model-View-Controller)**

```typescript
// Model - data and business logic
class TodoModel {
  private todos: Todo[] = [];

  addTodo(text: string) {
    this.todos.push({ id: Date.now(), text, completed: false });
    this.notify();
  }
}

// Controller - handles user input
class TodoController {
  constructor(private model: TodoModel) {}

  handleAddTodo(text: string) {
    if (text.trim()) this.model.addTodo(text);
  }
}

// View - React component
function TodoView({ controller, todos }: TodoViewProps) {
  return (
    <div>
      <input onSubmit={e => controller.handleAddTodo(e.target.value)} />
      <ul>{todos.map(todo => <li key={todo.id}>{todo.text}</li>)}</ul>
    </div>
  );
}
```

**Observer Pattern**

```typescript
class Subject<T> {
  private observers: Set<(data: T) => void> = new Set();

  subscribe(observer: (data: T) => void) {
    this.observers.add(observer);
    return () => this.observers.delete(observer);
  }

  notify(data: T) {
    this.observers.forEach(observer => observer(data));
  }
}

// Usage
const userPresence = new Subject<UserPresenceData>();

function UserStatus({ userId }: { userId: string }) {
  const [isOnline, setIsOnline] = useState(false);

  useEffect(() => {
    return userPresence.subscribe(data => {
      if (data.userId === userId) setIsOnline(data.isOnline);
    });
  }, [userId]);

  return <span>{isOnline ? 'Online' : 'Offline'}</span>;
}
```

**Factory Pattern**

```typescript
interface FormField {
  render(): JSX.Element;
  validate(): boolean;
  getValue(): any;
}

class FormFieldFactory {
  create(type: string, config: any): FormField {
    switch (type) {
      case 'text': return new TextField(config);
      case 'select': return new SelectField(config);
      case 'date': return new DateField(config);
      default: throw new Error(`Unknown field type: ${type}`);
    }
  }
}

// Usage
function DynamicForm({ schema }: { schema: FormSchema }) {
  const factory = new FormFieldFactory();
  const fields = schema.fields.map(f => factory.create(f.type, f.config));

  return (
    <form>
      {fields.map(field => field.render())}
    </form>
  );
}
```

## Module Systems and Code Splitting

### ES Modules

```typescript
// Exporting
export interface Logger { /* ... */ }
export class ConsoleLogger implements Logger { /* ... */ }
export default new ConsoleLogger();

// Importing
import logger, { Logger, ConsoleLogger } from './logger';
import type { Logger } from './logger'; // Type-only import
```

### Code Splitting Strategies

**Route-Based Splitting**

```typescript
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

**Component-Based Splitting**

```typescript
const HeavyComponent = lazy(() => import('./HeavyComponent'));

function FeaturePage() {
  const [show, setShow] = useState(false);

  return (
    <div>
      <button onClick={() => setShow(true)}>Load Feature</button>
      {show && (
        <Suspense fallback={<Loading />}>
          <HeavyComponent />
        </Suspense>
      )}
    </div>
  );
}
```

**Dynamic Imports**

```typescript
async function loadExporter() {
  const module = await import('./excel-exporter');
  return new module.ExcelExporter();
}

function DataTable() {
  const handleExport = async () => {
    const exporter = await loadExporter();
    exporter.export(data);
  };

  return <button onClick={handleExport}>Export</button>;
}
```

## Build Tools

### Webpack Configuration

```javascript
module.exports = {
  entry: './src/index.tsx',
  output: {
    filename: '[name].[contenthash].js',
    path: path.resolve(__dirname, 'dist')
  },
  optimization: {
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors'
        }
      }
    }
  },
  module: {
    rules: [
      {
        test: /\.(ts|tsx)$/,
        use: 'ts-loader'
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader', 'postcss-loader']
      }
    ]
  }
};
```

### Vite Configuration

```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components')
    }
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom'],
          'ui-vendor': ['@radix-ui/react-dialog']
        }
      }
    }
  }
});
```

## Testing Architecture

### Testing Pyramid

```
      /\
     /  \
    / E2E \         Few, slow, expensive
   /______\
   /      \
  /  INT   \       Some, medium speed
 /__________\
 /          \
/    UNIT    \     Many, fast, cheap
/______________\
```

**Unit Tests**

```typescript
describe('calculateTotal', () => {
  it('should sum item prices', () => {
    expect(calculateTotal([{ price: 10, qty: 2 }])).toBe(20);
  });
});
```

**Integration Tests**

```typescript
describe('LoginFlow', () => {
  it('should authenticate user', async () => {
    render(<LoginPage />);
    await userEvent.type(screen.getByLabelText('Email'), 'user@test.com');
    await userEvent.click(screen.getByText('Login'));
    expect(await screen.findByText('Dashboard')).toBeInTheDocument();
  });
});
```

**E2E Tests**

```typescript
test('complete checkout', async ({ page }) => {
  await page.goto('/products');
  await page.click('[data-testid="add-to-cart"]');
  await page.click('[data-testid="checkout"]');
  await page.fill('[name="card"]', '4242424242424242');
  await page.click('[data-testid="place-order"]');
  await expect(page.locator('[data-testid="success"]')).toBeVisible();
});
```

### Test Utilities

```typescript
// Custom render with providers
export function renderWithProviders(
  ui: React.ReactElement,
  options?: RenderOptions
) {
  function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>
        <BrowserRouter>{children}</BrowserRouter>
      </QueryClientProvider>
    );
  }

  return render(ui, { wrapper: Wrapper, ...options });
}

// Mock factories
export function createMockUser(overrides?: Partial<User>): User {
  return {
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
    ...overrides
  };
}
```

## Performance Optimization

### Tree Shaking

```typescript
// Good - enables tree shaking
import { debounce } from 'lodash-es';

// Bad - imports entire library
import _ from 'lodash';
```

### Caching Strategies

**Service Worker**

```javascript
const CACHE_NAME = 'app-v1';

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then(response => response || fetch(event.request))
  );
});
```

**React Query**

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 min
      cacheTime: 10 * 60 * 1000 // 10 min
    }
  }
});
```

### Bundle Optimization

```typescript
// Manual chunks in Vite
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom'],
          'utils': ['date-fns', 'lodash-es']
        }
      }
    }
  }
});
```

## Scalable Folder Structure

### Feature-Based Organization

```
src/
├── features/
│   ├── auth/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   ├── types/
│   │   └── index.ts
│   ├── products/
│   └── cart/
├── shared/
│   ├── components/
│   ├── hooks/
│   └── utils/
├── core/
│   ├── api/
│   ├── router/
│   └── store/
└── assets/
```

### Naming Conventions

```typescript
// Components
UserProfile.tsx
ProductCard.tsx

// Hooks
useAuth.ts
useLocalStorage.ts

// Utilities
formatDate.ts
debounce.ts

// Constants
API_BASE_URL
MAX_FILE_SIZE

// Types
User.types.ts
Product.types.ts
```

## Best Practices

1. **Component Design**
   - Single Responsibility Principle
   - Composition over inheritance
   - Proper TypeScript typing
   - Clear prop interfaces

2. **State Management**
   - Choose appropriate state level
   - Immutable updates
   - Separate server/client state
   - Avoid prop drilling

3. **Performance**
   - Code splitting
   - Lazy loading
   - Tree shaking
   - Proper caching

4. **Testing**
   - Follow testing pyramid
   - Test behavior, not implementation
   - Use proper test utilities
   - Mock external dependencies

5. **Scalability**
   - Consistent structure
   - Clear naming conventions
   - Module boundaries
   - Documentation

## Common Pitfalls

- **Over-engineering** - Start simple, add complexity as needed
- **Premature optimization** - Measure before optimizing
- **Tight coupling** - Use dependency injection and clear interfaces
- **Monolithic components** - Break down into smaller pieces
- **Global state overuse** - Prefer local state when possible
- **Ignoring types** - Use TypeScript for better DX and fewer bugs

## When to Use This Skill

Use this skill when you need to:

- Design a new application architecture
- Refactor existing code for better scalability
- Choose state management solutions
- Implement design patterns
- Optimize build and bundle configuration
- Structure testing strategies
- Improve application performance
- Scale codebases for growing teams

## Related Skills

- **react-patterns** - React-specific patterns
- **typescript-architecture** - TypeScript design patterns
- **performance-optimization** - Advanced performance techniques
- **testing-strategies** - Testing best practices
- **webpack-configuration** - Deep dive into Webpack
- **state-management** - Redux, Zustand, Jotai patterns

## Resources

- **Architecture Patterns** - Learn MVC, MVVM, Flux
- **Component Design** - Atomic design, composition patterns
- **State Management** - Redux, MobX, Zustand, Jotai
- **Build Tools** - Webpack, Vite, Rollup documentation
- **Testing** - Jest, React Testing Library, Playwright
- **Performance** - Web Vitals, Lighthouse, Bundle analyzers

## Examples

See EXAMPLES.md for 15+ detailed architectural examples including:

- Full-featured application architectures
- State management implementations
- Build configurations
- Testing strategies
- Performance optimizations
- Real-world patterns and solutions
