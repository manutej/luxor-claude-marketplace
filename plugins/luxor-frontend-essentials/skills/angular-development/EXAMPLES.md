# Angular Development Examples

A comprehensive collection of real-world Angular examples demonstrating modern patterns, best practices, and common use cases.

## Table of Contents

1. [Component Examples](#component-examples)
2. [Service Examples](#service-examples)
3. [Routing Examples](#routing-examples)
4. [Forms Examples](#forms-examples)
5. [RxJS Examples](#rxjs-examples)
6. [Signals Examples](#signals-examples)
7. [Directives Examples](#directives-examples)
8. [Pipes Examples](#pipes-examples)
9. [HTTP Client Examples](#http-client-examples)
10. [State Management Examples](#state-management-examples)
11. [Performance Examples](#performance-examples)
12. [Testing Examples](#testing-examples)

---

## Component Examples

### Example 1: Basic Standalone Component with Signals

A simple counter component demonstrating signals and computed values.

```typescript
import { Component, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-counter',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="counter-container">
      <h2>Counter: {{ count() }}</h2>
      <p>Double: {{ doubleCount() }}</p>
      <p>Is Even: {{ isEven() ? 'Yes' : 'No' }}</p>

      <div class="button-group">
        <button (click)="increment()" class="btn btn-primary">+</button>
        <button (click)="decrement()" class="btn btn-secondary">-</button>
        <button (click)="reset()" class="btn btn-danger">Reset</button>
      </div>

      <div class="history">
        <h3>History:</h3>
        <ul>
          @for (entry of history(); track $index) {
            <li>{{ entry }}</li>
          }
        </ul>
      </div>
    </div>
  `,
  styles: [`
    .counter-container {
      padding: 20px;
      border: 2px solid #333;
      border-radius: 8px;
      max-width: 400px;
      margin: 20px auto;
    }
    .button-group {
      display: flex;
      gap: 10px;
      margin: 20px 0;
    }
    .btn {
      padding: 10px 20px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
    .btn-primary { background: #007bff; color: white; }
    .btn-secondary { background: #6c757d; color: white; }
    .btn-danger { background: #dc3545; color: white; }
  `]
})
export class CounterComponent {
  count = signal(0);
  history = signal<string[]>([]);

  doubleCount = computed(() => this.count() * 2);
  isEven = computed(() => this.count() % 2 === 0);

  increment() {
    this.count.update(n => n + 1);
    this.addToHistory(`Incremented to ${this.count()}`);
  }

  decrement() {
    this.count.update(n => n - 1);
    this.addToHistory(`Decremented to ${this.count()}`);
  }

  reset() {
    this.count.set(0);
    this.addToHistory('Reset to 0');
  }

  private addToHistory(message: string) {
    this.history.update(h => [...h, `${new Date().toLocaleTimeString()}: ${message}`]);
  }
}
```

### Example 2: Component with Input/Output and Model

Parent-child component communication with signal-based inputs and two-way binding.

```typescript
// Child Component
import { Component, input, output, model, computed } from '@angular/core';

export interface Task {
  id: number;
  title: string;
  completed: boolean;
  priority: 'low' | 'medium' | 'high';
}

@Component({
  selector: 'app-task-item',
  standalone: true,
  template: `
    <div class="task-item" [class.completed]="task().completed">
      <input
        type="checkbox"
        [checked]="task().completed"
        (change)="toggleComplete()"
      >
      <span class="task-title">{{ task().title }}</span>
      <span class="priority" [class]="'priority-' + task().priority">
        {{ task().priority }}
      </span>
      <button (click)="delete.emit(task().id)" class="btn-delete">
        Delete
      </button>
    </div>
  `,
  styles: [`
    .task-item {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 10px;
      border: 1px solid #ddd;
      margin: 5px 0;
    }
    .task-item.completed {
      opacity: 0.6;
      text-decoration: line-through;
    }
    .priority {
      padding: 2px 8px;
      border-radius: 4px;
      font-size: 12px;
    }
    .priority-low { background: #28a745; color: white; }
    .priority-medium { background: #ffc107; color: black; }
    .priority-high { background: #dc3545; color: white; }
  `]
})
export class TaskItemComponent {
  task = input.required<Task>();
  delete = output<number>();
  completed = model(false);

  toggleComplete() {
    this.completed.update(c => !c);
  }
}

// Parent Component
@Component({
  selector: 'app-task-list',
  standalone: true,
  imports: [CommonModule, TaskItemComponent],
  template: `
    <div class="task-list">
      <h2>Tasks ({{ activeCount() }} active, {{ completedCount() }} completed)</h2>

      @for (task of tasks(); track task.id) {
        <app-task-item
          [task]="task"
          [(completed)]="task.completed"
          (delete)="deleteTask($event)"
        />
      } @empty {
        <p>No tasks yet!</p>
      }

      <button (click)="addSampleTask()" class="btn-add">Add Sample Task</button>
    </div>
  `
})
export class TaskListComponent {
  tasks = signal<Task[]>([
    { id: 1, title: 'Learn Angular', completed: false, priority: 'high' },
    { id: 2, title: 'Build a project', completed: false, priority: 'medium' },
    { id: 3, title: 'Write tests', completed: true, priority: 'low' }
  ]);

  activeCount = computed(() =>
    this.tasks().filter(t => !t.completed).length
  );

  completedCount = computed(() =>
    this.tasks().filter(t => t.completed).length
  );

  deleteTask(id: number) {
    this.tasks.update(tasks => tasks.filter(t => t.id !== id));
  }

  addSampleTask() {
    const newTask: Task = {
      id: Date.now(),
      title: `New Task ${this.tasks().length + 1}`,
      completed: false,
      priority: 'medium'
    };
    this.tasks.update(tasks => [...tasks, newTask]);
  }
}
```

### Example 3: Component with Lifecycle Hooks

Comprehensive example showing all major lifecycle hooks.

```typescript
import {
  Component,
  OnInit,
  OnDestroy,
  AfterViewInit,
  AfterContentInit,
  OnChanges,
  SimpleChanges,
  input,
  signal,
  viewChild,
  ElementRef
} from '@angular/core';
import { interval, Subscription } from 'rxjs';

@Component({
  selector: 'app-lifecycle-demo',
  standalone: true,
  template: `
    <div class="lifecycle-demo">
      <h2>Lifecycle Demo: {{ name() }}</h2>
      <p>Timer: {{ timer() }}</p>
      <div #contentDiv>Content goes here</div>

      <div class="logs">
        <h3>Lifecycle Logs:</h3>
        @for (log of logs(); track $index) {
          <div class="log-entry">{{ log }}</div>
        }
      </div>
    </div>
  `,
  styles: [`
    .lifecycle-demo {
      padding: 20px;
      border: 2px solid #007bff;
      border-radius: 8px;
    }
    .logs {
      margin-top: 20px;
      max-height: 200px;
      overflow-y: auto;
      background: #f5f5f5;
      padding: 10px;
    }
    .log-entry {
      padding: 4px;
      border-bottom: 1px solid #ddd;
      font-size: 12px;
    }
  `]
})
export class LifecycleDemoComponent implements OnInit, OnDestroy, AfterViewInit, AfterContentInit, OnChanges {
  name = input.required<string>();

  timer = signal(0);
  logs = signal<string[]>([]);

  contentDiv = viewChild<ElementRef>('contentDiv');

  private timerSubscription?: Subscription;

  constructor() {
    this.addLog('Constructor called');
  }

  ngOnChanges(changes: SimpleChanges) {
    this.addLog(`ngOnChanges: ${JSON.stringify(changes)}`);
  }

  ngOnInit() {
    this.addLog('ngOnInit: Component initialized');

    // Start timer
    this.timerSubscription = interval(1000).subscribe(() => {
      this.timer.update(t => t + 1);
    });
  }

  ngAfterContentInit() {
    this.addLog('ngAfterContentInit: Content initialized');
  }

  ngAfterViewInit() {
    this.addLog('ngAfterViewInit: View initialized');
    const element = this.contentDiv();
    if (element) {
      this.addLog(`Content div found: ${element.nativeElement.textContent}`);
    }
  }

  ngOnDestroy() {
    this.addLog('ngOnDestroy: Component being destroyed');
    this.timerSubscription?.unsubscribe();
  }

  private addLog(message: string) {
    const timestamp = new Date().toLocaleTimeString();
    this.logs.update(logs => [...logs, `[${timestamp}] ${message}`]);
  }
}
```

---

## Service Examples

### Example 4: HTTP Service with CRUD Operations

Complete CRUD service with error handling and type safety.

```typescript
import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpErrorResponse, HttpHeaders } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError, retry, map } from 'rxjs/operators';

export interface User {
  id: number;
  name: string;
  email: string;
  role: 'admin' | 'user' | 'guest';
  createdAt: string;
}

export interface CreateUserDto {
  name: string;
  email: string;
  role: 'admin' | 'user' | 'guest';
}

export interface UpdateUserDto {
  name?: string;
  email?: string;
  role?: 'admin' | 'user' | 'guest';
}

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private http = inject(HttpClient);
  private apiUrl = 'https://api.example.com/users';

  private httpOptions = {
    headers: new HttpHeaders({
      'Content-Type': 'application/json'
    })
  };

  // GET all users
  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl).pipe(
      retry(3),
      catchError(this.handleError)
    );
  }

  // GET user by ID
  getUser(id: number): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/${id}`).pipe(
      catchError(this.handleError)
    );
  }

  // POST create user
  createUser(user: CreateUserDto): Observable<User> {
    return this.http.post<User>(this.apiUrl, user, this.httpOptions).pipe(
      catchError(this.handleError)
    );
  }

  // PUT update user (full update)
  updateUser(id: number, user: User): Observable<User> {
    return this.http.put<User>(`${this.apiUrl}/${id}`, user, this.httpOptions).pipe(
      catchError(this.handleError)
    );
  }

  // PATCH update user (partial update)
  patchUser(id: number, updates: UpdateUserDto): Observable<User> {
    return this.http.patch<User>(`${this.apiUrl}/${id}`, updates, this.httpOptions).pipe(
      catchError(this.handleError)
    );
  }

  // DELETE user
  deleteUser(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`).pipe(
      catchError(this.handleError)
    );
  }

  // Search users
  searchUsers(query: string): Observable<User[]> {
    return this.http.get<User[]>(`${this.apiUrl}?q=${encodeURIComponent(query)}`).pipe(
      retry(2),
      catchError(this.handleError)
    );
  }

  // Get users by role
  getUsersByRole(role: string): Observable<User[]> {
    return this.getUsers().pipe(
      map(users => users.filter(user => user.role === role))
    );
  }

  // Private error handler
  private handleError(error: HttpErrorResponse): Observable<never> {
    let errorMessage = 'An unknown error occurred';

    if (error.error instanceof ErrorEvent) {
      // Client-side error
      errorMessage = `Client Error: ${error.error.message}`;
    } else {
      // Server-side error
      errorMessage = `Server Error Code: ${error.status}\nMessage: ${error.message}`;

      switch (error.status) {
        case 400:
          errorMessage = 'Bad Request: Invalid data provided';
          break;
        case 401:
          errorMessage = 'Unauthorized: Please log in';
          break;
        case 403:
          errorMessage = 'Forbidden: You do not have permission';
          break;
        case 404:
          errorMessage = 'Not Found: Resource does not exist';
          break;
        case 500:
          errorMessage = 'Internal Server Error: Please try again later';
          break;
      }
    }

    console.error(errorMessage);
    return throwError(() => new Error(errorMessage));
  }
}
```

### Example 5: Authentication Service with Token Management

Complete authentication service with JWT token handling.

```typescript
import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, BehaviorSubject, tap, catchError, of } from 'rxjs';

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData {
  name: string;
  email: string;
  password: string;
}

export interface AuthResponse {
  user: User;
  token: string;
  refreshToken: string;
}

export interface User {
  id: number;
  name: string;
  email: string;
  role: string;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private http = inject(HttpClient);
  private router = inject(Router);
  private apiUrl = 'https://api.example.com/auth';

  // Signals for reactive state
  isAuthenticated = signal(false);
  currentUser = signal<User | null>(null);

  // Observable for legacy compatibility
  private isAuthenticatedSubject = new BehaviorSubject<boolean>(false);
  isAuthenticated$ = this.isAuthenticatedSubject.asObservable();

  constructor() {
    this.checkAuthentication();
  }

  // Check if user is authenticated on app load
  private checkAuthentication() {
    const token = this.getToken();
    if (token) {
      this.validateToken(token).subscribe({
        next: (valid) => {
          if (valid) {
            this.isAuthenticated.set(true);
            this.isAuthenticatedSubject.next(true);
            this.loadCurrentUser();
          } else {
            this.logout();
          }
        },
        error: () => this.logout()
      });
    }
  }

  // Login
  login(credentials: LoginCredentials): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.apiUrl}/login`, credentials).pipe(
      tap(response => {
        this.handleAuthSuccess(response);
      }),
      catchError(error => {
        console.error('Login failed:', error);
        throw error;
      })
    );
  }

  // Register
  register(data: RegisterData): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.apiUrl}/register`, data).pipe(
      tap(response => {
        this.handleAuthSuccess(response);
      }),
      catchError(error => {
        console.error('Registration failed:', error);
        throw error;
      })
    );
  }

  // Logout
  logout() {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    localStorage.removeItem('user');
    this.isAuthenticated.set(false);
    this.currentUser.set(null);
    this.isAuthenticatedSubject.next(false);
    this.router.navigate(['/login']);
  }

  // Refresh token
  refreshToken(): Observable<AuthResponse> {
    const refreshToken = this.getRefreshToken();
    return this.http.post<AuthResponse>(`${this.apiUrl}/refresh`, { refreshToken }).pipe(
      tap(response => {
        this.setToken(response.token);
        this.setRefreshToken(response.refreshToken);
      })
    );
  }

  // Get current user
  getCurrentUser(): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/me`).pipe(
      tap(user => {
        this.currentUser.set(user);
        this.saveUser(user);
      })
    );
  }

  // Load current user from storage
  private loadCurrentUser() {
    const userJson = localStorage.getItem('user');
    if (userJson) {
      const user = JSON.parse(userJson) as User;
      this.currentUser.set(user);
    } else {
      this.getCurrentUser().subscribe();
    }
  }

  // Validate token
  private validateToken(token: string): Observable<boolean> {
    return this.http.post<{ valid: boolean }>(`${this.apiUrl}/validate`, { token }).pipe(
      tap(response => response.valid),
      catchError(() => of({ valid: false }))
    ).pipe(
      tap(response => response.valid)
    );
  }

  // Handle successful authentication
  private handleAuthSuccess(response: AuthResponse) {
    this.setToken(response.token);
    this.setRefreshToken(response.refreshToken);
    this.saveUser(response.user);
    this.currentUser.set(response.user);
    this.isAuthenticated.set(true);
    this.isAuthenticatedSubject.next(true);
  }

  // Token management
  getToken(): string | null {
    return localStorage.getItem('access_token');
  }

  private setToken(token: string) {
    localStorage.setItem('access_token', token);
  }

  private getRefreshToken(): string | null {
    return localStorage.getItem('refresh_token');
  }

  private setRefreshToken(token: string) {
    localStorage.setItem('refresh_token', token);
  }

  private saveUser(user: User) {
    localStorage.setItem('user', JSON.stringify(user));
  }

  // Check permissions
  hasRole(role: string): boolean {
    const user = this.currentUser();
    return user?.role === role;
  }

  hasAnyRole(roles: string[]): boolean {
    const user = this.currentUser();
    return user ? roles.includes(user.role) : false;
  }
}
```

