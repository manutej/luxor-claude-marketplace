---
name: hasura-graphql-engine
description: Complete guide for Hasura GraphQL Engine including instant GraphQL APIs, permissions, authentication, event triggers, actions, and production deployment
tags: [hasura, graphql, permissions, authentication, event-triggers, actions, remote-schemas, postgres, real-time, subscriptions]
tier: tier-1
---

# Hasura GraphQL Engine Mastery

A comprehensive skill for building production-ready GraphQL APIs with Hasura. Master instant API generation, granular permissions, authentication integration, event-driven architectures, custom business logic, and remote schema stitching for modern applications.

## When to Use This Skill

Use Hasura GraphQL Engine when:

- Building GraphQL APIs rapidly without writing backend code
- Need instant CRUD APIs from existing PostgreSQL databases
- Implementing granular row-level and column-level security
- Building real-time applications with GraphQL subscriptions
- Integrating multiple data sources (databases, REST APIs, GraphQL services)
- Creating event-driven architectures with database triggers
- Extending GraphQL with custom business logic via Actions
- Implementing authentication and authorization at the API layer
- Building admin panels, dashboards, or internal tools quickly
- Migrating from REST to GraphQL without rewriting backend
- Needing production-ready features (caching, rate limiting, monitoring)
- Building multi-tenant SaaS applications with role-based access

## Core Concepts

### Instant GraphQL API Generation

Hasura's primary value proposition is **automatic GraphQL API generation** from your database schema:

- **Table Tracking**: Point Hasura at PostgreSQL tables to instantly get queries, mutations, and subscriptions
- **Relationship Detection**: Automatically infers foreign key relationships as GraphQL connections
- **Type Safety**: Database schema translates directly to GraphQL types
- **Zero Code**: No resolver writing, no ORM configuration, no boilerplate
- **Real-time by Default**: Every query automatically has a subscription counterpart

**How it works:**
1. Connect Hasura to your PostgreSQL database
2. Track tables in the Hasura Console
3. GraphQL API is immediately available with:
   - `query` - Fetch data with filtering, sorting, pagination
   - `mutation` - Insert, update, delete operations
   - `subscription` - Real-time data updates via WebSockets

### Metadata-Driven Architecture

Hasura is **metadata-driven**, not code-driven:

- **Metadata**: JSON/YAML configuration defining your API
- **Declarative**: Define what you want, not how to implement it
- **Version Control**: Metadata files can be committed to Git
- **CLI Migration**: Hasura CLI manages metadata and migrations
- **Programmatic Control**: Metadata API for automation

**Key metadata components:**
- Table tracking and relationships
- Permission rules
- Remote schemas
- Actions
- Event triggers
- Custom functions

### Permission System

Hasura's **permission system** is its most powerful feature, enabling fine-grained access control:

- **Role-Based**: Define permissions per GraphQL operation per role
- **Row-Level Security**: Control which rows users can access
- **Column-Level Security**: Hide sensitive columns from specific roles
- **Session Variables**: Dynamic permissions based on JWT claims or webhook data
- **Check Constraints**: Boolean expressions determining access

**Permission Types:**
- `select` - Read permissions
- `insert` - Create permissions
- `update` - Modify permissions
- `delete` - Remove permissions

### Authentication Integration

Hasura **delegates authentication** to your auth service but **handles authorization**:

- **JWT Mode**: Validate JWT tokens containing user claims
- **Webhook Mode**: Call webhook to get session variables
- **Session Variables**: `x-hasura-role`, `x-hasura-user-id`, custom claims
- **Multi-Provider**: Support Auth0, Firebase, Cognito, custom auth

**Auth Flow:**
1. User authenticates with your auth service (Auth0, Firebase, custom)
2. Auth service issues JWT with Hasura claims
3. Client sends JWT in Authorization header
4. Hasura validates JWT and extracts session variables
5. Permissions evaluated using session variables
6. GraphQL query executed with appropriate access control

### Event Triggers

**Event Triggers** enable event-driven architectures by invoking webhooks on database changes:

- **Database Events**: INSERT, UPDATE, DELETE triggers
- **Reliable Delivery**: At-least-once delivery with retries
- **Payload**: Old and new row data in JSON
- **Async Processing**: Long-running tasks, external integrations
- **Use Cases**: Send emails, sync to Elasticsearch, update cache, trigger workflows

### Actions

**Actions** extend Hasura with custom business logic:

- **Custom Mutations**: Define GraphQL mutations handled by your code
- **Custom Queries**: Add custom query logic beyond database access
- **REST Integration**: Call REST APIs from GraphQL
- **Type Safety**: Define input/output types in GraphQL SDL
- **Handler**: Your HTTP endpoint receives GraphQL variables

