UPDATE pts_plant_log SET lifecycle_state = 'seeded_outdoor' WHERE lifecycle_state = 'seeded_direct';
ALTER TABLE pts_plant_log ALTER COLUMN lifecycle_state SET DEFAULT 'seeded_outdoor';
