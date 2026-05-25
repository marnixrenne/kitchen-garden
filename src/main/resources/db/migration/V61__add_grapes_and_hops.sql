-- V61: Add Grape and Hops to the plant database

-- ============================================================
-- INSERT PLANTS
-- ============================================================

INSERT INTO pts_plants (id, name, category, emoji) VALUES
    (gen_random_uuid(), 'Grape', 'Fruit', '🍇'),
    (gen_random_uuid(), 'Hops',  'Herb',  '🌿');

-- ============================================================
-- LATIN NAMES
-- ============================================================

UPDATE pts_plants SET latin_name = 'Vitis vinifera'    WHERE name = 'Grape';
UPDATE pts_plants SET latin_name = 'Humulus lupulus'   WHERE name = 'Hops';

-- ============================================================
-- PLANT ATTRIBUTES
-- ============================================================

UPDATE pts_plants SET
    sun_requirement  = 'full_sun',
    sowing_method    = 'direct',
    spacing_cm       = 150,
    height_min_cm    = 200,
    height_max_cm    = 500,
    frost_tolerance  = 'hardy'
WHERE name = 'Grape';

UPDATE pts_plants SET
    sun_requirement  = 'full_sun',
    sowing_method    = 'direct',
    spacing_cm       = 100,
    height_min_cm    = 300,
    height_max_cm    = 600,
    frost_tolerance  = 'hardy'
WHERE name = 'Hops';

-- ============================================================
-- SEEDING / PLANTING MONTHS (temperate European climate)
-- Grape: plant bare-root Nov–Mar
-- Hops:  plant rhizomes Mar–Apr
-- ============================================================

INSERT INTO pts_seeding_months (plant_id, month_num)
SELECT p.id, m.month_num
FROM pts_plants p
JOIN (VALUES
    ('Grape', 11), ('Grape', 12), ('Grape', 1), ('Grape', 2), ('Grape', 3),
    ('Hops',   3), ('Hops',   4)
) AS m(plant_name, month_num) ON p.name = m.plant_name;

-- ============================================================
-- HARVESTING MONTHS
-- ============================================================

INSERT INTO pts_harvesting_months (plant_id, month_num)
SELECT p.id, m.month_num
FROM pts_plants p
JOIN (VALUES
    ('Grape', 8), ('Grape',  9), ('Grape', 10),
    ('Hops',  8), ('Hops',   9)
) AS m(plant_name, month_num) ON p.name = m.plant_name;

-- ============================================================
-- COUNTRY ASSOCIATIONS
-- ============================================================

INSERT INTO pts_plant_countries (plant_id, country_code)
SELECT p.id, m.country_code
FROM pts_plants p
JOIN (VALUES
    -- Grape: temperate wine-growing regions
    ('Grape', 'AT'), ('Grape', 'BE'), ('Grape', 'CH'), ('Grape', 'CZ'),
    ('Grape', 'DE'), ('Grape', 'DK'), ('Grape', 'ES'), ('Grape', 'FR'),
    ('Grape', 'GB'), ('Grape', 'HR'), ('Grape', 'HU'), ('Grape', 'IE'),
    ('Grape', 'IT'), ('Grape', 'LU'), ('Grape', 'NL'), ('Grape', 'PL'),
    ('Grape', 'PT'), ('Grape', 'RO'), ('Grape', 'SE'), ('Grape', 'SI'),
    ('Grape', 'UA'), ('Grape', 'US'), ('Grape', 'CA'), ('Grape', 'AU'),
    ('Grape', 'NZ'), ('Grape', 'ZA'),

    -- Hops: traditional hop-growing regions
    ('Hops', 'AT'), ('Hops', 'BE'), ('Hops', 'CH'), ('Hops', 'CZ'),
    ('Hops', 'DE'), ('Hops', 'DK'), ('Hops', 'FR'), ('Hops', 'GB'),
    ('Hops', 'HU'), ('Hops', 'IE'), ('Hops', 'LU'), ('Hops', 'NL'),
    ('Hops', 'NO'), ('Hops', 'PL'), ('Hops', 'SE'), ('Hops', 'SK'),
    ('Hops', 'UA'), ('Hops', 'US'), ('Hops', 'CA'), ('Hops', 'AU')
) AS m(plant_name, country_code) ON p.name = m.plant_name;

-- ============================================================
-- COMPANION PLANTS
-- ============================================================

-- Grape — good: Nasturtium traps aphids; Chive and Rosemary repel pests; Basil improves general health
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Grape' AND v2.name = 'Nasturtium'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Grape' AND v2.name = 'Chive'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Grape' AND v2.name = 'Rosemary'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Grape' AND v2.name = 'Basil'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
-- Grape — bad: Fennel is allelopathic; Cabbage competes heavily for nutrients
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Grape' AND v2.name = 'Fennel'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Grape' AND v2.name = 'Cabbage'
ON CONFLICT (plant_id, companion_id) DO NOTHING;

-- Hops — good: Basil and Nasturtium repel aphids and other pests
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Hops' AND v2.name = 'Basil'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Hops' AND v2.name = 'Nasturtium'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
-- Hops — bad: Fennel is allelopathic
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Hops' AND v2.name = 'Fennel'
ON CONFLICT (plant_id, companion_id) DO NOTHING;

-- ============================================================
-- INSECTS
-- ============================================================

-- Grape
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Grape';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Grape';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Grape';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',  'beneficial' FROM pts_plants WHERE name = 'Grape';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',  'beneficial' FROM pts_plants WHERE name = 'Grape';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Grape';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'whitefly',  'pest'       FROM pts_plants WHERE name = 'Grape';

-- Hops
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Hops';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Hops';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Hops';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',  'beneficial' FROM pts_plants WHERE name = 'Hops';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',  'beneficial' FROM pts_plants WHERE name = 'Hops';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Hops';

-- ============================================================
-- PRUNING INFO
-- ============================================================

UPDATE pts_plants SET
    pruning_type = 'cutting_back',
    pruning_tip  = 'Prune in late winter (January–February) while the plant is fully dormant to avoid sap bleeding. For the spur system, cut each fruiting lateral back to 2–3 buds. For the cane system, retain one or two vigorous new canes tied horizontally and remove all others. Remove dead, crossing, or diseased wood entirely.'
WHERE name = 'Grape';

UPDATE pts_plants SET
    pruning_type = 'cutting_back',
    pruning_tip  = 'Cut all bines back to ground level in autumn after harvest, leaving a 5 cm stub above the crown. In spring, allow 3–4 strong shoots to develop from each crown and train these up the support structure, rubbing out all remaining shoots at the base. This annual cut-back keeps the plant productive and manageable.'
WHERE name = 'Hops';

-- ============================================================
-- FERTILIZER INFO
-- ============================================================

UPDATE pts_plants SET
    fertilizer_type = 'moderate_feeder',
    fertilizer_tip  = 'Apply a balanced granular fertiliser in early spring as buds begin to swell. Once fruit has set, switch to a high-potassium liquid feed every 2–3 weeks to support ripening. Avoid high-nitrogen feeds during the growing season — excess nitrogen produces lush leafy growth at the expense of fruit quality and sugar development.'
WHERE name = 'Grape';

UPDATE pts_plants SET
    fertilizer_type = 'moderate_feeder',
    fertilizer_tip  = 'Apply a nitrogen-rich fertiliser in early spring as the first shoots emerge to fuel rapid early-season growth. Switch to a balanced or high-potassium feed once the bines reach full height to support cone development. Plants growing in the same spot for several years benefit from an annual top-dress of well-rotted compost in autumn.'
WHERE name = 'Hops';