**Common use cases:**
- Payment processing
- Complex validations
- Third-party API calls
- Custom algorithms
- File uploads
- Email sending

### Remote Schemas

**Remote Schemas** enable schema stitching by merging external GraphQL APIs:

- **Schema Stitching**: Unify multiple GraphQL services
- **Type Extension**: Extend types with fields from remote schemas
- **Permissions**: Apply role-based permissions to remote schemas
- **Namespace**: Isolate remote schemas to avoid conflicts
- **Use Cases**: Microservices, legacy GraphQL APIs, third-party services

### Real-Time Subscriptions

Hasura provides **native GraphQL subscriptions**:

- **Live Queries**: Automatically push updates when data changes
- **WebSocket Protocol**: Efficient bi-directional communication
- **Multiplexing**: Optimize subscriptions for many concurrent clients
- **Filtering**: Subscribe to specific subsets of data
- **Polling Fallback**: HTTP-based streaming for restricted networks

## Permission System Deep Dive

### Row-Level Security

Row-level security uses **boolean check expressions** to filter accessible rows:

**Example: Users can only see their own data**
```json
{
  "check": {
    "user_id": {
      "_eq": "X-Hasura-User-Id"
    }
  }
}
```

**Example: Multi-tenant data isolation**
```json
{
  "check": {
    "tenant_id": {
      "_eq": "X-Hasura-Tenant-Id"
    }
  }
}
```

**Example: Complex access rules**
```json
{
  "check": {
    "_or": [
      {
        "user_id": {
          "_eq": "X-Hasura-User-Id"
        }
      },
      {
        "is_public": {
          "_eq": true
        }
      }
    ]
  }
}
```

### Column-Level Security

Control which columns are visible per role:

**Example: Hide sensitive user fields**
```yaml
select:
  columns:
    - id
    - username
    - email
    # password_hash is hidden
    # created_at is hidden
```

**Example: Different views for different roles**
```yaml
# Admin role sees all columns
select:
  columns: "*"

# User role sees limited columns
select:
  columns:
    - id
    - username
    - profile_picture
```

### Insert Permissions

Control what data can be inserted:

**Example: Set user_id from session**
```json
{
  "check": {
    "user_id": {
      "_eq": "X-Hasura-User-Id"
    }
  },
  "set": {
    "user_id": "X-Hasura-User-Id"
  }
}
```

**Example: Validate ownership before insert**
```json
{
  "check": {
    "project": {
      "owner_id": {
        "_eq": "X-Hasura-User-Id"
      }
    }
  }
}
```

### Update Permissions

Control which rows can be updated and what values can be set:

**Example: Update own data only**
```json
{
  "filter": {
    "user_id": {
      "_eq": "X-Hasura-User-Id"
    }
  },
  "check": {
    "user_id": {
      "_eq": "X-Hasura-User-Id"
    }
  },
  "set": {
    "updated_at": "now()"
  }
}
```

**filter**: Which rows can be selected for update
**check**: Validation after update completes
**set**: Automatically set column values

### Delete Permissions

Control which rows can be deleted:

**Example: Delete own data only**
```json
{
  "filter": {
    "user_id": {
      "_eq": "X-Hasura-User-Id"
    }
  }
}
```

## Authentication Integration

### JWT Mode Configuration

Configure Hasura to validate JWT tokens:

**Environment Variable:**
```bash
HASURA_GRAPHQL_JWT_SECRET='{
  "type": "RS256",
  "key": "-----BEGIN PUBLIC KEY-----\n...\n-----END PUBLIC KEY-----"
}'
```

**JWT Claims Structure:**
```json
{
  "sub": "user123",
  "iat": 1633024800,
  "exp": 1633111200,
  "https://hasura.io/jwt/claims": {
    "x-hasura-default-role": "user",
    "x-hasura-allowed-roles": ["user", "admin"],
    "x-hasura-user-id": "user123",
    "x-hasura-org-id": "org456"
  }
}
```

**Required Claims:**
- `x-hasura-default-role`: Default role if not specified in request
- `x-hasura-allowed-roles`: Array of roles user can assume
- Custom claims like `x-hasura-user-id` for permission checks

### Auth0 Integration

**Auth0 Rule to add Hasura claims:**
```javascript
function (user, context, callback) {
  const namespace = "https://hasura.io/jwt/claims";
  context.idToken[namespace] = {
    'x-hasura-default-role': 'user',
    'x-hasura-allowed-roles': ['user'],
    'x-hasura-user-id': user.user_id
  };
  callback(null, user, context);
}
```

