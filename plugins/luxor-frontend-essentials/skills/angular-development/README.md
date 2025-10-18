# Angular Development Skill

A comprehensive skill for building modern Angular applications with standalone components, signals, reactive forms, routing, and RxJS integration.

## Overview

This skill provides deep expertise in Angular framework development, covering everything from basic component creation to advanced patterns like lazy loading, state management with signals, and reactive programming with RxJS. Based on official Angular documentation (Context7 Trust Score: 8.9), it incorporates the latest best practices and modern patterns.

## What This Skill Covers

### Core Angular Concepts

- **Components**: Standalone components, lifecycle hooks, component communication
- **Services**: Dependency injection, providedIn configuration, service patterns
- **Directives**: Structural and attribute directives, custom directive creation
- **Pipes**: Built-in pipes, custom pipe implementation, pure vs impure pipes
- **Modules**: Migration from NgModules to standalone components

### Modern Angular Features

- **Signals**: Reactive state management with signals, computed values, effects
- **Control Flow**: New @if, @for, @switch syntax replacing *ngIf, *ngFor, *ngSwitch
- **inject() Function**: Modern dependency injection replacing constructor injection
- **Standalone Components**: Module-less architecture for better tree-shaking
- **Signal-based Inputs/Outputs**: Modern component communication patterns

### Routing and Navigation

- **Lazy Loading**: Route-level code splitting for performance
- **Guards**: Functional and class-based route guards
- **Resolvers**: Pre-fetching data before route activation
- **Route Parameters**: Accessing and reacting to route params
- **Child Routes**: Nested routing patterns

### Forms

- **Reactive Forms**: FormBuilder, FormGroup, FormControl, FormArray
- **Validation**: Built-in validators, custom validators, async validators
- **Dynamic Forms**: Programmatic form generation
- **Form State**: Tracking touched, dirty, valid states
- **Custom Form Controls**: ControlValueAccessor implementation

### RxJS Integration

- **Observables**: Creating and subscribing to observables
- **Operators**: map, filter, switchMap, combineLatest, debounceTime, etc.
- **Subjects**: BehaviorSubject, Subject, ReplaySubject patterns
- **Error Handling**: retry, catchError operators
- **Subscription Management**: takeUntilDestroyed, async pipe

### HTTP and Data

- **HttpClient**: GET, POST, PUT, PATCH, DELETE operations
- **Interceptors**: Request/response interception
- **Error Handling**: Global and local error handling
- **Type Safety**: Typed HTTP responses
- **Caching**: Response caching strategies

### State Management

- **Signals**: Modern reactive state with fine-grained updates
- **Services**: Service-based state management
- **BehaviorSubject**: Observable state patterns (legacy)
- **Computed Values**: Derived state with signals
- **Effects**: Side effects triggered by signal changes

### Performance Optimization

- **Lazy Loading**: Route and module lazy loading
- **OnPush Change Detection**: Optimized change detection strategy
- **TrackBy**: Efficient list rendering
- **Virtual Scrolling**: CDK virtual scroll for large lists
- **Memoization**: Computed signals for expensive calculations

### Testing

- **Component Tests**: TestBed, ComponentFixture, async testing
- **Service Tests**: HttpClientTestingModule, mock services
- **Dependency Injection**: Testing with DI
- **Spy Objects**: Jasmine spies and mocks
- **E2E Testing**: End-to-end testing patterns

## When to Use This Skill

Use this skill when you need to:

- Build a new Angular application from scratch
- Migrate an existing Angular app to modern patterns (standalone, signals, inject())
- Implement complex forms with validation
- Set up routing with lazy loading and guards
- Integrate RxJS for reactive programming
- Optimize Angular application performance
- Implement state management patterns
- Create reusable components and services
- Set up HTTP client with interceptors
- Write tests for Angular components and services
- Build enterprise-scale Angular applications
- Implement modern Angular best practices

## Quick Start Examples

