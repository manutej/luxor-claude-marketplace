# pytest - Advanced Python Unit Testing for Customer Support

## Overview

Welcome to the comprehensive pytest skill for customer support tech enablement. This resource helps support engineers, backend developers, QA teams, and data curators implement robust testing strategies for Python-based customer support applications, including ticketing systems, knowledge bases, and customer data platforms.

pytest is the industry-standard testing framework for Python, offering powerful features that make testing easier, more maintainable, and more comprehensive. In customer support contexts, where reliability and data accuracy are critical, pytest provides the tools needed to ensure system quality and customer satisfaction.

## Why pytest for Customer Support Systems?

Customer support systems have unique testing requirements that pytest addresses exceptionally well:

### Critical Business Needs

- **High Reliability Requirements**: Support systems are mission-critical; downtime directly impacts customer satisfaction and business reputation
- **Complex Data Relationships**: Tickets, customers, agents, comments, attachments, tags, and knowledge base articles with intricate interconnections
- **External Integrations**: Email services (SendGrid, AWS SES), CRM systems (Salesforce, HubSpot), payment processors (Stripe), notification services (Twilio, Firebase)
- **Asynchronous Operations**: Background jobs, email queues, webhook deliveries, batch processing, and async API endpoints
- **Data Validation**: Strict validation rules for customer PII, ticket priorities, SLA requirements, escalation logic, and compliance
- **Multi-tenant Architecture**: Secure isolation between different customer organizations or team workspaces
- **API-First Design**: RESTful APIs with comprehensive endpoint coverage for mobile apps and integrations
- **Real-time Features**: WebSocket connections, live chat, real-time ticket updates, and agent presence indicators
- **Compliance Requirements**: GDPR, CCPA, SOC 2, data retention policies, and comprehensive audit logging

### pytest Advantages

pytest addresses these needs with:

- **Powerful Fixture System** for managing test data, database connections, and dependencies
- **Parametrization** for testing multiple scenarios efficiently (priority levels, user roles, edge cases)
- **Rich Plugin Ecosystem** including pytest-asyncio, pytest-mock, pytest-cov, pytest-benchmark
- **Excellent Integration** with FastAPI, SQLAlchemy, PostgreSQL, Pydantic, and modern Python stacks
- **Clear, Readable Output** with detailed error messages and stack traces
- **Scalability** from small test suites to thousands of tests with parallel execution
- **Flexibility** supporting unit, integration, and end-to-end testing in one framework

## Installation and Setup

### Prerequisites

- Python 3.8 or higher
- pip (Python package manager)
- PostgreSQL 12+ (recommended for testing)
- Virtual environment (recommended)

### Basic Installation

```bash
# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install pytest with essential plugins
pip install pytest pytest-asyncio pytest-cov pytest-mock

# For customer support applications, also install:
pip install pytest-postgresql httpx fastapi sqlalchemy psycopg2-binary pydantic
```

### Complete Installation for Support Systems

```bash
# Install all recommended packages
pip install \
  pytest>=8.0.0 \
  pytest-asyncio>=0.23.0 \
  pytest-cov>=4.1.0 \
  pytest-mock>=3.12.0 \
  pytest-postgresql>=5.0.0 \
  pytest-benchmark>=4.0.0 \
  pytest-xdist>=3.5.0 \
  httpx>=0.26.0 \
  fastapi>=0.109.0 \
  sqlalchemy>=2.0.0 \
  psycopg2-binary>=2.9.9 \
  pydantic>=2.0.0 \
  alembic>=1.13.0
```

### Project Structure

Organize your customer support project with a clear, maintainable test structure:

