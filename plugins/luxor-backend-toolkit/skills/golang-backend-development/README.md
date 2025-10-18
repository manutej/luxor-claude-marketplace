# Go Backend Development Skill

> Complete guide for building production-grade backend systems with Go, emphasizing concurrency patterns, web servers, and microservices architecture.

## Overview

This skill provides comprehensive guidance for developing backend applications with Go (Golang), covering everything from basic HTTP servers to advanced concurrent systems. Go is particularly well-suited for backend development due to its:

- **Built-in Concurrency**: Goroutines and channels make concurrent programming natural and efficient
- **Fast Compilation**: Near-instant builds enable rapid development cycles
- **Static Typing**: Catch errors at compile time while maintaining clean syntax
- **Standard Library**: Robust HTTP, networking, and encoding packages included
- **Single Binary Deployment**: Simple distribution and deployment
- **Cross-Platform**: Compile for any OS/architecture from any platform
- **Memory Efficiency**: Efficient garbage collection with low overhead
- **Performance**: Near C/C++ performance for many workloads

## Why Go for Backend Development

### Performance Benefits

Go consistently delivers excellent performance for backend workloads:

- **Fast Startup**: Applications start in milliseconds
- **Low Memory Footprint**: Typical Go services use 10-50MB RAM
- **High Throughput**: Handle 10,000+ concurrent connections per instance
- **Efficient Networking**: Non-blocking I/O built into the runtime
- **Quick Compilation**: Rebuild entire applications in seconds

### Concurrency Model

Go's concurrency model is its defining feature:

```go
// Launch thousands of concurrent operations effortlessly
for i := 0; i < 10000; i++ {
    go handleRequest(requests[i])
}
```

**Key Advantages:**
- Goroutines cost ~2KB each (vs. 1MB+ for OS threads)
- Communicate safely through channels (no manual locking)
- Built-in scheduler manages goroutines efficiently
- Context propagation for cancellation and timeouts

### Developer Experience

**Simplicity:**
- 25 keywords (vs. 50+ in most languages)
- One formatting style enforced by `gofmt`
- Explicit error handling (no hidden exceptions)
- Straightforward dependency management with modules

**Tooling:**
- `go test` - built-in testing and benchmarking
- `go build` - compile for any platform
- `go mod` - dependency management
- `go vet` - static analysis
- `go fmt` - automatic formatting
- `pprof` - integrated profiling
- Race detector for finding concurrency bugs

## When to Choose Go

### Excellent For

1. **Web Services and APIs**
   - RESTful APIs
   - GraphQL servers
   - WebSocket servers
   - Microservices

2. **Network Services**
   - Proxies and load balancers
   - Service meshes
   - DNS servers
   - TCP/UDP servers

3. **Cloud-Native Applications**
   - Kubernetes operators
   - Container tools (Docker, containerd)
   - Service discovery
   - Configuration management

4. **Data Processing**
   - Stream processing
   - Log aggregation
   - ETL pipelines
   - Real-time analytics

5. **CLI Tools**
   - System utilities
   - DevOps tools
   - Database clients
   - Automation scripts

### Consider Alternatives For

- CPU-intensive scientific computing (consider Rust, C++)
- Machine learning inference at scale (Python, C++)
- Desktop GUI applications (Electron, Qt)
- Real-time embedded systems (C, Rust)
- Applications requiring dynamic typing (Python, JavaScript)

## Quick Start

### Installation

**macOS:**
```bash
brew install go
```

**Linux:**
```bash
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
```

**Windows:**
Download installer from https://go.dev/dl/

### Verify Installation

```bash
go version
# go version go1.21.0 darwin/arm64
```

### Create Your First Server

```bash
# Create new project
mkdir myserver
cd myserver
go mod init myserver

# Create main.go
cat > main.go << 'EOF'
package main

import (
    "fmt"
    "log"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello, World!")
    })

    log.Println("Server starting on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}
EOF

# Run the server
go run main.go
```

Visit http://localhost:8080 to see your server in action!

### Build and Deploy

```bash
# Build for current platform
go build -o myserver

# Build for Linux
GOOS=linux GOARCH=amd64 go build -o myserver-linux

# Build optimized binary
go build -ldflags="-s -w" -o myserver
```

## Core Concepts

### 1. Goroutines: The Concurrency Primitive

Goroutines are the foundation of Go's concurrency model:

```go
// Sequential execution
doExpensiveTask1()
doExpensiveTask2()
doExpensiveTask3()

// Concurrent execution
go doExpensiveTask1()
go doExpensiveTask2()
go doExpensiveTask3()
```

**Characteristics:**
- Start with ~2KB stack (grows as needed)
- Scheduled by Go runtime, not OS
- Multiplexed onto OS threads
- Can have millions in a single program

### 2. Channels: Safe Communication

Channels provide type-safe communication between goroutines:

