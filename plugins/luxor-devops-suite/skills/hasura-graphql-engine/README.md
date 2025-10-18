# Hasura GraphQL Engine Skill

Comprehensive skill for building production-ready GraphQL APIs with Hasura GraphQL Engine. Master instant API generation, granular permissions, authentication integration, event-driven architectures, and custom business logic.

## Overview

Hasura GraphQL Engine is an **instant GraphQL API generator** that provides:

- **Instant APIs**: Auto-generate GraphQL APIs from PostgreSQL databases
- **Real-time**: Built-in GraphQL subscriptions for live data
- **Permissions**: Granular row-level and column-level security
- **Authentication**: JWT and webhook-based auth integration
- **Event Triggers**: Database change webhooks for event-driven architectures
- **Actions**: Extend GraphQL with custom business logic
- **Remote Schemas**: Stitch multiple GraphQL services together
- **Production Ready**: Caching, rate limiting, monitoring out of the box

## The Hasura Value Proposition

### Traditional GraphQL Backend

```javascript
// Traditional approach: Write resolvers manually
const resolvers = {
  Query: {
    users: async (parent, args, context) => {
      // Auth check
      if (!context.user) throw new Error('Unauthorized');

      // Build query
      let query = db.select('*').from('users');

      // Apply filters
      if (args.where) {
        query = query.where(args.where);
      }

      // Apply pagination
      if (args.limit) {
        query = query.limit(args.limit);
      }

      // Execute
      return await query;
    }
  },
  Mutation: {
    insertUser: async (parent, args, context) => {
      // Auth check
      if (!context.user) throw new Error('Unauthorized');

      // Validation
      if (!args.email) throw new Error('Email required');

      // Insert
      return await db('users').insert(args).returning('*');
    }
  }
};

// 100+ lines of code for basic CRUD
// Manual permission handling
// No real-time subscriptions
// Custom caching logic needed
```

### Hasura Approach

```yaml
# Point to database, get instant API
HASURA_GRAPHQL_DATABASE_URL=postgres://...

# Define permissions once
tables:
  - table:
      name: users
      schema: public
    select_permissions:
      - role: user
        permission:
          filter:
            id: { _eq: X-Hasura-User-Id }
          columns: [id, email, username]

# GraphQL API ready with:
# ✓ Queries, mutations, subscriptions
# ✓ Filtering, sorting, pagination
# ✓ Relationships and nested queries
# ✓ Real-time updates
# ✓ Row-level security
# ✓ Column-level security
# ✓ Zero custom code
```

**Result:** 10x faster API development with enterprise-grade security.

## Quick Start

### 1. Run Hasura with Docker

```bash
# docker-compose.yml
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: postgrespassword
    volumes:
      - db_data:/var/lib/postgresql/data

  hasura:
    image: hasura/graphql-engine:v2.36.0
    ports:
      - "8080:8080"
    environment:
      HASURA_GRAPHQL_DATABASE_URL: postgres://postgres:postgrespassword@postgres:5432/postgres
      HASURA_GRAPHQL_ENABLE_CONSOLE: "true"
      HASURA_GRAPHQL_ADMIN_SECRET: myadminsecretkey

volumes:
  db_data:
```

```bash
docker-compose up -d
```

### 2. Access Hasura Console

Open http://localhost:8080/console

Admin secret: `myadminsecretkey`

### 3. Create Your First Table

**SQL:**
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  username TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**Track in Hasura:** Data tab → Track table

### 4. Query Your API

```graphql
# Query
query GetUsers {
  users {
    id
    email
    username
    created_at
  }
}

# Insert
mutation CreateUser {
  insert_users_one(object: {
    email: "user@example.com"
    username: "johndoe"
  }) {
    id
    email
    username
  }
}

# Subscribe (real-time)
subscription WatchUsers {
  users {
    id
    username
    created_at
  }
}
```

**That's it!** Fully functional GraphQL API in minutes.

