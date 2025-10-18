# Full-Stack API Development Workflow

Managing backend API and frontend integration with Linear for accelerated development.

## Project: RESTful API with React Frontend

### Project Setup

```
Tool: create_project

Parameters:
name: "Task Management API + Web App"
team: "Full-Stack"
summary: "Complete task management system with Node.js API and React frontend"
description: |
  # Task Management API + Web App

  ## Architecture
  - **Backend**: Node.js + Express + PostgreSQL
  - **Frontend**: React + TypeScript + Tailwind
  - **API**: RESTful with JWT authentication
  - **Deployment**: Docker + AWS

  ## Features
  - User authentication and authorization
  - Task CRUD operations
  - Project organization
  - Real-time updates with WebSockets
  - File attachments
  - Team collaboration

  ## Development Approach
  - API-first development
  - Parallel frontend/backend work
  - Comprehensive API documentation
  - E2E testing

  ## Timeline
  - Weeks 1-2: Database + Auth API
  - Weeks 3-4: Task API + Frontend Integration
  - Weeks 5-6: Real-time features + Polish

lead: "me"
priority: 1
startDate: "2025-01-15"
targetDate: "2025-03-01"
labels: ["full-stack", "api", "backend", "frontend"]
```

## Phase 1: Backend API Development

### Epic: Authentication System

```
Tool: create_issue

Parent Issue:
title: "[EPIC][Backend] Authentication & Authorization API"
team: "Backend"
description: |
  ## API Endpoints
  - POST /api/auth/register
  - POST /api/auth/login
  - POST /api/auth/logout
  - POST /api/auth/refresh
  - POST /api/auth/forgot-password
  - POST /api/auth/reset-password
  - GET /api/auth/me

  ## Features
  - JWT token generation
  - Refresh token rotation
  - Password hashing (bcrypt)
  - Email verification
  - Rate limiting
  - CORS configuration

  ## Security
  - Input validation
  - SQL injection prevention
  - XSS protection
  - CSRF tokens

  ## Documentation
  - OpenAPI/Swagger spec
  - Postman collection
  - API integration guide

project: "Task Management API + Web App"
labels: ["epic", "backend", "auth", "api"]
priority: 1
```

### Breaking Down Backend Work

```
Issue 1: Database Schema
title: "[Backend] User authentication database schema"
team: "Backend"
description: |
  ## Tables

  ### users
  ```sql
  CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
  );
  ```

  ### refresh_tokens
  ```sql
  CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
  );
  ```

  ### password_resets
  ```sql
  CREATE TABLE password_resets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
  );
  ```

  ## Indexes
  - users.email (unique)
  - refresh_tokens.token (unique)
  - refresh_tokens.user_id
  - password_resets.token (unique)

  ## Acceptance Criteria
  - Migration file created
  - Schema documented
  - Indexes optimized
  - Foreign keys properly set
parentId: "[auth-epic-id]"
assignee: "backend-dev-1"
project: "Task Management API + Web App"
labels: ["backend", "database", "schema"]
priority: 1
```

```
Issue 2: Authentication Endpoints
title: "[Backend] Implement auth API endpoints"
team: "Backend"
description: |
  ## Endpoints to Implement

  ### POST /api/auth/register
  Request:
  ```json
  {
    "email": "user@example.com",
    "password": "SecurePass123!",
    "firstName": "John",
    "lastName": "Doe"
  }
  ```
  Response: User object + tokens

  ### POST /api/auth/login
  Request:
  ```json
  {
    "email": "user@example.com",
    "password": "SecurePass123!"
  }
  ```
  Response: User object + tokens

  ### POST /api/auth/refresh
  Request:
  ```json
  {
    "refreshToken": "..."
  }
  ```
  Response: New access + refresh tokens

  ## Implementation Tasks
  - [ ] Password validation rules
  - [ ] Email format validation
  - [ ] Bcrypt password hashing
  - [ ] JWT token generation
  - [ ] Refresh token rotation
  - [ ] Error handling
  - [ ] Rate limiting (5 attempts/minute)

  ## Security Checklist
  - [ ] Passwords never logged
  - [ ] Tokens properly signed
  - [ ] Secure HTTP headers
  - [ ] Input sanitization

  ## Testing
  - [ ] Unit tests for each endpoint
  - [ ] Integration tests
  - [ ] Security tests
  - [ ] Load tests

  ## Acceptance Criteria
  - All endpoints working
  - Tests passing
  - OpenAPI documented
  - Postman collection updated
parentId: "[auth-epic-id]"
assignee: "backend-dev-1"
project: "Task Management API + Web App"
labels: ["backend", "api", "auth"]
priority: 1
links: [
  {
    url: "https://github.com/company/api/blob/main/docs/auth.md",
    title: "Auth API Documentation"
  }
]
```

