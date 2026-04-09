# FoodRush — Spring Boot Backend Design

**Framework:** Spring Boot 3.x  
**Java:** 21 (LTS)  
**Build tool:** Maven  
**Database:** PostgreSQL 16 + Flyway (migrations)  
**Cache:** Redis 7  
**Auth:** Spring Security + JWT  
**Docs:** Swagger/OpenAPI 3  

---

## 1. Dependencies (pom.xml)

```xml
<dependencies>
  <!-- Web -->
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
  </dependency>

  <!-- Security + JWT -->
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
  </dependency>
  <dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.3</version>
  </dependency>

  <!-- WebSocket -->
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
  </dependency>

  <!-- JPA + PostgreSQL -->
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
  </dependency>
  <dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
  </dependency>

  <!-- Redis -->
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
  </dependency>

  <!-- Validation -->
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
  </dependency>

  <!-- Flyway migrations -->
  <dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
  </dependency>

  <!-- Lombok -->
  <dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
  </dependency>

  <!-- MapStruct (DTO mapping) -->
  <dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct</artifactId>
    <version>1.5.5.Final</version>
  </dependency>

  <!-- Swagger -->
  <dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.3.0</version>
  </dependency>

  <!-- Firebase Admin (Push notifications) -->
  <dependency>
    <groupId>com.google.firebase</groupId>
    <artifactId>firebase-admin</artifactId>
    <version>9.2.0</version>
  </dependency>
</dependencies>
```

---

## 2. application.yml

```yaml
spring:
  application:
    name: foodrush-backend

  datasource:
    url: jdbc:postgresql://${DB_HOST:localhost}:5432/${DB_NAME:foodrush}
    username: ${DB_USERNAME:postgres}
    password: ${DB_PASSWORD:postgres}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5

  jpa:
    hibernate:
      ddl-auto: validate        # Flyway quản lý schema
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true

  flyway:
    enabled: true
    locations: classpath:db/migration

  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: 6379
      password: ${REDIS_PASSWORD:}

  cache:
    type: redis
    redis:
      time-to-live: 300000      # 5 phút

server:
  port: 8080

jwt:
  secret: ${JWT_SECRET:your-256-bit-secret-key-here}
  access-token-expiry: 900       # 15 phút (giây)
  refresh-token-expiry: 2592000  # 30 ngày (giây)

springdoc:
  api-docs:
    path: /api-docs
  swagger-ui:
    path: /swagger-ui.html

logging:
  level:
    com.foodrush: DEBUG
    org.springframework.security: INFO
```

---

## 3. Entities (JPA)

### User.java
```java
@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(unique = true)
    private String phoneNumber;

    @Column(nullable = false)
    private String passwordHash;

    @Column(nullable = false)
    private String firstName;

    @Column(nullable = false)
    private String lastName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserRole role;

    private String profilePictureUrl;
    private String fcmToken;

    @Column(nullable = false)
    private boolean isActive = true;

    @Column(nullable = false)
    private boolean isEmailVerified = false;

    private LocalDateTime lastLoginAt;

    @CreatedDate
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<Address> addresses;
}
```

### Order.java
```java
@Entity
@Table(name = "orders")
@Data
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class Order {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String orderNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "restaurant_id", nullable = false)
    private Restaurant restaurant;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "delivery_agent_id")
    private User deliveryAgent;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OrderStatus status;

    @Type(JsonType.class)
    @Column(columnDefinition = "jsonb")
    private Map<String, Object> deliveryAddressSnapshot;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal subtotal;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal deliveryFee;

    @Column(precision = 12, scale = 2)
    private BigDecimal discountAmount = BigDecimal.ZERO;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal totalAmount;

    private String specialInstructions;
    private LocalDateTime estimatedDeliveryAt;
    private LocalDateTime deliveredAt;
    private LocalDateTime cancelledAt;
    private String cancellationReason;

    @CreatedDate
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    private List<OrderItem> items;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    @OrderBy("createdAt ASC")
    private List<OrderStatusHistory> statusHistory;

    @OneToOne(mappedBy = "order", cascade = CascadeType.ALL)
    private Payment payment;
}
```

---

## 4. Enums

```java
// UserRole.java
public enum UserRole {
    CUSTOMER, RESTAURANT_ADMIN, DELIVERY_AGENT, SYSTEM_ADMIN
}

// OrderStatus.java
public enum OrderStatus {
    PENDING,            // Vừa đặt
    CONFIRMED,          // Nhà hàng xác nhận
    PREPARING,          // Đang chuẩn bị
    READY_FOR_PICKUP,   // Sẵn sàng giao
    PICKED_UP,          // Shipper đã lấy
    ON_THE_WAY,         // Đang giao
    DELIVERED,          // Đã giao
    CANCELLED           // Đã hủy
}

// PaymentMethod.java
public enum PaymentMethod {
    COD, CREDIT_CARD, MOMO, ZALOPAY
}

// PaymentStatus.java
public enum PaymentStatus {
    PENDING, PAID, FAILED, REFUNDED
}
```