```
support_backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI application entry point
│   ├── config.py            # Application configuration
│   ├── database.py          # Database configuration and session management
│   ├── dependencies.py      # FastAPI dependencies (auth, database, etc.)
│   ├── models/
│   │   ├── __init__.py
│   │   ├── ticket.py        # Ticket model
│   │   ├── customer.py      # Customer model
│   │   ├── agent.py         # Agent/User model
│   │   └── comment.py       # Comment model
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── ticket.py        # Pydantic schemas for tickets
│   │   ├── customer.py      # Pydantic schemas for customers
│   │   └── agent.py         # Pydantic schemas for agents
│   ├── routers/
│   │   ├── __init__.py
│   │   ├── tickets.py       # Ticket endpoints
│   │   ├── customers.py     # Customer endpoints
│   │   ├── agents.py        # Agent endpoints
│   │   └── admin.py         # Admin endpoints
│   ├── services/
│   │   ├── __init__.py
│   │   ├── ticket_service.py
│   │   ├── email_service.py
│   │   ├── notification_service.py
│   │   ├── sla_service.py
│   │   ├── assignment_service.py
│   │   └── escalation_service.py
│   ├── utils/
│   │   ├── __init__.py
│   │   ├── validators.py
│   │   ├── helpers.py
│   │   └── formatters.py
│   └── tasks/
│       ├── __init__.py
│       ├── email_tasks.py
│       └── export_tasks.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py          # Shared fixtures for all tests
│   ├── unit/
│   │   ├── __init__.py
│   │   ├── conftest.py      # Unit test fixtures
│   │   ├── test_validators.py
│   │   ├── test_models.py
│   │   ├── test_schemas.py
│   │   └── services/
│   │       ├── test_ticket_service.py
│   │       ├── test_email_service.py
│   │       ├── test_sla_service.py
│   │       └── test_assignment_service.py
│   ├── integration/
│   │   ├── __init__.py
│   │   ├── conftest.py      # Integration test fixtures
│   │   ├── test_api_tickets.py
│   │   ├── test_api_customers.py
│   │   ├── test_api_agents.py
│   │   ├── test_database.py
│   │   └── test_external_apis.py
│   ├── e2e/
│   │   ├── __init__.py
│   │   ├── test_ticket_lifecycle.py
│   │   ├── test_customer_journey.py
│   │   └── test_agent_workflow.py
│   └── performance/
│       ├── __init__.py
│       └── test_api_performance.py
├── migrations/              # Alembic database migrations
│   └── versions/
├── pytest.ini               # Pytest configuration
├── .coveragerc              # Coverage configuration
├── requirements.txt         # Production dependencies
├── requirements-dev.txt     # Development dependencies
└── README.md
```

### Configuration Files

#### pytest.ini

```ini
[pytest]
# Test discovery paths
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*

# Custom markers for categorizing tests
markers =
    unit: Unit tests (fast, isolated)
    integration: Integration tests (database, API)
    e2e: End-to-end tests (full workflows)
    slow: Slow running tests
    smoke: Quick smoke tests for sanity checks
    database: Tests requiring database
    external: Tests requiring external services
    auth: Authentication/authorization tests
    sla: SLA and escalation tests
    notification: Email and notification tests

# Default options for all test runs
addopts =
    -v                        # Verbose output
    --strict-markers          # Fail on unknown markers
    --tb=short                # Short traceback format
    --cov=app                 # Coverage for 'app' directory
    --cov-report=term-missing # Show missing lines in terminal
    --cov-report=html         # Generate HTML coverage report
    --cov-fail-under=75       # Fail if coverage below 75%
    --maxfail=5               # Stop after 5 failures
    -ra                       # Show summary of all test outcomes

# Async test configuration
asyncio_mode = auto

# Minimum Python version
minversion = 3.8

# Filter warnings
filterwarnings =
    ignore::DeprecationWarning
    ignore::PendingDeprecationWarning
```

#### .coveragerc

```ini
[run]
source = app
branch = True  # Enable branch coverage
omit =
    */tests/*
    */migrations/*
    */__init__.py
    */config.py
    */venv/*
    */.venv/*
    */site-packages/*

[report]
precision = 2
show_missing = True
skip_covered = False
exclude_lines =
    # Standard exclusions
    pragma: no cover
    def __repr__
    def __str__
    raise AssertionError
    raise NotImplementedError
    if __name__ == .__main__.:
    if TYPE_CHECKING:
    @abstractmethod
    @abc.abstractmethod
    except ImportError
    # Defensive programming
    pass
    # Debug code
    if settings.DEBUG

[html]
directory = htmlcov
title = Customer Support API Coverage Report

[xml]
output = coverage.xml
```