### Epic: Task Management API

```
Tool: create_issue

Parent Issue:
title: "[EPIC][Backend] Task Management API"
team: "Backend"
description: |
  ## API Endpoints

  ### Tasks
  - GET /api/tasks
  - POST /api/tasks
  - GET /api/tasks/:id
  - PUT /api/tasks/:id
  - DELETE /api/tasks/:id
  - PATCH /api/tasks/:id/status

  ### Projects
  - GET /api/projects
  - POST /api/projects
  - GET /api/projects/:id
  - PUT /api/projects/:id
  - DELETE /api/projects/:id

  ### Comments
  - GET /api/tasks/:id/comments
  - POST /api/tasks/:id/comments
  - DELETE /api/comments/:id

  ## Features
  - Filtering and sorting
  - Pagination
  - Search functionality
  - Bulk operations
  - File uploads

  ## Documentation
  - Full OpenAPI spec
  - Request/response examples
  - Error codes documented

project: "Task Management API + Web App"
labels: ["epic", "backend", "api"]
priority: 1
```

## Phase 2: Frontend Integration

### Parallel Frontend Work

While backend is being developed, create frontend issues:

```
Tool: create_issue

Issue: API Client Setup
title: "[Frontend] Setup API client with authentication"
team: "Frontend"
description: |
  ## Tasks
  - [ ] Create Axios instance with base configuration
  - [ ] Implement request interceptor for auth token
  - [ ] Implement response interceptor for token refresh
  - [ ] Handle 401 responses (redirect to login)
  - [ ] Setup environment variables for API URL
  - [ ] Create TypeScript types for API responses

  ## API Client Structure
  ```typescript
  // api/client.ts
  import axios from 'axios';

  const apiClient = axios.create({
    baseURL: process.env.REACT_APP_API_URL,
    timeout: 10000,
  });

  // Request interceptor
  apiClient.interceptors.request.use(
    (config) => {
      const token = localStorage.getItem('accessToken');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    }
  );

  // Response interceptor
  apiClient.interceptors.response.use(
    (response) => response,
    async (error) => {
      // Handle token refresh
      if (error.response?.status === 401) {
        // Refresh token logic
      }
      return Promise.reject(error);
    }
  );

  export default apiClient;
  ```

  ## Acceptance Criteria
  - API client configured
  - Auth token handling works
  - Token refresh implemented
  - TypeScript types defined
  - Error handling robust
assignee: "frontend-dev-1"
project: "Task Management API + Web App"
labels: ["frontend", "api-integration"]
priority: 1
```

```
Issue: Auth Integration
title: "[Frontend] Authentication flow integration"
team: "Frontend"
description: |
  ## Tasks
  - [ ] Create auth context/provider
  - [ ] Implement login form
  - [ ] Implement registration form
  - [ ] Implement logout functionality
  - [ ] Implement forgot password flow
  - [ ] Setup protected routes
  - [ ] Handle auth state persistence

  ## Components to Create
  - LoginPage
  - RegisterPage
  - ForgotPasswordPage
  - ResetPasswordPage
  - AuthProvider

  ## State Management
  ```typescript
  interface AuthState {
    user: User | null;
    isAuthenticated: boolean;
    isLoading: boolean;
    login: (email: string, password: string) => Promise<void>;
    register: (data: RegisterData) => Promise<void>;
    logout: () => void;
  }
  ```

  ## Acceptance Criteria
  - Login works with backend
  - Registration works with backend
  - Logout clears tokens
  - Protected routes redirect
  - Auth state persists on reload
assignee: "frontend-dev-1"
project: "Task Management API + Web App"
labels: ["frontend", "auth", "integration"]
priority: 1
```