---

## 5. Controllers

### AuthController.java
```java
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<AuthResponse> register(
        @Valid @RequestBody RegisterRequest request) {
        return ApiResponse.success(authService.register(request));
    }

    @PostMapping("/login")
    public ApiResponse<AuthResponse> login(
        @Valid @RequestBody LoginRequest request) {
        return ApiResponse.success(authService.login(request));
    }

    @PostMapping("/refresh")
    public ApiResponse<TokenRefreshResponse> refresh(
        @Valid @RequestBody RefreshTokenRequest request) {
        return ApiResponse.success(authService.refreshToken(request));
    }

    @PostMapping("/logout")
    @SecurityRequirement(name = "bearerAuth")
    public ApiResponse<Void> logout(
        @Valid @RequestBody LogoutRequest request) {
        authService.logout(request);
        return ApiResponse.success(null);
    }
}
```

### OrderController.java
```java
@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Orders")
public class OrderController {

    private final OrderService orderService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasRole('CUSTOMER')")
    public ApiResponse<OrderResponse> placeOrder(
        @Valid @RequestBody PlaceOrderRequest request,
        @AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(orderService.placeOrder(request, user.getId()));
    }

    @GetMapping
    @PreAuthorize("hasRole('CUSTOMER')")
    public ApiResponse<PageResponse<OrderSummaryResponse>> getMyOrders(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size,
        @RequestParam(required = false) OrderStatus status,
        @AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(orderService.getOrdersByUser(user.getId(), status, page, size));
    }

    @GetMapping("/{orderId}")
    public ApiResponse<OrderResponse> getOrder(
        @PathVariable Long orderId,
        @AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(orderService.getOrderById(orderId, user.getId()));
    }

    @PatchMapping("/{orderId}/cancel")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ApiResponse<OrderResponse> cancelOrder(
        @PathVariable Long orderId,
        @Valid @RequestBody CancelOrderRequest request,
        @AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(orderService.cancelOrder(orderId, request, user.getId()));
    }

    @PutMapping("/{orderId}/status")
    @PreAuthorize("hasAnyRole('RESTAURANT_ADMIN', 'DELIVERY_AGENT')")
    public ApiResponse<OrderResponse> updateStatus(
        @PathVariable Long orderId,
        @Valid @RequestBody UpdateOrderStatusRequest request,
        @AuthenticationPrincipal UserPrincipal user) {
        return ApiResponse.success(orderService.updateStatus(orderId, request, user.getId()));
    }
}
```

---

## 6. Service — OrderService

```java
@Service
@RequiredArgsConstructor
@Transactional
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final CartService cartService;
    private final UserRepository userRepository;
    private final RestaurantRepository restaurantRepository;
    private final OrderMapper orderMapper;
    private final SimpMessagingTemplate messagingTemplate;
    private final NotificationService notificationService;

    @Override
    public OrderResponse placeOrder(PlaceOrderRequest request, Long userId) {
        Cart cart = cartService.getCartByUserId(userId);

        if (cart.getItems().isEmpty()) {
            throw new BusinessRuleException("CART_001", "Giỏ hàng trống");
        }

        Restaurant restaurant = restaurantRepository.findById(cart.getRestaurantId())
            .orElseThrow(() -> new ResourceNotFoundException("Nhà hàng không tồn tại"));

        // Kiểm tra min order
        BigDecimal subtotal = calculateSubtotal(cart);
        if (subtotal.compareTo(restaurant.getMinOrderAmount()) < 0) {
            throw new BusinessRuleException("ORDER_002",
                "Đơn hàng tối thiểu " + restaurant.getMinOrderAmount() + "đ");
        }

        // Tạo order
        Order order = new Order();
        order.setOrderNumber(generateOrderNumber());
        order.setUser(userRepository.getReferenceById(userId));
        order.setRestaurant(restaurant);
        order.setStatus(OrderStatus.PENDING);
        order.setSubtotal(subtotal);
        order.setDeliveryFee(restaurant.getDeliveryFee());
        order.setTotalAmount(subtotal.add(restaurant.getDeliveryFee()));
        order.setSpecialInstructions(request.getSpecialInstructions());
        order.setDeliveryAddressSnapshot(buildAddressSnapshot(request.getDeliveryAddressId(), userId));

        // Copy cart items → order items
        List<OrderItem> items = cart.getItems().stream()
            .map(ci -> buildOrderItem(ci, order))
            .collect(Collectors.toList());
        order.setItems(items);

        // Ghi lịch sử
        order.setStatusHistory(List.of(
            buildStatusHistory(order, OrderStatus.PENDING, userId)
        ));

        Order saved = orderRepository.save(order);

        // Xóa giỏ hàng
        cartService.clearCart(userId);

        // Gửi WebSocket notification
        notifyOrderStatus(saved);

        return orderMapper.toResponse(saved);
    }

    @Override
    public OrderResponse updateStatus(Long orderId, UpdateOrderStatusRequest request, Long actorId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new ResourceNotFoundException("Đơn hàng không tồn tại"));

        validateStatusTransition(order.getStatus(), request.getStatus());
        order.setStatus(request.getStatus());
        order.getStatusHistory().add(buildStatusHistory(order, request.getStatus(), actorId));

        if (request.getStatus() == OrderStatus.DELIVERED) {
            order.setDeliveredAt(LocalDateTime.now());
        }

        Order saved = orderRepository.save(order);

        // Push WebSocket update
        notifyOrderStatus(saved);

        // Push FCM notification
        notificationService.sendOrderStatusUpdate(saved);

        return orderMapper.toResponse(saved);
    }

    private void notifyOrderStatus(Order order) {
        OrderStatusUpdateDto dto = OrderStatusUpdateDto.builder()
            .orderId(order.getId())
            .orderNumber(order.getOrderNumber())
            .newStatus(order.getStatus())
            .timestamp(LocalDateTime.now())
            .build();

        messagingTemplate.convertAndSendToUser(
            order.getUser().getId().toString(),
            "/queue/orders/" + order.getId() + "/status",
            dto
        );
    }

    private String generateOrderNumber() {
        return "FR-" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"))
               + "-" + String.format("%05d", orderRepository.countByCreatedAtDate(LocalDate.now()) + 1);
    }
}
```

