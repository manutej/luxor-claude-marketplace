# FastAPI Microservices Development

> Production-ready microservices development with FastAPI - async operations, dependency injection, REST APIs, and cloud deployment.

## Overview

This skill provides comprehensive guidance for building scalable, production-grade microservices using FastAPI, Python's modern async web framework. Whether you're building a simple REST API or a complex distributed system, this skill covers the patterns, practices, and deployment strategies you need.

## Key Features

### 🚀 High Performance
- **Async/await support** - Full asynchronous request handling for maximum throughput
- **Fast execution** - Performance on par with NodeJS and Go (powered by Starlette)
- **Efficient concurrency** - Handle thousands of concurrent connections
- **Optimized I/O** - Non-blocking database and API calls

### 🛠️ Developer Experience
- **Type hints everywhere** - Full IDE support with autocompletion
- **Automatic validation** - Request/response validation via Pydantic
- **Interactive docs** - Auto-generated Swagger UI and ReDoc
- **Fast development** - Reduce development time by 200-300%
- **Minimal boilerplate** - Write less code, do more

### 🏗️ Production Ready
- **Dependency injection** - Advanced DI system with lifecycle management
- **Authentication/Authorization** - OAuth2, JWT, API keys, and custom schemes
- **Database integration** - Async SQLAlchemy, MongoDB, and more
- **Testing support** - Comprehensive test client and async testing
- **Error handling** - Custom exception handlers and validation errors
- **Background tasks** - Async task execution without blocking

### 📦 Microservices Patterns
- **Service design** - Single responsibility, API-first, stateless patterns
- **Communication** - REST APIs, WebSockets, event-driven architectures
- **Scalability** - Horizontal scaling, load balancing, caching
- **Observability** - Logging, metrics, tracing, health checks
- **Deployment** - Docker, Kubernetes, cloud-native configurations

## When to Use This Skill

### Perfect For

✅ **Building REST APIs**
- RESTful microservices with CRUD operations
- Public and internal APIs
- API gateways and aggregation layers

✅ **Async-First Applications**
- High-concurrency services
- Real-time data processing
- WebSocket servers
- Event-driven architectures

✅ **Data-Intensive Services**
- Services with heavy database operations
- Data aggregation and transformation
- Analytics and reporting APIs

✅ **Microservices Architectures**
- Service-oriented architectures
- Distributed systems
- Cloud-native applications
- Containerized deployments

✅ **Modern Python Backend**
- New projects starting from scratch
- Migration from Flask/Django for performance
- Type-safe Python applications
- Teams wanting better DX and productivity

### Not Ideal For

❌ **Traditional web applications** - Use Django for admin panels and traditional web apps
❌ **Simple scripts** - Overkill for command-line tools or batch jobs
❌ **Synchronous-only libraries** - When stuck with blocking I/O libraries
❌ **Python 2 or old Python 3** - Requires Python 3.7+

## Quick Start

### Installation

```bash
# Install with standard dependencies
pip install "fastapi[standard]"

# Or minimal installation
pip install fastapi uvicorn
```

### Hello World API

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def read_root():
    return {"message": "Hello World"}

@app.get("/items/{item_id}")
async def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}
```

### Run the Server

```bash
uvicorn main:app --reload
```

Visit:
- API: http://127.0.0.1:8000
- Interactive docs: http://127.0.0.1:8000/docs
- Alternative docs: http://127.0.0.1:8000/redoc

## Architecture Overview

### Service Architecture

```
┌─────────────────────────────────────────────────┐
│                 API Gateway                      │
│            (nginx/traefik/kong)                  │
└─────────────────┬───────────────────────────────┘
                  │
        ┌─────────┴──────────┐
        │                    │
┌───────▼────────┐  ┌────────▼───────┐
│   User Service │  │  Order Service  │
│   (FastAPI)    │  │    (FastAPI)    │
└───────┬────────┘  └────────┬────────┘
        │                    │
