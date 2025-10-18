# Hasura GraphQL Engine Examples

Comprehensive collection of practical examples demonstrating Hasura's core features and real-world use cases.

## Table of Contents

1. [Basic CRUD Operations](#example-1-basic-crud-operations)
2. [Multi-Tenant SaaS Application](#example-2-multi-tenant-saas-application)
3. [Social Media Platform](#example-3-social-media-platform)
4. [E-Commerce Platform](#example-4-e-commerce-platform)
5. [Real-Time Collaboration App](#example-5-real-time-collaboration-app)
6. [User Authentication System](#example-6-user-authentication-system)
7. [Event-Driven Order Processing](#example-7-event-driven-order-processing)
8. [Custom Payment Action](#example-8-custom-payment-action)
9. [Remote Schema Integration](#example-9-remote-schema-integration)
10. [Advanced Permissions Patterns](#example-10-advanced-permissions-patterns)
11. [Real-Time Analytics Dashboard](#example-11-real-time-analytics-dashboard)
12. [File Upload with Actions](#example-12-file-upload-with-actions)
13. [GraphQL Query Optimization](#example-13-graphql-query-optimization)
14. [Automated Email Notifications](#example-14-automated-email-notifications)
15. [Admin Panel with Row-Level Security](#example-15-admin-panel-with-row-level-security)
16. [API Gateway Pattern](#example-16-api-gateway-pattern)
17. [Metadata API Automation](#example-17-metadata-api-automation)

---

## Example 1: Basic CRUD Operations

### Database Schema

```sql
-- Create users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  username TEXT NOT NULL UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);

-- Track table in Hasura via Console or Metadata API
```

### GraphQL Queries

```graphql
# 1. Fetch all users
query GetAllUsers {
  users {
    id
    email
    username
    full_name
    created_at
  }
}

# 2. Fetch user by ID
query GetUserById($userId: uuid!) {
  users_by_pk(id: $userId) {
    id
    email
    username
    full_name
    avatar_url
  }
}

# 3. Search users by username
query SearchUsers($searchTerm: String!) {
  users(
    where: { username: { _ilike: $searchTerm } }
    limit: 10
  ) {
    id
    username
    full_name
  }
}

# 4. Paginated user list
query PaginatedUsers($limit: Int!, $offset: Int!) {
  users(
    limit: $limit
    offset: $offset
    order_by: { created_at: desc }
  ) {
    id
    username
    email
    created_at
  }
  users_aggregate {
    aggregate {
      count
    }
  }
}
```

### GraphQL Mutations

```graphql
# 1. Create user
mutation CreateUser($email: String!, $username: String!, $fullName: String!) {
  insert_users_one(object: {
    email: $email
    username: $username
    full_name: $fullName
  }) {
    id
    email
    username
    created_at
  }
}

# 2. Update user
mutation UpdateUser($userId: uuid!, $fullName: String, $avatarUrl: String) {
  update_users_by_pk(
    pk_columns: { id: $userId }
    _set: {
      full_name: $fullName
      avatar_url: $avatarUrl
      updated_at: "now()"
    }
  ) {
    id
    full_name
    avatar_url
    updated_at
  }
}

# 3. Delete user
mutation DeleteUser($userId: uuid!) {
  delete_users_by_pk(id: $userId) {
    id
    username
  }
}

# 4. Bulk insert users
mutation BulkInsertUsers($users: [users_insert_input!]!) {
  insert_users(objects: $users) {
    affected_rows
    returning {
      id
      username
      email
    }
  }
}
```

### GraphQL Subscriptions

```graphql
# 1. Watch all users (real-time updates)
subscription WatchUsers {
  users(order_by: { created_at: desc }) {
    id
    username
    email
    created_at
  }
}

# 2. Watch specific user changes
subscription WatchUserById($userId: uuid!) {
  users_by_pk(id: $userId) {
    id
    username
    full_name
    avatar_url
    updated_at
  }
}

# 3. Watch new user registrations
subscription NewUserRegistrations {
  users(
    where: { created_at: { _gte: "now()" } }
    order_by: { created_at: desc }
  ) {
    id
    username
    email
    created_at
  }
}
```

---

## Example 2: Multi-Tenant SaaS Application

### Database Schema

```sql
-- Organizations (tenants)
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  plan TEXT NOT NULL DEFAULT 'free',
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Users belong to organizations
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  username TEXT NOT NULL,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'member',
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Projects belong to organizations
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  owner_id UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Tasks belong to projects
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'todo',
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  assignee_id UUID REFERENCES users(id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_org ON users(organization_id);
CREATE INDEX idx_projects_org ON projects(organization_id);
CREATE INDEX idx_tasks_project ON tasks(project_id);
```

### Permissions Configuration

```yaml
# users table permissions
- table:
    name: users
    schema: public
  select_permissions:
    - role: user
      permission:
        filter:
          organization_id: { _eq: X-Hasura-Org-Id }
        columns:
          - id
          - email
          - username
          - role
          - created_at

  insert_permissions:
    - role: admin
      permission:
        check:
          organization_id: { _eq: X-Hasura-Org-Id }
        columns:
          - email
          - username
          - organization_id
          - role

  update_permissions:
    - role: admin
      permission:
        filter:
          organization_id: { _eq: X-Hasura-Org-Id }
        check:
          organization_id: { _eq: X-Hasura-Org-Id }
        columns:
          - username
          - role

# projects table permissions
- table:
    name: projects
    schema: public
  select_permissions:
    - role: user
      permission:
        filter:
          organization_id: { _eq: X-Hasura-Org-Id }
        columns: "*"

  insert_permissions:
    - role: user
      permission:
        check:
          organization_id: { _eq: X-Hasura-Org-Id }
        set:
          organization_id: X-Hasura-Org-Id
          owner_id: X-Hasura-User-Id
        columns:
          - name
          - description

  update_permissions:
    - role: user
      permission:
        filter:
          _and:
            - organization_id: { _eq: X-Hasura-Org-Id }
            - owner_id: { _eq: X-Hasura-User-Id }
        columns:
          - name
          - description

# tasks table permissions
- table:
    name: tasks
    schema: public
  select_permissions:
    - role: user
      permission:
        filter:
          project:
            organization_id: { _eq: X-Hasura-Org-Id }
        columns: "*"

  insert_permissions:
    - role: user
      permission:
        check:
          project:
            organization_id: { _eq: X-Hasura-Org-Id }
        columns:
          - title
          - description
          - status
          - project_id
          - assignee_id

  update_permissions:
    - role: user
      permission:
        filter:
          project:
            organization_id: { _eq: X-Hasura-Org-Id }
        columns:
          - title
          - description
          - status
          - assignee_id
```

### JWT Configuration

```json
{
  "sub": "user-uuid",
  "https://hasura.io/jwt/claims": {
    "x-hasura-default-role": "user",
    "x-hasura-allowed-roles": ["user", "admin"],
    "x-hasura-user-id": "user-uuid",
    "x-hasura-org-id": "org-uuid"
  }
}
```

### GraphQL Queries

```graphql
# Get organization with all projects and tasks
query GetOrganizationData {
  organizations {
    id
    name
    plan
    projects(order_by: { created_at: desc }) {
      id
      name
      description
      owner {
        id
        username
      }
      tasks_aggregate {
        aggregate {
          count
        }
      }
      tasks(
        where: { status: { _eq: "todo" } }
        limit: 5
      ) {
        id
        title
        assignee {
          username
        }
      }
    }
  }
}

# Get my tasks across all projects
query MyTasks {
  tasks(
    where: { assignee_id: { _eq: "X-Hasura-User-Id" } }
    order_by: { created_at: desc }
  ) {
    id
    title
    status
    project {
      name
      organization {
        name
      }
    }
  }
}
```

---

## Example 3: Social Media Platform

### Database Schema

```sql
-- Users
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL UNIQUE,
  bio TEXT,
  avatar_url TEXT,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Posts
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  image_url TEXT,
  is_public BOOLEAN DEFAULT true,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Follows (user follows another user)
CREATE TABLE follows (
  follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id),
  CHECK (follower_id != following_id)
);

-- Likes
CREATE TABLE likes (
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, post_id)
);

-- Comments
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_posts_user ON posts(user_id);
CREATE INDEX idx_posts_created ON posts(created_at DESC);
CREATE INDEX idx_follows_follower ON follows(follower_id);
CREATE INDEX idx_follows_following ON follows(following_id);
CREATE INDEX idx_likes_post ON likes(post_id);
CREATE INDEX idx_comments_post ON comments(post_id);
```

### Permissions: Posts Table

```yaml
# Posts - Users can see own posts, public posts, and posts from followed users
- table:
    name: posts
    schema: public
  select_permissions:
    - role: user
      permission:
        filter:
          _or:
            - user_id: { _eq: X-Hasura-User-Id }
            - is_public: { _eq: true }
            - user:
                followers:
                  follower_id: { _eq: X-Hasura-User-Id }
        columns:
          - id
          - user_id
          - content
          - image_url
          - is_public
          - created_at
          - updated_at

  insert_permissions:
    - role: user
      permission:
        check: {}
        set:
          user_id: X-Hasura-User-Id
        columns:
          - content
          - image_url
          - is_public

  update_permissions:
    - role: user
      permission:
        filter:
          user_id: { _eq: X-Hasura-User-Id }
        check:
          user_id: { _eq: X-Hasura-User-Id }
        columns:
          - content
          - is_public

  delete_permissions:
    - role: user
      permission:
        filter:
          user_id: { _eq: X-Hasura-User-Id }
```

### GraphQL Queries

```graphql
# Get user profile with stats
query GetUserProfile($username: String!) {
  users(where: { username: { _eq: $username } }) {
    id
    username
    bio
    avatar_url
    is_verified
    posts_aggregate {
      aggregate {
        count
      }
    }
    followers_aggregate {
      aggregate {
        count
      }
    }
    following_aggregate {
      aggregate {
        count
      }
    }
    posts(
      limit: 10
      order_by: { created_at: desc }
    ) {
      id
      content
      image_url
      created_at
      likes_aggregate {
        aggregate {
          count
        }
      }
      comments_aggregate {
        aggregate {
          count
        }
      }
    }
  }
}

# Get feed (posts from followed users)
query GetFeed($limit: Int = 20, $offset: Int = 0) {
  posts(
    where: {
      user: {
        followers: {
          follower_id: { _eq: "X-Hasura-User-Id" }
        }
      }
    }
    order_by: { created_at: desc }
    limit: $limit
    offset: $offset
  ) {
    id
    content
    image_url
    created_at
    user {
      id
      username
      avatar_url
      is_verified
    }
    likes_aggregate {
      aggregate {
        count
      }
    }
    likes(where: { user_id: { _eq: "X-Hasura-User-Id" } }) {
      user_id
    }
    comments_aggregate {
      aggregate {
        count
      }
    }
    comments(limit: 3, order_by: { created_at: desc }) {
      id
      content
      user {
        username
        avatar_url
      }
      created_at
    }
  }
}

# Search users
query SearchUsers($searchTerm: String!) {
  users(
    where: {
      _or: [
        { username: { _ilike: $searchTerm } }
        { bio: { _ilike: $searchTerm } }
      ]
    }
    limit: 20
  ) {
    id
    username
    bio
    avatar_url
    is_verified
    followers_aggregate {
      aggregate {
        count
      }
    }
  }
}
```

### GraphQL Mutations

```graphql
# Create post
mutation CreatePost($content: String!, $imageUrl: String, $isPublic: Boolean = true) {
  insert_posts_one(object: {
    content: $content
    image_url: $imageUrl
    is_public: $isPublic
  }) {
    id
    content
    image_url
    created_at
  }
}

# Like post
mutation LikePost($postId: uuid!) {
  insert_likes_one(object: {
    post_id: $postId
  }) {
    post_id
    user_id
    created_at
  }
}

# Unlike post
mutation UnlikePost($postId: uuid!) {
  delete_likes_by_pk(
    post_id: $postId
    user_id: "X-Hasura-User-Id"
  ) {
    post_id
  }
}

# Follow user
mutation FollowUser($followingId: uuid!) {
  insert_follows_one(object: {
    following_id: $followingId
  }) {
    follower_id
    following_id
    created_at
  }
}

# Add comment
mutation AddComment($postId: uuid!, $content: String!) {
  insert_comments_one(object: {
    post_id: $postId
    content: $content
  }) {
    id
    content
    created_at
    user {
      username
      avatar_url
    }
  }
}
```

### Real-Time Subscriptions

```graphql
# Watch post likes and comments in real-time
subscription WatchPost($postId: uuid!) {
  posts_by_pk(id: $postId) {
    id
    content
    likes_aggregate {
      aggregate {
        count
      }
    }
    comments_aggregate {
      aggregate {
        count
      }
    }
    comments(order_by: { created_at: desc }, limit: 10) {
      id
      content
      created_at
      user {
        username
        avatar_url
      }
    }
  }
}

# Watch for new posts from followed users
subscription WatchFeed {
  posts(
    where: {
      user: {
        followers: {
          follower_id: { _eq: "X-Hasura-User-Id" }
        }
      }
    }
    order_by: { created_at: desc }
    limit: 20
  ) {
    id
    content
    image_url
    created_at
    user {
      username
      avatar_url
    }
  }
}
```

---

## Example 4: E-Commerce Platform

### Database Schema

```sql
-- Products
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  stock_quantity INT NOT NULL DEFAULT 0,
  category TEXT NOT NULL,
  image_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Orders
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  status TEXT NOT NULL DEFAULT 'pending',
  total DECIMAL(10,2) NOT NULL,
  shipping_address TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Order items
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  quantity INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
```

### Event Trigger: Order Confirmation

```yaml
# Event trigger configuration
event_triggers:
  - name: order_created
    table:
      name: orders
      schema: public
    webhook: https://myapp.com/webhooks/order-created
    insert:
      columns: "*"
    retry_conf:
      num_retries: 3
      interval_sec: 10
      timeout_sec: 60
```

**Webhook Handler (Node.js):**

```javascript
const express = require('express');
const app = express();

app.post('/webhooks/order-created', async (req, res) => {
  const { event } = req.body;
  const order = event.data.new;

  try {
    // 1. Fetch full order details
    const orderDetails = await fetchOrderDetails(order.id);

    // 2. Send confirmation email
    await sendEmail({
      to: orderDetails.user.email,
      subject: `Order Confirmation #${order.id}`,
      template: 'order-confirmation',
      data: {
        orderId: order.id,
        items: orderDetails.order_items,
        total: order.total,
        shippingAddress: order.shipping_address
      }
    });

    // 3. Update inventory
    for (const item of orderDetails.order_items) {
      await updateInventory(item.product_id, -item.quantity);
    }

    // 4. Notify shipping service
    await notifyShippingService({
      orderId: order.id,
      address: order.shipping_address,
      items: orderDetails.order_items
    });

    res.json({ success: true });
  } catch (error) {
    console.error('Order webhook error:', error);
    res.status(500).json({ error: error.message });
  }
});

async function fetchOrderDetails(orderId) {
  const query = `
    query GetOrder($orderId: uuid!) {
      orders_by_pk(id: $orderId) {
        id
        total
        shipping_address
        user {
          email
          username
        }
        order_items {
          product {
            name
          }
          quantity
          price
        }
      }
    }
  `;

  const response = await fetch('https://myhasura.app/v1/graphql', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-hasura-admin-secret': process.env.HASURA_ADMIN_SECRET
    },
    body: JSON.stringify({
      query,
      variables: { orderId }
    })
  });

  const { data } = await response.json();
  return data.orders_by_pk;
}
```

### GraphQL Mutations

```graphql
# Create order (complex transaction)
mutation CreateOrder(
  $shippingAddress: String!
  $orderItems: [order_items_insert_input!]!
) {
  insert_orders_one(object: {
    shipping_address: $shippingAddress
    total: 0  # Calculated in action
    order_items: {
      data: $orderItems
    }
  }) {
    id
    status
    total
    created_at
    order_items {
      product {
        name
      }
      quantity
      price
    }
  }
}
```

---

## Example 5: Real-Time Collaboration App

### Database Schema

```sql
-- Documents
CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content JSONB NOT NULL DEFAULT '{}'::jsonb,
  owner_id UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Document collaborators
CREATE TABLE document_collaborators (
  document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  permission TEXT NOT NULL CHECK (permission IN ('read', 'write', 'admin')),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY (document_id, user_id)
);

-- Document versions (history)
CREATE TABLE document_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
  content JSONB NOT NULL,
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_docs_owner ON documents(owner_id);
CREATE INDEX idx_collaborators_doc ON document_collaborators(document_id);
CREATE INDEX idx_versions_doc ON document_versions(document_id);
```

### Permissions

```yaml
# Documents - Access if owner or collaborator
- table:
    name: documents
    schema: public
  select_permissions:
    - role: user
      permission:
        filter:
          _or:
            - owner_id: { _eq: X-Hasura-User-Id }
            - collaborators:
                user_id: { _eq: X-Hasura-User-Id }
        columns: "*"

  update_permissions:
    - role: user
      permission:
        filter:
          _or:
            - owner_id: { _eq: X-Hasura-User-Id }
            - collaborators:
                _and:
                  - user_id: { _eq: X-Hasura-User-Id }
                  - permission: { _in: ["write", "admin"] }
        columns:
          - title
          - content
        set:
          updated_at: now()
```

### Real-Time Collaboration Subscription

```graphql
# Subscribe to document changes
subscription WatchDocument($documentId: uuid!) {
  documents_by_pk(id: $documentId) {
    id
    title
    content
    updated_at
    owner {
      id
      username
      avatar_url
    }
    collaborators {
      user {
        id
        username
        avatar_url
      }
      permission
    }
  }
}

# Watch all collaborators' cursors/selections (using presence)
subscription WatchCollaborators($documentId: uuid!) {
  document_collaborators(
    where: { document_id: { _eq: $documentId } }
  ) {
    user {
      id
      username
      avatar_url
    }
    permission
  }
}
```

### Optimistic UI Updates

```javascript
// React example with Apollo Client
const [updateDocument] = useMutation(UPDATE_DOCUMENT, {
  optimisticResponse: {
    update_documents_by_pk: {
      __typename: 'documents',
      id: documentId,
      title: newTitle,
      content: newContent,
      updated_at: new Date().toISOString()
    }
  }
});

// Update with optimistic UI
await updateDocument({
  variables: {
    documentId,
    title: newTitle,
    content: newContent
  }
});
```

---

## Example 6: User Authentication System

### Action: User Login

**GraphQL SDL:**

```graphql
type Mutation {
  login(username: String!, password: String!): LoginResponse
}

type LoginResponse {
  accessToken: String!
  refreshToken: String!
  user: User!
}

type User {
  id: uuid!
  username: String!
  email: String!
}
```

**Action Handler (Express):**

```javascript
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

app.post('/actions/login', async (req, res) => {
  const { input } = req.body;
  const { username, password } = input;

  try {
    // 1. Fetch user from database
    const userQuery = `
      query GetUser($username: String!) {
        users(where: { username: { _eq: $username } }, limit: 1) {
          id
          email
          username
          password_hash
        }
      }
    `;

    const userResponse = await fetch(process.env.HASURA_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-hasura-admin-secret': process.env.HASURA_ADMIN_SECRET
      },
      body: JSON.stringify({
        query: userQuery,
        variables: { username }
      })
    });

    const { data } = await userResponse.json();
    const user = data.users[0];

    if (!user) {
      return res.status(401).json({
        message: 'Invalid credentials'
      });
    }

    // 2. Verify password
    const validPassword = await bcrypt.compare(password, user.password_hash);

    if (!validPassword) {
      return res.status(401).json({
        message: 'Invalid credentials'
      });
    }

    // 3. Generate JWT tokens
    const accessToken = jwt.sign(
      {
        sub: user.id,
        'https://hasura.io/jwt/claims': {
          'x-hasura-default-role': 'user',
          'x-hasura-allowed-roles': ['user'],
          'x-hasura-user-id': user.id
        }
      },
      process.env.JWT_SECRET,
      { expiresIn: '15m' }
    );

    const refreshToken = jwt.sign(
      { sub: user.id },
      process.env.REFRESH_TOKEN_SECRET,
      { expiresIn: '7d' }
    );

    // 4. Return response
    res.json({
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        username: user.username,
        email: user.email
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
});
```

### Action: User Signup

```graphql
type Mutation {
  signup(
    email: String!
    username: String!
    password: String!
  ): SignupResponse
}

type SignupResponse {
  accessToken: String!
  user: User!
}
```

**Handler:**

```javascript
app.post('/actions/signup', async (req, res) => {
  const { input } = req.body;
  const { email, username, password } = input;

  try {
    // 1. Validate input
    if (password.length < 8) {
      return res.status(400).json({
        message: 'Password must be at least 8 characters'
      });
    }

    // 2. Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // 3. Create user
    const createUserMutation = `
      mutation CreateUser(
        $email: String!
        $username: String!
        $passwordHash: String!
      ) {
        insert_users_one(object: {
          email: $email
          username: $username
          password_hash: $passwordHash
        }) {
          id
          email
          username
        }
      }
    `;

    const response = await fetch(process.env.HASURA_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-hasura-admin-secret': process.env.HASURA_ADMIN_SECRET
      },
      body: JSON.stringify({
        query: createUserMutation,
        variables: { email, username, passwordHash }
      })
    });

    const { data, errors } = await response.json();

    if (errors) {
      if (errors[0].message.includes('Uniqueness violation')) {
        return res.status(400).json({
          message: 'Email or username already exists'
        });
      }
      throw new Error(errors[0].message);
    }

    const user = data.insert_users_one;

    // 4. Generate JWT
    const accessToken = jwt.sign(
      {
        sub: user.id,
        'https://hasura.io/jwt/claims': {
          'x-hasura-default-role': 'user',
          'x-hasura-allowed-roles': ['user'],
          'x-hasura-user-id': user.id
        }
      },
      process.env.JWT_SECRET,
      { expiresIn: '15m' }
    );

    res.json({
      accessToken,
      user: {
        id: user.id,
        username: user.username,
        email: user.email
      }
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
});
```

---

## Example 7: Event-Driven Order Processing

### Event Trigger: Order Status Changes

```yaml
event_triggers:
  - name: order_status_changed
    table:
      name: orders
      schema: public
    webhook: https://myapp.com/webhooks/order-status
    update:
      columns: [status]
    retry_conf:
      num_retries: 5
      interval_sec: 10
```

**Webhook Handler:**

```javascript
app.post('/webhooks/order-status', async (req, res) => {
  const { event } = req.body;
  const oldStatus = event.data.old.status;
  const newStatus = event.data.new.status;
  const order = event.data.new;

  try {
    // Handle different status transitions
    switch (newStatus) {
      case 'paid':
        await handleOrderPaid(order);
        break;

      case 'shipped':
        await handleOrderShipped(order);
        break;

      case 'delivered':
        await handleOrderDelivered(order);
        break;

      case 'canceled':
        await handleOrderCanceled(order);
        break;
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Order status webhook error:', error);
    res.status(500).json({ error: error.message });
  }
});

async function handleOrderPaid(order) {
  // 1. Send payment confirmation email
  await sendEmail({
    to: order.user_email,
    template: 'payment-confirmed',
    data: { orderId: order.id, total: order.total }
  });

  // 2. Notify warehouse to prepare shipment
  await notifyWarehouse({
    orderId: order.id,
    items: await getOrderItems(order.id)
  });

  // 3. Update analytics
  await trackEvent('order_paid', {
    orderId: order.id,
    total: order.total,
    userId: order.user_id
  });
}

async function handleOrderShipped(order) {
  // 1. Send shipping notification
  await sendEmail({
    to: order.user_email,
    template: 'order-shipped',
    data: {
      orderId: order.id,
      trackingNumber: order.tracking_number
    }
  });

  // 2. Send SMS notification (if enabled)
  if (order.notify_via_sms) {
    await sendSMS({
      to: order.phone,
      message: `Your order #${order.id} has shipped! Track: ${order.tracking_url}`
    });
  }
}

async function handleOrderDelivered(order) {
  // 1. Send delivery confirmation
  await sendEmail({
    to: order.user_email,
    template: 'order-delivered',
    data: { orderId: order.id }
  });

  // 2. Request review after 3 days
  await scheduleTask({
    task: 'request_review',
    delay: '3 days',
    data: { orderId: order.id }
  });
}

async function handleOrderCanceled(order) {
  // 1. Process refund
  await processRefund({
    orderId: order.id,
    amount: order.total,
    reason: order.cancel_reason
  });

  // 2. Restore inventory
  const items = await getOrderItems(order.id);
  for (const item of items) {
    await updateInventory(item.product_id, item.quantity);
  }

  // 3. Send cancellation email
  await sendEmail({
    to: order.user_email,
    template: 'order-canceled',
    data: { orderId: order.id, refundAmount: order.total }
  });
}
```

---

## Example 8: Custom Payment Action

### Action Definition

```graphql
type Mutation {
  processPayment(
    orderId: ID!
    paymentMethodId: String!
    amount: Float!
    currency: String!
  ): PaymentResponse
}

type PaymentResponse {
  success: Boolean!
  transactionId: String
  orderId: ID!
  error: String
}
```

**Handler (Stripe Integration):**

```javascript
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

app.post('/actions/process-payment', async (req, res) => {
  const { input, session_variables } = req.body;
  const { orderId, paymentMethodId, amount, currency } = input;
  const userId = session_variables['x-hasura-user-id'];

  try {
    // 1. Verify order belongs to user
    const orderQuery = `
      query GetOrder($orderId: uuid!, $userId: uuid!) {
        orders_by_pk(id: $orderId) {
          id
          user_id
          total
          status
        }
      }
    `;

    const orderResponse = await hasuraRequest(orderQuery, {
      orderId,
      userId
    });

    const order = orderResponse.data.orders_by_pk;

    if (!order) {
      return res.status(404).json({
        message: 'Order not found'
      });
    }

    if (order.user_id !== userId) {
      return res.status(403).json({
        message: 'Unauthorized'
      });
    }

    if (order.status !== 'pending') {
      return res.status(400).json({
        message: 'Order already processed'
      });
    }

    // 2. Create Stripe payment intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convert to cents
      currency: currency,
      payment_method: paymentMethodId,
      confirm: true,
      metadata: {
        orderId: orderId,
        userId: userId
      }
    });

    // 3. Update order status
    if (paymentIntent.status === 'succeeded') {
      const updateMutation = `
        mutation UpdateOrder($orderId: uuid!) {
          update_orders_by_pk(
            pk_columns: { id: $orderId }
            _set: { status: "paid" }
          ) {
            id
            status
          }
        }
      `;

      await hasuraRequest(updateMutation, { orderId });

      return res.json({
        success: true,
        transactionId: paymentIntent.id,
        orderId: orderId,
        error: null
      });
    } else {
      return res.json({
        success: false,
        transactionId: null,
        orderId: orderId,
        error: 'Payment failed'
      });
    }
  } catch (error) {
    console.error('Payment processing error:', error);

    return res.json({
      success: false,
      transactionId: null,
      orderId: orderId,
      error: error.message
    });
  }
});

async function hasuraRequest(query, variables) {
  const response = await fetch(process.env.HASURA_ENDPOINT, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-hasura-admin-secret': process.env.HASURA_ADMIN_SECRET
    },
    body: JSON.stringify({ query, variables })
  });

  return await response.json();
}
```

---

## Example 9: Remote Schema Integration

### Add Auth0 Management API as Remote Schema

```http
POST /v1/metadata HTTP/1.1
Content-Type: application/json
X-Hasura-Role: admin

{
  "type": "add_remote_schema",
  "args": {
    "name": "auth0_api",
    "definition": {
      "url": "https://myapp.auth0.com/api/v2/",
      "headers": [
        {
          "name": "Authorization",
          "value": "Bearer ${AUTH0_MANAGEMENT_TOKEN}"
        }
      ],
      "forward_client_headers": false,
      "timeout_seconds": 60
    }
  }
}
```

### Remote Schema Permissions

```http
POST /v1/metadata HTTP/1.1
Content-Type: application/json
X-Hasura-Role: admin

{
  "type": "add_remote_schema_permissions",
  "args": {
    "remote_schema": "auth0_api",
    "role": "user",
    "definition": {
      "schema": "type User { id: ID! email: String! name: String } type Query { user(id: ID! @preset(value: \"x-hasura-user-id\")): User }"
    }
  }
}
```

### Query Local + Remote Data

```graphql
query GetUserWithAuth0Profile {
  users_by_pk(id: "user-uuid") {
    id
    username
    created_at

    # Remote schema field
    auth0_profile {
      email
      email_verified
      last_login
      logins_count
    }
  }
}
```

---

## Example 10: Advanced Permissions Patterns

### Time-Based Permissions

```yaml
# Only allow updates during business hours
update_permissions:
  - role: user
    permission:
      filter:
        _and:
          - user_id: { _eq: X-Hasura-User-Id }
          - created_at: { _gte: "now() - interval '24 hours'" }
```

### Hierarchical Permissions

```sql
-- Organization hierarchy
CREATE TABLE org_hierarchy (
  parent_id UUID REFERENCES organizations(id),
  child_id UUID REFERENCES organizations(id),
  PRIMARY KEY (parent_id, child_id)
);
```

```yaml
# Access data from own org and child orgs
select_permissions:
  - role: manager
    permission:
      filter:
        _or:
          - organization_id: { _eq: X-Hasura-Org-Id }
          - organization:
              parent_orgs:
                parent_id: { _eq: X-Hasura-Org-Id }
```

### Computed Field Permissions

```sql
-- Function to check if user can edit post
CREATE FUNCTION can_edit_post(post_row posts, hasura_session json)
RETURNS boolean AS $$
  SELECT
    post_row.user_id = (hasura_session->>'x-hasura-user-id')::uuid
    OR
    (hasura_session->>'x-hasura-role') = 'admin'
$$ LANGUAGE sql STABLE;
```

```yaml
# Use computed field in permissions
update_permissions:
  - role: user
    permission:
      filter:
        can_edit_post:
          _eq: true
```

---

## Example 11: Real-Time Analytics Dashboard

### SQL Functions for Analytics

```sql
-- Daily active users
CREATE FUNCTION daily_active_users(date_param date)
RETURNS TABLE (date date, count bigint) AS $$
  SELECT
    date_param as date,
    COUNT(DISTINCT user_id) as count
  FROM user_activities
  WHERE DATE(created_at) = date_param
$$ LANGUAGE sql STABLE;

-- Revenue by day
CREATE FUNCTION revenue_by_day(start_date date, end_date date)
RETURNS TABLE (date date, revenue decimal) AS $$
  SELECT
    DATE(created_at) as date,
    SUM(total) as revenue
  FROM orders
  WHERE
    status = 'completed'
    AND DATE(created_at) BETWEEN start_date AND end_date
  GROUP BY DATE(created_at)
  ORDER BY date
$$ LANGUAGE sql STABLE;
```

### Track Functions in Hasura

```yaml
functions:
  - function:
      name: daily_active_users
      schema: public
  - function:
      name: revenue_by_day
      schema: public
```

### Real-Time Dashboard Subscription

```graphql
subscription DashboardMetrics {
  # Real-time order count
  orders_aggregate(
    where: { created_at: { _gte: "today" } }
  ) {
    aggregate {
      count
      sum {
        total
      }
    }
  }

  # Real-time user signups
  users_aggregate(
    where: { created_at: { _gte: "today" } }
  ) {
    aggregate {
      count
    }
  }

  # Top products today
  order_items_aggregate(
    where: { created_at: { _gte: "today" } }
    group_by: [product_id]
    order_by: { aggregate: { sum: { quantity: desc } } }
    limit: 5
  ) {
    aggregate {
      sum {
        quantity
      }
    }
    nodes {
      product {
        name
      }
    }
  }
}
```

---

## Example 12: File Upload with Actions

### Action: Upload File

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
  fileName: String!
}
```

**Handler (S3 Upload):**

```javascript
const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');

const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY,
  secretAccessKey: process.env.AWS_SECRET_KEY
});

app.post('/actions/upload-file', async (req, res) => {
  const { input, session_variables } = req.body;
  const { file, fileName, mimeType } = input;
  const userId = session_variables['x-hasura-user-id'];

  try {
    // 1. Decode base64 file
    const fileBuffer = Buffer.from(file, 'base64');

    // 2. Generate unique file ID
    const fileId = uuidv4();
    const fileExtension = fileName.split('.').pop();
    const s3Key = `uploads/${userId}/${fileId}.${fileExtension}`;

    // 3. Upload to S3
    const uploadParams = {
      Bucket: process.env.S3_BUCKET,
      Key: s3Key,
      Body: fileBuffer,
      ContentType: mimeType,
      ACL: 'public-read'
    };

    const uploadResult = await s3.upload(uploadParams).promise();

    // 4. Save file metadata to database
    const saveFileMutation = `
      mutation SaveFile(
        $fileId: uuid!
        $userId: uuid!
        $fileName: String!
        $mimeType: String!
        $url: String!
        $size: Int!
      ) {
        insert_files_one(object: {
          id: $fileId
          user_id: $userId
          file_name: $fileName
          mime_type: $mimeType
          url: $url
          size: $size
        }) {
          id
        }
      }
    `;

    await hasuraRequest(saveFileMutation, {
      fileId,
      userId,
      fileName,
      mimeType,
      url: uploadResult.Location,
      size: fileBuffer.length
    });

    // 5. Return response
    res.json({
      url: uploadResult.Location,
      fileId: fileId,
      fileName: fileName
    });
  } catch (error) {
    console.error('File upload error:', error);
    res.status(500).json({
      message: 'File upload failed',
      error: error.message
    });
  }
});
```

---

## Example 13: GraphQL Query Optimization

### Using Query Caching

```graphql
# Add @cached directive
query GetProducts @cached(ttl: 300) {
  products(
    where: { is_active: { _eq: true } }
    order_by: { created_at: desc }
    limit: 20
  ) {
    id
    name
    price
    image_url
  }
}
```

### Pagination with Cursors

```graphql
# Cursor-based pagination (more efficient than offset)
query GetPostsPaginated($cursor: timestamptz, $limit: Int = 20) {
  posts(
    where: { created_at: { _lt: $cursor } }
    order_by: { created_at: desc }
    limit: $limit
  ) {
    id
    title
    content
    created_at
  }
}

# Next page: use last post's created_at as cursor
```

### Efficient Aggregations

```graphql
# Get counts without fetching all data
query GetStats {
  users_aggregate {
    aggregate {
      count
    }
  }

  posts_aggregate(where: { created_at: { _gte: "2025-01-01" } }) {
    aggregate {
      count
    }
  }

  # Group by and aggregate
  posts_aggregate(
    group_by: [user_id]
    order_by: { aggregate: { count: desc } }
    limit: 10
  ) {
    aggregate {
      count
    }
    nodes {
      user {
        username
      }
    }
  }
}
```

---

## Example 14: Automated Email Notifications

### Event Trigger: New Comment Notification

```yaml
event_triggers:
  - name: comment_added
    table:
      name: comments
      schema: public
    webhook: https://myapp.com/webhooks/comment-added
    insert:
      columns: "*"
```

**Webhook Handler:**

```javascript
const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

app.post('/webhooks/comment-added', async (req, res) => {
  const { event } = req.body;
  const comment = event.data.new;

  try {
    // 1. Fetch comment with post and user details
    const query = `
      query GetCommentDetails($commentId: uuid!) {
        comments_by_pk(id: $commentId) {
          id
          content
          user {
            username
          }
          post {
            id
            title
            user {
              id
              email
              username
            }
          }
        }
      }
    `;

    const response = await hasuraRequest(query, {
      commentId: comment.id
    });

    const commentData = response.data.comments_by_pk;
    const postAuthor = commentData.post.user;

    // 2. Don't notify if commenting on own post
    if (commentData.user.id === postAuthor.id) {
      return res.json({ success: true, skipped: true });
    }

    // 3. Send email notification
    const msg = {
      to: postAuthor.email,
      from: 'notifications@myapp.com',
      subject: `New comment on "${commentData.post.title}"`,
      html: `
        <h2>New Comment</h2>
        <p><strong>${commentData.user.username}</strong> commented on your post:</p>
        <blockquote>${commentData.content}</blockquote>
        <p><a href="https://myapp.com/posts/${commentData.post.id}">View Post</a></p>
      `
    };

    await sgMail.send(msg);

    res.json({ success: true });
  } catch (error) {
    console.error('Comment notification error:', error);
    res.status(500).json({ error: error.message });
  }
});
```

---

## Example 15: Admin Panel with Row-Level Security

### Schema

```sql
-- Users with different roles
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  role TEXT NOT NULL DEFAULT 'user',
  CHECK (role IN ('user', 'moderator', 'admin'))
);

-- Content that can be moderated
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  content TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'published',
  CHECK (status IN ('draft', 'published', 'flagged', 'removed'))
);
```

### Role-Based Permissions

```yaml
# Regular users - can only manage own posts
- table:
    name: posts
    schema: public
  select_permissions:
    - role: user
      permission:
        filter:
          user_id: { _eq: X-Hasura-User-Id }
        columns: "*"

  update_permissions:
    - role: user
      permission:
        filter:
          user_id: { _eq: X-Hasura-User-Id }
        columns: [content, status]
        check:
          status: { _in: ["draft", "published"] }

# Moderators - can view all, flag inappropriate content
- table:
    name: posts
    schema: public
  select_permissions:
    - role: moderator
      permission:
        filter: {}  # Can see all posts
        columns: "*"

  update_permissions:
    - role: moderator
      permission:
        filter: {}
        columns: [status]
        check:
          status: { _in: ["flagged", "removed"] }

# Admins - full access
- table:
    name: posts
    schema: public
  select_permissions:
    - role: admin
      permission:
        filter: {}
        columns: "*"

  insert_permissions:
    - role: admin
      permission:
        check: {}
        columns: "*"

  update_permissions:
    - role: admin
      permission:
        filter: {}
        columns: "*"

  delete_permissions:
    - role: admin
      permission:
        filter: {}
```

---

## Example 16: API Gateway Pattern

### Unified GraphQL API from Multiple Sources

**Hasura as API Gateway:**

1. Local PostgreSQL database (users, orders)
2. Remote GraphQL API (payment service)
3. REST API via Actions (shipping service)

**Remote Schema: Payments API**

```http
POST /v1/metadata HTTP/1.1

{
  "type": "add_remote_schema",
  "args": {
    "name": "payments",
    "definition": {
      "url": "https://payments.myapp.com/graphql"
    }
  }
}
```

**Action: Get Shipping Status (REST to GraphQL)**

```graphql
type Query {
  getShippingStatus(trackingNumber: String!): ShippingStatus
}

type ShippingStatus {
  trackingNumber: String!
  status: String!
  estimatedDelivery: String
  location: String
}
```

**Unified Query:**

```graphql
query GetOrderDetails($orderId: uuid!) {
  # Local database
  orders_by_pk(id: $orderId) {
    id
    total
    created_at

    # Local relationship
    user {
      email
      username
    }

    # Remote schema relationship
    payment {
      transactionId
      status
      amount
    }

    # Action (REST API)
    shippingStatus(trackingNumber: $trackingNumber) {
      status
      estimatedDelivery
      location
    }
  }
}
```

---

## Example 17: Metadata API Automation

### Automate Hasura Configuration

**Script to setup permissions for all tables:**

```javascript
const fetch = require('node-fetch');

const HASURA_ENDPOINT = process.env.HASURA_ENDPOINT;
const ADMIN_SECRET = process.env.HASURA_ADMIN_SECRET;

async function hasuraMetadataRequest(type, args) {
  const response = await fetch(`${HASURA_ENDPOINT}/v1/metadata`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-hasura-admin-secret': ADMIN_SECRET
    },
    body: JSON.stringify({ type, args })
  });

  return await response.json();
}

async function setupTablePermissions(tableName) {
  // Select permission for 'user' role
  await hasuraMetadataRequest('pg_create_select_permission', {
    table: { name: tableName, schema: 'public' },
    role: 'user',
    permission: {
      filter: {
        user_id: { _eq: 'X-Hasura-User-Id' }
      },
      columns: '*'
    }
  });

  // Insert permission
  await hasuraMetadataRequest('pg_create_insert_permission', {
    table: { name: tableName, schema: 'public' },
    role: 'user',
    permission: {
      check: {},
      set: {
        user_id: 'X-Hasura-User-Id'
      },
      columns: '*'
    }
  });

  console.log(`Permissions set for ${tableName}`);
}

async function main() {
  const tables = ['posts', 'comments', 'likes'];

  for (const table of tables) {
    await setupTablePermissions(table);
  }

  console.log('All permissions configured!');
}

main();
```

---

## Summary

These 17 examples cover:

1. Basic CRUD operations
2. Multi-tenant SaaS architecture
3. Social media with complex permissions
4. E-commerce with event triggers
5. Real-time collaboration
6. Authentication actions
7. Event-driven order processing
8. Payment processing
9. Remote schema integration
10. Advanced permission patterns
11. Real-time analytics
12. File uploads
13. Query optimization
14. Automated notifications
15. Admin panels with RLS
16. API gateway pattern
17. Metadata automation

Each example demonstrates production-ready patterns you can adapt for your applications.

---

**Version**: 1.0.0
**Last Updated**: January 2025
