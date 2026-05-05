-- Insert new vegetables from Wikipedia's List of Vegetables
-- Skips the 24 already seeded in V2 (Tomato, Cucumber, Bell Pepper, etc.)

INSERT INTO vegetables (id, name, category, emoji) VALUES
    -- Leafy / Salad
    (gen_random_uuid(), 'Bok Choy',        'Leafy',    '🥬'),
    (gen_random_uuid(), 'Swiss Chard',     'Leafy',    '🌿'),
    (gen_random_uuid(), 'Watercress',      'Leafy',    '🌿'),
    (gen_random_uuid(), 'Endive',          'Leafy',    '🥬'),
    (gen_random_uuid(), 'Radicchio',       'Leafy',    '🥬'),
    (gen_random_uuid(), 'Chicory',         'Leafy',    '🌿'),
    (gen_random_uuid(), 'Lamb''s Lettuce', 'Leafy',    '🌿'),
    (gen_random_uuid(), 'Sorrel',          'Leafy',    '🌿'),
    (gen_random_uuid(), 'Mizuna',          'Leafy',    '🌿'),
    (gen_random_uuid(), 'Collard Greens',  'Leafy',    '🌿'),
    (gen_random_uuid(), 'Mustard Greens',  'Leafy',    '🌿'),
    (gen_random_uuid(), 'Artichoke',       'Leafy',    '🌱'),

    -- Brassica
    (gen_random_uuid(), 'Brussels Sprouts','Brassica', '🥦'),
    (gen_random_uuid(), 'Kohlrabi',        'Brassica', '🥦'),
    (gen_random_uuid(), 'Turnip',          'Brassica', '🌱'),
    (gen_random_uuid(), 'Napa Cabbage',    'Brassica', '🥬'),
    (gen_random_uuid(), 'Rapini',          'Brassica', '🥦'),

    -- Fruiting
    (gen_random_uuid(), 'Eggplant',        'Fruiting', '🍆'),
    (gen_random_uuid(), 'Chili Pepper',    'Fruiting', '🌶️'),
    (gen_random_uuid(), 'Squash',          'Fruiting', '🎃'),

    -- Root / Bulb / Stem
    (gen_random_uuid(), 'Potato',          'Root',     '🥔'),
    (gen_random_uuid(), 'Sweet Potato',    'Root',     '🍠'),
    (gen_random_uuid(), 'Parsnip',         'Root',     '🥕'),
    (gen_random_uuid(), 'Jerusalem Artichoke', 'Root', '🌱'),
    (gen_random_uuid(), 'Celeriac',        'Root',     '🌿'),
    (gen_random_uuid(), 'Daikon',          'Root',     '🌱'),
    (gen_random_uuid(), 'Garlic',          'Root',     '🧄'),
    (gen_random_uuid(), 'Shallot',         'Root',     '🧅'),
    (gen_random_uuid(), 'Spring Onion',    'Root',     '🧅'),
    (gen_random_uuid(), 'Celery',          'Root',     '🌿'),
    (gen_random_uuid(), 'Asparagus',       'Root',     '🌱'),

    -- Legume
    (gen_random_uuid(), 'Broad Bean',      'Legume',   '🫘'),
    (gen_random_uuid(), 'Runner Bean',     'Legume',   '🫘'),
    (gen_random_uuid(), 'Snap Pea',        'Legume',   '🫛'),
    (gen_random_uuid(), 'Lentil',          'Legume',   '🫘'),
    (gen_random_uuid(), 'Soybean',         'Legume',   '🫘'),

    -- Herb
    (gen_random_uuid(), 'Chive',           'Herb',     '🌿'),
    (gen_random_uuid(), 'Coriander',       'Herb',     '🌿'),
    (gen_random_uuid(), 'Mint',            'Herb',     '🌿'),
    (gen_random_uuid(), 'Thyme',           'Herb',     '🌿'),
    (gen_random_uuid(), 'Rosemary',        'Herb',     '🌿'),
    (gen_random_uuid(), 'Oregano',         'Herb',     '🌿'),
    (gen_random_uuid(), 'Sage',            'Herb',     '🌿'),
    (gen_random_uuid(), 'Chervil',         'Herb',     '🌿'),
    (gen_random_uuid(), 'Lemongrass',      'Herb',     '🌿');

