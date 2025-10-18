# CI/CD Pipeline Examples

> Production-ready workflow examples for modern software delivery

This document contains comprehensive, battle-tested CI/CD pipeline examples that you can adapt for your projects. Each example includes complete configuration files and explanations.

## Table of Contents

1. [Complete Node.js CI/CD Pipeline](#1-complete-nodejs-cicd-pipeline)
2. [Docker Multi-Stage Build and Push](#2-docker-multi-stage-build-and-push)
3. [Multi-Environment Deployment with Approvals](#3-multi-environment-deployment-with-approvals)
4. [Matrix Testing Across Platforms](#4-matrix-testing-across-platforms)
5. [Semantic Release Automation](#5-semantic-release-automation)
6. [Terraform Infrastructure Deployment](#6-terraform-infrastructure-deployment)
7. [Kubernetes Blue-Green Deployment](#7-kubernetes-blue-green-deployment)
8. [Monorepo CI with Turborepo](#8-monorepo-ci-with-turborepo)
9. [Python Application with Poetry](#9-python-application-with-poetry)
10. [Serverless Lambda Deployment](#10-serverless-lambda-deployment)
11. [Frontend Deploy to Vercel/Netlify](#11-frontend-deploy-to-vercelnetlify)
12. [Database Migration Pipeline](#12-database-migration-pipeline)
13. [Mobile App CI (React Native)](#13-mobile-app-ci-react-native)
14. [Canary Deployment with Flagger](#14-canary-deployment-with-flagger)
15. [Security Scanning Pipeline](#15-security-scanning-pipeline)
16. [Performance Benchmarking](#16-performance-benchmarking)
17. [Scheduled Maintenance Jobs](#17-scheduled-maintenance-jobs)
18. [Reusable Workflow Templates](#18-reusable-workflow-templates)

---

## 1. Complete Node.js CI/CD Pipeline

A comprehensive pipeline covering linting, testing, building, and deployment for a Node.js application.

**.github/workflows/nodejs-cicd.yml**

```yaml
name: Node.js CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '20'

jobs:
  # Code quality checks
  lint:
    name: Lint Code
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run ESLint
        run: npm run lint

      - name: Run Prettier check
        run: npm run format:check

      - name: Run TypeScript check
        run: npm run type-check

  # Unit and integration tests
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: testuser
          POSTGRES_PASSWORD: testpass
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run unit tests
        run: npm run test:unit -- --coverage

      - name: Run integration tests
        env:
          DATABASE_URL: postgresql://testuser:testpass@localhost:5432/testdb
          REDIS_URL: redis://localhost:6379
        run: npm run test:integration

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./coverage/coverage-final.json
          flags: unittests,integrationtests
          fail_ci_if_error: true

  # Security audit
  security:
    name: Security Audit
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}

      - name: Run npm audit
        run: npm audit --audit-level=moderate

      - name: Run Snyk security scan
        uses: snyk/actions/node@master
        continue-on-error: true
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

  # Build application
  build:
    name: Build Application
    needs: [lint, test, security]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build application
        run: npm run build

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: dist/
          retention-days: 7

  # Deploy to staging
  deploy-staging:
    name: Deploy to Staging
    needs: build
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: https://staging.example.com
    steps:
      - uses: actions/checkout@v4

      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-artifacts
          path: dist/

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1

      - name: Deploy to S3
        run: aws s3 sync dist/ s3://staging-bucket --delete

      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.STAGING_CLOUDFRONT_ID }} \
            --paths "/*"

      - name: Run smoke tests
        run: |
          sleep 10
          curl -f https://staging.example.com/health || exit 1

  # Deploy to production
  deploy-production:
    name: Deploy to Production
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com
    steps:
      - uses: actions/checkout@v4

      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-artifacts
          path: dist/

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1

      - name: Deploy to S3
        run: aws s3 sync dist/ s3://production-bucket --delete

      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.PRODUCTION_CLOUDFRONT_ID }} \
            --paths "/*"

      - name: Run smoke tests
        run: |
          sleep 10
          curl -f https://example.com/health || exit 1

      - name: Notify Slack
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'Production deployment ${{ job.status }}'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 2. Docker Multi-Stage Build and Push

Build optimized Docker images with multi-stage builds and push to multiple registries.

**.github/workflows/docker-build.yml**

```yaml
name: Docker Build and Push

on:
  push:
    branches: [main, develop]
    tags: ['v*']
  pull_request:
    branches: [main]

env:
  REGISTRY_DOCKERHUB: docker.io
  REGISTRY_GHCR: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
      id-token: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY_DOCKERHUB }}
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Login to GitHub Container Registry
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY_GHCR }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: |
            ${{ env.REGISTRY_DOCKERHUB }}/${{ env.IMAGE_NAME }}
            ${{ env.REGISTRY_GHCR }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=semver,pattern={{major}}
            type=sha,prefix={{branch}}-
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          build-args: |
            BUILD_DATE=${{ github.event.head_commit.timestamp }}
            VCS_REF=${{ github.sha }}
            VERSION=${{ steps.meta.outputs.version }}

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.REGISTRY_GHCR }}/${{ env.IMAGE_NAME }}:${{ steps.meta.outputs.version }}
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'

      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results.sarif'

      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          image: ${{ env.REGISTRY_GHCR }}/${{ env.IMAGE_NAME }}:${{ steps.meta.outputs.version }}
          format: spdx-json
          output-file: sbom.spdx.json

      - name: Upload SBOM
        uses: actions/upload-artifact@v4
        with:
          name: sbom
          path: sbom.spdx.json
```

**Dockerfile (Multi-Stage)**

```dockerfile
# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force

# Copy source and build
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy dependencies and build from builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --chown=nodejs:nodejs package*.json ./

# Security: Don't run as root
USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

EXPOSE 3000

CMD ["node", "dist/index.js"]
```

---

## 3. Multi-Environment Deployment with Approvals

Deploy to multiple environments with manual approval gates and environment protection rules.

**.github/workflows/multi-env-deploy.yml**

```yaml
name: Multi-Environment Deployment

on:
  push:
    branches: [main, staging, develop]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        type: choice
        options:
          - development
          - staging
          - production

jobs:
  build:
    name: Build Application
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Generate version
        id: version
        run: |
          VERSION=$(date +%Y%m%d)-$(git rev-parse --short HEAD)
          echo "version=$VERSION" >> $GITHUB_OUTPUT

      - name: Build application
        run: npm run build
        env:
          VERSION: ${{ steps.version.outputs.version }}

      - name: Create artifact
        run: tar -czf app-${{ steps.version.outputs.version }}.tar.gz dist/

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-artifact
          path: app-${{ steps.version.outputs.version }}.tar.gz

  deploy-development:
    name: Deploy to Development
    needs: build
    if: github.ref == 'refs/heads/develop' || (github.event_name == 'workflow_dispatch' && github.event.inputs.environment == 'development')
    runs-on: ubuntu-latest
    environment:
      name: development
      url: https://dev.example.com
    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: app-artifact

      - name: Extract artifact
        run: tar -xzf app-${{ needs.build.outputs.version }}.tar.gz

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_DEV }}
          aws-region: us-east-1

      - name: Deploy to development
        run: |
          aws s3 sync dist/ s3://dev-bucket --delete
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.DEV_CLOUDFRONT_ID }} \
            --paths "/*"

      - name: Health check
        run: |
          for i in {1..5}; do
            if curl -f https://dev.example.com/health; then
              echo "Health check passed"
              exit 0
            fi
            echo "Attempt $i failed, retrying..."
            sleep 10
          done
          exit 1

  deploy-staging:
    name: Deploy to Staging
    needs: build
    if: github.ref == 'refs/heads/staging' || (github.event_name == 'workflow_dispatch' && github.event.inputs.environment == 'staging')
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: https://staging.example.com
    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: app-artifact

      - name: Extract artifact
        run: tar -xzf app-${{ needs.build.outputs.version }}.tar.gz

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_STAGING }}
          aws-region: us-east-1

      - name: Deploy to staging
        run: |
          aws s3 sync dist/ s3://staging-bucket --delete
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.STAGING_CLOUDFRONT_ID }} \
            --paths "/*"

      - name: Run smoke tests
        run: |
          npm ci
          npm run test:smoke -- --env=staging

  deploy-production:
    name: Deploy to Production
    needs: [build, deploy-staging]
    if: github.ref == 'refs/heads/main' || (github.event_name == 'workflow_dispatch' && github.event.inputs.environment == 'production')
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com
    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: app-artifact

      - name: Extract artifact
        run: tar -xzf app-${{ needs.build.outputs.version }}.tar.gz

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_PRODUCTION }}
          aws-region: us-east-1

      - name: Backup current version
        run: |
          aws s3 sync s3://production-bucket s3://production-bucket-backup/$(date +%Y%m%d-%H%M%S)

      - name: Deploy to production
        id: deploy
        run: |
          aws s3 sync dist/ s3://production-bucket --delete
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.PRODUCTION_CLOUDFRONT_ID }} \
            --paths "/*"

      - name: Health check
        id: health
        run: |
          for i in {1..10}; do
            if curl -f https://example.com/health; then
              echo "Health check passed"
              exit 0
            fi
            echo "Attempt $i failed, retrying..."
            sleep 15
          done
          exit 1

      - name: Rollback on failure
        if: failure() && (steps.deploy.conclusion == 'success' || steps.health.conclusion == 'failure')
        run: |
          echo "Rolling back to previous version"
          BACKUP=$(aws s3 ls s3://production-bucket-backup/ | tail -1 | awk '{print $2}')
          aws s3 sync s3://production-bucket-backup/$BACKUP s3://production-bucket --delete
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.PRODUCTION_CLOUDFRONT_ID }} \
            --paths "/*"

      - name: Create deployment record
        if: success()
        run: |
          echo "Deployment successful: ${{ needs.build.outputs.version }}"
          # Log to deployment tracking system
          curl -X POST https://api.example.com/deployments \
            -H "Authorization: Bearer ${{ secrets.API_TOKEN }}" \
            -d "{\"version\": \"${{ needs.build.outputs.version }}\", \"environment\": \"production\", \"status\": \"success\"}"

      - name: Notify team
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: |
            Production deployment ${{ job.status }}
            Version: ${{ needs.build.outputs.version }}
            URL: https://example.com
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 4. Matrix Testing Across Platforms

Test across multiple operating systems, language versions, and configurations.

**.github/workflows/matrix-testing.yml**

```yaml
name: Cross-Platform Testing

on: [push, pull_request]

jobs:
  test-matrix:
    name: Test on ${{ matrix.os }} with Node ${{ matrix.node }}
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node: [18, 20, 22]
        include:
          # Add coverage only for one configuration
          - os: ubuntu-latest
            node: 20
            coverage: true
          # Exclude specific combinations
        exclude:
          - os: macos-latest
            node: 18

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run tests
        run: npm test

      - name: Run tests with coverage
        if: matrix.coverage
        run: npm test -- --coverage

      - name: Upload coverage
        if: matrix.coverage
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./coverage/coverage-final.json
          flags: node-${{ matrix.node }}

      - name: Build application
        run: npm run build

      - name: Test build output
        shell: bash
        run: |
          if [ ! -d "dist" ]; then
            echo "Build failed - dist directory not found"
            exit 1
          fi

  test-databases:
    name: Test with ${{ matrix.database }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        database:
          - postgres:14
          - postgres:15
          - postgres:16
          - mysql:8.0
          - mysql:8.2

    services:
      database:
        image: ${{ matrix.database }}
        env:
          POSTGRES_PASSWORD: postgres
          MYSQL_ROOT_PASSWORD: mysql
        options: >-
          --health-cmd "${{ contains(matrix.database, 'postgres') && 'pg_isready' || 'mysqladmin ping' }}"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
          - 3306:3306

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run database migrations
        env:
          DATABASE_URL: ${{ contains(matrix.database, 'postgres') && 'postgresql://postgres:postgres@localhost:5432/testdb' || 'mysql://root:mysql@localhost:3306/testdb' }}
        run: npm run migrate

      - name: Run integration tests
        env:
          DATABASE_URL: ${{ contains(matrix.database, 'postgres') && 'postgresql://postgres:postgres@localhost:5432/testdb' || 'mysql://root:mysql@localhost:3306/testdb' }}
        run: npm run test:integration

  test-browsers:
    name: E2E on ${{ matrix.browser }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        browser: [chromium, firefox, webkit]

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright
        run: npx playwright install --with-deps ${{ matrix.browser }}

      - name: Build app
        run: npm run build

      - name: Run E2E tests
        run: npx playwright test --project=${{ matrix.browser }}

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-results-${{ matrix.browser }}
          path: playwright-report/
          retention-days: 7
```

---

## 5. Semantic Release Automation

Automatically version, generate changelogs, and publish releases based on commit conventions.

**.github/workflows/release.yml**

```yaml
name: Release

on:
  push:
    branches:
      - main
      - next
      - beta
      - alpha

permissions:
  contents: write
  issues: write
  pull-requests: write
  packages: write

jobs:
  release:
    name: Semantic Release
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          persist-credentials: false

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Build application
        run: npm run build

      - name: Semantic Release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
        run: npx semantic-release

      - name: Get release version
        id: version
        run: |
          VERSION=$(node -p "require('./package.json').version")
          echo "version=$VERSION" >> $GITHUB_OUTPUT

      - name: Create GitHub Release
        if: steps.version.outputs.version != ''
        uses: ncipollo/release-action@v1
        with:
          tag: v${{ steps.version.outputs.version }}
          name: Release v${{ steps.version.outputs.version }}
          bodyFile: RELEASE_NOTES.md
          artifacts: 'dist/*'
          generateReleaseNotes: true
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Publish to npm
        if: steps.version.outputs.version != ''
        run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}

      - name: Build and push Docker image
        if: steps.version.outputs.version != ''
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            myorg/myapp:latest
            myorg/myapp:v${{ steps.version.outputs.version }}
            myorg/myapp:${{ github.sha }}

      - name: Update documentation
        if: steps.version.outputs.version != ''
        run: |
          npm run docs:generate
          # Deploy docs to GitHub Pages or documentation site

      - name: Notify release
        if: steps.version.outputs.version != ''
        uses: 8398a7/action-slack@v3
        with:
          status: custom
          custom_payload: |
            {
              text: "New release published!",
              attachments: [{
                color: 'good',
                text: `Version v${{ steps.version.outputs.version }} has been released\nhttps://github.com/${{ github.repository }}/releases/tag/v${{ steps.version.outputs.version }}`
              }]
            }
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

