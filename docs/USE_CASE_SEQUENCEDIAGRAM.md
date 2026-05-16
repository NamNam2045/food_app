# Hình 1. Biểu đồ Use Case — Format sequencediagram.org

> Paste **nguyên block code dưới đây** vào https://sequencediagram.org/ để render.
> Vì sequencediagram.org chuyên về sequence diagram, ta dùng **interaction-style**: mỗi actor gửi message tới `FoodRush System` đại diện cho từng use case. Quan hệ `include` / `extend` ghi chú bằng `note over`.

---

## A. Bản tổng quát (1 file — paste 1 lần)

```
title Hình 1. Biểu đồ Use Case tổng quát — FoodRush

actor Customer
actor "Restaurant Admin" as Owner
actor "Delivery Agent" as Shipper
actor "System Admin" as Admin
participant "FoodRush System" as System

==Customer Use Cases==

Customer->System: UC-C01 Đăng ký
Customer->System: UC-C02 Đăng nhập
Customer->System: UC-C03 Duyệt nhà hàng
Customer->System: UC-C04 Tìm kiếm
Customer->System: UC-C05 Xem menu
Customer->System: UC-C06 Thêm vào giỏ
note over Customer,System: «extend» UC-C05 Xem menu

Customer->System: UC-C07 Đặt hàng
note over Customer,System: «include» UC-C02 Đăng nhập\n«include» UC-C06 Thêm vào giỏ\n«include» UC-C08 Thanh toán

Customer->System: UC-C08 Thanh toán
Customer->System: UC-C09 Theo dõi đơn
note over Customer,System: «extend» UC-C07 Đặt hàng

Customer->System: UC-C10 Đánh giá
note over Customer,System: «extend» UC-C07 Đặt hàng\n(precondition: status = DELIVERED)

==Restaurant Admin Use Cases==

Owner->System: UC-R01 Quản lý hồ sơ NH
Owner->System: UC-R02 Quản lý menu
Owner->System: UC-R03 Nhận đơn
Owner->System: UC-R04 Cập nhật trạng thái đơn
note over Owner,System: «extend» UC-R03 Nhận đơn\n(PENDING→CONFIRMED→PREPARING→READY_FOR_PICKUP)
Owner->System: UC-R05 Xem báo cáo

==Delivery Agent Use Cases==

Shipper->System: UC-D01 Nhận đơn được phân công
Shipper->System: UC-D02 Cập nhật trạng thái giao
note over Shipper,System: «include» UC-D01 Nhận đơn được phân công\n(PICKED_UP→ON_THE_WAY→DELIVERED)
Shipper->System: UC-D03 Xem lịch sử giao

==System Admin Use Cases==

Admin->System: UC-A01 Quản lý user
Admin->System: UC-A02 Phê duyệt NH
note over Admin,System: «extend» UC-A01 Quản lý user
Admin->System: UC-A03 Thống kê hệ thống
```

---

## B. Bản tách theo từng actor (nếu muốn 4 diagram riêng)

### B.1. Customer

```
title Use Case — Customer (Khách hàng)

actor Customer
participant "FoodRush System" as System

Customer->System: Đăng ký
Customer->System: Đăng nhập
Customer->System: Duyệt nhà hàng
Customer->System: Tìm kiếm
Customer->System: Xem menu
Customer->System: Thêm vào giỏ
note over Customer,System: «extend» Xem menu

Customer->System: Đặt hàng
note over Customer,System: «include» Đăng nhập, Thêm vào giỏ, Thanh toán

Customer->System: Thanh toán
Customer->System: Theo dõi đơn
note over Customer,System: «extend» Đặt hàng

Customer->System: Đánh giá
note over Customer,System: «extend» Đặt hàng (sau DELIVERED)
```

### B.2. Restaurant Admin

```
title Use Case — Restaurant Admin (Chủ nhà hàng)

actor "Restaurant Admin" as Owner
participant "FoodRush System" as System

Owner->System: Quản lý hồ sơ NH
Owner->System: Quản lý menu
Owner->System: Nhận đơn

Owner->System: Cập nhật trạng thái đơn
note over Owner,System: «extend» Nhận đơn\nState machine:\nPENDING → CONFIRMED → PREPARING → READY_FOR_PICKUP

Owner->System: Xem báo cáo
```

### B.3. Delivery Agent

