# Enterprise Architecture Patterns

Quick reference guide for enterprise architecture patterns, distributed systems design, and scalable application development.

## Overview

This skill provides comprehensive coverage of modern enterprise architecture patterns including:

- Domain-Driven Design (DDD) - Strategic and tactical patterns
- Event Sourcing & CQRS - Event-driven architecture patterns
- Saga Patterns - Distributed transaction management
- API Gateway & Service Mesh - Service communication patterns
- Resilience Patterns - Building fault-tolerant systems
- Scalability Patterns - Horizontal and vertical scaling strategies

## Quick Start

### When to Use This Skill

Use enterprise architecture patterns when:

- Building microservices architectures
- Designing complex business domains
- Implementing event-driven systems
- Managing distributed transactions
- Scaling applications for high traffic
- Building resilient, fault-tolerant systems
- Migrating monoliths to microservices

### Core Pattern Categories

1. **Strategic DDD**: Bounded contexts, context mapping, ubiquitous language
2. **Tactical DDD**: Entities, value objects, aggregates, repositories, domain events
3. **Event Sourcing**: Event stores, event streams, projections, snapshots
4. **CQRS**: Command/query separation, read/write models, eventual consistency
5. **Sagas**: Orchestration, choreography, compensation
6. **API Patterns**: API Gateway, BFF, service mesh
7. **Resilience**: Circuit breaker, retry, bulkhead, timeout, fallback
8. **Scalability**: Horizontal scaling, caching, sharding, load balancing

## Pattern Catalog

### Domain-Driven Design Patterns

#### Strategic Patterns

| Pattern | Use Case | Key Benefit |
|---------|----------|-------------|
| Bounded Context | Define model boundaries | Clear scope and ownership |
| Ubiquitous Language | Shared vocabulary | Better communication |
| Context Mapping | Integration between contexts | Explicit relationships |
| Anti-Corruption Layer | Protect from external systems | Domain model integrity |
| Shared Kernel | Share subset of model | Reduce duplication |
| Customer-Supplier | Define dependencies | Clear service contracts |

#### Tactical Patterns

| Pattern | Use Case | Key Benefit |
|---------|----------|-------------|
| Entity | Objects with identity | Track lifecycle |
| Value Object | Descriptive attributes | Immutability, shareability |
| Aggregate | Consistency boundary | Transaction scope |
| Repository | Access aggregates | Abstract persistence |
| Domain Event | Capture business occurrences | Loose coupling |
| Domain Service | Cross-aggregate logic | Proper responsibility placement |

### Event Sourcing & CQRS

| Pattern | Use Case | Key Benefit |
|---------|----------|-------------|
| Event Store | Persist state as events | Complete audit trail |
| Event Stream | Aggregate event history | Rebuild state anytime |
| Projection | Build read models | Query optimization |
| Snapshot | Cache aggregate state | Performance improvement |
| Command Handler | Process write operations | Business logic encapsulation |
| Query Service | Read-only operations | Read optimization |

### Saga Patterns

| Pattern | Use Case | Key Benefit |
|---------|----------|-------------|
| Orchestration | Central coordinator | Simple flow control |
| Choreography | Event-driven coordination | No single point of failure |
| Compensation | Undo operations | Rollback capability |

### Service Communication

| Pattern | Use Case | Key Benefit |
|---------|----------|-------------|
| API Gateway | Single entry point | Centralized cross-cutting concerns |
| BFF | Client-specific backends | Optimized responses |
| Service Mesh | Service-to-service communication | Observability, security, traffic management |

### Resilience Patterns

| Pattern | Use Case | Key Benefit |
|---------|----------|-------------|
| Circuit Breaker | Prevent cascading failures | Fast failure detection |
| Retry | Handle transient failures | Automatic recovery |
| Bulkhead | Resource isolation | Failure containment |
| Timeout | Prevent indefinite waits | Resource protection |
| Fallback | Alternative responses | Graceful degradation |

### Scalability Patterns

