# Spring Boot Development Skill

A comprehensive skill for building modern Spring Boot applications with REST APIs, database integration, security, and enterprise Java patterns.

## Overview

Spring Boot is an opinionated framework built on top of the Spring Framework that makes it easy to create stand-alone, production-grade Spring-based applications. It provides auto-configuration, embedded servers, and production-ready features out of the box.

### Key Features

- **Auto-Configuration**: Automatically configures Spring application based on dependencies
- **Embedded Servers**: Built-in Tomcat, Jetty, or Undertow - no need for WAR deployment
- **Production-Ready**: Actuator endpoints for monitoring, health checks, and metrics
- **Starter Dependencies**: Curated sets of dependencies for different use cases
- **Convention over Configuration**: Sensible defaults with minimal configuration
- **Spring Ecosystem**: Full access to Spring Framework, Spring Data, Spring Security, etc.

## Getting Started

### Prerequisites

- Java 17 or higher
- Maven 3.6+ or Gradle 7+
- IDE (IntelliJ IDEA, Eclipse, VS Code)
- Database (PostgreSQL, MySQL, H2, etc.)

### Create a New Spring Boot Project

**Using Spring Initializr (https://start.spring.io/):**

1. Project: Maven or Gradle
2. Language: Java
3. Spring Boot: 3.x (latest stable)
4. Project Metadata:
   - Group: com.example
   - Artifact: myapp
   - Package name: com.example.myapp
   - Packaging: Jar
   - Java: 17

5. Dependencies:
   - Spring Web
   - Spring Data JPA
   - PostgreSQL Driver (or your database)
   - Spring Security
   - Validation
   - Lombok (optional)

**Using Maven:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>

    <groupId>com.example</groupId>
    <artifactId>myapp</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>myapp</name>
    <description>My Spring Boot Application</description>

    <properties>
        <java.version>17</java.version>
    </properties>

    <dependencies>
        <!-- Spring Boot Web -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- Spring Data JPA -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>

        <!-- PostgreSQL Driver -->
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>

        <!-- Spring Security -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>

        <!-- Validation -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

        <!-- Actuator -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

### Project Structure

```
myapp/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── example/
│   │   │           └── myapp/
│   │   │               ├── MyAppApplication.java
│   │   │               ├── config/
│   │   │               │   ├── SecurityConfig.java
│   │   │               │   └── AppConfig.java
│   │   │               ├── controller/
│   │   │               │   └── UserController.java
│   │   │               ├── service/
│   │   │               │   └── UserService.java
│   │   │               ├── repository/
│   │   │               │   └── UserRepository.java
│   │   │               ├── model/
│   │   │               │   └── User.java
│   │   │               ├── dto/
│   │   │               │   └── UserDTO.java
│   │   │               └── exception/
│   │   │                   ├── ResourceNotFoundException.java
│   │   │                   └── GlobalExceptionHandler.java
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       ├── application-prod.yml
│   │       └── db/
│   │           └── migration/
│   │               └── V1__Create_users_table.sql
│   └── test/
│       └── java/
│           └── com/
│               └── example/
│                   └── myapp/
│                       ├── MyAppApplicationTests.java
│                       ├── controller/
│                       │   └── UserControllerTest.java
│                       └── service/
│                           └── UserServiceTest.java
├── pom.xml
└── README.md
```

### Basic Application Setup

**Main Application Class:**

```java
package com.example.myapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class MyAppApplication {

    public static void main(String[] args) {
        SpringApplication.run(MyAppApplication.class, args);
    }
}
```

**Configuration (application.yml):**

```yaml
spring:
  application:
    name: myapp

  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: postgres
    password: password
    driver-class-name: org.postgresql.Driver

  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true

  security:
    user:
      name: admin
      password: admin

server:
  port: 8080
  servlet:
    context-path: /api

logging:
  level:
    root: INFO
    com.example.myapp: DEBUG

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: always
```

### Running the Application

**Using Maven:**

```bash
# Run the application
./mvnw spring-boot:run

# Run with specific profile
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# Build and run jar
./mvnw clean package
java -jar target/myapp-0.0.1-SNAPSHOT.jar
```

**Using Gradle:**

```bash
# Run the application
./gradlew bootRun

# Build and run jar
./gradlew build
java -jar build/libs/myapp-0.0.1-SNAPSHOT.jar
```

**Using IDE:**

Run the main application class (`MyAppApplication.java`) directly from your IDE.

## Quick Start Examples

### 1. Simple REST Controller

```java
@RestController
@RequestMapping("/api/hello")
public class HelloController {

    @GetMapping
    public String sayHello() {
        return "Hello, Spring Boot!";
    }

    @GetMapping("/{name}")
    public String sayHelloToName(@PathVariable String name) {
        return "Hello, " + name + "!";
    }
}
```

Test: `curl http://localhost:8080/api/hello/World`

### 2. Entity and Repository

```java
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String email;

    // Getters and setters
}

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}
```

### 3. Service Layer

```java
@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public List<User> findAll() {
        return userRepository.findAll();
    }

    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }

    public User save(User user) {
        return userRepository.save(user);
    }
}
```

### 4. Complete CRUD Controller

```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public List<User> getAllUsers() {
        return userService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        return userService.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<User> createUser(@Valid @RequestBody User user) {
        User created = userService.save(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id,
                                          @Valid @RequestBody User user) {
        return userService.findById(id)
            .map(existing -> {
                user.setId(id);
                return ResponseEntity.ok(userService.save(user));
            })
            .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        if (userService.findById(id).isPresent()) {
            userService.delete(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
```

## Common Development Tasks

### Database Setup

**H2 In-Memory Database (for development):**

```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
  h2:
    console:
      enabled: true
      path: /h2-console
```

**PostgreSQL:**

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: postgres
    password: password
```

**MySQL:**

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/mydb
    username: root
    password: password
```

### Database Migrations

**Using Flyway:**

Add dependency:
```xml
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
```

Create migration: `src/main/resources/db/migration/V1__Create_users_table.sql`

```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### Testing

**Unit Test:**

```java
@SpringBootTest
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @Test
    void testFindById() {
        User user = new User();
        user.setId(1L);
        user.setName("John");

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        Optional<User> result = userService.findById(1L);

        assertTrue(result.isPresent());
        assertEquals("John", result.get().getName());
    }
}
```

**Integration Test:**

```java
@SpringBootTest
@AutoConfigureMockMvc
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void testGetUser() throws Exception {
        mockMvc.perform(get("/api/users/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.id").value(1));
    }
}
```

## Key Concepts to Master

1. **Auto-Configuration**: Understanding how Spring Boot automatically configures your application
2. **Dependency Injection**: Constructor injection, component scanning, bean lifecycle
3. **REST APIs**: Building RESTful services with proper HTTP methods and status codes
4. **Data Access**: JPA entities, repositories, relationships, queries
5. **Security**: Authentication, authorization, JWT, OAuth2
6. **Exception Handling**: Global exception handlers, custom exceptions
7. **Validation**: Bean validation, custom validators
8. **Testing**: Unit tests, integration tests, test slices
9. **Configuration**: Properties, profiles, externalized configuration
10. **Production**: Actuator, monitoring, logging, deployment

## Resources

- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Spring Guides](https://spring.io/guides)
- [Baeldung Spring Boot Tutorials](https://www.baeldung.com/spring-boot)
- [Spring Boot GitHub](https://github.com/spring-projects/spring-boot)

## Next Steps

1. Review the SKILL.md file for comprehensive documentation
2. Check EXAMPLES.md for detailed code examples
3. Build a simple REST API project
4. Add database integration with Spring Data JPA
5. Implement authentication with Spring Security
6. Add validation and exception handling
7. Write unit and integration tests
8. Deploy your application

## Common Annotations Quick Reference

| Annotation | Purpose |
|------------|---------|
| `@SpringBootApplication` | Main application class |
| `@RestController` | REST API controller |
| `@Service` | Service layer component |
| `@Repository` | Data access layer component |
| `@Entity` | JPA entity |
| `@GetMapping` | HTTP GET request handler |
| `@PostMapping` | HTTP POST request handler |
| `@PutMapping` | HTTP PUT request handler |
| `@DeleteMapping` | HTTP DELETE request handler |
| `@PathVariable` | Extract path variable |
| `@RequestParam` | Extract query parameter |
| `@RequestBody` | Extract request body |
| `@Valid` | Enable validation |
| `@Transactional` | Enable transaction management |

## Troubleshooting

### Application won't start

- Check if port 8080 is already in use
- Verify database connection settings
- Check for missing dependencies
- Review application logs

### Database connection fails

- Verify database is running
- Check credentials in application.yml
- Ensure database driver dependency is included
- Check firewall settings

### 404 Not Found

- Verify controller path mapping
- Check if component scanning is configured correctly
- Ensure application context path is correct

### Bean creation error

- Check for circular dependencies
- Verify all required dependencies are autowired
- Review bean scope and lifecycle

This README provides a solid foundation for getting started with Spring Boot development. Refer to SKILL.md for in-depth documentation and EXAMPLES.md for practical code examples.
