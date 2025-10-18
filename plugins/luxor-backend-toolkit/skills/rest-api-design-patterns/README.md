# REST API Design Patterns

> Comprehensive guide for designing, implementing, and maintaining world-class RESTful APIs

## Overview

This skill provides a complete framework for building RESTful APIs following industry best practices. Whether you're designing a new API from scratch or refactoring an existing one, this guide covers everything from resource modeling to performance optimization.

## What You'll Learn

### Core REST Concepts
- REST architectural principles and maturity levels
- Resource-based design thinking
- Stateless communication patterns
- Uniform interface constraints
- Client-server separation

### Resource Modeling
- Naming conventions and URL structure
- Collection vs. individual resource patterns
- Nested resources and relationships
- Resource hierarchies and depth limits
- Action-based endpoints for non-CRUD operations

### HTTP Methods Mastery
- **GET**: Safe, idempotent retrieval operations
- **POST**: Resource creation and non-idempotent actions
- **PUT**: Full resource replacement (idempotent)
- **PATCH**: Partial updates with granular control
- **DELETE**: Resource removal patterns
- **OPTIONS**: CORS and capability discovery
- **HEAD**: Metadata retrieval without body

### API Versioning Strategies
1. **URI Versioning** (e.g., `/api/v1/users`) - Most common
2. **Header Versioning** (e.g., `X-API-Version: 2.0`) - Clean URIs
3. **Content Negotiation** (e.g., `Accept: application/vnd.api.v2+json`) - RESTful
4. **Query Parameter Versioning** (e.g., `/users?version=2`) - Simple but limited

### Pagination Patterns
- **Offset-based**: Traditional page/limit approach
- **Cursor-based**: Efficient for large datasets, prevents missed records
- **Page-based**: User-friendly numbered pages
- **Keyset**: Performance-optimized for ordered data

### Filtering and Sorting
- Query parameter conventions
- Complex filtering patterns
- Multi-field sorting
- Full-text search integration
- Faceted filtering for rich UIs

### Error Handling
- Consistent error response formats
- HTTP status code selection guide
- Validation error structures
- Error codes and debugging information
- User-friendly vs. developer-friendly messages

### HATEOAS and Hypermedia
- Link relations and affordances
- Self-documenting APIs
- Dynamic navigation
- Discoverability patterns
- HAL, JSON:API, and other formats

### Performance Optimization
- Caching strategies (ETags, Cache-Control)
- Response compression (gzip, brotli)
- Database query optimization
- Connection pooling
- Rate limiting patterns
- CDN integration

### Security Best Practices
- Authentication patterns (JWT, OAuth 2.0, API keys)
- Authorization and RBAC
- Input validation and sanitization
- CORS configuration
- Security headers
- Rate limiting and DDoS prevention
- Secrets management

### API Documentation
- OpenAPI/Swagger specifications
- Interactive documentation (Swagger UI, ReDoc)
- Code examples and SDKs
- Versioning documentation
- Changelog maintenance

## Quick Reference

### REST Design Checklist

```
Resource Design:
  ✓ Use plural nouns for collections (/users, /products)
  ✓ Use lowercase with hyphens (/user-profiles)
  ✓ Keep nesting to 2-3 levels maximum
  ✓ Use query parameters for filtering/sorting
  ✓ Implement proper pagination

HTTP Methods:
  ✓ GET for retrieval (safe, idempotent, cacheable)
  ✓ POST for creation (not idempotent)
  ✓ PUT for full replacement (idempotent)
  ✓ PATCH for partial updates (idempotent)
  ✓ DELETE for removal (idempotent)

Status Codes:
  ✓ 200 OK for successful GET/PUT/PATCH
  ✓ 201 Created for successful POST
  ✓ 204 No Content for successful DELETE
  ✓ 400 Bad Request for client errors
  ✓ 401 Unauthorized for authentication required
  ✓ 403 Forbidden for authorization failures
  ✓ 404 Not Found for missing resources
  ✓ 422 Unprocessable Entity for validation errors
  ✓ 429 Too Many Requests for rate limiting
  ✓ 500 Internal Server Error for server issues

Versioning:
  ✓ Choose one strategy and stick to it
  ✓ Document version lifecycle
  ✓ Support multiple versions temporarily
  ✓ Deprecate gracefully with warnings
  ✓ Sunset old versions with notice

Security:
  ✓ Always use HTTPS in production
  ✓ Implement authentication
  ✓ Validate all inputs
  ✓ Sanitize all outputs
  ✓ Use rate limiting
  ✓ Enable CORS carefully
  ✓ Log security events

Performance:
  ✓ Implement caching (ETags, Cache-Control)
  ✓ Use compression for large responses
  ✓ Paginate collections
  ✓ Optimize database queries
  ✓ Use async I/O
  ✓ Monitor performance metrics

Documentation:
  ✓ Generate OpenAPI specs
  ✓ Provide interactive docs
  ✓ Include code examples
  ✓ Document error responses
  ✓ Keep changelog updated
```

