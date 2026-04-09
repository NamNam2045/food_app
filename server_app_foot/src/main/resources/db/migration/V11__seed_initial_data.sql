-- ============================================================
-- V11__seed_initial_data.sql
-- Seed data dành cho môi trường development/demo
--
-- Tài khoản test:
--   SYSTEM_ADMIN  : admin@foodrush.vn     / Admin@123
--   RESTAURANT_ADMIN: lan@restaurant.vn  / Owner@123
--   RESTAURANT_ADMIN: hoang@restaurant.vn/ Owner@123
--   CUSTOMER      : hoa@example.com      / Customer@123
--   CUSTOMER      : binh@example.com     / Customer@123
--   CUSTOMER      : hang@example.com     / Customer@123
--   DELIVERY_AGENT: tai@shipper.vn       / Shipper@123
--   DELIVERY_AGENT: mai@shipper.vn       / Shipper@123
-- ============================================================

-- ============================================================
-- 1. USERS
-- ============================================================
INSERT INTO users (id, email, phone_number, password_hash, first_name, last_name,
                   role, active, email_verified, created_at, updated_at)
VALUES
  (1,  'admin@foodrush.vn',   '0901000001',
   '$2b$10$ltlpOXi047jBz7xmrN7s5u7LfywAnB/imfqL5o0RHQbf3NXUiw.q2',
   'Văn', 'Admin', 'SYSTEM_ADMIN', TRUE, TRUE, NOW() - INTERVAL '90 days', NOW()),

  (2,  'lan@restaurant.vn',   '0902000002',
   '$2b$10$JcM0FM2hU3PuiF0/jMpiy.LOBnQfUCK/BectS98vS7IQo4zM0VCsi',
   'Thị', 'Lan', 'RESTAURANT_ADMIN', TRUE, TRUE, NOW() - INTERVAL '60 days', NOW()),

  (3,  'hoang@restaurant.vn', '0903000003',
   '$2b$10$JcM0FM2hU3PuiF0/jMpiy.LOBnQfUCK/BectS98vS7IQo4zM0VCsi',
   'Minh', 'Hoàng', 'RESTAURANT_ADMIN', TRUE, TRUE, NOW() - INTERVAL '55 days', NOW()),

  (4,  'hoa@example.com',     '0904000004',
   '$2b$10$XDgb3LjFXYuBqJwL7kO1HuOLXV3dFLneFn4lTIMrR5JY6VPZ6nxTG',
   'Thị', 'Hoa', 'CUSTOMER', TRUE, TRUE, NOW() - INTERVAL '30 days', NOW()),

  (5,  'binh@example.com',    '0905000005',
   '$2b$10$XDgb3LjFXYuBqJwL7kO1HuOLXV3dFLneFn4lTIMrR5JY6VPZ6nxTG',
   'Văn', 'Bình', 'CUSTOMER', TRUE, TRUE, NOW() - INTERVAL '25 days', NOW()),

  (6,  'hang@example.com',    '0906000006',
   '$2b$10$XDgb3LjFXYuBqJwL7kO1HuOLXV3dFLneFn4lTIMrR5JY6VPZ6nxTG',
   'Thu', 'Hằng', 'CUSTOMER', TRUE, TRUE, NOW() - INTERVAL '20 days', NOW()),

  (7,  'tai@shipper.vn',      '0907000007',
   '$2b$10$Yscpe0c9EMJFkHpnWPz6y.Xs.R/N/wsnMm2AQUQ.vlSY61iAQwcEm',
   'Văn', 'Tài', 'DELIVERY_AGENT', TRUE, TRUE, NOW() - INTERVAL '45 days', NOW()),

  (8,  'mai@shipper.vn',      '0908000008',
   '$2b$10$Yscpe0c9EMJFkHpnWPz6y.Xs.R/N/wsnMm2AQUQ.vlSY61iAQwcEm',
   'Thị', 'Mai', 'DELIVERY_AGENT', TRUE, TRUE, NOW() - INTERVAL '40 days', NOW());

-- ============================================================
-- 2. ADDRESSES
-- ============================================================
INSERT INTO addresses (id, user_id, label, street_line1, street_line2, city, state,
                       postal_code, country_code, latitude, longitude, default_address,
                       created_at, updated_at)
VALUES
  -- Khách hàng Hoa (Hà Nội)
  (1, 4, 'Nhà',    '25 Hoàng Diệu',    NULL, 'Hà Nội',           'Hà Nội',           '10000', 'VN', 21.02450, 105.84120, TRUE,  NOW() - INTERVAL '29 days', NOW()),
  (2, 4, 'Công ty','88 Láng Hạ',       NULL, 'Hà Nội',           'Hà Nội',           '10000', 'VN', 21.03120, 105.85610, FALSE, NOW() - INTERVAL '29 days', NOW()),
  -- Khách hàng Bình (TP HCM)
  (3, 5, 'Nhà',    '12 Nguyễn Trãi',   NULL, 'TP Hồ Chí Minh',   'TP Hồ Chí Minh',   '70000', 'VN', 10.77480, 106.69430, TRUE,  NOW() - INTERVAL '24 days', NOW()),
  (4, 5, 'Công ty','100 CMT8',         NULL, 'TP Hồ Chí Minh',   'TP Hồ Chí Minh',   '70000', 'VN', 10.78910, 106.70120, FALSE, NOW() - INTERVAL '24 days', NOW()),
  -- Khách hàng Hằng (TP HCM)
  (5, 6, 'Nhà',    '35 Đinh Tiên Hoàng',NULL,'TP Hồ Chí Minh',   'TP Hồ Chí Minh',   '70000', 'VN', 10.79200, 106.70500, TRUE,  NOW() - INTERVAL '19 days', NOW()),
  -- Admin
  (6, 1, 'Văn phòng','1 Tràng Tiền',   NULL, 'Hà Nội',           'Hà Nội',           '10000', 'VN', 21.02800, 105.85700, TRUE,  NOW() - INTERVAL '89 days', NOW());

-- ============================================================
-- 3. RESTAURANTS
-- ============================================================
INSERT INTO restaurants (id, owner_id, name, slug, description, cuisine_type,
                         logo_url, banner_url, phone, email,
                         street_address, city, latitude, longitude,
                         rating_avg, rating_count,
                         min_order_amount, delivery_fee, estimated_delivery_minutes,
                         active, open, created_at, updated_at)