| Pattern | Use Case | Key Benefit |
|---------|----------|-------------|
| Horizontal Scaling | Add more instances | Linear capacity increase |
| Load Balancing | Distribute traffic | Even resource utilization |
| Caching | Reduce database load | Improved response time |
| Database Sharding | Partition data | Distribute storage load |
| CDN | Serve static content | Reduced latency |
| Read Replicas | Scale read operations | Read scalability |

## Common Scenarios

### Scenario 1: Building a New Microservices Application

**Patterns to Apply:**
1. Start with Bounded Contexts (DDD)
2. Define Aggregates and Entities (DDD)
3. Implement API Gateway for client access
4. Add Circuit Breakers for resilience
5. Use Event-Driven communication between services
6. Implement CQRS for read-heavy operations
7. Add Caching for frequently accessed data

### Scenario 2: Migrating Monolith to Microservices

**Patterns to Apply:**
1. Strangler Fig Pattern for gradual migration
2. Anti-Corruption Layer to protect from legacy
3. BFF Pattern for client compatibility
4. Event Sourcing for audit trail
5. Saga Pattern for distributed transactions
6. Service Mesh for observability

### Scenario 3: Handling Distributed Transactions

**Patterns to Apply:**
1. Saga Pattern (Orchestration or Choreography)
2. Event Sourcing for state management
3. Eventual Consistency acceptance
4. Compensation for rollback
5. Idempotent operations
6. Circuit Breaker for failure handling

### Scenario 4: Scaling High-Traffic Application

**Patterns to Apply:**
1. Horizontal Scaling with auto-scaling
2. Load Balancing (Round Robin, Least Connections)
3. Caching (Cache-Aside, Write-Through)
4. Database Sharding for data distribution
5. Read Replicas for read scalability
6. CDN for static assets
7. Async Processing for slow operations

### Scenario 5: Building Event-Driven Architecture

**Patterns to Apply:**
1. Domain Events for business occurrences
2. Event Sourcing for state persistence
3. CQRS for read/write separation
4. Event Bus for event distribution
5. Projections for read models
6. Saga Pattern for long-running processes

## Pattern Selection Guide

### Choose DDD When:
- Complex business domain with rich behavior
- Need to align software with business language
- Multiple teams working on different areas
- Domain experts available for collaboration
- Long-lived application expected to evolve

### Choose Event Sourcing When:
- Need complete audit trail
- Temporal queries required (state at any point in time)
- Event-driven architecture
- High write throughput
- Complex event processing needed

### Choose CQRS When:
- Very different read and write patterns
- Read scalability requirements
- Different consistency models for read/write
- Multiple read models needed
- Event sourcing already in use

### Choose Saga Pattern When:
- Distributed transactions across services
- Long-running business processes
- Need compensation capability
- Microservices architecture
- Eventual consistency acceptable

### Choose API Gateway When:
- Multiple client types (web, mobile, IoT)
- Need centralized authentication/authorization
- Rate limiting required
- Request aggregation needed
- Protocol translation necessary

### Choose Service Mesh When:
- Many microservices (10+)
- Need observability across services
- Complex traffic management
- Service-to-service security required
- Kubernetes environment

## Architecture Decision Framework

### Questions to Ask

**Domain Complexity:**
- How complex is the business domain?
- Do we need rich domain models?
- Is there a ubiquitous language?

**Scalability:**
- What are the scalability requirements?
- Read-heavy or write-heavy?
- Global or regional distribution?

**Consistency:**
- Can we accept eventual consistency?
- What are the consistency boundaries?
- Are there strong consistency requirements?

**Resilience:**
- What is the acceptable downtime?
- What are the failure scenarios?
- Do we need automatic recovery?

**Team Structure:**
- How many teams?
- Team size and expertise?
- Geographic distribution?

**Operational Maturity:**
- DevOps capabilities?
- Monitoring and observability?
- Deployment automation?

## Anti-Patterns to Avoid

### Architecture Anti-Patterns

1. **Distributed Monolith**: Microservices that are tightly coupled
   - Solution: Define clear boundaries, use async communication

2. **Anemic Domain Model**: Entities with no behavior, only data
   - Solution: Put business logic in domain objects

3. **Shared Database**: Multiple services sharing one database
   - Solution: Database per service, event-driven integration

