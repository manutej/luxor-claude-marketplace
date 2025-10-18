---
name: spring-boot-development
description: Comprehensive Spring Boot development skill covering auto-configuration, dependency injection, REST APIs, Spring Data, security, and enterprise Java applications
category: backend
tags: [spring-boot, java, rest-api, spring-data, jpa, security, microservices, enterprise]
version: 1.0.0
context7_library: /spring-projects/spring-boot
context7_trust_score: 7.5
---

# Spring Boot Development Skill

This skill provides comprehensive guidance for building modern Spring Boot applications using auto-configuration, dependency injection, REST APIs, Spring Data, Spring Security, and enterprise Java patterns based on official Spring Boot documentation.

## When to Use This Skill

Use this skill when:
- Building enterprise REST APIs and microservices
- Creating web applications with Spring MVC
- Developing data-driven applications with JPA and databases
- Implementing authentication and authorization with Spring Security
- Building production-ready applications with actuator and monitoring
- Creating scalable backend services with Spring Boot
- Migrating from traditional Spring to Spring Boot
- Developing cloud-native applications
- Building event-driven systems with messaging
- Creating batch processing applications

## Core Concepts

### Auto-Configuration

Spring Boot automatically configures your application based on the dependencies you have added to the project. This reduces boilerplate configuration significantly.

**How Auto-Configuration Works:**
```java
@SpringBootApplication
public class MyApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }
}
```

The `@SpringBootApplication` annotation is a combination of:
- `@Configuration`: Tags the class as a source of bean definitions
- `@EnableAutoConfiguration`: Enables Spring Boot's auto-configuration mechanism
- `@ComponentScan`: Enables component scanning in the current package and sub-packages

**Conditional Auto-Configuration:**
```java
@Configuration
@ConditionalOnClass(DataSource.class)
@ConditionalOnProperty(name = "spring.datasource.url")
public class DataSourceAutoConfiguration {

    @Bean
    @ConditionalOnMissingBean
    public DataSource dataSource() {
        return DataSourceBuilder.create().build();
    }
}
```

**Customizing Auto-Configuration:**
```java
// Exclude specific auto-configurations
@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
public class MyApplication {
    // ...
}

// Or in application.properties
// spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration
```

### Dependency Injection

Spring's IoC (Inversion of Control) container manages object creation and dependency injection.

**Constructor Injection (Recommended):**
```java
@Service
public class UserService {

    private final UserRepository userRepository;
    private final EmailService emailService;

    // Constructor injection - recommended approach
    public UserService(UserRepository userRepository, EmailService emailService) {
        this.userRepository = userRepository;
        this.emailService = emailService;
    }

    public User createUser(User user) {
        User saved = userRepository.save(user);
        emailService.sendWelcomeEmail(saved);
        return saved;
    }
}
```

**Field Injection (Not Recommended):**
```java
@Service
public class UserService {

    @Autowired  // Avoid field injection
    private UserRepository userRepository;

    // Difficult to test and creates tight coupling
}
```

**Setter Injection (Optional Dependencies):**
```java
@Service
public class UserService {

    private UserRepository userRepository;
    private EmailService emailService;

    @Autowired
    public void setUserRepository(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Autowired(required = false)
    public void setEmailService(EmailService emailService) {
        this.emailService = emailService;
    }
}
```

**Component Stereotypes:**
```java
@Component  // Generic component
public class MyComponent { }

@Service    // Business logic layer
public class MyService { }

@Repository // Data access layer
public class MyRepository { }

@Controller // Presentation layer (web)
public class MyController { }

@RestController // REST API controller
public class MyRestController { }
```

### Spring Web (REST APIs)

Build RESTful web services with Spring MVC annotations.