VALUES
  (1, 2,
   'Phở Hà Nội Ngon',
   'pho-ha-noi-ngon',
   'Phở bò truyền thống Hà Nội, nước dùng ninh xương 12 tiếng, hương vị đậm đà khó quên.',
   'Ẩm thực Việt',
   'https://images.foodrush.vn/logos/pho-ha-noi-ngon.png',
   'https://images.foodrush.vn/banners/pho-ha-noi-ngon.jpg',
   '024-3825-6789', 'contact@pho-hanoi.vn',
   '47 Bát Đàn, Hoàn Kiếm', 'Hà Nội',
   21.02850, 105.85420,
   5.00, 1,
   50000.00, 15000.00, 30,
   TRUE, TRUE, NOW() - INTERVAL '60 days', NOW()),

  (2, 2,
   'Cơm Tấm Sài Gòn 36',
   'com-tam-sai-gon-36',
   'Cơm tấm đặc sản Sài Gòn, bì, chả, sườn nướng thơm lừng. Mở cửa từ 6 giờ sáng.',
   'Ẩm thực Việt',
   'https://images.foodrush.vn/logos/com-tam-sai-gon.png',
   'https://images.foodrush.vn/banners/com-tam-sai-gon.jpg',
   '028-3821-4567', 'contact@comtam36.vn',
   '36 Võ Văn Tần, Quận 3', 'TP Hồ Chí Minh',
   10.77690, 106.70090,
   3.50, 2,
   40000.00, 12000.00, 25,
   TRUE, TRUE, NOW() - INTERVAL '58 days', NOW()),

  (3, 3,
   'Sushi Sakura',
   'sushi-sakura',
   'Nhà hàng Nhật chính thống, nguyên liệu tươi nhập khẩu, đầu bếp được đào tạo tại Tokyo.',
   'Nhật Bản',
   'https://images.foodrush.vn/logos/sushi-sakura.png',
   'https://images.foodrush.vn/banners/sushi-sakura.jpg',
   '028-3924-8888', 'hello@sakura-sushi.vn',
   '12 Lê Lợi, Quận 1', 'TP Hồ Chí Minh',
   10.78200, 106.69800,
   5.00, 1,
   100000.00, 20000.00, 40,
   TRUE, TRUE, NOW() - INTERVAL '50 days', NOW()),

  (4, 3,
   'Pizza Express Hà Nội',
   'pizza-express-ha-noi',
   'Pizza Ý theo công thức truyền thống, lò nướng củi nhập từ Napoli. Free ship trong 5km.',
   'Ý',
   'https://images.foodrush.vn/logos/pizza-express.png',
   'https://images.foodrush.vn/banners/pizza-express.jpg',
   '024-3716-5555', 'info@pizza-express.vn',
   '88 Kim Mã, Ba Đình', 'Hà Nội',
   21.02270, 105.84120,
   4.00, 1,
   150000.00, 25000.00, 45,
   TRUE, FALSE, NOW() - INTERVAL '45 days', NOW());

-- ============================================================
-- 4. OPERATING HOURS (dayOfWeek: 0=CN, 1=T2, ..., 6=T7)
-- ============================================================
INSERT INTO operating_hours (id, restaurant_id, day_of_week, open_time, close_time, closed)
VALUES
  -- Phở Hà Nội Ngon (id=1) — mở cả tuần
  (1,  1, 0, '07:00', '21:00', FALSE),
  (2,  1, 1, '06:30', '22:00', FALSE),
  (3,  1, 2, '06:30', '22:00', FALSE),
  (4,  1, 3, '06:30', '22:00', FALSE),
  (5,  1, 4, '06:30', '22:00', FALSE),
  (6,  1, 5, '06:30', '22:00', FALSE),
  (7,  1, 6, '07:00', '22:00', FALSE),
  -- Cơm Tấm Sài Gòn 36 (id=2) — mở cả tuần
  (8,  2, 0, '06:00', '21:30', FALSE),
  (9,  2, 1, '06:00', '22:00', FALSE),
  (10, 2, 2, '06:00', '22:00', FALSE),
  (11, 2, 3, '06:00', '22:00', FALSE),
  (12, 2, 4, '06:00', '22:00', FALSE),
  (13, 2, 5, '06:00', '22:00', FALSE),
  (14, 2, 6, '06:00', '22:00', FALSE),
  -- Sushi Sakura (id=3) — nghỉ Chủ nhật
  (15, 3, 0, '11:00', '22:00', TRUE),
  (16, 3, 1, '11:00', '22:00', FALSE),
  (17, 3, 2, '11:00', '22:00', FALSE),
  (18, 3, 3, '11:00', '22:00', FALSE),
  (19, 3, 4, '11:00', '22:00', FALSE),
  (20, 3, 5, '11:00', '22:00', FALSE),
  (21, 3, 6, '11:00', '22:30', FALSE),
  -- Pizza Express Hà Nội (id=4)
  (22, 4, 0, '10:00', '23:00', FALSE),
  (23, 4, 1, '10:00', '23:00', FALSE),
  (24, 4, 2, '10:00', '23:00', FALSE),
  (25, 4, 3, '10:00', '23:00', FALSE),
  (26, 4, 4, '10:00', '23:00', FALSE),
  (27, 4, 5, '10:00', '23:30', FALSE),
  (28, 4, 6, '10:00', '23:30', FALSE);

-- ============================================================
-- 5. MENU CATEGORIES
-- ============================================================
INSERT INTO menu_categories (id, restaurant_id, name, description, display_order, active,
                              created_at, updated_at)
VALUES
  -- Phở Hà Nội Ngon
  (1,  1, 'Các loại phở',   'Phở bò, gà, hải sản truyền thống',             1, TRUE, NOW() - INTERVAL '60 days', NOW()),
  (2,  1, 'Món thêm',       'Bánh quẩy, giò, trứng và các món phụ',          2, TRUE, NOW() - INTERVAL '60 days', NOW()),
  (3,  1, 'Đồ uống',        'Nước giải khát kèm bữa phở',                   3, TRUE, NOW() - INTERVAL '60 days', NOW()),
  -- Cơm Tấm Sài Gòn 36
  (4,  2, 'Cơm Tấm',        'Các phần cơm tấm đặc sản',                     1, TRUE, NOW() - INTERVAL '58 days', NOW()),
  (5,  2, 'Món thêm',       'Trứng, chả, bì heo và các món phụ',             2, TRUE, NOW() - INTERVAL '58 days', NOW()),
  (6,  2, 'Đồ uống',        'Nước giải khát',                                3, TRUE, NOW() - INTERVAL '58 days', NOW()),
  -- Sushi Sakura
  (7,  3, 'Sushi & Sashimi','Sushi tươi và sashimi cao cấp',                 1, TRUE, NOW() - INTERVAL '50 days', NOW()),
  (8,  3, 'Ramen & Udon',   'Mì Nhật truyền thống, nước dùng đậm đà',        2, TRUE, NOW() - INTERVAL '50 days', NOW()),
  (9,  3, 'Đồ uống Nhật',   'Trà xanh, sake, nước quả Nhật Bản',             3, TRUE, NOW() - INTERVAL '50 days', NOW()),
  -- Pizza Express Hà Nội
  (10, 4, 'Pizza',          'Pizza lò nướng củi theo phong cách Ý',          1, TRUE, NOW() - INTERVAL '45 days', NOW()),
  (11, 4, 'Pasta',          'Mì Ý sốt truyền thống',                         2, TRUE, NOW() - INTERVAL '45 days', NOW()),
  (12, 4, 'Đồ uống',        'Nước giải khát và nước trái cây',               3, TRUE, NOW() - INTERVAL '45 days', NOW());

