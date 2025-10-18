---
name: grpc-microservices
description: Comprehensive gRPC microservices skill covering protobuf schemas, service definitions, streaming patterns, interceptors, load balancing, and production gRPC architecture
---

# gRPC Microservices

A comprehensive skill for building high-performance, type-safe microservices using gRPC and Protocol Buffers. This skill covers service design, all streaming patterns, interceptors, load balancing, error handling, and production deployment patterns for distributed systems.

## When to Use This Skill

Use this skill when:

- Building microservices that require high-performance, low-latency communication
- Implementing real-time data streaming between services
- Designing type-safe APIs with strong contracts using Protocol Buffers
- Creating polyglot systems where services are written in different languages
- Building distributed systems requiring bidirectional streaming
- Implementing service meshes with advanced routing and observability
- Designing APIs that need to evolve with backward/forward compatibility
- Creating internal APIs where performance and type safety are critical
- Building event-driven architectures with streaming data pipelines
- Implementing client-server systems with push capabilities (server streaming)
- Designing systems requiring efficient binary serialization
- Building microservices requiring automatic code generation for multiple languages

## Core Concepts

### gRPC Fundamentals

gRPC is a modern open-source RPC framework that can run anywhere. It enables client and server applications to communicate transparently and makes it easier to build connected systems.

**Key Characteristics:**
- **HTTP/2 based**: Multiplexing, server push, header compression
- **Protocol Buffers**: Efficient binary serialization format
- **Streaming**: Bidirectional streaming support built-in
- **Code Generation**: Auto-generate client/server code in 10+ languages
- **Deadlines/Timeouts**: First-class timeout support
- **Cancellation**: Propagate cancellation across services
- **Interceptors**: Middleware pattern for cross-cutting concerns

### Protocol Buffers (protobuf)

Protocol Buffers is a language-neutral, platform-neutral extensible mechanism for serializing structured data.

**Advantages:**
- **Compact**: 3-10x smaller than JSON
- **Fast**: 20-100x faster to serialize/deserialize than JSON
- **Type-safe**: Strongly typed schema with validation
- **Backward/Forward Compatible**: Evolve schemas safely
- **Language Support**: Official support for 10+ languages
- **Self-documenting**: Schema serves as documentation

**Basic Syntax:**
```protobuf
syntax = "proto3";

message User {
  int32 id = 1;
  string name = 2;
  string email = 3;
}
```

### Service Definitions

gRPC services are defined in `.proto` files and specify available methods and their input/output types.

**Basic Service:**
```protobuf
service UserService {
  rpc GetUser(GetUserRequest) returns (GetUserResponse);
  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse);
}
```

### Four Types of RPC Methods

#### 1. Unary RPC (Request-Response)
Simple request-response pattern, like a traditional REST API call.

```protobuf
rpc GetUser(GetUserRequest) returns (GetUserResponse);
```

**Use Cases:**
- CRUD operations
- Simple queries
- Synchronous operations
- Traditional request-response patterns

#### 2. Server Streaming RPC
Client sends one request, server returns a stream of responses.

```protobuf
rpc ListUsers(ListUsersRequest) returns (stream User);
```

**Use Cases:**
- Paginated results
- Real-time updates
- Server-side event push
- Large dataset downloads

#### 3. Client Streaming RPC
Client sends a stream of requests, server returns one response.

```protobuf
rpc CreateUsers(stream CreateUserRequest) returns (CreateUsersResponse);
```

**Use Cases:**
- Bulk uploads
- Batch processing
- Client-side aggregation
- File uploads in chunks

#### 4. Bidirectional Streaming RPC
Both client and server send streams of messages independently.

```protobuf
rpc Chat(stream ChatMessage) returns (stream ChatMessage);
```

**Use Cases:**
- Real-time chat applications
- Live collaboration
- Gaming (real-time state sync)
- IoT bidirectional communication

## Protobuf Schema Design

### Message Design Best Practices

**1. Use Explicit Field Numbers**

Field numbers are critical for backward compatibility and should never be reused.

```protobuf
message User {
  int32 id = 1;           // Never change this number
  string name = 2;        // Never change this number
  string email = 3;       // Never change this number
  // int32 age = 4;       // DEPRECATED - don't reuse 4
  string phone = 5;       // New field - use next available
}
```

**2. Use Enumerations for Fixed Sets**

