# FastAPI Customer Support Tech Enablement

## Overview

FastAPI is a modern, fast (high-performance) web framework for building APIs with Python 3.8+ based on standard Python type hints. This skill package is specifically designed for customer support tech enablement teams working on backend systems, ticket management platforms, and real-time support applications.

## Why FastAPI for Customer Support Systems?

### Performance
- **Fast**: Very high performance, on par with NodeJS and Go (thanks to Starlette and Pydantic)
- **Async**: Native async/await support for handling concurrent support requests
- **Production-ready**: Used by companies like Microsoft, Uber, Netflix for mission-critical applications

### Developer Experience
- **Easy to learn**: Intuitive API design based on Python standards
- **Fast to code**: Reduce development time by 40-60%
- **Type safety**: Catch bugs early with Python type hints and Pydantic
- **Auto documentation**: Interactive API docs (Swagger UI and ReDoc) out of the box

### Customer Support Specific Benefits
- **Real-time capabilities**: WebSocket support for live chat between agents and customers
- **High concurrency**: Handle thousands of simultaneous ticket requests
- **Data validation**: Ensure ticket data integrity with Pydantic models
- **Database integration**: Seamless async SQLAlchemy for PostgreSQL operations
- **Background tasks**: Send email notifications without blocking API responses
- **Authentication**: Built-in security utilities for agent/customer portals

## Installation

### Basic Installation

```bash
pip install fastapi
pip install "uvicorn[standard]"
```

### Complete Stack for Customer Support

```bash
# Core dependencies
pip install fastapi uvicorn[standard]

# Database
pip install sqlalchemy asyncpg alembic

# Authentication
pip install python-jose[cryptography] passlib[bcrypt] python-multipart

# Validation and settings
pip install pydantic pydantic-settings email-validator

# Testing
pip install pytest pytest-asyncio httpx

# Optional: Redis caching
pip install redis

# Optional: Monitoring
pip install prometheus-client
```

### Using requirements.txt

Create a `requirements.txt` file:

```
fastapi==0.115.0
uvicorn[standard]==0.30.0
sqlalchemy==2.0.30
asyncpg==0.29.0
alembic==1.13.1
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.9
pydantic==2.7.0
pydantic-settings==2.2.1
email-validator==2.1.1
pytest==8.2.0
pytest-asyncio==0.23.6
httpx==0.27.0
redis==5.0.3
prometheus-client==0.20.0
```

Install with:
```bash
pip install -r requirements.txt
```

## Quick Start Guide

### 1. Basic FastAPI Application

Create `main.py`:

```python
from fastapi import FastAPI

app = FastAPI(title="Customer Support API")

@app.get("/")
async def root():
    return {"message": "Customer Support API v1.0"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
```

Run the application:
```bash
uvicorn main:app --reload
```

Visit:
- API: http://localhost:8000
- Interactive docs: http://localhost:8000/docs
- Alternative docs: http://localhost:8000/redoc

### 2. Support Ticket API Example

Create a simple ticket management system:

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, EmailStr
from typing import List, Optional
from datetime import datetime
from enum import Enum

app = FastAPI(title="Support Ticket API")

# Enums for ticket fields
class TicketStatus(str, Enum):
    OPEN = "open"
    IN_PROGRESS = "in_progress"
    RESOLVED = "resolved"
    CLOSED = "closed"

class TicketPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"

# Pydantic models
class TicketCreate(BaseModel):
    title: str
    description: str
    customer_email: EmailStr
    priority: TicketPriority = TicketPriority.MEDIUM

class Ticket(TicketCreate):
    id: int
    status: TicketStatus
    created_at: datetime

# In-memory storage (use database in production)
tickets_db: List[Ticket] = []
ticket_id_counter = 1

@app.post("/tickets/", response_model=Ticket, status_code=201)
async def create_ticket(ticket: TicketCreate):
    global ticket_id_counter
    new_ticket = Ticket(
        id=ticket_id_counter,
        status=TicketStatus.OPEN,
        created_at=datetime.utcnow(),
        **ticket.dict()
    )
    tickets_db.append(new_ticket)
    ticket_id_counter += 1
    return new_ticket

@app.get("/tickets/", response_model=List[Ticket])
async def list_tickets(status: Optional[TicketStatus] = None):
    if status:
        return [t for t in tickets_db if t.status == status]
    return tickets_db