**.releaserc.json**

```json
{
  "branches": [
    "main",
    {
      "name": "next",
      "prerelease": true
    },
    {
      "name": "beta",
      "prerelease": true
    },
    {
      "name": "alpha",
      "prerelease": true
    }
  ],
  "plugins": [
    [
      "@semantic-release/commit-analyzer",
      {
        "preset": "angular",
        "releaseRules": [
          { "type": "docs", "scope": "README", "release": "patch" },
          { "type": "refactor", "release": "patch" },
          { "type": "style", "release": "patch" },
          { "type": "perf", "release": "patch" }
        ]
      }
    ],
    [
      "@semantic-release/release-notes-generator",
      {
        "preset": "angular",
        "writerOpts": {
          "commitsSort": ["subject", "scope"]
        }
      }
    ],
    "@semantic-release/changelog",
    [
      "@semantic-release/npm",
      {
        "npmPublish": true
      }
    ],
    [
      "@semantic-release/git",
      {
        "assets": ["CHANGELOG.md", "package.json", "package-lock.json"],
        "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
      }
    ],
    [
      "@semantic-release/github",
      {
        "assets": [
          {
            "path": "dist/**",
            "label": "Distribution"
          }
        ]
      }
    ]
  ]
}
```

---

## 6. Terraform Infrastructure Deployment