---

## Routing Examples

### Example 6: Complete Routing Configuration with Guards

Advanced routing setup with lazy loading and multiple guard types.

```typescript
// app.routes.ts
import { Routes } from '@angular/router';
import { inject } from '@angular/core';
import { AuthService } from './services/auth.service';
import { Router } from '@angular/router';

// Functional guard for authentication
export const authGuard = () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isAuthenticated()) {
    return true;
  }

  return router.createUrlTree(['/login']);
};

// Functional guard for admin role
export const adminGuard = () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.hasRole('admin')) {
    return true;
  }

  return router.createUrlTree(['/unauthorized']);
};

// Functional guard to prevent authenticated users from accessing login
export const guestGuard = () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (!authService.isAuthenticated()) {
    return true;
  }

  return router.createUrlTree(['/dashboard']);
};

export const routes: Routes = [
  {
    path: '',
    redirectTo: '/home',
    pathMatch: 'full'
  },
  {
    path: 'home',
    loadComponent: () => import('./pages/home/home.component').then(m => m.HomeComponent),
    title: 'Home'
  },
  {
    path: 'login',
    loadComponent: () => import('./pages/auth/login.component').then(m => m.LoginComponent),
    canActivate: [guestGuard],
    title: 'Login'
  },
  {
    path: 'register',
    loadComponent: () => import('./pages/auth/register.component').then(m => m.RegisterComponent),
    canActivate: [guestGuard],
    title: 'Register'
  },
  {
    path: 'dashboard',
    loadComponent: () => import('./pages/dashboard/dashboard.component').then(m => m.DashboardComponent),
    canActivate: [authGuard],
    title: 'Dashboard'
  },
  {
    path: 'profile',
    loadComponent: () => import('./pages/profile/profile.component').then(m => m.ProfileComponent),
    canActivate: [authGuard],
    title: 'Profile'
  },
  {
    path: 'admin',
    canActivate: [authGuard, adminGuard],
    children: [
      {
        path: '',
        loadComponent: () => import('./pages/admin/admin.component').then(m => m.AdminComponent),
        title: 'Admin Dashboard'
      },
      {
        path: 'users',
        loadComponent: () => import('./pages/admin/users/users.component').then(m => m.UsersComponent),
        title: 'Manage Users'
      },
      {
        path: 'settings',
        loadComponent: () => import('./pages/admin/settings/settings.component').then(m => m.SettingsComponent),
        title: 'Admin Settings'
      }
    ]
  },
  {
    path: 'products',
    children: [
      {
        path: '',
        loadComponent: () => import('./pages/products/product-list.component').then(m => m.ProductListComponent),
        title: 'Products'
      },
      {
        path: ':id',
        loadComponent: () => import('./pages/products/product-detail.component').then(m => m.ProductDetailComponent),
        title: 'Product Details'
      },
      {
        path: ':id/edit',
        loadComponent: () => import('./pages/products/product-edit.component').then(m => m.ProductEditComponent),
        canActivate: [authGuard],
        title: 'Edit Product'
      }
    ]
  },
  {
    path: 'unauthorized',
    loadComponent: () => import('./pages/error/unauthorized.component').then(m => m.UnauthorizedComponent),
    title: 'Unauthorized'
  },
  {
    path: '404',
    loadComponent: () => import('./pages/error/not-found.component').then(m => m.NotFoundComponent),
    title: 'Page Not Found'
  },
  {
    path: '**',
    redirectTo: '/404'
  }
];
```

