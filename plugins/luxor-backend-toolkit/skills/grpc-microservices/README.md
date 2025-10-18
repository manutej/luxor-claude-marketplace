# gRPC Microservices Skill

A comprehensive skill for building production-grade microservices with gRPC and Protocol Buffers.

## Overview

This skill provides complete guidance for designing, implementing, and deploying high-performance microservices using gRPC. It covers everything from basic protobuf schema design to advanced patterns like bidirectional streaming, interceptors, load balancing, and service mesh integration.

## What is gRPC?

gRPC (gRPC Remote Procedure Call) is a modern, open-source, high-performance RPC framework that can run in any environment. It was originally developed by Google and is now part of the Cloud Native Computing Foundation (CNCF).

### Key Features

- **High Performance**: Built on HTTP/2, multiplexing, header compression
- **Protocol Buffers**: Efficient binary serialization (3-10x smaller, 20-100x faster than JSON)
- **Streaming**: First-class support for unary, server, client, and bidirectional streaming
- **Language Agnostic**: Official support for 10+ programming languages
- **Type Safety**: Strong typing with automatic code generation
- **Deadlines/Timeouts**: Built-in support for request timeouts
- **Cancellation**: Propagate cancellation signals across service boundaries
- **Load Balancing**: Client-side load balancing built-in
- **Interceptors**: Middleware pattern for cross-cutting concerns

## When to Use gRPC

### Ideal Use Cases

✅ **Microservices Communication**
- Internal service-to-service communication
- High-throughput, low-latency requirements
- Type-safe contracts between services

✅ **Real-Time Streaming**
- Live data feeds
- Chat applications
- Collaborative editing
- Gaming applications
- IoT telemetry

✅ **Polyglot Systems**
- Services written in different languages
- Need for consistent API definitions
- Automatic client generation

✅ **Mobile to Backend**
- Efficient bandwidth usage
- Battery-efficient communication
- Strong typing for mobile apps

### When NOT to Use gRPC

❌ **Browser-First Applications**
- Limited browser support (requires grpc-web)
- REST/GraphQL may be better for web frontends

❌ **Public APIs**
- REST is more widely understood
- Better tooling for REST (Swagger, Postman)
- Easier to debug and test

❌ **Simple CRUD Services**
- Overhead of protobuf definitions
- REST may be simpler for basic operations

## Quick Start

### Prerequisites

- Protocol Buffer Compiler (protoc)
- Language-specific gRPC plugins
- Basic understanding of RPC concepts

### Installation

**Go:**
```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

**Python:**
```bash
pip install grpcio grpcio-tools
```

**Node.js:**
```bash
npm install @grpc/grpc-js @grpc/proto-loader
```

**Java:**
```xml
<dependency>
    <groupId>io.grpc</groupId>
    <artifactId>grpc-netty-shaded</artifactId>
    <version>1.58.0</version>
</dependency>
```

### Your First gRPC Service

**1. Define the service (user.proto):**

```protobuf
syntax = "proto3";

package user;

option go_package = "github.com/example/user/pb";

service UserService {
  rpc GetUser(GetUserRequest) returns (User);
  rpc ListUsers(ListUsersRequest) returns (stream User);
}

message GetUserRequest {
  int32 id = 1;
}

message ListUsersRequest {
  int32 page_size = 1;
  string page_token = 2;
}

message User {
  int32 id = 1;
  string name = 2;
  string email = 3;
}
```

**2. Generate code:**

```bash
# Go
protoc --go_out=. --go_opt=paths=source_relative \
       --go-grpc_out=. --go-grpc_opt=paths=source_relative \
       user.proto

# Python
python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. user.proto

# Node.js (using dynamic loading, no generation needed)
```

**3. Implement the server (Go):**

```go
package main

import (
    "context"
    "log"
    "net"

    pb "github.com/example/user/pb"
    "google.golang.org/grpc"
)

type server struct {
    pb.UnimplementedUserServiceServer
}

func (s *server) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.User, error) {
    return &pb.User{
        Id:    req.Id,
        Name:  "John Doe",
        Email: "john@example.com",
    }, nil
}

