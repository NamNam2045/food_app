# 2.2.2 Mô tả Use Case chi tiết (Mobile App)

> Phạm vi: chỉ các Use Case có hiện diện trong ứng dụng Flutter (`food_app/lib/features/*`). Các use case dành riêng cho Web Admin (UC-12 Shipper, UC-13 SysAdmin) không nằm trong phạm vi.

## Bảng tổng quát

| ID | Tên Use Case | Actor | Mục tiêu | Tiền điều kiện | Hậu điều kiện |
|----|--------------|-------|----------|----------------|---------------|
| UC-01 | Đăng ký tài khoản | Khách | Tạo tài khoản mới | Email chưa tồn tại | Tài khoản được tạo, gửi mail verify |
| UC-02 | Đăng nhập | User | Xác thực và nhận token | Tài khoản tồn tại | Có access + refresh token |
| UC-03 | Duyệt & tìm nhà hàng | Customer | Tìm nhà hàng phù hợp | Có địa chỉ mặc định (gợi ý) | Hiển thị danh sách NH |
| UC-04 | Xem menu nhà hàng | Customer | Xem danh sách món | NH tồn tại | Hiển thị menu theo danh mục |
| UC-05 | Quản lý giỏ hàng | Customer | Chuẩn bị đơn | Đã đăng nhập | Giỏ hàng được cập nhật |
| UC-06 | Đặt hàng | Customer | Tạo đơn | Giỏ hàng có món, có địa chỉ | Đơn được tạo, NH nhận thông báo |
| UC-07 | Thanh toán | Customer | Thanh toán đơn | Đơn ở PENDING_PAYMENT | Đơn chuyển sang RECEIVED |
| UC-08 | Theo dõi đơn hàng | Customer | Xem trạng thái real-time | Đơn đang xử lý | Nhận sự kiện qua STOMP |
| UC-09 | Đánh giá nhà hàng | Customer | Gửi review | Đơn COMPLETED, chưa review | Review được lưu, cập nhật rating |
| UC-10 | Quản lý thực đơn | RAdmin | CRUD menu | Có quyền | Menu được cập nhật |
| UC-11 | Xử lý đơn hàng | RAdmin | Chuyển trạng thái đơn | Đơn thuộc về NH | Trạng thái mới broadcast |

*Bảng 3. Mô tả Use case tổng quát*

---

## UC-01. Đăng ký tài khoản

| Thuộc tính | Mô tả |
|---|---|
| **ID** | UC-01 |
| **Tên Use Case** | Đăng ký tài khoản |
| **Actor chính** | Khách (Guest) |
| **Màn hình app** | `features/auth/.../register_screen.dart` |
| **Mô tả ngắn** | Khách tạo tài khoản người dùng mới với vai trò mặc định CUSTOMER. |
| **Tiền điều kiện** | Email và số điện thoại chưa tồn tại trong hệ thống. |
| **Hậu điều kiện thành công** | `User` được tạo (`active=true`, `emailVerified=false`, role=CUSTOMER); mật khẩu băm BCrypt; gửi email verify async; trả `accessToken` + `refreshToken`. |
| **Hậu điều kiện thất bại** | Không bản ghi nào được tạo; trả mã lỗi nghiệp vụ. |
| **Điểm kích hoạt** | `POST /api/v1/auth/register` |
| **Luồng chính** | 1. App gửi `firstName, lastName, email, phoneNumber?, password (≥8)`. 2. Bean Validation kiểm tra format. 3. `AuthService.existsByEmail()` = false. 4. `existsByPhoneNumber()` = false (nếu có). 5. Lowercase email, băm password. 6. Lưu `User` role=CUSTOMER. 7. Sinh `emailVerificationToken` (UUID), gửi email async. 8. Phát JWT (access + refresh). 9. Trả 201 + token + user info. |
| **Luồng phụ / ngoại lệ** | **E1** Email trùng → `AUTH_003` (409). **E2** SĐT trùng → `AUTH_004` (409). **E3** Validation lỗi → 400. **E4** Gửi mail lỗi → log warning, không rollback. |
| **Phi chức năng** | Password băm BCrypt; gửi mail async để giảm latency. |

---

## UC-02. Đăng nhập

