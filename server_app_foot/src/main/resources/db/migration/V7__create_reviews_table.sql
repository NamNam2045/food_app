-- Reviews
CREATE TABLE reviews (
    id              BIGSERIAL PRIMARY KEY,
    order_id        BIGINT NOT NULL REFERENCES orders(id) UNIQUE,
    user_id         BIGINT NOT NULL REFERENCES users(id),
    restaurant_id   BIGINT NOT NULL REFERENCES restaurants(id),
    rating          SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment         TEXT,
    visible         BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reviews_restaurant_id ON reviews(restaurant_id, visible);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
