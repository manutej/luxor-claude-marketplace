---
name: angular-development
description: Comprehensive Angular framework development covering components, directives, services, dependency injection, routing, and reactive programming based on official Angular documentation
category: frontend
tags: [angular, typescript, components, services, dependency-injection, rxjs, reactive, standalone, signals]
version: 1.0.0
context7_library: /angular/angular
context7_trust_score: 8.9
---

# Angular Development Skill

## When to Use This Skill

Use this skill when working with Angular applications, including:

- Building modern Angular applications with standalone components
- Creating reactive UIs with Angular's component system
- Implementing dependency injection patterns
- Setting up routing with lazy loading and guards
- Building reactive forms with validation
- Managing state with Signals and RxJS
- Creating custom directives and pipes
- Implementing HTTP client integrations
- Migrating from older Angular patterns to modern approaches
- Optimizing Angular applications for performance
- Setting up Angular projects with best practices

## Core Concepts

### Components

Components are the fundamental building blocks of Angular applications. They control a portion of the screen called a view.

**Modern Standalone Component Pattern:**

```typescript
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-user-profile',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="profile">
      <h2>{{ user.name }}</h2>
      <p>{{ user.email }}</p>
      <button (click)="updateProfile()">Update</button>
    </div>
  `,
  styles: [`
    .profile {
      padding: 20px;
      border: 1px solid #ccc;
      border-radius: 8px;
    }
  `]
})
export class UserProfileComponent {
  user = {
    name: 'John Doe',
    email: 'john@example.com'
  };

  updateProfile() {
    console.log('Updating profile...');
  }
}
```

**Component Lifecycle Hooks:**

```typescript
import { Component, OnInit, OnDestroy, AfterViewInit } from '@angular/core';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-lifecycle-demo',
  standalone: true,
  template: `<div>{{ message }}</div>`
})
export class LifecycleDemoComponent implements OnInit, OnDestroy, AfterViewInit {
  message = '';
  private subscription?: Subscription;

  ngOnInit() {
    // Called once after component initialization
    console.log('Component initialized');
    this.message = 'Component ready';
  }

  ngAfterViewInit() {
    // Called after view initialization
    console.log('View initialized');
  }

  ngOnDestroy() {
    // Called before component destruction
    console.log('Component destroyed');
    this.subscription?.unsubscribe();
  }
}
```

### Services and Dependency Injection

Services provide shared functionality across components. Angular's dependency injection system makes services available throughout your application.

**Modern Injectable Service with inject() Function:**

```typescript
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface User {
  id: number;
  name: string;
  email: string;
}

@Injectable({
  providedIn: 'root' // Singleton service available app-wide
})
export class UserService {
  // Modern inject() function instead of constructor injection
  private http = inject(HttpClient);
  private apiUrl = 'https://api.example.com/users';

  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl);
  }

  getUserById(id: number): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/${id}`);
  }

  createUser(user: Omit<User, 'id'>): Observable<User> {
    return this.http.post<User>(this.apiUrl, user);
  }

  updateUser(id: number, user: Partial<User>): Observable<User> {
    return this.http.patch<User>(`${this.apiUrl}/${id}`, user);
  }

  deleteUser(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}
```

**Using Services in Components:**

```typescript
import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { UserService, User } from './user.service';

@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="user-list">
      <h2>Users</h2>
      @if (loading) {
        <p>Loading...</p>
      } @else if (error) {
        <p class="error">{{ error }}</p>
      } @else {
        <ul>
          @for (user of users; track user.id) {
            <li>{{ user.name }} - {{ user.email }}</li>
          }
        </ul>
      }
    </div>
  `
})
export class UserListComponent implements OnInit {
  private userService = inject(UserService);

  users: User[] = [];
  loading = false;
  error = '';

  ngOnInit() {
    this.loadUsers();
  }