-- ============================================================
-- 6. MENU ITEMS
-- ============================================================
INSERT INTO menu_items (id, category_id, restaurant_id, name, description, price,
                        image_url, available, featured, calories,
                        preparation_time_minutes, display_order,
                        created_at, updated_at)
VALUES
  -- ---- Phở Hà Nội Ngon - Các loại phở (category 1) ----
  (1,  1, 1, 'Phở bò tái',       'Thịt bò tái hồng, nước dùng trong, hành lá thơm',          75000.00, 'https://images.foodrush.vn/items/pho-bo-tai.jpg',     TRUE,  TRUE,  380, 10, 1, NOW() - INTERVAL '60 days', NOW()),
  (2,  1, 1, 'Phở bò chín',      'Thịt bò nạm chín mềm, bánh phở dai, nước dùng đậm đà',     70000.00, 'https://images.foodrush.vn/items/pho-bo-chin.jpg',    TRUE,  FALSE, 360, 10, 2, NOW() - INTERVAL '60 days', NOW()),
  (3,  1, 1, 'Phở gà',           'Gà ta hầm nhừ, nước dùng thanh ngọt, ít béo',              65000.00, 'https://images.foodrush.vn/items/pho-ga.jpg',         TRUE,  FALSE, 310, 10, 3, NOW() - INTERVAL '60 days', NOW()),
  (4,  1, 1, 'Phở đặc biệt',     'Tái + nạm + gân + gầu, tô đầy đủ nhất, dành cho người ăn nhiều', 90000.00, 'https://images.foodrush.vn/items/pho-dac-biet.jpg', TRUE, TRUE, 520, 12, 4, NOW() - INTERVAL '60 days', NOW()),
  (5,  1, 1, 'Phở hải sản',      'Tôm, mực, cá viên, nước dùng hải sản trong vắt',           95000.00, 'https://images.foodrush.vn/items/pho-hai-san.jpg',    TRUE,  FALSE, 420, 12, 5, NOW() - INTERVAL '60 days', NOW()),
  -- ---- Phở Hà Nội Ngon - Món thêm (category 2) ----
  (6,  2, 1, 'Bánh quẩy',        'Bánh quẩy giòn vàng, chấm hoisin sauce',                   10000.00, 'https://images.foodrush.vn/items/banh-quay.jpg',      TRUE,  FALSE, 120, 3,  1, NOW() - INTERVAL '60 days', NOW()),
  (7,  2, 1, 'Trứng luộc',       'Trứng gà ta luộc chín vừa',                                 8000.00, 'https://images.foodrush.vn/items/trung-luoc.jpg',     TRUE,  FALSE,  78, 5,  2, NOW() - INTERVAL '60 days', NOW()),
  (8,  2, 1, 'Giò lụa',          'Giò lụa Hà Nội chính gốc, 1 lát dày',                     20000.00, 'https://images.foodrush.vn/items/gio-lua.jpg',         TRUE,  FALSE,  90, 3,  3, NOW() - INTERVAL '60 days', NOW()),
  (9,  2, 1, 'Hành trần thêm',   'Hành lá, ngò gai, giá đỗ thêm',                             5000.00, 'https://images.foodrush.vn/items/hanh-tran.jpg',      TRUE,  FALSE,  15, 2,  4, NOW() - INTERVAL '60 days', NOW()),
  -- ---- Phở Hà Nội Ngon - Đồ uống (category 3) ----
  (10, 3, 1, 'Nước lọc',         'Nước tinh khiết 500ml',                                    10000.00, 'https://images.foodrush.vn/items/nuoc-loc.jpg',        TRUE,  FALSE,   0, 1,  1, NOW() - INTERVAL '60 days', NOW()),
  (11, 3, 1, 'Nước ngọt lon',    'Coca-Cola / Pepsi / 7Up lon 330ml',                        15000.00, 'https://images.foodrush.vn/items/nuoc-ngot.jpg',       TRUE,  FALSE, 140, 1,  2, NOW() - INTERVAL '60 days', NOW()),
  (12, 3, 1, 'Trà đá',           'Trà mộc đá lạnh',                                           8000.00, 'https://images.foodrush.vn/items/tra-da.jpg',          TRUE,  FALSE,  10, 2,  3, NOW() - INTERVAL '60 days', NOW()),
  (13, 3, 1, 'Nước dừa tươi',    'Dừa xiêm tươi, ngọt mát',                                 25000.00, 'https://images.foodrush.vn/items/nuoc-dua.jpg',        TRUE,  FALSE,  60, 3,  4, NOW() - INTERVAL '60 days', NOW()),

  -- ---- Cơm Tấm Sài Gòn 36 - Cơm Tấm (category 4) ----
  (14, 4, 2, 'Cơm tấm sườn',     'Sườn nướng than hoa, cơm tấm dẻo, mỡ hành thơm',         45000.00, 'https://images.foodrush.vn/items/com-tam-suon.jpg',    TRUE,  FALSE, 560, 10, 1, NOW() - INTERVAL '58 days', NOW()),
  (15, 4, 2, 'Cơm tấm bì',       'Bì lợn trộn thính thơm, sả và gia vị truyền thống',       40000.00, 'https://images.foodrush.vn/items/com-tam-bi.jpg',      TRUE,  FALSE, 480, 10, 2, NOW() - INTERVAL '58 days', NOW()),
  (16, 4, 2, 'Cơm tấm chả',      'Chả trứng hấp mềm, béo ngậy, chan nước mắm ngon',         42000.00, 'https://images.foodrush.vn/items/com-tam-cha.jpg',     TRUE,  FALSE, 510, 10, 3, NOW() - INTERVAL '58 days', NOW()),
  (17, 4, 2, 'Cơm tấm sườn bì chả','Combo đầy đủ sườn + bì + chả, phần to cho bữa trưa ngon', 65000.00,'https://images.foodrush.vn/items/com-tam-sbc.jpg',TRUE, TRUE, 730, 12, 4, NOW() - INTERVAL '58 days', NOW()),
  (18, 4, 2, 'Cơm tấm đặc biệt', 'Sườn + bì + chả + trứng ốp la + soup cua, đặc sản nhà hàng', 75000.00,'https://images.foodrush.vn/items/com-tam-db.jpg', TRUE, TRUE, 850, 15, 5, NOW() - INTERVAL '58 days', NOW()),
  -- ---- Cơm Tấm Sài Gòn 36 - Món thêm (category 5) ----
  (19, 5, 2, 'Trứng ốp la',       'Trứng gà ta chiên vừa chín, lòng đào',                   10000.00, 'https://images.foodrush.vn/items/trung-op-la.jpg',    TRUE,  FALSE,  95, 5,  1, NOW() - INTERVAL '58 days', NOW()),
  (20, 5, 2, 'Chả trứng thêm',   'Một miếng chả trứng thêm',                               18000.00, 'https://images.foodrush.vn/items/cha-trung.jpg',       TRUE,  FALSE, 150, 5,  2, NOW() - INTERVAL '58 days', NOW()),
  (21, 5, 2, 'Bì heo thêm',      'Phần bì heo thêm trộn thính thơm',                       15000.00, 'https://images.foodrush.vn/items/bi-heo.jpg',          TRUE,  FALSE, 110, 3,  3, NOW() - INTERVAL '58 days', NOW()),
  (22, 5, 2, 'Soup cua',          'Soup cua trứng cút nồng ấm',                             20000.00, 'https://images.foodrush.vn/items/soup-cua.jpg',        TRUE,  FALSE, 130, 5,  4, NOW() - INTERVAL '58 days', NOW()),
  -- ---- Cơm Tấm Sài Gòn 36 - Đồ uống (category 6) ----
  (23, 6, 2, 'Trà đá',            'Trà đen đá lạnh miễn phí (phục vụ tại bàn), giao kèm',   5000.00, 'https://images.foodrush.vn/items/tra-da-ct.jpg',       TRUE,  FALSE,  10, 1,  1, NOW() - INTERVAL '58 days', NOW()),
  (24, 6, 2, 'Nước mía',          'Nước mía ép tươi thêm tắc',                              20000.00, 'https://images.foodrush.vn/items/nuoc-mia.jpg',        TRUE,  FALSE,  80, 3,  2, NOW() - INTERVAL '58 days', NOW()),
  (25, 6, 2, 'Sinh tố bơ',        'Sinh tố bơ sáp béo ngậy, thêm sữa đặc',                 35000.00, 'https://images.foodrush.vn/items/sinh-to-bo.jpg',      TRUE,  FALSE, 220, 5,  3, NOW() - INTERVAL '58 days', NOW()),
  (26, 6, 2, 'Nước ngọt lon',     'Coca-Cola / Pepsi lon 330ml',                            15000.00, 'https://images.foodrush.vn/items/nuoc-ngot-ct.jpg',    TRUE,  FALSE, 140, 1,  4, NOW() - INTERVAL '58 days', NOW()),

  -- ---- Sushi Sakura - Sushi & Sashimi (category 7) ----
  (27, 7, 3, 'Sushi cá hồi',      '2 miếng sushi cá hồi Na Uy tươi ngon, cơm nắm dấm Nhật',  80000.00,'https://images.foodrush.vn/items/sushi-salmon.jpg',  TRUE,  TRUE,  210, 10, 1, NOW() - INTERVAL '50 days', NOW()),
  (28, 7, 3, 'Sashimi cá ngừ',    '5 lát sashimi cá ngừ vây xanh nhập khẩu',               120000.00,'https://images.foodrush.vn/items/sashimi-tuna.jpg',   TRUE,  FALSE, 180, 10, 2, NOW() - INTERVAL '50 days', NOW()),
  (29, 7, 3, 'Sushi tôm',         '2 miếng sushi tôm luộc, wasabi tự nhiên',                70000.00,'https://images.foodrush.vn/items/sushi-shrimp.jpg',   TRUE,  FALSE, 160, 8,  3, NOW() - INTERVAL '50 days', NOW()),
  (30, 7, 3, 'California Roll',   '8 miếng crab stick, bơ, dưa leo bọc ngoài, trứng cá',    90000.00,'https://images.foodrush.vn/items/california-roll.jpg',TRUE,  TRUE,  280, 12, 4, NOW() - INTERVAL '50 days', NOW()),
  (31, 7, 3, 'Dragon Roll',       '8 miếng tôm tempura, cá hồi phủ trên, sốt eel',         150000.00,'https://images.foodrush.vn/items/dragon-roll.jpg',    TRUE,  TRUE,  350, 15, 5, NOW() - INTERVAL '50 days', NOW()),
  (32, 7, 3, 'Salmon Avocado Roll','8 miếng cá hồi + bơ, cuộn lá nori thơm',               130000.00,'https://images.foodrush.vn/items/salmon-avo.jpg',     TRUE,  FALSE, 320, 12, 6, NOW() - INTERVAL '50 days', NOW()),
  -- ---- Sushi Sakura - Ramen & Udon (category 8) ----
  (33, 8, 3, 'Ramen Tonkotsu',    'Nước dùng heo ninh 18 tiếng, chashu mềm, rong biển',    120000.00,'https://images.foodrush.vn/items/ramen-tonkotsu.jpg', TRUE,  TRUE,  620, 20, 1, NOW() - INTERVAL '50 days', NOW()),
  (34, 8, 3, 'Ramen Miso',        'Nước dùng miso đậm vị, bơ lạc rang thơm',              110000.00,'https://images.foodrush.vn/items/ramen-miso.jpg',     TRUE,  FALSE, 580, 20, 2, NOW() - INTERVAL '50 days', NOW()),
  (35, 8, 3, 'Udon Tôm Tempura',  'Mì udon thô với 3 tôm tempura giòn vàng, dashi udon',  130000.00,'https://images.foodrush.vn/items/udon-tempura.jpg',   TRUE,  FALSE, 650, 18, 3, NOW() - INTERVAL '50 days', NOW()),
  (36, 8, 3, 'Soba lạnh Zaru',    'Mì kiều mạch lạnh, chấm nước tsuyu thơm ngon',         100000.00,'https://images.foodrush.vn/items/soba-zaru.jpg',      TRUE,  FALSE, 390, 15, 4, NOW() - INTERVAL '50 days', NOW()),
  -- ---- Sushi Sakura - Đồ uống Nhật (category 9) ----
  (37, 9, 3, 'Trà xanh lạnh',     'Matcha hoặc sencha pha lạnh, không đường',               30000.00,'https://images.foodrush.vn/items/tra-xanh-lanh.jpg',  TRUE,  FALSE,   5, 3,  1, NOW() - INTERVAL '50 days', NOW()),
  (38, 9, 3, 'Yuzu Soda',         'Nước cam quýt Yuzu Nhật, soda nhẹ, tươi mát',            45000.00,'https://images.foodrush.vn/items/yuzu-soda.jpg',     TRUE,  FALSE,  80, 3,  2, NOW() - INTERVAL '50 days', NOW()),
  (39, 9, 3, 'Sake lạnh (100ml)', 'Sake Junmai Daiginjo premium, độ cồn 15%',               80000.00,'https://images.foodrush.vn/items/sake.jpg',           TRUE,  FALSE,  90, 3,  3, NOW() - INTERVAL '50 days', NOW()),
  (40, 9, 3, 'Matcha Latte',      'Matcha pha với oat milk, ít ngọt theo yêu cầu',          55000.00,'https://images.foodrush.vn/items/matcha-latte.jpg',   TRUE,  TRUE,  120, 5,  4, NOW() - INTERVAL '50 days', NOW()),

  -- ---- Pizza Express Hà Nội - Pizza (category 10) ----
  (41,10, 4, 'Margherita',        'Cà chua San Marzano, mozzarella tươi, lá basil Ý',       180000.00,'https://images.foodrush.vn/items/pizza-margherita.jpg',TRUE, FALSE, 780, 20, 1, NOW() - INTERVAL '45 days', NOW()),
  (42,10, 4, 'Pepperoni',         'Xúc xích pepperoni Mỹ, phô mai mozzarella chảy đều',     220000.00,'https://images.foodrush.vn/items/pizza-pepperoni.jpg',TRUE, TRUE,  950, 20, 2, NOW() - INTERVAL '45 days', NOW()),
  (43,10, 4, 'Hawaiian',          'Dứa tươi + thịt xông khói + phô mai mozzarella',         200000.00,'https://images.foodrush.vn/items/pizza-hawaiian.jpg', TRUE, FALSE, 870, 20, 3, NOW() - INTERVAL '45 days', NOW()),
  (44,10, 4, 'BBQ Chicken',       'Ức gà nướng BBQ, hành tây, ớt chuông, sốt BBQ đặc trưng',240000.00,'https://images.foodrush.vn/items/pizza-bbq.jpg',    TRUE, TRUE, 1020, 22, 4, NOW() - INTERVAL '45 days', NOW()),
  (45,10, 4, 'Four Cheese',       'Mozzarella, Gorgonzola, Parmesan, Provolone — 4 loại phô mai', 230000.00,'https://images.foodrush.vn/items/pizza-4cheese.jpg',TRUE,FALSE,980,22, 5, NOW() - INTERVAL '45 days', NOW()),
  -- ---- Pizza Express Hà Nội - Pasta (category 11) ----
  (46,11, 4, 'Spaghetti Bolognese','Mì spaghetti sốt thịt bò xay truyền thống Bologna',     160000.00,'https://images.foodrush.vn/items/spaghetti-bolo.jpg',TRUE, FALSE, 720, 18, 1, NOW() - INTERVAL '45 days', NOW()),
  (47,11, 4, 'Fettuccine Alfredo', 'Mì dẹp sốt kem phô mai trắng, thịt gà thêm',           180000.00,'https://images.foodrush.vn/items/fettuccine.jpg',    TRUE, TRUE,  840, 18, 2, NOW() - INTERVAL '45 days', NOW()),
  (48,11, 4, 'Penne Arrabbiata',  'Mì ống sốt cà chua cay, tỏi, ớt đỏ tươi',              150000.00,'https://images.foodrush.vn/items/penne-arrabbiata.jpg',TRUE,FALSE,680, 15, 3, NOW() - INTERVAL '45 days', NOW()),
  (49,11, 4, 'Carbonara',         'Trứng lòng đỏ, guanciale, Pecorino Romano, tiêu đen',   190000.00,'https://images.foodrush.vn/items/carbonara.jpg',      TRUE, TRUE,  890, 18, 4, NOW() - INTERVAL '45 days', NOW()),
  -- ---- Pizza Express Hà Nội - Đồ uống (category 12) ----
  (50,12, 4, 'Coca Cola',         'Lon 330ml lạnh',                                          30000.00,'https://images.foodrush.vn/items/coca-cola.jpg',      TRUE,  FALSE, 140, 1,  1, NOW() - INTERVAL '45 days', NOW()),
  (51,12, 4, 'Fanta cam',         'Lon 330ml lạnh',                                          30000.00,'https://images.foodrush.vn/items/fanta.jpg',          TRUE,  FALSE, 160, 1,  2, NOW() - INTERVAL '45 days', NOW()),
  (52,12, 4, 'Sprite',            'Lon 330ml lạnh',                                          30000.00,'https://images.foodrush.vn/items/sprite.jpg',         TRUE,  FALSE, 140, 1,  3, NOW() - INTERVAL '45 days', NOW()),
  (53,12, 4, 'Nước khoáng',       'Chai 500ml',                                              20000.00,'https://images.foodrush.vn/items/nuoc-khoang.jpg',    TRUE,  FALSE,   0, 1,  4, NOW() - INTERVAL '45 days', NOW());

