# Linear Workflow Guide

Complete guide to using Linear for accelerated software development with the Linear Development Accelerator skill.

## Table of Contents

1. [Linear Fundamentals](#linear-fundamentals)
2. [Project Setup Workflows](#project-setup-workflows)
3. [Daily Development Workflows](#daily-development-workflows)
4. [Team Collaboration Patterns](#team-collaboration-patterns)
5. [Sprint/Cycle Management](#sprintcycle-management)
6. [GitHub Integration](#github-integration)
7. [Advanced Workflows](#advanced-workflows)
8. [Best Practices](#best-practices)

## Linear Fundamentals

### Core Entities

Understanding Linear's hierarchy:

```
Workspace (Organization)
  ├── Teams (e.g., Frontend, Backend, Mobile)
  │   ├── Projects (Major initiatives)
  │   │   └── Issues (Individual tasks)
  │   ├── Cycles (Sprints/iterations)
  │   │   └── Issues
  │   └── Labels (Categorization)
  └── Users (Team members)
```

### Issue Lifecycle

```
Backlog → Todo → In Progress → In Review → Done
                                         → Canceled
```

### Key Concepts

**Issues**: The fundamental unit of work
- Can be standalone or part of a project
- Can have parent/child relationships
- Track with labels, status, priority, assignee

**Projects**: Collections of related issues for larger initiatives
- Have start/target dates
- Track progress across multiple issues
- Can span multiple cycles

**Cycles**: Time-boxed iterations (like sprints)
- Typically 1-2 weeks
- Help organize work into manageable chunks
- Track team velocity

**Labels**: Flexible categorization system
- Type labels (bug, feature, improvement)
- Area labels (frontend, backend, mobile)
- Status labels (blocked, ready-for-dev)
- Technology labels (react, python, flutter)

## Project Setup Workflows

### 1. New Frontend Project

**Scenario**: Starting a React e-commerce frontend

```
Step 1: Create the project
─────────────────────────────
Use: create_project

name: "E-Commerce Frontend Redesign"
team: "Frontend"
summary: "Modern e-commerce UI with React + TypeScript"
description: |
  # Project Overview
  Complete redesign of e-commerce platform

  ## Tech Stack
  - React 18 + TypeScript
  - Tailwind CSS
  - Zustand state management
  - Vite build tool

  ## Goals
  - Modern UI/UX
  - < 2s load time
  - Mobile responsive
  - Accessibility compliant

  ## Timeline
  Q1 2025: Design & Setup (2 weeks)
  Q2 2025: Core Features (6 weeks)
  Q3 2025: Testing & Launch (4 weeks)

lead: "me"
priority: 2 (High)
startDate: "2025-01-15"
targetDate: "2025-04-15"
labels: ["frontend", "react", "redesign"]
```

```
Step 2: Create epic issues
─────────────────────────────
Epic 1: Design System
Use: create_issue

title: "[EPIC] Design System & Component Library"
team: "Frontend"
description: |
  ## Overview
  Build reusable design system

  ## Components
  - Primitive components (Button, Input, Card)
  - Color palette (light/dark modes)
  - Typography system
  - Spacing/sizing tokens

  ## Deliverables
  - Storybook documentation
  - Component library npm package

project: "E-Commerce Frontend Redesign"
labels: ["epic", "design-system"]
priority: 1

Epic 2: Product Catalog
Epic 3: Shopping Cart
Epic 4: Checkout Flow
```

```
Step 3: Break down into tasks
─────────────────────────────
For each epic, create child issues:

Use: create_issue

title: "Create Button component with variants"
parentId: "[design-system-epic-id]"
team: "Frontend"
description: |
  ## Tasks
  - [ ] Design variants (primary, secondary, ghost)
  - [ ] Implement component
  - [ ] Add loading state
  - [ ] Add icon support
  - [ ] Write unit tests
  - [ ] Document in Storybook

  ## Acceptance Criteria
  - All variants implemented
  - Accessible (ARIA labels)
  - Tests passing
  - Documented

assignee: "frontend-dev-1"
labels: ["component", "design-system"]
priority: 2
```

### 2. New Mobile App Project

**Scenario**: Flutter chat application (iOS + Android)

```
Step 1: Create project with platform tracking
─────────────────────────────────────────────
Use: create_project

name: "Chat App - iOS & Android"
team: "Mobile"
summary: "Real-time chat app with voice/video calls"
description: |
  # Chat Application

  ## Platforms
  - iOS 14+ (iPhone, iPad)
  - Android 8.0+ (phones, tablets)

  ## Features
  - Real-time messaging
  - Voice/video calls (Agora SDK)
  - Group chats
  - Media sharing
  - Push notifications

  ## Platform Notes
  - iOS: CallKit integration
  - Android: ConnectionService
  - Shared: 80% code reuse

labels: ["mobile", "flutter", "ios", "android"]
```

```
Step 2: Create platform-specific issues
──────────────────────────────────────
Use: create_issue

# Shared functionality
title: "Implement real-time messaging"
team: "Mobile"
labels: ["shared", "messaging", "flutter"]
description: |
  ## Platform: Both iOS & Android
  Core messaging implementation
  ...

# iOS-specific
title: "[iOS] CallKit integration for native calls"
team: "Mobile"
labels: ["ios", "calls", "platform-specific"]
description: |
  ## Platform: iOS Only
  Integrate CallKit for native call experience
  ...

# Android-specific
title: "[Android] ConnectionService integration"
team: "Mobile"
labels: ["android", "calls", "platform-specific"]
description: |
  ## Platform: Android Only
  Integrate ConnectionService
  ...
```

### 3. New Full-Stack Project

**Scenario**: Node.js API + React Frontend

```
Step 1: Create main project
──────────────────────────
Use: create_project

name: "Task Management System - Full Stack"
team: "Full-Stack"
description: |
  # Task Management System

  ## Architecture
  - Backend: Node.js + Express + PostgreSQL
  - Frontend: React + TypeScript + Tailwind
  - API: RESTful with JWT auth
  - Deployment: Docker + AWS

  ## Development Strategy
  - API-first development
  - Parallel frontend/backend work
  - Comprehensive testing

  ## Team Coordination
  - Backend team: 2 developers
  - Frontend team: 2 developers
  - Daily sync: 10 AM
```

```
Step 2: Create backend and frontend epics
────────────────────────────────────────
Backend Epic:
title: "[EPIC][Backend] RESTful API Development"
team: "Backend"
labels: ["epic", "backend", "api"]

Frontend Epic:
title: "[EPIC][Frontend] Web Application UI"
team: "Frontend"
labels: ["epic", "frontend", "react"]
```

```
Step 3: Create integration coordination issues
──────────────────────────────────────────────
Use: create_issue

title: "[Integration] Auth API ↔️ Frontend Auth Flow"
team: "Full-Stack"
description: |
  ## Coordination Point
  Backend auth endpoints + Frontend login/register

  ## Backend Status
  - [ ] POST /api/auth/register
  - [ ] POST /api/auth/login
  - [ ] POST /api/auth/refresh

  ## Frontend Status
  - [ ] Login form component
  - [ ] Register form component
  - [ ] Auth context setup

  ## Dependencies
  - Frontend blocked on: API endpoints complete
  - Backend provides: OpenAPI spec

  ## Sync Points
  - Daily standup: 10 AM
  - API contract review: Wednesday

labels: ["integration", "coordination", "backend", "frontend"]
priority: 1
```

## Daily Development Workflows

### Morning Routine

**Check your active work**:
```
Use: list_issues

assignee: "me"
state: "In Progress"
orderBy: "updatedAt"
limit: 10
```

**Review what's in your queue**:
```
Use: list_issues

assignee: "me"
state: "Todo"
priority: [1, 2]  # Urgent and High
orderBy: "priority"
limit: 10
```

### Starting Work on an Issue

```
1. Move issue to In Progress
────────────────────────────
Use: update_issue

id: "[issue-id]"
state: "In Progress"
assignee: "me"
```

```
2. Create git branch using Linear's suggested name
──────────────────────────────────────────────────
Use: get_issue (to get gitBranchName)

id: "[issue-id]"

Returns: gitBranchName: "team/CET-123-feature-name"

$ git checkout -b team/CET-123-feature-name
```

```
3. Add initial progress comment
───────────────────────────────
Use: create_comment

issueId: "[issue-id]"
body: |
  ## Starting Work

  **Approach:**
  - First implementing core functionality
  - Then adding tests
  - Finally updating documentation

  **Estimated completion:** End of day
```

### During Development

**Update progress regularly**:
```
Use: create_comment

issueId: "[issue-id]"
body: |
  ## Progress Update

  ### Completed
  - ✅ Core functionality implemented
  - ✅ Unit tests written (12 tests)

  ### In Progress
  - 🔄 Integration tests

  ### Blockers
  - None currently

  ### Next
  - Complete integration tests
  - Update documentation
  - Request code review
```

### Completing Work

```
1. Create pull request
─────────────────────
# In your commit messages, reference Linear issue
$ git commit -m "CET-123: Implement user authentication"
$ git push origin team/CET-123-feature-name
$ gh pr create --title "CET-123: User authentication" --body "..."

Linear automatically links the PR!
```

```
2. Move to In Review
───────────────────
Use: update_issue

id: "[issue-id]"
state: "In Review"
links: [
  {
    url: "https://github.com/org/repo/pull/123",
    title: "PR: User authentication"
  }
]
```

```
3. After merge, mark as Done
───────────────────────────
Use: update_issue

id: "[issue-id]"
state: "Done"
```

```
4. Add completion summary
────────────────────────
Use: create_comment

issueId: "[issue-id]"
body: |
  ## Completion Summary ✅

  **PR merged:** #123
  **Deployed to:** staging.example.com

  **Implementation:**
  - JWT-based authentication
  - Refresh token rotation
  - Rate limiting

  **Testing:**
  - 15 unit tests added
  - 5 integration tests
  - Manual testing complete

  **Documentation:**
  - API docs updated
  - README updated
```

## Team Collaboration Patterns

### Daily Standup Query

**What did I work on yesterday?**
```
Use: list_issues

assignee: "me"
state: "Done"
updatedAt: "-P1D"  # Last 24 hours
limit: 10
```

**What am I working on today?**
```
Use: list_issues

assignee: "me"
state: "In Progress"
orderBy: "priority"
```

**What's blocking me?**
```
Use: list_issues

assignee: "me"
label: "blocked"
state: "In Progress"
```

### Code Review Workflow

**Finding issues ready for review**:
```
Use: list_issues

team: "Frontend"
state: "In Review"
orderBy: "createdAt"
limit: 10
```

**Adding review feedback**:
```
Use: create_comment

issueId: "[issue-id]"
body: |
  ## Code Review Feedback

  ### Strengths
  - ✅ Clean component structure
  - ✅ Good test coverage

  ### Suggestions
  - Consider extracting hook for form logic
  - Add loading skeleton component
  - Update TypeScript types for better inference

  ### Questions
  - Why did we choose Zustand over Context?

  **Status:** Approved with minor suggestions
```

### Cross-Team Coordination

**Finding integration points**:
```
Use: list_issues

label: "integration"
state: ["Todo", "In Progress"]
orderBy: "priority"
```

**Backend team: What's ready for frontend?**
```
Use: list_issues

team: "Backend"
label: "ready-for-integration"
state: "Done"
orderBy: "updatedAt"
```

**Frontend team: What needs backend support?**
```
Use: list_issues

team: "Frontend"
label: "blocked"
label: "needs-backend"
state: "In Progress"
```

## Sprint/Cycle Management

### Planning a New Cycle

```
Step 1: Review backlog
─────────────────────
Use: list_issues

team: "Frontend"
state: "Backlog"
priority: [1, 2]  # High priority items
orderBy: "priority"
limit: 50
```

```
Step 2: Get current cycle
────────────────────────
Use: list_cycles

teamId: "[team-id]"
type: "current"
```

```
Step 3: Move selected issues to cycle
────────────────────────────────────
Use: update_issue

id: "[issue-id]"
cycle: "[cycle-id-or-name]"
state: "Todo"
```

```
Step 4: Assign and balance workload
──────────────────────────────────
# Review team capacity
Use: list_issues

team: "Frontend"
cycle: "[current-cycle]"
assignee: "dev-1"

# Adjust assignments
Use: update_issue

id: "[issue-id]"
assignee: "dev-2"
```

### Mid-Cycle Check-in

**Cycle progress**:
```
Use: list_issues

team: "Frontend"
cycle: "[current-cycle]"
state: "Done"
```

**Burndown tracking**:
```
# Total issues in cycle
Use: list_issues
team: "Frontend"
cycle: "[current-cycle]"

# Completed
state: "Done"

# In Progress
state: "In Progress"

# Not started
state: "Todo"
```

**At-risk items**:
```
Use: list_issues

team: "Frontend"
cycle: "[current-cycle]"
state: ["Todo", "In Progress"]
priority: 1  # Urgent
```

### Cycle Retrospective

**Completed work**:
```
Use: list_issues

team: "Frontend"
cycle: "[cycle-name]"
state: "Done"
orderBy: "updatedAt"
limit: 100
```

**Incomplete work (move to next cycle)**:
```
Use: list_issues

team: "Frontend"
cycle: "[cycle-name]"
state: ["Todo", "In Progress"]

# Move to next cycle
Use: update_issue
id: "[issue-id]"
cycle: "[next-cycle-id]"
```

## GitHub Integration

### Branch Naming

Use Linear's suggested git branch names:

```
Use: get_issue

id: "[issue-id]"

Returns: gitBranchName: "cetiaiservices/cet-95-feature-name"

$ git checkout -b cetiaiservices/cet-95-feature-name
```

### Commit Messages

Reference Linear issues in commits:

```bash
# Pattern: ISSUE-ID: Description
git commit -m "CET-95: Add user authentication"
git commit -m "CET-96: Fix login form validation"
```

### Pull Request Integration

**Automatic PR linking**:
- Create PR from Linear branch
- Linear automatically detects and links PR
- PR status updates Linear issue status

**Manual PR linking**:
```
Use: update_issue

id: "[issue-id]"
links: [
  {
    url: "https://github.com/org/repo/pull/123",
    title: "PR: Feature implementation"
  }
]
```

### Deployment Tracking

**Add deployment link after deploy**:
```
Use: create_comment

issueId: "[issue-id]"
body: |
  ## Deployed ✅

  **Environment:** Production
  **URL:** https://app.example.com
  **Deployed at:** 2025-01-15 14:30 UTC
  **Commit:** abc123def

  **Verified:**
  - ✅ Feature working as expected
  - ✅ No errors in logs
  - ✅ Performance within targets
```

## Advanced Workflows

### Bug Triage Process

```
Step 1: Create bug with template
───────────────────────────────
Use: create_issue

title: "[BUG] Login fails with OAuth providers"
team: "Backend"
description: |
  ## Bug Description
  OAuth login (Google, GitHub) returning 500 error

  ## Environment
  - Browser: Chrome 120
  - OS: macOS 14
  - Version: 1.2.3

  ## Steps to Reproduce
  1. Click "Login with Google"
  2. Authorize in Google popup
  3. Redirect back to app
  4. 500 error appears

  ## Expected Behavior
  User should be logged in

  ## Actual Behavior
  500 Internal Server Error

  ## Logs
  ```
  [ERROR] OAuth callback failed: Invalid state parameter
  ```

  ## Screenshots
  [Attach screenshots]

labels: ["bug", "needs-triage", "oauth"]
priority: 1  # High - blocking users
```

```
Step 2: Triage and assign
────────────────────────
Use: update_issue

id: "[bug-id]"
state: "Todo"
assignee: "backend-auth-expert"
priority: 1
labels: ["bug", "oauth", "p1-critical"]
```

```
Step 3: Investigation
────────────────────
Use: create_comment

issueId: "[bug-id]"
body: |
  ## Investigation

  **Root cause:** State parameter mismatch between
  initiation and callback

  **Affected:** Google and GitHub OAuth only
  **Impact:** ~30% of login attempts

  **Fix approach:** Update state validation logic
```

```
Step 4: Fix and verify
─────────────────────
Use: update_issue

id: "[bug-id]"
state: "Done"

Use: create_comment
body: |
  ## Fixed ✅

  **PR:** #456
  **Fix:** Updated OAuth state validation
  **Testing:** 100 test logins successful
  **Deployed:** Production

  **Verification:**
  - ✅ Google OAuth working
  - ✅ GitHub OAuth working
  - ✅ Error rate: 0%
```

### Release Management

**Create release tracking issue**:
```
Use: create_issue

title: "[RELEASE] v2.0.0 - Major Feature Release"
team: "Engineering"
description: |
  ## Release Information
  - Version: 2.0.0
  - Target Date: March 15, 2025
  - Type: Major release

  ## Features Included
  - [ ] User dashboard redesign (CET-45)
  - [ ] Real-time notifications (CET-67)
  - [ ] Dark mode support (CET-78)
  - [ ] Performance improvements (CET-89)

  ## Pre-Release Checklist
  - [ ] All features complete
  - [ ] QA testing passed
  - [ ] Performance benchmarks met
  - [ ] Documentation updated
  - [ ] Migration scripts ready
  - [ ] Rollback plan documented

  ## Deployment Plan
  1. Deploy to staging (March 13)
  2. Stakeholder review (March 14)
  3. Deploy to production (March 15, 6 AM UTC)
  4. Monitor for 24 hours

  ## Rollback Procedure
  Previous version: v1.9.5
  Rollback time: < 5 minutes
  [Link to rollback docs]

labels: ["release", "v2.0.0"]
priority: 1
dueDate: "2025-03-15"
```

### Performance Tracking

**Create performance issue**:
```
Use: create_issue

title: "[Performance] Dashboard load time optimization"
team: "Frontend"
description: |
  ## Current Performance
  - Load time: 4.2s
  - First Contentful Paint: 2.1s
  - Largest Contentful Paint: 3.8s

  ## Targets
  - Load time: < 2s (50% improvement)
  - FCP: < 1s
  - LCP: < 2s

  ## Optimization Tasks
  - [ ] Code splitting by route
  - [ ] Image lazy loading
  - [ ] Bundle size reduction
  - [ ] Server-side rendering
  - [ ] Cache optimization

  ## Metrics Tracking
  Will update with benchmark results

labels: ["performance", "optimization"]
priority: 2
```

**Update with results**:
```
Use: create_comment

issueId: "[perf-issue-id]"
body: |
  ## Performance Results 📊

  ### Before
  - Load time: 4.2s
  - FCP: 2.1s
  - LCP: 3.8s
  - Bundle: 850 KB

  ### After
  - Load time: 1.8s ✅ (57% improvement)
  - FCP: 0.9s ✅
  - LCP: 1.7s ✅
  - Bundle: 420 KB ✅ (51% reduction)

  ### Optimizations Applied
  - Code splitting: -200 KB
  - Image optimization: -150 KB
  - Tree shaking: -80 KB

  **All targets met!**
```

## Best Practices

### Issue Creation

**Good Issue Title**:
```
✅ "Add user profile edit functionality"
✅ "[Bug] Login form validation fails on mobile"
✅ "[Frontend] Implement dark mode toggle"

❌ "Fix bug"
❌ "Update stuff"
❌ "Make it work"
```

**Good Issue Description**:
```
## Overview
Clear explanation of what and why

## Tasks
- [ ] Specific, actionable task 1
- [ ] Specific, actionable task 2

## Acceptance Criteria
- Clear definition of "done"
- Measurable outcomes
- Edge cases considered

## Resources
- Link to designs
- Link to documentation
- Related issues
```

### Label Strategy

**Recommended taxonomy**:
```
Type:
- feature
- bug
- improvement
- docs
- refactor
- test

Priority:
- p0-critical
- p1-high
- p2-medium
- p3-low

Area:
- frontend
- backend
- mobile
- devops
- design

Status:
- blocked
- ready-for-dev
- needs-review
- waiting-on-qa

Technology:
- react
- typescript
- python
- flutter
- postgres
```

### Comment Guidelines

**Effective comments**:
```
✅ Provide context and decisions
✅ Document blockers and solutions
✅ Update stakeholders on progress
✅ Link to relevant resources
✅ Use formatting for clarity

❌ "Working on it"
❌ "Done"
❌ Duplicate information from commits
```

### Project Updates

**Weekly project update template**:
```
Use: update_project

description: |
  # [Project Name]

  ## Status: [On Track / At Risk / Blocked]
  **Week X of Y**

  ## This Week
  - ✅ Completed item 1
  - ✅ Completed item 2
  - 🔄 In progress item 3

  ## Next Week
  - Planned item 1
  - Planned item 2

  ## Metrics
  - Issues completed: X/Y (Z%)
  - On schedule: Yes/No

  ## Risks
  - Risk 1: Description and mitigation

  [Original project description preserved below]
```

This comprehensive guide covers the essential Linear workflows for accelerated software development. Use it as a reference for setting up projects, managing daily work, coordinating teams, and maintaining best practices.
