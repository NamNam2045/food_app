# TÀI LIỆU THIẾT KẾ HỆ THỐNG — FoodRush

> **Phạm vi:** Tập trung phân tích **App Flutter** (mobile client). Phần Backend Spring Boot chỉ trình bày phần quan trọng phục vụ vận hành app.
> **Nguồn:** `/mnt/e/food-app/food_app/` (63 file Dart) + `/mnt/e/food-app/server_app_foot/` (141 file Java, 11 Flyway migration).
> **Stack:** Flutter 3.9.2 + Spring Boot 3.2.4 + PostgreSQL + Redis + Firebase FCM + WebSocket STOMP.

---

## Mục lục

1. [Tổng quan hệ thống](#1-tổng-quan-hệ-thống)
2. [Phân tích cấu trúc source code (App Flutter)](#2-phân-tích-cấu-trúc-source-code-app-flutter)
3. [Phân tích Database](#3-phân-tích-database)
4. [ERD (DBML)](#4-erd-dbml)
5. [Use Case](#5-use-case)
6. [Sequence Diagram](#6-sequence-diagram-syntax-sequencediagramorg)
7. [Class Diagram (App Flutter)](#7-class-diagram-app-flutter)
8. [Luồng nguyên lý hoạt động](#8-luồng-nguyên-lý-hoạt-động)
9. [Phân tích nghiệp vụ](#9-phân-tích-nghiệp-vụ)
10. [Plan thực hiện công việc](#10-plan-thực-hiện-công-việc)

---

## 1. Tổng quan hệ thống

### 1.1. Hệ thống làm gì

**FoodRush** là nền tảng đặt đồ ăn trực tuyến cho thị trường Việt Nam. Toàn bộ vòng đời nghiệp vụ chính được phục vụ bởi **app Flutter dành cho khách hàng**:

```
Duyệt nhà hàng → Xem menu → Thêm giỏ → Đặt hàng → Thanh toán
       → Theo dõi đơn real-time → Nhận hàng → Đánh giá
```

App còn có khu vực **admin (RESTAURANT_ADMIN)** ngay trong Flutter để chủ nhà hàng quản lý menu và đơn (xem mục 2.4).

### 1.2. Người dùng chính của app Flutter

| Role (từ `auth_state.dart`) | Mô tả | Khu vực trong app |
|---|---|---|
| `CUSTOMER` | Khách hàng đầu cuối | `/home`, `/restaurants/**`, `/cart`, `/checkout`, `/orders/**`, `/profile/**` |
| `RESTAURANT_ADMIN` | Chủ/nhân viên nhà hàng | `/admin/**` (xem `app.dart:136-138`) |
| `DELIVERY_AGENT` / `SYSTEM_ADMIN` | Có tài khoản nhưng dùng web Thymeleaf phía server, không có UI trên Flutter |

### 1.3. Module chính trong app Flutter (`food_app/lib/features/`)

| Feature | Trách nhiệm |
|---|---|
| `auth` | Onboarding, Splash, Login, Register, Forgot password |
| `home` | Bottom-navigation shell, 4 tab (Khám phá, Tìm kiếm, Đơn hàng, Hồ sơ) |
| `discover` | Danh sách + filter nhà hàng |
| `search` | Tìm kiếm nhà hàng/món |
| `restaurant` | Chi tiết nhà hàng + menu + item detail |
| `cart` | Giỏ hàng |
| `order` | Checkout, lịch sử, chi tiết, **tracking real-time** |
| `profile` | Hồ sơ, địa chỉ, payment methods, support pages |
| `review` | Đánh giá sau khi đơn `DELIVERED` |
| `notification` | Danh sách thông báo (dùng FCM background message) |
| `admin` | Quản lý menu + đơn cho `RESTAURANT_ADMIN` |

### 1.4. Kiến trúc tổng thể

```
┌────────────────────────────────────────────────────────────────┐
│                    FLUTTER APP (food_app)                       │
│ ┌────────────────────────────────────────────────────────────┐ │
│ │ Presentation (Screen / Widget — Material 3)                 │ │
│ │   ↓ uses                                                    │ │
│ │ Logic (Cubit + State — flutter_bloc 8.1.6)                  │ │
│ │   ↓ uses                                                    │ │
│ │ Data (Repository → Model fromJson)                          │ │
│ │   ↓ uses                                                    │ │
│ │ Core: ApiClient (Dio 5.9.0) │ TokenStorage │ Routing        │ │
│ └────────────────────────────────────────────────────────────┘ │
│      ▼ HTTPS REST                ▼ STOMP/SockJS                  │
└──────┼───────────────────────────┼───────────────────────────────┘
       │                           │
┌──────▼───────────────────────────▼───────────────────────────────┐
│              SPRING BOOT BACKEND (server_app_foot)                │
│ JwtAuthFilter → REST Controllers → Services → JPA Repos → PG DB  │
│ + WebSocket STOMP /ws (+ SockJS) — broadcast /user/queue/orders   │
│ + @Async FCM push (Firebase Admin SDK 9.2.0)                      │
│ + Redis: revoked refresh token blacklist                          │
│ + SMTP: email verify + password reset                             │
└──────────────────────────────────────────────────────────────────┘
```

### 1.5. Công nghệ sử dụng

**Mobile (`food_app/pubspec.yaml`):**

| Package | Mục đích |
|---|---|
| `flutter_bloc 8.1.6` | State management (Cubit) |
| `go_router 14.8.1` | Declarative routing + redirect guard |
| `dio 5.9.0` | HTTP client + interceptor JWT |
| `flutter_secure_storage 9.2.4` | Persist access/refresh token (encrypted) |
| `shared_preferences 2.5.3` | Onboarding flag + fallback khi Secure Storage lỗi |
| `stomp_dart_client 3.0.1` | WebSocket STOMP (theo dõi đơn real-time) |
| `intl 0.20.2` | Format ngày/giờ/tiền tệ |
| `equatable 2.0.7` | Value equality cho State |
| `cupertino_icons 1.0.8` | Icon iOS |

**Backend tóm tắt (xem chi tiết `server_app_foot/pom.xml`):**
- Spring Boot 3.2.4 + Java 17, PostgreSQL, Flyway, Redis, JWT (jjwt 0.12.5), Firebase Admin 9.2.0, Thymeleaf (web SSR cho admin/owner/shipper), springdoc-openapi 2.3.0 (Swagger).

### 1.6. External service

| Service | Vai trò | Vị trí cấu hình |
|---|---|---|
| PostgreSQL | DB chính | `application.yml` `spring.datasource` |
| Redis | Revoked refresh token blacklist (logout/rotate) | `application.yml` `spring.data.redis` |
| Firebase Cloud Messaging | Push notification cho app Flutter | `application.yml` `firebase.*`, `FirebaseConfig.java` |
| SMTP (Gmail) | Email verify + reset password | `application.yml` `spring.mail` |

---

## 2. Phân tích cấu trúc source code (App Flutter)

### 2.1. Folder structure

```
food_app/lib/
├── main.dart                          # Entry: runApp(FoodRushApp())
├── app.dart                           # DI + GoRouter + ThemeData
├── core/
│   ├── constants/app_constants.dart   # apiBaseUrl, webSocketUrl, key SharedPref
│   ├── network/
│   │   ├── api_client.dart            # Dio + interceptor JWT + parse ApiResponse
│   │   └── api_exception.dart         # Exception wrapper {message, errorCode, statusCode, details}
│   ├── routing/go_router_refresh_stream.dart  # Bridge Stream → Listenable
│   ├── storage/token_storage.dart     # FlutterSecureStorage + SharedPreferences fallback
│   └── utils/formatters.dart          # intl helpers
├── shared/widgets/
│   └── restaurant_card.dart
└── features/
    ├── auth/{data,logic,presentation/screens}
    │   ├── data/
    │   │   ├── auth_repository.dart   # login/register/logout/forgotPassword
    │   │   └── models/auth_session.dart
    │   ├── logic/
    │   │   ├── auth_cubit.dart        # bootstrap, login, register, logout
    │   │   └── auth_state.dart        # AuthStatus {unknown, unauthenticated, authenticated}
    │   └── presentation/screens/      # splash, onboarding, login, register, forgot_password
    ├── home/presentation/home_shell_screen.dart      # IndexedStack 4 tabs
    ├── discover/{data,logic,presentation}            # list/filter restaurants
    ├── restaurant/{data/models,logic,presentation}   # detail + menu + item detail
    ├── search/presentation/screens/search_screen.dart
    ├── cart/{data,logic,presentation}                # CartCubit + CartRepository
    ├── order/{data,presentation/screens}             # checkout, history, detail, tracking
    ├── profile/{data,presentation/screens}           # 8 screen
    ├── review/data/                                   # review_repository + models
    ├── notification/presentation/screens
    └── admin/presentation/screens                    # dashboard, manage menu/orders, add/edit item
```

### 2.2. Layered architecture (Feature-first Clean Architecture)

```
┌─────────────────────────────────────────────┐
│ Presentation                                 │
│  - Screen (StatefulWidget / Stateless)       │
│  - BlocBuilder/BlocListener consume Cubit    │
└──────────────────┬──────────────────────────┘
                   │ calls
                   ▼
┌─────────────────────────────────────────────┐
│ Logic (Cubit + State)                        │
│  - Emit state on user intent                 │
│  - Catch ApiException → errorMessage         │
└──────────────────┬──────────────────────────┘
                   │ calls
                   ▼
┌─────────────────────────────────────────────┐
│ Data (Repository)                            │
│  - Pure async functions                      │
│  - Map JSON → Model via fromJson factory     │
└──────────────────┬──────────────────────────┘
                   │ uses
                   ▼
┌─────────────────────────────────────────────┐
│ Core/Network — ApiClient (Dio + JWT)         │
│  - Interceptor onRequest: attach Bearer      │
│  - Interceptor onError: map ApiException     │
│  - _unwrap: payload.success → data | throw   │
└──────────────────┬──────────────────────────┘
                   │ HTTPS
                   ▼
                Backend
```

### 2.3. Dependency Injection (`app.dart`)

App khởi tạo dependency 1 lần ở root, sau đó cung cấp qua `MultiRepositoryProvider` + `BlocProvider.value`:

```
TokenStorage
   └─→ ApiClient                                       (singleton ở app root)
         └─→ AuthRepository ────────────────► AuthCubit  (global)
         └─→ RestaurantRepository ──┐
         └─→ CartRepository ────────┤
         └─→ UserRepository ────────┼─► context.read<T>()
         └─→ OrderRepository ───────┤    (screens lấy ra dùng)
         └─→ ReviewRepository ──────┘
```

`AuthCubit` là cubit **global** (cung cấp bằng `BlocProvider.value`). Các cubit khác như `CartCubit`, `RestaurantDetailCubit`, `DiscoverCubit` được scoped trong route tương ứng để tự huỷ khi rời màn hình.

### 2.4. Routing (`app.dart` — go_router)

| Path | Screen | Guard (redirect logic) |
|---|---|---|
| `/` | `SplashScreen` | Always start here |
| `/onboarding` | `OnboardingScreen` | `!onboardingSeen` |
| `/login`, `/register`, `/forgot-password` | Auth screens | `!isAuthenticated` |
| `/home` | `HomeShellScreen` (IndexedStack 4 tab) | `isAuthenticated` |
| `/restaurants`, `/restaurants/:id` | List/Detail | **Public** |
| `/restaurants/:rId/items/:id` | `ItemDetailScreen` | `isAuthenticated` |
| `/search?q=` | `SearchScreen` | `isAuthenticated` |
| `/cart` | `CartScreen` (scoped `CartCubit`) | `isAuthenticated` |
| `/checkout` | `CheckoutScreen` | `isAuthenticated` |
| `/orders`, `/orders/:id`, `/orders/:id/tracking` | History / Detail / Tracking | `isAuthenticated` |
| `/profile`, `/profile/edit`, `/profile/addresses`, `/profile/addresses/new`, `/profile/payment-methods` | Profile screens | `isAuthenticated` |
| `/support/faq`, `/support/terms`, `/support/privacy` | Static info | Public |
| `/notifications` | `NotificationsScreen` | `isAuthenticated` |
| `/admin`, `/admin/menu`, `/admin/menu/items/new`, `/admin/menu/items/:id`, `/admin/orders` | Admin screens | `isAuthenticated` **AND** `userRole == 'RESTAURANT_ADMIN'` |

**Cơ chế redirect** (`app.dart:98-145`):
- `AuthStatus.unknown` → giữ ở `/`
- Chưa onboarding → ép về `/onboarding`
- Chưa đăng nhập + route private → ép về `/login`
- Đã đăng nhập + đang ở `/login` `/register` `/` → ép về `/home`
- Vào `/admin/**` nhưng không phải `RESTAURANT_ADMIN` → ép về `/home`

**Refresh listener:** `GoRouterRefreshStream(_authCubit.stream)` — mỗi khi `AuthCubit` emit state, go_router re-check redirect.

### 2.5. State Management — Cubit pattern (`flutter_bloc`)

| Cubit | Phạm vi | State chính |
|---|---|---|
| `AuthCubit` | Global | `AuthState{status, onboardingSeen, isSubmitting, errorMessage, userEmail, userFullName, userRole}` |
| `CartCubit` | Scoped `/cart` | `CartState{status, cart: CartModel, isUpdating, errorMessage, successMessage}` |
| `RestaurantDetailCubit` | Scoped `/restaurants/:id` | `RestaurantDetailState{status, restaurant, menu, isAddingToCart, addedCart, success/error}` |
| `DiscoverCubit` | Scoped tab Khám phá | `DiscoverState{status, restaurants, searchText, errorMessage}` |

Các screen còn lại (Profile, Order detail, Checkout, Tracking) **không dùng Cubit** mà quản lý local state trong `StatefulWidget` — pattern đơn giản với `setState` + `await repository.xxx()` (xem `OrderTrackingScreen` và `CheckoutScreen`).

### 2.6. Network layer (`core/network/api_client.dart`)

`ApiClient` đóng vai trò gateway:

1. **Interceptor `onRequest`** — đọc `TokenStorage.readAccessToken()`, đính `Authorization: Bearer ...`.
2. **Interceptor `onResponse`** — log (debug mode).
3. **Interceptor `onError`** — nếu response chứa `{message, errorCode, details}` → wrap thành `DioException(error: ApiException(...))`.
4. **`_unwrap(response)`** — payload chuẩn backend là `{success: bool, message, data, errorCode, details, timestamp}`. Nếu `success=false` → throw `ApiException`. Nếu OK → return `payload['data']`.

Tất cả repository chỉ làm việc với `data` đã unwrap, không phải tự parse wrapper.

### 2.7. Storage layer (`core/storage/token_storage.dart`)

- **Primary:** `FlutterSecureStorage` (Android Keystore / iOS Keychain) lưu access/refresh token, expiry epoch, user role.
- **Fallback:** Khi `PlatformException` (ví dụ web / desktop) → tự fallback sang `SharedPreferences`.
- **`hasValidAccessToken()`** — check expiry epoch nội bộ (không decode JWT).
- **`isOnboardingSeen()`** — luôn dùng `SharedPreferences`.

### 2.8. WebSocket real-time (`stomp_dart_client`)

Chỉ dùng tại 1 màn hình: `OrderTrackingScreen` (`features/order/presentation/screens/order_tracking_screen.dart:62-110`).

- URL: `AppConstants.webSocketUrl` → `http://<host>:8080/ws` (SockJS)
- Header: `Authorization: Bearer <accessToken>`
- Heartbeat: 10s in/out, reconnect delay 5s
- Subscribe: `/user/queue/orders/{orderId}/status`
- Khi nhận message: gọi `_load(silent: true)` để re-fetch order detail (tránh trust payload từ socket, gọi REST cho dữ liệu canonical).
- **Fallback:** `Timer.periodic(15s)` polling nếu mất kết nối — UI hiển thị badge "Realtime: Mất kết nối (đang dùng polling)".

### 2.9. Bảng module tổng hợp

| STT | Module (Flutter) | Chức năng | File liên quan | Mô tả |
|---|---|---|---|---|
| 1 | `core/network` | HTTP client, JWT inject, unwrap ApiResponse | `api_client.dart`, `api_exception.dart` | Singleton ở root, dùng Dio interceptor |
| 2 | `core/storage` | Persist token + onboarding flag | `token_storage.dart` | SecureStorage + SP fallback |
| 3 | `core/routing` | Bridge stream → Listenable cho go_router | `go_router_refresh_stream.dart` | Để router rebuild khi AuthState đổi |
| 4 | `core/utils` | Format date/currency | `formatters.dart` | dùng `intl` |
| 5 | `features/auth` | Onboarding, splash, login, register, forgot | `auth_repository.dart`, `auth_cubit.dart`, `auth_state.dart` + 5 screen | Global Cubit, JWT persist |
| 6 | `features/home` | Bottom-nav shell | `home_shell_screen.dart` | IndexedStack 4 tab (tránh rebuild) |
| 7 | `features/discover` | List + filter NH | `restaurant_repository.dart`, `discover_cubit.dart`, `discover_screen.dart` | Sort theo rating mặc định |
| 8 | `features/search` | Tìm kiếm | `search_screen.dart` | Dùng chung `RestaurantRepository` |
| 9 | `features/restaurant` | Chi tiết NH + menu + item | `restaurant_detail_cubit.dart`, `restaurant_detail_screen.dart`, `item_detail_screen.dart` | Add to cart trực tiếp từ đây |
| 10 | `features/cart` | Giỏ hàng | `cart_repository.dart`, `cart_cubit.dart`, `cart_screen.dart`, `cart.dart`, `cart_item.dart` | 1 user — 1 cart — 1 NH |
| 11 | `features/order` | Checkout, history, detail, tracking | `order_repository.dart`, `order_models.dart` + 4 screen | Tracking dùng STOMP + polling fallback |
| 12 | `features/profile` | Profile, địa chỉ, support pages | `user_repository.dart`, `user_profile_model.dart`, `address_model.dart` + 8 screen | Hỗ trợ multiple addresses |
| 13 | `features/review` | Tạo review sau DELIVERED | `review_repository.dart`, `review_models.dart` | 1 order → 1 review |
| 14 | `features/notification` | Lịch sử thông báo | `notifications_screen.dart` | Hiển thị status updates |
| 15 | `features/admin` | Quản lý menu + đơn (cho NH owner) | 4 screen trong `admin/presentation/screens/` | Dùng `RestaurantRepository` + `OrderRepository` |

### 2.10. Tóm tắt backend (chỉ phần quan trọng phục vụ app)

> Phần này chỉ liệt kê các thành phần backend mà app Flutter **trực tiếp tương tác**. Chi tiết đầy đủ xem `docs/05_SPRING_BOOT_DESIGN.md`.

| Layer | Component | Trách nhiệm |
|---|---|---|
| Security | `JwtAuthFilter` (`auth/security/`) | Parse `Authorization: Bearer`, set `SecurityContext` |
| Security | `SecurityConfig.apiFilterChain` | `/api/**` stateless + JWT, allow `GET /restaurants/**` public |
| Auth | `AuthController` `/api/v1/auth/**` | register, login, refresh, logout, forgot-password, reset-password, verify-email |
| Auth | `AuthServiceImpl` | BCrypt 12 + JWT (access 15min, refresh 30d) + Redis revoke |
| User | `UserController` `/api/v1/users/me/**` | profile, addresses, FCM token |
| Restaurant | `RestaurantController` `/api/v1/restaurants/**` | List + filter + geo search + detail |
| Menu | `MenuController` `/api/v1/restaurants/{id}/menu/**` | Menu category + item |
| Cart | `CartController` `/api/v1/cart/**` | get/add/update/remove/clear |
| Order | `OrderController` `/api/v1/orders/**` | placeOrder, getMyOrders, detail, cancel, updateStatus |
| Payment | `PaymentController` `/api/v1/payments/**` | get info, confirm COD |
| Review | `ReviewController` `/api/v1/reviews/**` + `/api/v1/restaurants/{id}/reviews` | create + list |
| Realtime | `WebSocketConfig` + `SimpMessagingTemplate` | STOMP `/ws`, broadcast `/user/queue/orders/{id}/status` |
| Notification | `NotificationServiceImpl` `@Async` | Gửi FCM khi order status change |

---

## 3. Phân tích Database

Schema từ Flyway `V1..V11` (`server_app_foot/src/main/resources/db/migration/`). Tổng **14 bảng** PostgreSQL, mọi PK đều `BIGSERIAL`.

| Table | Column | Type | PK/FK | Description |
|---|---|---|---|---|
| **users** | id | BIGSERIAL | PK | |
| | email | VARCHAR(255) | UNIQUE, NOT NULL | Login username |
| | phone_number | VARCHAR(20) | UNIQUE | |
| | password_hash | VARCHAR(255) | NOT NULL | BCrypt strength 12 |
| | first_name, last_name | VARCHAR(100) | NOT NULL | |
| | role | VARCHAR(30) | NOT NULL DEFAULT 'CUSTOMER' | CUSTOMER, RESTAURANT_ADMIN, DELIVERY_AGENT, SYSTEM_ADMIN |
| | profile_picture_url | TEXT | | |
| | fcm_token | VARCHAR(255) | | App gửi qua `PUT /users/me/fcm-token` |
| | active, email_verified | BOOLEAN | NOT NULL | |
| | email_verification_token, password_reset_token | VARCHAR(255) | | UUID, có expires_at 30 phút |
| | password_reset_expires_at, last_login_at | TIMESTAMPTZ | | |
| | created_at, updated_at | TIMESTAMPTZ | NOT NULL | |
| **addresses** | id | BIGSERIAL | PK | |
| | user_id | BIGINT | FK→users(id) ON DELETE CASCADE | |
| | label | VARCHAR(50) | NOT NULL | "Nhà", "Công ty"... |
| | street_line1, street_line2, city, state, postal_code | VARCHAR | | |
| | country_code | VARCHAR(2) | NOT NULL DEFAULT 'VN' | V9 đổi từ CHAR(2) → VARCHAR(2) |
| | latitude, longitude | DECIMAL(10,7) | | |
| | default_address | BOOLEAN | NOT NULL DEFAULT FALSE | App hiển thị "Mặc định" |
| **restaurants** | id | BIGSERIAL | PK | |
| | owner_id | BIGINT | FK→users(id) | |
| | name | VARCHAR(255) | NOT NULL | |
| | slug | VARCHAR(255) | UNIQUE, NOT NULL | SEO URL, app dùng `/restaurants/:slug` |
| | description, logo_url, banner_url | TEXT | | |
| | cuisine_type | VARCHAR(100) | NOT NULL | "Ẩm thực Việt", "Nhật Bản"... |
| | phone, email, street_address, city | VARCHAR | | |
| | latitude, longitude | DECIMAL(10,7) | | Geo search |
| | rating_avg | DECIMAL(3,2) | NOT NULL DEFAULT 0 | Cập nhật khi có review |
| | rating_count | INTEGER | NOT NULL DEFAULT 0 | |
| | min_order_amount, delivery_fee | DECIMAL(12,2) | NOT NULL | |
| | estimated_delivery_minutes | INTEGER | NOT NULL DEFAULT 30 | |
| | active, open | BOOLEAN | NOT NULL | |
| **operating_hours** | id | BIGSERIAL | PK | |
| | restaurant_id | BIGINT | FK→restaurants(id) CASCADE | |
| | day_of_week | INTEGER | CHECK 0..6 | 0=Chủ Nhật, 1..6=T2..T7 (V10 đổi SMALLINT→INT) |
| | open_time, close_time | TIME | NOT NULL | |
| | closed | BOOLEAN | NOT NULL DEFAULT FALSE | |
| **menu_categories** | id | BIGSERIAL | PK | |
| | restaurant_id | BIGINT | FK→restaurants(id) CASCADE | |
| | name | VARCHAR(100) | NOT NULL | |
| | description | TEXT | | |
| | display_order | INTEGER | NOT NULL DEFAULT 0 | |
| | active | BOOLEAN | NOT NULL DEFAULT TRUE | |
| **menu_items** | id | BIGSERIAL | PK | |
| | category_id | BIGINT | FK→menu_categories(id) CASCADE | |
| | restaurant_id | BIGINT | FK→restaurants(id) CASCADE | Denormalize |
| | name | VARCHAR(255) | NOT NULL | |
| | description | TEXT | | |
| | price | DECIMAL(12,2) | NOT NULL | VND |
| | image_url | TEXT | | |
| | available, featured | BOOLEAN | NOT NULL | App tắt món bằng cờ available |
| | calories, preparation_time_minutes, display_order | INTEGER | | |
| **carts** | id | BIGSERIAL | PK | |
| | user_id | BIGINT | FK→users(id) CASCADE **UNIQUE** | 1 user → 1 cart |
| | restaurant_id | BIGINT | FK→restaurants(id) ON DELETE SET NULL | Khoá nhà hàng đang chọn |
| **cart_items** | id | BIGSERIAL | PK | |
| | cart_id | BIGINT | FK→carts(id) CASCADE | |
| | menu_item_id | BIGINT | FK→menu_items(id) | |
| | quantity | INTEGER | NOT NULL CHECK > 0 | |
| | unit_price | DECIMAL(12,2) | NOT NULL | Snapshot khi add |
| | special_instructions | TEXT | | |
| **orders** | id | BIGSERIAL | PK | |
| | order_number | VARCHAR(20) | UNIQUE, NOT NULL | Format `FR-yyyyMMdd-00001` |
| | user_id | BIGINT | FK→users(id) | |
| | restaurant_id | BIGINT | FK→restaurants(id) | |
| | delivery_agent_id | BIGINT | FK→users(id) NULLABLE | Shipper được assign |
| | status | VARCHAR(30) | NOT NULL DEFAULT 'PENDING' | 8 trạng thái |
| | delivery_address_snapshot | TEXT | | JSON snapshot |
| | subtotal, delivery_fee, discount_amount, total_amount | DECIMAL(12,2) | NOT NULL | |
| | special_instructions | TEXT | | |
| | estimated_delivery_at, delivered_at, cancelled_at | TIMESTAMPTZ | | |
| | cancellation_reason | TEXT | | |
| **order_items** | id | BIGSERIAL | PK | |
| | order_id | BIGINT | FK→orders(id) CASCADE | |
| | menu_item_id | BIGINT | FK→menu_items(id) | |
| | menu_item_name | VARCHAR(255) | NOT NULL | Snapshot tên |
| | quantity, unit_price, subtotal | NOT NULL | | |
| | special_instructions | TEXT | | |
| **order_status_history** | id | BIGSERIAL | PK | |
| | order_id | BIGINT | FK→orders(id) CASCADE | |
| | status | VARCHAR(30) | NOT NULL | |
| | notes | TEXT | | |
| | changed_by_user_id | BIGINT | | Không FK |
| | created_at | TIMESTAMPTZ | NOT NULL | App hiển thị timeline |
| **payments** | id | BIGSERIAL | PK | |
| | order_id | BIGINT | FK→orders(id) UNIQUE, NOT NULL | 1:1 |
| | payment_method | VARCHAR(30) | NOT NULL | COD, CREDIT_CARD, MOMO, ZALOPAY |
| | payment_status | VARCHAR(30) | NOT NULL DEFAULT 'PENDING' | PENDING, PAID, FAILED, REFUNDED |
| | amount | DECIMAL(12,2) | NOT NULL | |
| | transaction_id, gateway_response | | | |
| | paid_at | TIMESTAMPTZ | | |
| **reviews** | id | BIGSERIAL | PK | |
| | order_id | BIGINT | FK→orders(id) UNIQUE | 1:1 |
| | user_id, restaurant_id | BIGINT | FK | |
| | rating | INTEGER | CHECK 1..5 (V10 đổi SMALLINT→INT) | |
| | comment | TEXT | | |
| | visible | BOOLEAN | NOT NULL DEFAULT TRUE | Admin có thể ẩn |
| **promo_codes** | id | BIGSERIAL | PK | |
| | code | VARCHAR(30) | UNIQUE, NOT NULL | "FIRST10", "SAVE20K"... |
| | discount_type | VARCHAR(20) | NOT NULL | PERCENTAGE / FIXED |
| | discount_value | DECIMAL(10,2) | NOT NULL | |
| | min_order_amount, max_discount_amount | DECIMAL(12,2) | | |
| | start_date, end_date | TIMESTAMPTZ | NOT NULL | |
| | usage_limit, used_count | INTEGER | NOT NULL | |
| | active | BOOLEAN | NOT NULL DEFAULT TRUE | |

**Index quan trọng cho query app:**
- `idx_users_email`, `idx_users_phone`
- `idx_restaurants_active(active, open)`, `idx_restaurants_slug`, `idx_restaurants_city`, `idx_restaurants_cuisine`
- `idx_menu_items_available(restaurant_id, available)`
- `idx_orders_user_id` (cho `/orders` của tôi), `idx_orders_created_at DESC`
- `idx_reviews_restaurant_id(restaurant_id, visible)`

---

## 4. ERD (DBML)

Paste trực tiếp vào https://dbdiagram.io:

```dbml
Table users {
  id bigint [pk, increment]
  email varchar(255) [unique, not null]
  phone_number varchar(20) [unique]
  password_hash varchar(255) [not null]
  first_name varchar(100) [not null]
  last_name varchar(100) [not null]
  role varchar(30) [not null, default: 'CUSTOMER']
  profile_picture_url text
  fcm_token varchar(255)
  active boolean [not null, default: true]
  email_verified boolean [not null, default: false]
  email_verification_token varchar(255)
  password_reset_token varchar(255)
  password_reset_expires_at timestamptz
  last_login_at timestamptz
  created_at timestamptz [not null]
  updated_at timestamptz [not null]
}

Table addresses {
  id bigint [pk, increment]
  user_id bigint [ref: > users.id, not null]
  label varchar(50) [not null]
  street_line1 varchar(255) [not null]
  street_line2 varchar(255)
  city varchar(100) [not null]
  state varchar(100) [not null]
  postal_code varchar(20) [not null]
  country_code varchar(2) [not null, default: 'VN']
  latitude decimal(10,7)
  longitude decimal(10,7)
  default_address boolean [not null, default: false]
}

Table restaurants {
  id bigint [pk, increment]
  owner_id bigint [ref: > users.id, not null]
  name varchar(255) [not null]
  slug varchar(255) [unique, not null]
  description text
  cuisine_type varchar(100) [not null]
  logo_url text
  banner_url text
  phone varchar(20)
  email varchar(255)
  street_address varchar(255) [not null]
  city varchar(100) [not null]
  latitude decimal(10,7)
  longitude decimal(10,7)
  rating_avg decimal(3,2) [not null, default: 0]
  rating_count int [not null, default: 0]
  min_order_amount decimal(12,2) [not null, default: 0]
  delivery_fee decimal(12,2) [not null, default: 0]
  estimated_delivery_minutes int [not null, default: 30]
  active boolean [not null, default: true]
  open boolean [not null, default: false]
}

Table operating_hours {
  id bigint [pk, increment]
  restaurant_id bigint [ref: > restaurants.id, not null]
  day_of_week int [not null, note: '0=Sun..6=Sat']
  open_time time [not null]
  close_time time [not null]
  closed boolean [not null, default: false]
}

Table menu_categories {
  id bigint [pk, increment]
  restaurant_id bigint [ref: > restaurants.id, not null]
  name varchar(100) [not null]
  description text
  display_order int [not null, default: 0]
  active boolean [not null, default: true]
}

Table menu_items {
  id bigint [pk, increment]
  category_id bigint [ref: > menu_categories.id, not null]
  restaurant_id bigint [ref: > restaurants.id, not null]
  name varchar(255) [not null]
  description text
  price decimal(12,2) [not null]
  image_url text
  available boolean [not null, default: true]
  featured boolean [not null, default: false]
  calories int
  preparation_time_minutes int [not null, default: 15]
  display_order int [not null, default: 0]
}

Table carts {
  id bigint [pk, increment]
  user_id bigint [ref: > users.id, unique, not null]
  restaurant_id bigint [ref: > restaurants.id]
}

Table cart_items {
  id bigint [pk, increment]
  cart_id bigint [ref: > carts.id, not null]
  menu_item_id bigint [ref: > menu_items.id, not null]
  quantity int [not null]
  unit_price decimal(12,2) [not null]
  special_instructions text
}

Table orders {
  id bigint [pk, increment]
  order_number varchar(20) [unique, not null]
  user_id bigint [ref: > users.id, not null]
  restaurant_id bigint [ref: > restaurants.id, not null]
  delivery_agent_id bigint [ref: > users.id]
  status varchar(30) [not null, default: 'PENDING']
  delivery_address_snapshot text
  subtotal decimal(12,2) [not null]
  delivery_fee decimal(12,2) [not null]
  discount_amount decimal(12,2) [not null, default: 0]
  total_amount decimal(12,2) [not null]
  special_instructions text
  estimated_delivery_at timestamptz
  delivered_at timestamptz
  cancelled_at timestamptz
  cancellation_reason text
}

Table order_items {
  id bigint [pk, increment]
  order_id bigint [ref: > orders.id, not null]
  menu_item_id bigint [ref: > menu_items.id, not null]
  menu_item_name varchar(255) [not null]
  quantity int [not null]
  unit_price decimal(12,2) [not null]
  subtotal decimal(12,2) [not null]
  special_instructions text
}

Table order_status_history {
  id bigint [pk, increment]
  order_id bigint [ref: > orders.id, not null]
  status varchar(30) [not null]
  notes text
  changed_by_user_id bigint
  created_at timestamptz [not null]
}

Table payments {
  id bigint [pk, increment]
  order_id bigint [ref: - orders.id, unique, not null]
  payment_method varchar(30) [not null]
  payment_status varchar(30) [not null, default: 'PENDING']
  amount decimal(12,2) [not null]
  transaction_id varchar(255)
  gateway_response text
  paid_at timestamptz
}

Table reviews {
  id bigint [pk, increment]
  order_id bigint [ref: - orders.id, unique, not null]
  user_id bigint [ref: > users.id, not null]
  restaurant_id bigint [ref: > restaurants.id, not null]
  rating int [not null, note: '1..5']
  comment text
  visible boolean [not null, default: true]
}

Table promo_codes {
  id bigint [pk, increment]
  code varchar(30) [unique, not null]
  discount_type varchar(20) [not null, note: 'PERCENTAGE | FIXED']
  discount_value decimal(10,2) [not null]
  min_order_amount decimal(12,2)
  max_discount_amount decimal(12,2)
  start_date timestamptz [not null]
  end_date timestamptz [not null]
  usage_limit int [not null, default: 9999]
  used_count int [not null, default: 0]
  active boolean [not null, default: true]
}
```

---

## 5. Use Case

### Actor

- **Customer** (Khách hàng) — Flutter mobile app
- **Restaurant Admin** (Chủ nhà hàng) — Khu vực `/admin/**` trong Flutter + Web Thymeleaf
- **External:** Backend, FCM, SMTP

### Customer Use Cases (focus chính)

- UC-C01. Xem onboarding (lần đầu cài app)
- UC-C02. Đăng ký tài khoản
- UC-C03. Đăng nhập
- UC-C04. Đăng xuất
- UC-C05. Quên mật khẩu (gửi email)
- UC-C06. Xem & cập nhật profile (firstName, lastName, phone, avatar)
- UC-C07. Quản lý địa chỉ (thêm/sửa/xóa/đặt mặc định)
- UC-C08. Duyệt nhà hàng (list + filter city/cuisine/open + search)
- UC-C09. Xem chi tiết nhà hàng + menu + review
- UC-C10. Xem chi tiết món ăn
- UC-C11. Thêm món vào giỏ (chỉ cho phép cùng 1 nhà hàng)
- UC-C12. Tăng/giảm số lượng món trong giỏ
- UC-C13. Xóa món / xóa toàn bộ giỏ
- UC-C14. Đặt hàng (chọn địa chỉ + payment + promo + special instructions)
- UC-C15. Áp mã giảm giá khi checkout
- UC-C16. Theo dõi đơn real-time (STOMP + polling 15s fallback)
- UC-C17. Xem lịch sử đơn (filter status)
- UC-C18. Xem chi tiết đơn + payment info
- UC-C19. Hủy đơn (chỉ khi PENDING/CONFIRMED)
- UC-C20. Đánh giá nhà hàng sau khi DELIVERED (1 order → 1 review)
- UC-C21. Xem thông báo

### Restaurant Admin Use Cases (trong `/admin/**` của Flutter)

- UC-R01. Dashboard tổng quan
- UC-R02. Quản lý menu (CRUD danh mục + món)
- UC-R03. Quản lý đơn hàng của nhà hàng (filter status + date)
- UC-R04. Cập nhật trạng thái đơn (CONFIRMED → PREPARING → READY_FOR_PICKUP)

### Quan hệ

- `Place Order` ─ «include» → `Validate Promo`, `Snapshot Address`, `Create Payment`, `Clear Cart`
- `Track Order` ─ «extend» → `Subscribe STOMP`, `Polling Fallback`
- `Create Review` ─ «precondition» → đơn phải `DELIVERED`
- `Add to Cart` ─ «extend» → `Reject if different restaurant`

```
                         ┌────────────────┐
                         │   Customer     │
                         └────────┬───────┘
                                  │
                ┌─────────────────┼─────────────────┬─────────────────┐
                │                 │                 │                 │
        Auth & Profile     Browse & Search     Cart & Order     Track & Review
        ─────────────     ───────────────     ─────────────     ──────────────
        UC-C01..07         UC-C08..10          UC-C11..15        UC-C16..21
```

---

## 6. Sequence Diagram (syntax sequencediagram.org)

> Tất cả diagram dưới đây **paste trực tiếp** vào https://sequencediagram.org/.

### 6.1. App khởi động — Bootstrap Auth

```
title App Bootstrap (Splash)

participant User
participant SplashScreen
participant AuthCubit
participant TokenStorage
participant GoRouter

User->SplashScreen: Mở app
SplashScreen->AuthCubit: bootstrap()
AuthCubit->TokenStorage: isOnboardingSeen()
TokenStorage-->AuthCubit: false/true
AuthCubit->TokenStorage: hasValidAccessToken()
TokenStorage->TokenStorage: Đọc access_token + expiry epoch
TokenStorage-->AuthCubit: true/false

alt Chưa onboarding
AuthCubit-->SplashScreen: emit(unauthenticated, onboardingSeen=false)
SplashScreen->GoRouter: redirect /onboarding

else Token còn hạn
AuthCubit-->SplashScreen: emit(authenticated, userRole)
SplashScreen->GoRouter: redirect /home

else Token hết hạn hoặc không có
AuthCubit->TokenStorage: clearTokens()
AuthCubit-->SplashScreen: emit(unauthenticated, onboardingSeen=true)
SplashScreen->GoRouter: redirect /login
end
```

### 6.2. Đăng ký

```
title Register Flow

participant User
participant RegisterScreen
participant AuthCubit
participant AuthRepository
participant ApiClient
participant Backend

User->RegisterScreen: Nhập firstName, lastName, email, phone, password
RegisterScreen->AuthCubit: register(...)
AuthCubit->AuthCubit: emit(isSubmitting=true)
AuthCubit->AuthRepository: register(...)
AuthRepository->ApiClient: POST /auth/register {firstName, lastName, email, phoneNumber, password}
ApiClient->Backend: HTTP POST + body
Backend->Backend: existsByEmail/Phone check
Backend->Backend: BCrypt(password) + save User CUSTOMER + generate verifyToken
Backend->Backend: EmailService.sendEmailVerification @Async
Backend-->ApiClient: 201 {success, data:{id, email, role, accessToken, refreshToken, accessTokenExpiresIn}}

alt success=false (email/phone đã dùng)
ApiClient-->AuthRepository: throw ApiException(AUTH_003/004)
AuthRepository-->AuthCubit: ApiException
AuthCubit-->RegisterScreen: emit(isSubmitting=false, errorMessage)
RegisterScreen-->User: Hiển thị thông báo lỗi

else success=true
ApiClient-->AuthRepository: AuthSession.fromJson
AuthRepository-->AuthCubit: AuthSession
AuthCubit->TokenStorage: saveTokens(access, refresh, expiry, role)
AuthCubit-->RegisterScreen: emit(authenticated, userRole=CUSTOMER)
RegisterScreen->GoRouter: trigger redirect (AuthCubit.stream)
GoRouter-->User: Navigate /home
end
```

### 6.3. Đăng nhập

```
title Login Flow

participant User
participant LoginScreen
participant AuthCubit
participant AuthRepository
participant ApiClient
participant Backend
participant TokenStorage
participant GoRouter

User->LoginScreen: Nhập email + password
LoginScreen->AuthCubit: login(email, password)
AuthCubit->AuthCubit: emit(isSubmitting=true, clearError=true)
AuthCubit->AuthRepository: login(email, password)
AuthRepository->ApiClient: POST /auth/login
ApiClient->Backend: HTTP POST {email, password}
Backend->Backend: AuthenticationManager.authenticate (BCrypt match)

alt Sai mật khẩu
Backend-->ApiClient: 401 {success=false, errorCode, message}
ApiClient-->AuthRepository: ApiException
AuthRepository-->AuthCubit: ApiException
AuthCubit-->LoginScreen: emit(isSubmitting=false, errorMessage='Sai email/mật khẩu')
LoginScreen-->User: SnackBar lỗi

else Đúng
Backend->Backend: generate JWT access (15min) + refresh (30d)
Backend-->ApiClient: 200 {success=true, data: AuthSession}
ApiClient-->AuthRepository: AuthSession
AuthRepository-->AuthCubit: AuthSession
AuthCubit->TokenStorage: saveTokens(access, refresh, expiresIn, role)
AuthCubit-->LoginScreen: emit(authenticated, userEmail, userRole, isSubmitting=false)
LoginScreen->GoRouter: Refresh redirect via AuthCubit.stream
GoRouter-->User: Navigate /home
end
```

### 6.4. Refresh Token (transparent — không có UI)

```
title Refresh Access Token

participant ApiClient
participant TokenStorage
participant Backend
participant Redis

note over ApiClient: (Implicit — diễn ra khi app phát hiện token gần hết hạn)
ApiClient->TokenStorage: readRefreshToken
ApiClient->Backend: POST /auth/refresh {refreshToken}
Backend->Backend: JwtUtil.validateToken
Backend->Redis: GET revoked:token:{hash}
Redis-->Backend: null

alt Token bị revoke / hết hạn
Backend-->ApiClient: 401 UnauthorizedException
ApiClient->TokenStorage: clearTokens
ApiClient-->ApiClient: App quay về /login

else Hợp lệ
Backend->Redis: SETEX revoked:token:{hash} 30d true
Backend->Backend: Gen new access + refresh
Backend-->ApiClient: 200 {accessToken, refreshToken, accessTokenExpiresIn}
ApiClient->TokenStorage: saveTokens (rotate)
end
```

### 6.5. Duyệt nhà hàng (Discover)

```
title Discover Restaurants

participant User
participant DiscoverScreen
participant DiscoverCubit
participant RestaurantRepository
participant ApiClient
participant Backend
participant DB

User->DiscoverScreen: Mở tab Khám phá
DiscoverScreen->DiscoverCubit: loadRestaurants()
DiscoverCubit->DiscoverCubit: emit(loading)
DiscoverCubit->RestaurantRepository: fetchRestaurants(search, sortBy='rating')
RestaurantRepository->ApiClient: GET /restaurants?sortBy=rating
ApiClient->Backend: HTTP GET (no auth required — permitAll)
Backend->DB: SELECT ... ORDER BY rating_avg DESC LIMIT 20
DB-->Backend: List<Restaurant>
Backend-->ApiClient: 200 {success, data: {content, totalElements, totalPages}}
ApiClient-->RestaurantRepository: data.content → List<RestaurantSummary>
RestaurantRepository-->DiscoverCubit: List
DiscoverCubit-->DiscoverScreen: emit(success, restaurants)
DiscoverScreen-->User: Render danh sách RestaurantCard
```

### 6.6. Thêm món vào giỏ

```
title Add to Cart

participant User
participant ItemDetailScreen
participant RestaurantDetailCubit
participant CartRepository
participant ApiClient
participant Backend

User->ItemDetailScreen: Tap "Thêm vào giỏ"
ItemDetailScreen->RestaurantDetailCubit: addItemToCart(menuItemId)
RestaurantDetailCubit->RestaurantDetailCubit: emit(isAddingToCart=true)
RestaurantDetailCubit->CartRepository: addItem(menuItemId, quantity=1)
CartRepository->ApiClient: POST /cart/items {menuItemId, quantity:1}
ApiClient->Backend: HTTP POST + Bearer token
Backend->Backend: JwtAuthFilter → userId
Backend->Backend: CartService.addItem (check available, check restaurant conflict)

alt Món không available
Backend-->ApiClient: 400 {errorCode: CART_002, message}
ApiClient-->CartRepository: ApiException
CartRepository-->RestaurantDetailCubit: ApiException
RestaurantDetailCubit-->ItemDetailScreen: emit(errorMessage)
ItemDetailScreen-->User: SnackBar "Món ăn này hiện không có sẵn"

else Cart đang có món NH khác
Backend-->ApiClient: 400 {errorCode: CART_003}
ApiClient-->RestaurantDetailCubit: ApiException
RestaurantDetailCubit-->ItemDetailScreen: emit(errorMessage)
ItemDetailScreen-->User: Dialog "Xóa giỏ hàng cũ?"

else OK
Backend-->ApiClient: 201 {success, data: CartResponse}
ApiClient-->CartRepository: CartModel.fromJson
CartRepository-->RestaurantDetailCubit: CartModel
RestaurantDetailCubit-->ItemDetailScreen: emit(addedCart, successMessage='Đã thêm món vào giỏ')
ItemDetailScreen-->User: SnackBar success + cart icon update
end
```

### 6.7. Đặt hàng (Place Order)

```
title Place Order Flow

participant User
participant CheckoutScreen
participant OrderRepository
participant CartRepository
participant UserRepository
participant ApiClient
participant Backend
participant WS
participant FCM

User->CheckoutScreen: Mở /checkout
CheckoutScreen->CartRepository: fetchCart()
CheckoutScreen->UserRepository: getAddresses()
CartRepository-->CheckoutScreen: CartModel
UserRepository-->CheckoutScreen: List<AddressModel>
CheckoutScreen->CheckoutScreen: Auto-select defaultAddress
CheckoutScreen-->User: Render địa chỉ + items + tổng tiền

User->CheckoutScreen: Chọn paymentMethod=COD, nhập promo + note
User->CheckoutScreen: Tap "Đặt hàng"
CheckoutScreen->CheckoutScreen: Validate address selected
CheckoutScreen->OrderRepository: placeOrder(addressId, paymentMethod, promo, note)
OrderRepository->ApiClient: POST /orders
ApiClient->Backend: HTTP POST + Bearer

Backend->Backend: @PreAuthorize hasRole('CUSTOMER')
Backend->Backend: OrderService.placeOrder (transactional)
note over Backend: 1. Get cart\n2. Check addressOwnership\n3. Check minOrderAmount\n4. Validate promo\n5. Build addressSnapshot JSON\n6. generateOrderNumber FR-yyyyMMdd-00001\n7. Save Order PENDING + items + history\n8. Save Payment PENDING\n9. promoCode.usedCount++\n10. cart.clear

Backend->WS: convertAndSendToUser /queue/orders/{id}/status (PENDING)
Backend->FCM: sendOrderStatusUpdate @Async
FCM-->User: Push notification

Backend-->ApiClient: 201 {success, data: OrderDetailModel}
ApiClient-->OrderRepository: OrderDetailModel
OrderRepository-->CheckoutScreen: OrderDetailModel
CheckoutScreen->GoRouter: go('/orders/${id}/tracking')
GoRouter-->User: Navigate OrderTrackingScreen
```

### 6.8. Theo dõi đơn real-time (STOMP + polling fallback)

```
title Order Tracking Real-time

participant User
participant TrackingScreen
participant OrderRepository
participant StompClient
participant Timer
participant Backend
participant RestaurantAdmin
participant Shipper

User->TrackingScreen: Mở /orders/{id}/tracking
TrackingScreen->OrderRepository: getOrderDetail(orderId)
OrderRepository-->TrackingScreen: OrderDetailModel
TrackingScreen-->User: Render timeline 5 bước

TrackingScreen->StompClient: activate (SockJS + Bearer token)
StompClient->Backend: CONNECT /ws
Backend-->StompClient: CONNECTED
StompClient->Backend: SUBSCRIBE /user/queue/orders/{id}/status
TrackingScreen->Timer: periodic 15s → _load(silent: true)

note over RestaurantAdmin: NH nhấn "Xác nhận" trên web/app
RestaurantAdmin->Backend: PUT /orders/{id}/status {CONFIRMED}
Backend->Backend: validateStatusTransition + save history
Backend->StompClient: SEND /user/{userId}/queue/orders/{id}/status
StompClient-->TrackingScreen: MESSAGE
TrackingScreen->OrderRepository: getOrderDetail (re-fetch canonical)
OrderRepository-->TrackingScreen: updated OrderDetailModel
TrackingScreen-->User: Timeline cập nhật

Shipper->Backend: PUT status PICKED_UP → ON_THE_WAY → DELIVERED
Backend->StompClient: SEND broadcast
StompClient-->TrackingScreen: MESSAGE
TrackingScreen->OrderRepository: re-fetch
TrackingScreen-->User: "Đã giao thành công 🍜"

alt WebSocket mất kết nối
StompClient-->TrackingScreen: onWebSocketError
TrackingScreen->TrackingScreen: setState(_socketConnected=false)
TrackingScreen-->User: Badge "Realtime: Mất kết nối (đang dùng polling)"
note over Timer: Timer 15s tiếp tục gọi _load silent
end
```

### 6.9. Hủy đơn

```
title Cancel Order

participant User
participant OrderDetailScreen
participant OrderRepository
participant ApiClient
participant Backend

User->OrderDetailScreen: Tap "Hủy đơn"
OrderDetailScreen-->User: Dialog nhập reason
User->OrderDetailScreen: Nhập reason + confirm
OrderDetailScreen->OrderRepository: cancelOrder(orderId, reason)
OrderRepository->ApiClient: PATCH /orders/{id}/cancel {reason}
ApiClient->Backend: HTTP PATCH + Bearer
Backend->Backend: Check ownership (FORBIDDEN nếu khác user)
Backend->Backend: Check status in (PENDING, CONFIRMED)

alt Status không cho phép hủy
Backend-->ApiClient: 400 {errorCode: ORDER_001}
ApiClient-->OrderRepository: ApiException
OrderRepository-->OrderDetailScreen: throw
OrderDetailScreen-->User: SnackBar "Không thể hủy đơn ở trạng thái này"

else OK
Backend->Backend: status=CANCELLED, cancelledAt=now, save history
Backend->Backend: WebSocket broadcast + FCM @Async
Backend-->ApiClient: 200 OrderDetailModel
ApiClient-->OrderDetailScreen: updated
OrderDetailScreen-->User: Cập nhật UI + thông báo "Đã hủy đơn"
end
```

### 6.10. Đánh giá nhà hàng

```
title Create Review

participant User
participant OrderHistoryScreen
participant ReviewDialog
participant ReviewRepository
participant ApiClient
participant Backend

User->OrderHistoryScreen: Xem đơn DELIVERED, tap "Đánh giá"
OrderHistoryScreen->ReviewDialog: Mở dialog
User->ReviewDialog: Chọn rating 1-5 + nhập comment + submit
ReviewDialog->ReviewRepository: createReview(orderId, rating, comment)
ReviewRepository->ApiClient: POST /reviews
ApiClient->Backend: HTTP POST + Bearer
Backend->Backend: Verify order DELIVERED & userOwn
Backend->Backend: Check uniqueness (reviews.order_id UNIQUE)
Backend->Backend: save Review + update restaurant.rating_avg/count
Backend-->ApiClient: 201 ReviewResponse
ApiClient-->ReviewRepository: ReviewModel
ReviewRepository-->ReviewDialog: ReviewModel
ReviewDialog-->User: SnackBar "Cảm ơn bạn đã đánh giá!" + close
OrderHistoryScreen->OrderHistoryScreen: reload list
```

### 6.11. JWT Auth Middleware (mọi request có token)

```
title JWT Auth Filter (mỗi request /api/**)

participant ApiClient
participant Backend
participant JwtAuthFilter
participant JwtUtil
participant SecurityContext
participant Controller

ApiClient->Backend: HTTP /api/v1/cart Authorization: Bearer <token>
Backend->JwtAuthFilter: doFilterInternal
JwtAuthFilter->JwtAuthFilter: extractToken("Bearer ...")
JwtAuthFilter->JwtUtil: validateToken(token)

alt Invalid hoặc thiếu
JwtUtil-->JwtAuthFilter: false / no token
JwtAuthFilter->Backend: chain.doFilter (anonymous)
Backend-->ApiClient: 401 (nếu endpoint yêu cầu auth)

else Valid
JwtUtil-->JwtAuthFilter: Claims{sub=userId, role, email}
JwtAuthFilter->JwtAuthFilter: Build UserPrincipal + ROLE_{role}
JwtAuthFilter->SecurityContext: setAuthentication
JwtAuthFilter->Backend: chain.doFilter
Backend->Controller: dispatch with @AuthenticationPrincipal
Controller-->ApiClient: response
end
```

### 6.12. Quên mật khẩu

```
title Forgot & Reset Password

participant User
participant ForgotPasswordScreen
participant AuthRepository
participant Backend
participant SMTP
participant EmailClient

User->ForgotPasswordScreen: Nhập email + submit
ForgotPasswordScreen->AuthRepository: forgotPassword(email)
AuthRepository->Backend: POST /auth/forgot-password {email}

alt Email không tồn tại
Backend->Backend: Không tiết lộ (security) — trả 200
note over Backend: Tránh user enumeration

else Tồn tại
Backend->Backend: Generate UUID token + expiresAt = now+30min
Backend->Backend: Save to user.passwordResetToken
Backend->SMTP: Send link {frontend}/reset?token=XXX
SMTP->EmailClient: Email tới user
end

Backend-->ForgotPasswordScreen: 200 "Email đặt lại mật khẩu đã được gửi"
ForgotPasswordScreen-->User: SnackBar

User->EmailClient: Click link
EmailClient->ForgotPasswordScreen: Open deep link với token
User->ForgotPasswordScreen: Nhập new password
ForgotPasswordScreen->Backend: POST /auth/reset-password {token, newPassword}

alt Token sai
Backend-->ForgotPasswordScreen: 400 AUTH_005
ForgotPasswordScreen-->User: "Token không hợp lệ"

else Token hết hạn
Backend-->ForgotPasswordScreen: 400 AUTH_006

else OK
Backend->Backend: BCrypt new password + clear token
Backend-->ForgotPasswordScreen: 200
ForgotPasswordScreen-->User: Navigate /login
end
```

### 6.13. Quản lý menu (Admin trong app)

```
title Restaurant Admin — Add Menu Item

participant Owner
participant AdminAddEditItemScreen
participant RestaurantRepository
participant ApiClient
participant Backend

Owner->AdminAddEditItemScreen: Mở /admin/menu/items/new?restaurantId=1
Owner->AdminAddEditItemScreen: Nhập name, price, category, image, available
AdminAddEditItemScreen->RestaurantRepository: createMenuItem(...)
RestaurantRepository->ApiClient: POST /restaurants/1/menu/items
ApiClient->Backend: HTTP POST + Bearer
Backend->Backend: @PreAuthorize hasAnyRole('RESTAURANT_ADMIN','SYSTEM_ADMIN')
Backend->Backend: MenuService.createItem (verify ownership)
Backend->Backend: save MenuItem
Backend-->ApiClient: 201 MenuItemResponse
ApiClient-->AdminAddEditItemScreen: MenuItemModel
AdminAddEditItemScreen->GoRouter: pop()
GoRouter-->Owner: Quay lại danh sách menu
```

### 6.14. Đăng xuất

```
title Logout

participant User
participant ProfileScreen
participant AuthCubit
participant AuthRepository
participant TokenStorage
participant Backend
participant Redis

User->ProfileScreen: Tap "Đăng xuất"
ProfileScreen->AuthCubit: logout()
AuthCubit->AuthCubit: emit(isSubmitting=true)
AuthCubit->AuthRepository: logout()
AuthRepository->TokenStorage: readRefreshToken

alt Refresh token rỗng
AuthRepository-->AuthCubit: skip API call

else
AuthRepository->Backend: POST /auth/logout {refreshToken}
Backend->Redis: SETEX revoked:token:{hash} 30d true
Backend-->AuthRepository: 200
note over AuthRepository: Bắt ApiException và bỏ qua (vẫn clear local)
end

AuthCubit->TokenStorage: clearTokens
AuthCubit-->ProfileScreen: emit(unauthenticated, isSubmitting=false)
ProfileScreen->GoRouter: refresh via stream → /login
```

---

## 7. Class Diagram (App Flutter)

### 7.1. Core layer

```
+----------------------+         +---------------------+
|    AppConstants      |         |   GoRouterRefresh   |
|----------------------|         |       Stream        |
| + apiBaseUrl: String |         |---------------------|
| + webSocketUrl       |         | - listen Stream     |
+----------------------+         | notifyListeners()   |
                                 +---------------------+

+--------------------------+        +-----------------------+
|     TokenStorage         |◆──────|       ApiClient        |
|--------------------------|        |-----------------------|
| - secureStorage          |        | - dio: Dio            |
| + saveTokens(...)        |        | - tokenStorage        |
| + readAccessToken        |        | + get/post/put/       |
| + readRefreshToken       |        |   patch/delete        |
| + readUserRole           |        | - _unwrap()           |
| + hasValidAccessToken    |        +-----------------------+
| + clearTokens            |
| + isOnboardingSeen       |        +-----------------------+
| + setOnboardingSeen      |        |     ApiException      |
+--------------------------+        |-----------------------|
                                    | - message, errorCode  |
                                    | - statusCode, details |
                                    +-----------------------+
```

### 7.2. Auth feature

```
+-----------------+
|  AuthSession    |
|-----------------|
| id, email       |
| firstName/last  |
| role            |
| accessToken     |
| refreshToken    |
| accessTokenExpr |
+--------+--------+
         │ uses (fromJson)
         ▼
+----------------------+        +----------------------+
|   AuthRepository     |◀───────│      AuthCubit       |
|----------------------|        |----------------------|
| - apiClient          |        | - authRepository     |
| - tokenStorage       |        | - tokenStorage       |
| + login              |        | + bootstrap          |
| + register           |        | + login              |
| + logout             |        | + register           |
| + forgotPassword     |        | + logout             |
+----------------------+        | + completeOnboarding |
                                | - _persistSession    |
                                +----------+-----------+
                                           │
                                           ▼ emits
                                +----------------------+
                                |     AuthState        |
                                |----------------------|
                                | status, onboardingSeen|
                                | isSubmitting          |
                                | errorMessage          |
                                | userEmail, userRole   |
                                +----------------------+
```

### 7.3. Cart feature

```
+----------------+        +-----------------+
|   CartItem     |        |   CartModel     |
|----------------|        |-----------------|
| id, menuItemId |◆──────*| id, restaurantId|
| menuItemName   |        | items: List     |
| menuItemImageUrl|       | subtotal,       |
| quantity       |        | deliveryFee,    |
| unitPrice      |        | total           |
| subtotal       |        +-----------------+
| specialInstr.  |
+----------------+
         │
         ▼ used by
+----------------------+        +----------------------+
|   CartRepository     |◀───────│      CartCubit       |
|----------------------|        |----------------------|
| + fetchCart          |        | + loadCart           |
| + addItem            |        | + addItem            |
| + updateItem         |        | + increaseQty        |
| + removeItem         |        | + decreaseQty        |
| + clearCart          |        | + removeItem         |
+----------------------+        | + clearCart          |
                                +----------------------+
```

### 7.4. Order feature

```
+----------------------+
|  OrderSummaryModel   |  (cho list)
+----------------------+

+----------------------+         +------------------------+
|  OrderDetailModel    |◆───────*|     OrderItemModel     |
|----------------------|         +------------------------+
| id, orderNumber      |
| status               |         +------------------------+
| restaurantName       |◆───────*|OrderStatusHistoryModel |
| restaurantPhone      |         +------------------------+
| deliveryAddressSnap. |
| items, statusHistory |
| subtotal, fee, disc. |
| totalAmount          |
| paymentMethod/Status |
| estimatedDeliveryAt  |
| deliveredAt          |
| cancelledAt/reason   |
+----------------------+

+----------------------+
|  PaymentInfoModel    |
+----------------------+

+----------------------+
|   OrderRepository    |   used by Screens trực tiếp (no Cubit)
|----------------------|
| + getMyOrders        |
| + getOrderDetail     |
| + placeOrder         |
| + cancelOrder        |
| + updateOrderStatus  |
| + getRestaurantOrders|
| + getPaymentByOrder  |
+----------------------+

+----------------------+
| OrderTrackingScreen  |   ── uses StompClient + Timer 15s
|----------------------|
| - stompClient        |
| - timer              |
| - _socketConnected   |
| + _connectRealtime   |
| + _load(silent)      |
+----------------------+
```

### 7.5. Restaurant feature

```
+----------------------+        +----------------------+
|  RestaurantSummary   |        |  RestaurantDetail    |
|----------------------|        |----------------------|
| id, name, slug       |        | id, name, slug       |
| cuisineType          |        | description          |
| rating_avg, count    |        | logoUrl, bannerUrl   |
| deliveryFee          |        | phone, email         |
| logoUrl, distance    |        | streetAddress, city  |
+----------------------+        | rating, deliveryFee  |
                                | minOrderAmount       |
                                | estimatedMinutes     |
                                | operatingHours[]     |
                                +----------------------+

+----------------------+        +------------------------------+
|   MenuCategory       |◆──────*|      MenuItemModel           |
|----------------------|        +------------------------------+
| id, name, items[]    |
+----------------------+

+----------------------------+
|   RestaurantRepository     |
|----------------------------|
| + fetchRestaurants(filter) |
| + fetchRestaurantDetail    |
| + fetchMenu                |
| + fetchMenuItem            |
| + createCategory/MenuItem  |
| + updateMenuItem           |
| + deleteMenuItem/Category  |
+----------------------------+
        ▲
        │ used by
+-------+------------+        +----------------------+
|RestaurantDetailCubit|       |   DiscoverCubit      |
|--------------------|        |----------------------|
| + load             |        | + loadRestaurants    |
| + addItemToCart    |        +----------------------+
+--------------------+
```

### 7.6. Profile feature

```
+----------------------+        +----------------------+
|  UserProfileModel    |        |    AddressModel      |
|----------------------|        |----------------------|
| id, email            |        | id, label            |
| firstName, lastName  |        | streetLine1/2        |
| phoneNumber, role    |        | city, state, postal  |
| profilePictureUrl    |        | countryCode='VN'     |
| emailVerified        |        | latitude, longitude  |
+----------------------+        | defaultAddress       |
                                +----------------------+

+----------------------+
|   UserRepository     |   used by ProfileScreen / SavedAddresses /
|----------------------|   AddAddressScreen / EditProfileScreen
| + getProfile         |   (không có Cubit — state local)
| + updateProfile      |
| + getAddresses       |
| + addAddress         |
| + updateAddress      |
| + deleteAddress      |
+----------------------+
```

### 7.7. Quan hệ tổng

```
TokenStorage ─── used by ───▶ ApiClient ─── used by ───▶ All Repositories
                                                              │
   ┌─────── AuthRepository      ── used by ──▶ AuthCubit       │
   │                                                            │
MultiRepositoryProvider ─── provides ───▶  RestaurantRepository ─▶ DiscoverCubit, RestaurantDetailCubit
                                       │                       │
                                       ├─▶ CartRepository ─▶ CartCubit, RestaurantDetailCubit
                                       ├─▶ UserRepository ─▶ Profile screens (no Cubit)
                                       ├─▶ OrderRepository ─▶ Order screens (no Cubit)
                                       └─▶ ReviewRepository ─▶ Review dialog (no Cubit)

AuthCubit ── stream ──▶ GoRouterRefreshStream ── refreshListenable ──▶ GoRouter ── redirect() ──▶ Navigation
```

---

## 8. Luồng nguyên lý hoạt động

### Ví dụ end-to-end: **"Khách hàng đặt món Phở từ giỏ → giao đến nhà"**

#### Bước 1 — User interaction (Flutter)

1. User mở app → `main.dart` → `FoodRushApp` → `SplashScreen` (`/`).
2. `AuthCubit.bootstrap()` đọc `TokenStorage`:
   - `isOnboardingSeen` = true (đã onboard)
   - `hasValidAccessToken()` = true (token còn 10 phút)
   - → emit `authenticated` + `userRole='CUSTOMER'`
3. `GoRouter.refreshListenable` nhận stream change → redirect `/` → `/home`.
4. `HomeShellScreen` hiển thị bottom-nav 4 tab → mặc định tab Khám phá → `DiscoverScreen`.

#### Bước 2 — Frontend processing

5. `DiscoverCubit.loadRestaurants()` → `RestaurantRepository.fetchRestaurants()`.
6. `ApiClient.get('/restaurants', query: {sortBy: 'rating', page: 0, size: 20})`.
7. **Dio interceptor `onRequest`** đính `Authorization: Bearer <accessToken>`.

#### Bước 3 — API communication

8. Request đi tới `http://10.0.2.2:8080/api/v1/restaurants` (Android emulator) hoặc `localhost:8080/...` (iOS/web).
9. Backend trả về `{success:true, data:{content:[...], totalElements:4, totalPages:1}, timestamp}`.
10. `ApiClient._unwrap()` → trả `data` cho repository, repository map `data.content` thành `List<RestaurantSummary>`.

#### Bước 4 — Business logic Backend

11. User tap nhà hàng "Phở Hà Nội Ngon" → `/restaurants/1`.
12. `RestaurantDetailCubit.load()` chạy 2 request song song:
    - `GET /restaurants/1` → `RestaurantDetail`
    - `GET /restaurants/1/menu` → `List<MenuCategory>` (với items embed)
13. User tap "Phở bò tái" → `/restaurants/1/items/1` → `ItemDetailScreen` → tap "Thêm vào giỏ".
14. `RestaurantDetailCubit.addItemToCart(1)` → `CartRepository.addItem(menuItemId=1, qty=1)`.
15. `POST /api/v1/cart/items` → Backend `CartService.addItem`:
    - Check `menuItem.available` (CART_002 nếu false)
    - Tìm cart hiện tại hoặc tạo mới (`user_id UNIQUE`)
    - Check `cart.restaurant_id` khớp (CART_003 nếu khác)
    - `CartItem.unit_price = menuItem.price` (snapshot)
    - Save và return `CartResponse`
16. App emit `successMessage='Đã thêm món vào giỏ'`.

#### Bước 5 — Checkout & Place Order

17. User vào tab Đơn → tap icon Giỏ hàng → `/cart` → tap "Đặt hàng" → `/checkout`.
18. `CheckoutScreen.initState` chạy song song:
    - `cartRepository.fetchCart()` → `CartModel`
    - `userRepository.getAddresses()` → `List<AddressModel>`
    - Auto-select `defaultAddress=true`
19. User nhập promo `FIRST10`, chọn `paymentMethod=COD`, viết note → tap "Đặt hàng".
20. `orderRepository.placeOrder(addressId, paymentMethod, promo, note)`.
21. `POST /api/v1/orders` → Backend `OrderService.placeOrder` (transactional):
    - Lấy cart, kiểm items không rỗng (CART_001)
    - Verify address ownership
    - Tính `subtotal`, check ≥ `min_order_amount` (ORDER_002)
    - Validate promo: active, in date, used < limit, min_order, calc discount cap by max
    - Build address snapshot JSON
    - Generate `order_number = FR-20260515-00001`
    - Save `Order PENDING + items + history[PENDING]`
    - Save `Payment(PENDING)`
    - `promoCode.usedCount++`
    - `cart.clear()`
    - `SimpMessagingTemplate.convertAndSendToUser(userId, "/queue/orders/{id}/status", message)`
    - `notificationService.sendOrderStatusUpdate @Async` → Firebase Messaging

#### Bước 6 — Database & DB interaction

22. Hibernate INSERT vào `orders`, cascade `order_items`, `order_status_history`.
23. `@CreatedDate` / `@LastModifiedDate` set tự động bởi `AuditingEntityListener` (`AuditConfig`).
24. `payments` INSERT với status `PENDING`.
25. `cart_items` DELETE cascade khi `cart.items.clear() + save`.

#### Bước 7 — Real-time tracking

26. App navigate `/orders/{id}/tracking` → `OrderTrackingScreen`.
27. `initState` chạy:
    - `_load()` lần đầu: REST `GET /orders/{id}` → `OrderDetailModel`
    - `_connectRealtimeChannel()`: STOMP CONNECT `/ws` với Bearer token → SUBSCRIBE `/user/queue/orders/{id}/status`
    - `Timer.periodic(15s)`: poll silent fallback
28. NH owner mở `/admin/orders?restaurantId=1`, tap đơn → cập nhật status `CONFIRMED`:
    - `PUT /api/v1/orders/{id}/status {status: CONFIRMED}`
    - Backend `OrderService.updateStatus` validate transition `PENDING → CONFIRMED` ✓
    - Lưu history, broadcast STOMP + FCM
29. Stomp client nhận message → callback gọi `_load(silent: true)` → re-fetch để có dữ liệu canonical (không trust payload socket).
30. Timeline cập nhật.

#### Bước 8 — Giao hàng

31. Shipper (web Thymeleaf `/shipper/dashboard`) thấy đơn `READY_FOR_PICKUP` → accept → `PICKED_UP`.
32. Shipper update `ON_THE_WAY` → `DELIVERED` → `orders.delivered_at = now()`.
33. Mỗi step backend broadcast → app cập nhật timeline real-time.
34. Khi `DELIVERED`, shipper tap "Xác nhận đã thu tiền COD" → `PATCH /api/v1/payments/orders/{id}/confirm-cod` → `Payment.status = PAID`.

#### Bước 9 — Review

35. App push notification "Đơn hàng đã được giao thành công 🍜".
36. User vào `/orders/{id}` → tap "Đánh giá".
37. `POST /api/v1/reviews {orderId, rating: 5, comment}` → Backend save + tăng `restaurant.rating_avg`/`count`.

#### Bước 10 — Cache & Notification

- **Redis:** Khi user logout / refresh token, backend SET `revoked:token:{hash}` TTL 30 ngày → các request sau với token này bị reject.
- **FCM:** Push không chặn response (`@Async`). Token FCM được app upload qua `PUT /users/me/fcm-token` khi user login lần đầu.

---

## 9. Phân tích nghiệp vụ

### 9.1. Business rules chính (đã verify trong code)

| Rule | Vị trí code | Mô tả |
|---|---|---|
| Email/Phone unique | `AuthServiceImpl.register` | Trùng → `AUTH_003` / `AUTH_004` |
| Password hashed BCrypt strength 12 | `SecurityConfig.passwordEncoder` | |
| JWT access 15 phút, refresh 30 ngày | `application.yml`: `jwt.access-token-expiry: 900`, `jwt.refresh-token-expiry: 2592000` | |
| Refresh token rotation | `AuthServiceImpl.refreshToken` | Token cũ → Redis blacklist trước khi gen mới |
| Reset password token TTL 30 phút | `AuthServiceImpl.RESET_TOKEN_EXPIRY_MINUTES` | |
| Email enumeration protection | `AuthServiceImpl.forgotPassword` | Email không tồn tại vẫn trả 200 |
| 1 user — 1 cart | `carts.user_id UNIQUE` (V4) | |
| Cart bị khoá theo 1 nhà hàng | `CartServiceImpl.addItem` | Conflict → `CART_003` |
| Món không available → reject | `CartServiceImpl.addItem` | `CART_002` |
| Order phải đạt `min_order_amount` | `OrderServiceImpl.placeOrder` | `ORDER_002` |
| Order chỉ hủy khi PENDING/CONFIRMED | `OrderServiceImpl.cancelOrder` | `ORDER_001` |
| State machine 8 trạng thái có ràng buộc | `OrderServiceImpl.validateStatusTransition` | `ORDER_003` |
| 1 Order ↔ 1 Payment | `payments.order_id UNIQUE` (V6) | |
| 1 Order ↔ 1 Review, chỉ sau DELIVERED | `reviews.order_id UNIQUE` + `ReviewServiceImpl` | |
| Rating 1..5 | `reviews.rating CHECK` | |
| Promo: active + in date + used<limit + minOrder | `OrderServiceImpl.validatePromoCode` | |
| Promo PERCENTAGE bị cap bởi `max_discount_amount` | same | |
| Address snapshot JSON tại thời điểm đặt | `OrderServiceImpl.buildAddressSnapshot` | Tránh "rewrite history" khi user xóa địa chỉ |
| Order number format `FR-yyyyMMdd-00001` | `OrderServiceImpl.generateOrderNumber` | |
| Cart `unit_price` snapshot khi add | `CartServiceImpl.addItem` | Đề phòng NH đổi giá sau |
| Restaurant slug unique, append timestamp nếu trùng | `RestaurantServiceImpl.create` | |

### 9.2. State machine `OrderStatus`

```
   ┌─────────────────────────────────────────────────────────────────────┐
   │                                                                     │
   ▼                                                                     │
PENDING ──→ CONFIRMED ──→ PREPARING ──→ READY_FOR_PICKUP ──→ PICKED_UP ──┤
   │            │              ▲                                         │
   │            │              └─ (Restaurant Admin)                     │
   ▼            ▼                                                         │
CANCELLED   CANCELLED                                                     │
                                                                          │
                                                              ON_THE_WAY ─┘
                                                                  │
                                                                  ▼
                                                             DELIVERED
```

| From → To | Cho phép | Ai làm |
|---|---|---|
| `PENDING → CONFIRMED` | ✓ | Restaurant Admin |
| `PENDING → CANCELLED` | ✓ | Customer hoặc Restaurant Admin |
| `CONFIRMED → PREPARING` | ✓ | Restaurant Admin |
| `CONFIRMED → CANCELLED` | ✓ | Customer hoặc Restaurant Admin |
| `PREPARING → READY_FOR_PICKUP` | ✓ | Restaurant Admin |
| `READY_FOR_PICKUP → PICKED_UP` | ✓ | Delivery Agent (accept order) |
| `PICKED_UP → ON_THE_WAY` | ✓ | Delivery Agent |
| `ON_THE_WAY → DELIVERED` | ✓ | Delivery Agent |
| Mọi transition khác | ✗ → `ORDER_003` | |

### 9.3. Role permission (Spring Security `@PreAuthorize`)

| Endpoint | Role yêu cầu |
|---|---|
| `POST /api/v1/orders` | `CUSTOMER` |
| `GET /api/v1/orders` (my) | `CUSTOMER` |
| `PATCH /api/v1/orders/{id}/cancel` | `CUSTOMER` |
| `PUT /api/v1/orders/{id}/status` | `RESTAURANT_ADMIN`, `DELIVERY_AGENT`, `SYSTEM_ADMIN` |
| `GET /api/v1/restaurants/{id}/orders` | `RESTAURANT_ADMIN`, `SYSTEM_ADMIN` |
| `PATCH /api/v1/payments/orders/{id}/confirm-cod` | `DELIVERY_AGENT`, `SYSTEM_ADMIN` |
| `POST/PUT /api/v1/restaurants` | `RESTAURANT_ADMIN`, `SYSTEM_ADMIN` |
| `DELETE /api/v1/restaurants/{id}` | `SYSTEM_ADMIN` |
| `POST/PUT/DELETE /menu/**` | `RESTAURANT_ADMIN`, `SYSTEM_ADMIN` |
| `GET /api/v1/restaurants/**` | **permitAll** (xem chi tiết NH không cần login) |
| `/api/v1/auth/**` | permitAll |
| `/admin/**` (web SSR) | `SYSTEM_ADMIN` (FormLogin) |
| `/owner/**` (web SSR) | `RESTAURANT_ADMIN` (FormLogin) |
| `/shipper/**` (web SSR) | `DELIVERY_AGENT` (FormLogin) |

### 9.4. Validation (Bean Validation + DTO `@Valid`)

| DTO | Constraint |
|---|---|
| `RegisterRequest` | `email @Email`, `password @Size(min=8)`, `phoneNumber @Pattern` |
| `LoginRequest` | `email @NotBlank`, `password @NotBlank` |
| `AddToCartRequest` | `menuItemId @NotNull`, `quantity @Min(1)` |
| `PlaceOrderRequest` | `deliveryAddressId @NotNull`, `paymentMethod @NotNull` |
| `CreateReviewRequest` | `orderId @NotNull`, `rating @Min(1) @Max(5)` |
| `AddressRequest` | `label, streetLine1, city, state, postalCode @NotBlank` |

Client side Flutter chỉ làm validation cơ bản (regex email, password length ≥ 8). Validation chủ yếu chịu trách nhiệm bởi backend.

### 9.5. Error handling

**Format chuẩn API:**
```json
{
  "success": false,
  "errorCode": "ORDER_002",
  "message": "Đơn hàng tối thiểu 50000đ",
  "details": null,
  "timestamp": "2026-05-15T10:30:00"
}
```

**Bảng mã lỗi (verify trong code):**

| Code | Ngữ cảnh |
|---|---|
| `AUTH_003` | Email đã được sử dụng |
| `AUTH_004` | Số điện thoại đã được sử dụng |
| `AUTH_005` | Reset password token không hợp lệ |
| `AUTH_006` | Reset password token hết hạn |
| `AUTH_007` | Email verification token không hợp lệ |
| `AUTH_008` | Email đã verify từ trước |
| `CART_001` | Giỏ hàng trống |
| `CART_002` | Món ăn không có sẵn |
| `CART_003` | Giỏ đang có món NH khác |
| `ORDER_001` | Không thể hủy ở trạng thái hiện tại |
| `ORDER_002` | Dưới min order amount |
| `ORDER_003` | Status transition không hợp lệ |
| `FORBIDDEN` | Truy cập đơn của user khác |

**Xử lý phía Flutter:**

```
Dio response.data.success == false
     ↓
ApiClient._unwrap throws ApiException(message, errorCode, statusCode, details)
     ↓
Repository.xxx() rethrows
     ↓
Cubit catch ApiException → emit(state.copyWith(errorMessage: e.message))
     ↓
BlocListener / BlocBuilder → ScaffoldMessenger.showSnackBar(e.message)
```

Trường hợp `errorMessage` cần action đặc biệt:
- `CART_003` (cart conflict) → Screen show dialog "Xóa giỏ hàng cũ?"
- `ORDER_001` (không thể hủy) → SnackBar thông báo
- `401` chung → ApiClient không tự refresh — app sẽ giữ ở 401 cho đến khi user dùng → expire local check trong `TokenStorage.hasValidAccessToken` đẩy về `/login`

### 9.6. Data flow nghiệp vụ tổng

```
Cart items với unit_price snapshot
        │
        ▼
[ Customer ] ─→ Place Order (transactional)
        │
        ├──→ Order PENDING + items + history[PENDING]
        ├──→ Payment(PENDING)
        ├──→ promoCode.usedCount++
        ├──→ cart cleared
        ├──→ WS broadcast /queue/orders/{id}/status
        └──→ FCM push @Async

[ Restaurant Admin ] ─→ Update status PENDING→CONFIRMED→PREPARING→READY_FOR_PICKUP
                              └──→ each transition: history++, WS broadcast, FCM

[ Delivery Agent ] ─→ Accept (PICKED_UP) → ON_THE_WAY → DELIVERED
                              └──→ delivered_at=now, WS broadcast, FCM
                              └──→ Confirm COD → Payment.status=PAID

[ Customer ] ─→ Create Review (only if DELIVERED, only once)
                              └──→ rating_avg/count update
```

---

## 10. Plan thực hiện công việc

### Phase 1 — Khảo sát source code

| Phase | Task | Input | Output | Estimate | Note |
|---|---|---|---|---|---|
| 1.1 | Đọc README + `pubspec.yaml` + `pom.xml` | Repo root | Tech stack list | 1h | Flutter 3.9.2, Spring Boot 3.2.4 |
| 1.2 | Liệt kê feature Flutter + screen | `food_app/lib/features/` | 11 feature, 63 file Dart, danh sách screen | 2h | |
| 1.3 | Liệt kê package backend | `server_app_foot/src` | 13 module Java | 1h | Chỉ tóm tắt |
| 1.4 | Đọc `app.dart` + routing | `food_app/lib/app.dart` | Sơ đồ route + guard | 1.5h | go_router redirect logic |

### Phase 2 — Phân tích kiến trúc

| Phase | Task | Input | Output | Estimate | Note |
|---|---|---|---|---|---|
| 2.1 | Vẽ kiến trúc tổng (Client → API → DB) | All config | Diagram tổng | 1.5h | |
| 2.2 | Phân tích Network/Storage layer | `core/network`, `core/storage` | Sequence Dio interceptor + Secure Storage fallback | 2h | |
| 2.3 | Phân tích State management (Cubit) | `auth_cubit`, `cart_cubit`, `discover_cubit`, `restaurant_detail_cubit` | Bảng Cubit + scope | 2h | |
| 2.4 | Phân tích WebSocket flow | `order_tracking_screen.dart` | Sequence STOMP + polling fallback | 1.5h | |
| 2.5 | Backend security tóm tắt | `SecurityConfig` | Bảng filter chain + RBAC | 1h | |

### Phase 3 — Phân tích DB

| Phase | Task | Input | Output | Estimate | Note |
|---|---|---|---|---|---|
| 3.1 | Đọc V1..V11 Flyway migration | `db/migration/` | Bảng 14 entity | 2h | |
| 3.2 | Phân tích quan hệ + CASCADE | Same | DBML ERD | 2h | dbdiagram.io |
| 3.3 | Mapping JPA entity ↔ table | `*/entity/*.java` | Bảng cột chi tiết | 1.5h | |
| 3.4 | Hiểu seed data V11 | V11 | Domain mẫu | 1h | 8 user, 4 NH, 10 order các status |

### Phase 4 — Phân tích nghiệp vụ

| Phase | Task | Input | Output | Estimate | Note |
|---|---|---|---|---|---|
| 4.1 | Đọc `OrderServiceImpl` | order/service | State machine + promo logic | 3h | Core nhất |
| 4.2 | Đọc `CartServiceImpl` | cart/service | Conflict rule + qty=0 delete | 1.5h | |
| 4.3 | Đọc `AuthServiceImpl` | auth/service | Token rotate + reset flow | 2h | |
| 4.4 | Đọc `RestaurantServiceImpl` | restaurant/service | Geo-search + sort | 1.5h | |
| 4.5 | Tổng hợp role permission `@PreAuthorize` | All controllers | Bảng RBAC | 1h | |

### Phase 5 — Vẽ diagram

| Phase | Task | Input | Output | Estimate | Note |
|---|---|---|---|---|---|
| 5.1 | Use Case 4 actor | Phase 4 | UC list | 2h | |
| 5.2 | Sequence auth (4) | Phase 4.3 | Login/Register/Refresh/Logout | 2h | sequencediagram.org |
| 5.3 | Sequence order flow (5) | Phase 4.1, 4.2 | Cart/PlaceOrder/Cancel/Tracking/Review | 3h | |
| 5.4 | Sequence aux (4) | Phase 2 | JWT filter, geo search, forgot, admin add item | 2h | |
| 5.5 | Class diagram Flutter | Phase 2.3 | Core + 5 feature class diagram | 2h | |
| 5.6 | ERD DBML | Phase 3 | dbdiagram.io paste | 1h | |

### Phase 6 — Review tài liệu

| Phase | Task | Input | Output | Estimate | Note |
|---|---|---|---|---|---|
| 6.1 | Đối chiếu sequence với code | Doc + source | Fix sai khớp | 2h | |
| 6.2 | Verify ERD với migration | Doc + Flyway | OK | 1h | |
| 6.3 | Stakeholder review (BA/Dev) | Doc complete | Feedback | 4h | |
| 6.4 | Cập nhật final | Feedback | v1.0 | 3h | |

**Tổng effort:** ~46 giờ ≈ 6 ngày làm việc cho 1 BA/Tech Lead.

---

## Phụ lục — Tài liệu/Code cần đọc thêm

Nếu cần phân tích sâu hơn, đáng đọc tiếp:

**App Flutter:**
- `food_app/lib/features/order/presentation/screens/checkout_screen.dart` (full) — validation FE
- `food_app/lib/features/cart/presentation/cart_screen.dart` — UX cart
- `food_app/lib/features/discover/presentation/discover_screen.dart` — filter UI
- `food_app/lib/features/admin/presentation/screens/admin_add_edit_item_screen.dart` — quản lý menu trong app
- `food_app/lib/core/utils/formatters.dart` — format date/currency

**Backend (chỉ phần app cần):**
- `server_app_foot/src/main/java/com/foodrush/order/repository/OrderRepository.java` — custom @Query (filter restaurant orders, find nearby)
- `server_app_foot/src/main/java/com/foodrush/restaurant/repository/RestaurantRepository.java` — công thức haversine
- `server_app_foot/src/main/java/com/foodrush/common/service/EmailServiceImpl.java` — template email
- `server_app_foot/src/main/java/com/foodrush/common/exceptions/*` — GlobalExceptionHandler

---

**Tài liệu được sinh hoàn toàn từ phân tích source code thực tế** (`/mnt/e/food-app/food_app/` 63 file Dart + `/mnt/e/food-app/server_app_foot/` 141 file Java + 11 Flyway migration).

Sequence diagram đã được viết theo syntax **sequencediagram.org** và có thể paste trực tiếp. ERD theo **DBML** format paste vào dbdiagram.io.