## Coordination Between Teams

### Tracking Integration Points

```
Tool: create_issue

Coordination Issue:
title: "[Integration] Task API ↔️ Frontend Task Management"
team: "Full-Stack"
description: |
  ## Backend Status
  - [x] Database schema complete
  - [x] CRUD endpoints implemented
  - [ ] Filtering/sorting endpoints
  - [ ] File upload endpoint
  - [ ] WebSocket events

  ## Frontend Status
  - [x] API client setup
  - [x] Task components created
  - [ ] List view implementation
  - [ ] Create/Edit forms
  - [ ] File upload UI

  ## Integration Checklist
  - [ ] API types synced with frontend
  - [ ] Error handling coordinated
  - [ ] Loading states consistent
  - [ ] Validation rules match
  - [ ] E2E tests passing

  ## Blockers
  - ⚠️ Frontend blocked on file upload endpoint
  - Estimated backend completion: Tomorrow

  ## Communication
  - Daily sync meeting: 10 AM
  - Slack channel: #api-integration
  - API docs: [link]

assignee: "tech-lead"
project: "Task Management API + Web App"
labels: ["integration", "coordination", "backend", "frontend"]
priority: 2
```

## API Documentation Workflow

### Creating API Documentation Issue

```
Tool: create_issue

Issue:
title: "[Backend] Complete OpenAPI documentation"
team: "Backend"
description: |
  ## Documentation Requirements

  ### OpenAPI Spec
  - [ ] All endpoints documented
  - [ ] Request schemas defined
  - [ ] Response schemas defined
  - [ ] Error responses documented
  - [ ] Authentication documented
  - [ ] Examples for all endpoints

  ### Additional Documentation
  - [ ] Postman collection updated
  - [ ] README with quickstart
  - [ ] Authentication guide
  - [ ] Error handling guide
  - [ ] Rate limiting docs

  ## Tools
  - Swagger UI hosted at /api-docs
  - Postman collection exported
  - TypeScript types generated from OpenAPI

  ## Acceptance Criteria
  - OpenAPI spec complete and valid
  - Swagger UI accessible
  - Postman collection works
  - Frontend team approved docs
assignee: "backend-dev-2"
project: "Task Management API + Web App"
labels: ["backend", "documentation", "api"]
priority: 2
```

## Testing Workflow

### Backend Testing

```
Tool: create_issue

Issue:
title: "[Backend] API integration tests"
team: "Backend"
description: |
  ## Test Coverage Requirements

  ### Unit Tests (80% coverage)
  - [ ] Auth service tests
  - [ ] Task service tests
  - [ ] User service tests
  - [ ] Validation tests
  - [ ] Utility function tests

  ### Integration Tests
  - [ ] Auth endpoints (register, login, logout, refresh)
  - [ ] Task CRUD operations
  - [ ] Project CRUD operations
  - [ ] Comment operations
  - [ ] File upload/download
  - [ ] Authorization checks

  ### E2E Tests
  - [ ] Complete user workflows
  - [ ] Error scenarios
  - [ ] Rate limiting
  - [ ] Concurrent requests

  ## Test Framework
  - Jest for unit tests
  - Supertest for API tests
  - Test database setup/teardown

  ## Acceptance Criteria
  - All tests passing
  - 80%+ code coverage
  - CI pipeline green
  - Performance tests included
assignee: "backend-dev-1"
project: "Task Management API + Web App"
labels: ["backend", "testing"]
priority: 2
```

### Frontend Testing