**Client usage:**
```javascript
const token = await auth0Client.getTokenSilently();

const response = await fetch('https://my-hasura.app/v1/graphql', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ query, variables })
});
```

### Firebase Integration

**Firebase custom claims:**
```javascript
// Admin SDK
const admin = require('firebase-admin');

async function setCustomClaims(uid) {
  await admin.auth().setCustomUserClaims(uid, {
    'https://hasura.io/jwt/claims': {
      'x-hasura-default-role': 'user',
      'x-hasura-allowed-roles': ['user'],
      'x-hasura-user-id': uid
    }
  });
}
```

### Webhook Mode

Alternative to JWT - Hasura calls your webhook for each request:

**Webhook endpoint:**
```javascript
app.post('/auth-webhook', async (req, res) => {
  const authHeader = req.headers['authorization'];

  // Validate token (your logic)
  const user = await validateToken(authHeader);

  if (!user) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  // Return session variables
  res.json({
    'X-Hasura-User-Id': user.id,
    'X-Hasura-Role': user.role,
    'X-Hasura-Org-Id': user.orgId
  });
});
```

**Hasura config:**
```bash
HASURA_GRAPHQL_AUTH_HOOK=https://myapp.com/auth-webhook
HASURA_GRAPHQL_AUTH_HOOK_MODE=POST
```

## Event Triggers

### Creating Event Triggers

Event triggers invoke webhooks on database changes:

**Via Console:**
1. Navigate to Events tab
2. Create Trigger
3. Select table and operations (INSERT, UPDATE, DELETE)
4. Provide webhook URL
5. Configure retry and timeout settings

**Via Metadata API:**
```http
POST /v1/metadata HTTP/1.1
Content-Type: application/json
X-Hasura-Role: admin

{
  "type": "create_event_trigger",
  "args": {
    "name": "user_created",
    "table": {
      "name": "users",
      "schema": "public"
    },
    "webhook": "https://myapp.com/webhooks/user-created",
    "insert": {
      "columns": "*"
    },
    "retry_conf": {
      "num_retries": 3,
      "interval_sec": 10,
      "timeout_sec": 60
    }
  }
}
```

### Event Payload Structure

Webhook receives structured JSON payload:

```json
{
  "event": {
    "session_variables": {
      "x-hasura-role": "user",
      "x-hasura-user-id": "123"
    },
    "op": "INSERT",
    "data": {
      "old": null,
      "new": {
        "id": "uuid-here",
        "email": "user@example.com",
        "created_at": "2025-01-15T10:30:00Z"
      }
    }
  },
  "created_at": "2025-01-15T10:30:00.123456Z",
  "id": "event-id",
  "trigger": {
    "name": "user_created"
  },
  "table": {
    "schema": "public",
    "name": "users"
  }
}
```

### Event Trigger Use Cases

**Send Welcome Email:**
```javascript
// Webhook handler
app.post('/webhooks/user-created', async (req, res) => {
  const { event } = req.body;
  const user = event.data.new;

  await sendEmail({
    to: user.email,
    subject: 'Welcome!',
    template: 'welcome',
    data: { name: user.name }
  });

  res.json({ success: true });
});
```

**Sync to Elasticsearch:**
```javascript
app.post('/webhooks/product-updated', async (req, res) => {
  const { event } = req.body;
  const product = event.data.new;

  await esClient.index({
    index: 'products',
    id: product.id,
    body: product
  });

  res.json({ success: true });
});
```

**Trigger Workflow:**
```javascript
app.post('/webhooks/order-placed', async (req, res) => {
  const { event } = req.body;
  const order = event.data.new;

  // Trigger payment processing
  await processPayment(order.id);

  // Notify inventory system
  await updateInventory(order.items);

  // Send confirmation email
  await sendOrderConfirmation(order);

  res.json({ success: true });
});
```

## Actions (Custom Business Logic)

### Defining Actions

Actions extend GraphQL with custom mutations and queries:

**GraphQL SDL Definition:**
```graphql
type Mutation {
  login(username: String!, password: String!): LoginResponse
}

type LoginResponse {
  accessToken: String!
  refreshToken: String!
  user: User!
}
```

**Action Configuration:**
```yaml
- name: login
  definition:
    kind: synchronous
    handler: https://myapp.com/actions/login
    forward_client_headers: true
    headers:
      - name: X-API-Key
        value: secret-key
  permissions:
    - role: anonymous
```

### Action Handler Implementation

