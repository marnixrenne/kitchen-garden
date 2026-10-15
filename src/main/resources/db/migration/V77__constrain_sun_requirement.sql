ALTER TABLE pts_plants
    ADD CONSTRAINT chk_plants_sun_requirement
    CHECK (sun_requirement IN ('shade', 'partial_shade', 'full_sun'));
