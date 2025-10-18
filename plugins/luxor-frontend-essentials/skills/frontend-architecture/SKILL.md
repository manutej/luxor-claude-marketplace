---
name: frontend-architecture
description: Component architecture, design patterns, state management strategies, module systems, build tools, and scalable application structure
category: frontend
tags: [architecture, design-patterns, components, scalability, modules, state-management]
version: 1.0.0
---

# Frontend Architecture Skill

## When to Use This Skill

Use this skill when you need to:

- **Design scalable application architecture** - Structure large-scale frontend applications with maintainable patterns
- **Choose architectural patterns** - Select appropriate design patterns (MVC, MVVM, Flux) for your use case
- **Implement state management** - Design state architecture for complex applications
- **Structure component hierarchies** - Create reusable, composable component systems
- **Optimize build processes** - Configure bundlers and build tools for optimal performance
- **Plan testing strategies** - Architect comprehensive testing approaches across layers
- **Design module systems** - Implement code splitting, lazy loading, and module boundaries
- **Scale codebases** - Establish conventions for growing teams and applications
- **Refactor legacy code** - Migrate to modern architectural patterns
- **Performance optimization** - Structure applications for optimal load times and runtime performance

## Core Concepts

### 1. Component Architecture

Component-based architecture is the foundation of modern frontend development, enabling modularity and reusability.

#### Component Design Principles

**Single Responsibility Principle**
Each component should have one clear purpose:

```typescript
// Bad: Component doing too much
function UserDashboard() {
  const [user, setUser] = useState(null);
  const [posts, setPosts] = useState([]);
  const [notifications, setNotifications] = useState([]);
  const [settings, setSettings] = useState({});

  // Mixing concerns: data fetching, rendering, business logic
  useEffect(() => {
    fetch('/api/user').then(r => r.json()).then(setUser);
    fetch('/api/posts').then(r => r.json()).then(setPosts);
    fetch('/api/notifications').then(r => r.json()).then(setNotifications);
  }, []);

  return (
    <div>
      <header>{user?.name}</header>
      <PostList posts={posts} />
      <NotificationBell count={notifications.length} />
      <SettingsPanel settings={settings} />
    </div>
  );
}

// Good: Separated concerns
function UserDashboard() {
  return (
    <DashboardLayout>
      <UserHeader />
      <UserPosts />
      <UserNotifications />
      <UserSettings />
    </DashboardLayout>
  );
}

function UserPosts() {
  const { posts, loading } = useUserPosts();

  if (loading) return <PostsLoading />;
  return <PostList posts={posts} />;
}
```

**Composition Over Inheritance**

```typescript
// Using composition for flexibility
interface ButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  variant?: 'primary' | 'secondary';
}

function Button({ children, onClick, variant = 'primary' }: ButtonProps) {
  return (
    <button className={`btn btn-${variant}`} onClick={onClick}>
      {children}
    </button>
  );
}

// Compose complex components
function IconButton({ icon, ...props }: ButtonProps & { icon: string }) {
  return (
    <Button {...props}>
      <Icon name={icon} />
      {props.children}
    </Button>
  );
}

function LoadingButton({ loading, ...props }: ButtonProps & { loading: boolean }) {
  return (
    <Button {...props} disabled={loading}>
      {loading ? <Spinner /> : props.children}
    </Button>
  );
}
```

#### Container vs Presentational Components

```typescript
// Presentational Component (Pure UI)
interface UserCardProps {
  user: User;
  onEdit: () => void;
  onDelete: () => void;
}

function UserCard({ user, onEdit, onDelete }: UserCardProps) {
  return (
    <div className="user-card">
      <img src={user.avatar} alt={user.name} />
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      <div className="actions">
        <button onClick={onEdit}>Edit</button>
        <button onClick={onDelete}>Delete</button>
      </div>
    </div>
  );
}

// Container Component (Logic & Data)
function UserCardContainer({ userId }: { userId: string }) {
  const { data: user, isLoading } = useQuery(['user', userId], () =>
    fetchUser(userId)
  );
  const deleteMutation = useMutation(deleteUser);
  const navigate = useNavigate();

  const handleEdit = () => navigate(`/users/${userId}/edit`);
  const handleDelete = () => {
    if (confirm('Delete user?')) {
      deleteMutation.mutate(userId);
    }
  };

  if (isLoading) return <Skeleton />;
  if (!user) return <ErrorState />;

  return (
    <UserCard
      user={user}
      onEdit={handleEdit}
      onDelete={handleDelete}
    />
  );
}
```

### 2. Separation of Concerns

#### Layer Architecture

```
┌─────────────────────────────────────┐
│        Presentation Layer           │
│     (Components, Views, UI)         │
├─────────────────────────────────────┤
│       Application Layer             │
│  (State Management, Routing, Hooks) │
├─────────────────────────────────────┤
│         Domain Layer                │
│   (Business Logic, Entities)        │
├─────────────────────────────────────┤
│      Infrastructure Layer           │
│    (API, Storage, Services)         │
└─────────────────────────────────────┘
```

**Example Implementation:**

