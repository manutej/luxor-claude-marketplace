# Axum Web Framework Skill

Complete guide for building production-ready web applications and REST APIs with Axum, the ergonomic and modular Rust web framework.

## Overview

Axum is a web application framework built on top of Tokio and Tower, designed to be ergonomic, modular, and fast. It leverages Rust's type system to provide compile-time guarantees about request handling, making it an excellent choice for building robust web services.

**Key Features:**

- **Type-Safe Extractors**: Extract request data with compile-time type checking
- **Tower Integration**: Full access to Tower middleware ecosystem
- **Ergonomic API**: Minimal boilerplate with maximum expressiveness
- **Async/Await**: Built on Tokio for high-performance async I/O
- **Composable Routing**: Nested routers and flexible route organization
- **Flexible State Management**: Type-safe shared state across handlers
- **Powerful Middleware**: Layer-based middleware with fine-grained control
- **Error Handling**: Type-safe error conversion to HTTP responses

## Why Axum?

### Performance

Axum is built on Tokio and Hyper, providing excellent performance:

- **Non-blocking I/O**: Efficient handling of thousands of concurrent connections
- **Zero-cost abstractions**: Rust's type system eliminates runtime overhead
- **Minimal allocations**: Careful memory management for low latency
- **HTTP/2 support**: Built-in support for modern HTTP features

### Developer Experience

Axum prioritizes developer ergonomics without sacrificing safety:

- **Type inference**: Handlers automatically adapt to extractor types
- **Compile-time errors**: Catch issues before deployment
- **Clear error messages**: Helpful compiler diagnostics
- **Minimal boilerplate**: Write handlers as simple async functions

### Ecosystem Integration

Axum integrates seamlessly with the Rust ecosystem:

- **Tower middleware**: Reuse middleware from the broader Tower ecosystem
- **Tokio runtime**: Compatible with all Tokio-based libraries
- **Serde integration**: JSON, form, and custom serialization support
- **Database libraries**: Works with sqlx, diesel, and other async ORMs

## When to Use Axum

Axum excels in scenarios requiring:

### REST APIs

- **Microservices**: Build scalable, independent services
- **Public APIs**: Create robust, well-documented APIs
- **Internal APIs**: Service-to-service communication
- **GraphQL backends**: Implement GraphQL resolvers

### Web Applications

- **Server-side rendering**: Generate HTML responses
- **API gateways**: Route and transform requests
- **WebSocket servers**: Real-time bidirectional communication
- **Server-Sent Events**: Push updates to clients

### High-Performance Services

- **High-throughput systems**: Handle millions of requests
- **Low-latency APIs**: Microsecond response times
- **Real-time applications**: Gaming, chat, trading platforms
- **IoT backends**: Handle device telemetry at scale

### Production Systems

- **Mission-critical services**: Banking, healthcare, finance
- **Regulated environments**: Compliance-heavy industries
- **Long-running services**: Stability and reliability required
- **Resource-constrained environments**: Efficient memory usage

## Architecture Overview

### Request Flow

```
Client Request
    ↓
TCP Listener (Tokio)
    ↓
Hyper HTTP Server
    ↓
Tower Middleware Stack (before routing)
    ↓
Axum Router
    ↓
Tower Middleware Stack (after routing)
    ↓
Route Middleware
    ↓
Handler Function
    ↓
Extractors (from request)
    ↓
Business Logic
    ↓
Response (IntoResponse)
    ↓
Tower Middleware Stack (response)
    ↓
Client Response
```

### Component Hierarchy

```
Application
├── Router (routing layer)
│   ├── Routes (path + method → handler)
│   ├── Nested Routers (modular organization)
│   ├── Middleware Layers (cross-cutting concerns)
│   └── Fallback Handler (404s)
├── Handlers (async functions)
│   ├── Extractors (type-safe request data)
│   └── Responses (IntoResponse types)
├── State (shared application data)
│   ├── Database Pools
│   ├── Configuration
│   └── Shared Resources
└── Middleware (Tower layers)
    ├── Logging/Tracing
    ├── Authentication
    ├── Compression
    └── Error Handling
```

### Type System Benefits

Axum leverages Rust's type system for safety:

1. **Extractor Type Safety**: Compile-time validation of request extraction
2. **State Type Safety**: Ensure handlers receive correct state types
3. **Response Type Safety**: All responses implement IntoResponse
4. **Middleware Composability**: Type-safe middleware chaining
5. **Error Handling**: Custom error types with compile-time validation