### Example 7: Route Parameters and Query Params

Component demonstrating route parameters and query parameter handling.

```typescript
import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';
import { switchMap, map } from 'rxjs/operators';
import { ProductService, Product } from '../../services/product.service';

@Component({
  selector: 'app-product-detail',
  standalone: true,
  imports: [CommonModule, RouterLink],
  template: `
    <div class="product-detail">
      @if (loading()) {
        <p>Loading product...</p>
      } @else if (error()) {
        <div class="error">{{ error() }}</div>
      } @else if (product(); as product) {
        <div class="product-card">
          <h1>{{ product.name }}</h1>
          <p class="price">{{ product.price | currency }}</p>
          <p class="description">{{ product.description }}</p>
          <p class="category">Category: {{ product.category }}</p>

          <div class="actions">
            <button (click)="goToEdit()">Edit</button>
            <button (click)="goBack()">Back to List</button>
            <button (click)="viewRelated()">View Related Products</button>
          </div>

          @if (showRelated()) {
            <div class="related-products">
              <h3>Related Products</h3>
              @for (related of relatedProducts(); track related.id) {
                <a [routerLink]="['/products', related.id]">
                  {{ related.name }}
                </a>
              }
            </div>
          }
        </div>
      }
    </div>
  `,
  styles: [`
    .product-detail {
      max-width: 800px;
      margin: 20px auto;
      padding: 20px;
    }
    .product-card {
      border: 1px solid #ddd;
      border-radius: 8px;
      padding: 20px;
    }
    .price {
      font-size: 24px;
      font-weight: bold;
      color: #28a745;
    }
    .actions {
      display: flex;
      gap: 10px;
      margin: 20px 0;
    }
    .related-products {
      margin-top: 20px;
      padding-top: 20px;
      border-top: 1px solid #ddd;
    }
  `]
})
export class ProductDetailComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private productService = inject(ProductService);

  product = signal<Product | null>(null);
  relatedProducts = signal<Product[]>([]);
  loading = signal(false);
  error = signal('');
  showRelated = signal(false);

  ngOnInit() {
    // Get product ID from route params and load product
    this.route.paramMap.pipe(
      switchMap(params => {
        const id = Number(params.get('id'));
        this.loading.set(true);
        return this.productService.getProduct(id);
      })
    ).subscribe({
      next: (product) => {
        this.product.set(product);
        this.loading.set(false);

        // Check query params for showRelated
        const queryParams = this.route.snapshot.queryParams;
        if (queryParams['showRelated'] === 'true') {
          this.viewRelated();
        }
      },
      error: (err) => {
        this.error.set('Failed to load product');
        this.loading.set(false);
        console.error(err);
      }
    });
  }

  goToEdit() {
    const product = this.product();
    if (product) {
      this.router.navigate(['/products', product.id, 'edit']);
    }
  }

  goBack() {
    // Navigate back with query params preserved
    const queryParams = this.route.snapshot.queryParams;
    this.router.navigate(['/products'], { queryParams });
  }

  viewRelated() {
    const product = this.product();
    if (product) {
      this.productService.getProductsByCategory(product.category).subscribe(products => {
        this.relatedProducts.set(products.filter(p => p.id !== product.id));
        this.showRelated.set(true);

        // Update URL with query param
        this.router.navigate([], {
          relativeTo: this.route,
          queryParams: { showRelated: 'true' },
          queryParamsHandling: 'merge'
        });
      });
    }
  }
}
```