## Quick Start Guide

### Your First Test

Create a simple test for ticket validation:

```python
# tests/unit/test_validators.py
import pytest
from app.utils.validators import validate_ticket_priority, validate_email

def test_valid_priority_accepted():
    """Test that valid ticket priorities are accepted."""
    assert validate_ticket_priority("low") is True
    assert validate_ticket_priority("medium") is True
    assert validate_ticket_priority("high") is True
    assert validate_ticket_priority("critical") is True

def test_invalid_priority_rejected():
    """Test that invalid priorities raise ValueError."""
    with pytest.raises(ValueError, match="Invalid priority"):
        validate_ticket_priority("invalid")

    with pytest.raises(ValueError):
        validate_ticket_priority("")

@pytest.mark.parametrize("email,expected", [
    ("user@example.com", True),
    ("agent@support.com", True),
    ("invalid.email", False),
    ("@example.com", False),
    ("user@", False),
])
def test_email_validation(email, expected):
    """Test email validation with various inputs."""
    assert validate_email(email) == expected
```

Run your first test:

```bash
# Run all tests
pytest

# Run specific test file
pytest tests/unit/test_validators.py

# Run with verbose output
pytest tests/unit/test_validators.py -v

# Run with coverage
pytest tests/unit/test_validators.py --cov=app.utils.validators
```

### Testing a FastAPI Endpoint

```python
# tests/integration/test_api_tickets.py
import pytest
from fastapi.testclient import TestClient
from app.main import app

@pytest.fixture
def client():
    """Provide FastAPI test client."""
    return TestClient(app)

def test_create_ticket(client):
    """Test creating a support ticket via API."""
    response = client.post(
        "/api/v1/tickets",
        json={
            "title": "Login Issue",
            "description": "Cannot access account after password reset",
            "priority": "high",
            "customer_email": "customer@example.com",
            "category": "authentication"
        }
    )

    assert response.status_code == 201
    data = response.json()
    assert data["title"] == "Login Issue"
    assert data["priority"] == "high"
    assert "id" in data
    assert "created_at" in data

def test_list_tickets(client):
    """Test retrieving list of tickets."""
    response = client.get("/api/v1/tickets")

    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)

def test_get_ticket_not_found(client):
    """Test retrieving non-existent ticket returns 404."""
    response = client.get("/api/v1/tickets/99999")
    assert response.status_code == 404
```

Run API tests:

```bash
pytest tests/integration/test_api_tickets.py -v
```

### Using Database Fixtures

```python
# tests/conftest.py
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database import Base
from app.models import Customer, Ticket

@pytest.fixture(scope="session")
def db_engine():
    """Create test database engine."""
    engine = create_engine(
        "postgresql://test:test@localhost:5432/support_test",
        echo=False
    )
    Base.metadata.create_all(engine)
    yield engine
    Base.metadata.drop_all(engine)
    engine.dispose()

@pytest.fixture
def db_session(db_engine):
    """Provide database session with automatic rollback."""
    connection = db_engine.connect()
    transaction = connection.begin()
    session = sessionmaker(bind=connection)()

    yield session

    session.close()
    transaction.rollback()
    connection.close()

@pytest.fixture
def sample_customer(db_session):
    """Create a sample customer for testing."""
    customer = Customer(
        email="test@example.com",
        name="Test Customer",
        tier="premium"
    )
    db_session.add(customer)
    db_session.commit()
    return customer

# tests/integration/test_database.py
def test_customer_creation(sample_customer):
    """Test that customer was created successfully."""
    assert sample_customer.email == "test@example.com"
    assert sample_customer.tier == "premium"
    assert sample_customer.id is not None

def test_ticket_creation(db_session, sample_customer):
    """Test creating a ticket for a customer."""
    ticket = Ticket(
        title="Test Ticket",
        description="Test description",
        priority="high",
        customer_id=sample_customer.id
    )
    db_session.add(ticket)
    db_session.commit()

    assert ticket.id is not None
    assert ticket.customer.email == sample_customer.email
```