func (s *server) ListUsers(req *pb.ListUsersRequest, stream pb.UserService_ListUsersServer) error {
    users := []*pb.User{
        {Id: 1, Name: "Alice", Email: "alice@example.com"},
        {Id: 2, Name: "Bob", Email: "bob@example.com"},
    }

    for _, user := range users {
        if err := stream.Send(user); err != nil {
            return err
        }
    }

    return nil
}

func main() {
    lis, err := net.Listen("tcp", ":50051")
    if err != nil {
        log.Fatalf("failed to listen: %v", err)
    }

    s := grpc.NewServer()
    pb.RegisterUserServiceServer(s, &server{})

    log.Printf("Server listening on :50051")
    if err := s.Serve(lis); err != nil {
        log.Fatalf("failed to serve: %v", err)
    }
}
```

**4. Create a client (Go):**

```go
package main

import (
    "context"
    "io"
    "log"
    "time"

    pb "github.com/example/user/pb"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
)

func main() {
    conn, err := grpc.Dial("localhost:50051", grpc.WithTransportCredentials(insecure.NewCredentials()))
    if err != nil {
        log.Fatalf("did not connect: %v", err)
    }
    defer conn.Close()

    client := pb.NewUserServiceClient(conn)

    // Unary call
    ctx, cancel := context.WithTimeout(context.Background(), time.Second)
    defer cancel()

    user, err := client.GetUser(ctx, &pb.GetUserRequest{Id: 1})
    if err != nil {
        log.Fatalf("GetUser failed: %v", err)
    }
    log.Printf("User: %v", user)

    // Streaming call
    stream, err := client.ListUsers(ctx, &pb.ListUsersRequest{PageSize: 10})
    if err != nil {
        log.Fatalf("ListUsers failed: %v", err)
    }

    for {
        user, err := stream.Recv()
        if err == io.EOF {
            break
        }
        if err != nil {
            log.Fatalf("stream error: %v", err)
        }
        log.Printf("User: %v", user)
    }
}
```

**5. Run:**

```bash
# Terminal 1 - Start server
go run server.go