  loadUsers() {
    this.loading = true;
    this.userService.getUsers().subscribe({
      next: (users) => {
        this.users = users;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load users';
        this.loading = false;
        console.error(err);
      }
    });
  }
}
```

### Signals - Modern Reactive State Management

Signals provide a new way to manage reactive state in Angular with fine-grained reactivity.

```typescript
import { Component, signal, computed, effect } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-counter',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="counter">
      <h2>Counter: {{ count() }}</h2>
      <p>Double: {{ doubleCount() }}</p>
      <p>Status: {{ status() }}</p>
      <button (click)="increment()">Increment</button>
      <button (click)="decrement()">Decrement</button>
      <button (click)="reset()">Reset</button>
    </div>
  `
})
export class CounterComponent {
  // Writable signal
  count = signal(0);

  // Computed signal - automatically updates when count changes
  doubleCount = computed(() => this.count() * 2);
  status = computed(() => {
    const value = this.count();
    if (value < 0) return 'Negative';
    if (value === 0) return 'Zero';
    return 'Positive';
  });

  constructor() {
    // Effect runs whenever signals it reads change
    effect(() => {
      console.log(`Count changed to: ${this.count()}`);
    });
  }

  increment() {
    this.count.update(value => value + 1);
  }

  decrement() {
    this.count.update(value => value - 1);
  }

  reset() {
    this.count.set(0);
  }
}
```

**Advanced Signals Pattern - Shopping Cart:**

```typescript
import { Injectable, signal, computed } from '@angular/core';

export interface CartItem {
  id: number;
  name: string;
  price: number;
  quantity: number;
}

@Injectable({
  providedIn: 'root'
})
export class CartService {
  private items = signal<CartItem[]>([]);

  // Computed values
  totalItems = computed(() =>
    this.items().reduce((sum, item) => sum + item.quantity, 0)
  );

  totalPrice = computed(() =>
    this.items().reduce((sum, item) => sum + (item.price * item.quantity), 0)
  );

  // Read-only access to items
  getItems = this.items.asReadonly();

  addItem(item: Omit<CartItem, 'quantity'>) {
    this.items.update(currentItems => {
      const existing = currentItems.find(i => i.id === item.id);
      if (existing) {
        return currentItems.map(i =>
          i.id === item.id ? { ...i, quantity: i.quantity + 1 } : i
        );
      }
      return [...currentItems, { ...item, quantity: 1 }];
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

  clear() {
    this.items.set([]);
  }
}
```

### Routing

Angular's router enables navigation between views and lazy loading of feature modules.

**Modern Route Configuration with Lazy Loading:**

```typescript
import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    redirectTo: '/home',
    pathMatch: 'full'
  },
  {
    path: 'home',
    loadComponent: () => import('./home/home.component').then(m => m.HomeComponent)
  },
  {
    path: 'users',
    loadComponent: () => import('./users/user-list.component').then(m => m.UserListComponent)
  },
  {
    path: 'users/:id',
    loadComponent: () => import('./users/user-detail.component').then(m => m.UserDetailComponent)
  },
  {
    path: 'admin',
    loadComponent: () => import('./admin/admin.component').then(m => m.AdminComponent),
    canActivate: [(route, state) => inject(AuthGuard).canActivate(route, state)]
  },
  {
    path: '**',
    loadComponent: () => import('./not-found/not-found.component').then(m => m.NotFoundComponent)
  }
];
```

**Route Guards with inject() Function:**

```typescript
import { Injectable, inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';
import { AuthService } from './auth.service';

// Functional guard (modern approach)
export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isAuthenticated()) {
    return true;
  }

  // Redirect to login
  return router.createUrlTree(['/login'], {
    queryParams: { returnUrl: state.url }
  });
};

// Class-based guard (traditional approach)
@Injectable({
  providedIn: 'root'
})
export class AuthGuard {
  private authService = inject(AuthService);
  private router = inject(Router);

  canActivate(route: any, state: any): boolean {
    if (this.authService.isAuthenticated()) {
      return true;
    }

    this.router.navigate(['/login'], {
      queryParams: { returnUrl: state.url }
    });
    return false;
  }
}
```

**Router with Route Parameters:**

