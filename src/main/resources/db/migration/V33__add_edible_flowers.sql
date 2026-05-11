-- V33: Add common edible flowers
-- New entries: Nasturtium, Calendula, Lavender, Viola, Sunflower,
--              Cornflower, Chamomile, Elderflower, Rose

-- ============================================================
-- INSERT VEGETABLES
-- ============================================================

INSERT INTO vegetables (id, name, category, emoji) VALUES
    (gen_random_uuid(), 'Nasturtium',  'Flower', '🌸'),
    (gen_random_uuid(), 'Calendula',   'Flower', '🌼'),
    (gen_random_uuid(), 'Lavender',    'Flower', '🌸'),
    (gen_random_uuid(), 'Viola',       'Flower', '🌸'),
    (gen_random_uuid(), 'Sunflower',   'Flower', '🌻'),
    (gen_random_uuid(), 'Cornflower',  'Flower', '🌸'),
    (gen_random_uuid(), 'Chamomile',   'Flower', '🌼'),
    (gen_random_uuid(), 'Elderflower', 'Flower', '🌸'),
    (gen_random_uuid(), 'Rose',        'Flower', '🌹');

-- ============================================================
-- SEEDING MONTHS (global, no country)
-- ============================================================

INSERT INTO seeding_months (vegetable_id, month_num)
SELECT v.id, m.month_num
FROM vegetables v
JOIN (VALUES
    ('Nasturtium',  4), ('Nasturtium',  5),
    ('Calendula',   3), ('Calendula',   4),
    ('Lavender',    2), ('Lavender',    3), ('Lavender',    4),
    ('Viola',       2), ('Viola',       3), ('Viola',       8), ('Viola',       9),
    ('Sunflower',   4), ('Sunflower',   5),
    ('Cornflower',  3), ('Cornflower',  4), ('Cornflower',  9),
    ('Chamomile',   3), ('Chamomile',   4), ('Chamomile',   9),
    ('Elderflower', 3), ('Elderflower', 4),
    ('Rose',        3), ('Rose',        4)
) AS m(veg_name, month_num) ON v.name = m.veg_name;

-- ============================================================
-- HARVESTING MONTHS (global, no country)
-- ============================================================

INSERT INTO harvesting_months (vegetable_id, month_num)
SELECT v.id, m.month_num
FROM vegetables v
JOIN (VALUES
    ('Nasturtium',  6), ('Nasturtium',  7), ('Nasturtium',  8), ('Nasturtium',  9),
    ('Calendula',   6), ('Calendula',   7), ('Calendula',   8), ('Calendula',   9), ('Calendula', 10),
    ('Lavender',    6), ('Lavender',    7), ('Lavender',    8),
    ('Viola',       4), ('Viola',       5), ('Viola',       6), ('Viola',      10), ('Viola',      11),
    ('Sunflower',   7), ('Sunflower',   8), ('Sunflower',   9),
    ('Cornflower',  5), ('Cornflower',  6), ('Cornflower',  7), ('Cornflower',  8),
    ('Chamomile',   5), ('Chamomile',   6), ('Chamomile',   7), ('Chamomile',   8),
    ('Elderflower', 5), ('Elderflower', 6),
    ('Rose',        5), ('Rose',        6), ('Rose',        7), ('Rose',        8), ('Rose',       9)
) AS m(veg_name, month_num) ON v.name = m.veg_name;

-- ============================================================
-- VEGETABLE COUNTRIES
-- ============================================================

