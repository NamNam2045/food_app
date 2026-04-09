# FoodRush — Ứng dụng Đặt Đồ Ăn

**Stack:** Flutter + Java Spring Boot + PostgreSQL  
**Tài liệu BA:** `/docs/`

---

## Tài liệu Thiết kế

| File | Nội dung |
|------|---------|
| [01_PROJECT_OVERVIEW.md](docs/01_PROJECT_OVERVIEW.md) | Tổng quan dự án, kiến trúc hệ thống, cấu trúc thư mục |
| [02_DATABASE_SCHEMA.md](docs/02_DATABASE_SCHEMA.md) | ERD — 14 bảng với đầy đủ columns, types, constraints |
| [03_API_SPECIFICATION.md](docs/03_API_SPECIFICATION.md) | Đặc tả REST API — tất cả endpoints, request/response |
| [04_FLUTTER_SCREENS.md](docs/04_FLUTTER_SCREENS.md) | Màn hình Flutter — wireframes, navigation flow, dependencies |
| [05_SPRING_BOOT_DESIGN.md](docs/05_SPRING_BOOT_DESIGN.md) | Backend design — entities, controllers, services, security |
| [06_IMPLEMENTATION_ROADMAP.md](docs/06_IMPLEMENTATION_ROADMAP.md) | Lộ trình 4 sprint, acceptance criteria, risk matrix |

---

## Tóm tắt Nhanh

### Tính năng MVP
- Đăng ký / Đăng nhập (JWT + Refresh Token)
- Duyệt nhà hàng & thực đơn
- Giỏ hàng & đặt hàng
- Theo dõi đơn real-time (WebSocket STOMP)
- Lịch sử đơn hàng
- Quản lý nhà hàng (Admin panel)

### Chạy local

```bash
# Backend
cd foodrush-backend
docker-compose up -d   # PostgreSQL + Redis
mvn spring-boot:run

# Flutter
cd foodrush_flutter
flutter pub get
flutter run
```

### API Docs
Truy cập: `http://localhost:8080/swagger-ui.html`
"# food-app" 