```protobuf
enum UserRole {
  USER_ROLE_UNSPECIFIED = 0;  // Always have a zero value
  USER_ROLE_ADMIN = 1;
  USER_ROLE_MODERATOR = 2;
  USER_ROLE_MEMBER = 3;
}

message User {
  int32 id = 1;
  string name = 2;
  UserRole role = 3;
}
```

**3. Use Nested Messages for Complex Types**

```protobuf
message User {
  int32 id = 1;
  string name = 2;

  message Address {
    string street = 1;
    string city = 2;
    string state = 3;
    string zip = 4;
  }

  Address address = 3;
  repeated Address additional_addresses = 4;
}
```

**4. Use `repeated` for Arrays**

```protobuf
message UserList {
  repeated User users = 1;
}

message User {
  int32 id = 1;
  string name = 2;
  repeated string tags = 3;
}
```

**5. Use `oneof` for Union Types**

```protobuf
message SearchRequest {
  string query = 1;

  oneof filter {
    string category = 2;
    int32 user_id = 3;
    string tag = 4;
  }
}
```

**6. Use `google.protobuf` Well-Known Types**

```protobuf
import "google/protobuf/timestamp.proto";
import "google/protobuf/duration.proto";
import "google/protobuf/empty.proto";
import "google/protobuf/wrappers.proto";

message Event {
  string id = 1;
  string name = 2;
  google.protobuf.Timestamp created_at = 3;
  google.protobuf.Duration duration = 4;
  google.protobuf.Int32Value optional_count = 5;
}
```

### Service Design Patterns

**1. Resource-Oriented Design**

Follow RESTful principles adapted for RPC:

```protobuf
service UserService {
  // Get single resource
  rpc GetUser(GetUserRequest) returns (User);

  // List resources
  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse);

  // Create resource
  rpc CreateUser(CreateUserRequest) returns (User);

  // Update resource
  rpc UpdateUser(UpdateUserRequest) returns (User);

  // Delete resource
  rpc DeleteUser(DeleteUserRequest) returns (google.protobuf.Empty);
}
```

**2. Pagination Pattern**

```protobuf
message ListUsersRequest {
  int32 page_size = 1;
  string page_token = 2;
  string filter = 3;
}

message ListUsersResponse {
  repeated User users = 1;
  string next_page_token = 2;
  int32 total_count = 3;
}
```

**3. Batch Operations Pattern**

```protobuf
message BatchGetUsersRequest {
  repeated int32 user_ids = 1;
}

message BatchGetUsersResponse {
  map<int32, User> users = 1;
  repeated int32 not_found = 2;
}
```

**4. Long-Running Operations Pattern**

```protobuf
import "google/longrunning/operations.proto";

service BatchJobService {
  rpc ProcessBatch(BatchRequest) returns (google.longrunning.Operation);
  rpc GetOperation(GetOperationRequest) returns (google.longrunning.Operation);
}
```

## Streaming Patterns

### Server Streaming Patterns

**1. Pagination Streaming**

Stream large result sets efficiently:

```protobuf
service ProductService {
  rpc SearchProducts(SearchRequest) returns (stream Product);
}

message SearchRequest {
  string query = 1;
  int32 limit = 2;
}
```

**Implementation (Go):**
```go
func (s *server) SearchProducts(req *pb.SearchRequest, stream pb.ProductService_SearchProductsServer) error {
    products := s.db.Search(req.Query, req.Limit)

    for _, product := range products {
        if err := stream.Send(&product); err != nil {
            return err
        }
    }

    return nil
}
```

**2. Real-Time Updates**

Push updates to clients as they occur:

```protobuf
service EventService {
  rpc SubscribeToEvents(SubscribeRequest) returns (stream Event);
}

message SubscribeRequest {
  repeated string event_types = 1;
  google.protobuf.Timestamp since = 2;
}
```

**3. Log Tailing**

Stream logs or audit trails:

```protobuf
service LogService {
  rpc TailLogs(TailRequest) returns (stream LogEntry);
}

message TailRequest {
  string service_name = 1;
  string level = 2;
  int32 lines = 3;
}
```

### Client Streaming Patterns

**1. Bulk Upload**

Client streams data, server processes and returns summary:

```protobuf
service UploadService {
  rpc UploadImages(stream ImageChunk) returns (UploadSummary);
}

message ImageChunk {
  string filename = 1;
  bytes data = 2;
  int32 chunk_number = 3;
}

message UploadSummary {
  int32 total_images = 1;
  int64 total_bytes = 2;
  repeated string uploaded_filenames = 3;
}
```

**Implementation (Go):**
```go
func (s *server) UploadImages(stream pb.UploadService_UploadImagesServer) error {
    var count int32
    var totalBytes int64
    var filenames []string

    for {
        chunk, err := stream.Recv()
        if err == io.EOF {
            return stream.SendAndClose(&pb.UploadSummary{
                TotalImages: count,
                TotalBytes:  totalBytes,
                UploadedFilenames: filenames,
            })
        }
        if err != nil {
            return err
        }

        // Process chunk
        totalBytes += int64(len(chunk.Data))
        if chunk.ChunkNumber == 0 {
            count++
            filenames = append(filenames, chunk.Filename)
        }
    }
}
```

**2. Aggregation**

Client sends multiple data points, server aggregates:

```protobuf
service AnalyticsService {
  rpc RecordMetrics(stream Metric) returns (AggregateResult);
}

message Metric {
  string name = 1;
  double value = 2;
  google.protobuf.Timestamp timestamp = 3;
}
```

### Bidirectional Streaming Patterns

**1. Chat Application**

Real-time bidirectional communication:

```protobuf
service ChatService {
  rpc Chat(stream ChatMessage) returns (stream ChatMessage);
}

message ChatMessage {
  string user_id = 1;
  string room_id = 2;
  string content = 3;
  google.protobuf.Timestamp timestamp = 4;
}
```

**Implementation (Go):**
```go
func (s *server) Chat(stream pb.ChatService_ChatServer) error {
    // Create channel for this client
    clientID := uuid.New().String()
    msgChan := make(chan *pb.ChatMessage, 10)

    // Register client
    s.mu.Lock()
    s.clients[clientID] = msgChan
    s.mu.Unlock()

    defer func() {
        s.mu.Lock()
        delete(s.clients, clientID)
        close(msgChan)
        s.mu.Unlock()
    }()

    // Goroutine to send messages to client
    go func() {
        for msg := range msgChan {
            if err := stream.Send(msg); err != nil {
                return
            }
        }
    }()

    // Receive messages from client
    for {
        msg, err := stream.Recv()
        if err == io.EOF {
            return nil
        }
        if err != nil {
            return err
        }

        // Broadcast to all clients in room
        s.broadcast(msg)
    }
}
```

**2. Live Collaboration**

Real-time document editing:

```protobuf
service CollaborationService {
  rpc Collaborate(stream DocumentEdit) returns (stream DocumentEdit);
}

message DocumentEdit {
  string document_id = 1;
  string user_id = 2;
  int32 position = 3;
  string content = 4;
  enum Operation {
    OPERATION_UNSPECIFIED = 0;
    OPERATION_INSERT = 1;
    OPERATION_DELETE = 2;
    OPERATION_UPDATE = 3;
  }
  Operation operation = 5;
}
```

**3. Game State Synchronization**

Real-time multiplayer game updates:

```protobuf
service GameService {
  rpc PlayGame(stream GameAction) returns (stream GameState);
}

message GameAction {
  string player_id = 1;
  string game_id = 2;
  string action_type = 3;
  bytes action_data = 4;
}

message GameState {
  string game_id = 1;
  repeated PlayerState players = 2;
  bytes world_state = 3;
  google.protobuf.Timestamp timestamp = 4;
}
```

## Interceptors (Middleware)

Interceptors provide a way to add cross-cutting concerns to gRPC services.

### Unary Interceptors

**Server-side Unary Interceptor:**

```go
func UnaryServerInterceptor() grpc.UnaryServerInterceptor {
    return func(
        ctx context.Context,
        req interface{},
        info *grpc.UnaryServerInfo,
        handler grpc.UnaryHandler,
    ) (interface{}, error) {
        // Pre-processing
        start := time.Now()
        log.Printf("Method: %s, Start: %v", info.FullMethod, start)

        // Call the handler
        resp, err := handler(ctx, req)

        // Post-processing
        duration := time.Since(start)
        log.Printf("Method: %s, Duration: %v, Error: %v",
            info.FullMethod, duration, err)

        return resp, err
    }
}

// Usage
server := grpc.NewServer(
    grpc.UnaryInterceptor(UnaryServerInterceptor()),
)
```