**Basic REST Controller:**
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
    public ResponseEntity<User> createUser(@RequestBody @Valid User user) {
        User created = userService.save(user);
        URI location = ServletUriComponentsBuilder
            .fromCurrentRequest()
            .path("/{id}")
            .buildAndExpand(created.getId())
            .toUri();
        return ResponseEntity.created(location).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id,
                                          @RequestBody @Valid User user) {
        return userService.update(id, user)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        if (userService.delete(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
```

**Request Mapping Variations:**
```java
@RestController
@RequestMapping("/api/products")
public class ProductController {

    // Query parameters
    @GetMapping("/search")
    public List<Product> search(@RequestParam String name,
                               @RequestParam(required = false) String category) {
        return productService.search(name, category);
    }

    // Multiple path variables
    @GetMapping("/categories/{categoryId}/products/{productId}")
    public Product getProductInCategory(@PathVariable Long categoryId,
                                       @PathVariable Long productId) {
        return productService.findInCategory(categoryId, productId);
    }

    // Request headers
    @GetMapping("/{id}")
    public Product getProduct(@PathVariable Long id,
                             @RequestHeader("Accept-Language") String language) {
        return productService.find(id, language);
    }

    // Matrix variables
    @GetMapping("/{id}")
    public Product getProductWithMatrix(@PathVariable Long id,
                                       @MatrixVariable Map<String, String> filters) {
        return productService.findWithFilters(id, filters);
    }
}
```

**Response Handling:**
```java
@RestController
@RequestMapping("/api/orders")
public class OrderController {

    // Return different status codes
    @PostMapping
    public ResponseEntity<Order> createOrder(@RequestBody Order order) {
        Order created = orderService.create(order);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    // Custom headers
    @GetMapping("/{id}")
    public ResponseEntity<Order> getOrder(@PathVariable Long id) {
        Order order = orderService.findById(id);
        return ResponseEntity.ok()
            .header("X-Order-Version", order.getVersion().toString())
            .body(order);
    }

    // No content response
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteOrder(@PathVariable Long id) {
        orderService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
```

### Spring Data JPA

Spring Data JPA provides repository abstractions for database access.

**Entity Definition:**
```java
@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String name;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Order> orders = new ArrayList<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "department_id")
    private Department department;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Getters and setters
}
```

**Repository Interface:**
```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    // Query method - Spring Data generates implementation
    Optional<User> findByEmail(String email);

    List<User> findByNameContaining(String name);

    List<User> findByDepartmentId(Long departmentId);

    // Custom JPQL query
    @Query("SELECT u FROM User u WHERE u.email = ?1")
    Optional<User> findByEmailQuery(String email);

    // Named parameters
    @Query("SELECT u FROM User u WHERE u.name LIKE %:name% AND u.department.id = :deptId")
    List<User> searchByNameAndDepartment(@Param("name") String name,
                                        @Param("deptId") Long deptId);

    // Native SQL query
    @Query(value = "SELECT * FROM users WHERE email = ?1", nativeQuery = true)
    Optional<User> findByEmailNative(String email);

    // Modifying query
    @Modifying
    @Query("UPDATE User u SET u.name = :name WHERE u.id = :id")
    int updateUserName(@Param("id") Long id, @Param("name") String name);

    // Pagination and sorting
    Page<User> findByDepartmentId(Long departmentId, Pageable pageable);

    List<User> findByNameContaining(String name, Sort sort);
}
```

**Repository Usage:**
```java
@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }

    public User save(User user) {
        return userRepository.save(user);
    }

    public List<User> findAll() {
        return userRepository.findAll();
    }

    public Page<User> findAll(int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("name"));
        return userRepository.findAll(pageable);
    }

    public boolean delete(Long id) {
        if (userRepository.existsById(id)) {
            userRepository.deleteById(id);
            return true;
        }
        return false;
    }
}
```

**Relationships:**
```java
// One-to-Many
@Entity
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> items = new ArrayList<>();
}

// Many-to-Many
@Entity
public class Student {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToMany
    @JoinTable(
        name = "student_course",
        joinColumns = @JoinColumn(name = "student_id"),
        inverseJoinColumns = @JoinColumn(name = "course_id")
    )
    private Set<Course> courses = new HashSet<>();
}
```

### Configuration

Spring Boot uses `application.properties` or `application.yml` for configuration.

**Application Properties:**
```properties
# Server configuration
server.port=8080
server.servlet.context-path=/api

# Database configuration
spring.datasource.url=jdbc:postgresql://localhost:5432/mydb
spring.datasource.username=user
spring.datasource.password=password
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA configuration
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# Logging
logging.level.root=INFO
logging.level.com.example=DEBUG
logging.level.org.springframework.web=DEBUG
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n

# Custom properties
app.name=My Application
app.version=1.0.0
```

**Application YAML:**
```yaml
server:
  port: 8080
  servlet:
    context-path: /api

spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: user
    password: password
    driver-class-name: org.postgresql.Driver

  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: true
    properties:
      hibernate:
        format_sql: true
        dialect: org.hibernate.dialect.PostgreSQLDialect

logging:
  level:
    root: INFO
    com.example: DEBUG
    org.springframework.web: DEBUG

app:
  name: My Application
  version: 1.0.0