| Thuộc tính | Mô tả |
|---|---|
| **ID** | UC-02 |
| **Tên Use Case** | Đăng nhập & làm mới phiên |
| **Actor chính** | User (mọi role) |
| **Màn hình app** | `features/auth/.../login_screen.dart` |
| **Mô tả ngắn** | Xác thực email/password, cấp JWT; hỗ trợ refresh và logout (thu hồi refresh token qua Redis). |
| **Tiền điều kiện** | Tài khoản tồn tại, `active=true`. |
| **Hậu điều kiện** | `lastLoginAt` cập nhật; trả `accessToken` + `refreshToken` kèm thời hạn; khi logout, refresh token được lưu vào Redis với key `revoked:token:{hash}`. |
| **Điểm kích hoạt** | `POST /api/v1/auth/login` · `/refresh` · `/logout` |
| **Luồng chính (Login)** | 1. App gửi `{email, password}`. 2. `AuthenticationManager` xác thực qua `UserDetailsService`. 3. Cập nhật `user.lastLoginAt`. 4. `JwtUtil` sinh access (short-lived) + refresh (claim `type=refresh`). 5. Trả 200 + token + role. |
| **Luồng phụ (Refresh)** | 1. Client gửi refresh token cũ. 2. `JwtUtil.validateToken()`. 3. Kiểm tra Redis revoke list. 4. Cấp cặp mới, đưa token cũ vào revoke với TTL. |
| **Ngoại lệ** | **E1** Sai mật khẩu → 401 "Email hoặc mật khẩu không đúng". **E2** Refresh hết hạn → 401. **E3** Refresh đã revoke → 401. **E4** Account `active=false` → 401. |

---

## UC-03. Duyệt & tìm nhà hàng

| Thuộc tính | Mô tả |
|---|---|
| **ID** | UC-03 |
| **Actor chính** | Customer / Guest |
| **Màn hình app** | `features/home`, `features/discover`, `features/search`, `features/restaurant` |
| **Mục tiêu** | Hiển thị danh sách nhà hàng phù hợp theo bộ lọc và vị trí. |
| **Tiền điều kiện** | (Khuyến nghị) Customer đã đăng nhập và có địa chỉ mặc định để truyền `lat/lng`. |
| **Hậu điều kiện** | Trả danh sách nhà hàng `active=true`, có phân trang. |
| **Kích hoạt** | `GET /api/v1/restaurants?city=&cuisineType=&search=&isOpen=&lat=&lng=&maxDistanceKm=10&page=0&size=20&sortBy=rating` |
| **Luồng chính** | 1. App gửi query params. 2. Có `lat/lng` → `findNearby()` (Haversine). 3. Ngược lại → lọc `city`, `cuisineType`, `search` (LIKE name/description), `isOpen`. 4. Sort theo `rating` DESC / `deliveryTime` ASC / `distance`. 5. Chỉ lấy `active=true`, phân trang. 6. Trả `Page<RestaurantListItemDto>`. |
| **Luồng phụ** | **A1** Không có toạ độ → nhánh filter thuần text. **A2** Không có match → trả page rỗng (không exception). |
| **Phi chức năng** | Endpoint public, cần rate-limit ở gateway; cache-friendly. |

---

## UC-04. Xem menu nhà hàng

| Thuộc tính | Mô tả |
|---|---|
| **ID** | UC-04 |
| **Actor chính** | Customer / Guest |
| **Màn hình app** | `features/restaurant/.../restaurant_detail_screen.dart` |
| **Tiền điều kiện** | Nhà hàng tồn tại, `active=true`. |
| **Hậu điều kiện** | Trả cây menu: danh mục → món, đã lọc visibility. |
| **Kích hoạt** | `GET /api/v1/restaurants/{restaurantId}/menu` · `GET .../menu/items/{itemId}` |
| **Luồng chính** | 1. Tìm `Restaurant` theo id; không có → `ResourceNotFoundException`. 2. Lấy `MenuCategory` `active=true`, sort `displayOrder ASC`. 3. Trong mỗi category lấy `MenuItem` `available=true`. 4. Trả DTO (name, mảng món: id, name, price, image, calories, prepTime, featured). 5. Chi tiết món: kiểm tra item thuộc restaurant; sai → 404. |
| **Ngoại lệ** | **E1** Danh mục không tồn tại → 404. **E2** Món không thuộc nhà hàng → 404. |