---

## Forms Examples

### Example 8: Complex Reactive Form with Nested FormGroups

Multi-step form with validation and dynamic form arrays.

```typescript
import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators, FormArray, FormGroup } from '@angular/forms';

interface Address {
  street: string;
  city: string;
  state: string;
  zipCode: string;
}

interface PhoneNumber {
  type: 'home' | 'work' | 'mobile';
  number: string;
}

interface UserProfile {
  personalInfo: {
    firstName: string;
    lastName: string;
    email: string;
    dateOfBirth: string;
  };
  address: Address;
  phoneNumbers: PhoneNumber[];
  preferences: {
    newsletter: boolean;
    notifications: boolean;
    theme: 'light' | 'dark';
  };
}

@Component({
  selector: 'app-user-profile-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <form [formGroup]="profileForm" (ngSubmit)="onSubmit()" class="profile-form">
      <h2>User Profile</h2>

      <!-- Personal Information -->
      <div formGroupName="personalInfo" class="form-section">
        <h3>Personal Information</h3>

        <div class="form-group">
          <label for="firstName">First Name:</label>
          <input id="firstName" type="text" formControlName="firstName">
          @if (personalInfo.get('firstName')?.invalid && personalInfo.get('firstName')?.touched) {
            <div class="error">First name is required (min 2 characters)</div>
          }
        </div>

        <div class="form-group">
          <label for="lastName">Last Name:</label>
          <input id="lastName" type="text" formControlName="lastName">
          @if (personalInfo.get('lastName')?.invalid && personalInfo.get('lastName')?.touched) {
            <div class="error">Last name is required (min 2 characters)</div>
          }
        </div>

        <div class="form-group">
          <label for="email">Email:</label>
          <input id="email" type="email" formControlName="email">
          @if (personalInfo.get('email')?.invalid && personalInfo.get('email')?.touched) {
            <div class="error">Valid email is required</div>
          }
        </div>

        <div class="form-group">
          <label for="dateOfBirth">Date of Birth:</label>
          <input id="dateOfBirth" type="date" formControlName="dateOfBirth">
        </div>
      </div>

      <!-- Address -->
      <div formGroupName="address" class="form-section">
        <h3>Address</h3>

        <div class="form-group">
          <label for="street">Street:</label>
          <input id="street" type="text" formControlName="street">
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="city">City:</label>
            <input id="city" type="text" formControlName="city">
          </div>

          <div class="form-group">
            <label for="state">State:</label>
            <input id="state" type="text" formControlName="state">
          </div>

          <div class="form-group">
            <label for="zipCode">Zip Code:</label>
            <input id="zipCode" type="text" formControlName="zipCode">
            @if (address.get('zipCode')?.invalid && address.get('zipCode')?.touched) {
              <div class="error">Valid zip code required (5 digits)</div>
            }
          </div>
        </div>
      </div>

      <!-- Phone Numbers (FormArray) -->
      <div class="form-section">
        <h3>Phone Numbers</h3>
        <div formArrayName="phoneNumbers">
          @for (phone of phoneNumbers.controls; track $index; let i = $index) {
            <div [formGroupName]="i" class="phone-entry">
              <select formControlName="type">
                <option value="home">Home</option>
                <option value="work">Work</option>
                <option value="mobile">Mobile</option>
              </select>

              <input type="tel" formControlName="number" placeholder="Phone number">

              <button type="button" (click)="removePhone(i)" class="btn-remove">
                Remove
              </button>
            </div>
          }
        </div>

        <button type="button" (click)="addPhone()" class="btn-add">
          Add Phone Number
        </button>
      </div>

      <!-- Preferences -->
      <div formGroupName="preferences" class="form-section">
        <h3>Preferences</h3>

        <div class="form-group">
          <label>
            <input type="checkbox" formControlName="newsletter">
            Subscribe to newsletter
          </label>
        </div>

        <div class="form-group">
          <label>
            <input type="checkbox" formControlName="notifications">
            Enable notifications
          </label>
        </div>

        <div class="form-group">
          <label for="theme">Theme:</label>
          <select id="theme" formControlName="theme">
            <option value="light">Light</option>
            <option value="dark">Dark</option>
          </select>
        </div>
      </div>

      <!-- Form Actions -->
      <div class="form-actions">
        <button type="submit" [disabled]="profileForm.invalid" class="btn-submit">
          Save Profile
        </button>
        <button type="button" (click)="resetForm()" class="btn-reset">
          Reset
        </button>
        <button type="button" (click)="fillSampleData()" class="btn-sample">
          Fill Sample Data
        </button>
      </div>

      <!-- Form Status -->
      <div class="form-status">
        <p>Form Valid: {{ profileForm.valid }}</p>
        <p>Form Dirty: {{ profileForm.dirty }}</p>
        <p>Form Touched: {{ profileForm.touched }}</p>
      </div>

      <!-- Form Value Preview -->
      @if (showPreview()) {
        <div class="form-preview">
          <h3>Form Value:</h3>
          <pre>{{ profileForm.value | json }}</pre>
        </div>
      }
    </form>
  `,
  styles: [`
    .profile-form {
      max-width: 800px;
      margin: 20px auto;
      padding: 20px;
      border: 1px solid #ddd;
      border-radius: 8px;
    }
    .form-section {
      margin: 20px 0;
      padding: 20px;
      background: #f9f9f9;
      border-radius: 4px;
    }
    .form-group {
      margin: 10px 0;
    }
    .form-group label {
      display: block;
      margin-bottom: 5px;
      font-weight: bold;
    }
    .form-group input,
    .form-group select {
      width: 100%;
      padding: 8px;
      border: 1px solid #ddd;
      border-radius: 4px;
    }
    .form-group input.ng-invalid.ng-touched {
      border-color: #dc3545;
    }
    .form-row {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 10px;
    }
    .phone-entry {
      display: flex;
      gap: 10px;
      margin: 10px 0;
    }
    .error {
      color: #dc3545;
      font-size: 12px;
      margin-top: 4px;
    }
    .form-actions {
      display: flex;
      gap: 10px;
      margin: 20px 0;
    }
    .btn-submit {
      background: #28a745;
      color: white;
      padding: 10px 20px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
    .btn-submit:disabled {
      background: #6c757d;
      cursor: not-allowed;
    }
    .form-preview {
      margin-top: 20px;
      padding: 20px;
      background: #e9ecef;
      border-radius: 4px;
    }
    .form-preview pre {
      background: white;
      padding: 10px;
      border-radius: 4px;
      overflow-x: auto;
    }
  `]
})
export class UserProfileFormComponent {
  private fb = inject(FormBuilder);

