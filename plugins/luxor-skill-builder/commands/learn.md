# /learn

Master any topic by building comprehensive context through deep research, web search, web fetch, and structured knowledge engineering. Creates reusable knowledge bases that empower both you and your agents.

## Usage

```bash
# Learning modes
/learn "<topic>" [options]
/learn "<topic>" --depth <level>
/learn "<topic>" --format <type> --save <path>
/learn "<topic>" --context-for <agent-name>

# Progressive learning
/learn "<topic>" --progressive
/learn "<topic>" --prerequisites

# Integration modes
/learn "<topic>" --build-on <existing-doc>
/learn "<topic>" --compare "<topic1> vs <topic2>"
```

## Parameters

### Required
- `topic` (string): The subject to master
  - Can be technical, conceptual, or domain knowledge
  - Be specific for better results
  - Examples: "React Server Components", "quantum computing basics", "OAuth2 flow"

### Optional Flags

#### Depth Control
- `--depth <level>`: Learning depth
  - `quick`: Overview and key concepts (15-20 min)
  - `standard`: Comprehensive understanding (30-45 min, default)
  - `deep`: Expert-level mastery (60-90 min)
  - `mastery`: Complete mastery with practice (2-3 hours)

#### Output Format
- `--format <type>`: Knowledge structure
  - `knowledge-map`: Concept hierarchy with relationships (default)
  - `tutorial`: Step-by-step learning guide
  - `reference`: Quick reference with examples
  - `context-doc`: Optimized for agent consumption

#### Context Engineering
- `--context-for <agent>`: Optimize for specific agent
  - Creates context document in agent-readable format
  - Includes domain knowledge, patterns, best practices
  - Saves to `.claude/context/<agent-name>/`

- `--build-on <path>`: Extend existing knowledge
  - Integrates with existing documentation
  - Creates knowledge graph connections
  - Avoids duplication

#### Learning Path
- `--progressive`: Generate learning roadmap
  - Creates prerequisite chain
  - Suggests learning order
  - Generates milestone checkpoints

- `--prerequisites`: Identify what to learn first
  - Lists required background knowledge
  - Links to prerequisite resources
  - Estimates time investment

#### Comparison Mode
- `--compare "<A> vs <B>"`: Comparative learning
  - Side-by-side analysis
  - Use cases for each
  - Decision framework

#### Source Control
- `--sources <type>`: Prioritize source types
  - `official`: Official documentation only
  - `academic`: Research papers and scholarly articles
  - `practical`: Tutorials and practical guides
  - `all`: All source types (default)

- `--recency <period>`: Focus on recent information
  - `week`, `month`, `year`, `any` (default)

#### Output Location
- `--save <path>`: Custom save location
  - Default: `docs/learning/<topic>.md`
  - Context docs: `.claude/context/<agent>/<topic>.md`

## Examples

### Example 1: Quick Topic Overview
```bash
/learn "GraphQL fundamentals" --depth quick --format reference
```

**What it does**:
1. Uses `/deep -ws` for quick discovery (10 results)
2. WebFetch official GraphQL documentation
3. Extracts key concepts: queries, mutations, schemas, resolvers
4. Creates quick reference with code examples
5. Saves to `docs/learning/graphql-fundamentals.md`

**Output structure**:
```markdown
# GraphQL Fundamentals - Quick Reference

## Core Concepts
- Query language for APIs
- Type system and schema
- Resolvers and data fetching

## Basic Usage
[Code examples]

## Key Differences from REST
[Comparison table]

## Resources
[Links to official docs]
```

**Time**: 15-20 minutes

---

### Example 2: Deep Mastery Learning
```bash
/learn "React Server Components" --depth mastery --progressive
```

**What it does**:
1. Identifies prerequisites (React fundamentals, SSR concepts)
2. Uses `/deep -r` for comprehensive research (30+ sources)
3. WebFetch official React docs, RFCs, and example repos
4. Uses `/deep -t` to reason about architecture patterns
5. Creates progressive learning path with milestones
6. Generates practice projects and exercises
7. Saves to `docs/learning/react-server-components-mastery.md`

**Output structure**:
```markdown
# React Server Components - Mastery Guide

## Learning Path
1. Prerequisites (estimated 2 hours)
2. Core Concepts (3-4 hours)
3. Advanced Patterns (4-6 hours)
4. Production Practices (2-3 hours)

## Phase 1: Prerequisites
### What you need to know first
- React fundamentals
- Server-side rendering basics
- Suspense and Concurrent Features

[Links to prerequisite learning]

## Phase 2: Core Concepts
[Detailed explanations with examples]

## Phase 3: Advanced Patterns
[Complex use cases and patterns]

## Phase 4: Production Practices
[Real-world implementation guide]

## Practice Projects
1. Simple RSC app
2. Intermediate: Data fetching patterns
3. Advanced: Streaming and Suspense

## Knowledge Checkpoints
- [ ] Understand RSC lifecycle
- [ ] Implement server/client component split
- [ ] Handle streaming and Suspense
- [ ] Deploy RSC application

## Resources & References
[Comprehensive resource list]
```

