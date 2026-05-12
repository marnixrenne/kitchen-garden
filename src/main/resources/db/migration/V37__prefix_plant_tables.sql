-- V37: Add pts_ prefix to plant-domain tables

ALTER TABLE companion_plants   RENAME TO pts_companion_plants;
ALTER TABLE harvesting_months  RENAME TO pts_harvesting_months;
ALTER TABLE plant_countries    RENAME TO pts_plant_countries;
ALTER TABLE plants             RENAME TO pts_plants;
ALTER TABLE seeding_months     RENAME TO pts_seeding_months;