@app.get("/tickets/{ticket_id}", response_model=Ticket)
async def get_ticket(ticket_id: int):
    ticket = next((t for t in tickets_db if t.id == ticket_id), None)
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")
    return ticket

@app.patch("/tickets/{ticket_id}/status")
async def update_ticket_status(ticket_id: int, status: TicketStatus):
    ticket = next((t for t in tickets_db if t.id == ticket_id), None)
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")
    ticket.status = status
    return {"message": f"Ticket {ticket_id} status updated to {status}"}
```

Run with:
```bash
uvicorn main:app --reload
```

Test the API:
```bash
# Create a ticket
curl -X POST "http://localhost:8000/tickets/" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Cannot access dashboard",
    "description": "Getting 404 error when accessing dashboard",
    "customer_email": "customer@example.com",
    "priority": "high"
  }'

# List all tickets
curl "http://localhost:8000/tickets/"

# Get specific ticket
curl "http://localhost:8000/tickets/1"

# Update ticket status
curl -X PATCH "http://localhost:8000/tickets/1/status?status=in_progress"
```

### 3. Database Integration Example

Upgrade to use PostgreSQL with async SQLAlchemy:

```python
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy import Column, Integer, String, DateTime, Enum as SQLEnum
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import declarative_base
from sqlalchemy.sql import func
from typing import AsyncGenerator
import enum

DATABASE_URL = "postgresql+asyncpg://user:password@localhost/support_db"

engine = create_async_engine(DATABASE_URL, echo=True)
AsyncSessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
Base = declarative_base()

# Enums
class TicketStatusEnum(enum.Enum):
    OPEN = "open"
    IN_PROGRESS = "in_progress"
    RESOLVED = "resolved"
    CLOSED = "closed"

# Database model
class TicketDB(Base):
    __tablename__ = "tickets"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    description = Column(String, nullable=False)
    customer_email = Column(String(100), nullable=False)
    status = Column(SQLEnum(TicketStatusEnum), default=TicketStatusEnum.OPEN)
    priority = Column(String(20))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

# Dependency
async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

app = FastAPI()

# Create tables on startup
@app.on_event("startup")
async def startup():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

# Endpoints
@app.post("/tickets/")
async def create_ticket(ticket: TicketCreate, db: AsyncSession = Depends(get_db)):
    db_ticket = TicketDB(**ticket.dict())
    db.add(db_ticket)
    await db.flush()
    await db.refresh(db_ticket)
    return db_ticket

@app.get("/tickets/{ticket_id}")
async def get_ticket(ticket_id: int, db: AsyncSession = Depends(get_db)):
    from sqlalchemy import select
    result = await db.execute(select(TicketDB).where(TicketDB.id == ticket_id))
    ticket = result.scalar_one_or_none()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")
    return ticket
```

## Key Features

### 1. Automatic Interactive API Documentation

FastAPI automatically generates documentation based on your code:

- **Swagger UI**: Interactive documentation at `/docs`
- **ReDoc**: Alternative documentation at `/redoc`
- **OpenAPI schema**: JSON schema at `/openapi.json`

No need to write separate documentation - it's always in sync with your code!

### 2. Data Validation with Pydantic

Automatic request validation, type conversion, and error messages:

```python
from pydantic import BaseModel, Field, EmailStr, validator

class TicketCreate(BaseModel):
    title: str = Field(..., min_length=3, max_length=200)
    description: str = Field(..., min_length=10)
    customer_email: EmailStr
    priority: str

    @validator('priority')
    def priority_must_be_valid(cls, v):
        valid_priorities = ['low', 'medium', 'high', 'urgent']
        if v not in valid_priorities:
            raise ValueError(f'Priority must be one of: {valid_priorities}')
        return v
```

### 3. Dependency Injection

Share logic across endpoints with dependencies:

```python
from fastapi import Depends

async def get_current_user(token: str = Depends(oauth2_scheme)):
    # Decode token and get user
    return user

@app.get("/tickets/my-tickets")
async def get_my_tickets(current_user: User = Depends(get_current_user)):
    return {"tickets": [...], "user": current_user}
```

### 4. Background Tasks

Execute tasks after returning response:

```python
from fastapi import BackgroundTasks

def send_notification_email(email: str, message: str):
    # Send email logic
    pass

