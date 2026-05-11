ALTER TABLE vegetables
    ADD COLUMN sowing_method         VARCHAR(10),
    ADD COLUMN seed_depth_mm         SMALLINT,
    ADD COLUMN spacing_cm            SMALLINT,
    ADD COLUMN germination_days_min  SMALLINT,
    ADD COLUMN germination_days_max  SMALLINT,
    ADD COLUMN days_to_maturity_min  SMALLINT,
    ADD COLUMN days_to_maturity_max  SMALLINT,
    ADD COLUMN frost_tolerance       VARCHAR(12);