```typescript
import { Component, OnInit, inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { switchMap } from 'rxjs/operators';
import { UserService, User } from '../services/user.service';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-user-detail',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="user-detail">
      @if (user) {
        <h2>{{ user.name }}</h2>
        <p>Email: {{ user.email }}</p>
        <button (click)="goBack()">Back</button>
        <button (click)="editUser()">Edit</button>
      } @else {
        <p>Loading user...</p>
      }
    </div>
  `
})
export class UserDetailComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private userService = inject(UserService);

  user?: User;

  ngOnInit() {
    this.route.paramMap.pipe(
      switchMap(params => {
        const id = Number(params.get('id'));
        return this.userService.getUserById(id);
      })
    ).subscribe(user => {
      this.user = user;
    });
  }

  goBack() {
    this.router.navigate(['/users']);
  }

  editUser() {
    this.router.navigate(['/users', this.user?.id, 'edit']);
  }
}
```

### Reactive Forms

Reactive forms provide a model-driven approach to handling form inputs with built-in validation.

**Form with Validation:**

```typescript
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';

@Component({
  selector: 'app-user-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <form [formGroup]="userForm" (ngSubmit)="onSubmit()" class="user-form">
      <div class="form-group">
        <label for="name">Name:</label>
        <input
          id="name"
          type="text"
          formControlName="name"
          [class.error]="name.invalid && name.touched"
        >
        @if (name.invalid && name.touched) {
          <div class="error-message">
            @if (name.errors?.['required']) {
              <span>Name is required</span>
            }
            @if (name.errors?.['minlength']) {
              <span>Name must be at least 3 characters</span>
            }
          </div>
        }
      </div>

      <div class="form-group">
        <label for="email">Email:</label>
        <input
          id="email"
          type="email"
          formControlName="email"
          [class.error]="email.invalid && email.touched"
        >
        @if (email.invalid && email.touched) {
          <div class="error-message">
            @if (email.errors?.['required']) {
              <span>Email is required</span>
            }
            @if (email.errors?.['email']) {
              <span>Invalid email format</span>
            }
          </div>
        }
      </div>

      <div class="form-group">
        <label for="age">Age:</label>
        <input
          id="age"
          type="number"
          formControlName="age"
          [class.error]="age.invalid && age.touched"
        >
        @if (age.invalid && age.touched) {
          <div class="error-message">
            @if (age.errors?.['min']) {
              <span>Age must be at least 18</span>
            }
            @if (age.errors?.['max']) {
              <span>Age must be less than 100</span>
            }
          </div>
        }
      </div>

      <button type="submit" [disabled]="userForm.invalid">Submit</button>
      <button type="button" (click)="resetForm()">Reset</button>
    </form>
  `
})
export class UserFormComponent {
  private fb = inject(FormBuilder);

  userForm = this.fb.group({
    name: ['', [Validators.required, Validators.minLength(3)]],
    email: ['', [Validators.required, Validators.email]],
    age: [null, [Validators.min(18), Validators.max(100)]]
  });

  // Convenience getters
  get name() { return this.userForm.get('name')!; }
  get email() { return this.userForm.get('email')!; }
  get age() { return this.userForm.get('age')!; }

  onSubmit() {
    if (this.userForm.valid) {
      console.log('Form submitted:', this.userForm.value);
      // Handle form submission
    }
  }

  resetForm() {
    this.userForm.reset();
  }
}
```

**Custom Validators:**

```typescript
import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

export class CustomValidators {
  static passwordMatch(passwordField: string, confirmField: string): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const password = control.get(passwordField);
      const confirm = control.get(confirmField);

      if (!password || !confirm) {
        return null;
      }

      return password.value === confirm.value ? null : { passwordMismatch: true };
    };
  }

  static noWhitespace(): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const value = control.value as string;
      if (!value) return null;

      const hasWhitespace = value.trim().length === 0;
      return hasWhitespace ? { whitespace: true } : null;
    };
  }

  static strongPassword(): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const value = control.value as string;
      if (!value) return null;

      const hasNumber = /\d/.test(value);
      const hasUpper = /[A-Z]/.test(value);
      const hasLower = /[a-z]/.test(value);
      const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(value);
      const isLongEnough = value.length >= 8;

      const valid = hasNumber && hasUpper && hasLower && hasSpecial && isLongEnough;

      return valid ? null : {
        weakPassword: {
          hasNumber,
          hasUpper,
          hasLower,
          hasSpecial,
          isLongEnough
        }
      };
    };
  }
}
```

### Directives

Directives allow you to attach behavior to elements in the DOM.

**Structural Directive:**

```typescript
import { Directive, Input, TemplateRef, ViewContainerRef, inject } from '@angular/core';

@Directive({
  selector: '[appRepeat]',
  standalone: true
})
export class RepeatDirective {
  private templateRef = inject(TemplateRef<any>);
  private viewContainer = inject(ViewContainerRef);

  @Input() set appRepeat(times: number) {
    this.viewContainer.clear();
    for (let i = 0; i < times; i++) {
      this.viewContainer.createEmbeddedView(this.templateRef, {
        $implicit: i,
        index: i
      });
    }
  }
}

// Usage:
// <div *appRepeat="5; let i = index">Item {{ i }}</div>
```

**Attribute Directive:**

```typescript
import { Directive, ElementRef, HostListener, Input, inject } from '@angular/core';

@Directive({
  selector: '[appHighlight]',
  standalone: true
})
export class HighlightDirective {
  private el = inject(ElementRef);

  @Input() appHighlight = 'yellow';
  @Input() defaultColor = 'transparent';

  @HostListener('mouseenter') onMouseEnter() {
    this.highlight(this.appHighlight);
  }

  @HostListener('mouseleave') onMouseLeave() {
    this.highlight(this.defaultColor);
  }

  private highlight(color: string) {
    this.el.nativeElement.style.backgroundColor = color;
  }
}

// Usage:
// <p appHighlight="lightblue" defaultColor="white">Hover me!</p>
```

### Pipes

Pipes transform displayed values within templates.

**Custom Pipe:**

```typescript
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'truncate',
  standalone: true
})
export class TruncatePipe implements PipeTransform {
  transform(value: string, limit = 50, ellipsis = '...'): string {
    if (!value) return '';
    if (value.length <= limit) return value;
    return value.substring(0, limit) + ellipsis;
  }
}

// Usage:
// {{ longText | truncate:100:'...' }}
```

**Async Pipe with Observables:**

```typescript
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Observable, interval, map } from 'rxjs';

@Component({
  selector: 'app-clock',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="clock">
      <h2>Current Time</h2>
      <p>{{ time$ | async | date:'medium' }}</p>
    </div>
  `
})
export class ClockComponent {
  time$: Observable<Date> = interval(1000).pipe(
    map(() => new Date())
  );
}
```

### RxJS Integration

Angular extensively uses RxJS for reactive programming patterns.

**Observable Patterns:**

```typescript
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject, Subject, combineLatest } from 'rxjs';
import { map, filter, debounceTime, distinctUntilChanged, switchMap, catchError, retry } from 'rxjs/operators';

