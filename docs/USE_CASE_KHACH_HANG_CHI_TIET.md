# 8 Use Case Khách hàng — Phân rã chi tiết theo Source Code

> Mỗi diagram dưới đây **map 1-1 với API endpoint thực tế** (Spring Boot Controller) và **logic Cubit/Repository** trong Flutter.
> Render tại https://www.plantuml.com/plantuml/uml/ (paste code giữa `@startuml ... @enduml`).

---

## UC1. Đăng ký / Đăng nhập

> **Backend:** `auth/controller/AuthController.java`, `auth/service/AuthServiceImpl.java`
> **Frontend:** `features/auth/data/auth_repository.dart`, `features/auth/logic/auth_cubit.dart`
> **API:** `/api/v1/auth/**`

```plantuml
@startuml UC1_DangKy_DangNhap
title UC1. Đăng ký / Đăng nhập

left to right direction
skinparam usecase {
  BackgroundColor #FFF6E5
  BorderColor #E85B2E
}

actor "Khách hàng" as KH

rectangle "Module Auth (AuthController + AuthServiceImpl)" {

  usecase "UC1.1 Đăng ký tài khoản\n(POST /auth/register)"        as UC11
  usecase "UC1.2 Đăng nhập\n(POST /auth/login)"                    as UC12
  usecase "UC1.3 Đăng xuất\n(POST /auth/logout)"                   as UC13
  usecase "UC1.4 Quên mật khẩu\n(POST /auth/forgot-password)"      as UC14
  usecase "UC1.5 Đặt lại mật khẩu\n(POST /auth/reset-password)"    as UC15
  usecase "UC1.6 Xác thực email\n(GET /auth/verify-email)"         as UC16
  usecase "UC1.7 Làm mới token\n(POST /auth/refresh)"              as UC17

  ' Internal flows
  usecase "Sinh JWT access+refresh\n(JwtUtil)"                     as JWT
  usecase "Hash password\n(BCrypt strength 12)"                    as BCRYPT
  usecase "Gửi email verify\n(EmailService @Async)"                as EMAIL
  usecase "Lưu token blacklist\n(Redis SETEX 30d)"                 as REDIS
}

KH --> UC11
KH --> UC12
KH --> UC13
KH --> UC14
KH --> UC15
KH --> UC16

' Đăng ký flow
UC11 ..> BCRYPT  : <<include>>
UC11 ..> EMAIL   : <<include>>\n(verification)
UC11 ..> JWT     : <<include>>
UC11 ..> UC16    : <<extend>>\n(verify sau)

' Đăng nhập flow
UC12 ..> BCRYPT  : <<include>>\n(match)
UC12 ..> JWT     : <<include>>
UC12 ..> UC17    : <<extend>>\n(khi token gần hết)

' Đăng xuất / Refresh
UC13 ..> REDIS   : <<include>>
UC17 ..> REDIS   : <<include>>\n(rotation)
UC17 ..> JWT     : <<include>>

' Forgot/Reset
UC14 ..> EMAIL   : <<include>>\n(reset link, TTL 30m)
UC14 ..> UC15    : <<extend>>
UC15 ..> BCRYPT  : <<include>>

@enduml
```

**Error codes:** `AUTH_003` Email đã dùng · `AUTH_004` Phone đã dùng · `AUTH_005` Reset token sai · `AUTH_006` Reset token hết hạn · `AUTH_007` Verify token sai · `AUTH_008` Email đã verify

---

## UC2. Tìm kiếm Nhà hàng / Món

> **Backend:** `restaurant/controller/RestaurantController.java::getRestaurants(...)`
> **Frontend:** `features/discover/data/restaurant_repository.dart::fetchRestaurants(...)`
> **API:** `GET /api/v1/restaurants?city&cuisineType&search&isOpen&lat&lng&maxDistanceKm&page&size&sortBy`