```typescript
// Domain Layer - Business entities and logic
export class User {
  constructor(
    public id: string,
    public email: string,
    public name: string,
    public role: UserRole
  ) {}

  canEditPost(post: Post): boolean {
    return this.role === 'admin' || post.authorId === this.id;
  }

  get displayName(): string {
    return this.name || this.email.split('@')[0];
  }
}

// Infrastructure Layer - API communication
export class UserRepository {
  constructor(private apiClient: ApiClient) {}

  async findById(id: string): Promise<User> {
    const data = await this.apiClient.get(`/users/${id}`);
    return new User(data.id, data.email, data.name, data.role);
  }

  async save(user: User): Promise<void> {
    await this.apiClient.put(`/users/${user.id}`, {
      email: user.email,
      name: user.name,
      role: user.role
    });
  }
}

// Application Layer - State management
export function useUser(userId: string) {
  const repository = useUserRepository();

  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => repository.findById(userId)
  });
}

// Presentation Layer - UI Component
export function UserProfile({ userId }: { userId: string }) {
  const { data: user, isLoading } = useUser(userId);

  if (isLoading) return <Loading />;

  return (
    <div>
      <h1>{user.displayName}</h1>
      <p>{user.email}</p>
    </div>
  );
}
```

## Design Patterns

### 1. Model-View-Controller (MVC)

```typescript
// Model - Data and business logic
class TodoModel {
  private todos: Todo[] = [];
  private observers: Set<(todos: Todo[]) => void> = new Set();

  addTodo(text: string) {
    const todo = { id: Date.now(), text, completed: false };
    this.todos.push(todo);
    this.notify();
  }

  toggleTodo(id: number) {
    const todo = this.todos.find(t => t.id === id);
    if (todo) {
      todo.completed = !todo.completed;
      this.notify();
    }
  }

  getTodos() {
    return [...this.todos];
  }

  subscribe(observer: (todos: Todo[]) => void) {
    this.observers.add(observer);
    return () => this.observers.delete(observer);
  }

  private notify() {
    this.observers.forEach(observer => observer(this.getTodos()));
  }
}

// Controller - Handles user input
class TodoController {
  constructor(private model: TodoModel) {}

  handleAddTodo(text: string) {
    if (text.trim()) {
      this.model.addTodo(text);
    }
  }

  handleToggleTodo(id: number) {
    this.model.toggleTodo(id);
  }
}

// View - React component
function TodoView() {
  const [model] = useState(() => new TodoModel());
  const [controller] = useState(() => new TodoController(model));
  const [todos, setTodos] = useState(model.getTodos());
  const [inputValue, setInputValue] = useState('');

  useEffect(() => {
    return model.subscribe(setTodos);
  }, [model]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    controller.handleAddTodo(inputValue);
    setInputValue('');
  };

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <input
          value={inputValue}
          onChange={e => setInputValue(e.target.value)}
        />
        <button type="submit">Add</button>
      </form>
      <ul>
        {todos.map(todo => (
          <li key={todo.id}>
            <input
              type="checkbox"
              checked={todo.completed}
              onChange={() => controller.handleToggleTodo(todo.id)}
            />
            {todo.text}
          </li>
        ))}
      </ul>
    </div>
  );
}
```

### 2. Model-View-ViewModel (MVVM)

```typescript
// Model
interface Task {
  id: string;
  title: string;
  completed: boolean;
  dueDate: Date;
}

class TaskService {
  async fetchTasks(): Promise<Task[]> {
    const response = await fetch('/api/tasks');
    return response.json();
  }

  async updateTask(id: string, updates: Partial<Task>): Promise<Task> {
    const response = await fetch(`/api/tasks/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(updates)
    });
    return response.json();
  }
}

// ViewModel
class TaskListViewModel {
  private tasks = signal<Task[]>([]);
  private loading = signal(false);
  private filter = signal<'all' | 'active' | 'completed'>('all');

  constructor(private service: TaskService) {}

  // Computed values
  get filteredTasks() {
    return computed(() => {
      const filterValue = this.filter.value;
      const tasksValue = this.tasks.value;

      if (filterValue === 'active') {
        return tasksValue.filter(t => !t.completed);
      }
      if (filterValue === 'completed') {
        return tasksValue.filter(t => t.completed);
      }
      return tasksValue;
    });
  }

  get stats() {
    return computed(() => {
      const tasksValue = this.tasks.value;
      return {
        total: tasksValue.length,
        completed: tasksValue.filter(t => t.completed).length,
        active: tasksValue.filter(t => !t.completed).length
      };
    });
  }

  // Commands
  async loadTasks() {
    this.loading.value = true;
    try {
      this.tasks.value = await this.service.fetchTasks();
    } finally {
      this.loading.value = false;
    }
  }

  async toggleTask(id: string) {
    const task = this.tasks.value.find(t => t.id === id);
    if (!task) return;

    const updated = await this.service.updateTask(id, {
      completed: !task.completed
    });

    this.tasks.value = this.tasks.value.map(t =>
      t.id === id ? updated : t
    );
  }

  setFilter(filter: 'all' | 'active' | 'completed') {
    this.filter.value = filter;
  }
}

