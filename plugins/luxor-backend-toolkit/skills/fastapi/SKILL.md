---
name: FastAPI Customer Support Tech Enablement
version: 1.0.0
description: Comprehensive FastAPI skill for building modern Python web APIs with focus on customer support systems, ticket management, real-time chat, and backend operations
tags:
  - fastapi
  - python
  - web-framework
  - async
  - rest-api
  - customer-support
  - backend
  - postgresql
  - sqlalchemy
  - pydantic
  - websocket
  - authentication
  - api-documentation
capabilities:
  - async_api_development
  - dependency_injection
  - database_integration
  - request_validation
  - authentication_authorization
  - websocket_real_time
  - background_tasks
  - api_documentation
  - testing
  - error_handling
supported_databases:
  - PostgreSQL
  - SQLite
  - MySQL
  - MongoDB
context: customer_support_tech_enablement
difficulty: intermediate_to_advanced
---

# FastAPI Customer Support Tech Enablement Skill

## Overview

This skill provides comprehensive guidance for building production-ready customer support APIs using FastAPI, the modern, fast (high-performance) web framework for building APIs with Python 3.8+ based on standard Python type hints.

FastAPI is ideal for customer support systems due to its:
- **Async capabilities** for handling concurrent requests (multiple support agents, real-time updates)
- **Automatic data validation** with Pydantic (ensuring data integrity for tickets, users, responses)
- **Built-in API documentation** (OpenAPI/Swagger for support team training)
- **WebSocket support** for real-time chat and notifications
- **Easy database integration** with SQLAlchemy for PostgreSQL operations
- **Type safety** reducing bugs in critical support workflows

## Core Competencies

### 1. Async API Development

FastAPI is built on top of Starlette for web routing and Pydantic for data validation, providing excellent async support for I/O-bound operations common in customer support systems.

**Key Concepts:**
- Use `async def` for path operations when making database queries, external API calls, or file operations
- Use regular `def` for CPU-bound operations or when using synchronous libraries
- FastAPI automatically handles the async/await pattern under the hood
- Background tasks for non-blocking operations (email notifications, log processing)

**Best Practices for Support APIs:**
```python
# Async for database operations (most support APIs)
@app.get("/tickets/{ticket_id}")
async def get_ticket(ticket_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Ticket).where(Ticket.id == ticket_id))
    ticket = result.scalar_one_or_none()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")
    return ticket

# Sync for simple operations without I/O
@app.get("/health")
def health_check():
    return {"status": "healthy"}
```

### 2. Dependency Injection System

FastAPI's dependency injection is powerful for managing shared resources like database sessions, authentication, and configuration.

**Database Session Management:**
```python
from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker

DATABASE_URL = "postgresql+asyncpg://user:password@localhost/support_db"

engine = create_async_engine(DATABASE_URL, echo=True)
AsyncSessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

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

# Use in endpoints
@app.post("/tickets/")
async def create_ticket(
    ticket: TicketCreate,
    db: AsyncSession = Depends(get_db)
):
    db_ticket = Ticket(**ticket.dict())
    db.add(db_ticket)
    await db.commit()
    await db.refresh(db_ticket)
    return db_ticket
```

**Authentication Dependencies:**
```python
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db)
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    result = await db.execute(select(User).where(User.username == username))
    user = result.scalar_one_or_none()
    if user is None:
        raise credentials_exception
    return user

async def get_current_active_agent(
    current_user: User = Depends(get_current_user)
) -> User:
    if not current_user.is_active or current_user.role != "agent":
        raise HTTPException(status_code=403, detail="Not authorized as support agent")
    return current_user
```

### 3. Request Validation with Pydantic

Pydantic models ensure data integrity throughout your support system.

**Base Models for Customer Support:**
```python
from pydantic import BaseModel, EmailStr, Field, validator
from datetime import datetime
from typing import Optional, List
from enum import Enum

class TicketPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"

class TicketStatus(str, Enum):
    OPEN = "open"
    IN_PROGRESS = "in_progress"
    WAITING_CUSTOMER = "waiting_customer"
    RESOLVED = "resolved"
    CLOSED = "closed"

class TicketBase(BaseModel):
    title: str = Field(..., min_length=3, max_length=200)
    description: str = Field(..., min_length=10)
    priority: TicketPriority = TicketPriority.MEDIUM
    category: str = Field(..., max_length=50)

    @validator('title')
    def title_must_not_be_empty(cls, v):
        if not v.strip():
            raise ValueError('Title cannot be empty or whitespace')
        return v.strip()

class TicketCreate(TicketBase):
    customer_email: EmailStr
    attachments: Optional[List[str]] = []

class TicketUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=3, max_length=200)
    description: Optional[str] = None
    status: Optional[TicketStatus] = None
    priority: Optional[TicketPriority] = None
    assigned_to: Optional[int] = None

class TicketResponse(TicketBase):
    id: int
    status: TicketStatus
    customer_email: str
    assigned_to: Optional[int]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True  # For SQLAlchemy models
```

