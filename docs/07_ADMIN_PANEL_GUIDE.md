# Hướng dẫn sử dụng trang quản trị FoodRush Admin

> **URL:** `http://localhost:8080/admin`  
> **Vai trò yêu cầu:** `SYSTEM_ADMIN`

---

## Mục lục

1. [Đăng nhập / Đăng xuất](#1-đăng-nhập--đăng-xuất)
2. [Dashboard — Tổng quan](#2-dashboard--tổng-quan)
3. [Quản lý người dùng](#3-quản-lý-người-dùng)
4. [Quản lý nhà hàng](#4-quản-lý-nhà-hàng)
5. [Quản lý thực đơn](#5-quản-lý-thực-đơn)
6. [Quản lý đơn hàng](#6-quản-lý-đơn-hàng)
7. [Quản lý đánh giá](#7-quản-lý-đánh-giá)
8. [Quản lý mã khuyến mãi](#8-quản-lý-mã-khuyến-mãi)
9. [Phân quyền và bảo mật](#9-phân-quyền-và-bảo-mật)

---

## 1. Đăng nhập / Đăng xuất

### Đăng nhập

Truy cập `http://localhost:8080/admin/login`

| Trường | Giá trị |
|--------|---------|
| Email  | `admin@foodrush.vn` (tài khoản seed mặc định) |
| Password | `Admin@123` |

- Sau khi đăng nhập thành công, hệ thống tự chuyển đến `/admin/dashboard`.
- Nếu sai email/mật khẩu, trang hiển thị thông báo lỗi màu đỏ.
- Phiên đăng nhập dùng **session cookie** (không phải JWT) — tự động hết hạn khi đóng trình duyệt.

### Đăng xuất

Nhấn nút **Đăng xuất** ở cuối thanh điều hướng trái. Session và cookie `JSESSIONID` sẽ bị xoá ngay lập tức.

---

## 2. Dashboard — Tổng quan

**URL:** `/admin/dashboard`

Trang chủ hiển thị các chỉ số tổng quan hệ thống theo thời gian thực:

| Thẻ thống kê | Mô tả |
|---|---|
| **Người dùng** | Tổng số tài khoản đã đăng ký |
| **Nhà hàng** | Tổng nhà hàng / số đang kích hoạt |
| **Đơn hàng** | Tổng đơn / số đơn đang chờ xử lý |
| **Doanh thu** | Tổng doanh thu đã thanh toán / doanh thu hôm nay |
| **Đơn hôm nay** | Số đơn được tạo trong ngày hiện tại |
| **Đánh giá** | Tổng số đánh giá toàn hệ thống |

Phía dưới là bảng **10 đơn hàng gần nhất**, gồm: mã đơn, khách hàng, nhà hàng, tổng tiền, trạng thái và nút xem chi tiết.

---

## 3. Quản lý người dùng

**URL:** `/admin/users`

### Xem danh sách

- Hiển thị tất cả tài khoản với thông tin: ID, email, họ tên, vai trò, trạng thái hoạt động, ngày đăng ký.
- Phân trang: 20 người dùng / trang.

### Tìm kiếm

Nhập từ khóa vào ô tìm kiếm (hỗ trợ tìm theo **email**, **họ**, **tên**) rồi nhấn **Tìm**.  
Nhấn **Xóa lọc** để quay về danh sách đầy đủ.

### Badge vai trò

| Badge | Vai trò |
|---|---|
| 🔴 `SYSTEM_ADMIN` | Quản trị viên hệ thống |
| 🟡 `RESTAURANT_OWNER` | Chủ nhà hàng |
| ⚫ `CUSTOMER` | Khách hàng |

### Khoá / Mở khoá tài khoản

Nhấn nút 🔒 (khoá) hoặc 🔓 (mở) ở cột **Thao tác** để bật/tắt quyền đăng nhập của tài khoản.  
> **Lưu ý:** Không thể tự khoá tài khoản SYSTEM_ADMIN đang đăng nhập.

---

## 4. Quản lý nhà hàng

### 4.1 Danh sách nhà hàng

**URL:** `/admin/restaurants`

Hiển thị: tên, ẩm thực, thành phố, điểm đánh giá, trạng thái mở cửa, trạng thái kích hoạt.

**Tìm kiếm:** theo tên nhà hàng.

**Các thao tác nhanh trong bảng:**

| Nút | Chức năng |
|---|---|
| 👁️ (Xem) | Vào trang chi tiết nhà hàng |
| 🚪 (Mở/Đóng cửa) | Bật/tắt cờ `open` — ảnh hưởng tới khả năng đặt hàng của khách |
| ✅/❌ (Kích hoạt) | Bật/tắt cờ `active` — ẩn/hiện nhà hàng khỏi danh sách tìm kiếm |

### 4.2 Chi tiết nhà hàng

**URL:** `/admin/restaurants/{id}`

Hiển thị toàn bộ thông tin: chủ sở hữu, địa chỉ, điện thoại, điểm đánh giá, phí giao hàng, trạng thái.

Các nút **Mở cửa / Đóng cửa** và **Kích hoạt / Vô hiệu hóa** hoạt động từ trang này.

Phần **Danh mục thực đơn** liệt kê số lượng món theo từng danh mục.  
Nhấn **Quản lý thực đơn** để vào trang chỉnh sửa món ăn.

### Sự khác biệt: Open vs Active

| Cờ | Ý nghĩa | Ảnh hưởng |
|---|---|---|
| `open = true` | Nhà hàng đang mở cửa | Khách có thể đặt đơn |
| `open = false` | Nhà hàng đóng cửa tạm thời | Không nhận đơn mới, vẫn hiển thị |
| `active = true` | Nhà hàng được kích hoạt | Xuất hiện trong tìm kiếm |
| `active = false` | Nhà hàng bị vô hiệu hóa | Ẩn khỏi ứng dụng khách hàng |

---

## 5. Quản lý thực đơn

**URL:** `/admin/restaurants/{id}/menu`

### Cấu trúc hiển thị

Thực đơn được tổ chức theo accordion — mỗi **danh mục** là một panel mở/đóng, bên trong liệt kê danh sách **món ăn** gồm: tên, mô tả, giá, trạng thái có sẵn.

### Bật/Tắt món ăn

Nhấn nút 👁️ hoặc 🚫 ở cột **Thao tác** để chuyển trạng thái món giữa **Có sẵn** và **Hết món**.

> Chức năng này dùng để xử lý nhanh khi một món ăn tạm thời hết nguyên liệu mà không cần xoá khỏi menu.

---

## 6. Quản lý đơn hàng

### 6.1 Danh sách đơn hàng

**URL:** `/admin/orders`

**Bộ lọc:**
- **Trạng thái:** chọn một trong các trạng thái (hoặc để trống xem tất cả)
- **Ngày:** chọn ngày cụ thể để lọc đơn trong ngày đó
- Nhấn **Lọc** để áp dụng, nhấn **Xóa lọc** để reset.

**Bảng màu trạng thái đơn hàng:**

| Trạng thái | Màu | Ý nghĩa |
|---|---|---|
| `PENDING` | 🟡 Vàng | Đơn vừa đặt, chờ nhà hàng xác nhận |
| `CONFIRMED` | 🔵 Xanh dương | Nhà hàng đã xác nhận |
| `PREPARING` | 🔵 Cyan | Đang chuẩn bị món |
| `ON_THE_WAY` | 🟣 Tím | Đang giao hàng |
| `DELIVERED` | 🟢 Xanh lá | Giao thành công |
| `CANCELLED` | 🔴 Đỏ | Đã huỷ |

### 6.2 Chi tiết đơn hàng

**URL:** `/admin/orders/{id}`

Hiển thị đầy đủ thông tin:

- **Header:** mã đơn, thời gian tạo, trạng thái hiện tại
- **Bảng món:** tên món, đơn giá, số lượng, thành tiền; tổng kết gồm phí ship, giảm giá, **tổng cộng**
- **Khách hàng:** họ tên, email, số điện thoại
- **Địa chỉ giao hàng:** địa chỉ snapshot tại thời điểm đặt
- **Nhà hàng:** tên và link sang trang chi tiết nhà hàng
- **Thanh toán:** phương thức, trạng thái, mã giao dịch (nếu có)

> **Lưu ý:** Trang admin hiện chỉ xem đơn. Để **cập nhật trạng thái** đơn hàng, nhà hàng dùng REST API `PUT /api/v1/orders/{id}/status` (yêu cầu JWT token của `RESTAURANT_OWNER` hoặc `SYSTEM_ADMIN`).

---

## 7. Quản lý đánh giá

**URL:** `/admin/reviews`

Hiển thị tất cả đánh giá với: nhà hàng, người dùng, số sao, nội dung, trạng thái hiển thị, ngày tạo.

### Ẩn / Hiện đánh giá

Nhấn nút 👁️ / 🚫 ở cột **Thao tác** để toggle trạng thái `visible`:

- `visible = true`: Đánh giá hiển thị công khai trên ứng dụng
- `visible = false`: Đánh giá bị ẩn (khách hàng không thấy, nhà hàng không thấy)

> Dùng chức năng này khi đánh giá vi phạm nội quy (spam, ngôn từ không phù hợp) mà không cần xoá vĩnh viễn.

---

## 8. Quản lý mã khuyến mãi

**URL:** `/admin/promo-codes`

### 8.1 Danh sách mã

Hiển thị: mã code, loại giảm, giá trị, đơn tối thiểu, thời hạn hiệu lực, số lượt đã dùng / giới hạn, trạng thái.

### 8.2 Tạo mã mới

Nhấn nút **+ Tạo mã mới** — dialog mở ra với các trường:

| Trường | Bắt buộc | Mô tả |
|---|---|---|
| **Mã code** | ✅ | Tối đa 30 ký tự, in hoa, không dấu (vd: `WELCOME20`) |
| **Loại giảm** | ✅ | `Phần trăm (%)` hoặc `Số tiền cố định (đ)` |
| **Giá trị giảm** | ✅ | Số % hoặc số tiền |
| **Giảm tối đa** | ❌ | Áp dụng khi loại giảm là %. Bỏ trống = không giới hạn |
| **Đơn hàng tối thiểu** | ❌ | Giá trị đơn tối thiểu để áp mã. Bỏ trống = không yêu cầu |
| **Giới hạn sử dụng** | ❌ | Tổng số lượt dùng cho phép. Bỏ trống = không giới hạn |
| **Ngày bắt đầu** | ✅ | Thời điểm mã bắt đầu có hiệu lực |
| **Ngày kết thúc** | ✅ | Thời điểm mã hết hạn |

Nhấn **Tạo mã** để lưu. Mã được kích hoạt (`active = true`) ngay sau khi tạo.

### 8.3 Bật / Tắt mã

Nhấn nút toggle ở cột **Thao tác** để tạm dừng hoặc kích hoạt lại mã mà không cần xoá.

### 8.4 Xoá mã

Nhấn nút 🗑️ — hệ thống hiện hộp thoại xác nhận trước khi xoá vĩnh viễn.

> **Khuyến nghị:** Tắt mã thay vì xoá để giữ lại lịch sử. Chỉ xoá khi mã tạo nhầm.

---

## 9. Phân quyền và bảo mật

### Phân quyền admin

Trang quản trị chỉ dành cho tài khoản có role `SYSTEM_ADMIN`. Mọi route `/admin/**` (trừ `/admin/login`) đều yêu cầu xác thực qua form login.

### Tách biệt với REST API

| | Admin Web | REST API |
|---|---|---|
| URL prefix | `/admin/**` | `/api/**` |
| Xác thực | Session cookie (form login) | JWT Bearer token |
| Phiên đăng nhập | Stateful (server lưu session) | Stateless |
| CSRF | Bật (form POST có `_csrf` token) | Tắt |

### Lưu ý bảo mật

- **Đổi mật khẩu admin ngay** sau khi triển khai production — tài khoản seed `admin@foodrush.vn / Admin@123` là mật khẩu mặc định.
- Session tối đa **3 phiên đồng thời** cho một tài khoản admin.
- Đăng xuất luôn khi rời máy tính để tránh session bị chiếm dụng.
- Trong môi trường production, đặt admin site sau VPN hoặc IP whitelist.

---

## Câu hỏi thường gặp

**Q: Tôi đăng nhập thấy màn hình trắng / redirect về /admin/login?**  
A: Tài khoản không có role `SYSTEM_ADMIN`. Kiểm tra bảng `users`, cột `role`.

**Q: Tôi muốn cập nhật trạng thái đơn hàng qua trang admin, có được không?**  
A: Trang admin hiện chỉ xem đơn. Để cập nhật trạng thái, dùng REST API:
```
PUT /api/v1/orders/{orderId}/status
Authorization: Bearer <jwt_token>
Body: { "status": "CONFIRMED" }
```

**Q: Mã giảm giá tạo xong không áp dụng được?**  
A: Kiểm tra các điều kiện: (1) mã đang `active`, (2) thời gian hiện tại trong khoảng `startDate` → `endDate`, (3) giá trị đơn hàng đạt `minOrderAmount`, (4) chưa vượt `usageLimit`.

**Q: Cách thêm nhà hàng mới?**  
A: Trang admin không có form thêm nhà hàng. Tạo nhà hàng qua REST API:
```
POST /api/v1/restaurants
Authorization: Bearer <jwt_token_of_SYSTEM_ADMIN>
```

**Q: Docker build lâu quá?**  
A: Sau lần build đầu, các lần sau sẽ dùng cache Maven layer, nhanh hơn nhiều. Dùng `docker compose build app` (không có `--no-cache`).
