-- ============================================================
-- V12__cleanup_seed_data.sql
--
-- Mục đích: chỉnh lại dữ liệu seed cho các môi trường đã chạy V11
-- bản cũ. Hai vấn đề được sửa:
--
--   1. Image URL placeholder trỏ đến domain ảo (https://images.foodrush.vn/...)
--      gây broken images trên UI → set NULL toàn bộ. Owner/admin sẽ
--      upload ảnh thật qua trang quản lý.
--
--   2. Hai owner (lan, hoang) đang sở hữu mỗi người 2 nhà hàng nhưng
--      `OwnerService.getRestaurantByOwner` được thiết kế cho 1-1 →
--      chỉ thấy 1 nhà hàng đầu tiên trên dashboard. Thêm 2 owner mới
--      (tu, phong) và chia lại sao cho mỗi nhà hàng có owner riêng.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Clear ảnh trỏ về domain ảo
-- ------------------------------------------------------------
UPDATE restaurants
   SET logo_url   = NULL
 WHERE logo_url   LIKE 'https://images.foodrush.vn/%';

UPDATE restaurants
   SET banner_url = NULL
 WHERE banner_url LIKE 'https://images.foodrush.vn/%';

UPDATE menu_items
   SET image_url  = NULL
 WHERE image_url  LIKE 'https://images.foodrush.vn/%';

-- ------------------------------------------------------------
-- 2. Bổ sung 2 owner mới (chỉ chèn nếu chưa tồn tại)
-- ------------------------------------------------------------
INSERT INTO users (email, phone_number, password_hash, first_name, last_name,
                   role, active, email_verified, created_at, updated_at)
SELECT 'tu@restaurant.vn', '0909000009',
       '$2b$10$JcM0FM2hU3PuiF0/jMpiy.LOBnQfUCK/BectS98vS7IQo4zM0VCsi',
       'Văn', 'Tú', 'RESTAURANT_ADMIN', TRUE, TRUE, NOW(), NOW()
 WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'tu@restaurant.vn');

INSERT INTO users (email, phone_number, password_hash, first_name, last_name,
                   role, active, email_verified, created_at, updated_at)
SELECT 'phong@restaurant.vn', '0910000010',
       '$2b$10$JcM0FM2hU3PuiF0/jMpiy.LOBnQfUCK/BectS98vS7IQo4zM0VCsi',
       'Đức', 'Phong', 'RESTAURANT_ADMIN', TRUE, TRUE, NOW(), NOW()
 WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'phong@restaurant.vn');

-- ------------------------------------------------------------
-- 3. Gán lại owner 1-1 cho từng nhà hàng (theo slug để idempotent)
--    Phở Hà Nội Ngon       ← lan
--    Sushi Sakura          ← hoang
--    Cơm Tấm Sài Gòn 36    ← tu     (chuyển từ lan)
--    Pizza Express Hà Nội  ← phong  (chuyển từ hoang)
-- ------------------------------------------------------------
UPDATE restaurants
   SET owner_id = (SELECT id FROM users WHERE email = 'tu@restaurant.vn')
 WHERE slug = 'com-tam-sai-gon-36';

UPDATE restaurants
   SET owner_id = (SELECT id FROM users WHERE email = 'phong@restaurant.vn')
 WHERE slug = 'pizza-express-ha-noi';

-- ------------------------------------------------------------
-- 4. Đồng bộ lại sequence users_id_seq
-- ------------------------------------------------------------
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));
