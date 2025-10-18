# Spring Boot Development Examples

Comprehensive code examples demonstrating Spring Boot patterns, best practices, and real-world use cases.

## Table of Contents

1. [Basic Spring Boot Application](#1-basic-spring-boot-application)
2. [REST API with CRUD Operations](#2-rest-api-with-crud-operations)
3. [Database Integration with JPA](#3-database-integration-with-jpa)
4. [Custom Queries and Specifications](#4-custom-queries-and-specifications)
5. [Request Validation](#5-request-validation)
6. [Exception Handling](#6-exception-handling)
7. [Authentication with JWT](#7-authentication-with-jwt)
8. [Role-Based Authorization](#8-role-based-authorization)
9. [File Upload and Download](#9-file-upload-and-download)
10. [Caching with Redis](#10-caching-with-redis)
11. [Async Processing](#11-async-processing)
12. [Scheduled Tasks](#12-scheduled-tasks)
13. [Email Service](#13-email-service)
14. [Pagination and Sorting](#14-pagination-and-sorting)
15. [Database Transactions](#15-database-transactions)
16. [Actuator and Monitoring](#16-actuator-and-monitoring)
17. [Docker Deployment](#17-docker-deployment)
18. [API Versioning](#18-api-versioning)

---

## 1. Basic Spring Boot Application

**Application Class:**

```java
package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestTemplate;

@SpringBootApplication
public class DemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
```

**Simple Controller:**

```java
@RestController
@RequestMapping("/api")
public class WelcomeController {

    @Value("${app.name}")
    private String appName;

    @GetMapping("/welcome")
    public Map<String, Object> welcome() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Welcome to " + appName);
        response.put("timestamp", LocalDateTime.now());
        response.put("status", "success");
        return response;
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Application is running");
    }
}
```

**Configuration:**

```yaml
# application.yml
app:
  name: Spring Boot Demo Application

server:
  port: 8080

logging:
  level:
    root: INFO
    com.example.demo: DEBUG
```

---

## 2. REST API with CRUD Operations

**Entity:**

```java
@Entity
@Table(name = "products")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(length = 1000)
    private String description;

    @Column(nullable = false)
    private BigDecimal price;

    @Column(nullable = false)
    private Integer stock;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
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

    // Constructors, getters, and setters
    public Product() {}

    public Product(String name, String description, BigDecimal price, Integer stock) {
        this.name = name;
        this.description = description;
        this.price = price;
        this.stock = stock;
    }

    // Getters and setters omitted for brevity
}
```

**Repository:**

```java
@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByNameContaining(String name);
    List<Product> findByPriceBetween(BigDecimal minPrice, BigDecimal maxPrice);
    List<Product> findByStockLessThan(Integer stock);
}
```

**Service:**

```java
@Service
@Transactional
public class ProductService {

    private static final Logger logger = LoggerFactory.getLogger(ProductService.class);

    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    @Transactional(readOnly = true)
    public List<Product> findAll() {
        logger.debug("Fetching all products");
        return productRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Optional<Product> findById(Long id) {
        logger.debug("Fetching product with id: {}", id);
        return productRepository.findById(id);
    }

    public Product create(Product product) {
        logger.info("Creating new product: {}", product.getName());
        return productRepository.save(product);
    }

    public Optional<Product> update(Long id, Product productDetails) {
        logger.info("Updating product with id: {}", id);
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
        logger.info("Deleting product with id: {}", id);
        return productRepository.findById(id)
            .map(product -> {
                productRepository.delete(product);
                return true;
            })
            .orElse(false);
    }

    @Transactional(readOnly = true)
    public List<Product> searchByName(String name) {
        return productRepository.findByNameContaining(name);
    }

    @Transactional(readOnly = true)
    public List<Product> findByPriceRange(BigDecimal minPrice, BigDecimal maxPrice) {
        return productRepository.findByPriceBetween(minPrice, maxPrice);
    }
}
```

**Controller:**

```java
@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts() {
        List<Product> products = productService.findAll();
        return ResponseEntity.ok(products);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id) {
        return productService.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Product> createProduct(@RequestBody Product product) {
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
            @RequestBody Product product) {
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

    @GetMapping("/search")
    public ResponseEntity<List<Product>> searchProducts(@RequestParam String name) {
        List<Product> products = productService.searchByName(name);
        return ResponseEntity.ok(products);
    }

    @GetMapping("/price-range")
    public ResponseEntity<List<Product>> getProductsByPriceRange(
            @RequestParam BigDecimal min,
            @RequestParam BigDecimal max) {
        List<Product> products = productService.findByPriceRange(min, max);
        return ResponseEntity.ok(products);
    }
}
```

---

## 3. Database Integration with JPA

**Complex Entity with Relationships:**

```java
@Entity
@Table(name = "orders")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "order_number", nullable = false, unique = true)
    private String orderNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> items = new ArrayList<>();

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OrderStatus status;

    @Column(nullable = false)
    private BigDecimal totalAmount;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (orderNumber == null) {
            orderNumber = generateOrderNumber();
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Helper methods
    public void addItem(OrderItem item) {
        items.add(item);
        item.setOrder(this);
        calculateTotal();
    }

    public void removeItem(OrderItem item) {
        items.remove(item);
        item.setOrder(null);
        calculateTotal();
    }

    private void calculateTotal() {
        totalAmount = items.stream()
            .map(OrderItem::getSubtotal)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private String generateOrderNumber() {
        return "ORD-" + System.currentTimeMillis();
    }

    // Getters and setters
}

@Entity
@Table(name = "order_items")
public class OrderItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id")
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(nullable = false)
    private Integer quantity;

    @Column(nullable = false)
    private BigDecimal price;

    @Column(nullable = false)
    private BigDecimal subtotal;

    @PrePersist
    @PreUpdate
    private void calculateSubtotal() {
        if (price != null && quantity != null) {
            subtotal = price.multiply(BigDecimal.valueOf(quantity));
        }
    }

    // Getters and setters
}

@Entity
@Table(name = "customers")
public class Customer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String phone;

    @OneToMany(mappedBy = "customer", cascade = CascadeType.ALL)
    private List<Order> orders = new ArrayList<>();

    // Getters and setters
}

public enum OrderStatus {
    PENDING,
    CONFIRMED,
    PROCESSING,
    SHIPPED,
    DELIVERED,
    CANCELLED
}
```

**Repository with Custom Queries:**

```java
@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    @Query("SELECT o FROM Order o WHERE o.customer.id = :customerId")
    List<Order> findByCustomerId(@Param("customerId") Long customerId);

    @Query("SELECT o FROM Order o WHERE o.status = :status")
    List<Order> findByStatus(@Param("status") OrderStatus status);

    @Query("SELECT o FROM Order o WHERE o.createdAt BETWEEN :startDate AND :endDate")
    List<Order> findByDateRange(
        @Param("startDate") LocalDateTime startDate,
        @Param("endDate") LocalDateTime endDate
    );

    @Query("SELECT o FROM Order o JOIN FETCH o.items WHERE o.id = :id")
    Optional<Order> findByIdWithItems(@Param("id") Long id);
}
```

---

## 4. Custom Queries and Specifications

**Specification Pattern:**

```java
public class ProductSpecification {

    public static Specification<Product> hasName(String name) {
        return (root, query, builder) ->
            name == null ? null : builder.like(
                builder.lower(root.get("name")),
                "%" + name.toLowerCase() + "%"
            );
    }

    public static Specification<Product> hasPriceGreaterThan(BigDecimal price) {
        return (root, query, builder) ->
            price == null ? null : builder.greaterThanOrEqualTo(root.get("price"), price);
    }

    public static Specification<Product> hasPriceLessThan(BigDecimal price) {
        return (root, query, builder) ->
            price == null ? null : builder.lessThanOrEqualTo(root.get("price"), price);
    }

    public static Specification<Product> hasStockGreaterThan(Integer stock) {
        return (root, query, builder) ->
            stock == null ? null : builder.greaterThan(root.get("stock"), stock);
    }
}

@Repository
public interface ProductRepository extends JpaRepository<Product, Long>,
                                         JpaSpecificationExecutor<Product> {
    // Standard methods
}

@Service
public class ProductSearchService {

    private final ProductRepository productRepository;

    public ProductSearchService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    public List<Product> searchProducts(String name, BigDecimal minPrice,
                                       BigDecimal maxPrice, Integer minStock) {
        Specification<Product> spec = Specification.where(null);

        if (name != null) {
            spec = spec.and(ProductSpecification.hasName(name));
        }
        if (minPrice != null) {
            spec = spec.and(ProductSpecification.hasPriceGreaterThan(minPrice));
        }
        if (maxPrice != null) {
            spec = spec.and(ProductSpecification.hasPriceLessThan(maxPrice));
        }
        if (minStock != null) {
            spec = spec.and(ProductSpecification.hasStockGreaterThan(minStock));
        }

        return productRepository.findAll(spec);
    }
}
```

**Native Query Example:**

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    @Query(value = """
        SELECT u.* FROM users u
        LEFT JOIN orders o ON u.id = o.customer_id
        WHERE o.created_at >= :startDate
        GROUP BY u.id
        HAVING COUNT(o.id) >= :minOrders
        """, nativeQuery = true)
    List<User> findActiveCustomers(
        @Param("startDate") LocalDateTime startDate,
        @Param("minOrders") int minOrders
    );

    @Modifying
    @Query(value = "UPDATE users SET last_login = :loginTime WHERE id = :userId",
           nativeQuery = true)
    void updateLastLogin(@Param("userId") Long userId,
                        @Param("loginTime") LocalDateTime loginTime);
}
```

---

## 5. Request Validation

**Entity with Validation:**

```java
@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    private String name;

    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    @Column(unique = true)
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    @Pattern(
        regexp = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=]).*$",
        message = "Password must contain at least one digit, one lowercase, one uppercase, and one special character"
    )
    private String password;

    @NotNull(message = "Age is required")
    @Min(value = 18, message = "Age must be at least 18")
    @Max(value = 120, message = "Age must be less than 120")
    private Integer age;

    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "Invalid phone number")
    private String phone;

    // Getters and setters
}
```

**Custom Validator:**

```java
@Documented
@Constraint(validatedBy = UniqueEmailValidator.class)
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
public @interface UniqueEmail {
    String message() default "Email already exists";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}

@Component
public class UniqueEmailValidator implements ConstraintValidator<UniqueEmail, String> {

    private final UserRepository userRepository;

    public UniqueEmailValidator(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public boolean isValid(String email, ConstraintValidatorContext context) {
        if (email == null) {
            return true;
        }
        return !userRepository.existsByEmail(email);
    }
}

// Usage
public class UserDTO {
    @UniqueEmail
    @Email
    private String email;
}
```

**Validation Groups:**

```java
public interface CreateGroup {}
public interface UpdateGroup {}

@Entity
public class User {

    @Null(groups = CreateGroup.class, message = "ID must be null when creating")
    @NotNull(groups = UpdateGroup.class, message = "ID is required when updating")
    private Long id;

    @NotBlank(groups = {CreateGroup.class, UpdateGroup.class})
    private String name;

    @NotBlank(groups = CreateGroup.class)
    @Null(groups = UpdateGroup.class, message = "Password cannot be updated")
    private String password;
}

@RestController
@RequestMapping("/api/users")
public class UserController {

    @PostMapping
    public ResponseEntity<User> createUser(
            @Validated(CreateGroup.class) @RequestBody User user) {
        // Create logic
    }

    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(
            @PathVariable Long id,
            @Validated(UpdateGroup.class) @RequestBody User user) {
        // Update logic
    }
}
```

---

## 6. Exception Handling

**Custom Exceptions:**

```java
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String resourceName, String fieldName, Object fieldValue) {
        super(String.format("%s not found with %s: '%s'", resourceName, fieldName, fieldValue));
    }
}

public class BadRequestException extends RuntimeException {
    public BadRequestException(String message) {
        super(message);
    }
}

public class UnauthorizedException extends RuntimeException {
    public UnauthorizedException(String message) {
        super(message);
    }
}
```

**Error Response DTO:**

```java
public class ErrorResponse {
    private LocalDateTime timestamp;
    private int status;
    private String error;
    private String message;
    private String path;
    private Map<String, String> validationErrors;

    public ErrorResponse(int status, String error, String message, String path) {
        this.timestamp = LocalDateTime.now();
        this.status = status;
        this.error = error;
        this.message = message;
        this.path = path;
    }

    // Getters and setters
}
```

**Global Exception Handler:**

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFound(
            ResourceNotFoundException ex,
            WebRequest request) {
        logger.error("Resource not found: {}", ex.getMessage());

        ErrorResponse error = new ErrorResponse(
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
        logger.error("Bad request: {}", ex.getMessage());

        ErrorResponse error = new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Bad Request",
            ex.getMessage(),
            request.getDescription(false).replace("uri=", "")
        );

        return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationErrors(
            MethodArgumentNotValidException ex,
            WebRequest request) {
        logger.error("Validation error: {}", ex.getMessage());

        Map<String, String> validationErrors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error ->
            validationErrors.put(error.getField(), error.getDefaultMessage())
        );

        ErrorResponse error = new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Validation Failed",
            "Input validation failed",
            request.getDescription(false).replace("uri=", "")
        );
        error.setValidationErrors(validationErrors);

        return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ErrorResponse> handleDataIntegrityViolation(
            DataIntegrityViolationException ex,
            WebRequest request) {
        logger.error("Data integrity violation: {}", ex.getMessage());

        String message = "Database constraint violation";
        if (ex.getCause() instanceof ConstraintViolationException) {
            message = "Duplicate entry or constraint violation";
        }

        ErrorResponse error = new ErrorResponse(
            HttpStatus.CONFLICT.value(),
            "Conflict",
            message,
            request.getDescription(false).replace("uri=", "")
        );

        return new ResponseEntity<>(error, HttpStatus.CONFLICT);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGlobalException(
            Exception ex,
            WebRequest request) {
        logger.error("Unexpected error: ", ex);

        ErrorResponse error = new ErrorResponse(
            HttpStatus.INTERNAL_SERVER_ERROR.value(),
            "Internal Server Error",
            "An unexpected error occurred",
            request.getDescription(false).replace("uri=", "")
        );

        return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
```

---

## 7. Authentication with JWT

**JWT Utility Class:**

```java
@Component
public class JwtTokenProvider {

    @Value("${app.jwt.secret}")
    private String jwtSecret;

    @Value("${app.jwt.expiration-ms}")
    private long jwtExpirationMs;

    public String generateToken(UserDetails userDetails) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + jwtExpirationMs);

        return Jwts.builder()
            .setSubject(userDetails.getUsername())
            .setIssuedAt(now)
            .setExpiration(expiryDate)
            .signWith(SignatureAlgorithm.HS512, jwtSecret)
            .compact();
    }

    public String getUsernameFromToken(String token) {
        Claims claims = Jwts.parser()
            .setSigningKey(jwtSecret)
            .parseClaimsJws(token)
            .getBody();

        return claims.getSubject();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parser().setSigningKey(jwtSecret).parseClaimsJws(token);
            return true;
        } catch (SignatureException ex) {
            logger.error("Invalid JWT signature");
        } catch (MalformedJwtException ex) {
            logger.error("Invalid JWT token");
        } catch (ExpiredJwtException ex) {
            logger.error("Expired JWT token");
        } catch (UnsupportedJwtException ex) {
            logger.error("Unsupported JWT token");
        } catch (IllegalArgumentException ex) {
            logger.error("JWT claims string is empty");
        }
        return false;
    }
}
```

**JWT Authentication Filter:**

```java
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider tokenProvider;
    private final UserDetailsService userDetailsService;

    public JwtAuthenticationFilter(JwtTokenProvider tokenProvider,
                                  UserDetailsService userDetailsService) {
        this.tokenProvider = tokenProvider;
        this.userDetailsService = userDetailsService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                   HttpServletResponse response,
                                   FilterChain filterChain)
            throws ServletException, IOException {
        try {
            String jwt = getJwtFromRequest(request);

            if (jwt != null && tokenProvider.validateToken(jwt)) {
                String username = tokenProvider.getUsernameFromToken(jwt);

                UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(
                        userDetails,
                        null,
                        userDetails.getAuthorities()
                    );

                authentication.setDetails(
                    new WebAuthenticationDetailsSource().buildDetails(request)
                );

                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception ex) {
            logger.error("Could not set user authentication in security context", ex);
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

**Authentication Controller:**

```java
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final UserService userService;
    private final JwtTokenProvider tokenProvider;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@Valid @RequestBody SignUpRequest signUpRequest) {
        if (userService.existsByEmail(signUpRequest.getEmail())) {
            return ResponseEntity.badRequest()
                .body(new ApiResponse(false, "Email already in use"));
        }

        User user = new User();
        user.setName(signUpRequest.getName());
        user.setEmail(signUpRequest.getEmail());
        user.setPassword(passwordEncoder.encode(signUpRequest.getPassword()));

        User result = userService.save(user);

        return ResponseEntity.ok(new ApiResponse(true, "User registered successfully"));
    }

    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(
                loginRequest.getEmail(),
                loginRequest.getPassword()
            )
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);

        String jwt = tokenProvider.generateToken(
            (UserDetails) authentication.getPrincipal()
        );

        return ResponseEntity.ok(new JwtAuthenticationResponse(jwt));
    }
}
```

---

## 8. Role-Based Authorization

**User with Roles:**

```java
@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String email;
    private String password;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "user_roles",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<Role> roles = new HashSet<>();

    // Getters and setters
}

@Entity
@Table(name = "roles")
public class Role {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private RoleName name;

    // Getters and setters
}

public enum RoleName {
    ROLE_USER,
    ROLE_ADMIN,
    ROLE_MODERATOR
}
```

**UserDetails Implementation:**

```java
public class UserPrincipal implements UserDetails {

    private Long id;
    private String name;
    private String email;
    private String password;
    private Collection<? extends GrantedAuthority> authorities;

    public UserPrincipal(Long id, String name, String email, String password,
                        Collection<? extends GrantedAuthority> authorities) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.password = password;
        this.authorities = authorities;
    }

    public static UserPrincipal create(User user) {
        List<GrantedAuthority> authorities = user.getRoles().stream()
            .map(role -> new SimpleGrantedAuthority(role.getName().name()))
            .collect(Collectors.toList());

        return new UserPrincipal(
            user.getId(),
            user.getName(),
            user.getEmail(),
            user.getPassword(),
            authorities
        );
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }

    // Getters
}
```

**Security Configuration:**

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .cors()
            .and()
            .exceptionHandling()
                .authenticationEntryPoint(jwtAuthenticationEntryPoint)
            .and()
            .sessionManagement()
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .requestMatchers("/api/moderator/**").hasAnyRole("ADMIN", "MODERATOR")
                .anyRequest().authenticated()
            );

        http.addFilterBefore(jwtAuthenticationFilter,
                            UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }
}
```

**Method-Level Security:**

```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping
    public List<User> getAllUsers() {
        return userService.findAll();
    }

    @PreAuthorize("hasRole('USER')")
    @GetMapping("/me")
    public User getCurrentUser(@CurrentUser UserPrincipal currentUser) {
        return userService.findById(currentUser.getId());
    }

    @PreAuthorize("hasRole('ADMIN') or #id == principal.id")
    @PutMapping("/{id}")
    public User updateUser(@PathVariable Long id, @RequestBody User user) {
        return userService.update(id, user);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
        userService.delete(id);
        return ResponseEntity.ok().build();
    }
}
```

---

## 9. File Upload and Download

**File Storage Service:**

```java
@Service
public class FileStorageService {

    private final Path fileStorageLocation;

    @Autowired
    public FileStorageService(@Value("${file.upload-dir}") String uploadDir) {
        this.fileStorageLocation = Paths.get(uploadDir).toAbsolutePath().normalize();

        try {
            Files.createDirectories(this.fileStorageLocation);
        } catch (Exception ex) {
            throw new RuntimeException("Could not create upload directory", ex);
        }
    }

    public String storeFile(MultipartFile file) {
        String fileName = StringUtils.cleanPath(file.getOriginalFilename());

        try {
            if (fileName.contains("..")) {
                throw new BadRequestException("Invalid file path: " + fileName);
            }

            String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
            Path targetLocation = this.fileStorageLocation.resolve(uniqueFileName);
            Files.copy(file.getInputStream(), targetLocation,
                      StandardCopyOption.REPLACE_EXISTING);

            return uniqueFileName;
        } catch (IOException ex) {
            throw new RuntimeException("Could not store file " + fileName, ex);
        }
    }

    public Resource loadFileAsResource(String fileName) {
        try {
            Path filePath = this.fileStorageLocation.resolve(fileName).normalize();
            Resource resource = new UrlResource(filePath.toUri());

            if (resource.exists()) {
                return resource;
            } else {
                throw new ResourceNotFoundException("File", "name", fileName);
            }
        } catch (MalformedURLException ex) {
            throw new ResourceNotFoundException("File", "name", fileName);
        }
    }

    public void deleteFile(String fileName) {
        try {
            Path filePath = this.fileStorageLocation.resolve(fileName).normalize();
            Files.deleteIfExists(filePath);
        } catch (IOException ex) {
            throw new RuntimeException("Could not delete file " + fileName, ex);
        }
    }
}
```

**File Controller:**

```java
@RestController
@RequestMapping("/api/files")
public class FileController {

    private final FileStorageService fileStorageService;

    public FileController(FileStorageService fileStorageService) {
        this.fileStorageService = fileStorageService;
    }

    @PostMapping("/upload")
    public ResponseEntity<UploadFileResponse> uploadFile(
            @RequestParam("file") MultipartFile file) {
        String fileName = fileStorageService.storeFile(file);

        String fileDownloadUri = ServletUriComponentsBuilder.fromCurrentContextPath()
            .path("/api/files/download/")
            .path(fileName)
            .toUriString();

        return ResponseEntity.ok(new UploadFileResponse(
            fileName,
            fileDownloadUri,
            file.getContentType(),
            file.getSize()
        ));
    }

    @PostMapping("/upload-multiple")
    public ResponseEntity<List<UploadFileResponse>> uploadMultipleFiles(
            @RequestParam("files") MultipartFile[] files) {
        List<UploadFileResponse> responses = Arrays.stream(files)
            .map(file -> {
                String fileName = fileStorageService.storeFile(file);
                String fileDownloadUri = ServletUriComponentsBuilder
                    .fromCurrentContextPath()
                    .path("/api/files/download/")
                    .path(fileName)
                    .toUriString();

                return new UploadFileResponse(
                    fileName,
                    fileDownloadUri,
                    file.getContentType(),
                    file.getSize()
                );
            })
            .collect(Collectors.toList());

        return ResponseEntity.ok(responses);
    }

    @GetMapping("/download/{fileName:.+}")
    public ResponseEntity<Resource> downloadFile(
            @PathVariable String fileName,
            HttpServletRequest request) {
        Resource resource = fileStorageService.loadFileAsResource(fileName);

        String contentType = null;
        try {
            contentType = request.getServletContext()
                .getMimeType(resource.getFile().getAbsolutePath());
        } catch (IOException ex) {
            logger.info("Could not determine file type.");
        }

        if (contentType == null) {
            contentType = "application/octet-stream";
        }

        return ResponseEntity.ok()
            .contentType(MediaType.parseMediaType(contentType))
            .header(HttpHeaders.CONTENT_DISPOSITION,
                   "attachment; filename=\"" + resource.getFilename() + "\"")
            .body(resource);
    }

    @DeleteMapping("/{fileName:.+}")
    public ResponseEntity<?> deleteFile(@PathVariable String fileName) {
        fileStorageService.deleteFile(fileName);
        return ResponseEntity.ok(new ApiResponse(true, "File deleted successfully"));
    }
}
```

**Configuration:**

```yaml
# application.yml
file:
  upload-dir: ./uploads

spring:
  servlet:
    multipart:
      enabled: true
      max-file-size: 10MB
      max-request-size: 10MB
```

---

## 10. Caching with Redis

**Dependencies (pom.xml):**

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-cache</artifactId>
</dependency>
```

**Redis Configuration:**

```java
@Configuration
@EnableCaching
public class RedisConfig {

    @Bean
    public RedisTemplate<String, Object> redisTemplate(
            RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);

        Jackson2JsonRedisSerializer<Object> serializer =
            new Jackson2JsonRedisSerializer<>(Object.class);

        ObjectMapper mapper = new ObjectMapper();
        mapper.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.ANY);
        mapper.activateDefaultTyping(
            mapper.getPolymorphicTypeValidator(),
            ObjectMapper.DefaultTyping.NON_FINAL
        );
        serializer.setObjectMapper(mapper);

        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(serializer);
        template.setHashKeySerializer(new StringRedisSerializer());
        template.setHashValueSerializer(serializer);
        template.afterPropertiesSet();

        return template;
    }

    @Bean
    public CacheManager cacheManager(RedisConnectionFactory connectionFactory) {
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(10))
            .serializeKeysWith(
                RedisSerializationContext.SerializationPair.fromSerializer(
                    new StringRedisSerializer()
                )
            )
            .serializeValuesWith(
                RedisSerializationContext.SerializationPair.fromSerializer(
                    new GenericJackson2JsonRedisSerializer()
                )
            )
            .disableCachingNullValues();

        return RedisCacheManager.builder(connectionFactory)
            .cacheDefaults(config)
            .build();
    }
}
```

**Service with Caching:**

```java
@Service
public class ProductService {

    private final ProductRepository productRepository;

    @Cacheable(value = "products", key = "#id")
    public Optional<Product> findById(Long id) {
        logger.info("Fetching product from database: {}", id);
        return productRepository.findById(id);
    }

    @Cacheable(value = "products", unless = "#result.isEmpty()")
    public List<Product> findAll() {
        logger.info("Fetching all products from database");
        return productRepository.findAll();
    }

    @CachePut(value = "products", key = "#product.id")
    public Product save(Product product) {
        logger.info("Saving product and updating cache: {}", product.getId());
        return productRepository.save(product);
    }

    @CacheEvict(value = "products", key = "#id")
    public void delete(Long id) {
        logger.info("Deleting product and evicting from cache: {}", id);
        productRepository.deleteById(id);
    }

    @CacheEvict(value = "products", allEntries = true)
    public void clearCache() {
        logger.info("Clearing all products from cache");
    }
}
```

**Configuration:**

```yaml
spring:
  redis:
    host: localhost
    port: 6379
    password:
    timeout: 2000ms
    jedis:
      pool:
        max-active: 8
        max-idle: 8
        min-idle: 0
```

---

## 11. Async Processing

**Enable Async:**

```java
@Configuration
@EnableAsync
public class AsyncConfig {

    @Bean(name = "taskExecutor")
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("async-");
        executor.initialize();
        return executor;
    }
}
```

**Async Service:**

```java
@Service
public class EmailService {

    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);

    @Async("taskExecutor")
    public CompletableFuture<Void> sendEmail(String to, String subject, String body) {
        logger.info("Sending email to: {}", to);

        try {
            // Simulate email sending
            Thread.sleep(3000);
            logger.info("Email sent successfully to: {}", to);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Error sending email", e);
        }

        return CompletableFuture.completedFuture(null);
    }

    @Async
    public CompletableFuture<String> processLongRunningTask(String data) {
        logger.info("Starting long running task with data: {}", data);

        try {
            Thread.sleep(5000);
            String result = "Processed: " + data;
            logger.info("Task completed: {}", result);
            return CompletableFuture.completedFuture(result);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Task interrupted", e);
            return CompletableFuture.failedFuture(e);
        }
    }
}
```

**Using Async Methods:**

```java
@Service
public class OrderService {

    private final EmailService emailService;
    private final NotificationService notificationService;

    @Transactional
    public Order createOrder(Order order) {
        Order saved = orderRepository.save(order);

        // These run asynchronously
        emailService.sendEmail(
            order.getCustomer().getEmail(),
            "Order Confirmation",
            "Your order has been confirmed"
        );

        notificationService.sendNotification(
            order.getCustomer().getId(),
            "Order placed successfully"
        );

        return saved;
    }

    public void processOrdersAsync(List<Long> orderIds) {
        List<CompletableFuture<Void>> futures = orderIds.stream()
            .map(id -> emailService.sendEmail("customer@example.com", "subject", "body"))
            .collect(Collectors.toList());

        // Wait for all to complete
        CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).join();
    }
}
```

---

## 12. Scheduled Tasks

**Enable Scheduling:**

```java
@Configuration
@EnableScheduling
public class SchedulingConfig {
}
```

**Scheduled Service:**

```java
@Service
public class ScheduledTasks {

