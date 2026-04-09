# FoodRush — API Specification

**Base URL:** `https://api.foodrush.vn/api/v1`  
**Auth:** Bearer JWT trong header `Authorization: Bearer <token>`  
**Content-Type:** `application/json`  
**Response format chung:**

```json
{
  "success": true,
  "message": "OK",
  "data": { ... },
  "timestamp": "2026-04-02T10:00:00Z"
}
```

**Error response:**
```json
{
  "success": false,
  "message": "Lỗi xác thực",
  "errorCode": "AUTH_001",
  "details": ["Email không hợp lệ"],
  "timestamp": "2026-04-02T10:00:00Z"
}
```

---

## Module 1: Authentication `/auth`

### POST `/auth/register`
Đăng ký tài khoản mới.

**Request:**
```json
{
  "firstName": "Nguyen",
  "lastName": "Van A",
  "email": "vana@email.com",
  "phoneNumber": "0901234567",
  "password": "P@ssw0rd123"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "vana@email.com",
    "firstName": "Nguyen",
    "lastName": "Van A",
    "role": "CUSTOMER",
    "accessToken": "eyJhbG...",
    "refreshToken": "eyJhbG...",
    "accessTokenExpiresIn": 900
  }
}
```

---

### POST `/auth/login`
Đăng nhập.

**Request:**
```json
{
  "email": "vana@email.com",
  "password": "P@ssw0rd123"
}
```

**Response 200:** Giống `/auth/register`

---

### POST `/auth/refresh`
Làm mới access token.

**Request:**
```json
{ "refreshToken": "eyJhbG..." }
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbG...",
    "refreshToken": "eyJhbG...",
    "accessTokenExpiresIn": 900
  }
}
```

---

### POST `/auth/logout`
Đăng xuất (thu hồi refresh token).

**Auth required:** Yes

**Request:**
```json
{ "refreshToken": "eyJhbG..." }
```

**Response 200:** `{ "success": true, "message": "Đăng xuất thành công" }`

---

### POST `/auth/forgot-password`
Gửi email reset mật khẩu.

**Request:** `{ "email": "vana@email.com" }`

**Response 200:** `{ "success": true, "message": "Email đã được gửi" }`

---

### POST `/auth/reset-password`
Đặt lại mật khẩu với token từ email.

**Request:**
```json
{
  "token": "abc123",
  "newPassword": "NewP@ss123"
}
```

---

## Module 2: User Profile `/users`

### GET `/users/me`
Lấy thông tin profile hiện tại. **Auth required.**

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "vana@email.com",
    "firstName": "Nguyen",
    "lastName": "Van A",
    "phoneNumber": "0901234567",
    "role": "CUSTOMER",
    "profilePictureUrl": "https://...",
    "isEmailVerified": true,
    "createdAt": "2026-01-15T08:00:00Z"
  }
}
```

---

### PUT `/users/me`
Cập nhật profile. **Auth required.**

**Request:**
```json
{
  "firstName": "Nguyen",
  "lastName": "Van B",
  "phoneNumber": "0909876543",
  "profilePictureUrl": "https://..."
}
```

---

### GET `/users/me/addresses`
Lấy danh sách địa chỉ. **Auth required.**

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 10,
      "label": "Nhà",
      "streetLine1": "123 Đường ABC",
      "city": "Hồ Chí Minh",
      "latitude": 10.7769,
      "longitude": 106.7009,
      "isDefault": true
    }
  ]
}
```

---

### POST `/users/me/addresses`
Thêm địa chỉ mới. **Auth required.**

**Request:**
```json
{
  "label": "Công ty",
  "streetLine1": "456 Đường XYZ",
  "streetLine2": "Tầng 5",
  "city": "Hồ Chí Minh",
  "state": "Hồ Chí Minh",
  "postalCode": "70000",
  "countryCode": "VN",
  "latitude": 10.7800,
  "longitude": 106.6950,
  "isDefault": false
}
```

---

### PUT `/users/me/addresses/{addressId}`
Cập nhật địa chỉ. **Auth required.**