```

**Configuration Properties Class:**
```java
@Configuration
@ConfigurationProperties(prefix = "app")
public class AppConfig {

    private String name;
    private String version;
    private Security security = new Security();

    public static class Security {
        private int tokenExpiration = 3600;
        private String secretKey;

        // Getters and setters
    }

    // Getters and setters
}

// Usage
@Service
public class MyService {

    private final AppConfig appConfig;

    public MyService(AppConfig appConfig) {
        this.appConfig = appConfig;
    }

    public void printConfig() {
        System.out.println("App: " + appConfig.getName());
        System.out.println("Version: " + appConfig.getVersion());
    }
}
```

**Environment-Specific Configuration:**
```properties
# application.properties (default)
spring.profiles.active=dev

# application-dev.properties
spring.datasource.url=jdbc:postgresql://localhost:5432/mydb_dev
logging.level.root=DEBUG

# application-prod.properties
spring.datasource.url=jdbc:postgresql://prod-server:5432/mydb_prod
logging.level.root=WARN
```

**Profile-Specific Beans:**
```java
@Configuration
public class DatabaseConfig {

    @Bean
    @Profile("dev")
    public DataSource devDataSource() {
        return new EmbeddedDatabaseBuilder()
            .setType(EmbeddedDatabaseType.H2)
            .build();
    }

    @Bean
    @Profile("prod")
    public DataSource prodDataSource() {
        return DataSourceBuilder.create().build();
    }
}
```

### Spring Security

Implement authentication and authorization in your application.

**Basic Security Configuration:**
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .requestMatchers("/api/users/**").hasAnyRole("USER", "ADMIN")
                .anyRequest().authenticated()
            )
            .httpBasic();

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

**In-Memory Authentication:**
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public UserDetailsService userDetailsService(PasswordEncoder passwordEncoder) {
        UserDetails user = User.builder()
            .username("user")
            .password(passwordEncoder.encode("password"))
            .roles("USER")
            .build();

        UserDetails admin = User.builder()
            .username("admin")
            .password(passwordEncoder.encode("admin"))
            .roles("ADMIN", "USER")
            .build();

        return new InMemoryUserDetailsManager(user, admin);
    }
}
```

**Database Authentication:**
```java
@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    public CustomUserDetailsService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(username)
            .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));

        return org.springframework.security.core.userdetails.User.builder()
            .username(user.getEmail())
            .password(user.getPassword())
            .roles(user.getRoles().toArray(new String[0]))
            .build();
    }
}

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final CustomUserDetailsService userDetailsService;

    public SecurityConfig(CustomUserDetailsService userDetailsService) {
        this.userDetailsService = userDetailsService;
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider(PasswordEncoder passwordEncoder) {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(userDetailsService);
        provider.setPasswordEncoder(passwordEncoder);
        return provider;
    }
}
```

**JWT Authentication:**
```java
@Component
public class JwtTokenProvider {

    @Value("${app.security.jwt.secret}")
    private String jwtSecret;

    @Value("${app.security.jwt.expiration}")
    private int jwtExpiration;

    public String generateToken(Authentication authentication) {
        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();

        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + jwtExpiration);

        return Jwts.builder()
            .setSubject(Long.toString(userPrincipal.getId()))
            .setIssuedAt(now)
            .setExpiration(expiryDate)
            .signWith(SignatureAlgorithm.HS512, jwtSecret)
            .compact();
    }

    public Long getUserIdFromJWT(String token) {
        Claims claims = Jwts.parser()
            .setSigningKey(jwtSecret)
            .parseClaimsJws(token)
            .getBody();

        return Long.parseLong(claims.getSubject());
    }

    public boolean validateToken(String authToken) {
        try {
            Jwts.parser().setSigningKey(jwtSecret).parseClaimsJws(authToken);
            return true;
        } catch (SignatureException | MalformedJwtException | ExpiredJwtException |
                 UnsupportedJwtException | IllegalArgumentException ex) {
            return false;
        }
    }
}

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider tokenProvider;
    private final CustomUserDetailsService customUserDetailsService;

    public JwtAuthenticationFilter(JwtTokenProvider tokenProvider,
                                  CustomUserDetailsService customUserDetailsService) {
        this.tokenProvider = tokenProvider;
        this.customUserDetailsService = customUserDetailsService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                   HttpServletResponse response,
                                   FilterChain filterChain) throws ServletException, IOException {
        try {
            String jwt = getJwtFromRequest(request);

            if (jwt != null && tokenProvider.validateToken(jwt)) {
                Long userId = tokenProvider.getUserIdFromJWT(jwt);

                UserDetails userDetails = customUserDetailsService.loadUserById(userId);
                UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(
                        userDetails, null, userDetails.getAuthorities()
                    );

                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception ex) {
            logger.error("Could not set user authentication", ex);
        }

        filterChain.doFilter(request, response);
    }

    private String getJwtFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
```

