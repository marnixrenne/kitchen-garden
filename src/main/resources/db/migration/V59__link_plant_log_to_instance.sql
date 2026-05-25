ALTER TABLE pts_plant_log
    ADD COLUMN instance_id UUID REFERENCES garden_plant_instances(id) ON DELETE SET NULL;

-- Backfill: match existing log rows to their instance via user -> garden -> instance
UPDATE pts_plant_log pl
SET    instance_id = gpi.id
FROM   garden_plant_instances gpi
JOIN   pts_garden g ON g.id = gpi.garden_id
WHERE  gpi.plant_id = pl.plant_id
  AND  g.user_id    = pl.user_id;