  showPreview = signal(true);

  profileForm = this.fb.group({
    personalInfo: this.fb.group({
      firstName: ['', [Validators.required, Validators.minLength(2)]],
      lastName: ['', [Validators.required, Validators.minLength(2)]],
      email: ['', [Validators.required, Validators.email]],
      dateOfBirth: ['']
    }),
    address: this.fb.group({
      street: [''],
      city: [''],
      state: [''],
      zipCode: ['', [Validators.pattern(/^\d{5}$/)]]
    }),
    phoneNumbers: this.fb.array([]),
    preferences: this.fb.group({
      newsletter: [false],
      notifications: [true],
      theme: ['light' as 'light' | 'dark']
    })
  });

  get personalInfo() {
    return this.profileForm.get('personalInfo') as FormGroup;
  }

  get address() {
    return this.profileForm.get('address') as FormGroup;
  }

  get phoneNumbers() {
    return this.profileForm.get('phoneNumbers') as FormArray;
  }

  get preferences() {
    return this.profileForm.get('preferences') as FormGroup;
  }

  addPhone() {
    const phoneForm = this.fb.group({
      type: ['mobile' as 'home' | 'work' | 'mobile'],
      number: ['', [Validators.required, Validators.pattern(/^\d{10}$/)]]
    });
    this.phoneNumbers.push(phoneForm);
  }

  removePhone(index: number) {
    this.phoneNumbers.removeAt(index);
  }

  onSubmit() {
    if (this.profileForm.valid) {
      const formValue = this.profileForm.value as UserProfile;
      console.log('Form submitted:', formValue);
      // Handle form submission
    } else {
      console.log('Form is invalid');
      this.markFormGroupTouched(this.profileForm);
    }
  }

  resetForm() {
    this.profileForm.reset({
      preferences: {
        newsletter: false,
        notifications: true,
        theme: 'light'
      }
    });
    this.phoneNumbers.clear();
  }

  fillSampleData() {
    this.profileForm.patchValue({
      personalInfo: {
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        dateOfBirth: '1990-01-15'
      },
      address: {
        street: '123 Main St',
        city: 'New York',
        state: 'NY',
        zipCode: '10001'
      },
      preferences: {
        newsletter: true,
        notifications: true,
        theme: 'dark'
      }
    });

    // Add sample phone numbers
    this.addPhone();
    this.phoneNumbers.at(0).patchValue({
      type: 'mobile',
      number: '5551234567'
    });
  }

  private markFormGroupTouched(formGroup: FormGroup) {
    Object.keys(formGroup.controls).forEach(key => {
      const control = formGroup.get(key);
      control?.markAsTouched();

      if (control instanceof FormGroup) {
        this.markFormGroupTouched(control);
      }
    });
  }
}
```

---

## Signals Examples

### Example 9: Shopping Cart with Signals

Complete shopping cart implementation using signals for state management.

```typescript
import { Injectable, signal, computed, effect } from '@angular/core';

export interface CartItem {
  id: number;
  productId: number;
  name: string;
  price: number;
  quantity: number;
  imageUrl?: string;
}

@Injectable({
  providedIn: 'root'
})
export class CartService {
  // Private writable signal
  private items = signal<CartItem[]>([]);

  // Public readonly signal
  readonly cartItems = this.items.asReadonly();

  // Computed signals
  readonly itemCount = computed(() =>
    this.items().reduce((sum, item) => sum + item.quantity, 0)
  );

  readonly subtotal = computed(() =>
    this.items().reduce((sum, item) => sum + (item.price * item.quantity), 0)
  );

  readonly tax = computed(() => this.subtotal() * 0.08);

  readonly total = computed(() => this.subtotal() + this.tax());

  readonly isEmpty = computed(() => this.items().length === 0);

  readonly uniqueItemCount = computed(() => this.items().length);

  constructor() {
    // Load cart from localStorage
    this.loadCart();

    // Save cart whenever it changes
    effect(() => {
      const items = this.items();
      this.saveCart(items);
      console.log('Cart updated:', items);
    });
  }

  addItem(product: Omit<CartItem, 'quantity'>) {
    this.items.update(currentItems => {
      const existingItem = currentItems.find(item => item.productId === product.productId);

      if (existingItem) {
        // Increase quantity if item already exists
        return currentItems.map(item =>
          item.productId === product.productId
            ? { ...item, quantity: item.quantity + 1 }
            : item
        );
      } else {
        // Add new item with quantity 1
        return [...currentItems, { ...product, quantity: 1 }];
      }
    });
  }

  removeItem(id: number) {
    this.items.update(currentItems =>
      currentItems.filter(item => item.id !== id)
    );
  }

  updateQuantity(id: number, quantity: number) {
    if (quantity <= 0) {
      this.removeItem(id);
      return;
    }

    this.items.update(currentItems =>
      currentItems.map(item =>
        item.id === id ? { ...item, quantity } : item
      )
    );
  }