**Time**: 2-3 hours total learning investment
**Immediate**: 60-90 min for documentation generation

---

### Example 3: Context Engineering for Agent
```bash
/learn "Kubernetes architecture" --context-for deployment-orchestrator --format context-doc
```

**What it does**:
1. Researches Kubernetes architecture comprehensively
2. Extracts knowledge relevant to deployment orchestration
3. Formats for agent consumption (structured, parseable)
4. Includes common patterns, best practices, anti-patterns
5. Saves to `.claude/context/deployment-orchestrator/kubernetes-architecture.md`

**Output structure** (agent-optimized):
```markdown
# Kubernetes Architecture - Context for deployment-orchestrator

## Domain Knowledge

### Core Components
- **Control Plane**: API server, scheduler, controller manager, etcd
- **Node Components**: kubelet, kube-proxy, container runtime
- **Add-ons**: DNS, Dashboard, monitoring

### Resource Types
```yaml
# Pod
# Deployment
# Service
# ConfigMap
# Secret
```

### Deployment Patterns
1. **Rolling Update**: Zero-downtime deployments
2. **Blue-Green**: Instant rollback capability
3. **Canary**: Gradual traffic shifting

### Common Anti-Patterns
- ❌ Not setting resource limits
- ❌ Using latest tag
- ❌ Storing secrets in ConfigMaps

### Best Practices for Deployment Agent
1. Always define resource requests/limits
2. Use liveness and readiness probes
3. Implement proper health checks
4. Version everything explicitly
5. Use namespaces for isolation

### Code Templates
[Agent-executable templates]

### Error Patterns & Solutions
[Common errors and how to handle them]

### References
[Official docs, API references]
```

**Agent benefit**: deployment-orchestrator can now make informed decisions about Kubernetes deployments

**Time**: 30-45 minutes

---

### Example 4: Comparative Learning
```bash
/learn --compare "PostgreSQL vs MongoDB" --depth standard
```

**What it does**:
1. Researches both databases comprehensively
2. Uses `/deep -t` to analyze trade-offs
3. Creates decision matrix
4. Provides use case recommendations
5. Saves to `docs/learning/postgresql-vs-mongodb-comparison.md`

**Output structure**:
```markdown
# PostgreSQL vs MongoDB - Comparison Guide

## Executive Summary
[When to use each, key differentiators]

## Side-by-Side Comparison

| Aspect | PostgreSQL | MongoDB |
|--------|------------|---------|
| Data Model | Relational (tables) | Document (JSON-like) |
| Schema | Rigid, enforced | Flexible, dynamic |
| ACID | Full ACID | Limited ACID |
| Scalability | Vertical, read replicas | Horizontal sharding |
| Query Language | SQL | MongoDB Query Language |

## Use Cases

### Choose PostgreSQL when:
- Need strong consistency and ACID guarantees
- Complex joins and relationships
- Structured data with clear schema
- Regulatory compliance requirements

### Choose MongoDB when:
- Rapid development with evolving schema
- Hierarchical data structures
- Horizontal scaling requirements
- High write throughput

## Decision Framework
[Flowchart for decision making]

## Migration Considerations
[If switching between them]

## Learning Resources
[Specific to each database]
```

**Time**: 30-45 minutes

---

### Example 5: Building on Existing Knowledge
```bash
/learn "Advanced TypeScript patterns" --build-on docs/learning/typescript-basics.md --depth deep
```

**What it does**:
1. Reads existing TypeScript basics document
2. Identifies knowledge gaps and advanced topics
3. Researches advanced patterns not covered
4. Creates knowledge graph linking to basics
5. Extends existing doc or creates companion
6. Saves to `docs/learning/typescript-advanced-patterns.md`