**Client-side Unary Interceptor:**

```go
func UnaryClientInterceptor() grpc.UnaryClientInterceptor {
    return func(
        ctx context.Context,
        method string,
        req, reply interface{},
        cc *grpc.ClientConn,
        invoker grpc.UnaryInvoker,
        opts ...grpc.CallOption,
    ) error {
        start := time.Now()

        // Call the remote method
        err := invoker(ctx, method, req, reply, cc, opts...)

        log.Printf("Method: %s, Duration: %v, Error: %v",
            method, time.Since(start), err)

        return err
    }
}

// Usage
conn, err := grpc.Dial(
    address,
    grpc.WithUnaryInterceptor(UnaryClientInterceptor()),
)
```

### Streaming Interceptors

**Server-side Stream Interceptor:**

```go
func StreamServerInterceptor() grpc.StreamServerInterceptor {
    return func(
        srv interface{},
        ss grpc.ServerStream,
        info *grpc.StreamServerInfo,
        handler grpc.StreamHandler,
    ) error {
        log.Printf("Stream started: %s", info.FullMethod)

        err := handler(srv, ss)

        log.Printf("Stream ended: %s, Error: %v", info.FullMethod, err)

        return err
    }
}
```

### Common Interceptor Patterns

#### 1. Authentication Interceptor

```go
func AuthInterceptor(secret string) grpc.UnaryServerInterceptor {
    return func(
        ctx context.Context,
        req interface{},
        info *grpc.UnaryServerInfo,
        handler grpc.UnaryHandler,
    ) (interface{}, error) {
        // Extract metadata
        md, ok := metadata.FromIncomingContext(ctx)
        if !ok {
            return nil, status.Error(codes.Unauthenticated, "no metadata")
        }

        // Get authorization token
        tokens := md["authorization"]
        if len(tokens) == 0 {
            return nil, status.Error(codes.Unauthenticated, "no token")
        }

        // Validate token
        token := tokens[0]
        claims, err := validateJWT(token, secret)
        if err != nil {
            return nil, status.Error(codes.Unauthenticated, "invalid token")
        }

        // Add claims to context
        ctx = context.WithValue(ctx, "claims", claims)

        return handler(ctx, req)
    }
}
```

#### 2. Logging Interceptor

```go
func LoggingInterceptor(logger *log.Logger) grpc.UnaryServerInterceptor {
    return func(
        ctx context.Context,
        req interface{},
        info *grpc.UnaryServerInfo,
        handler grpc.UnaryHandler,
    ) (interface{}, error) {
        start := time.Now()

        // Get request ID from metadata
        requestID := getRequestID(ctx)

        logger.Printf("[%s] Request: %s", requestID, info.FullMethod)

        resp, err := handler(ctx, req)

        duration := time.Since(start)
        statusCode := status.Code(err)

        logger.Printf("[%s] Response: %s, Duration: %v, Status: %v",
            requestID, info.FullMethod, duration, statusCode)

        return resp, err
    }
}
```

#### 3. Rate Limiting Interceptor

```go
func RateLimitInterceptor(limiter *rate.Limiter) grpc.UnaryServerInterceptor {
    return func(
        ctx context.Context,
        req interface{},
        info *grpc.UnaryServerInfo,
        handler grpc.UnaryHandler,
    ) (interface{}, error) {
        if !limiter.Allow() {
            return nil, status.Error(
                codes.ResourceExhausted,
                "rate limit exceeded",
            )
        }

        return handler(ctx, req)
    }
}
```

#### 4. Tracing Interceptor (OpenTelemetry)

```go
func TracingInterceptor(tracer trace.Tracer) grpc.UnaryServerInterceptor {
    return func(
        ctx context.Context,
        req interface{},
        info *grpc.UnaryServerInfo,
        handler grpc.UnaryHandler,
    ) (interface{}, error) {
        ctx, span := tracer.Start(ctx, info.FullMethod)
        defer span.End()

        // Add attributes
        span.SetAttributes(
            attribute.String("rpc.method", info.FullMethod),
            attribute.String("rpc.service", "MyService"),
        )

        resp, err := handler(ctx, req)

        if err != nil {
            span.RecordError(err)
            span.SetStatus(codes2.Error, err.Error())
        } else {
            span.SetStatus(codes2.Ok, "")
        }

        return resp, err
    }
}
```