# Terminal 2 - Run client
go run client.go
```

## Core Concepts

### Protocol Buffers

Protocol Buffers (protobuf) is a language-neutral data serialization format.

**Key Concepts:**
- **Messages**: Structured data definitions
- **Fields**: Typed fields with unique numbers
- **Field Numbers**: Permanent identifiers (never reuse!)
- **Types**: Scalar (int32, string, bool), messages, enums, repeated, maps

**Example:**
```protobuf
message User {
  int32 id = 1;              // Field number 1
  string name = 2;           // Field number 2
  repeated string tags = 3;  // Array of strings

  enum Role {
    ROLE_UNSPECIFIED = 0;
    ROLE_USER = 1;
    ROLE_ADMIN = 2;
  }
  Role role = 4;
}
```

### Service Definitions

Services define RPC methods and their request/response types.

```protobuf
service ProductService {
  // Unary RPC
  rpc GetProduct(GetProductRequest) returns (Product);

  // Server streaming
  rpc ListProducts(ListProductsRequest) returns (stream Product);

  // Client streaming
  rpc CreateProducts(stream CreateProductRequest) returns (CreateProductsResponse);

  // Bidirectional streaming
  rpc UpdateProducts(stream ProductUpdate) returns (stream ProductUpdate);
}
```

### Four RPC Types

**1. Unary RPC** - Single request, single response
```
Client → Server
Client ← Server (single response)
```

**2. Server Streaming** - Single request, stream of responses
```
Client → Server
Client ← Server (response 1)
Client ← Server (response 2)
Client ← Server (response 3)
...
```

**3. Client Streaming** - Stream of requests, single response
```
Client → Server (request 1)
Client → Server (request 2)
Client → Server (request 3)
...
Client ← Server (final response)
```

**4. Bidirectional Streaming** - Both send streams independently
```
Client ⇄ Server (both send/receive independently)
```

## Streaming Patterns

### Server Streaming Use Cases

- **Pagination**: Stream large result sets
- **Real-time Updates**: Push server events to clients
- **Log Tailing**: Stream log entries as they occur
- **File Downloads**: Stream file chunks
- **Notifications**: Push notifications to clients

### Client Streaming Use Cases

- **File Uploads**: Upload large files in chunks
- **Bulk Operations**: Send many items to process
- **Telemetry**: Send metrics/logs to server
- **Batch Processing**: Aggregate client data

### Bidirectional Streaming Use Cases

- **Chat Applications**: Real-time messaging
- **Collaborative Editing**: Google Docs-style editing
- **Gaming**: Real-time multiplayer state sync
- **IoT**: Bidirectional device communication
- **Trading Systems**: Real-time price feeds and orders

## Interceptors (Middleware)

Interceptors provide a way to add cross-cutting concerns without modifying service logic.

### Common Interceptor Patterns

**Authentication:**
```go
func AuthInterceptor(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
    // Extract and validate token
    // Add user info to context
    // Call handler
}
```

**Logging:**
```go
func LoggingInterceptor(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
    start := time.Now()
    resp, err := handler(ctx, req)
    log.Printf("Method: %s, Duration: %v", info.FullMethod, time.Since(start))
    return resp, err
}
```

**Rate Limiting:**
```go
func RateLimitInterceptor(limiter *rate.Limiter) grpc.UnaryServerInterceptor {
    return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
        if !limiter.Allow() {
            return nil, status.Error(codes.ResourceExhausted, "rate limit exceeded")
        }
        return handler(ctx, req)
    }
}
```

**Tracing (OpenTelemetry):**
```go
func TracingInterceptor(tracer trace.Tracer) grpc.UnaryServerInterceptor {
    return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
        ctx, span := tracer.Start(ctx, info.FullMethod)
        defer span.End()

        resp, err := handler(ctx, req)
        if err != nil {
            span.RecordError(err)
        }
        return resp, err
    }
}
```

### Chaining Interceptors

```go
server := grpc.NewServer(
    grpc.ChainUnaryInterceptor(
        RecoveryInterceptor(),
        LoggingInterceptor(),
        TracingInterceptor(tracer),
        AuthInterceptor(secret),
        RateLimitInterceptor(limiter),
    ),
)
```

## Load Balancing

### Client-Side Load Balancing

gRPC supports client-side load balancing with multiple policies:

**Round Robin:**
```go
conn, err := grpc.Dial(
    "dns:///my-service:50051",
    grpc.WithDefaultServiceConfig(`{"loadBalancingPolicy":"round_robin"}`),
)
```

**Custom Service Discovery:**
Implement custom resolvers for Consul, etcd, Kubernetes, etc.

### Server-Side Load Balancing

Use a load balancer (L4/L7) in front of gRPC services:
- NGINX with HTTP/2 support
- Envoy proxy
- HAProxy with HTTP/2
- Cloud load balancers (AWS ALB, GCP Load Balancer)

### Service Mesh Integration

Use service meshes for advanced traffic management:
- **Istio**: Full-featured service mesh
- **Linkerd**: Lightweight service mesh
- **Consul Connect**: Service mesh by HashiCorp

## Error Handling

### Status Codes

gRPC uses standardized status codes similar to HTTP but designed for RPC:

```go
import "google.golang.org/grpc/status"
import "google.golang.org/grpc/codes"

// Return errors with appropriate codes
return nil, status.Error(codes.NotFound, "user not found")
return nil, status.Error(codes.InvalidArgument, "invalid user ID")
return nil, status.Error(codes.Unauthenticated, "authentication required")
```

### Rich Error Details

Add structured error information:

```go
import "google.golang.org/genproto/googleapis/rpc/errdetails"

badRequest := &errdetails.BadRequest{}
badRequest.FieldViolations = append(badRequest.FieldViolations,
    &errdetails.BadRequest_FieldViolation{
        Field:       "email",
        Description: "must be a valid email address",
    },
)

