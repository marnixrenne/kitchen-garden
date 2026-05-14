-- V44: Add common kitchen-garden fruits as a new 'Fruit' category

-- ============================================================
-- INSERT PLANTS
-- ============================================================

INSERT INTO pts_plants (id, name, category, emoji) VALUES
    (gen_random_uuid(), 'Strawberry',   'Fruit', '🍓'),
    (gen_random_uuid(), 'Raspberry',    'Fruit', '🍓'),
    (gen_random_uuid(), 'Blackberry',   'Fruit', '🫐'),
    (gen_random_uuid(), 'Blueberry',    'Fruit', '🫐'),
    (gen_random_uuid(), 'Gooseberry',   'Fruit', '🍈'),
    (gen_random_uuid(), 'Redcurrant',   'Fruit', '🍓'),
    (gen_random_uuid(), 'Blackcurrant', 'Fruit', '🫐'),
    (gen_random_uuid(), 'Apple',        'Fruit', '🍎'),
    (gen_random_uuid(), 'Pear',         'Fruit', '🍐'),
    (gen_random_uuid(), 'Cherry',       'Fruit', '🍒'),
    (gen_random_uuid(), 'Plum',         'Fruit', '🍑'),
    (gen_random_uuid(), 'Rhubarb',      'Fruit', '🌿');

-- ============================================================
-- LATIN NAMES
-- ============================================================

UPDATE pts_plants SET latin_name = 'Fragaria × ananassa'       WHERE name = 'Strawberry';
UPDATE pts_plants SET latin_name = 'Rubus idaeus'              WHERE name = 'Raspberry';
UPDATE pts_plants SET latin_name = 'Rubus fruticosus'          WHERE name = 'Blackberry';
UPDATE pts_plants SET latin_name = 'Vaccinium corymbosum'      WHERE name = 'Blueberry';
UPDATE pts_plants SET latin_name = 'Ribes uva-crispa'          WHERE name = 'Gooseberry';
UPDATE pts_plants SET latin_name = 'Ribes rubrum'              WHERE name = 'Redcurrant';
UPDATE pts_plants SET latin_name = 'Ribes nigrum'              WHERE name = 'Blackcurrant';
UPDATE pts_plants SET latin_name = 'Malus domestica'           WHERE name = 'Apple';
UPDATE pts_plants SET latin_name = 'Pyrus communis'            WHERE name = 'Pear';
UPDATE pts_plants SET latin_name = 'Prunus avium'              WHERE name = 'Cherry';
UPDATE pts_plants SET latin_name = 'Prunus domestica'          WHERE name = 'Plum';
UPDATE pts_plants SET latin_name = 'Rheum × hybridum'          WHERE name = 'Rhubarb';

-- ============================================================
-- SEEDING / PLANTING MONTHS (temperate European climate)
-- Soft fruits: plant bare-root Nov–Mar; Rhubarb: seed Feb–Apr
-- ============================================================

INSERT INTO pts_seeding_months (plant_id, month_num)
SELECT p.id, m.month_num
FROM pts_plants p
JOIN (VALUES
    ('Strawberry',    2), ('Strawberry',    3), ('Strawberry',    4),
    ('Raspberry',    10), ('Raspberry',    11), ('Raspberry',    12), ('Raspberry',    1), ('Raspberry',    2), ('Raspberry',    3),
    ('Blackberry',   10), ('Blackberry',   11), ('Blackberry',   12), ('Blackberry',    1), ('Blackberry',    2), ('Blackberry',    3),
    ('Blueberry',    10), ('Blueberry',    11), ('Blueberry',    12), ('Blueberry',     1), ('Blueberry',     2), ('Blueberry',     3),
    ('Gooseberry',   10), ('Gooseberry',   11), ('Gooseberry',   12), ('Gooseberry',    1), ('Gooseberry',    2), ('Gooseberry',    3),
    ('Redcurrant',   10), ('Redcurrant',   11), ('Redcurrant',   12), ('Redcurrant',    1), ('Redcurrant',    2), ('Redcurrant',    3),
    ('Blackcurrant', 10), ('Blackcurrant', 11), ('Blackcurrant', 12), ('Blackcurrant',  1), ('Blackcurrant',  2), ('Blackcurrant',  3),
    ('Apple',        11), ('Apple',        12), ('Apple',         1), ('Apple',          2), ('Apple',          3),
    ('Pear',         11), ('Pear',         12), ('Pear',          1), ('Pear',           2), ('Pear',           3),
    ('Cherry',       11), ('Cherry',       12), ('Cherry',        1), ('Cherry',         2), ('Cherry',         3),
    ('Plum',         11), ('Plum',         12), ('Plum',          1), ('Plum',           2), ('Plum',           3),
    ('Rhubarb',       2), ('Rhubarb',       3), ('Rhubarb',       4)
) AS m(plant_name, month_num) ON p.name = m.plant_name;