```
title Use Case — Delivery Agent (Shipper)

actor "Delivery Agent" as Shipper
participant "FoodRush System" as System

Shipper->System: Nhận đơn được phân công

Shipper->System: Cập nhật trạng thái giao
note over Shipper,System: «include» Nhận đơn được phân công\nState machine:\nPICKED_UP → ON_THE_WAY → DELIVERED

Shipper->System: Xem lịch sử giao
```

### B.4. System Admin

```
title Use Case — System Admin (Quản trị viên)

actor "System Admin" as Admin
participant "FoodRush System" as System

Admin->System: Quản lý user

Admin->System: Phê duyệt NH
note over Admin,System: «extend» Quản lý user

Admin->System: Thống kê hệ thống
```

---

## C. Bản "Use case có nội bộ hệ thống" (chi tiết hơn)

Phiên bản này phân tách `FoodRush System` thành 3 thành phần con (App Flutter, Backend, External) để thấy nội bộ hệ thống xử lý ra sao.

```
title Use Case chi tiết — Customer (kèm internal flow)

actor Customer
participant "App Flutter" as App
participant "Backend API" as API
participant "PostgreSQL" as DB
participant "External\n(FCM/SMTP)" as Ext

==UC-C01 Đăng ký==
Customer->App: Mở /register, nhập thông tin
App->API: POST /auth/register
API->DB: INSERT users (BCrypt password)
API->Ext: SMTP send email verification
API-->App: 201 + JWT
App-->Customer: Navigate /home

==UC-C02 Đăng nhập==
Customer->App: Nhập email/password
App->API: POST /auth/login
API->DB: SELECT user, BCrypt match
API-->App: JWT access+refresh
App-->Customer: /home

==UC-C03..C05 Duyệt / Tìm kiếm / Xem menu==
Customer->App: Mở tab Khám phá
App->API: GET /restaurants?sortBy=rating
API->DB: SELECT restaurants
API-->App: Page<Restaurant>
Customer->App: Tap nhà hàng
App->API: GET /restaurants/{id}\nGET /restaurants/{id}/menu
API-->App: Detail + menu

==UC-C06 Thêm vào giỏ==
Customer->App: Tap "Thêm vào giỏ"
App->API: POST /cart/items
API->DB: Validate same restaurant, save CartItem
API-->App: CartResponse

==UC-C07 Đặt hàng (include UC-C02, UC-C06, UC-C08)==
Customer->App: Tap "Đặt hàng" tại Checkout
App->API: POST /orders
API->DB: BEGIN TX\nValidate promo, snapshot address\nINSERT order + items + history\nINSERT payment(PENDING)\nDELETE cart items\nCOMMIT
API->Ext: FCM async push
API-->App: OrderDetail

==UC-C09 Theo dõi đơn (extend UC-C07)==
App->API: GET /orders/{id}
App->API: SUBSCRIBE STOMP /user/queue/orders/{id}/status
note over App,API: Realtime + polling 15s fallback

==UC-C10 Đánh giá (extend UC-C07, sau DELIVERED)==
Customer->App: Chọn rating + comment
App->API: POST /reviews
API->DB: INSERT review\nUPDATE restaurants.rating_avg/count
API-->App: 201
```

---

## D. Hướng dẫn render

| Bước | Hành động |
|---|---|
| 1 | Mở https://sequencediagram.org/ |
| 2 | Xóa code mẫu mặc định |
| 3 | Copy **toàn bộ block code** ở mục A (hoặc B/C tuỳ ý) — chỉ phần text giữa 3 dấu backtick |
| 4 | Paste vào editor bên trái |
| 5 | Diagram tự render ngay bên phải |
| 6 | Export: File menu → Export as PNG / SVG / PDF |

> **Lưu ý syntax sequencediagram.org:**
> - `actor X` hoặc `actor "Tên có khoảng trắng" as Alias` — tạo actor
> - `participant X` — tạo participant (hình chữ nhật)
> - `==Title==` — section header
> - `A->B: msg` — solid arrow (request)
> - `A-->B: msg` — dashed arrow (response)
> - `note over A,B: text` — note span nhiều participant
> - `\n` trong message/note = xuống dòng
> - `alt / else / end` — block điều kiện (xem ví dụ Order Tracking ở `SYSTEM_DESIGN.md` mục 6.8)
