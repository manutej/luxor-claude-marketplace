# GraphQL API Development

Build production-ready GraphQL APIs with Node.js, Express, and graphql-js. This comprehensive skill covers everything from basic schema design to advanced patterns like federation, subscriptions, and real-time updates.

## Overview

GraphQL is a query language and runtime for APIs that gives clients precise control over the data they request. Unlike REST APIs with fixed endpoints, GraphQL allows clients to specify exactly what data they need in a single request, reducing over-fetching and under-fetching.

## Key Features

### Schema-First Development
- **Strongly Typed**: Every field has a defined type, enabling validation and tooling
- **Self-Documenting**: Schema serves as live documentation via introspection
- **Contract-Based**: Schema defines the contract between client and server
- **IDE Support**: Rich autocomplete and validation in development tools

### Flexible Data Fetching
- **Precise Queries**: Clients request exactly what they need
- **Single Request**: Fetch multiple resources in one roundtrip
- **Nested Data**: Navigate relationships naturally
- **No Versioning**: Add new fields without breaking existing clients

### Real-Time Capabilities
- **Subscriptions**: WebSocket-based real-time updates
- **Live Queries**: Automatically update when data changes
- **Event-Driven**: Publish-subscribe pattern for notifications
- **Bi-directional**: Server can push updates to clients

### Developer Experience
- **GraphiQL/Playground**: Interactive API exploration
- **Type Generation**: Auto-generate TypeScript types from schema
- **Error Handling**: Rich error information with field-level precision
- **Introspection**: Query the schema itself for documentation

## When to Use GraphQL

### Ideal Use Cases

1. **Complex Data Requirements**
   - Apps with many views requiring different data shapes
   - Mobile apps with bandwidth constraints
   - Multiple client types (web, mobile, desktop)

2. **Rapid Iteration**
   - Frontend teams need flexibility without backend changes
   - Frequent UI changes requiring different data
   - A/B testing different features

3. **Microservices Architecture**
   - Multiple data sources to aggregate
   - Need unified API across services
   - Service composition and federation

4. **Real-Time Features**
   - Chat applications
   - Live dashboards
   - Collaborative editing
   - Notifications and updates

5. **Developer Productivity**
   - Type safety end-to-end
   - Self-documenting API
   - Strong tooling ecosystem

### When REST Might Be Better

- Simple CRUD operations
- File uploads/downloads (requires multipart handling in GraphQL)
- HTTP caching is critical (GraphQL typically uses POST)
- Team unfamiliar with GraphQL (learning curve)
- Existing REST infrastructure works well

## Core Concepts

### The Type System

GraphQL's type system is the foundation of every GraphQL API:

```graphql
# Scalar types
String    # Text data
Int       # 32-bit integer
Float     # Floating point number
Boolean   # true or false
ID        # Unique identifier

# Object types
type User {
  id: ID!           # ! means non-null (required)
  name: String!
  email: String!
  age: Int
  posts: [Post!]!   # List of posts (non-null list, non-null items)
}

# Input types (for mutations)
input CreateUserInput {
  name: String!
  email: String!
  age: Int
}

# Enums
enum Role {
  USER
  ADMIN
  MODERATOR
}

# Interfaces (shared fields)
interface Node {
  id: ID!
  createdAt: String!
}

# Unions (multiple possible types)
union SearchResult = User | Post | Comment
```

### Schema Structure

Every GraphQL schema has entry points:

```graphql
# Read operations
type Query {
  user(id: ID!): User
  posts: [Post!]!
  search(query: String!): [SearchResult!]!
}

# Write operations
type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  deleteUser(id: ID!): Boolean!
}

# Real-time updates
type Subscription {
  userCreated: User!
  postPublished: Post!
  messageReceived(channelId: ID!): Message!
}
```

### Resolvers

Resolvers are functions that fetch the data for each field:

```javascript
const resolvers = {
  Query: {
    user: (parent, args, context) => {
      return context.db.findUserById(args.id);
    },
    posts: (parent, args, context) => {
      return context.db.getAllPosts();
    }
  },
  User: {
    posts: (user, args, context) => {
      // Fetch posts for this specific user
      return context.db.findPostsByAuthorId(user.id);
    }
  },
  Mutation: {
    createUser: (parent, { input }, context) => {
      return context.db.createUser(input);
    }
  }
};
```

**Resolver signature**: `(parent, args, context, info) => result`
- **parent**: Result from parent resolver
- **args**: Field arguments
- **context**: Shared state (database, user, etc.)
- **info**: Query metadata

## Quick Start

### 1. Install Dependencies

```bash
npm install graphql express graphql-http
```

### 2. Define Schema

```javascript
import { buildSchema } from 'graphql';

const schema = buildSchema(`
  type User {
    id: ID!
    name: String!
    email: String!
  }

  type Query {
    user(id: ID!): User
    users: [User!]!
  }

  type Mutation {
    createUser(name: String!, email: String!): User!
  }