---

## 7. Security Config

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;
    private final UserDetailsServiceImpl userDetailsService;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
            .csrf(AbstractHttpConfigurer::disable)
            .sessionManagement(s -> s.sessionCreationPolicy(STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(
                    "/api/v1/auth/**",
                    "/api/v1/restaurants/**",
                    "/swagger-ui/**",
                    "/api-docs/**",
                    "/ws/**"
                ).permitAll()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)
            .build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config)
        throws Exception {
        return config.getAuthenticationManager();
    }
}
```

---

## 8. WebSocket Config

```java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        registry.enableSimpleBroker("/topic", "/queue");
        registry.setApplicationDestinationPrefixes("/app");
        registry.setUserDestinationPrefix("/user");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws")
            .setAllowedOriginPatterns("*")
            .withSockJS();
    }
}
```

---

## 9. Global Exception Handler

```java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleNotFound(ResourceNotFoundException ex) {
        return ErrorResponse.of("NOT_FOUND", ex.getMessage());
    }

    @ExceptionHandler(BusinessRuleException.class)
    @ResponseStatus(HttpStatus.UNPROCESSABLE_ENTITY)
    public ErrorResponse handleBusinessRule(BusinessRuleException ex) {
        return ErrorResponse.of(ex.getErrorCode(), ex.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleValidation(MethodArgumentNotValidException ex) {
        List<String> errors = ex.getBindingResult().getFieldErrors()
            .stream()
            .map(fe -> fe.getField() + ": " + fe.getDefaultMessage())
            .collect(Collectors.toList());
        return ErrorResponse.of("VALIDATION_ERROR", "Dữ liệu không hợp lệ", errors);
    }

    @ExceptionHandler(AccessDeniedException.class)
    @ResponseStatus(HttpStatus.FORBIDDEN)
    public ErrorResponse handleForbidden(AccessDeniedException ex) {
        return ErrorResponse.of("FORBIDDEN", "Bạn không có quyền thực hiện hành động này");
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ErrorResponse handleGeneric(Exception ex) {
        log.error("Unexpected error", ex);
        return ErrorResponse.of("INTERNAL_ERROR", "Đã xảy ra lỗi hệ thống");
    }
}
```

---

## 10. Docker Compose

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: foodrush
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      DB_HOST: postgres
      DB_NAME: foodrush
      DB_USERNAME: postgres
      DB_PASSWORD: postgres
      REDIS_HOST: redis
      JWT_SECRET: your-super-secret-jwt-key-min-32-chars
    depends_on:
      - postgres
      - redis

volumes:
  postgres_data:
  redis_data:
```

---

## 11. Flyway Migrations (Tóm tắt)

```
V1__create_users_table.sql          → Bảng users + addresses
V2__create_restaurants_table.sql    → Bảng restaurants + operating_hours
V3__create_menu_tables.sql          → Bảng menu_categories + menu_items
V4__create_cart_tables.sql          → Bảng carts + cart_items
V5__create_orders_tables.sql        → Bảng orders + order_items + order_status_history
V6__create_payments_table.sql       → Bảng payments
V7__create_reviews_table.sql        → Bảng reviews
V8__create_refresh_tokens_table.sql → Bảng refresh_tokens
V9__create_indexes.sql              → Tất cả indexes
```
