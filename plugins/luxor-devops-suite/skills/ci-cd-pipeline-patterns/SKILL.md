---
name: ci-cd-pipeline-patterns
description: Comprehensive CI/CD pipeline patterns skill covering GitHub Actions, workflows, automation, testing, deployment strategies, and release management for modern software delivery
---

# CI/CD Pipeline Patterns

A comprehensive skill for designing, implementing, and optimizing CI/CD pipelines using GitHub Actions and modern DevOps practices. Master workflow automation, testing strategies, deployment patterns, and release management for continuous software delivery.

## When to Use This Skill

Use this skill when:

- Setting up continuous integration and deployment pipelines for projects
- Automating build, test, and deployment workflows
- Implementing multi-environment deployment strategies (staging, production)
- Managing release automation and versioning
- Configuring matrix builds for multi-platform testing
- Securing CI/CD pipelines with secrets and OIDC
- Optimizing pipeline performance with caching and parallelization
- Building containerized applications with Docker in CI
- Deploying to cloud platforms (AWS, Azure, GCP, Vercel, Netlify)
- Implementing infrastructure as code with Terraform/CloudFormation
- Setting up monorepo CI/CD patterns
- Creating reusable workflow templates and custom actions
- Implementing deployment strategies (blue-green, canary, rolling)
- Automating changelog generation and semantic versioning
- Integrating quality gates and code coverage checks

## Core Concepts

### CI/CD Fundamentals

**Continuous Integration (CI)**: Automatically building and testing code changes as developers commit to the repository.

**Continuous Deployment (CD)**: Automatically deploying code changes to production after passing tests.

**Continuous Delivery**: Keeping code in a deployable state, with manual approval for production deployment.

### GitHub Actions Architecture

GitHub Actions provides event-driven automation directly integrated with your repository.

#### Workflows

YAML files in `.github/workflows/` that define automated processes:

```yaml
name: CI Pipeline
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build project
        run: npm run build
```

**Key Components:**
- **name**: Human-readable workflow name
- **on**: Events that trigger the workflow (push, pull_request, schedule, workflow_dispatch)
- **jobs**: Collection of steps that run in sequence or parallel
- **runs-on**: The runner environment (ubuntu-latest, windows-latest, macos-latest)

#### Jobs

Groups of steps executed on the same runner:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test

  deploy:
    needs: test  # Runs after 'test' job completes
    runs-on: ubuntu-latest
    steps:
      - run: npm run deploy
```

**Job Features:**
- **needs**: Define job dependencies (sequential execution)
- **if**: Conditional execution based on expressions
- **strategy**: Matrix builds for multiple configurations
- **outputs**: Share data between jobs
- **environment**: Deployment environments with protection rules

#### Steps

Individual tasks within a job:

```yaml
steps:
  - name: Checkout code
    uses: actions/checkout@v4

  - name: Setup Node.js
    uses: actions/setup-node@v4
    with:
      node-version: '20'

  - name: Install dependencies
    run: npm ci

  - name: Run tests
    run: npm test
```

**Step Types:**
- **uses**: Run a pre-built action from marketplace or repository
- **run**: Execute shell commands
- **with**: Provide inputs to actions
- **env**: Set environment variables for the step

#### Actions

Reusable units of code that perform specific tasks:

**Official Actions:**
- `actions/checkout@v4`: Check out repository code
- `actions/setup-node@v4`: Setup Node.js environment
- `actions/cache@v4`: Cache dependencies
- `actions/upload-artifact@v4`: Upload build artifacts
- `actions/download-artifact@v4`: Download artifacts from previous jobs

**Marketplace Actions:**
- `docker/build-push-action@v5`: Build and push Docker images
- `aws-actions/configure-aws-credentials@v4`: Configure AWS credentials
- `codecov/codecov-action@v4`: Upload code coverage
- `google-github-actions/auth@v2`: Authenticate with Google Cloud

#### Secrets and Variables

**Secrets**: Encrypted sensitive data (API keys, credentials, tokens)

```yaml
steps:
  - name: Deploy to production
    env:
      API_KEY: ${{ secrets.API_KEY }}
      DATABASE_URL: ${{ secrets.DATABASE_URL }}
    run: npm run deploy