**Output structure**:
```markdown
# Advanced TypeScript Patterns

## Prerequisites
**Required**: [TypeScript Basics](./typescript-basics.md)
- Generic types
- Union and intersection types
- Type guards

## Building On
This guide assumes you understand:
- Basic type annotations (see basics doc §2.1)
- Interface vs Type (see basics doc §3.4)
- Generic constraints (see basics doc §5.2)

## Advanced Topics

### 1. Conditional Types
[Builds on: Generic types from basics]
[Detailed explanation]

### 2. Template Literal Types
[New concept, no prerequisite]
[Detailed explanation]

### 3. Advanced Mapped Types
[Builds on: Mapped types from basics]
[Advanced patterns]

## Knowledge Graph
```
TypeScript Basics
    ├─→ Generics (basics §5)
    │   └─→ Conditional Types (this doc §1)
    │       └─→ Distributive Conditionals (this doc §1.3)
    ├─→ Mapped Types (basics §6)
    │   └─→ Advanced Mapped Types (this doc §3)
    └─→ Type Guards (basics §4)
        └─→ Custom Type Guards (this doc §4)
```

## Practice Challenges
[Progressive difficulty]

## Resources
[Advanced-specific resources]
```

**Time**: 60-90 minutes

---

### Example 6: Progressive Learning Path
```bash
/learn "Machine Learning fundamentals" --progressive --prerequisites
```

**What it does**:
1. Maps entire ML learning domain
2. Identifies prerequisite knowledge (math, programming)
3. Creates staged learning path
4. Estimates time investment per stage
5. Links to resources for each stage
6. Saves to `docs/learning/machine-learning-roadmap.md`

**Output structure**:
```markdown
# Machine Learning - Progressive Learning Roadmap

## Prerequisites Assessment

### Essential Prerequisites (20-40 hours)
- [ ] **Linear Algebra** (10-15 hours)
  - Vectors and matrices
  - Matrix operations
  - Eigenvalues and eigenvectors
  - Resources: [Khan Academy Linear Algebra]

- [ ] **Calculus** (10-15 hours)
  - Derivatives and gradients
  - Partial derivatives
  - Chain rule
  - Resources: [3Blue1Brown Calculus]

- [ ] **Python Programming** (10-15 hours)
  - Numpy and Pandas
  - Data manipulation
  - Resources: [Python for Data Science]

- [ ] **Statistics & Probability** (8-12 hours)
  - Probability distributions
  - Bayesian thinking
  - Resources: [Stats 110]

## Learning Path (80-120 hours total)

### Stage 1: Foundations (15-20 hours)
**Prerequisites**: Linear Algebra, Calculus basics
**Topics**:
- Supervised vs Unsupervised learning
- Training, validation, test sets
- Loss functions and optimization
- Gradient descent

**Milestones**:
- [ ] Implement linear regression from scratch
- [ ] Understand gradient descent intuitively
- [ ] Use scikit-learn for basic models

**Resources**: [Links]

### Stage 2: Core Algorithms (20-30 hours)
**Prerequisites**: Stage 1 complete
**Topics**:
- Linear models (regression, classification)
- Decision trees and random forests
- Support Vector Machines
- Evaluation metrics

**Milestones**:
- [ ] Build end-to-end ML pipeline
- [ ] Compare multiple algorithms
- [ ] Handle real-world datasets

**Resources**: [Links]

### Stage 3: Neural Networks (25-35 hours)
**Prerequisites**: Stage 2 complete, Calculus
**Topics**:
- Perceptrons and activation functions
- Backpropagation
- Deep learning frameworks (PyTorch/TensorFlow)
- CNNs and RNNs

**Milestones**:
- [ ] Build neural network from scratch
- [ ] Train image classifier
- [ ] Implement sequence model

**Resources**: [Links]

### Stage 4: Advanced Topics (20-35 hours)
**Prerequisites**: Stage 3 complete
**Topics**:
- Transfer learning
- Attention mechanisms
- Reinforcement learning basics
- MLOps and deployment

**Milestones**:
- [ ] Deploy ML model to production
- [ ] Fine-tune pre-trained model
- [ ] Implement basic RL agent

**Resources**: [Links]

## Practice Projects by Stage

### Stage 1 Projects
1. House price prediction
2. Iris flower classification
3. Boston housing regression

### Stage 2 Projects
1. Credit card fraud detection
2. Customer churn prediction
3. Sentiment analysis

### Stage 3 Projects
1. Image classification (MNIST, CIFAR-10)
2. Text generation
3. Object detection

### Stage 4 Projects
1. Deploy model as API
2. Fine-tune BERT for NLP
3. Build recommendation system

## Time Investment Summary
- Prerequisites: 20-40 hours
- Stage 1: 15-20 hours
- Stage 2: 20-30 hours
- Stage 3: 25-35 hours
- Stage 4: 20-35 hours
- **Total**: 100-160 hours

## Assessment Checkpoints
[Quiz questions for each stage]

## Common Pitfalls
[What to avoid at each stage]

## Community & Support
[Forums, Discord, study groups]
```

**Time**: 45-60 minutes to generate roadmap

---

### Example 7: Tutorial Format Learning
```bash
/learn "Docker containerization" --format tutorial --depth standard
```