    private static final Logger logger = LoggerFactory.getLogger(ScheduledTasks.class);

    private final OrderRepository orderRepository;
    private final EmailService emailService;

    // Execute at fixed rate (every 5 seconds)
    @Scheduled(fixedRate = 5000)
    public void reportCurrentTime() {
        logger.info("The time is now {}", LocalDateTime.now());
    }

    // Execute at fixed delay (5 seconds after previous execution completes)
    @Scheduled(fixedDelay = 5000)
    public void scheduleFixedDelayTask() {
        logger.info("Fixed delay task - {}", LocalDateTime.now());
    }

    // Execute with initial delay
    @Scheduled(fixedRate = 5000, initialDelay = 10000)
    public void scheduleTaskWithInitialDelay() {
        logger.info("Task with initial delay - {}", LocalDateTime.now());
    }

    // Execute using cron expression (every day at 2 AM)
    @Scheduled(cron = "0 0 2 * * ?")
    public void scheduledDailyTask() {
        logger.info("Daily task executed at 2 AM");
        cleanupOldData();
    }

    // Every hour at minute 0
    @Scheduled(cron = "0 0 * * * ?")
    public void hourlyTask() {
        logger.info("Hourly task - {}", LocalDateTime.now());
    }

    // Every Monday at 9 AM
    @Scheduled(cron = "0 0 9 * * MON")
    public void weeklyTask() {
        logger.info("Weekly task - Monday 9 AM");
        generateWeeklyReports();
    }

