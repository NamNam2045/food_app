# FoodRush — Flutter Screens & Navigation Flow

**Pattern:** BLoC + Clean Architecture  
**Navigation:** GoRouter (named routes)  
**State:** flutter_bloc  

---

## Navigation Flow Tổng quan

```
App Launch
    │
    ▼
[SplashScreen] ──── Kiểm tra token
    │
    ├── Có token valid ──► [HomeScreen] (Bottom Nav)
    │
    └── Không có token ──► [OnboardingScreen]
                                │
                        ┌───────┴────────┐
                        ▼                ▼
                  [LoginScreen]   [RegisterScreen]
                        │
                        ▼
                  [HomeScreen] (Bottom Nav)


[HomeScreen] Bottom Navigation:
    ├── Tab 0: [DiscoverScreen]    (Khám phá nhà hàng)
    ├── Tab 1: [SearchScreen]      (Tìm kiếm)
    ├── Tab 2: [OrdersScreen]      (Đơn hàng của tôi)
    └── Tab 3: [ProfileScreen]     (Hồ sơ)
```

---

## Screens Chi tiết

### 1. SplashScreen
**Route:** `/`  
**Chức năng:** Hiển thị logo, kiểm tra JWT còn hạn không, điều hướng tương ứng.  
**Thời gian hiển thị:** Tối đa 2 giây.

```
┌─────────────────────────┐
│                         │
│                         │
│    🍜  FoodRush          │
│                         │
│    ████████████ 80%     │
│                         │
└─────────────────────────┘
```

---

### 2. OnboardingScreen
**Route:** `/onboarding`  
**Chức năng:** 3 slide giới thiệu tính năng.

```
┌─────────────────────────┐
│  [●  ○  ○]              │
│                         │
│   🍕                    │
│                         │
│  Đặt đồ ăn yêu thích    │
│  Nhanh chóng, tiện lợi  │
│                         │
│  [Tiếp theo →]          │
│  [Bỏ qua]               │
└─────────────────────────┘
```

---

### 3. LoginScreen
**Route:** `/login`

```
┌─────────────────────────┐
│ ← Đăng nhập             │
│                         │
│  [Email input field   ] │
│  [Password input     🔑]│
│                         │
│  Quên mật khẩu?         │
│                         │
│  [    ĐĂNG NHẬP    ]    │
│                         │
│  ─────── hoặc ──────    │
│  [  Đăng nhập Google ]  │
│                         │
│  Chưa có tài khoản?     │
│  Đăng ký ngay           │
└─────────────────────────┘
```

**BLoC events:** `LoginSubmitted`, `PasswordVisibilityToggled`  
**BLoC states:** `LoginInitial`, `LoginLoading`, `LoginSuccess`, `LoginFailure`

---

### 4. RegisterScreen
**Route:** `/register`

```
┌─────────────────────────┐
│ ← Đăng ký               │
│                         │
│  [Họ           ] [Tên ] │
│  [Email               ] │
│  [Số điện thoại       ] │
│  [Mật khẩu         🔑 ] │
│  [Nhập lại mật khẩu  ] │
│                         │
│  ☑ Tôi đồng ý với       │
│    Điều khoản sử dụng   │
│                         │
│  [    ĐĂNG KÝ      ]    │
└─────────────────────────┘
```

---

### 5. HomeScreen (DiscoverTab)
**Route:** `/home`

```
┌─────────────────────────┐
│ 📍 Hồ Chí Minh     🔔  │
│ Xin chào, Nguyen!       │
│                         │
│ [🔍 Tìm món ăn...    ]  │
│                         │
│ Danh mục               │
│ [🍜][🍕][🍱][🍔][🥗][+]│
│                         │
│ ⭐ Nhà hàng nổi bật    │
│ ┌─────────┐ ┌─────────┐ │
│ │ [img]   │ │ [img]   │ │
│ │ Phở HN  │ │ Pizza VN│ │
│ │ ⭐4.7   │ │ ⭐4.5   │ │
│ │ 25 phút │ │ 30 phút │ │
│ └─────────┘ └─────────┘ │
│                         │
│ Gần bạn                 │
│ [RestaurantCard...]     │
│ [RestaurantCard...]     │
│                         │
│ [🏠][🔍][📦][👤]       │
└─────────────────────────┘
```