export interface Product {
  id: number;
  name: string;
  price: number;
  category: string;
}

@Injectable({
  providedIn: 'root'
})
export class ProductService {
  private http = inject(HttpClient);
  private apiUrl = 'https://api.example.com/products';

  // BehaviorSubject for state management
  private productsSubject = new BehaviorSubject<Product[]>([]);
  products$ = this.productsSubject.asObservable();

  // Subject for search queries
  private searchSubject = new Subject<string>();

  constructor() {
    this.initializeSearch();
  }

  private initializeSearch() {
    this.searchSubject.pipe(
      debounceTime(300),
      distinctUntilChanged(),
      switchMap(query => this.searchProducts(query))
    ).subscribe(products => {
      this.productsSubject.next(products);
    });
  }

  search(query: string) {
    this.searchSubject.next(query);
  }

  private searchProducts(query: string): Observable<Product[]> {
    return this.http.get<Product[]>(`${this.apiUrl}?q=${query}`).pipe(
      retry(3),
      catchError(error => {
        console.error('Search failed:', error);
        return [];
      })
    );
  }

  getProductsByCategory(category: string): Observable<Product[]> {
    return this.products$.pipe(
      map(products => products.filter(p => p.category === category))
    );
  }

  getExpensiveProducts(minPrice: number): Observable<Product[]> {
    return this.products$.pipe(
      map(products => products.filter(p => p.price >= minPrice))
    );
  }
}
```

**Combining Multiple Observables:**

```typescript
import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { combineLatest, map } from 'rxjs';
import { ProductService } from './product.service';
import { UserService } from './user.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="dashboard">
      @if (dashboardData$ | async; as data) {
        <h2>Welcome, {{ data.user.name }}</h2>
        <p>Products: {{ data.productCount }}</p>
        <p>Total Value: {{ data.totalValue | currency }}</p>
      }
    </div>
  `
})
export class DashboardComponent implements OnInit {
  private productService = inject(ProductService);
  private userService = inject(UserService);

  dashboardData$ = combineLatest([
    this.userService.getCurrentUser(),
    this.productService.products$
  ]).pipe(
    map(([user, products]) => ({
      user,
      productCount: products.length,
      totalValue: products.reduce((sum, p) => sum + p.price, 0)
    }))
  );

  ngOnInit() {
    // Data streams are automatically combined
  }
}
```