Deploy and manage infrastructure as code with Terraform.

**.github/workflows/terraform.yml**

```yaml
name: Terraform Infrastructure

on:
  push:
    branches: [main]
    paths:
      - 'terraform/**'
  pull_request:
    branches: [main]
    paths:
      - 'terraform/**'
  workflow_dispatch:
    inputs:
      action:
        description: 'Terraform action to perform'
        required: true
        type: choice
        options:
          - plan
          - apply
          - destroy

env:
  TF_VERSION: '1.7.0'
  TF_WORKING_DIR: './terraform'

jobs:
  terraform-validation:
    name: Terraform Validation
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ${{ env.TF_WORKING_DIR }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Format Check
        run: terraform fmt -check -recursive

      - name: Terraform Init
        run: terraform init -backend=false

      - name: Terraform Validate
        run: terraform validate

      - name: Run tflint
        uses: terraform-linters/setup-tflint@v4
        with:
          tflint_version: latest

      - name: Initialize tflint
        run: tflint --init

      - name: Run tflint
        run: tflint --recursive

  terraform-plan:
    name: Terraform Plan
    needs: terraform-validation
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
      pull-requests: write
    defaults:
      run:
        working-directory: ${{ env.TF_WORKING_DIR }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_TERRAFORM_ROLE }}
          aws-region: us-east-1

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        id: plan
        run: |
          terraform plan -no-color -out=tfplan
          terraform show -no-color tfplan > plan.txt

      - name: Upload plan
        uses: actions/upload-artifact@v4
        with:
          name: terraform-plan
          path: ${{ env.TF_WORKING_DIR }}/tfplan

      - name: Comment PR with plan
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const fs = require('fs');
            const plan = fs.readFileSync('${{ env.TF_WORKING_DIR }}/plan.txt', 'utf8');
            const output = `#### Terraform Plan 📋

            <details><summary>Show Plan</summary>

            \`\`\`terraform
            ${plan}
            \`\`\`

            </details>

            *Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            });

      - name: Run Checkov security scan
        uses: bridgecrewio/checkov-action@master
        with:
          directory: ${{ env.TF_WORKING_DIR }}
          framework: terraform
          output_format: sarif
          output_file_path: checkov-results.sarif

      - name: Upload Checkov results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: checkov-results.sarif

  terraform-apply:
    name: Terraform Apply
    needs: terraform-plan
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    environment:
      name: production-infrastructure
    defaults:
      run:
        working-directory: ${{ env.TF_WORKING_DIR }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_TERRAFORM_ROLE }}
          aws-region: us-east-1

      - name: Terraform Init
        run: terraform init

      - name: Download plan
        uses: actions/download-artifact@v4
        with:
          name: terraform-plan
          path: ${{ env.TF_WORKING_DIR }}

      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan

      - name: Get outputs
        id: outputs
        run: |
          terraform output -json > outputs.json
          echo "outputs=$(cat outputs.json)" >> $GITHUB_OUTPUT

      - name: Update documentation
        run: |
          # Generate infrastructure documentation
          terraform-docs markdown table ${{ env.TF_WORKING_DIR }} > INFRASTRUCTURE.md

      - name: Notify deployment
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'Terraform infrastructure deployment completed'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}

  terraform-destroy:
    name: Terraform Destroy
    if: github.event_name == 'workflow_dispatch' && github.event.inputs.action == 'destroy'
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    environment:
      name: production-infrastructure-destroy
    defaults:
      run:
        working-directory: ${{ env.TF_WORKING_DIR }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_TERRAFORM_ROLE }}
          aws-region: us-east-1

      - name: Terraform Init
        run: terraform init

      - name: Terraform Destroy
        run: terraform destroy -auto-approve
```