### 4. Database Integration with SQLAlchemy

Modern async SQLAlchemy integration for PostgreSQL operations.

**Model Definitions:**
```python
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Enum, Text
from sqlalchemy.orm import declarative_base, relationship
from sqlalchemy.sql import func
import enum

Base = declarative_base()

class TicketStatusEnum(enum.Enum):
    OPEN = "open"
    IN_PROGRESS = "in_progress"
    WAITING_CUSTOMER = "waiting_customer"
    RESOLVED = "resolved"
    CLOSED = "closed"

class TicketPriorityEnum(enum.Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(100))
    role = Column(String(20), default="customer")  # customer, agent, admin
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    assigned_tickets = relationship("Ticket", back_populates="assigned_agent")
    comments = relationship("Comment", back_populates="author")

class Ticket(Base):
    __tablename__ = "tickets"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=False)
    status = Column(Enum(TicketStatusEnum), default=TicketStatusEnum.OPEN, index=True)
    priority = Column(Enum(TicketPriorityEnum), default=TicketPriorityEnum.MEDIUM, index=True)
    category = Column(String(50), index=True)
    customer_email = Column(String(100), index=True, nullable=False)
    assigned_to = Column(Integer, ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    resolved_at = Column(DateTime(timezone=True), nullable=True)

    assigned_agent = relationship("User", back_populates="assigned_tickets")
    comments = relationship("Comment", back_populates="ticket", cascade="all, delete-orphan")

class Comment(Base):
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True, index=True)
    ticket_id = Column(Integer, ForeignKey("tickets.id"), nullable=False)
    author_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    content = Column(Text, nullable=False)
    is_internal = Column(Boolean, default=False)  # Internal agent notes
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    ticket = relationship("Ticket", back_populates="comments")
    author = relationship("User", back_populates="comments")
```

**Database Initialization:**
```python
async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

@app.on_event("startup")
async def startup():
    await init_db()
```

### 5. Authentication & Authorization

JWT-based authentication for support portal access.

**Password Hashing:**
```python
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)
```

**Token Generation:**
```python
from datetime import datetime, timedelta
from jose import jwt

SECRET_KEY = "your-secret-key-here"  # Use environment variable in production
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt
```

**Login Endpoint:**
```python
from fastapi.security import OAuth2PasswordRequestForm

@app.post("/token")
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(User).where(User.username == form_data.username))
    user = result.scalar_one_or_none()

    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username, "role": user.role},
        expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}
```

### 6. WebSocket for Real-Time Support

Real-time chat between customers and support agents.

**WebSocket Manager:**
```python
from fastapi import WebSocket, WebSocketDisconnect
from typing import Dict, List

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[int, List[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, ticket_id: int):
        await websocket.accept()
        if ticket_id not in self.active_connections:
            self.active_connections[ticket_id] = []
        self.active_connections[ticket_id].append(websocket)

    def disconnect(self, websocket: WebSocket, ticket_id: int):
        if ticket_id in self.active_connections:
            self.active_connections[ticket_id].remove(websocket)
            if not self.active_connections[ticket_id]:
                del self.active_connections[ticket_id]

    async def send_message(self, message: str, ticket_id: int):
        if ticket_id in self.active_connections:
            for connection in self.active_connections[ticket_id]:
                await connection.send_text(message)

    async def broadcast(self, message: str, ticket_id: int, exclude: WebSocket = None):
        if ticket_id in self.active_connections:
            for connection in self.active_connections[ticket_id]:
                if connection != exclude:
                    await connection.send_text(message)

manager = ConnectionManager()

@app.websocket("/ws/ticket/{ticket_id}")
async def websocket_endpoint(
    websocket: WebSocket,
    ticket_id: int,
    token: str,
    db: AsyncSession = Depends(get_db)
):
    # Verify token
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username = payload.get("sub")
    except JWTError:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    await manager.connect(websocket, ticket_id)
    try:
        while True:
            data = await websocket.receive_text()
            message = {
                "ticket_id": ticket_id,
                "username": username,
                "message": data,
                "timestamp": datetime.utcnow().isoformat()
            }
            await manager.broadcast(json.dumps(message), ticket_id)
    except WebSocketDisconnect:
        manager.disconnect(websocket, ticket_id)
```

