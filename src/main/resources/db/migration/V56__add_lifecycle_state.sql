ALTER TABLE pts_plant_log
    ADD COLUMN lifecycle_state      VARCHAR(20)  NOT NULL DEFAULT 'seeded',
    ADD COLUMN lifecycle_updated_at TIMESTAMP;
