-- Cart and Cart Items
CREATE TABLE carts (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    restaurant_id   BIGINT REFERENCES restaurants(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE cart_items (
    id                      BIGSERIAL PRIMARY KEY,
    cart_id                 BIGINT NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    menu_item_id            BIGINT NOT NULL REFERENCES menu_items(id),
    quantity                INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price              DECIMAL(12, 2) NOT NULL,
    special_instructions    TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_carts_user_id ON carts(user_id);
CREATE INDEX idx_cart_items_cart_id ON cart_items(cart_id);
