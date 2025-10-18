# CI/CD Pipeline Patterns

> Comprehensive guide to building production-ready CI/CD pipelines with GitHub Actions

## Overview

This skill provides comprehensive patterns and best practices for implementing continuous integration and continuous deployment pipelines using GitHub Actions. Master workflow automation, testing strategies, deployment patterns, and release management for modern software delivery.

## Quick Start

### Basic CI Pipeline

Create `.github/workflows/ci.yml`:

```yaml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linting
        run: npm run lint

      - name: Run tests
        run: npm test

      - name: Build project
        run: npm run build
```

### Basic CD Pipeline

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Deploy to production
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
        run: npm run deploy
```

## Core Features

### Workflow Triggers

Configure when your pipelines run:

- **Push events**: On code commits to specific branches
- **Pull requests**: On PR creation/updates
- **Schedules**: Cron-based periodic runs
- **Manual triggers**: workflow_dispatch for on-demand execution
- **Release events**: On GitHub release creation
- **Workflow calls**: Reusable workflow invocation

### Testing Strategies

Comprehensive testing in CI:

- **Unit tests**: Fast, isolated component tests
- **Integration tests**: Multi-component interaction tests
- **E2E tests**: Full application workflow testing
- **Performance tests**: Load and benchmark testing
- **Security scans**: Vulnerability and dependency audits
- **Code coverage**: Track and enforce coverage thresholds

### Deployment Patterns

Production-ready deployment strategies:

- **Blue-Green**: Zero-downtime deployments with instant rollback
- **Canary**: Gradual rollout to subset of users
- **Rolling**: Sequential instance updates
- **Multi-environment**: Staged deployments (dev → staging → production)

### Build Optimization

Speed up your pipelines:

- **Dependency caching**: Cache npm, pip, maven, etc.
- **Docker layer caching**: Reuse unchanged Docker layers
- **Parallel jobs**: Run independent tasks simultaneously
- **Matrix builds**: Test across multiple configurations
- **Conditional execution**: Skip unnecessary steps

## Common Workflows

### Node.js Application

```yaml
name: Node.js CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node-version: [18, 20, 22]

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - run: npm ci
      - run: npm test
      - run: npm run build
```

### Docker Build and Push

```yaml
name: Docker Build

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  docker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            myorg/myapp:latest
            myorg/myapp:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Python Application

```yaml
name: Python CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.9', '3.10', '3.11', '3.12']

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-dev.txt

      - name: Run linting
        run: |
          flake8 .
          black --check .
          mypy .

      - name: Run tests
        run: pytest --cov=. --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: ./coverage.xml
```

## Security Best Practices

### Secret Management

Never hardcode secrets in workflows:

```yaml
# ❌ Bad
- run: curl -H "Authorization: Bearer abc123" api.example.com

# ✅ Good
- run: curl -H "Authorization: Bearer $TOKEN" api.example.com
  env:
    TOKEN: ${{ secrets.API_TOKEN }}
```

### OIDC Authentication

Use short-lived tokens instead of long-lived credentials:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read

    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/GitHubActions
          aws-region: us-east-1

      - run: aws s3 sync ./dist s3://my-bucket
```

### Minimal Permissions

Restrict workflow permissions to minimum required:

```yaml
permissions:
  contents: read      # Read code
  pull-requests: write # Comment on PRs
  id-token: write     # Generate OIDC tokens
```

### Pin Action Versions

Use commit SHAs for immutable references:

```yaml
# Less secure (tag can be moved)
- uses: actions/checkout@v4

# More secure (immutable)
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
```

## Advanced Patterns

### Reusable Workflows

Create shareable workflow templates:

```yaml
# .github/workflows/reusable-test.yml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      node-version:
        required: false
        type: string
        default: '20'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
      - run: npm ci && npm test
```

**Usage:**
```yaml
jobs:
  test-app:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: '20'