### DELETE `/users/me/addresses/{addressId}`
Xóa địa chỉ. **Auth required.**

---

## Module 3: Restaurants `/restaurants`

### GET `/restaurants`
Lấy danh sách nhà hàng với filter & pagination.

**Query params:**
| Param | Type | Mô tả |
|-------|------|-------|
| city | string | Lọc theo thành phố |
| cuisineType | string | Lọc theo loại ẩm thực |
| search | string | Tìm kiếm theo tên |
| lat | double | Vĩ độ người dùng |
| lng | double | Kinh độ người dùng |
| maxDistance | int | Bán kính km (mặc định 10) |
| minRating | double | Rating tối thiểu |
| isOpen | boolean | Chỉ nhà hàng đang mở |
| page | int | Mặc định 0 |
| size | int | Mặc định 20 |
| sortBy | string | `rating` / `distance` / `deliveryTime` |

**Response 200:**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 5,
        "name": "Phở Hà Nội",
        "slug": "pho-ha-noi",
        "cuisineType": "Việt Nam",
        "logoUrl": "https://...",
        "bannerUrl": "https://...",
        "ratingAvg": 4.7,
        "ratingCount": 230,
        "deliveryFee": 15000,
        "estimatedDeliveryMinutes": 25,
        "isOpen": true,
        "distanceKm": 1.2
      }
    ],
    "totalElements": 48,
    "totalPages": 3,
    "currentPage": 0,
    "pageSize": 20
  }
}
```

---

### GET `/restaurants/{idOrSlug}`
Chi tiết nhà hàng.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 5,
    "name": "Phở Hà Nội",
    "slug": "pho-ha-noi",
    "description": "Phở truyền thống từ năm 1990...",
    "cuisineType": "Việt Nam",
    "phone": "028-1234-5678",
    "streetAddress": "789 Nguyễn Trãi",
    "city": "Hồ Chí Minh",
    "latitude": 10.7769,
    "longitude": 106.7009,
    "ratingAvg": 4.7,
    "ratingCount": 230,
    "minOrderAmount": 50000,
    "deliveryFee": 15000,
    "estimatedDeliveryMinutes": 25,
    "isOpen": true,
    "operatingHours": [
      {
        "dayOfWeek": 1,
        "openTime": "07:00",
        "closeTime": "22:00",
        "isClosed": false
      }
    ]
  }
}
```

---

### POST `/restaurants` *(RESTAURANT_ADMIN)*
Tạo nhà hàng mới. **Auth required (RESTAURANT_ADMIN).**

### PUT `/restaurants/{id}` *(RESTAURANT_ADMIN)*
Cập nhật nhà hàng. **Auth required.**

### DELETE `/restaurants/{id}` *(SYSTEM_ADMIN)*
Xóa nhà hàng.

---

## Module 4: Menu `/restaurants/{restaurantId}/menu`

### GET `/restaurants/{restaurantId}/menu`
Lấy toàn bộ menu theo danh mục.

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Các loại Phở",
      "displayOrder": 1,
      "items": [
        {
          "id": 10,
          "name": "Phở Bò Tái",
          "description": "Phở bò tái thơm ngon...",
          "price": 65000,
          "imageUrl": "https://...",
          "isAvailable": true,
          "isFeatured": true,
          "calories": 450,
          "preparationTimeMinutes": 10
        }
      ]
    }
  ]
}
```

---

### GET `/restaurants/{restaurantId}/menu/items/{itemId}`
Chi tiết một món ăn.

---

### POST `/restaurants/{restaurantId}/menu/categories` *(RESTAURANT_ADMIN)*
Thêm danh mục menu.

**Request:**
```json
{
  "name": "Đồ uống",
  "description": "Các loại nước giải khát",
  "displayOrder": 5
}
```

---

### POST `/restaurants/{restaurantId}/menu/items` *(RESTAURANT_ADMIN)*
Thêm món ăn vào menu.

**Request:**
```json
{
  "categoryId": 3,
  "name": "Phở Gà",
  "description": "Phở gà truyền thống",
  "price": 55000,
  "imageUrl": "https://...",
  "isAvailable": true,
  "calories": 380,
  "preparationTimeMinutes": 8
}
```

---

### PUT `/restaurants/{restaurantId}/menu/items/{itemId}` *(RESTAURANT_ADMIN)*
Cập nhật món ăn.

### DELETE `/restaurants/{restaurantId}/menu/items/{itemId}` *(RESTAURANT_ADMIN)*
Xóa món ăn.

---

## Module 5: Cart `/cart`

### GET `/cart`
Lấy giỏ hàng hiện tại. **Auth required.**

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 7,
    "restaurantId": 5,
    "restaurantName": "Phở Hà Nội",
    "items": [
      {
        "id": 21,
        "menuItemId": 10,
        "menuItemName": "Phở Bò Tái",
        "menuItemImageUrl": "https://...",
        "quantity": 2,
        "unitPrice": 65000,
        "subtotal": 130000,
        "specialInstructions": "Ít hành"
      }
    ],
    "itemCount": 2,
    "subtotal": 130000,
    "deliveryFee": 15000,
    "total": 145000
  }
}
```

