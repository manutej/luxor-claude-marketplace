# Pydantic Data Validation Skill

## Overview

Welcome to the comprehensive Pydantic skill for customer support tech enablement! This skill provides everything you need to build robust, type-safe data validation systems for customer support operations using Pydantic V2.

Pydantic is a data validation library that uses Python type hints to validate data at runtime, providing developer-friendly error messages when data is invalid. It's the foundation of modern Python data validation, powering frameworks like FastAPI, and is essential for building reliable customer support systems.

## What is Pydantic?

Pydantic is a data validation and settings management library that leverages Python's type hints to ensure data integrity. It validates data structures, coerces types when appropriate, and provides detailed error messages when validation fails.

### Key Benefits for Customer Support Teams

1. **Data Quality Assurance**: Ensure all support tickets, customer data, and API requests meet quality standards
2. **Automatic Validation**: Catch data issues before they reach your database or cause bugs
3. **Type Safety**: Leverage Python type hints for IDE autocomplete and early error detection
4. **Clear Error Messages**: Understand exactly what's wrong with invalid data
5. **Performance**: Pydantic V2 is built on Rust, making it extremely fast
6. **API Documentation**: Automatic OpenAPI schema generation with FastAPI
7. **Configuration Management**: Type-safe environment variable and settings handling

## Installation

### Basic Installation

```bash
pip install pydantic>=2.0.0
```

### Full Installation for Customer Support Systems

```bash
# Install core packages
pip install pydantic>=2.0.0
pip install pydantic-settings>=2.0.0
pip install email-validator>=2.0.0

# Optional: For FastAPI integration
pip install fastapi>=0.100.0
pip install uvicorn[standard]

# Optional: For enhanced validation
pip install python-dotenv>=1.0.0
pip install phonenumbers>=8.13.0
```

### Requirements File

Create a `requirements.txt` file:

```
pydantic>=2.5.0
pydantic-settings>=2.1.0
email-validator>=2.1.0
python-dotenv>=1.0.0
fastapi>=0.104.0
uvicorn[standard]>=0.24.0
```

Then install:
```bash
pip install -r requirements.txt
```

## Quick Start Guide

### Your First Pydantic Model

Let's create a simple support ticket model:

```python
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class SupportTicket(BaseModel):
    ticket_id: int
    customer_email: str
    subject: str = Field(min_length=5, max_length=200)
    description: str = Field(min_length=20)
    priority: str = 'medium'
    status: str = 'open'
    created_at: datetime

# Create a ticket
ticket = SupportTicket(
    ticket_id=12345,
    customer_email='customer@example.com',
    subject='Cannot login to account',
    description='I have been trying to log in for the past hour but keep getting an error message.',
    created_at='2024-01-15T10:30:00'
)

# Access validated data
print(f"Ticket #{ticket.ticket_id}: {ticket.subject}")
print(f"Priority: {ticket.priority}")

# Convert to dictionary
ticket_dict = ticket.model_dump()

# Convert to JSON
ticket_json = ticket.model_dump_json(indent=2)
```

### Handling Validation Errors

```python
from pydantic import ValidationError

try:
    # This will fail validation
    invalid_ticket = SupportTicket(
        ticket_id='not-a-number',  # Should be int
        customer_email='customer@example.com',
        subject='Hi',  # Too short (min_length=5)
        description='Help',  # Too short (min_length=20)
        created_at='2024-01-15T10:30:00'
    )
except ValidationError as e:
    print(f"Validation failed with {e.error_count()} errors:")
    for error in e.errors():
        print(f"  - {error['loc'][0]}: {error['msg']}")
```

Output:
```
Validation failed with 3 errors:
  - ticket_id: Input should be a valid integer
  - subject: String should have at least 5 characters
  - description: String should have at least 20 characters
```

## Pydantic V1 vs V2 Differences

Understanding the differences between Pydantic V1 and V2 is crucial for modern development.

### Major Changes in V2

