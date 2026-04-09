-- Restaurants and Operating Hours
CREATE TABLE restaurants (
    id                              BIGSERIAL PRIMARY KEY,
    owner_id                        BIGINT NOT NULL REFERENCES users(id),
    name                            VARCHAR(255) NOT NULL,
    slug                            VARCHAR(255) NOT NULL UNIQUE,
    description                     TEXT,
    cuisine_type                    VARCHAR(100) NOT NULL,
    logo_url                        TEXT,
    banner_url                      TEXT,
    phone                           VARCHAR(20),
    email                           VARCHAR(255),
    street_address                  VARCHAR(255) NOT NULL,
    city                            VARCHAR(100) NOT NULL,
    latitude                        DECIMAL(10, 7),
    longitude                       DECIMAL(10, 7),
    rating_avg                      DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
    rating_count                    INTEGER NOT NULL DEFAULT 0,
    min_order_amount                DECIMAL(12, 2) NOT NULL DEFAULT 0,
    delivery_fee                    DECIMAL(12, 2) NOT NULL DEFAULT 0,
    estimated_delivery_minutes      INTEGER NOT NULL DEFAULT 30,
    active                          BOOLEAN NOT NULL DEFAULT TRUE,
    open                            BOOLEAN NOT NULL DEFAULT FALSE,
    created_at                      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE operating_hours (
    id              BIGSERIAL PRIMARY KEY,
    restaurant_id   BIGINT NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    day_of_week     SMALLINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    open_time       TIME NOT NULL,
    close_time      TIME NOT NULL,
    closed          BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_restaurants_city ON restaurants(city);
CREATE INDEX idx_restaurants_cuisine ON restaurants(cuisine_type);
CREATE INDEX idx_restaurants_active ON restaurants(active, open);
CREATE INDEX idx_restaurants_slug ON restaurants(slug);
CREATE INDEX idx_operating_hours_restaurant ON operating_hours(restaurant_id);
