-- V36: Rename vegetable → plant throughout the schema

-- Rename columns before renaming tables (Postgres requires columns to be renamed on the current table name)
ALTER TABLE seeding_months    RENAME COLUMN vegetable_id TO plant_id;
ALTER TABLE harvesting_months RENAME COLUMN vegetable_id TO plant_id;
ALTER TABLE companion_plants  RENAME COLUMN vegetable_id TO plant_id;
ALTER TABLE vegetable_countries RENAME COLUMN vegetable_id TO plant_id;
ALTER TABLE garden_vegetables RENAME COLUMN vegetable_id TO plant_id;

-- Rename tables
ALTER TABLE vegetables        RENAME TO plants;
ALTER TABLE vegetable_countries RENAME TO plant_countries;
ALTER TABLE garden_vegetables RENAME TO garden_plants;

-- Update image URLs
UPDATE plants SET image_url = REPLACE(image_url, '/images/vegetables/', '/images/plants/') WHERE image_url LIKE '%/images/vegetables/%';