**Express.js Handler:**
```javascript
app.post('/actions/login', async (req, res) => {
  const { input, session_variables } = req.body;
  const { username, password } = input;

  // Validate credentials
  const user = await validateCredentials(username, password);

  if (!user) {
    return res.status(401).json({
      message: 'Invalid credentials'
    });
  }

  // Generate tokens
  const accessToken = generateJWT(user);
  const refreshToken = generateRefreshToken(user);

  // Return action response
  res.json({
    accessToken,
    refreshToken,
    user: {
      id: user.id,
      username: user.username,
      email: user.email
    }
  });
});
```

### Action Permissions

Control which roles can execute actions:

**Via Metadata API:**
```http
POST /v1/metadata HTTP/1.1
Content-Type: application/json
X-Hasura-Role: admin

{
  "type": "create_action_permission",
  "args": {
    "action": "insertAuthor",
    "role": "user"
  }
}
```

**Multiple Roles:**
```yaml
permissions:
  - role: user
  - role: admin
  - role: anonymous
```

### Action Types

**Synchronous Actions:**
- Client waits for response
- Use for: Login, payments, validations
- Timeout: Configurable (default 30s)

**Asynchronous Actions:**
- Returns immediately with action ID
- Use for: Long-running tasks, batch processing
- Poll for completion or use webhooks

### Advanced Action Patterns

**Payment Processing:**
```graphql
type Mutation {
  processPayment(
    orderId: ID!
    amount: Float!
    currency: String!
    paymentMethod: String!
  ): PaymentResponse
}

type PaymentResponse {
  success: Boolean!
  transactionId: String
  error: String
}
```

**File Upload:**
```graphql
type Mutation {
  uploadFile(
    file: String!  # Base64 encoded
    fileName: String!
    mimeType: String!
  ): FileUploadResponse
}

type FileUploadResponse {
  url: String!
  fileId: ID!
}
```

**Complex Validation:**
```graphql
type Mutation {
  createProject(
    name: String!
    description: String!
    teamMembers: [ID!]!
  ): CreateProjectResponse
}

type CreateProjectResponse {
  project: Project
  errors: [ValidationError!]
}

type ValidationError {
  field: String!
  message: String!
}
```

## Remote Schemas

### Adding Remote Schemas

Integrate external GraphQL APIs:

**Via Metadata API:**
```http
POST /v1/metadata HTTP/1.1
Content-Type: application/json
X-Hasura-Role: admin

{
  "type": "add_remote_schema",
  "args": {
    "name": "auth0_api",
    "definition": {
      "url": "https://myapp.auth0.com/graphql",
      "headers": [
        {
          "name": "Authorization",
          "value": "Bearer ${AUTH0_TOKEN}"
        }
      ],
      "forward_client_headers": false,
      "timeout_seconds": 60
    }
  }
}
```

### Remote Schema Customization

Customize type and field names to avoid conflicts:

```http
{
  "type": "add_remote_schema",
  "args": {
    "name": "countries",
    "definition": {
      "url": "https://countries.trevorblades.com/graphql",
      "customization": {
        "root_fields_namespace": "countries_api",
        "type_names": {
          "prefix": "Countries_",
          "suffix": "_Type"
        },
        "field_names": [
          {
            "parent_type": "Country",
            "prefix": "country_"
          }
        ]
      }
    }
  }
}
```

### Remote Schema Permissions

Apply role-based permissions to remote schemas:

**Original Remote Schema:**
```graphql
type User {
  id: ID!
  first_name: String!
  last_name: String!
  phone: String!
  email: String!
}

type Query {
  user(id: ID!): User
  get_users_by_name(first_name: String!, last_name: String): [User]
}
```

**Restricted Schema for 'public' Role:**
```graphql
type User {
  first_name: String!
  last_name: String!
}

type Query {
  get_users_by_name(first_name: String!, last_name: String): [User]
}
```

**Via Metadata API:**
```http
POST /v1/metadata HTTP/1.1
Content-Type: application/json
X-Hasura-Role: admin

{
  "type": "add_remote_schema_permissions",
  "args": {
    "remote_schema": "user_api",
    "role": "public",
    "definition": {
      "schema": "type User { first_name: String! last_name: String! } type Query { get_users_by_name(first_name: String!, last_name: String): [User] }"
    }
  }
}
```

### Remote Schema Argument Presets

Automatically inject session variables into remote schema queries:

**Session Variable Preset:**
```graphql
type Query {
  get_user(id: ID! @preset(value: "x-hasura-user-id")): User
  get_user_activities(user_id: ID!, limit: Int!): [Activity]
}
```

**Static Value Preset:**
```graphql
type Query {
  get_user(id: ID! @preset(value: "x-hasura-user-id")): User
  get_user_activities(
    user_id: ID!
    limit: Int! @preset(value: 10)
  ): [Activity]
}
```