### Creating a Standalone Component

```typescript
import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-welcome',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="welcome">
      <h1>{{ title() }}</h1>
      <p>{{ message() }}</p>
      <button (click)="updateMessage()">Update</button>
    </div>
  `
})
export class WelcomeComponent {
  title = signal('Welcome');
  message = signal('Hello, Angular!');

  updateMessage() {
    this.message.set('Message updated!');
  }
}
```

### Creating a Service with inject()

```typescript
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class DataService {
  private http = inject(HttpClient);

  getData(): Observable<any[]> {
    return this.http.get<any[]>('/api/data');
  }
}
```

### Setting Up Lazy Loading Routes

```typescript
import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: 'home',
    loadComponent: () => import('./home/home.component')
      .then(m => m.HomeComponent)
  },
  {
    path: 'dashboard',
    loadComponent: () => import('./dashboard/dashboard.component')
      .then(m => m.DashboardComponent)
  }
];
```

### Building a Reactive Form

```typescript
import { Component, inject } from '@angular/core';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';

@Component({
  selector: 'app-contact-form',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <form [formGroup]="form" (ngSubmit)="onSubmit()">
      <input formControlName="name" placeholder="Name">
      <input formControlName="email" placeholder="Email">
      <button type="submit" [disabled]="form.invalid">Submit</button>
    </form>
  `
})
export class ContactFormComponent {
  private fb = inject(FormBuilder);

  form = this.fb.group({
    name: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]]
  });

  onSubmit() {
    if (this.form.valid) {
      console.log(this.form.value);
    }
  }
}
```

## Key Patterns and Best Practices

### 1. Use Standalone Components

Standalone components simplify the architecture and improve tree-shaking:

```typescript
@Component({
  selector: 'app-my-component',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `...`
})
export class MyComponent {}
```

### 2. Leverage the inject() Function

The inject() function provides cleaner dependency injection:

```typescript
export class MyService {
  private http = inject(HttpClient);
  private router = inject(Router);
}
```

### 3. Use Signals for State Management

Signals provide fine-grained reactivity with automatic dependency tracking:

```typescript
export class CounterService {
  count = signal(0);
  doubleCount = computed(() => this.count() * 2);

  increment() {
    this.count.update(n => n + 1);
  }
}
```

### 4. Implement Lazy Loading

Lazy load routes for better performance:

```typescript
{
  path: 'admin',
  loadComponent: () => import('./admin/admin.component')
    .then(m => m.AdminComponent)
}
```

### 5. Use Reactive Forms

Reactive forms provide better type safety and testability:

```typescript
form = this.fb.group({
  username: ['', [Validators.required, Validators.minLength(3)]],
  password: ['', [Validators.required, Validators.minLength(8)]]
});
```

### 6. Handle Subscriptions Properly

Always clean up subscriptions to prevent memory leaks:

```typescript
// Use async pipe (automatically unsubscribes)
data$ = this.service.getData();

// Or use takeUntilDestroyed
ngOnInit() {
  this.service.getData()
    .pipe(takeUntilDestroyed(this.destroyRef))
    .subscribe(data => this.data = data);
}
```

### 7. Use OnPush Change Detection

Optimize performance with OnPush strategy:

```typescript
@Component({
  selector: 'app-optimized',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `...`
})
export class OptimizedComponent {}
```

### 8. Type Everything

Leverage TypeScript's type system:

```typescript
interface User {
  id: number;
  name: string;
  email: string;
}

getUser(id: number): Observable<User> {
  return this.http.get<User>(`/api/users/${id}`);
}
```

### 9. Use TrackBy Functions

Improve rendering performance with trackBy:

```typescript
@for (item of items; track item.id) {
  <div>{{ item.name }}</div>
}
```

### 10. Implement Proper Error Handling

Always handle errors in HTTP requests:

```typescript
getData(): Observable<Data[]> {
  return this.http.get<Data[]>('/api/data').pipe(
    retry(3),
    catchError(error => {
      console.error('Error:', error);
      return of([]);
    })
  );
}
```

## Modern Angular Architecture

### Application Bootstrap

```typescript
// main.ts
import { bootstrapApplication } from '@angular/platform-browser';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { AppComponent } from './app/app.component';
import { routes } from './app/app.routes';
import { authInterceptor } from './interceptors/auth.interceptor';

bootstrapApplication(AppComponent, {
  providers: [
    provideRouter(routes),
    provideHttpClient(
      withInterceptors([authInterceptor])
    )
  ]
});
```

### Feature-Based Organization

```
src/app/
├── core/
│   ├── services/
│   ├── guards/
│   ├── interceptors/
│   └── models/
├── features/
│   ├── users/
│   │   ├── components/
│   │   ├── services/
│   │   └── models/
│   └── products/
│       ├── components/
│       ├── services/
│       └── models/
└── shared/
    ├── components/
    ├── directives/
    └── pipes/
```

### Smart vs Presentational Components

**Presentational (Dumb) Component:**
```typescript
@Component({
  selector: 'app-user-card',
  standalone: true,
  template: `
    <div class="card">
      <h3>{{ user().name }}</h3>
      <button (click)="edit.emit(user())">Edit</button>
    </div>
  `
})
export class UserCardComponent {
  user = input.required<User>();
  edit = output<User>();
}
```

**Smart (Container) Component:**
```typescript
@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [UserCardComponent],
  template: `
    @for (user of users$ | async; track user.id) {
      <app-user-card
        [user]="user"
        (edit)="handleEdit($event)"
      />
    }
  `
})
export class UserListComponent {
  private userService = inject(UserService);
  users$ = this.userService.getUsers();

  handleEdit(user: User) {
    this.userService.updateUser(user.id, user).subscribe();
  }
}
```

## Migration Strategies

### From NgModules to Standalone

**Before:**
```typescript
@NgModule({
  declarations: [MyComponent],
  imports: [CommonModule],
  exports: [MyComponent]
})
export class MyModule {}
```

**After:**
```typescript
@Component({
  selector: 'app-my-component',
  standalone: true,
  imports: [CommonModule],
  template: `...`
})
export class MyComponent {}
```

### From Constructor Injection to inject()

**Before:**
```typescript
constructor(
  private http: HttpClient,
  private router: Router
) {}
```

**After:**
```typescript
private http = inject(HttpClient);
private router = inject(Router);
```

### From *ngIf to @if

**Before:**
```html
<div *ngIf="isVisible">Content</div>
<div *ngIf="isVisible; else elseBlock">Content</div>
<ng-template #elseBlock>Else content</ng-template>
```

**After:**
```html
@if (isVisible) {
  <div>Content</div>
}

@if (isVisible) {
  <div>Content</div>
} @else {
  <div>Else content</div>
}
```

### From *ngFor to @for

**Before:**
```html
<div *ngFor="let item of items; trackBy: trackById">
  {{ item.name }}
</div>
```

**After:**
```html
@for (item of items; track item.id) {
  <div>{{ item.name }}</div>
}
```

### From BehaviorSubject to Signals

**Before:**
```typescript
private countSubject = new BehaviorSubject(0);
count$ = this.countSubject.asObservable();

increment() {
  this.countSubject.next(this.countSubject.value + 1);
}
```

**After:**
```typescript
count = signal(0);

increment() {
  this.count.update(n => n + 1);
}
```

## Common Use Cases

### Authentication Flow

```typescript
@Injectable({ providedIn: 'root' })
export class AuthService {
  private http = inject(HttpClient);
  private router = inject(Router);

  isAuthenticated = signal(false);
  currentUser = signal<User | null>(null);

  login(credentials: { email: string; password: string }) {
    return this.http.post<{ user: User; token: string }>('/api/login', credentials)
      .pipe(
        tap(response => {
          localStorage.setItem('token', response.token);
          this.currentUser.set(response.user);
          this.isAuthenticated.set(true);
        })
      );
  }

  logout() {
    localStorage.removeItem('token');
    this.currentUser.set(null);
    this.isAuthenticated.set(false);
    this.router.navigate(['/login']);
  }
}
```

### CRUD Operations

```typescript
@Injectable({ providedIn: 'root' })
export class ProductService {
  private http = inject(HttpClient);
  private apiUrl = '/api/products';

  getAll(): Observable<Product[]> {
    return this.http.get<Product[]>(this.apiUrl);
  }

  getById(id: number): Observable<Product> {
    return this.http.get<Product>(`${this.apiUrl}/${id}`);
  }

  create(product: Omit<Product, 'id'>): Observable<Product> {
    return this.http.post<Product>(this.apiUrl, product);
  }

  update(id: number, product: Partial<Product>): Observable<Product> {
    return this.http.patch<Product>(`${this.apiUrl}/${id}`, product);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}
```

### Real-time Search

```typescript
@Component({
  selector: 'app-search',
  standalone: true,
  imports: [ReactiveFormsModule, CommonModule],
  template: `
    <input [formControl]="searchControl" placeholder="Search...">
    @for (result of results$ | async; track result.id) {
      <div>{{ result.name }}</div>
    }
  `
})
export class SearchComponent {
  private searchService = inject(SearchService);

  searchControl = new FormControl('');

  results$ = this.searchControl.valueChanges.pipe(
    debounceTime(300),
    distinctUntilChanged(),
    switchMap(query =>
      query ? this.searchService.search(query) : of([])
    )
  );
}
```

## Testing Patterns

### Component Test

```typescript
describe('UserListComponent', () => {
  let component: UserListComponent;
  let fixture: ComponentFixture<UserListComponent>;
  let userService: jasmine.SpyObj<UserService>;

  beforeEach(async () => {
    const spy = jasmine.createSpyObj('UserService', ['getUsers']);

    await TestBed.configureTestingModule({
      imports: [UserListComponent],
      providers: [{ provide: UserService, useValue: spy }]
    }).compileComponents();

    userService = TestBed.inject(UserService) as jasmine.SpyObj<UserService>;
    fixture = TestBed.createComponent(UserListComponent);
    component = fixture.componentInstance;
  });

  it('should load users', () => {
    const mockUsers = [{ id: 1, name: 'John' }];
    userService.getUsers.and.returnValue(of(mockUsers));

    fixture.detectChanges();

    expect(component.users.length).toBe(1);
  });
});
```

### Service Test

```typescript
describe('DataService', () => {
  let service: DataService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [DataService]
    });

    service = TestBed.inject(DataService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  it('should fetch data', () => {
    const mockData = [{ id: 1 }];

    service.getData().subscribe(data => {
      expect(data).toEqual(mockData);
    });

    const req = httpMock.expectOne('/api/data');
    expect(req.request.method).toBe('GET');
    req.flush(mockData);
  });
});
```

## Resources

- [Official Angular Documentation](https://angular.io/docs)
- [Angular Blog](https://blog.angular.io/)
- [Angular GitHub Repository](https://github.com/angular/angular)
- [RxJS Documentation](https://rxjs.dev/)
- [Angular Style Guide](https://angular.io/guide/styleguide)

## Context7 Integration

This skill is based on comprehensive research from the official Angular repository (Context7 Trust Score: 8.9), incorporating:

- Latest standalone component patterns
- Modern dependency injection with inject()
- Signal-based reactive state management
- New control flow syntax (@if, @for, @switch)
- Lazy loading best practices
- Reactive forms patterns
- RxJS integration strategies
- Performance optimization techniques
- Testing methodologies
- Migration paths from legacy patterns

All examples and patterns follow the official Angular team's recommendations and best practices, ensuring your Angular applications are built with industry-standard approaches that are maintainable, performant, and future-proof.