#### 5. Error Recovery Interceptor

```go
func RecoveryInterceptor() grpc.UnaryServerInterceptor {
    return func(
        ctx context.Context,
        req interface{},
        info *grpc.UnaryServerInfo,
        handler grpc.UnaryHandler,
    ) (resp interface{}, err error) {
        defer func() {
            if r := recover(); r != nil {
                log.Printf("Panic recovered: %v\n%s", r, debug.Stack())
                err = status.Error(codes.Internal, "internal server error")
            }
        }()

        return handler(ctx, req)
    }
}
```

### Chaining Multiple Interceptors

```go
server := grpc.NewServer(
    grpc.ChainUnaryInterceptor(
        RecoveryInterceptor(),
        LoggingInterceptor(logger),
        TracingInterceptor(tracer),
        AuthInterceptor(jwtSecret),
        RateLimitInterceptor(limiter),
    ),
    grpc.ChainStreamInterceptor(
        StreamRecoveryInterceptor(),
        StreamLoggingInterceptor(logger),
    ),
)
```

## Load Balancing

### Client-Side Load Balancing

gRPC provides built-in client-side load balancing with multiple policies.

**1. Round Robin**

```go
import "google.golang.org/grpc/balancer/roundrobin"

conn, err := grpc.Dial(
    "dns:///my-service.example.com:50051",
    grpc.WithDefaultServiceConfig(`{"loadBalancingPolicy":"round_robin"}`),
    grpc.WithInsecure(),
)
```

**2. Pick First (Default)**

```go
conn, err := grpc.Dial(
    "dns:///my-service.example.com:50051",
    grpc.WithDefaultServiceConfig(`{"loadBalancingPolicy":"pick_first"}`),
    grpc.WithInsecure(),
)
```

**3. Custom Resolver**

Implement custom service discovery:

```go
type exampleResolver struct {
    target     resolver.Target
    cc         resolver.ClientConn
    addrsStore map[string][]string
}

func (r *exampleResolver) ResolveNow(resolver.ResolveNowOptions) {
    // Discover service addresses
    addresses := r.discoverServices()

    var addrs []resolver.Address
    for _, addr := range addresses {
        addrs = append(addrs, resolver.Address{Addr: addr})
    }

    r.cc.UpdateState(resolver.State{Addresses: addrs})
}

func init() {
    resolver.Register(&exampleResolverBuilder{})
}
```

### Load Balancing with Service Mesh

**Kubernetes with Service Mesh (Istio/Linkerd):**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: grpc-service
spec:
  selector:
    app: grpc-app
  ports:
  - name: grpc
    port: 50051
    targetPort: 50051
    protocol: TCP
  type: ClusterIP
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: grpc-service
spec:
  host: grpc-service
  trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN
    connectionPool:
      http:
        http2MaxRequests: 1000
        maxRequestsPerConnection: 10
```

### Health Checking

Implement health check service:

```protobuf
service Health {
  rpc Check(HealthCheckRequest) returns (HealthCheckResponse);
  rpc Watch(HealthCheckRequest) returns (stream HealthCheckResponse);
}

message HealthCheckRequest {
  string service = 1;
}

message HealthCheckResponse {
  enum ServingStatus {
    UNKNOWN = 0;
    SERVING = 1;
    NOT_SERVING = 2;
    SERVICE_UNKNOWN = 3;
  }
  ServingStatus status = 1;
}
```

**Implementation:**

```go
import "google.golang.org/grpc/health"
import healthpb "google.golang.org/grpc/health/grpc_health_v1"

healthServer := health.NewServer()
healthpb.RegisterHealthServer(grpcServer, healthServer)

// Set service status
healthServer.SetServingStatus("UserService", healthpb.HealthCheckResponse_SERVING)
```

## Error Handling

### gRPC Status Codes

gRPC uses standardized status codes for error handling:

```go
import "google.golang.org/grpc/codes"
import "google.golang.org/grpc/status"