**Literal String (not session variable):**
```graphql
type Query {
  hello(text: String! @preset(value: "x-hasura-hello", static: true))
}
```

### Remote Relationships

Connect local database tables to remote schemas:

**Example: Link local customer to remote payments API**

**SQL Table:**
```sql
CREATE TABLE customer (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);
```

**Remote Schema (Payments API):**
```graphql
type Transaction {
  customer_id: Int!
  amount: Int!
  time: String!
  merchant: String!
}

type Query {
  transactions(customer_id: String!, limit: Int): [Transaction]
}
```

**Remote Relationship Definition:**
```yaml
- table:
    name: customer
    schema: public
  remote_relationships:
    - name: customer_transactions_history
      definition:
        remote_schema: payments
        hasura_fields:
          - id
        remote_field:
          transactions:
            arguments:
              customer_id: $id
```

**GraphQL Query with Remote Relationship:**
```graphql
query {
  customer {
    name
    customer_transactions_history {
      amount
      time
    }
  }
}
```

## Production Deployment

### Docker Deployment

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    restart: always
    volumes:
      - db_data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: postgrespassword
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  hasura:
    image: hasura/graphql-engine:v2.36.0
    ports:
      - "8080:8080"
    depends_on:
      postgres:
        condition: service_healthy
    restart: always
    environment:
      HASURA_GRAPHQL_DATABASE_URL: postgres://postgres:postgrespassword@postgres:5432/postgres
      HASURA_GRAPHQL_ENABLE_CONSOLE: "true"
      HASURA_GRAPHQL_DEV_MODE: "true"
      HASURA_GRAPHQL_ENABLED_LOG_TYPES: startup, http-log, webhook-log, websocket-log, query-log
      HASURA_GRAPHQL_ADMIN_SECRET: myadminsecretkey
      HASURA_GRAPHQL_JWT_SECRET: '{"type":"HS256","key":"super-secret-jwt-signing-key-min-32-chars"}'
      HASURA_GRAPHQL_UNAUTHORIZED_ROLE: anonymous

volumes:
  db_data:
```

### Kubernetes Deployment

**hasura-deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hasura
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hasura
  template:
    metadata:
      labels:
        app: hasura
    spec:
      containers:
      - name: hasura
        image: hasura/graphql-engine:v2.36.0
        ports:
        - containerPort: 8080
        env:
        - name: HASURA_GRAPHQL_DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: hasura-secrets
              key: database-url
        - name: HASURA_GRAPHQL_ADMIN_SECRET
          valueFrom:
            secretKeyRef:
              name: hasura-secrets
              key: admin-secret
        - name: HASURA_GRAPHQL_JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: hasura-secrets
              key: jwt-secret
        - name: HASURA_GRAPHQL_ENABLE_CONSOLE
          value: "false"
        - name: HASURA_GRAPHQL_ENABLE_TELEMETRY
          value: "false"
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: hasura
  namespace: production
spec:
  type: ClusterIP
  selector:
    app: hasura
  ports:
  - port: 80
    targetPort: 8080
```

### Environment Variables (Production)

**Essential Production Config:**
```bash
# Database
HASURA_GRAPHQL_DATABASE_URL=postgres://user:password@host:5432/dbname

# Security
HASURA_GRAPHQL_ADMIN_SECRET=strong-random-secret
HASURA_GRAPHQL_JWT_SECRET='{"type":"RS256","key":"..."}'
HASURA_GRAPHQL_UNAUTHORIZED_ROLE=anonymous

# Performance
HASURA_GRAPHQL_ENABLE_CONSOLE=false
HASURA_GRAPHQL_DEV_MODE=false
HASURA_GRAPHQL_ENABLE_TELEMETRY=false

# Logging
HASURA_GRAPHQL_ENABLED_LOG_TYPES=startup,http-log,webhook-log,websocket-log

# Rate Limiting
HASURA_GRAPHQL_RATE_LIMIT_PER_MINUTE=1000

# CORS
HASURA_GRAPHQL_CORS_DOMAIN=https://myapp.com,https://admin.myapp.com

# Connections
HASURA_GRAPHQL_PG_CONNECTIONS=50
HASURA_GRAPHQL_PG_TIMEOUT=60
```

### Monitoring and Observability

**Health Check Endpoint:**
```bash
curl http://hasura:8080/healthz
# Returns: OK
```

**Prometheus Metrics:**
```bash
HASURA_GRAPHQL_ENABLE_METRICS=true
HASURA_GRAPHQL_METRICS_SECRET=metrics-secret

# Access at: http://hasura:8080/v1/metrics
```