    // Business day task (Mon-Fri at 10 AM)
    @Scheduled(cron = "0 0 10 * * MON-FRI")
    public void businessDayTask() {
        logger.info("Business day task");
    }

    private void cleanupOldData() {
        LocalDateTime cutoffDate = LocalDateTime.now().minusDays(30);
        orderRepository.deleteByCreatedAtBefore(cutoffDate);
        logger.info("Deleted orders older than 30 days");
    }

    private void generateWeeklyReports() {
        // Generate and send reports
        logger.info("Generating weekly reports");
    }

    // Send daily summary email
    @Scheduled(cron = "0 0 18 * * ?")
    public void sendDailySummary() {
        LocalDate today = LocalDate.now();
        long orderCount = orderRepository.countByCreatedAtBetween(
            today.atStartOfDay(),
            today.plusDays(1).atStartOfDay()
        );

        emailService.sendEmail(
            "admin@example.com",
            "Daily Summary",
            "Today's order count: " + orderCount
        );
    }
}
```

---

## 13. Email Service

**Dependencies:**

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-mail</artifactId>
</dependency>
```

**Email Configuration:**

```yaml
spring:
  mail:
    host: smtp.gmail.com
    port: 587
    username: your-email@gmail.com
    password: your-password
    properties:
      mail:
        smtp:
          auth: true
          starttls:
            enable: true
```