```

**Variables**: Non-sensitive configuration data

```yaml
env:
  NODE_ENV: ${{ vars.NODE_ENV }}
  API_ENDPOINT: ${{ vars.API_ENDPOINT }}
```

**Secret Types:**
- **Repository secrets**: Available to all workflows in a repository
- **Environment secrets**: Scoped to specific environments (production, staging)
- **Organization secrets**: Shared across repositories in an organization

#### Artifacts

Files produced by workflows that can be downloaded or used by other jobs:

```yaml
- name: Upload build artifacts
  uses: actions/upload-artifact@v4
  with:
    name: dist-files
    path: dist/
    retention-days: 7

- name: Download artifacts
  uses: actions/download-artifact@v4
  with:
    name: dist-files
    path: ./dist
```

### Workflow Triggers

#### Event Triggers

**Push Events:**
```yaml
on:
  push:
    branches:
      - main
      - develop
      - 'release/**'
    paths:
      - 'src/**'
      - 'package.json'
    tags:
      - 'v*'
```

**Pull Request Events:**
```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened]
    branches:
      - main
    paths-ignore:
      - 'docs/**'
      - '**.md'
```

**Schedule (Cron):**
```yaml
on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight UTC
    - cron: '0 */6 * * *'  # Every 6 hours
```

**Manual Triggers (workflow_dispatch):**
```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        type: choice
        options:
          - staging
          - production
      version:
        description: 'Version to deploy'
        required: true
        type: string
```

**Release Events:**
```yaml
on:
  release:
    types: [published, created, released]
```

**Workflow Call (Reusable Workflows):**
```yaml
on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
    secrets:
      api-key:
        required: true
```

### Matrix Builds

Run jobs across multiple configurations in parallel:

```yaml
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node-version: [18, 20, 22]
        include:
          - os: ubuntu-latest
            node-version: 20
            coverage: true
        exclude:
          - os: macos-latest
            node-version: 18
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm test
      - if: matrix.coverage
        run: npm run coverage
```

**Matrix Features:**
- **Parallel execution**: All combinations run simultaneously
- **include**: Add specific configurations
- **exclude**: Remove specific combinations
- **fail-fast**: Stop all jobs if one fails (default: true)
- **max-parallel**: Limit concurrent jobs

### Caching Strategies

Speed up workflows by caching dependencies:

**Node.js Caching:**
```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'  # Automatically caches npm dependencies
```

**Custom Caching:**
```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/.npm
      ~/.cache
      node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

**Docker Layer Caching:**
```yaml
- uses: docker/build-push-action@v5
  with:
    context: .
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

## Testing Strategies in CI

### Unit Testing

Fast, isolated tests for individual components:

```yaml
jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run unit tests
        run: npm run test:unit -- --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          files: ./coverage/coverage-final.json
          flags: unit-tests
          token: ${{ secrets.CODECOV_TOKEN }}
```

### Integration Testing

Test interactions between components and services:

```yaml
jobs:
  integration-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Run database migrations
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
        run: npm run migrate

      - name: Run integration tests
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
          REDIS_URL: redis://localhost:6379
        run: npm run test:integration
```

### End-to-End Testing

Test complete user workflows:

```yaml
jobs:
  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Build application
        run: npm run build

      - name: Install Playwright browsers
        run: npx playwright install --with-deps

      - name: Run E2E tests
        run: npm run test:e2e

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30
```

### Performance Testing

Benchmark and performance regression testing:

```yaml
jobs:
  performance-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Build for production
        run: npm run build

      - name: Run Lighthouse CI
        uses: treosh/lighthouse-ci-action@v11
        with:
          urls: |
            http://localhost:3000
            http://localhost:3000/dashboard
          uploadArtifacts: true
          temporaryPublicStorage: true

      - name: Run load tests
        run: npm run test:load