**Structured Logging:**
```bash
HASURA_GRAPHQL_ENABLED_LOG_TYPES=startup,http-log,webhook-log,websocket-log,query-log
HASURA_GRAPHQL_LOG_LEVEL=info
```

**APM Integration (Datadog example):**
```yaml
env:
  - name: HASURA_GRAPHQL_ENABLE_APM
    value: "true"
  - name: DD_AGENT_HOST
    valueFrom:
      fieldRef:
        fieldPath: status.hostIP
  - name: DD_SERVICE
    value: "hasura-graphql"
  - name: DD_ENV
    value: "production"
```

## Migrations and Version Control

### Hasura CLI Setup

**Initialize Hasura project:**
```bash
hasura init my-project --endpoint https://hasura.myapp.com
cd my-project
```

**Project structure:**
```
my-project/
├── config.yaml              # Hasura CLI config
├── metadata/                # Metadata files
│   ├── databases/
│   │   └── default/
│   │       ├── tables/
│   │       │   ├── public_users.yaml
│   │       │   └── public_posts.yaml
│   ├── actions.yaml
│   ├── remote_schemas.yaml
│   └── version.yaml
└── migrations/              # Database migrations
    └── default/
        ├── 1642531200000_create_users_table/
        │   └── up.sql
        └── 1642531300000_create_posts_table/
            └── up.sql
```

### Creating Migrations

**Via Console (auto-tracked):**
```bash
# Start console with migration tracking
hasura console

# Make changes in console UI
# Migrations auto-generated in migrations/ folder
```

**Manual migration:**
```bash
# Create migration
hasura migrate create create_users_table --database-name default

# Edit generated SQL files
# migrations/default/{timestamp}_create_users_table/up.sql
# migrations/default/{timestamp}_create_users_table/down.sql
```

**Example migration (up.sql):**
```sql
CREATE TABLE public.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  username TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_username ON public.users(username);
```

**Example migration (down.sql):**
```sql
DROP TABLE IF EXISTS public.users CASCADE;
```

### Applying Migrations

**Apply migrations:**
```bash
# Apply all pending migrations
hasura migrate apply --database-name default

# Apply specific version
hasura migrate apply --version 1642531200000 --database-name default

# Check migration status
hasura migrate status --database-name default
```

### Exporting and Importing Metadata

**Export metadata:**
```bash
hasura metadata export
# Exports to metadata/ folder
```

**Apply metadata:**
```bash
hasura metadata apply
# Applies metadata from metadata/ folder
```

**Reload metadata:**
```bash
hasura metadata reload
```

### CI/CD Integration

**GitHub Actions example:**
```yaml
name: Deploy Hasura

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Install Hasura CLI
        run: |
          curl -L https://github.com/hasura/graphql-engine/raw/stable/cli/get.sh | bash

      - name: Apply Migrations
        env:
          HASURA_GRAPHQL_ENDPOINT: ${{ secrets.HASURA_ENDPOINT }}
          HASURA_GRAPHQL_ADMIN_SECRET: ${{ secrets.HASURA_ADMIN_SECRET }}
        run: |
          cd hasura
          hasura migrate apply --database-name default
          hasura metadata apply

      - name: Reload Metadata
        env:
          HASURA_GRAPHQL_ENDPOINT: ${{ secrets.HASURA_ENDPOINT }}
          HASURA_GRAPHQL_ADMIN_SECRET: ${{ secrets.HASURA_ADMIN_SECRET }}
        run: |
          cd hasura
          hasura metadata reload
```

## Best Practices

### Security Best Practices

1. **Always use ADMIN_SECRET in production**
   - Never expose admin API without authentication
   - Rotate secrets regularly
   - Use strong, random secrets (min 32 characters)

2. **Implement proper JWT validation**
   - Use RS256 (asymmetric) in production
   - Set appropriate token expiration
   - Validate issuer and audience claims

3. **Apply least-privilege permissions**
   - Start with no access, add permissions as needed
   - Use row-level security for all tables
   - Hide sensitive columns from unauthorized roles

4. **Disable console in production**
   - `HASURA_GRAPHQL_ENABLE_CONSOLE=false`
   - Use metadata files and CLI for changes

5. **Enable rate limiting**
   - Protect against DoS attacks
   - Set per-role limits if needed
   - Monitor and adjust based on usage

6. **Validate webhook payloads**
   - Use webhook secrets for event triggers
   - Validate action inputs
   - Sanitize all user inputs

### Performance Best Practices