## API Reference

### Common Annotations

**Core Spring Annotations:**
- `@SpringBootApplication`: Main application class
- `@Component`: Generic component
- `@Service`: Service layer component
- `@Repository`: Data access layer component
- `@Configuration`: Configuration class
- `@Bean`: Bean definition method
- `@Autowired`: Dependency injection
- `@Value`: Inject property values
- `@Profile`: Conditional beans based on profiles

**Web Annotations:**
- `@RestController`: REST API controller
- `@Controller`: MVC controller
- `@RequestMapping`: Map HTTP requests
- `@GetMapping`: Map GET requests
- `@PostMapping`: Map POST requests
- `@PutMapping`: Map PUT requests
- `@DeleteMapping`: Map DELETE requests
- `@PatchMapping`: Map PATCH requests
- `@PathVariable`: Extract path variables
- `@RequestParam`: Extract query parameters
- `@RequestBody`: Extract request body
- `@RequestHeader`: Extract request headers
- `@ResponseStatus`: Set response status

**Data Annotations:**
- `@Entity`: JPA entity
- `@Table`: Table mapping
- `@Id`: Primary key
- `@GeneratedValue`: Auto-generated values
- `@Column`: Column mapping
- `@OneToOne`: One-to-one relationship
- `@OneToMany`: One-to-many relationship
- `@ManyToOne`: Many-to-one relationship
- `@ManyToMany`: Many-to-many relationship
- `@JoinColumn`: Join column
- `@JoinTable`: Join table

**Validation Annotations:**
- `@Valid`: Enable validation
- `@NotNull`: Field cannot be null
- `@NotEmpty`: Field cannot be empty
- `@NotBlank`: Field cannot be blank
- `@Size`: String or collection size
- `@Min`: Minimum value
- `@Max`: Maximum value
- `@Email`: Email format
- `@Pattern`: Regex pattern

**Transaction Annotations:**
- `@Transactional`: Enable transaction management
- `@Transactional(readOnly = true)`: Read-only transaction

**Security Annotations:**
- `@EnableWebSecurity`: Enable security
- `@PreAuthorize`: Method-level authorization
- `@PostAuthorize`: Post-method authorization
- `@Secured`: Role-based access

**Async and Scheduling:**
- `@EnableAsync`: Enable async processing
- `@Async`: Async method
- `@EnableScheduling`: Enable scheduling
- `@Scheduled`: Scheduled method

## Workflow Patterns

### REST API Design Pattern

**Complete CRUD REST API:**
```java
// Entity
@Entity
@Table(name = "products")
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Name is required")
    private String name;

    @NotBlank(message = "Description is required")
    private String description;

    @NotNull(message = "Price is required")
    @Min(value = 0, message = "Price must be positive")
    private BigDecimal price;

    @NotNull(message = "Stock is required")
    @Min(value = 0, message = "Stock must be positive")
    private Integer stock;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Getters and setters
}

// Repository
@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByNameContaining(String name);
    List<Product> findByPriceBetween(BigDecimal minPrice, BigDecimal maxPrice);
}

// Service
@Service
@Transactional
public class ProductService {

    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    @Transactional(readOnly = true)
    public Page<Product> findAll(Pageable pageable) {
        return productRepository.findAll(pageable);
    }

    @Transactional(readOnly = true)
    public Optional<Product> findById(Long id) {
        return productRepository.findById(id);
    }

    public Product create(Product product) {
        return productRepository.save(product);
    }

    public Optional<Product> update(Long id, Product productDetails) {
        return productRepository.findById(id)
            .map(product -> {
                product.setName(productDetails.getName());
                product.setDescription(productDetails.getDescription());
                product.setPrice(productDetails.getPrice());
                product.setStock(productDetails.getStock());
                return productRepository.save(product);
            });
    }

    public boolean delete(Long id) {
        return productRepository.findById(id)
            .map(product -> {
                productRepository.delete(product);
                return true;
            })
            .orElse(false);
    }
}

// Controller
@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    public Page<Product> getAllProducts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id") String sortBy) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(sortBy));
        return productService.findAll(pageable);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id) {
        return productService.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Product> createProduct(@Valid @RequestBody Product product) {
        Product created = productService.create(product);
        URI location = ServletUriComponentsBuilder
            .fromCurrentRequest()
            .path("/{id}")
            .buildAndExpand(created.getId())
            .toUri();
        return ResponseEntity.created(location).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(
            @PathVariable Long id,
            @Valid @RequestBody Product product) {
        return productService.update(id, product)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        if (productService.delete(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
```

