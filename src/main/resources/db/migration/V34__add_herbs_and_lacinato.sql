-- V34: Add Tarragon, Lovage, and Lacinato Kale
-- Note: Chamomile (kamille) was already added in V33.

-- ============================================================
-- INSERT VEGETABLES
-- ============================================================

INSERT INTO vegetables (id, name, category, emoji) VALUES
    (gen_random_uuid(), 'Tarragon',      'Herb',     '🌿'),
    (gen_random_uuid(), 'Lovage',        'Herb',     '🌿'),
    (gen_random_uuid(), 'Lacinato Kale', 'Brassica', '🥬');

-- ============================================================
-- SEEDING MONTHS (global, no country)
-- ============================================================

INSERT INTO seeding_months (vegetable_id, month_num)
SELECT v.id, m.month_num
FROM vegetables v
JOIN (VALUES
    ('Tarragon',      3), ('Tarragon',      4), ('Tarragon',      5),
    ('Lovage',        3), ('Lovage',        4),
    ('Lacinato Kale', 4), ('Lacinato Kale', 5), ('Lacinato Kale', 6)
) AS m(veg_name, month_num) ON v.name = m.veg_name;

-- ============================================================
-- HARVESTING MONTHS (global, no country)
-- ============================================================

INSERT INTO harvesting_months (vegetable_id, month_num)
SELECT v.id, m.month_num
FROM vegetables v
JOIN (VALUES
    ('Tarragon',      5), ('Tarragon',      6), ('Tarragon',      7),
    ('Tarragon',      8), ('Tarragon',      9),
    ('Lovage',        4), ('Lovage',        5), ('Lovage',        6),
    ('Lovage',        7), ('Lovage',        8),
    ('Lacinato Kale', 9), ('Lacinato Kale', 10), ('Lacinato Kale', 11),
    ('Lacinato Kale', 12), ('Lacinato Kale', 1), ('Lacinato Kale', 2)
) AS m(veg_name, month_num) ON v.name = m.veg_name;

-- ============================================================
-- VEGETABLE COUNTRIES
-- ============================================================

INSERT INTO vegetable_countries (vegetable_id, country_code)
SELECT v.id, m.country_code
FROM vegetables v
JOIN (VALUES
    -- Tarragon: French origin, widely grown temperate
    ('Tarragon', 'FR'), ('Tarragon', 'IT'), ('Tarragon', 'ES'), ('Tarragon', 'PT'),
    ('Tarragon', 'HR'), ('Tarragon', 'SI'), ('Tarragon', 'DE'), ('Tarragon', 'NL'),
    ('Tarragon', 'BE'), ('Tarragon', 'GB'), ('Tarragon', 'IE'), ('Tarragon', 'AT'),
    ('Tarragon', 'CH'), ('Tarragon', 'DK'), ('Tarragon', 'SE'), ('Tarragon', 'NO'),
    ('Tarragon', 'PL'), ('Tarragon', 'CZ'), ('Tarragon', 'LU'),
    ('Tarragon', 'US'), ('Tarragon', 'CA'), ('Tarragon', 'AU'), ('Tarragon', 'NZ'),

    -- Lovage: northern and central European culinary herb
    ('Lovage', 'DE'), ('Lovage', 'AT'), ('Lovage', 'CH'), ('Lovage', 'CZ'),
    ('Lovage', 'SK'), ('Lovage', 'PL'), ('Lovage', 'HU'), ('Lovage', 'RO'),
    ('Lovage', 'NL'), ('Lovage', 'BE'), ('Lovage', 'FR'), ('Lovage', 'GB'),
    ('Lovage', 'IE'), ('Lovage', 'DK'), ('Lovage', 'SE'), ('Lovage', 'NO'),
    ('Lovage', 'FI'), ('Lovage', 'IT'), ('Lovage', 'LU'),
    ('Lovage', 'US'), ('Lovage', 'CA'), ('Lovage', 'AU'),

    -- Lacinato Kale: Tuscan origin, widely grown
    ('Lacinato Kale', 'IT'), ('Lacinato Kale', 'ES'), ('Lacinato Kale', 'PT'),
    ('Lacinato Kale', 'FR'), ('Lacinato Kale', 'HR'), ('Lacinato Kale', 'SI'),
    ('Lacinato Kale', 'DE'), ('Lacinato Kale', 'NL'), ('Lacinato Kale', 'BE'),
    ('Lacinato Kale', 'GB'), ('Lacinato Kale', 'IE'), ('Lacinato Kale', 'AT'),
    ('Lacinato Kale', 'CH'), ('Lacinato Kale', 'DK'), ('Lacinato Kale', 'SE'),
    ('Lacinato Kale', 'NO'), ('Lacinato Kale', 'FI'), ('Lacinato Kale', 'PL'),
    ('Lacinato Kale', 'CZ'),
    ('Lacinato Kale', 'US'), ('Lacinato Kale', 'CA'), ('Lacinato Kale', 'AU'),
    ('Lacinato Kale', 'NZ'), ('Lacinato Kale', 'ZA')

) AS m(veg_name, country_code) ON v.name = m.veg_name;