1. **Optimize database queries**
   - Create appropriate indexes
   - Use database views for complex queries
   - Leverage PostgreSQL performance tuning

2. **Use query caching**
   - Enable @cached directive for expensive queries
   - Set appropriate TTL values
   - Cache at CDN level when possible

3. **Limit query depth and complexity**
   - Set max query depth limits
   - Restrict deeply nested queries
   - Use pagination for large result sets

4. **Configure connection pooling**
   - Tune `HASURA_GRAPHQL_PG_CONNECTIONS`
   - Monitor connection usage
   - Use PgBouncer for large deployments

5. **Optimize subscriptions**
   - Use subscription multiplexing
   - Limit concurrent subscriptions per client
   - Consider polling for less time-sensitive data

### Development Workflow Best Practices

1. **Version control metadata**
   - Commit metadata/ folder to Git
   - Use migrations for all schema changes
   - Review metadata changes in PRs

2. **Environment separation**
   - Development, staging, production environments
   - Use different admin secrets per environment
   - Test migrations in staging first

3. **Testing strategy**
   - Test permissions thoroughly
   - Integration test event triggers
   - Test action handlers independently

4. **Documentation**
   - Document custom actions and their inputs/outputs
   - Explain complex permission rules
   - Maintain API documentation for consumers

5. **Monitoring and alerting**
   - Monitor query performance
   - Alert on failed webhooks/event triggers
   - Track error rates and latencies

## Common Patterns and Examples

### Pattern 1: Multi-Tenant SaaS

**Schema:**
```sql
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL
);

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  organization_id UUID NOT NULL REFERENCES organizations(id)
);

CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  organization_id UUID NOT NULL REFERENCES organizations(id)
);
```

**Permissions (users table):**
```json
{
  "filter": {
    "organization_id": {
      "_eq": "X-Hasura-Org-Id"
    }
  }
}
```

**JWT Claims:**
```json
{
  "https://hasura.io/jwt/claims": {
    "x-hasura-default-role": "user",
    "x-hasura-allowed-roles": ["user", "org-admin"],
    "x-hasura-user-id": "user-uuid",
    "x-hasura-org-id": "org-uuid"
  }
}
```

### Pattern 2: Social Media Application

**Schema:**
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  bio TEXT,
  avatar_url TEXT
);