```

### Monorepo CI/CD

Detect and build only affected packages:

```yaml
jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      packages: ${{ steps.filter.outputs.changes }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v3
        id: filter
        with:
          filters: |
            frontend:
              - 'packages/frontend/**'
            backend:
              - 'packages/backend/**'

  build:
    needs: detect-changes
    if: needs.detect-changes.outputs.packages != '[]'
    strategy:
      matrix:
        package: ${{ fromJson(needs.detect-changes.outputs.packages) }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run build --workspace=${{ matrix.package }}
```

### Release Automation

Automatically version and release based on commits:

```yaml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - run: npm ci

      - name: Semantic Release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
        run: npx semantic-release
```

## Deployment Targets

### AWS

Deploy to various AWS services:

```yaml
# S3 Static Site
- name: Deploy to S3
  run: aws s3 sync ./dist s3://my-bucket --delete

# ECS Service
- name: Update ECS service
  run: |
    aws ecs update-service \
      --cluster my-cluster \
      --service my-service \
      --force-new-deployment

# Lambda Function
- name: Deploy Lambda
  run: |
    aws lambda update-function-code \
      --function-name my-function \
      --zip-file fileb://function.zip
```

### Vercel

```yaml
- name: Deploy to Vercel
  uses: amondnet/vercel-action@v25
  with:
    vercel-token: ${{ secrets.VERCEL_TOKEN }}
    vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
    vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
    vercel-args: '--prod'
```

### Netlify

```yaml
- name: Deploy to Netlify
  uses: nwtgck/actions-netlify@v3
  with:
    publish-dir: './dist'
    production-branch: main
    github-token: ${{ secrets.GITHUB_TOKEN }}
  env:
    NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
    NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

### Kubernetes

```yaml
- name: Deploy to Kubernetes
  run: |
    kubectl set image deployment/myapp \
      myapp=myregistry/myapp:${{ github.sha }}
    kubectl rollout status deployment/myapp
```

## Performance Tips

### 1. Cache Dependencies

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'  # Automatically caches npm dependencies
```

### 2. Parallel Jobs

```yaml
jobs:
  # These run in parallel
  lint:
    runs-on: ubuntu-latest
    steps:
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    steps:
      - run: npm test

  build:
    runs-on: ubuntu-latest
    steps:
      - run: npm run build
```

### 3. Skip Redundant Runs

```yaml
on:
  push:
    paths-ignore:
      - 'docs/**'
      - '**.md'
      - '.github/ISSUE_TEMPLATE/**'
```

### 4. Use Sparse Checkout

```yaml
- uses: actions/checkout@v4
  with:
    sparse-checkout: |
      src/
      package.json
    sparse-checkout-cone-mode: false
```

### 5. Optimize Docker Builds

```yaml
- uses: docker/build-push-action@v5
  with:
    context: .
    cache-from: type=gha
    cache-to: type=gha,mode=max
    platforms: linux/amd64  # Build single platform if multi-arch not needed
```

## Troubleshooting

### Common Issues

**Slow builds**
- Enable caching for dependencies
- Use parallel jobs
- Optimize Docker layer caching
- Consider self-hosted runners

**Failed deployments**
- Add retry logic for transient failures
- Implement health checks before marking complete
- Use deployment protection rules
- Set appropriate timeouts

**Secret access issues**
- Verify secret names match exactly
- Check environment-scoped secrets
- Ensure workflow has necessary permissions
- Use OIDC instead of long-lived credentials

**Workflow not triggering**
- Check branch/path filters
- Verify workflow syntax is valid
- Ensure `.github/workflows/` location is correct
- Check if workflow is disabled

## Best Practices Checklist

- [ ] Use dependency caching to speed up builds
- [ ] Run jobs in parallel when possible
- [ ] Pin action versions to SHAs for security
- [ ] Use OIDC for cloud authentication
- [ ] Implement proper secret management
- [ ] Add health checks to deployments
- [ ] Set up deployment environments with protection rules
- [ ] Configure status checks to prevent bad merges
- [ ] Use matrix builds for multi-platform testing
- [ ] Implement automatic rollback on deployment failure
- [ ] Add code coverage reporting
- [ ] Set up security scanning (dependencies, containers)
- [ ] Use reusable workflows for common patterns
- [ ] Configure notifications for failed deployments
- [ ] Document deployment process and runbooks

## Resources

### Official Documentation
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)

### Tools and Actions
- [actions/checkout](https://github.com/actions/checkout) - Check out repository
- [actions/setup-node](https://github.com/actions/setup-node) - Setup Node.js
- [docker/build-push-action](https://github.com/docker/build-push-action) - Build Docker images
- [codecov/codecov-action](https://github.com/codecov/codecov-action) - Upload coverage

### Learning Resources
- [GitHub Skills](https://skills.github.com/) - Interactive tutorials
- [Awesome Actions](https://github.com/sdras/awesome-actions) - Curated list
- [GitHub Actions Toolkit](https://github.com/actions/toolkit) - Build custom actions

## Examples

See [EXAMPLES.md](./EXAMPLES.md) for detailed, production-ready workflow examples including:

- Complete Node.js CI/CD pipeline
- Docker multi-stage build and deployment
- Multi-environment deployment with approvals
- Monorepo CI/CD with Turborepo
- Kubernetes blue-green deployment
- Terraform infrastructure deployment
- Semantic versioning and release automation
- And many more...

---

**Version**: 1.0.0
**Last Updated**: October 2025
**Maintained By**: Claude Skills Team