`);
```

### 3. Implement Resolvers

```javascript
const users = [
  { id: '1', name: 'Alice', email: 'alice@example.com' },
  { id: '2', name: 'Bob', email: 'bob@example.com' }
];

const root = {
  user: ({ id }) => users.find(u => u.id === id),
  users: () => users,
  createUser: ({ name, email }) => {
    const user = {
      id: String(users.length + 1),
      name,
      email
    };
    users.push(user);
    return user;
  }
};
```

### 4. Create Server

```javascript
import express from 'express';
import { createHandler } from 'graphql-http/lib/use/express';

const app = express();

app.all('/graphql', createHandler({
  schema,
  rootValue: root
}));

app.listen(4000, () => {
  console.log('GraphQL server running at http://localhost:4000/graphql');
});
```

### 5. Query Your API

```graphql
# Fetch a user
query {
  user(id: "1") {
    id
    name
    email
  }
}

# Create a user
mutation {
  createUser(name: "Charlie", email: "charlie@example.com") {
    id
    name
  }
}

# Fetch all users
query {
  users {
    id
    name
  }
}
```

## Schema Design Principles

### 1. Design from the Client Perspective

Think about what clients need, not what your database looks like:

```graphql
# Good: Client-focused
type Product {
  displayPrice: String!    # "$19.99"
  isAvailable: Boolean!
  canShipToday: Boolean!
}

# Avoid: Database-focused
type Product {
  price_cents: Int!
  stock_quantity: Int!
  warehouse_id: ID!
}
```

### 2. Use Nullable Fields Carefully

Only mark fields as non-null (`!`) if they'll ALWAYS have a value:

```graphql
type User {
  id: ID!           # ✓ Always has ID
  name: String!     # ✓ Required field
  email: String!    # ✓ Required for login
  bio: String       # ✗ Optional, might be null
  avatar: String    # ✗ Optional
}
```

### 3. Embrace Relationships

GraphQL naturally handles relationships:

```graphql
type User {
  id: ID!
  name: String!
  posts: [Post!]!      # User has many posts
  followers: [User!]!   # User has many followers
}

type Post {
  id: ID!
  title: String!
  author: User!         # Post belongs to user
  comments: [Comment!]!
}
```

### 4. Use Input Types for Mutations

Always use input types for complex mutations:

```graphql
# Good
input CreatePostInput {
  title: String!
  content: String!
  tags: [String!]
  draft: Boolean
}

type Mutation {
  createPost(input: CreatePostInput!): Post!
}

# Avoid
type Mutation {
  createPost(
    title: String!,
    content: String!,
    tags: [String!],
    draft: Boolean
  ): Post!
}
```

### 5. Plan for Pagination

Lists that can grow should be paginated:

```graphql
type Query {
  # Simple offset pagination
  posts(offset: Int, limit: Int): PostConnection!

  # Cursor-based (better for real-time data)
  feed(first: Int, after: String): FeedConnection!
}

type PostConnection {
  items: [Post!]!
  total: Int!
  hasMore: Boolean!
}
```

### 6. Handle Errors Gracefully

Design mutations to return detailed error information:

```graphql
type CreateUserPayload {
  user: User
  errors: [UserError!]
  success: Boolean!
}

type UserError {
  field: String
  message: String!
}

type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
}
```

## Performance Optimization

### The N+1 Problem

Most common GraphQL performance issue:

```javascript
// BAD: Causes N+1 queries
type User {
  posts: [Post!]!
}

// Resolver runs once per user!
User: {
  posts: (user) => db.query('SELECT * FROM posts WHERE author_id = ?', user.id)
}

// Querying 100 users = 1 query for users + 100 queries for posts = 101 total!
```

### Solution: DataLoader

```javascript
import DataLoader from 'dataloader';

const postLoader = new DataLoader(async (userIds) => {
  // One query for ALL users
  const posts = await db.query(
    'SELECT * FROM posts WHERE author_id IN (?)',
    userIds
  );

  // Group by user ID
  const postsByUser = {};
  posts.forEach(post => {
    if (!postsByUser[post.author_id]) {
      postsByUser[post.author_id] = [];
    }
    postsByUser[post.author_id].push(post);
  });

  // Return in same order as input
  return userIds.map(id => postsByUser[id] || []);
});

// Use in resolver
User: {
  posts: (user, args, context) => context.loaders.post.load(user.id)
}

// 100 users = 1 query for users + 1 query for ALL posts = 2 total!
```

## Authentication and Authorization

### Context-Based Auth

```javascript
// Extract user from JWT token
const context = async ({ req }) => {
  const token = req.headers.authorization?.replace('Bearer ', '');

  if (!token) {
    return { user: null };
  }

  const user = await verifyToken(token);
  return { user };
};

// Use in resolver
Query: {
  me: (parent, args, context) => {
    if (!context.user) {
      throw new Error('Not authenticated');
    }
    return context.user;
  }
}
```