┌───────▼────────┐  ┌────────▼────────┐
│   PostgreSQL   │  │    PostgreSQL   │
└────────────────┘  └─────────────────┘

         ┌──────────────┐
         │    Redis     │
         │   (Cache)    │
         └──────────────┘

         ┌──────────────┐
         │  RabbitMQ    │
         │ (Message Q)  │
         └──────────────┘
```

### Application Structure

```
fastapi-service/
├── app/
│   ├── main.py              # Application entry point
│   ├── config.py            # Configuration management
│   ├── dependencies.py      # Shared dependencies
│   │
│   ├── models/              # Database models (SQLAlchemy)
│   │   ├── user.py
│   │   └── item.py
│   │
│   ├── schemas/             # Pydantic schemas (validation)
│   │   ├── user.py
│   │   └── item.py
│   │
│   ├── routers/             # API route handlers
│   │   ├── users.py
│   │   └── items.py
│   │
│   ├── services/            # Business logic
│   │   ├── user_service.py
│   │   └── item_service.py
│   │
│   └── database.py          # Database configuration
│
├── tests/                   # Test suite
│   ├── test_users.py
│   └── test_items.py
│
├── Dockerfile               # Container definition
├── docker-compose.yml       # Local development stack
├── requirements.txt         # Python dependencies
└── .env                     # Environment variables
```

### Request Flow

```
1. HTTP Request
   ↓
2. Middleware (CORS, Auth, Logging)
   ↓
3. Route Matching
   ↓
4. Dependency Injection
   ├── Database Connection
   ├── Authentication
   ├── Common Parameters
   └── Business Services
   ↓
5. Request Validation (Pydantic)
   ↓
6. Route Handler Execution
   ↓
7. Response Validation (Pydantic)
   ↓
8. Response Serialization
   ↓
9. HTTP Response
```

## Core Concepts

### 1. Path Operations

Define API endpoints using HTTP methods:

```python
@app.get("/items/")           # Read collection
@app.post("/items/")          # Create new item
@app.get("/items/{id}")       # Read single item
@app.put("/items/{id}")       # Update item
@app.delete("/items/{id}")    # Delete item
@app.patch("/items/{id}")     # Partial update
```

### 2. Request Validation

Automatic validation with Pydantic:

```python
from pydantic import BaseModel, Field, EmailStr

class User(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr
    age: int = Field(..., ge=0, le=150)

@app.post("/users/")
async def create_user(user: User):
    # user is validated automatically
    return user
```

### 3. Dependency Injection

Reusable logic with dependencies:

```python
from fastapi import Depends

async def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        await db.close()

@app.get("/items/")
async def read_items(db = Depends(get_db)):
    return await db.query(Item).all()
```

### 4. Async Operations

Non-blocking I/O for better performance:

```python
@app.get("/users/{user_id}")
async def get_user(user_id: int):
    # Async database query
    user = await db.users.find_one({"id": user_id})

    # Async external API call
    async with httpx.AsyncClient() as client:
        profile = await client.get(f"https://api.example.com/profile/{user_id}")

    return {"user": user, "profile": profile.json()}
```

### 5. Background Tasks

Execute tasks after returning response:

```python
from fastapi import BackgroundTasks

def send_email(email: str, message: str):
    # Send email logic
    pass

@app.post("/send-notification/")
async def send_notification(
    email: str,
    background_tasks: BackgroundTasks
):
    background_tasks.add_task(send_email, email, "Welcome!")
    return {"message": "Notification will be sent"}
```

## Authentication Patterns

### JWT Authentication

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
import jwt

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

async def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=401)
    except jwt.PyJWTError:
        raise HTTPException(status_code=401)

    user = await get_user(username)
    if user is None:
        raise HTTPException(status_code=401)
    return user

@app.get("/users/me")
async def read_users_me(current_user = Depends(get_current_user)):
    return current_user
```

## Database Integration

### Async SQLAlchemy

```python
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

engine = create_async_engine(DATABASE_URL, echo=True)
async_session = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

async def get_db():
    async with async_session() as session:
        yield session

@app.get("/users/")
async def list_users(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User))
    return result.scalars().all()
```

### MongoDB with Motor

```python
from motor.motor_asyncio import AsyncIOMotorClient

client = AsyncIOMotorClient(MONGODB_URL)
db = client.mydatabase

@app.post("/items/")
async def create_item(item: Item):
    result = await db.items.insert_one(item.dict())
    return {"id": str(result.inserted_id)}
```

## Testing

### Test Client

```python
from fastapi.testclient import TestClient

client = TestClient(app)

def test_create_user():
    response = client.post(
        "/users/",
        json={"username": "test", "email": "test@example.com"}
    )
    assert response.status_code == 201
    assert response.json()["username"] == "test"
```

### Async Testing

```python
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_list_items():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/items/")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
```

## Deployment

### Docker

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./app /app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fastapi-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: fastapi
  template:
    metadata:
      labels:
        app: fastapi
    spec:
      containers:
      - name: fastapi
        image: myregistry/fastapi-app:latest
        ports:
        - containerPort: 8000
        resources:
          limits:
            memory: "512Mi"
            cpu: "500m"
```

### Production Server

```bash
# With Gunicorn and Uvicorn workers
gunicorn main:app \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000 \
  --log-level info
```

## Monitoring & Observability

### Health Checks

```python
@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.get("/ready")
async def readiness_check():
    # Check database, cache, etc.
    await db.execute("SELECT 1")
    return {"status": "ready"}
```

### Metrics

```python
from prometheus_client import Counter, Histogram

REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total requests',
    ['method', 'endpoint', 'status']
)