-- ============================================================
-- HARVESTING MONTHS
-- ============================================================

INSERT INTO pts_harvesting_months (plant_id, month_num)
SELECT p.id, m.month_num
FROM pts_plants p
JOIN (VALUES
    ('Strawberry',    6), ('Strawberry',    7), ('Strawberry',    8),
    ('Raspberry',     6), ('Raspberry',     7), ('Raspberry',     8), ('Raspberry',     9), ('Raspberry',    10),
    ('Blackberry',    8), ('Blackberry',    9), ('Blackberry',   10),
    ('Blueberry',     7), ('Blueberry',     8), ('Blueberry',     9),
    ('Gooseberry',    6), ('Gooseberry',    7), ('Gooseberry',    8),
    ('Redcurrant',    6), ('Redcurrant',    7), ('Redcurrant',    8),
    ('Blackcurrant',  7), ('Blackcurrant',  8),
    ('Apple',         8), ('Apple',          9), ('Apple',         10),
    ('Pear',          8), ('Pear',           9), ('Pear',          10),
    ('Cherry',        6), ('Cherry',         7), ('Cherry',         8),
    ('Plum',          7), ('Plum',           8), ('Plum',           9),
    ('Rhubarb',       4), ('Rhubarb',        5), ('Rhubarb',        6), ('Rhubarb',       7)
) AS m(plant_name, month_num) ON p.name = m.plant_name;

-- ============================================================
-- COUNTRY ASSOCIATIONS (temperate Europe + similar climates)
-- ============================================================

