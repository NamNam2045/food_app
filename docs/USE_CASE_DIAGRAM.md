# Hình 1. Biểu đồ Use Case tổng quát — FoodRush

> **Hệ thống:** FoodRush (Ứng dụng đặt đồ ăn online)
> **Phạm vi:** Toàn bộ hệ thống — 4 actor chính
> **Format chính:** PlantUML (paste vào https://www.plantuml.com/plantuml/ hoặc dùng plugin IntelliJ / VS Code "PlantUML")

---

## 1. PlantUML — Use Case Diagram (Bản chính thức)

```plantuml
@startuml UseCaseTongQuat
title Hình 1. Biểu đồ Use Case tổng quát — Hệ thống FoodRush

left to right direction

skinparam packageStyle rectangle
skinparam actorStyle awesome
skinparam usecase {
  BackgroundColor #FFF6E5
  BorderColor #E85B2E
  ArrowColor #555555
}
skinparam actor {
  BackgroundColor #EAF4FF
  BorderColor #2E5BE8
}

' ==================== ACTORS ====================
actor "Customer\n(Khách hàng)"        as Customer
actor "Restaurant Admin\n(Chủ nhà hàng)" as Owner
actor "Delivery Agent\n(Shipper)"      as Shipper
actor "System Admin\n(Quản trị viên)"  as Admin

' ==================== HỆ THỐNG ====================
rectangle "FoodRush System" {

  ' ----------- CUSTOMER USE CASES -----------
  package "Tài khoản & Truy cập" as PKG_C_AUTH {
    usecase "Đăng ký"      as UC_C01
    usecase "Đăng nhập"    as UC_C02
  }

  package "Duyệt & Tìm kiếm" as PKG_C_BROWSE {
    usecase "Duyệt nhà hàng" as UC_C03
    usecase "Tìm kiếm"       as UC_C04
    usecase "Xem menu"       as UC_C05
  }

  package "Mua hàng" as PKG_C_ORDER {
    usecase "Thêm vào giỏ"   as UC_C06
    usecase "Đặt hàng"       as UC_C07
    usecase "Thanh toán"     as UC_C08
    usecase "Theo dõi đơn"   as UC_C09
    usecase "Đánh giá"       as UC_C10
  }

  ' ----------- RESTAURANT ADMIN USE CASES -----------
  package "Quản lý nhà hàng" as PKG_R {
    usecase "Quản lý hồ sơ NH"          as UC_R01
    usecase "Quản lý menu"              as UC_R02
    usecase "Nhận đơn"                  as UC_R03
    usecase "Cập nhật trạng thái đơn"   as UC_R04
    usecase "Xem báo cáo"               as UC_R05
  }

  ' ----------- DELIVERY AGENT USE CASES -----------
  package "Giao hàng" as PKG_D {
    usecase "Nhận đơn được phân công"   as UC_D01
    usecase "Cập nhật trạng thái giao"  as UC_D02
    usecase "Xem lịch sử giao"          as UC_D03
  }

  ' ----------- SYSTEM ADMIN USE CASES -----------
  package "Quản trị hệ thống" as PKG_A {
    usecase "Quản lý user"        as UC_A01
    usecase "Phê duyệt NH"        as UC_A02
    usecase "Thống kê hệ thống"   as UC_A03
  }
}

' ==================== ACTOR ↔ USE CASE ====================

' Customer
Customer --> UC_C01
Customer --> UC_C02
Customer --> UC_C03
Customer --> UC_C04
Customer --> UC_C05
Customer --> UC_C06
Customer --> UC_C07
Customer --> UC_C08
Customer --> UC_C09
Customer --> UC_C10

' Restaurant Admin
Owner --> UC_R01
Owner --> UC_R02
Owner --> UC_R03
Owner --> UC_R04
Owner --> UC_R05

' Delivery Agent
Shipper --> UC_D01
Shipper --> UC_D02
Shipper --> UC_D03

' System Admin
Admin --> UC_A01
Admin --> UC_A02
Admin --> UC_A03

' ==================== INCLUDE / EXTEND ====================

' Customer flow
UC_C07 ..> UC_C02 : <<include>>
UC_C07 ..> UC_C06 : <<include>>
UC_C07 ..> UC_C08 : <<include>>
UC_C09 ..> UC_C07 : <<extend>>
UC_C10 ..> UC_C07 : <<extend>>\n(after DELIVERED)
UC_C06 ..> UC_C05 : <<extend>>

' Restaurant flow
UC_R03 ..> UC_R04 : <<extend>>

' Delivery flow
UC_D02 ..> UC_D01 : <<include>>

' Admin
UC_A02 ..> UC_A01 : <<extend>>

@enduml
```

---

## 2. ASCII Diagram (Xem nhanh)

```
                              ┌──────────────────────────────────────────────────────┐
                              │                  FoodRush System                       │
                              │                                                        │
                              │  ╔═══ Tài khoản & Truy cập ═══════════════════╗        │
                              │  ║ (Đăng ký)        (Đăng nhập)               ║        │
                              │  ╚════════════════════════════════════════════╝        │
                              │                                                        │
                              │  ╔═══ Duyệt & Tìm kiếm ═══════════════════════╗        │
                              │  ║ (Duyệt nhà hàng) (Tìm kiếm) (Xem menu)     ║        │
                              │  ╚════════════════════════════════════════════╝        │
                              │                                                        │
       ┌─────────────┐        │  ╔═══ Mua hàng ═══════════════════════════════╗        │
       │   Customer  │────────▶  ║ (Thêm vào giỏ) ──include──▶ (Đặt hàng) ────║        │
       │ (Khách hàng)│        │  ║                                  │         ║        │
       └─────────────┘        │  ║                  include ─────── │         ║        │
                              │  ║                       ▼                    ║        │
                              │  ║                  (Thanh toán)              ║        │
                              │  ║                                            ║        │
                              │  ║  (Theo dõi đơn) extend (Đặt hàng)          ║        │
                              │  ║  (Đánh giá) extend after DELIVERED         ║        │
                              │  ╚════════════════════════════════════════════╝        │
                              │                                                        │
       ┌──────────────────┐   │  ╔═══ Quản lý nhà hàng ═══════════════════════╗        │
       │ Restaurant Admin │───▶  ║ (Quản lý hồ sơ NH)  (Quản lý menu)         ║        │
       │  (Chủ nhà hàng)  │   │  ║ (Nhận đơn) ───extend──▶ (Cập nhật trạng    ║        │
       └──────────────────┘   │  ║                          thái đơn)         ║        │
                              │  ║ (Xem báo cáo)                              ║        │
                              │  ╚════════════════════════════════════════════╝        │
                              │                                                        │
       ┌─────────────────┐    │  ╔═══ Giao hàng ══════════════════════════════╗        │
       │ Delivery Agent  │────▶  ║ (Nhận đơn được phân công) ──include──▶    ║        │
       │    (Shipper)    │    │  ║ (Cập nhật trạng thái giao)                 ║        │
       └─────────────────┘    │  ║ (Xem lịch sử giao)                         ║        │
                              │  ╚════════════════════════════════════════════╝        │
                              │                                                        │
       ┌─────────────────┐    │  ╔═══ Quản trị hệ thống ══════════════════════╗        │
       │  System Admin   │────▶  ║ (Quản lý user) ◀──extend── (Phê duyệt NH)  ║        │
       │  (Quản trị viên)│    │  ║ (Thống kê hệ thống)                        ║        │
       └─────────────────┘    │  ╚════════════════════════════════════════════╝        │
                              │                                                        │
                              └──────────────────────────────────────────────────────┘
```

---

## 3. Bảng tổng hợp Actor & Use Case

| Actor | Mã | Use Case | Mô tả nghiệp vụ |
|---|---|---|---|
| **Customer** | UC-C01 | Đăng ký | Tạo tài khoản mới, gửi email verification |
| | UC-C02 | Đăng nhập | Xác thực bằng email + password → JWT |
| | UC-C03 | Duyệt nhà hàng | Liệt kê + filter (city, cuisine, open, geo) |
| | UC-C04 | Tìm kiếm | Search NH theo tên/từ khoá |
| | UC-C05 | Xem menu | Hiển thị danh mục + món + giá |
| | UC-C06 | Thêm vào giỏ | Add món (1 user — 1 cart — 1 NH) |
| | UC-C07 | Đặt hàng | Tạo Order từ cart, sinh `FR-yyyyMMdd-00001` |
| | UC-C08 | Thanh toán | Chọn COD/MoMo/ZaloPay/Credit Card |
| | UC-C09 | Theo dõi đơn | Real-time STOMP `/user/queue/orders/{id}/status` |
| | UC-C10 | Đánh giá | 1 review/order, sau khi DELIVERED |
| **Restaurant Admin** | UC-R01 | Quản lý hồ sơ NH | Update thông tin NH + operating hours |
| | UC-R02 | Quản lý menu | CRUD category + menu item |
| | UC-R03 | Nhận đơn | Xem order PENDING của NH |
| | UC-R04 | Cập nhật trạng thái đơn | PENDING→CONFIRMED→PREPARING→READY_FOR_PICKUP |
| | UC-R05 | Xem báo cáo | Dashboard doanh thu, số đơn |
| **Delivery Agent** | UC-D01 | Nhận đơn được phân công | Accept đơn READY_FOR_PICKUP, gán shipper |
| | UC-D02 | Cập nhật trạng thái giao | PICKED_UP → ON_THE_WAY → DELIVERED |
| | UC-D03 | Xem lịch sử giao | Danh sách đơn đã hoàn thành |
| **System Admin** | UC-A01 | Quản lý user | Active/deactive tài khoản, role |
| | UC-A02 | Phê duyệt NH | Approve NH mới đăng ký |
| | UC-A03 | Thống kê hệ thống | Báo cáo tổng quan toàn nền tảng |

---

## 4. Quan hệ Include / Extend

| Quan hệ | Use case | Giải thích |
|---|---|---|
| `Đặt hàng` ─include→ `Đăng nhập` | Bắt buộc đã đăng nhập mới đặt được |
| `Đặt hàng` ─include→ `Thêm vào giỏ` | Đơn được build từ giỏ |
| `Đặt hàng` ─include→ `Thanh toán` | Mỗi đơn phải tạo record Payment |
| `Theo dõi đơn` ─extend→ `Đặt hàng` | Sau khi có đơn mới track được |
| `Đánh giá` ─extend→ `Đặt hàng` | Chỉ active sau khi đơn `DELIVERED` |
| `Thêm vào giỏ` ─extend→ `Xem menu` | Có thể add từ ItemDetail trong menu |
| `Cập nhật trạng thái đơn` ─extend→ `Nhận đơn` | Owner sau khi nhận đơn sẽ chuyển trạng thái |
| `Cập nhật trạng thái giao` ─include→ `Nhận đơn được phân công` | Shipper phải nhận đơn trước khi update |
| `Phê duyệt NH` ─extend→ `Quản lý user` | Phê duyệt cũng là một tác vụ quản lý user role |

---

## 5. Mermaid (Alternative — Github render trực tiếp)

> Mermaid chưa hỗ trợ use case diagram chính thức, dùng `flowchart` mô phỏng. Khuyến nghị dùng PlantUML ở mục 1 cho chuẩn UML.

```mermaid
flowchart LR
    %% Actors
    C(["👤 Customer"])
    R(["🏪 Restaurant Admin"])
    D(["🛵 Delivery Agent"])
    A(["⚙️ System Admin"])

    subgraph SYS["FoodRush System"]
        direction TB

        subgraph CUS["Customer Use Cases"]
            UC1((Đăng ký))
            UC2((Đăng nhập))
            UC3((Duyệt nhà hàng))
            UC4((Tìm kiếm))
            UC5((Xem menu))
            UC6((Thêm vào giỏ))
            UC7((Đặt hàng))
            UC8((Thanh toán))
            UC9((Theo dõi đơn))
            UC10((Đánh giá))
        end

        subgraph ROW["Restaurant Admin Use Cases"]
            UR1((Quản lý hồ sơ NH))
            UR2((Quản lý menu))
            UR3((Nhận đơn))
            UR4((Cập nhật trạng thái đơn))
            UR5((Xem báo cáo))
        end

        subgraph DEL["Delivery Agent Use Cases"]
            UD1((Nhận đơn được phân công))
            UD2((Cập nhật trạng thái giao))
            UD3((Xem lịch sử giao))
        end

        subgraph ADM["System Admin Use Cases"]
            UA1((Quản lý user))
            UA2((Phê duyệt NH))
            UA3((Thống kê hệ thống))
        end
    end

    C --- UC1
    C --- UC2
    C --- UC3
    C --- UC4
    C --- UC5
    C --- UC6
    C --- UC7
    C --- UC8
    C --- UC9
    C --- UC10

    R --- UR1
    R --- UR2
    R --- UR3
    R --- UR4
    R --- UR5

    D --- UD1
    D --- UD2
    D --- UD3

    A --- UA1
    A --- UA2
    A --- UA3

    %% Include/Extend (dashed)
    UC7 -.->|include| UC2
    UC7 -.->|include| UC6
    UC7 -.->|include| UC8
    UC9 -.->|extend| UC7
    UC10 -.->|extend after DELIVERED| UC7
    UR3 -.->|extend| UR4
    UD2 -.->|include| UD1
```

---

## Cách render

| Tool | Cách dùng |
|---|---|
| **PlantUML online** | Copy block code `@startuml ... @enduml` ở mục 1 → paste vào https://www.plantuml.com/plantuml/uml/ → Submit |
| **VS Code** | Cài extension "PlantUML" (jebbs.plantuml) → mở file `.md` này → Alt+D xem preview |
| **IntelliJ IDEA** | Cài plugin "PlantUML integration" → trỏ chuột vào code block → click 👁 |
| **Mermaid** | GitHub render trực tiếp khi push lên repo, hoặc dùng https://mermaid.live |
| **CLI** | `plantuml USE_CASE_DIAGRAM.md` (xuất PNG/SVG) |