---

## 7. Kubernetes Blue-Green Deployment

Zero-downtime deployment using blue-green strategy in Kubernetes.

**.github/workflows/k8s-blue-green.yml**

```yaml
name: Kubernetes Blue-Green Deployment

on:
  push:
    branches: [main]
  workflow_dispatch:

env:
  CLUSTER_NAME: production-cluster
  NAMESPACE: production
  APP_NAME: myapp

jobs:
  build-and-push:
    name: Build and Push Docker Image
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.meta.outputs.version }}
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to container registry
        uses: docker/login-action@v3
        with:
          registry: ${{ secrets.REGISTRY_URL }}
          username: ${{ secrets.REGISTRY_USERNAME }}
          password: ${{ secrets.REGISTRY_PASSWORD }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ secrets.REGISTRY_URL }}/${{ env.APP_NAME }}
          tags: |
            type=sha,prefix={{branch}}-
            type=ref,event=branch
            type=semver,pattern={{version}}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy-green:
    name: Deploy to Green Environment
    needs: build-and-push
    runs-on: ubuntu-latest
    environment:
      name: production-green
    steps:
      - uses: actions/checkout@v4

      - name: Configure kubectl
        uses: azure/k8s-set-context@v3
        with:
          method: kubeconfig
          kubeconfig: ${{ secrets.KUBE_CONFIG }}

      - name: Deploy green deployment
        run: |
          # Create green deployment if it doesn't exist
          kubectl apply -f - <<EOF
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: ${{ env.APP_NAME }}-green
            namespace: ${{ env.NAMESPACE }}
            labels:
              app: ${{ env.APP_NAME }}
              version: green
          spec:
            replicas: 3
            selector:
              matchLabels:
                app: ${{ env.APP_NAME }}
                version: green
            template:
              metadata:
                labels:
                  app: ${{ env.APP_NAME }}
                  version: green
              spec:
                containers:
                - name: ${{ env.APP_NAME }}
                  image: ${{ secrets.REGISTRY_URL }}/${{ env.APP_NAME }}:${{ needs.build-and-push.outputs.image-tag }}
                  ports:
                  - containerPort: 3000
                  env:
                  - name: VERSION
                    value: "${{ needs.build-and-push.outputs.image-tag }}"
                  livenessProbe:
                    httpGet:
                      path: /health
                      port: 3000
                    initialDelaySeconds: 30
                    periodSeconds: 10
                  readinessProbe:
                    httpGet:
                      path: /ready
                      port: 3000
                    initialDelaySeconds: 5
                    periodSeconds: 5
          EOF

      - name: Wait for green deployment
        run: |
          kubectl rollout status deployment/${{ env.APP_NAME }}-green -n ${{ env.NAMESPACE }} --timeout=5m

      - name: Run smoke tests against green
        run: |
          # Get green pod IP
          GREEN_POD=$(kubectl get pod -n ${{ env.NAMESPACE }} -l app=${{ env.APP_NAME }},version=green -o jsonpath='{.items[0].metadata.name}')

          # Port forward to test
          kubectl port-forward -n ${{ env.NAMESPACE }} $GREEN_POD 8080:3000 &
          PF_PID=$!
          sleep 5

          # Run tests
          curl -f http://localhost:8080/health || exit 1

          # Cleanup
          kill $PF_PID

  switch-to-green:
    name: Switch Traffic to Green
    needs: deploy-green
    runs-on: ubuntu-latest
    environment:
      name: production-switch
    steps:
      - uses: actions/checkout@v4

      - name: Configure kubectl
        uses: azure/k8s-set-context@v3
        with:
          method: kubeconfig
          kubeconfig: ${{ secrets.KUBE_CONFIG }}

      - name: Update service to point to green
        run: |
          kubectl patch service ${{ env.APP_NAME }} -n ${{ env.NAMESPACE }} -p '{"spec":{"selector":{"version":"green"}}}'

      - name: Wait and monitor
        run: |
          echo "Monitoring green deployment for 5 minutes..."
          sleep 300

      - name: Check error rates
        run: |
          # Query metrics/logs to check for errors
          # If error rate is high, fail the deployment
          ERROR_RATE=$(kubectl logs -n ${{ env.NAMESPACE }} -l app=${{ env.APP_NAME }},version=green --tail=1000 | grep -c "ERROR" || echo "0")
          if [ "$ERROR_RATE" -gt 10 ]; then
            echo "Error rate too high: $ERROR_RATE"
            exit 1
          fi

  cleanup-blue:
    name: Cleanup Blue Deployment
    needs: switch-to-green
    runs-on: ubuntu-latest
    steps:
      - name: Configure kubectl
        uses: azure/k8s-set-context@v3
        with:
          method: kubeconfig
          kubeconfig: ${{ secrets.KUBE_CONFIG }}

      - name: Scale down blue deployment
        run: |
          kubectl scale deployment/${{ env.APP_NAME }}-blue -n ${{ env.NAMESPACE }} --replicas=0 || echo "Blue deployment doesn't exist"

      - name: Rename deployments
        run: |
          # Rename green to blue for next deployment
          kubectl delete deployment/${{ env.APP_NAME }}-blue -n ${{ env.NAMESPACE }} || true
          kubectl get deployment/${{ env.APP_NAME }}-green -n ${{ env.NAMESPACE }} -o yaml | \
            sed 's/-green/-blue/g' | \
            kubectl apply -f -
          kubectl delete deployment/${{ env.APP_NAME }}-green -n ${{ env.NAMESPACE }}

      - name: Update service
        run: |
          kubectl patch service ${{ env.APP_NAME }} -n ${{ env.NAMESPACE }} -p '{"spec":{"selector":{"version":"blue"}}}'

  rollback:
    name: Rollback to Blue
    if: failure()
    needs: [deploy-green, switch-to-green]
    runs-on: ubuntu-latest
    steps:
      - name: Configure kubectl
        uses: azure/k8s-set-context@v3
        with:
          method: kubeconfig
          kubeconfig: ${{ secrets.KUBE_CONFIG }}

      - name: Switch back to blue
        run: |
          kubectl patch service ${{ env.APP_NAME }} -n ${{ env.NAMESPACE }} -p '{"spec":{"selector":{"version":"blue"}}}'

      - name: Scale down green
        run: |
          kubectl scale deployment/${{ env.APP_NAME }}-green -n ${{ env.NAMESPACE }} --replicas=0

      - name: Notify rollback
        uses: 8398a7/action-slack@v3
        with:
          status: failure
          text: 'Deployment failed - rolled back to blue environment'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 8. Monorepo CI with Turborepo

Efficient CI/CD for monorepos using Turborepo for task caching and parallelization.

**.github/workflows/turborepo-ci.yml**

```yaml
name: Monorepo CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
  TURBO_TEAM: ${{ secrets.TURBO_TEAM }}

