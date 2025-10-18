# Go Backend Development Examples

> 25+ practical, production-ready examples demonstrating Go backend patterns, from basic HTTP servers to advanced microservices.

## Table of Contents

1. [Basic Web Server](#1-basic-web-server)
2. [JSON REST API](#2-json-rest-api)
3. [Middleware Chain](#3-middleware-chain)
4. [Context-Based Timeout](#4-context-based-timeout)
5. [Worker Pool Pattern](#5-worker-pool-pattern)
6. [Pipeline Pattern](#6-pipeline-pattern)
7. [Fan-Out/Fan-In Pattern](#7-fan-outfan-in-pattern)
8. [Database CRUD Operations](#8-database-crud-operations)
9. [Transaction Handling](#9-transaction-handling)
10. [Graceful Shutdown](#10-graceful-shutdown)
11. [Rate Limiting](#11-rate-limiting)
12. [Circuit Breaker](#12-circuit-breaker)
13. [WebSocket Server](#13-websocket-server)
14. [gRPC Service](#14-grpc-service)
15. [Caching Layer](#15-caching-layer)
16. [Event-Driven Architecture](#16-event-driven-architecture)
17. [File Upload Handler](#17-file-upload-handler)
18. [Authentication Middleware](#18-authentication-middleware)
19. [Structured Logging](#19-structured-logging)
20. [Health Check System](#20-health-check-system)
21. [Concurrent File Processing](#21-concurrent-file-processing)
22. [Service Discovery](#22-service-discovery)
23. [Message Queue Consumer](#23-message-queue-consumer)
24. [Background Job Processor](#24-background-job-processor)
25. [API Gateway Pattern](#25-api-gateway-pattern)

---

## 1. Basic Web Server

A minimal HTTP server demonstrating Go's built-in web capabilities.

```go
package main

import (
    "fmt"
    "log"
    "net/http"
)

func main() {
    // Register handler function
    http.HandleFunc("/", handleRoot)
    http.HandleFunc("/health", handleHealth)

    // Start server
    log.Println("Server starting on :8080")
    if err := http.ListenAndServe(":8080", nil); err != nil {
        log.Fatal(err)
    }
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello, World!")
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusOK)
    fmt.Fprintf(w, "OK")
}
```

**Use Case**: Simple web services, health check endpoints, landing pages

**Key Concepts**:
- `http.HandleFunc` registers handlers
- `http.ListenAndServe` starts the server
- Handler functions receive `ResponseWriter` and `*Request`

---

## 2. JSON REST API

Complete RESTful API with JSON encoding/decoding.

```go
package main

import (
    "encoding/json"
    "log"
    "net/http"
    "strconv"
    "sync"
)

type User struct {
    ID    int    `json:"id"`
    Name  string `json:"name"`
    Email string `json:"email"`
}

type UserStore struct {
    users map[int]*User
    mu    sync.RWMutex
    nextID int
}

func NewUserStore() *UserStore {
    return &UserStore{
        users: make(map[int]*User),
        nextID: 1,
    }
}

func (s *UserStore) Create(user *User) *User {
    s.mu.Lock()
    defer s.mu.Unlock()
    user.ID = s.nextID
    s.nextID++
    s.users[user.ID] = user
    return user
}

func (s *UserStore) Get(id int) (*User, bool) {
    s.mu.RLock()
    defer s.mu.RUnlock()
    user, ok := s.users[id]
    return user, ok
}

func (s *UserStore) List() []*User {
    s.mu.RLock()
    defer s.mu.RUnlock()
    users := make([]*User, 0, len(s.users))
    for _, user := range s.users {
        users = append(users, user)
    }
    return users
}

func main() {
    store := NewUserStore()

    http.HandleFunc("/users", func(w http.ResponseWriter, r *http.Request) {
        switch r.Method {
        case http.MethodGet:
            handleListUsers(w, r, store)
        case http.MethodPost:
            handleCreateUser(w, r, store)
        default:
            http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
        }
    })

    http.HandleFunc("/users/", func(w http.ResponseWriter, r *http.Request) {
        if r.Method == http.MethodGet {
            handleGetUser(w, r, store)
        } else {
            http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
        }
    })

    log.Fatal(http.ListenAndServe(":8080", nil))
}

func handleListUsers(w http.ResponseWriter, r *http.Request, store *UserStore) {
    users := store.List()
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(users)
}

func handleCreateUser(w http.ResponseWriter, r *http.Request, store *UserStore) {
    var user User
    if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    created := store.Create(&user)
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusCreated)
    json.NewEncoder(w).Encode(created)
}

func handleGetUser(w http.ResponseWriter, r *http.Request, store *UserStore) {
    // Extract ID from path (simple parsing)
    idStr := r.URL.Path[len("/users/"):]
    id, err := strconv.Atoi(idStr)
    if err != nil {
        http.Error(w, "Invalid user ID", http.StatusBadRequest)
        return
    }

    user, ok := store.Get(id)
    if !ok {
        http.Error(w, "User not found", http.StatusNotFound)
        return
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(user)
}
```

**Use Case**: RESTful APIs, CRUD operations, microservice endpoints

**Key Concepts**:
- JSON encoding/decoding with struct tags
- Thread-safe data access with `sync.RWMutex`
- HTTP method routing
- Status code handling

---

## 3. Middleware Chain

Composable middleware for cross-cutting concerns.

```go
package main

import (
    "log"
    "net/http"
    "time"
)

type Middleware func(http.Handler) http.Handler

// Chain multiple middleware
func Chain(h http.Handler, middlewares ...Middleware) http.Handler {
    for i := len(middlewares) - 1; i >= 0; i-- {
        h = middlewares[i](h)
    }
    return h
}

// Logging middleware
func LoggingMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        next.ServeHTTP(w, r)
        log.Printf("%s %s %v", r.Method, r.URL.Path, time.Since(start))
    })
}

// CORS middleware
func CORSMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Access-Control-Allow-Origin", "*")
        w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

        if r.Method == http.MethodOptions {
            w.WriteHeader(http.StatusOK)
            return
        }

        next.ServeHTTP(w, r)
    })
}

// Recovery middleware
func RecoveryMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        defer func() {
            if err := recover(); err != nil {
                log.Printf("panic recovered: %v", err)
                http.Error(w, "Internal Server Error", http.StatusInternalServerError)
            }
        }()
        next.ServeHTTP(w, r)
    })
}

// Request ID middleware
func RequestIDMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        requestID := r.Header.Get("X-Request-ID")
        if requestID == "" {
            requestID = generateRequestID()
        }
        w.Header().Set("X-Request-ID", requestID)
        next.ServeHTTP(w, r)
    })
}

func generateRequestID() string {
    return fmt.Sprintf("%d", time.Now().UnixNano())
}

func main() {
    handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte("Hello, World!"))
    })

    // Chain middleware
    wrapped := Chain(handler,
        RecoveryMiddleware,
        LoggingMiddleware,
        CORSMiddleware,
        RequestIDMiddleware,
    )

    http.Handle("/", wrapped)
    log.Fatal(http.ListenAndServe(":8080", nil))
}
```

**Use Case**: Adding logging, CORS, authentication, recovery to handlers

**Key Concepts**:
- Middleware as higher-order functions
- Composable handler chain
- Request/response wrapping

---

## 4. Context-Based Timeout

Using context for request timeouts and cancellation.

```go
package main

import (
    "context"
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "time"
)

func main() {
    http.HandleFunc("/search", handleSearch)
    log.Fatal(http.ListenAndServe(":8080", nil))
}

func handleSearch(w http.ResponseWriter, r *http.Request) {
    // Create context with timeout
    ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
    defer cancel()

    query := r.URL.Query().Get("q")
    if query == "" {
        http.Error(w, "missing query parameter", http.StatusBadRequest)
        return
    }

    // Perform search with context
    results, err := performSearch(ctx, query)
    if err != nil {
        if err == context.DeadlineExceeded {
            http.Error(w, "Search timeout", http.StatusRequestTimeout)
            return
        }
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(results)
}

type SearchResult struct {
    Query   string   `json:"query"`
    Results []string `json:"results"`
    Took    string   `json:"took"`
}

func performSearch(ctx context.Context, query string) (*SearchResult, error) {
    start := time.Now()

    // Simulate search with channels
    resultCh := make(chan []string, 1)
    errCh := make(chan error, 1)

    go func() {
        // Simulate expensive search operation
        time.Sleep(2 * time.Second)

        // Simulate results
        results := []string{
            fmt.Sprintf("Result 1 for %s", query),
            fmt.Sprintf("Result 2 for %s", query),
            fmt.Sprintf("Result 3 for %s", query),
        }
        resultCh <- results
    }()

    // Wait for result or timeout
    select {
    case results := <-resultCh:
        return &SearchResult{
            Query:   query,
            Results: results,
            Took:    time.Since(start).String(),
        }, nil
    case err := <-errCh:
        return nil, err
    case <-ctx.Done():
        return nil, ctx.Err()
    }
}

// HTTP client with context
func httpDo(ctx context.Context, req *http.Request,
            f func(*http.Response, error) error) error {
    client := &http.Client{}

    ch := make(chan error, 1)
    go func() {
        ch <- f(client.Do(req))
    }()

    select {
    case <-ctx.Done():
        // Wait for f to return
        <-ch
        return ctx.Err()
    case err := <-ch:
        return err
    }
}
```

**Use Case**: Preventing long-running requests, enforcing SLAs, cancellation

**Key Concepts**:
- Context for cancellation and timeouts
- Select statement for multiplexing
- Goroutine coordination with channels

---

## 5. Worker Pool Pattern

Fixed number of workers processing jobs from a queue.

```go
package main

import (
    "fmt"
    "log"
    "sync"
    "time"
)

type Job struct {
    ID   int
    Data string
}

type Result struct {
    Job    Job
    Output string
    Err    error
}

func worker(id int, jobs <-chan Job, results chan<- Result, wg *sync.WaitGroup) {
    defer wg.Done()

    for job := range jobs {
        log.Printf("Worker %d processing job %d", id, job.ID)

        // Simulate work
        time.Sleep(time.Second)

        results <- Result{
            Job:    job,
            Output: fmt.Sprintf("Processed: %s", job.Data),
            Err:    nil,
        }
    }

    log.Printf("Worker %d finished", id)
}

func main() {
    const numWorkers = 3
    const numJobs = 10

    jobs := make(chan Job, numJobs)
    results := make(chan Result, numJobs)

    var wg sync.WaitGroup

    // Start workers
    for w := 1; w <= numWorkers; w++ {
        wg.Add(1)
        go worker(w, jobs, results, &wg)
    }

    // Send jobs
    go func() {
        for j := 1; j <= numJobs; j++ {
            jobs <- Job{
                ID:   j,
                Data: fmt.Sprintf("Job data %d", j),
            }
        }
        close(jobs)
    }()

    // Wait for workers to complete
    go func() {
        wg.Wait()
        close(results)
    }()

    // Collect results
    for result := range results {
        if result.Err != nil {
            log.Printf("Job %d failed: %v", result.Job.ID, result.Err)
        } else {
            log.Printf("Job %d completed: %s", result.Job.ID, result.Output)
        }
    }

    log.Println("All jobs completed")
}
```

**Use Case**: Batch processing, concurrent task execution, resource pooling

**Key Concepts**:
- Fixed worker pool
- Job distribution via channels
- Result collection
- WaitGroup for synchronization

---

## 6. Pipeline Pattern

Multi-stage data processing with channels.

```go
package main

import (
    "fmt"
)

// Stage 1: Generate numbers
func generate(nums ...int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for _, n := range nums {
            out <- n
        }
    }()
    return out
}

// Stage 2: Square numbers
func square(in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for n := range in {
            out <- n * n
        }
    }()
    return out
}

// Stage 3: Filter even numbers
func filterEven(in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for n := range in {
            if n%2 == 0 {
                out <- n
            }
        }
    }()
    return out
}

// Stage 4: Sum numbers
func sum(in <-chan int) int {
    total := 0
    for n := range in {
        total += n
    }
    return total
}

func main() {
    // Build pipeline
    numbers := generate(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
    squared := square(numbers)
    evens := filterEven(squared)
    result := sum(evens)

    fmt.Printf("Result: %d\n", result)
    // Output: 220 (4 + 16 + 36 + 64 + 100)
}

// Pipeline with cancellation
func generateWithDone(done <-chan struct{}, nums ...int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for _, n := range nums {
            select {
            case out <- n:
            case <-done:
                return
            }
        }
    }()
    return out
}

func squareWithDone(done <-chan struct{}, in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for n := range in {
            select {
            case out <- n * n:
            case <-done:
                return
            }
        }
    }()
    return out
}
```

**Use Case**: Data transformation, ETL pipelines, stream processing

**Key Concepts**:
- Pipeline stages as functions returning channels
- Closing channels to signal completion
- Optional cancellation with done channel

---

## 7. Fan-Out/Fan-In Pattern

Distribute work across multiple workers and merge results.

```go
package main

import (
    "fmt"
    "sync"
)

func generate(nums ...int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for _, n := range nums {
            out <- n
        }
    }()
    return out
}

func square(in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for n := range in {
            out <- n * n
        }
    }()
    return out
}

// Merge multiple channels into one (fan-in)
func merge(cs ...<-chan int) <-chan int {
    var wg sync.WaitGroup
    out := make(chan int)

    // Start output goroutine for each input channel
    output := func(c <-chan int) {
        defer wg.Done()
        for n := range c {
            out <- n
        }
    }

    wg.Add(len(cs))
    for _, c := range cs {
        go output(c)
    }

    // Close out once all outputs are done
    go func() {
        wg.Wait()
        close(out)
    }()

    return out
}

func main() {
    in := generate(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

    // Fan out: distribute work across multiple workers
    c1 := square(in)
    c2 := square(in)
    c3 := square(in)

    // Fan in: merge results
    for n := range merge(c1, c2, c3) {
        fmt.Println(n)
    }
}

// Advanced merge with cancellation
func mergeWithDone(done <-chan struct{}, cs ...<-chan int) <-chan int {
    var wg sync.WaitGroup
    out := make(chan int)

    output := func(c <-chan int) {
        defer wg.Done()
        for n := range c {
            select {
            case out <- n:
            case <-done:
                return
            }
        }
    }

    wg.Add(len(cs))
    for _, c := range cs {
        go output(c)
    }

    go func() {
        wg.Wait()
        close(out)
    }()

    return out
}
```

**Use Case**: Parallel processing, load distribution, aggregating results

**Key Concepts**:
- Fan-out: multiple workers reading from same channel
- Fan-in: merging multiple channels into one
- WaitGroup for coordination

---

## 8. Database CRUD Operations

Complete CRUD operations with PostgreSQL.

```go
package main

import (
    "context"
    "database/sql"
    "fmt"
    "log"
    "time"

    _ "github.com/lib/pq"
)

type User struct {
    ID        int
    Name      string
    Email     string
    CreatedAt time.Time
    UpdatedAt time.Time
}

type UserRepository struct {
    db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
    return &UserRepository{db: db}
}

// Create user
func (r *UserRepository) Create(ctx context.Context, user *User) error {
    query := `
        INSERT INTO users (name, email, created_at, updated_at)
        VALUES ($1, $2, NOW(), NOW())
        RETURNING id, created_at, updated_at
    `

    err := r.db.QueryRowContext(ctx, query, user.Name, user.Email).Scan(
        &user.ID,
        &user.CreatedAt,
        &user.UpdatedAt,
    )

    return err
}

// Get user by ID
func (r *UserRepository) GetByID(ctx context.Context, id int) (*User, error) {
    user := &User{}
    query := `
        SELECT id, name, email, created_at, updated_at
        FROM users
        WHERE id = $1
    `

    err := r.db.QueryRowContext(ctx, query, id).Scan(
        &user.ID,
        &user.Name,
        &user.Email,
        &user.CreatedAt,
        &user.UpdatedAt,
    )

    if err == sql.ErrNoRows {
        return nil, fmt.Errorf("user not found")
    }

    return user, err
}

// List all users
func (r *UserRepository) List(ctx context.Context) ([]*User, error) {
    query := `
        SELECT id, name, email, created_at, updated_at
        FROM users
        ORDER BY created_at DESC
    `

    rows, err := r.db.QueryContext(ctx, query)
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    var users []*User
    for rows.Next() {
        user := &User{}
        if err := rows.Scan(&user.ID, &user.Name, &user.Email,
            &user.CreatedAt, &user.UpdatedAt); err != nil {
            return nil, err
        }
        users = append(users, user)
    }

    return users, rows.Err()
}

// Update user
func (r *UserRepository) Update(ctx context.Context, user *User) error {
    query := `
        UPDATE users
        SET name = $1, email = $2, updated_at = NOW()
        WHERE id = $3
        RETURNING updated_at
    `

    err := r.db.QueryRowContext(ctx, query, user.Name, user.Email, user.ID).Scan(
        &user.UpdatedAt,
    )

    return err
}

// Delete user
func (r *UserRepository) Delete(ctx context.Context, id int) error {
    query := `DELETE FROM users WHERE id = $1`
    result, err := r.db.ExecContext(ctx, query, id)
    if err != nil {
        return err
    }

    rows, err := result.RowsAffected()
    if err != nil {
        return err
    }

    if rows == 0 {
        return fmt.Errorf("user not found")
    }

    return nil
}

func main() {
    // Connect to database
    connStr := "host=localhost port=5432 user=postgres password=secret dbname=mydb sslmode=disable"
    db, err := sql.Open("postgres", connStr)
    if err != nil {
        log.Fatal(err)
    }
    defer db.Close()

    // Configure connection pool
    db.SetMaxOpenConns(25)
    db.SetMaxIdleConns(5)
    db.SetConnMaxLifetime(5 * time.Minute)

    // Ping database
    if err := db.Ping(); err != nil {
        log.Fatal(err)
    }

    repo := NewUserRepository(db)
    ctx := context.Background()

    // Create user
    user := &User{
        Name:  "John Doe",
        Email: "john@example.com",
    }

    if err := repo.Create(ctx, user); err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Created user: %+v\n", user)

    // Get user
    found, err := repo.GetByID(ctx, user.ID)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Found user: %+v\n", found)

    // List users
    users, err := repo.List(ctx)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Total users: %d\n", len(users))

    // Update user
    user.Name = "Jane Doe"
    if err := repo.Update(ctx, user); err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Updated user: %+v\n", user)

    // Delete user
    if err := repo.Delete(ctx, user.ID); err != nil {
        log.Fatal(err)
    }
    fmt.Println("User deleted")
}
```

**Use Case**: Database-backed applications, data persistence, repository pattern

**Key Concepts**:
- Connection pooling
- Context for cancellation
- Prepared statements
- Error handling for no rows

---

## 9. Transaction Handling

Managing database transactions with rollback.

```go
package main

import (
    "context"
    "database/sql"
    "fmt"
    "log"

    _ "github.com/lib/pq"
)

type TransferService struct {
    db *sql.DB
}

func NewTransferService(db *sql.DB) *TransferService {
    return &TransferService{db: db}
}

// Transfer funds between accounts
func (s *TransferService) Transfer(ctx context.Context, fromID, toID int, amount float64) error {
    // Start transaction
    tx, err := s.db.BeginTx(ctx, nil)
    if err != nil {
        return fmt.Errorf("begin transaction: %w", err)
    }

    // Defer rollback - will be no-op if commit succeeds
    defer tx.Rollback()

    // Debit from account
    var balance float64
    err = tx.QueryRowContext(ctx,
        "SELECT balance FROM accounts WHERE id = $1 FOR UPDATE",
        fromID).Scan(&balance)
    if err != nil {
        return fmt.Errorf("get from account: %w", err)
    }

    if balance < amount {
        return fmt.Errorf("insufficient funds")
    }

    _, err = tx.ExecContext(ctx,
        "UPDATE accounts SET balance = balance - $1 WHERE id = $2",
        amount, fromID)
    if err != nil {
        return fmt.Errorf("debit account: %w", err)
    }

    // Credit to account
    _, err = tx.ExecContext(ctx,
        "UPDATE accounts SET balance = balance + $1 WHERE id = $2",
        amount, toID)
    if err != nil {
        return fmt.Errorf("credit account: %w", err)
    }

    // Record transaction
    _, err = tx.ExecContext(ctx,
        `INSERT INTO transactions (from_account, to_account, amount, created_at)
         VALUES ($1, $2, $3, NOW())`,
        fromID, toID, amount)
    if err != nil {
        return fmt.Errorf("record transaction: %w", err)
    }

    // Commit transaction
    if err := tx.Commit(); err != nil {
        return fmt.Errorf("commit transaction: %w", err)
    }

    return nil
}

// Batch insert with transaction
func (s *TransferService) BatchInsert(ctx context.Context, users []User) error {
    tx, err := s.db.BeginTx(ctx, nil)
    if err != nil {
        return err
    }
    defer tx.Rollback()

    stmt, err := tx.PrepareContext(ctx,
        "INSERT INTO users (name, email) VALUES ($1, $2)")
    if err != nil {
        return err
    }
    defer stmt.Close()

    for _, user := range users {
        if _, err := stmt.ExecContext(ctx, user.Name, user.Email); err != nil {
            return err  // Triggers rollback
        }
    }

    return tx.Commit()
}

func main() {
    db, err := sql.Open("postgres", "...")
    if err != nil {
        log.Fatal(err)
    }
    defer db.Close()

    service := NewTransferService(db)
    ctx := context.Background()

    // Transfer $100 from account 1 to account 2
    err = service.Transfer(ctx, 1, 2, 100.00)
    if err != nil {
        log.Printf("Transfer failed: %v", err)
    } else {
        log.Println("Transfer successful")
    }
}
```

**Use Case**: Financial transactions, atomic operations, data consistency

**Key Concepts**:
- Transaction lifecycle (Begin, Commit, Rollback)
- Deferred rollback for safety
- Row locking with `FOR UPDATE`
- Error wrapping for context

---

## 10. Graceful Shutdown

Properly shutting down HTTP server and cleaning up resources.

```go
package main

import (
    "context"
    "log"
    "net/http"
    "os"
    "os/signal"
    "syscall"
    "time"
)

func main() {
    // Create server
    srv := &http.Server{
        Addr:         ":8080",
        Handler:      setupRoutes(),
        ReadTimeout:  15 * time.Second,
        WriteTimeout: 15 * time.Second,
        IdleTimeout:  60 * time.Second,
    }

    // Start server in goroutine
    go func() {
        log.Println("Server starting on :8080")
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatalf("Server failed to start: %v", err)
        }
    }()

    // Wait for interrupt signal
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    log.Println("Server is shutting down...")

    // Create shutdown context with timeout
    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()

    // Attempt graceful shutdown
    if err := srv.Shutdown(ctx); err != nil {
        log.Fatalf("Server forced to shutdown: %v", err)
    }

    log.Println("Server exited gracefully")
}

func setupRoutes() http.Handler {
    mux := http.NewServeMux()

    mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        // Simulate long request
        time.Sleep(2 * time.Second)
        w.Write([]byte("Hello, World!"))
    })

    return mux
}

// Complete shutdown example with cleanup
type Application struct {
    server *http.Server
    db     *sql.DB
    logger *log.Logger
}

func (app *Application) Shutdown(ctx context.Context) error {
    app.logger.Println("Starting shutdown sequence...")

    // Shutdown HTTP server
    if err := app.server.Shutdown(ctx); err != nil {
        return fmt.Errorf("http server shutdown: %w", err)
    }
    app.logger.Println("HTTP server stopped")

    // Close database connections
    if err := app.db.Close(); err != nil {
        return fmt.Errorf("database close: %w", err)
    }
    app.logger.Println("Database connections closed")

    // Perform other cleanup tasks
    // - Flush metrics
    // - Close message queues
    // - Save state

    app.logger.Println("Shutdown complete")
    return nil
}
```

**Use Case**: Production deployments, zero-downtime deploys, resource cleanup

**Key Concepts**:
- Signal handling for interrupts
- Graceful HTTP server shutdown
- Timeout for shutdown operations
- Resource cleanup sequence

---

## 11. Rate Limiting

Implementing rate limiting middleware.

```go
package main

import (
    "net/http"
    "sync"
    "time"

    "golang.org/x/time/rate"
)

// Simple rate limiter using golang.org/x/time/rate
func rateLimitMiddleware(limiter *rate.Limiter) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            if !limiter.Allow() {
                http.Error(w, "Too Many Requests", http.StatusTooManyRequests)
                return
            }
            next.ServeHTTP(w, r)
        })
    }
}

// Per-IP rate limiter
type IPRateLimiter struct {
    limiters map[string]*rate.Limiter
    mu       sync.RWMutex
    rate     rate.Limit
    burst    int
}

func NewIPRateLimiter(r rate.Limit, b int) *IPRateLimiter {
    return &IPRateLimiter{
        limiters: make(map[string]*rate.Limiter),
        rate:     r,
        burst:    b,
    }
}

func (i *IPRateLimiter) GetLimiter(ip string) *rate.Limiter {
    i.mu.Lock()
    defer i.mu.Unlock()

    limiter, exists := i.limiters[ip]
    if !exists {
        limiter = rate.NewLimiter(i.rate, i.burst)
        i.limiters[ip] = limiter
    }

    return limiter
}

func (i *IPRateLimiter) Middleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        ip := r.RemoteAddr
        limiter := i.GetLimiter(ip)

        if !limiter.Allow() {
            http.Error(w, "Too Many Requests", http.StatusTooManyRequests)
            return
        }

        next.ServeHTTP(w, r)
    })
}

// Cleanup old limiters
func (i *IPRateLimiter) CleanupOldLimiters() {
    ticker := time.NewTicker(5 * time.Minute)
    defer ticker.Stop()

    for range ticker.C {
        i.mu.Lock()
        for ip, limiter := range i.limiters {
            if limiter.Tokens() == float64(i.burst) {
                delete(i.limiters, ip)
            }
        }
        i.mu.Unlock()
    }
}

func main() {
    // Global rate limiter: 10 req/sec, burst 20
    globalLimiter := rate.NewLimiter(10, 20)

    // Per-IP rate limiter: 5 req/sec per IP, burst 10
    ipLimiter := NewIPRateLimiter(5, 10)
    go ipLimiter.CleanupOldLimiters()

    handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte("Success!"))
    })

    // Apply rate limiting
    http.Handle("/api/",
        rateLimitMiddleware(globalLimiter)(
            ipLimiter.Middleware(handler)))

    log.Fatal(http.ListenAndServe(":8080", nil))
}
```

**Use Case**: API protection, preventing abuse, enforcing quotas

**Key Concepts**:
- Token bucket algorithm
- Per-IP rate limiting
- Limiter cleanup
- Middleware pattern

---

## 12. Circuit Breaker

Preventing cascading failures with circuit breaker pattern.

```go
package main

import (
    "errors"
    "fmt"
    "sync"
    "time"
)

type State int

const (
    StateClosed State = iota
    StateOpen
    StateHalfOpen
)

type CircuitBreaker struct {
    maxFailures  int
    timeout      time.Duration
    failures     int
    lastFailTime time.Time
    state        State
    mu           sync.Mutex
}

func NewCircuitBreaker(maxFailures int, timeout time.Duration) *CircuitBreaker {
    return &CircuitBreaker{
        maxFailures: maxFailures,
        timeout:     timeout,
        state:       StateClosed,
    }
}

var ErrCircuitOpen = errors.New("circuit breaker is open")

func (cb *CircuitBreaker) Call(fn func() error) error {
    cb.mu.Lock()

    // Check if we should transition to half-open
    if cb.state == StateOpen {
        if time.Since(cb.lastFailTime) > cb.timeout {
            cb.state = StateHalfOpen
            fmt.Println("Circuit breaker: Transitioning to half-open")
        } else {
            cb.mu.Unlock()
            return ErrCircuitOpen
        }
    }

    cb.mu.Unlock()

    // Execute function
    err := fn()

    cb.mu.Lock()
    defer cb.mu.Unlock()

    if err != nil {
        cb.failures++
        cb.lastFailTime = time.Now()

        if cb.failures >= cb.maxFailures {
            cb.state = StateOpen
            fmt.Println("Circuit breaker: Opening circuit")
        }

        return err
    }

    // Success - reset failures
    if cb.state == StateHalfOpen {
        cb.state = StateClosed
        fmt.Println("Circuit breaker: Closing circuit")
    }

    cb.failures = 0
    return nil
}

func (cb *CircuitBreaker) State() State {
    cb.mu.Lock()
    defer cb.mu.Unlock()
    return cb.state
}

// Example usage
func main() {
    cb := NewCircuitBreaker(3, 5*time.Second)

    // Simulated unreliable service
    callCount := 0
    unreliableService := func() error {
        callCount++
        if callCount <= 5 {
            return errors.New("service unavailable")
        }
        return nil
    }

    // Make calls
    for i := 0; i < 10; i++ {
        err := cb.Call(unreliableService)
        if err != nil {
            fmt.Printf("Call %d failed: %v (state: %v)\n", i+1, err, cb.State())
        } else {
            fmt.Printf("Call %d succeeded (state: %v)\n", i+1, cb.State())
        }

        time.Sleep(1 * time.Second)
    }
}
```

**Use Case**: Microservices resilience, preventing cascading failures

**Key Concepts**:
- Three states: Closed, Open, Half-Open
- Failure counting
- Timeout-based recovery
- State transitions

---

## 13. WebSocket Server

Real-time bidirectional communication with WebSockets.

```go
package main

import (
    "log"
    "net/http"
    "sync"

    "github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
    CheckOrigin: func(r *http.Request) bool {
        return true  // Allow all origins in development
    },
}

type Client struct {
    conn *websocket.Conn
    send chan []byte
}

type Hub struct {
    clients    map[*Client]bool
    broadcast  chan []byte
    register   chan *Client
    unregister chan *Client
    mu         sync.RWMutex
}

func NewHub() *Hub {
    return &Hub{
        clients:    make(map[*Client]bool),
        broadcast:  make(chan []byte),
        register:   make(chan *Client),
        unregister: make(chan *Client),
    }
}

func (h *Hub) Run() {
    for {
        select {
        case client := <-h.register:
            h.mu.Lock()
            h.clients[client] = true
            h.mu.Unlock()
            log.Printf("Client connected. Total: %d", len(h.clients))

        case client := <-h.unregister:
            h.mu.Lock()
            if _, ok := h.clients[client]; ok {
                delete(h.clients, client)
                close(client.send)
            }
            h.mu.Unlock()
            log.Printf("Client disconnected. Total: %d", len(h.clients))

        case message := <-h.broadcast:
            h.mu.RLock()
            for client := range h.clients {
                select {
                case client.send <- message:
                default:
                    close(client.send)
                    delete(h.clients, client)
                }
            }
            h.mu.RUnlock()
        }
    }
}

func (c *Client) readPump(hub *Hub) {
    defer func() {
        hub.unregister <- c
        c.conn.Close()
    }()

    for {
        _, message, err := c.conn.ReadMessage()
        if err != nil {
            if websocket.IsUnexpectedCloseError(err,
                websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
                log.Printf("error: %v", err)
            }
            break
        }

        log.Printf("Received: %s", message)
        hub.broadcast <- message
    }
}

func (c *Client) writePump() {
    defer c.conn.Close()

    for message := range c.send {
        if err := c.conn.WriteMessage(websocket.TextMessage, message); err != nil {
            return
        }
    }
}

func serveWs(hub *Hub, w http.ResponseWriter, r *http.Request) {
    conn, err := upgrader.Upgrade(w, r, nil)
    if err != nil {
        log.Println(err)
        return
    }

    client := &Client{
        conn: conn,
        send: make(chan []byte, 256),
    }

    hub.register <- client

    go client.writePump()
    go client.readPump(hub)
}

func main() {
    hub := NewHub()
    go hub.Run()

    http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
        serveWs(hub, w, r)
    })

    log.Println("WebSocket server starting on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}
```

**Use Case**: Chat applications, real-time dashboards, live notifications

**Key Concepts**:
- WebSocket upgrade
- Hub pattern for broadcasting
- Read/write pumps
- Client management

---

## 14. gRPC Service

Building gRPC services for efficient microservice communication.

```proto
// user.proto
syntax = "proto3";

package user;

option go_package = "github.com/example/user/pb";

service UserService {
  rpc GetUser(GetUserRequest) returns (User);
  rpc CreateUser(CreateUserRequest) returns (User);
  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse);
}

message User {
  int32 id = 1;
  string name = 2;
  string email = 3;
}

message GetUserRequest {
  int32 id = 1;
}

message CreateUserRequest {
  string name = 1;
  string email = 2;
}

message ListUsersRequest {
  int32 limit = 1;
  int32 offset = 2;
}

message ListUsersResponse {
  repeated User users = 1;
}
```

```go
// server.go
package main

import (
    "context"
    "database/sql"
    "log"
    "net"

    pb "github.com/example/user/pb"
    "google.golang.org/grpc"
    "google.golang.org/grpc/codes"
    "google.golang.org/grpc/status"
)

type server struct {
    pb.UnimplementedUserServiceServer
    db *sql.DB
}

func (s *server) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.User, error) {
    user := &pb.User{}

    err := s.db.QueryRowContext(ctx,
        "SELECT id, name, email FROM users WHERE id = $1",
        req.GetId(),
    ).Scan(&user.Id, &user.Name, &user.Email)

    if err == sql.ErrNoRows {
        return nil, status.Errorf(codes.NotFound, "user not found")
    }
    if err != nil {
        return nil, status.Errorf(codes.Internal, "database error")
    }

    return user, nil
}

func (s *server) CreateUser(ctx context.Context, req *pb.CreateUserRequest) (*pb.User, error) {
    user := &pb.User{
        Name:  req.GetName(),
        Email: req.GetEmail(),
    }

    err := s.db.QueryRowContext(ctx,
        "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id",
        user.Name, user.Email,
    ).Scan(&user.Id)

    if err != nil {
        return nil, status.Errorf(codes.Internal, "failed to create user")
    }

    return user, nil
}

func (s *server) ListUsers(ctx context.Context, req *pb.ListUsersRequest) (*pb.ListUsersResponse, error) {
    rows, err := s.db.QueryContext(ctx,
        "SELECT id, name, email FROM users LIMIT $1 OFFSET $2",
        req.GetLimit(), req.GetOffset())
    if err != nil {
        return nil, status.Errorf(codes.Internal, "database error")
    }
    defer rows.Close()

    var users []*pb.User
    for rows.Next() {
        user := &pb.User{}
        if err := rows.Scan(&user.Id, &user.Name, &user.Email); err != nil {
            return nil, status.Errorf(codes.Internal, "scan error")
        }
        users = append(users, user)
    }

    return &pb.ListUsersResponse{Users: users}, nil
}

func main() {
    lis, err := net.Listen("tcp", ":50051")
    if err != nil {
        log.Fatalf("failed to listen: %v", err)
    }

    db, err := sql.Open("postgres", "...")
    if err != nil {
        log.Fatalf("failed to connect to database: %v", err)
    }
    defer db.Close()

    s := grpc.NewServer()
    pb.RegisterUserServiceServer(s, &server{db: db})

    log.Println("gRPC server listening on :50051")
    if err := s.Serve(lis); err != nil {
        log.Fatalf("failed to serve: %v", err)
    }
}
```

**Use Case**: Microservices, efficient service-to-service communication

**Key Concepts**:
- Protocol Buffers for serialization
- Strongly-typed service contracts
- Error codes and status
- Efficient binary protocol

---

## 15. Caching Layer

Implementing caching with Redis.

```go
package main

import (
    "context"
    "database/sql"
    "encoding/json"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
)

type CachedUserRepository struct {
    db    *sql.DB
    cache *redis.Client
    ttl   time.Duration
}

func NewCachedUserRepository(db *sql.DB, cache *redis.Client) *CachedUserRepository {
    return &CachedUserRepository{
        db:    db,
        cache: cache,
        ttl:   5 * time.Minute,
    }
}

func (r *CachedUserRepository) GetUser(ctx context.Context, id int) (*User, error) {
    cacheKey := fmt.Sprintf("user:%d", id)

    // Try cache first
    cached, err := r.cache.Get(ctx, cacheKey).Result()
    if err == nil {
        var user User
        if err := json.Unmarshal([]byte(cached), &user); err == nil {
            return &user, nil
        }
    }

    // Cache miss - query database
    user, err := r.getUserFromDB(ctx, id)
    if err != nil {
        return nil, err
    }

    // Update cache (don't fail on cache error)
    go r.cacheUser(context.Background(), cacheKey, user)

    return user, nil
}

func (r *CachedUserRepository) getUserFromDB(ctx context.Context, id int) (*User, error) {
    user := &User{}
    err := r.db.QueryRowContext(ctx,
        "SELECT id, name, email FROM users WHERE id = $1",
        id).Scan(&user.ID, &user.Name, &user.Email)

    if err == sql.ErrNoRows {
        return nil, fmt.Errorf("user not found")
    }

    return user, err
}

func (r *CachedUserRepository) cacheUser(ctx context.Context, key string, user *User) {
    data, err := json.Marshal(user)
    if err != nil {
        return
    }

    r.cache.Set(ctx, key, data, r.ttl)
}

func (r *CachedUserRepository) UpdateUser(ctx context.Context, user *User) error {
    // Update database
    _, err := r.db.ExecContext(ctx,
        "UPDATE users SET name = $1, email = $2 WHERE id = $3",
        user.Name, user.Email, user.ID)
    if err != nil {
        return err
    }

    // Invalidate cache
    cacheKey := fmt.Sprintf("user:%d", user.ID)
    r.cache.Del(ctx, cacheKey)

    return nil
}

// Cache-aside pattern with loader function
func (r *CachedUserRepository) GetOrLoad(ctx context.Context, id int,
    loader func(context.Context, int) (*User, error)) (*User, error) {

    cacheKey := fmt.Sprintf("user:%d", id)

    // Try cache
    cached, err := r.cache.Get(ctx, cacheKey).Result()
    if err == nil {
        var user User
        if err := json.Unmarshal([]byte(cached), &user); err == nil {
            return &user, nil
        }
    }

    // Load from source
    user, err := loader(ctx, id)
    if err != nil {
        return nil, err
    }

    // Cache result
    go r.cacheUser(context.Background(), cacheKey, user)

    return user, nil
}

func main() {
    // Database connection
    db, err := sql.Open("postgres", "...")
    if err != nil {
        log.Fatal(err)
    }
    defer db.Close()

    // Redis connection
    cache := redis.NewClient(&redis.Options{
        Addr: "localhost:6379",
    })
    defer cache.Close()

    repo := NewCachedUserRepository(db, cache)
    ctx := context.Background()

    // Get user (cached)
    user, err := repo.GetUser(ctx, 1)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("User: %+v\n", user)
}
```

**Use Case**: Performance optimization, reducing database load

**Key Concepts**:
- Cache-aside pattern
- TTL for cache expiration
- Cache invalidation on updates
- Async cache population

---

## 16. Event-Driven Architecture

Publishing and consuming events with message queue.

```go
package main

import (
    "context"
    "encoding/json"
    "log"
    "time"

    "github.com/streadway/amqp"
)

type Event struct {
    Type      string                 `json:"type"`
    Timestamp time.Time              `json:"timestamp"`
    Data      map[string]interface{} `json:"data"`
}

type EventPublisher struct {
    conn    *amqp.Connection
    channel *amqp.Channel
}

func NewEventPublisher(url string) (*EventPublisher, error) {
    conn, err := amqp.Dial(url)
    if err != nil {
        return nil, err
    }

    channel, err := conn.Channel()
    if err != nil {
        return nil, err
    }

    // Declare exchange
    err = channel.ExchangeDeclare(
        "events",  // name
        "topic",   // type
        true,      // durable
        false,     // auto-deleted
        false,     // internal
        false,     // no-wait
        nil,       // arguments
    )
    if err != nil {
        return nil, err
    }

    return &EventPublisher{conn: conn, channel: channel}, nil
}

func (p *EventPublisher) Publish(ctx context.Context, event *Event) error {
    event.Timestamp = time.Now()

    body, err := json.Marshal(event)
    if err != nil {
        return err
    }

    return p.channel.PublishWithContext(
        ctx,
        "events",     // exchange
        event.Type,   // routing key
        false,        // mandatory
        false,        // immediate
        amqp.Publishing{
            ContentType: "application/json",
            Body:        body,
        },
    )
}

func (p *EventPublisher) Close() {
    p.channel.Close()
    p.conn.Close()
}

type EventHandler func(Event) error

type EventConsumer struct {
    conn     *amqp.Connection
    channel  *amqp.Channel
    handlers map[string]EventHandler
}

func NewEventConsumer(url string) (*EventConsumer, error) {
    conn, err := amqp.Dial(url)
    if err != nil {
        return nil, err
    }

    channel, err := conn.Channel()
    if err != nil {
        return nil, err
    }

    return &EventConsumer{
        conn:     conn,
        channel:  channel,
        handlers: make(map[string]EventHandler),
    }, nil
}

func (c *EventConsumer) Subscribe(eventType string, handler EventHandler) error {
    c.handlers[eventType] = handler

    // Declare queue
    q, err := c.channel.QueueDeclare(
        "",    // name (auto-generated)
        false, // durable
        false, // delete when unused
        true,  // exclusive
        false, // no-wait
        nil,   // arguments
    )
    if err != nil {
        return err
    }

    // Bind queue to exchange
    err = c.channel.QueueBind(
        q.Name,     // queue name
        eventType,  // routing key
        "events",   // exchange
        false,      // no-wait
        nil,        // arguments
    )
    if err != nil {
        return err
    }

    return nil
}

func (c *EventConsumer) Start(ctx context.Context) error {
    msgs, err := c.channel.Consume(
        "",    // queue (will use bound queue)
        "",    // consumer
        true,  // auto-ack
        false, // exclusive
        false, // no-local
        false, // no-wait
        nil,   // args
    )
    if err != nil {
        return err
    }

    go func() {
        for {
            select {
            case msg := <-msgs:
                var event Event
                if err := json.Unmarshal(msg.Body, &event); err != nil {
                    log.Printf("Failed to unmarshal event: %v", err)
                    continue
                }

                if handler, ok := c.handlers[event.Type]; ok {
                    if err := handler(event); err != nil {
                        log.Printf("Handler error: %v", err)
                    }
                }

            case <-ctx.Done():
                return
            }
        }
    }()

    return nil
}

func (c *EventConsumer) Close() {
    c.channel.Close()
    c.conn.Close()
}

func main() {
    // Publisher
    publisher, err := NewEventPublisher("amqp://guest:guest@localhost:5672/")
    if err != nil {
        log.Fatal(err)
    }
    defer publisher.Close()

    // Publish event
    err = publisher.Publish(context.Background(), &Event{
        Type: "user.created",
        Data: map[string]interface{}{
            "user_id": 123,
            "email":   "user@example.com",
        },
    })
    if err != nil {
        log.Fatal(err)
    }

    // Consumer
    consumer, err := NewEventConsumer("amqp://guest:guest@localhost:5672/")
    if err != nil {
        log.Fatal(err)
    }
    defer consumer.Close()

    // Subscribe to events
    consumer.Subscribe("user.created", func(event Event) error {
        log.Printf("User created: %+v", event.Data)
        return nil
    })

    // Start consuming
    ctx := context.Background()
    consumer.Start(ctx)

    // Keep running
    select {}
}
```

**Use Case**: Decoupled microservices, async processing, event sourcing

**Key Concepts**:
- Publish-subscribe pattern
- Event routing with topics
- Async event processing
- Decoupled services

---

## 17. File Upload Handler

Handling multipart file uploads.

```go
package main

import (
    "crypto/md5"
    "encoding/hex"
    "fmt"
    "io"
    "log"
    "net/http"
    "os"
    "path/filepath"
)

const (
    maxUploadSize = 10 * 1024 * 1024 // 10 MB
    uploadPath    = "./uploads"
)

func handleFileUpload(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodPost {
        http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
        return
    }

    // Limit request body size
    r.Body = http.MaxBytesReader(w, r.Body, maxUploadSize)

    // Parse multipart form
    if err := r.ParseMultipartForm(maxUploadSize); err != nil {
        http.Error(w, "File too large", http.StatusBadRequest)
        return
    }

    // Get file from form
    file, fileHeader, err := r.FormFile("file")
    if err != nil {
        http.Error(w, "Failed to get file", http.StatusBadRequest)
        return
    }
    defer file.Close()

    // Validate file type
    buffer := make([]byte, 512)
    if _, err := file.Read(buffer); err != nil {
        http.Error(w, "Failed to read file", http.StatusInternalServerError)
        return
    }

    contentType := http.DetectContentType(buffer)
    if contentType != "image/jpeg" && contentType != "image/png" {
        http.Error(w, "Invalid file type", http.StatusBadRequest)
        return
    }

    // Reset file pointer
    file.Seek(0, 0)

    // Generate unique filename
    hash := md5.New()
    if _, err := io.Copy(hash, file); err != nil {
        http.Error(w, "Failed to process file", http.StatusInternalServerError)
        return
    }
    hashInBytes := hash.Sum(nil)[:16]
    filename := hex.EncodeToString(hashInBytes) + filepath.Ext(fileHeader.Filename)

    // Reset file pointer again
    file.Seek(0, 0)

    // Create upload directory
    os.MkdirAll(uploadPath, os.ModePerm)

    // Create destination file
    dst, err := os.Create(filepath.Join(uploadPath, filename))
    if err != nil {
        http.Error(w, "Failed to create file", http.StatusInternalServerError)
        return
    }
    defer dst.Close()

    // Copy file content
    if _, err := io.Copy(dst, file); err != nil {
        http.Error(w, "Failed to save file", http.StatusInternalServerError)
        return
    }

    // Return success response
    w.WriteHeader(http.StatusCreated)
    fmt.Fprintf(w, `{"filename": "%s", "size": %d}`, filename, fileHeader.Size)
}

// Multiple file upload
func handleMultipleFileUpload(w http.ResponseWriter, r *http.Request) {
    if err := r.ParseMultipartForm(maxUploadSize); err != nil {
        http.Error(w, "Failed to parse form", http.StatusBadRequest)
        return
    }

    files := r.MultipartForm.File["files"]
    var uploadedFiles []string

    for _, fileHeader := range files {
        file, err := fileHeader.Open()
        if err != nil {
            continue
        }
        defer file.Close()

        // Process each file...
        filename := fileHeader.Filename
        uploadedFiles = append(uploadedFiles, filename)
    }

    fmt.Fprintf(w, `{"uploaded": %d, "files": %v}`, len(uploadedFiles), uploadedFiles)
}

func main() {
    http.HandleFunc("/upload", handleFileUpload)
    http.HandleFunc("/upload-multiple", handleMultipleFileUpload)

    log.Println("Server starting on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}
```

**Use Case**: File upload APIs, image processing, document management

**Key Concepts**:
- Multipart form parsing
- File size limits
- Content type validation
- Unique filename generation

---

## 18. Authentication Middleware

JWT-based authentication middleware.

```go
package main

import (
    "context"
    "fmt"
    "net/http"
    "strings"
    "time"

    "github.com/golang-jwt/jwt/v5"
)

var jwtSecret = []byte("your-secret-key")

type Claims struct {
    UserID int    `json:"user_id"`
    Email  string `json:"email"`
    jwt.RegisteredClaims
}

func generateToken(userID int, email string) (string, error) {
    claims := Claims{
        UserID: userID,
        Email:  email,
        RegisteredClaims: jwt.RegisteredClaims{
            ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
            IssuedAt:  jwt.NewNumericDate(time.Now()),
        },
    }

    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    return token.SignedString(jwtSecret)
}

func validateToken(tokenString string) (*Claims, error) {
    token, err := jwt.ParseWithClaims(tokenString, &Claims{},
        func(token *jwt.Token) (interface{}, error) {
            if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
                return nil, fmt.Errorf("unexpected signing method")
            }
            return jwtSecret, nil
        })

    if err != nil {
        return nil, err
    }

    if claims, ok := token.Claims.(*Claims); ok && token.Valid {
        return claims, nil
    }

    return nil, fmt.Errorf("invalid token")
}

type contextKey string

const userContextKey contextKey = "user"

func authMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // Get token from Authorization header
        authHeader := r.Header.Get("Authorization")
        if authHeader == "" {
            http.Error(w, "Missing authorization header", http.StatusUnauthorized)
            return
        }

        // Extract token
        parts := strings.Split(authHeader, " ")
        if len(parts) != 2 || parts[0] != "Bearer" {
            http.Error(w, "Invalid authorization header", http.StatusUnauthorized)
            return
        }

        tokenString := parts[1]

        // Validate token
        claims, err := validateToken(tokenString)
        if err != nil {
            http.Error(w, "Invalid token", http.StatusUnauthorized)
            return
        }

        // Add claims to context
        ctx := context.WithValue(r.Context(), userContextKey, claims)
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}

func getUserFromContext(ctx context.Context) (*Claims, bool) {
    claims, ok := ctx.Value(userContextKey).(*Claims)
    return claims, ok
}

// Handler example
func protectedHandler(w http.ResponseWriter, r *http.Request) {
    claims, ok := getUserFromContext(r.Context())
    if !ok {
        http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

    fmt.Fprintf(w, "Hello, %s (ID: %d)", claims.Email, claims.UserID)
}

// Login handler
func loginHandler(w http.ResponseWriter, r *http.Request) {
    var creds struct {
        Email    string `json:"email"`
        Password string `json:"password"`
    }

    if err := json.NewDecoder(r.Body).Decode(&creds); err != nil {
        http.Error(w, "Invalid request", http.StatusBadRequest)
        return
    }

    // Validate credentials (simplified)
    userID := 123  // Get from database

    // Generate token
    token, err := generateToken(userID, creds.Email)
    if err != nil {
        http.Error(w, "Failed to generate token", http.StatusInternalServerError)
        return
    }

    json.NewEncoder(w).Encode(map[string]string{
        "token": token,
    })
}

func main() {
    http.HandleFunc("/login", loginHandler)
    http.Handle("/protected", authMiddleware(http.HandlerFunc(protectedHandler)))

    log.Fatal(http.ListenAndServe(":8080", nil))
}
```

**Use Case**: API authentication, user sessions, access control

**Key Concepts**:
- JWT token generation and validation
- Authorization header parsing
- Context for user information
- Middleware pattern

---

## 19. Structured Logging

Production-ready structured logging with slog.

```go
package main

import (
    "context"
    "log/slog"
    "net/http"
    "os"
    "time"
)

// Setup logger
func setupLogger() *slog.Logger {
    return slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
        Level: slog.LevelInfo,
    }))
}

// Request logging middleware
func loggingMiddleware(logger *slog.Logger) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            start := time.Now()

            // Create logger with request context
            reqLogger := logger.With(
                "method", r.Method,
                "path", r.URL.Path,
                "remote_addr", r.RemoteAddr,
                "user_agent", r.UserAgent(),
            )

            // Add logger to context
            ctx := context.WithValue(r.Context(), "logger", reqLogger)

            // Wrap response writer to capture status
            rw := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}

            // Log request
            reqLogger.Info("request started")

            // Process request
            next.ServeHTTP(rw, r.WithContext(ctx))

            // Log response
            reqLogger.Info("request completed",
                "status", rw.statusCode,
                "duration", time.Since(start).String(),
            )
        })
    }
}

type responseWriter struct {
    http.ResponseWriter
    statusCode int
}

func (rw *responseWriter) WriteHeader(code int) {
    rw.statusCode = code
    rw.ResponseWriter.WriteHeader(code)
}

// Get logger from context
func getLogger(ctx context.Context) *slog.Logger {
    if logger, ok := ctx.Value("logger").(*slog.Logger); ok {
        return logger
    }
    return slog.Default()
}

// Example handler
func handleAPI(w http.ResponseWriter, r *http.Request) {
    logger := getLogger(r.Context())

    logger.Info("processing API request",
        "query", r.URL.Query().Get("q"),
    )

    // Simulate work
    time.Sleep(100 * time.Millisecond)

    logger.Info("API request processed successfully")

    w.WriteHeader(http.StatusOK)
    w.Write([]byte(`{"status": "success"}`))
}

// Error logging example
func handleError(w http.ResponseWriter, r *http.Request) {
    logger := getLogger(r.Context())

    // Simulate error
    err := fmt.Errorf("database connection failed")

    logger.Error("operation failed",
        "error", err.Error(),
        "operation", "fetch_user",
        "user_id", 123,
    )

    http.Error(w, "Internal Server Error", http.StatusInternalServerError)
}

func main() {
    logger := setupLogger()

    mux := http.NewServeMux()
    mux.HandleFunc("/api", handleAPI)
    mux.HandleFunc("/error", handleError)

    handler := loggingMiddleware(logger)(mux)

    logger.Info("server starting", "port", 8080)
    log.Fatal(http.ListenAndServe(":8080", handler))
}
```

**Use Case**: Production logging, debugging, monitoring

**Key Concepts**:
- Structured logging with slog
- Context-aware logging
- Request/response logging
- JSON output for log aggregation

---

## 20. Health Check System

Comprehensive health check endpoint.

```go
package main

import (
    "context"
    "database/sql"
    "encoding/json"
    "net/http"
    "sync"
    "time"

    "github.com/redis/go-redis/v9"
)

type HealthStatus string

const (
    StatusHealthy   HealthStatus = "healthy"
    StatusDegraded  HealthStatus = "degraded"
    StatusUnhealthy HealthStatus = "unhealthy"
)

type ComponentHealth struct {
    Status  HealthStatus `json:"status"`
    Message string       `json:"message,omitempty"`
    Latency string       `json:"latency,omitempty"`
}

type HealthResponse struct {
    Status     HealthStatus               `json:"status"`
    Timestamp  time.Time                  `json:"timestamp"`
    Components map[string]ComponentHealth `json:"components"`
}

type HealthChecker struct {
    db    *sql.DB
    cache *redis.Client
}

func NewHealthChecker(db *sql.DB, cache *redis.Client) *HealthChecker {
    return &HealthChecker{db: db, cache: cache}
}

func (h *HealthChecker) checkDatabase(ctx context.Context) ComponentHealth {
    start := time.Now()

    err := h.db.PingContext(ctx)
    latency := time.Since(start)

    if err != nil {
        return ComponentHealth{
            Status:  StatusUnhealthy,
            Message: err.Error(),
            Latency: latency.String(),
        }
    }

    if latency > 1*time.Second {
        return ComponentHealth{
            Status:  StatusDegraded,
            Message: "High latency",
            Latency: latency.String(),
        }
    }

    return ComponentHealth{
        Status:  StatusHealthy,
        Latency: latency.String(),
    }
}

func (h *HealthChecker) checkCache(ctx context.Context) ComponentHealth {
    start := time.Now()

    err := h.cache.Ping(ctx).Err()
    latency := time.Since(start)

    if err != nil {
        return ComponentHealth{
            Status:  StatusUnhealthy,
            Message: err.Error(),
            Latency: latency.String(),
        }
    }

    return ComponentHealth{
        Status:  StatusHealthy,
        Latency: latency.String(),
    }
}

func (h *HealthChecker) Check(ctx context.Context) *HealthResponse {
    var wg sync.WaitGroup
    components := make(map[string]ComponentHealth)
    var mu sync.Mutex

    // Check database
    wg.Add(1)
    go func() {
        defer wg.Done()
        health := h.checkDatabase(ctx)
        mu.Lock()
        components["database"] = health
        mu.Unlock()
    }()

    // Check cache
    wg.Add(1)
    go func() {
        defer wg.Done()
        health := h.checkCache(ctx)
        mu.Lock()
        components["cache"] = health
        mu.Unlock()
    }()

    wg.Wait()

    // Determine overall status
    overallStatus := StatusHealthy
    for _, comp := range components {
        if comp.Status == StatusUnhealthy {
            overallStatus = StatusUnhealthy
            break
        }
        if comp.Status == StatusDegraded && overallStatus != StatusUnhealthy {
            overallStatus = StatusDegraded
        }
    }

    return &HealthResponse{
        Status:     overallStatus,
        Timestamp:  time.Now(),
        Components: components,
    }
}

func healthHandler(checker *HealthChecker) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
        defer cancel()

        health := checker.Check(ctx)

        w.Header().Set("Content-Type", "application/json")

        // Set HTTP status based on health
        switch health.Status {
        case StatusHealthy:
            w.WriteHeader(http.StatusOK)
        case StatusDegraded:
            w.WriteHeader(http.StatusOK)
        case StatusUnhealthy:
            w.WriteHeader(http.StatusServiceUnavailable)
        }

        json.NewEncoder(w).Encode(health)
    }
}

// Simple liveness probe
func livenessHandler(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusOK)
    w.Write([]byte("OK"))
}

// Readiness probe
func readinessHandler(checker *HealthChecker) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
        defer cancel()

        // Check critical dependencies only
        dbHealth := checker.checkDatabase(ctx)

        if dbHealth.Status == StatusUnhealthy {
            w.WriteHeader(http.StatusServiceUnavailable)
            w.Write([]byte("NOT READY"))
            return
        }

        w.WriteHeader(http.StatusOK)
        w.Write([]byte("READY"))
    }
}

func main() {
    db, _ := sql.Open("postgres", "...")
    cache := redis.NewClient(&redis.Options{Addr: "localhost:6379"})

    checker := NewHealthChecker(db, cache)

    http.HandleFunc("/health", healthHandler(checker))
    http.HandleFunc("/health/live", livenessHandler)
    http.HandleFunc("/health/ready", readinessHandler(checker))

    log.Fatal(http.ListenAndServe(":8080", nil))
}
```

**Use Case**: Kubernetes probes, monitoring, service health

**Key Concepts**:
- Component health checks
- Liveness and readiness probes
- Concurrent health checks
- Status aggregation

---

## 21-25: Additional Examples

Due to length constraints, here are brief outlines for the remaining examples:

### 21. Concurrent File Processing
- Walk directory tree
- Process files in worker pool
- Aggregate results with channels
- Progress tracking

### 22. Service Discovery
- Service registration
- Health checking
- Load balancing
- Failover handling

### 23. Message Queue Consumer
- AMQP/RabbitMQ consumer
- Message acknowledgment
- Retry logic
- Dead letter queue

### 24. Background Job Processor
- Job queue with Redis
- Worker pool
- Job retry and exponential backoff
- Job status tracking

### 25. API Gateway Pattern
- Request routing
- Service discovery integration
- Load balancing
- Response aggregation

---

**Version**: 1.0.0
**Last Updated**: October 2025
**Total Examples**: 25+ production-ready patterns
