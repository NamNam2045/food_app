-- Promo Codes
CREATE TABLE promo_codes (
    id                  BIGSERIAL PRIMARY KEY,
    code                VARCHAR(30) NOT NULL UNIQUE,
    discount_type       VARCHAR(20) NOT NULL,   -- PERCENTAGE | FIXED
    discount_value      DECIMAL(10, 2) NOT NULL,
    min_order_amount    DECIMAL(12, 2),
    max_discount_amount DECIMAL(12, 2),
    start_date          TIMESTAMPTZ NOT NULL,
    end_date            TIMESTAMPTZ NOT NULL,
    usage_limit         INTEGER NOT NULL DEFAULT 9999,
    used_count          INTEGER NOT NULL DEFAULT 0,
    active              BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_promo_codes_code ON promo_codes(code, active);

-- Seed dữ liệu mẫu
INSERT INTO promo_codes (code, discount_type, discount_value, min_order_amount, max_discount_amount, start_date, end_date, usage_limit)
VALUES
  ('FIRST10',  'PERCENTAGE', 10, 50000,  30000, NOW(), NOW() + INTERVAL '365 days', 9999),
  ('SAVE20K',  'FIXED',      20000, 100000, NULL, NOW(), NOW() + INTERVAL '30 days', 500),
  ('WELCOME',  'PERCENTAGE', 15, 80000,  50000, NOW(), NOW() + INTERVAL '90 days', 1000);