---

## UC-05. Quản lý giỏ hàng

| Thuộc tính | Mô tả |
|---|---|
| **ID** | UC-05 |
| **Actor chính** | Customer (đã đăng nhập) |
| **Màn hình app** | `features/cart/.../cart_screen.dart` |
| **Tiền điều kiện** | Có access token hợp lệ. |
| **Hậu điều kiện** | Cart entity phản ánh đúng thay đổi; mọi item phải thuộc cùng một nhà hàng. |
| **Kích hoạt** | `GET/POST/PUT/DELETE /api/v1/cart[/items[/{id}]]` |
| **Luồng chính – Thêm món** | 1. Nhận `{menuItemId, quantity, specialInstructions}`. 2. Lấy `MenuItem`; `available=false` → `CART_002`. 3. Tìm/tạo `Cart`. 4. Có món của nhà hàng khác → `CART_003`. 5. Trùng món → tăng quantity, không thì tạo `CartItem` + snapshot `unitPrice`. 6. Persist. |
| **Luồng phụ** | **A1** `PUT /items/{id}` với `quantity=0` → xoá item; hết item → `cart.restaurant=null`. **A2** `DELETE /api/v1/cart` → xoá toàn bộ. |
| **Ngoại lệ** | `CART_001` (giỏ trống), `CART_002` (món hết hàng), `CART_003` (xung đột NH), 404 không tìm thấy. |

---

## UC-06. Đặt hàng

| Thuộc tính | Mô tả |
|---|---|
| **ID** | UC-06 |
| **Actor chính** | Customer |
| **Màn hình app** | `features/cart/.../checkout_screen.dart`, `features/order` |
| **Tiền điều kiện** | (1) Cart không rỗng. (2) Subtotal ≥ `restaurant.minOrderAmount`. (3) `deliveryAddressId` thuộc user. |
| **Hậu điều kiện** | `Order` (status=PENDING) + `OrderItem[]` snapshot + `Payment` (PENDING) + `OrderStatusHistory`; clear cart; STOMP push `/user/{id}/queue/orders/{orderId}/status`; FCM async. |
| **Kích hoạt** | `POST /api/v1/orders` (role CUSTOMER) |
| **Luồng chính** | 1. Validate cart không rỗng (`CART_001`). 2. Tính `subtotal`; thiếu min → `ORDER_002`. 3. Lấy `Address`, kiểm ownership. 4. Áp `promoCode` (uppercase, active); invalid → silent zero. 5. Sinh `orderNumber`; set `paymentMethod ∈ {COD, CREDIT_CARD, MOMO, ZALOPAY}`. 6. `total = subtotal + deliveryFee − discount`; `estimatedDeliveryAt = now + restaurant.estimatedDeliveryMinutes`. 7. Snapshot địa chỉ → JSON. 8. Tạo `Order` + `OrderItem[]` + `OrderStatusHistory("Đơn hàng được tạo")` + `Payment(PENDING)`. 9. Tăng `promoCode.usageCount`. 10. Clear cart. 11. `SimpMessagingTemplate.convertAndSendToUser(...)`. 12. FCM async tới `user.fcmToken`. |
| **Ngoại lệ** | `CART_001`, `ORDER_002`, 404 địa chỉ, 400 paymentMethod sai. |

---

## UC-07. Thanh toán

| Thuộc tính | Mô tả |
|---|---|
| **ID** | UC-07 |
| **Actor chính** | Customer (xem) · Shipper/SysAdmin (xác nhận COD ở backend) |
| **Màn hình app** | `features/order/.../order_detail_screen.dart` (xem payment), bước checkout của UC-06 |
| **Tiền điều kiện** | (1) Order tồn tại, thuộc user. (2) `Payment` tạo lúc đặt hàng với `status=PENDING`. |
| **Hậu điều kiện** | Sau xác nhận: `Payment.status=PAID`, `paidAt=now()`. |
| **Kích hoạt** | `GET /api/v1/payments/orders/{orderId}` · `PATCH /api/v1/payments/orders/{orderId}/confirm-cod` |
| **Luồng chính – Xem** | 1. Lấy Order, kiểm ownership. 2. Lấy `Payment`; không có → 404. 3. Trả `{method, status, amount, paidAt}`. |
| **Luồng chính – Xác nhận COD** | 1. Role `DELIVERY_AGENT`/`SYSTEM_ADMIN`. 2. Chuyển `PENDING → PAID`, set `paidAt`. 3. Lưu. |
| **Luồng phụ** | Cổng thanh toán online (MOMO/ZaloPay/Card) qua webhook callback riêng. |
| **Ngoại lệ** | 404 order/payment, 403 nếu role không đủ. |

