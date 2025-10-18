# Frontend Architecture Examples

A comprehensive collection of real-world architectural patterns and examples for building scalable frontend applications.

## Table of Contents

1. [E-Commerce Application Architecture](#1-e-commerce-application-architecture)
2. [Social Media Dashboard](#2-social-media-dashboard)
3. [Multi-Tenant SaaS Platform](#3-multi-tenant-saas-platform)
4. [Real-Time Collaboration App](#4-real-time-collaboration-app)
5. [Micro-Frontend Architecture](#5-micro-frontend-architecture)
6. [Offline-First PWA](#6-offline-first-pwa)
7. [Admin Dashboard with RBAC](#7-admin-dashboard-with-rbac)
8. [Form Builder Application](#8-form-builder-application)
9. [Data Visualization Platform](#9-data-visualization-platform)
10. [Plugin-Based Architecture](#10-plugin-based-architecture)
11. [State Machine Architecture](#11-state-machine-architecture)
12. [Event-Driven Architecture](#12-event-driven-architecture)
13. [Layered Architecture Pattern](#13-layered-architecture-pattern)
14. [Repository Pattern Implementation](#14-repository-pattern-implementation)
15. [Feature Flag System](#15-feature-flag-system)
16. [Advanced Caching Strategy](#16-advanced-caching-strategy)
17. [Scalable Testing Architecture](#17-scalable-testing-architecture)

---

## 1. E-Commerce Application Architecture

A complete e-commerce platform demonstrating feature-based architecture, state management, and modular design.

### Folder Structure

```
src/
├── features/
│   ├── products/
│   │   ├── components/
│   │   │   ├── ProductCard.tsx
│   │   │   ├── ProductGrid.tsx
│   │   │   ├── ProductDetail.tsx
│   │   │   └── ProductFilter.tsx
│   │   ├── hooks/
│   │   │   ├── useProducts.ts
│   │   │   ├── useProductFilters.ts
│   │   │   └── useProductSearch.ts
│   │   ├── services/
│   │   │   └── productService.ts
│   │   ├── store/
│   │   │   └── productStore.ts
│   │   └── types/
│   │       └── product.types.ts
│   ├── cart/
│   │   ├── components/
│   │   │   ├── Cart.tsx
│   │   │   ├── CartItem.tsx
│   │   │   └── CartSummary.tsx
│   │   ├── hooks/
│   │   │   └── useCart.ts
│   │   ├── store/
│   │   │   └── cartStore.ts
│   │   └── types/
│   │       └── cart.types.ts
│   ├── checkout/
│   │   ├── components/
│   │   ├── hooks/
│   │   └── services/
│   └── auth/
├── shared/
│   ├── components/
│   ├── hooks/
│   └── utils/
└── core/
    ├── api/
    ├── router/
    └── store/
```

### Implementation

**Product Feature**

```typescript
// features/products/types/product.types.ts
export interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  images: string[];
  category: string;
  stock: number;
  rating: number;
}

export interface ProductFilters {
  category?: string;
  minPrice?: number;
  maxPrice?: number;
  inStock?: boolean;
  rating?: number;
}

// features/products/services/productService.ts
export class ProductService {
  constructor(private apiClient: ApiClient) {}

  async getProducts(filters?: ProductFilters): Promise<Product[]> {
    const params = new URLSearchParams();

    if (filters?.category) params.append('category', filters.category);
    if (filters?.minPrice) params.append('minPrice', String(filters.minPrice));
    if (filters?.maxPrice) params.append('maxPrice', String(filters.maxPrice));

    const response = await this.apiClient.get(`/products?${params}`);
    return response.data;
  }

  async getProduct(id: string): Promise<Product> {
    const response = await this.apiClient.get(`/products/${id}`);
    return response.data;
  }

  async searchProducts(query: string): Promise<Product[]> {
    const response = await this.apiClient.get(`/products/search?q=${query}`);
    return response.data;
  }
}

// features/products/store/productStore.ts
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

interface ProductState {
  products: Product[];
  selectedProduct: Product | null;
  filters: ProductFilters;
  loading: boolean;
  error: string | null;

  setProducts: (products: Product[]) => void;
  setSelectedProduct: (product: Product | null) => void;
  setFilters: (filters: ProductFilters) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
}

export const useProductStore = create<ProductState>()(
  devtools((set) => ({
    products: [],
    selectedProduct: null,
    filters: {},
    loading: false,
    error: null,

    setProducts: (products) => set({ products }),
    setSelectedProduct: (selectedProduct) => set({ selectedProduct }),
    setFilters: (filters) => set({ filters }),
    setLoading: (loading) => set({ loading }),
    setError: (error) => set({ error })
  }))
);

// features/products/hooks/useProducts.ts
export function useProducts(filters?: ProductFilters) {
  const productService = useProductService();
  const setProducts = useProductStore(state => state.setProducts);
  const setLoading = useProductStore(state => state.setLoading);
  const setError = useProductStore(state => state.setError);

  return useQuery({
    queryKey: ['products', filters],
    queryFn: async () => {
      setLoading(true);
      try {
        const products = await productService.getProducts(filters);
        setProducts(products);
        return products;
      } catch (error) {
        setError(error.message);
        throw error;
      } finally {
        setLoading(false);
      }
    },
    staleTime: 5 * 60 * 1000
  });
}

// features/products/components/ProductGrid.tsx
export function ProductGrid() {
  const filters = useProductStore(state => state.filters);
  const { data: products, isLoading } = useProducts(filters);

  if (isLoading) return <ProductGridSkeleton />;

  return (
    <div className="product-grid">
      {products?.map(product => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  );
}
```

**Cart Feature**

```typescript
// features/cart/store/cartStore.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface CartItem {
  product: Product;
  quantity: number;
}

interface CartState {
  items: CartItem[];
  addItem: (product: Product, quantity: number) => void;
  removeItem: (productId: string) => void;
  updateQuantity: (productId: string, quantity: number) => void;
  clear: () => void;
  total: () => number;
  itemCount: () => number;
}

export const useCartStore = create<CartState>()(
  persist(
    (set, get) => ({
      items: [],

      addItem: (product, quantity) =>
        set((state) => {
          const existing = state.items.find(
            item => item.product.id === product.id
          );

          if (existing) {
            return {
              items: state.items.map(item =>
                item.product.id === product.id
                  ? { ...item, quantity: item.quantity + quantity }
                  : item
              )
            };
          }

          return {
            items: [...state.items, { product, quantity }]
          };
        }),

      removeItem: (productId) =>
        set((state) => ({
          items: state.items.filter(item => item.product.id !== productId)
        })),

      updateQuantity: (productId, quantity) =>
        set((state) => ({
          items: state.items.map(item =>
            item.product.id === productId
              ? { ...item, quantity }
              : item
          )
        })),

      clear: () => set({ items: [] }),

      total: () => {
        const items = get().items;
        return items.reduce(
          (sum, item) => sum + item.product.price * item.quantity,
          0
        );
      },

      itemCount: () => {
        const items = get().items;
        return items.reduce((sum, item) => sum + item.quantity, 0);
      }
    }),
    { name: 'cart-storage' }
  )
);

// features/cart/components/Cart.tsx
export function Cart() {
  const items = useCartStore(state => state.items);
  const total = useCartStore(state => state.total());
  const removeItem = useCartStore(state => state.removeItem);
  const updateQuantity = useCartStore(state => state.updateQuantity);

  return (
    <div className="cart">
      <h2>Shopping Cart</h2>

      {items.length === 0 ? (
        <EmptyCart />
      ) : (
        <>
          <div className="cart-items">
            {items.map(item => (
              <CartItem
                key={item.product.id}
                item={item}
                onRemove={() => removeItem(item.product.id)}
                onUpdateQuantity={(qty) =>
                  updateQuantity(item.product.id, qty)
                }
              />
            ))}
          </div>

          <CartSummary total={total} />

          <Link to="/checkout">
            <Button>Proceed to Checkout</Button>
          </Link>
        </>
      )}
    </div>
  );
}
```

---

## 2. Social Media Dashboard

Real-time updates with WebSocket integration and optimistic updates.

### Architecture

```typescript
// core/websocket/WebSocketManager.ts
export class WebSocketManager {
  private socket: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private listeners = new Map<string, Set<(data: any) => void>>();

  connect(url: string, token: string) {
    this.socket = new WebSocket(`${url}?token=${token}`);

    this.socket.onopen = () => {
      console.log('WebSocket connected');
      this.reconnectAttempts = 0;
    };

    this.socket.onmessage = (event) => {
      const message = JSON.parse(event.data);
      this.notifyListeners(message.type, message.data);
    };

    this.socket.onclose = () => {
      console.log('WebSocket disconnected');
      this.reconnect(url, token);
    };

    this.socket.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
  }

  subscribe(eventType: string, callback: (data: any) => void) {
    if (!this.listeners.has(eventType)) {
      this.listeners.set(eventType, new Set());
    }

    this.listeners.get(eventType)!.add(callback);

    return () => {
      this.listeners.get(eventType)?.delete(callback);
    };
  }

  send(eventType: string, data: any) {
    if (this.socket?.readyState === WebSocket.OPEN) {
      this.socket.send(JSON.stringify({ type: eventType, data }));
    }
  }

  private notifyListeners(eventType: string, data: any) {
    this.listeners.get(eventType)?.forEach(callback => callback(data));
  }

  private reconnect(url: string, token: string) {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts), 30000);

      setTimeout(() => {
        console.log(`Reconnecting... attempt ${this.reconnectAttempts}`);
        this.connect(url, token);
      }, delay);
    }
  }

  disconnect() {
    this.socket?.close();
    this.socket = null;
    this.listeners.clear();
  }
}

// features/feed/hooks/useFeed.ts
export function useFeed() {
  const queryClient = useQueryClient();
  const ws = useWebSocketManager();

  const { data: posts, isLoading } = useQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts
  });

  // Subscribe to real-time updates
  useEffect(() => {
    const unsubscribe = ws.subscribe('post:created', (newPost: Post) => {
      queryClient.setQueryData<Post[]>(['posts'], (old = []) => [
        newPost,
        ...old
      ]);
    });

    return unsubscribe;
  }, [ws, queryClient]);

  const createPost = useMutation({
    mutationFn: async (content: string) => {
      const tempId = `temp-${Date.now()}`;
      const optimisticPost: Post = {
        id: tempId,
        content,
        author: currentUser,
        createdAt: new Date(),
        likes: 0,
        comments: []
      };

      // Optimistic update
      queryClient.setQueryData<Post[]>(['posts'], (old = []) => [
        optimisticPost,
        ...old
      ]);

      try {
        const post = await postService.create(content);
        return post;
      } catch (error) {
        // Rollback on error
        queryClient.setQueryData<Post[]>(['posts'], (old = []) =>
          old.filter(p => p.id !== tempId)
        );
        throw error;
      }
    },
    onSuccess: (newPost) => {
      // Replace optimistic post with real post
      queryClient.setQueryData<Post[]>(['posts'], (old = []) =>
        old.map(p => p.id.startsWith('temp-') ? newPost : p)
      );
    }
  });

  const likePost = useMutation({
    mutationFn: async (postId: string) => {
      // Optimistic update
      queryClient.setQueryData<Post[]>(['posts'], (old = []) =>
        old.map(p =>
          p.id === postId
            ? { ...p, likes: p.likes + 1, likedByCurrentUser: true }
            : p
        )
      );

      return postService.like(postId);
    },
    onError: (error, postId) => {
      // Rollback on error
      queryClient.setQueryData<Post[]>(['posts'], (old = []) =>
        old.map(p =>
          p.id === postId
            ? { ...p, likes: p.likes - 1, likedByCurrentUser: false }
            : p
        )
      );
    }
  });

  return {
    posts,
    isLoading,
    createPost: createPost.mutate,
    likePost: likePost.mutate
  };
}
```

---

## 3. Multi-Tenant SaaS Platform

Tenant isolation, feature flags, and role-based access control.

### Implementation

```typescript
// core/tenant/TenantContext.tsx
interface Tenant {
  id: string;
  name: string;
  plan: 'free' | 'pro' | 'enterprise';
  features: string[];
  settings: Record<string, any>;
}

interface TenantContextValue {
  tenant: Tenant | null;
  hasFeature: (feature: string) => boolean;
  getSetting: <T>(key: string, defaultValue: T) => T;
}

const TenantContext = createContext<TenantContextValue>(null!);

export function TenantProvider({ children }: { children: React.ReactNode }) {
  const [tenant, setTenant] = useState<Tenant | null>(null);

  useEffect(() => {
    // Load tenant from subdomain or context
    const subdomain = window.location.hostname.split('.')[0];
    loadTenant(subdomain).then(setTenant);
  }, []);

  const hasFeature = useCallback(
    (feature: string) => {
      return tenant?.features.includes(feature) ?? false;
    },
    [tenant]
  );

  const getSetting = useCallback(
    <T,>(key: string, defaultValue: T): T => {
      return (tenant?.settings[key] as T) ?? defaultValue;
    },
    [tenant]
  );

  return (
    <TenantContext.Provider value={{ tenant, hasFeature, getSetting }}>
      {children}
    </TenantContext.Provider>
  );
}

export const useTenant = () => useContext(TenantContext);

// shared/components/FeatureGate.tsx
export function FeatureGate({
  feature,
  fallback,
  children
}: {
  feature: string;
  fallback?: React.ReactNode;
  children: React.ReactNode;
}) {
  const { hasFeature } = useTenant();

  if (!hasFeature(feature)) {
    return <>{fallback || null}</>;
  }

  return <>{children}</>;
}

// Usage
function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>

      <FeatureGate feature="analytics">
        <AnalyticsWidget />
      </FeatureGate>

      <FeatureGate
        feature="advanced-reports"
        fallback={<UpgradeBanner feature="Advanced Reports" />}
      >
        <AdvancedReports />
      </FeatureGate>
    </div>
  );
}

// core/rbac/usePermissions.ts
export function usePermissions() {
  const { user } = useAuth();

  const hasPermission = useCallback(
    (permission: string) => {
      return user?.permissions.includes(permission) ?? false;
    },
    [user]
  );

  const hasRole = useCallback(
    (role: string) => {
      return user?.roles.includes(role) ?? false;
    },
    [user]
  );

  const hasAnyRole = useCallback(
    (roles: string[]) => {
      return roles.some(role => user?.roles.includes(role)) ?? false;
    },
    [user]
  );

  return { hasPermission, hasRole, hasAnyRole };
}

// shared/components/ProtectedRoute.tsx
export function ProtectedRoute({
  children,
  permission,
  fallback
}: {
  children: React.ReactNode;
  permission?: string;
  fallback?: React.ReactNode;
}) {
  const { isAuthenticated } = useAuth();
  const { hasPermission } = usePermissions();

  if (!isAuthenticated) {
    return <Navigate to="/login" />;
  }

  if (permission && !hasPermission(permission)) {
    return <>{fallback || <AccessDenied />}</>;
  }

  return <>{children}</>;
}
```

---

## 4. Real-Time Collaboration App

Operational transformation and conflict resolution for collaborative editing.

### Implementation

```typescript
// core/collaboration/OperationalTransform.ts
export interface Operation {
  type: 'insert' | 'delete';
  position: number;
  content?: string;
  length?: number;
  userId: string;
  timestamp: number;
}

export class OperationalTransform {
  static transform(op1: Operation, op2: Operation): Operation {
    // If both are inserts
    if (op1.type === 'insert' && op2.type === 'insert') {
      if (op1.position < op2.position) {
        return op2;
      } else if (op1.position > op2.position) {
        return {
          ...op2,
          position: op2.position + (op1.content?.length || 0)
        };
      } else {
        // Same position, use timestamp to decide
        return op1.timestamp < op2.timestamp
          ? op2
          : { ...op2, position: op2.position + (op1.content?.length || 0) };
      }
    }

    // If both are deletes
    if (op1.type === 'delete' && op2.type === 'delete') {
      if (op1.position < op2.position) {
        return {
          ...op2,
          position: op2.position - (op1.length || 0)
        };
      }
      return op2;
    }

    // Insert vs Delete
    if (op1.type === 'insert' && op2.type === 'delete') {
      if (op1.position <= op2.position) {
        return {
          ...op2,
          position: op2.position + (op1.content?.length || 0)
        };
      }
      return op2;
    }

    // Delete vs Insert
    if (op1.type === 'delete' && op2.type === 'insert') {
      if (op1.position < op2.position) {
        return {
          ...op2,
          position: op2.position - (op1.length || 0)
        };
      }
      return op2;
    }

    return op2;
  }

  static apply(content: string, operation: Operation): string {
    if (operation.type === 'insert') {
      return (
        content.slice(0, operation.position) +
        operation.content +
        content.slice(operation.position)
      );
    }

    if (operation.type === 'delete') {
      return (
        content.slice(0, operation.position) +
        content.slice(operation.position + (operation.length || 0))
      );
    }

    return content;
  }
}

// features/editor/hooks/useCollaborativeEditor.ts
export function useCollaborativeEditor(documentId: string) {
  const [content, setContent] = useState('');
  const [cursors, setCursors] = useState<Map<string, number>>(new Map());
  const pendingOperations = useRef<Operation[]>([]);
  const ws = useWebSocketManager();
  const { user } = useAuth();

  // Load initial content
  useEffect(() => {
    loadDocument(documentId).then(doc => setContent(doc.content));
  }, [documentId]);

  // Subscribe to remote operations
  useEffect(() => {
    const unsubscribe = ws.subscribe('operation', (op: Operation) => {
      if (op.userId === user?.id) return;

      // Transform pending operations
      pendingOperations.current = pendingOperations.current.map(
        pendingOp => OperationalTransform.transform(op, pendingOp)
      );

      // Apply operation
      setContent(content =>
        OperationalTransform.apply(content, op)
      );
    });

    return unsubscribe;
  }, [ws, user]);

  // Subscribe to cursor updates
  useEffect(() => {
    const unsubscribe = ws.subscribe('cursor', ({ userId, position }) => {
      setCursors(prev => new Map(prev).set(userId, position));
    });

    return unsubscribe;
  }, [ws]);

  const handleChange = useCallback((newContent: string, position: number) => {
    const operation: Operation = {
      type: newContent.length > content.length ? 'insert' : 'delete',
      position,
      content: newContent.length > content.length
        ? newContent.slice(position, position + (newContent.length - content.length))
        : undefined,
      length: newContent.length < content.length
        ? content.length - newContent.length
        : undefined,
      userId: user!.id,
      timestamp: Date.now()
    };

    // Apply locally
    setContent(newContent);

    // Send to server
    ws.send('operation', operation);
    pendingOperations.current.push(operation);

    // Acknowledge from server
    ws.subscribe('operation:ack', (ackOp: Operation) => {
      if (ackOp.timestamp === operation.timestamp) {
        pendingOperations.current = pendingOperations.current.filter(
          op => op.timestamp !== operation.timestamp
        );
      }
    });
  }, [content, ws, user]);

  const handleCursorMove = useCallback((position: number) => {
    ws.send('cursor', { position });
  }, [ws]);

  return {
    content,
    cursors,
    handleChange,
    handleCursorMove
  };
}
```

---

## 5. Micro-Frontend Architecture

Module federation and independent deployment of frontend modules.

### Webpack Module Federation Configuration

```javascript
// host/webpack.config.js
const ModuleFederationPlugin = require('webpack/lib/container/ModuleFederationPlugin');

module.exports = {
  plugins: [
    new ModuleFederationPlugin({
      name: 'host',
      remotes: {
        products: 'products@http://localhost:3001/remoteEntry.js',
        cart: 'cart@http://localhost:3002/remoteEntry.js',
        checkout: 'checkout@http://localhost:3003/remoteEntry.js'
      },
      shared: {
        react: { singleton: true, requiredVersion: '^18.0.0' },
        'react-dom': { singleton: true, requiredVersion: '^18.0.0' }
      }
    })
  ]
};

// products/webpack.config.js
module.exports = {
  plugins: [
    new ModuleFederationPlugin({
      name: 'products',
      filename: 'remoteEntry.js',
      exposes: {
        './ProductList': './src/components/ProductList',
        './ProductDetail': './src/components/ProductDetail'
      },
      shared: {
        react: { singleton: true },
        'react-dom': { singleton: true }
      }
    })
  ]
};

// host/src/App.tsx
import { lazy, Suspense } from 'react';

const ProductList = lazy(() => import('products/ProductList'));
const Cart = lazy(() => import('cart/Cart'));
const Checkout = lazy(() => import('checkout/Checkout'));

function App() {
  return (
    <BrowserRouter>
      <Header />
      <Suspense fallback={<Loading />}>
        <Routes>
          <Route path="/products" element={<ProductList />} />
          <Route path="/cart" element={<Cart />} />
          <Route path="/checkout" element={<Checkout />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}

// Shared event bus for micro-frontend communication
class EventBus {
  private events = new Map<string, Set<(data: any) => void>>();

  emit(event: string, data?: any) {
    this.events.get(event)?.forEach(handler => handler(data));
  }

  on(event: string, handler: (data: any) => void) {
    if (!this.events.has(event)) {
      this.events.set(event, new Set());
    }
    this.events.get(event)!.add(handler);

    return () => this.events.get(event)?.delete(handler);
  }
}

export const eventBus = new EventBus();

// Usage in micro-frontends
// In products module
eventBus.emit('product:added-to-cart', { productId: '123', quantity: 1 });

// In cart module
eventBus.on('product:added-to-cart', ({ productId, quantity }) => {
  addItemToCart(productId, quantity);
});
```

---

## 6. Offline-First PWA

Service workers, IndexedDB, and background sync.

### Implementation

```typescript
// core/offline/ServiceWorkerManager.ts
export class ServiceWorkerManager {
  async register() {
    if ('serviceWorker' in navigator) {
      try {
        const registration = await navigator.serviceWorker.register('/sw.js');
        console.log('Service Worker registered:', registration);

        registration.addEventListener('updatefound', () => {
          const newWorker = registration.installing;
          newWorker?.addEventListener('statechange', () => {
            if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
              // New version available
              this.notifyUpdate();
            }
          });
        });
      } catch (error) {
        console.error('Service Worker registration failed:', error);
      }
    }
  }

  private notifyUpdate() {
    if (confirm('New version available. Update now?')) {
      window.location.reload();
    }
  }

  async unregister() {
    const registrations = await navigator.serviceWorker.getRegistrations();
    for (const registration of registrations) {
      await registration.unregister();
    }
  }
}

// public/sw.js
const CACHE_NAME = 'app-v1';
const RUNTIME_CACHE = 'runtime';

const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/static/css/main.css',
  '/static/js/main.js'
];

// Install - cache static assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(STATIC_ASSETS);
    })
  );
  self.skipWaiting();
});

// Activate - clean old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME && name !== RUNTIME_CACHE)
          .map((name) => caches.delete(name))
      );
    })
  );
  self.clients.claim();
});

// Fetch - network first, fall back to cache
self.addEventListener('fetch', (event) => {
  const { request } = event;

  // API requests - network first
  if (request.url.includes('/api/')) {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const clone = response.clone();
          caches.open(RUNTIME_CACHE).then((cache) => {
            cache.put(request, clone);
          });
          return response;
        })
        .catch(() => {
          return caches.match(request);
        })
    );
    return;
  }

  // Static assets - cache first
  event.respondWith(
    caches.match(request).then((cached) => {
      return cached || fetch(request);
    })
  );
});

// Background sync
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-posts') {
    event.waitUntil(syncPosts());
  }
});

async function syncPosts() {
  const db = await openDB();
  const posts = await db.getAll('pending-posts');

  for (const post of posts) {
    try {
      await fetch('/api/posts', {
        method: 'POST',
        body: JSON.stringify(post)
      });
      await db.delete('pending-posts', post.id);
    } catch (error) {
      console.error('Sync failed:', error);
    }
  }
}

// core/offline/useOfflineSync.ts
export function useOfflineSync() {
  const [isOnline, setIsOnline] = useState(navigator.onLine);

  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  const createPost = useMutation({
    mutationFn: async (content: string) => {
      if (isOnline) {
        return postService.create(content);
      } else {
        // Save to IndexedDB
        const db = await openDB();
        const post = {
          id: crypto.randomUUID(),
          content,
          createdAt: new Date(),
          synced: false
        };
        await db.add('pending-posts', post);

        // Register background sync
        if ('serviceWorker' in navigator && 'sync' in ServiceWorkerRegistration.prototype) {
          const registration = await navigator.serviceWorker.ready;
          await registration.sync.register('sync-posts');
        }

        return post;
      }
    }
  });

  return { isOnline, createPost };
}
```

---

## 7. Admin Dashboard with RBAC

Complete role-based access control system.

### Implementation

```typescript
// core/rbac/permissions.ts
export const PERMISSIONS = {
  // Users
  'users:read': 'View users',
  'users:create': 'Create users',
  'users:update': 'Update users',
  'users:delete': 'Delete users',

  // Posts
  'posts:read': 'View posts',
  'posts:create': 'Create posts',
  'posts:update': 'Update posts',
  'posts:delete': 'Delete posts',
  'posts:publish': 'Publish posts',

  // Settings
  'settings:read': 'View settings',
  'settings:update': 'Update settings'
} as const;

export type Permission = keyof typeof PERMISSIONS;

export const ROLES = {
  admin: Object.keys(PERMISSIONS) as Permission[],
  editor: [
    'users:read',
    'posts:read',
    'posts:create',
    'posts:update',
    'posts:publish'
  ] as Permission[],
  author: [
    'posts:read',
    'posts:create',
    'posts:update'
  ] as Permission[],
  viewer: [
    'users:read',
    'posts:read'
  ] as Permission[]
};

export type Role = keyof typeof ROLES;

// core/rbac/useAuthorization.ts
export function useAuthorization() {
  const { user } = useAuth();

  const hasPermission = useCallback(
    (permission: Permission): boolean => {
      if (!user) return false;

      const userPermissions = user.roles.flatMap(role => ROLES[role] || []);
      return userPermissions.includes(permission);
    },
    [user]
  );

  const hasAnyPermission = useCallback(
    (permissions: Permission[]): boolean => {
      return permissions.some(hasPermission);
    },
    [hasPermission]
  );

  const hasAllPermissions = useCallback(
    (permissions: Permission[]): boolean => {
      return permissions.every(hasPermission);
    },
    [hasPermission]
  );

  const hasRole = useCallback(
    (role: Role): boolean => {
      return user?.roles.includes(role) ?? false;
    },
    [user]
  );

  return {
    hasPermission,
    hasAnyPermission,
    hasAllPermissions,
    hasRole
  };
}

// shared/components/Can.tsx
export function Can({
  permission,
  permissions,
  requireAll = false,
  fallback,
  children
}: {
  permission?: Permission;
  permissions?: Permission[];
  requireAll?: boolean;
  fallback?: React.ReactNode;
  children: React.ReactNode;
}) {
  const { hasPermission, hasAnyPermission, hasAllPermissions } = useAuthorization();

  let authorized = false;

  if (permission) {
    authorized = hasPermission(permission);
  } else if (permissions) {
    authorized = requireAll
      ? hasAllPermissions(permissions)
      : hasAnyPermission(permissions);
  }

  if (!authorized) {
    return <>{fallback || null}</>;
  }

  return <>{children}</>;
}

// Usage
function UserManagement() {
  return (
    <div>
      <h1>User Management</h1>

      <Can permission="users:create">
        <Button>Create User</Button>
      </Can>

      <Can permission="users:read">
        <UserList />
      </Can>

      <Can
        permissions={['users:update', 'users:delete']}
        fallback={<p>You don't have permission to manage users.</p>}
      >
        <UserActions />
      </Can>
    </div>
  );
}
```

---

## 8. Form Builder Application

Dynamic form generation with validation.

### Implementation

```typescript
// features/form-builder/types.ts
export interface FormField {
  id: string;
  type: 'text' | 'email' | 'number' | 'select' | 'checkbox' | 'radio' | 'textarea';
  label: string;
  placeholder?: string;
  required?: boolean;
  validation?: ValidationRule[];
  options?: { value: string; label: string }[];
  defaultValue?: any;
}

export interface ValidationRule {
  type: 'required' | 'min' | 'max' | 'pattern' | 'custom';
  value?: any;
  message: string;
}

export interface FormSchema {
  id: string;
  title: string;
  description?: string;
  fields: FormField[];
  submitButton: string;
}

// features/form-builder/FormRenderer.tsx
export function FormRenderer({ schema }: { schema: FormSchema }) {
  const {
    register,
    handleSubmit,
    formState: { errors },
    watch
  } = useForm();

  const onSubmit = (data: any) => {
    console.log('Form submitted:', data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <h2>{schema.title}</h2>
      {schema.description && <p>{schema.description}</p>}

      {schema.fields.map(field => (
        <div key={field.id} className="form-field">
          <label htmlFor={field.id}>
            {field.label}
            {field.required && <span className="required">*</span>}
          </label>

          {field.type === 'text' || field.type === 'email' || field.type === 'number' ? (
            <input
              id={field.id}
              type={field.type}
              placeholder={field.placeholder}
              {...register(field.id, getValidationRules(field))}
            />
          ) : field.type === 'textarea' ? (
            <textarea
              id={field.id}
              placeholder={field.placeholder}
              {...register(field.id, getValidationRules(field))}
            />
          ) : field.type === 'select' ? (
            <select id={field.id} {...register(field.id, getValidationRules(field))}>
              <option value="">Select...</option>
              {field.options?.map(option => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          ) : field.type === 'checkbox' ? (
            <input
              id={field.id}
              type="checkbox"
              {...register(field.id, getValidationRules(field))}
            />
          ) : null}

          {errors[field.id] && (
            <span className="error">{errors[field.id]?.message as string}</span>
          )}
        </div>
      ))}

      <button type="submit">{schema.submitButton}</button>
    </form>
  );
}

function getValidationRules(field: FormField) {
  const rules: any = {};

  field.validation?.forEach(rule => {
    if (rule.type === 'required') {
      rules.required = rule.message;
    } else if (rule.type === 'min') {
      rules.min = { value: rule.value, message: rule.message };
    } else if (rule.type === 'max') {
      rules.max = { value: rule.value, message: rule.message };
    } else if (rule.type === 'pattern') {
      rules.pattern = { value: new RegExp(rule.value), message: rule.message };
    }
  });

  return rules;
}
```

---

## 9. Data Visualization Platform

Large dataset handling with virtualization.

### Implementation

```typescript
// features/visualization/hooks/useVirtualization.ts
export function useVirtualization<T>({
  items,
  itemHeight,
  containerHeight,
  overscan = 3
}: {
  items: T[];
  itemHeight: number;
  containerHeight: number;
  overscan?: number;
}) {
  const [scrollTop, setScrollTop] = useState(0);

  const visibleStart = Math.floor(scrollTop / itemHeight);
  const visibleEnd = Math.ceil((scrollTop + containerHeight) / itemHeight);

  const start = Math.max(0, visibleStart - overscan);
  const end = Math.min(items.length, visibleEnd + overscan);

  const visibleItems = items.slice(start, end);

  const totalHeight = items.length * itemHeight;
  const offsetY = start * itemHeight;

  const handleScroll = (e: React.UIEvent<HTMLDivElement>) => {
    setScrollTop(e.currentTarget.scrollTop);
  };

  return {
    visibleItems,
    totalHeight,
    offsetY,
    handleScroll,
    start,
    end
  };
}

// Usage
function LargeList({ items }: { items: DataPoint[] }) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [containerHeight, setContainerHeight] = useState(600);

  const {
    visibleItems,
    totalHeight,
    offsetY,
    handleScroll
  } = useVirtualization({
    items,
    itemHeight: 50,
    containerHeight
  });

  useEffect(() => {
    if (containerRef.current) {
      setContainerHeight(containerRef.current.clientHeight);
    }
  }, []);

  return (
    <div
      ref={containerRef}
      style={{ height: '600px', overflow: 'auto' }}
      onScroll={handleScroll}
    >
      <div style={{ height: totalHeight, position: 'relative' }}>
        <div style={{ transform: `translateY(${offsetY}px)` }}>
          {visibleItems.map((item, index) => (
            <DataRow key={start + index} data={item} />
          ))}
        </div>
      </div>
    </div>
  );
}
```

---

## 10. Plugin-Based Architecture

Extensible plugin system.

### Implementation

```typescript
// core/plugins/PluginManager.ts
export interface Plugin {
  name: string;
  version: string;
  initialize: (context: PluginContext) => void | Promise<void>;
  destroy?: () => void | Promise<void>;
}

export interface PluginContext {
  registerComponent: (name: string, component: React.ComponentType) => void;
  registerRoute: (path: string, component: React.ComponentType) => void;
  registerMenuItem: (item: MenuItem) => void;
  registerHook: (name: string, callback: Function) => void;
  getAPI: () => API;
}

export class PluginManager {
  private plugins: Map<string, Plugin> = new Map();
  private components: Map<string, React.ComponentType> = new Map();
  private routes: Array<{ path: string; component: React.ComponentType }> = [];
  private menuItems: MenuItem[] = [];
  private hooks: Map<string, Set<Function>> = new Map();

  async loadPlugin(plugin: Plugin) {
    const context: PluginContext = {
      registerComponent: (name, component) => {
        this.components.set(name, component);
      },
      registerRoute: (path, component) => {
        this.routes.push({ path, component });
      },
      registerMenuItem: (item) => {
        this.menuItems.push(item);
      },
      registerHook: (name, callback) => {
        if (!this.hooks.has(name)) {
          this.hooks.set(name, new Set());
        }
        this.hooks.get(name)!.add(callback);
      },
      getAPI: () => this.getAPI()
    };

    await plugin.initialize(context);
    this.plugins.set(plugin.name, plugin);
  }

  async unloadPlugin(name: string) {
    const plugin = this.plugins.get(name);
    if (plugin?.destroy) {
      await plugin.destroy();
    }
    this.plugins.delete(name);
  }

  getComponent(name: string) {
    return this.components.get(name);
  }

  getRoutes() {
    return this.routes;
  }

  getMenuItems() {
    return this.menuItems;
  }

  executeHook(name: string, ...args: any[]) {
    const callbacks = this.hooks.get(name);
    if (callbacks) {
      callbacks.forEach(callback => callback(...args));
    }
  }

  private getAPI() {
    // Return API for plugins
    return {
      // API methods
    };
  }
}

// Example plugin
export const AnalyticsPlugin: Plugin = {
  name: 'analytics',
  version: '1.0.0',

  initialize(context) {
    // Register components
    context.registerComponent('AnalyticsDashboard', AnalyticsDashboard);

    // Register routes
    context.registerRoute('/analytics', AnalyticsDashboard);

    // Register menu items
    context.registerMenuItem({
      label: 'Analytics',
      path: '/analytics',
      icon: 'chart'
    });

    // Register hooks
    context.registerHook('page:view', (page: string) => {
      console.log('Page viewed:', page);
    });
  },

  destroy() {
    console.log('Analytics plugin destroyed');
  }
};
```

---

## 11. State Machine Architecture

Using XState for predictable state transitions and complex workflows.

### Implementation

```typescript
// features/checkout/machines/checkoutMachine.ts
import { createMachine, assign } from 'xstate';

interface CheckoutContext {
  cart: CartItem[];
  shippingAddress: Address | null;
  paymentMethod: PaymentMethod | null;
  error: string | null;
}

type CheckoutEvent =
  | { type: 'NEXT' }
  | { type: 'BACK' }
  | { type: 'SET_SHIPPING'; address: Address }
  | { type: 'SET_PAYMENT'; payment: PaymentMethod }
  | { type: 'SUBMIT' }
  | { type: 'RETRY' };

export const checkoutMachine = createMachine<CheckoutContext, CheckoutEvent>({
  id: 'checkout',
  initial: 'cart',
  context: {
    cart: [],
    shippingAddress: null,
    paymentMethod: null,
    error: null
  },
  states: {
    cart: {
      on: {
        NEXT: {
          target: 'shipping',
          cond: (context) => context.cart.length > 0
        }
      }
    },
    shipping: {
      on: {
        BACK: 'cart',
        SET_SHIPPING: {
          actions: assign({
            shippingAddress: (_, event) => event.address
          })
        },
        NEXT: {
          target: 'payment',
          cond: (context) => context.shippingAddress !== null
        }
      }
    },
    payment: {
      on: {
        BACK: 'shipping',
        SET_PAYMENT: {
          actions: assign({
            paymentMethod: (_, event) => event.payment
          })
        },
        SUBMIT: {
          target: 'processing',
          cond: (context) => context.paymentMethod !== null
        }
      }
    },
    processing: {
      invoke: {
        src: 'processOrder',
        onDone: 'success',
        onError: {
          target: 'error',
          actions: assign({
            error: (_, event) => event.data.message
          })
        }
      }
    },
    success: {
      type: 'final'
    },
    error: {
      on: {
        RETRY: 'payment',
        BACK: 'payment'
      }
    }
  }
}, {
  services: {
    processOrder: async (context) => {
      const response = await fetch('/api/orders', {
        method: 'POST',
        body: JSON.stringify({
          cart: context.cart,
          shipping: context.shippingAddress,
          payment: context.paymentMethod
        })
      });

      if (!response.ok) {
        throw new Error('Payment failed');
      }

      return response.json();
    }
  }
});

// Usage in component
function CheckoutFlow() {
  const [state, send] = useMachine(checkoutMachine);

  return (
    <div>
      {state.matches('cart') && (
        <CartStep onNext={() => send('NEXT')} />
      )}

      {state.matches('shipping') && (
        <ShippingStep
          onBack={() => send('BACK')}
          onNext={(address) => {
            send({ type: 'SET_SHIPPING', address });
            send('NEXT');
          }}
        />
      )}

      {state.matches('payment') && (
        <PaymentStep
          onBack={() => send('BACK')}
          onSubmit={(payment) => {
            send({ type: 'SET_PAYMENT', payment });
            send('SUBMIT');
          }}
        />
      )}

      {state.matches('processing') && <ProcessingSpinner />}

      {state.matches('success') && <OrderSuccess />}

      {state.matches('error') && (
        <ErrorMessage
          message={state.context.error}
          onRetry={() => send('RETRY')}
        />
      )}
    </div>
  );
}
```

---

## 12. Event-Driven Architecture

Decoupled components communicating through events.

### Implementation

```typescript
// core/events/EventEmitter.ts
export class EventEmitter<T extends Record<string, any>> {
  private events = new Map<keyof T, Set<(data: any) => void>>();

  on<K extends keyof T>(event: K, handler: (data: T[K]) => void): () => void {
    if (!this.events.has(event)) {
      this.events.set(event, new Set());
    }

    this.events.get(event)!.add(handler);

    return () => {
      this.events.get(event)?.delete(handler);
    };
  }

  emit<K extends keyof T>(event: K, data: T[K]): void {
    this.events.get(event)?.forEach(handler => handler(data));
  }

  once<K extends keyof T>(event: K, handler: (data: T[K]) => void): void {
    const unsubscribe = this.on(event, (data) => {
      handler(data);
      unsubscribe();
    });
  }
}

// Application events
interface AppEvents {
  'user:login': { user: User };
  'user:logout': void;
  'notification:show': { message: string; type: 'success' | 'error' };
  'cart:item-added': { productId: string; quantity: number };
  'order:completed': { orderId: string; total: number };
}

export const appEvents = new EventEmitter<AppEvents>();

// Usage in features
function ProductCard({ product }: { product: Product }) {
  const handleAddToCart = () => {
    // Emit event instead of direct coupling
    appEvents.emit('cart:item-added', {
      productId: product.id,
      quantity: 1
    });

    appEvents.emit('notification:show', {
      message: 'Product added to cart',
      type: 'success'
    });
  };

  return (
    <div>
      <h3>{product.name}</h3>
      <button onClick={handleAddToCart}>Add to Cart</button>
    </div>
  );
}

// Cart component listens to events
function Cart() {
  const [items, setItems] = useState<CartItem[]>([]);

  useEffect(() => {
    return appEvents.on('cart:item-added', ({ productId, quantity }) => {
      // Update cart
      setItems(prev => [...prev, { productId, quantity }]);
    });
  }, []);

  return <div>{/* Cart UI */}</div>;
}

// Notification component listens to events
function NotificationManager() {
  const [notifications, setNotifications] = useState<Notification[]>([]);

  useEffect(() => {
    return appEvents.on('notification:show', ({ message, type }) => {
      const id = crypto.randomUUID();
      setNotifications(prev => [...prev, { id, message, type }]);

      setTimeout(() => {
        setNotifications(prev => prev.filter(n => n.id !== id));
      }, 3000);
    });
  }, []);

  return (
    <div className="notifications">
      {notifications.map(n => (
        <div key={n.id} className={`notification ${n.type}`}>
          {n.message}
        </div>
      ))}
    </div>
  );
}
```

---

## 13. Layered Architecture Pattern

Clean separation of concerns across application layers.

### Implementation

```typescript
// Domain Layer - Business entities and logic
export class User {
  constructor(
    public readonly id: string,
    public email: string,
    public name: string,
    private _role: UserRole
  ) {}

  get role(): UserRole {
    return this._role;
  }

  canEdit(resource: Resource): boolean {
    return this._role === 'admin' || resource.authorId === this.id;
  }

  updateProfile(name: string, email: string): void {
    if (!this.isValidEmail(email)) {
      throw new Error('Invalid email');
    }
    this.name = name;
    this.email = email;
  }

  private isValidEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }
}

// Infrastructure Layer - Data access
export interface IUserRepository {
  findById(id: string): Promise<User>;
  save(user: User): Promise<void>;
  delete(id: string): Promise<void>;
}

export class HttpUserRepository implements IUserRepository {
  constructor(private apiClient: ApiClient) {}

  async findById(id: string): Promise<User> {
    const data = await this.apiClient.get(`/users/${id}`);
    return new User(data.id, data.email, data.name, data.role);
  }

  async save(user: User): Promise<void> {
    await this.apiClient.put(`/users/${user.id}`, {
      email: user.email,
      name: user.name
    });
  }

  async delete(id: string): Promise<void> {
    await this.apiClient.delete(`/users/${id}`);
  }
}

// Application Layer - Use cases
export class UpdateUserProfileUseCase {
  constructor(private userRepository: IUserRepository) {}

  async execute(userId: string, name: string, email: string): Promise<User> {
    const user = await this.userRepository.findById(userId);
    user.updateProfile(name, email);
    await this.userRepository.save(user);
    return user;
  }
}

// Presentation Layer - React components
function UserProfileForm({ userId }: { userId: string }) {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const useCase = useUpdateUserProfileUseCase();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await useCase.execute(userId, name, email);
      toast.success('Profile updated');
    } catch (error) {
      toast.error(error.message);
    }
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
      />
      <button type="submit">Update Profile</button>
    </form>
  );
}
```

---

## 14. Repository Pattern Implementation

Abstract data access layer for flexibility and testability.

### Implementation

```typescript
// Domain interfaces
export interface IRepository<T> {
  findAll(): Promise<T[]>;
  findById(id: string): Promise<T | null>;
  create(entity: Omit<T, 'id'>): Promise<T>;
  update(id: string, entity: Partial<T>): Promise<T>;
  delete(id: string): Promise<void>;
}

// Concrete repository implementations
export class HttpRepository<T extends { id: string }> implements IRepository<T> {
  constructor(
    private endpoint: string,
    private apiClient: ApiClient
  ) {}

  async findAll(): Promise<T[]> {
    const response = await this.apiClient.get(this.endpoint);
    return response.data;
  }

  async findById(id: string): Promise<T | null> {
    try {
      const response = await this.apiClient.get(`${this.endpoint}/${id}`);
      return response.data;
    } catch (error) {
      if (error.status === 404) return null;
      throw error;
    }
  }

  async create(entity: Omit<T, 'id'>): Promise<T> {
    const response = await this.apiClient.post(this.endpoint, entity);
    return response.data;
  }

  async update(id: string, entity: Partial<T>): Promise<T> {
    const response = await this.apiClient.patch(`${this.endpoint}/${id}`, entity);
    return response.data;
  }

  async delete(id: string): Promise<void> {
    await this.apiClient.delete(`${this.endpoint}/${id}`);
  }
}

// Cached repository decorator
export class CachedRepository<T extends { id: string }> implements IRepository<T> {
  private cache = new Map<string, { data: T; timestamp: number }>();
  private cacheDuration = 5 * 60 * 1000; // 5 minutes

  constructor(private repository: IRepository<T>) {}

  async findAll(): Promise<T[]> {
    return this.repository.findAll();
  }

  async findById(id: string): Promise<T | null> {
    const cached = this.cache.get(id);
    const now = Date.now();

    if (cached && now - cached.timestamp < this.cacheDuration) {
      return cached.data;
    }

    const entity = await this.repository.findById(id);
    if (entity) {
      this.cache.set(id, { data: entity, timestamp: now });
    }

    return entity;
  }

  async create(entity: Omit<T, 'id'>): Promise<T> {
    const created = await this.repository.create(entity);
    this.cache.set(created.id, { data: created, timestamp: Date.now() });
    return created;
  }

  async update(id: string, entity: Partial<T>): Promise<T> {
    const updated = await this.repository.update(id, entity);
    this.cache.set(id, { data: updated, timestamp: Date.now() });
    return updated;
  }

  async delete(id: string): Promise<void> {
    await this.repository.delete(id);
    this.cache.delete(id);
  }
}

// Usage
const productRepository = new CachedRepository(
  new HttpRepository<Product>('/api/products', apiClient)
);

function useProducts() {
  const repository = useProductRepository();

  return useQuery({
    queryKey: ['products'],
    queryFn: () => repository.findAll()
  });
}
```

---

## 15. Feature Flag System

Runtime feature toggles and A/B testing.

### Implementation

```typescript
// core/features/FeatureFlagManager.ts
export interface FeatureFlag {
  key: string;
  enabled: boolean;
  rolloutPercentage?: number;
  variants?: Record<string, any>;
  rules?: FeatureRule[];
}

export interface FeatureRule {
  attribute: string;
  operator: 'equals' | 'contains' | 'gt' | 'lt';
  value: any;
}

export class FeatureFlagManager {
  private flags = new Map<string, FeatureFlag>();
  private userAttributes: Record<string, any> = {};

  setUserAttributes(attributes: Record<string, any>) {
    this.userAttributes = attributes;
  }

  registerFlag(flag: FeatureFlag) {
    this.flags.set(flag.key, flag);
  }

  isEnabled(key: string): boolean {
    const flag = this.flags.get(key);
    if (!flag) return false;

    // Check if globally enabled
    if (!flag.enabled) return false;

    // Check rules
    if (flag.rules && !this.evaluateRules(flag.rules)) {
      return false;
    }

    // Check rollout percentage
    if (flag.rolloutPercentage !== undefined) {
      const hash = this.hashString(this.userAttributes.userId + key);
      const bucket = hash % 100;
      return bucket < flag.rolloutPercentage;
    }

    return true;
  }

  getVariant(key: string): string | null {
    const flag = this.flags.get(key);
    if (!flag || !this.isEnabled(key)) return null;

    if (flag.variants) {
      const variantKeys = Object.keys(flag.variants);
      const hash = this.hashString(this.userAttributes.userId + key);
      const index = hash % variantKeys.length;
      return variantKeys[index];
    }

    return null;
  }

  private evaluateRules(rules: FeatureRule[]): boolean {
    return rules.every(rule => {
      const value = this.userAttributes[rule.attribute];

      switch (rule.operator) {
        case 'equals':
          return value === rule.value;
        case 'contains':
          return Array.isArray(value) && value.includes(rule.value);
        case 'gt':
          return value > rule.value;
        case 'lt':
          return value < rule.value;
        default:
          return false;
      }
    });
  }

  private hashString(str: string): number {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash);
  }
}

// React integration
const FeatureFlagContext = createContext<FeatureFlagManager>(null!);

export function FeatureFlagProvider({ children }: { children: React.ReactNode }) {
  const [manager] = useState(() => new FeatureFlagManager());
  const { user } = useAuth();

  useEffect(() => {
    if (user) {
      manager.setUserAttributes({
        userId: user.id,
        email: user.email,
        plan: user.plan,
        signupDate: user.createdAt
      });
    }
  }, [user, manager]);

  useEffect(() => {
    // Load feature flags from server
    fetch('/api/feature-flags')
      .then(r => r.json())
      .then(flags => {
        flags.forEach((flag: FeatureFlag) => manager.registerFlag(flag));
      });
  }, [manager]);

  return (
    <FeatureFlagContext.Provider value={manager}>
      {children}
    </FeatureFlagContext.Provider>
  );
}

export function useFeatureFlag(key: string) {
  const manager = useContext(FeatureFlagContext);
  const [enabled, setEnabled] = useState(manager.isEnabled(key));

  useEffect(() => {
    setEnabled(manager.isEnabled(key));
  }, [manager, key]);

  return enabled;
}

export function useFeatureVariant(key: string) {
  const manager = useContext(FeatureFlagContext);
  return manager.getVariant(key);
}

// Usage
function Dashboard() {
  const newDashboard = useFeatureFlag('new-dashboard');
  const variant = useFeatureVariant('dashboard-layout');

  if (newDashboard) {
    return variant === 'compact' ? <CompactDashboard /> : <ExpandedDashboard />;
  }

  return <LegacyDashboard />;
}
```

---

## 16. Advanced Caching Strategy

Multi-level caching with invalidation and persistence.

### Implementation

```typescript
// core/cache/CacheManager.ts
export interface CacheEntry<T> {
  data: T;
  timestamp: number;
  expiresAt: number;
  tags: string[];
}

export class CacheManager {
  private memoryCache = new Map<string, CacheEntry<any>>();
  private persistentCache: IDBDatabase | null = null;

  async initialize() {
    this.persistentCache = await openDB('app-cache', 1, {
      upgrade(db) {
        db.createObjectStore('cache');
      }
    });
  }

  async get<T>(key: string): Promise<T | null> {
    // Check memory cache first
    const memoryCached = this.memoryCache.get(key);
    if (memoryCached && memoryCached.expiresAt > Date.now()) {
      return memoryCached.data;
    }

    // Check persistent cache
    if (this.persistentCache) {
      const tx = this.persistentCache.transaction('cache', 'readonly');
      const store = tx.objectStore('cache');
      const cached = await store.get(key);

      if (cached && cached.expiresAt > Date.now()) {
        // Promote to memory cache
        this.memoryCache.set(key, cached);
        return cached.data;
      }
    }

    return null;
  }

  async set<T>(
    key: string,
    data: T,
    ttl: number = 5 * 60 * 1000,
    tags: string[] = []
  ): Promise<void> {
    const entry: CacheEntry<T> = {
      data,
      timestamp: Date.now(),
      expiresAt: Date.now() + ttl,
      tags
    };

    // Set in memory cache
    this.memoryCache.set(key, entry);

    // Set in persistent cache
    if (this.persistentCache) {
      const tx = this.persistentCache.transaction('cache', 'readwrite');
      const store = tx.objectStore('cache');
      await store.put(entry, key);
    }
  }

  async invalidate(key: string): Promise<void> {
    this.memoryCache.delete(key);

    if (this.persistentCache) {
      const tx = this.persistentCache.transaction('cache', 'readwrite');
      const store = tx.objectStore('cache');
      await store.delete(key);
    }
  }

  async invalidateByTag(tag: string): Promise<void> {
    // Invalidate memory cache
    for (const [key, entry] of this.memoryCache.entries()) {
      if (entry.tags.includes(tag)) {
        this.memoryCache.delete(key);
      }
    }

    // Invalidate persistent cache
    if (this.persistentCache) {
      const tx = this.persistentCache.transaction('cache', 'readwrite');
      const store = tx.objectStore('cache');
      const keys = await store.getAllKeys();

      for (const key of keys) {
        const entry = await store.get(key);
        if (entry?.tags.includes(tag)) {
          await store.delete(key);
        }
      }
    }
  }

  async clear(): Promise<void> {
    this.memoryCache.clear();

    if (this.persistentCache) {
      const tx = this.persistentCache.transaction('cache', 'readwrite');
      const store = tx.objectStore('cache');
      await store.clear();
    }
  }
}

// React Query integration with cache
export function useCachedQuery<T>(
  queryKey: string[],
  queryFn: () => Promise<T>,
  options?: {
    ttl?: number;
    tags?: string[];
  }
) {
  const cache = useCacheManager();

  return useQuery({
    queryKey,
    queryFn: async () => {
      const cacheKey = queryKey.join(':');
      const cached = await cache.get<T>(cacheKey);

      if (cached) {
        return cached;
      }

      const data = await queryFn();
      await cache.set(cacheKey, data, options?.ttl, options?.tags);

      return data;
    }
  });
}

// Usage
function ProductList() {
  const { data: products } = useCachedQuery(
    ['products'],
    () => fetchProducts(),
    {
      ttl: 10 * 60 * 1000, // 10 minutes
      tags: ['products']
    }
  );

  return <div>{/* Render products */}</div>;
}

// Invalidate cache when mutation succeeds
function useCreateProduct() {
  const cache = useCacheManager();

  return useMutation({
    mutationFn: createProduct,
    onSuccess: () => {
      cache.invalidateByTag('products');
    }
  });
}
```

---

## 17. Scalable Testing Architecture

Comprehensive testing utilities, factories, and patterns.

### Implementation

```typescript
// test/utils/renderWithProviders.tsx
export function renderWithProviders(
  ui: React.ReactElement,
  options?: {
    initialState?: Partial<AppState>;
    user?: User;
    featureFlags?: Record<string, boolean>;
  }
) {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false }
    }
  });

  const mockStore = createMockStore(options?.initialState);

  function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <Provider store={mockStore}>
        <QueryClientProvider client={queryClient}>
          <MemoryRouter>
            <AuthProvider initialUser={options?.user}>
              <FeatureFlagProvider initialFlags={options?.featureFlags}>
                {children}
              </FeatureFlagProvider>
            </AuthProvider>
          </MemoryRouter>
        </QueryClientProvider>
      </Provider>
    );
  }

  return {
    ...render(ui, { wrapper: Wrapper }),
    queryClient,
    store: mockStore
  };
}

// test/factories/userFactory.ts
export class UserFactory {
  private defaults: Partial<User> = {
    id: crypto.randomUUID(),
    email: 'test@example.com',
    name: 'Test User',
    role: 'user',
    createdAt: new Date()
  };

  build(overrides?: Partial<User>): User {
    return {
      ...this.defaults,
      ...overrides
    } as User;
  }

  buildMany(count: number, overrides?: Partial<User>): User[] {
    return Array.from({ length: count }, () => this.build(overrides));
  }

  admin(overrides?: Partial<User>): User {
    return this.build({ ...overrides, role: 'admin' });
  }

  withPosts(postCount: number): User & { posts: Post[] } {
    const user = this.build();
    const posts = new PostFactory().buildMany(postCount, { authorId: user.id });
    return { ...user, posts };
  }
}

// test/mocks/apiMocks.ts
export function setupApiMocks() {
  const server = setupServer();

  beforeAll(() => server.listen());
  afterEach(() => server.resetHandlers());
  afterAll(() => server.close());

  return {
    mockGetProducts: (products: Product[]) => {
      server.use(
        rest.get('/api/products', (req, res, ctx) => {
          return res(ctx.json(products));
        })
      );
    },

    mockCreateProduct: (product: Product) => {
      server.use(
        rest.post('/api/products', (req, res, ctx) => {
          return res(ctx.json(product));
        })
      );
    },

    mockError: (endpoint: string, status: number, message: string) => {
      server.use(
        rest.all(endpoint, (req, res, ctx) => {
          return res(ctx.status(status), ctx.json({ message }));
        })
      );
    }
  };
}

// test/custom-matchers.ts
expect.extend({
  toHaveBeenCalledWithUser(received: jest.Mock, user: User) {
    const pass = received.mock.calls.some(call =>
      call.some(arg => arg?.id === user.id)
    );

    return {
      pass,
      message: () =>
        pass
          ? `Expected mock not to have been called with user ${user.id}`
          : `Expected mock to have been called with user ${user.id}`
    };
  },

  toBeInLoadingState(received: HTMLElement) {
    const hasSpinner = received.querySelector('[data-testid="loading"]');
    const hasLoadingText = received.textContent?.includes('Loading');

    return {
      pass: Boolean(hasSpinner || hasLoadingText),
      message: () =>
        hasSpinner || hasLoadingText
          ? 'Expected element not to be in loading state'
          : 'Expected element to be in loading state'
    };
  }
});

// Example test
describe('ProductList', () => {
  const api = setupApiMocks();
  const factory = new UserFactory();

  it('should display products', async () => {
    const products = new ProductFactory().buildMany(3);
    api.mockGetProducts(products);

    const { getByText } = renderWithProviders(<ProductList />);

    await waitFor(() => {
      products.forEach(product => {
        expect(getByText(product.name)).toBeInTheDocument();
      });
    });
  });

  it('should handle errors', async () => {
    api.mockError('/api/products', 500, 'Server error');

    const { getByText } = renderWithProviders(<ProductList />);

    await waitFor(() => {
      expect(getByText(/error/i)).toBeInTheDocument();
    });
  });
});
```

---

This completes all 17 comprehensive frontend architecture examples, demonstrating production-ready patterns for modern web applications.