4. **Chatty Services**: Too many synchronous calls between services
   - Solution: Aggregate data, use async events, implement BFF

5. **God Service**: One service doing too much
   - Solution: Split by business capability, follow SRP

6. **No API Versioning**: Breaking changes without versioning
   - Solution: Version APIs from start, support multiple versions

### Implementation Anti-Patterns

1. **Large Aggregates**: Aggregates with too many entities
   - Solution: Keep aggregates small, use references

2. **Event Coupling**: Events containing too much information
   - Solution: Minimal event data, separate queries for details

3. **Sync Over Async**: Using sync calls when async is better
   - Solution: Default to async, use sync only when necessary

4. **Premature Optimization**: Optimizing before measuring
   - Solution: Profile first, optimize bottlenecks

5. **Over-Engineering**: Adding patterns without need
   - Solution: Start simple, add complexity when justified

## Implementation Checklist

### Starting a New Service

- [ ] Define bounded context and ubiquitous language
- [ ] Identify aggregates and their boundaries
- [ ] Design entities and value objects
- [ ] Define domain events
- [ ] Create repository interfaces
- [ ] Implement API contract (OpenAPI)
- [ ] Add authentication and authorization
- [ ] Implement circuit breaker for external calls
- [ ] Add health check endpoints
- [ ] Configure logging and metrics
- [ ] Set up distributed tracing
- [ ] Write unit and integration tests
- [ ] Document API and architecture decisions
- [ ] Set up CI/CD pipeline
- [ ] Configure monitoring and alerting

### Adding Event Sourcing

- [ ] Design event schema
- [ ] Implement event store
- [ ] Create event handlers
- [ ] Build projections for read models
- [ ] Add snapshot mechanism
- [ ] Implement event versioning
- [ ] Add event replay capability
- [ ] Monitor event processing lag
- [ ] Test event ordering
- [ ] Plan for event migration

### Implementing CQRS

- [ ] Separate command and query models
- [ ] Design command handlers
- [ ] Create read models
- [ ] Implement projections
- [ ] Set up event bus
- [ ] Add eventual consistency handling
- [ ] Monitor projection lag
- [ ] Implement query optimization
- [ ] Add cache for read models
- [ ] Test consistency scenarios

### Adding Saga Pattern

- [ ] Identify saga participants
- [ ] Define saga steps
- [ ] Design compensation logic
- [ ] Choose orchestration or choreography
- [ ] Implement saga state persistence
- [ ] Add timeout handling
- [ ] Implement retry logic
- [ ] Monitor saga execution
- [ ] Test compensation scenarios
- [ ] Handle partial failures

## Metrics to Track

### Performance Metrics
- Request latency (p50, p95, p99)
- Throughput (requests per second)
- Error rate
- Success rate
- Time to first byte

### Availability Metrics
- Uptime percentage
- Mean time between failures (MTBF)
- Mean time to recovery (MTTR)
- Service level indicators (SLIs)
- Service level objectives (SLOs)

### Scalability Metrics
- CPU utilization
- Memory usage
- Database connections
- Queue depth
- Cache hit rate

### Business Metrics
- Event processing lag
- Saga completion rate
- Projection freshness
- Command processing time
- Query response time

## Resources

### Official Documentation
- **Domain-Driven Design**: https://www.domainlanguage.com
- **Microservices.io**: https://microservices.io
- **Martin Fowler**: https://martinfowler.com
- **Microsoft Architecture**: https://learn.microsoft.com/azure/architecture
- **AWS Architecture**: https://aws.amazon.com/architecture

### Tools & Frameworks
- **Event Store**: EventStoreDB, Axon Framework
- **CQRS**: MediatR, Axon Framework
- **API Gateway**: Kong, AWS API Gateway, Azure APIM
- **Service Mesh**: Istio, Linkerd, Consul
- **Circuit Breaker**: Resilience4j, Polly, Hystrix

### Community
- DDD Community: https://www.dddhub.com
- CQRS/Event Sourcing: https://cqrs.nu
- Microservices Practitioners: Various meetups and conferences

---

For detailed examples and implementation code, see EXAMPLES.md