```
Tool: create_issue

Issue:
title: "[Frontend] Component and integration tests"
team: "Frontend"
description: |
  ## Test Coverage

  ### Unit Tests (70% coverage)
  - [ ] Component tests (React Testing Library)
  - [ ] Hook tests
  - [ ] Utility function tests
  - [ ] API client tests (mocked)

  ### Integration Tests
  - [ ] Auth flow tests (with mocked API)
  - [ ] Task management flow
  - [ ] Form validation
  - [ ] Error handling

  ### E2E Tests (Cypress)
  - [ ] Login/Register flow
  - [ ] Create/Edit task flow
  - [ ] Project management
  - [ ] File upload
  - [ ] Responsive design

  ## Test Framework
  - Jest + React Testing Library
  - Cypress for E2E
  - MSW for API mocking

  ## Acceptance Criteria
  - All tests passing
  - 70%+ component coverage
  - E2E tests cover critical paths
  - CI integration complete
assignee: "frontend-dev-2"
project: "Task Management API + Web App"
labels: ["frontend", "testing"]
priority: 2
```

## Deployment Workflow

### Creating Deployment Issues

```
Tool: create_issue

Issue:
title: "[DevOps] Docker containerization and AWS deployment"
team: "DevOps"
description: |
  ## Containerization

  ### Backend Dockerfile
  - [ ] Multi-stage build for optimization
  - [ ] Production dependencies only
  - [ ] Health check endpoint
  - [ ] Non-root user

  ### Frontend Dockerfile
  - [ ] Nginx for serving static files
  - [ ] GZIP compression
  - [ ] Cache headers
  - [ ] Security headers

  ### Docker Compose
  - [ ] Development environment
  - [ ] Backend + Frontend + Database
  - [ ] Volume mounts for hot reload
  - [ ] Environment variables

  ## AWS Deployment

  ### Infrastructure
  - [ ] ECS cluster setup
  - [ ] RDS PostgreSQL instance
  - [ ] Application Load Balancer
  - [ ] CloudFront CDN for frontend
  - [ ] S3 bucket for file uploads
  - [ ] Route53 DNS configuration

  ### CI/CD Pipeline
  - [ ] GitHub Actions workflow
  - [ ] Automated testing
  - [ ] Docker image builds
  - [ ] ECS deployment
  - [ ] Rollback strategy

  ## Acceptance Criteria
  - App deploys successfully
  - Zero-downtime deployments
  - Health checks working
  - Monitoring in place
  - Backup strategy implemented
assignee: "devops-engineer"
project: "Task Management API + Web App"
labels: ["devops", "deployment", "infrastructure"]
priority: 1
```

## Daily Coordination Queries

### Backend Team View

```
Tool: list_issues

Parameters:
team: "Backend"
project: "Task Management API + Web App"
state: "In Progress"
orderBy: "updatedAt"
```

### Frontend Team View

```
Tool: list_issues

Parameters:
team: "Frontend"
project: "Task Management API + Web App"
state: "In Progress"
orderBy: "updatedAt"
```

### Integration Blockers

```
Tool: list_issues

Parameters:
project: "Task Management API + Web App"
label: "blocked"
state: "In Progress"
orderBy: "priority"
```

### Ready for Integration

```
Tool: list_issues

Parameters:
project: "Task Management API + Web App"
label: "ready-for-integration"
orderBy: "updatedAt"
```

## Progress Tracking

### Weekly Sprint Review

```
Tool: list_issues

Backend Completed:
team: "Backend"
project: "Task Management API + Web App"
state: "Done"
orderBy: "updatedAt"
limit: 20

Frontend Completed:
team: "Frontend"
project: "Task Management API + Web App"
state: "Done"
orderBy: "updatedAt"
limit: 20
```

## Best Practices for Full-Stack Projects

1. **API-First Development**:
   - Define API contracts first
   - Frontend can mock APIs while backend builds
   - Use OpenAPI for contract

2. **Parallel Development**:
   - Backend and frontend teams work simultaneously
   - Use integration issues to track dependencies
   - Regular sync meetings

3. **Clear Communication**:
   - Tag relevant team members in comments
   - Update issue status promptly
   - Document blockers clearly

4. **Type Safety**:
   - Generate TypeScript types from OpenAPI
   - Share types between backend and frontend
   - Validate at runtime

5. **Testing Strategy**:
   - Backend: Unit + Integration tests
   - Frontend: Component + E2E tests
   - Full-stack: Integration E2E tests

6. **Deployment Coordination**:
   - Deploy backend first
   - Test with production API
   - Deploy frontend
   - Monitor both services

This workflow ensures efficient, organized full-stack development with clear coordination between teams.