## Key Features for Support Teams

### 1. Comprehensive Test Coverage

pytest enables thorough testing of all customer support functionality:

- **API Endpoints**: Test all CRUD operations for tickets, customers, and agents
- **Business Logic**: Validate SLA calculations, ticket assignment, escalation rules
- **Data Validation**: Ensure all input validation rules are working correctly
- **External Integrations**: Mock and test email services, CRM sync, webhooks
- **Background Tasks**: Test async jobs for email delivery, data exports, cleanup
- **Database Operations**: Verify queries, relationships, transactions, and migrations

### 2. Fixture System for Reusable Test Data

Fixtures eliminate repetitive setup code and ensure consistent test environments:

```python
# Reusable fixtures in conftest.py
@pytest.fixture
def ticket_factory(db_session):
    """Factory for creating test tickets."""
    def _create(title="Test", priority="medium", **kwargs):
        ticket = Ticket(title=title, priority=priority, **kwargs)
        db_session.add(ticket)
        db_session.commit()
        return ticket
    return _create

# Use in tests
def test_high_priority_assignment(ticket_factory, agent):
    high_priority_ticket = ticket_factory(priority="critical")
    assign_ticket(high_priority_ticket, agent)
    assert high_priority_ticket.assigned_agent_id == agent.id
```

### 3. Parametrization for Edge Cases

Test multiple scenarios efficiently without duplicating code:

```python
@pytest.mark.parametrize("priority,expected_sla", [
    ("critical", 1),
    ("high", 4),
    ("medium", 24),
    ("low", 72)
])
def test_sla_calculation(priority, expected_sla):
    """Verify SLA hours for each priority level."""
    sla = calculate_sla_hours(priority)
    assert sla == expected_sla
```

### 4. Mocking External Services

Test without dependency on external services:

```python
def test_email_notification(mocker):
    """Test email sent without actually sending."""
    mock_send = mocker.patch('app.services.email.send_email')
    mock_send.return_value = {"status": "sent"}

    notify_customer("ticket_created", "customer@example.com")

    mock_send.assert_called_once()
```

### 5. Async Testing Support

Test modern async endpoints and background tasks:

```python
@pytest.mark.asyncio
async def test_async_ticket_creation():
    """Test async ticket creation service."""
    ticket = await create_ticket_async(
        title="Async Test",
        priority="high"
    )
    assert ticket.id is not None
```

### 6. Code Coverage Reporting

Measure and improve test coverage:

```bash
# Generate coverage report
pytest --cov=app --cov-report=html

# View report
open htmlcov/index.html

# Fail if coverage drops below threshold
pytest --cov=app --cov-fail-under=80
```

## Common Testing Patterns

### Pattern 1: Testing CRUD Operations

```python
def test_ticket_lifecycle(db_session):
    """Test complete ticket CRUD operations."""
    # Create
    ticket = Ticket(title="Test", priority="high")
    db_session.add(ticket)
    db_session.commit()
    ticket_id = ticket.id

    # Read
    found = db_session.query(Ticket).filter_by(id=ticket_id).first()
    assert found is not None

    # Update
    found.status = "resolved"
    db_session.commit()
    assert found.status == "resolved"

    # Delete
    db_session.delete(found)
    db_session.commit()
    assert db_session.query(Ticket).filter_by(id=ticket_id).first() is None
```

### Pattern 2: Testing Error Handling

```python
def test_invalid_ticket_creation(client):
    """Test that invalid data returns proper errors."""
    response = client.post(
        "/api/v1/tickets",
        json={"description": "Missing title"}  # Title is required
    )
    assert response.status_code == 422  # Validation error
    errors = response.json()["detail"]
    assert any("title" in str(e).lower() for e in errors)
```

### Pattern 3: Testing Authentication