// Return errors with appropriate codes
func (s *server) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.User, error) {
    if req.Id <= 0 {
        return nil, status.Error(codes.InvalidArgument, "id must be positive")
    }

    user, err := s.db.GetUser(req.Id)
    if err == sql.ErrNoRows {
        return nil, status.Error(codes.NotFound, "user not found")
    }
    if err != nil {
        return nil, status.Error(codes.Internal, "database error")
    }

    return user, nil
}
```

**Common Status Codes:**
- `OK`: Success
- `Canceled`: Operation was cancelled
- `Unknown`: Unknown error
- `InvalidArgument`: Client specified invalid argument
- `DeadlineExceeded`: Deadline expired before operation
- `NotFound`: Entity not found
- `AlreadyExists`: Entity already exists
- `PermissionDenied`: Permission denied
- `ResourceExhausted`: Resource exhausted (rate limit)
- `FailedPrecondition`: Operation rejected (system not in valid state)
- `Aborted`: Operation aborted
- `OutOfRange`: Out of valid range
- `Unimplemented`: Operation not implemented
- `Internal`: Internal server error
- `Unavailable`: Service unavailable
- `DataLoss`: Unrecoverable data loss
- `Unauthenticated`: Request lacks valid authentication

### Rich Error Details

Add structured error details:

```go
import "google.golang.org/genproto/googleapis/rpc/errdetails"

func (s *server) CreateUser(ctx context.Context, req *pb.CreateUserRequest) (*pb.User, error) {
    // Validate request
    violations := validateCreateUserRequest(req)
    if len(violations) > 0 {
        badRequest := &errdetails.BadRequest{}
        for field, msg := range violations {
            badRequest.FieldViolations = append(
                badRequest.FieldViolations,
                &errdetails.BadRequest_FieldViolation{
                    Field:       field,
                    Description: msg,
                },
            )
        }

        st := status.New(codes.InvalidArgument, "invalid request")
        st, _ = st.WithDetails(badRequest)
        return nil, st.Err()
    }

    // Create user...
}
```

**Client-side error handling:**

```go
resp, err := client.CreateUser(ctx, req)
if err != nil {
    st := status.Convert(err)

    for _, detail := range st.Details() {
        switch t := detail.(type) {
        case *errdetails.BadRequest:
            for _, violation := range t.FieldViolations {
                fmt.Printf("Invalid field %s: %s\n",
                    violation.Field, violation.Description)
            }
        }
    }
}
```

### Error Propagation

```go
func (s *server) ProcessOrder(ctx context.Context, req *pb.OrderRequest) (*pb.OrderResponse, error) {
    // Call inventory service
    inventory, err := s.inventoryClient.CheckInventory(ctx, &pb.InventoryRequest{
        ProductId: req.ProductId,
    })
    if err != nil {
        // Propagate error with additional context
        st := status.Convert(err)
        return nil, status.Errorf(st.Code(),
            "inventory check failed: %v", st.Message())
    }

    // Continue processing...
}
```

### Retry Logic

```go
import "google.golang.org/grpc/codes"
import "google.golang.org/grpc/status"

func CallWithRetry(ctx context.Context, maxRetries int, fn func() error) error {
    var err error

    for i := 0; i < maxRetries; i++ {
        err = fn()
        if err == nil {
            return nil
        }

        // Check if error is retryable
        st := status.Convert(err)
        if !isRetryable(st.Code()) {
            return err
        }

        // Exponential backoff
        backoff := time.Duration(math.Pow(2, float64(i))) * time.Second
        time.Sleep(backoff)
    }

    return err
}

func isRetryable(code codes.Code) bool {
    return code == codes.Unavailable ||
           code == codes.DeadlineExceeded ||
           code == codes.ResourceExhausted
}
```

## Best Practices

### 1. Schema Evolution

**DO:**
- Always use `syntax = "proto3"`
- Never reuse field numbers
- Use `reserved` for deprecated fields
- Add new fields with new numbers
- Use optional wrappers for nullable fields

```protobuf
message User {
  int32 id = 1;
  string name = 2;
  // string age = 3;  // Deprecated
  reserved 3;
  reserved "age";

  string email = 4;
  google.protobuf.Int32Value phone = 5;  // Optional
}
```

**DON'T:**
- Change field types
- Reuse field numbers
- Remove fields without reserving numbers
- Change message names without aliases

### 2. Performance Optimization

**Connection Management:**
```go
// Reuse connections
var conn *grpc.ClientConn
var once sync.Once