INSERT INTO vegetable_countries (vegetable_id, country_code)
SELECT v.id, m.country_code
FROM vegetables v
JOIN (VALUES
    -- Nasturtium: widely grown temperate gardens
    ('Nasturtium', 'AT'), ('Nasturtium', 'BE'), ('Nasturtium', 'CH'), ('Nasturtium', 'CZ'),
    ('Nasturtium', 'DE'), ('Nasturtium', 'DK'), ('Nasturtium', 'ES'), ('Nasturtium', 'FI'),
    ('Nasturtium', 'FR'), ('Nasturtium', 'GB'), ('Nasturtium', 'HR'), ('Nasturtium', 'HU'),
    ('Nasturtium', 'IE'), ('Nasturtium', 'IT'), ('Nasturtium', 'LU'), ('Nasturtium', 'NL'),
    ('Nasturtium', 'NO'), ('Nasturtium', 'PL'), ('Nasturtium', 'PT'), ('Nasturtium', 'SE'),
    ('Nasturtium', 'SI'),
    ('Nasturtium', 'US'), ('Nasturtium', 'CA'), ('Nasturtium', 'AU'), ('Nasturtium', 'NZ'),
    ('Nasturtium', 'ZA'),

    -- Calendula: widely grown temperate
    ('Calendula', 'AT'), ('Calendula', 'BE'), ('Calendula', 'CH'), ('Calendula', 'CZ'),
    ('Calendula', 'DE'), ('Calendula', 'DK'), ('Calendula', 'ES'), ('Calendula', 'FI'),
    ('Calendula', 'FR'), ('Calendula', 'GB'), ('Calendula', 'HR'), ('Calendula', 'HU'),
    ('Calendula', 'IE'), ('Calendula', 'IT'), ('Calendula', 'LU'), ('Calendula', 'NL'),
    ('Calendula', 'NO'), ('Calendula', 'PL'), ('Calendula', 'PT'), ('Calendula', 'SE'),
    ('Calendula', 'SI'), ('Calendula', 'SK'), ('Calendula', 'UA'),
    ('Calendula', 'US'), ('Calendula', 'CA'), ('Calendula', 'AU'), ('Calendula', 'NZ'),
    ('Calendula', 'ZA'),

    -- Lavender: Mediterranean origin, widely grown
    ('Lavender', 'FR'), ('Lavender', 'IT'), ('Lavender', 'ES'), ('Lavender', 'PT'),
    ('Lavender', 'HR'), ('Lavender', 'SI'), ('Lavender', 'DE'), ('Lavender', 'NL'),
    ('Lavender', 'BE'), ('Lavender', 'GB'), ('Lavender', 'IE'), ('Lavender', 'AT'),
    ('Lavender', 'CH'), ('Lavender', 'DK'), ('Lavender', 'SE'),
    ('Lavender', 'US'), ('Lavender', 'CA'), ('Lavender', 'AU'), ('Lavender', 'NZ'),
    ('Lavender', 'ZA'),

    -- Viola: widespread temperate
    ('Viola', 'AT'), ('Viola', 'BE'), ('Viola', 'CH'), ('Viola', 'CZ'), ('Viola', 'DE'),
    ('Viola', 'DK'), ('Viola', 'ES'), ('Viola', 'FI'), ('Viola', 'FR'), ('Viola', 'GB'),
    ('Viola', 'HR'), ('Viola', 'HU'), ('Viola', 'IE'), ('Viola', 'IT'), ('Viola', 'LU'),
    ('Viola', 'NL'), ('Viola', 'NO'), ('Viola', 'PL'), ('Viola', 'PT'), ('Viola', 'SE'),
    ('Viola', 'SI'), ('Viola', 'SK'), ('Viola', 'UA'),
    ('Viola', 'US'), ('Viola', 'CA'), ('Viola', 'AU'), ('Viola', 'NZ'),

    -- Sunflower: widespread
    ('Sunflower', 'AT'), ('Sunflower', 'BE'), ('Sunflower', 'CH'), ('Sunflower', 'CZ'),
    ('Sunflower', 'DE'), ('Sunflower', 'DK'), ('Sunflower', 'ES'), ('Sunflower', 'FR'),
    ('Sunflower', 'GB'), ('Sunflower', 'HR'), ('Sunflower', 'HU'), ('Sunflower', 'IE'),
    ('Sunflower', 'IT'), ('Sunflower', 'NL'), ('Sunflower', 'PL'), ('Sunflower', 'PT'),
    ('Sunflower', 'RO'), ('Sunflower', 'SE'), ('Sunflower', 'UA'),
    ('Sunflower', 'US'), ('Sunflower', 'CA'), ('Sunflower', 'AU'), ('Sunflower', 'NZ'),
    ('Sunflower', 'ZA'), ('Sunflower', 'AR'), ('Sunflower', 'CN'), ('Sunflower', 'IN'),

    -- Cornflower: temperate European, widely naturalized
    ('Cornflower', 'AT'), ('Cornflower', 'BE'), ('Cornflower', 'CH'), ('Cornflower', 'CZ'),
    ('Cornflower', 'DE'), ('Cornflower', 'DK'), ('Cornflower', 'ES'), ('Cornflower', 'FI'),
    ('Cornflower', 'FR'), ('Cornflower', 'GB'), ('Cornflower', 'HR'), ('Cornflower', 'HU'),
    ('Cornflower', 'IE'), ('Cornflower', 'IT'), ('Cornflower', 'LU'), ('Cornflower', 'NL'),
    ('Cornflower', 'NO'), ('Cornflower', 'PL'), ('Cornflower', 'PT'), ('Cornflower', 'RO'),
    ('Cornflower', 'SE'), ('Cornflower', 'SI'), ('Cornflower', 'SK'), ('Cornflower', 'UA'),
    ('Cornflower', 'US'), ('Cornflower', 'CA'), ('Cornflower', 'AU'), ('Cornflower', 'NZ'),

    -- Chamomile: temperate European, widely grown
    ('Chamomile', 'AT'), ('Chamomile', 'BE'), ('Chamomile', 'CH'), ('Chamomile', 'CZ'),
    ('Chamomile', 'DE'), ('Chamomile', 'DK'), ('Chamomile', 'ES'), ('Chamomile', 'FI'),
    ('Chamomile', 'FR'), ('Chamomile', 'GB'), ('Chamomile', 'HR'), ('Chamomile', 'HU'),
    ('Chamomile', 'IE'), ('Chamomile', 'IT'), ('Chamomile', 'LU'), ('Chamomile', 'NL'),
    ('Chamomile', 'NO'), ('Chamomile', 'PL'), ('Chamomile', 'PT'), ('Chamomile', 'RO'),
    ('Chamomile', 'SE'), ('Chamomile', 'SI'), ('Chamomile', 'SK'), ('Chamomile', 'UA'),
    ('Chamomile', 'US'), ('Chamomile', 'CA'), ('Chamomile', 'AU'), ('Chamomile', 'NZ'),

    -- Elderflower: European, especially northern and central
    ('Elderflower', 'AT'), ('Elderflower', 'BE'), ('Elderflower', 'CH'), ('Elderflower', 'CZ'),
    ('Elderflower', 'DE'), ('Elderflower', 'DK'), ('Elderflower', 'FI'), ('Elderflower', 'FR'),
    ('Elderflower', 'GB'), ('Elderflower', 'HR'), ('Elderflower', 'HU'), ('Elderflower', 'IE'),
    ('Elderflower', 'IT'), ('Elderflower', 'LU'), ('Elderflower', 'NL'), ('Elderflower', 'NO'),
    ('Elderflower', 'PL'), ('Elderflower', 'PT'), ('Elderflower', 'RO'), ('Elderflower', 'SE'),
    ('Elderflower', 'SI'), ('Elderflower', 'SK'), ('Elderflower', 'UA'),
    ('Elderflower', 'US'), ('Elderflower', 'CA'), ('Elderflower', 'AU'), ('Elderflower', 'NZ'),

    -- Rose: worldwide
    ('Rose', 'AT'), ('Rose', 'BE'), ('Rose', 'CH'), ('Rose', 'CZ'), ('Rose', 'DE'),
    ('Rose', 'DK'), ('Rose', 'ES'), ('Rose', 'FI'), ('Rose', 'FR'), ('Rose', 'GB'),
    ('Rose', 'HR'), ('Rose', 'HU'), ('Rose', 'IE'), ('Rose', 'IT'), ('Rose', 'LU'),
    ('Rose', 'NL'), ('Rose', 'NO'), ('Rose', 'PL'), ('Rose', 'PT'), ('Rose', 'RO'),
    ('Rose', 'SE'), ('Rose', 'SI'), ('Rose', 'SK'), ('Rose', 'UA'),
    ('Rose', 'US'), ('Rose', 'CA'), ('Rose', 'AU'), ('Rose', 'NZ'),
    ('Rose', 'ZA'), ('Rose', 'AR'), ('Rose', 'BR'), ('Rose', 'CN'), ('Rose', 'IN'), ('Rose', 'JP')

) AS m(veg_name, country_code) ON v.name = m.veg_name;