**Email Service:**

```java
@Service
public class EmailService {

    private final JavaMailSender mailSender;
    private final TemplateEngine templateEngine;

    @Value("${spring.mail.username}")
    private String fromEmail;

    // Send simple email
    public void sendSimpleEmail(String to, String subject, String text) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromEmail);
        message.setTo(to);
        message.setSubject(subject);
        message.setText(text);

        mailSender.send(message);
    }

    // Send HTML email
    public void sendHtmlEmail(String to, String subject, String htmlBody)
            throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

        helper.setFrom(fromEmail);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(htmlBody, true);

        mailSender.send(message);
    }

    // Send email with attachment
    public void sendEmailWithAttachment(String to, String subject, String text,
                                       String attachmentPath)
            throws MessagingException, IOException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true);

        helper.setFrom(fromEmail);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(text);

        FileSystemResource file = new FileSystemResource(new File(attachmentPath));
        helper.addAttachment(file.getFilename(), file);

        mailSender.send(message);
    }

    // Send email using Thymeleaf template
    public void sendTemplatedEmail(String to, String subject,
                                  String templateName,
                                  Map<String, Object> variables)
            throws MessagingException {
        Context context = new Context();
        context.setVariables(variables);

        String htmlBody = templateEngine.process(templateName, context);

        sendHtmlEmail(to, subject, htmlBody);
    }

    // Send order confirmation email
    public void sendOrderConfirmation(Order order) throws MessagingException {
        Map<String, Object> variables = new HashMap<>();
        variables.put("customerName", order.getCustomer().getName());
        variables.put("orderNumber", order.getOrderNumber());
        variables.put("items", order.getItems());
        variables.put("totalAmount", order.getTotalAmount());

        sendTemplatedEmail(
            order.getCustomer().getEmail(),
            "Order Confirmation - " + order.getOrderNumber(),
            "order-confirmation",
            variables
        );
    }
}
```