// View
function TaskListView() {
  const [viewModel] = useState(() =>
    new TaskListViewModel(new TaskService())
  );

  useEffect(() => {
    viewModel.loadTasks();
  }, [viewModel]);

  const tasks = useSignal(viewModel.filteredTasks);
  const stats = useSignal(viewModel.stats);

  return (
    <div>
      <div className="stats">
        <span>Total: {stats.total}</span>
        <span>Active: {stats.active}</span>
        <span>Completed: {stats.completed}</span>
      </div>

      <div className="filters">
        <button onClick={() => viewModel.setFilter('all')}>All</button>
        <button onClick={() => viewModel.setFilter('active')}>Active</button>
        <button onClick={() => viewModel.setFilter('completed')}>Completed</button>
      </div>

      <ul>
        {tasks.map(task => (
          <li key={task.id}>
            <input
              type="checkbox"
              checked={task.completed}
              onChange={() => viewModel.toggleTask(task.id)}
            />
            {task.title}
          </li>
        ))}
      </ul>
    </div>
  );
}
```

### 3. Flux Architecture

```typescript
// Actions
enum ActionType {
  ADD_ITEM = 'ADD_ITEM',
  REMOVE_ITEM = 'REMOVE_ITEM',
  UPDATE_QUANTITY = 'UPDATE_QUANTITY',
  CLEAR_CART = 'CLEAR_CART'
}

interface Action {
  type: ActionType;
  payload?: any;
}

class CartActions {
  static addItem(item: CartItem): Action {
    return { type: ActionType.ADD_ITEM, payload: item };
  }

  static removeItem(itemId: string): Action {
    return { type: ActionType.REMOVE_ITEM, payload: itemId };
  }

  static updateQuantity(itemId: string, quantity: number): Action {
    return { type: ActionType.UPDATE_QUANTITY, payload: { itemId, quantity } };
  }
}

// Dispatcher
class Dispatcher {
  private callbacks: Set<(action: Action) => void> = new Set();

  register(callback: (action: Action) => void) {
    this.callbacks.add(callback);
    return () => this.callbacks.delete(callback);
  }

  dispatch(action: Action) {
    this.callbacks.forEach(callback => callback(action));
  }
}

const dispatcher = new Dispatcher();

// Store
class CartStore {
  private items: Map<string, CartItem> = new Map();
  private listeners: Set<() => void> = new Set();

  constructor() {
    dispatcher.register(this.handleAction.bind(this));
  }

  private handleAction(action: Action) {
    switch (action.type) {
      case ActionType.ADD_ITEM:
        this.addItem(action.payload);
        break;
      case ActionType.REMOVE_ITEM:
        this.removeItem(action.payload);
        break;
      case ActionType.UPDATE_QUANTITY:
        this.updateQuantity(action.payload.itemId, action.payload.quantity);
        break;
      case ActionType.CLEAR_CART:
        this.clear();
        break;
    }
  }

  private addItem(item: CartItem) {
    const existing = this.items.get(item.id);
    if (existing) {
      existing.quantity += item.quantity;
    } else {
      this.items.set(item.id, { ...item });
    }
    this.emitChange();
  }

  private removeItem(itemId: string) {
    this.items.delete(itemId);
    this.emitChange();
  }

  private updateQuantity(itemId: string, quantity: number) {
    const item = this.items.get(itemId);
    if (item) {
      item.quantity = quantity;
      this.emitChange();
    }
  }

  private clear() {
    this.items.clear();
    this.emitChange();
  }

  getItems(): CartItem[] {
    return Array.from(this.items.values());
  }

  getTotal(): number {
    return Array.from(this.items.values())
      .reduce((sum, item) => sum + item.price * item.quantity, 0);
  }

  subscribe(listener: () => void) {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  private emitChange() {
    this.listeners.forEach(listener => listener());
  }
}

const cartStore = new CartStore();

// View
function ShoppingCart() {
  const [items, setItems] = useState(cartStore.getItems());
  const [total, setTotal] = useState(cartStore.getTotal());

  useEffect(() => {
    return cartStore.subscribe(() => {
      setItems(cartStore.getItems());
      setTotal(cartStore.getTotal());
    });
  }, []);

  const handleAddItem = (item: CartItem) => {
    dispatcher.dispatch(CartActions.addItem(item));
  };

  const handleRemoveItem = (itemId: string) => {
    dispatcher.dispatch(CartActions.removeItem(itemId));
  };

  return (
    <div>
      <h2>Cart Total: ${total.toFixed(2)}</h2>
      <ul>
        {items.map(item => (
          <li key={item.id}>
            {item.name} - ${item.price} x {item.quantity}
            <button onClick={() => handleRemoveItem(item.id)}>Remove</button>
          </li>
        ))}
      </ul>
    </div>
  );
}
```

### 4. Observer Pattern

```typescript
interface Observer<T> {
  update(data: T): void;
}

class Subject<T> {
  private observers: Set<Observer<T>> = new Set();

  attach(observer: Observer<T>): () => void {
    this.observers.add(observer);
    return () => this.observers.delete(observer);
  }

  notify(data: T): void {
    this.observers.forEach(observer => observer.update(data));
  }
}

// Application example
interface UserData {
  id: string;
  name: string;
  isOnline: boolean;
}

class UserPresenceService extends Subject<UserData> {
  private socket: WebSocket;

