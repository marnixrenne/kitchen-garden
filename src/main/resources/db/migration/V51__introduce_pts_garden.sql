CREATE TABLE pts_garden (
    id         UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id    UUID         NOT NULL REFERENCES sec_users(id) ON DELETE CASCADE,
    name       VARCHAR(100) NOT NULL DEFAULT 'My Garden',
    created_at TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_pts_garden_user ON pts_garden(user_id);

-- Create a default garden for every user that already has plants in garden_plants
INSERT INTO pts_garden (id, user_id, name)
SELECT gen_random_uuid(), user_id, 'My Garden'
FROM (SELECT DISTINCT user_id FROM garden_plants) AS existing_users;

-- Attach garden_id to each existing row (nullable during migration)
ALTER TABLE garden_plants ADD COLUMN garden_id UUID REFERENCES pts_garden(id) ON DELETE CASCADE;

UPDATE garden_plants gp
SET    garden_id = pg.id
FROM   pts_garden pg
WHERE  pg.user_id = gp.user_id;

ALTER TABLE garden_plants ALTER COLUMN garden_id SET NOT NULL;

-- Remove old user-scoped index, PK, and column
DROP INDEX IF EXISTS idx_garden_plants_user_id;
ALTER TABLE garden_plants DROP CONSTRAINT pk_garden_vegetable;
ALTER TABLE garden_plants DROP COLUMN user_id;

ALTER TABLE garden_plants ADD CONSTRAINT pk_garden_plants PRIMARY KEY (garden_id, plant_id);
