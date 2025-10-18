# pytest Examples for Customer Support Systems

This document provides 15+ comprehensive, production-ready examples for testing customer support applications using pytest, FastAPI, SQLAlchemy, and PostgreSQL.

## Table of Contents

1. [Testing FastAPI Support Ticket Endpoints](#1-testing-fastapi-support-ticket-endpoints)
2. [Database Fixtures with SQLAlchemy](#2-database-fixtures-with-sqlalchemy)
3. [Mocking External Email Service](#3-mocking-external-email-service)
4. [Parametrized Data Validation Tests](#4-parametrized-data-validation-tests)
5. [Testing Async Operations](#5-testing-async-operations)
6. [Coverage Reporting Setup](#6-coverage-reporting-setup)
7. [Testing Authentication](#7-testing-authentication)
8. [Testing Database Transactions](#8-testing-database-transactions)
9. [Testing Error Handling](#9-testing-error-handling)
10. [Fixture Scopes Demonstration](#10-fixture-scopes-demonstration)
11. [Testing Background Tasks](#11-testing-background-tasks)
12. [Testing Webhooks](#12-testing-webhooks)
13. [Conftest.py Organization](#13-conftest-organization)
14. [Testing with pytest-asyncio](#14-testing-with-pytest-asyncio)
15. [CI Integration Example](#15-ci-integration-example)
16. [Testing SLA Calculations](#16-testing-sla-calculations)
17. [Testing Ticket Assignment Logic](#17-testing-ticket-assignment-logic)
18. [Testing Customer Data Validation](#18-testing-customer-data-validation)

---

## 1. Testing FastAPI Support Ticket Endpoints

Complete example of testing CRUD operations for support tickets.

```python
# tests/integration/test_api_tickets.py
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.models import Ticket, Customer
from sqlalchemy.orm import Session

@pytest.fixture
def client():
    """Provide FastAPI test client."""
    return TestClient(app)

@pytest.fixture
def client_with_db(db_session):
    """Provide client with database dependency override."""
    from app.dependencies import get_db

    def override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    client = TestClient(app)
    yield client
    app.dependency_overrides.clear()

def test_create_ticket_success(client_with_db):
    """Test successful ticket creation via POST."""
    response = client_with_db.post(
        "/api/v1/tickets",
        json={
            "title": "Cannot login to dashboard",
            "description": "User gets 'invalid credentials' error",
            "priority": "high",
            "customer_email": "user@example.com",
            "category": "authentication"
        }
    )

    assert response.status_code == 201
    data = response.json()
    assert data["title"] == "Cannot login to dashboard"
    assert data["priority"] == "high"
    assert data["status"] == "open"
    assert "id" in data
    assert "created_at" in data

def test_get_tickets_list(client_with_db, db_session):
    """Test retrieving paginated list of tickets."""
    # Create test tickets
    for i in range(5):
        ticket = Ticket(
            title=f"Test Ticket {i}",
            description=f"Description {i}",
            priority=["low", "medium", "high"][i % 3]
        )
        db_session.add(ticket)
    db_session.commit()

    response = client_with_db.get("/api/v1/tickets?page=1&limit=10")

    assert response.status_code == 200
    data = response.json()
    assert isinstance(data["items"], list)
    assert len(data["items"]) == 5
    assert "total" in data
    assert "page" in data

def test_get_ticket_by_id(client_with_db, db_session):
    """Test retrieving specific ticket by ID."""
    ticket = Ticket(
        title="Specific Ticket",
        description="Test description",
        priority="medium"
    )
    db_session.add(ticket)
    db_session.commit()

    response = client_with_db.get(f"/api/v1/tickets/{ticket.id}")

    assert response.status_code == 200
    data = response.json()
    assert data["id"] == ticket.id
    assert data["title"] == "Specific Ticket"

def test_update_ticket_status(client_with_db, db_session):
    """Test updating ticket status via PATCH."""
    ticket = Ticket(title="Update Test", priority="high", status="open")
    db_session.add(ticket)
    db_session.commit()

    response = client_with_db.patch(
        f"/api/v1/tickets/{ticket.id}",
        json={"status": "in_progress"}
    )

    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "in_progress"

    # Verify in database
    db_session.refresh(ticket)
    assert ticket.status == "in_progress"

def test_delete_ticket(client_with_db, db_session):
    """Test deleting a ticket via DELETE."""
    ticket = Ticket(title="Delete Test", priority="low")
    db_session.add(ticket)
    db_session.commit()
    ticket_id = ticket.id

    response = client_with_db.delete(f"/api/v1/tickets/{ticket_id}")

    assert response.status_code == 204

    # Verify deletion
    deleted_ticket = db_session.query(Ticket).filter_by(id=ticket_id).first()
    assert deleted_ticket is None

def test_get_ticket_not_found(client_with_db):
    """Test 404 response for non-existent ticket."""
    response = client_with_db.get("/api/v1/tickets/99999")
    assert response.status_code == 404
    assert "not found" in response.json()["detail"].lower()

def test_filter_tickets_by_priority(client_with_db, db_session):
    """Test filtering tickets by priority level."""
    for priority in ["low", "medium", "high", "critical"]:
        for i in range(2):
            ticket = Ticket(
                title=f"{priority} priority {i}",
                priority=priority
            )
            db_session.add(ticket)
    db_session.commit()

    response = client_with_db.get("/api/v1/tickets?priority=high")

    assert response.status_code == 200
    data = response.json()
    assert len(data["items"]) == 2
    assert all(t["priority"] == "high" for t in data["items"])
```

---

## 2. Database Fixtures with SQLAlchemy

Comprehensive database fixture examples with proper isolation and cleanup.

```python
# tests/conftest.py
import pytest
from sqlalchemy import create_engine, event
from sqlalchemy.orm import sessionmaker, Session
from app.database import Base
from app.models import Ticket, Customer, Agent, Comment
from typing import Generator

@pytest.fixture(scope="session")
def db_engine():
    """Create database engine for test session."""
    engine = create_engine(
        "postgresql://test:test@localhost:5432/support_test",
        echo=False,
        pool_pre_ping=True,
        pool_size=10
    )

    # Create all tables
    Base.metadata.create_all(engine)

    yield engine

    # Cleanup
    Base.metadata.drop_all(engine)
    engine.dispose()

@pytest.fixture
def db_session(db_engine) -> Generator[Session, None, None]:
    """Provide database session with automatic rollback for test isolation."""
    connection = db_engine.connect()
    transaction = connection.begin()
    session = sessionmaker(bind=connection)()

    # Enable savepoints for nested transactions
    @event.listens_for(session, "after_transaction_end")
    def restart_savepoint(session, transaction):
        if transaction.nested and not transaction._parent.nested:
            session.expire_all()
            session.begin_nested()

    session.begin_nested()

    yield session

    # Cleanup
    session.close()
    transaction.rollback()
    connection.close()

@pytest.fixture
def customer_factory(db_session):
    """Factory for creating test customers."""
    created = []

    def _create_customer(
        email=None,
        name=None,
        tier="basic",
        **kwargs
    ):
        import uuid
        customer = Customer(
            email=email or f"customer{uuid.uuid4().hex[:8]}@example.com",
            name=name or f"Customer {uuid.uuid4().hex[:8]}",
            tier=tier,
            **kwargs
        )
        db_session.add(customer)
        db_session.commit()
        created.append(customer)
        return customer

    yield _create_customer

@pytest.fixture
def ticket_factory(db_session):
    """Factory for creating test tickets."""
    created = []

    def _create_ticket(
        title=None,
        customer_id=None,
        priority="medium",
        status="open",
        **kwargs
    ):
        import uuid
        ticket = Ticket(
            title=title or f"Ticket {uuid.uuid4().hex[:8]}",
            description=kwargs.pop("description", "Test ticket description"),
            customer_id=customer_id,
            priority=priority,
            status=status,
            **kwargs
        )
        db_session.add(ticket)
        db_session.commit()
        created.append(ticket)
        return ticket

    yield _create_ticket

# Usage example
def test_customer_ticket_relationship(customer_factory, ticket_factory):
    """Test relationship between customers and their tickets."""
    customer = customer_factory(tier="premium", name="VIP Customer")

    # Create multiple tickets for customer
    ticket1 = ticket_factory(
        customer_id=customer.id,
        title="First Issue",
        priority="high"
    )
    ticket2 = ticket_factory(
        customer_id=customer.id,
        title="Second Issue",
        priority="medium"
    )

    assert len(customer.tickets) == 2
    assert customer.tickets[0].priority == "high"
    assert customer.tickets[1].priority == "medium"
```

---

## 3. Mocking External Email Service

Testing email notifications without actually sending emails.

```python
# tests/unit/services/test_email_service.py
import pytest
from app.services.email import EmailService, send_ticket_notification
from app.models import Ticket

def test_send_ticket_created_notification(mocker):
    """Test email sent when ticket is created."""
    mock_send = mocker.patch('app.services.email.EmailService.send_email')
    mock_send.return_value = {
        "status": "sent",
        "message_id": "msg_abc123",
        "provider": "sendgrid"
    }

    ticket = Ticket(
        id=1,
        title="Login Problem",
        customer_email="customer@example.com",
        priority="high"
    )

    result = send_ticket_notification(ticket, "created")

    # Verify email service called
    mock_send.assert_called_once()

    # Verify call arguments
    call_kwargs = mock_send.call_args.kwargs
    assert call_kwargs["to"] == "customer@example.com"
    assert call_kwargs["template"] == "ticket_created"
    assert call_kwargs["context"]["ticket_id"] == 1
    assert call_kwargs["context"]["title"] == "Login Problem"

    # Verify return value
    assert result["status"] == "sent"
    assert result["message_id"] == "msg_abc123"

def test_send_email_with_retry(mocker):
    """Test email retry logic on failure."""
    mock_send = mocker.patch('app.services.email.EmailService.send_email')

    # First two attempts fail, third succeeds
    mock_send.side_effect = [
        Exception("Connection timeout"),
        Exception("Service unavailable"),
        {"status": "sent", "message_id": "msg_retry123"}
    ]

    email_service = EmailService(max_retries=3)
    result = email_service.send_with_retry(
        to="user@example.com",
        subject="Test",
        body="Test message"
    )

    assert mock_send.call_count == 3
    assert result["status"] == "sent"

def test_email_fallback_provider(mocker):
    """Test fallback to secondary email provider on primary failure."""
    mock_sendgrid = mocker.patch('app.services.email.sendgrid_send')
    mock_ses = mocker.patch('app.services.email.ses_send')

    # Primary provider fails
    mock_sendgrid.side_effect = Exception("SendGrid API error")

    # Fallback succeeds
    mock_ses.return_value = {
        "status": "sent",
        "message_id": "ses_123",
        "provider": "aws_ses"
    }

    email_service = EmailService(use_fallback=True)
    result = email_service.send_email(
        to="customer@example.com",
        subject="Ticket Update",
        body="Your ticket has been updated"
    )

    # Verify primary called first
    mock_sendgrid.assert_called_once()

    # Verify fallback called
    mock_ses.assert_called_once()

    # Verify result from fallback
    assert result["provider"] == "aws_ses"
    assert result["status"] == "sent"

def test_batch_email_sending(mocker, ticket_factory):
    """Test sending batch notifications to multiple customers."""
    mock_send = mocker.patch('app.services.email.EmailService.send_email')
    mock_send.return_value = {"status": "sent"}

    tickets = [
        ticket_factory(customer_email=f"customer{i}@example.com")
        for i in range(5)
    ]

    from app.services.email import send_batch_notifications
    results = send_batch_notifications(tickets, "status_update")

    assert mock_send.call_count == 5
    assert len(results) == 5
    assert all(r["status"] == "sent" for r in results)
```

---

## 4. Parametrized Data Validation Tests

Testing data validation with multiple input scenarios.

```python
# tests/unit/test_validators.py
import pytest
from app.validators import (
    validate_email,
    validate_ticket_priority,
    validate_phone_number,
    validate_ticket_title
)
from pydantic import ValidationError

@pytest.mark.parametrize("email,expected_valid", [
    ("user@example.com", True),
    ("user.name@example.com", True),
    ("user+tag@example.co.uk", True),
    ("user@subdomain.example.com", True),
    ("invalid.email", False),
    ("@example.com", False),
    ("user@", False),
    ("user @example.com", False),
    ("user@example .com", False),
    ("", False),
    (None, False),
])
def test_email_validation(email, expected_valid):
    """Test email validation with various formats."""
    result = validate_email(email)
    assert result.is_valid == expected_valid

@pytest.mark.parametrize("priority,should_raise", [
    ("low", False),
    ("medium", False),
    ("high", False),
    ("critical", False),
    ("invalid", True),
    ("", True),
    (None, True),
    ("LOW", True),  # Case sensitive
    ("urgent", True),
])
def test_priority_validation(priority, should_raise):
    """Test ticket priority validation."""
    if should_raise:
        with pytest.raises(ValueError, match="Invalid priority"):
            validate_ticket_priority(priority)
    else:
        assert validate_ticket_priority(priority) == priority

@pytest.mark.parametrize("phone,country,expected_valid", [
    ("+1-555-123-4567", "US", True),
    ("555-123-4567", "US", True),
    ("+44 20 7123 4567", "UK", True),
    ("invalid", "US", False),
    ("123", "US", False),
    ("", "US", False),
])
def test_phone_number_validation(phone, country, expected_valid):
    """Test phone number validation for different countries."""
    result = validate_phone_number(phone, country_code=country)
    assert result.is_valid == expected_valid

@pytest.mark.parametrize("title,expected_error", [
    pytest.param("Valid ticket title", None, id="valid"),
    pytest.param("", "empty", id="empty"),
    pytest.param("a" * 300, "too_long", id="too-long"),
    pytest.param("ab", "too_short", id="too-short"),
    pytest.param("<script>alert('xss')</script>", "invalid_chars", id="xss-attempt"),
    pytest.param("Title with\nnewline", "invalid_chars", id="newline"),
])
def test_ticket_title_validation(title, expected_error):
    """Test ticket title validation with edge cases."""
    result = validate_ticket_title(title)

    if expected_error is None:
        assert result.is_valid is True
        assert result.sanitized_value == title
    else:
        assert result.is_valid is False
        assert expected_error in result.error_code

@pytest.mark.parametrize("data,expected_errors", [
    (
        {"title": "Valid", "priority": "high", "customer_email": "user@example.com"},
        []
    ),
    (
        {"priority": "high", "customer_email": "user@example.com"},
        ["title"]  # Missing title
    ),
    (
        {"title": "Valid", "priority": "invalid", "customer_email": "user@example.com"},
        ["priority"]  # Invalid priority
    ),
    (
        {"title": "Valid", "priority": "high", "customer_email": "invalid"},
        ["customer_email"]  # Invalid email
    ),
    (
        {"title": "", "priority": "invalid", "customer_email": "invalid"},
        ["title", "priority", "customer_email"]  # Multiple errors
    ),
])
def test_ticket_creation_validation(data, expected_errors):
    """Test complete ticket creation validation."""
    from app.schemas import TicketCreate

    if expected_errors:
        with pytest.raises(ValidationError) as exc_info:
            TicketCreate(**data)

        errors = exc_info.value.errors()
        error_fields = [e["loc"][0] for e in errors]

        for expected_field in expected_errors:
            assert expected_field in error_fields
    else:
        ticket = TicketCreate(**data)
        assert ticket.title == data["title"]
        assert ticket.priority == data["priority"]
```

---

## 5. Testing Async Operations

Testing asynchronous functions and background tasks.

```python
# tests/unit/services/test_async_operations.py
import pytest
import asyncio
from app.services.async_ticket import (
    create_ticket_async,
    process_tickets_batch_async,
    send_notification_async
)

@pytest.mark.asyncio
async def test_async_ticket_creation():
    """Test asynchronous ticket creation."""
    ticket = await create_ticket_async(
        title="Async Ticket Test",
        description="Testing async operations",
        priority="high",
        customer_email="async@example.com"
    )

    assert ticket.id is not None
    assert ticket.title == "Async Ticket Test"
    assert ticket.status == "open"

@pytest.mark.asyncio
async def test_concurrent_ticket_creation():
    """Test creating multiple tickets concurrently."""
    tasks = [
        create_ticket_async(
            title=f"Concurrent Ticket {i}",
            priority=["low", "medium", "high"][i % 3]
        )
        for i in range(10)
    ]

    tickets = await asyncio.gather(*tasks)

    assert len(tickets) == 10
    assert all(t.id is not None for t in tickets)
    assert all(t.status == "open" for t in tickets)

@pytest.mark.asyncio
async def test_async_notification_with_mock(mocker):
    """Test async notification service with mocking."""
    from unittest.mock import AsyncMock

    mock_send = mocker.patch(
        'app.services.notification.send_push_async',
        new_callable=AsyncMock
    )
    mock_send.return_value = {"delivered": True, "notification_id": "notif_123"}

    result = await send_notification_async(
        user_id=456,
        message="New ticket assigned",
        priority="high"
    )

    assert result["delivered"] is True
    mock_send.assert_awaited_once()

    call_kwargs = mock_send.call_args.kwargs
    assert call_kwargs["user_id"] == 456
    assert "ticket assigned" in call_kwargs["message"].lower()

@pytest.mark.asyncio
async def test_batch_processing_async(ticket_factory):
    """Test async batch processing of tickets."""
    tickets = [ticket_factory(status="open") for _ in range(20)]
    ticket_ids = [t.id for t in tickets]

    results = await process_tickets_batch_async(
        ticket_ids=ticket_ids,
        action="assign_to_agent",
        agent_id=1
    )

    assert len(results) == 20
    assert all(r["status"] == "success" for r in results)
```

---

## 6. Coverage Reporting Setup

Complete coverage configuration and usage examples.

```ini
# .coveragerc
[run]
source = app
branch = True
omit =
    */tests/*
    */migrations/*
    */__init__.py
    */config.py
    */venv/*

[report]
precision = 2
show_missing = True
skip_covered = False
exclude_lines =
    pragma: no cover
    def __repr__
    def __str__
    raise AssertionError
    raise NotImplementedError
    if __name__ == .__main__.:
    if TYPE_CHECKING:
    @abstractmethod

[html]
directory = htmlcov
title = Support System Coverage

[xml]
output = coverage.xml
```

```bash
# Run tests with coverage
pytest --cov=app --cov-report=html --cov-report=term-missing

# Fail if coverage below 80%
pytest --cov=app --cov-fail-under=80

# Generate XML for CI/CD
pytest --cov=app --cov-report=xml

# Coverage for specific module
pytest tests/unit/services/ --cov=app.services --cov-report=term
```

```python
# pytest.ini
[pytest]
addopts =
    --cov=app
    --cov-report=html
    --cov-report=term-missing
    --cov-fail-under=75
    -v
```

---

## 7. Testing Authentication

Testing authentication and authorization flows.

```python
# tests/integration/test_auth.py
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.auth import create_access_token, verify_token
from datetime import datetime, timedelta

@pytest.fixture
def client():
    return TestClient(app)

def test_login_success(client, db_session):
    """Test successful login returns JWT token."""
    from app.models import User
    from app.auth import hash_password

    # Create test user
    user = User(
        email="agent@support.com",
        password_hash=hash_password("securepass123"),
        role="agent"
    )
    db_session.add(user)
    db_session.commit()

    response = client.post(
        "/api/v1/auth/login",
        json={"email": "agent@support.com", "password": "securepass123"}
    )

    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"

def test_login_invalid_credentials(client):
    """Test login fails with invalid credentials."""
    response = client.post(
        "/api/v1/auth/login",
        json={"email": "invalid@example.com", "password": "wrongpass"}
    )

    assert response.status_code == 401
    assert "incorrect" in response.json()["detail"].lower()

def test_protected_endpoint_without_token(client):
    """Test protected endpoint requires authentication."""
    response = client.get("/api/v1/tickets/my-tickets")
    assert response.status_code == 401

def test_protected_endpoint_with_valid_token(client, db_session):
    """Test access with valid JWT token."""
    from app.models import User
    user = User(email="agent@support.com", role="agent")
    db_session.add(user)
    db_session.commit()

    token = create_access_token({"sub": user.email, "role": user.role})

    response = client.get(
        "/api/v1/tickets/my-tickets",
        headers={"Authorization": f"Bearer {token}"}
    )

    assert response.status_code == 200

def test_expired_token(client):
    """Test that expired tokens are rejected."""
    # Create expired token
    token = create_access_token(
        {"sub": "user@example.com"},
        expires_delta=timedelta(seconds=-1)  # Already expired
    )

    response = client.get(
        "/api/v1/tickets/my-tickets",
        headers={"Authorization": f"Bearer {token}"}
    )

    assert response.status_code == 401
    assert "expired" in response.json()["detail"].lower()

def test_role_based_access_control(client, db_session):
    """Test RBAC - agents cannot access admin endpoints."""
    from app.models import User
    agent = User(email="agent@support.com", role="agent")
    db_session.add(agent)
    db_session.commit()

    token = create_access_token({"sub": agent.email, "role": "agent"})

    # Agent trying to access admin endpoint
    response = client.delete(
        "/api/v1/admin/users/123",
        headers={"Authorization": f"Bearer {token}"}
    )

    assert response.status_code == 403
    assert "permission" in response.json()["detail"].lower()

def test_admin_access_allowed(client, db_session):
    """Test admin can access admin endpoints."""
    from app.models import User
    admin = User(email="admin@support.com", role="admin")
    db_session.add(admin)
    db_session.commit()

    token = create_access_token({"sub": admin.email, "role": "admin"})

    response = client.get(
        "/api/v1/admin/users",
        headers={"Authorization": f"Bearer {token}"}
    )

    assert response.status_code == 200
```

---

## 8. Testing Database Transactions

Testing transaction handling and rollback scenarios.

```python
# tests/integration/test_transactions.py
import pytest
from sqlalchemy.exc import IntegrityError
from app.models import Ticket, Customer

def test_transaction_commit(db_session):
    """Test successful transaction commit."""
    ticket = Ticket(title="Transaction Test", priority="medium")
    db_session.add(ticket)
    db_session.commit()

    assert ticket.id is not None

    # Verify persistence
    found = db_session.query(Ticket).filter_by(id=ticket.id).first()
    assert found is not None
    assert found.title == "Transaction Test"

def test_transaction_rollback_on_error(db_session):
    """Test transaction rollback on constraint violation."""
    # Create first customer
    customer1 = Customer(email="unique@example.com", name="First")
    db_session.add(customer1)
    db_session.commit()

    initial_count = db_session.query(Customer).count()

    # Try to create duplicate (should fail on unique email constraint)
    try:
        customer2 = Customer(email="unique@example.com", name="Duplicate")
        db_session.add(customer2)
        db_session.commit()
    except IntegrityError:
        db_session.rollback()

    final_count = db_session.query(Customer).count()
    assert final_count == initial_count  # No new record added

def test_nested_transaction_savepoint(db_session):
    """Test nested transactions with savepoints."""
    ticket1 = Ticket(title="First", priority="high")
    db_session.add(ticket1)
    db_session.flush()

    # Create savepoint
    savepoint = db_session.begin_nested()

    try:
        # This will fail
        ticket2 = Ticket(title="Second", priority="invalid_priority")
        db_session.add(ticket2)
        db_session.flush()
    except:
        savepoint.rollback()

    # First ticket should still exist
    db_session.commit()
    assert db_session.query(Ticket).count() == 1

def test_bulk_insert_transaction(db_session):
    """Test bulk insert in single transaction."""
    tickets = [
        Ticket(title=f"Bulk Ticket {i}", priority="medium")
        for i in range(100)
    ]

    db_session.bulk_save_objects(tickets)
    db_session.commit()

    count = db_session.query(Ticket).count()
    assert count == 100

def test_transaction_isolation(db_engine):
    """Test transaction isolation between sessions."""
    from sqlalchemy.orm import sessionmaker

    Session = sessionmaker(bind=db_engine)
    session1 = Session()
    session2 = Session()

    # Session 1 creates ticket but doesn't commit
    ticket = Ticket(title="Isolation Test", priority="low")
    session1.add(ticket)
    session1.flush()

    # Session 2 shouldn't see uncommitted ticket
    found = session2.query(Ticket).filter_by(title="Isolation Test").first()
    assert found is None

    # After commit, session 2 can see it
    session1.commit()
    found = session2.query(Ticket).filter_by(title="Isolation Test").first()
    assert found is not None

    session1.close()
    session2.close()
```

---

## 9. Testing Error Handling

Testing error responses and exception handling.

```python
# tests/integration/test_error_handling.py
import pytest
from fastapi import status
from app.exceptions import TicketNotFoundError, InvalidPriorityError

def test_404_not_found(client):
    """Test 404 response for non-existent resource."""
    response = client.get("/api/v1/tickets/99999")

    assert response.status_code == status.HTTP_404_NOT_FOUND
    data = response.json()
    assert "detail" in data
    assert "not found" in data["detail"].lower()

def test_422_validation_error(client):
    """Test 422 response for invalid data."""
    response = client.post(
        "/api/v1/tickets",
        json={
            "description": "Missing required title field",
            "priority": "high"
        }
    )

    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY
    data = response.json()
    assert "detail" in data

    errors = data["detail"]
    assert any("title" in str(error).lower() for error in errors)

def test_400_bad_request(client):
    """Test 400 response for malformed request."""
    response = client.post(
        "/api/v1/tickets",
        data="invalid json",
        headers={"Content-Type": "application/json"}
    )

    assert response.status_code == status.HTTP_400_BAD_REQUEST

def test_custom_exception_handling(mocker, client):
    """Test custom exception handling."""
    mocker.patch(
        'app.services.ticket.get_ticket',
        side_effect=TicketNotFoundError("Ticket 123 not found")
    )

    response = client.get("/api/v1/tickets/123")

    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert "Ticket 123" in response.json()["detail"]

def test_logging_on_error(caplog, db_session):
    """Test that errors are properly logged."""
    import logging
    from app.services.ticket import delete_ticket

    with caplog.at_level(logging.ERROR):
        with pytest.raises(TicketNotFoundError):
            delete_ticket(99999, db_session)

    assert len(caplog.records) > 0
    assert "Ticket" in caplog.text
    assert "99999" in caplog.text

@pytest.mark.parametrize("invalid_input,expected_error", [
    ({"title": "", "priority": "high"}, "title"),
    ({"title": "Valid", "priority": "invalid"}, "priority"),
    ({"title": "Valid", "customer_email": "not-email"}, "email"),
])
def test_validation_errors(client, invalid_input, expected_error):
    """Test various validation errors."""
    response = client.post("/api/v1/tickets", json=invalid_input)

    assert response.status_code == 422
    errors = response.json()["detail"]
    assert any(expected_error in str(e).lower() for e in errors)
```

---

## 10. Fixture Scopes Demonstration

Examples of different fixture scopes and their use cases.

```python
# tests/conftest.py
import pytest

@pytest.fixture(scope="session")
def session_data():
    """Session scope: Created once for entire test session."""
    print("\n[SESSION] Creating session data")
    data = {"sessions": 0}
    yield data
    print("\n[SESSION] Cleaning up session data")

@pytest.fixture(scope="module")
def module_data():
    """Module scope: Created once per test module."""
    print("\n[MODULE] Creating module data")
    data = {"modules": 0}
    yield data
    print("\n[MODULE] Cleaning up module data")

@pytest.fixture(scope="class")
def class_data():
    """Class scope: Created once per test class."""
    print("\n[CLASS] Creating class data")
    data = {"classes": 0}
    yield data
    print("\n[CLASS] Cleaning up class data")

@pytest.fixture(scope="function")
def function_data():
    """Function scope: Created for each test function."""
    print("\n[FUNCTION] Creating function data")
    data = {"functions": 0}
    yield data
    print("\n[FUNCTION] Cleaning up function data")

# tests/test_scopes.py
def test_function_scope_1(function_data, session_data):
    """First test using function and session fixtures."""
    function_data["functions"] += 1
    session_data["sessions"] += 1
    assert function_data["functions"] == 1
    assert session_data["sessions"] == 1

def test_function_scope_2(function_data, session_data):
    """Second test - function fixture reset, session persists."""
    function_data["functions"] += 1
    session_data["sessions"] += 1
    assert function_data["functions"] == 1  # Reset for this test
    assert session_data["sessions"] == 2  # Persists across tests

class TestClassScope:
    """Tests demonstrating class scope."""

    def test_class_1(self, class_data):
        class_data["classes"] += 1
        assert class_data["classes"] == 1

    def test_class_2(self, class_data):
        class_data["classes"] += 1
        assert class_data["classes"] == 2  # Persists within class

# Practical example: Database connection pool
@pytest.fixture(scope="session")
def db_connection_pool():
    """Session-scoped database connection pool."""
    from sqlalchemy import pool
    connection_pool = pool.QueuePool(
        create_connection,
        max_overflow=10,
        pool_size=5
    )
    yield connection_pool
    connection_pool.dispose()

@pytest.fixture(scope="function")
def db_connection(db_connection_pool):
    """Function-scoped connection from pool."""
    conn = db_connection_pool.connect()
    yield conn
    conn.close()
```

---

## 11. Testing Background Tasks

Testing async background tasks and job processing.

```python
# tests/unit/tasks/test_background_tasks.py
import pytest
from app.tasks.background import (
    send_bulk_emails_task,
    cleanup_old_tickets_task,
    export_tickets_task
)

@pytest.mark.asyncio
async def test_send_bulk_emails_task(mocker):
    """Test bulk email sending background task."""
    from unittest.mock import AsyncMock

    mock_send = mocker.patch(
        'app.services.email.send_email_async',
        new_callable=AsyncMock
    )
    mock_send.return_value = {"status": "sent"}

    emails = [
        {"to": f"customer{i}@example.com", "subject": "Update"}
        for i in range(5)
    ]

    result = await send_bulk_emails_task(emails)

    assert mock_send.call_count == 5
    assert result["total"] == 5
    assert result["sent"] == 5
    assert result["failed"] == 0

def test_cleanup_old_tickets_task(db_session, ticket_factory):
    """Test background task that cleans up old closed tickets."""
    from datetime import datetime, timedelta

    # Create old closed tickets
    old_date = datetime.utcnow() - timedelta(days=365)
    for i in range(3):
        ticket = ticket_factory(
            status="closed",
            created_at=old_date
        )

    # Create recent tickets
    for i in range(2):
        ticket = ticket_factory(status="closed")

    initial_count = db_session.query(Ticket).count()
    assert initial_count == 5

    # Run cleanup task
    deleted_count = cleanup_old_tickets_task(
        db_session,
        days_old=180,
        status="closed"
    )

    assert deleted_count == 3
    final_count = db_session.query(Ticket).count()
    assert final_count == 2

@pytest.mark.asyncio
async def test_export_tickets_task(db_session, ticket_factory, mocker):
    """Test ticket export background task."""
    # Create test tickets
    for i in range(10):
        ticket_factory(priority=["low", "high"][i % 2])

    mock_upload = mocker.patch('app.storage.upload_file')
    mock_upload.return_value = "https://storage.example.com/export_123.csv"

    result = await export_tickets_task(
        filters={"priority": "high"},
        format="csv"
    )

    assert result["status"] == "completed"
    assert result["row_count"] == 5
    assert "file_url" in result
    mock_upload.assert_called_once()

def test_task_failure_handling(mocker, db_session):
    """Test background task failure handling and retry."""
    from app.tasks.background import process_with_retry

    mock_process = mocker.patch('app.tasks.process_function')
    mock_process.side_effect = [
        Exception("Temporary error"),
        Exception("Temporary error"),
        {"status": "success"}
    ]

    result = process_with_retry(task_id=123, max_retries=3)

    assert result["status"] == "success"
    assert mock_process.call_count == 3
```

---

## 12. Testing Webhooks

Testing webhook delivery and handling.

```python
# tests/integration/test_webhooks.py
import pytest
from app.models import WebhookSubscription, Ticket

def test_webhook_delivery_on_event(mocker, db_session):
    """Test webhook delivered when event occurs."""
    # Create webhook subscription
    webhook = WebhookSubscription(
        url="https://customer.example.com/webhooks",
        events=["ticket.created", "ticket.updated"],
        secret="webhook_secret_123",
        active=True
    )
    db_session.add(webhook)
    db_session.commit()

    mock_post = mocker.patch('requests.post')
    mock_post.return_value.status_code = 200

    # Trigger event
    from app.services.webhooks import trigger_webhook
    ticket = Ticket(id=1, title="Test", priority="high")

    trigger_webhook("ticket.created", ticket.to_dict())

    # Verify webhook called
    assert mock_post.call_count == 1
    call_kwargs = mock_post.call_args.kwargs

    assert call_kwargs["url"] == "https://customer.example.com/webhooks"
    assert "ticket.created" in call_kwargs["json"]["event"]
    assert call_kwargs["json"]["data"]["id"] == 1
    assert "X-Webhook-Signature" in call_kwargs["headers"]

def test_webhook_retry_on_failure(mocker, db_session):
    """Test webhook retry mechanism on delivery failure."""
    webhook = WebhookSubscription(
        url="https://customer.example.com/webhooks",
        events=["ticket.created"],
        active=True,
        max_retries=3
    )
    db_session.add(webhook)
    db_session.commit()

    mock_post = mocker.patch('requests.post')
    # First two attempts fail, third succeeds
    mock_post.side_effect = [
        mocker.Mock(status_code=500),
        mocker.Mock(status_code=503),
        mocker.Mock(status_code=200)
    ]

    from app.services.webhooks import deliver_webhook_with_retry
    result = deliver_webhook_with_retry(
        webhook_id=webhook.id,
        event="ticket.created",
        data={"id": 1}
    )

    assert mock_post.call_count == 3
    assert result["status"] == "delivered"

def test_webhook_signature_validation(mocker):
    """Test webhook signature for security."""
    import hmac
    import hashlib

    secret = "webhook_secret_123"
    payload = '{"event": "ticket.created", "data": {"id": 1}}'

    # Generate signature
    signature = hmac.new(
        secret.encode(),
        payload.encode(),
        hashlib.sha256
    ).hexdigest()

    from app.services.webhooks import validate_webhook_signature
    is_valid = validate_webhook_signature(payload, signature, secret)

    assert is_valid is True

    # Test invalid signature
    is_valid = validate_webhook_signature(payload, "invalid_sig", secret)
    assert is_valid is False

def test_webhook_filtering_by_event(mocker, db_session):
    """Test webhooks only triggered for subscribed events."""
    webhook = WebhookSubscription(
        url="https://customer.example.com/webhooks",
        events=["ticket.created"],  # Only subscribed to created
        active=True
    )
    db_session.add(webhook)
    db_session.commit()

    mock_post = mocker.patch('requests.post')

    from app.services.webhooks import trigger_webhooks

    # Should trigger
    trigger_webhooks("ticket.created", {"id": 1}, db_session)
    assert mock_post.call_count == 1

    # Should not trigger (not subscribed)
    trigger_webhooks("ticket.updated", {"id": 1}, db_session)
    assert mock_post.call_count == 1  # Still 1, not called again
```

---

## 13. Conftest Organization

Best practices for organizing conftest.py files.

```python
# tests/conftest.py (root conftest)
"""
Root conftest.py - Shared fixtures for all tests.
Fixtures defined here are available to all test modules.
"""
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Database fixtures
@pytest.fixture(scope="session")
def db_engine():
    """Session-scoped database engine."""
    engine = create_engine("postgresql://test:test@localhost/test_db")
    yield engine
    engine.dispose()

@pytest.fixture
def db_session(db_engine):
    """Function-scoped database session with rollback."""
    connection = db_engine.connect()
    transaction = connection.begin()
    session = sessionmaker(bind=connection)()
    yield session
    session.close()
    transaction.rollback()
    connection.close()

# API client fixtures
@pytest.fixture
def client():
    """FastAPI test client."""
    from fastapi.testclient import TestClient
    from app.main import app
    return TestClient(app)

# tests/unit/conftest.py (unit test specific)
"""
Unit test conftest - Fixtures specific to unit tests.
"""
import pytest

@pytest.fixture
def mock_db_session(mocker):
    """Mock database session for unit tests."""
    session = mocker.Mock()
    session.add = mocker.Mock()
    session.commit = mocker.Mock()
    session.query = mocker.Mock()
    return session

# tests/integration/conftest.py (integration test specific)
"""
Integration test conftest - Fixtures for integration tests.
"""
import pytest

@pytest.fixture
def client_with_db(client, db_session):
    """Client with real database for integration tests."""
    from app.main import app
    from app.dependencies import get_db

    def override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    yield client
    app.dependency_overrides.clear()

@pytest.fixture
def sample_data(db_session):
    """Create sample data for integration tests."""
    from app.models import Ticket, Customer

    customer = Customer(email="test@example.com", name="Test")
    db_session.add(customer)
    db_session.flush()

    tickets = [
        Ticket(title=f"Ticket {i}", customer_id=customer.id)
        for i in range(5)
    ]
    db_session.add_all(tickets)
    db_session.commit()

    return {"customer": customer, "tickets": tickets}

# tests/e2e/conftest.py (e2e test specific)
"""
E2E test conftest - Fixtures for end-to-end tests.
"""
import pytest

@pytest.fixture(scope="module")
def e2e_client():
    """Module-scoped client for e2e tests."""
    from fastapi.testclient import TestClient
    from app.main import app
    return TestClient(app)

@pytest.fixture
def authenticated_user(e2e_client):
    """Create and authenticate user for e2e tests."""
    # Register user
    register_response = e2e_client.post(
        "/api/auth/register",
        json={"email": "e2e@test.com", "password": "testpass123"}
    )

    # Login
    login_response = e2e_client.post(
        "/api/auth/login",
        json={"email": "e2e@test.com", "password": "testpass123"}
    )

    token = login_response.json()["access_token"]
    return {"email": "e2e@test.com", "token": token}
```

---

## 14. Testing with pytest-asyncio

Advanced async testing patterns.

```python
# tests/unit/test_async_advanced.py
import pytest
import asyncio
from app.services.async_service import AsyncTicketService

@pytest.fixture
async def async_service():
    """Async fixture for service instance."""
    service = AsyncTicketService()
    await service.initialize()
    yield service
    await service.cleanup()

@pytest.mark.asyncio
async def test_async_service_initialization(async_service):
    """Test async service initialization."""
    assert async_service.is_initialized is True

@pytest.mark.asyncio
async def test_concurrent_operations(async_service):
    """Test handling multiple concurrent async operations."""
    async def create_ticket(title):
        return await async_service.create(title=title, priority="medium")

    # Create 10 tickets concurrently
    tasks = [create_ticket(f"Ticket {i}") for i in range(10)]
    tickets = await asyncio.gather(*tasks)

    assert len(tickets) == 10
    assert all(t.id is not None for t in tickets)

@pytest.mark.asyncio
async def test_async_error_handling(async_service):
    """Test async error handling."""
    with pytest.raises(ValueError, match="Invalid priority"):
        await async_service.create(
            title="Test",
            priority="invalid_priority"
        )

@pytest.mark.asyncio
async def test_async_timeout():
    """Test async operation with timeout."""
    async def slow_operation():
        await asyncio.sleep(10)
        return "completed"

    with pytest.raises(asyncio.TimeoutError):
        await asyncio.wait_for(slow_operation(), timeout=1.0)

@pytest.mark.asyncio
async def test_async_context_manager():
    """Test async context manager."""
    from app.services.async_context import AsyncDatabaseSession

    async with AsyncDatabaseSession() as session:
        ticket = await session.create_ticket(title="Test")
        assert ticket.id is not None

@pytest.mark.asyncio
@pytest.mark.parametrize("count", [1, 5, 10, 50])
async def test_async_batch_processing(count):
    """Test async batch processing with different sizes."""
    from app.services.batch import process_batch_async

    items = [{"id": i} for i in range(count)]
    results = await process_batch_async(items)

    assert len(results) == count
    assert all(r["status"] == "processed" for r in results)
```

---

## 15. CI Integration Example

Complete CI/CD pipeline configuration with pytest.

```yaml
# .github/workflows/test.yml
name: Test Suite

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: test_user
          POSTGRES_PASSWORD: test_password
          POSTGRES_DB: support_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
          cache: 'pip'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install -r requirements-dev.txt

      - name: Lint with flake8
        run: |
          flake8 app tests --count --show-source --statistics

      - name: Type check with mypy
        run: |
          mypy app

      - name: Run database migrations
        env:
          DATABASE_URL: postgresql://test_user:test_password@localhost:5432/support_test
        run: |
          alembic upgrade head

      - name: Run tests with coverage
        env:
          DATABASE_URL: postgresql://test_user:test_password@localhost:5432/support_test
          REDIS_URL: redis://localhost:6379
        run: |
          pytest -v \
            --cov=app \
            --cov-report=xml \
            --cov-report=term-missing \
            --cov-fail-under=80 \
            -n auto

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
          fail_ci_if_error: true

      - name: Archive test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: |
            htmlcov/
            .coverage

      - name: Run security checks
        run: |
          pip install bandit safety
          bandit -r app/
          safety check
```

```bash
# Makefile for local testing
.PHONY: test test-unit test-integration test-e2e test-coverage

test:
	pytest -v

test-unit:
	pytest tests/unit -v

test-integration:
	pytest tests/integration -v -m integration

test-e2e:
	pytest tests/e2e -v -m e2e --slow

test-coverage:
	pytest --cov=app --cov-report=html --cov-report=term-missing

test-fast:
	pytest -m "not slow" -v

test-parallel:
	pytest -n auto -v

lint:
	flake8 app tests
	black app tests --check
	isort app tests --check

format:
	black app tests
	isort app tests

typecheck:
	mypy app
```

---

## 16. Testing SLA Calculations

Testing Service Level Agreement logic.

```python
# tests/unit/services/test_sla.py
import pytest
from datetime import datetime, timedelta
from app.services.sla import (
    calculate_sla_hours,
    is_sla_breached,
    calculate_time_remaining,
    get_business_hours
)

@pytest.mark.parametrize("priority,expected_hours", [
    ("critical", 1),
    ("high", 4),
    ("medium", 24),
    ("low", 72),
])
def test_sla_hours_by_priority(priority, expected_hours):
    """Test SLA hours calculation for each priority level."""
    sla_hours = calculate_sla_hours(priority)
    assert sla_hours == expected_hours

def test_sla_breach_detection():
    """Test detection of SLA breaches."""
    created_at = datetime.utcnow() - timedelta(hours=2)
    ticket = Ticket(
        priority="critical",  # 1 hour SLA
        created_at=created_at,
        status="open"
    )

    is_breached = is_sla_breached(ticket)
    assert is_breached is True

def test_sla_not_breached():
    """Test ticket within SLA."""
    created_at = datetime.utcnow() - timedelta(minutes=30)
    ticket = Ticket(
        priority="critical",  # 1 hour SLA
        created_at=created_at,
        status="open"
    )

    is_breached = is_sla_breached(ticket)
    assert is_breached is False

def test_sla_time_remaining():
    """Test calculation of remaining SLA time."""
    created_at = datetime.utcnow() - timedelta(hours=1)
    ticket = Ticket(
        priority="high",  # 4 hour SLA
        created_at=created_at
    )

    remaining = calculate_time_remaining(ticket)
    assert 2.9 <= remaining.total_seconds() / 3600 <= 3.1  # ~3 hours

def test_business_hours_calculation():
    """Test business hours vs calendar hours."""
    # Monday 9 AM to Tuesday 9 AM
    start = datetime(2025, 1, 6, 9, 0)  # Monday
    end = datetime(2025, 1, 7, 9, 0)    # Tuesday

    business_hours = get_business_hours(start, end)
    # Should be 8 hours (Monday 9-5), not 24 hours
    assert business_hours == 8
```

---

## 17. Testing Ticket Assignment Logic

Testing automatic ticket assignment algorithms.

```python
# tests/unit/services/test_assignment.py
import pytest
from app.services.assignment import (
    assign_round_robin,
    assign_by_workload,
    assign_by_expertise
)
from app.models import Agent, Ticket

@pytest.fixture
def agents(db_session):
    """Create test agents."""
    agents = [
        Agent(name="Agent 1", email="agent1@support.com", expertise=["billing"]),
        Agent(name="Agent 2", email="agent2@support.com", expertise=["technical"]),
        Agent(name="Agent 3", email="agent3@support.com", expertise=["billing", "technical"]),
    ]
    db_session.add_all(agents)
    db_session.commit()
    return agents

def test_round_robin_assignment(db_session, agents):
    """Test round-robin assignment distributes evenly."""
    tickets = []
    for i in range(9):
        ticket = Ticket(title=f"Ticket {i}", priority="medium")
        db_session.add(ticket)
        db_session.flush()

        assigned_agent = assign_round_robin(ticket, db_session)
        ticket.assigned_agent_id = assigned_agent.id
        tickets.append(ticket)

    db_session.commit()

    # Verify even distribution (3 tickets per agent)
    for agent in agents:
        assigned_count = len([t for t in tickets if t.assigned_agent_id == agent.id])
        assert assigned_count == 3

def test_workload_based_assignment(db_session, agents):
    """Test assignment based on current workload."""
    # Give agents different workloads
    for i in range(5):
        ticket = Ticket(title=f"Existing {i}", assigned_agent_id=agents[0].id)
        db_session.add(ticket)

    for i in range(2):
        ticket = Ticket(title=f"Existing {i}", assigned_agent_id=agents[1].id)
        db_session.add(ticket)

    db_session.commit()

    # New ticket should go to agent with least workload (agents[2] with 0)
    new_ticket = Ticket(title="New Ticket", priority="high")
    assigned_agent = assign_by_workload(new_ticket, db_session)

    assert assigned_agent.id == agents[2].id

def test_expertise_based_assignment(db_session, agents):
    """Test assignment based on agent expertise."""
    billing_ticket = Ticket(
        title="Billing Issue",
        category="billing",
        priority="high"
    )

    assigned_agent = assign_by_expertise(billing_ticket, db_session)

    # Should be assigned to agent with billing expertise
    assert "billing" in assigned_agent.expertise
```

---

## 18. Testing Customer Data Validation

Testing comprehensive customer data validation.

```python
# tests/unit/test_customer_validation.py
import pytest
from app.validators import validate_customer_data
from app.schemas import CustomerCreate
from pydantic import ValidationError

def test_valid_customer_data():
    """Test validation of valid customer data."""
    customer = CustomerCreate(
        email="customer@example.com",
        name="John Doe",
        company="Acme Corp",
        phone="+1-555-123-4567",
        tier="premium"
    )

    assert customer.email == "customer@example.com"
    assert customer.tier == "premium"

@pytest.mark.parametrize("email", [
    "invalid",
    "@example.com",
    "user@",
    "",
])
def test_invalid_email(email):
    """Test customer creation fails with invalid email."""
    with pytest.raises(ValidationError) as exc_info:
        CustomerCreate(
            email=email,
            name="Test User"
        )

    errors = exc_info.value.errors()
    assert any("email" in str(e["loc"]) for e in errors)

def test_tier_validation():
    """Test customer tier validation."""
    with pytest.raises(ValidationError):
        CustomerCreate(
            email="test@example.com",
            name="Test",
            tier="invalid_tier"
        )

def test_phone_number_normalization():
    """Test phone number is normalized."""
    customer = CustomerCreate(
        email="test@example.com",
        name="Test",
        phone="555-123-4567"
    )

    # Should be normalized to E.164 format
    assert customer.phone.startswith("+")

def test_company_name_sanitization():
    """Test company name XSS protection."""
    customer = CustomerCreate(
        email="test@example.com",
        name="Test",
        company="<script>alert('xss')</script>"
    )

    # Should be sanitized
    assert "<script>" not in customer.company
```

---

## Summary

These 18 comprehensive examples cover:

1. FastAPI endpoint testing
2. Database fixtures and factories
3. External service mocking
4. Parametrized validation tests
5. Async operation testing
6. Coverage configuration
7. Authentication flows
8. Transaction handling
9. Error handling
10. Fixture scopes
11. Background tasks
12. Webhook testing
13. Conftest organization
14. Advanced async patterns
15. CI/CD integration
16. SLA calculations
17. Assignment algorithms
18. Data validation

Each example is production-ready and demonstrates real-world testing scenarios for customer support systems using pytest, FastAPI, SQLAlchemy, and PostgreSQL.