**Widgets:** `RestaurantCard`, `CategoryFilterChip`, `FeaturedBanner`

---

### 6. RestaurantListScreen
**Route:** `/restaurants`

```
┌─────────────────────────┐
│ ← Nhà hàng Việt Nam     │
│ [🔍 Tìm...          ]   │
│                         │
│ Sắp xếp: [Rating ▼]    │
│ [Mở cửa][Gần nhất][...]│
│                         │
│ ┌───────────────────┐   │
│ │ [banner img]      │   │
│ │ Phở Hà Nội        │   │
│ │ ⭐4.7 (230) • 1.2km│  │
│ │ 25 phút • 15.000đ  │   │
│ └───────────────────┘   │
│                         │
│ ┌───────────────────┐   │
│ │ [banner img]      │   │
│ │ Bún Bò Huế        │   │
│ │ ⭐4.5 (95) • 2.1km │   │
│ └───────────────────┘   │
└─────────────────────────┘
```

---

### 7. RestaurantDetailScreen
**Route:** `/restaurants/:id`

```
┌─────────────────────────┐
│ [───── banner image ───]│
│ ←                  ♡   │
│                         │
│ Phở Hà Nội              │
│ Việt Nam • ⭐4.7 (230)  │
│ 🕐 25-35 phút  📦15k   │
│ ✅ Đang mở cửa          │
│                         │
│ [Thông tin][Đánh giá]  │
│ ─────────────────────   │
│                         │
│ 🏷 Các loại Phở         │
│ ┌─────────────────────┐ │
│ │[img] Phở Bò Tái     │ │
│ │      65.000đ   [+]  │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │[img] Phở Gà         │ │
│ │      55.000đ   [+]  │ │
│ └─────────────────────┘ │
│                         │
│ [     Xem giỏ (2)  ]   │
└─────────────────────────┘
```

**Widgets:** `MenuCategoryTab`, `MenuItemCard`, `FloatingCartBar`

---

### 8. ItemDetailScreen
**Route:** `/restaurants/:id/items/:itemId`

```
┌─────────────────────────┐
│ ← Chi tiết món          │
│ [────── item image ────]│
│                         │
│ Phở Bò Tái              │
│ 65.000đ                 │
│ 🕐 ~10 phút  🔥450 kcal│
│                         │
│ Mô tả:                  │
│ Phở bò tái thơm ngon... │
│                         │
│ Ghi chú đặc biệt:       │
│ [Ít hành, nhiều giá    ]│
│                         │
│ Số lượng:               │
│ [−]  2  [+]             │
│                         │
│ [  Thêm vào giỏ 130k  ]│
└─────────────────────────┘
```

---

### 9. CartScreen
**Route:** `/cart`

```
┌─────────────────────────┐
│ ← Giỏ hàng (3 món)     │
│                         │
│ 📍 Phở Hà Nội           │
│                         │
│ ┌─────────────────────┐ │
│ │ Phở Bò Tái          │ │
│ │ Ít hành             │ │
│ │ [−] 2 [+]  130.000đ │ │
│ │                  🗑  │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │ Nước ngọt           │ │
│ │ [−] 1 [+]   15.000đ │ │
│ └─────────────────────┘ │
│                         │
│ Thêm ghi chú đơn hàng   │
│ [                     ] │
│                         │
│ ─── Tóm tắt đơn hàng── │
│ Tạm tính:     145.000đ  │
│ Phí giao hàng:  15.000đ │
│ Khuyến mãi:    -14.500đ │
│ ──────────────────────  │
│ Tổng cộng:    145.500đ  │
│                         │
│ [   TIẾN HÀNH ĐẶT   ]  │
└─────────────────────────┘
```