### 7. Background Tasks

Handle email notifications and long-running operations without blocking responses.

**Email Notification Task:**
```python
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_email_notification(to_email: str, subject: str, body: str):
    """Background task to send email"""
    try:
        msg = MIMEMultipart()
        msg['From'] = "support@company.com"
        msg['To'] = to_email
        msg['Subject'] = subject

        msg.attach(MIMEText(body, 'html'))

        # Configure SMTP
        with smtplib.SMTP('smtp.gmail.com', 587) as server:
            server.starttls()
            server.login("support@company.com", "password")
            server.send_message(msg)
    except Exception as e:
        print(f"Failed to send email: {e}")

@app.post("/tickets/")
async def create_ticket(
    ticket: TicketCreate,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db)
):
    db_ticket = Ticket(**ticket.dict())
    db.add(db_ticket)
    await db.commit()
    await db.refresh(db_ticket)

    # Send confirmation email in background
    background_tasks.add_task(
        send_email_notification,
        ticket.customer_email,
        f"Ticket #{db_ticket.id} Created",
        f"Your support ticket has been created. We'll respond within 24 hours."
    )

    return db_ticket
```

### 8. Pagination & Filtering

Essential for support ticket lists with many records.

**Pagination Dependencies:**
```python
from typing import Optional

class PaginationParams(BaseModel):
    skip: int = Field(0, ge=0, description="Number of records to skip")
    limit: int = Field(10, ge=1, le=100, description="Maximum records to return")

class TicketFilters(BaseModel):
    status: Optional[TicketStatus] = None
    priority: Optional[TicketPriority] = None
    category: Optional[str] = None
    assigned_to: Optional[int] = None
    search: Optional[str] = Field(None, description="Search in title/description")

@app.get("/tickets/", response_model=List[TicketResponse])
async def list_tickets(
    filters: TicketFilters = Depends(),
    pagination: PaginationParams = Depends(),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    query = select(Ticket)

    # Apply filters
    if filters.status:
        query = query.where(Ticket.status == filters.status)
    if filters.priority:
        query = query.where(Ticket.priority == filters.priority)
    if filters.category:
        query = query.where(Ticket.category == filters.category)
    if filters.assigned_to:
        query = query.where(Ticket.assigned_to == filters.assigned_to)
    if filters.search:
        search_term = f"%{filters.search}%"
        query = query.where(
            (Ticket.title.ilike(search_term)) |
            (Ticket.description.ilike(search_term))
        )

    # Apply pagination
    query = query.offset(pagination.skip).limit(pagination.limit)
    query = query.order_by(Ticket.created_at.desc())

    result = await db.execute(query)
    tickets = result.scalars().all()

    return tickets
```

### 9. Error Handling & Middleware

Consistent error responses and logging.

**Custom Exception Handlers:**
```python
from fastapi.responses import JSONResponse

class TicketNotFoundError(Exception):
    def __init__(self, ticket_id: int):
        self.ticket_id = ticket_id

@app.exception_handler(TicketNotFoundError)
async def ticket_not_found_handler(request: Request, exc: TicketNotFoundError):
    return JSONResponse(
        status_code=404,
        content={
            "error": "ticket_not_found",
            "message": f"Ticket with ID {exc.ticket_id} not found",
            "ticket_id": exc.ticket_id
        }
    )

@app.exception_handler(ValidationError)
async def validation_exception_handler(request: Request, exc: ValidationError):
    return JSONResponse(
        status_code=422,
        content={
            "error": "validation_error",
            "message": "Invalid request data",
            "details": exc.errors()
        }
    )
```

**Logging Middleware:**
```python
import time
import logging

logger = logging.getLogger(__name__)

@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()

    # Log request
    logger.info(f"Request: {request.method} {request.url}")

    response = await call_next(request)

    # Log response
    process_time = time.time() - start_time
    logger.info(
        f"Response: {response.status_code} "
        f"(took {process_time:.2f}s)"
    )

    response.headers["X-Process-Time"] = str(process_time)
    return response
```

### 10. CORS Configuration

Enable web clients to access the API.

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",  # React dev server
        "https://support.company.com"  # Production domain
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 11. API Documentation