**What it does**:
1. Researches Docker comprehensively
2. Creates step-by-step tutorial
3. Includes hands-on exercises
4. Provides troubleshooting for each step
5. Saves to `docs/learning/docker-containerization-tutorial.md`

**Output structure**:
```markdown
# Docker Containerization - Step-by-Step Tutorial

## What You'll Learn
- Create Docker containers
- Build Docker images
- Manage multi-container applications
- Deploy containerized apps

## Prerequisites
- Basic command line knowledge
- Understanding of applications and servers
- Docker installed ([Install Guide])

## Tutorial Structure
Estimated completion: 3-4 hours

---

## Part 1: Your First Container (30 min)

### Step 1: Run a Container
```bash
docker run hello-world
```

**What happens**:
1. Docker checks for local image
2. Downloads from Docker Hub if missing
3. Creates container from image
4. Runs container and shows output

**Expected output**:
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

**Troubleshooting**:
- If "docker: command not found": Docker not installed
- If "permission denied": Run with sudo or add user to docker group

### Step 2: Run Interactive Container
```bash
docker run -it ubuntu bash
```

**What this does**:
- `-it`: Interactive terminal
- `ubuntu`: Image name
- `bash`: Command to run

**Try this inside the container**:
```bash
ls
pwd
exit  # Exit container
```

### Step 3: List Containers
```bash
docker ps       # Running containers
docker ps -a    # All containers
```

**Practice Exercise**:
1. Run nginx container: `docker run nginx`
2. Open another terminal and check: `docker ps`
3. Stop container: `docker stop <container-id>`

---

## Part 2: Building Docker Images (45 min)

### Step 4: Create a Dockerfile
Create `Dockerfile`:
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

**Line-by-line explanation**:
- `FROM`: Base image
- `WORKDIR`: Set working directory
- `COPY`: Copy files into container
- `RUN`: Execute command during build
- `EXPOSE`: Document port
- `CMD`: Default command

### Step 5: Build the Image
```bash
docker build -t my-app:v1 .
```

**What happens**:
1. Reads Dockerfile
2. Executes each instruction
3. Creates layers
4. Tags final image

**Expected output**:
```
[+] Building 23.4s (10/10) FINISHED
...
Successfully tagged my-app:v1
```

### Step 6: Run Your Image
```bash
docker run -p 3000:3000 my-app:v1
```

**Test it**:
```bash
curl http://localhost:3000
```

**Practice Exercise**:
Build a Python Flask app with Docker
[Step-by-step instructions]

---

## Part 3: Multi-Container Applications (60 min)

### Step 7: Docker Compose
Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://db:5432/myapp
    depends_on:
      - db
  db:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=secret
    volumes:
      - db-data:/var/lib/postgresql/data

volumes:
  db-data:
```

### Step 8: Run with Compose
```bash
docker-compose up
```

**What this orchestrates**:
1. Creates network
2. Starts database container
3. Starts web container
4. Connects them together

**Practice Exercise**:
Add Redis caching layer to the stack
[Instructions]

---

## Part 4: Best Practices (45 min)

### Multi-Stage Builds
```dockerfile
# Build stage
FROM node:20 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY package*.json ./
RUN npm ci --production
CMD ["node", "dist/index.js"]
```

**Why this is better**:
- Smaller final image
- No dev dependencies in production
- Security: fewer attack vectors

### .dockerignore
```
node_modules
npm-debug.log
.git
.env
*.md
```

**Practice Exercise**:
Optimize your Dockerfile
[Checklist and steps]

---

## Troubleshooting Guide

### Issue: Image build fails
**Symptoms**: Error during `docker build`
**Common causes**:
1. Syntax error in Dockerfile
2. Missing files referenced in COPY
3. Network issues downloading packages

**Solutions**:
[Step-by-step debugging]

### Issue: Container exits immediately
**Symptoms**: Container runs and stops
**Common causes**:
1. No long-running process
2. Application error
3. Wrong CMD/ENTRYPOINT

**Solutions**:
[Debugging steps]

## Next Steps
- Learn Kubernetes for orchestration
- Study Docker security best practices
- Explore Docker networking in depth
- Practice with real projects

## Resources
- [Official Docker docs]
- [Docker best practices]
- [Docker security checklist]
```

**Time**: 30-45 minutes to generate tutorial

---

### Example 8: Quick Prerequisites Check
```bash
/learn "Rust programming" --prerequisites
```

**What it does**:
1. Analyzes Rust learning requirements
2. Identifies necessary background
3. Links to prerequisite resources
4. Estimates time investment
5. Saves to `docs/learning/rust-prerequisites.md`

**Output**:
```markdown
# Rust Programming - Prerequisites

