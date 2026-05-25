CREATE TABLE garden_plant_instances (
    id         UUID      NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    garden_id  UUID      NOT NULL REFERENCES pts_garden(id)  ON DELETE CASCADE,
    plant_id   UUID      NOT NULL REFERENCES pts_plants(id)  ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_garden_plant_instances_garden ON garden_plant_instances(garden_id);

-- Migrate existing garden membership rows into instances
INSERT INTO garden_plant_instances (garden_id, plant_id, created_at)
SELECT garden_id, plant_id, NOW()
FROM garden_plants;

DROP TABLE garden_plants;