```python
def test_unauthenticated_request(client):
    """Test that protected endpoints require authentication."""
    response = client.get("/api/v1/admin/users")
    assert response.status_code == 401

def test_insufficient_permissions(client, agent_token):
    """Test that agents cannot access admin endpoints."""
    response = client.delete(
        "/api/v1/tickets/1",
        headers={"Authorization": f"Bearer {agent_token}"}
    )
    assert response.status_code == 403  # Forbidden
```

### Pattern 4: Testing Business Logic

```python
def test_automatic_escalation(db_session):
    """Test that old unassigned tickets are escalated."""
    from datetime import datetime, timedelta

    old_ticket = Ticket(
        title="Old Ticket",
        priority="medium",
        created_at=datetime.utcnow() - timedelta(days=3)
    )
    db_session.add(old_ticket)
    db_session.commit()

    escalate_overdue_tickets(db_session)

    db_session.refresh(old_ticket)
    assert old_ticket.priority == "high"  # Escalated
    assert old_ticket.escalated is True
```

## Running Tests

### Basic Commands

```bash
# Run all tests
pytest

# Run specific file
pytest tests/unit/test_validators.py

# Run specific test
pytest tests/unit/test_validators.py::test_email_validation

# Run tests matching pattern
pytest -k "email"

# Run with verbose output
pytest -v

# Run with very verbose output
pytest -vv
```

### Running by Markers

```bash
# Run only unit tests
pytest -m unit

# Run all except slow tests
pytest -m "not slow"

# Run integration and database tests
pytest -m "integration or database"

# Run smoke tests (quick validation)
pytest -m smoke
```

### Parallel Execution

```bash
# Install pytest-xdist
pip install pytest-xdist

# Run tests in parallel (auto-detect CPU count)
pytest -n auto

# Run tests on 4 cores
pytest -n 4
```

### Coverage Options

```bash
# Run with coverage
pytest --cov=app

# Show lines not covered
pytest --cov=app --cov-report=term-missing

# Generate HTML report
pytest --cov=app --cov-report=html

# Generate XML for CI/CD
pytest --cov=app --cov-report=xml

# Fail if coverage below threshold
pytest --cov=app --cov-fail-under=80
```

### Debugging Tests

```bash
# Stop at first failure
pytest -x

# Drop into debugger on failure
pytest --pdb

# Show local variables in traceback
pytest -l

# Show print statements
pytest -s

# More detailed output
pytest -vv
```

## Troubleshooting

### Common Issues and Solutions

#### 1. ModuleNotFoundError

**Problem:** `ModuleNotFoundError: No module named 'app'`

**Solution:**
```bash
# Option 1: Install package in development mode
pip install -e .

# Option 2: Set PYTHONPATH
export PYTHONPATH="${PYTHONPATH}:${PWD}"

# Option 3: Add to pytest.ini
# [pytest]
# pythonpath = .
```

#### 2. Database Locked Errors

**Problem:** "database is locked" with SQLite

**Solution:** Use PostgreSQL for tests instead of SQLite:
```python
# Use PostgreSQL which supports concurrent access
@pytest.fixture(scope="session")
def db_engine():
    engine = create_engine(
        "postgresql://test:test@localhost/test_db",
        pool_pre_ping=True
    )
    return engine
```

#### 3. Async Tests Hanging

**Problem:** Async tests never complete

**Solution:**
```python
# Ensure pytest-asyncio is installed
pip install pytest-asyncio

# Configure in pytest.ini
# [pytest]
# asyncio_mode = auto

# Always use @pytest.mark.asyncio
@pytest.mark.asyncio
async def test_async_function():
    result = await async_function()
    assert result is not None
```

#### 4. Fixture Not Found

**Problem:** `fixture 'db_session' not found`

**Solution:**
- Ensure fixture is in conftest.py at correct level
- Check fixture name spelling
- Verify no circular dependencies

#### 5. Tests Pass Individually But Fail Together

**Problem:** Tests pass when run alone but fail when run together