| Feature | Pydantic V1 | Pydantic V2 |
|---------|-------------|-------------|
| **Core Performance** | Pure Python | Rust-powered core (10-50x faster) |
| **Validation** | `validator()` | `@field_validator()`, `@model_validator()` |
| **Serialization** | `.dict()`, `.json()` | `.model_dump()`, `.model_dump_json()` |
| **Configuration** | `Config` class | `ConfigDict` or class kwargs |
| **Settings** | `pydantic.BaseSettings` | `pydantic-settings.BaseSettings` |
| **Field validation mode** | `pre=True/False` | `mode='before'/'after'` |
| **JSON schema** | `.schema()` | `.model_json_schema()` |

### Migration Examples

#### V1 Code:
```python
from pydantic import BaseModel, validator

class User(BaseModel):
    name: str
    email: str

    @validator('email')
    def validate_email(cls, v):
        if '@' not in v:
            raise ValueError('Invalid email')
        return v

    class Config:
        frozen = True

user_dict = user.dict()
user_json = user.json()
```

#### V2 Code:
```python
from pydantic import BaseModel, field_validator, ConfigDict

class User(BaseModel):
    model_config = ConfigDict(frozen=True)

    name: str
    email: str

    @field_validator('email')
    @classmethod
    def validate_email(cls, v: str) -> str:
        if '@' not in v:
            raise ValueError('Invalid email')
        return v

user_dict = user.model_dump()
user_json = user.model_dump_json()
```

### Why Upgrade to V2?

1. **Performance**: 10-50x faster validation thanks to Rust core
2. **Better Type Support**: Improved TypeScript-like typing with `Annotated`
3. **Cleaner API**: More consistent naming and patterns
4. **Better Error Messages**: More detailed and actionable validation errors
5. **Future-Proof**: V1 is in maintenance mode, V2 receives active development
6. **Better IDE Support**: Enhanced autocomplete and type checking

## Key Features for Support Teams

### 1. Email Validation

```python
from pydantic import BaseModel, EmailStr

class CustomerContact(BaseModel):
    email: EmailStr  # Validates email format
    backup_email: EmailStr | None = None

# Valid
contact = CustomerContact(email='user@example.com')

# Invalid - raises ValidationError
contact = CustomerContact(email='not-an-email')
```

### 2. Field Constraints

```python
from pydantic import BaseModel, Field

class TicketForm(BaseModel):
    subject: str = Field(min_length=10, max_length=200)
    priority: int = Field(ge=1, le=5)  # Between 1 and 5
    category: str = Field(pattern=r'^(tech|billing|account)$')
```

### 3. Custom Validators

```python
from pydantic import BaseModel, field_validator

class Ticket(BaseModel):
    ticket_id: str

    @field_validator('ticket_id')
    @classmethod
    def validate_ticket_format(cls, v: str) -> str:
        if not v.startswith('TKT-'):
            raise ValueError('Ticket ID must start with TKT-')
        return v.upper()
```

### 4. Nested Models

```python
from pydantic import BaseModel

class Address(BaseModel):
    street: str
    city: str
    country: str

class Customer(BaseModel):
    name: str
    email: str
    address: Address  # Nested model

customer = Customer(
    name='John Doe',
    email='john@example.com',
    address={
        'street': '123 Main St',
        'city': 'New York',
        'country': 'USA'
    }
)
```

### 5. Optional Fields and Defaults

```python
from pydantic import BaseModel, Field
from typing import Optional

class Ticket(BaseModel):
    ticket_id: int
    subject: str
    description: str
    assigned_to: Optional[str] = None  # Optional field
    tags: list[str] = Field(default_factory=list)  # Default empty list
    priority: str = 'medium'  # Default value
```

## Best Practices for Validation

### 1. Separate Request and Response Models

```python
# Request model - minimal required data
class TicketCreateRequest(BaseModel):
    customer_email: str
    subject: str
    description: str

# Response model - includes server-generated fields
class TicketResponse(BaseModel):
    ticket_id: int
    customer_email: str
    subject: str
    description: str
    created_at: datetime
    status: str
```

### 2. Use Descriptive Field Names and Descriptions

```python
class Ticket(BaseModel):
    ticket_id: int = Field(description='Unique ticket identifier')
    subject: str = Field(
        description='Brief summary of the issue',
        min_length=10,
        max_length=200,
        examples=['Cannot access dashboard', 'Payment failed']
    )
```

### 3. Validate Business Logic with Model Validators

