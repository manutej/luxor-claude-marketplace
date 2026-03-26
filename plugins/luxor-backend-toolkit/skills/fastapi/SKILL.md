---
name: "fastapi-customer-support"
description: "FastAPI patterns for customer support APIs including async endpoints, Pydantic validation, SQLAlchemy integration, WebSocket chat, JWT auth, and background tasks. Use when building Python support ticket systems, real-time agent chat, or async REST APIs with FastAPI and PostgreSQL."
---

# FastAPI Customer Support API Patterns

Production-ready patterns for building customer support APIs with FastAPI, async SQLAlchemy, Pydantic validation, and WebSocket real-time chat.

## Async Endpoints & Database Sessions

```python
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from fastapi import FastAPI, Depends, HTTPException

DATABASE_URL = "postgresql+asyncpg://user:password@localhost/support_db"
engine = create_async_engine(DATABASE_URL, pool_size=10, max_overflow=20, pool_pre_ping=True)
AsyncSessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise

@app.get("/tickets/{ticket_id}")
async def get_ticket(ticket_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Ticket).where(Ticket.id == ticket_id))
    ticket = result.scalar_one_or_none()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")
    return ticket
```

## Pydantic Request Validation

```python
from pydantic import BaseModel, EmailStr, Field, validator
from enum import Enum

class TicketPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"

class TicketCreate(BaseModel):
    title: str = Field(..., min_length=3, max_length=200)
    description: str = Field(..., min_length=10)
    priority: TicketPriority = TicketPriority.MEDIUM
    category: str = Field(..., max_length=50)
    customer_email: EmailStr

    @validator('title')
    def title_must_not_be_empty(cls, v):
        if not v.strip():
            raise ValueError('Title cannot be empty or whitespace')
        return v.strip()
```

## JWT Authentication & Role-Based Access

```python
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

async def get_current_user(token: str = Depends(oauth2_scheme), db: AsyncSession = Depends(get_db)) -> User:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=401, detail="Invalid credentials")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    result = await db.execute(select(User).where(User.username == username))
    user = result.scalar_one_or_none()
    if user is None:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return user

async def get_current_active_agent(current_user: User = Depends(get_current_user)) -> User:
    if not current_user.is_active or current_user.role != "agent":
        raise HTTPException(status_code=403, detail="Not authorized as support agent")
    return current_user
```

## WebSocket Real-Time Chat

```python
class ConnectionManager:
    def __init__(self):
        self.active_connections: dict[int, list[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, ticket_id: int):
        await websocket.accept()
        self.active_connections.setdefault(ticket_id, []).append(websocket)

    async def broadcast(self, message: str, ticket_id: int, exclude: WebSocket = None):
        for conn in self.active_connections.get(ticket_id, []):
            if conn != exclude:
                await conn.send_text(message)

manager = ConnectionManager()

@app.websocket("/ws/ticket/{ticket_id}")
async def websocket_endpoint(websocket: WebSocket, ticket_id: int, token: str):
    # Verify JWT token, then manage connection
    await manager.connect(websocket, ticket_id)
    try:
        while True:
            data = await websocket.receive_text()
            await manager.broadcast(json.dumps({"ticket_id": ticket_id, "message": data}), ticket_id)
    except WebSocketDisconnect:
        manager.disconnect(websocket, ticket_id)
```

## Background Tasks & Pagination

```python
@app.post("/tickets/")
async def create_ticket(ticket: TicketCreate, background_tasks: BackgroundTasks, db: AsyncSession = Depends(get_db)):
    db_ticket = Ticket(**ticket.dict())
    db.add(db_ticket)
    await db.commit()
    await db.refresh(db_ticket)
    background_tasks.add_task(send_email_notification, ticket.customer_email, f"Ticket #{db_ticket.id} Created")
    return db_ticket

@app.get("/tickets/", response_model=list[TicketResponse])
async def list_tickets(
    status: TicketStatus | None = None,
    priority: TicketPriority | None = None,
    skip: int = 0,
    limit: int = Query(10, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
):
    query = select(Ticket)
    if status:
        query = query.where(Ticket.status == status)
    if priority:
        query = query.where(Ticket.priority == priority)
    result = await db.execute(query.offset(skip).limit(limit).order_by(Ticket.created_at.desc()))
    return result.scalars().all()
```

## Eager Loading & Caching

```python
from sqlalchemy.orm import selectinload

# Eager load related data to avoid N+1 queries
query = select(Ticket).options(
    selectinload(Ticket.comments),
    selectinload(Ticket.assigned_agent)
).where(Ticket.id == ticket_id)

# Redis caching for frequently accessed tickets
async def get_cached_ticket(ticket_id: int) -> dict | None:
    cached = await redis_client.get(f"ticket:{ticket_id}")
    return json.loads(cached) if cached else None
```

## Error Handling & Middleware

```python
@app.exception_handler(TicketNotFoundError)
async def ticket_not_found_handler(request, exc):
    return JSONResponse(status_code=404, content={"error": "ticket_not_found", "ticket_id": exc.ticket_id})

@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    response.headers["X-Process-Time"] = str(time.time() - start_time)
    return response
```

## Testing with pytest & httpx

```python
@pytest.fixture
async def client(test_db):
    app.dependency_overrides[get_db] = lambda: test_db
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac
    app.dependency_overrides.clear()

@pytest.mark.anyio
async def test_create_ticket(client: AsyncClient):
    response = await client.post("/tickets/", json={
        "title": "Test Ticket", "description": "This is a test ticket",
        "priority": "high", "category": "technical", "customer_email": "customer@example.com"
    })
    assert response.status_code == 200
    assert response.json()["status"] == "open"
```

See [EXAMPLES.md](EXAMPLES.md) for full application examples including SLA tracking, bulk operations, Docker deployment, and Prometheus metrics integration.
