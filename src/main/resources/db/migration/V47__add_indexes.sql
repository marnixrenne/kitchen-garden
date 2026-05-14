-- C-5: Index for signup token lookup by email (used in initiateSignup)
CREATE INDEX IF NOT EXISTS idx_sec_signup_tokens_email ON sec_signup_tokens (email);

-- M-9: Indexes on foreign keys and frequently filtered columns

-- Security tables
CREATE INDEX IF NOT EXISTS idx_sec_user_roles_user_id       ON sec_user_roles (user_id);
CREATE INDEX IF NOT EXISTS idx_sec_user_roles_role_id       ON sec_user_roles (role_id);
CREATE INDEX IF NOT EXISTS idx_sec_role_authorities_role_id ON sec_role_authorities (role_id);

-- Plant month tables (high-traffic: used on every plant-list and detail request)
CREATE INDEX IF NOT EXISTS idx_pts_seeding_months_plant_id    ON pts_seeding_months (plant_id);
CREATE INDEX IF NOT EXISTS idx_pts_seeding_months_country     ON pts_seeding_months (country_code);
CREATE INDEX IF NOT EXISTS idx_pts_harvesting_months_plant_id ON pts_harvesting_months (plant_id);
CREATE INDEX IF NOT EXISTS idx_pts_harvesting_months_country  ON pts_harvesting_months (country_code);

-- Companion plants
CREATE INDEX IF NOT EXISTS idx_pts_companion_plants_plant_id    ON pts_companion_plants (plant_id);
CREATE INDEX IF NOT EXISTS idx_pts_companion_plants_companion_id ON pts_companion_plants (companion_id);

-- Insects and countries
CREATE INDEX IF NOT EXISTS idx_pts_plant_insects_plant_id  ON pts_plant_insects (plant_id);
CREATE INDEX IF NOT EXISTS idx_pts_plant_countries_plant_id ON pts_plant_countries (plant_id);

-- Garden and preferences (user-scoped lookups on every authenticated request)
CREATE INDEX IF NOT EXISTS idx_garden_plants_user_id       ON garden_plants (user_id);
CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id    ON user_preferences (user_id);