```plantuml
@startuml UC2_TimKiem
title UC2. Tìm kiếm Nhà hàng / Món

left to right direction
skinparam usecase {
  BackgroundColor #FFF6E5
  BorderColor #E85B2E
}

actor "Khách hàng" as KH

rectangle "Module Discover / Search\n(RestaurantController.getRestaurants)" {

  usecase "UC2.1 Tìm theo từ khoá\n(query: search)"          as UC21
  usecase "UC2.2 Lọc theo thành phố\n(query: city)"          as UC22
  usecase "UC2.3 Lọc theo cuisine\n(query: cuisineType)"     as UC23
  usecase "UC2.4 Lọc NH đang mở\n(query: isOpen=true)"       as UC24
  usecase "UC2.5 Tìm NH gần\n(query: lat,lng,maxDistanceKm)" as UC25
  usecase "UC2.6 Sắp xếp\n(sortBy: rating/deliveryTime/distance)" as UC26
  usecase "Phân trang\n(page, size — default 20)"            as PAGE
}

KH --> UC21
KH --> UC22
KH --> UC23
KH --> UC24
KH --> UC25

UC21 ..> UC22 : <<extend>>
UC21 ..> UC23 : <<extend>>
UC21 ..> UC24 : <<extend>>
UC21 ..> UC25 : <<extend>>\n(geo search\nfindNearby)
UC21 ..> UC26 : <<include>>\n(mặc định rating DESC)
UC21 ..> PAGE : <<include>>

@enduml
```

**Logic:** Nếu có `lat & lng` → `RestaurantRepository.findNearby` (haversine + filter). Ngược lại → `findWithFilters`.

---

## UC3. Xem menu

> **Backend:** `restaurant/controller/RestaurantController` + `menu/controller/MenuController`
> **Frontend:** `features/restaurant/logic/restaurant_detail_cubit.dart`
> **API:** `GET /restaurants/{idOrSlug}` · `GET /restaurants/{id}/menu` · `GET /restaurants/{id}/menu/items/{itemId}` · `GET /restaurants/{id}/reviews`

```plantuml
@startuml UC3_XemMenu
title UC3. Xem Menu

left to right direction
skinparam usecase {
  BackgroundColor #FFF6E5
  BorderColor #E85B2E
}

actor "Khách hàng" as KH

rectangle "Module Restaurant + Menu" {

  usecase "UC3.1 Xem chi tiết NH\n(GET /restaurants/{idOrSlug})" as UC31
  usecase "UC3.2 Xem menu theo danh mục\n(GET /restaurants/{id}/menu)" as UC32
  usecase "UC3.3 Xem chi tiết món\n(GET /menu/items/{itemId})" as UC33
  usecase "UC3.4 Xem đánh giá NH\n(GET /restaurants/{id}/reviews)" as UC34
  usecase "UC3.5 Xem giờ hoạt động\n(từ operating_hours embed)" as UC35
  usecase "Hiển thị rating\n(rating_avg + rating_count)" as RATING
  usecase "Hiển thị min order +\ndelivery fee + estimated time" as INFO
}

KH --> UC31
KH --> UC32
KH --> UC33
KH --> UC34

UC31 ..> UC32   : <<include>>\n(RestaurantDetailCubit.load\nload 2 API song song)
UC31 ..> UC35   : <<include>>
UC31 ..> RATING : <<include>>
UC31 ..> INFO   : <<include>>
UC32 ..> UC33   : <<extend>>\n(tap món)
UC31 ..> UC34   : <<extend>>

note bottom of UC31
  Hỗ trợ cả ID số và slug:
  /restaurants/1
  /restaurants/pho-ha-noi-ngon
end note

@enduml
```

---

## UC4. Quản lý giỏ hàng

> **Backend:** `cart/controller/CartController.java`, `cart/service/CartServiceImpl.java`
> **Frontend:** `features/cart/data/cart_repository.dart`, `features/cart/logic/cart_cubit.dart`
> **DB constraint:** `carts.user_id UNIQUE` — 1 user — 1 cart — 1 NH

```plantuml
@startuml UC4_GioHang
title UC4. Quản lý giỏ hàng

left to right direction
skinparam usecase {
  BackgroundColor #FFF6E5
  BorderColor #E85B2E
}

actor "Khách hàng" as KH

rectangle "Module Cart (CartServiceImpl)" {

  usecase "UC4.1 Xem giỏ hàng\n(GET /cart)"             as UC41
  usecase "UC4.2 Thêm món vào giỏ\n(POST /cart/items)"  as UC42
  usecase "UC4.3 Cập nhật số lượng\n(PUT /cart/items/{id})" as UC43
  usecase "UC4.4 Xóa món khỏi giỏ\n(DELETE /cart/items/{id})" as UC44
  usecase "UC4.5 Xóa toàn bộ giỏ\n(DELETE /cart)"        as UC45

  ' Internal validation
  usecase "Check món available\n(menuItem.available)"    as CHECK_AVAIL
  usecase "Check cùng nhà hàng\n(CART_003 nếu khác)"     as CHECK_RES
  usecase "Snapshot unit_price\n(giá tại thời điểm add)" as SNAPSHOT
  usecase "Auto-delete khi qty=0"                        as AUTO_DEL
  usecase "Reset restaurant_id\nkhi giỏ rỗng"            as RESET_RES
}

KH --> UC41
KH --> UC42
KH --> UC43
KH --> UC44
KH --> UC45

UC42 ..> CHECK_AVAIL : <<include>>
UC42 ..> CHECK_RES   : <<include>>
UC42 ..> SNAPSHOT    : <<include>>

UC43 ..> AUTO_DEL    : <<extend>>\n(qty=0 → xóa)
UC44 ..> RESET_RES   : <<extend>>\n(nếu giỏ rỗng)
UC45 ..> RESET_RES   : <<include>>

@enduml
```

