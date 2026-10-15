CREATE TABLE pts_garden_bed (
    id           UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    garden_id    UUID         NOT NULL REFERENCES pts_garden(id) ON DELETE CASCADE,
    name         VARCHAR(100),
    bed_type     VARCHAR(20)  CHECK (bed_type IN ('in_ground', 'raised', 'container', 'greenhouse')),
    length_cm    INTEGER      CHECK (length_cm BETWEEN 1 AND 10000),
    width_cm     INTEGER      CHECK (width_cm  BETWEEN 1 AND 10000),
    sun_exposure VARCHAR(15)  CHECK (sun_exposure IN ('shade', 'partial_shade', 'full_sun')),
    aspect       VARCHAR(2)   CHECK (aspect IN ('N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW')),
    created_at   TIMESTAMP    NOT NULL DEFAULT NOW(),
    -- Target of the composite FK below, which keeps an instance's bed inside its own garden
    CONSTRAINT uq_garden_bed_garden UNIQUE (id, garden_id)
);

CREATE INDEX idx_garden_bed_garden ON pts_garden_bed(garden_id);

-- Every existing garden gets one unnamed bed holding all of its plant instances
INSERT INTO pts_garden_bed (garden_id, created_at)
SELECT id, created_at FROM pts_garden;

ALTER TABLE garden_plant_instances ADD COLUMN bed_id UUID;

UPDATE garden_plant_instances gpi
SET    bed_id = b.id
FROM   pts_garden_bed b
WHERE  b.garden_id = gpi.garden_id;

ALTER TABLE garden_plant_instances ALTER COLUMN bed_id SET NOT NULL;

ALTER TABLE garden_plant_instances
    ADD CONSTRAINT fk_garden_plant_instance_bed
    FOREIGN KEY (bed_id, garden_id) REFERENCES pts_garden_bed(id, garden_id);

CREATE INDEX idx_garden_plant_instances_bed ON garden_plant_instances(bed_id);