## Required Knowledge

### Essential (Must Have)
- **Programming Fundamentals** ⚠️ REQUIRED
  - Variables, functions, control flow
  - Data structures (arrays, structs)
  - Estimated time: If new to programming: 40-60 hours
  - Resources: [Python or C fundamentals]

### Strongly Recommended
- **Systems Programming Concepts**
  - Memory management basics
  - Stack vs heap
  - Pointers/references
  - Estimated time: 5-10 hours
  - Resources: [C programming basics]

- **Command Line Proficiency**
  - Basic terminal navigation
  - Running commands
  - Estimated time: 2-3 hours
  - Resources: [Command Line Crash Course]

### Nice to Have
- **Functional Programming Concepts**
  - Higher-order functions
  - Immutability
  - Pattern matching
  - Estimated time: 5-8 hours
  - Resources: [Functional Programming intro]

## Learning Path Recommendation

### If you're new to programming:
1. Learn programming fundamentals (Python recommended)
2. Build 3-5 small projects
3. Learn basic systems concepts
4. Then start Rust

**Time to Rust-ready**: 60-80 hours

### If you know C/C++:
1. Review ownership concept (new to Rust)
2. Understand borrowing and lifetimes
3. Start Rust immediately

**Time to Rust-ready**: 2-5 hours prep

### If you know Python/JavaScript:
1. Learn systems programming basics
2. Understand memory management
3. Review static typing
4. Start Rust

**Time to Rust-ready**: 10-15 hours prep

## Assessment
[Quick quiz to check readiness]

## Resources
[Links to prerequisite learning materials]
```

**Time**: 15-20 minutes

---

### Example 9: Agent Context Engineering Pipeline
```bash
/learn "OpenAPI specification" --context-for api-architect --depth deep
```

**What it does**:
1. Researches OpenAPI 3.0 specification thoroughly
2. Extracts patterns relevant to API design
3. Includes schema examples, best practices
4. Formats for api-architect agent consumption
5. Saves to `.claude/context/api-architect/openapi-specification.md`

**Agent-optimized output**:
```markdown
# OpenAPI Specification - Context for api-architect

## Domain Overview
OpenAPI (formerly Swagger) is a specification for describing RESTful APIs.

## Core Concepts for API Design

### OpenAPI Document Structure
```yaml
openapi: 3.0.0
info:
  title: API Title
  version: 1.0.0
paths:
  /resource:
    get:
      summary: Get resource
      parameters: []
      responses: {}
```

### Schema Design Patterns

#### Pattern 1: Request Body Validation
```yaml
requestBody:
  required: true
  content:
    application/json:
      schema:
        type: object
        required: [name, email]
        properties:
          name:
            type: string
            minLength: 1
          email:
            type: string
            format: email
```

**When to use**: All POST/PUT endpoints
**Agent action**: Generate this structure for create/update endpoints

#### Pattern 2: Error Response Schema
```yaml
components:
  schemas:
    Error:
      type: object
      required: [code, message]
      properties:
        code:
          type: string
        message:
          type: string
        details:
          type: object
```

**When to use**: Consistent error handling
**Agent action**: Include in all endpoint responses

### Best Practices for api-architect

1. **Always define schemas in components**
   - Reusable schemas
   - DRY principle
   - Easier maintenance

2. **Use semantic versioning in info.version**
   ```yaml
   version: 1.2.3  # MAJOR.MINOR.PATCH
   ```

3. **Document all parameters thoroughly**
   ```yaml
   parameters:
     - name: id
       in: path
       required: true
       description: Unique identifier for the resource
       schema:
         type: string
         format: uuid
   ```

4. **Include examples in schemas**
   ```yaml
   schema:
     type: object
     example:
       id: "123e4567-e89b-12d3-a456-426614174000"
       name: "Example"
   ```

### Code Generation Templates

#### REST Endpoint Template
```yaml
/api/v1/{resource}:
  get:
    summary: List {resources}
    parameters:
      - $ref: '#/components/parameters/Page'
      - $ref: '#/components/parameters/Limit'
    responses:
      '200':
        description: Successful response
        content:
          application/json:
            schema:
              type: object
              properties:
                data:
                  type: array
                  items:
                    $ref: '#/components/schemas/{Resource}'
                pagination:
                  $ref: '#/components/schemas/Pagination'
  post:
    summary: Create {resource}
    requestBody:
      $ref: '#/components/requestBodies/{Resource}Create'
    responses:
      '201':
        description: Created
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/{Resource}'
```

### Common Anti-Patterns to Avoid