---

### 10. CheckoutScreen
**Route:** `/checkout`

```
┌─────────────────────────┐
│ ← Xác nhận đặt hàng    │
│                         │
│ 📍 Giao đến             │
│ ┌─────────────────────┐ │
│ │ 🏠 Nhà              │ │
│ │ 123 Đường ABC, Q.1  │ │
│ │               [Đổi] │ │
│ └─────────────────────┘ │
│                         │
│ 💳 Phương thức thanh toán│
│ ○ Tiền mặt (COD)        │
│ ○ Thẻ ngân hàng         │
│ ○ MoMo                  │
│ ○ ZaloPay               │
│                         │
│ 🎟 Mã giảm giá          │
│ [NHẬP MÃ...       ÁP]  │
│                         │
│ ─── Tóm tắt ───         │
│ Tổng cộng:    145.500đ  │
│                         │
│ [   XÁC NHẬN ĐẶT    ]  │
└─────────────────────────┘
```

---

### 11. OrderTrackingScreen
**Route:** `/orders/:orderId/tracking`

```
┌─────────────────────────┐
│ ← Theo dõi đơn hàng    │
│ #FR-20260402-00100      │
│                         │
│ ✅ Đặt hàng thành công  │
│ ✅ Nhà hàng xác nhận    │
│ ✅ Đang chuẩn bị        │
│ 🔄 Đang giao hàng  ←NOW │
│ ○  Đã giao              │
│                         │
│ ⏱ Dự kiến: 15 phút nữa  │
│                         │
│ 🏍 Shipper: Trần Văn B  │
│ 📞 Gọi shipper          │
│                         │
│ [────── MAP VIEW ──────]│
│ [   (Google Maps)     ] │
│ [                     ] │
│                         │
│ 📍 Phở Hà Nội → Nhà bạn │
│                         │
│ [   Liên hệ nhà hàng  ]│
└─────────────────────────┘
```

**Real-time:** Subscribe STOMP WebSocket khi màn hình active.

---

### 12. OrderHistoryScreen (OrdersTab)
**Route:** `/orders`

```
┌─────────────────────────┐
│ Đơn hàng của tôi        │
│ [Tất cả][Đang giao][✅] │
│                         │
│ ┌─────────────────────┐ │
│ │ Phở Hà Nội   ✅GiaoRồi│
│ │ 02/04/2026          │ │
│ │ 2 món • 145.500đ    │ │
│ │ [Đặt lại] [Đánh giá]│ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │ Pizza VN    🔄GiaoHàng│
│ │ 02/04/2026          │ │
│ │ 1 món • 89.000đ     │ │
│ │ [Theo dõi]          │ │
│ └─────────────────────┘ │
└─────────────────────────┘
```

---

### 13. OrderDetailScreen
**Route:** `/orders/:orderId`

Chi tiết đầy đủ của đơn hàng: danh sách món, địa chỉ giao, trạng thái, thanh toán, lịch sử trạng thái.

---

### 14. ProfileScreen (ProfileTab)
**Route:** `/profile`

```
┌─────────────────────────┐
│ Hồ sơ                   │
│                         │
│  [avatar]  Nguyen Van A │
│            vana@email   │
│            [Chỉnh sửa]  │
│                         │
│ ─── Tài khoản ───       │
│ 📍 Địa chỉ của tôi   →  │
│ 💳 Phương thức TT    →  │
│ 🔔 Thông báo         →  │
│                         │
│ ─── Hỗ trợ ───          │
│ ❓ Trợ giúp & FAQ    →  │
│ 📄 Điều khoản SD     →  │
│ 🔒 Chính sách BM     →  │
│ ⭐ Đánh giá ứng dụng →  │
│                         │
│ [      ĐĂNG XUẤT    ]   │
└─────────────────────────┘
```

---

### 15. Admin Screens *(RESTAURANT_ADMIN)*

