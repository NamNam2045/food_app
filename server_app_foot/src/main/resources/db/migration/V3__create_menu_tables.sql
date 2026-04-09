-- Menu Categories and Items
CREATE TABLE menu_categories (
    id              BIGSERIAL PRIMARY KEY,
    restaurant_id   BIGINT NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    display_order   INTEGER NOT NULL DEFAULT 0,
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE menu_items (
    id                          BIGSERIAL PRIMARY KEY,
    category_id                 BIGINT NOT NULL REFERENCES menu_categories(id) ON DELETE CASCADE,
    restaurant_id               BIGINT NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    name                        VARCHAR(255) NOT NULL,
    description                 TEXT,
    price                       DECIMAL(12, 2) NOT NULL,
    image_url                   TEXT,
    available                   BOOLEAN NOT NULL DEFAULT TRUE,
    featured                    BOOLEAN NOT NULL DEFAULT FALSE,
    calories                    INTEGER,
    preparation_time_minutes    INTEGER NOT NULL DEFAULT 15,
    display_order               INTEGER NOT NULL DEFAULT 0,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_menu_categories_restaurant ON menu_categories(restaurant_id);
CREATE INDEX idx_menu_items_restaurant ON menu_items(restaurant_id);
CREATE INDEX idx_menu_items_category ON menu_items(category_id);
CREATE INDEX idx_menu_items_available ON menu_items(restaurant_id, available);
