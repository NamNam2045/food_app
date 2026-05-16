# BÁO CÁO ĐỒ ÁN

## ĐỀ TÀI: XÂY DỰNG ỨNG DỤNG ĐẶT ĐỒ ĂN ONLINE

**Tên dự án:** FoodRush — Ứng dụng đặt đồ ăn online đa nền tảng
**Công nghệ:** Flutter (Dart) + Spring Boot (Java) + PostgreSQL + Redis + WebSocket (STOMP) + Firebase FCM
**Phiên bản:** 1.0
**Năm:** 2026

---

## MỤC LỤC

- [DANH MỤC HÌNH VÀ BẢNG](#danh-mục-hình-và-bảng)
- [MỞ ĐẦU](#mở-đầu)
  - [1. Giới thiệu môn học](#1-giới-thiệu-môn-học)
  - [2. Giới thiệu đề tài](#2-giới-thiệu-đề-tài)
  - [3. Thành viên & phân công](#3-thành-viên--phân-công)
- [CHƯƠNG 1. CƠ SỞ LÝ THUYẾT](#chương-1-cơ-sở-lý-thuyết)
  - [1.1 Tổng quan Flutter](#11-tổng-quan-flutter)
  - [1.2 Ngôn ngữ Dart](#12-ngôn-ngữ-dart)
  - [1.3 Spring Boot và hệ sinh thái Java](#13-spring-boot-và-hệ-sinh-thái-java)
  - [1.4 PostgreSQL](#14-postgresql)
  - [1.5 Kiến trúc Flutter](#15-kiến-trúc-flutter)
  - [1.6 State Management (BLoC)](#16-state-management-bloc)
  - [1.7 Giao tiếp Client–Server: REST API & WebSocket (STOMP)](#17-giao-tiếp-clientserver-rest-api--websocket-stomp)
  - [1.8 Xác thực và bảo mật: JWT, Spring Security, Refresh Token](#18-xác-thực-và-bảo-mật-jwt-spring-security-refresh-token)
  - [1.9 Caching với Redis](#19-caching-với-redis)
  - [1.10 Push Notification với Firebase FCM](#110-push-notification-với-firebase-fcm)
  - [1.11 Các công nghệ và thư viện sử dụng](#111-các-công-nghệ-và-thư-viện-sử-dụng)
- [CHƯƠNG 2. XÂY DỰNG ỨNG DỤNG](#chương-2-xây-dựng-ứng-dụng)
  - [2.1 Mô tả chức năng](#21-mô-tả-chức-năng)
  - [2.2 Phân tích hệ thống](#22-phân-tích-hệ-thống)
  - [2.3 Thiết kế hệ thống](#23-thiết-kế-hệ-thống)
- [CHƯƠNG 3. THỰC NGHIỆM](#chương-3-thực-nghiệm)
  - [3.1 Kiến trúc triển khai](#31-kiến-trúc-triển-khai)
  - [3.2 Môi trường](#32-môi-trường)
  - [3.3 Triển khai ứng dụng](#33-triển-khai-ứng-dụng)
- [KẾT LUẬN](#kết-luận)
- [PHỤ LỤC](#phụ-lục)

---

## DANH MỤC HÌNH VÀ BẢNG

### Hình
- Hình 1. Kiến trúc tổng thể hệ thống FoodRush
- Hình 2. Biểu đồ Use Case tổng quát
- Hình 3. Use Case Khách hàng (Customer)
- Hình 4. Use Case Chủ nhà hàng (Restaurant Admin)
- Hình 5. Use Case Shipper (Delivery Agent)
- Hình 6. Sơ đồ luồng đặt hàng (Order Flow)
- Hình 7. Sơ đồ tuần tự thanh toán
- Hình 8. ERD cơ sở dữ liệu
- Hình 9. Sơ đồ luồng xác thực JWT
- Hình 10. Sơ đồ luồng cập nhật trạng thái đơn qua WebSocket
- Hình 11. Mô hình triển khai Docker
- Hình 12. Màn hình đăng nhập / đăng ký
- Hình 13. Màn hình trang chủ và tìm kiếm nhà hàng
- Hình 14. Màn hình chi tiết nhà hàng và thực đơn
- Hình 15. Màn hình giỏ hàng và thanh toán
- Hình 16. Màn hình theo dõi đơn hàng real-time
- Hình 17. Màn hình lịch sử đơn hàng
- Hình 18. Màn hình quản trị nhà hàng

### Bảng
- Bảng 1. Vai trò các bên liên quan (Stakeholders)
- Bảng 2. Tech Stack và lý do lựa chọn
- Bảng 3. So sánh state management Flutter
- Bảng 4. So sánh PostgreSQL với các RDBMS khác
- Bảng 5. Danh sách API endpoint chính
- Bảng 6. Mô tả Use Case tổng quát
- Bảng 7. Mô tả use case Customer
- Bảng 8. Mô tả use case Restaurant Admin
- Bảng 9. Mô tả use case Delivery Agent
- Bảng 10. Mô tả bảng `users`
- Bảng 11. Mô tả bảng `restaurants`
- Bảng 12. Mô tả bảng `menu_items`
- Bảng 13. Mô tả bảng `orders`
- Bảng 14. Mô tả bảng `payments`
- Bảng 15. Mô tả bảng `reviews`
- Bảng 16. Môi trường phát triển & triển khai

---

## MỞ ĐẦU

### 1. Giới thiệu môn học

Trong bối cảnh công nghệ thông tin phát triển mạnh mẽ, nhu cầu xây dựng các ứng dụng có thể hoạt động trên nhiều nền tảng khác nhau ngày càng trở nên phổ biến. Môn học **Chuyên đề 2 – Phát triển ứng dụng đa nền tảng** được xây dựng nhằm giúp sinh viên tiếp cận và làm chủ các công nghệ hiện đại phục vụ cho việc phát triển ứng dụng trên cả thiết bị di động và nền tảng web. Thay vì phải xây dựng nhiều phiên bản riêng biệt cho từng hệ điều hành, xu hướng hiện nay là sử dụng các framework đa nền tảng để tối ưu hóa quá trình phát triển.

Trong môn học này, **Flutter** được lựa chọn làm công nghệ cốt lõi cho phía client, kết hợp với ngôn ngữ lập trình **Dart** để xây dựng giao diện và xử lý logic cho ứng dụng. Phía server, sinh viên được làm quen với **Spring Boot (Java)** – một trong những framework backend mạnh mẽ và phổ biến nhất trong môi trường doanh nghiệp hiện nay – nhằm xây dựng REST API, xử lý xác thực, lưu trữ dữ liệu và đồng bộ real-time.

Mục tiêu chính của môn học là giúp sinh viên hiểu rõ cách thức hoạt động của một hệ thống client–server đầy đủ, từ giao diện người dùng, logic nghiệp vụ, đến cơ sở dữ liệu và bảo mật. Thông qua quá trình thực hiện đề tài, sinh viên không chỉ nắm vững kiến thức lý thuyết mà còn phát triển kỹ năng thực hành: thiết kế kiến trúc, lập trình đa nền tảng, kết nối API, quản lý trạng thái, xử lý thời gian thực và triển khai sản phẩm thực tế.

### 2. Giới thiệu đề tài

Trong phạm vi môn học, nhóm lựa chọn thực hiện đề tài **"Xây dựng ứng dụng đặt đồ ăn online"** với tên gọi **FoodRush**. Đây là một ứng dụng giúp khách hàng có thể duyệt danh sách nhà hàng, đặt món ăn, thanh toán online và theo dõi trạng thái đơn hàng theo thời gian thực. Cùng với đó là các vai trò khác trong hệ sinh thái như chủ nhà hàng, shipper và quản trị hệ thống.

Bài toán đặt đồ ăn online là một bài toán có tính thực tế cao, mô phỏng được nhiều khía cạnh của một hệ thống thương mại điện tử hiện đại: xác thực người dùng nhiều vai trò, quản lý sản phẩm và giá, giỏ hàng, đặt hàng, thanh toán, theo dõi giao hàng và đánh giá. Đề tài này phù hợp để áp dụng đồng thời nhiều công nghệ cốt lõi trong phát triển phần mềm hiện đại.

Mục tiêu của đề tài là xây dựng một hệ thống gồm:

- **Ứng dụng di động đa nền tảng** (Flutter) chạy trên Android và iOS, có giao diện thân thiện, hỗ trợ xác thực JWT, đặt đơn, thanh toán và theo dõi đơn real-time qua WebSocket.
- **Backend Spring Boot** cung cấp REST API và WebSocket STOMP, có lớp bảo mật (Spring Security + JWT), tài liệu API tự sinh (Swagger/OpenAPI 3) và cơ chế cache (Redis).
- **Cơ sở dữ liệu PostgreSQL** với migration được quản lý bằng Flyway, đảm bảo tính nhất quán dữ liệu (ACID).
- **Thông báo đẩy** qua Firebase Cloud Messaging.
- **Đóng gói triển khai** bằng Docker / Docker Compose.

Về phạm vi triển khai, hệ thống bao quát ba nhóm người dùng cuối là **khách hàng (CUSTOMER)**, **quản lý nhà hàng (RESTAURANT_ADMIN)** và **shipper (DELIVERY_AGENT)**, bên cạnh vai trò **quản trị hệ thống (SYSTEM_ADMIN)**. Ứng dụng đi sâu vào nghiệp vụ MVP (đặt hàng – thanh toán – theo dõi) và mở rộng dần các tính năng như đánh giá, mã giảm giá, chat và bản đồ shipper.

Thông qua đề tài này, nhóm hướng đến việc áp dụng các kiến thức về Flutter, Dart, Java, Spring Boot và cơ sở dữ liệu quan hệ vào một sản phẩm gần với thực tế, đồng thời rèn luyện kỹ năng phân tích – thiết kế – triển khai và làm việc nhóm theo quy trình phần mềm hiện đại.

### 3. Thành viên & phân công

| STT | Tên | Vai trò | Công việc |
|-----|-----|---------|-----------|
| 1 | ... | Leader | Thiết kế kiến trúc hệ thống, quản lý tiến độ |
| 2 | ... | Mobile Dev | Phát triển Flutter UI, BLoC state, tích hợp API |
| 3 | ... | Backend Dev | Spring Boot REST API, Spring Security/JWT |
| 4 | ... | Backend Dev / DBA | Thiết kế DB PostgreSQL, Flyway, Redis cache |

---

## CHƯƠNG 1. CƠ SỞ LÝ THUYẾT

### 1.1 Tổng quan Flutter

Flutter là một framework mã nguồn mở được phát triển bởi **Google**, cho phép xây dựng ứng dụng đa nền tảng (Android, iOS, Web, Desktop) từ một codebase duy nhất. Thay vì phải phát triển riêng biệt cho từng hệ điều hành, Flutter cung cấp một giải pháp thống nhất giúp lập trình viên tạo ra các ứng dụng có giao diện đẹp, hiệu năng cao và hoạt động ổn định trên nhiều nền tảng khác nhau.

Khác với các framework cross-platform khác như React Native (sử dụng cầu nối JavaScript bridge tới thành phần native) hay Ionic (chạy trên WebView), Flutter render trực tiếp lên canvas bằng engine đồ hoạ riêng (Skia/Impeller). Điều này mang lại ba ưu điểm rõ rệt:

1. **Hiệu năng gần như native**: code Dart được biên dịch AOT (Ahead-Of-Time) sang mã máy cho từng nền tảng, không phải đi qua bridge khi runtime.
2. **Giao diện đồng nhất tuyệt đối**: vì Flutter tự vẽ giao diện thay vì gọi widget của hệ điều hành, UI hiển thị nhất quán giữa Android, iOS và Web.
3. **Hot Reload**: cập nhật giao diện và logic gần như tức thời mà không cần khởi động lại ứng dụng, rút ngắn đáng kể vòng lặp phát triển.

Trong dự án FoodRush, Flutter là lựa chọn lý tưởng vì các lý do sau:

- **Tốc độ phát triển**: chỉ cần một đội mobile để hỗ trợ cả iOS và Android, phù hợp với quy mô đồ án.
- **Trải nghiệm người dùng nhất quán**: các màn hình duyệt nhà hàng, giỏ hàng, checkout và theo dõi đơn yêu cầu UI phức tạp với nhiều animation – đây là thế mạnh của Flutter.
- **Hệ sinh thái plugin phong phú**: có sẵn các package cho HTTP, WebSocket, lưu trữ bảo mật, push notification, bản đồ, thanh toán… giúp nhóm tập trung vào nghiệp vụ thay vì viết lại nền tảng.
- **Khả năng mở rộng sang Web**: cùng codebase có thể triển khai bản web cho admin panel của nhà hàng.

Một số hạn chế cần lưu ý: kích thước file APK/IPA của ứng dụng Flutter thường lớn hơn native (do bundled engine); bản Flutter Web chưa thực sự tối ưu cho SEO; truy cập một số API rất đặc thù của hệ điều hành vẫn cần viết platform channel.

### 1.2 Ngôn ngữ Dart

Dart là ngôn ngữ lập trình do Google phát triển, được thiết kế đặc biệt để tối ưu cho việc xây dựng giao diện người dùng và xử lý các tác vụ bất đồng bộ. Cú pháp của Dart gần gũi với Java, C# và JavaScript, giúp lập trình viên dễ dàng tiếp cận. Một số đặc điểm chính:

- **Strong typing với type inference**: Dart là ngôn ngữ kiểu tĩnh nhưng cho phép suy luận kiểu (`var`, `final`), giúp cân bằng giữa an toàn kiểu và sự gọn gàng.
- **Null-safety**: từ Dart 2.12 trở đi, Dart hỗ trợ null-safety ở mức ngôn ngữ. Biến mặc định không thể null; muốn cho phép null phải khai báo `Type?`. Tính năng này giúp loại bỏ phần lớn lỗi NullPointerException tại compile-time – một trong những nguồn lỗi phổ biến nhất trong các ứng dụng mobile truyền thống.
- **Lập trình hướng đối tượng đầy đủ**: hỗ trợ class, abstract class, mixin, interface (qua `implements`), generic và extension methods.
- **Bất đồng bộ với `async`/`await`, `Future` và `Stream`**: `Future<T>` cho tác vụ trả về một giá trị trong tương lai (ví dụ: gọi API lấy danh sách nhà hàng), `Stream<T>` cho luồng dữ liệu liên tục (ví dụ: stream cập nhật trạng thái đơn hàng qua WebSocket).
- **Biên dịch linh hoạt**: JIT trong khi phát triển (phục vụ Hot Reload), AOT khi build release để tối ưu hiệu năng.

Trong FoodRush, Dart được sử dụng để:

- Định nghĩa các **model bất biến** (`Restaurant`, `MenuItem`, `Order`, `CartItem`) với hỗ trợ `copyWith` và `Equatable`.
- Viết các **BLoC/Cubit** quản lý trạng thái dựa trên `Stream`.
- Xử lý các **Future** trả về từ Dio khi gọi REST API và từ STOMP client khi nhận sự kiện cập nhật đơn hàng.

### 1.3 Spring Boot và hệ sinh thái Java

**Spring Boot** là phần mở rộng của Spring Framework, được tạo ra để đơn giản hoá việc xây dựng các ứng dụng Java doanh nghiệp. Spring Boot cung cấp ba ý tưởng chủ đạo:

1. **Auto-configuration**: tự động cấu hình các bean dựa trên các dependency có trong classpath, giảm đáng kể lượng cấu hình XML/Java boilerplate.
2. **Starter dependencies**: các module gói sẵn (`spring-boot-starter-web`, `spring-boot-starter-data-jpa`, `spring-boot-starter-security`…) giúp khai báo nhanh các nhóm chức năng.
3. **Embedded server**: tích hợp sẵn Tomcat/Jetty/Undertow để chạy ứng dụng dưới dạng `.jar` thực thi độc lập, rất phù hợp khi đóng gói container Docker.

Trong FoodRush, Spring Boot 3.x là tầng backend cốt lõi và đảm nhận:

- **REST API** cho toàn bộ nghiệp vụ (auth, restaurant, menu, cart, order, payment, review, notification) thông qua `@RestController`, `@RequestMapping`.
- **Lớp persistence** thông qua **Spring Data JPA** + **Hibernate**, ánh xạ entity sang bảng PostgreSQL, hỗ trợ truy vấn JPQL và Specification cho lọc động.
- **Bảo mật** với **Spring Security** + JWT filter, phân quyền theo `@PreAuthorize("hasRole('RESTAURANT_ADMIN')")`.
- **Real-time** thông qua module **Spring WebSocket + STOMP**, broadcast cập nhật trạng thái đơn cho khách hàng và nhà hàng.
- **Tài liệu API** tự sinh bằng **springdoc-openapi** (Swagger UI), giúp frontend tra cứu nhanh.
- **Migration cơ sở dữ liệu** với **Flyway**: các script SQL được đánh phiên bản (`V1__init.sql`, `V2__add_indexes.sql`…) chạy tự động khi ứng dụng khởi động.

Spring Boot được lựa chọn do hệ sinh thái Java cực kỳ trưởng thành, tài liệu phong phú, dễ tích hợp với PostgreSQL, Redis, Firebase và đa số các dịch vụ cloud.

### 1.4 PostgreSQL

PostgreSQL là một hệ quản trị cơ sở dữ liệu quan hệ (RDBMS) mã nguồn mở, nổi tiếng với tính ổn định, tuân thủ chuẩn SQL nghiêm ngặt và hỗ trợ nhiều tính năng nâng cao mà các RDBMS thương mại khác cung cấp. So với MySQL (lựa chọn phổ biến trong các đồ án nhỏ), PostgreSQL có một số ưu thế đáng kể đối với bài toán FoodRush:

- **Hỗ trợ kiểu dữ liệu phong phú**: ngoài các kiểu cơ bản, PostgreSQL hỗ trợ `JSONB` (lưu JSON nhị phân, có thể index), `ARRAY`, `UUID`, `INET`, geometric types. Điều này hữu ích để lưu các trường biến đổi như metadata khuyến mãi, payload payment gateway, hoặc danh sách topping.
- **Tính nhất quán mạnh (ACID)**: phù hợp với nghiệp vụ thanh toán và đặt hàng – nơi không được phép mất giao dịch.
- **Full-text search và tìm kiếm theo địa lý**: thông qua các extension như `pg_trgm`, `unaccent`, `PostGIS`, giúp triển khai tìm nhà hàng theo tên hoặc theo khoảng cách địa lý.
- **MVCC (Multi-Version Concurrency Control)**: nhiều giao dịch đọc/ghi đồng thời mà không khoá toàn bảng, phù hợp với hệ thống có nhiều người đặt đơn cùng lúc.
- **Quản lý migration với Flyway/Liquibase**: schema được version hoá, đảm bảo môi trường dev và prod đồng nhất.

PostgreSQL được sử dụng để lưu các bảng chính: `users`, `addresses`, `restaurants`, `operating_hours`, `menu_categories`, `menu_items`, `carts`, `cart_items`, `orders`, `order_items`, `order_status_history`, `payments`, `reviews`. Các quan hệ được mô tả chi tiết trong Chương 2.

### 1.5 Kiến trúc Flutter

Flutter được xây dựng dựa trên mô hình kiến trúc **hướng Widget**: toàn bộ giao diện là một cây phân cấp gọi là **Widget Tree**. Mỗi phần tử – từ một dòng văn bản, nút bấm cho tới một layout phức tạp – đều là widget. Có hai loại widget chính:

- **StatelessWidget**: không thay đổi trạng thái trong vòng đời của nó, dùng cho các thành phần tĩnh (logo, icon, text cố định).
- **StatefulWidget**: có trạng thái nội bộ, gọi `setState()` để rebuild khi dữ liệu thay đổi. Tuy nhiên trong dự án, `setState()` chỉ được dùng cho UI cục bộ – logic nghiệp vụ được tách ra BLoC.

Bên cạnh widget tree, Flutter còn quản lý hai cây song song:

- **Element Tree**: lưu trữ trạng thái và mối quan hệ giữa các widget.
- **RenderObject Tree**: chịu trách nhiệm layout, paint và hit-test.

Cách tổ chức ba cây này giúp Flutter tối ưu render – khi rebuild, chỉ phần widget có thay đổi mới được tái dựng RenderObject tương ứng.

Trong FoodRush, kiến trúc phía client áp dụng nguyên lý **Clean Architecture** kết hợp **Feature-first**:

```
lib/
├── core/                  # cross-cutting: network (Dio + interceptor), storage, theme, utils
├── features/
│   ├── auth/              # đăng nhập, đăng ký, refresh token
│   ├── home/              # trang chủ, gợi ý nhà hàng
│   ├── restaurant/        # danh sách & chi tiết nhà hàng
│   ├── menu/              # thực đơn, chi tiết món
│   ├── cart/              # giỏ hàng, checkout
│   ├── order/             # tracking, lịch sử
│   ├── payment/           # thanh toán
│   ├── review/            # đánh giá
│   ├── notification/      # thông báo
│   └── admin/             # cho RESTAURANT_ADMIN
└── shared/                # widgets dùng chung, model ApiResponse, Pagination
```

Mỗi feature thường có ba lớp: **data** (datasource gọi API), **domain** (model, repository interface), **presentation** (BLoC + UI). Cấu trúc này giúp nhiều người làm việc song song và dễ kiểm thử.

### 1.6 State Management (BLoC)

Quản lý trạng thái là một trong những thử thách lớn nhất khi xây dựng ứng dụng Flutter quy mô vừa và lớn. FoodRush có nhiều màn hình chia sẻ trạng thái (giỏ hàng, đăng nhập, đơn hàng đang theo dõi) và cần xử lý dữ liệu thời gian thực, nên việc lựa chọn pattern phù hợp là then chốt.

**Bảng 3. So sánh state management Flutter**

| Giải pháp | Đặc điểm | Phù hợp với |
|-----------|----------|-------------|
| `setState` | Đơn giản, cục bộ trong widget | UI nhỏ, không chia sẻ trạng thái |
| Provider | Dễ học, dùng `ChangeNotifier` | Ứng dụng nhỏ–trung bình |
| Riverpod | Cải tiến Provider, không phụ thuộc BuildContext | Dự án mới, cần testability |
| GetX | Tích hợp DI, route, state | Dự án cần phát triển nhanh, ít quy ước |
| **BLoC / Cubit** | Tách biệt rõ event–state, dựa trên Stream | Dự án trung bình–lớn, cần testable & maintainable |

Dự án FoodRush lựa chọn **BLoC pattern** (qua package `flutter_bloc`) với một số lý do:

1. **Phân tách rõ ràng giữa UI và logic**: UI dispatch event, BLoC xử lý và phát ra state, UI rebuild theo state. Mọi luồng dữ liệu đều rõ ràng, dễ debug.
2. **Predictable state**: mỗi state là một class bất biến, dễ snapshot và replay.
3. **Tính testable cao**: có thể test BLoC độc lập với UI bằng `bloc_test`, không cần Flutter test environment.
4. **Cubit cho các case đơn giản**: với những trạng thái không cần event (ví dụ `CartCubit`, `ThemeCubit`), Cubit là phiên bản gọn nhẹ hơn của BLoC.

Ví dụ tổ chức `OrderTrackingBloc`:

- **Event**: `LoadOrder`, `OrderStatusReceived(status)`, `CancelOrder`.
- **State**: `OrderInitial`, `OrderLoading`, `OrderTracking(order)`, `OrderCompleted(order)`, `OrderError(message)`.
- BLoC lắng nghe stream STOMP từ backend, mỗi khi nhận sự kiện sẽ `add(OrderStatusReceived(...))` và emit state mới.

### 1.7 Giao tiếp Client–Server: REST API & WebSocket (STOMP)

FoodRush sử dụng kết hợp hai phương thức giao tiếp:

#### REST API (HTTP/HTTPS)

REST là kiến trúc trao đổi dữ liệu dựa trên giao thức HTTP, sử dụng các phương thức như `GET`, `POST`, `PUT`, `DELETE`. Dữ liệu chính được truyền dưới dạng JSON. Trong dự án, REST API dùng cho hầu hết nghiệp vụ:

- **Authentication**: `POST /api/auth/register`, `POST /api/auth/login`, `POST /api/auth/refresh`, `POST /api/auth/logout`.
- **Restaurant & Menu**: `GET /api/restaurants`, `GET /api/restaurants/{id}`, `GET /api/restaurants/{id}/menu`.
- **Cart**: `GET /api/cart`, `POST /api/cart/items`, `PUT /api/cart/items/{id}`, `DELETE /api/cart/items/{id}`.
- **Order**: `POST /api/orders`, `GET /api/orders`, `GET /api/orders/{id}`, `POST /api/orders/{id}/cancel`.
- **Payment**: `POST /api/payments/{orderId}/charge`, `POST /api/payments/webhook` (callback từ cổng thanh toán).
- **Review**: `POST /api/reviews`, `GET /api/restaurants/{id}/reviews`.

Phía Flutter dùng thư viện **Dio** – một HTTP client mạnh hơn `http` chuẩn vì hỗ trợ **interceptor** (tự gắn JWT, refresh token, log request), **cancel token** (huỷ request khi rời màn hình), **FormData** (upload ảnh menu / profile), và **timeout** mềm dẻo.

#### WebSocket với STOMP

Một số nghiệp vụ yêu cầu thông tin tức thời, ví dụ:

- Khách hàng theo dõi trạng thái đơn theo thời gian thực (RECEIVED → PREPARING → READY → DELIVERING → COMPLETED).
- Nhà hàng nhận đơn mới ngay khi khách đặt.
- Shipper nhận thông tin đơn được phân công.

Với những trường hợp này, REST API (yêu cầu polling) là không hiệu quả. FoodRush sử dụng **WebSocket** kết hợp với giao thức **STOMP** (Simple Text Oriented Messaging Protocol). STOMP cung cấp cơ chế pub/sub trên WebSocket:

- **Topic** broadcast: `/topic/orders/{restaurantId}` – nhà hàng subscribe để nhận đơn mới.
- **User queue**: `/user/queue/order-status` – khách hàng subscribe để nhận cập nhật cho đơn của mình.

Backend sử dụng `@MessageMapping` và `SimpMessagingTemplate.convertAndSendToUser(...)` của Spring để publish; client Flutter dùng package `stomp_dart_client` để subscribe và parse JSON.

### 1.8 Xác thực và bảo mật: JWT, Spring Security, Refresh Token

Hệ thống đa người dùng buộc phải có cơ chế xác thực và phân quyền chặt chẽ. FoodRush áp dụng tổ hợp **JWT (JSON Web Token)** + **Refresh Token** + **Spring Security**:

- **Access Token (JWT)**: token ngắn hạn (~15 phút), được ký bằng thuật toán HMAC SHA-256, chứa `userId`, `role`, `exp`. Client gửi kèm trong header `Authorization: Bearer <token>`. Backend xác thực không cần truy DB nhờ tính chất stateless của JWT.
- **Refresh Token**: token dài hạn (~7–30 ngày), lưu trong DB (`refresh_tokens`) và trong `flutter_secure_storage` ở client. Khi access token hết hạn, client gọi `POST /api/auth/refresh` để lấy access token mới mà không cần đăng nhập lại.
- **Spring Security**: cung cấp `SecurityFilterChain` với một custom `OncePerRequestFilter` (`JwtAuthenticationFilter`) trích token từ header, validate, set `Authentication` vào `SecurityContext`. Các endpoint nhạy cảm được phân quyền bằng annotation:
  - `@PreAuthorize("hasRole('CUSTOMER')")` cho đặt hàng.
  - `@PreAuthorize("hasRole('RESTAURANT_ADMIN')")` cho quản lý menu.
  - `@PreAuthorize("hasRole('DELIVERY_AGENT')")` cho cập nhật vị trí shipper.
- **Mật khẩu**: hash bằng **BCrypt** (`BCryptPasswordEncoder` với cost factor 10–12), không bao giờ lưu plain text.
- **CORS**: cấu hình `CorsConfiguration` cho phép app web và mobile gọi API.
- **Rate limiting**: thông qua Redis (bucket4j hoặc bucket-redis) để chống brute-force ở các endpoint đăng nhập.

Mục tiêu: an toàn ngay cả khi access token bị lộ (ngắn hạn), giữ trải nghiệm người dùng (không phải đăng nhập lại quá thường xuyên), và sẵn sàng cho việc revoke session qua DB.

### 1.9 Caching với Redis

Redis là một in-memory key-value store, được dùng trong FoodRush với ba mục tiêu:

1. **Cache dữ liệu đọc nhiều**: danh sách nhà hàng, menu, danh mục. Các dữ liệu này thay đổi không thường xuyên nhưng được truy vấn liên tục, cache giúp giảm tải DB và tăng tốc response.
2. **Lưu giỏ hàng tạm thời (transient cart)** cho khách chưa đăng nhập: với TTL ngắn (~24h).
3. **Rate limiting & session blacklist**: lưu danh sách JWT đã logout/forced-revoke, kiểm tra mỗi request.

Spring Boot tích hợp Redis qua `spring-boot-starter-data-redis` và annotation `@Cacheable`, `@CacheEvict`. Khi entity được cập nhật (ví dụ nhà hàng đổi menu), `@CacheEvict` sẽ tự xoá cache liên quan để đảm bảo tính nhất quán.

### 1.10 Push Notification với Firebase FCM

**Firebase Cloud Messaging (FCM)** là dịch vụ của Google cho phép gửi thông báo đẩy miễn phí tới Android và iOS từ một API thống nhất. FoodRush sử dụng FCM cho các kịch bản:

- Thông báo khi đơn hàng đổi trạng thái (đã xác nhận, đang chuẩn bị, đang giao, đã giao).
- Thông báo cho nhà hàng khi có đơn mới.
- Thông báo khuyến mãi / mã giảm giá (Phase 2).

Luồng triển khai:

1. Client Flutter đăng ký FCM token và gửi về backend qua `POST /api/users/me/fcm-token`.
2. Backend lưu token vào cột `users.fcm_token`.
3. Khi xảy ra sự kiện cần thông báo (ví dụ trạng thái đơn chuyển sang DELIVERING), backend gọi Firebase Admin SDK gửi message tới token tương ứng.

So với việc tự xây dựng socket push, FCM mang lại các lợi ích: tin cậy cao, hỗ trợ background/terminate state, tiết kiệm pin và là tiêu chuẩn của hệ điều hành Android.

### 1.11 Các công nghệ và thư viện sử dụng

#### Frontend (Flutter)

| Package | Mục đích |
|---------|----------|
| `flutter_bloc` | Quản lý trạng thái theo BLoC pattern |
| `dio` | HTTP client (interceptor, cancel, timeout, FormData) |
| `go_router` | Khai báo router phân cấp, deep-link friendly |
| `equatable` | So sánh giá trị model bất biến, hỗ trợ BLoC state |
| `flutter_secure_storage` | Lưu Access/Refresh Token an toàn (Keychain/Keystore) |
| `shared_preferences` | Lưu cấu hình không nhạy cảm (theme, locale) |
| `stomp_dart_client` | Kết nối WebSocket theo giao thức STOMP |
| `intl` | Định dạng tiền tệ, ngày giờ theo locale |
| `cupertino_icons` | Icon iOS |

#### Backend (Spring Boot)

| Module | Vai trò |
|--------|---------|
| `spring-boot-starter-web` | REST controller, Tomcat embedded |
| `spring-boot-starter-data-jpa` | ORM với Hibernate, repository pattern |
| `spring-boot-starter-security` | Authentication & Authorization |
| `spring-boot-starter-validation` | Validate DTO bằng Bean Validation (`@NotNull`, `@Email`) |
| `spring-boot-starter-websocket` | WebSocket + STOMP |
| `spring-boot-starter-data-redis` | Tích hợp Redis |
| `jjwt` (io.jsonwebtoken) | Tạo và verify JWT |
| `flyway-core` | Migration cơ sở dữ liệu |
| `springdoc-openapi` | Tự sinh tài liệu Swagger UI |
| `postgresql` (JDBC driver) | Kết nối PostgreSQL |
| `firebase-admin` | Gửi push notification |

#### Hạ tầng

| Thành phần | Công nghệ |
|------------|-----------|
| Cơ sở dữ liệu | PostgreSQL 16 |
| Cache | Redis 7 |
| Push notification | Firebase Cloud Messaging |
| Đóng gói | Docker + Docker Compose |
| CI/CD (gợi ý) | GitHub Actions |
| Hosting backend (gợi ý) | VPS Linux (Ubuntu) hoặc Render / Railway / AWS ECS |

**Bảng 2. Tech Stack và lý do lựa chọn**

| Layer | Công nghệ | Lý do |
|-------|-----------|-------|
| Mobile | Flutter 3.x + Dart | Cross-platform, Hot Reload, hệ widget mạnh |
| State Management | flutter_bloc | Predictable, testable, phù hợp dự án trung bình |
| HTTP | Dio | Interceptor, cancel, FormData |
| Real-time | STOMP/WebSocket | Tích hợp tự nhiên với Spring WebSocket |
| Backend | Spring Boot 3.x | Hệ sinh thái Java doanh nghiệp, auto-config |
| Auth | JWT + Refresh Token | Stateless, mobile-friendly |
| DB | PostgreSQL 16 | ACID, JSONB, full-text, geo |
| Cache | Redis | Tăng tốc đọc, rate limit, session |
| Migration | Flyway | Versioned schema, dev/prod parity |
| Docs API | Swagger / OpenAPI 3 | Tự sinh từ annotation |
| Push | Firebase FCM | Cross-platform, miễn phí, tin cậy |
| Container | Docker + Compose | Dev/prod parity, dễ deploy |

---

## CHƯƠNG 2. XÂY DỰNG ỨNG DỤNG

### 2.1 Mô tả chức năng

Ứng dụng FoodRush được xây dựng theo kiến trúc client–server: client là Flutter app, server là Spring Boot REST API + WebSocket. Hệ thống phục vụ bốn vai trò người dùng, mỗi vai trò có nhóm chức năng riêng.

**Bảng 1. Vai trò các bên liên quan (Stakeholders)**

| Vai trò | Mô tả |
|---------|-------|
| CUSTOMER | Khách hàng đặt đồ ăn |
| RESTAURANT_ADMIN | Quản lý nhà hàng, menu, đơn |
| DELIVERY_AGENT | Shipper giao hàng |
| SYSTEM_ADMIN | Quản trị toàn hệ thống |

#### 2.1.1 Nhóm chức năng dành cho Khách hàng (Customer)

Đây là nhóm chức năng cốt lõi, chiếm phần lớn thời lượng phát triển. Bao gồm:

- **Đăng ký / Đăng nhập**: bằng email + mật khẩu. Sau đăng nhập, hệ thống trả về Access Token và Refresh Token. App lưu Refresh Token vào `flutter_secure_storage`.
- **Quản lý hồ sơ và địa chỉ**: chỉnh sửa tên, số điện thoại, ảnh đại diện; quản lý nhiều địa chỉ giao hàng, đặt địa chỉ mặc định.
- **Duyệt nhà hàng**: theo vị trí (tính khoảng cách từ địa chỉ mặc định), theo loại ẩm thực (Việt, Hàn, Nhật…), theo từ khóa.
- **Xem chi tiết nhà hàng & thực đơn**: hiển thị banner, mô tả, giờ mở cửa, đánh giá, danh mục menu, từng món có ảnh / mô tả / giá / topping.
- **Giỏ hàng**: thêm món, điều chỉnh số lượng, ghi chú đặc biệt, áp dụng mã giảm giá (Phase 2). Giỏ hàng được giữ trên server (cho user đã đăng nhập) hoặc Redis tạm thời (user khách).
- **Đặt hàng và thanh toán**: chọn địa chỉ giao hàng, phương thức thanh toán (COD, thẻ). Đơn được tạo với trạng thái khởi tạo `PENDING_PAYMENT` hoặc `RECEIVED`.
- **Theo dõi đơn hàng real-time**: subscribe `/user/queue/order-status` qua STOMP, cập nhật trạng thái ngay khi nhà hàng / shipper thao tác.
- **Lịch sử đơn hàng**: danh sách đơn đã đặt, có thể xem lại chi tiết, đặt lại.
- **Đánh giá nhà hàng**: sau khi đơn `COMPLETED`, khách hàng có thể chấm sao và viết nhận xét.
- **Thông báo đẩy**: nhận thông báo trạng thái đơn qua FCM.

#### 2.1.2 Nhóm chức năng dành cho Chủ nhà hàng (Restaurant Admin)

- **Quản lý hồ sơ nhà hàng**: tên, mô tả, banner, logo, giờ mở cửa, vị trí.
- **Quản lý thực đơn**: tạo danh mục (Khai vị, Món chính, Đồ uống…), thêm/sửa/xoá món, đăng ảnh, đặt trạng thái còn hàng / hết hàng, đặt giá khuyến mãi.
- **Quản lý đơn hàng**: xem danh sách đơn theo trạng thái (mới, đang chuẩn bị, sẵn sàng, đang giao, hoàn thành, đã huỷ). Khi nhận đơn mới (qua STOMP), app phát âm thanh / hiển thị banner. Có thể chấp nhận, từ chối hoặc cập nhật trạng thái.
- **Báo cáo doanh thu**: xem doanh thu theo ngày / tháng, top món bán chạy (cơ bản trong MVP).

#### 2.1.3 Nhóm chức năng dành cho Shipper (Delivery Agent)

- **Đăng nhập** và **bật trạng thái sẵn sàng nhận đơn**.
- **Nhận thông tin đơn được phân công** qua FCM hoặc STOMP.
- **Cập nhật trạng thái giao hàng**: đã lấy hàng, đang giao, đã giao.
- **Cập nhật vị trí** (Phase 2): gửi vị trí định kỳ để khách hàng xem trên bản đồ.

#### 2.1.4 Nhóm chức năng dành cho Quản trị hệ thống (System Admin)

- Quản lý tài khoản và quyền: kích hoạt / khoá tài khoản.
- Phê duyệt nhà hàng đăng ký mới.
- Xem tổng quan thống kê hệ thống.

#### 2.1.5 Tóm tắt luồng sử dụng chính

**Luồng đặt hàng tiêu chuẩn (happy path)**:

1. Khách hàng đăng nhập → vào trang chủ → chọn nhà hàng → xem menu → thêm món vào giỏ.
2. Mở giỏ hàng → chọn địa chỉ + phương thức thanh toán → đặt hàng.
3. Backend tạo `Order` (trạng thái RECEIVED), publish event qua STOMP cho nhà hàng (`/topic/restaurants/{id}/new-orders`).
4. Nhà hàng nhận thông báo → chấp nhận đơn → cập nhật trạng thái PREPARING → READY.
5. Backend phân công shipper → trạng thái DELIVERING → khách hàng và shipper đều nhận update qua STOMP và FCM.
6. Shipper giao hàng → cập nhật COMPLETED.
7. Khách hàng được phép đánh giá nhà hàng.

### 2.2 Phân tích hệ thống

#### 2.2.1 Use Case hệ thống

**Hình 2. Biểu đồ Use Case tổng quát** *(actor: Customer, Restaurant Admin, Delivery Agent, System Admin)*

Các use case được nhóm theo actor:

- **Customer**: Đăng ký, Đăng nhập, Duyệt nhà hàng, Tìm kiếm, Xem menu, Thêm vào giỏ, Đặt hàng, Thanh toán, Theo dõi đơn, Đánh giá.
- **Restaurant Admin**: Quản lý hồ sơ NH, Quản lý menu, Nhận đơn, Cập nhật trạng thái đơn, Xem báo cáo.
- **Delivery Agent**: Nhận đơn được phân công, Cập nhật trạng thái giao, Xem lịch sử giao.
- **System Admin**: Quản lý user, Phê duyệt NH, Thống kê hệ thống.

#### 2.2.2 Mô tả use case

**Bảng 6. Mô tả Use Case tổng quát**

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
| UC-12 | Cập nhật trạng thái giao | Shipper | Đẩy trạng thái giao hàng | Đơn được gán cho shipper | Trạng thái mới broadcast |
| UC-13 | Quản trị hệ thống | SysAdmin | Khoá user, phê duyệt NH | Có quyền SYSTEM_ADMIN | Trạng thái user/NH cập nhật |

### 2.3 Thiết kế hệ thống

#### a. Kiến trúc tổng thể

```
┌─────────────────────────────────────────────────────────┐
│                    FLUTTER APP                           │
│  ┌────────┐ ┌──────────┐ ┌────────┐ ┌────────┐ ┌──────┐ │
│  │  Auth  │ │Restaurant│ │ Cart   │ │ Order  │ │Admin │ │
│  └────────┘ └──────────┘ └────────┘ └────────┘ └──────┘ │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTPS / WSS (STOMP)
┌──────────────────────▼──────────────────────────────────┐
│              SPRING BOOT API (Port 8080)                 │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌──────────────┐      │
│  │  Auth  │ │ Menu   │ │ Order  │ │ Notification │      │
│  └────────┘ └────────┘ └────────┘ └──────────────┘      │
│         Spring Security + JWT Filter + WebSocket          │
└──────┬───────────────┬──────────────────┬─────────────────┘
       │               │                  │
┌──────▼──────┐ ┌──────▼──────┐  ┌────────▼────────┐
│ PostgreSQL  │ │   Redis     │  │ Firebase FCM    │
│ (Primary)   │ │ (Cache)     │  │ (Push)          │
└─────────────┘ └─────────────┘  └─────────────────┘
```

**Phía Client (Flutter)** áp dụng Clean Architecture: mỗi feature có ba lớp **data / domain / presentation**. Tầng `core/network` chứa Dio client với interceptor JWT, tự refresh khi gặp 401. Tầng `core/storage` quản lý `flutter_secure_storage` cho token và `shared_preferences` cho cấu hình.

**Phía Server (Spring Boot)** chia theo bounded context: `auth`, `user`, `restaurant`, `menu`, `cart`, `order`, `payment`, `review`, `notification`. Mỗi context theo cấu trúc `controller / service / repository / entity / dto`. Cross-cutting bố trí trong `common` (DTO chung, enum, exception, validator) và `config` (Security, JWT, WebSocket, Swagger, Redis).

**Luồng dữ liệu đặt hàng (chế độ online)**:

1. Customer đặt hàng → Flutter `POST /api/orders` kèm JWT.
2. Spring Security xác thực token, controller chuyển vào `OrderService`.
3. `OrderService` mở transaction: kiểm tra giỏ, tính tổng tiền, tạo `Order` + `OrderItem`, ghi `order_status_history`.
4. Sau commit, service publish event qua `SimpMessagingTemplate` đến `/topic/restaurants/{restaurantId}/new-orders` và gửi FCM.
5. Restaurant client (đang subscribe) nhận sự kiện ngay lập tức.
6. Mỗi lần đổi trạng thái, lặp lại bước publish – tới topic của khách `/user/{userId}/queue/order-status`.

#### b. Database

PostgreSQL được tổ chức thành các bảng chính (tóm tắt; chi tiết xem file `docs/02_DATABASE_SCHEMA.md`).

**Bảng 10. Mô tả bảng `users`**

| Tên cột | Kiểu | Ràng buộc | Mô tả |
|---------|------|-----------|-------|
| id | BIGSERIAL | PK | Định danh |
| email | VARCHAR(255) | UNIQUE NOT NULL | Email đăng nhập |
| phone_number | VARCHAR(20) | UNIQUE | SĐT |
| password_hash | VARCHAR(255) | NOT NULL | Hash BCrypt |
| first_name | VARCHAR(100) | NOT NULL | |
| last_name | VARCHAR(100) | NOT NULL | |
| role | VARCHAR(30) | NOT NULL | CUSTOMER / RESTAURANT_ADMIN / DELIVERY_AGENT / SYSTEM_ADMIN |
| fcm_token | VARCHAR(255) | | Token push notification |
| is_active | BOOLEAN | DEFAULT true | |
| created_at | TIMESTAMPTZ | NOT NULL | |
| updated_at | TIMESTAMPTZ | NOT NULL | |

**Bảng 11. Mô tả bảng `restaurants`**

| Tên cột | Kiểu | Ràng buộc | Mô tả |
|---------|------|-----------|-------|
| id | BIGSERIAL | PK | |
| owner_id | BIGINT | FK → users(id) | Chủ nhà hàng |
| name | VARCHAR(255) | NOT NULL | |
| slug | VARCHAR(255) | UNIQUE | URL-safe |
| cuisine_type | VARCHAR(100) | NOT NULL | Loại ẩm thực |
| latitude / longitude | DECIMAL(10,7) | | Vị trí |
| rating_avg | DECIMAL(3,2) | DEFAULT 0 | |
| is_active | BOOLEAN | DEFAULT true | |

**Bảng 12. Mô tả bảng `menu_items`**

| Tên cột | Kiểu | Ràng buộc | Mô tả |
|---------|------|-----------|-------|
| id | BIGSERIAL | PK | |
| category_id | BIGINT | FK → menu_categories(id) | |
| name | VARCHAR(255) | NOT NULL | |
| description | TEXT | | |
| price | DECIMAL(12,2) | NOT NULL | |
| image_url | TEXT | | |
| is_available | BOOLEAN | DEFAULT true | |

**Bảng 13. Mô tả bảng `orders`**

| Tên cột | Kiểu | Ràng buộc | Mô tả |
|---------|------|-----------|-------|
| id | BIGSERIAL | PK | |
| user_id | BIGINT | FK → users(id) | Khách đặt |
| restaurant_id | BIGINT | FK → restaurants(id) | |
| delivery_agent_id | BIGINT | FK → users(id) NULL | Shipper |
| address_id | BIGINT | FK → addresses(id) | Địa chỉ giao |
| subtotal / delivery_fee / total | DECIMAL(12,2) | NOT NULL | |
| status | VARCHAR(30) | NOT NULL | PENDING_PAYMENT / RECEIVED / PREPARING / READY / DELIVERING / COMPLETED / CANCELED |
| payment_method | VARCHAR(20) | NOT NULL | COD / CARD |
| placed_at | TIMESTAMPTZ | NOT NULL | |
| completed_at | TIMESTAMPTZ | NULL | |

**Bảng 14. Mô tả bảng `payments`**

| Tên cột | Kiểu | Ràng buộc | Mô tả |
|---------|------|-----------|-------|
| id | BIGSERIAL | PK | |
| order_id | BIGINT | FK → orders(id) UNIQUE | |
| amount | DECIMAL(12,2) | NOT NULL | |
| method | VARCHAR(20) | NOT NULL | COD / CARD |
| status | VARCHAR(20) | NOT NULL | PENDING / SUCCESS / FAILED / REFUNDED |
| transaction_id | VARCHAR(255) | | ID từ cổng thanh toán |
| paid_at | TIMESTAMPTZ | | |

**Bảng 15. Mô tả bảng `reviews`**

| Tên cột | Kiểu | Ràng buộc | Mô tả |
|---------|------|-----------|-------|
| id | BIGSERIAL | PK | |
| order_id | BIGINT | FK → orders(id) UNIQUE | |
| restaurant_id | BIGINT | FK → restaurants(id) | |
| user_id | BIGINT | FK → users(id) | |
| rating | SMALLINT | CHECK BETWEEN 1 AND 5 | |
| comment | TEXT | | |
| created_at | TIMESTAMPTZ | NOT NULL | |

#### c. UI/UX

- **Hình 12. Màn hình đăng nhập / đăng ký** – form email + mật khẩu, có toggle ẩn/hiện, link quên mật khẩu, lưu trạng thái loading.
- **Hình 13. Trang chủ & tìm kiếm** – banner khuyến mãi, nhà hàng theo gợi ý vị trí, thanh tìm kiếm và filter cuisine type.
- **Hình 14. Chi tiết nhà hàng & menu** – tab danh mục, list món, modal chi tiết món có chọn topping.
- **Hình 15. Giỏ hàng & checkout** – danh sách món, chỉnh số lượng, chọn địa chỉ giao, chọn phương thức thanh toán, tổng tiền.
- **Hình 16. Theo dõi đơn hàng real-time** – timeline trạng thái có animation, dự kiến thời gian giao.
- **Hình 17. Lịch sử đơn hàng** – list đơn đã đặt, badge trạng thái.
- **Hình 18. Quản trị nhà hàng** – dashboard đơn mới, danh sách menu, doanh thu.

Toàn bộ UI tuân theo **Material 3**, hỗ trợ light/dark theme, sử dụng hệ tokens màu định nghĩa tại `core/theme/app_theme.dart`.

---

## CHƯƠNG 3. THỰC NGHIỆM

### 3.1 Kiến trúc triển khai

Hệ thống được triển khai theo mô hình **ba lớp**: Client – Server – Database, kết hợp với Redis cache và Firebase FCM.

- **Client (Flutter App)**: build release thành APK (Android) và IPA (iOS), phân phối qua nội bộ hoặc lên Google Play / TestFlight.
- **Server (Spring Boot)**: chạy dạng `.jar` thực thi với Tomcat embedded, hoặc đóng gói Docker container, expose cổng 8080.
- **Database (PostgreSQL)** và **Redis**: chạy container riêng, dữ liệu được persist qua Docker volume.

**Triển khai Docker Compose**

Một file `docker-compose.yml` (đã có sẵn trong `server_app_foot/`) khai báo các service:

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: foodrush
      POSTGRES_USER: foodrush
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7
    ports:
      - "6379:6379"

  backend:
    build: .
    depends_on:
      - postgres
      - redis
    environment:
      SPRING_PROFILES_ACTIVE: prod
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/foodrush
      SPRING_DATA_REDIS_HOST: redis
    ports:
      - "8080:8080"

volumes:
  pgdata:
```

**Triển khai bản Android**

```bash
flutter build apk --release
# Kết quả: build/app/outputs/flutter-apk/app-release.apk
```

Khi chạy thử trên Android Emulator, baseUrl trỏ tới `http://10.0.2.2:8080`. Trên thiết bị thật cùng LAN, dùng IP máy chạy server (ví dụ `http://192.168.1.10:8080`). Khi triển khai thật, dùng HTTPS domain (ví dụ `https://api.foodrush.com`).

**Triển khai bản iOS**

```bash
flutter build ipa --release
```

Yêu cầu Mac với Xcode để ký và phân phối qua TestFlight / App Store.

### 3.2 Môi trường

**Bảng 16. Môi trường phát triển & triển khai**

| Thành phần | Phiên bản |
|------------|-----------|
| Flutter SDK | 3.x (stable) |
| Dart SDK | ≥ 3.9 |
| JDK | 17 |
| Spring Boot | 3.x |
| PostgreSQL | 16 |
| Redis | 7 |
| Hệ điều hành phát triển | Windows 11 / macOS / Ubuntu |
| IDE | VS Code, Android Studio, IntelliJ IDEA |
| Quản lý phiên bản | Git + GitHub |
| CI/CD (đề xuất) | GitHub Actions |
| Container | Docker Desktop / Docker Engine |
| Postman / Insomnia | Kiểm thử API |

### 3.3 Triển khai ứng dụng

Hình ảnh minh hoạ các màn hình chính:

- **Hình 12. Màn hình đăng nhập / đăng ký**
- **Hình 13. Màn hình trang chủ và tìm kiếm nhà hàng**
- **Hình 14. Màn hình chi tiết nhà hàng và thực đơn**
- **Hình 15. Màn hình giỏ hàng và thanh toán**
- **Hình 16. Màn hình theo dõi đơn hàng real-time**
- **Hình 17. Màn hình lịch sử đơn hàng**
- **Hình 18. Màn hình quản trị nhà hàng**

*(Chèn ảnh chụp màn hình từ thiết bị thực tế hoặc emulator vào các vị trí trên khi xuất bản báo cáo.)*

---

## KẾT LUẬN

### 1. Đã đạt được

Trong quá trình thực hiện, nhóm đã xây dựng thành công một hệ thống đặt đồ ăn online tương đối hoàn chỉnh ở mức MVP, gồm ba thành phần chính:

- **Ứng dụng Flutter** chạy trên cả Android và iOS, áp dụng **Clean Architecture** kết hợp **BLoC pattern**. Hệ thống module hoá rõ ràng theo feature (auth, restaurant, menu, cart, order, profile, notification, admin) giúp dễ mở rộng và bảo trì.
- **Backend Spring Boot** triển khai đầy đủ các nghiệp vụ MVP: xác thực JWT, CRUD nhà hàng – thực đơn, giỏ hàng, đặt hàng, thanh toán, theo dõi đơn real-time qua WebSocket/STOMP, đánh giá. Bảo mật bằng Spring Security với phân quyền theo role và rate limiting bằng Redis.
- **Cơ sở dữ liệu PostgreSQL** được thiết kế chuẩn 3NF, quản lý migration bằng Flyway, đảm bảo tính nhất quán cho nghiệp vụ thanh toán và đặt đơn.

Về mặt kỹ thuật, nhóm đã làm chủ được nhiều công nghệ then chốt: Flutter widget tree, BLoC, Dio interceptor, go_router, STOMP client; Spring Security với JWT filter, Spring Data JPA, Spring WebSocket; PostgreSQL với chỉ mục địa lý; Redis cache với `@Cacheable`; Firebase FCM cho push notification; Docker Compose để đóng gói triển khai.

Việc xây dựng end-to-end một hệ thống đa người dùng – đa vai trò giúp nhóm hình thành tư duy thiết kế kiến trúc tổng thể, hiểu rõ luồng dữ liệu giữa các tầng và biết cách xử lý các vấn đề thường gặp trong sản phẩm thực tế như xác thực, đồng bộ thời gian thực, bảo mật và tối ưu hiệu năng.

### 2. Hạn chế

Mặc dù hệ thống đã hoạt động đúng nghiệp vụ, vẫn còn một số hạn chế cần cải thiện:

- **Giao diện chưa hoàn thiện**: một số màn hình còn ở mức "đủ dùng", chưa có các trạng thái loading / empty / error đồng bộ, animation và micro-interaction chưa được trau chuốt.
- **Tích hợp thanh toán còn ở mức mô phỏng**: chưa tích hợp cổng thanh toán thật (VNPay, MoMo, Stripe). Webhook payment hiện được mock.
- **Theo dõi shipper trên bản đồ chưa có**: mới chỉ broadcast trạng thái đơn, chưa hiển thị vị trí real-time trên Google Map.
- **Chưa có CI/CD tự động**: hiện việc build và deploy còn thực hiện thủ công, chưa có pipeline GitHub Actions chạy test + build image + deploy.
- **Bảo mật cơ bản, chưa phòng các kịch bản nâng cao**: chưa có cơ chế 2FA, chưa kiểm thử OWASP toàn diện, logging audit còn sơ sài.
- **Hiệu năng chưa đo đạc**: chưa có benchmark cụ thể cho thông lượng API, độ trễ WebSocket khi nhiều người dùng đồng thời.

### 3. Hướng phát triển

Trong tương lai, hệ thống có thể được mở rộng theo các hướng sau:

- **Tích hợp cổng thanh toán thật** (VNPay, MoMo, ZaloPay, Stripe) với webhook xác thực chữ ký.
- **Bản đồ theo dõi shipper real-time** sử dụng Google Maps SDK, kết hợp WebSocket gửi vị trí mỗi 5 giây.
- **Chat trực tiếp** giữa khách hàng và nhà hàng / shipper qua WebSocket.
- **Hệ thống khuyến mãi** đầy đủ: mã giảm giá, flash sale, point/loyalty.
- **Tìm kiếm nâng cao** với Elasticsearch hoặc PostgreSQL full-text + `pg_trgm` cho fuzzy match.
- **CI/CD tự động** bằng GitHub Actions: lint → test → build Docker image → deploy lên môi trường staging.
- **Monitoring & logging tập trung**: ELK stack hoặc Grafana + Prometheus + Loki để theo dõi sức khoẻ hệ thống.
- **Mở rộng quy mô (scale-out)**: tách microservice (order, payment, notification thành service riêng), sử dụng Kafka cho event streaming.
- **Phiên bản web** cho admin panel của nhà hàng dùng cùng codebase Flutter Web.

---

## PHỤ LỤC

### A. Tài liệu và link tham khảo

- Flutter Documentation: <https://docs.flutter.dev/>
- Dart Language Tour: <https://dart.dev/guides>
- flutter_bloc: <https://pub.dev/packages/flutter_bloc>
- Dio HTTP Client: <https://pub.dev/packages/dio>
- go_router: <https://pub.dev/packages/go_router>
- stomp_dart_client: <https://pub.dev/packages/stomp_dart_client>
- flutter_secure_storage: <https://pub.dev/packages/flutter_secure_storage>
- Spring Boot Reference: <https://docs.spring.io/spring-boot/docs/current/reference/html/>
- Spring Security Reference: <https://docs.spring.io/spring-security/reference/>
- Spring WebSocket / STOMP: <https://docs.spring.io/spring-framework/reference/web/websocket.html>
- PostgreSQL 16 Docs: <https://www.postgresql.org/docs/16/>
- Flyway Migrations: <https://documentation.red-gate.com/fd>
- Redis Docs: <https://redis.io/docs/>
- Firebase Cloud Messaging: <https://firebase.google.com/docs/cloud-messaging>
- OWASP API Security Top 10: <https://owasp.org/API-Security/>
- JWT Introduction: <https://jwt.io/introduction>
- REST API Design: <https://restfulapi.net/>

### B. Link mã nguồn

Toàn bộ mã nguồn của hệ thống được lưu trữ tại:

- **Repository**: `https://github.com/<ten-user>/<ten-repo>`
- **Cấu trúc chính**:
  - `food_app/` — mã nguồn ứng dụng Flutter
  - `server_app_foot/` — mã nguồn backend Spring Boot
  - `docs/` — tài liệu thiết kế (overview, ERD, API spec, screens, design, roadmap)

**Hướng dẫn chạy (tóm tắt)**:

1. Clone repository.
2. Khởi động hạ tầng:
   ```bash
   cd server_app_foot
   docker-compose up -d
   ```
3. Chạy backend Spring Boot (port 8080):
   ```bash
   ./mvnw spring-boot:run
   ```
4. Cấu hình `baseUrl` trong `food_app/lib/core/constants/` rồi chạy app:
   ```bash
   cd ../food_app
   flutter pub get
   flutter run
   ```

### C. Danh sách API endpoint chính (rút gọn)

**Bảng 5. Danh sách API endpoint chính**

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| POST | /api/auth/register | Đăng ký | – |
| POST | /api/auth/login | Đăng nhập | – |
| POST | /api/auth/refresh | Refresh token | Refresh JWT |
| GET | /api/restaurants | Danh sách NH | Optional |
| GET | /api/restaurants/{id} | Chi tiết NH | Optional |
| GET | /api/restaurants/{id}/menu | Menu của NH | Optional |
| GET | /api/cart | Lấy giỏ hiện tại | Customer |
| POST | /api/cart/items | Thêm món | Customer |
| POST | /api/orders | Tạo đơn | Customer |
| GET | /api/orders | Lịch sử đơn | Customer |
| POST | /api/orders/{id}/cancel | Huỷ đơn | Customer |
| POST | /api/payments/{orderId}/charge | Thanh toán | Customer |
| POST | /api/reviews | Đánh giá | Customer |
| GET | /api/admin/restaurants/{id}/orders | Đơn của NH | RAdmin |
| PATCH | /api/admin/orders/{id}/status | Cập nhật trạng thái | RAdmin |
| PATCH | /api/delivery/orders/{id}/status | Shipper cập nhật | DeliveryAgent |
| WS | /ws + STOMP `/topic/restaurants/{id}/new-orders` | NH lắng nghe đơn mới | RAdmin |
| WS | /ws + STOMP `/user/queue/order-status` | Customer lắng nghe đơn của mình | Customer |

---

*Hết báo cáo.*