  constructor() {
    super();
    this.socket = new WebSocket('wss://api.example.com/presence');

    this.socket.onmessage = (event) => {
      const userData = JSON.parse(event.data);
      this.notify(userData);
    };
  }

  updatePresence(isOnline: boolean) {
    this.socket.send(JSON.stringify({ isOnline }));
  }
}

// Observer components
class UserStatusObserver implements Observer<UserData> {
  constructor(private userId: string, private callback: (isOnline: boolean) => void) {}

  update(data: UserData): void {
    if (data.id === this.userId) {
      this.callback(data.isOnline);
    }
  }
}

function UserStatus({ userId }: { userId: string }) {
  const [isOnline, setIsOnline] = useState(false);
  const service = useUserPresenceService();

  useEffect(() => {
    const observer = new UserStatusObserver(userId, setIsOnline);
    return service.attach(observer);
  }, [userId, service]);

  return (
    <span className={`status ${isOnline ? 'online' : 'offline'}`}>
      {isOnline ? 'Online' : 'Offline'}
    </span>
  );
}
```

### 5. Factory Pattern

```typescript
// Abstract factory for form inputs
interface FormInput {
  render(): JSX.Element;
  validate(): boolean;
  getValue(): any;
}

class TextInputFactory {
  create(config: TextInputConfig): FormInput {
    return new TextInput(config);
  }
}

class SelectInputFactory {
  create(config: SelectInputConfig): FormInput {
    return new SelectInput(config);
  }
}

class DateInputFactory {
  create(config: DateInputConfig): FormInput {
    return new DateInput(config);
  }
}

// Form builder using factory
class FormBuilder {
  private factories = new Map<string, any>([
    ['text', new TextInputFactory()],
    ['email', new TextInputFactory()],
    ['select', new SelectInputFactory()],
    ['date', new DateInputFactory()]
  ]);

  createField(type: string, config: any): FormInput {
    const factory = this.factories.get(type);
    if (!factory) {
      throw new Error(`Unknown field type: ${type}`);
    }
    return factory.create(config);
  }

  buildForm(schema: FormSchema): FormInput[] {
    return schema.fields.map(field =>
      this.createField(field.type, field.config)
    );
  }
}

// Usage
function DynamicForm({ schema }: { schema: FormSchema }) {
  const [builder] = useState(() => new FormBuilder());
  const [fields] = useState(() => builder.buildForm(schema));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    const isValid = fields.every(field => field.validate());
    if (isValid) {
      const values = fields.map(field => field.getValue());
      console.log('Form values:', values);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      {fields.map((field, index) => (
        <div key={index}>{field.render()}</div>
      ))}
      <button type="submit">Submit</button>
    </form>
  );
}
```

### 6. Module Pattern

```typescript
// Revealing module pattern
const AuthModule = (() => {
  // Private state
  let currentUser: User | null = null;
  const listeners: Set<(user: User | null) => void> = new Set();

  // Private methods
  function notifyListeners() {
    listeners.forEach(listener => listener(currentUser));
  }

  function storeToken(token: string) {
    localStorage.setItem('auth_token', token);
  }

  function clearToken() {
    localStorage.removeItem('auth_token');
  }

  // Public API
  return {
    async login(email: string, password: string) {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        body: JSON.stringify({ email, password })
      });

      const { user, token } = await response.json();
      currentUser = user;
      storeToken(token);
      notifyListeners();

      return user;
    },

    logout() {
      currentUser = null;
      clearToken();
      notifyListeners();
    },

    getCurrentUser() {
      return currentUser;
    },

    isAuthenticated() {
      return currentUser !== null;
    },

    subscribe(listener: (user: User | null) => void) {
      listeners.add(listener);
      return () => listeners.delete(listener);
    }
  };
})();

// Usage in React
function useAuth() {
  const [user, setUser] = useState(AuthModule.getCurrentUser());

  useEffect(() => {
    return AuthModule.subscribe(setUser);
  }, []);

  return {
    user,
    isAuthenticated: AuthModule.isAuthenticated(),
    login: AuthModule.login,
    logout: AuthModule.logout
  };
}
```

## State Management

### 1. Local vs Global State

```typescript
// Local state - Component-specific
function SearchBar() {
  const [query, setQuery] = useState(''); // Local to this component
  const [isFocused, setIsFocused] = useState(false);

  return (
    <input
      value={query}
      onChange={e => setQuery(e.target.value)}
      onFocus={() => setIsFocused(true)}
      onBlur={() => setIsFocused(false)}
    />
  );
}

// Lifted state - Shared between siblings
function SearchPage() {
  const [searchResults, setSearchResults] = useState([]);

  const handleSearch = async (query: string) => {
    const results = await searchAPI(query);
    setSearchResults(results);
  };

  return (
    <div>
      <SearchBar onSearch={handleSearch} />
      <SearchResults results={searchResults} />
      <SearchFilters results={searchResults} />
    </div>
  );
}

// Global state - Application-wide
const UserContext = createContext<UserContextValue>(null);