```

### Code Quality and Linting

Enforce code standards and quality gates:

```yaml
jobs:
  code-quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Run ESLint
        run: npm run lint

      - name: Run Prettier check
        run: npm run format:check

      - name: Run TypeScript check
        run: npm run type-check

      - name: Run security audit
        run: npm audit --audit-level=moderate

      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

## Deployment Patterns

### Blue-Green Deployment

Zero-downtime deployment by maintaining two identical environments:

```yaml
jobs:
  deploy-blue-green:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Green environment
        run: |
          # Deploy new version to green environment
          ./deploy.sh green

      - name: Run smoke tests on Green
        run: |
          # Verify green environment is healthy
          curl -f https://green.example.com/health

      - name: Switch traffic to Green
        run: |
          # Update load balancer to point to green
          aws elbv2 modify-rule --rule-arn $RULE_ARN \
            --actions Type=forward,TargetGroupArn=$GREEN_TG

      - name: Monitor Green environment
        run: |
          # Monitor for 5 minutes
          ./monitor.sh green 300

      - name: Rollback if needed
        if: failure()
        run: |
          # Switch back to blue
          aws elbv2 modify-rule --rule-arn $RULE_ARN \
            --actions Type=forward,TargetGroupArn=$BLUE_TG
```

### Canary Deployment

Gradual rollout to a subset of users:

```yaml
jobs:
  canary-deployment:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy canary (10% traffic)
        run: |
          kubectl set image deployment/app app=myapp:${{ github.sha }}
          kubectl scale deployment/app-canary --replicas=1
          kubectl annotate service app-service \
            traffic-split='{"canary": 10, "stable": 90}'

      - name: Monitor canary metrics
        run: |
          # Monitor error rates, latency for 15 minutes
          ./monitor-canary.sh 900

      - name: Increase canary traffic (50%)
        run: |
          kubectl annotate service app-service \
            traffic-split='{"canary": 50, "stable": 50}' --overwrite

      - name: Monitor again
        run: ./monitor-canary.sh 600

      - name: Full rollout (100%)
        run: |
          kubectl set image deployment/app-stable app=myapp:${{ github.sha }}
          kubectl scale deployment/app-canary --replicas=0

      - name: Rollback canary
        if: failure()
        run: |
          kubectl scale deployment/app-canary --replicas=0
```

### Rolling Deployment

Sequential update of instances:

```yaml
jobs:
  rolling-deployment:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy with rolling update
        run: |
          kubectl set image deployment/app \
            app=myapp:${{ github.sha }} \
            --record

      - name: Wait for rollout to complete
        run: |
          kubectl rollout status deployment/app --timeout=10m

      - name: Verify deployment
        run: |
          kubectl get pods -l app=myapp
          curl -f https://api.example.com/health

      - name: Rollback on failure
        if: failure()
        run: |
          kubectl rollout undo deployment/app
```

### Multi-Environment Deployment

Deploy to staging, then production with approvals:

```yaml
jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: https://staging.example.com
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to staging
        run: ./deploy.sh staging

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to production
        run: ./deploy.sh production
```

## Security Best Practices

### Secret Management

**Using GitHub Secrets:**
```yaml
steps:
  - name: Configure AWS credentials
    uses: aws-actions/configure-aws-credentials@v4
    with:
      aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
      aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      aws-region: us-east-1
```

**Environment-Scoped Secrets:**
```yaml
jobs:
  deploy:
    environment: production  # Uses production-scoped secrets
    steps:
      - name: Deploy
        env:
          API_KEY: ${{ secrets.PRODUCTION_API_KEY }}
        run: ./deploy.sh
```

### OIDC (OpenID Connect)

Authenticate without long-lived credentials:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
          aws-region: us-east-1

      - name: Deploy to AWS
        run: aws s3 sync ./dist s3://my-bucket
```

**Google Cloud OIDC:**
```yaml
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: 'projects/123/locations/global/workloadIdentityPools/pool/providers/provider'
    service_account: 'github-actions@project.iam.gserviceaccount.com'
```

### Secure Workflows

**Restrict permissions:**
```yaml
permissions:
  contents: read      # Read repository contents
  pull-requests: write # Comment on PRs
  id-token: write     # OIDC token generation
  actions: read       # Read workflow runs