**Thymeleaf Email Template (templates/order-confirmation.html):**

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Order Confirmation</title>
</head>
<body>
    <h1>Order Confirmation</h1>
    <p>Dear <span th:text="${customerName}">Customer</span>,</p>
    <p>Thank you for your order! Your order number is: <strong th:text="${orderNumber}">123</strong></p>

    <h2>Order Items:</h2>
    <table>
        <tr>
            <th>Product</th>
            <th>Quantity</th>
            <th>Price</th>
        </tr>
        <tr th:each="item : ${items}">
            <td th:text="${item.product.name}">Product</td>
            <td th:text="${item.quantity}">1</td>
            <td th:text="${item.price}">$10.00</td>
        </tr>
    </table>

    <p><strong>Total Amount: <span th:text="${totalAmount}">$100.00</span></strong></p>
</body>
</html>
```

---

## 14. Pagination and Sorting

**Service with Pagination:**

```java
@Service
public class ProductService {

    private final ProductRepository productRepository;

    @Transactional(readOnly = true)
    public Page<Product> findAll(int page, int size, String sortBy, String direction) {
        Sort.Direction sortDirection = direction.equalsIgnoreCase("desc")
            ? Sort.Direction.DESC
            : Sort.Direction.ASC;

        Pageable pageable = PageRequest.of(page, size, Sort.by(sortDirection, sortBy));
        return productRepository.findAll(pageable);
    }