## Core Capabilities

### Instant GraphQL API

Track a PostgreSQL table and immediately get:

- **Queries**: `users`, `users_by_pk`, `users_aggregate`
- **Mutations**: `insert_users`, `update_users`, `delete_users`
- **Subscriptions**: Real-time updates for all queries
- **Filtering**: `where` clauses with operators (`_eq`, `_gt`, `_like`, `_in`, etc.)
- **Sorting**: `order_by` on any column
- **Pagination**: `limit` and `offset`
- **Relationships**: Auto-detected from foreign keys
- **Aggregations**: `count`, `sum`, `avg`, `max`, `min`

### Granular Permissions

Define **who can access what data** with precision:

```yaml
# Example: Users can only see and update their own profile
select_permissions:
  - role: user
    permission:
      filter:
        id: { _eq: X-Hasura-User-Id }
      columns: [id, email, username, avatar_url]

update_permissions:
  - role: user
    permission:
      filter:
        id: { _eq: X-Hasura-User-Id }
      columns: [username, avatar_url]
      set:
        updated_at: now()
```

**Permission Features:**
- Row-level security with boolean expressions
- Column-level security (hide sensitive fields)
- Session variables from JWT/webhook
- Validation with `check` constraints
- Auto-set columns (e.g., `user_id`, `updated_at`)

### Authentication Integration

Hasura **validates and authorizes**, you handle **authentication**:

**JWT Mode:**
```json
{
  "sub": "user123",
  "https://hasura.io/jwt/claims": {
    "x-hasura-default-role": "user",
    "x-hasura-allowed-roles": ["user", "admin"],
    "x-hasura-user-id": "user123",
    "x-hasura-org-id": "org456"
  }
}
```

**Webhook Mode:**
```javascript
// Your auth webhook
app.post('/auth', (req, res) => {
  const token = req.headers['authorization'];
  const user = validateToken(token);

  res.json({
    'X-Hasura-User-Id': user.id,
    'X-Hasura-Role': user.role
  });
});
```

**Supported auth providers:**
- Auth0
- Firebase Authentication
- AWS Cognito
- Supabase Auth
- Custom JWT issuer
- Any webhook

### Event Triggers

Turn database changes into events:

```yaml
# Send welcome email when user signs up
event_triggers:
  - name: user_created
    table:
      name: users
      schema: public
    webhook: https://myapp.com/webhooks/user-created
    insert:
      columns: "*"
```

**Webhook receives:**
```json
{
  "event": {
    "op": "INSERT",
    "data": {
      "old": null,
      "new": {
        "id": "uuid",
        "email": "user@example.com"
      }
    }
  }
}
```

**Use cases:**
- Send emails/SMS
- Sync to Elasticsearch
- Update cache
- Trigger workflows
- External integrations

### Actions (Custom Logic)

Extend GraphQL with custom business logic:

```graphql
# Define custom mutation
type Mutation {
  login(username: String!, password: String!): LoginResponse
}

type LoginResponse {
  accessToken: String!
  user: User!
}
```

**Handler (your code):**
```javascript
app.post('/actions/login', async (req, res) => {
  const { username, password } = req.body.input;

  const user = await validateCredentials(username, password);
  const token = generateJWT(user);

  res.json({
    accessToken: token,
    user: user
  });
});
```

**Use cases:**
- Login/signup
- Payment processing
- Complex validations
- Third-party API calls
- File uploads

### Remote Schemas

Stitch multiple GraphQL APIs:

```yaml
# Add external GraphQL API
remote_schemas:
  - name: countries
    definition:
      url: https://countries.trevorblades.com/graphql
```

**Query multiple sources:**
```graphql
query {
  # Local database
  users {
    id
    username
    country_code

    # Remote schema
    country {
      name
      emoji
      capital
    }
  }
}
```

**Use cases:**
- Microservices federation
- Third-party GraphQL APIs
- Legacy GraphQL services
- Multi-cloud architectures

