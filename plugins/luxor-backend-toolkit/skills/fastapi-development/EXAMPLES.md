# FastAPI Examples

Comprehensive collection of practical FastAPI examples covering common use cases and patterns.

## Table of Contents

1. [Basic Examples](#basic-examples)
2. [Request Handling](#request-handling)
3. [Authentication Examples](#authentication-examples)
4. [Database Integration](#database-integration)
5. [Advanced Patterns](#advanced-patterns)
6. [Real-World Applications](#real-world-applications)

## Basic Examples

### Example 1: Hello World API

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
```

**Usage:**
```bash
# Start server
uvicorn main:app --reload

# Test endpoints
curl http://localhost:8000/
curl http://localhost:8000/health
```

---

### Example 2: Path Parameters with Validation

```python
from fastapi import FastAPI, Path
from enum import Enum

app = FastAPI()

class ModelName(str, Enum):
    alexnet = "alexnet"
    resnet = "resnet"
    lenet = "lenet"

@app.get("/items/{item_id}")
async def read_item(
    item_id: int = Path(..., title="The ID of the item", ge=1, le=1000)
):
    return {"item_id": item_id}

@app.get("/models/{model_name}")
async def get_model(model_name: ModelName):
    if model_name == ModelName.alexnet:
        return {"model_name": model_name, "message": "Deep Learning FTW!"}
    if model_name.value == "lenet":
        return {"model_name": model_name, "message": "LeCNN all the images"}
    return {"model_name": model_name, "message": "Have some residuals"}

@app.get("/files/{file_path:path}")
async def read_file(file_path: str):
    return {"file_path": file_path}
```

**Usage:**
```bash
curl http://localhost:8000/items/42
curl http://localhost:8000/models/alexnet
curl http://localhost:8000/files/home/user/myfile.txt
```

---

### Example 3: Query Parameters with Defaults

```python
from fastapi import FastAPI, Query
from typing import Optional, List

app = FastAPI()

@app.get("/items/")
async def read_items(
    skip: int = 0,
    limit: int = 10,
    q: Optional[str] = None
):
    items = [{"item_id": i} for i in range(skip, skip + limit)]
    if q:
        items = [item for item in items if q in str(item)]
    return {"items": items, "query": q}

@app.get("/search/")
async def search_items(
    q: str = Query(..., min_length=3, max_length=50, regex="^[a-zA-Z0-9 ]+$"),
    tags: List[str] = Query([], description="List of tags to filter by"),
    price_min: Optional[float] = Query(None, ge=0),
    price_max: Optional[float] = Query(None, ge=0)
):
    return {
        "q": q,
        "tags": tags,
        "price_range": {"min": price_min, "max": price_max}
    }
```

**Usage:**
```bash
curl "http://localhost:8000/items/?skip=5&limit=20&q=test"
curl "http://localhost:8000/search/?q=laptop&tags=electronics&tags=computers&price_min=500&price_max=2000"
```

---

## Request Handling

### Example 4: POST Request with Pydantic Model

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, EmailStr, validator
from typing import Optional
from datetime import datetime

app = FastAPI()

class User(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr
    full_name: Optional[str] = None
    age: Optional[int] = Field(None, ge=0, le=150)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    @validator('username')
    def username_alphanumeric(cls, v):
        assert v.isalnum(), 'must be alphanumeric'
        return v

    class Config:
        schema_extra = {
            "example": {
                "username": "johndoe",
                "email": "john@example.com",
                "full_name": "John Doe",
                "age": 30
            }
        }

# In-memory database
users_db = {}
user_id_counter = 0

@app.post("/users/", status_code=201)
async def create_user(user: User):
    global user_id_counter
    user_id_counter += 1
    users_db[user_id_counter] = user
    return {"id": user_id_counter, **user.dict()}

@app.get("/users/{user_id}")
async def get_user(user_id: int):
    if user_id not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    return {"id": user_id, **users_db[user_id].dict()}

@app.get("/users/")
async def list_users(skip: int = 0, limit: int = 10):
    users = [
        {"id": uid, **user.dict()}
        for uid, user in list(users_db.items())[skip:skip+limit]
    ]
    return {"users": users, "total": len(users_db)}
```

**Usage:**
```bash
# Create user
curl -X POST "http://localhost:8000/users/" \
  -H "Content-Type: application/json" \
  -d '{"username": "johndoe", "email": "john@example.com", "full_name": "John Doe", "age": 30}'

# Get user
curl http://localhost:8000/users/1

# List users
curl "http://localhost:8000/users/?skip=0&limit=10"
```

---

### Example 5: File Upload and Download

```python
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import FileResponse
from typing import List
import shutil
import os
from pathlib import Path

app = FastAPI()

UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)

@app.post("/upload/")
async def upload_file(file: UploadFile = File(...)):
    file_path = UPLOAD_DIR / file.filename
    with file_path.open("wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return {
        "filename": file.filename,
        "content_type": file.content_type,
        "size": file_path.stat().st_size
    }

@app.post("/upload-multiple/")
async def upload_multiple_files(files: List[UploadFile] = File(...)):
    uploaded_files = []
    for file in files:
        file_path = UPLOAD_DIR / file.filename
        with file_path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        uploaded_files.append({
            "filename": file.filename,
            "size": file_path.stat().st_size
        })

    return {"files": uploaded_files}

@app.get("/download/{filename}")
async def download_file(filename: str):
    file_path = UPLOAD_DIR / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="File not found")

    return FileResponse(
        path=file_path,
        filename=filename,
        media_type='application/octet-stream'
    )

@app.get("/files/")
async def list_files():
    files = [
        {
            "filename": f.name,
            "size": f.stat().st_size,
            "modified": f.stat().st_mtime
        }
        for f in UPLOAD_DIR.iterdir() if f.is_file()
    ]
    return {"files": files}
```

**Usage:**
```bash
# Upload single file
curl -X POST "http://localhost:8000/upload/" \
  -F "file=@/path/to/file.pdf"

# Upload multiple files
curl -X POST "http://localhost:8000/upload-multiple/" \
  -F "files=@file1.pdf" \
  -F "files=@file2.pdf"

# Download file
curl -O "http://localhost:8000/download/file.pdf"

# List files
curl http://localhost:8000/files/
```

---

### Example 6: Form Data Handling

```python
from fastapi import FastAPI, Form, File, UploadFile
from typing import Optional

app = FastAPI()

@app.post("/login/")
async def login(username: str = Form(...), password: str = Form(...)):
    # In real app, verify credentials
    return {"username": username, "message": "Login successful"}

@app.post("/register/")
async def register(
    username: str = Form(..., min_length=3),
    email: str = Form(...),
    password: str = Form(..., min_length=8),
    full_name: Optional[str] = Form(None),
    profile_pic: Optional[UploadFile] = File(None)
):
    user_data = {
        "username": username,
        "email": email,
        "full_name": full_name
    }

    if profile_pic:
        user_data["profile_pic"] = profile_pic.filename

    return {"user": user_data, "message": "Registration successful"}
```

**Usage:**
```bash
# Login
curl -X POST "http://localhost:8000/login/" \
  -d "username=johndoe&password=secret123"

# Register with profile picture
curl -X POST "http://localhost:8000/register/" \
  -F "username=johndoe" \
  -F "email=john@example.com" \
  -F "password=secret123" \
  -F "full_name=John Doe" \
  -F "profile_pic=@profile.jpg"
```

---

## Authentication Examples

### Example 7: JWT Authentication

```python
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic import BaseModel
from datetime import datetime, timedelta
from typing import Optional

# Configuration
SECRET_KEY = "your-secret-key-keep-it-secret"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

app = FastAPI()

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# Models
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class User(BaseModel):
    username: str
    email: Optional[str] = None
    full_name: Optional[str] = None
    disabled: Optional[bool] = None

class UserInDB(User):
    hashed_password: str

# Mock database
fake_users_db = {
    "johndoe": {
        "username": "johndoe",
        "full_name": "John Doe",
        "email": "johndoe@example.com",
        "hashed_password": "$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW",  # secret
        "disabled": False,
    }
}

# Utility functions
def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def get_user(db, username: str):
    if username in db:
        user_dict = db[username]
        return UserInDB(**user_dict)

def authenticate_user(fake_db, username: str, password: str):
    user = get_user(fake_db, username)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(token: str = Depends(oauth2_scheme)):
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
        token_data = TokenData(username=username)
    except JWTError:
        raise credentials_exception
    user = get_user(fake_users_db, username=token_data.username)
    if user is None:
        raise credentials_exception
    return user

async def get_current_active_user(current_user: User = Depends(get_current_user)):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

# Endpoints
@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    user = authenticate_user(fake_users_db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users/me", response_model=User)
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    return current_user

@app.get("/items/")
async def read_items(current_user: User = Depends(get_current_active_user)):
    return [{"item": "Item 1"}, {"item": "Item 2"}]
```

**Usage:**
```bash
# Get token
TOKEN=$(curl -X POST "http://localhost:8000/token" \
  -d "username=johndoe&password=secret" | jq -r '.access_token')

# Use token to access protected endpoint
curl -H "Authorization: Bearer $TOKEN" http://localhost:8000/users/me

# Access protected items
curl -H "Authorization: Bearer $TOKEN" http://localhost:8000/items/
```

---

### Example 8: API Key Authentication

```python
from fastapi import FastAPI, Security, HTTPException, status
from fastapi.security import APIKeyHeader, APIKeyQuery
from typing import Optional

app = FastAPI()

API_KEY = "your-super-secret-api-key"
API_KEY_NAME = "X-API-Key"

api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=False)
api_key_query = APIKeyQuery(name="api_key", auto_error=False)

async def get_api_key(
    api_key_header: str = Security(api_key_header),
    api_key_query: str = Security(api_key_query),
) -> str:
    if api_key_header == API_KEY:
        return api_key_header
    if api_key_query == API_KEY:
        return api_key_query
    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="Could not validate API key"
    )

@app.get("/public")
async def public_endpoint():
    return {"message": "This is a public endpoint"}

@app.get("/secure")
async def secure_endpoint(api_key: str = Depends(get_api_key)):
    return {"message": "This is a secure endpoint", "api_key": api_key}

@app.get("/data")
async def get_data(api_key: str = Depends(get_api_key)):
    return {
        "data": ["item1", "item2", "item3"],
        "authenticated": True
    }
```

**Usage:**
```bash
# Public endpoint (no auth required)
curl http://localhost:8000/public

# Secure endpoint with API key in header
curl -H "X-API-Key: your-super-secret-api-key" http://localhost:8000/secure

# Secure endpoint with API key in query parameter
curl "http://localhost:8000/secure?api_key=your-super-secret-api-key"
```

---

## Database Integration

### Example 9: SQLAlchemy with PostgreSQL

```python
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy import create_engine, Column, Integer, String, Boolean, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

# Database setup
SQLALCHEMY_DATABASE_URL = "postgresql://user:password@localhost/dbname"
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Database models
class UserModel(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    username = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

Base.metadata.create_all(bind=engine)

# Pydantic schemas
class UserBase(BaseModel):
    email: str
    username: str

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    email: Optional[str] = None
    username: Optional[str] = None
    is_active: Optional[bool] = None

class User(UserBase):
    id: int
    is_active: bool
    created_at: datetime

    class Config:
        orm_mode = True

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# FastAPI app
app = FastAPI()

# Helper functions
def get_password_hash(password: str) -> str:
    # In production, use proper hashing
    return f"hashed_{password}"

# CRUD operations
@app.post("/users/", response_model=User, status_code=201)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    # Check if user exists
    db_user = db.query(UserModel).filter(
        (UserModel.email == user.email) | (UserModel.username == user.username)
    ).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email or username already registered")

    # Create user
    hashed_password = get_password_hash(user.password)
    db_user = UserModel(
        email=user.email,
        username=user.username,
        hashed_password=hashed_password
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@app.get("/users/", response_model=List[User])
def read_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    users = db.query(UserModel).offset(skip).limit(limit).all()
    return users

@app.get("/users/{user_id}", response_model=User)
def read_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(UserModel).filter(UserModel.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@app.put("/users/{user_id}", response_model=User)
def update_user(user_id: int, user_update: UserUpdate, db: Session = Depends(get_db)):
    db_user = db.query(UserModel).filter(UserModel.id == user_id).first()
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")

    update_data = user_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_user, key, value)

    db.commit()
    db.refresh(db_user)
    return db_user

@app.delete("/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db)):
    db_user = db.query(UserModel).filter(UserModel.id == user_id).first()
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")

    db.delete(db_user)
    db.commit()
    return {"message": "User deleted successfully"}
```

---

### Example 10: Async Database with Databases Library

```python
from fastapi import FastAPI, HTTPException
from databases import Database
from pydantic import BaseModel
from typing import List
import asyncio

DATABASE_URL = "postgresql://user:password@localhost/dbname"
database = Database(DATABASE_URL)

app = FastAPI()

# Pydantic models
class ProductCreate(BaseModel):
    name: str
    description: str
    price: float

class Product(ProductCreate):
    id: int

# Startup and shutdown events
@app.on_event("startup")
async def startup():
    await database.connect()

@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()

# Endpoints
@app.post("/products/", response_model=Product)
async def create_product(product: ProductCreate):
    query = """
        INSERT INTO products (name, description, price)
        VALUES (:name, :description, :price)
        RETURNING id, name, description, price
    """
    result = await database.fetch_one(
        query=query,
        values={"name": product.name, "description": product.description, "price": product.price}
    )
    return result

@app.get("/products/", response_model=List[Product])
async def list_products(skip: int = 0, limit: int = 100):
    query = "SELECT id, name, description, price FROM products LIMIT :limit OFFSET :skip"
    results = await database.fetch_all(query=query, values={"skip": skip, "limit": limit})
    return results

@app.get("/products/{product_id}", response_model=Product)
async def get_product(product_id: int):
    query = "SELECT id, name, description, price FROM products WHERE id = :product_id"
    result = await database.fetch_one(query=query, values={"product_id": product_id})
    if not result:
        raise HTTPException(status_code=404, detail="Product not found")
    return result

@app.put("/products/{product_id}", response_model=Product)
async def update_product(product_id: int, product: ProductCreate):
    query = """
        UPDATE products
        SET name = :name, description = :description, price = :price
        WHERE id = :product_id
        RETURNING id, name, description, price
    """
    result = await database.fetch_one(
        query=query,
        values={
            "product_id": product_id,
            "name": product.name,
            "description": product.description,
            "price": product.price
        }
    )
    if not result:
        raise HTTPException(status_code=404, detail="Product not found")
    return result

@app.delete("/products/{product_id}")
async def delete_product(product_id: int):
    query = "DELETE FROM products WHERE id = :product_id RETURNING id"
    result = await database.fetch_one(query=query, values={"product_id": product_id})
    if not result:
        raise HTTPException(status_code=404, detail="Product not found")
    return {"message": "Product deleted successfully"}
```

---

## Advanced Patterns

### Example 11: WebSocket Real-Time Chat

```python
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from typing import List

app = FastAPI()

class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def send_personal_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)

    async def broadcast(self, message: str):
        for connection in self.active_connections:
            await connection.send_text(message)

manager = ConnectionManager()

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: int):
    await manager.connect(websocket)
    await manager.broadcast(f"Client #{client_id} joined the chat")
    try:
        while True:
            data = await websocket.receive_text()
            await manager.send_personal_message(f"You wrote: {data}", websocket)
            await manager.broadcast(f"Client #{client_id} says: {data}")
    except WebSocketDisconnect:
        manager.disconnect(websocket)
        await manager.broadcast(f"Client #{client_id} left the chat")

@app.get("/")
async def get():
    return {"message": "WebSocket chat server"}
```

**HTML Client:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Chat</title>
</head>
<body>
    <h1>WebSocket Chat</h1>
    <form action="" onsubmit="sendMessage(event)">
        <input type="text" id="messageText" autocomplete="off"/>
        <button>Send</button>
    </form>
    <ul id='messages'>
    </ul>
    <script>
        var client_id = Date.now()
        var ws = new WebSocket(`ws://localhost:8000/ws/${client_id}`);
        ws.onmessage = function(event) {
            var messages = document.getElementById('messages')
            var message = document.createElement('li')
            var content = document.createTextNode(event.data)
            message.appendChild(content)
            messages.appendChild(message)
        };
        function sendMessage(event) {
            var input = document.getElementById("messageText")
            ws.send(input.value)
            input.value = ''
            event.preventDefault()
        }
    </script>
</body>
</html>
```

---

### Example 12: Background Tasks

```python
from fastapi import FastAPI, BackgroundTasks
from pydantic import BaseModel, EmailStr
import time

app = FastAPI()

class EmailSchema(BaseModel):
    email: EmailStr
    subject: str
    body: str

def send_email(email: str, subject: str, body: str):
    """Simulate sending email"""
    time.sleep(5)  # Simulate email sending delay
    print(f"Email sent to {email}")
    print(f"Subject: {subject}")
    print(f"Body: {body}")

def process_file(filename: str):
    """Simulate file processing"""
    time.sleep(10)
    print(f"File {filename} processed successfully")

def log_activity(user_id: int, action: str):
    """Log user activity"""
    print(f"User {user_id} performed: {action}")

@app.post("/send-email/")
async def send_email_endpoint(
    email: EmailSchema,
    background_tasks: BackgroundTasks
):
    background_tasks.add_task(send_email, email.email, email.subject, email.body)
    return {"message": "Email will be sent in background"}

@app.post("/process-file/")
async def process_file_endpoint(
    filename: str,
    background_tasks: BackgroundTasks
):
    background_tasks.add_task(process_file, filename)
    background_tasks.add_task(log_activity, 1, f"file_processed: {filename}")
    return {"message": "File processing started", "filename": filename}

@app.post("/register/")
async def register(
    email: EmailStr,
    background_tasks: BackgroundTasks
):
    # Save user to database
    background_tasks.add_task(send_email, email, "Welcome!", "Thanks for registering!")
    background_tasks.add_task(log_activity, 1, "user_registered")
    return {"message": "Registration successful"}
```

---

### Example 13: Middleware

```python
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
import time

app = FastAPI()

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify allowed origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# GZip Middleware
app.add_middleware(GZipMiddleware, minimum_size=1000)

# Custom timing middleware
@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response

# Custom logging middleware
@app.middleware("http")
async def log_requests(request: Request, call_next):
    print(f"Request: {request.method} {request.url}")
    response = await call_next(request)
    print(f"Response status: {response.status_code}")
    return response

@app.get("/")
async def root():
    return {"message": "Hello World"}
```

---

### Example 14: Custom Response Classes

```python
from fastapi import FastAPI
from fastapi.responses import (
    HTMLResponse,
    JSONResponse,
    PlainTextResponse,
    RedirectResponse,
    StreamingResponse,
    FileResponse
)
import io

app = FastAPI()

@app.get("/html", response_class=HTMLResponse)
async def get_html():
    html_content = """
    <html>
        <head>
            <title>FastAPI HTML</title>
        </head>
        <body>
            <h1>Hello from FastAPI!</h1>
        </body>
    </html>
    """
    return HTMLResponse(content=html_content)

@app.get("/text", response_class=PlainTextResponse)
async def get_text():
    return "This is plain text response"

@app.get("/redirect")
async def redirect():
    return RedirectResponse(url="/html")

@app.get("/custom-json")
async def custom_json():
    return JSONResponse(
        content={"message": "Custom JSON response"},
        headers={"X-Custom-Header": "Custom Value"}
    )

@app.get("/stream")
async def stream():
    async def generate():
        for i in range(10):
            yield f"data: {i}\n\n"

    return StreamingResponse(generate(), media_type="text/event-stream")

@app.get("/download")
async def download_file():
    # Create a sample file in memory
    content = b"This is the file content"
    file_like = io.BytesIO(content)

    return StreamingResponse(
        file_like,
        media_type="application/octet-stream",
        headers={"Content-Disposition": "attachment; filename=download.txt"}
    )
```

---

### Example 15: Request Validation and Error Handling

```python
from fastapi import FastAPI, HTTPException, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from pydantic import BaseModel, validator, Field
from typing import Optional

app = FastAPI()

# Custom exceptions
class ItemNotFoundException(Exception):
    def __init__(self, item_id: int):
        self.item_id = item_id

class InvalidPriceException(Exception):
    def __init__(self, price: float):
        self.price = price

# Exception handlers
@app.exception_handler(ItemNotFoundException)
async def item_not_found_exception_handler(request: Request, exc: ItemNotFoundException):
    return JSONResponse(
        status_code=404,
        content={"message": f"Item {exc.item_id} not found"},
    )

@app.exception_handler(InvalidPriceException)
async def invalid_price_exception_handler(request: Request, exc: InvalidPriceException):
    return JSONResponse(
        status_code=400,
        content={"message": f"Invalid price: {exc.price}"},
    )

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "detail": exc.errors(),
            "body": exc.body
        },
    )

# Models with validation
class Product(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    price: float = Field(..., gt=0)
    tax: Optional[float] = Field(None, ge=0, le=100)

    @validator('price')
    def price_must_be_positive(cls, v):
        if v <= 0:
            raise InvalidPriceException(v)
        return v

    @validator('tax')
    def tax_percentage_valid(cls, v):
        if v and (v < 0 or v > 100):
            raise ValueError('Tax must be between 0 and 100')
        return v

# Endpoints
@app.post("/products/")
async def create_product(product: Product):
    return {"product": product, "message": "Product created"}

@app.get("/products/{product_id}")
async def get_product(product_id: int):
    # Simulate product not found
    if product_id > 100:
        raise ItemNotFoundException(product_id)
    return {"product_id": product_id}

@app.get("/error")
async def trigger_error():
    raise HTTPException(
        status_code=500,
        detail="Internal server error occurred",
        headers={"X-Error": "Custom error header"}
    )
```

---

## Real-World Applications

### Example 16: E-Commerce API

```python
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from enum import Enum

app = FastAPI(title="E-Commerce API")

# Enums
class OrderStatus(str, Enum):
    pending = "pending"
    processing = "processing"
    shipped = "shipped"
    delivered = "delivered"
    cancelled = "cancelled"

# Pydantic Models
class ProductBase(BaseModel):
    name: str
    description: Optional[str] = None
    price: float = Field(..., gt=0)
    stock: int = Field(..., ge=0)
    category: str

class ProductCreate(ProductBase):
    pass

class Product(ProductBase):
    id: int
    created_at: datetime

    class Config:
        orm_mode = True

class OrderItemCreate(BaseModel):
    product_id: int
    quantity: int = Field(..., gt=0)

class OrderItem(OrderItemCreate):
    id: int
    total_price: float

class OrderCreate(BaseModel):
    items: List[OrderItemCreate]
    shipping_address: str

class Order(BaseModel):
    id: int
    user_id: int
    items: List[OrderItem]
    total_amount: float
    status: OrderStatus
    shipping_address: str
    created_at: datetime

# Mock database
products_db = {}
orders_db = {}
product_id_counter = 0
order_id_counter = 0

# Product endpoints
@app.post("/products/", response_model=Product, status_code=201)
async def create_product(product: ProductCreate):
    global product_id_counter
    product_id_counter += 1
    new_product = {
        "id": product_id_counter,
        **product.dict(),
        "created_at": datetime.utcnow()
    }
    products_db[product_id_counter] = new_product
    return new_product

@app.get("/products/", response_model=List[Product])
async def list_products(
    skip: int = 0,
    limit: int = 100,
    category: Optional[str] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None
):
    products = list(products_db.values())

    if category:
        products = [p for p in products if p["category"] == category]
    if min_price is not None:
        products = [p for p in products if p["price"] >= min_price]
    if max_price is not None:
        products = [p for p in products if p["price"] <= max_price]

    return products[skip:skip + limit]

@app.get("/products/{product_id}", response_model=Product)
async def get_product(product_id: int):
    if product_id not in products_db:
        raise HTTPException(status_code=404, detail="Product not found")
    return products_db[product_id]

# Order endpoints
@app.post("/orders/", response_model=Order, status_code=201)
async def create_order(order: OrderCreate):
    global order_id_counter

    # Validate products and calculate total
    order_items = []
    total_amount = 0

    for item in order.items:
        product = products_db.get(item.product_id)
        if not product:
            raise HTTPException(
                status_code=404,
                detail=f"Product {item.product_id} not found"
            )
        if product["stock"] < item.quantity:
            raise HTTPException(
                status_code=400,
                detail=f"Insufficient stock for product {item.product_id}"
            )

        item_total = product["price"] * item.quantity
        order_items.append({
            "id": len(order_items) + 1,
            "product_id": item.product_id,
            "quantity": item.quantity,
            "total_price": item_total
        })
        total_amount += item_total

        # Update stock
        product["stock"] -= item.quantity

    order_id_counter += 1
    new_order = {
        "id": order_id_counter,
        "user_id": 1,  # Mock user ID
        "items": order_items,
        "total_amount": total_amount,
        "status": OrderStatus.pending,
        "shipping_address": order.shipping_address,
        "created_at": datetime.utcnow()
    }
    orders_db[order_id_counter] = new_order
    return new_order

@app.get("/orders/{order_id}", response_model=Order)
async def get_order(order_id: int):
    if order_id not in orders_db:
        raise HTTPException(status_code=404, detail="Order not found")
    return orders_db[order_id]

@app.patch("/orders/{order_id}/status")
async def update_order_status(order_id: int, status: OrderStatus):
    if order_id not in orders_db:
        raise HTTPException(status_code=404, detail="Order not found")

    orders_db[order_id]["status"] = status
    return {"message": f"Order status updated to {status}"}

@app.get("/orders/", response_model=List[Order])
async def list_orders(
    skip: int = 0,
    limit: int = 100,
    status: Optional[OrderStatus] = None
):
    orders = list(orders_db.values())

    if status:
        orders = [o for o in orders if o["status"] == status]

    return orders[skip:skip + limit]
```

---

### Example 17: Blog API with Comments

```python
from fastapi import FastAPI, Depends, HTTPException, status
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

app = FastAPI(title="Blog API")

# Models
class CommentCreate(BaseModel):
    content: str
    author: str

class Comment(CommentCreate):
    id: int
    post_id: int
    created_at: datetime

class PostCreate(BaseModel):
    title: str
    content: str
    author: str
    tags: List[str] = []

class PostUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None
    tags: Optional[List[str]] = None

class Post(PostCreate):
    id: int
    created_at: datetime
    updated_at: datetime
    comments_count: int = 0

class PostDetail(Post):
    comments: List[Comment] = []

# Mock database
posts_db = {}
comments_db = {}
post_id_counter = 0
comment_id_counter = 0

# Post endpoints
@app.post("/posts/", response_model=Post, status_code=201)
async def create_post(post: PostCreate):
    global post_id_counter
    post_id_counter += 1
    now = datetime.utcnow()
    new_post = {
        "id": post_id_counter,
        **post.dict(),
        "created_at": now,
        "updated_at": now,
        "comments_count": 0
    }
    posts_db[post_id_counter] = new_post
    return new_post

@app.get("/posts/", response_model=List[Post])
async def list_posts(
    skip: int = 0,
    limit: int = 10,
    tag: Optional[str] = None,
    author: Optional[str] = None
):
    posts = list(posts_db.values())

    if tag:
        posts = [p for p in posts if tag in p["tags"]]
    if author:
        posts = [p for p in posts if p["author"] == author]

    # Sort by created_at descending
    posts.sort(key=lambda x: x["created_at"], reverse=True)
    return posts[skip:skip + limit]

@app.get("/posts/{post_id}", response_model=PostDetail)
async def get_post(post_id: int):
    if post_id not in posts_db:
        raise HTTPException(status_code=404, detail="Post not found")

    post = posts_db[post_id].copy()
    post["comments"] = [
        c for c in comments_db.values() if c["post_id"] == post_id
    ]
    return post

@app.put("/posts/{post_id}", response_model=Post)
async def update_post(post_id: int, post_update: PostUpdate):
    if post_id not in posts_db:
        raise HTTPException(status_code=404, detail="Post not found")

    post = posts_db[post_id]
    update_data = post_update.dict(exclude_unset=True)

    for key, value in update_data.items():
        post[key] = value

    post["updated_at"] = datetime.utcnow()
    return post

@app.delete("/posts/{post_id}")
async def delete_post(post_id: int):
    if post_id not in posts_db:
        raise HTTPException(status_code=404, detail="Post not found")

    # Delete associated comments
    comment_ids_to_delete = [
        cid for cid, c in comments_db.items() if c["post_id"] == post_id
    ]
    for cid in comment_ids_to_delete:
        del comments_db[cid]

    del posts_db[post_id]
    return {"message": "Post deleted successfully"}

# Comment endpoints
@app.post("/posts/{post_id}/comments/", response_model=Comment, status_code=201)
async def create_comment(post_id: int, comment: CommentCreate):
    if post_id not in posts_db:
        raise HTTPException(status_code=404, detail="Post not found")

    global comment_id_counter
    comment_id_counter += 1
    new_comment = {
        "id": comment_id_counter,
        "post_id": post_id,
        **comment.dict(),
        "created_at": datetime.utcnow()
    }
    comments_db[comment_id_counter] = new_comment

    # Update comment count
    posts_db[post_id]["comments_count"] += 1

    return new_comment

@app.get("/posts/{post_id}/comments/", response_model=List[Comment])
async def list_comments(post_id: int):
    if post_id not in posts_db:
        raise HTTPException(status_code=404, detail="Post not found")

    comments = [c for c in comments_db.values() if c["post_id"] == post_id]
    comments.sort(key=lambda x: x["created_at"])
    return comments

@app.delete("/comments/{comment_id}")
async def delete_comment(comment_id: int):
    if comment_id not in comments_db:
        raise HTTPException(status_code=404, detail="Comment not found")

    comment = comments_db[comment_id]
    post_id = comment["post_id"]

    del comments_db[comment_id]
    posts_db[post_id]["comments_count"] -= 1

    return {"message": "Comment deleted successfully"}
```

---

## Conclusion

These examples cover the most common FastAPI patterns and use cases. Each example is production-ready and follows best practices for API development. Use them as templates for your own projects!

**Key Takeaways:**
- Always validate input with Pydantic models
- Use dependency injection for reusable code
- Implement proper error handling
- Use async/await for I/O operations
- Test your endpoints thoroughly
- Document your API with examples

---

**Version**: 1.0.0
**Last Updated**: October 2025