---

### POST `/cart/items`
Thêm món vào giỏ. **Auth required.**

**Request:**
```json
{
  "menuItemId": 10,
  "quantity": 1,
  "specialInstructions": "Ít hành"
}
```

> **Lưu ý:** Nếu thêm món từ nhà hàng khác, trả về lỗi 409 với `errorCode: CART_RESTAURANT_CONFLICT` và yêu cầu xác nhận xóa giỏ cũ.

---

### PUT `/cart/items/{cartItemId}`
Cập nhật số lượng.

**Request:** `{ "quantity": 3 }`

---

### DELETE `/cart/items/{cartItemId}`
Xóa một món khỏi giỏ.

### DELETE `/cart`
Xóa toàn bộ giỏ hàng.

---

## Module 6: Orders `/orders`

### POST `/orders`
Đặt hàng từ giỏ hàng hiện tại. **Auth required.**

**Request:**
```json
{
  "deliveryAddressId": 10,
  "paymentMethod": "COD",
  "specialInstructions": "Gọi điện trước khi giao",
  "promoCode": "FIRST10"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": 100,
    "orderNumber": "FR-20260402-00100",
    "status": "PENDING",
    "restaurantName": "Phở Hà Nội",
    "items": [ ... ],
    "subtotal": 130000,
    "deliveryFee": 15000,
    "discountAmount": 13000,
    "totalAmount": 132000,
    "estimatedDeliveryAt": "2026-04-02T11:30:00Z",
    "createdAt": "2026-04-02T11:00:00Z"
  }
}
```

---

### GET `/orders`
Lịch sử đơn hàng của user hiện tại. **Auth required.**

**Query params:** `page`, `size`, `status`

**Response 200:** Danh sách đơn rút gọn (orderNumber, status, totalAmount, restaurantName, createdAt)

---