@app.post("/tickets/")
async def create_ticket(
    ticket: TicketCreate,
    background_tasks: BackgroundTasks
):
    # Create ticket
    new_ticket = create_ticket_in_db(ticket)

    # Schedule email notification
    background_tasks.add_task(
        send_notification_email,
        ticket.customer_email,
        f"Ticket #{new_ticket.id} created"
    )

    return new_ticket
```

### 5. WebSocket Support

Real-time communication for live chat:

```python
from fastapi import WebSocket

@app.websocket("/ws/chat/{ticket_id}")
async def websocket_endpoint(websocket: WebSocket, ticket_id: int):
    await websocket.accept()
    while True:
        data = await websocket.receive_text()
        await websocket.send_text(f"Message received: {data}")
```

### 6. Authentication & Security

Built-in security utilities:

```python
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import jwt

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

@app.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    # Verify credentials
    # Generate JWT token
    return {"access_token": token, "token_type": "bearer"}

@app.get("/protected")
async def protected_route(token: str = Depends(oauth2_scheme)):
    # Verify token
    return {"message": "Authenticated"}
```

## Performance Characteristics

### Benchmarks

FastAPI is one of the fastest Python frameworks available:

| Framework | Requests/sec | Latency (ms) |
|-----------|--------------|--------------|
| FastAPI   | ~30,000      | ~3.5         |
| Flask     | ~5,000       | ~20          |
| Django    | ~3,000       | ~33          |

*Results vary based on implementation and hardware*

### Async Benefits

Using async operations provides significant benefits for I/O-bound operations:

**Synchronous (blocking)**:
```python
@app.get("/tickets/{ticket_id}")
def get_ticket(ticket_id: int):
    ticket = db.query(Ticket).filter(Ticket.id == ticket_id).first()
    return ticket
```
- Blocks the thread during database query
- Can handle ~1000 concurrent requests

**Asynchronous (non-blocking)**:
```python
@app.get("/tickets/{ticket_id}")
async def get_ticket(ticket_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Ticket).where(Ticket.id == ticket_id))
    ticket = result.scalar_one_or_none()
    return ticket
```
- Releases thread during database query
- Can handle ~10,000+ concurrent requests

### When to Use Async

**Use `async def` for**:
- Database queries
- External API calls
- File I/O operations
- Network requests
- Any operation that involves waiting

**Use regular `def` for**:
- CPU-intensive operations
- Simple computations
- Working with synchronous libraries

## Common Use Cases for Customer Support

### 1. Ticket Management API
- Create, read, update, delete tickets
- Filter and search tickets
- Bulk operations
- SLA tracking

### 2. Agent Portal Backend
- Agent authentication
- Ticket assignment
- Performance metrics
- Activity logs

### 3. Customer Portal API
- Customer authentication
- View own tickets
- Submit new tickets
- Upload attachments

### 4. Real-time Chat System
- WebSocket connections
- Message history
- Typing indicators
- Agent availability

### 5. Analytics & Reporting
- Ticket statistics
- Agent performance
- Customer satisfaction
- Response time metrics

### 6. Integration APIs
- Email integration (IMAP/SMTP)
- Webhook receivers
- Third-party service connectors
- CRM integrations

## Project Structure

Recommended structure for a customer support API:

```
support_api/
├── main.py                 # Application entry point
├── config.py              # Configuration and settings
├── requirements.txt       # Dependencies
├── .env                   # Environment variables
│
├── api/                   # API endpoints
│   ├── __init__.py
│   ├── tickets.py
│   ├── users.py
│   ├── auth.py
│   └── chat.py
│
├── models/                # Database models
│   ├── __init__.py
│   ├── ticket.py
│   ├── user.py
│   └── comment.py
│
├── schemas/               # Pydantic schemas
│   ├── __init__.py
│   ├── ticket.py
│   └── user.py
│
├── services/              # Business logic
│   ├── __init__.py
│   ├── ticket_service.py
│   └── email_service.py
│
├── dependencies/          # FastAPI dependencies
│   ├── __init__.py
│   ├── database.py
│   └── auth.py
│
└── tests/                 # Test suite
    ├── __init__.py
    ├── test_tickets.py
    └── test_auth.py