-- Seeding months (temperate / European climate)
INSERT INTO seeding_months (vegetable_id, month_num)
SELECT v.id, m.month_num
FROM vegetables v
JOIN (VALUES
    ('Bok Choy',         3), ('Bok Choy',         4), ('Bok Choy',         5), ('Bok Choy',         8), ('Bok Choy',         9),
    ('Swiss Chard',      3), ('Swiss Chard',      4), ('Swiss Chard',      5), ('Swiss Chard',      6),
    ('Watercress',       3), ('Watercress',       4), ('Watercress',       5),
    ('Endive',           5), ('Endive',           6), ('Endive',           7),
    ('Radicchio',        5), ('Radicchio',        6), ('Radicchio',        7),
    ('Chicory',          4), ('Chicory',          5), ('Chicory',          6),
    ('Lamb''s Lettuce',  8), ('Lamb''s Lettuce',  9), ('Lamb''s Lettuce', 10),
    ('Sorrel',           3), ('Sorrel',           4), ('Sorrel',           5),
    ('Mizuna',           3), ('Mizuna',           4), ('Mizuna',           5), ('Mizuna',           8), ('Mizuna',           9),
    ('Collard Greens',   3), ('Collard Greens',   4), ('Collard Greens',   5),
    ('Mustard Greens',   3), ('Mustard Greens',   4), ('Mustard Greens',   5), ('Mustard Greens',   8), ('Mustard Greens',   9),
    ('Artichoke',        3), ('Artichoke',        4),
    ('Brussels Sprouts', 4), ('Brussels Sprouts', 5),
    ('Kohlrabi',         3), ('Kohlrabi',         4), ('Kohlrabi',         5), ('Kohlrabi',         7), ('Kohlrabi',         8),
    ('Turnip',           3), ('Turnip',           4), ('Turnip',           7), ('Turnip',           8),
    ('Napa Cabbage',     6), ('Napa Cabbage',     7), ('Napa Cabbage',     8),
    ('Rapini',           3), ('Rapini',           4), ('Rapini',           8), ('Rapini',           9),
    ('Eggplant',         2), ('Eggplant',         3),
    ('Chili Pepper',     2), ('Chili Pepper',     3), ('Chili Pepper',     4),
    ('Squash',           4), ('Squash',           5),
    ('Potato',           3), ('Potato',           4), ('Potato',           5),
    ('Sweet Potato',     4), ('Sweet Potato',     5),
    ('Parsnip',          3), ('Parsnip',          4), ('Parsnip',          5),
    ('Jerusalem Artichoke', 3), ('Jerusalem Artichoke', 4),
    ('Celeriac',         2), ('Celeriac',         3),
    ('Daikon',           8), ('Daikon',           9),
    ('Garlic',          10), ('Garlic',          11),
    ('Shallot',          3), ('Shallot',          4),
    ('Spring Onion',     3), ('Spring Onion',     4), ('Spring Onion',     5), ('Spring Onion',     6), ('Spring Onion',     7),
    ('Celery',           3), ('Celery',           4),
    ('Asparagus',        3), ('Asparagus',        4),
    ('Broad Bean',       2), ('Broad Bean',       3), ('Broad Bean',       4), ('Broad Bean',      10), ('Broad Bean',      11),
    ('Runner Bean',      5), ('Runner Bean',      6),
    ('Snap Pea',         3), ('Snap Pea',         4), ('Snap Pea',         5),
    ('Lentil',           3), ('Lentil',           4),
    ('Soybean',          5), ('Soybean',          6),
    ('Chive',            3), ('Chive',            4), ('Chive',            5),
    ('Coriander',        4), ('Coriander',        5), ('Coriander',        6), ('Coriander',        8), ('Coriander',        9),
    ('Mint',             3), ('Mint',             4), ('Mint',             5),
    ('Thyme',            3), ('Thyme',            4), ('Thyme',            5),
    ('Rosemary',         3), ('Rosemary',         4),
    ('Oregano',          3), ('Oregano',          4), ('Oregano',          5),
    ('Sage',             3), ('Sage',             4),
    ('Chervil',          3), ('Chervil',          4), ('Chervil',          5), ('Chervil',          8), ('Chervil',          9),
    ('Lemongrass',       3), ('Lemongrass',       4)
) AS m(veg_name, month_num) ON v.name = m.veg_name;