  incrementQuantity(id: number) {
    this.items.update(currentItems =>
      currentItems.map(item =>
        item.id === id ? { ...item, quantity: item.quantity + 1 } : item
      )
    );
  }

  decrementQuantity(id: number) {
    this.items.update(currentItems =>
      currentItems.map(item =>
        item.id === id ? { ...item, quantity: Math.max(1, item.quantity - 1) } : item
      )
    );
  }

  clear() {
    this.items.set([]);
  }

  private saveCart(items: CartItem[]) {
    localStorage.setItem('cart', JSON.stringify(items));
  }

  private loadCart() {
    const cartJson = localStorage.getItem('cart');
    if (cartJson) {
      try {
        const items = JSON.parse(cartJson) as CartItem[];
        this.items.set(items);
      } catch (error) {
        console.error('Failed to load cart:', error);
      }
    }
  }
}

// Cart Component
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-shopping-cart',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="shopping-cart">
      <h2>Shopping Cart</h2>

      @if (cart.isEmpty()) {
        <div class="empty-cart">
          <p>Your cart is empty</p>
          <button (click)="addSampleItems()">Add Sample Items</button>
        </div>
      } @else {
        <div class="cart-items">
          @for (item of cart.cartItems(); track item.id) {
            <div class="cart-item">
              <div class="item-info">
                <h3>{{ item.name }}</h3>
                <p class="price">{{ item.price | currency }}</p>
              </div>

              <div class="quantity-controls">
                <button (click)="cart.decrementQuantity(item.id)">-</button>
                <span class="quantity">{{ item.quantity }}</span>
                <button (click)="cart.incrementQuantity(item.id)">+</button>
              </div>

              <div class="item-total">
                {{ item.price * item.quantity | currency }}
              </div>

              <button (click)="cart.removeItem(item.id)" class="btn-remove">
                Remove
              </button>
            </div>
          }
        </div>

        <div class="cart-summary">
          <div class="summary-row">
            <span>Items ({{ cart.itemCount() }}):</span>
            <span>{{ cart.subtotal() | currency }}</span>
          </div>
          <div class="summary-row">
            <span>Tax (8%):</span>
            <span>{{ cart.tax() | currency }}</span>
          </div>
          <div class="summary-row total">
            <span>Total:</span>
            <span>{{ cart.total() | currency }}</span>
          </div>

          <button (click)="checkout()" class="btn-checkout">
            Proceed to Checkout
          </button>
          <button (click)="cart.clear()" class="btn-clear">
            Clear Cart
          </button>
        </div>
      }
    </div>
  `,
  styles: [`
    .shopping-cart {
      max-width: 800px;
      margin: 20px auto;
      padding: 20px;
    }
    .empty-cart {
      text-align: center;
      padding: 40px;
      background: #f9f9f9;
      border-radius: 8px;
    }
    .cart-items {
      margin: 20px 0;
    }
    .cart-item {
      display: flex;
      align-items: center;
      gap: 20px;
      padding: 15px;
      border: 1px solid #ddd;
      border-radius: 4px;
      margin: 10px 0;
    }
    .item-info {
      flex: 1;
    }
    .quantity-controls {
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .quantity-controls button {
      width: 30px;
      height: 30px;
      border: 1px solid #ddd;
      background: white;
      cursor: pointer;
    }
    .cart-summary {
      border-top: 2px solid #ddd;
      padding-top: 20px;
      margin-top: 20px;
    }
    .summary-row {
      display: flex;
      justify-content: space-between;
      margin: 10px 0;
    }
    .summary-row.total {
      font-size: 20px;
      font-weight: bold;
      margin-top: 15px;
      padding-top: 15px;
      border-top: 1px solid #ddd;
    }
    .btn-checkout {
      width: 100%;
      padding: 15px;
      background: #28a745;
      color: white;
      border: none;
      border-radius: 4px;
      font-size: 16px;
      cursor: pointer;
      margin-top: 15px;
    }
    .btn-clear {
      width: 100%;
      padding: 10px;
      background: #dc3545;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      margin-top: 10px;
    }
  `]
})
export class ShoppingCartComponent {
  cart = inject(CartService);

  addSampleItems() {
    this.cart.addItem({
      id: 1,
      productId: 101,
      name: 'Angular Book',
      price: 39.99
    });

    this.cart.addItem({
      id: 2,
      productId: 102,
      name: 'TypeScript Guide',
      price: 29.99
    });

    this.cart.addItem({
      id: 3,
      productId: 103,
      name: 'RxJS Mastery',
      price: 34.99
    });
  }

  checkout() {
    console.log('Proceeding to checkout with:', {
      items: this.cart.cartItems(),
      total: this.cart.total()
    });
  }
}
```

---

## RxJS Examples

### Example 10: Advanced RxJS Patterns - Real-time Search

Comprehensive search implementation with debouncing, caching, and error handling.

```typescript
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import {
  Observable,
  Subject,
  BehaviorSubject,
  merge,
  of,
  throwError,
  timer
} from 'rxjs';
import {
  debounceTime,
  distinctUntilChanged,
  switchMap,
  map,
  catchError,
  retry,
  shareReplay,
  tap,
  filter,
  take
} from 'rxjs/operators';

export interface SearchResult {
  id: number;
  title: string;
  description: string;
  category: string;
}

@Injectable({
  providedIn: 'root'
})
export class SearchService {
  private http = inject(HttpClient);
  private apiUrl = 'https://api.example.com/search';

  // Search query subject
  private searchQuerySubject = new Subject<string>();

  // Loading state
  private loadingSubject = new BehaviorSubject<boolean>(false);
  readonly loading$ = this.loadingSubject.asObservable();

  // Error state
  private errorSubject = new BehaviorSubject<string | null>(null);
  readonly error$ = this.errorSubject.asObservable();

  // Cache for search results
  private cache = new Map<string, Observable<SearchResult[]>>();
  private cacheTimeout = 5 * 60 * 1000; // 5 minutes

  // Search results observable
  readonly searchResults$: Observable<SearchResult[]> = this.searchQuerySubject.pipe(
    // Debounce to avoid excessive API calls
    debounceTime(300),
    // Only search if query changed
    distinctUntilChanged(),
    // Filter out empty queries
    filter(query => query.trim().length > 0),
    // Set loading state
    tap(() => {
      this.loadingSubject.next(true);
      this.errorSubject.next(null);
    }),
    // Switch to new search, canceling previous
    switchMap(query => this.searchWithCache(query)),
    // Clear loading state
    tap(() => this.loadingSubject.next(false)),
    // Share the same observable among multiple subscribers
    shareReplay(1)
  );

  search(query: string) {
    this.searchQuerySubject.next(query);
  }

  private searchWithCache(query: string): Observable<SearchResult[]> {
    // Check cache first
    const cached = this.cache.get(query);
    if (cached) {
      console.log('Returning cached results for:', query);
      return cached;
    }

    // Perform actual search
    const search$ = this.performSearch(query).pipe(
      retry(2),
      catchError(error => {
        console.error('Search failed:', error);
        this.errorSubject.next('Search failed. Please try again.');
        return of([]);
      }),
      shareReplay(1)
    );

    // Store in cache
    this.cache.set(query, search$);

    // Clear from cache after timeout
    timer(this.cacheTimeout).pipe(take(1)).subscribe(() => {
      this.cache.delete(query);
    });

    return search$;
  }

  private performSearch(query: string): Observable<SearchResult[]> {
    return this.http.get<SearchResult[]>(`${this.apiUrl}?q=${encodeURIComponent(query)}`);
  }

  clearCache() {
    this.cache.clear();
  }
}

// Search Component
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-search',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="search-container">
      <div class="search-box">
        <input
          type="text"
          [(ngModel)]="searchQuery"
          (input)="onSearchChange()"
          placeholder="Search..."
          class="search-input"
        >
        @if (searchService.loading$ | async) {
          <span class="loading-spinner">Loading...</span>
        }
      </div>

      @if (searchService.error$ | async; as error) {
        <div class="error-message">{{ error }}</div>
      }

      <div class="search-results">
        @for (result of searchService.searchResults$ | async; track result.id) {
          <div class="result-item">
            <h3>{{ result.title }}</h3>
            <p>{{ result.description }}</p>
            <span class="category">{{ result.category }}</span>
          </div>
        } @empty {
          @if (searchQuery && !(searchService.loading$ | async)) {
            <p class="no-results">No results found</p>
          }
        }
      </div>
    </div>
  `,
  styles: [`
    .search-container {
      max-width: 600px;
      margin: 20px auto;
      padding: 20px;
    }
    .search-box {
      position: relative;
      margin-bottom: 20px;
    }
    .search-input {
      width: 100%;
      padding: 12px;
      font-size: 16px;
      border: 2px solid #ddd;
      border-radius: 8px;
    }
    .loading-spinner {
      position: absolute;
      right: 12px;
      top: 12px;
      color: #007bff;
    }
    .result-item {
      padding: 15px;
      border: 1px solid #ddd;
      border-radius: 4px;
      margin: 10px 0;
    }
    .result-item h3 {
      margin: 0 0 8px 0;
    }
    .category {
      display: inline-block;
      padding: 4px 8px;
      background: #007bff;
      color: white;
      border-radius: 4px;
      font-size: 12px;
    }
  `]
})
export class SearchComponent {
  searchService = inject(SearchService);
  searchQuery = '';