st := status.New(codes.InvalidArgument, "validation failed")
st, _ = st.WithDetails(badRequest)
return nil, st.Err()
```

### Retry Logic

Implement retry logic for transient failures:

```go
func CallWithRetry(ctx context.Context, maxRetries int, fn func() error) error {
    for i := 0; i < maxRetries; i++ {
        err := fn()
        if err == nil {
            return nil
        }

        // Only retry specific error codes
        st := status.Convert(err)
        if st.Code() != codes.Unavailable && st.Code() != codes.DeadlineExceeded {
            return err
        }

        // Exponential backoff
        backoff := time.Duration(math.Pow(2, float64(i))) * time.Second
        time.Sleep(backoff)
    }
    return err
}
```

## Security

### TLS/SSL

Always use TLS in production:

**Server:**
```go
creds, err := credentials.NewServerTLSFromFile(certFile, keyFile)
server := grpc.NewServer(grpc.Creds(creds))
```

**Client:**
```go
creds, err := credentials.NewClientTLSFromFile(certFile, "")
conn, err := grpc.Dial(address, grpc.WithTransportCredentials(creds))
```

### Mutual TLS (mTLS)

For service-to-service authentication:

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
```

### Token-Based Authentication

Use OAuth2, JWT, or custom tokens:

```go
type tokenAuth struct {
    token string
}

func (t tokenAuth) GetRequestMetadata(ctx context.Context, uri ...string) (map[string]string, error) {
    return map[string]string{
        "authorization": "Bearer " + t.token,
    }, nil
}

conn, err := grpc.Dial(
    address,
    grpc.WithPerRPCCredentials(tokenAuth{token: "my-token"}),
)
```

## Production Deployment

### Docker

**Dockerfile:**
```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o server ./cmd/server

FROM alpine:latest
COPY --from=builder /app/server .
EXPOSE 50051
CMD ["./server"]
```

### Kubernetes

**Deployment:**
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
        livenessProbe:
          exec:
            command: ["/bin/grpc_health_probe", "-addr=:50051"]
        readinessProbe:
          exec:
            command: ["/bin/grpc_health_probe", "-addr=:50051"]
```

### Health Checks

Implement standard gRPC health checking:

```go
import "google.golang.org/grpc/health"
import healthpb "google.golang.org/grpc/health/grpc_health_v1"

healthServer := health.NewServer()
healthpb.RegisterHealthServer(grpcServer, healthServer)
healthServer.SetServingStatus("", healthpb.HealthCheckResponse_SERVING)
```

### Monitoring

Use Prometheus for metrics:

```go
import "github.com/grpc-ecosystem/go-grpc-prometheus"