-- ============================================================
-- SUN REQUIREMENT
-- ============================================================

UPDATE vegetables SET sun_requirement = 'full_sun'
WHERE name IN ('Calendula', 'Lavender', 'Sunflower', 'Cornflower', 'Chamomile', 'Rose');

UPDATE vegetables SET sun_requirement = 'partial_shade'
WHERE name IN ('Nasturtium', 'Viola', 'Elderflower');

-- ============================================================
-- SOWING INFO
-- ============================================================
-- (name, method, depth_mm, spacing_cm, germ_min, germ_max, mat_min, mat_max, frost)

UPDATE vegetables AS v
SET
    sowing_method        = d.sm,
    seed_depth_mm        = d.sd,
    spacing_cm           = d.sp,
    germination_days_min = d.gn,
    germination_days_max = d.gx,
    days_to_maturity_min = d.mn,
    days_to_maturity_max = d.mx,
    frost_tolerance      = d.ft
FROM (VALUES
    ('Nasturtium',  'direct', 12,  20,  7,  14,  50,  60,  'tender'),
    ('Calendula',   'direct',  6,  30,  5,  10,  50,  70,  'hardy'),
    ('Lavender',    'indoor',  3,  45, 14,  21,  90, 120,  'half_hardy'),
    ('Viola',       'indoor',  3,  20, 10,  14,  60,  80,  'hardy'),
    ('Sunflower',   'both',   25,  60,  7,  10,  70, 100,  'tender'),
    ('Cornflower',  'direct',  3,  30,  7,  14,  60,  75,  'hardy'),
    ('Chamomile',   'direct',  2,  20,  7,  14,  45,  60,  'hardy'),
    ('Elderflower', 'both',    3, 300, 21,  28, 365, 730,  'hardy'),
    ('Rose',        'both',    3,  60, 21,  28,  90, 120,  'half_hardy')
) AS d(nm, sm, sd, sp, gn, gx, mn, mx, ft)
WHERE v.name = d.nm;