CREATE TABLE posts (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  content TEXT NOT NULL,
  is_public BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE follows (
  follower_id UUID REFERENCES users(id),
  following_id UUID REFERENCES users(id),
  PRIMARY KEY (follower_id, following_id)
);

CREATE TABLE likes (
  user_id UUID REFERENCES users(id),
  post_id UUID REFERENCES posts(id),
  PRIMARY KEY (user_id, post_id)
);
```

**Permission: View posts (user can see own posts, public posts, and posts from followed users):**
```json
{
  "filter": {
    "_or": [
      {
        "user_id": {
          "_eq": "X-Hasura-User-Id"
        }
      },
      {
        "is_public": {
          "_eq": true
        }
      },
      {
        "user": {
          "followers": {
            "follower_id": {
              "_eq": "X-Hasura-User-Id"
            }
          }
        }
      }
    ]
  }
}
```

### Pattern 3: E-Commerce Platform

**Schema:**
```sql
CREATE TABLE products (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  stock_quantity INT NOT NULL,
  is_active BOOLEAN DEFAULT true
);

CREATE TABLE orders (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  status TEXT NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE order_items (
  id UUID PRIMARY KEY,
  order_id UUID REFERENCES orders(id),
  product_id UUID REFERENCES products(id),
  quantity INT NOT NULL,
  price DECIMAL(10,2) NOT NULL
);
```

**Event Trigger: Order confirmation email**
```javascript
app.post('/webhooks/order-created', async (req, res) => {
  const { event } = req.body;
  const order = event.data.new;

  // Fetch order details with items
  const orderDetails = await fetchOrderDetails(order.id);

  // Send confirmation email
  await sendEmail({
    to: orderDetails.user.email,
    template: 'order-confirmation',
    data: orderDetails
  });

  res.json({ success: true });
});
```

**Action: Process payment**
```graphql
type Mutation {
  processPayment(
    orderId: ID!
    paymentMethodId: String!
  ): PaymentResponse
}

type PaymentResponse {
  success: Boolean!
  orderId: ID!
  transactionId: String
  error: String
}
```

### Pattern 4: Real-Time Collaboration

**Schema:**
```sql
CREATE TABLE documents (
  id UUID PRIMARY KEY,
  title TEXT NOT NULL,
  content JSONB NOT NULL DEFAULT '{}'::jsonb,
  owner_id UUID NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE document_collaborators (
  document_id UUID REFERENCES documents(id),
  user_id UUID NOT NULL,
  permission TEXT NOT NULL, -- 'read', 'write', 'admin'
  PRIMARY KEY (document_id, user_id)
);
```

**Permission: Access documents (own or collaborated):**
```json
{
  "filter": {
    "_or": [
      {
        "owner_id": {
          "_eq": "X-Hasura-User-Id"
        }
      },
      {
        "collaborators": {
          "user_id": {
            "_eq": "X-Hasura-User-Id"
          }
        }
      }
    ]
  }
}
```

**GraphQL Subscription: Real-time updates**
```graphql
subscription DocumentUpdates($documentId: uuid!) {
  documents_by_pk(id: $documentId) {
    id
    title
    content
    updated_at
  }
}
```

### Pattern 5: Admin Dashboard with Analytics

**Custom SQL Function for analytics:**
```sql
CREATE OR REPLACE FUNCTION get_user_stats(user_row users)
RETURNS TABLE (
  total_posts INT,
  total_followers INT,
  total_following INT,
  engagement_rate DECIMAL
) AS $$
  SELECT
    (SELECT COUNT(*) FROM posts WHERE user_id = user_row.id)::INT,
    (SELECT COUNT(*) FROM follows WHERE following_id = user_row.id)::INT,
    (SELECT COUNT(*) FROM follows WHERE follower_id = user_row.id)::INT,
    (SELECT AVG(like_count) FROM posts WHERE user_id = user_row.id)::DECIMAL
$$ LANGUAGE SQL STABLE;
```

**Track function in Hasura:**
```yaml
- function:
    name: get_user_stats
    schema: public
  configuration:
    custom_root_fields:
      function: getUserStats
```

**GraphQL Query:**
```graphql
query UserWithStats {
  users {
    id
    username
    get_user_stats {
      total_posts
      total_followers
      total_following
      engagement_rate
    }
  }
}
```

## Troubleshooting

### Common Issues and Solutions

**Issue: JWT validation failing**
```
Solution:
1. Verify JWT secret configuration matches your auth provider
2. Check JWT contains required Hasura claims
3. Ensure claims are in correct namespace (https://hasura.io/jwt/claims)
4. Validate JWT hasn't expired
5. Check issuer and audience if configured
```

**Issue: Permission denied errors**
```
Solution:
1. Check role is in allowed_roles
2. Verify permission rules allow the operation
3. Test with admin role to isolate permission issue
4. Check session variables are being sent correctly
5. Review both row-level and column-level permissions
```

**Issue: Event trigger not firing**
```
Solution:
1. Check webhook is accessible from Hasura
2. Verify table name and operation match trigger config
3. Check webhook returns 200 status
4. Review event trigger logs in Hasura console
5. Ensure database triggers are enabled
```

**Issue: Action returning errors**
```
Solution:
1. Verify action handler URL is accessible
2. Check request/response format matches action definition
3. Review action handler logs
4. Test action handler independently
5. Verify permissions allow the role to execute action
```

**Issue: Remote schema not loading**
```
Solution:
1. Verify remote GraphQL endpoint is accessible
2. Check authentication headers if required
3. Test remote schema independently
4. Review timeout settings
5. Check for type name conflicts
```

**Issue: Subscription connection dropping**
```
Solution:
1. Check WebSocket support on hosting platform
2. Verify connection timeout settings
3. Implement reconnection logic in client
4. Check for firewall/proxy blocking WebSockets
5. Monitor connection pool limits
```

## Additional Resources

### Official Documentation
- Hasura Docs: https://hasura.io/docs
- Hasura GraphQL API Reference: https://hasura.io/docs/latest/api-reference
- Hasura Cloud: https://hasura.io/cloud

### Learning Resources
- Hasura Learn: https://hasura.io/learn
- Hasura Blog: https://hasura.io/blog
- Hasura YouTube: https://youtube.com/hasurahq

### Community
- Discord: https://discord.gg/hasura
- GitHub: https://github.com/hasura/graphql-engine
- Forum: https://github.com/hasura/graphql-engine/discussions

### Tools and Integrations
- Hasura CLI: https://hasura.io/docs/latest/hasura-cli/overview
- Hasura Cloud Console: https://cloud.hasura.io
- GraphQL Code Generator: https://www.graphql-code-generator.com

---

**Skill Version**: 1.0.0
**Last Updated**: January 2025
**Skill Category**: Backend, GraphQL, API Development, Real-time, Database
**Compatible With**: PostgreSQL, Auth0, Firebase, Cognito, Kubernetes, Docker