grpcMetrics := grpc_prometheus.NewServerMetrics()
server := grpc.NewServer(
    grpc.UnaryInterceptor(grpcMetrics.UnaryServerInterceptor()),
)
grpcMetrics.InitializeMetrics(server)
```

## Best Practices

### ✅ DO:

1. **Use streaming for large datasets** - More efficient than repeated unary calls
2. **Implement proper error handling** - Use appropriate status codes
3. **Set timeouts and deadlines** - Prevent hanging requests
4. **Use TLS in production** - Encrypt all traffic
5. **Implement health checks** - For load balancer integration
6. **Add monitoring and tracing** - Observability is critical
7. **Version your APIs** - Plan for evolution
8. **Reuse connections** - Don't create per-request
9. **Use interceptors for cross-cutting concerns** - DRY principle
10. **Test thoroughly** - Unit and integration tests

### ❌ DON'T:

1. **Don't use unary for large data** - Use streaming instead
2. **Don't ignore context cancellation** - Respect client cancellation
3. **Don't skip authentication** - Always validate requests
4. **Don't forget graceful shutdown** - Handle SIGTERM properly
5. **Don't hardcode endpoints** - Use service discovery
6. **Don't reuse field numbers** - Breaking change!
7. **Don't skip health checks** - Required for production
8. **Don't ignore deadlines** - Set appropriate timeouts
9. **Don't create connections per request** - Performance killer
10. **Don't deploy without monitoring** - You're flying blind

## Language Support

gRPC officially supports:

- **C/C++**: High performance implementations
- **Go**: First-class support, widely used
- **Java**: Mature, production-ready
- **Python**: Great for ML/data services
- **C#**: .NET integration
- **Node.js**: JavaScript ecosystem
- **Ruby**: Web service backends
- **PHP**: Web application integration
- **Objective-C**: iOS applications
- **Dart**: Flutter mobile apps

Community support for many more languages including Rust, Swift, Kotlin, Scala, etc.

## Resources

### Official Documentation
- gRPC.io: https://grpc.io
- Protocol Buffers: https://protobuf.dev
- gRPC GitHub: https://github.com/grpc/grpc

### Language Guides
- Go: https://grpc.io/docs/languages/go/
- Python: https://grpc.io/docs/languages/python/
- Java: https://grpc.io/docs/languages/java/
- Node.js: https://grpc.io/docs/languages/node/

### Tools
- grpcurl: CLI for gRPC (like curl for REST)
- grpc_health_probe: Kubernetes health checks
- BloomRPC: GUI client for gRPC
- Postman: gRPC support in recent versions

### Learning Resources
- gRPC Up and Running (O'Reilly)
- gRPC Microservices (Packt)
- Official tutorials: https://grpc.io/docs/tutorials/

## What's Included in This Skill

### SKILL.md
Comprehensive guide covering:
- Core concepts and fundamentals
- Protobuf schema design patterns
- All four RPC types with examples
- Streaming patterns and use cases
- Interceptor implementations
- Load balancing strategies
- Error handling patterns
- Security best practices
- Production deployment guides
- 15+ detailed patterns

### EXAMPLES.md
Practical, runnable examples:
- Complete protobuf schemas
- Unary RPC implementations
- Server streaming examples
- Client streaming examples
- Bidirectional streaming chat
- Authentication interceptors
- Load balancing configurations
- Health check implementations
- Multi-language interop examples
- Production deployment configurations

## Common Issues & Troubleshooting

### Connection Issues

**Problem**: `rpc error: code = Unavailable desc = connection refused`

**Solutions:**
- Verify server is running: `netstat -an | grep 50051`
- Check firewall settings allow gRPC traffic
- Ensure correct host and port in client connection
- Verify network connectivity between client and server

**Problem**: `rpc error: code = DeadlineExceeded`

**Solutions:**
- Increase context timeout on client side
- Check server performance and resource usage
- Verify network latency is acceptable
- Review server-side processing time
- Check for blocking operations in handlers

### Protobuf Issues

**Problem**: `proto: duplicate field number`

**Solution:**
- Each field must have a unique number within a message
- Never reuse field numbers, even for deleted fields
- Use `reserved` keyword for deprecated field numbers

**Problem**: `protoc: command not found`

**Solution:**
```bash
# macOS
brew install protobuf

# Ubuntu/Debian
sudo apt-get install protobuf-compiler

# Or download from https://github.com/protocolbuffers/protobuf/releases
```

### Code Generation Issues

**Problem**: Generated code not found after running protoc

**Solution:**
- Verify output path is correct: `--go_out=.`
- Check Go module path matches `go_package` option
- Ensure protoc plugins are installed:
  ```bash
  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
  ```
- Add `$GOPATH/bin` to your PATH

### Streaming Issues

**Problem**: Stream hangs or blocks indefinitely

**Solution:**
- Always check `err == io.EOF` when receiving
- Call `stream.CloseSend()` when client is done sending
- Set appropriate context timeouts
- Handle context cancellation properly

**Problem**: Messages not received in streaming RPC

**Solution:**
- Ensure `stream.Send()` is called correctly
- Check for errors after each send
- Verify receiver is calling `stream.Recv()` in a loop
- Check message buffering and flow control

### Performance Issues

**Problem**: Slow RPC calls

**Solutions:**
- Enable connection pooling on client side
- Use streaming RPCs for large datasets
- Implement request batching where appropriate
- Enable HTTP/2 multiplexing
- Check for network latency issues
- Profile server-side handlers

**Problem**: High memory usage

**Solutions:**
- Stream large payloads instead of sending all at once
- Implement backpressure in streaming RPCs
- Set appropriate message size limits
- Monitor goroutine leaks on server
- Use connection pooling with limits

## Frequently Asked Questions

### When should I use gRPC vs REST?

**Use gRPC when:**
- Building internal microservices
- Need high performance and low latency
- Require bidirectional streaming
- Want type-safe contracts
- Building polyglot systems

**Use REST when:**
- Building public APIs
- Need broad client compatibility
- Want simple debugging with browser/curl
- Require human-readable payloads
- Have simple CRUD operations

### Can I use gRPC from a web browser?

Yes, but with limitations. Use grpc-web for browser clients:
- Requires a proxy (Envoy, grpc-web proxy)
- Limited streaming support (server streaming only)
- Additional complexity in deployment

For new projects, consider:
- Using gRPC for service-to-service communication
- Using REST or GraphQL for browser clients
- Using WebSockets for real-time browser features

### How do I version my gRPC APIs?

**Option 1: Package versioning**
```protobuf
package myservice.v1;
package myservice.v2;
```

**Option 2: Service versioning**
```protobuf
service UserServiceV1 { }
service UserServiceV2 { }
```

**Option 3: Field evolution**
- Add new optional fields
- Never remove fields, use `reserved`
- Use `oneof` for alternative fields
- Maintain backward compatibility

### How do I handle authentication?

**Token-based (recommended):**
1. Client sends JWT/OAuth token in metadata
2. Server validates in interceptor
3. Add user context for downstream handlers

**mTLS (service-to-service):**
1. Configure certificates on both sides
2. Enable client certificate verification
3. Extract identity from certificate

**API keys:**
1. Pass in metadata: `x-api-key`
2. Validate in interceptor
3. Rate limit per key

### What's the maximum message size?

**Default limits:**
- Server receive: 4 MB
- Client send: unlimited (limited by memory)

**Change limits:**
```go
// Server
grpc.NewServer(
    grpc.MaxRecvMsgSize(10 * 1024 * 1024), // 10 MB
)