## Quick Start

### Basic Application

```rust
use axum::{
    Router,
    routing::get,
    response::Json,
};
use serde::Serialize;

#[derive(Serialize)]
struct Message {
    text: String,
}

async fn hello() -> Json<Message> {
    Json(Message {
        text: "Hello, World!".to_string(),
    })
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(hello));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000")
        .await
        .unwrap();

    println!("Listening on http://0.0.0.0:3000");
    axum::serve(listener, app).await.unwrap();
}
```

### With State Management

```rust
use axum::{
    Router,
    routing::get,
    extract::State,
};
use std::sync::Arc;

#[derive(Clone)]
struct AppState {
    counter: Arc<AtomicU64>,
}

async fn increment(State(state): State<AppState>) -> String {
    let value = state.counter.fetch_add(1, Ordering::SeqCst);
    format!("Counter: {}", value + 1)
}

#[tokio::main]
async fn main() {
    let state = AppState {
        counter: Arc::new(AtomicU64::new(0)),
    };

    let app = Router::new()
        .route("/increment", get(increment))
        .with_state(state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000")
        .await
        .unwrap();

    axum::serve(listener, app).await.unwrap();
}
```

### With Middleware

```rust
use axum::{
    Router,
    routing::get,
    middleware,
    extract::Request,
    response::Response,
};
use tower_http::trace::TraceLayer;

async fn logging_middleware(
    req: Request,
    next: middleware::Next,
) -> Response {
    println!("Request: {} {}", req.method(), req.uri());
    next.run(req).await
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(|| async { "Hello!" }))
        .layer(middleware::from_fn(logging_middleware))
        .layer(TraceLayer::new_for_http());

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000")
        .await
        .unwrap();

    axum::serve(listener, app).await.unwrap();
}
```

## Core Concepts

### Handlers

Handlers are async functions that process requests. They can:

- Accept any number of extractors (up to 16)
- Return any type implementing `IntoResponse`
- Be generic over extractors
- Use custom extractors

```rust
// Simple handler
async fn handler() -> &'static str {
    "Hello"
}

// With extractors
async fn user_handler(
    Path(id): Path<u32>,
    State(state): State<AppState>,
    Json(data): Json<UserData>,
) -> Result<Json<User>, AppError> {
    // Process request
}
```

### Extractors

Extractors allow type-safe extraction of data from requests:

- **Path**: URL path parameters
- **Query**: Query string parameters
- **Json**: JSON request body
- **Form**: Form data
- **State**: Application state
- **Headers**: HTTP headers
- **Extension**: Request extensions
- **Custom**: Implement FromRequest

### Responses

Any type implementing `IntoResponse` can be returned:

- Primitive types: `String`, `&str`
- Status codes: `StatusCode`
- Tuples: `(StatusCode, Json<T>)`
- Headers: `(HeaderMap, String)`
- Full control: `Response`
- Custom types: Implement `IntoResponse`

### State

Share data across handlers with type-safe state:

- Must implement `Clone`
- Typically wrapped in `Arc` for shared ownership
- Can have multiple state types with nested routers
- Accessed via `State<T>` extractor

### Middleware

Transform requests and responses with middleware:

- **Tower middleware**: From tower and tower-http crates
- **Custom middleware**: Using `middleware::from_fn`
- **Service trait**: Full control with Tower's Service
- **Layers**: Composable middleware stacks

## Project Structure

### Recommended Organization

```
my-axum-app/
├── Cargo.toml
├── .env
├── src/
│   ├── main.rs                 # Application entry point
│   ├── config.rs               # Configuration management
│   ├── error.rs                # Error types
│   ├── state.rs                # Application state
│   ├── routes/
│   │   ├── mod.rs              # Route modules
│   │   ├── api.rs              # API routes
│   │   ├── auth.rs             # Authentication routes
│   │   └── health.rs           # Health check routes
│   ├── handlers/
│   │   ├── mod.rs              # Handler modules
│   │   ├── users.rs            # User handlers
│   │   └── posts.rs            # Post handlers
│   ├── middleware/
│   │   ├── mod.rs              # Middleware modules
│   │   ├── auth.rs             # Authentication middleware
│   │   └── logging.rs          # Logging middleware
│   ├── models/
│   │   ├── mod.rs              # Data models
│   │   └── user.rs             # User model
│   ├── services/
│   │   ├── mod.rs              # Service modules
│   │   └── user_service.rs     # User business logic
│   └── repositories/
│       ├── mod.rs              # Repository modules
│       └── user_repo.rs        # User data access
├── tests/
│   ├── integration_test.rs     # Integration tests
│   └── common/
│       └── mod.rs              # Test utilities
└── migrations/                 # Database migrations
    └── 001_create_users.sql
```

