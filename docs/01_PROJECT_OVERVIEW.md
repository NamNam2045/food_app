# FoodRush — Tổng quan Dự án

**Tên dự án:** FoodRush  
**Ngày:** 02/04/2026  
**Phiên bản:** 1.0  
**Stack:** Flutter (Mobile) + Java Spring Boot (REST API) + PostgreSQL  
**Tác giả:** BA Team

---

## 1. Mục tiêu Dự án

Xây dựng ứng dụng đặt đồ ăn trực tuyến cho phép khách hàng:
- Duyệt danh sách nhà hàng và thực đơn
- Thêm món vào giỏ hàng và đặt đơn
- Thanh toán online
- Theo dõi trạng thái đơn hàng theo thời gian thực
- Đánh giá nhà hàng sau khi nhận hàng

---

## 2. Các bên liên quan (Stakeholders)

| Vai trò | Mô tả |
|---------|-------|
| **CUSTOMER** | Khách hàng đặt đồ ăn qua app |
| **RESTAURANT_ADMIN** | Quản lý nhà hàng, menu, đơn hàng |
| **DELIVERY_AGENT** | Giao hàng, cập nhật trạng thái giao hàng |
| **SYSTEM_ADMIN** | Quản trị hệ thống toàn bộ |

---

## 3. Phạm vi chức năng (Scope)

### MVP (Phase 1)
- [x] Đăng ký / Đăng nhập (JWT)
- [x] Duyệt nhà hàng theo vị trí / danh mục
- [x] Xem thực đơn và chi tiết món ăn
- [x] Giỏ hàng
- [x] Đặt hàng & thanh toán (COD + thẻ)
- [x] Theo dõi đơn hàng (real-time via WebSocket)
- [x] Lịch sử đơn hàng
- [x] Quản lý hồ sơ & địa chỉ

### Phase 2
- [ ] Đánh giá & nhận xét
- [ ] Chương trình khuyến mãi / mã giảm giá
- [ ] Push notification
- [ ] Chat với nhà hàng
- [ ] Bản đồ theo dõi shipper

---

## 4. Kiến trúc Hệ thống

```
┌─────────────────────────────────────────────────────────┐
│                    FLUTTER APP                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐  │
│  │   Auth   │  │Restaurant│  │  Order   │  │ Admin  │  │
│  │  Module  │  │  Module  │  │  Module  │  │ Panel  │  │
│  └──────────┘  └──────────┘  └──────────┘  └────────┘  │
└───────────────────────┬─────────────────────────────────┘
                        │ HTTPS / WSS
┌───────────────────────▼─────────────────────────────────┐
│              SPRING BOOT API (Port 8080)                 │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌──────────────┐  │
│  │  Auth  │  │ Menu   │  │ Order  │  │ Notification │  │
│  │  /api  │  │  /api  │  │  /api  │  │   Service    │  │
│  └────────┘  └────────┘  └────────┘  └──────────────┘  │
│              Spring Security + JWT Filter                 │
└────────┬────────────────┬────────────────────────────────┘
         │                │
┌────────▼──────┐  ┌──────▼──────┐  ┌────────────────────┐
│  PostgreSQL   │  │    Redis    │  │  Firebase FCM      │
│  (Primary DB) │  │   (Cache)   │  │  (Push Notify)     │
└───────────────┘  └─────────────┘  └────────────────────┘
```

---

## 5. Cấu trúc Thư mục

### 5.1 Flutter

```
foodrush_flutter/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/        # API URLs, route names, app constants
│   │   ├── errors/           # Exception & Failure classes
│   │   ├── network/          # Dio client, interceptors, WebSocket
│   │   ├── storage/          # SecureStorage, SharedPreferences
│   │   ├── theme/            # Colors, TextStyles, AppTheme
│   │   └── utils/            # Validators, Formatters, Extensions
│   ├── features/
│   │   ├── auth/             # Login, Register, ForgotPassword
│   │   ├── home/             # Home screen, search
│   │   ├── restaurant/       # Danh sách & chi tiết nhà hàng
│   │   ├── menu/             # Thực đơn, chi tiết món, tùy chọn
│   │   ├── cart/             # Giỏ hàng, Checkout
│   │   ├── order/            # Tracking, Lịch sử, Chi tiết đơn
│   │   ├── profile/          # Hồ sơ, địa chỉ, thanh toán
│   │   ├── notifications/    # Thông báo
│   │   └── admin/            # Quản lý nhà hàng (RESTAURANT_ADMIN)
│   └── shared/
│       ├── widgets/          # Shared UI components
│       └── models/           # Pagination, ApiResponse
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
└── pubspec.yaml
```

### 5.2 Spring Boot

```
foodrush-backend/
├── src/main/java/com/foodrush/
│   ├── FoodRushApplication.java
│   ├── config/               # Security, JWT, WebSocket, Redis, Swagger
│   ├── common/               # DTOs chung, Enums, Exceptions, Utils
│   ├── auth/                 # Authentication & Authorization
│   ├── user/                 # User profile, Addresses
│   ├── restaurant/           # Restaurants, OperatingHours
│   ├── menu/                 # MenuCategory, MenuItem
│   ├── cart/                 # Cart, CartItem
│   ├── order/                # Order, OrderItem, StatusHistory
│   ├── payment/              # Payment processing
│   ├── review/               # Reviews & Ratings
│   └── notification/         # Push notifications
├── src/main/resources/
│   ├── application.yml
│   ├── application-dev.yml
│   ├── application-prod.yml
│   └── db/migration/         # Flyway SQL migrations
├── pom.xml
├── Dockerfile
└── docker-compose.yml
```

---

## 6. Tech Stack & Lý do Lựa chọn

| Layer | Technology | Lý do |
|-------|-----------|-------|
| Mobile | Flutter 3.x | Cross-platform (iOS + Android), hot reload, widget-based UI |
| State Management | BLoC pattern | Predictable state, testable, separation of concerns |
| HTTP Client | Dio | Interceptors, cancellation, FormData support |
| Real-time | STOMP over WebSocket | Order tracking, tích hợp tốt với Spring |
| Backend | Spring Boot 3.x | Mature ecosystem, auto-config, Spring Security tích hợp |
| Auth | JWT + Refresh Token | Stateless, mobile-friendly |
| Database | PostgreSQL 16 | ACID, full-text search, JSON support, geolocation |
| Cache | Redis | Session, rate limiting, cart caching |
| Migration | Flyway | Version-controlled DB schema |
| Docs | Swagger/OpenAPI 3 | Auto-generate từ annotations |
| Notifications | Firebase FCM | Cross-platform push notifications |
| Containerization | Docker + Docker Compose | Dev/prod parity |