---

## UC-08. Theo dõi đơn hàng real-time

| Thuộc tính | Mô tả |
|---|---|
| **ID** | UC-08 |
| **Actor chính** | Customer (xem) |
| **Màn hình app** | `features/order/.../order_tracking_screen.dart`, `features/notification` |
| **Tiền điều kiện** | (1) Đơn đang xử lý. (2) Client đã setup WebSocket STOMP. |
| **Hậu điều kiện** | Mỗi lần `OrderServiceImpl.updateStatus()` đổi trạng thái → broadcast `OrderStatusUpdateMessage`. |
| **Endpoint** | WS handshake: `GET /ws` (SockJS); subscribe: `/user/queue/orders/{orderId}/status`; broker: `/topic`, `/queue` |
| **Luồng chính** | 1. App mở SockJS `/ws`, gắn `Authorization: Bearer` qua `WebSocketAuthChannelInterceptor`. 2. `SUBSCRIBE /user/queue/orders/{orderId}/status`. 3. Server `convertAndSendToUser()` (theo cả id và email). 4. Payload `{orderId, orderNumber, newStatus, previousStatus, message (VN), estimatedDeliveryAt, timestamp}`. |
| **Mapping thông điệp** | PENDING → "Đơn hàng đang chờ xác nhận"; CONFIRMED → "Nhà hàng đã xác nhận đơn hàng"; PREPARING → "Nhà hàng đang chuẩn bị đơn hàng"; READY_FOR_PICKUP → "Đơn hàng đã sẵn sàng, đang chờ shipper"; PICKED_UP → "Shipper đã lấy hàng"; ON_THE_WAY → "Shipper đang trên đường giao hàng"; DELIVERED → "Đơn hàng đã được giao thành công"; CANCELLED → "Đơn hàng đã bị hủy". |
| **Luồng phụ** | Song song STOMP, gửi FCM tới `user.fcmToken` cho trường hợp app background. |
| **Ngoại lệ** | Mất kết nối WS → client tự reconnect; gửi lỗi → log best-effort. |

---

## UC-09. Đánh giá nhà hàng

| Thuộc tính | Mô tả |
|---|---|
| **ID** | UC-09 |
| **Actor chính** | Customer |
| **Màn hình app** | `features/review/.../write_review_screen.dart`, `features/restaurant` (hiển thị review) |
| **Tiền điều kiện** | (1) Đơn `DELIVERED`. (2) Chưa review đơn này. (3) Khách là chủ đơn. |
| **Hậu điều kiện** | `Review` được lưu; `Restaurant.ratingAvg` & `ratingCount` cập nhật. |
| **Kích hoạt** | `POST /api/v1/reviews` · `GET /api/v1/restaurants/{id}/reviews` |
| **Luồng chính** | 1. Nhận `{orderId, rating(1–5), comment?}`. 2. Lấy Order, kiểm ownership. 3. `status != DELIVERED` → `REVIEW_001`. 4. `existsByOrderId()` → `REVIEW_002`. 5. Tạo `Review(visible=true)`. 6. Tính lại `ratingAvg` (1 decimal) + `ratingCount`, save Restaurant. 7. Trả 201 "Cảm ơn bạn đã đánh giá!". |
| **Luồng phụ – List** | Paging size=20, sort `createdAt DESC`, kèm phân phối sao 1–5. |
| **Ngoại lệ** | 404 order/user, `REVIEW_001`, `REVIEW_002`, 400 rating ngoài [1..5]. |

---

## UC-10. Quản lý thực đơn (Restaurant Admin)