### Field-Level Authorization

```javascript
Post: {
  draft: (post, args, context) => {
    // Only author can see draft status
    if (post.authorId !== context.user?.id) {
      return null;
    }
    return post.draft;
  }
}
```

## Real-Time with Subscriptions

### Setup

```javascript
import { PubSub } from 'graphql-subscriptions';

const pubsub = new PubSub();

const resolvers = {
  Subscription: {
    postCreated: {
      subscribe: () => pubsub.asyncIterator(['POST_CREATED'])
    }
  },
  Mutation: {
    createPost: async (parent, { input }) => {
      const post = await db.createPost(input);

      // Notify subscribers
      pubsub.publish('POST_CREATED', { postCreated: post });

      return post;
    }
  }
};
```

### Client Usage

```graphql
subscription {
  postCreated {
    id
    title
    author {
      name
    }
  }
}
```

## Testing

### Unit Test Resolvers

```javascript
import { expect, test } from '@jest/globals';

test('user resolver returns user', async () => {
  const mockDb = {
    findUserById: () => Promise.resolve({
      id: '1',
      name: 'Alice'
    })
  };

  const result = await resolvers.Query.user(
    null,
    { id: '1' },
    { db: mockDb }
  );

  expect(result.name).toBe('Alice');
});
```

### Integration Test Queries

```javascript
import { graphql } from 'graphql';

test('executes user query', async () => {
  const query = `
    query {
      user(id: "1") {
        id
        name
      }
    }
  `;

  const result = await graphql({
    schema,
    source: query,
    contextValue: { db: mockDb }
  });

  expect(result.errors).toBeUndefined();
  expect(result.data.user.name).toBe('Alice');
});
```

## Best Practices Checklist

- [ ] Use input types for all mutations
- [ ] Implement DataLoader for nested data
- [ ] Add pagination for unbounded lists
- [ ] Handle errors with detailed messages
- [ ] Validate inputs before database operations
- [ ] Use context for shared state (db, auth, loaders)
- [ ] Implement proper authentication/authorization
- [ ] Cache frequently accessed data
- [ ] Monitor query complexity and depth
- [ ] Version with @deprecated, never break existing queries
- [ ] Test resolvers and integration
- [ ] Document schema with descriptions
- [ ] Use non-null only for truly required fields
- [ ] Organize schema into logical modules
- [ ] Secure production with rate limiting

## Example Use Cases

### E-Commerce API

```graphql
type Product {
  id: ID!
  name: String!
  price: Float!
  description: String
  images: [String!]!
  inStock: Boolean!
  reviews: [Review!]!
}

type Cart {
  id: ID!
  items: [CartItem!]!
  total: Float!
}

type Mutation {
  addToCart(productId: ID!, quantity: Int!): Cart!
  checkout(cartId: ID!, paymentMethod: String!): Order!
}
```

### Social Media API

```graphql
type User {
  id: ID!
  username: String!
  posts: [Post!]!
  followers: [User!]!
  following: [User!]!
}

type Post {
  id: ID!
  content: String!
  author: User!
  likes: Int!
  comments: [Comment!]!
  createdAt: String!
}

type Subscription {
  newPost: Post!
  newFollower: User!
}
```

### Blog API

```graphql
type Post {
  id: ID!
  title: String!
  content: String!
  author: Author!
  tags: [String!]!
  publishedAt: String
  draft: Boolean!
}

type Query {
  post(id: ID!): Post
  posts(tag: String, published: Boolean): [Post!]!
  search(query: String!): [Post!]!
}
```

## Common Patterns

### Relay Connection Pattern

```graphql
type PostConnection {
  edges: [PostEdge!]!
  pageInfo: PageInfo!
}

type PostEdge {
  node: Post!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  endCursor: String
}
```

### Mutation Payload Pattern

```graphql
type CreatePostPayload {
  post: Post
  errors: [Error!]
  userErrors: [UserError!]
  success: Boolean!
}
```

### Abstract Types Pattern

```graphql
interface Node {
  id: ID!
}

union SearchResult = User | Post | Comment

type Query {
  node(id: ID!): Node
  search(query: String!): [SearchResult!]!
}
```

## Next Steps

1. Read SKILL.md for comprehensive documentation
2. Check EXAMPLES.md for detailed code examples
3. Build a simple GraphQL API following the quick start
4. Implement DataLoader for performance
5. Add authentication and authorization
6. Set up subscriptions for real-time features
7. Write tests for your resolvers
8. Deploy to production with monitoring

## Resources

- **Official Docs**: https://graphql.org/learn/
- **GraphQL.js**: https://github.com/graphql/graphql-js
- **How to GraphQL**: https://howtographql.com
- **Apollo Docs**: https://apollographql.com/docs/
- **GraphQL Tools**: https://graphql-tools.com

---

**Version**: 1.0.0
**Author**: Claude Code Skill
**License**: MIT