```

**Pin action versions to SHA:**
```yaml
# Less secure (tag can be moved)
- uses: actions/checkout@v4

# More secure (immutable SHA)
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
```

**Prevent script injection:**
```yaml
# Vulnerable to injection
- run: echo "Hello ${{ github.event.issue.title }}"

# Safe approach
- run: echo "Hello $TITLE"
  env:
    TITLE: ${{ github.event.issue.title }}
```

## Docker in CI/CD

### Building Docker Images

```yaml
jobs:
  build-docker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: myorg/myapp
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix={{branch}}-

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Multi-Stage Docker Builds

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./
EXPOSE 3000
CMD ["npm", "start"]
```

### Container Scanning

```yaml
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: 'myorg/myapp:${{ github.sha }}'
    format: 'sarif'
    output: 'trivy-results.sarif'

- name: Upload Trivy results to GitHub Security
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: 'trivy-results.sarif'
```

## Release Automation

### Semantic Versioning

Automatically version releases based on commit messages:

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Semantic Release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
        run: npx semantic-release
```

**Configuration (.releaserc.json):**
```json
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/npm",
    "@semantic-release/github",
    ["@semantic-release/git", {
      "assets": ["CHANGELOG.md", "package.json"],
      "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
    }]
  ]
}
```

### Changelog Generation

```yaml
- name: Generate changelog
  uses: mikepenz/release-changelog-builder-action@v4
  with:
    configuration: '.github/changelog-config.json'
    outputFile: 'CHANGELOG.md'
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

- name: Create GitHub Release
  uses: ncipollo/release-action@v1
  with:
    tag: ${{ steps.version.outputs.tag }}
    name: Release ${{ steps.version.outputs.tag }}
    bodyFile: 'CHANGELOG.md'
    artifacts: 'dist/*'
```

### Release Notes Automation

```yaml
- name: Build Release Notes
  id: release_notes
  uses: mikepenz/release-changelog-builder-action@v4
  with:
    configurationJson: |
      {
        "categories": [
          {
            "title": "## 🚀 Features",
            "labels": ["feature", "enhancement"]
          },
          {
            "title": "## 🐛 Fixes",
            "labels": ["bug", "fix"]
          },
          {
            "title": "## 📝 Documentation",
            "labels": ["documentation"]
          }
        ]
      }
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Monorepo CI/CD Patterns

### Path-Based Triggers

Run workflows only when specific packages change:

```yaml
name: Frontend CI
on:
  push:
    paths:
      - 'packages/frontend/**'
      - 'package.json'
      - 'pnpm-lock.yaml'

jobs:
  test-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Test frontend
        run: pnpm --filter frontend test