### Real-Time Subscriptions

Every query becomes a subscription:

```graphql
# Live query - updates when data changes
subscription LiveOrders {
  orders(
    where: { status: { _eq: "pending" } }
    order_by: { created_at: desc }
  ) {
    id
    total
    status
    items {
      product {
        name
      }
      quantity
    }
  }
}
```

**Features:**
- WebSocket-based
- Multiplexed (efficient for many clients)
- Automatic change detection
- Filtering and sorting maintained
- Cursor-based pagination support

## Architecture Overview

### How Hasura Works

```
┌─────────────┐
│   Client    │
│  (Web/App)  │
└──────┬──────┘
       │ GraphQL Query + JWT
       │
       ▼
┌─────────────────────────────────────────┐
│         Hasura GraphQL Engine          │
│                                         │
│  ┌───────────┐  ┌──────────────────┐  │
│  │ Auth      │  │ Permission       │  │
│  │ Validator │─▶│ Engine           │  │
│  └───────────┘  └──────────────────┘  │
│                          │             │
│                          ▼             │
│  ┌──────────────────────────────────┐ │
│  │     GraphQL → SQL Compiler      │ │
│  └──────────────────────────────────┘ │
└─────────────────┬───────────────────────┘
                  │ SQL Query
                  ▼
         ┌─────────────────┐
         │   PostgreSQL    │
         │    Database     │
         └─────────────────┘
```

**Request Flow:**

1. Client sends GraphQL query with auth header
2. Hasura validates JWT/webhook
3. Extracts session variables (user_id, role, etc.)
4. Checks permissions for the role
5. Compiles GraphQL to optimized SQL
6. Applies row/column filters from permissions
7. Executes SQL on PostgreSQL
8. Returns GraphQL response

### Metadata-Driven Design

Hasura configuration is **metadata**, not code:

```
hasura/
├── metadata/
│   ├── databases/
│   │   └── default/
│   │       ├── tables/
│   │       │   ├── public_users.yaml      # Table config
│   │       │   └── public_posts.yaml
│   ├── actions.yaml                       # Custom mutations
│   ├── remote_schemas.yaml                # External APIs
│   └── version.yaml
└── migrations/
    └── default/
        ├── 1_create_users.up.sql
        └── 2_create_posts.up.sql
```

**Benefits:**
- Version control your entire API
- Easy collaboration (Git-based)
- Environment promotion (dev → staging → prod)
- Declarative infrastructure-as-code

## When to Use Hasura

### Excellent For

✓ **Rapid API Development**: Need GraphQL API yesterday
✓ **CRUD-Heavy Apps**: Admin panels, dashboards, internal tools
✓ **Real-Time Apps**: Chat, collaboration, live dashboards
✓ **Multi-Tenant SaaS**: Built-in row-level security
✓ **Microservices**: Schema stitching for service federation
✓ **Event-Driven**: Database triggers to webhooks
✓ **Prototyping**: Validate ideas quickly
✓ **Postgres-Centric**: Your data is in PostgreSQL

### Consider Alternatives If

⚠ **Complex Business Logic**: Heavy custom logic better in code
⚠ **Non-Postgres Primary DB**: Hasura is PostgreSQL-first
⚠ **Graph Algorithms**: Complex graph traversals not optimal
⚠ **Batch Processing**: Not designed for ETL workloads
⚠ **File Storage Primary**: Better solutions for file-heavy apps

## Production Deployment

### Key Production Settings

```bash
# Security
HASURA_GRAPHQL_ADMIN_SECRET=strong-random-secret
HASURA_GRAPHQL_JWT_SECRET='{"type":"RS256","key":"..."}'

# Performance
HASURA_GRAPHQL_ENABLE_CONSOLE=false
HASURA_GRAPHQL_DEV_MODE=false

# Rate Limiting
HASURA_GRAPHQL_RATE_LIMIT_PER_MINUTE=1000

# Connections
HASURA_GRAPHQL_PG_CONNECTIONS=50

# CORS
HASURA_GRAPHQL_CORS_DOMAIN=https://myapp.com

# Logging
HASURA_GRAPHQL_ENABLED_LOG_TYPES=startup,http-log,webhook-log
```