**Error codes:** `CART_001` Giỏ trống · `CART_002` Món không available · `CART_003` Khác nhà hàng

---

## UC5. ⭐ ĐẶT HÀNG (Trung tâm)

> **Backend:** `order/controller/OrderController.java`, `order/service/OrderServiceImpl.java::placeOrder`
> **Frontend:** `features/order/presentation/screens/checkout_screen.dart`
> **API:** `POST /api/v1/orders` · `PATCH /api/v1/orders/{id}/cancel`
> **Transactional:** Toàn bộ flow đặt hàng nằm trong 1 `@Transactional`

```plantuml
@startuml UC5_DatHang
title UC5. ⭐ Đặt hàng (Chức năng trung tâm)

left to right direction
skinparam usecase {
  BackgroundColor #FFF6E5
  BorderColor #E85B2E
}

actor "Khách hàng" as KH

rectangle "Module Order — OrderServiceImpl.placeOrder (Transactional)" {

  usecase "**UC5.1 Đặt hàng**\n(POST /orders)" as UC51 #FFB74D

  ' --- Include (bắt buộc) ---
  usecase "Lấy giỏ hàng hiện tại\n(throw CART_001 nếu trống)" as STEP1
  usecase "Verify địa chỉ thuộc user" as STEP2
  usecase "Tính subtotal\nkiểm min_order_amount\n(ORDER_002)" as STEP3
  usecase "Validate promo code\n(active/date/limit/min)" as STEP4
  usecase "Build address snapshot JSON" as STEP5
  usecase "Sinh order_number\nFR-yyyyMMdd-00001" as STEP6
  usecase "Save Order PENDING\n+ OrderItems\n+ StatusHistory[PENDING]" as STEP7
  usecase "Save Payment PENDING" as STEP8
  usecase "promo.usedCount++" as STEP9
  usecase "Clear cart" as STEP10
  usecase "Broadcast WebSocket\n/user/queue/orders/{id}/status" as STEP11
  usecase "Send FCM push @Async" as STEP12

  ' --- Extend ---
  usecase "UC5.7 Hủy đơn hàng\n(PATCH /orders/{id}/cancel)" as UC57
}

KH --> UC51
KH --> UC57

UC51 ..> STEP1  : <<include>>
UC51 ..> STEP2  : <<include>>
UC51 ..> STEP3  : <<include>>
UC51 ..> STEP4  : <<include>>
UC51 ..> STEP5  : <<include>>
UC51 ..> STEP6  : <<include>>
UC51 ..> STEP7  : <<include>>
UC51 ..> STEP8  : <<include>>
UC51 ..> STEP9  : <<extend>>\n(nếu có promo)
UC51 ..> STEP10 : <<include>>
UC51 ..> STEP11 : <<include>>
UC51 ..> STEP12 : <<include>>

UC51 <.. UC57   : <<extend>>\n(chỉ khi status\n= PENDING/CONFIRMED\nelse ORDER_001)

note bottom of UC51
  Validate transition: ORDER_003
  total = subtotal + deliveryFee - discount
  estimatedDeliveryAt = now + restaurant.estimatedDeliveryMinutes
end note

@enduml
```

**Error codes:** `CART_001` Giỏ trống · `ORDER_002` Dưới min order · `ORDER_001` Không thể huỷ · `ORDER_003` Status transition sai · `FORBIDDEN` Đơn không phải của user

---

## UC6. Thanh toán

> **Backend:** `payment/controller/PaymentController.java`, `payment/service/PaymentServiceImpl.java`
> **Entity:** `Payment` (1:1 với Order — `payments.order_id UNIQUE`)
> **Enum:** `PaymentMethod{COD, CREDIT_CARD, MOMO, ZALOPAY}` · `PaymentStatus{PENDING, PAID, FAILED, REFUNDED}`