@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    response = await call_next(request)
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.url.path,
        status=response.status_code
    ).inc()
    return response
```

## Best Practices

### ✅ Do

- Use async/await for I/O operations
- Implement proper error handling
- Validate all inputs with Pydantic
- Use dependency injection for shared logic
- Write comprehensive tests
- Document your APIs
- Implement health checks
- Use environment variables for config
- Monitor and log everything
- Use type hints everywhere

### ❌ Don't

- Block the event loop with CPU-intensive tasks
- Mix sync and async code carelessly
- Ignore validation errors
- Hardcode secrets or config
- Skip testing edge cases
- Over-complicate dependency chains
- Forget to handle database connections properly
- Deploy without health checks
- Ignore performance monitoring
- Use raw SQL without parameterization

## Performance Tips

1. **Use async everywhere** - Maximize concurrency
2. **Connection pooling** - Reuse database connections
3. **Caching** - Use Redis for frequently accessed data
4. **Pagination** - Limit response sizes
5. **Background tasks** - Offload heavy processing
6. **Compression** - Enable gzip for responses
7. **Database indexes** - Optimize query performance
8. **Load balancing** - Distribute traffic across instances
9. **CDN** - Cache static assets
10. **Monitoring** - Identify bottlenecks early

## Resources

### Official Documentation
- FastAPI Docs: https://fastapi.tiangolo.com
- Pydantic Docs: https://docs.pydantic.dev
- Starlette Docs: https://www.starlette.io

### Community
- GitHub: https://github.com/fastapi/fastapi
- Discord: https://discord.gg/VQjSZaeJmf
- Stack Overflow: [fastapi] tag

### Related Skills
- `python-async-programming` - Deep dive into async/await
- `postgresql-optimization` - Database performance
- `docker-deployment` - Containerization strategies
- `kubernetes-orchestration` - K8s deployment patterns

## What's Next?

1. **Read SKILL.md** - Comprehensive patterns and practices
2. **Study EXAMPLES.md** - 15+ production-ready examples
3. **Build a project** - Start with a simple CRUD API
4. **Deploy to production** - Use Docker and cloud platforms
5. **Monitor and optimize** - Track performance and improve

---

**Version**: 1.0.0
**Last Updated**: October 2025
**Maintained By**: Claude Code Skills Library
**License**: MIT
