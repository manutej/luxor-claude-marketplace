# Frontend Project Setup Example

Complete workflow for setting up a new React frontend project in Linear.

## Step 1: Create the Project

```
Tool: create_project

Parameters:
name: "E-Commerce Frontend Redesign"
team: "Frontend"
summary: "Complete UI/UX redesign of e-commerce platform with modern React architecture"
description: |
  # E-Commerce Frontend Redesign

  ## Project Goals
  - Modernize UI/UX with contemporary design system
  - Improve performance (target: < 2s load time)
  - Implement responsive design for mobile/tablet
  - Add dark mode support
  - Improve accessibility (WCAG 2.1 AA compliance)

  ## Tech Stack
  - React 18 with TypeScript
  - Tailwind CSS for styling
  - Zustand for state management
  - React Query for data fetching
  - Vite for build tooling

  ## Timeline
  - Q1 2025: Planning & Architecture (Weeks 1-2)
  - Q1 2025: Core Components (Weeks 3-6)
  - Q2 2025: Feature Implementation (Weeks 7-10)
  - Q2 2025: Testing & Polish (Weeks 11-12)

  ## Success Metrics
  - Lighthouse score > 90
  - Core Web Vitals in "Good" range
  - Zero critical accessibility issues
  - 50% reduction in bundle size
lead: "me"
priority: 2
startDate: "2025-01-15"
targetDate: "2025-04-15"
labels: ["frontend", "redesign", "react"]
```

## Step 2: Create Foundation Issues

### Architecture & Setup

```
Tool: create_issue

Issue 1 - Project Setup:
title: "Setup React + TypeScript + Vite project"
team: "Frontend"
description: |
  ## Tasks
  - [ ] Initialize Vite project with React + TS template
  - [ ] Configure ESLint and Prettier
  - [ ] Setup Tailwind CSS
  - [ ] Configure path aliases
  - [ ] Setup Git hooks with Husky
  - [ ] Configure environment variables

  ## Acceptance Criteria
  - Project builds successfully
  - Linting and formatting work
  - Hot reload functions correctly
  - Sample page renders
assignee: "me"
project: "E-Commerce Frontend Redesign"
labels: ["setup", "infrastructure", "frontend"]
priority: 1
```

```
Issue 2 - Design System:
title: "Implement design system foundation"
team: "Frontend"
description: |
  ## Overview
  Create reusable design system components and tokens

  ## Tasks
  - [ ] Define color palette (light/dark modes)
  - [ ] Setup typography scale
  - [ ] Create spacing and sizing tokens
  - [ ] Build primitive components (Button, Input, Card)
  - [ ] Document components in Storybook
  - [ ] Setup design tokens export

  ## Resources
  - Figma: [link to design file]

  ## Acceptance Criteria
  - All primitive components documented
  - Dark mode variants work correctly
  - Accessibility features included
  - Storybook deployed
assignee: "designer-name"
project: "E-Commerce Frontend Redesign"
labels: ["design-system", "ui", "frontend"]
priority: 2
```

## Step 3: Create Feature Epics

### Epic 1: Product Catalog

```
Tool: create_issue

Parent Issue:
title: "[EPIC] Product Catalog Redesign"
team: "Frontend"
description: |
  ## Overview
  Redesign product browsing and discovery experience

  ## Features
  - Product grid with infinite scroll
  - Advanced filtering and sorting
  - Product quick view
  - Wishlist functionality
  - Product comparisons

  ## Design
  [Link to Figma designs]

  ## Acceptance Criteria
  - All features implemented and tested
  - Performance targets met
  - Accessibility compliant
  - Mobile responsive
project: "E-Commerce Frontend Redesign"
labels: ["epic", "product-catalog", "frontend"]
priority: 2
```

Now create child issues:

```
Tool: create_issue

Child Issue 1:
title: "Product Grid Component"
team: "Frontend"
description: |
  ## Tasks
  - [ ] Create ProductCard component
  - [ ] Implement grid layout with Tailwind
  - [ ] Add image lazy loading
  - [ ] Implement infinite scroll
  - [ ] Add loading skeletons

  ## Acceptance Criteria
  - Renders 100+ products smoothly
  - Images lazy load correctly
  - Infinite scroll works on all devices
  - Skeleton states during loading
parentId: "[epic-issue-id]"
assignee: "frontend-dev-1"
project: "E-Commerce Frontend Redesign"
labels: ["frontend", "component", "product-catalog"]
priority: 2
```

```
Child Issue 2:
title: "Product Filtering System"
team: "Frontend"
description: |
  ## Tasks
  - [ ] Create FilterPanel component
  - [ ] Implement category filters
  - [ ] Add price range slider
  - [ ] Implement rating filter
  - [ ] Add search within results
  - [ ] URL state management for filters

  ## Acceptance Criteria
  - Filters update URL query params
  - Back button works correctly
  - Filter combinations work properly
  - Mobile filter drawer implemented
parentId: "[epic-issue-id]"
assignee: "frontend-dev-2"
project: "E-Commerce Frontend Redesign"
labels: ["frontend", "filtering", "product-catalog"]
priority: 2
```