## Design Decision Framework

### When to Use Each HTTP Method

**GET - Retrieval**
```
Use when: Fetching data without side effects
Examples:
  - List all users: GET /users
  - Get user by ID: GET /users/123
  - Search products: GET /products?q=laptop
Safe: Yes | Idempotent: Yes | Cacheable: Yes
```

**POST - Creation or Actions**
```
Use when: Creating new resources or triggering actions
Examples:
  - Create user: POST /users
  - Login: POST /auth/login
  - Process payment: POST /payments/123/process
Safe: No | Idempotent: No | Cacheable: No
```

**PUT - Full Replacement**
```
Use when: Replacing entire resource
Examples:
  - Update all user fields: PUT /users/123
  - Replace configuration: PUT /settings
Requires: All fields in request body
Safe: No | Idempotent: Yes | Cacheable: No
```

**PATCH - Partial Update**
```
Use when: Updating specific fields
Examples:
  - Update email only: PATCH /users/123 {"email": "new@example.com"}
  - Change status: PATCH /orders/456 {"status": "shipped"}
Requires: Only fields to update
Safe: No | Idempotent: Yes | Cacheable: No
```

**DELETE - Removal**
```
Use when: Removing resources
Examples:
  - Delete user: DELETE /users/123
  - Cancel subscription: DELETE /subscriptions/789
Safe: No | Idempotent: Yes | Cacheable: No
```

### When to Use Nested Resources

**Use Nested Routes When:**
- Strong ownership relationship exists (comments belong to posts)
- Parent context is always required
- Nesting is 2-3 levels maximum
- Example: `GET /posts/42/comments`

**Use Flat Routes When:**
- Resources can exist independently
- You need to query across parents
- Resource has multiple parents
- Example: `GET /comments?post_id=42&user_id=5`

**Hybrid Approach:**
```
# Create comment on post (nested)
POST /posts/42/comments

# Get comments across all posts (flat)
GET /comments?user_id=5

# Get specific comment (flat - if you have ID)
GET /comments/123
```

### Versioning Strategy Selection

**Choose URI Versioning if:**
- You want explicit, visible versions
- You need different routing logic
- You're building a public API
- You want browser-friendly testing
- Example: `/api/v1/users`, `/api/v2/users`

**Choose Header Versioning if:**
- You want clean, unchanging URIs
- You're building an internal API
- You understand content negotiation
- Example: `X-API-Version: 2.0`

**Choose Content Negotiation if:**
- You're a REST purist
- You understand Accept headers well
- You want maximum RESTfulness
- Example: `Accept: application/vnd.api.v2+json`

### Pagination Strategy Selection

**Offset-Based (Traditional)**
```
Best for: Small to medium datasets, user-facing pages
Pros: Simple, supports jumping to any page
Cons: Performance issues with large offsets, inconsistent with data changes
Example: GET /items?limit=10&offset=20
```

**Cursor-Based (Recommended)**
```
Best for: Large datasets, real-time data, feeds
Pros: Consistent results, efficient, handles data changes
Cons: Can't jump to arbitrary page
Example: GET /items?limit=10&cursor=eyJpZCI6MTIzfQ==
```

**Page-Based**
```
Best for: User interfaces with page numbers
Pros: User-friendly, intuitive
Cons: Same issues as offset-based
Example: GET /items?page=3&page_size=10
```

**Keyset Pagination**
```
Best for: Performance-critical applications
Pros: Best performance, consistent
Cons: Requires indexed column, complex implementation
Example: GET /items?limit=10&since_id=123
```

## Common Patterns

### Resource Filtering

