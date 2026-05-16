# FoodRush Backend — Spring Boot REST API

## Tech Stack
- Java 17 + Spring Boot 3.2
- PostgreSQL 16 (JPA + Flyway migrations)
- Redis 7 (token blacklist, cache)
- JWT (access 15 phút + refresh 30 ngày)
- WebSocket STOMP (order tracking real-time)
- Swagger/OpenAPI 3

## Chạy với Docker (khuyến nghị)

```bash
docker-compose up -d
```

App sẽ khởi động tại: http://localhost:8080  
Swagger UI: http://localhost:8080/swagger-ui.html

Lưu ý:
- Hãy chạy bằng `docker-compose` (không chạy `docker run` trực tiếp cho app image), vì app cần env `DB_HOST=postgres`, `REDIS_HOST=redis`.
- Ảnh upload sẽ được lưu trong volume Docker `uploads_data` và được serve qua đường dẫn `/uploads/**`.

## Chạy local (cần PostgreSQL và Redis đang chạy)

```bash
# 1. Chạy database
docker-compose up -d postgres redis

# 2. Chạy app
./mvnw spring-boot:run
```

## Cấu trúc API

| Module | Base Path |
|--------|-----------|
| Auth | `/api/v1/auth` |
| Users | `/api/v1/users` |
| Restaurants | `/api/v1/restaurants` |
| Menu | `/api/v1/restaurants/{id}/menu` |
| Cart | `/api/v1/cart` |
| Orders | `/api/v1/orders` |
| Reviews | `/api/v1/reviews` |
| Payments | `/api/v1/payments` |

## WebSocket

- Endpoint: `ws://localhost:8080/ws`
- Protocol: STOMP
- Subscribe: `/user/queue/orders/{orderId}/status`

## Cấu trúc Package

```
com.foodrush/
├── FoodRushApplication.java
├── config/          # Security, WebSocket, Redis, Swagger
├── common/          # ApiResponse, PageResponse, Enums, Exceptions, JwtUtil
├── auth/            # Register, Login, JWT Filter
├── user/            # Profile, Addresses
├── restaurant/      # Restaurants, OperatingHours
├── menu/            # MenuCategory, MenuItem
├── cart/            # Cart, CartItem
├── order/           # Order placement, tracking, status updates
├── payment/         # Payment records
└── review/          # Reviews & ratings
```

## Database Migrations (Flyway)

```
V1 → users, addresses
V2 → restaurants, operating_hours
V3 → menu_categories, menu_items
V4 → carts, cart_items
V5 → orders, order_items, order_status_history
V6 → payments
V7 → reviews
```

## Biến môi trường

| Variable | Default | Mô tả |
|----------|---------|-------|
| DB_HOST | localhost | PostgreSQL host |
| DB_NAME | foodrush | Database name |
| DB_USERNAME | postgres | DB user |
| DB_PASSWORD | postgres | DB password |
| REDIS_HOST | localhost | Redis host |
| APP_UPLOAD_DIR | ./uploads | Thư mục lưu ảnh upload |
| JWT_SECRET | (hardcoded dev key) | JWT signing key (≥32 chars) |