FastAPI automatically generates interactive documentation.

**Customizing Documentation:**
```python
from fastapi import FastAPI

app = FastAPI(
    title="Customer Support API",
    description="API for managing customer support tickets, agents, and real-time chat",
    version="1.0.0",
    contact={
        "name": "Support Team",
        "email": "tech@company.com"
    },
    license_info={
        "name": "MIT"
    }
)

# Add tags for organization
tags_metadata = [
    {
        "name": "tickets",
        "description": "Operations with support tickets",
    },
    {
        "name": "users",
        "description": "User and agent management",
    },
    {
        "name": "chat",
        "description": "Real-time chat via WebSocket",
    },
]

app = FastAPI(openapi_tags=tags_metadata)
```

### 12. Testing

Comprehensive testing with pytest and httpx.

**Test Setup:**
```python
import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from main import app, get_db

TEST_DATABASE_URL = "postgresql+asyncpg://user:password@localhost/test_support_db"

@pytest.fixture
async def test_db():
    engine = create_async_engine(TEST_DATABASE_URL)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    TestSessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with TestSessionLocal() as session:
        yield session

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

@pytest.fixture
async def client(test_db):
    async def override_get_db():
        yield test_db

    app.dependency_overrides[get_db] = override_get_db
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac
    app.dependency_overrides.clear()

@pytest.mark.anyio
async def test_create_ticket(client: AsyncClient):
    response = await client.post(
        "/tickets/",
        json={
            "title": "Test Ticket",
            "description": "This is a test ticket",
            "priority": "high",
            "category": "technical",
            "customer_email": "customer@example.com"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == "Test Ticket"
    assert data["status"] == "open"
```

## Performance Optimization

### Database Query Optimization

**Use Eager Loading:**
```python
from sqlalchemy.orm import selectinload

@app.get("/tickets/{ticket_id}/full")
async def get_ticket_with_comments(
    ticket_id: int,
    db: AsyncSession = Depends(get_db)
):
    query = select(Ticket).options(
        selectinload(Ticket.comments),
        selectinload(Ticket.assigned_agent)
    ).where(Ticket.id == ticket_id)

    result = await db.execute(query)
    ticket = result.scalar_one_or_none()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")
    return ticket
```

**Database Connection Pooling:**
```python
engine = create_async_engine(
    DATABASE_URL,
    pool_size=10,
    max_overflow=20,
    pool_pre_ping=True,
    pool_recycle=3600
)
```

### Caching with Redis

```python
import redis.asyncio as redis
from fastapi import Depends

redis_client = redis.Redis(host='localhost', port=6379, decode_responses=True)

async def get_cached_ticket(ticket_id: int) -> Optional[dict]:
    cached = await redis_client.get(f"ticket:{ticket_id}")
    if cached:
        return json.loads(cached)
    return None

async def cache_ticket(ticket_id: int, data: dict, expire: int = 300):
    await redis_client.setex(
        f"ticket:{ticket_id}",
        expire,
        json.dumps(data)
    )

@app.get("/tickets/{ticket_id}")
async def get_ticket(
    ticket_id: int,
    db: AsyncSession = Depends(get_db)
):
    # Try cache first
    cached = await get_cached_ticket(ticket_id)
    if cached:
        return cached

    # Query database
    result = await db.execute(select(Ticket).where(Ticket.id == ticket_id))
    ticket = result.scalar_one_or_none()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    # Cache result
    ticket_dict = {
        "id": ticket.id,
        "title": ticket.title,
        "status": ticket.status.value,
        # ... other fields
    }
    await cache_ticket(ticket_id, ticket_dict)

    return ticket_dict
```

## Security Best Practices

1. **Environment Variables**: Never hardcode secrets
2. **Input Validation**: Use Pydantic models for all inputs
3. **Rate Limiting**: Implement with slowapi or custom middleware
4. **SQL Injection Prevention**: Use SQLAlchemy ORM (never raw SQL)
5. **HTTPS Only**: Configure SSL/TLS in production
6. **CORS**: Restrict to known origins
7. **Authentication**: Use JWT with short expiration times
8. **Password Hashing**: Always use bcrypt or similar

## Deployment Considerations

### Docker Configuration

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Health Checks

```python
@app.get("/health")
async def health_check(db: AsyncSession = Depends(get_db)):
    try:
        # Check database connection
        await db.execute(text("SELECT 1"))
        return {
            "status": "healthy",
            "database": "connected",
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        raise HTTPException(
            status_code=503,
            detail=f"Service unhealthy: {str(e)}"
        )
```