-- ============================================================
-- SUN REQUIREMENT
-- ============================================================

UPDATE vegetables SET sun_requirement = 'full_sun'
WHERE name = 'Tarragon';

UPDATE vegetables SET sun_requirement = 'partial_shade'
WHERE name IN ('Lovage', 'Lacinato Kale');

-- ============================================================
-- SOWING INFO
-- ============================================================

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
    ('Tarragon',      'indoor',  3,  30, 14, 21, 60,  90, 'half_hardy'),
    ('Lovage',        'both',    3,  60, 10, 14, 60,  90, 'hardy'),
    ('Lacinato Kale', 'indoor',  6,  45,  5, 10, 60,  90, 'very_hardy')
) AS d(nm, sm, sd, sp, gn, gx, mn, mx, ft)
WHERE v.name = d.nm;

-- ============================================================
-- PRUNING INFO
-- ============================================================

UPDATE vegetables SET pruning_type = 'cutting_back',
    pruning_tip = 'Cut back by half in midsummer after the first flush of growth to encourage fresh, bushy new shoots. In autumn, cut the whole plant back to 10 cm above the base. Divide clumps every 3–4 years to keep the plant vigorous.'
WHERE name = 'Tarragon';

UPDATE vegetables SET pruning_type = 'cutting_back',
    pruning_tip = 'Cut back hard to ground level in midsummer after flowering to encourage a second flush of fresh young leaves. Divide the clump every 2–3 years in spring as it grows very vigorously and can become crowded.'
WHERE name = 'Lovage';

UPDATE vegetables SET pruning_type = 'leaf_removal',
    pruning_tip = 'Harvest outer leaves from the base of the plant regularly — this acts as natural pruning. Remove yellowing or damaged leaves promptly to prevent disease. The growing point at the top remains intact, giving months of continuous harvest.'
WHERE name = 'Lacinato Kale';

-- ============================================================
-- COMPANION PLANTS
-- ============================================================

-- Tarragon: good with tomato and eggplant (pest deterrent)
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Tarragon' AND v2.name = 'Tomato';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Tarragon' AND v2.name = 'Eggplant';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Tarragon' AND v2.name = 'Bell Pepper';

-- Lovage: good with bean, pea, carrot (general pollinator attractant)
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Lovage' AND v2.name = 'Bean';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Lovage' AND v2.name = 'Carrot';

-- Lacinato Kale: similar companions to Kale
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Lacinato Kale' AND v2.name = 'Nasturtium';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Lacinato Kale' AND v2.name = 'Celery';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Lacinato Kale' AND v2.name = 'Tomato';

INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2
WHERE v1.name = 'Lacinato Kale' AND v2.name = 'Fennel';