### GET `/orders/{orderId}`
Chi tiết đơn hàng. **Auth required.**

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 100,
    "orderNumber": "FR-20260402-00100",
    "status": "PREPARING",
    "restaurant": {
      "id": 5,
      "name": "Phở Hà Nội",
      "phone": "028-1234-5678"
    },
    "deliveryAgent": {
      "id": 25,
      "firstName": "Tran",
      "lastName": "Van B",
      "phone": "0912345678"
    },
    "deliveryAddress": {
      "label": "Nhà",
      "streetLine1": "123 Đường ABC",
      "city": "Hồ Chí Minh"
    },
    "items": [
      {
        "menuItemName": "Phở Bò Tái",
        "quantity": 2,
        "unitPrice": 65000,
        "subtotal": 130000
      }
    ],
    "statusHistory": [
      { "status": "PENDING", "createdAt": "2026-04-02T11:00:00Z" },
      { "status": "CONFIRMED", "createdAt": "2026-04-02T11:02:00Z" },
      { "status": "PREPARING", "createdAt": "2026-04-02T11:05:00Z" }
    ],
    "subtotal": 130000,
    "deliveryFee": 15000,
    "discountAmount": 13000,
    "totalAmount": 132000,
    "paymentMethod": "COD",
    "paymentStatus": "PENDING",
    "estimatedDeliveryAt": "2026-04-02T11:30:00Z",
    "createdAt": "2026-04-02T11:00:00Z"
  }
}
```

---

### PATCH `/orders/{orderId}/cancel`
Hủy đơn hàng (chỉ khi PENDING / CONFIRMED). **Auth required.**

**Request:** `{ "reason": "Tôi đặt nhầm" }`

---

### PUT `/orders/{orderId}/status` *(RESTAURANT_ADMIN / DELIVERY_AGENT)*
Cập nhật trạng thái đơn hàng. **Auth required.**

**Request:**
```json
{
  "status": "PREPARING",
  "notes": "Đơn hàng đang được chuẩn bị"
}
```

---

### GET `/restaurants/{restaurantId}/orders` *(RESTAURANT_ADMIN)*
Danh sách đơn hàng của nhà hàng.

**Query params:** `status`, `date`, `page`, `size`

---

## Module 7: Reviews `/reviews`

### POST `/reviews`
Đánh giá đơn hàng đã giao. **Auth required.**

**Request:**
```json
{
  "orderId": 100,
  "rating": 5,
  "comment": "Phở ngon, giao nhanh!"
}
```

---

### GET `/restaurants/{restaurantId}/reviews`
Danh sách đánh giá của nhà hàng.

**Query params:** `page`, `size`, `minRating`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "averageRating": 4.7,
    "totalReviews": 230,
    "ratingDistribution": {
      "5": 150, "4": 60, "3": 15, "2": 3, "1": 2
    },
    "reviews": [
      {
        "id": 55,
        "user": { "firstName": "Nguyen", "profilePictureUrl": "..." },
        "rating": 5,
        "comment": "Rất ngon!",
        "createdAt": "2026-03-20T12:00:00Z"
      }
    ],
    "totalElements": 230,
    "totalPages": 12,
    "currentPage": 0
  }
}
```

---

## Module 8: WebSocket — Order Tracking

**Endpoint:** `wss://api.foodrush.vn/ws`  
**Protocol:** STOMP over WebSocket

### Subscribe kênh theo dõi đơn hàng:
```
SUBSCRIBE /user/queue/orders/{orderId}/status
```

### Server push khi trạng thái thay đổi:
```json
{
  "orderId": 100,
  "orderNumber": "FR-20260402-00100",
  "newStatus": "ON_THE_WAY",
  "previousStatus": "PICKED_UP",
  "message": "Shipper đang trên đường giao hàng",
  "estimatedDeliveryAt": "2026-04-02T11:30:00Z",
  "timestamp": "2026-04-02T11:20:00Z"
}
```

---

## HTTP Status Codes

| Code | Ý nghĩa |
|------|---------|
| 200 | OK |
| 201 | Created |
| 204 | No Content (DELETE) |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (token missing/invalid) |
| 403 | Forbidden (không đủ quyền) |
| 404 | Not Found |
| 409 | Conflict (đặt hàng từ nhà hàng khác...) |
| 422 | Unprocessable Entity (business rule violation) |
| 429 | Too Many Requests (rate limit) |
| 500 | Internal Server Error |

---

## Error Codes

| Code | Mô tả |
|------|-------|
| AUTH_001 | Token không hợp lệ hoặc hết hạn |
| AUTH_002 | Refresh token không hợp lệ |
| AUTH_003 | Email đã tồn tại |
| CART_001 | Giỏ hàng trống |
| CART_002 | Món không còn có sẵn |
| CART_003 | Xung đột nhà hàng trong giỏ |
| ORDER_001 | Không thể hủy đơn ở trạng thái này |
| ORDER_002 | Không đủ điều kiện đặt hàng (min order) |
| REVIEW_001 | Đơn hàng chưa được giao |
| REVIEW_002 | Đã đánh giá đơn hàng này |