-- ============================================================
-- PRUNING INFO
-- ============================================================

UPDATE vegetables SET pruning_type = 'deadheading',
    pruning_tip = 'Pick spent flowers regularly to encourage continuous blooming throughout summer. Nasturtiums self-seed freely — leave a few flowers to set seed if you want plants to return naturally next year.'
WHERE name = 'Nasturtium';

UPDATE vegetables SET pruning_type = 'deadheading',
    pruning_tip = 'Remove spent flower heads regularly, including the green calyx beneath, to prevent seed formation and extend the flowering season well into autumn.'
WHERE name = 'Calendula';

UPDATE vegetables SET pruning_type = 'cutting_back',
    pruning_tip = 'Trim lightly after flowering each year, removing spent flower stems and about 3 cm of foliage growth. In spring, cut back to fresh green growth — never into old woody stems as lavender will not regrow from bare wood.'
WHERE name = 'Lavender';

UPDATE vegetables SET pruning_type = 'deadheading',
    pruning_tip = 'Pick flowers and remove spent blooms every day or two to keep the plant flowering. Cut plants back by half in midsummer if they become leggy and they will put on a second flush of growth and flowers.'
WHERE name = 'Viola';

UPDATE vegetables SET pruning_type = 'deadheading',
    pruning_tip = 'Remove spent blooms on branching varieties to encourage further flower production. For single-stem varieties grown for cut flowers, harvest the bloom when outer petals are just opening — no further deadheading is needed.'
WHERE name = 'Sunflower';

UPDATE vegetables SET pruning_type = 'deadheading',
    pruning_tip = 'Deadhead regularly by removing spent flowers back to a side bud to encourage a long succession of blooms through summer. This also prevents excessive self-seeding if you want to control the plant.'
WHERE name = 'Cornflower';

UPDATE vegetables SET pruning_type = 'deadheading',
    pruning_tip = 'Harvest flowers as soon as they fully open by gently rubbing them off the stems. Picking every few days keeps the plant in full bloom and prevents seed set if you want to limit self-seeding.'
WHERE name = 'Chamomile';

UPDATE vegetables SET pruning_type = 'cutting_back',
    pruning_tip = 'In late winter cut back one third of the oldest stems to ground level to keep the shrub productive and well-shaped. Lightly trim the remaining stems after flowering. Hard renovation pruning every few years will rejuvenate an old or overgrown plant.'
WHERE name = 'Elderflower';

UPDATE vegetables SET pruning_type = 'deadheading',
    pruning_tip = 'Remove spent blooms by cutting the stem back to the first outward-facing leaf with five leaflets to encourage repeat flowering. In late winter, prune all stems back by a third, cutting to an outward-facing bud, and remove dead or crossing wood entirely.'
WHERE name = 'Rose';

-- ============================================================
-- COMPANION PLANTS
-- ============================================================

-- Nasturtium: good companions
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Nasturtium' AND v2.name = 'Tomato';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Nasturtium' AND v2.name = 'Cucumber';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Nasturtium' AND v2.name = 'Kale';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Nasturtium' AND v2.name = 'Bean';

-- Nasturtium: bad companions
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Nasturtium' AND v2.name = 'Fennel';

-- Calendula: good companions
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Calendula' AND v2.name = 'Tomato';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Calendula' AND v2.name = 'Carrot';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Calendula' AND v2.name = 'Asparagus';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Calendula' AND v2.name = 'Bean';

-- Lavender: good companions
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Lavender' AND v2.name = 'Carrot';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Lavender' AND v2.name = 'Cabbage';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Lavender' AND v2.name = 'Rosemary';

-- Sunflower: good companions
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Sunflower' AND v2.name = 'Cucumber';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Sunflower' AND v2.name = 'Squash';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Sunflower' AND v2.name = 'Pumpkin';

-- Sunflower: bad companions
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Sunflower' AND v2.name = 'Potato';

-- Chamomile: good companions
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Chamomile' AND v2.name = 'Cabbage';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Chamomile' AND v2.name = 'Cucumber';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Chamomile' AND v2.name = 'Onion';

-- Rose: good companions
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Rose' AND v2.name = 'Garlic';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Rose' AND v2.name = 'Chive';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Rose' AND v2.name = 'Lavender';

-- Rose: bad companions
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Rose' AND v2.name = 'Fennel';