jobs:
  changes:
    name: Detect Changes
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
              - 'apps/frontend/**'
            backend:
              - 'apps/backend/**'
            mobile:
              - 'apps/mobile/**'
            shared:
              - 'packages/**'

  setup:
    name: Setup
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Get pnpm store directory
        id: pnpm-cache
        run: echo "pnpm_cache_dir=$(pnpm store path)" >> $GITHUB_OUTPUT

      - name: Setup pnpm cache
        uses: actions/cache@v4
        with:
          path: ${{ steps.pnpm-cache.outputs.pnpm_cache_dir }}
          key: ${{ runner.os }}-pnpm-store-${{ hashFiles('**/pnpm-lock.yaml') }}
          restore-keys: |
            ${{ runner.os }}-pnpm-store-

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Cache Turbo
        uses: actions/cache@v4
        with:
          path: .turbo
          key: ${{ runner.os }}-turbo-${{ github.sha }}
          restore-keys: |
            ${{ runner.os }}-turbo-

  lint:
    name: Lint
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Restore cache
        uses: actions/cache@v4
        with:
          path: |
            ~/.pnpm-store
            .turbo
          key: ${{ runner.os }}-pnpm-store-${{ hashFiles('**/pnpm-lock.yaml') }}

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Run lint
        run: pnpm turbo run lint

  type-check:
    name: Type Check
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Restore cache
        uses: actions/cache@v4
        with:
          path: |
            ~/.pnpm-store
            .turbo
          key: ${{ runner.os }}-pnpm-store-${{ hashFiles('**/pnpm-lock.yaml') }}

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Run type check
        run: pnpm turbo run type-check

  test:
    name: Test
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Restore cache
        uses: actions/cache@v4
        with:
          path: |
            ~/.pnpm-store
            .turbo
          key: ${{ runner.os }}-pnpm-store-${{ hashFiles('**/pnpm-lock.yaml') }}

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Run tests
        run: pnpm turbo run test -- --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          directory: ./coverage
          flags: monorepo
          token: ${{ secrets.CODECOV_TOKEN }}

  build:
    name: Build
    needs: [lint, type-check, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Restore cache
        uses: actions/cache@v4
        with:
          path: |
            ~/.pnpm-store
            .turbo
          key: ${{ runner.os }}-pnpm-store-${{ hashFiles('**/pnpm-lock.yaml') }}

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Build packages
        run: pnpm turbo run build

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-outputs
          path: |
            apps/*/dist
            apps/*/.next
          retention-days: 7

  deploy-affected:
    name: Deploy Affected Apps
    needs: [build, changes]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    strategy:
      matrix:
        app: ${{ fromJson(needs.changes.outputs.packages) }}
    steps:
      - uses: actions/checkout@v4

      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-outputs

      - name: Deploy ${{ matrix.app }}
        run: |
          echo "Deploying ${{ matrix.app }}"
          # Add deployment logic specific to each app
```

**turbo.json**

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env"],
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"]
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": ["coverage/**"]
    },
    "lint": {
      "outputs": []
    },
    "type-check": {
      "dependsOn": ["^build"],
      "outputs": []
    },
    "deploy": {
      "dependsOn": ["build", "test", "lint"],
      "outputs": []
    }
  }
}
```

---

## 9. Python Application with Poetry

CI/CD for Python applications using Poetry for dependency management.

**.github/workflows/python-poetry.yml**

```yaml
name: Python CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  PYTHON_VERSION: '3.12'

jobs:
  quality:
    name: Code Quality
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}

      - name: Install Poetry
        uses: snok/install-poetry@v1
        with:
          version: 1.7.1
          virtualenvs-create: true
          virtualenvs-in-project: true

      - name: Load cached venv
        id: cached-poetry-dependencies
        uses: actions/cache@v4
        with:
          path: .venv
          key: venv-${{ runner.os }}-${{ hashFiles('**/poetry.lock') }}

      - name: Install dependencies
        if: steps.cached-poetry-dependencies.outputs.cache-hit != 'true'
        run: poetry install --no-interaction --no-root

      - name: Install project
        run: poetry install --no-interaction

      - name: Run black
        run: poetry run black --check .

      - name: Run isort
        run: poetry run isort --check-only .

      - name: Run flake8
        run: poetry run flake8 .

      - name: Run mypy
        run: poetry run mypy .

      - name: Run pylint
        run: poetry run pylint src/

  test:
    name: Test Python ${{ matrix.python-version }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.10', '3.11', '3.12']

    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v4

      - name: Setup Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Install Poetry
        uses: snok/install-poetry@v1

      - name: Load cached venv
        uses: actions/cache@v4
        with:
          path: .venv
          key: venv-${{ runner.os }}-${{ matrix.python-version }}-${{ hashFiles('**/poetry.lock') }}

      - name: Install dependencies
        run: poetry install --no-interaction

      - name: Run tests
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/testdb
        run: |
          poetry run pytest \
            --cov=src \
            --cov-report=xml \
            --cov-report=html \
            --junit-xml=junit.xml \
            -v

      - name: Upload coverage
        if: matrix.python-version == '3.12'
        uses: codecov/codecov-action@v4
        with:
          file: ./coverage.xml
          flags: python-${{ matrix.python-version }}
          token: ${{ secrets.CODECOV_TOKEN }}

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results-${{ matrix.python-version }}
          path: junit.xml

  security:
    name: Security Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}

      - name: Install Poetry
        uses: snok/install-poetry@v1

      - name: Install dependencies
        run: poetry install --no-interaction

      - name: Run safety check
        run: poetry run safety check

      - name: Run bandit
        run: poetry run bandit -r src/

  build:
    name: Build Package
    needs: [quality, test, security]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}

      - name: Install Poetry
        uses: snok/install-poetry@v1

      - name: Build package
        run: poetry build

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/

  deploy:
    name: Deploy to PyPI
    needs: build
    if: github.ref == 'refs/heads/main' && startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    environment:
      name: pypi
      url: https://pypi.org/project/myproject
    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}

      - name: Install Poetry
        uses: snok/install-poetry@v1

      - name: Download artifacts
        uses: actions/download-artifact@v4
        with:
          name: dist
          path: dist/

      - name: Publish to PyPI
        env:
          POETRY_PYPI_TOKEN_PYPI: ${{ secrets.PYPI_TOKEN }}
        run: poetry publish
```

---

## 10. Serverless Lambda Deployment

Deploy AWS Lambda functions with automated testing and deployment.

**.github/workflows/serverless-lambda.yml**

```yaml
name: Serverless Lambda Deployment

on:
  push:
    branches: [main]
    paths:
      - 'functions/**'
      - 'serverless.yml'
  pull_request:
    branches: [main]

jobs:
  test:
    name: Test Lambda Functions
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run unit tests
        run: npm run test:unit

      - name: Run integration tests
        run: npm run test:integration

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}

  deploy-dev:
    name: Deploy to Development
    needs: test
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment:
      name: dev
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1

      - name: Install dependencies
        run: npm ci

      - name: Install Serverless Framework
        run: npm install -g serverless@3

      - name: Deploy to dev
        run: |
          serverless deploy --stage dev --verbose

      - name: Run smoke tests
        env:
          API_ENDPOINT: ${{ steps.deploy.outputs.api-endpoint }}
        run: npm run test:smoke -- --env=dev

  deploy-prod:
    name: Deploy to Production
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment:
      name: production
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1

      - name: Install dependencies
        run: npm ci --production

      - name: Install Serverless Framework
        run: npm install -g serverless@3

      - name: Deploy to production
        id: deploy
        run: |
          serverless deploy --stage prod --verbose
          API_ENDPOINT=$(serverless info --stage prod | grep "endpoint:" | cut -d' ' -f5)
          echo "api-endpoint=$API_ENDPOINT" >> $GITHUB_OUTPUT

      - name: Run smoke tests
        env:
          API_ENDPOINT: ${{ steps.deploy.outputs.api-endpoint }}
        run: npm run test:smoke -- --env=prod

      - name: Publish metrics
        run: |
          # Publish deployment metrics to CloudWatch
          aws cloudwatch put-metric-data \
            --namespace ServerlessApp \
            --metric-name Deployment \
            --value 1 \
            --dimensions Environment=production

      - name: Notify deployment
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: |
            Production deployment completed
            API Endpoint: ${{ steps.deploy.outputs.api-endpoint }}
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## Additional Examples (11-18)

Due to length constraints, here are condensed versions of the remaining examples. Each would follow similar comprehensive patterns as above.

### 11. Frontend Deploy to Vercel/Netlify

```yaml
name: Frontend Deployment

on:
  push:
    branches: [main]

jobs:
  deploy-vercel:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

### 12. Database Migration Pipeline

```yaml
name: Database Migrations

on:
  push:
    branches: [main]
    paths:
      - 'migrations/**'

jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run migrations
        run: npm run migrate:prod
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

### 13. Mobile App CI (React Native)

```yaml
name: React Native CI

on: [push, pull_request]

jobs:
  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: cd ios && pod install
      - run: xcodebuild -workspace ios/App.xcworkspace -scheme App build
```

### 14. Canary Deployment with Flagger

```yaml
name: Canary Deployment

jobs:
  canary:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy canary
        run: kubectl apply -f canary.yaml
      - name: Monitor canary
        run: flagger-loadtester -gate http://canary-endpoint
```

### 15. Security Scanning Pipeline

```yaml
name: Security Scan

on:
  schedule:
    - cron: '0 0 * * *'

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Trivy
        uses: aquasecurity/trivy-action@master
      - name: Run Snyk
        uses: snyk/actions/node@master
```

### 16. Performance Benchmarking

```yaml
name: Performance Tests

on: [pull_request]

jobs:
  benchmark:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run benchmarks
        run: npm run benchmark
      - name: Compare with main
        run: npm run benchmark:compare
```

### 17. Scheduled Maintenance Jobs

```yaml
name: Scheduled Maintenance

on:
  schedule:
    - cron: '0 2 * * 0'  # Weekly on Sunday at 2 AM

jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - name: Cleanup old artifacts
        run: |
          # Cleanup logic
          aws s3 rm s3://bucket/old/ --recursive
```

### 18. Reusable Workflow Templates

```yaml
# .github/workflows/reusable-deploy.yml
name: Reusable Deploy

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
    secrets:
      api-key:
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    steps:
      - uses: actions/checkout@v4
      - name: Deploy
        run: ./deploy.sh ${{ inputs.environment }}
```

---

**Document Version**: 1.0.0
**Last Updated**: October 2025
**Total Examples**: 18
**Coverage**: Node.js, Docker, Python, Serverless, Kubernetes, Monorepos, Mobile, and more