#### AdminDashboardScreen `/admin`
```
┌─────────────────────────┐
│ Dashboard               │
│ Phở Hà Nội        [⚙️]  │
│                         │
│ Hôm nay                 │
│ ┌────────┐ ┌──────────┐ │
│ │ 23     │ │ 1.8tr đ  │ │
│ │ Đơn    │ │ Doanh thu│ │
│ └────────┘ └──────────┘ │
│                         │
│ Đơn hàng mới (5)        │
│ ┌─────────────────────┐ │
│ │ #100 • 3 món • 145k │ │
│ │ [Xác nhận][Từ chối] │ │
│ └─────────────────────┘ │
└─────────────────────────┘
```

#### ManageMenuScreen `/admin/menu`
- Danh sách categories và items
- Toggle is_available
- CRUD danh mục và món ăn

#### ManageOrdersScreen `/admin/orders`
- List đơn theo status
- Cập nhật trạng thái đơn

---

## Screen List & Routes Summary

| # | Screen | Route | Auth | Role |
|---|--------|-------|------|------|
| 1 | SplashScreen | `/` | No | Any |
| 2 | OnboardingScreen | `/onboarding` | No | Any |
| 3 | LoginScreen | `/login` | No | Any |
| 4 | RegisterScreen | `/register` | No | Any |
| 5 | ForgotPasswordScreen | `/forgot-password` | No | Any |
| 6 | HomeScreen | `/home` | Yes | CUSTOMER |
| 7 | RestaurantListScreen | `/restaurants` | No | Any |
| 8 | RestaurantDetailScreen | `/restaurants/:id` | No | Any |
| 9 | ItemDetailScreen | `/restaurants/:rId/items/:id` | Yes | CUSTOMER |
| 10 | CartScreen | `/cart` | Yes | CUSTOMER |
| 11 | CheckoutScreen | `/checkout` | Yes | CUSTOMER |
| 12 | OrderTrackingScreen | `/orders/:id/tracking` | Yes | CUSTOMER |
| 13 | OrderHistoryScreen | `/orders` | Yes | CUSTOMER |
| 14 | OrderDetailScreen | `/orders/:id` | Yes | CUSTOMER |
| 15 | ProfileScreen | `/profile` | Yes | CUSTOMER |
| 16 | EditProfileScreen | `/profile/edit` | Yes | CUSTOMER |
| 17 | SavedAddressesScreen | `/profile/addresses` | Yes | CUSTOMER |
| 18 | AddAddressScreen | `/profile/addresses/new` | Yes | CUSTOMER |
| 19 | NotificationsScreen | `/notifications` | Yes | CUSTOMER |
| 20 | AdminDashboardScreen | `/admin` | Yes | RESTAURANT_ADMIN |
| 21 | ManageMenuScreen | `/admin/menu` | Yes | RESTAURANT_ADMIN |
| 22 | AddEditItemScreen | `/admin/menu/items/:id?` | Yes | RESTAURANT_ADMIN |
| 23 | ManageOrdersScreen | `/admin/orders` | Yes | RESTAURANT_ADMIN |

---

## Flutter Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter_bloc: ^8.1.3          # State management
  go_router: ^13.0.0            # Navigation
  dio: ^5.4.0                   # HTTP client
  stomp_dart_client: ^1.0.0     # WebSocket STOMP
  flutter_secure_storage: ^9.0  # JWT storage
  shared_preferences: ^2.2.2    # Local settings
  cached_network_image: ^3.3.0  # Image caching
  google_maps_flutter: ^2.5.0   # Map view
  firebase_messaging: ^14.7.6   # Push notifications
  get_it: ^7.6.4                # Dependency injection
  equatable: ^2.0.5             # Value equality
  json_annotation: ^4.8.1       # JSON serialization
  intl: ^0.19.0                 # Số tiền, ngày tháng
  shimmer: ^3.0.0               # Loading skeleton

dev_dependencies:
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.5
  mocktail: ^1.0.2
```
