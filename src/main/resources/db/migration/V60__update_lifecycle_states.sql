ALTER TABLE pts_plant_log ALTER COLUMN lifecycle_state TYPE VARCHAR(30);

UPDATE pts_plant_log SET lifecycle_state = 'seeded_direct' WHERE lifecycle_state = 'seeded';