function App() {
  const [user, setUser] = useState<User | null>(null);

  return (
    <UserContext.Provider value={{ user, setUser }}>
      <Router />
    </UserContext.Provider>
  );
}

// Server state - Managed by React Query
function useProducts() {
  return useQuery({
    queryKey: ['products'],
    queryFn: fetchProducts,
    staleTime: 5 * 60 * 1000 // 5 minutes
  });
}
```

### 2. Unidirectional Data Flow

```typescript
// Redux-style unidirectional flow
interface AppState {
  user: User | null;
  cart: CartItem[];
  notifications: Notification[];
}

type AppAction =
  | { type: 'user/login'; payload: User }
  | { type: 'user/logout' }
  | { type: 'cart/addItem'; payload: CartItem }
  | { type: 'cart/removeItem'; payload: string }
  | { type: 'notifications/add'; payload: Notification };

function appReducer(state: AppState, action: AppAction): AppState {
  switch (action.type) {
    case 'user/login':
      return { ...state, user: action.payload };

    case 'user/logout':
      return { ...state, user: null, cart: [] };

    case 'cart/addItem':
      return {
        ...state,
        cart: [...state.cart, action.payload]
      };

    case 'cart/removeItem':
      return {
        ...state,
        cart: state.cart.filter(item => item.id !== action.payload)
      };

    case 'notifications/add':
      return {
        ...state,
        notifications: [...state.notifications, action.payload]
      };

    default:
      return state;
  }
}

// Store setup
const AppContext = createContext<{
  state: AppState;
  dispatch: React.Dispatch<AppAction>;
}>(null!);

function AppProvider({ children }: { children: React.ReactNode }) {
  const [state, dispatch] = useReducer(appReducer, {
    user: null,
    cart: [],
    notifications: []
  });

  return (
    <AppContext.Provider value={{ state, dispatch }}>
      {children}
    </AppContext.Provider>
  );
}

// Selectors
function useUser() {
  const { state } = useContext(AppContext);
  return state.user;
}

function useCart() {
  const { state, dispatch } = useContext(AppContext);

  return {
    items: state.cart,
    addItem: (item: CartItem) =>
      dispatch({ type: 'cart/addItem', payload: item }),
    removeItem: (id: string) =>
      dispatch({ type: 'cart/removeItem', payload: id })
  };
}
```

### 3. State Management Patterns

**Zustand - Simple State Management**

```typescript
import create from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface TodoState {
  todos: Todo[];
  filter: 'all' | 'active' | 'completed';
  addTodo: (text: string) => void;
  toggleTodo: (id: string) => void;
  removeTodo: (id: string) => void;
  setFilter: (filter: 'all' | 'active' | 'completed') => void;
  filteredTodos: () => Todo[];
}

const useTodoStore = create<TodoState>()(
  devtools(
    persist(
      (set, get) => ({
        todos: [],
        filter: 'all',

        addTodo: (text) =>
          set((state) => ({
            todos: [...state.todos, {
              id: crypto.randomUUID(),
              text,
              completed: false
            }]
          })),

        toggleTodo: (id) =>
          set((state) => ({
            todos: state.todos.map(todo =>
              todo.id === id
                ? { ...todo, completed: !todo.completed }
                : todo
            )
          })),

        removeTodo: (id) =>
          set((state) => ({
            todos: state.todos.filter(todo => todo.id !== id)
          })),

        setFilter: (filter) => set({ filter }),

        filteredTodos: () => {
          const { todos, filter } = get();
          if (filter === 'active') return todos.filter(t => !t.completed);
          if (filter === 'completed') return todos.filter(t => t.completed);
          return todos;
        }
      }),
      { name: 'todo-storage' }
    )
  )
);

// Usage
function TodoList() {
  const todos = useTodoStore(state => state.filteredTodos());
  const toggleTodo = useTodoStore(state => state.toggleTodo);

  return (
    <ul>
      {todos.map(todo => (
        <li key={todo.id}>
          <input
            type="checkbox"
            checked={todo.completed}
            onChange={() => toggleTodo(todo.id)}
          />
          {todo.text}
        </li>
      ))}
    </ul>
  );
}
```

**Jotai - Atomic State Management**

```typescript
import { atom, useAtom, useAtomValue, useSetAtom } from 'jotai';
import { atomWithStorage } from 'jotai/utils';

// Primitive atoms
const userAtom = atom<User | null>(null);
const cartItemsAtom = atomWithStorage<CartItem[]>('cart', []);

// Derived atoms
const cartTotalAtom = atom((get) => {
  const items = get(cartItemsAtom);
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
});

const cartCountAtom = atom((get) => {
  const items = get(cartItemsAtom);
  return items.reduce((sum, item) => sum + item.quantity, 0);
});

// Write-only atoms (actions)
const addToCartAtom = atom(
  null,
  (get, set, item: CartItem) => {
    const items = get(cartItemsAtom);
    const existing = items.find(i => i.id === item.id);

    if (existing) {
      set(cartItemsAtom, items.map(i =>
        i.id === item.id
          ? { ...i, quantity: i.quantity + item.quantity }
          : i
      ));
    } else {
      set(cartItemsAtom, [...items, item]);
    }
  }
);