func getConnection() *grpc.ClientConn {
    once.Do(func() {
        var err error
        conn, err = grpc.Dial(
            address,
            grpc.WithKeepaliveParams(keepalive.ClientParameters{
                Time:                10 * time.Second,
                Timeout:             3 * time.Second,
                PermitWithoutStream: true,
            }),
        )
        if err != nil {
            log.Fatal(err)
        }
    })
    return conn
}
```

**Connection Pooling:**
```go
type ConnectionPool struct {
    connections []*grpc.ClientConn
    next        uint32
}

func (p *ConnectionPool) GetConnection() *grpc.ClientConn {
    n := atomic.AddUint32(&p.next, 1)
    return p.connections[n%uint32(len(p.connections))]
}
```

**Streaming for Large Data:**
```protobuf
// Instead of this:
rpc GetAllUsers(Empty) returns (UserList);  // Large response

// Use this:
rpc ListUsers(ListUsersRequest) returns (stream User);  // Streamed
```

### 3. Security Best Practices

**TLS Configuration:**
```go
// Server-side
creds, err := credentials.NewServerTLSFromFile(certFile, keyFile)
server := grpc.NewServer(grpc.Creds(creds))

// Client-side
creds, err := credentials.NewClientTLSFromFile(certFile, "")
conn, err := grpc.Dial(address, grpc.WithTransportCredentials(creds))
```

**Mutual TLS (mTLS):**
```go
cert, err := tls.LoadX509KeyPair(certFile, keyFile)
certPool := x509.NewCertPool()
ca, err := ioutil.ReadFile(caFile)
certPool.AppendCertsFromPEM(ca)

creds := credentials.NewTLS(&tls.Config{
    Certificates: []tls.Certificate{cert},
    ClientAuth:   tls.RequireAndVerifyClientCert,
    ClientCAs:    certPool,
})

server := grpc.NewServer(grpc.Creds(creds))
```

**Token Authentication:**
```go
type tokenAuth struct {
    token string
}

func (t tokenAuth) GetRequestMetadata(ctx context.Context, uri ...string) (map[string]string, error) {
    return map[string]string{
        "authorization": "Bearer " + t.token,
    }, nil
}

func (t tokenAuth) RequireTransportSecurity() bool {
    return true
}

// Usage
conn, err := grpc.Dial(
    address,
    grpc.WithPerRPCCredentials(tokenAuth{token: "my-token"}),
)
```

### 4. Timeout and Deadline Management

```go
// Set deadline for request
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

resp, err := client.GetUser(ctx, &pb.GetUserRequest{Id: 123})
if err != nil {
    if status.Code(err) == codes.DeadlineExceeded {
        log.Println("Request timed out")
    }
}
```

**Server-side deadline propagation:**
```go
func (s *server) ComplexOperation(ctx context.Context, req *pb.Request) (*pb.Response, error) {
    // Check if deadline is already exceeded
    deadline, ok := ctx.Deadline()
    if ok && time.Now().After(deadline) {
        return nil, status.Error(codes.DeadlineExceeded, "deadline exceeded")
    }

    // Propagate context to downstream calls
    user, err := s.userClient.GetUser(ctx, &pb.GetUserRequest{Id: req.UserId})
    if err != nil {
        return nil, err
    }

    // Continue with remaining time...
}
```

### 5. Monitoring and Observability

**Prometheus Metrics:**
```go
import "github.com/grpc-ecosystem/go-grpc-prometheus"

// Server metrics
grpcMetrics := grpc_prometheus.NewServerMetrics()
server := grpc.NewServer(
    grpc.UnaryInterceptor(grpcMetrics.UnaryServerInterceptor()),
    grpc.StreamInterceptor(grpcMetrics.StreamServerInterceptor()),
)
grpcMetrics.InitializeMetrics(server)

// Expose metrics
http.Handle("/metrics", promhttp.Handler())
```

### 6. Graceful Shutdown

```go
server := grpc.NewServer()
// Register services...

go func() {
    if err := server.Serve(listener); err != nil {
        log.Fatalf("failed to serve: %v", err)
    }
}()

// Wait for interrupt signal
quit := make(chan os.Signal, 1)
signal.Notify(quit, os.Interrupt, syscall.SIGTERM)
<-quit

log.Println("Shutting down server...")

// Graceful shutdown
server.GracefulStop()
log.Println("Server stopped")
```

### 7. Service Versioning

**URL-based versioning:**
```protobuf
package api.v1;

service UserServiceV1 {
  rpc GetUser(GetUserRequest) returns (User);
}

package api.v2;