INSERT INTO pts_plant_countries (plant_id, country_code)
SELECT p.id, m.country_code
FROM pts_plants p
JOIN (VALUES
    -- Strawberry: widely grown across all temperate regions
    ('Strawberry', 'AT'), ('Strawberry', 'BE'), ('Strawberry', 'CH'), ('Strawberry', 'CZ'),
    ('Strawberry', 'DE'), ('Strawberry', 'DK'), ('Strawberry', 'ES'), ('Strawberry', 'FI'),
    ('Strawberry', 'FR'), ('Strawberry', 'GB'), ('Strawberry', 'HR'), ('Strawberry', 'HU'),
    ('Strawberry', 'IE'), ('Strawberry', 'IT'), ('Strawberry', 'LU'), ('Strawberry', 'NL'),
    ('Strawberry', 'NO'), ('Strawberry', 'PL'), ('Strawberry', 'PT'), ('Strawberry', 'RO'),
    ('Strawberry', 'SE'), ('Strawberry', 'SI'), ('Strawberry', 'SK'), ('Strawberry', 'UA'),
    ('Strawberry', 'US'), ('Strawberry', 'CA'), ('Strawberry', 'AU'), ('Strawberry', 'NZ'),
    ('Strawberry', 'ZA'),

    -- Raspberry
    ('Raspberry', 'AT'), ('Raspberry', 'BE'), ('Raspberry', 'CH'), ('Raspberry', 'CZ'),
    ('Raspberry', 'DE'), ('Raspberry', 'DK'), ('Raspberry', 'FI'), ('Raspberry', 'FR'),
    ('Raspberry', 'GB'), ('Raspberry', 'HR'), ('Raspberry', 'HU'), ('Raspberry', 'IE'),
    ('Raspberry', 'LU'), ('Raspberry', 'NL'), ('Raspberry', 'NO'), ('Raspberry', 'PL'),
    ('Raspberry', 'RO'), ('Raspberry', 'SE'), ('Raspberry', 'SI'), ('Raspberry', 'SK'),
    ('Raspberry', 'UA'), ('Raspberry', 'US'), ('Raspberry', 'CA'), ('Raspberry', 'AU'), ('Raspberry', 'NZ'),

    -- Blackberry
    ('Blackberry', 'AT'), ('Blackberry', 'BE'), ('Blackberry', 'CH'), ('Blackberry', 'CZ'),
    ('Blackberry', 'DE'), ('Blackberry', 'DK'), ('Blackberry', 'ES'), ('Blackberry', 'FR'),
    ('Blackberry', 'GB'), ('Blackberry', 'HR'), ('Blackberry', 'HU'), ('Blackberry', 'IE'),
    ('Blackberry', 'IT'), ('Blackberry', 'LU'), ('Blackberry', 'NL'), ('Blackberry', 'PL'),
    ('Blackberry', 'PT'), ('Blackberry', 'SE'), ('Blackberry', 'SI'), ('Blackberry', 'UA'),
    ('Blackberry', 'US'), ('Blackberry', 'CA'), ('Blackberry', 'AU'), ('Blackberry', 'NZ'),
    ('Blackberry', 'ZA'),

    -- Blueberry
    ('Blueberry', 'AT'), ('Blueberry', 'BE'), ('Blueberry', 'CH'), ('Blueberry', 'CZ'),
    ('Blueberry', 'DE'), ('Blueberry', 'DK'), ('Blueberry', 'FI'), ('Blueberry', 'FR'),
    ('Blueberry', 'GB'), ('Blueberry', 'HU'), ('Blueberry', 'IE'), ('Blueberry', 'LU'),
    ('Blueberry', 'NL'), ('Blueberry', 'NO'), ('Blueberry', 'PL'), ('Blueberry', 'SE'),
    ('Blueberry', 'UA'), ('Blueberry', 'US'), ('Blueberry', 'CA'), ('Blueberry', 'AU'), ('Blueberry', 'NZ'),

    -- Gooseberry
    ('Gooseberry', 'AT'), ('Gooseberry', 'BE'), ('Gooseberry', 'CH'), ('Gooseberry', 'CZ'),
    ('Gooseberry', 'DE'), ('Gooseberry', 'DK'), ('Gooseberry', 'FI'), ('Gooseberry', 'FR'),
    ('Gooseberry', 'GB'), ('Gooseberry', 'HU'), ('Gooseberry', 'IE'), ('Gooseberry', 'LU'),
    ('Gooseberry', 'NL'), ('Gooseberry', 'NO'), ('Gooseberry', 'PL'), ('Gooseberry', 'SE'),
    ('Gooseberry', 'SK'), ('Gooseberry', 'UA'), ('Gooseberry', 'US'), ('Gooseberry', 'CA'),

    -- Redcurrant
    ('Redcurrant', 'AT'), ('Redcurrant', 'BE'), ('Redcurrant', 'CH'), ('Redcurrant', 'CZ'),
    ('Redcurrant', 'DE'), ('Redcurrant', 'DK'), ('Redcurrant', 'FI'), ('Redcurrant', 'FR'),
    ('Redcurrant', 'GB'), ('Redcurrant', 'HU'), ('Redcurrant', 'IE'), ('Redcurrant', 'LU'),
    ('Redcurrant', 'NL'), ('Redcurrant', 'NO'), ('Redcurrant', 'PL'), ('Redcurrant', 'SE'),
    ('Redcurrant', 'SK'), ('Redcurrant', 'UA'), ('Redcurrant', 'US'), ('Redcurrant', 'CA'),

    -- Blackcurrant
    ('Blackcurrant', 'AT'), ('Blackcurrant', 'BE'), ('Blackcurrant', 'CH'), ('Blackcurrant', 'CZ'),
    ('Blackcurrant', 'DE'), ('Blackcurrant', 'DK'), ('Blackcurrant', 'FI'), ('Blackcurrant', 'FR'),
    ('Blackcurrant', 'GB'), ('Blackcurrant', 'HU'), ('Blackcurrant', 'IE'), ('Blackcurrant', 'LU'),
    ('Blackcurrant', 'NL'), ('Blackcurrant', 'NO'), ('Blackcurrant', 'PL'), ('Blackcurrant', 'SE'),
    ('Blackcurrant', 'SK'), ('Blackcurrant', 'UA'), ('Blackcurrant', 'US'), ('Blackcurrant', 'CA'),

    -- Apple
    ('Apple', 'AT'), ('Apple', 'BE'), ('Apple', 'CH'), ('Apple', 'CZ'),
    ('Apple', 'DE'), ('Apple', 'DK'), ('Apple', 'ES'), ('Apple', 'FI'),
    ('Apple', 'FR'), ('Apple', 'GB'), ('Apple', 'HR'), ('Apple', 'HU'),
    ('Apple', 'IE'), ('Apple', 'IT'), ('Apple', 'LU'), ('Apple', 'NL'),
    ('Apple', 'NO'), ('Apple', 'PL'), ('Apple', 'PT'), ('Apple', 'RO'),
    ('Apple', 'SE'), ('Apple', 'SI'), ('Apple', 'SK'), ('Apple', 'UA'),
    ('Apple', 'US'), ('Apple', 'CA'), ('Apple', 'AU'), ('Apple', 'NZ'), ('Apple', 'ZA'),

    -- Pear
    ('Pear', 'AT'), ('Pear', 'BE'), ('Pear', 'CH'), ('Pear', 'CZ'),
    ('Pear', 'DE'), ('Pear', 'DK'), ('Pear', 'ES'), ('Pear', 'FR'),
    ('Pear', 'GB'), ('Pear', 'HR'), ('Pear', 'HU'), ('Pear', 'IE'),
    ('Pear', 'IT'), ('Pear', 'LU'), ('Pear', 'NL'), ('Pear', 'PL'),
    ('Pear', 'PT'), ('Pear', 'RO'), ('Pear', 'SE'), ('Pear', 'SI'),
    ('Pear', 'UA'), ('Pear', 'US'), ('Pear', 'CA'), ('Pear', 'AU'), ('Pear', 'NZ'),

    -- Cherry
    ('Cherry', 'AT'), ('Cherry', 'BE'), ('Cherry', 'CH'), ('Cherry', 'CZ'),
    ('Cherry', 'DE'), ('Cherry', 'DK'), ('Cherry', 'ES'), ('Cherry', 'FR'),
    ('Cherry', 'GB'), ('Cherry', 'HR'), ('Cherry', 'HU'), ('Cherry', 'IE'),
    ('Cherry', 'IT'), ('Cherry', 'LU'), ('Cherry', 'NL'), ('Cherry', 'PL'),
    ('Cherry', 'PT'), ('Cherry', 'RO'), ('Cherry', 'SE'), ('Cherry', 'SI'),
    ('Cherry', 'UA'), ('Cherry', 'US'), ('Cherry', 'CA'), ('Cherry', 'AU'), ('Cherry', 'NZ'),

    -- Plum
    ('Plum', 'AT'), ('Plum', 'BE'), ('Plum', 'CH'), ('Plum', 'CZ'),
    ('Plum', 'DE'), ('Plum', 'DK'), ('Plum', 'ES'), ('Plum', 'FR'),
    ('Plum', 'GB'), ('Plum', 'HR'), ('Plum', 'HU'), ('Plum', 'IE'),
    ('Plum', 'IT'), ('Plum', 'LU'), ('Plum', 'NL'), ('Plum', 'PL'),
    ('Plum', 'PT'), ('Plum', 'RO'), ('Plum', 'SE'), ('Plum', 'SI'),
    ('Plum', 'UA'), ('Plum', 'US'), ('Plum', 'CA'), ('Plum', 'AU'), ('Plum', 'NZ'),

    -- Rhubarb
    ('Rhubarb', 'AT'), ('Rhubarb', 'BE'), ('Rhubarb', 'CH'), ('Rhubarb', 'CZ'),
    ('Rhubarb', 'DE'), ('Rhubarb', 'DK'), ('Rhubarb', 'FI'), ('Rhubarb', 'FR'),
    ('Rhubarb', 'GB'), ('Rhubarb', 'HU'), ('Rhubarb', 'IE'), ('Rhubarb', 'LU'),
    ('Rhubarb', 'NL'), ('Rhubarb', 'NO'), ('Rhubarb', 'PL'), ('Rhubarb', 'SE'),
    ('Rhubarb', 'SK'), ('Rhubarb', 'UA'), ('Rhubarb', 'US'), ('Rhubarb', 'CA'),
    ('Rhubarb', 'AU'), ('Rhubarb', 'NZ')
) AS m(plant_name, country_code) ON p.name = m.plant_name;