// Usage
function ShoppingCart() {
  const items = useAtomValue(cartItemsAtom);
  const total = useAtomValue(cartTotalAtom);
  const count = useAtomValue(cartCountAtom);
  const addToCart = useSetAtom(addToCartAtom);

  return (
    <div>
      <h2>Cart ({count} items) - ${total.toFixed(2)}</h2>
      {/* ... */}
    </div>
  );
}
```

## Module Systems

### 1. ES Modules

```typescript
// modules/logger.ts
export interface Logger {
  info(message: string): void;
  warn(message: string): void;
  error(message: string): void;
}

export class ConsoleLogger implements Logger {
  info(message: string) {
    console.log(`[INFO] ${message}`);
  }

  warn(message: string) {
    console.warn(`[WARN] ${message}`);
  }

  error(message: string) {
    console.error(`[ERROR] ${message}`);
  }
}

export default new ConsoleLogger();

// modules/api-client.ts
import logger, { Logger } from './logger';

export class ApiClient {
  constructor(
    private baseURL: string,
    private logger: Logger = logger
  ) {}

  async get<T>(path: string): Promise<T> {
    this.logger.info(`GET ${path}`);
    const response = await fetch(`${this.baseURL}${path}`);
    return response.json();
  }
}

// app.ts
import { ApiClient } from './modules/api-client';
import logger from './modules/logger';

const api = new ApiClient('https://api.example.com', logger);
```

### 2. Code Splitting

```typescript
// Route-based code splitting
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

const Home = lazy(() => import('./pages/Home'));
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<PageLoader />}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/settings" element={<Settings />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}

// Component-based code splitting
const HeavyChart = lazy(() => import('./components/HeavyChart'));

function Analytics() {
  const [showChart, setShowChart] = useState(false);

  return (
    <div>
      <button onClick={() => setShowChart(true)}>Show Chart</button>

      {showChart && (
        <Suspense fallback={<div>Loading chart...</div>}>
          <HeavyChart data={chartData} />
        </Suspense>
      )}
    </div>
  );
}

// Dynamic imports with loading states
function DataTable() {
  const [ExcelExporter, setExporter] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  const handleExport = async () => {
    if (!ExcelExporter) {
      setLoading(true);
      const module = await import('./utils/excel-exporter');
      setExporter(() => module.ExcelExporter);
      setLoading(false);
    }

    if (ExcelExporter) {
      new ExcelExporter().export(data);
    }
  };

  return (
    <div>
      <button onClick={handleExport} disabled={loading}>
        {loading ? 'Loading...' : 'Export to Excel'}
      </button>
    </div>
  );
}
```

### 3. Lazy Loading

```typescript
// Image lazy loading
function LazyImage({ src, alt }: { src: string; alt: string }) {
  const [imageSrc, setImageSrc] = useState<string>();
  const imgRef = useRef<HTMLImageElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setImageSrc(src);
          observer.disconnect();
        }
      },
      { rootMargin: '100px' }
    );

    if (imgRef.current) {
      observer.observe(imgRef.current);
    }

    return () => observer.disconnect();
  }, [src]);

  return (
    <img
      ref={imgRef}
      src={imageSrc || 'placeholder.jpg'}
      alt={alt}
      loading="lazy"
    />
  );
}

// Data lazy loading with infinite scroll
function InfiniteList() {
  const [page, setPage] = useState(1);
  const { data, isLoading, hasNextPage } = useInfiniteQuery({
    queryKey: ['items', page],
    queryFn: ({ pageParam = 1 }) => fetchItems(pageParam),
    getNextPageParam: (lastPage, pages) =>
      lastPage.hasMore ? pages.length + 1 : undefined
  });

  const loadMoreRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && hasNextPage && !isLoading) {
          setPage(prev => prev + 1);
        }
      }
    );

    if (loadMoreRef.current) {
      observer.observe(loadMoreRef.current);
    }

    return () => observer.disconnect();
  }, [hasNextPage, isLoading]);

  return (
    <div>
      {data?.pages.map((page, i) => (
        <div key={i}>
          {page.items.map(item => (
            <ItemCard key={item.id} item={item} />
          ))}
        </div>
      ))}
      {hasNextPage && <div ref={loadMoreRef}>Loading more...</div>}
    </div>
  );
}
```

## Build Tools

### 1. Webpack Configuration

```javascript
// webpack.config.js
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');

