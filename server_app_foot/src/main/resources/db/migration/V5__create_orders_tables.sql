-- Orders, Order Items, Status History
CREATE TABLE orders (
    id                          BIGSERIAL PRIMARY KEY,
    order_number                VARCHAR(20) NOT NULL UNIQUE,
    user_id                     BIGINT NOT NULL REFERENCES users(id),
    restaurant_id               BIGINT NOT NULL REFERENCES restaurants(id),
    delivery_agent_id           BIGINT REFERENCES users(id),
    status                      VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    delivery_address_snapshot   TEXT,
    subtotal                    DECIMAL(12, 2) NOT NULL,
    delivery_fee                DECIMAL(12, 2) NOT NULL,
    discount_amount             DECIMAL(12, 2) NOT NULL DEFAULT 0,
    total_amount                DECIMAL(12, 2) NOT NULL,
    special_instructions        TEXT,
    estimated_delivery_at       TIMESTAMPTZ,
    delivered_at                TIMESTAMPTZ,
    cancelled_at                TIMESTAMPTZ,
    cancellation_reason         TEXT,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE order_items (
    id                      BIGSERIAL PRIMARY KEY,
    order_id                BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    menu_item_id            BIGINT NOT NULL REFERENCES menu_items(id),
    menu_item_name          VARCHAR(255) NOT NULL,
    quantity                INTEGER NOT NULL,
    unit_price              DECIMAL(12, 2) NOT NULL,
    subtotal                DECIMAL(12, 2) NOT NULL,
    special_instructions    TEXT
);

CREATE TABLE order_status_history (
    id                  BIGSERIAL PRIMARY KEY,
    order_id            BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    status              VARCHAR(30) NOT NULL,
    notes               TEXT,
    changed_by_user_id  BIGINT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_restaurant_id ON orders(restaurant_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_status_history_order_id ON order_status_history(order_id);
