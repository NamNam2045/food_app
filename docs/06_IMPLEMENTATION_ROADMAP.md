# FoodRush — Lộ trình Triển khai

**Tổng thời gian ước tính:** 16 tuần (4 Sprint × 4 tuần)  
**Team:** 2 BE dev + 2 Flutter dev + 1 BA/QA

---

## Sprint 1 (Tuần 1–4): Foundation

### Backend
- [ ] Setup Spring Boot project (pom.xml, configs)
- [ ] Docker Compose (PostgreSQL, Redis)
- [ ] Flyway migrations V1–V3 (users, restaurants, menu)
- [ ] Auth module (register, login, JWT, refresh token)
- [ ] User module (profile, addresses CRUD)
- [ ] Restaurant module (CRUD, list với filter)
- [ ] Menu module (categories, items CRUD)
- [ ] Swagger/OpenAPI docs

### Flutter
- [ ] Setup Flutter project (BLoC, GoRouter, Dio)
- [ ] Core layer (ApiClient, interceptors, storage)
- [ ] Theme (colors, typography, spacing)
- [ ] Shared widgets (Button, TextField, AppBar, Loading)
- [ ] Auth feature (Splash → Onboarding → Login → Register)
- [ ] Home screen layout
- [ ] Restaurant list + detail screens

**Milestone:** Người dùng có thể đăng ký, đăng nhập, xem danh sách nhà hàng và menu.

---

## Sprint 2 (Tuần 5–8): Core Ordering Flow

### Backend
- [ ] Flyway migrations V4–V6 (cart, orders, payments)
- [ ] Cart module (get, add, update, delete)
- [ ] Order module (place, get, cancel, status update)
- [ ] Payment module (COD + tích hợp placeholder payment gateway)
- [ ] WebSocket setup (STOMP, order status push)
- [ ] Order number generation
- [ ] Business rule validation (min order, restaurant conflict)

### Flutter
- [ ] Cart feature (CartScreen, CartBloc)
- [ ] Checkout screen (address selection, payment method)
- [ ] Order placement flow
- [ ] Order tracking screen (WebSocket STOMP client)
- [ ] Order history screen
- [ ] Order detail screen
- [ ] Status stepper widget

**Milestone:** Người dùng có thể đặt hàng và theo dõi trạng thái theo thời gian thực.

---

## Sprint 3 (Tuần 9–12): Admin & Notifications

### Backend
- [ ] Flyway migration V7–V8 (reviews, refresh_tokens)
- [ ] Review module
- [ ] Restaurant admin endpoints (manage menu, manage orders)
- [ ] Firebase FCM integration
- [ ] Push notification service
- [ ] Rating recalculation khi có review mới
- [ ] Rate limiting (Spring Security / Redis)

### Flutter
- [ ] Profile screen (edit, addresses, payment methods)
- [ ] Review & rating screen
- [ ] Admin panel screens (dashboard, manage menu, manage orders)
- [ ] Firebase push notification handler
- [ ] Notifications screen
- [ ] Search screen với debounce

**Milestone:** Admin nhà hàng có thể quản lý menu và xử lý đơn hàng. User nhận push notification.

---

## Sprint 4 (Tuần 13–16): Polish & Launch

### Backend
- [ ] Caching (Redis @Cacheable cho restaurant list, menu)
- [ ] Performance optimization (N+1 query fixes, indexes)
- [ ] Security audit (OWASP checklist)
- [ ] Logging & monitoring setup
- [ ] Production configs (application-prod.yml)
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Load testing

### Flutter
- [ ] Error handling & retry logic
- [ ] Offline state handling
- [ ] Performance: image lazy loading, list virtualization
- [ ] Analytics integration
- [ ] App Store / Play Store metadata
- [ ] Beta testing (TestFlight / Firebase App Distribution)

**Milestone:** App sẵn sàng release lên App Store và Google Play.

---

## Acceptance Criteria Chính

### Đặt hàng
- [ ] Thêm món vào giỏ hàng < 2 giây
- [ ] Đặt đơn thành công → redirect tracking screen < 3 giây
- [ ] Xung đột nhà hàng trong giỏ → hiển thị dialog xác nhận

### Theo dõi đơn hàng
- [ ] Cập nhật trạng thái real-time qua WebSocket < 1 giây
- [ ] Hiển thị đúng 8 trạng thái đơn hàng
- [ ] Nhận push notification khi trạng thái thay đổi

### Authentication
- [ ] Access token hết hạn → tự động refresh
- [ ] Refresh token hết hạn → redirect login screen
- [ ] JWT invalidation khi logout

### Performance
- [ ] Danh sách nhà hàng load < 1 giây (cached)
- [ ] API response time < 500ms (p95)
- [ ] App size < 30MB

---

## Rủi ro & Giảm thiểu

| Rủi ro | Xác suất | Tác động | Giảm thiểu |
|--------|----------|----------|-----------|
| Tích hợp payment gateway phức tạp | Trung bình | Cao | Dùng Stripe/Braintree sandbox trước; COD làm fallback |
| WebSocket kết nối bất ổn | Trung bình | Trung bình | Implement reconnection logic + polling fallback |
| Google Maps API chi phí | Thấp | Trung bình | Cache geocoding results; dùng OpenStreetMap cho dev |
| Push notification iOS certificate | Thấp | Cao | Setup APNs certificate sớm trong Sprint 3 |

---

## Checklist Bảo mật (OWASP Mobile Top 10)

- [ ] Không lưu JWT trong plaintext (dùng flutter_secure_storage)
- [ ] Certificate pinning cho production API calls
- [ ] Input validation cả FE và BE
- [ ] SQL injection prevention (JPA parameterized queries)
- [ ] Rate limiting trên auth endpoints (5 req/min)
- [ ] Sensitive data không log ra console
- [ ] HTTPS enforced (reject HTTP)
- [ ] Password hashing bcrypt cost factor ≥ 12
- [ ] Refresh token rotation khi dùng
- [ ] CORS chỉ cho phép origin được whitelist