module.exports = (env, argv) => {
  const isDevelopment = argv.mode === 'development';

  return {
    entry: {
      main: './src/index.tsx',
      vendor: ['react', 'react-dom']
    },

    output: {
      path: path.resolve(__dirname, 'dist'),
      filename: isDevelopment
        ? '[name].js'
        : '[name].[contenthash].js',
      chunkFilename: '[name].[contenthash].chunk.js',
      clean: true
    },

    optimization: {
      splitChunks: {
        chunks: 'all',
        cacheGroups: {
          vendor: {
            test: /[\\/]node_modules[\\/]/,
            name: 'vendors',
            priority: 10
          },
          common: {
            minChunks: 2,
            priority: 5,
            reuseExistingChunk: true
          }
        }
      },
      runtimeChunk: 'single'
    },

    module: {
      rules: [
        {
          test: /\.(ts|tsx)$/,
          use: 'ts-loader',
          exclude: /node_modules/
        },
        {
          test: /\.css$/,
          use: [
            isDevelopment ? 'style-loader' : MiniCssExtractPlugin.loader,
            'css-loader',
            'postcss-loader'
          ]
        },
        {
          test: /\.(png|jpg|gif|svg)$/,
          type: 'asset',
          parser: {
            dataUrlCondition: {
              maxSize: 8 * 1024 // 8kb
            }
          }
        }
      ]
    },

    plugins: [
      new HtmlWebpackPlugin({
        template: './public/index.html'
      }),
      !isDevelopment && new MiniCssExtractPlugin({
        filename: '[name].[contenthash].css'
      }),
      process.env.ANALYZE && new BundleAnalyzerPlugin()
    ].filter(Boolean),

    devServer: {
      port: 3000,
      hot: true,
      historyApiFallback: true
    }
  };
};
```

### 2. Vite Configuration

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { visualizer } from 'rollup-plugin-visualizer';
import path from 'path';

export default defineConfig({
  plugins: [
    react(),
    visualizer({
      template: 'treemap',
      open: true,
      gzipSize: true
    })
  ],

  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@utils': path.resolve(__dirname, './src/utils')
    }
  },

  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom', 'react-router-dom'],
          'ui-vendor': ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu'],
          'utils': ['date-fns', 'lodash-es']
        }
      }
    },
    chunkSizeWarningLimit: 1000
  },

  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
});
```

## Testing Architecture

### 1. Testing Pyramid

```typescript
// Unit tests - Test individual functions/components
describe('calculateCartTotal', () => {
  it('should sum item prices', () => {
    const items = [
      { price: 10, quantity: 2 },
      { price: 5, quantity: 3 }
    ];
    expect(calculateCartTotal(items)).toBe(35);
  });

  it('should handle empty cart', () => {
    expect(calculateCartTotal([])).toBe(0);
  });
});

// Component tests
describe('UserCard', () => {
  it('should render user information', () => {
    const user = { name: 'John', email: 'john@example.com' };
    render(<UserCard user={user} />);

    expect(screen.getByText('John')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
  });

  it('should call onEdit when edit button is clicked', () => {
    const onEdit = jest.fn();
    render(<UserCard user={user} onEdit={onEdit} />);

    fireEvent.click(screen.getByText('Edit'));
    expect(onEdit).toHaveBeenCalled();
  });
});

// Integration tests - Test component interactions
describe('LoginFlow', () => {
  it('should login user and redirect to dashboard', async () => {
    const { user } = renderWithRouter(<LoginPage />);

    await user.type(screen.getByLabelText('Email'), 'user@example.com');
    await user.type(screen.getByLabelText('Password'), 'password123');
    await user.click(screen.getByText('Login'));

    await waitFor(() => {
      expect(screen.getByText('Dashboard')).toBeInTheDocument();
    });
  });
});

// E2E tests - Test complete user flows
describe('Checkout Flow', () => {
  it('should complete purchase', async () => {
    await page.goto('http://localhost:3000');

    // Add items to cart
    await page.click('[data-testid="product-1"]');
    await page.click('[data-testid="add-to-cart"]');

    // Go to checkout
    await page.click('[data-testid="cart-icon"]');
    await page.click('[data-testid="checkout"]');

    // Fill shipping info
    await page.fill('[name="address"]', '123 Main St');
    await page.fill('[name="city"]', 'New York');

    // Complete payment
    await page.fill('[name="cardNumber"]', '4242424242424242');
    await page.click('[data-testid="place-order"]');

    // Verify success
    await expect(page.locator('[data-testid="order-confirmation"]'))
      .toBeVisible();
  });
});
```

### 2. Testing Patterns

```typescript
// Test utilities
export function renderWithProviders(
  ui: React.ReactElement,
  options?: {
    preloadedState?: Partial<AppState>;
    store?: AppStore;
  }
) {
  const store = options?.store || createStore(options?.preloadedState);

  function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <Provider store={store}>
        <QueryClientProvider client={queryClient}>
          <BrowserRouter>
            {children}
          </BrowserRouter>
        </QueryClientProvider>
      </Provider>
    );
  }

  return {
    ...render(ui, { wrapper: Wrapper }),
    store
  };
}

// Mock factories
export function createMockUser(overrides?: Partial<User>): User {
  return {
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
    role: 'user',
    ...overrides
  };
}

// Custom matchers
expect.extend({
  toHaveBeenCalledWithUser(received, user: User) {
    const pass = received.mock.calls.some((call: any[]) =>
      call.some(arg => arg?.id === user.id)
    );

    return {
      pass,
      message: () =>
        pass
          ? `Expected not to have been called with user ${user.id}`
          : `Expected to have been called with user ${user.id}`
    };
  }
});
```

## Performance Optimization

### 1. Code Splitting Strategies