```
Single field:
  GET /products?category=electronics

Multiple fields:
  GET /products?category=electronics&min_price=100&max_price=500

Multiple values (OR):
  GET /products?tags=wireless,bluetooth

Range queries:
  GET /events?start_date=2024-01-01&end_date=2024-12-31

Text search:
  GET /articles?q=machine+learning

Negation:
  GET /users?status!=inactive

Complex queries (JSON):
  GET /products?filter={"category": "electronics", "price": {"$gte": 100}}
```

### Resource Sorting

```
Single field:
  GET /products?sort=price

Descending:
  GET /products?sort=-price

Multiple fields:
  GET /products?sort=category,price

Mixed order:
  GET /products?sort=category,-price

Query parameter style:
  GET /products?sort_by=price&order=desc
```

### Bulk Operations

```
Bulk create:
  POST /users/bulk
  Body: [{"name": "User 1"}, {"name": "User 2"}]

Bulk update:
  PATCH /users/bulk
  Body: [{"id": 1, "status": "active"}, {"id": 2, "status": "inactive"}]

Bulk delete:
  DELETE /users?ids=1,2,3,4

Batch processing:
  POST /jobs/batch
  Body: {"operations": [{"action": "create", "resource": "user", "data": {...}}]}
```

### Action Endpoints

For operations that don't fit CRUD:

```
User actions:
  POST /users/123/activate
  POST /users/123/deactivate
  POST /users/123/reset-password

Order actions:
  POST /orders/456/cancel
  POST /orders/456/refund
  POST /orders/456/ship

Document actions:
  POST /documents/789/publish
  POST /documents/789/archive
  POST /documents/789/duplicate
```

## Framework-Specific Examples

### FastAPI Advantages

- Automatic OpenAPI documentation
- Pydantic data validation
- Type hints for better IDE support
- Async/await support out of the box
- Dependency injection system

### Express.js Advantages

- Mature ecosystem with extensive middleware
- Flexible and unopinionated
- Large community and resources
- Easy to integrate with existing Node.js apps
- Great for microservices

## Integration Patterns

### Database Integration

**Connection Pooling:**
```python
# FastAPI with asyncpg
from databases import Database

database = Database("postgresql://user:pass@localhost/db")

@app.on_event("startup")
async def startup():
    await database.connect()

@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()
```

### Authentication Integration

**JWT with Refresh Tokens:**
```
POST /auth/login
  → Returns: access_token (15 min), refresh_token (7 days)

GET /api/resource
  → Header: Authorization: Bearer {access_token}

POST /auth/refresh
  → Body: {refresh_token}
  → Returns: new access_token
```

### Third-Party API Integration

**Webhook Patterns:**
```
Register webhook:
  POST /webhooks
  Body: {"url": "https://example.com/webhook", "events": ["user.created"]}

Webhook delivery:
  POST https://example.com/webhook
  Headers: X-Webhook-Signature: {hmac_signature}
  Body: {"event": "user.created", "data": {...}}

Verify webhooks:
  GET /webhooks/{id}
  DELETE /webhooks/{id}
```

## When to Use This Skill

### Perfect For

- Building new RESTful APIs from scratch
- Refactoring legacy APIs for better design
- Standardizing API patterns across teams
- Onboarding new developers to REST principles
- API design reviews and audits
- Creating API style guides
- Microservices architecture
- Mobile and web backends
- Third-party integrations

### Also Useful For

- Understanding API best practices
- Preparing for technical interviews
- Learning HTTP protocol deeply
- Designing consistent error handling
- Implementing security patterns
- Optimizing API performance
- Creating API documentation
- Building developer-friendly APIs

## Resources and Further Reading

### Official Specifications
- RFC 7231 (HTTP/1.1 Semantics)
- RFC 6749 (OAuth 2.0)
- OpenAPI Specification
- JSON Schema

### Books
- "RESTful Web APIs" by Leonard Richardson & Mike Amundsen
- "REST API Design Rulebook" by Mark Masse
- "Building Microservices" by Sam Newman

### Online Resources
- FastAPI Documentation: https://fastapi.tiangolo.com
- Express.js Guide: https://expressjs.com/en/guide/routing.html
- MDN HTTP Documentation: https://developer.mozilla.org/en-US/docs/Web/HTTP
- REST API Tutorial: https://restfulapi.net

## Contributing

This skill is continuously updated with new patterns, examples, and best practices from real-world API development.

---

**Version**: 1.0.0
**Last Updated**: October 2025
**Maintained By**: Claude Code Skills Team