// Client
grpc.Dial(addr,
    grpc.WithDefaultCallOptions(
        grpc.MaxCallRecvMsgSize(10 * 1024 * 1024),
    ),
)
```

**Best practice:** Use streaming for large data instead of increasing limits.

### How do I handle errors properly?

**Always use status codes:**
```go
return nil, status.Error(codes.NotFound, "user not found")
```

**Add structured details:**
```go
st := status.New(codes.InvalidArgument, "validation failed")
st, _ = st.WithDetails(&errdetails.BadRequest{...})
return nil, st.Err()
```

**Client-side handling:**
```go
if err != nil {
    st := status.Convert(err)
    switch st.Code() {
    case codes.NotFound:
        // Handle not found
    case codes.InvalidArgument:
        // Handle invalid input
    default:
        // Handle other errors
    }
}
```

### How do I test gRPC services?

**Unit tests:**
- Test service implementation directly
- Mock dependencies
- Don't spin up gRPC server

**Integration tests:**
- Start in-process gRPC server
- Use test client
- Test full RPC cycle

**Example:**
```go
func TestUserService(t *testing.T) {
    // Setup
    lis := bufconn.Listen(bufSize)
    s := grpc.NewServer()
    pb.RegisterUserServiceServer(s, &userServer{})
    go s.Serve(lis)
    defer s.Stop()

    // Create client
    conn, _ := grpc.Dial("",
        grpc.WithContextDialer(func(context.Context, string) (net.Conn, error) {
            return lis.Dial()
        }),
        grpc.WithInsecure(),
    )
    defer conn.Close()

    client := pb.NewUserServiceClient(conn)

    // Test
    user, err := client.GetUser(ctx, &pb.GetUserRequest{Id: 1})
    assert.NoError(t, err)
    assert.Equal(t, "John", user.Name)
}
```

## Performance Tips

1. **Reuse connections**: Create one connection and reuse across requests
2. **Use connection pooling**: For high-throughput clients
3. **Enable keepalive**: Prevent connection drops
4. **Use streaming**: For large datasets and real-time data
5. **Implement backpressure**: Control flow in streams
6. **Profile your code**: Use pprof to identify bottlenecks
7. **Monitor metrics**: Track latency, throughput, errors
8. **Use proper timeouts**: Set context deadlines
9. **Batch operations**: When possible, batch multiple items
10. **Optimize protobuf**: Keep messages small and flat

---

**Skill Version**: 1.0.0
**Last Updated**: October 2025
**Maintained By**: Claude Skills Team