```typescript
// Route-based splitting
const routes = [
  {
    path: '/',
    component: lazy(() => import('./pages/Home'))
  },
  {
    path: '/dashboard',
    component: lazy(() => import('./pages/Dashboard'))
  }
];

// Feature-based splitting
const FeatureToggle = ({ feature, children }: FeatureToggleProps) => {
  const [Component, setComponent] = useState<React.ComponentType | null>(null);

  useEffect(() => {
    if (feature.enabled) {
      import(`./features/${feature.name}`).then(module => {
        setComponent(() => module.default);
      });
    }
  }, [feature]);

  if (!Component) return null;
  return <Component>{children}</Component>;
};

// Library splitting
const Editor = lazy(() =>
  import(/* webpackChunkName: "editor" */ '@monaco-editor/react')
);
```

### 2. Tree Shaking

```typescript
// Good - Named imports enable tree shaking
import { debounce } from 'lodash-es';

// Bad - Imports entire library
import _ from 'lodash';

// Configure in package.json
{
  "sideEffects": [
    "*.css",
    "*.scss"
  ]
}

// Mark pure functions for tree shaking
/*#__PURE__*/
export function createLogger() {
  return console.log;
}
```

### 3. Caching Strategies

```typescript
// Service Worker caching
// sw.js
const CACHE_NAME = 'app-v1';
const STATIC_ASSETS = [
  '/',
  '/styles.css',
  '/app.js'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(STATIC_ASSETS);
    })
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});

// HTTP caching headers (server-side)
app.use('/static', express.static('public', {
  maxAge: '1y',
  immutable: true
}));

// React Query caching
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      cacheTime: 10 * 60 * 1000, // 10 minutes
      refetchOnWindowFocus: false
    }
  }
});
```

## Scalability

### 1. Folder Structure

```
src/
├── features/           # Feature-based organization
│   ├── auth/
│   │   ├── components/
│   │   │   ├── LoginForm.tsx
│   │   │   └── SignupForm.tsx
│   │   ├── hooks/
│   │   │   └── useAuth.ts
│   │   ├── services/
│   │   │   └── authService.ts
│   │   ├── types/
│   │   │   └── auth.types.ts
│   │   └── index.ts
│   ├── products/
│   └── cart/
├── shared/             # Shared across features
│   ├── components/
│   │   ├── Button/
│   │   ├── Modal/
│   │   └── Form/
│   ├── hooks/
│   ├── utils/
│   └── types/
├── core/              # Core app functionality
│   ├── api/
│   ├── config/
│   ├── router/
│   └── store/
├── layouts/
├── pages/
└── assets/
```

### 2. Naming Conventions

```typescript
// Components - PascalCase
export function UserProfile() {}
export function ProductCard() {}

// Hooks - camelCase with 'use' prefix
export function useAuth() {}
export function useLocalStorage() {}

// Utilities - camelCase
export function formatDate() {}
export function debounce() {}

// Constants - UPPER_SNAKE_CASE
export const API_BASE_URL = 'https://api.example.com';
export const MAX_FILE_SIZE = 5 * 1024 * 1024;

// Types/Interfaces - PascalCase
export interface User {}
export type UserRole = 'admin' | 'user';

// Files
UserProfile.tsx         // Component
UserProfile.test.tsx    // Test
UserProfile.module.css  // CSS Module
useAuth.ts             // Hook
userService.ts         // Service
user.types.ts          // Types
```

### 3. Dependency Management

```typescript
// Dependency injection for testability
interface Services {
  api: ApiClient;
  storage: StorageService;
  logger: Logger;
}

const ServicesContext = createContext<Services>(null!);

export function useServices() {
  return useContext(ServicesContext);
}

// Usage in components
function UserProfile() {
  const { api, logger } = useServices();

  const loadUser = async () => {
    try {
      const user = await api.get('/user');
      return user;
    } catch (error) {
      logger.error('Failed to load user', error);
    }
  };
}

// Testing with mocked services
test('loads user data', () => {
  const mockApi = { get: jest.fn().mockResolvedValue(mockUser) };
  const mockLogger = { error: jest.fn() };

  render(
    <ServicesContext.Provider value={{ api: mockApi, logger: mockLogger }}>
      <UserProfile />
    </ServicesContext.Provider>
  );
});
```

## Best Practices

1. **Component Design**
   - Keep components small and focused
   - Prefer composition over inheritance
   - Use TypeScript for type safety
   - Implement proper prop validation

2. **State Management**
   - Choose the right level of state (local vs global)
   - Avoid prop drilling with context or state libraries
   - Use immutable updates
   - Separate server state from client state

3. **Performance**
   - Implement code splitting and lazy loading
   - Optimize bundle size with tree shaking
   - Use memoization appropriately
   - Implement proper caching strategies

4. **Testing**
   - Follow the testing pyramid
   - Write meaningful tests, not just for coverage
   - Use proper test utilities and helpers
   - Mock external dependencies

5. **Scalability**
   - Use consistent folder structure
   - Follow naming conventions
   - Implement proper module boundaries
   - Document architectural decisions

## Related Skills

- **react-patterns** - React-specific patterns and best practices
- **typescript-architecture** - TypeScript design patterns
- **performance-optimization** - Advanced performance techniques
- **testing-strategies** - Comprehensive testing approaches