### Exception Handling Pattern

**Global Exception Handler:**
```java
// Custom exceptions
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}

public class BadRequestException extends RuntimeException {
    public BadRequestException(String message) {
        super(message);
    }
}

// Error response
public class ErrorResponse {
    private LocalDateTime timestamp;
    private int status;
    private String error;
    private String message;
    private String path;

    // Constructors, getters, setters
}

// Global exception handler
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFound(
            ResourceNotFoundException ex,
            WebRequest request) {
        ErrorResponse error = new ErrorResponse(
            LocalDateTime.now(),
            HttpStatus.NOT_FOUND.value(),
            "Not Found",
            ex.getMessage(),
            request.getDescription(false).replace("uri=", "")
        );
        return new ResponseEntity<>(error, HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(BadRequestException.class)
    public ResponseEntity<ErrorResponse> handleBadRequest(
            BadRequestException ex,
            WebRequest request) {
        ErrorResponse error = new ErrorResponse(
            LocalDateTime.now(),
            HttpStatus.BAD_REQUEST.value(),
            "Bad Request",
            ex.getMessage(),
            request.getDescription(false).replace("uri=", "")
        );
        return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidationErrors(
            MethodArgumentNotValidException ex) {
        Map<String, Object> errors = new HashMap<>();
        errors.put("timestamp", LocalDateTime.now());
        errors.put("status", HttpStatus.BAD_REQUEST.value());

        Map<String, String> fieldErrors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error ->
            fieldErrors.put(error.getField(), error.getDefaultMessage())
        );
        errors.put("errors", fieldErrors);

        return new ResponseEntity<>(errors, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGlobalException(
            Exception ex,
            WebRequest request) {
        ErrorResponse error = new ErrorResponse(
            LocalDateTime.now(),
            HttpStatus.INTERNAL_SERVER_ERROR.value(),
            "Internal Server Error",
            ex.getMessage(),
            request.getDescription(false).replace("uri=", "")
        );
        return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
```

### Database Integration Pattern

**Complete Database Setup:**
```java
// application.yml
/*
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: user
    password: password
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
*/

// Flyway migrations (db/migration/V1__Create_users_table.sql)
/*
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_users_email ON users(email);
*/

// Entity with auditing
@Entity
@Table(name = "users")
@EntityListeners(AuditingEntityListener.class)
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String password;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // Getters and setters
}

// Enable JPA auditing
@Configuration
@EnableJpaAuditing
public class JpaConfig {
}
```

### Testing Pattern

**Unit Tests:**
```java
@SpringBootTest
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testFindById_Success() {
        User user = new User();
        user.setId(1L);
        user.setEmail("test@example.com");

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        Optional<User> result = userService.findById(1L);

        assertTrue(result.isPresent());
        assertEquals("test@example.com", result.get().getEmail());
        verify(userRepository, times(1)).findById(1L);
    }

    @Test
    void testFindById_NotFound() {
        when(userRepository.findById(1L)).thenReturn(Optional.empty());

        Optional<User> result = userService.findById(1L);

        assertFalse(result.isPresent());
    }
}
```

**Integration Tests:**
```java
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class UserControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Test
    void testCreateUser_Success() throws Exception {
        User user = new User();
        user.setEmail("test@example.com");
        user.setName("Test User");

        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(user)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.email").value("test@example.com"))
            .andExpect(jsonPath("$.name").value("Test User"));
    }

    @Test
    void testGetUser_Success() throws Exception {
        User user = new User();
        user.setEmail("test@example.com");
        user.setName("Test User");
        User saved = userRepository.save(user);

        mockMvc.perform(get("/api/users/" + saved.getId()))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.id").value(saved.getId()))
            .andExpect(jsonPath("$.email").value("test@example.com"));
    }

    @Test
    void testGetUser_NotFound() throws Exception {
        mockMvc.perform(get("/api/users/999"))
            .andExpect(status().isNotFound());
    }
}
```

## Best Practices

### 1. Use Constructor Injection

Constructor injection is the recommended approach for dependency injection.

