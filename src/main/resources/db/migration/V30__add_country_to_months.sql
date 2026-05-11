ALTER TABLE seeding_months   ADD COLUMN country_code CHAR(2) REFERENCES countries(code);
ALTER TABLE harvesting_months ADD COLUMN country_code CHAR(2) REFERENCES countries(code);

-- Existing rows (country_code = NULL) represent global/default data.
-- Country-specific overrides have a non-null country_code.
-- Enforce uniqueness separately for global and country-specific rows.
CREATE UNIQUE INDEX seeding_months_global_uniq
    ON seeding_months (vegetable_id, month_num)
    WHERE country_code IS NULL;

CREATE UNIQUE INDEX seeding_months_country_uniq
    ON seeding_months (vegetable_id, month_num, country_code)
    WHERE country_code IS NOT NULL;

CREATE UNIQUE INDEX harvesting_months_global_uniq
    ON harvesting_months (vegetable_id, month_num)
    WHERE country_code IS NULL;

CREATE UNIQUE INDEX harvesting_months_country_uniq
    ON harvesting_months (vegetable_id, month_num, country_code)
    WHERE country_code IS NOT NULL;