❌ **Don't**: Define schemas inline
```yaml
# Bad
responses:
  '200':
    content:
      application/json:
        schema:
          type: object
          properties:
            id: { type: string }
```

✅ **Do**: Reference component schemas
```yaml
# Good
responses:
  '200':
    content:
      application/json:
        schema:
          $ref: '#/components/schemas/Resource'
```

### Decision Framework

**When to use OpenAPI**:
- RESTful APIs (primary use case)
- Need API documentation
- Code generation desired
- API-first development

**When to consider alternatives**:
- GraphQL APIs (use GraphQL schema)
- gRPC (use protobuf)
- WebSocket-heavy (OpenAPI limited support)

### Validation Rules for Agent

When generating OpenAPI specs:
1. ✅ Validate against OpenAPI 3.0 schema
2. ✅ Ensure all $ref paths exist
3. ✅ Check all required fields present
4. ✅ Verify examples match schemas
5. ✅ Confirm security schemes defined

### Integration with API Development

```
api-architect workflow:
1. Design API endpoints → Generate OpenAPI spec
2. Validate spec → Use openapi-validator
3. Generate code → Use openapi-generator
4. Test API → Use generated client
5. Deploy → Serve spec at /api/docs
```

### Tools and Commands

```bash
# Validate OpenAPI spec
npx @redocly/cli lint openapi.yaml

# Generate TypeScript client
npx @openapitools/openapi-generator-cli generate \
  -i openapi.yaml \
  -g typescript-axios \
  -o ./generated/client

# Generate server stub
npx @openapitools/openapi-generator-cli generate \
  -i openapi.yaml \
  -g nodejs-express-server \
  -o ./generated/server
```

### Resources for Agent Reference
- [OpenAPI 3.0 Specification]
- [OpenAPI Best Practices]
- [Schema Design Patterns]
- [Code Generation Tools]

## Agent Usage Pattern

When api-architect receives request to create API:
1. Use templates from this document
2. Follow best practices listed
3. Avoid anti-patterns
4. Validate against rules
5. Generate complete OpenAPI spec
6. Include in API documentation
```

**Agent enhancement**: api-architect now has deep OpenAPI knowledge for better API design

**Time**: 60-90 minutes

---

### Example 10: Multi-Topic Learning Session
```bash
/learn "microservices architecture" --depth deep --progressive --context-for deployment-orchestrator
```

**What it does**:
1. Creates comprehensive microservices learning path
2. Generates progressive roadmap
3. Creates deployment-orchestrator context doc
4. Includes both human-readable and agent-optimized sections
5. Saves to:
   - `docs/learning/microservices-architecture-mastery.md` (human)
   - `.claude/context/deployment-orchestrator/microservices-architecture.md` (agent)

**Time**: 90-120 minutes for complete package

---

## What It Does (Automated Workflow)

### Phase 1: Topic Analysis & Planning (5-10 min)

1. **Parse Learning Intent**
   - Extract topic and learning goals
   - Identify depth level and format
   - Determine if context engineering needed
   - Check for prerequisite flags

2. **Scope Learning Domain**
   - Map topic boundaries
   - Identify core vs advanced concepts
   - Detect prerequisites
   - Plan learning structure

3. **Research Strategy**
   - Select research mode (`/deep -ws`, `/deep -r`, `/deep -wf`)
   - Identify authoritative sources
   - Plan knowledge synthesis approach

### Phase 2: Deep Research & Knowledge Gathering (15-60 min depending on depth)

4. **Quick Discovery** (if `--depth quick`)
   ```bash
   /deep -ws "<topic> fundamentals" --max-results=15
   ```
   - Fast overview of topic landscape
   - Identify key concepts
   - Extract quick reference material

5. **Comprehensive Research** (if `--depth standard` or `deep`)
   ```bash
   /deep -r "<topic> comprehensive guide" --depth=comprehensive --sources=all
   ```
   - Multi-source research
   - WebSearch for resource discovery
   - WebFetch for deep content analysis
   - Cross-reference authoritative sources

6. **Mastery-Level Investigation** (if `--depth mastery`)
   ```bash
   /deep -r "<topic>" --depth=exhaustive --sources=all
   /deep -t "analyze advanced patterns and edge cases for <topic>" --budget=8192
   ```
   - Exhaustive source gathering (30+ sources)
   - Extended thinking for pattern analysis
   - Advanced topics and edge cases
   - Expert-level insights

7. **Prerequisite Mapping** (if `--prerequisites` flag)
   - Identify foundational knowledge needed
   - Build dependency graph
   - Link to prerequisite resources
   - Estimate time investment

8. **Comparative Analysis** (if `--compare` flag)
   ```bash
   /deep -t "analyze trade-offs between <A> and <B>" --budget=4096
   ```
   - Research both options thoroughly
   - Use extended thinking for analysis
   - Create decision framework

### Phase 3: Knowledge Structuring & Synthesis (10-30 min)

9. **Progressive Learning Path** (if `--progressive` flag)
   - Create stage-based roadmap
   - Identify milestones
   - Generate practice projects
   - Estimate time per stage

10. **Knowledge Map Generation** (if `--format knowledge-map`)
    - Extract concept hierarchy
    - Map relationships and dependencies
    - Create visual structure
    - Link related concepts

11. **Tutorial Generation** (if `--format tutorial`)
    - Create step-by-step instructions
    - Include hands-on exercises
    - Add troubleshooting sections
    - Provide practice challenges

12. **Context Document Engineering** (if `--context-for <agent>`)
    - Extract agent-relevant knowledge
    - Format for machine parsing
    - Include code templates
    - Add decision frameworks
    - Create best practice checklists

### Phase 4: Integration & Enhancement (5-15 min)

13. **Build on Existing Knowledge** (if `--build-on` flag)
    - Read existing documentation
    - Identify knowledge gaps
    - Create knowledge graph connections
    - Extend or create companion doc

14. **Quality Assurance**
    - Verify all claims have sources
    - Check code examples for accuracy
    - Ensure logical flow
    - Validate prerequisite chains

15. **Cross-Linking**
    - Link to related learning docs
    - Reference prerequisite materials
    - Connect to project documentation
    - Add resource bibliography

### Phase 5: Output & Storage (2-5 min)

16. **Format Documentation**
    - Apply chosen format template
    - Add table of contents
    - Format code blocks
    - Include diagrams (ASCII/Mermaid)

17. **Save to Appropriate Location**
    ```
    Human learning: docs/learning/<topic>.md
    Agent context: .claude/context/<agent>/<topic>.md
    Comparisons: docs/learning/<topic1>-vs-<topic2>.md
    Roadmaps: docs/learning/<topic>-roadmap.md
    ```

18. **Generate Metadata**
    ```yaml
    ---
    topic: <topic>
    depth: <level>
    created: <timestamp>
    estimated_learning_time: <hours>
    prerequisites: [list]
    related_docs: [paths]
    ---
    ```

19. **Report Completion**
    - Display learning path summary
    - Show time investment estimate
    - Provide next steps
    - Link to saved documentation

---

## Integration Points

### Works With Other Commands

#### Learning → Research → Implementation
```bash
# 1. Learn the fundamentals
/learn "topic" --depth standard

