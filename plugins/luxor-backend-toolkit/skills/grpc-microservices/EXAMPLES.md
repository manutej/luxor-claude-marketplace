# gRPC Microservices - Practical Examples

This document contains runnable, production-ready examples for building gRPC microservices.

## Table of Contents

1. [Basic Protobuf Schemas](#basic-protobuf-schemas)
2. [Unary RPC - User Service](#unary-rpc---user-service)
3. [Server Streaming - Product Catalog](#server-streaming---product-catalog)
4. [Client Streaming - Metrics Collection](#client-streaming---metrics-collection)
5. [Bidirectional Streaming - Chat Application](#bidirectional-streaming---chat-application)
6. [Authentication Interceptor](#authentication-interceptor)
7. [Logging and Tracing Interceptor](#logging-and-tracing-interceptor)
8. [Rate Limiting Interceptor](#rate-limiting-interceptor)
9. [Error Handling Patterns](#error-handling-patterns)
10. [Load Balancing with Service Discovery](#load-balancing-with-service-discovery)
11. [Health Check Service](#health-check-service)
12. [TLS/SSL Configuration](#tlsssl-configuration)
13. [Kubernetes Deployment](#kubernetes-deployment)
14. [Multi-Language Interop (Go + Python)](#multi-language-interop-go--python)
15. [Event Streaming System](#event-streaming-system)
16. [File Upload Service](#file-upload-service)
17. [Real-Time Notifications](#real-time-notifications)
18. [Transaction Processing Service](#transaction-processing-service)

---

## Basic Protobuf Schemas

### Complete E-Commerce Schema

```protobuf
// ecommerce.proto
syntax = "proto3";

package ecommerce.v1;

option go_package = "github.com/example/ecommerce/pb/v1";

import "google/protobuf/timestamp.proto";
import "google/protobuf/empty.proto";

// User domain
message User {
  int32 id = 1;
  string email = 2;
  string name = 3;
  google.protobuf.Timestamp created_at = 4;

  enum Role {
    ROLE_UNSPECIFIED = 0;
    ROLE_CUSTOMER = 1;
    ROLE_ADMIN = 2;
    ROLE_MERCHANT = 3;
  }
  Role role = 5;

  message Address {
    string street = 1;
    string city = 2;
    string state = 3;
    string postal_code = 4;
    string country = 5;
  }
  repeated Address addresses = 6;
}

// Product domain
message Product {
  int32 id = 1;
  string name = 2;
  string description = 3;
  int64 price_cents = 4;  // Price in cents to avoid floating point
  string currency = 5;
  int32 stock = 6;
  repeated string image_urls = 7;
  repeated string tags = 8;
  google.protobuf.Timestamp created_at = 9;

  enum Status {
    STATUS_UNSPECIFIED = 0;
    STATUS_ACTIVE = 1;
    STATUS_DRAFT = 2;
    STATUS_ARCHIVED = 3;
  }
  Status status = 10;
}

// Order domain
message Order {
  int32 id = 1;
  int32 user_id = 2;
  repeated OrderItem items = 3;
  int64 total_cents = 4;
  string currency = 5;

  enum Status {
    STATUS_UNSPECIFIED = 0;
    STATUS_PENDING = 1;
    STATUS_PROCESSING = 2;
    STATUS_SHIPPED = 3;
    STATUS_DELIVERED = 4;
    STATUS_CANCELLED = 5;
  }
  Status status = 6;

  google.protobuf.Timestamp created_at = 7;
  google.protobuf.Timestamp updated_at = 8;
}

message OrderItem {
  int32 product_id = 1;
  string product_name = 2;
  int32 quantity = 3;
  int64 price_cents = 4;
}

// Request/Response messages
message GetUserRequest {
  int32 id = 1;
}

message ListProductsRequest {
  int32 page_size = 1;
  string page_token = 2;
  string search_query = 3;
  repeated string tags = 4;
}

message ListProductsResponse {
  repeated Product products = 1;
  string next_page_token = 2;
  int32 total_count = 3;
}

message CreateOrderRequest {
  int32 user_id = 1;
  repeated OrderItem items = 2;
}

message UpdateOrderStatusRequest {
  int32 order_id = 1;
  Order.Status status = 2;
}
```

---

## Unary RPC - User Service

Complete implementation of a user management service with CRUD operations.

### Protobuf Definition

```protobuf
// user.proto
syntax = "proto3";

package user.v1;

option go_package = "github.com/example/user/pb/v1";

import "google/protobuf/timestamp.proto";
import "google/protobuf/empty.proto";

service UserService {
  rpc GetUser(GetUserRequest) returns (User);
  rpc CreateUser(CreateUserRequest) returns (User);
  rpc UpdateUser(UpdateUserRequest) returns (User);
  rpc DeleteUser(DeleteUserRequest) returns (google.protobuf.Empty);
  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse);
}

message User {
  int32 id = 1;
  string email = 2;
  string name = 3;
  string phone = 4;
  google.protobuf.Timestamp created_at = 5;
  google.protobuf.Timestamp updated_at = 6;
}

message GetUserRequest {
  int32 id = 1;
}

message CreateUserRequest {
  string email = 1;
  string name = 2;
  string phone = 3;
}

message UpdateUserRequest {
  int32 id = 1;
  string name = 2;
  string phone = 3;
}

message DeleteUserRequest {
  int32 id = 1;
}

message ListUsersRequest {
  int32 page_size = 1;
  string page_token = 2;
}

message ListUsersResponse {
  repeated User users = 1;
  string next_page_token = 2;
}
```

### Server Implementation (Go)

```go
// server/main.go
package main

import (
    "context"
    "database/sql"
    "log"
    "net"
    "time"

    pb "github.com/example/user/pb/v1"
    _ "github.com/lib/pq"
    "google.golang.org/grpc"
    "google.golang.org/grpc/codes"
    "google.golang.org/grpc/status"
    "google.golang.org/protobuf/types/known/emptypb"
    "google.golang.org/protobuf/types/known/timestamppb"
)

type server struct {
    pb.UnimplementedUserServiceServer
    db *sql.DB
}

func (s *server) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.User, error) {
    if req.Id <= 0 {
        return nil, status.Error(codes.InvalidArgument, "id must be positive")
    }

    var user pb.User
    var createdAt, updatedAt time.Time

    err := s.db.QueryRowContext(ctx,
        "SELECT id, email, name, phone, created_at, updated_at FROM users WHERE id = $1",
        req.Id,
    ).Scan(&user.Id, &user.Email, &user.Name, &user.Phone, &createdAt, &updatedAt)

    if err == sql.ErrNoRows {
        return nil, status.Error(codes.NotFound, "user not found")
    }
    if err != nil {
        log.Printf("database error: %v", err)
        return nil, status.Error(codes.Internal, "internal server error")
    }

    user.CreatedAt = timestamppb.New(createdAt)
    user.UpdatedAt = timestamppb.New(updatedAt)

    return &user, nil
}

func (s *server) CreateUser(ctx context.Context, req *pb.CreateUserRequest) (*pb.User, error) {
    // Validation
    if req.Email == "" {
        return nil, status.Error(codes.InvalidArgument, "email is required")
    }
    if req.Name == "" {
        return nil, status.Error(codes.InvalidArgument, "name is required")
    }

    // Check if email already exists
    var exists bool
    err := s.db.QueryRowContext(ctx,
        "SELECT EXISTS(SELECT 1 FROM users WHERE email = $1)",
        req.Email,
    ).Scan(&exists)

    if err != nil {
        return nil, status.Error(codes.Internal, "internal server error")
    }
    if exists {
        return nil, status.Error(codes.AlreadyExists, "email already exists")
    }

    // Insert user
    var user pb.User
    var createdAt, updatedAt time.Time

    err = s.db.QueryRowContext(ctx,
        "INSERT INTO users (email, name, phone) VALUES ($1, $2, $3) RETURNING id, email, name, phone, created_at, updated_at",
        req.Email, req.Name, req.Phone,
    ).Scan(&user.Id, &user.Email, &user.Name, &user.Phone, &createdAt, &updatedAt)

    if err != nil {
        log.Printf("insert error: %v", err)
        return nil, status.Error(codes.Internal, "failed to create user")
    }

    user.CreatedAt = timestamppb.New(createdAt)
    user.UpdatedAt = timestamppb.New(updatedAt)

    return &user, nil
}

func (s *server) UpdateUser(ctx context.Context, req *pb.UpdateUserRequest) (*pb.User, error) {
    if req.Id <= 0 {
        return nil, status.Error(codes.InvalidArgument, "id must be positive")
    }

    result, err := s.db.ExecContext(ctx,
        "UPDATE users SET name = $1, phone = $2, updated_at = NOW() WHERE id = $3",
        req.Name, req.Phone, req.Id,
    )

    if err != nil {
        return nil, status.Error(codes.Internal, "failed to update user")
    }

    rowsAffected, _ := result.RowsAffected()
    if rowsAffected == 0 {
        return nil, status.Error(codes.NotFound, "user not found")
    }

    // Return updated user
    return s.GetUser(ctx, &pb.GetUserRequest{Id: req.Id})
}

func (s *server) DeleteUser(ctx context.Context, req *pb.DeleteUserRequest) (*emptypb.Empty, error) {
    if req.Id <= 0 {
        return nil, status.Error(codes.InvalidArgument, "id must be positive")
    }

    result, err := s.db.ExecContext(ctx, "DELETE FROM users WHERE id = $1", req.Id)
    if err != nil {
        return nil, status.Error(codes.Internal, "failed to delete user")
    }

    rowsAffected, _ := result.RowsAffected()
    if rowsAffected == 0 {
        return nil, status.Error(codes.NotFound, "user not found")
    }

    return &emptypb.Empty{}, nil
}

func (s *server) ListUsers(ctx context.Context, req *pb.ListUsersRequest) (*pb.ListUsersResponse, error) {
    pageSize := req.PageSize
    if pageSize <= 0 || pageSize > 100 {
        pageSize = 10 // Default page size
    }

    offset := 0
    if req.PageToken != "" {
        // Parse page token (simplified - use actual token in production)
        // offset = parsePageToken(req.PageToken)
    }

    rows, err := s.db.QueryContext(ctx,
        "SELECT id, email, name, phone, created_at, updated_at FROM users ORDER BY id LIMIT $1 OFFSET $2",
        pageSize+1, offset, // Fetch one extra to determine if there's a next page
    )

    if err != nil {
        return nil, status.Error(codes.Internal, "database error")
    }
    defer rows.Close()

    var users []*pb.User
    for rows.Next() {
        var user pb.User
        var createdAt, updatedAt time.Time

        if err := rows.Scan(&user.Id, &user.Email, &user.Name, &user.Phone, &createdAt, &updatedAt); err != nil {
            return nil, status.Error(codes.Internal, "scan error")
        }

        user.CreatedAt = timestamppb.New(createdAt)
        user.UpdatedAt = timestamppb.New(updatedAt)

        users = append(users, &user)
    }

    var nextPageToken string
    if len(users) > int(pageSize) {
        users = users[:pageSize]
        // Generate next page token (simplified)
        nextPageToken = "next_page"
    }

    return &pb.ListUsersResponse{
        Users:         users,
        NextPageToken: nextPageToken,
    }, nil
}

func main() {
    // Connect to database
    db, err := sql.Open("postgres", "postgresql://user:password@localhost/userdb?sslmode=disable")
    if err != nil {
        log.Fatalf("failed to connect to database: %v", err)
    }
    defer db.Close()

    // Create listener
    lis, err := net.Listen("tcp", ":50051")
    if err != nil {
        log.Fatalf("failed to listen: %v", err)
    }

    // Create gRPC server
    s := grpc.NewServer()
    pb.RegisterUserServiceServer(s, &server{db: db})

    log.Printf("Server listening on :50051")
    if err := s.Serve(lis); err != nil {
        log.Fatalf("failed to serve: %v", err)
    }
}
```

### Client Implementation (Go)

```go
// client/main.go
package main

import (
    "context"
    "log"
    "time"

    pb "github.com/example/user/pb/v1"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
)

func main() {
    // Connect to server
    conn, err := grpc.Dial("localhost:50051", grpc.WithTransportCredentials(insecure.NewCredentials()))
    if err != nil {
        log.Fatalf("did not connect: %v", err)
    }
    defer conn.Close()

    client := pb.NewUserServiceClient(conn)
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()

    // Create user
    createResp, err := client.CreateUser(ctx, &pb.CreateUserRequest{
        Email: "john@example.com",
        Name:  "John Doe",
        Phone: "+1234567890",
    })
    if err != nil {
        log.Fatalf("CreateUser failed: %v", err)
    }
    log.Printf("Created user: %v", createResp)

    // Get user
    getResp, err := client.GetUser(ctx, &pb.GetUserRequest{Id: createResp.Id})
    if err != nil {
        log.Fatalf("GetUser failed: %v", err)
    }
    log.Printf("Retrieved user: %v", getResp)

    // Update user
    updateResp, err := client.UpdateUser(ctx, &pb.UpdateUserRequest{
        Id:    createResp.Id,
        Name:  "John Smith",
        Phone: "+9876543210",
    })
    if err != nil {
        log.Fatalf("UpdateUser failed: %v", err)
    }
    log.Printf("Updated user: %v", updateResp)

    // List users
    listResp, err := client.ListUsers(ctx, &pb.ListUsersRequest{PageSize: 10})
    if err != nil {
        log.Fatalf("ListUsers failed: %v", err)
    }
    log.Printf("Listed %d users", len(listResp.Users))
    for _, user := range listResp.Users {
        log.Printf("  - %s (%s)", user.Name, user.Email)
    }

    // Delete user
    _, err = client.DeleteUser(ctx, &pb.DeleteUserRequest{Id: createResp.Id})
    if err != nil {
        log.Fatalf("DeleteUser failed: %v", err)
    }
    log.Printf("Deleted user %d", createResp.Id)
}
```

---

## Server Streaming - Product Catalog

Stream products to clients for efficient large dataset handling.

### Protobuf Definition

```protobuf
// product.proto
syntax = "proto3";

package product.v1;

option go_package = "github.com/example/product/pb/v1";

service ProductService {
  // Server streaming - sends products one by one
  rpc SearchProducts(SearchRequest) returns (stream Product);
  rpc WatchPriceChanges(WatchRequest) returns (stream PriceUpdate);
}

message Product {
  int32 id = 1;
  string name = 2;
  string description = 3;
  int64 price_cents = 4;
  string category = 5;
  int32 stock = 6;
}

message SearchRequest {
  string query = 1;
  string category = 2;
  int32 max_results = 3;
}

message WatchRequest {
  repeated int32 product_ids = 1;
}

message PriceUpdate {
  int32 product_id = 1;
  int64 old_price_cents = 2;
  int64 new_price_cents = 3;
  string reason = 4;
}
```

### Server Implementation (Go)

```go
// server/main.go
package main

import (
    "context"
    "log"
    "math/rand"
    "net"
    "sync"
    "time"

    pb "github.com/example/product/pb/v1"
    "google.golang.org/grpc"
    "google.golang.org/grpc/codes"
    "google.golang.org/grpc/status"
)

type server struct {
    pb.UnimplementedProductServiceServer
    products         []*pb.Product
    priceWatchers    map[int32][]chan *pb.PriceUpdate
    priceWatchersMux sync.RWMutex
}

func newServer() *server {
    s := &server{
        products:      generateProducts(1000),
        priceWatchers: make(map[int32][]chan *pb.PriceUpdate),
    }

    // Start background price updater
    go s.updatePrices()

    return s
}

func generateProducts(count int) []*pb.Product {
    categories := []string{"Electronics", "Books", "Clothing", "Home", "Sports"}
    products := make([]*pb.Product, count)

    for i := 0; i < count; i++ {
        products[i] = &pb.Product{
            Id:          int32(i + 1),
            Name:        "Product " + string(rune('A'+i%26)),
            Description: "Description for product " + string(rune('A'+i%26)),
            PriceCents:  int64(1000 + rand.Intn(99000)),
            Category:    categories[i%len(categories)],
            Stock:       rand.Intn(100),
        }
    }

    return products
}

func (s *server) SearchProducts(req *pb.SearchRequest, stream pb.ProductService_SearchProductsServer) error {
    log.Printf("SearchProducts: query=%s, category=%s, max=%d", req.Query, req.Category, req.MaxResults)

    maxResults := req.MaxResults
    if maxResults <= 0 || maxResults > 100 {
        maxResults = 100
    }

    sent := 0
    for _, product := range s.products {
        // Check if context is cancelled
        if err := stream.Context().Err(); err != nil {
            return status.Error(codes.Canceled, "client cancelled request")
        }

        // Filter by category
        if req.Category != "" && product.Category != req.Category {
            continue
        }

        // Simple search filter (in production, use proper search)
        if req.Query != "" {
            // Check if query matches name or description (case-insensitive)
            // For simplicity, just check product name
            // In production, use proper text search
        }

        // Send product to client
        if err := stream.Send(product); err != nil {
            return status.Error(codes.Internal, "failed to send product")
        }

        sent++
        if sent >= int(maxResults) {
            break
        }

        // Simulate some processing time
        time.Sleep(10 * time.Millisecond)
    }

    log.Printf("Sent %d products", sent)
    return nil
}

func (s *server) WatchPriceChanges(req *pb.WatchRequest, stream pb.ProductService_WatchPriceChangesServer) error {
    if len(req.ProductIds) == 0 {
        return status.Error(codes.InvalidArgument, "product_ids is required")
    }

    log.Printf("WatchPriceChanges: watching %d products", len(req.ProductIds))

    // Create channel for this watcher
    updateChan := make(chan *pb.PriceUpdate, 10)

    // Register watcher for each product
    s.priceWatchersMux.Lock()
    for _, productID := range req.ProductIds {
        s.priceWatchers[productID] = append(s.priceWatchers[productID], updateChan)
    }
    s.priceWatchersMux.Unlock()

    // Cleanup on exit
    defer func() {
        s.priceWatchersMux.Lock()
        for _, productID := range req.ProductIds {
            watchers := s.priceWatchers[productID]
            for i, ch := range watchers {
                if ch == updateChan {
                    s.priceWatchers[productID] = append(watchers[:i], watchers[i+1:]...)
                    break
                }
            }
        }
        s.priceWatchersMux.Unlock()
        close(updateChan)
    }()

    // Stream price updates
    for {
        select {
        case update := <-updateChan:
            if err := stream.Send(update); err != nil {
                return status.Error(codes.Internal, "failed to send update")
            }
        case <-stream.Context().Done():
            return status.Error(codes.Canceled, "client cancelled request")
        }
    }
}

func (s *server) updatePrices() {
    ticker := time.NewTicker(5 * time.Second)
    defer ticker.Stop()

    for range ticker.C {
        // Randomly update some product prices
        for i := 0; i < 5; i++ {
            productIdx := rand.Intn(len(s.products))
            product := s.products[productIdx]

            oldPrice := product.PriceCents
            newPrice := oldPrice + int64(rand.Intn(2000)-1000) // +/- $10

            if newPrice < 100 {
                newPrice = 100
            }

            product.PriceCents = newPrice

            // Notify watchers
            update := &pb.PriceUpdate{
                ProductId:     product.Id,
                OldPriceCents: oldPrice,
                NewPriceCents: newPrice,
                Reason:        "market adjustment",
            }

            s.priceWatchersMux.RLock()
            watchers := s.priceWatchers[product.Id]
            for _, ch := range watchers {
                select {
                case ch <- update:
                default:
                    // Channel full, skip
                }
            }
            s.priceWatchersMux.RUnlock()
        }
    }
}

func main() {
    lis, err := net.Listen("tcp", ":50052")
    if err != nil {
        log.Fatalf("failed to listen: %v", err)
    }

    s := grpc.NewServer()
    pb.RegisterProductServiceServer(s, newServer())

    log.Printf("Product service listening on :50052")
    if err := s.Serve(lis); err != nil {
        log.Fatalf("failed to serve: %v", err)
    }
}
```

### Client Implementation (Go)

```go
// client/main.go
package main

import (
    "context"
    "io"
    "log"

    pb "github.com/example/product/pb/v1"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
)

func main() {
    conn, err := grpc.Dial("localhost:50052", grpc.WithTransportCredentials(insecure.NewCredentials()))
    if err != nil {
        log.Fatalf("did not connect: %v", err)
    }
    defer conn.Close()

    client := pb.NewProductServiceClient(conn)
    ctx := context.Background()

    // Search products with streaming
    log.Println("Searching products...")
    stream, err := client.SearchProducts(ctx, &pb.SearchRequest{
        Query:      "Product",
        Category:   "Electronics",
        MaxResults: 10,
    })
    if err != nil {
        log.Fatalf("SearchProducts failed: %v", err)
    }

    count := 0
    for {
        product, err := stream.Recv()
        if err == io.EOF {
            break
        }
        if err != nil {
            log.Fatalf("stream error: %v", err)
        }

        count++
        log.Printf("  %d. %s - $%.2f (Stock: %d)",
            count, product.Name, float64(product.PriceCents)/100, product.Stock)
    }

    log.Printf("Received %d products\n", count)

    // Watch price changes
    log.Println("\nWatching price changes for products 1, 2, 3...")
    watchStream, err := client.WatchPriceChanges(ctx, &pb.WatchRequest{
        ProductIds: []int32{1, 2, 3},
    })
    if err != nil {
        log.Fatalf("WatchPriceChanges failed: %v", err)
    }

    // Receive price updates (this will run indefinitely)
    for i := 0; i < 10; i++ { // Receive 10 updates then exit
        update, err := watchStream.Recv()
        if err == io.EOF {
            break
        }
        if err != nil {
            log.Fatalf("watch stream error: %v", err)
        }

        log.Printf("Price update: Product %d: $%.2f → $%.2f (%s)",
            update.ProductId,
            float64(update.OldPriceCents)/100,
            float64(update.NewPriceCents)/100,
            update.Reason)
    }
}
```

---

## Client Streaming - Metrics Collection

Client streams metrics data, server aggregates and returns summary.

### Protobuf Definition

```protobuf
// metrics.proto
syntax = "proto3";

package metrics.v1;

option go_package = "github.com/example/metrics/pb/v1";

import "google/protobuf/timestamp.proto";

service MetricsService {
  rpc RecordMetrics(stream Metric) returns (MetricsSummary);
}

message Metric {
  string name = 1;
  double value = 2;
  map<string, string> labels = 3;
  google.protobuf.Timestamp timestamp = 4;

  enum Type {
    TYPE_UNSPECIFIED = 0;
    TYPE_COUNTER = 1;
    TYPE_GAUGE = 2;
    TYPE_HISTOGRAM = 3;
  }
  Type type = 5;
}

message MetricsSummary {
  int32 total_metrics = 1;
  int32 unique_metric_names = 2;
  google.protobuf.Timestamp start_time = 3;
  google.protobuf.Timestamp end_time = 4;
  map<string, MetricStats> stats = 5;
}

message MetricStats {
  int32 count = 1;
  double sum = 2;
  double min = 3;
  double max = 4;
  double avg = 5;
}
```

### Server Implementation (Go)

```go
// server/main.go
package main

import (
    "io"
    "log"
    "math"
    "net"

    pb "github.com/example/metrics/pb/v1"
    "google.golang.org/grpc"
    "google.golang.org/grpc/codes"
    "google.golang.org/grpc/status"
    "google.golang.org/protobuf/types/known/timestamppb"
)

type server struct {
    pb.UnimplementedMetricsServiceServer
}

type metricAggregator struct {
    count  int32
    sum    float64
    min    float64
    max    float64
    values []float64
}

func (s *server) RecordMetrics(stream pb.MetricsService_RecordMetricsServer) error {
    log.Println("RecordMetrics: starting to receive metrics")

    aggregators := make(map[string]*metricAggregator)
    var totalMetrics int32
    var startTime, endTime *timestamppb.Timestamp

    for {
        metric, err := stream.Recv()
        if err == io.EOF {
            // Client finished sending
            log.Printf("RecordMetrics: received %d metrics", totalMetrics)
            break
        }
        if err != nil {
            return status.Error(codes.Internal, "failed to receive metric")
        }

        // Track timestamps
        if startTime == nil {
            startTime = metric.Timestamp
        }
        endTime = metric.Timestamp

        // Get or create aggregator for this metric name
        agg, exists := aggregators[metric.Name]
        if !exists {
            agg = &metricAggregator{
                min: math.Inf(1),
                max: math.Inf(-1),
            }
            aggregators[metric.Name] = agg
        }

        // Update aggregator
        agg.count++
        agg.sum += metric.Value
        if metric.Value < agg.min {
            agg.min = metric.Value
        }
        if metric.Value > agg.max {
            agg.max = metric.Value
        }
        agg.values = append(agg.values, metric.Value)

        totalMetrics++
    }

    // Calculate statistics
    stats := make(map[string]*pb.MetricStats)
    for name, agg := range aggregators {
        avg := agg.sum / float64(agg.count)
        stats[name] = &pb.MetricStats{
            Count: agg.count,
            Sum:   agg.sum,
            Min:   agg.min,
            Max:   agg.max,
            Avg:   avg,
        }
    }

    // Send summary back to client
    summary := &pb.MetricsSummary{
        TotalMetrics:       totalMetrics,
        UniqueMetricNames:  int32(len(aggregators)),
        StartTime:          startTime,
        EndTime:            endTime,
        Stats:              stats,
    }

    return stream.SendAndClose(summary)
}

func main() {
    lis, err := net.Listen("tcp", ":50053")
    if err != nil {
        log.Fatalf("failed to listen: %v", err)
    }

    s := grpc.NewServer()
    pb.RegisterMetricsServiceServer(s, &server{})

    log.Printf("Metrics service listening on :50053")
    if err := s.Serve(lis); err != nil {
        log.Fatalf("failed to serve: %v", err)
    }
}
```

### Client Implementation (Go)

```go
// client/main.go
package main

import (
    "context"
    "log"
    "math/rand"
    "time"

    pb "github.com/example/metrics/pb/v1"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
    "google.golang.org/protobuf/types/known/timestamppb"
)

func main() {
    conn, err := grpc.Dial("localhost:50053", grpc.WithTransportCredentials(insecure.NewCredentials()))
    if err != nil {
        log.Fatalf("did not connect: %v", err)
    }
    defer conn.Close()

    client := pb.NewMetricsServiceClient(conn)
    ctx := context.Background()

    // Open stream
    stream, err := client.RecordMetrics(ctx)
    if err != nil {
        log.Fatalf("RecordMetrics failed: %v", err)
    }

    // Send metrics
    metricNames := []string{"cpu_usage", "memory_usage", "request_count", "error_rate"}

    log.Println("Sending metrics...")
    for i := 0; i < 100; i++ {
        metric := &pb.Metric{
            Name:      metricNames[rand.Intn(len(metricNames))],
            Value:     rand.Float64() * 100,
            Timestamp: timestamppb.New(time.Now()),
            Type:      pb.Metric_TYPE_GAUGE,
            Labels: map[string]string{
                "host":   "server-1",
                "region": "us-west-2",
            },
        }

        if err := stream.Send(metric); err != nil {
            log.Fatalf("failed to send metric: %v", err)
        }

        if (i+1)%20 == 0 {
            log.Printf("Sent %d metrics...", i+1)
        }

        // Simulate some delay
        time.Sleep(10 * time.Millisecond)
    }

    // Receive summary
    summary, err := stream.CloseAndRecv()
    if err != nil {
        log.Fatalf("failed to receive summary: %v", err)
    }

    log.Printf("\nMetrics Summary:")
    log.Printf("  Total metrics: %d", summary.TotalMetrics)
    log.Printf("  Unique names: %d", summary.UniqueMetricNames)
    log.Printf("  Time range: %v to %v", summary.StartTime.AsTime(), summary.EndTime.AsTime())
    log.Println("\nStatistics:")
    for name, stats := range summary.Stats {
        log.Printf("  %s:", name)
        log.Printf("    Count: %d", stats.Count)
        log.Printf("    Sum: %.2f", stats.Sum)
        log.Printf("    Min: %.2f", stats.Min)
        log.Printf("    Max: %.2f", stats.Max)
        log.Printf("    Avg: %.2f", stats.Avg)
    }
}
```

---

## Bidirectional Streaming - Chat Application

Real-time chat with bidirectional streaming.

### Protobuf Definition

```protobuf
// chat.proto
syntax = "proto3";

package chat.v1;

option go_package = "github.com/example/chat/pb/v1";

import "google/protobuf/timestamp.proto";

service ChatService {
  rpc Chat(stream ChatMessage) returns (stream ChatMessage);
  rpc JoinRoom(JoinRoomRequest) returns (stream RoomEvent);
}

message ChatMessage {
  string message_id = 1;
  string user_id = 2;
  string room_id = 3;
  string content = 4;
  google.protobuf.Timestamp timestamp = 5;

  enum Type {
    TYPE_UNSPECIFIED = 0;
    TYPE_TEXT = 1;
    TYPE_IMAGE = 2;
    TYPE_FILE = 3;
  }
  Type type = 6;
}

message JoinRoomRequest {
  string user_id = 1;
  string room_id = 2;
  string display_name = 3;
}

message RoomEvent {
  enum EventType {
    EVENT_TYPE_UNSPECIFIED = 0;
    EVENT_TYPE_USER_JOINED = 1;
    EVENT_TYPE_USER_LEFT = 2;
    EVENT_TYPE_MESSAGE = 3;
  }
  EventType type = 1;
  string user_id = 2;
  string message = 3;
  google.protobuf.Timestamp timestamp = 4;
}
```

### Server Implementation (Go)

```go
// server/main.go
package main

import (
    "io"
    "log"
    "net"
    "sync"
    "time"

    pb "github.com/example/chat/pb/v1"
    "github.com/google/uuid"
    "google.golang.org/grpc"
    "google.golang.org/grpc/codes"
    "google.golang.org/grpc/status"
    "google.golang.org/protobuf/types/known/timestamppb"
)

type server struct {
    pb.UnimplementedChatServiceServer
    rooms      map[string]*chatRoom
    roomsMutex sync.RWMutex
}

type chatRoom struct {
    id      string
    clients map[string]chan *pb.ChatMessage
    mu      sync.RWMutex
}

func newServer() *server {
    return &server{
        rooms: make(map[string]*chatRoom),
    }
}

func (s *server) getOrCreateRoom(roomID string) *chatRoom {
    s.roomsMutex.Lock()
    defer s.roomsMutex.Unlock()

    room, exists := s.rooms[roomID]
    if !exists {
        room = &chatRoom{
            id:      roomID,
            clients: make(map[string]chan *pb.ChatMessage),
        }
        s.rooms[roomID] = room
        log.Printf("Created new room: %s", roomID)
    }

    return room
}

func (r *chatRoom) broadcast(msg *pb.ChatMessage) {
    r.mu.RLock()
    defer r.mu.RUnlock()

    log.Printf("Broadcasting message in room %s from user %s", r.id, msg.UserId)

    for clientID, ch := range r.clients {
        select {
        case ch <- msg:
            // Message sent successfully
        default:
            // Channel full, client is slow
            log.Printf("Client %s is slow, skipping message", clientID)
        }
    }
}

func (r *chatRoom) addClient(clientID string, ch chan *pb.ChatMessage) {
    r.mu.Lock()
    defer r.mu.Unlock()

    r.clients[clientID] = ch
    log.Printf("Client %s joined room %s (total: %d)", clientID, r.id, len(r.clients))
}

func (r *chatRoom) removeClient(clientID string) {
    r.mu.Lock()
    defer r.mu.Unlock()

    delete(r.clients, clientID)
    log.Printf("Client %s left room %s (remaining: %d)", clientID, r.id, len(r.clients))
}

func (s *server) Chat(stream pb.ChatService_ChatServer) error {
    clientID := uuid.New().String()
    var room *chatRoom
    var messagesChan chan *pb.ChatMessage

    log.Printf("New chat connection: %s", clientID)

    // Goroutine to send messages to client
    sendDone := make(chan struct{})
    go func() {
        defer close(sendDone)

        for msg := range messagesChan {
            if err := stream.Send(msg); err != nil {
                log.Printf("Error sending message to client %s: %v", clientID, err)
                return
            }
        }
    }()

    // Receive messages from client
    for {
        msg, err := stream.Recv()
        if err == io.EOF {
            log.Printf("Client %s closed connection", clientID)
            break
        }
        if err != nil {
            log.Printf("Error receiving from client %s: %v", clientID, err)
            break
        }

        // First message determines the room
        if room == nil {
            room = s.getOrCreateRoom(msg.RoomId)
            messagesChan = make(chan *pb.ChatMessage, 100)
            room.addClient(clientID, messagesChan)

            // Send join notification
            joinMsg := &pb.ChatMessage{
                MessageId: uuid.New().String(),
                UserId:    "system",
                RoomId:    msg.RoomId,
                Content:   msg.UserId + " joined the room",
                Timestamp: timestamppb.New(time.Now()),
                Type:      pb.ChatMessage_TYPE_TEXT,
            }
            room.broadcast(joinMsg)
        }

        // Add timestamp and ID if not present
        if msg.Timestamp == nil {
            msg.Timestamp = timestamppb.New(time.Now())
        }
        if msg.MessageId == "" {
            msg.MessageId = uuid.New().String()
        }

        // Broadcast message to all clients in room
        room.broadcast(msg)
    }

    // Cleanup
    if room != nil {
        room.removeClient(clientID)
        close(messagesChan)

        // Send leave notification
        leaveMsg := &pb.ChatMessage{
            MessageId: uuid.New().String(),
            UserId:    "system",
            RoomId:    room.id,
            Content:   clientID + " left the room",
            Timestamp: timestamppb.New(time.Now()),
            Type:      pb.ChatMessage_TYPE_TEXT,
        }
        room.broadcast(leaveMsg)
    }

    <-sendDone
    return nil
}

func (s *server) JoinRoom(req *pb.JoinRoomRequest, stream pb.ChatService_JoinRoomServer) error {
    room := s.getOrCreateRoom(req.RoomId)
    eventChan := make(chan *pb.ChatMessage, 100)

    clientID := req.UserId
    room.addClient(clientID, eventChan)

    defer func() {
        room.removeClient(clientID)
        close(eventChan)
    }()

    // Send join event
    room.broadcast(&pb.ChatMessage{
        MessageId: uuid.New().String(),
        UserId:    "system",
        RoomId:    req.RoomId,
        Content:   req.DisplayName + " joined",
        Timestamp: timestamppb.New(time.Now()),
    })

    // Stream events to client
    for {
        select {
        case msg, ok := <-eventChan:
            if !ok {
                return nil
            }

            event := &pb.RoomEvent{
                Type:      pb.RoomEvent_EVENT_TYPE_MESSAGE,
                UserId:    msg.UserId,
                Message:   msg.Content,
                Timestamp: msg.Timestamp,
            }

            if err := stream.Send(event); err != nil {
                return err
            }

        case <-stream.Context().Done():
            return status.Error(codes.Canceled, "client disconnected")
        }
    }
}

func main() {
    lis, err := net.Listen("tcp", ":50054")
    if err != nil {
        log.Fatalf("failed to listen: %v", err)
    }

    s := grpc.NewServer()
    pb.RegisterChatServiceServer(s, newServer())

    log.Printf("Chat service listening on :50054")
    if err := s.Serve(lis); err != nil {
        log.Fatalf("failed to serve: %v", err)
    }
}
```

### Client Implementation (Go)

```go
// client/main.go
package main

import (
    "bufio"
    "context"
    "fmt"
    "io"
    "log"
    "os"
    "strings"

    pb "github.com/example/chat/pb/v1"
    "github.com/google/uuid"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
    "google.golang.org/protobuf/types/known/timestamppb"
    "time"
)

func main() {
    if len(os.Args) < 3 {
        log.Fatalf("Usage: %s <username> <room>", os.Args[0])
    }

    username := os.Args[1]
    roomID := os.Args[2]

    conn, err := grpc.Dial("localhost:50054", grpc.WithTransportCredentials(insecure.NewCredentials()))
    if err != nil {
        log.Fatalf("did not connect: %v", err)
    }
    defer conn.Close()

    client := pb.NewChatServiceClient(conn)
    ctx := context.Background()

    // Open bidirectional stream
    stream, err := client.Chat(ctx)
    if err != nil {
        log.Fatalf("Chat failed: %v", err)
    }

    // Goroutine to receive messages
    go func() {
        for {
            msg, err := stream.Recv()
            if err == io.EOF {
                log.Println("Server closed connection")
                return
            }
            if err != nil {
                log.Printf("Error receiving message: %v", err)
                return
            }

            timestamp := msg.Timestamp.AsTime().Format("15:04:05")
            fmt.Printf("\n[%s] %s: %s\n> ", timestamp, msg.UserId, msg.Content)
        }
    }()

    // Read from stdin and send messages
    fmt.Printf("Joined room '%s' as '%s'\n", roomID, username)
    fmt.Println("Type your messages (Ctrl+C to exit):")

    scanner := bufio.NewScanner(os.Stdin)
    for {
        fmt.Print("> ")
        if !scanner.Scan() {
            break
        }

        text := strings.TrimSpace(scanner.Text())
        if text == "" {
            continue
        }

        msg := &pb.ChatMessage{
            MessageId: uuid.New().String(),
            UserId:    username,
            RoomId:    roomID,
            Content:   text,
            Timestamp: timestamppb.New(time.Now()),
            Type:      pb.ChatMessage_TYPE_TEXT,
        }

        if err := stream.Send(msg); err != nil {
            log.Fatalf("Failed to send message: %v", err)
        }
    }

    stream.CloseSend()
}
```

---

## Authentication Interceptor

JWT-based authentication interceptor for gRPC services.

```go
// auth_interceptor.go
package interceptor

import (
    "context"
    "strings"

    "github.com/golang-jwt/jwt/v5"
    "google.golang.org/grpc"
    "google.golang.org/grpc/codes"
    "google.golang.org/grpc/metadata"
    "google.golang.org/grpc/status"
)

type Claims struct {
    UserID string `json:"user_id"`
    Email  string `json:"email"`
    Role   string `json:"role"`
    jwt.RegisteredClaims
}

type contextKey string

const (
    ClaimsContextKey contextKey = "claims"
)

func AuthInterceptor(jwtSecret string) grpc.UnaryServerInterceptor {
    return func(
        ctx context.Context,
        req interface{},
        info *grpc.UnaryServerInfo,
        handler grpc.UnaryHandler,
    ) (interface{}, error) {
        // Skip authentication for certain methods
        if isPublicMethod(info.FullMethod) {
            return handler(ctx, req)
        }

        // Extract metadata
        md, ok := metadata.FromIncomingContext(ctx)
        if !ok {
            return nil, status.Error(codes.Unauthenticated, "no metadata provided")
        }

        // Get authorization header
        authHeaders := md["authorization"]
        if len(authHeaders) == 0 {
            return nil, status.Error(codes.Unauthenticated, "no authorization header")
        }

        // Parse token
        token := strings.TrimPrefix(authHeaders[0], "Bearer ")
        claims, err := validateJWT(token, jwtSecret)
        if err != nil {
            return nil, status.Error(codes.Unauthenticated, "invalid token")
        }

        // Add claims to context
        ctx = context.WithValue(ctx, ClaimsContextKey, claims)

        // Call handler with enriched context
        return handler(ctx, req)
    }
}

func StreamAuthInterceptor(jwtSecret string) grpc.StreamServerInterceptor {
    return func(
        srv interface{},
        ss grpc.ServerStream,
        info *grpc.StreamServerInfo,
        handler grpc.StreamHandler,
    ) error {
        // Skip authentication for certain methods
        if isPublicMethod(info.FullMethod) {
            return handler(srv, ss)
        }

        // Extract metadata from stream context
        md, ok := metadata.FromIncomingContext(ss.Context())
        if !ok {
            return status.Error(codes.Unauthenticated, "no metadata provided")
        }

        // Get authorization header
        authHeaders := md["authorization"]
        if len(authHeaders) == 0 {
            return status.Error(codes.Unauthenticated, "no authorization header")
        }

        // Parse token
        token := strings.TrimPrefix(authHeaders[0], "Bearer ")
        claims, err := validateJWT(token, jwtSecret)
        if err != nil {
            return status.Error(codes.Unauthenticated, "invalid token")
        }

        // Create wrapped stream with enriched context
        wrappedStream := &wrappedServerStream{
            ServerStream: ss,
            ctx:          context.WithValue(ss.Context(), ClaimsContextKey, claims),
        }

        return handler(srv, wrappedStream)
    }
}

type wrappedServerStream struct {
    grpc.ServerStream
    ctx context.Context
}

func (w *wrappedServerStream) Context() context.Context {
    return w.ctx
}

func validateJWT(tokenString, secret string) (*Claims, error) {
    token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
        return []byte(secret), nil
    })

    if err != nil {
        return nil, err
    }

    if claims, ok := token.Claims.(*Claims); ok && token.Valid {
        return claims, nil
    }

    return nil, jwt.ErrSignatureInvalid
}

func isPublicMethod(method string) bool {
    publicMethods := map[string]bool{
        "/user.v1.UserService/CreateUser": true,
        "/auth.v1.AuthService/Login":      true,
        "/health.Health/Check":            true,
    }

    return publicMethods[method]
}

// GetClaims extracts claims from context
func GetClaims(ctx context.Context) (*Claims, error) {
    claims, ok := ctx.Value(ClaimsContextKey).(*Claims)
    if !ok {
        return nil, status.Error(codes.Unauthenticated, "no claims in context")
    }
    return claims, nil
}

// RequireRole checks if user has required role
func RequireRole(ctx context.Context, requiredRole string) error {
    claims, err := GetClaims(ctx)
    if err != nil {
        return err
    }

    if claims.Role != requiredRole {
        return status.Error(codes.PermissionDenied, "insufficient permissions")
    }

    return nil
}
```

**Usage:**

```go
// Server setup
server := grpc.NewServer(
    grpc.ChainUnaryInterceptor(
        AuthInterceptor("your-secret-key"),
        // other interceptors...
    ),
    grpc.ChainStreamInterceptor(
        StreamAuthInterceptor("your-secret-key"),
        // other interceptors...
    ),
)

// In handler
func (s *server) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.User, error) {
    // Get claims from context
    claims, err := interceptor.GetClaims(ctx)
    if err != nil {
        return nil, err
    }

    // Check permissions
    if err := interceptor.RequireRole(ctx, "admin"); err != nil {
        return nil, err
    }

    // Use claims
    log.Printf("Request from user: %s (%s)", claims.Email, claims.UserID)

    // ... handle request
}

// Client setup
func createAuthClient(token string) pb.UserServiceClient {
    conn, _ := grpc.Dial(
        "localhost:50051",
        grpc.WithPerRPCCredentials(&tokenAuth{token: token}),
    )
    return pb.NewUserServiceClient(conn)
}

type tokenAuth struct {
    token string
}

func (t *tokenAuth) GetRequestMetadata(ctx context.Context, uri ...string) (map[string]string, error) {
    return map[string]string{
        "authorization": "Bearer " + t.token,
    }, nil
}

func (t *tokenAuth) RequireTransportSecurity() bool {
    return false // Set to true in production with TLS
}
```

---

## Logging and Tracing Interceptor

Comprehensive logging and OpenTelemetry tracing.

```go
// logging_interceptor.go
package interceptor

import (
    "context"
    "log"
    "time"

    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/attribute"
    "go.opentelemetry.io/otel/codes"
    "go.opentelemetry.io/otel/trace"
    "google.golang.org/grpc"
    "google.golang.org/grpc/metadata"
    "google.golang.org/grpc/status"
)

type Logger interface {
    Info(msg string, fields ...interface{})
    Error(msg string, fields ...interface{})
    Warn(msg string, fields ...interface{})
}

func LoggingInterceptor(logger Logger) grpc.UnaryServerInterceptor {
    return func(
        ctx context.Context,
        req interface{},
        info *grpc.UnaryServerInfo,
        handler grpc.UnaryHandler,
    ) (interface{}, error) {
        start := time.Now()

        // Get request ID from metadata
        requestID := getRequestID(ctx)

        logger.Info("gRPC request started",
            "method", info.FullMethod,
            "request_id", requestID,
        )

        // Call handler
        resp, err := handler(ctx, req)

        // Log response
        duration := time.Since(start)
        statusCode := status.Code(err)

        fields := []interface{}{
            "method", info.FullMethod,
            "request_id", requestID,
            "duration_ms", duration.Milliseconds(),
            "status", statusCode.String(),
        }

        if err != nil {
            logger.Error("gRPC request failed", append(fields, "error", err.Error())...)
        } else {
            logger.Info("gRPC request completed", fields...)
        }

        return resp, err
    }
}

func TracingInterceptor(tracer trace.Tracer) grpc.UnaryServerInterceptor {
    return func(
        ctx context.Context,
        req interface{},
        info *grpc.UnaryServerInfo,
        handler grpc.UnaryHandler,
    ) (interface{}, error) {
        // Start span
        ctx, span := tracer.Start(ctx, info.FullMethod,
            trace.WithSpanKind(trace.SpanKindServer),
        )
        defer span.End()

        // Add attributes
        span.SetAttributes(
            attribute.String("rpc.service", extractService(info.FullMethod)),
            attribute.String("rpc.method", extractMethod(info.FullMethod)),
            attribute.String("rpc.system", "grpc"),
        )

        // Add request ID if available
        if requestID := getRequestID(ctx); requestID != "" {
            span.SetAttributes(attribute.String("request.id", requestID))
        }

        // Call handler
        resp, err := handler(ctx, req)

        // Record error if any
        if err != nil {
            span.RecordError(err)
            span.SetStatus(codes.Error, err.Error())
            span.SetAttributes(
                attribute.String("rpc.grpc.status_code", status.Code(err).String()),
            )
        } else {
            span.SetStatus(codes.Ok, "")
        }

        return resp, err
    }
}

func CombinedLoggingTracingInterceptor(logger Logger) grpc.UnaryServerInterceptor {
    tracer := otel.Tracer("grpc-server")

    return func(
        ctx context.Context,
        req interface{},
        info *grpc.UnaryServerInfo,
        handler grpc.UnaryHandler,
    ) (interface{}, error) {
        start := time.Now()

        // Start span
        ctx, span := tracer.Start(ctx, info.FullMethod,
            trace.WithSpanKind(trace.SpanKindServer),
        )
        defer span.End()

        // Get request ID
        requestID := getRequestID(ctx)

        // Add span attributes
        span.SetAttributes(
            attribute.String("rpc.service", extractService(info.FullMethod)),
            attribute.String("rpc.method", extractMethod(info.FullMethod)),
            attribute.String("request.id", requestID),
        )

        // Log start
        logger.Info("Request started",
            "method", info.FullMethod,
            "request_id", requestID,
            "trace_id", span.SpanContext().TraceID().String(),
        )

        // Call handler
        resp, err := handler(ctx, req)

        // Calculate duration
        duration := time.Since(start)

        // Record metrics
        statusCode := status.Code(err)

        // Update span
        if err != nil {
            span.RecordError(err)
            span.SetStatus(codes.Error, err.Error())
            logger.Error("Request failed",
                "method", info.FullMethod,
                "request_id", requestID,
                "duration_ms", duration.Milliseconds(),
                "error", err.Error(),
                "status", statusCode.String(),
            )
        } else {
            span.SetStatus(codes.Ok, "")
            logger.Info("Request completed",
                "method", info.FullMethod,
                "request_id", requestID,
                "duration_ms", duration.Milliseconds(),
            )
        }

        return resp, err
    }
}

func getRequestID(ctx context.Context) string {
    md, ok := metadata.FromIncomingContext(ctx)
    if !ok {
        return ""
    }

    values := md.Get("x-request-id")
    if len(values) == 0 {
        return ""
    }

    return values[0]
}

func extractService(fullMethod string) string {
    // fullMethod format: /package.Service/Method
    parts := strings.Split(fullMethod, "/")
    if len(parts) >= 2 {
        serviceParts := strings.Split(parts[1], ".")
        if len(serviceParts) > 0 {
            return serviceParts[len(serviceParts)-1]
        }
    }
    return "unknown"
}

func extractMethod(fullMethod string) string {
    // fullMethod format: /package.Service/Method
    parts := strings.Split(fullMethod, "/")
    if len(parts) >= 3 {
        return parts[2]
    }
    return "unknown"
}

// Simple logger implementation
type SimpleLogger struct{}

func (l *SimpleLogger) Info(msg string, fields ...interface{}) {
    log.Printf("[INFO] %s %v", msg, fields)
}

func (l *SimpleLogger) Error(msg string, fields ...interface{}) {
    log.Printf("[ERROR] %s %v", msg, fields)
}

func (l *SimpleLogger) Warn(msg string, fields ...interface{}) {
    log.Printf("[WARN] %s %v", msg, fields)
}
```

---

## Rate Limiting Interceptor

Token bucket rate limiting for gRPC services.

```go
// rate_limit_interceptor.go
package interceptor

import (
    "context"
    "sync"
    "time"

    "golang.org/x/time/rate"
    "google.golang.org/grpc"
    "google.golang.org/grpc/codes"
    "google.golang.org/grpc/metadata"
    "google.golang.org/grpc/status"
)

type RateLimiter struct {
    limiters map[string]*rate.Limiter
    mu       sync.RWMutex
    rate     rate.Limit
    burst    int
}

func NewRateLimiter(requestsPerSecond int, burst int) *RateLimiter {
    return &RateLimiter{
        limiters: make(map[string]*rate.Limiter),
        rate:     rate.Limit(requestsPerSecond),
        burst:    burst,
    }
}

func (rl *RateLimiter) getLimiter(key string) *rate.Limiter {
    rl.mu.RLock()
    limiter, exists := rl.limiters[key]
    rl.mu.RUnlock()

    if !exists {
        rl.mu.Lock()
        limiter = rate.NewLimiter(rl.rate, rl.burst)
        rl.limiters[key] = limiter
        rl.mu.Unlock()
    }

    return limiter
}

func RateLimitInterceptor(rl *RateLimiter) grpc.UnaryServerInterceptor {
    return func(
        ctx context.Context,
        req interface{},
        info *grpc.UnaryServerInfo,
        handler grpc.UnaryHandler,
    ) (interface{}, error) {
        // Get rate limit key (e.g., user ID, IP address)
        key := getRateLimitKey(ctx)

        limiter := rl.getLimiter(key)

        if !limiter.Allow() {
            return nil, status.Error(
                codes.ResourceExhausted,
                "rate limit exceeded, please try again later",
            )
        }

        return handler(ctx, req)
    }
}

func getRateLimitKey(ctx context.Context) string {
    // Try to get user ID from claims
    if claims, err := GetClaims(ctx); err == nil {
        return "user:" + claims.UserID
    }

    // Fallback to IP address or other identifier
    md, ok := metadata.FromIncomingContext(ctx)
    if ok {
        if ips := md.Get("x-forwarded-for"); len(ips) > 0 {
            return "ip:" + ips[0]
        }
    }

    return "default"
}

// Per-method rate limiting
type MethodRateLimiter struct {
    limiters map[string]*RateLimiter
    mu       sync.RWMutex
}

func NewMethodRateLimiter() *MethodRateLimiter {
    return &MethodRateLimiter{
        limiters: make(map[string]*RateLimiter),
    }
}

func (mrl *MethodRateLimiter) SetMethodLimit(method string, requestsPerSecond, burst int) {
    mrl.mu.Lock()
    defer mrl.mu.Unlock()

    mrl.limiters[method] = NewRateLimiter(requestsPerSecond, burst)
}

func MethodRateLimitInterceptor(mrl *MethodRateLimiter) grpc.UnaryServerInterceptor {
    return func(
        ctx context.Context,
        req interface{},
        info *grpc.UnaryServerInfo,
        handler grpc.UnaryHandler,
    ) (interface{}, error) {
        mrl.mu.RLock()
        limiter, exists := mrl.limiters[info.FullMethod]
        mrl.mu.RUnlock()

        if !exists {
            // No rate limit for this method
            return handler(ctx, req)
        }

        key := getRateLimitKey(ctx)
        methodLimiter := limiter.getLimiter(key)

        if !methodLimiter.Allow() {
            return nil, status.Error(
                codes.ResourceExhausted,
                "rate limit exceeded for this method",
            )
        }

        return handler(ctx, req)
    }
}

// Example usage
func setupRateLimiting() grpc.ServerOption {
    // Global rate limiting: 100 requests/second per user/IP
    globalRL := NewRateLimiter(100, 200)

    // Per-method rate limiting
    methodRL := NewMethodRateLimiter()
    methodRL.SetMethodLimit("/user.v1.UserService/CreateUser", 10, 20)
    methodRL.SetMethodLimit("/user.v1.UserService/DeleteUser", 5, 10)

    return grpc.ChainUnaryInterceptor(
        RateLimitInterceptor(globalRL),
        MethodRateLimitInterceptor(methodRL),
    )
}
```

This completes the first half of the examples. Due to length constraints, I'll create the remaining examples (9-18) in the response that follows. The file now contains:

1. ✅ Basic Protobuf Schemas
2. ✅ Unary RPC - User Service
3. ✅ Server Streaming - Product Catalog
4. ✅ Client Streaming - Metrics Collection
5. ✅ Bidirectional Streaming - Chat Application
6. ✅ Authentication Interceptor
7. ✅ Logging and Tracing Interceptor
8. ✅ Rate Limiting Interceptor

Remaining examples to add:
9. Error Handling Patterns
10. Load Balancing with Service Discovery
11. Health Check Service
12. TLS/SSL Configuration
13. Kubernetes Deployment
14. Multi-Language Interop (Go + Python)
15. Event Streaming System
16. File Upload Service
17. Real-Time Notifications
18. Transaction Processing Service