### Deployment Options

**Hasura Cloud** (Managed):
- Global CDN
- Auto-scaling
- Monitoring/alerting
- Click-to-deploy
- Free tier available

**Self-Hosted**:
- Docker/Docker Compose
- Kubernetes (Helm charts available)
- AWS ECS/Fargate
- Google Cloud Run
- Azure Container Instances

### Monitoring

- **Health endpoint**: `/healthz`
- **Metrics**: Prometheus integration
- **Logging**: Structured JSON logs
- **APM**: DataDog, New Relic integration
- **Cloud dashboard**: Built-in monitoring (Hasura Cloud)

## Common Use Cases

### 1. SaaS Application Backend

Multi-tenant data isolation with row-level security:

```yaml
# Automatic tenant isolation
select_permissions:
  - role: user
    permission:
      filter:
        organization_id: { _eq: X-Hasura-Org-Id }
```

### 2. Real-Time Dashboards

Live data updates with subscriptions:

```graphql
subscription LiveMetrics {
  metrics_aggregate(
    where: { created_at: { _gte: "2025-01-15" } }
  ) {
    aggregate {
      count
      sum { value }
      avg { value }
    }
  }
}
```

### 3. E-Commerce Platform

Event triggers for order processing:

```javascript
// Order created → Process payment
// Order paid → Update inventory
// Order shipped → Send notification
```

### 4. Social Media App

Complex permissions for privacy:

```yaml
# See own posts, public posts, and posts from followed users
filter:
  _or:
    - user_id: { _eq: X-Hasura-User-Id }
    - is_public: { _eq: true }
    - user:
        followers:
          follower_id: { _eq: X-Hasura-User-Id }
```

### 5. Internal Admin Tools

Rapid CRUD interface generation:

- Auto-generated queries/mutations
- Role-based access control
- Relationship traversal
- Bulk operations

## Learning Path

### Beginner (Week 1)
1. Run Hasura locally with Docker
2. Create tables and track them
3. Explore auto-generated GraphQL API
4. Set up basic select permissions
5. Integrate JWT authentication

### Intermediate (Week 2-3)
1. Design permission system for your use case
2. Implement event triggers
3. Create custom actions
4. Set up migrations and metadata workflow
5. Deploy to staging environment

### Advanced (Week 4+)
1. Add remote schemas
2. Optimize query performance
3. Implement caching strategy
4. Set up monitoring and alerting
5. Production deployment and CI/CD

## Resources

### Official
- **Docs**: https://hasura.io/docs
- **Learn**: https://hasura.io/learn (interactive tutorials)
- **Cloud**: https://cloud.hasura.io
- **CLI**: https://hasura.io/docs/latest/hasura-cli

### Community
- **Discord**: https://discord.gg/hasura
- **GitHub**: https://github.com/hasura/graphql-engine
- **Forum**: https://github.com/hasura/graphql-engine/discussions
- **Blog**: https://hasura.io/blog

### Tools
- **Hasura Cloud Console**: Managed platform
- **Hasura CLI**: Local development and migrations
- **GraphQL Code Generator**: Client code generation
- **Apollo Client**: Frontend integration

## Next Steps

1. **Read SKILL.md**: Comprehensive reference guide
2. **Review EXAMPLES.md**: 15+ practical code examples
3. **Run Quick Start**: Get Hasura running locally
4. **Build Sample App**: Create todo app or blog
5. **Deploy**: Try Hasura Cloud free tier

## Support

- Open issues on GitHub
- Ask questions on Discord
- Explore documentation
- Check community discussions

---

**Version**: 1.0.0
**Updated**: January 2025
**License**: Open Source (Apache 2.0)