    @Transactional(readOnly = true)
    public Page<Product> searchProducts(String name, BigDecimal minPrice,
                                       BigDecimal maxPrice, int page, int size) {
        Specification<Product> spec = Specification.where(null);

        if (name != null) {
            spec = spec.and(ProductSpecification.hasName(name));
        }
        if (minPrice != null) {
            spec = spec.and(ProductSpecification.hasPriceGreaterThan(minPrice));
        }
        if (maxPrice != null) {
            spec = spec.and(ProductSpecification.hasPriceLessThan(maxPrice));
        }

        Pageable pageable = PageRequest.of(page, size, Sort.by("name"));
        return productRepository.findAll(spec, pageable);
    }
}
```

**Controller with Pagination:**

```java
@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final ProductService productService;

    @GetMapping
    public ResponseEntity<Page<Product>> getProducts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "asc") String direction) {
        Page<Product> products = productService.findAll(page, size, sortBy, direction);
        return ResponseEntity.ok(products);
    }

    @GetMapping("/search")
    public ResponseEntity<Page<Product>> searchProducts(
            @RequestParam(required = false) String name,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<Product> products = productService.searchProducts(
            name, minPrice, maxPrice, page, size
        );
        return ResponseEntity.ok(products);
    }
}
```

**Custom Page Response:**

```java
public class PagedResponse<T> {
    private List<T> content;
    private int page;
    private int size;
    private long totalElements;
    private int totalPages;
    private boolean last;

