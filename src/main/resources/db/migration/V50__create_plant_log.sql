CREATE TABLE pts_plant_log (
    id         UUID      NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id    UUID      NOT NULL REFERENCES sec_users(id) ON DELETE CASCADE,
    plant_id   UUID      NOT NULL REFERENCES pts_plants(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, plant_id)
);

CREATE TABLE pts_plant_log_entry (
    id         UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    log_id     UUID        NOT NULL REFERENCES pts_plant_log(id) ON DELETE CASCADE,
    action     VARCHAR(20) NOT NULL DEFAULT 'seeding',
    date       DATE        NOT NULL,
    comment    TEXT,
    created_at TIMESTAMP   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_plant_log_entry_log ON pts_plant_log_entry(log_id);