# 2. Deep research specific aspect
/research "topic advanced patterns" --format comprehensive

# 3. Implement using knowledge
# Use practical-programmer or code-craftsman agent
```

#### Learning → Context → Agent Enhancement
```bash
# 1. Learn domain knowledge
/learn "Kubernetes" --context-for deployment-orchestrator

# 2. Agent now has context
# deployment-orchestrator uses Kubernetes knowledge

# 3. Verify agent knowledge
/agentinfo deployment-orchestrator
```

#### Comparison → Decision → Documentation
```bash
# 1. Compare options
/learn --compare "Option A vs Option B"

# 2. Make decision (human review)

# 3. Document chosen approach
/research "Option A implementation guide"
```

### Agent Invocation Pattern

When `/learn` is executed, Claude automatically:

1. **Invokes deep-researcher agent** for comprehensive research
2. **Uses `/deep` command** with appropriate flags:
   - Quick: `/deep -ws "<topic>"`
   - Standard: `/deep -r "<topic>" --depth=standard`
   - Deep: `/deep -r "<topic>" --depth=comprehensive`
   - Mastery: `/deep -r "<topic>" --depth=exhaustive` + `/deep -t` for analysis

3. **Structures knowledge** using docs-generator patterns
4. **Saves output** to appropriate location
5. **Returns summary** with learning path and time estimates

---

## Output Locations and Naming

### Human Learning Docs
```
docs/learning/
├── <topic>.md                           # Standard learning doc
├── <topic>-mastery.md                   # Deep mastery guide
├── <topic>-roadmap.md                   # Progressive learning path
├── <topic1>-vs-<topic2>.md             # Comparisons
└── <topic>-prerequisites.md             # Prerequisite guide
```

### Agent Context Docs
```
.claude/context/
├── <agent-name>/
│   ├── <topic>.md                       # Agent-optimized context
│   ├── patterns-<topic>.md              # Pattern library
│   └── best-practices-<topic>.md        # Best practice guide
```

### Knowledge Graph
```
docs/knowledge/
└── graph.yaml                           # Topic relationships
```

---

## Configuration

### Default Settings
Can be configured in `.claude/settings.local.json`:

```json
{
  "learn_command": {
    "default_depth": "standard",
    "default_format": "knowledge-map",
    "output_dir": "docs/learning",
    "context_dir": ".claude/context",
    "create_prerequisites": true,
    "auto_link_docs": true,
    "generate_practice": true,
    "time_estimates": true
  }
}
```

### Depth Level Mappings

```yaml
quick:
  time: "15-20 min"
  sources: 5-10
  detail: "overview and key concepts"
  research_mode: "/deep -ws"