```go
// Create channel
messages := make(chan string)

// Send value
go func() {
    messages <- "Hello"
}()

// Receive value
msg := <-messages
fmt.Println(msg)  // "Hello"
```

**Channel Patterns:**
- **Unbuffered**: Synchronous (sender waits for receiver)
- **Buffered**: Asynchronous up to buffer size
- **Directional**: Enforce send-only or receive-only in function signatures
- **Select**: Multiplex multiple channel operations

### 3. The Select Statement

Select enables handling multiple channel operations:

```go
select {
case msg := <-messages:
    fmt.Println("Received:", msg)
case <-timeout:
    fmt.Println("Timed out")
case <-done:
    return
default:
    fmt.Println("No message ready")
}
```

### 4. Context: Request Lifecycle Management

Context propagates cancellation signals and deadlines:

```go
func processRequest(ctx context.Context, data string) error {
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()

    select {
    case result := <-processAsync(data):
        return nil
    case <-ctx.Done():
        return ctx.Err()  // Timeout or cancellation
    }
}
```

### 5. Error Handling

Go uses explicit error handling:

```go
result, err := doSomething()
if err != nil {
    return fmt.Errorf("failed to do something: %w", err)
}

// Use result
```

**Best Practices:**
- Always check errors immediately
- Wrap errors with context using `%w`
- Return errors rather than panic
- Use custom error types for programmatic handling

## Project Structure

Standard Go project layout:

```
myproject/
├── cmd/
│   └── server/
│       └── main.go              # Application entrypoint
├── internal/
│   ├── api/
│   │   ├── handlers.go          # HTTP handlers
│   │   └── middleware.go        # HTTP middleware
│   ├── service/
│   │   └── user.go              # Business logic
│   ├── repository/
│   │   └── postgres.go          # Data access
│   └── models/
│       └── user.go              # Domain models
├── pkg/
│   └── utils/
│       └── validation.go        # Public utilities
├── api/
│   └── openapi.yaml             # API specification
├── migrations/
│   └── 001_init.sql             # Database migrations
├── scripts/
│   └── build.sh                 # Build scripts
├── configs/
│   └── config.yaml              # Configuration
├── docker/
│   └── Dockerfile               # Container definition
├── go.mod                        # Module definition
├── go.sum                        # Dependency checksums
└── README.md
```

**Key Directories:**
- `cmd/`: Main applications for this project
- `internal/`: Private application code (cannot be imported by other projects)
- `pkg/`: Public library code (can be imported by other projects)
- `api/`: API definitions and protocols
- `migrations/`: Database schema migrations

## Development Workflow

### 1. Initialize Project

```bash
mkdir myproject && cd myproject
go mod init github.com/username/myproject
```

### 2. Add Dependencies

```bash
go get github.com/gorilla/mux
go get github.com/lib/pq
```

### 3. Write Code

```bash
# Run during development
go run cmd/server/main.go

# Watch for changes (use air or similar)
air
```

### 4. Test

```bash
# Run all tests
go test ./...

# Run with coverage
go test -cover ./...

# Run with race detector
go test -race ./...

# Benchmark
go test -bench . ./...
```

### 5. Format and Lint

```bash
# Format code
go fmt ./...

# Vet code
go vet ./...

# Use staticcheck
staticcheck ./...
```

### 6. Build

```bash
# Build for current platform
go build -o bin/server cmd/server/main.go

# Build for production (optimized)
go build -ldflags="-s -w" -o bin/server cmd/server/main.go
```

## Common Patterns

### HTTP Server

```go
package main

import (
    "encoding/json"
    "log"
    "net/http"
)

type Response struct {
    Message string `json:"message"`
}

func main() {
    http.HandleFunc("/api/hello", handleHello)
    log.Fatal(http.ListenAndServe(":8080", nil))
}

func handleHello(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(Response{Message: "Hello, World!"})
}
```

### Database Connection

```go
import (
    "database/sql"
    _ "github.com/lib/pq"
)

func initDB() (*sql.DB, error) {
    db, err := sql.Open("postgres",
        "host=localhost port=5432 user=postgres password=secret dbname=mydb sslmode=disable")
    if err != nil {
        return nil, err
    }

    db.SetMaxOpenConns(25)
    db.SetMaxIdleConns(5)
    db.SetConnMaxLifetime(5 * time.Minute)

    return db, db.Ping()
}
```

### Middleware

```go
func loggingMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        next.ServeHTTP(w, r)
        log.Printf("%s %s %v", r.Method, r.URL.Path, time.Since(start))
    })
}

// Usage
http.Handle("/api/", loggingMiddleware(apiHandler))
```

### Worker Pool

