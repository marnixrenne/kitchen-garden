-- MOVED log entries record the source and destination bed. The ids are cleared when
-- a bed is deleted; the name snapshots keep the history readable afterwards.
ALTER TABLE pts_plant_log_entry
    ADD COLUMN from_bed_id   UUID REFERENCES pts_garden_bed(id) ON DELETE SET NULL,
    ADD COLUMN to_bed_id     UUID REFERENCES pts_garden_bed(id) ON DELETE SET NULL,
    ADD COLUMN from_bed_name VARCHAR(100),
    ADD COLUMN to_bed_name   VARCHAR(100);

-- A log that so far only holds moves has no lifecycle state yet
ALTER TABLE pts_plant_log
    ALTER COLUMN lifecycle_state DROP NOT NULL,
    ALTER COLUMN lifecycle_state DROP DEFAULT;