  onSearchChange() {
    this.searchService.search(this.searchQuery);
  }
}
```

---

## Directives Examples

### Example 11: Custom Tooltip Directive

Advanced attribute directive with dynamic positioning and styling.

```typescript
import {
  Directive,
  ElementRef,
  HostListener,
  Input,
  Renderer2,
  inject,
  OnDestroy
} from '@angular/core';

@Directive({
  selector: '[appTooltip]',
  standalone: true
})
export class TooltipDirective implements OnDestroy {
  private el = inject(ElementRef);
  private renderer = inject(Renderer2);

  @Input() appTooltip = '';
  @Input() tooltipPosition: 'top' | 'bottom' | 'left' | 'right' = 'top';
  @Input() tooltipDelay = 300;

  private tooltipElement: HTMLElement | null = null;
  private showTimeout?: number;

  @HostListener('mouseenter') onMouseEnter() {
    this.showTimeout = window.setTimeout(() => {
      this.show();
    }, this.tooltipDelay);
  }

  @HostListener('mouseleave') onMouseLeave() {
    if (this.showTimeout) {
      clearTimeout(this.showTimeout);
    }
    this.hide();
  }

  private show() {
    if (!this.appTooltip || this.tooltipElement) return;

    // Create tooltip element
    this.tooltipElement = this.renderer.createElement('div');
    this.renderer.appendChild(
      this.tooltipElement,
      this.renderer.createText(this.appTooltip)
    );

    // Style tooltip
    this.renderer.addClass(this.tooltipElement, 'custom-tooltip');
    this.renderer.setStyle(this.tooltipElement, 'position', 'absolute');
    this.renderer.setStyle(this.tooltipElement, 'background', '#333');
    this.renderer.setStyle(this.tooltipElement, 'color', 'white');
    this.renderer.setStyle(this.tooltipElement, 'padding', '8px 12px');
    this.renderer.setStyle(this.tooltipElement, 'border-radius', '4px');
    this.renderer.setStyle(this.tooltipElement, 'font-size', '14px');
    this.renderer.setStyle(this.tooltipElement, 'z-index', '1000');
    this.renderer.setStyle(this.tooltipElement, 'white-space', 'nowrap');

    // Append to body
    this.renderer.appendChild(document.body, this.tooltipElement);

    // Position tooltip
    this.positionTooltip();
  }

  private positionTooltip() {
    if (!this.tooltipElement) return;

    const hostPos = this.el.nativeElement.getBoundingClientRect();
    const tooltipPos = this.tooltipElement.getBoundingClientRect();
    const scrollPos = window.pageYOffset || document.documentElement.scrollTop;
    const scrollPosX = window.pageXOffset || document.documentElement.scrollLeft;

    let top = 0;
    let left = 0;

    switch (this.tooltipPosition) {
      case 'top':
        top = hostPos.top + scrollPos - tooltipPos.height - 8;
        left = hostPos.left + scrollPosX + (hostPos.width - tooltipPos.width) / 2;
        break;
      case 'bottom':
        top = hostPos.bottom + scrollPos + 8;
        left = hostPos.left + scrollPosX + (hostPos.width - tooltipPos.width) / 2;
        break;
      case 'left':
        top = hostPos.top + scrollPos + (hostPos.height - tooltipPos.height) / 2;
        left = hostPos.left + scrollPosX - tooltipPos.width - 8;
        break;
      case 'right':
        top = hostPos.top + scrollPos + (hostPos.height - tooltipPos.height) / 2;
        left = hostPos.right + scrollPosX + 8;
        break;
    }

    this.renderer.setStyle(this.tooltipElement, 'top', `${top}px`);
    this.renderer.setStyle(this.tooltipElement, 'left', `${left}px`);
  }

  private hide() {
    if (this.tooltipElement) {
      this.renderer.removeChild(document.body, this.tooltipElement);
      this.tooltipElement = null;
    }
  }

  ngOnDestroy() {
    if (this.showTimeout) {
      clearTimeout(this.showTimeout);
    }
    this.hide();
  }
}