## Modern Angular Patterns

### Standalone Components

Standalone components eliminate the need for NgModules in most cases.

**Standalone Component Application:**

```typescript
// main.ts
import { bootstrapApplication } from '@angular/platform-browser';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { AppComponent } from './app/app.component';
import { routes } from './app/app.routes';

bootstrapApplication(AppComponent, {
  providers: [
    provideRouter(routes),
    provideHttpClient()
  ]
}).catch(err => console.error(err));
```

**App Component:**

```typescript
import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, RouterOutlet],
  template: `
    <header>
      <h1>My Angular App</h1>
    </header>
    <main>
      <router-outlet></router-outlet>
    </main>
    <footer>
      <p>&copy; 2024 My App</p>
    </footer>
  `,
  styles: [`
    header {
      background: #1976d2;
      color: white;
      padding: 20px;
    }
    main {
      min-height: 80vh;
      padding: 20px;
    }
    footer {
      background: #f5f5f5;
      padding: 20px;
      text-align: center;
    }
  `]
})
export class AppComponent {}
```

### Control Flow Syntax

Modern Angular uses new control flow syntax with `@if`, `@for`, and `@switch`.

```typescript
import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-control-flow-demo',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="demo">
      <!-- @if directive -->
      @if (isLoggedIn()) {
        <p>Welcome back!</p>
        <button (click)="logout()">Logout</button>
      } @else {
        <p>Please log in</p>
        <button (click)="login()">Login</button>
      }

      <!-- @for directive -->
      <h3>Items:</h3>
      @for (item of items(); track item.id) {
        <div class="item">
          <span>{{ item.name }}</span>
          @if ($index === 0) {
            <span class="badge">First</span>
          }
        </div>
      } @empty {
        <p>No items available</p>
      }

      <!-- @switch directive -->
      <h3>Status: {{ status() }}</h3>
      @switch (status()) {
        @case ('loading') {
          <p>Loading data...</p>
        }
        @case ('success') {
          <p>Data loaded successfully!</p>
        }
        @case ('error') {
          <p>Error loading data</p>
        }
        @default {
          <p>Unknown status</p>
        }
      }
    </div>
  `
})
export class ControlFlowDemoComponent {
  isLoggedIn = signal(false);
  items = signal([
    { id: 1, name: 'Item 1' },
    { id: 2, name: 'Item 2' },
    { id: 3, name: 'Item 3' }
  ]);
  status = signal<'loading' | 'success' | 'error' | 'idle'>('idle');

  login() {
    this.isLoggedIn.set(true);
  }

  logout() {
    this.isLoggedIn.set(false);
  }
}
```

### Input and Output with Signals

Modern Angular supports signal-based inputs and outputs.

```typescript
import { Component, input, output, model } from '@angular/core';

@Component({
  selector: 'app-user-card',
  standalone: true,
  template: `
    <div class="card">
      <h3>{{ name() }}</h3>
      <p>{{ email() }}</p>
      <p>Active: {{ isActive() }}</p>
      <button (click)="handleClick()">Select</button>
      <button (click)="toggleActive()">Toggle Active</button>
    </div>
  `
})
export class UserCardComponent {
  // Signal-based input (read-only)
  name = input.required<string>();
  email = input<string>('');

  // Two-way binding with model()
  isActive = model(false);

  // Signal-based output
  userSelected = output<string>();

  handleClick() {
    this.userSelected.emit(this.name());
  }

