-- Remove duplicate (garden_id, plant_id) pairs, keeping the oldest instance
DELETE FROM garden_plant_instances
WHERE id NOT IN (
    SELECT DISTINCT ON (garden_id, plant_id) id
    FROM garden_plant_instances
    ORDER BY garden_id, plant_id, created_at
);

ALTER TABLE garden_plant_instances
    ADD CONSTRAINT uq_garden_plant_instance UNIQUE (garden_id, plant_id);