```

## Troubleshooting Guide

### Common Issues

#### 1. Import Errors

**Problem**: `ModuleNotFoundError: No module named 'fastapi'`

**Solution**:
```bash
pip install fastapi uvicorn
```

#### 2. Database Connection Issues

**Problem**: `Could not connect to database`

**Solution**:
- Check database URL format: `postgresql+asyncpg://user:pass@host:port/db`
- Ensure PostgreSQL is running: `pg_isready`
- Install asyncpg: `pip install asyncpg`
- Test connection separately

#### 3. Pydantic Validation Errors

**Problem**: `validation error for TicketCreate`

**Solution**:
- Check request body matches Pydantic model
- Use `Optional[]` for nullable fields
- Verify field types (int, str, etc.)
- Check custom validators

#### 4. Async/Await Issues

**Problem**: `RuntimeWarning: coroutine was never awaited`

**Solution**:
- Use `await` when calling async functions
- Mark function as `async def` if it calls async functions
- Don't mix sync and async database sessions

#### 5. CORS Errors in Browser

**Problem**: `No 'Access-Control-Allow-Origin' header`

**Solution**:
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

#### 6. JWT Token Issues

**Problem**: `Could not validate credentials`

**Solution**:
- Check SECRET_KEY is consistent
- Verify token hasn't expired
- Ensure ALGORITHM matches between encode/decode
- Check token format: `Bearer <token>`

### Performance Issues

#### Slow API Responses

**Diagnose**:
1. Enable SQL logging: `engine = create_async_engine(url, echo=True)`
2. Check for N+1 queries
3. Use database query profiling

**Solutions**:
- Use eager loading with `selectinload()` or `joinedload()`
- Add database indexes
- Implement caching with Redis
- Use connection pooling
- Optimize database queries

#### Memory Leaks

**Diagnose**:
- Use memory profiler: `pip install memory_profiler`
- Monitor with tools like `top` or `htop`

**Solutions**:
- Close database sessions properly
- Use `async with` for resource management
- Implement connection limits
- Clear cached data periodically

## Best Practices

### 1. Always Use Type Hints

```python
from typing import List, Optional

async def get_tickets(
    status: Optional[str] = None,
    limit: int = 10
) -> List[Ticket]:
    # Implementation
    pass
```

### 2. Use Pydantic for Data Validation

```python
class TicketCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    priority: str = Field(..., regex="^(low|medium|high|urgent)$")
```

### 3. Implement Proper Error Handling

```python
@app.exception_handler(ValueError)
async def value_error_handler(request: Request, exc: ValueError):
    return JSONResponse(
        status_code=400,
        content={"error": str(exc)}
    )
```

### 4. Use Environment Variables

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    secret_key: str

    class Config:
        env_file = ".env"

settings = Settings()
```

### 5. Write Tests

```python
@pytest.mark.anyio
async def test_create_ticket(client: AsyncClient):
    response = await client.post("/tickets/", json={
        "title": "Test",
        "description": "Test ticket",
        "customer_email": "test@example.com"
    })
    assert response.status_code == 201
```

## Resources

### Official Documentation
- FastAPI Docs: https://fastapi.tiangolo.com
- Pydantic Docs: https://docs.pydantic.dev
- SQLAlchemy Docs: https://docs.sqlalchemy.org

### Tutorials
- FastAPI Tutorial: https://fastapi.tiangolo.com/tutorial/
- SQLAlchemy with FastAPI: https://fastapi.tiangolo.com/tutorial/sql-databases/
- Testing FastAPI: https://fastapi.tiangolo.com/tutorial/testing/

### Community
- GitHub: https://github.com/fastapi/fastapi
- Discord: https://discord.gg/VQjSZaeJmf
- Stack Overflow: Tag [fastapi]

## Next Steps

1. **Explore EXAMPLES.md** - 15+ practical examples for customer support systems
2. **Review SKILL.md** - Comprehensive technical guidance
3. **Build a prototype** - Start with the quick start example
4. **Add database** - Integrate PostgreSQL with SQLAlchemy
5. **Implement auth** - Add JWT authentication
6. **Add WebSocket** - Enable real-time chat
7. **Write tests** - Ensure code reliability
8. **Deploy** - Use Docker and container orchestration

## Support

For issues specific to this skill package, please refer to:
- EXAMPLES.md for code samples
- SKILL.md for detailed technical guidance
- FastAPI official documentation for framework questions

Happy coding!