  toggleActive() {
    this.isActive.update(active => !active);
  }
}

// Parent component usage:
// <app-user-card
//   [name]="userName"
//   [email]="userEmail"
//   [(isActive)]="userActive"
//   (userSelected)="onUserSelected($event)"
// />
```

## Best Practices from Context7 Research

### 1. Use Standalone Components

Prefer standalone components over NgModule-based components for better tree-shaking and simpler architecture.

```typescript
// Good: Standalone component
@Component({
  selector: 'app-feature',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `...`
})
export class FeatureComponent {}

// Avoid: NgModule-based (legacy pattern)
@NgModule({
  declarations: [FeatureComponent],
  imports: [CommonModule, FormsModule]
})
export class FeatureModule {}
```

### 2. Use inject() Function

Prefer the `inject()` function over constructor injection for cleaner code.

```typescript
// Good: inject() function
export class MyComponent {
  private http = inject(HttpClient);
  private router = inject(Router);
}

// Avoid: Constructor injection (still valid but more verbose)
export class MyComponent {
  constructor(
    private http: HttpClient,
    private router: Router
  ) {}
}
```

### 3. Leverage Signals for State

Use Signals for reactive state management instead of manually managing observables.

```typescript
// Good: Signals
export class TodoService {
  private todos = signal<Todo[]>([]);
  completedCount = computed(() => this.todos().filter(t => t.completed).length);
}

// Avoid: Manual observable management
export class TodoService {
  private todosSubject = new BehaviorSubject<Todo[]>([]);
  todos$ = this.todosSubject.asObservable();
  completedCount$ = this.todos$.pipe(
    map(todos => todos.filter(t => t.completed).length)
  );
}
```

### 4. Implement Lazy Loading

Use lazy loading for better performance and faster initial load times.

```typescript
// Good: Lazy loaded routes
export const routes: Routes = [
  {
    path: 'admin',
    loadComponent: () => import('./admin/admin.component').then(m => m.AdminComponent)
  }
];

// Avoid: Eager loading everything
import { AdminComponent } from './admin/admin.component';
export const routes: Routes = [
  { path: 'admin', component: AdminComponent }
];
```

### 5. Use Reactive Forms

Prefer reactive forms over template-driven forms for better testability and type safety.

```typescript
// Good: Reactive forms
export class MyFormComponent {
  form = this.fb.group({
    name: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]]
  });
}

// Avoid: Template-driven forms for complex scenarios
// <form #myForm="ngForm">
//   <input name="name" ngModel required>
// </form>
```

### 6. Unsubscribe from Observables

Always clean up subscriptions to prevent memory leaks.

```typescript
// Good: Using takeUntilDestroyed (Angular 16+)
export class MyComponent {
  private destroyed$ = inject(DestroyRef);

  ngOnInit() {
    this.dataService.getData()
      .pipe(takeUntilDestroyed(this.destroyed$))
      .subscribe(data => this.data = data);
  }
}

// Alternative: Using async pipe (automatically unsubscribes)
export class MyComponent {
  data$ = this.dataService.getData();
}
```

### 7. Use OnPush Change Detection

Optimize performance with OnPush change detection strategy.

```typescript
import { ChangeDetectionStrategy } from '@angular/core';

@Component({
  selector: 'app-optimized',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `{{ data() }}`
})
export class OptimizedComponent {
  data = signal('initial value');
}
```

### 8. Implement Proper Error Handling

Always handle errors in HTTP requests and observables.

```typescript
export class DataService {
  private http = inject(HttpClient);

  getData(): Observable<Data[]> {
    return this.http.get<Data[]>('/api/data').pipe(
      retry(3),
      catchError(error => {
        console.error('Failed to fetch data:', error);
        return of([]);
      })
    );
  }
}
```

### 9. Use TrackBy with ngFor

Improve rendering performance with trackBy functions.

```typescript
// Good: With trackBy
@Component({
  template: `
    @for (item of items; track item.id) {
      <div>{{ item.name }}</div>
    }
  `
})
export class MyComponent {
  items = [{ id: 1, name: 'Item 1' }];
}