```python
from pydantic import model_validator

class DateRange(BaseModel):
    start_date: datetime
    end_date: datetime

    @model_validator(mode='after')
    def validate_date_range(self) -> 'DateRange':
        if self.end_date <= self.start_date:
            raise ValueError('end_date must be after start_date')
        return self
```

### 4. Use Enums for Fixed Choices

```python
from enum import Enum

class TicketStatus(str, Enum):
    OPEN = 'open'
    IN_PROGRESS = 'in_progress'
    RESOLVED = 'resolved'
    CLOSED = 'closed'

class Ticket(BaseModel):
    status: TicketStatus = TicketStatus.OPEN
```

### 5. Configure Models Appropriately

```python
from pydantic import ConfigDict

class StrictTicket(BaseModel):
    model_config = ConfigDict(
        strict=True,  # No type coercion
        frozen=True,  # Immutable after creation
        extra='forbid',  # Reject unknown fields
        validate_assignment=True  # Validate on attribute changes
    )

    ticket_id: int
    subject: str
```

## Configuration Management

Pydantic is excellent for managing application configuration with type safety:

```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    # Database
    database_url: str
    db_pool_size: int = 10

    # Email
    smtp_host: str
    smtp_port: int = 587
    smtp_username: str
    smtp_password: str

    # Application
    debug: bool = False
    max_tickets_per_page: int = 50

    model_config = SettingsConfigDict(
        env_file='.env',
        env_file_encoding='utf-8',
        case_sensitive=False
    )

# Automatically loads from environment variables or .env file
settings = Settings()
```

## Troubleshooting Guide

### Problem: ImportError for BaseSettings

**Error:**
```
ImportError: cannot import name 'BaseSettings' from 'pydantic'
```

**Solution:**
In Pydantic V2, `BaseSettings` moved to a separate package:
```bash
pip install pydantic-settings
```

Then import:
```python
from pydantic_settings import BaseSettings
```

### Problem: ValidationError with Datetime

**Error:**
```
ValidationError: Input should be a valid datetime
```

**Solution:**
Ensure datetime strings are in ISO format:
```python
# Good
created_at = '2024-01-15T10:30:00'
created_at = '2024-01-15T10:30:00Z'
created_at = '2024-01-15T10:30:00+00:00'

# Bad
created_at = '01/15/2024'
created_at = 'Jan 15, 2024'
```

### Problem: Mutable Default Argument

**Error:**
```python
class Ticket(BaseModel):
    tags: list[str] = []  # All instances share the same list!
```

**Solution:**
Use `Field(default_factory=list)`:
```python
from pydantic import Field

class Ticket(BaseModel):
    tags: list[str] = Field(default_factory=list)
```

### Problem: Validation Too Strict

**Issue:** Pydantic rejects valid data due to strict type checking.

**Solution:**
Adjust model configuration:
```python
from pydantic import ConfigDict

class FlexibleModel(BaseModel):
    model_config = ConfigDict(
        strict=False,  # Allow type coercion
        str_strip_whitespace=True  # Auto-trim strings
    )
```

### Problem: Slow Validation Performance

**Issue:** Validation is slower than expected.

**Solutions:**

1. **Use TypeAdapter for bulk operations:**
```python
from pydantic import TypeAdapter

adapter = TypeAdapter(list[Ticket])
tickets = adapter.validate_python(ticket_list)
```

2. **Enable strict mode (no coercion):**
```python
class FastModel(BaseModel):
    model_config = ConfigDict(strict=True)
```

3. **Use discriminated unions:**
```python
from typing import Literal, Union
from pydantic import Field

class EmailTicket(BaseModel):
    type: Literal['email'] = 'email'

class PhoneTicket(BaseModel):
    type: Literal['phone'] = 'phone'

Ticket = Union[EmailTicket, PhoneTicket]

class Container(BaseModel):
    ticket: Ticket = Field(discriminator='type')
```

### Problem: Email Validation Failing

**Error:**
```
ValueError: email-validator not installed
```

**Solution:**
Install the email-validator package:
```bash
pip install email-validator
```

### Problem: Can't Exclude Fields from Serialization

**Issue:** Need to hide internal fields from API responses.