service UserServiceV2 {
  rpc GetUser(GetUserRequest) returns (User);
}
```

**Field-based versioning:**
```protobuf
message User {
  int32 id = 1;
  string name = 2;
  string email = 3;

  // v2 additions
  string phone = 4;
  Address address = 5;
}
```

### 8. Testing Best Practices

**Unit Testing with Mocks:**
```go
type mockUserClient struct {
    pb.UserServiceClient
    getUserFunc func(ctx context.Context, req *pb.GetUserRequest) (*pb.User, error)
}

func (m *mockUserClient) GetUser(ctx context.Context, req *pb.GetUserRequest, opts ...grpc.CallOption) (*pb.User, error) {
    return m.getUserFunc(ctx, req)
}

func TestOrderService(t *testing.T) {
    mockClient := &mockUserClient{
        getUserFunc: func(ctx context.Context, req *pb.GetUserRequest) (*pb.User, error) {
            return &pb.User{Id: 1, Name: "Test User"}, nil
        },
    }

    // Test with mock...
}
```

**Integration Testing:**
```go
func TestIntegration(t *testing.T) {
    // Start test server
    lis, err := net.Listen("tcp", ":0")
    require.NoError(t, err)

    server := grpc.NewServer()
    pb.RegisterUserServiceServer(server, &userServer{})

    go server.Serve(lis)
    defer server.Stop()

    // Connect client
    conn, err := grpc.Dial(lis.Addr().String(), grpc.WithInsecure())
    require.NoError(t, err)
    defer conn.Close()

    client := pb.NewUserServiceClient(conn)

    // Test requests...
}
```

## Production Deployment Patterns

### Docker Deployment

**Dockerfile:**
```dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o server ./cmd/server

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/

COPY --from=builder /app/server .
COPY --from=builder /app/proto ./proto

EXPOSE 50051

CMD ["./server"]
```

### Kubernetes Deployment

**deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grpc-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: grpc-service
  template:
    metadata:
      labels:
        app: grpc-service
    spec:
      containers:
      - name: grpc-service
        image: grpc-service:latest
        ports:
        - containerPort: 50051
          name: grpc
          protocol: TCP
        env:
        - name: PORT
          value: "50051"
        livenessProbe:
          exec:
            command: ["/bin/grpc_health_probe", "-addr=:50051"]
          initialDelaySeconds: 10
        readinessProbe:
          exec:
            command: ["/bin/grpc_health_probe", "-addr=:50051"]
          initialDelaySeconds: 5
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: grpc-service
spec:
  selector:
    app: grpc-service
  ports:
  - port: 50051
    targetPort: 50051
    protocol: TCP
    name: grpc
  type: ClusterIP
```

### Service Mesh Integration (Istio)

**VirtualService for traffic routing:**
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: grpc-service
spec:
  hosts:
  - grpc-service
  http:
  - match:
    - headers:
        version:
          exact: v2
    route:
    - destination:
        host: grpc-service
        subset: v2
  - route:
    - destination:
        host: grpc-service
        subset: v1
```

## Common Patterns and Anti-Patterns

### ✅ DO:

1. **Use streaming for large datasets**
2. **Implement proper error handling with status codes**
3. **Add interceptors for cross-cutting concerns**
4. **Use connection pooling for high-throughput clients**
5. **Implement health checks**
6. **Set appropriate timeouts and deadlines**
7. **Use TLS in production**
8. **Version your APIs**
9. **Monitor with metrics and tracing**
10. **Test with integration tests**

### ❌ DON'T:

1. **Don't use unary RPCs for large datasets** - Use streaming instead
2. **Don't ignore context cancellation** - Always check context.Done()
3. **Don't create new connections per request** - Reuse connections
4. **Don't skip authentication/authorization** - Always validate
5. **Don't forget graceful shutdown** - Handle SIGTERM properly
6. **Don't hardcode endpoints** - Use service discovery
7. **Don't ignore errors** - Handle all error cases
8. **Don't use blocking operations without timeouts** - Always set deadlines
9. **Don't skip health checks** - Implement liveness/readiness probes
10. **Don't deploy without monitoring** - Add metrics and logging

---

**Skill Version**: 1.0.0
**Last Updated**: October 2025
**Skill Category**: Microservices, gRPC, Distributed Systems, API Design
**Compatible With**: Go, Python, Node.js, Java, C++, C#, Ruby, and more