// Old syntax with trackBy:
// *ngFor="let item of items; trackBy: trackById"
```

### 10. Type Your Code

Leverage TypeScript's type system for better IDE support and fewer runtime errors.

```typescript
interface User {
  id: number;
  name: string;
  email: string;
  role: 'admin' | 'user' | 'guest';
}

export class UserService {
  getUser(id: number): Observable<User> {
    return this.http.get<User>(`/api/users/${id}`);
  }

  updateUser(id: number, updates: Partial<User>): Observable<User> {
    return this.http.patch<User>(`/api/users/${id}`, updates);
  }
}
```

## Performance Optimization

### Lazy Loading Modules

```typescript
export const routes: Routes = [
  {
    path: 'dashboard',
    loadComponent: () => import('./dashboard/dashboard.component')
      .then(m => m.DashboardComponent),
    children: [
      {
        path: 'analytics',
        loadComponent: () => import('./analytics/analytics.component')
          .then(m => m.AnalyticsComponent)
      }
    ]
  }
];
```

### Virtual Scrolling

```typescript
import { Component } from '@angular/core';
import { ScrollingModule } from '@angular/cdk/scrolling';

@Component({
  selector: 'app-virtual-scroll',
  standalone: true,
  imports: [ScrollingModule],
  template: `
    <cdk-virtual-scroll-viewport itemSize="50" class="viewport">
      @for (item of items; track item) {
        <div class="item">{{ item }}</div>
      }
    </cdk-virtual-scroll-viewport>
  `,
  styles: [`
    .viewport {
      height: 400px;
      width: 100%;
    }
    .item {
      height: 50px;
    }
  `]
})
export class VirtualScrollComponent {
  items = Array.from({ length: 10000 }, (_, i) => `Item ${i + 1}`);
}
```

### Memoization with Signals

```typescript
export class DataProcessorService {
  private rawData = signal<number[]>([]);

  // Computed signals automatically memoize results
  processedData = computed(() => {
    const data = this.rawData();
    // Expensive computation only runs when rawData changes
    return data.map(n => n * 2).filter(n => n > 10).sort((a, b) => a - b);
  });

  statistics = computed(() => {
    const data = this.processedData();
    return {
      count: data.length,
      sum: data.reduce((a, b) => a + b, 0),
      average: data.length ? data.reduce((a, b) => a + b, 0) / data.length : 0
    };
  });
}
```

## Testing Angular Applications

### Component Testing

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { UserListComponent } from './user-list.component';
import { UserService } from './user.service';
import { of } from 'rxjs';

describe('UserListComponent', () => {
  let component: UserListComponent;
  let fixture: ComponentFixture<UserListComponent>;
  let userService: jasmine.SpyObj<UserService>;

  beforeEach(async () => {
    const userServiceSpy = jasmine.createSpyObj('UserService', ['getUsers']);

    await TestBed.configureTestingModule({
      imports: [UserListComponent],
      providers: [
        { provide: UserService, useValue: userServiceSpy }
      ]
    }).compileComponents();

    userService = TestBed.inject(UserService) as jasmine.SpyObj<UserService>;
    fixture = TestBed.createComponent(UserListComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load users on init', () => {
    const mockUsers = [
      { id: 1, name: 'John', email: 'john@example.com' },
      { id: 2, name: 'Jane', email: 'jane@example.com' }
    ];
    userService.getUsers.and.returnValue(of(mockUsers));

    fixture.detectChanges();

    expect(component.users.length).toBe(2);
    expect(userService.getUsers).toHaveBeenCalled();
  });
});
```

### Service Testing

```typescript
import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { UserService } from './user.service';

describe('UserService', () => {
  let service: UserService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [UserService]
    });

    service = TestBed.inject(UserService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('should fetch users', () => {
    const mockUsers = [
      { id: 1, name: 'John', email: 'john@example.com' }
    ];

    service.getUsers().subscribe(users => {
      expect(users.length).toBe(1);
      expect(users).toEqual(mockUsers);
    });

    const req = httpMock.expectOne('https://api.example.com/users');
    expect(req.request.method).toBe('GET');
    req.flush(mockUsers);
  });
});
```

## Migration Guide

### From NgModules to Standalone