standard:
  time: "30-45 min"
  sources: 10-20
  detail: "comprehensive understanding"
  research_mode: "/deep -r --depth=standard"

deep:
  time: "60-90 min"
  sources: 20-30
  detail: "expert-level mastery"
  research_mode: "/deep -r --depth=comprehensive"

mastery:
  time: "2-3 hours"
  sources: 30-50
  detail: "complete mastery with practice"
  research_mode: "/deep -r --depth=exhaustive + /deep -t"
```

---

## Tips for Best Results

### 1. Be Specific with Topics
```bash
✅ /learn "React Server Components architecture and data fetching patterns"
❌ /learn "React"
```

### 2. Choose Appropriate Depth
```bash
# Quick overview before meeting
/learn "GraphQL basics" --depth quick --format reference

# Learning new technology
/learn "GraphQL" --depth standard --progressive

# Mastering for production use
/learn "GraphQL" --depth mastery --context-for api-architect
```

### 3. Use Prerequisites for Efficiency
```bash
# Check before diving deep
/learn "Rust programming" --prerequisites
# Review prerequisites first, then:
/learn "Rust programming" --depth deep
```

### 4. Build Knowledge Progressively
```bash
# Start with basics
/learn "TypeScript basics" --format tutorial

# Build on it
/learn "Advanced TypeScript patterns" --build-on docs/learning/typescript-basics.md

# Create agent context
/learn "TypeScript design patterns" --context-for code-craftsman
```

### 5. Use Comparison for Decision Making
```bash
# Before architectural decision
/learn --compare "monolith vs microservices for our use case"

# Before technology choice
/learn --compare "PostgreSQL vs MongoDB vs DynamoDB"
```

### 6. Create Context for Agents
```bash
# Enhance agent capabilities
/learn "OpenAPI specification" --context-for api-architect
/learn "Kubernetes architecture" --context-for deployment-orchestrator
/learn "React patterns" --context-for frontend-architect

# Agent now has domain expertise
```

---

## Troubleshooting

### Issue: Topic too broad
**Symptoms**: Unfocused learning document, takes too long
**Solution**: Be more specific
```bash
# Instead of:
/learn "programming"

# Use:
/learn "functional programming concepts in JavaScript"
```

### Issue: Missing prerequisites
**Symptoms**: Document assumes knowledge you don't have
**Solution**: Check prerequisites first
```bash
/learn "advanced topic" --prerequisites
# Learn prerequisites, then return to main topic
```

### Issue: Not enough depth
**Symptoms**: Document too surface-level
**Solution**: Increase depth or use mastery
```bash
/learn "topic" --depth deep
# or
/learn "topic" --depth mastery --progressive
```

### Issue: Agent not using context
**Symptoms**: Agent doesn't seem to know domain knowledge
**Solution**: Verify context file was created and restart Claude
```bash
# Check context file exists
ls .claude/context/<agent-name>/<topic>.md

# Restart Claude Code
```

---

## Related Commands

- `/deep` - Direct deep research with modes
- `/research` - Codebase and API research
- `/meta-agent` - Create specialized learning agents
- `/agentinfo` - View agent capabilities and context
- `/help` - List all commands

---

## Philosophy

Learning is not about consuming information—it's about building understanding, making connections, and creating reusable knowledge that compounds over time.

The `/learn` command embodies these principles:

1. **Progressive Mastery**: From overview to expertise through structured paths
2. **Knowledge Engineering**: Create reusable context for yourself and agents
3. **Connected Learning**: Build knowledge graphs, link concepts, avoid duplication
4. **Practical Focus**: Always include practice, examples, and real-world application
5. **Agent Enhancement**: Your learning enhances your AI assistants' capabilities

Every `/learn` session builds your knowledge foundation and empowers your agents, creating a virtuous cycle of continuous improvement.

---

**Ready to learn?**

```bash
# Start your first learning session
/learn "your topic here"

# Or get a roadmap
/learn "your topic" --prerequisites --progressive

# Or enhance an agent
/learn "domain knowledge" --context-for agent-name
```

The deep-researcher agent will comprehensively research your topic, structure the knowledge for mastery, and create documentation that serves both you and your AI assistants.
