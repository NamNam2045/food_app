-- Payments
CREATE TABLE payments (
    id                  BIGSERIAL PRIMARY KEY,
    order_id            BIGINT NOT NULL REFERENCES orders(id) UNIQUE,
    payment_method      VARCHAR(30) NOT NULL,
    payment_status      VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    amount              DECIMAL(12, 2) NOT NULL,
    transaction_id      VARCHAR(255),
    gateway_response    TEXT,
    paid_at             TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(payment_status);