```plantuml
@startuml UC6_ThanhToan
title UC6. Thanh toán

left to right direction
skinparam usecase {
  BackgroundColor #FFF6E5
  BorderColor #E85B2E
}

actor "Khách hàng" as KH
actor "Shipper /\nSystem Admin" as STAFF #lightgray

rectangle "Module Payment" {

  usecase "UC6.1 Chọn phương thức TT\n(field paymentMethod\ntrong PlaceOrderRequest)" as UC61
  usecase "UC6.2 Xem thông tin TT đơn\n(GET /payments/orders/{id})" as UC62
  usecase "UC6.3 Xác nhận thanh toán COD\n(PATCH /payments/orders/{id}/confirm-cod)" as UC63

  ' Sub: payment methods
  usecase "COD\n(Tiền mặt khi nhận)" as M_COD
  usecase "MoMo" as M_MOMO
  usecase "ZaloPay" as M_ZALO
  usecase "Credit Card" as M_CC

  ' Internal
  usecase "Tạo Payment PENDING\n(khi đặt hàng)" as CREATE_PAY
  usecase "Cập nhật status=PAID\n+ paidAt=now" as MARK_PAID
}

KH --> UC61
KH --> UC62
STAFF --> UC63

UC61 ..> M_COD  : <<extend>>
UC61 ..> M_MOMO : <<extend>>
UC61 ..> M_ZALO : <<extend>>
UC61 ..> M_CC   : <<extend>>

UC61 ..> CREATE_PAY : <<include>>\n(được gọi từ UC5.1 placeOrder)
UC63 ..> MARK_PAID  : <<include>>

note bottom
  Theo source code: gateway thật chưa tích hợp.
  Entity có sẵn fields: transaction_id, gateway_response.
  COD → PENDING → Shipper xác nhận → PAID.
  Các gateway khác → PENDING (chờ tích hợp).
end note

@enduml
```

---

## UC7. Theo dõi đơn hàng

> **Backend:** `order/controller/OrderController` (GET) + `WebSocketConfig` (STOMP) + `NotificationServiceImpl` (FCM)
> **Frontend:** `features/order/presentation/screens/order_tracking_screen.dart`
> **API REST:** `GET /orders` · `GET /orders/{id}`
> **WebSocket:** `/ws` (SockJS) → `/user/queue/orders/{id}/status`

```plantuml
@startuml UC7_TheoDoi
title UC7. Theo dõi đơn hàng (Real-time + Polling fallback)

left to right direction
skinparam usecase {
  BackgroundColor #FFF6E5
  BorderColor #E85B2E
}

actor "Khách hàng" as KH

rectangle "Module Order Tracking" {

  usecase "UC7.1 Xem lịch sử đơn\n(GET /orders\n?status&page&size)" as UC71
  usecase "UC7.2 Xem chi tiết đơn\n(GET /orders/{id})" as UC72
  usecase "UC7.3 Xem timeline status\n(order_status_history)" as UC73
  usecase "UC7.4 Subscribe Realtime\n(STOMP /ws +\n/user/queue/orders/{id}/status)" as UC74
  usecase "UC7.5 Polling fallback\n(Timer.periodic 15s\n_load(silent:true))" as UC75
  usecase "UC7.6 Nhận FCM push\n(Firebase Messaging)" as UC76
  usecase "Re-fetch khi có WS message\n(REST canonical)" as REFETCH
  usecase "Reconnect WS\n(delay 5s)" as RECONNECT
  usecase "Heartbeat 10s\nin/out" as HEARTBEAT
}

KH --> UC71
KH --> UC72

UC71 ..> UC72  : <<extend>>\n(tap đơn)
UC72 ..> UC73  : <<include>>
UC72 ..> UC74  : <<include>>\n(activate StompClient)
UC72 ..> UC75  : <<include>>\n(luôn chạy)
UC72 ..> UC76  : <<extend>>\n(background push)

UC74 ..> HEARTBEAT : <<include>>
UC74 ..> REFETCH   : <<include>>\n(callback subscribe)
UC74 ..> RECONNECT : <<extend>>\n(onWebSocketError)
UC75 ..> REFETCH   : <<include>>

note bottom of UC74
  Source code: order_tracking_screen.dart:62-110
  - SockJS + Bearer token header
  - Subscribe /user/queue/orders/{orderId}/status
  - Khi nhận MESSAGE → gọi REST re-fetch
    (không trust payload socket)
end note

@enduml
```

**Trạng thái UI:** Badge "Realtime: Đang kết nối" (xanh) hoặc "Mất kết nối (đang dùng polling)" (cam).

---

## UC8. Đánh giá đơn hàng