### Dependencies

**Cargo.toml essentials:**

```toml
[dependencies]
axum = "0.7"
tokio = { version = "1.0", features = ["full"] }
tower = "0.4"
tower-http = { version = "0.5", features = ["fs", "trace", "cors", "compression-full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }

# Database (optional)
sqlx = { version = "0.7", features = ["runtime-tokio-native-tls", "postgres"] }

# Validation (optional)
validator = { version = "0.16", features = ["derive"] }

# Configuration (optional)
config = "0.13"
dotenvy = "0.15"
```

## Best Practices

### 1. Handler Design

- Keep handlers thin, move logic to services
- Use extractors for all input validation
- Return `Result` types for error handling
- Add `#[instrument]` for tracing

### 2. State Management

- Use `Arc` for shared, expensive-to-clone types
- Keep state immutable where possible
- Use `RwLock` or `Mutex` for mutable state
- Keep state structs focused and minimal

### 3. Error Handling

- Create custom error types implementing `IntoResponse`
- Include context in error messages
- Log errors at appropriate levels
- Return correct HTTP status codes

### 4. Middleware

- Apply middleware at the appropriate level
- Use `ServiceBuilder` for multiple layers
- Handle errors from fallible middleware
- Keep middleware focused on single concerns

### 5. Testing

- Write unit tests for handlers
- Use integration tests for full app testing
- Mock external dependencies
- Test error cases thoroughly

### 6. Performance

- Use connection pooling for databases
- Enable response compression
- Implement caching where appropriate
- Use backpressure handling (rate limiting, load shedding)

### 7. Security

- Validate all inputs
- Use HTTPS in production
- Implement proper authentication/authorization
- Set security headers (CORS, CSP, etc.)
- Rate limit public endpoints

## Comparison with Other Frameworks

### Axum vs Actix-web

**Axum Advantages:**
- Simpler, more ergonomic API
- Better Tower ecosystem integration
- More intuitive middleware system
- Type-safe extractors without macros

**Actix-web Advantages:**
- Slightly higher throughput in some benchmarks
- Larger community and ecosystem
- More built-in features

### Axum vs Rocket

**Axum Advantages:**
- Async/await throughout (no blocking)
- More flexible middleware
- Better performance
- No proc macros for routing

**Rocket Advantages:**
- More beginner-friendly
- Rich built-in features
- Comprehensive documentation

### Axum vs Warp

**Axum Advantages:**
- More intuitive API
- Better error messages
- Simpler learning curve
- More flexible routing

**Warp Advantages:**
- Earlier adoption of filter-based approach
- Mature ecosystem

## Resources

### Official Documentation

- **Axum Docs**: https://docs.rs/axum
- **GitHub Repository**: https://github.com/tokio-rs/axum
- **Examples**: https://github.com/tokio-rs/axum/tree/main/examples
- **API Reference**: https://docs.rs/axum/latest/axum/

### Ecosystem Resources

- **Tower**: https://docs.rs/tower
- **Tokio**: https://tokio.rs
- **Hyper**: https://hyper.rs
- **Serde**: https://serde.rs

### Learning Resources

- **Axum Tutorial**: Comprehensive guides in the repository
- **Rust Web Development**: Books and courses on Rust web programming
- **Tower Guides**: Understanding middleware and services
- **Production Deployments**: Real-world Axum applications

### Community

- **Discord**: Tokio Discord server (#axum channel)
- **Reddit**: r/rust web development discussions
- **GitHub Discussions**: Axum repository discussions
- **Stack Overflow**: Questions tagged with [axum]

## Getting Help

When you need assistance:

1. **Check the documentation**: Axum docs are comprehensive
2. **Review examples**: The examples directory has common patterns
3. **Search issues**: GitHub issues often have solutions
4. **Ask the community**: Discord and discussions are active
5. **Use this skill**: Reference patterns and examples here

---

**Skill Version**: 1.0.0
**Maintained By**: Claude Code Skills
**Framework Version**: Axum 0.7+
**Last Updated**: October 2025