| Thuộc tính | Mô tả |
|---|---|
| **ID** | UC-10 |
| **Actor chính** | Restaurant Admin (`RESTAURANT_ADMIN`) |
| **Màn hình app** | `features/admin/.../admin_manage_menu_screen.dart`, `admin_add_edit_item_screen.dart` |
| **Tiền điều kiện** | Đã đăng nhập role `RESTAURANT_ADMIN`; sở hữu một `Restaurant`. |
| **Hậu điều kiện** | Danh mục/món được tạo, cập nhật, hoặc soft-delete (`active=false` / `available=false`); ảnh upload qua `ImageStorageService`. |
| **Kích hoạt** | API: `/api/v1/restaurants/{id}/menu/categories[/{catId}]`, `/menu/items[/{itemId}]` (POST/PUT/DELETE) |
| **Luồng chính (Tạo món)** | 1. Submit `{categoryId, name, description, price, imageFile?, featured, calories, prepTime, displayOrder}` (multipart). 2. Kiểm category thuộc restaurant của owner. 3. Có `imageFile` → `ImageStorageService.storeImage()` trả URL. 4. Tạo `MenuItem(available=true)`. 5. Trả 201 + DTO. |
| **Các thao tác khác** | Tạo/sửa category (name, description, displayOrder); toggle `available` của item; soft-delete category (`active=false`, disable items con). |
| **Ngoại lệ** | Không sở hữu restaurant → RuntimeException; lỗi upload ảnh → 400; item/category không thuộc restaurant → 403/404. |

---

## UC-11. Xử lý đơn hàng (Restaurant Admin)

| Thuộc tính | Mô tả |
|---|---|
| **ID** | UC-11 |
| **Actor chính** | Restaurant Admin |
| **Màn hình app** | `features/admin/.../admin_manage_orders_screen.dart`, `admin_dashboard_screen.dart` |
| **Tiền điều kiện** | Đơn thuộc restaurant của owner. |
| **Hậu điều kiện** | `Order.status` cập nhật theo state machine hợp lệ; `OrderStatusHistory` thêm bản ghi; STOMP + FCM broadcast tới khách. |
| **Kích hoạt** | API: `GET/POST` endpoints của order (list/detail/update status) |
| **Máy trạng thái** | `PENDING → CONFIRMED → PREPARING → READY_FOR_PICKUP`; `PENDING/CONFIRMED → CANCELLED`. (PICKED_UP/ON_THE_WAY/DELIVERED thuộc shipper) |
| **Luồng chính** | 1. Owner mở list, lọc theo `status` + `date` (yyyy-MM-dd), paging 20/page. 2. Xem detail (items, khách, địa chỉ, payment, history). 3. Submit `newStatus`. 4. `validateStatusTransition(current, new)` sai → `ORDER_003`. 5. Cập nhật status, thêm `OrderStatusHistory(note?)`. 6. Gửi STOMP `OrderStatusUpdateMessage` + FCM. |
| **Ngoại lệ** | Đơn không thuộc restaurant → 403; chuyển trạng thái sai → 400 `ORDER_003`. |

---

## Phụ lục: Enum & mã lỗi nghiệp vụ

| Enum | Giá trị |
|---|---|
| **OrderStatus** | `PENDING → CONFIRMED → PREPARING → READY_FOR_PICKUP → PICKED_UP → ON_THE_WAY → DELIVERED` · `CANCELLED` |
| **UserRole** | `CUSTOMER`, `RESTAURANT_ADMIN`, `DELIVERY_AGENT`, `SYSTEM_ADMIN` |
| **PaymentMethod** | `COD`, `CREDIT_CARD`, `MOMO`, `ZALOPAY` |
| **PaymentStatus** | `PENDING`, `PAID`, `FAILED`, `REFUNDED` |

| Mã lỗi | Ý nghĩa |
|---|---|
| `AUTH_001..008` | Unauthorized / sai mật khẩu / email-SĐT trùng / token reset-verify lỗi |
| `CART_001/002/003` | Giỏ trống / món không khả dụng / xung đột nhà hàng |
| `ORDER_001/002/003` | Không thể huỷ / dưới minimum / chuyển trạng thái không hợp lệ |
| `REVIEW_001/002` | Đơn chưa giao / đã review trước đó |
| `NOT_FOUND`, `FORBIDDEN`, `VALIDATION_ERROR` | Lỗi chung |