**Solution:** Ensure test isolation with proper fixture cleanup:
```python
@pytest.fixture
def db_session(db_engine):
    connection = db_engine.connect()
    transaction = connection.begin()
    session = sessionmaker(bind=connection)()

    yield session

    # Cleanup ensures isolation
    session.close()
    transaction.rollback()
    connection.close()
```

#### 6. Mock Not Working

**Problem:** Mock is not being called or original function runs

**Solution:** Patch where it's used, not where it's defined:
```python
# If tickets.py imports: from services import send_email
# Patch it in tickets module:
mocker.patch('app.routers.tickets.send_email')

# Not in services module:
# mocker.patch('app.services.email.send_email')  # Wrong!
```

## Best Practices

### 1. Write Descriptive Test Names

```python
# Good - describes what is being tested
def test_high_priority_ticket_assigns_to_senior_agent():
    pass

def test_sla_breach_notification_sent_when_critical_ticket_unassigned_for_1_hour():
    pass

# Bad - vague, unclear
def test_assignment():
    pass

def test_notification():
    pass
```

### 2. Follow AAA Pattern

```python
def test_ticket_assignment():
    # Arrange: Set up test data
    agent = create_agent(role="senior")
    ticket = create_ticket(priority="critical")

    # Act: Execute the operation
    result = assign_ticket(ticket, agent)

    # Assert: Verify outcomes
    assert result.assigned_agent_id == agent.id
    assert result.status == "assigned"
```

### 3. Keep Tests Independent

Each test should run successfully regardless of other tests:

```python
# Bad - depends on test_create_user
def test_get_user():
    user = get_user("test@example.com")
    assert user is not None

# Good - self-contained
def test_get_user(test_user):
    user = get_user(test_user.email)
    assert user is not None
```

### 4. Use Fixtures for Setup

```python
# Good - reusable fixture
@pytest.fixture
def authenticated_client(client):
    client.headers.update({"Authorization": "Bearer test_token"})
    return client

def test_protected_endpoint(authenticated_client):
    response = authenticated_client.get("/api/protected")
    assert response.status_code == 200

# Bad - setup in each test
def test_protected_endpoint(client):
    client.headers.update({"Authorization": "Bearer test_token"})
    response = client.get("/api/protected")
    assert response.status_code == 200
```

### 5. Test One Thing Per Test

```python
# Good - focused test
def test_ticket_creation_sets_default_status():
    ticket = create_ticket(title="Test")
    assert ticket.status == "open"

def test_ticket_creation_sets_timestamp():
    ticket = create_ticket(title="Test")
    assert ticket.created_at is not None

# Bad - testing multiple things
def test_ticket_creation():
    ticket = create_ticket(title="Test")
    assert ticket.status == "open"
    assert ticket.created_at is not None
    assert ticket.priority == "medium"
```

## Next Steps

1. **Review Examples**: Check EXAMPLES.md for 15+ practical code examples
2. **Study Skill Guide**: Read SKILL.md for comprehensive documentation
3. **Set Up Tests**: Create your first test file following the quick start guide
4. **Add Coverage**: Aim for 80%+ coverage on critical business logic
5. **Integrate CI/CD**: Add pytest to your continuous integration pipeline
6. **Iterate**: Continuously improve test coverage and quality

## Resources

- [Official pytest Documentation](https://docs.pytest.org/)
- [pytest-asyncio Documentation](https://pytest-asyncio.readthedocs.io/)
- [pytest-mock Documentation](https://pytest-mock.readthedocs.io/)
- [FastAPI Testing Guide](https://fastapi.tiangolo.com/tutorial/testing/)
- [SQLAlchemy Testing Guide](https://docs.sqlalchemy.org/en/20/core/pooling.html)
- [Coverage.py Documentation](https://coverage.readthedocs.io/)

## Support

For questions or issues:
- Review the EXAMPLES.md file for 15+ practical examples
- Check the SKILL.md file for comprehensive documentation
- Consult the troubleshooting section above
- Review pytest official documentation

**Happy Testing!** Build reliable, well-tested customer support systems with confidence.