```go
func worker(id int, jobs <-chan int, results chan<- int) {
    for j := range jobs {
        results <- process(j)
    }
}

func main() {
    jobs := make(chan int, 100)
    results := make(chan int, 100)

    // Start workers
    for w := 1; w <= 3; w++ {
        go worker(w, jobs, results)
    }

    // Send jobs
    for j := 1; j <= 9; j++ {
        jobs <- j
    }
    close(jobs)

    // Collect results
    for a := 1; a <= 9; a++ {
        <-results
    }
}
```

## Learning Path

### Beginner (Week 1-2)
1. Install Go and set up environment
2. Learn basic syntax and types
3. Understand functions and methods
4. Work with slices, maps, and structs
5. Build simple CLI tools

### Intermediate (Week 3-4)
1. Master goroutines and channels
2. Understand the select statement
3. Build HTTP servers
4. Work with JSON and APIs
5. Implement error handling patterns

### Advanced (Week 5-8)
1. Deep dive into concurrency patterns
2. Master context package
3. Implement middleware patterns
4. Database integration with connection pooling
5. Testing and benchmarking
6. Profiling and optimization
7. Build microservices
8. Deploy to production

## Production Checklist

### Before Deploying

- [ ] All tests pass (`go test ./...`)
- [ ] No race conditions (`go test -race ./...`)
- [ ] Code formatted (`go fmt ./...`)
- [ ] Code vetted (`go vet ./...`)
- [ ] Dependencies up to date (`go mod tidy`)
- [ ] Configuration externalized (environment variables)
- [ ] Logging implemented (structured logging)
- [ ] Metrics exposed (Prometheus format)
- [ ] Health check endpoint (`/health`)
- [ ] Graceful shutdown implemented
- [ ] Request timeouts configured
- [ ] Database connection pool tuned
- [ ] TLS certificates configured (for HTTPS)
- [ ] Rate limiting implemented
- [ ] Input validation on all endpoints
- [ ] Error handling doesn't leak sensitive info

### Deployment Best Practices

1. **Build optimized binaries**
   ```bash
   CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o app
   ```

2. **Use minimal Docker images**
   ```dockerfile
   FROM golang:1.21 AS builder
   WORKDIR /app
   COPY . .
   RUN go build -o server cmd/server/main.go

   FROM alpine:latest
   RUN apk --no-cache add ca-certificates
   WORKDIR /root/
   COPY --from=builder /app/server .
   CMD ["./server"]
   ```

3. **Set resource limits**
   - Memory: Set `GOMEMLIMIT`
   - CPU: Configure container limits
   - File descriptors: Increase for high-concurrency

4. **Monitor in production**
   - CPU and memory usage
   - Goroutine count
   - Request rate and latency
   - Error rates
   - Database connection pool stats

## Common Gotchas

### 1. Loop Variable Capture

```go
// Wrong - all goroutines share same variable
for _, v := range values {
    go func() {
        fmt.Println(v)  // Unpredictable output
    }()
}

// Correct - pass variable as parameter
for _, v := range values {
    go func(val string) {
        fmt.Println(val)  // Correct output
    }(v)
}
```

### 2. Nil Maps

```go
var m map[string]int
m["key"] = 1  // Panic! Map is nil

// Correct
m := make(map[string]int)
m["key"] = 1  // Works
```

### 3. Channel Deadlocks

```go
// Deadlock - unbuffered channel with no receiver
ch := make(chan int)
ch <- 1  // Blocks forever

// Fix 1: Use buffered channel
ch := make(chan int, 1)
ch <- 1  // Doesn't block

// Fix 2: Receive in goroutine
go func() {
    <-ch
}()
ch <- 1
```

### 4. Goroutine Leaks

```go
// Leak - goroutine never exits
func leak() {
    ch := make(chan int)
    go func() {
        val := <-ch  // Waits forever
        process(val)
    }()
    return  // Function exits, goroutine remains
}

// Fix - use context for cancellation
func noLeak(ctx context.Context) {
    ch := make(chan int)
    go func() {
        select {
        case val := <-ch:
            process(val)
        case <-ctx.Done():
            return
        }
    }()
}
```

## Resources

### Official
- [Go Documentation](https://go.dev/doc/)
- [Effective Go](https://go.dev/doc/effective_go)
- [Go Blog](https://go.dev/blog/)
- [Go Playground](https://go.dev/play/)

### Learning
- [Tour of Go](https://go.dev/tour/)
- [Go by Example](https://gobyexample.com/)
- [Learn Go with Tests](https://quii.gitbook.io/learn-go-with-tests/)

### Community
- [Go Forum](https://forum.golangbridge.org/)
- [r/golang](https://www.reddit.com/r/golang/)
- [Gophers Slack](https://gophers.slack.com/)

### Tools
- [Go Tools](https://pkg.go.dev/)
- [Awesome Go](https://awesome-go.com/)

---

**Version**: 1.0.0
**Last Updated**: October 2025
**Maintained By**: Claude Code Skills Team