```java
// Good - Constructor injection
@Service
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;

    public UserService(UserRepository userRepository, EmailService emailService) {
        this.userRepository = userRepository;
        this.emailService = emailService;
    }
}

// Bad - Field injection
@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;
}
```

### 2. Use DTOs for API Requests/Responses

Don't expose entities directly through REST APIs.

```java
// DTO
public class UserDTO {
    private Long id;
    private String email;
    private String name;

    // No password field exposed
    // Getters and setters
}

// Mapper
@Component
public class UserMapper {
    public UserDTO toDTO(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setEmail(user.getEmail());
        dto.setName(user.getName());
        return dto;
    }

    public User toEntity(UserDTO dto) {
        User user = new User();
        user.setEmail(dto.getEmail());
        user.setName(dto.getName());
        return user;
    }
}

// Controller
@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;
    private final UserMapper userMapper;

    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getUser(@PathVariable Long id) {
        return userService.findById(id)
            .map(userMapper::toDTO)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
}
```

### 3. Use Validation

Always validate input data.

```java
// Entity with validation
@Entity
public class User {
    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;

    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    private String name;

    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;
}

// Controller
@PostMapping
public ResponseEntity<User> createUser(@Valid @RequestBody User user) {
    // Validation happens automatically
    return ResponseEntity.ok(userService.save(user));
}
```

### 4. Use Transactions Properly

Mark service methods with appropriate transaction settings.

```java
@Service
@Transactional
public class OrderService {

    @Transactional(readOnly = true)
    public List<Order> findAll() {
        return orderRepository.findAll();
    }

    @Transactional
    public Order createOrder(Order order) {
        // Multiple database operations in one transaction
        Order saved = orderRepository.save(order);
        inventoryService.decreaseStock(order.getItems());
        emailService.sendOrderConfirmation(saved);
        return saved;
    }
}
```

### 5. Use Pagination

Always paginate large datasets.

```java
@GetMapping
public Page<Product> getProducts(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size,
        @RequestParam(defaultValue = "id") String sortBy) {
    Pageable pageable = PageRequest.of(page, size, Sort.by(sortBy));
    return productService.findAll(pageable);
}
```

### 6. Handle Exceptions Globally

Use `@RestControllerAdvice` for centralized exception handling.

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse(ex.getMessage()));
    }
}
```

### 7. Use Logging

Implement proper logging throughout your application.

```java
@Service
public class UserService {
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);

    public User createUser(User user) {
        logger.info("Creating user with email: {}", user.getEmail());
        try {
            User saved = userRepository.save(user);
            logger.info("User created successfully with id: {}", saved.getId());
            return saved;
        } catch (Exception e) {
            logger.error("Error creating user: {}", e.getMessage(), e);
            throw e;
        }
    }
}
```

### 8. Secure Your Endpoints

Implement proper authentication and authorization.

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer().jwt();

        return http.build();
    }
}
```

### 9. Use Database Migrations

Use Flyway or Liquibase for database version control.

```sql
-- V1__Create_users_table.sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL
);

-- V2__Add_password_column.sql
ALTER TABLE users ADD COLUMN password VARCHAR(255);
```

### 10. Monitor Your Application

Use Spring Boot Actuator for monitoring.

```properties
# application.properties
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=always
```

## Examples

See EXAMPLES.md for detailed code examples including:
- Basic Spring Boot Application
- REST API with CRUD Operations
- Database Integration with JPA
- Custom Queries and Specifications
- Request Validation
- Exception Handling
- Authentication with JWT
- Role-Based Authorization
- File Upload/Download
- Caching with Redis
- Async Processing
- Scheduled Tasks
- Multiple Database Configuration
- Actuator and Monitoring
- Docker Deployment

## Summary

This Spring Boot development skill covers:

1. **Auto-Configuration**: Automatic configuration based on dependencies
2. **Dependency Injection**: IoC container, constructor injection, component stereotypes
3. **REST APIs**: Controllers, request mapping, response handling
4. **Spring Data JPA**: Entities, repositories, relationships, queries
5. **Configuration**: Properties, YAML, profiles, custom properties
6. **Security**: Authentication, authorization, JWT, role-based access
7. **Exception Handling**: Global exception handling, custom exceptions
8. **Testing**: Unit tests, integration tests, MockMvc
9. **Best Practices**: DTOs, validation, transactions, pagination, logging
10. **Production Ready**: Actuator, monitoring, database migrations, deployment

The patterns and examples are based on official Spring Boot documentation (Trust Score: 7.5) and represent modern enterprise Java development practices.