> **Backend:** `review/controller/ReviewController.java`, `review/service/ReviewServiceImpl.java`
> **Frontend:** `features/review/data/review_repository.dart`
> **DB constraint:** `reviews.order_id UNIQUE` · `rating CHECK 1..5`
> **Precondition:** Order phải có `status = DELIVERED`

```plantuml
@startuml UC8_DanhGia
title UC8. Đánh giá đơn hàng

left to right direction
skinparam usecase {
  BackgroundColor #FFF6E5
  BorderColor #E85B2E
}

actor "Khách hàng" as KH

rectangle "Module Review" {

  usecase "UC8.1 Tạo đánh giá\n(POST /reviews)" as UC81
  usecase "UC8.2 Xem đánh giá NH\n(GET /restaurants/{id}/reviews)" as UC82
  usecase "Chấm điểm 1-5 sao\n(rating CHECK 1..5)" as RATE
  usecase "Viết bình luận\n(comment TEXT)" as COMMENT
  usecase "Verify đơn DELIVERED\n+ thuộc về user" as VERIFY
  usecase "Verify chưa review\n(order_id UNIQUE)" as UNIQUE_CHECK
  usecase "Cập nhật rating_avg\n+ rating_count NH" as UPDATE_RATING
}

KH --> UC81
KH --> UC82

UC81 ..> VERIFY        : <<include>>
UC81 ..> UNIQUE_CHECK  : <<include>>
UC81 ..> RATE          : <<include>>
UC81 ..> COMMENT       : <<extend>>\n(có thể trống)
UC81 ..> UPDATE_RATING : <<include>>

note bottom of UC81
  Precondition (extend của UC5.1 Đặt hàng):
  - status = DELIVERED
  - chưa có review nào cho order_id

  Postcondition:
  - restaurant.rating_avg recalculated
  - restaurant.rating_count++
end note

@enduml
```

---

## Tổng hợp ánh xạ Use Case ↔ Source Code

| Use Case | API endpoint | Backend service | Frontend repository/screen |
|---|---|---|---|
| **UC1** Đăng ký/Đăng nhập | `POST /auth/{register,login,refresh,logout,forgot-password,reset-password}` · `GET /auth/verify-email` | `AuthServiceImpl` | `AuthRepository` + `AuthCubit` + 5 auth screens |
| **UC2** Tìm kiếm | `GET /restaurants?city&cuisine&search&isOpen&lat&lng&maxDistanceKm&sortBy` | `RestaurantServiceImpl.getRestaurants` | `RestaurantRepository.fetchRestaurants` + `DiscoverCubit` + `SearchScreen` |
| **UC3** Xem menu | `GET /restaurants/{id}` · `/menu` · `/menu/items/{itemId}` · `/reviews` | `RestaurantServiceImpl` + `MenuServiceImpl` | `RestaurantDetailCubit` + `RestaurantDetailScreen` + `ItemDetailScreen` |
| **UC4** Giỏ hàng | `GET /cart` · `POST /cart/items` · `PUT/DELETE /cart/items/{id}` · `DELETE /cart` | `CartServiceImpl` | `CartRepository` + `CartCubit` + `CartScreen` |
| **UC5** Đặt hàng ⭐ | `POST /orders` · `PATCH /orders/{id}/cancel` | `OrderServiceImpl.placeOrder` (transactional) | `OrderRepository` + `CheckoutScreen` + `OrderDetailScreen` |
| **UC6** Thanh toán | `GET /payments/orders/{id}` · `PATCH /payments/orders/{id}/confirm-cod` | `PaymentServiceImpl` | `OrderRepository.getPaymentByOrder` |
| **UC7** Theo dõi | `GET /orders` · `GET /orders/{id}` · STOMP `/ws` + `/user/queue/orders/{id}/status` | `OrderServiceImpl` + `WebSocketConfig` + `NotificationServiceImpl` | `OrderRepository` + `OrderHistoryScreen` + **`OrderTrackingScreen`** (StompClient + Timer) |
| **UC8** Đánh giá | `POST /reviews` · `GET /restaurants/{id}/reviews` | `ReviewServiceImpl.createReview` | `ReviewRepository` + Review dialog trong `OrderHistoryScreen` |

---

## Cách dùng

1. Copy nguyên block `@startuml ... @enduml` của diagram cần render
2. Paste vào https://www.plantuml.com/plantuml/uml/
3. Click **Submit** → diagram hiển thị, có thể export PNG/SVG

**VS Code:** cài plugin `jebbs.plantuml`, mở file `.md` này, gõ `Alt+D` để preview tất cả diagram.