## Monitoring & Observability

### Prometheus Metrics

```python
from prometheus_client import Counter, Histogram, generate_latest
from fastapi.responses import Response

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')

@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    duration = time.time() - start_time

    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.url.path,
        status=response.status_code
    ).inc()
    REQUEST_DURATION.observe(duration)

    return response

@app.get("/metrics")
async def metrics():
    return Response(generate_latest(), media_type="text/plain")
```

## Common Patterns for Customer Support

### 1. Ticket Assignment Logic

```python
@app.post("/tickets/{ticket_id}/assign")
async def assign_ticket(
    ticket_id: int,
    agent_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_agent)
):
    # Get ticket
    result = await db.execute(select(Ticket).where(Ticket.id == ticket_id))
    ticket = result.scalar_one_or_none()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")

    # Verify agent exists and is active
    agent_result = await db.execute(select(User).where(User.id == agent_id))
    agent = agent_result.scalar_one_or_none()
    if not agent or agent.role != "agent" or not agent.is_active:
        raise HTTPException(status_code=400, detail="Invalid agent")

    # Update ticket
    ticket.assigned_to = agent_id
    ticket.status = TicketStatusEnum.IN_PROGRESS
    await db.commit()

    return {"message": f"Ticket assigned to {agent.full_name}"}
```

### 2. SLA Tracking

```python
from datetime import timedelta

def calculate_sla_breach(ticket: Ticket) -> dict:
    sla_hours = {
        TicketPriorityEnum.URGENT: 4,
        TicketPriorityEnum.HIGH: 8,
        TicketPriorityEnum.MEDIUM: 24,
        TicketPriorityEnum.LOW: 48
    }

    sla_deadline = ticket.created_at + timedelta(hours=sla_hours[ticket.priority])
    now = datetime.utcnow()

    if ticket.status in [TicketStatusEnum.RESOLVED, TicketStatusEnum.CLOSED]:
        resolution_time = ticket.resolved_at or ticket.updated_at
        breached = resolution_time > sla_deadline
        time_to_resolution = (resolution_time - ticket.created_at).total_seconds() / 3600
    else:
        breached = now > sla_deadline
        time_to_resolution = None

    return {
        "sla_deadline": sla_deadline,
        "breached": breached,
        "time_to_resolution_hours": time_to_resolution
    }
```

### 3. Bulk Operations

```python
@app.post("/tickets/bulk-update")
async def bulk_update_tickets(
    ticket_ids: List[int],
    update_data: TicketUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_agent)
):
    result = await db.execute(
        select(Ticket).where(Ticket.id.in_(ticket_ids))
    )
    tickets = result.scalars().all()

    if not tickets:
        raise HTTPException(status_code=404, detail="No tickets found")

    for ticket in tickets:
        if update_data.status:
            ticket.status = update_data.status
        if update_data.priority:
            ticket.priority = update_data.priority
        if update_data.assigned_to:
            ticket.assigned_to = update_data.assigned_to

    await db.commit()

    return {"updated_count": len(tickets), "ticket_ids": ticket_ids}
```

## Troubleshooting Guide

### Common Issues

**1. Database Connection Errors**
- Check connection string format: `postgresql+asyncpg://user:pass@host:port/db`
- Ensure asyncpg is installed: `pip install asyncpg`
- Verify PostgreSQL is running and accepting connections

**2. Async/Await Errors**
- Always use `async def` for async database operations
- Use `await` when calling async functions
- Don't mix sync and async SQLAlchemy sessions

**3. Pydantic Validation Errors**
- Check field types match the schema
- Use Optional[] for nullable fields
- Add validators for custom business logic

**4. JWT Token Issues**
- Verify SECRET_KEY is consistent
- Check token expiration time
- Ensure ALGORITHM matches between encoding and decoding

**5. WebSocket Connection Drops**
- Implement reconnection logic on client side
- Add heartbeat/ping messages
- Check for network timeouts

## Summary

This FastAPI skill provides everything needed to build production-ready customer support APIs with:
- High-performance async operations
- Type-safe data validation
- Secure authentication
- Real-time communication
- Comprehensive testing
- Monitoring and observability

Key advantages for customer support systems:
- Handle thousands of concurrent requests
- Real-time updates for agents and customers
- Automatic API documentation for onboarding
- Type safety reduces bugs in critical workflows
- Easy integration with PostgreSQL and other databases