```typescript
// Before: NgModule-based
@NgModule({
  declarations: [MyComponent],
  imports: [CommonModule, FormsModule],
  exports: [MyComponent]
})
export class MyModule {}

// After: Standalone
@Component({
  selector: 'app-my-component',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `...`
})
export class MyComponent {}
```

### From Constructor to inject()

```typescript
// Before: Constructor injection
export class MyService {
  constructor(
    private http: HttpClient,
    private router: Router,
    private auth: AuthService
  ) {}
}

// After: inject() function
export class MyService {
  private http = inject(HttpClient);
  private router = inject(Router);
  private auth = inject(AuthService);
}
```

### From BehaviorSubject to Signals

```typescript
// Before: BehaviorSubject
export class StateService {
  private countSubject = new BehaviorSubject<number>(0);
  count$ = this.countSubject.asObservable();

  increment() {
    this.countSubject.next(this.countSubject.value + 1);
  }
}

// After: Signals
export class StateService {
  count = signal(0);

  increment() {
    this.count.update(value => value + 1);
  }
}
```

## Common Patterns

### Master-Detail Pattern

```typescript
// List component
@Component({
  selector: 'app-product-list',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="product-list">
      @for (product of products(); track product.id) {
        <div
          class="product-item"
          [class.selected]="selectedId() === product.id"
          (click)="selectProduct(product.id)"
        >
          {{ product.name }} - {{ product.price | currency }}
        </div>
      }
    </div>
  `
})
export class ProductListComponent {
  products = input.required<Product[]>();
  selectedId = model<number | null>(null);

  selectProduct(id: number) {
    this.selectedId.set(id);
  }
}

// Parent component
@Component({
  selector: 'app-product-master-detail',
  standalone: true,
  imports: [ProductListComponent, ProductDetailComponent],
  template: `
    <div class="master-detail">
      <app-product-list
        [products]="products()"
        [(selectedId)]="selectedProductId"
      />
      @if (selectedProduct(); as product) {
        <app-product-detail [product]="product" />
      }
    </div>
  `
})
export class ProductMasterDetailComponent {
  products = signal<Product[]>([]);
  selectedProductId = signal<number | null>(null);

  selectedProduct = computed(() => {
    const id = this.selectedProductId();
    return this.products().find(p => p.id === id);
  });
}
```

### Smart/Presentational Pattern

```typescript
// Presentational component (dumb)
@Component({
  selector: 'app-user-card-presentational',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="user-card">
      <h3>{{ user().name }}</h3>
      <p>{{ user().email }}</p>
      <button (click)="edit.emit(user())">Edit</button>
      <button (click)="delete.emit(user().id)">Delete</button>
    </div>
  `
})
export class UserCardPresentationalComponent {
  user = input.required<User>();
  edit = output<User>();
  delete = output<number>();
}

// Smart component (container)
@Component({
  selector: 'app-user-list-container',
  standalone: true,
  imports: [CommonModule, UserCardPresentationalComponent],
  template: `
    @for (user of users$ | async; track user.id) {
      <app-user-card-presentational
        [user]="user"
        (edit)="handleEdit($event)"
        (delete)="handleDelete($event)"
      />
    }
  `
})
export class UserListContainerComponent {
  private userService = inject(UserService);

  users$ = this.userService.getUsers();

  handleEdit(user: User) {
    // Business logic
    this.userService.updateUser(user.id, user).subscribe();
  }

  handleDelete(id: number) {
    // Business logic
    this.userService.deleteUser(id).subscribe();
  }
}
```

## Context7 Integration Summary

This skill incorporates best practices from the official Angular documentation (Context7 Trust Score: 8.9), including:

- **Standalone Components**: Modern approach eliminating NgModules
- **inject() Function**: Cleaner dependency injection
- **Signals**: Fine-grained reactive state management
- **Control Flow Syntax**: @if, @for, @switch directives
- **Lazy Loading**: Performance optimization patterns
- **Reactive Forms**: Type-safe form handling
- **RxJS Patterns**: Observable composition and operators
- **Modern Routing**: Functional guards and resolvers
- **Change Detection**: OnPush strategy for performance
- **Testing**: Component and service testing patterns

All examples follow the latest Angular best practices and patterns recommended in the official documentation, ensuring production-ready, maintainable, and performant Angular applications.
