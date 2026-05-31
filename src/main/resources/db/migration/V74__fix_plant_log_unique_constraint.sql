-- Replace UNIQUE(user_id, plant_id) with UNIQUE(instance_id):
-- the old constraint incorrectly prevented a user from logging actions on the
-- same plant in two different gardens (one instance per garden).
ALTER TABLE pts_plant_log
    DROP CONSTRAINT pts_plant_log_user_id_plant_id_key;

CREATE UNIQUE INDEX pts_plant_log_instance_id_uq
    ON pts_plant_log(instance_id)
    WHERE instance_id IS NOT NULL;