### Epic 2: Shopping Cart

```
Tool: create_issue

Parent Issue:
title: "[EPIC] Shopping Cart Experience"
team: "Frontend"
description: |
  ## Overview
  Modern shopping cart with real-time updates

  ## Features
  - Cart sidebar/drawer
  - Quantity adjustments
  - Remove items
  - Apply coupon codes
  - Shipping calculator
  - Cart persistence

  ## Acceptance Criteria
  - Cart state persists across sessions
  - Real-time price calculations
  - Optimistic updates
  - Error handling
project: "E-Commerce Frontend Redesign"
labels: ["epic", "cart", "frontend"]
priority: 1
```

## Step 4: Organize Into Cycles

### Cycle 1: Foundation (Weeks 1-2)

```
Tool: list_cycles
Parameters:
  teamId: "frontend-team-id"
  type: "current"

Then update issues:
Tool: update_issue
Parameters:
  id: "[project-setup-issue-id]"
  cycle: "[cycle-1-id]"

Repeat for:
- Project setup issue
- Design system issue
- Architecture documentation issue
```

### Cycle 2: Product Catalog (Weeks 3-4)

```
Add to cycle:
- Product Grid Component
- Product Filtering System
- Product Detail Page
- Wishlist Feature
```

### Cycle 3: Shopping & Checkout (Weeks 5-6)

```
Add to cycle:
- Cart implementation
- Checkout flow
- Payment integration
- Order confirmation
```

## Step 5: Track Progress

### Daily Stand-up Query

```
Tool: list_issues

Get my tasks:
assignee: "me"
state: "In Progress"
project: "E-Commerce Frontend Redesign"
limit: 10
```

### Sprint Review Query

```
Tool: list_issues

Completed this cycle:
project: "E-Commerce Frontend Redesign"
state: "Done"
orderBy: "updatedAt"
limit: 50
```

### Blocked Issues Query

```
Tool: list_issues

Find blockers:
project: "E-Commerce Frontend Redesign"
label: "blocked"
state: "In Progress"
```

## Step 6: Issue Updates During Development

### Starting Work

```
Tool: update_issue

Parameters:
  id: "[issue-id]"
  state: "In Progress"
  assignee: "me"
```

### Adding Progress Comments

```
Tool: create_comment

Parameters:
  issueId: "[issue-id]"
  body: |
    ## Progress Update

    ### Completed
    - ✅ Created ProductCard component
    - ✅ Implemented grid layout
    - ✅ Added image lazy loading

    ### In Progress
    - 🔄 Implementing infinite scroll
    - 🔄 Adding skeleton loading states

    ### Blockers
    - Waiting on image CDN configuration

    ### Next Steps
    - Complete infinite scroll
    - Add unit tests
    - Performance optimization
```

### Linking PR

```
Tool: update_issue

Parameters:
  id: "[issue-id]"
  state: "In Review"
  links: [
    {
      url: "https://github.com/company/ecommerce/pull/123",
      title: "PR: Product Grid Component"
    }
  ]
```

### Completing Issue

```
Tool: update_issue

Parameters:
  id: "[issue-id]"
  state: "Done"
```

```
Tool: create_comment

Parameters:
  issueId: "[issue-id]"
  body: |
    ## Completion Summary

    ✅ All acceptance criteria met
    ✅ PR merged: #123
    ✅ Deployed to staging: https://staging.example.com
    ✅ QA approved

    ### Metrics
    - Bundle size: +12KB (within budget)
    - Lighthouse: 95/100
    - Test coverage: 87%

    ### Documentation
    - Storybook: https://storybook.example.com/product-grid
    - Component docs updated
```

## Step 7: Project-Level Updates

### Weekly Project Update

```
Tool: update_project

Parameters:
  id: "[project-id]"
  description: |
    # E-Commerce Frontend Redesign

    ## Status: On Track ✅
    **Week 4 of 12 - End of Cycle 2**

    ## Progress
    - Product Catalog: 75% complete
    - Design System: 100% complete
    - Shopping Cart: 25% complete

    ## Completed This Week
    - ✅ Product Grid Component
    - ✅ Filtering System
    - ✅ Product Quick View

    ## Next Week
    - Cart Drawer Component
    - Checkout Flow Design
    - Payment Integration Planning

    ## Metrics
    - Issues Completed: 12/45 (27%)
    - On Schedule: Yes
    - Performance: Meeting targets

    ## Risks
    - ⚠️ Waiting on API updates for wishlist feature
    - Mitigation: Mock API ready, can proceed

    [Previous content preserved...]
```

## Result

After this setup, you have:

- 1 Well-defined project
- 2-3 Epic issues (parent issues)
- 15-20 Feature issues (child issues)
- Clear ownership and assignments
- Organized into 3-4 cycles
- Tracking structure in place
- Ready to start development with full visibility

## Tips

1. **Create issues in batches**: Don't create all at once, add as you learn
2. **Update regularly**: Keep Linear current with development status
3. **Use comments**: Document decisions and context
4. **Link everything**: PRs, docs, designs, deployments
5. **Review weekly**: Update project description with status
6. **Celebrate wins**: Mark milestones and completed features
