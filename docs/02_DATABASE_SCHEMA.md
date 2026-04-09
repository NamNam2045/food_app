# FoodRush — Database Schema (ERD)

**Database:** PostgreSQL 16  
**Convention:** snake_case, BIGSERIAL PKs, audit columns (created_at, updated_at) trên tất cả bảng

---

## Tổng quan Quan hệ

```
users ──────────────────────── addresses (1:N)
users ──────────────────────── restaurants (1:N, owner)
users ──────────────────────── carts (1:1)
users ──────────────────────── orders (1:N)
users ──────────────────────── reviews (1:N)

restaurants ─────────────────── operating_hours (1:N)
restaurants ─────────────────── menu_categories (1:N)
menu_categories ─────────────── menu_items (1:N)

carts ───────────────────────── cart_items (1:N)
cart_items ──────────────────── menu_items (N:1)

orders ──────────────────────── order_items (1:N)
orders ──────────────────────── order_status_history (1:N)
orders ──────────────────────── payments (1:1)
order_items ─────────────────── menu_items (N:1)

reviews ─────────────────────── restaurants (N:1)
reviews ─────────────────────── orders (1:1)
```

---

## Bảng Chi tiết

### 1. `users`

| Column | Type | Constraints | Mô tả |
|--------|------|-------------|-------|
| id | BIGSERIAL | PK | |
| email | VARCHAR(255) | UNIQUE NOT NULL | |
| phone_number | VARCHAR(20) | UNIQUE | |
| password_hash | VARCHAR(255) | NOT NULL | bcrypt |
| first_name | VARCHAR(100) | NOT NULL | |
| last_name | VARCHAR(100) | NOT NULL | |
| role | VARCHAR(30) | NOT NULL | CUSTOMER / RESTAURANT_ADMIN / DELIVERY_AGENT / SYSTEM_ADMIN |
| profile_picture_url | TEXT | | |
| fcm_token | VARCHAR(255) | | Firebase push token |
| is_active | BOOLEAN | DEFAULT true | |
| is_email_verified | BOOLEAN | DEFAULT false | |
| email_verification_token | VARCHAR(255) | | |
| password_reset_token | VARCHAR(255) | | |
| password_reset_expires_at | TIMESTAMPTZ | | |
| last_login_at | TIMESTAMPTZ | | |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |

---

### 2. `addresses`

| Column | Type | Constraints | Mô tả |
|--------|------|-------------|-------|
| id | BIGSERIAL | PK | |
| user_id | BIGINT | FK → users(id) NOT NULL | |
| label | VARCHAR(50) | NOT NULL | "Nhà", "Công ty", "Khác" |
| street_line_1 | VARCHAR(255) | NOT NULL | |
| street_line_2 | VARCHAR(255) | | |
| city | VARCHAR(100) | NOT NULL | |
| state | VARCHAR(100) | NOT NULL | |
| postal_code | VARCHAR(20) | NOT NULL | |
| country_code | CHAR(2) | DEFAULT 'VN' | ISO 3166-1 |
| latitude | DECIMAL(10,7) | | |
| longitude | DECIMAL(10,7) | | |
| is_default | BOOLEAN | DEFAULT false | |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |

---

### 3. `restaurants`

| Column | Type | Constraints | Mô tả |
|--------|------|-------------|-------|
| id | BIGSERIAL | PK | |
| owner_id | BIGINT | FK → users(id) NOT NULL | |
| name | VARCHAR(255) | NOT NULL | |
| slug | VARCHAR(255) | UNIQUE NOT NULL | URL-safe identifier |
| description | TEXT | | |
| cuisine_type | VARCHAR(100) | NOT NULL | "Việt Nam", "Nhật", "Hàn"... |
| logo_url | TEXT | | |
| banner_url | TEXT | | |
| phone | VARCHAR(20) | | |
| email | VARCHAR(255) | | |
| street_address | VARCHAR(255) | NOT NULL | |
| city | VARCHAR(100) | NOT NULL | |
| latitude | DECIMAL(10,7) | | |
| longitude | DECIMAL(10,7) | | |
| rating_avg | DECIMAL(3,2) | DEFAULT 0.00 | Cập nhật khi có review |
| rating_count | INTEGER | DEFAULT 0 | |
| min_order_amount | DECIMAL(12,2) | DEFAULT 0 | |
| delivery_fee | DECIMAL(12,2) | DEFAULT 0 | |
| estimated_delivery_minutes | INTEGER | DEFAULT 30 | |
| is_active | BOOLEAN | DEFAULT true | |
| is_open | BOOLEAN | DEFAULT false | Tính từ operating_hours |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |

---

### 4. `operating_hours`

| Column | Type | Constraints | Mô tả |
|--------|------|-------------|-------|
| id | BIGSERIAL | PK | |
| restaurant_id | BIGINT | FK → restaurants(id) NOT NULL | |
| day_of_week | SMALLINT | NOT NULL | 0=CN, 1=T2...6=T7 |
| open_time | TIME | NOT NULL | |
| close_time | TIME | NOT NULL | |
| is_closed | BOOLEAN | DEFAULT false | Ngày nghỉ |

---

### 5. `menu_categories`

| Column | Type | Constraints | Mô tả |
|--------|------|-------------|-------|
| id | BIGSERIAL | PK | |
| restaurant_id | BIGINT | FK → restaurants(id) NOT NULL | |
| name | VARCHAR(100) | NOT NULL | "Khai vị", "Món chính"... |
| description | TEXT | | |
| display_order | INTEGER | DEFAULT 0 | Thứ tự hiển thị |
| is_active | BOOLEAN | DEFAULT true | |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |

---

### 6. `menu_items`

| Column | Type | Constraints | Mô tả |
|--------|------|-------------|-------|
| id | BIGSERIAL | PK | |
| category_id | BIGINT | FK → menu_categories(id) NOT NULL | |
| restaurant_id | BIGINT | FK → restaurants(id) NOT NULL | Denormalized |
| name | VARCHAR(255) | NOT NULL | |
| description | TEXT | | |
| price | DECIMAL(12,2) | NOT NULL | |
| image_url | TEXT | | |
| is_available | BOOLEAN | DEFAULT true | |
| is_featured | BOOLEAN | DEFAULT false | |
| calories | INTEGER | | |
| preparation_time_minutes | INTEGER | DEFAULT 15 | |
| display_order | INTEGER | DEFAULT 0 | |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |

---

### 7. `carts`

| Column | Type | Constraints | Mô tả |
|--------|------|-------------|-------|
| id | BIGSERIAL | PK | |
| user_id | BIGINT | FK → users(id) UNIQUE NOT NULL | 1 user = 1 cart |
| restaurant_id | BIGINT | FK → restaurants(id) | Giỏ hàng của nhà hàng nào |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |

---

### 8. `cart_items`

| Column | Type | Constraints | Mô tả |
|--------|------|-------------|-------|
| id | BIGSERIAL | PK | |
| cart_id | BIGINT | FK → carts(id) NOT NULL | |
| menu_item_id | BIGINT | FK → menu_items(id) NOT NULL | |
| quantity | INTEGER | NOT NULL DEFAULT 1, CHECK > 0 | |
| unit_price | DECIMAL(12,2) | NOT NULL | Giá tại thời điểm thêm |
| special_instructions | TEXT | | Ghi chú riêng |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |

---

### 9. `orders`

| Column | Type | Constraints | Mô tả |
|--------|------|-------------|-------|
| id | BIGSERIAL | PK | |
| order_number | VARCHAR(20) | UNIQUE NOT NULL | "FR-20260402-00001" |
| user_id | BIGINT | FK → users(id) NOT NULL | |
| restaurant_id | BIGINT | FK → restaurants(id) NOT NULL | |
| delivery_agent_id | BIGINT | FK → users(id) | Shipper |
| status | VARCHAR(30) | NOT NULL | Xem bảng trạng thái bên dưới |
| delivery_address_snapshot | JSONB | NOT NULL | Snapshot địa chỉ lúc đặt |
| subtotal | DECIMAL(12,2) | NOT NULL | |
| delivery_fee | DECIMAL(12,2) | NOT NULL | |
| discount_amount | DECIMAL(12,2) | DEFAULT 0 | |
| total_amount | DECIMAL(12,2) | NOT NULL | |
| special_instructions | TEXT | | |
| estimated_delivery_at | TIMESTAMPTZ | | |
| delivered_at | TIMESTAMPTZ | | |
| cancelled_at | TIMESTAMPTZ | | |
| cancellation_reason | TEXT | | |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |

**Vòng đời trạng thái đơn hàng:**
```
PENDING → CONFIRMED → PREPARING → READY_FOR_PICKUP
       → PICKED_UP → ON_THE_WAY → DELIVERED
       → CANCELLED (từ PENDING hoặc CONFIRMED)
```

---

### 10. `order_items`

| Column | Type | Constraints | Mô tả |
|--------|------|-------------|-------|
| id | BIGSERIAL | PK | |
| order_id | BIGINT | FK → orders(id) NOT NULL | |
| menu_item_id | BIGINT | FK → menu_items(id) NOT NULL | |
| menu_item_name | VARCHAR(255) | NOT NULL | Snapshot tên |
| quantity | INTEGER | NOT NULL | |
| unit_price | DECIMAL(12,2) | NOT NULL | Snapshot giá |
| subtotal | DECIMAL(12,2) | NOT NULL | quantity × unit_price |
| special_instructions | TEXT | | |

---

### 11. `order_status_history`

| Column | Type | Constraints | Mô tả |
|--------|------|-------------|-------|
| id | BIGSERIAL | PK | |
| order_id | BIGINT | FK → orders(id) NOT NULL | |
| status | VARCHAR(30) | NOT NULL | |
| notes | TEXT | | |
| changed_by_user_id | BIGINT | FK → users(id) | |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |

---

### 12. `payments`

| Column | Type | Constraints | Mô tả |
|--------|------|-------------|-------|
| id | BIGSERIAL | PK | |
| order_id | BIGINT | FK → orders(id) UNIQUE NOT NULL | |
| payment_method | VARCHAR(30) | NOT NULL | COD / CREDIT_CARD / MOMO / ZALOPAY |
| payment_status | VARCHAR(30) | NOT NULL | PENDING / PAID / FAILED / REFUNDED |
| amount | DECIMAL(12,2) | NOT NULL | |
| transaction_id | VARCHAR(255) | | ID từ payment gateway |
| gateway_response | JSONB | | Raw response từ gateway |
| paid_at | TIMESTAMPTZ | | |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |

---

### 13. `reviews`

| Column | Type | Constraints | Mô tả |
|--------|------|-------------|-------|
| id | BIGSERIAL | PK | |
| order_id | BIGINT | FK → orders(id) UNIQUE NOT NULL | 1 đơn = 1 review |
| user_id | BIGINT | FK → users(id) NOT NULL | |
| restaurant_id | BIGINT | FK → restaurants(id) NOT NULL | |
| rating | SMALLINT | NOT NULL, CHECK 1-5 | |
| comment | TEXT | | |
| is_visible | BOOLEAN | DEFAULT true | Admin có thể ẩn |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |

---

### 14. `refresh_tokens`

| Column | Type | Constraints | Mô tả |
|--------|------|-------------|-------|
| id | BIGSERIAL | PK | |
| user_id | BIGINT | FK → users(id) NOT NULL | |
| token_hash | VARCHAR(255) | NOT NULL | SHA-256 của token |
| expires_at | TIMESTAMPTZ | NOT NULL | |
| is_revoked | BOOLEAN | DEFAULT false | |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT NOW() | |

---

## Indexes Khuyến nghị

```sql
-- users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone_number);

-- restaurants
CREATE INDEX idx_restaurants_city ON restaurants(city);
CREATE INDEX idx_restaurants_cuisine ON restaurants(cuisine_type);
CREATE INDEX idx_restaurants_location ON restaurants USING gist(
  ll_to_earth(latitude, longitude)
);

-- menu_items
CREATE INDEX idx_menu_items_restaurant ON menu_items(restaurant_id);
CREATE INDEX idx_menu_items_category ON menu_items(category_id);

-- orders
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_restaurant ON orders(restaurant_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);

-- cart_items
CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);
```