-- Harvesting months (temperate / European climate)
INSERT INTO harvesting_months (vegetable_id, month_num)
SELECT v.id, m.month_num
FROM vegetables v
JOIN (VALUES
    ('Bok Choy',         5), ('Bok Choy',         6), ('Bok Choy',         7), ('Bok Choy',        10), ('Bok Choy',        11),
    ('Swiss Chard',      6), ('Swiss Chard',      7), ('Swiss Chard',      8), ('Swiss Chard',      9), ('Swiss Chard',     10),
    ('Watercress',       5), ('Watercress',       6), ('Watercress',       7), ('Watercress',       8), ('Watercress',       9),
    ('Endive',           8), ('Endive',           9), ('Endive',          10), ('Endive',          11),
    ('Radicchio',        8), ('Radicchio',        9), ('Radicchio',       10), ('Radicchio',       11),
    ('Chicory',          7), ('Chicory',           8), ('Chicory',          9), ('Chicory',         10),
    ('Lamb''s Lettuce', 10), ('Lamb''s Lettuce', 11), ('Lamb''s Lettuce', 12),
    ('Sorrel',           5), ('Sorrel',           6), ('Sorrel',           7), ('Sorrel',           8), ('Sorrel',           9),
    ('Mizuna',           5), ('Mizuna',           6), ('Mizuna',           7), ('Mizuna',           9), ('Mizuna',          10),
    ('Collard Greens',   6), ('Collard Greens',   7), ('Collard Greens',   8), ('Collard Greens',   9), ('Collard Greens',  10), ('Collard Greens',  11),
    ('Mustard Greens',   4), ('Mustard Greens',   5), ('Mustard Greens',   6), ('Mustard Greens',   9), ('Mustard Greens',  10),
    ('Artichoke',        6), ('Artichoke',        7), ('Artichoke',        8),
    ('Brussels Sprouts', 9), ('Brussels Sprouts',10), ('Brussels Sprouts',11), ('Brussels Sprouts',12),
    ('Kohlrabi',         5), ('Kohlrabi',         6), ('Kohlrabi',         7), ('Kohlrabi',         9), ('Kohlrabi',        10),
    ('Turnip',           5), ('Turnip',           6), ('Turnip',           9), ('Turnip',          10),
    ('Napa Cabbage',     9), ('Napa Cabbage',    10), ('Napa Cabbage',    11),
    ('Rapini',           4), ('Rapini',           5), ('Rapini',           9), ('Rapini',          10),
    ('Eggplant',         7), ('Eggplant',         8), ('Eggplant',         9),
    ('Chili Pepper',     7), ('Chili Pepper',     8), ('Chili Pepper',     9), ('Chili Pepper',    10),
    ('Squash',           8), ('Squash',           9), ('Squash',          10),
    ('Potato',           7), ('Potato',           8), ('Potato',           9),
    ('Sweet Potato',     9), ('Sweet Potato',    10),
    ('Parsnip',          9), ('Parsnip',         10), ('Parsnip',         11), ('Parsnip',         12),
    ('Jerusalem Artichoke',10), ('Jerusalem Artichoke',11), ('Jerusalem Artichoke',12),
    ('Celeriac',         9), ('Celeriac',        10), ('Celeriac',        11),
    ('Daikon',          10), ('Daikon',          11),
    ('Garlic',           6), ('Garlic',           7),
    ('Shallot',          7), ('Shallot',          8),
    ('Spring Onion',     5), ('Spring Onion',     6), ('Spring Onion',     7), ('Spring Onion',     8), ('Spring Onion',     9),
    ('Celery',           8), ('Celery',           9), ('Celery',          10),
    ('Asparagus',        4), ('Asparagus',        5), ('Asparagus',        6),
    ('Broad Bean',       5), ('Broad Bean',       6), ('Broad Bean',       7),
    ('Runner Bean',      7), ('Runner Bean',      8), ('Runner Bean',      9), ('Runner Bean',     10),
    ('Snap Pea',         5), ('Snap Pea',         6), ('Snap Pea',         7),
    ('Lentil',           7), ('Lentil',           8),
    ('Soybean',          9), ('Soybean',         10),
    ('Chive',            5), ('Chive',            6), ('Chive',            7), ('Chive',            8), ('Chive',            9), ('Chive',           10),
    ('Coriander',        5), ('Coriander',        6), ('Coriander',        7), ('Coriander',        8), ('Coriander',        9), ('Coriander',       10),
    ('Mint',             5), ('Mint',             6), ('Mint',             7), ('Mint',             8), ('Mint',             9), ('Mint',            10),
    ('Thyme',            5), ('Thyme',            6), ('Thyme',            7), ('Thyme',            8), ('Thyme',            9), ('Thyme',           10),
    ('Rosemary',         5), ('Rosemary',         6), ('Rosemary',         7), ('Rosemary',         8), ('Rosemary',         9), ('Rosemary',        10), ('Rosemary',        11),
    ('Oregano',          5), ('Oregano',          6), ('Oregano',          7), ('Oregano',          8), ('Oregano',          9), ('Oregano',         10),
    ('Sage',             5), ('Sage',             6), ('Sage',             7), ('Sage',             8), ('Sage',             9), ('Sage',            10),
    ('Chervil',          4), ('Chervil',          5), ('Chervil',          6), ('Chervil',          9), ('Chervil',         10), ('Chervil',         11),
    ('Lemongrass',       7), ('Lemongrass',       8), ('Lemongrass',       9), ('Lemongrass',      10)
) AS m(veg_name, month_num) ON v.name = m.veg_name;