-- ============================================================
-- 7. ORDERS
-- Subtotal / deliveryFee / discountAmount / totalAmount khớp
-- với items bên dưới
-- ============================================================
INSERT INTO orders (id, order_number, user_id, restaurant_id, delivery_agent_id,
                    status, delivery_address_snapshot,
                    subtotal, delivery_fee, discount_amount, total_amount,
                    special_instructions,
                    estimated_delivery_at, delivered_at, cancelled_at, cancellation_reason,
                    created_at, updated_at)
VALUES
  -- Order 1: user=Hoa, nhà hàng Phở, DELIVERED, 8 ngày trước
  (1,  'FR-20260401-00001', 4, 1, 7, 'DELIVERED',
   '{"label":"Nhà","streetLine1":"25 Hoàng Diệu","streetLine2":"","city":"Hà Nội","state":"Hà Nội","postalCode":"10000"}',
   170000.00, 15000.00, 0.00, 185000.00,
   NULL,
   NOW() - INTERVAL '7 days 23 hours', NOW() - INTERVAL '7 days 22 hours 10 minutes', NULL, NULL,
   NOW() - INTERVAL '8 days', NOW() - INTERVAL '7 days 22 hours 10 minutes'),

  -- Order 2: user=Bình, nhà hàng Cơm Tấm, DELIVERED, 7 ngày trước
  (2,  'FR-20260402-00001', 5, 2, 8, 'DELIVERED',
   '{"label":"Nhà","streetLine1":"12 Nguyễn Trãi","streetLine2":"","city":"TP Hồ Chí Minh","state":"TP Hồ Chí Minh","postalCode":"70000"}',
   110000.00, 12000.00, 0.00, 122000.00,
   'Ít mỡ hành, thêm nước mắm bên',
   NOW() - INTERVAL '6 days 23 hours', NOW() - INTERVAL '6 days 22 hours 30 minutes', NULL, NULL,
   NOW() - INTERVAL '7 days', NOW() - INTERVAL '6 days 22 hours 30 minutes'),

  -- Order 3: user=Hoa, Pizza Express, DELIVERED, dùng FIRST10 (discount 30k)
  (3,  'FR-20260403-00001', 4, 4, 7, 'DELIVERED',
   '{"label":"Nhà","streetLine1":"25 Hoàng Diệu","streetLine2":"","city":"Hà Nội","state":"Hà Nội","postalCode":"10000"}',
   460000.00, 25000.00, 30000.00, 455000.00,
   NULL,
   NOW() - INTERVAL '5 days 23 hours', NOW() - INTERVAL '5 days 22 hours', NULL, NULL,
   NOW() - INTERVAL '6 days', NOW() - INTERVAL '5 days 22 hours'),

  -- Order 4: user=Hằng, Sushi Sakura, DELIVERED, 5 ngày trước
  (4,  'FR-20260404-00001', 6, 3, 8, 'DELIVERED',
   '{"label":"Nhà","streetLine1":"35 Đinh Tiên Hoàng","streetLine2":"","city":"TP Hồ Chí Minh","state":"TP Hồ Chí Minh","postalCode":"70000"}',
   280000.00, 20000.00, 0.00, 300000.00,
   NULL,
   NOW() - INTERVAL '4 days 23 hours', NOW() - INTERVAL '4 days 22 hours', NULL, NULL,
   NOW() - INTERVAL '5 days', NOW() - INTERVAL '4 days 22 hours'),

  -- Order 5: user=Bình, Sushi Sakura, CONFIRMED
  (5,  'FR-20260407-00001', 5, 3, NULL, 'CONFIRMED',
   '{"label":"Nhà","streetLine1":"12 Nguyễn Trãi","streetLine2":"","city":"TP Hồ Chí Minh","state":"TP Hồ Chí Minh","postalCode":"70000"}',
   210000.00, 20000.00, 0.00, 230000.00,
   NULL,
   NOW() + INTERVAL '35 minutes', NULL, NULL, NULL,
   NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),

  -- Order 6: user=Hoa, Phở Hà Nội, PREPARING
  (6,  'FR-20260408-00001', 4, 1, NULL, 'PREPARING',
   '{"label":"Công ty","streetLine1":"88 Láng Hạ","streetLine2":"","city":"Hà Nội","state":"Hà Nội","postalCode":"10000"}',
   110000.00, 15000.00, 0.00, 125000.00,
   'Ít hành',
   NOW() + INTERVAL '25 minutes', NULL, NULL, NULL,
   NOW() - INTERVAL '1 hour', NOW() - INTERVAL '45 minutes'),

  -- Order 7: user=Hằng, Cơm Tấm, PENDING
  (7,  'FR-20260409-00001', 6, 2, NULL, 'PENDING',
   '{"label":"Nhà","streetLine1":"35 Đinh Tiên Hoàng","streetLine2":"","city":"TP Hồ Chí Minh","state":"TP Hồ Chí Minh","postalCode":"70000"}',
   160000.00, 12000.00, 0.00, 172000.00,
   NULL,
   NOW() + INTERVAL '30 minutes', NULL, NULL, NULL,
   NOW() - INTERVAL '10 minutes', NOW() - INTERVAL '10 minutes'),

  -- Order 8: user=Bình, Cơm Tấm, DELIVERED, 4 ngày trước
  (8,  'FR-20260405-00001', 5, 2, 7, 'DELIVERED',
   '{"label":"Công ty","streetLine1":"100 CMT8","streetLine2":"","city":"TP Hồ Chí Minh","state":"TP Hồ Chí Minh","postalCode":"70000"}',
   122000.00, 12000.00, 0.00, 134000.00,
   NULL,
   NOW() - INTERVAL '3 days 23 hours', NOW() - INTERVAL '3 days 22 hours 45 minutes', NULL, NULL,
   NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days 22 hours 45 minutes'),

  -- Order 9: user=Hoa, Pizza Express, CANCELLED, 3 ngày trước
  (9,  'FR-20260406-00001', 4, 4, NULL, 'CANCELLED',
   '{"label":"Nhà","streetLine1":"25 Hoàng Diệu","streetLine2":"","city":"Hà Nội","state":"Hà Nội","postalCode":"10000"}',
   230000.00, 25000.00, 0.00, 255000.00,
   NULL,
   NULL, NULL, NOW() - INTERVAL '3 days', 'Đặt nhầm, muốn đổi món khác',
   NOW() - INTERVAL '3 days 30 minutes', NOW() - INTERVAL '3 days'),

  -- Order 10: user=Hằng, Sushi Sakura, ON_THE_WAY (đang giao)
  (10, 'FR-20260409-00002', 6, 3, 8, 'ON_THE_WAY',
   '{"label":"Nhà","streetLine1":"35 Đinh Tiên Hoàng","streetLine2":"","city":"TP Hồ Chí Minh","state":"TP Hồ Chí Minh","postalCode":"70000"}',
   290000.00, 20000.00, 0.00, 310000.00,
   'Gọi trước 5 phút khi tới',
   NOW() + INTERVAL '15 minutes', NULL, NULL, NULL,
   NOW() - INTERVAL '55 minutes', NOW() - INTERVAL '15 minutes');

-- ============================================================
-- 8. ORDER ITEMS
-- ============================================================
INSERT INTO order_items (id, order_id, menu_item_id, menu_item_name,
                         quantity, unit_price, subtotal, special_instructions)
VALUES
  -- Order 1: Phở bò tái ×2 + Nước lọc ×2
  (1,  1,  1, 'Phở bò tái',        2, 75000.00, 150000.00, NULL),
  (2,  1, 10, 'Nước lọc',          2, 10000.00,  20000.00, NULL),
  -- Order 2: Cơm tấm sườn ×1 + Cơm tấm sườn bì chả ×1
  (3,  2, 14, 'Cơm tấm sườn',      1, 45000.00,  45000.00, NULL),
  (4,  2, 17, 'Cơm tấm sườn bì chả',1, 65000.00, 65000.00, 'Thêm nước mắm riêng'),
  -- Order 3: Margherita ×1 + Pepperoni ×1 + Coca Cola ×2
  (5,  3, 41, 'Margherita',         1,180000.00, 180000.00, NULL),
  (6,  3, 42, 'Pepperoni',          1,220000.00, 220000.00, NULL),
  (7,  3, 50, 'Coca Cola',          2, 30000.00,  60000.00, NULL),
  -- Order 4: Sushi cá hồi ×2 + Ramen Tonkotsu ×1
  (8,  4, 27, 'Sushi cá hồi',       2, 80000.00, 160000.00, NULL),
  (9,  4, 33, 'Ramen Tonkotsu',     1,120000.00, 120000.00, 'Ít cay'),
  -- Order 5: Dragon Roll ×1 + Trà xanh lạnh ×2
  (10, 5, 31, 'Dragon Roll',        1,150000.00, 150000.00, NULL),
  (11, 5, 37, 'Trà xanh lạnh',      2, 30000.00,  60000.00, NULL),
  -- Order 6: Phở đặc biệt ×1 + Bánh quẩy ×2
  (12, 6,  4, 'Phở đặc biệt',       1, 90000.00,  90000.00, 'Ít hành'),
  (13, 6,  6, 'Bánh quẩy',          2, 10000.00,  20000.00, NULL),
  -- Order 7: Cơm tấm đặc biệt ×2 + Trà đá ×2
  (14, 7, 18, 'Cơm tấm đặc biệt',  2, 75000.00, 150000.00, NULL),
  (15, 7, 23, 'Trà đá',             2,  5000.00,  10000.00, NULL),
  -- Order 8: Cơm tấm bì ×1 + Cơm tấm chả ×1 + Nước mía ×2
  (16, 8, 15, 'Cơm tấm bì',         1, 40000.00,  40000.00, NULL),
  (17, 8, 16, 'Cơm tấm chả',        1, 42000.00,  42000.00, NULL),
  (18, 8, 24, 'Nước mía',           2, 20000.00,  40000.00, NULL),
  -- Order 9: Four Cheese ×1 (đã huỷ)
  (19, 9, 45, 'Four Cheese',         1,230000.00, 230000.00, NULL),
  -- Order 10: California Roll ×2 + Matcha Latte ×2
  (20,10, 30, 'California Roll',     2, 90000.00, 180000.00, NULL),
  (21,10, 40, 'Matcha Latte',        2, 55000.00, 110000.00, 'Ít ngọt');

-- ============================================================
-- 9. ORDER STATUS HISTORY
-- ============================================================
INSERT INTO order_status_history (id, order_id, status, notes, changed_by_user_id, created_at)
VALUES
  -- Order 1 (DELIVERED): 7 bước
  (1,  1, 'PENDING',          'Đơn hàng được tạo',          4, NOW() - INTERVAL '8 days'),
  (2,  1, 'CONFIRMED',        'Nhà hàng xác nhận',          2, NOW() - INTERVAL '8 days' + INTERVAL '5 minutes'),
  (3,  1, 'PREPARING',        'Đang nấu',                   2, NOW() - INTERVAL '8 days' + INTERVAL '8 minutes'),
  (4,  1, 'READY_FOR_PICKUP', 'Sẵn sàng lấy hàng',          2, NOW() - INTERVAL '8 days' + INTERVAL '20 minutes'),
  (5,  1, 'PICKED_UP',        'Shipper đã lấy',             7, NOW() - INTERVAL '8 days' + INTERVAL '25 minutes'),
  (6,  1, 'ON_THE_WAY',       'Đang giao',                  7, NOW() - INTERVAL '8 days' + INTERVAL '27 minutes'),
  (7,  1, 'DELIVERED',        'Giao thành công',            7, NOW() - INTERVAL '7 days 22 hours 10 minutes'),

  -- Order 2 (DELIVERED): 7 bước
  (8,  2, 'PENDING',          'Đơn hàng được tạo',          5, NOW() - INTERVAL '7 days'),
  (9,  2, 'CONFIRMED',        'Nhà hàng xác nhận',          2, NOW() - INTERVAL '7 days' + INTERVAL '4 minutes'),
  (10, 2, 'PREPARING',        'Đang chuẩn bị',              2, NOW() - INTERVAL '7 days' + INTERVAL '7 minutes'),
  (11, 2, 'READY_FOR_PICKUP', 'Sẵn sàng',                   2, NOW() - INTERVAL '7 days' + INTERVAL '15 minutes'),
  (12, 2, 'PICKED_UP',        'Shipper lấy hàng',           8, NOW() - INTERVAL '7 days' + INTERVAL '20 minutes'),
  (13, 2, 'ON_THE_WAY',       'Đang trên đường',            8, NOW() - INTERVAL '7 days' + INTERVAL '22 minutes'),
  (14, 2, 'DELIVERED',        'Đã giao',                    8, NOW() - INTERVAL '6 days 22 hours 30 minutes'),

  -- Order 3 (DELIVERED): 7 bước
  (15, 3, 'PENDING',          'Đơn hàng được tạo',          4, NOW() - INTERVAL '6 days'),
  (16, 3, 'CONFIRMED',        'Xác nhận',                   3, NOW() - INTERVAL '6 days' + INTERVAL '6 minutes'),
  (17, 3, 'PREPARING',        'Đang nướng pizza',           3, NOW() - INTERVAL '6 days' + INTERVAL '8 minutes'),
  (18, 3, 'READY_FOR_PICKUP', 'Sẵn sàng',                   3, NOW() - INTERVAL '6 days' + INTERVAL '30 minutes'),
  (19, 3, 'PICKED_UP',        'Shipper lấy',                7, NOW() - INTERVAL '6 days' + INTERVAL '38 minutes'),
  (20, 3, 'ON_THE_WAY',       'Đang giao',                  7, NOW() - INTERVAL '6 days' + INTERVAL '40 minutes'),
  (21, 3, 'DELIVERED',        'Giao thành công',            7, NOW() - INTERVAL '5 days 22 hours'),

  -- Order 4 (DELIVERED): 7 bước
  (22, 4, 'PENDING',          'Đơn hàng được tạo',          6, NOW() - INTERVAL '5 days'),
  (23, 4, 'CONFIRMED',        'Xác nhận đơn',               3, NOW() - INTERVAL '5 days' + INTERVAL '5 minutes'),
  (24, 4, 'PREPARING',        'Đang làm sushi',             3, NOW() - INTERVAL '5 days' + INTERVAL '8 minutes'),
  (25, 4, 'READY_FOR_PICKUP', 'Sẵn sàng giao',              3, NOW() - INTERVAL '5 days' + INTERVAL '25 minutes'),
  (26, 4, 'PICKED_UP',        'Shipper lấy',                8, NOW() - INTERVAL '5 days' + INTERVAL '33 minutes'),
  (27, 4, 'ON_THE_WAY',       'Đang giao',                  8, NOW() - INTERVAL '5 days' + INTERVAL '35 minutes'),
  (28, 4, 'DELIVERED',        'Đã giao xong',               8, NOW() - INTERVAL '4 days 22 hours'),

  -- Order 5 (CONFIRMED): 2 bước
  (29, 5, 'PENDING',          'Đơn hàng được tạo',          5, NOW() - INTERVAL '2 days'),
  (30, 5, 'CONFIRMED',        'Nhà hàng vừa xác nhận',      3, NOW() - INTERVAL '2 days' + INTERVAL '6 minutes'),

  -- Order 6 (PREPARING): 3 bước
  (31, 6, 'PENDING',          'Đơn hàng được tạo',          4, NOW() - INTERVAL '1 hour'),
  (32, 6, 'CONFIRMED',        'Đã xác nhận',                2, NOW() - INTERVAL '55 minutes'),
  (33, 6, 'PREPARING',        'Đang nấu phở',               2, NOW() - INTERVAL '50 minutes'),

  -- Order 7 (PENDING): 1 bước
  (34, 7, 'PENDING',          'Đơn hàng được tạo',          6, NOW() - INTERVAL '10 minutes'),

  -- Order 8 (DELIVERED): 7 bước
  (35, 8, 'PENDING',          'Đơn hàng được tạo',          5, NOW() - INTERVAL '4 days'),
  (36, 8, 'CONFIRMED',        'Xác nhận',                   2, NOW() - INTERVAL '4 days' + INTERVAL '4 minutes'),
  (37, 8, 'PREPARING',        'Chuẩn bị cơm tấm',           2, NOW() - INTERVAL '4 days' + INTERVAL '7 minutes'),
  (38, 8, 'READY_FOR_PICKUP', 'Xong rồi',                   2, NOW() - INTERVAL '4 days' + INTERVAL '18 minutes'),
  (39, 8, 'PICKED_UP',        'Shipper lấy',                7, NOW() - INTERVAL '4 days' + INTERVAL '24 minutes'),
  (40, 8, 'ON_THE_WAY',       'Đang giao',                  7, NOW() - INTERVAL '4 days' + INTERVAL '26 minutes'),
  (41, 8, 'DELIVERED',        'Giao xong',                  7, NOW() - INTERVAL '3 days 22 hours 45 minutes'),

  -- Order 9 (CANCELLED): 2 bước
  (42, 9, 'PENDING',          'Đơn hàng được tạo',          4, NOW() - INTERVAL '3 days 30 minutes'),
  (43, 9, 'CANCELLED',        'Khách huỷ: Đặt nhầm, muốn đổi món khác', 4, NOW() - INTERVAL '3 days'),

  -- Order 10 (ON_THE_WAY): 6 bước
  (44,10, 'PENDING',          'Đơn hàng được tạo',          6, NOW() - INTERVAL '55 minutes'),
  (45,10, 'CONFIRMED',        'Nhà hàng xác nhận',          3, NOW() - INTERVAL '50 minutes'),
  (46,10, 'PREPARING',        'Đang làm sushi',             3, NOW() - INTERVAL '47 minutes'),
  (47,10, 'READY_FOR_PICKUP', 'Sẵn sàng giao',              3, NOW() - INTERVAL '25 minutes'),
  (48,10, 'PICKED_UP',        'Shipper lấy hàng',           8, NOW() - INTERVAL '20 minutes'),
  (49,10, 'ON_THE_WAY',       'Đang trên đường giao',       8, NOW() - INTERVAL '15 minutes');

-- ============================================================
-- 10. PAYMENTS
-- ============================================================
INSERT INTO payments (id, order_id, payment_method, payment_status,
                      amount, transaction_id, paid_at, created_at, updated_at)
VALUES
  (1,  1, 'COD',         'PAID',    185000.00, NULL,                         NOW() - INTERVAL '7 days 22 hours 10 minutes', NOW() - INTERVAL '8 days', NOW()),
  (2,  2, 'MOMO',        'PAID',    122000.00, 'MOMO20260402-A1B2C3D4',      NOW() - INTERVAL '6 days 22 hours 30 minutes', NOW() - INTERVAL '7 days', NOW()),
  (3,  3, 'CREDIT_CARD', 'PAID',    455000.00, 'STRIPE-PI-3abc456789xyz',    NOW() - INTERVAL '5 days 22 hours',            NOW() - INTERVAL '6 days', NOW()),
  (4,  4, 'ZALOPAY',     'PAID',    300000.00, 'ZALO20260404-E5F6G7H8',      NOW() - INTERVAL '4 days 22 hours',            NOW() - INTERVAL '5 days', NOW()),
  (5,  5, 'MOMO',        'PENDING', 230000.00, NULL,                         NULL,                                           NOW() - INTERVAL '2 days', NOW()),
  (6,  6, 'COD',         'PENDING', 125000.00, NULL,                         NULL,                                           NOW() - INTERVAL '1 hour', NOW()),
  (7,  7, 'COD',         'PENDING', 172000.00, NULL,                         NULL,                                           NOW() - INTERVAL '10 minutes', NOW()),
  (8,  8, 'ZALOPAY',     'PAID',    134000.00, 'ZALO20260405-I9J0K1L2',      NOW() - INTERVAL '3 days 22 hours 45 minutes', NOW() - INTERVAL '4 days', NOW()),
  (9,  9, 'COD',         'PENDING', 255000.00, NULL,                         NULL,                                           NOW() - INTERVAL '3 days 30 minutes', NOW()),
  (10,10, 'CREDIT_CARD', 'PENDING', 310000.00, NULL,                         NULL,                                           NOW() - INTERVAL '55 minutes', NOW());

-- ============================================================
-- 11. REVIEWS (chỉ cho các đơn đã DELIVERED)
-- ============================================================
INSERT INTO reviews (id, order_id, user_id, restaurant_id, rating, comment,
                     visible, created_at, updated_at)
VALUES
  (1, 1, 4, 1, 5,
   'Phở ngon tuyệt vời! Nước dùng đậm đà, thịt mềm. Giao hàng rất nhanh, đúng giờ. Sẽ order lại!',
   TRUE, NOW() - INTERVAL '7 days 20 hours', NOW()),

  (2, 2, 5, 2, 4,
   'Cơm tấm ngon, đúng vị Sài Gòn. Sườn nướng thơm, ăn cùng bì rất hợp. Trừ 1 sao vì hơi muộn 10 phút.',
   TRUE, NOW() - INTERVAL '6 days 20 hours', NOW()),

  (3, 3, 4, 4, 4,
   'Pizza Pepperoni giòn, phô mai chảy đều rất thích. Margherita thì tròn vị. Sẽ comeback!',
   TRUE, NOW() - INTERVAL '5 days 20 hours', NOW()),

  (4, 4, 6, 3, 5,
   'Sushi cá hồi cực kỳ tươi, Ramen tonkotsu sánh đặc đúng chuẩn quán Nhật mình từng ăn ở Osaka. 5/5!',
   TRUE, NOW() - INTERVAL '4 days 20 hours', NOW()),

  (5, 8, 5, 2, 3,
   'Cơm tấm ổn, nhưng lần này cơm hơi khô hơn bình thường. Nước mía thì ngon. Hy vọng lần sau sẽ tốt hơn.',
   TRUE, NOW() - INTERVAL '3 days 20 hours', NOW());

-- ============================================================
-- 12. CẬP NHẬT PROMO CODE đã dùng (Order 3 dùng FIRST10)
-- ============================================================
UPDATE promo_codes SET used_count = 1 WHERE code = 'FIRST10';

-- ============================================================
-- 13. RESET SEQUENCES (để INSERT tiếp không bị conflict)
-- ============================================================
SELECT setval('users_id_seq',                (SELECT MAX(id) FROM users));
SELECT setval('addresses_id_seq',            (SELECT MAX(id) FROM addresses));
SELECT setval('restaurants_id_seq',          (SELECT MAX(id) FROM restaurants));
SELECT setval('operating_hours_id_seq',      (SELECT MAX(id) FROM operating_hours));
SELECT setval('menu_categories_id_seq',      (SELECT MAX(id) FROM menu_categories));
SELECT setval('menu_items_id_seq',           (SELECT MAX(id) FROM menu_items));
SELECT setval('orders_id_seq',               (SELECT MAX(id) FROM orders));
SELECT setval('order_items_id_seq',          (SELECT MAX(id) FROM order_items));
SELECT setval('order_status_history_id_seq', (SELECT MAX(id) FROM order_status_history));
SELECT setval('payments_id_seq',             (SELECT MAX(id) FROM payments));
SELECT setval('reviews_id_seq',              (SELECT MAX(id) FROM reviews));
SELECT setval('promo_codes_id_seq',          (SELECT MAX(id) FROM promo_codes));