// Usage example:
// <button
//   appTooltip="Click to save"
//   tooltipPosition="top"
//   [tooltipDelay]="500"
// >
//   Save
// </button>
```

---

## Pipes Examples

### Example 12: Custom Pipes Collection

Multiple useful custom pipes for data transformation.

```typescript
// 1. File Size Pipe
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'fileSize',
  standalone: true
})
export class FileSizePipe implements PipeTransform {
  transform(bytes: number, decimals = 2): string {
    if (bytes === 0) return '0 Bytes';

    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));

    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
  }
}

// Usage: {{ 1048576 | fileSize }} // Output: 1 MB

// 2. Time Ago Pipe
@Pipe({
  name: 'timeAgo',
  standalone: true
})
export class TimeAgoPipe implements PipeTransform {
  transform(value: string | Date): string {
    const date = value instanceof Date ? value : new Date(value);
    const now = new Date();
    const seconds = Math.floor((now.getTime() - date.getTime()) / 1000);

    if (seconds < 60) return 'just now';
    if (seconds < 3600) return `${Math.floor(seconds / 60)} minutes ago`;
    if (seconds < 86400) return `${Math.floor(seconds / 3600)} hours ago`;
    if (seconds < 604800) return `${Math.floor(seconds / 86400)} days ago`;
    if (seconds < 2592000) return `${Math.floor(seconds / 604800)} weeks ago`;
    if (seconds < 31536000) return `${Math.floor(seconds / 2592000)} months ago`;
    return `${Math.floor(seconds / 31536000)} years ago`;
  }
}

// Usage: {{ '2024-01-01' | timeAgo }} // Output: 3 months ago

// 3. Safe HTML Pipe
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';

@Pipe({
  name: 'safeHtml',
  standalone: true
})
export class SafeHtmlPipe implements PipeTransform {
  constructor(private sanitizer: DomSanitizer) {}

  transform(value: string): SafeHtml {
    return this.sanitizer.bypassSecurityTrustHtml(value);
  }
}

// Usage: <div [innerHTML]="htmlContent | safeHtml"></div>

// 4. Filter Pipe
@Pipe({
  name: 'filter',
  standalone: true,
  pure: false
})
export class FilterPipe implements PipeTransform {
  transform<T>(items: T[], searchText: string, property?: keyof T): T[] {
    if (!items || !searchText) {
      return items;
    }

    searchText = searchText.toLowerCase();

    return items.filter(item => {
      if (property) {
        const value = item[property];
        return String(value).toLowerCase().includes(searchText);
      }

      // Search in all properties
      return Object.values(item as object).some(value =>
        String(value).toLowerCase().includes(searchText)
      );
    });
  }
}

// Usage: @for (item of items | filter:searchText:'name'; track item.id)

// 5. Sort Pipe
@Pipe({
  name: 'sort',
  standalone: true,
  pure: false
})
export class SortPipe implements PipeTransform {
  transform<T>(items: T[], property?: keyof T, order: 'asc' | 'desc' = 'asc'): T[] {
    if (!items || items.length === 0) {
      return items;
    }

    const sortedItems = [...items].sort((a, b) => {
      const aVal = property ? a[property] : a;
      const bVal = property ? b[property] : b;

      if (aVal < bVal) return order === 'asc' ? -1 : 1;
      if (aVal > bVal) return order === 'asc' ? 1 : -1;
      return 0;
    });

    return sortedItems;
  }
}

// Usage: @for (item of items | sort:'name':'asc'; track item.id)
```

---

## Testing Examples

### Example 13: Comprehensive Component Testing

Complete test suite for a component with dependencies.

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { UserListComponent } from './user-list.component';
import { UserService, User } from './user.service';
import { of, throwError } from 'rxjs';
import { signal } from '@angular/core';

describe('UserListComponent', () => {
  let component: UserListComponent;
  let fixture: ComponentFixture<UserListComponent>;
  let userService: jasmine.SpyObj<UserService>;
  let httpMock: HttpTestingController;

  const mockUsers: User[] = [
    { id: 1, name: 'John Doe', email: 'john@example.com', role: 'admin', createdAt: '2024-01-01' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'user', createdAt: '2024-01-02' }
  ];

  beforeEach(async () => {
    const userServiceSpy = jasmine.createSpyObj('UserService', ['getUsers', 'deleteUser']);

    await TestBed.configureTestingModule({
      imports: [UserListComponent],
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        { provide: UserService, useValue: userServiceSpy }
      ]
    }).compileComponents();

    userService = TestBed.inject(UserService) as jasmine.SpyObj<UserService>;
    httpMock = TestBed.inject(HttpTestingController);
    fixture = TestBed.createComponent(UserListComponent);
    component = fixture.componentInstance;
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load users on init', () => {
    userService.getUsers.and.returnValue(of(mockUsers));

    fixture.detectChanges(); // triggers ngOnInit

    expect(userService.getUsers).toHaveBeenCalled();
    expect(component.users().length).toBe(2);
    expect(component.loading()).toBe(false);
  });

  it('should handle error when loading users fails', () => {
    const errorMessage = 'Failed to load users';
    userService.getUsers.and.returnValue(throwError(() => new Error(errorMessage)));

    fixture.detectChanges();

    expect(component.error()).toBeTruthy();
    expect(component.loading()).toBe(false);
  });

  it('should delete user', () => {
    component.users.set(mockUsers);
    userService.deleteUser.and.returnValue(of(void 0));

    component.deleteUser(1);

    expect(userService.deleteUser).toHaveBeenCalledWith(1);
  });

  it('should filter users by search term', () => {
    component.users.set(mockUsers);
    component.searchTerm.set('Jane');

    fixture.detectChanges();

    const filtered = component.filteredUsers();
    expect(filtered.length).toBe(1);
    expect(filtered[0].name).toBe('Jane Smith');
  });

  it('should render user list', () => {
    component.users.set(mockUsers);
    fixture.detectChanges();

    const compiled = fixture.nativeElement;
    const userItems = compiled.querySelectorAll('.user-item');

    expect(userItems.length).toBe(2);
  });

  it('should show loading state', () => {
    component.loading.set(true);
    fixture.detectChanges();

    const compiled = fixture.nativeElement;
    const loadingElement = compiled.querySelector('.loading');

    expect(loadingElement).toBeTruthy();
    expect(loadingElement.textContent).toContain('Loading');
  });

  it('should show error message', () => {
    const errorMsg = 'Error loading users';
    component.error.set(errorMsg);
    fixture.detectChanges();

    const compiled = fixture.nativeElement;
    const errorElement = compiled.querySelector('.error');

    expect(errorElement).toBeTruthy();
    expect(errorElement.textContent).toContain(errorMsg);
  });
});
```

---

This comprehensive examples collection demonstrates modern Angular development patterns using Context7-researched best practices, including standalone components, signals, inject() function, reactive forms, RxJS operators, and thorough testing strategies.