    public PagedResponse(Page<T> page) {
        this.content = page.getContent();
        this.page = page.getNumber();
        this.size = page.getSize();
        this.totalElements = page.getTotalElements();
        this.totalPages = page.getTotalPages();
        this.last = page.isLast();
    }

    // Getters and setters
}

@GetMapping
public ResponseEntity<PagedResponse<Product>> getProducts(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size) {
    Page<Product> productPage = productService.findAll(page, size, "id", "asc");
    return ResponseEntity.ok(new PagedResponse<>(productPage));
}
```

---

## 15. Database Transactions

**Transaction Management:**

```java
@Service
@Transactional
public class OrderService {

    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final EmailService emailService;

    // Read-only transaction
    @Transactional(readOnly = true)
    public Optional<Order> findById(Long id) {
        return orderRepository.findById(id);
    }

    // Default transaction (read-write)
    public Order createOrder(Order order) {
        // Validate stock
        for (OrderItem item : order.getItems()) {
            Product product = productRepository.findById(item.getProduct().getId())
                .orElseThrow(() -> new ResourceNotFoundException(
                    "Product", "id", item.getProduct().getId()
                ));

            if (product.getStock() < item.getQuantity()) {
                throw new BadRequestException("Insufficient stock for product: " + product.getName());
            }

            // Decrease stock
            product.setStock(product.getStock() - item.getQuantity());
            productRepository.save(product);
        }

        // Save order
        Order saved = orderRepository.save(order);

        // Send email (if this fails, transaction rolls back)
        try {
            emailService.sendOrderConfirmation(saved);
        } catch (Exception e) {
            throw new RuntimeException("Failed to send order confirmation", e);
        }

        return saved;
    }