```

### Affected Package Detection

```yaml
jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      affected: ${{ steps.affected.outputs.packages }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Detect affected packages
        id: affected
        run: |
          # Use tools like Nx or Turborepo to detect changes
          AFFECTED=$(npx nx affected:apps --base=origin/main --plain)
          echo "packages=$AFFECTED" >> $GITHUB_OUTPUT

  test-affected:
    needs: detect-changes
    runs-on: ubuntu-latest
    strategy:
      matrix:
        package: ${{ fromJson(needs.detect-changes.outputs.affected) }}
    steps:
      - uses: actions/checkout@v4
      - name: Test ${{ matrix.package }}
        run: npm run test --workspace=${{ matrix.package }}
```

### Turborepo CI

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Build with Turborepo
        run: npx turbo build --cache-dir=.turbo

      - name: Cache Turbo
        uses: actions/cache@v4
        with:
          path: .turbo
          key: ${{ runner.os }}-turbo-${{ github.sha }}
          restore-keys: |
            ${{ runner.os }}-turbo-
```

## Performance Optimization

### Parallel Job Execution

```yaml
jobs:
  # These jobs run in parallel
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run lint

  unit-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run test:unit

  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run build

  # This job waits for all above to complete
  deploy:
    needs: [lint, unit-test, build]
    runs-on: ubuntu-latest
    steps:
      - run: npm run deploy
```

### Conditional Job Execution

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run build

  deploy-staging:
    needs: build
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    steps:
      - run: ./deploy.sh staging

  deploy-production:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - run: ./deploy.sh production
```

### Dependency Caching

```yaml
steps:
  # Node.js with npm
  - uses: actions/setup-node@v4
    with:
      node-version: '20'
      cache: 'npm'

  # Python with pip
  - uses: actions/setup-python@v5
    with:
      python-version: '3.11'
      cache: 'pip'

  # Ruby with bundler
  - uses: ruby/setup-ruby@v1
    with:
      ruby-version: '3.2'
      bundler-cache: true

  # Go modules
  - uses: actions/setup-go@v5
    with:
      go-version: '1.21'
      cache: true
```

## Reusable Workflows

### Creating Reusable Workflows

```yaml
# .github/workflows/reusable-deploy.yml
name: Reusable Deploy Workflow

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      version:
        required: false
        type: string
        default: 'latest'
    secrets:
      deploy-key:
        required: true
    outputs:
      deployment-url:
        description: "URL of the deployment"
        value: ${{ jobs.deploy.outputs.url }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    outputs:
      url: ${{ steps.deploy.outputs.url }}
    steps:
      - uses: actions/checkout@v4

      - name: Deploy
        id: deploy
        env:
          DEPLOY_KEY: ${{ secrets.deploy-key }}
        run: |
          ./deploy.sh ${{ inputs.environment }} ${{ inputs.version }}
          echo "url=https://${{ inputs.environment }}.example.com" >> $GITHUB_OUTPUT
```

### Calling Reusable Workflows

```yaml
# .github/workflows/main.yml
name: Main Pipeline

on: [push]

jobs:
  deploy-staging:
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: staging
      version: ${{ github.sha }}
    secrets:
      deploy-key: ${{ secrets.STAGING_DEPLOY_KEY }}

  deploy-production:
    needs: deploy-staging
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: production
      version: ${{ github.sha }}
    secrets:
      deploy-key: ${{ secrets.PRODUCTION_DEPLOY_KEY }}
```

## Infrastructure as Code

### Terraform Deployment

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.7.0

      - name: Terraform Format
        run: terraform fmt -check

      - name: Terraform Init
        run: terraform init
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan -out=tfplan
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve tfplan
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### AWS CloudFormation

```yaml
jobs:
  deploy-cloudformation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1

      - name: Deploy CloudFormation stack
        run: |
          aws cloudformation deploy \
            --template-file infrastructure/template.yml \
            --stack-name my-app-stack \
            --parameter-overrides \
              Environment=production \
              Version=${{ github.sha }} \
            --capabilities CAPABILITY_IAM
```

## Best Practices

### Workflow Organization

1. **Separate concerns**: Different workflows for CI, CD, and scheduled tasks
2. **Use descriptive names**: Clear workflow and job names
3. **Organize with directories**: Group related workflows
4. **Version control**: Track workflow changes like code

### Efficiency

1. **Cache dependencies**: Reduce build times significantly
2. **Parallel execution**: Run independent jobs simultaneously
3. **Conditional runs**: Skip unnecessary jobs
4. **Matrix strategies**: Test multiple configurations efficiently
5. **Artifact reuse**: Share build outputs between jobs

### Security

1. **Minimize permissions**: Use least-privilege principle
2. **Use OIDC**: Avoid long-lived credentials
3. **Secret rotation**: Regularly update secrets
4. **Pin dependencies**: Use specific versions or SHAs
5. **Scan for vulnerabilities**: Automated security checks

### Reliability

1. **Timeout settings**: Prevent hanging jobs
2. **Retry logic**: Handle transient failures
3. **Failure notifications**: Alert on critical failures
4. **Rollback mechanisms**: Quick recovery from failed deployments
5. **Health checks**: Verify deployments before marking complete

### Observability

1. **Detailed logging**: Clear, actionable logs
2. **Status checks**: Prevent merging failing builds
3. **Deployment tracking**: Know what's deployed where
4. **Metrics collection**: Track pipeline performance
5. **Audit trails**: Track who deployed what and when

## Failure Handling

### Retry Failed Steps

```yaml
steps:
  - name: Deploy with retry
    uses: nick-fields/retry-action@v2
    with:
      timeout_minutes: 10
      max_attempts: 3
      retry_wait_seconds: 30
      command: npm run deploy
```

### Continue on Error

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Run optional check
        continue-on-error: true
        run: npm run optional-check

      - name: Run required tests
        run: npm test
```

### Conditional Cleanup

```yaml
steps:
  - name: Deploy
    id: deploy
    run: ./deploy.sh

  - name: Rollback on failure
    if: failure() && steps.deploy.conclusion == 'failure'
    run: ./rollback.sh

  - name: Cleanup
    if: always()
    run: ./cleanup.sh
```

## Advanced Patterns

### Dynamic Matrix Generation

```yaml
jobs:
  generate-matrix:
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.set-matrix.outputs.matrix }}
    steps:
      - uses: actions/checkout@v4
      - id: set-matrix
        run: |
          # Generate matrix based on project structure
          MATRIX=$(find packages -maxdepth 1 -type d -not -name packages | \
            jq -R -s -c 'split("\n")[:-1]')
          echo "matrix=$MATRIX" >> $GITHUB_OUTPUT

  test:
    needs: generate-matrix
    runs-on: ubuntu-latest
    strategy:
      matrix:
        package: ${{ fromJson(needs.generate-matrix.outputs.matrix) }}
    steps:
      - uses: actions/checkout@v4
      - run: npm test --workspace=${{ matrix.package }}
```

### Composite Actions

Create reusable action combinations:

```yaml
# .github/actions/setup-project/action.yml
name: 'Setup Project'
description: 'Setup Node.js and install dependencies'
inputs:
  node-version:
    description: 'Node.js version'
    required: false
    default: '20'
runs:
  using: 'composite'
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.node-version }}
        cache: 'npm'

    - run: npm ci
      shell: bash

    - run: npm run build
      shell: bash
```

**Usage:**
```yaml
steps:
  - uses: actions/checkout@v4
  - uses: ./.github/actions/setup-project
    with:
      node-version: '20'
```

### Self-Hosted Runners

```yaml
jobs:
  deploy:
    runs-on: [self-hosted, linux, production]
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to production
        run: ./deploy.sh
```

**Benefits:**
- Custom hardware/software requirements
- Faster builds (pre-cached dependencies)
- Access to internal networks
- Cost savings for high-volume CI/CD

## Platform-Specific Deployments

### Vercel Deployment

```yaml
jobs:
  deploy-vercel:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

### Netlify Deployment

```yaml
jobs:
  deploy-netlify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build
        run: npm run build

      - name: Deploy to Netlify
        uses: nwtgck/actions-netlify@v3
        with:
          publish-dir: './dist'
          production-branch: main
          github-token: ${{ secrets.GITHUB_TOKEN }}
          deploy-message: 'Deploy from GitHub Actions'
        env:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

### AWS ECS Deployment

```yaml
jobs:
  deploy-ecs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build and push Docker image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: my-app
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

      - name: Update ECS service
        run: |
          aws ecs update-service \
            --cluster my-cluster \
            --service my-service \
            --force-new-deployment
```

### Kubernetes Deployment

```yaml
jobs:
  deploy-k8s:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup kubectl
        uses: azure/setup-kubectl@v3
        with:
          version: 'v1.28.0'

      - name: Configure kubeconfig
        run: |
          echo "${{ secrets.KUBE_CONFIG }}" | base64 -d > kubeconfig.yml
          echo "KUBECONFIG=$(pwd)/kubeconfig.yml" >> $GITHUB_ENV

      - name: Deploy to Kubernetes
        run: |
          kubectl set image deployment/myapp \
            myapp=myregistry/myapp:${{ github.sha }}
          kubectl rollout status deployment/myapp
```

---

**Skill Version**: 1.0.0
**Last Updated**: October 2025
**Skill Category**: DevOps, CI/CD, Automation, Deployment
**Compatible With**: GitHub Actions, Docker, Kubernetes, AWS, Azure, GCP, Vercel, Netlify
