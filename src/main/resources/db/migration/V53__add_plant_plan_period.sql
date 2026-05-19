ALTER TABLE pts_plant_plan_entry
    RENAME COLUMN planned_date TO planned_date_start;

ALTER TABLE pts_plant_plan_entry
    ADD COLUMN planned_date_end DATE;

UPDATE pts_plant_plan_entry
    SET planned_date_end = planned_date_start;

ALTER TABLE pts_plant_plan_entry
    ALTER COLUMN planned_date_end SET NOT NULL;