    // Custom transaction settings
    @Transactional(
        propagation = Propagation.REQUIRES_NEW,
        isolation = Isolation.SERIALIZABLE,
        timeout = 30,
        rollbackFor = Exception.class
    )
    public void processPayment(Long orderId, PaymentDetails payment) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new ResourceNotFoundException("Order", "id", orderId));

        // Process payment
        boolean paymentSuccess = paymentGateway.process(payment);

        if (paymentSuccess) {
            order.setStatus(OrderStatus.PAID);
            orderRepository.save(order);
        } else {
            throw new RuntimeException("Payment failed");
        }
    }

    // Programmatic transaction management
    @Autowired
    private TransactionTemplate transactionTemplate;

    public Order createOrderProgrammatic(Order order) {
        return transactionTemplate.execute(status -> {
            try {
                // Update stock
                for (OrderItem item : order.getItems()) {
                    Product product = productRepository.findById(
                        item.getProduct().getId()
                    ).orElseThrow();

                    product.setStock(product.getStock() - item.getQuantity());
                    productRepository.save(product);
                }

                // Save order
                Order saved = orderRepository.save(order);

                // Send email
                emailService.sendOrderConfirmation(saved);

                return saved;
            } catch (Exception e) {
                status.setRollbackOnly();
                throw new RuntimeException("Order creation failed", e);
            }
        });
    }
}
```

---

## 16. Actuator and Monitoring

**Dependencies:**

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

**Configuration:**

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus,env,beans,mappings
      base-path: /actuator
  endpoint:
    health:
      show-details: always
      show-components: always
  metrics:
    export:
      prometheus:
        enabled: true
  info:
    env:
      enabled: true

info:
  app:
    name: Spring Boot Application
    description: My Spring Boot Application
    version: 1.0.0
    encoding: @project.build.sourceEncoding@
    java:
      version: @java.version@
```

**Custom Health Indicator:**

```java
@Component
public class CustomHealthIndicator implements HealthIndicator {

    @Override
    public Health health() {
        // Check some custom health condition
        boolean isHealthy = checkCustomCondition();

        if (isHealthy) {
            return Health.up()
                .withDetail("customService", "Available")
                .withDetail("timestamp", LocalDateTime.now())
                .build();
        }

        return Health.down()
            .withDetail("customService", "Unavailable")
            .withDetail("error", "Service is down")
            .build();
    }

    private boolean checkCustomCondition() {
        // Implement your health check logic
        return true;
    }
}
```

**Custom Metrics:**

```java
@Service
public class OrderService {

    private final MeterRegistry meterRegistry;
    private final Counter orderCounter;
    private final Timer orderTimer;

    public OrderService(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.orderCounter = Counter.builder("orders.created")
            .description("Total number of orders created")
            .register(meterRegistry);
        this.orderTimer = Timer.builder("orders.processing.time")
            .description("Time taken to process orders")
            .register(meterRegistry);
    }

    public Order createOrder(Order order) {
        return orderTimer.record(() -> {
            Order saved = orderRepository.save(order);
            orderCounter.increment();
            return saved;
        });
    }
}
```

**Available Endpoints:**
- `GET /actuator/health` - Application health
- `GET /actuator/info` - Application info
- `GET /actuator/metrics` - Application metrics
- `GET /actuator/env` - Environment properties
- `GET /actuator/beans` - Spring beans
- `GET /actuator/mappings` - Request mappings

---

## 17. Docker Deployment

**Dockerfile:**

```dockerfile
# Build stage
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Run stage
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**docker-compose.yml:**

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/mydb
      - SPRING_DATASOURCE_USERNAME=postgres
      - SPRING_DATASOURCE_PASSWORD=password
    depends_on:
      - db
      - redis
    networks:
      - app-network

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=mydb
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    networks:
      - app-network

volumes:
  postgres-data:

networks:
  app-network:
    driver: bridge
```

**Build and Run:**

```bash
# Build image
docker build -t myapp:latest .

# Run with docker-compose
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop
docker-compose down
```

---

## 18. API Versioning

**URL Versioning:**

```java
@RestController
@RequestMapping("/api/v1/users")
public class UserControllerV1 {

    @GetMapping("/{id}")
    public UserV1 getUser(@PathVariable Long id) {
        return userService.findByIdV1(id);
    }
}

@RestController
@RequestMapping("/api/v2/users")
public class UserControllerV2 {

    @GetMapping("/{id}")
    public UserV2 getUser(@PathVariable Long id) {
        return userService.findByIdV2(id);
    }
}
```

**Header Versioning:**

```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping(value = "/{id}", headers = "X-API-VERSION=1")
    public UserV1 getUserV1(@PathVariable Long id) {
        return userService.findByIdV1(id);
    }

    @GetMapping(value = "/{id}", headers = "X-API-VERSION=2")
    public UserV2 getUserV2(@PathVariable Long id) {
        return userService.findByIdV2(id);
    }
}
```

**Accept Header Versioning:**

```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping(value = "/{id}",
                produces = "application/vnd.myapp.v1+json")
    public UserV1 getUserV1(@PathVariable Long id) {
        return userService.findByIdV1(id);
    }

    @GetMapping(value = "/{id}",
                produces = "application/vnd.myapp.v2+json")
    public UserV2 getUserV2(@PathVariable Long id) {
        return userService.findByIdV2(id);
    }
}
```

---

This examples file provides comprehensive, production-ready code examples for building Spring Boot applications. Each example demonstrates best practices and real-world patterns used in enterprise applications.