**Solution:**
Use `Field(exclude=True)`:
```python
class Ticket(BaseModel):
    ticket_id: int
    subject: str
    internal_notes: str = Field(exclude=True)

ticket = Ticket(ticket_id=1, subject='Test', internal_notes='Secret')
print(ticket.model_dump())  # internal_notes not included
```

Or exclude dynamically:
```python
print(ticket.model_dump(exclude={'internal_notes'}))
```

### Problem: Need to Validate Existing Model Instances

**Issue:** Modified model instance isn't being revalidated.

**Solution:**
Enable `validate_assignment`:
```python
from pydantic import ConfigDict

class Ticket(BaseModel):
    model_config = ConfigDict(validate_assignment=True)

    priority: int

ticket = Ticket(priority=1)
ticket.priority = 'high'  # Raises ValidationError
```

## Common Use Cases

### Use Case 1: API Request Validation

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, ValidationError

app = FastAPI()

class CreateTicketRequest(BaseModel):
    subject: str
    description: str
    priority: str = 'medium'

@app.post('/tickets/')
async def create_ticket(request: CreateTicketRequest):
    # Request is automatically validated by FastAPI
    return {'ticket_id': 123, **request.model_dump()}
```

### Use Case 2: Database Model Validation

```python
from sqlalchemy import create_engine
from pydantic import BaseModel, ConfigDict

class TicketDB(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    ticket_id: int
    subject: str
    status: str

# Convert SQLAlchemy model to Pydantic
orm_ticket = session.query(TicketORM).first()
pydantic_ticket = TicketDB.model_validate(orm_ticket)
```

### Use Case 3: Configuration File Parsing

```python
import json
from pydantic import BaseModel

class AppConfig(BaseModel):
    database_url: str
    debug: bool = False
    max_connections: int = 100

with open('config.json') as f:
    config_data = json.load(f)

config = AppConfig(**config_data)
```

## Testing with Pydantic

```python
import pytest
from pydantic import ValidationError

def test_ticket_validation():
    # Test valid data
    ticket = Ticket(
        ticket_id=123,
        subject='Test ticket',
        description='A valid description'
    )
    assert ticket.ticket_id == 123

    # Test invalid data
    with pytest.raises(ValidationError) as exc_info:
        Ticket(ticket_id='invalid', subject='', description='')

    errors = exc_info.value.errors()
    assert len(errors) >= 1
    assert any(e['loc'] == ('ticket_id',) for e in errors)
```

## Performance Tips

1. **Reuse TypeAdapters**: Create once, use many times
2. **Use strict mode**: Disable type coercion when data is already correct type
3. **Avoid dynamic model creation**: Define models at module level
4. **Use discriminated unions**: For polymorphic data with type field
5. **Batch validate**: Use TypeAdapter for lists instead of validating one-by-one

## Additional Resources

- **Official Documentation**: https://docs.pydantic.dev/
- **Pydantic Settings**: https://docs.pydantic.dev/latest/concepts/pydantic_settings/
- **FastAPI Documentation**: https://fastapi.tiangolo.com/
- **Migration Guide**: https://docs.pydantic.dev/latest/migration/
- **GitHub Repository**: https://github.com/pydantic/pydantic
- **Discord Community**: https://discord.com/invite/pydantic

## Next Steps

1. Review the **SKILL.md** file for comprehensive patterns and techniques
2. Explore **EXAMPLES.md** for 15+ practical, runnable examples
3. Start with simple models and gradually add complexity
4. Integrate with FastAPI for automatic API documentation
5. Use BaseSettings for configuration management
6. Write tests for your validation logic
7. Monitor validation performance in production

## Support

For questions and issues:
- Check the official Pydantic documentation
- Search GitHub issues: https://github.com/pydantic/pydantic/issues
- Join the Pydantic Discord community
- Review examples in this skill package

## Version History

- **1.0.0** (2024-01-15): Initial release with Pydantic V2 support
  - Comprehensive customer support examples
  - FastAPI integration patterns
  - BaseSettings configuration management
  - Performance optimization techniques
  - 15+ practical examples

---

**License**: MIT

**Maintained by**: Customer Support Tech Enablement Team

**Last Updated**: January 2024
