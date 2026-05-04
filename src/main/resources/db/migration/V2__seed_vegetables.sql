WITH inserted AS (
    INSERT INTO vegetables (id, name, category, emoji) VALUES
        (gen_random_uuid(), 'Tomato',      'Fruiting', '🍅'),
        (gen_random_uuid(), 'Cucumber',    'Fruiting', '🥒'),
        (gen_random_uuid(), 'Bell Pepper', 'Fruiting', '🫑'),
        (gen_random_uuid(), 'Zucchini',    'Fruiting', '🥬'),
        (gen_random_uuid(), 'Pumpkin',     'Fruiting', '🎃'),
        (gen_random_uuid(), 'Sweetcorn',   'Fruiting', '🌽'),
        (gen_random_uuid(), 'Lettuce',     'Leafy',    '🥗'),
        (gen_random_uuid(), 'Spinach',     'Leafy',    '🌿'),
        (gen_random_uuid(), 'Rocket',      'Leafy',    '🌱'),
        (gen_random_uuid(), 'Kale',        'Brassica', '🥦'),
        (gen_random_uuid(), 'Cabbage',     'Brassica', '🥦'),
        (gen_random_uuid(), 'Broccoli',    'Brassica', '🥦'),
        (gen_random_uuid(), 'Cauliflower', 'Brassica', '🥦'),
        (gen_random_uuid(), 'Carrot',      'Root',     '🥕'),
        (gen_random_uuid(), 'Radish',      'Root',     '🌰'),
        (gen_random_uuid(), 'Beetroot',    'Root',     '🍠'),
        (gen_random_uuid(), 'Onion',       'Root',     '🧅'),
        (gen_random_uuid(), 'Leek',        'Root',     '🥬'),
        (gen_random_uuid(), 'Pea',         'Legume',   '🫛'),
        (gen_random_uuid(), 'Bean',        'Legume',   '🫘'),
        (gen_random_uuid(), 'Parsley',     'Herb',     '🌿'),
        (gen_random_uuid(), 'Basil',       'Herb',     '🌿'),
        (gen_random_uuid(), 'Dill',        'Herb',     '🌿'),
        (gen_random_uuid(), 'Fennel',      'Herb',     '🌿')
    RETURNING id, name
)
INSERT INTO seeding_months (vegetable_id, month_num)
SELECT v.id, m.month_num
FROM inserted v
JOIN (VALUES
    ('Tomato',      2), ('Tomato',      3), ('Tomato',      4),
    ('Cucumber',    3), ('Cucumber',    4), ('Cucumber',    5),
    ('Bell Pepper', 2), ('Bell Pepper', 3),
    ('Zucchini',    4), ('Zucchini',    5),
    ('Pumpkin',     4), ('Pumpkin',     5),
    ('Sweetcorn',   5),
    ('Lettuce',     3), ('Lettuce',     4), ('Lettuce',     5), ('Lettuce',     6), ('Lettuce',     7), ('Lettuce',     8), ('Lettuce',     9),
    ('Spinach',     2), ('Spinach',     3), ('Spinach',     4), ('Spinach',     8), ('Spinach',     9),
    ('Rocket',      4), ('Rocket',      5), ('Rocket',      6), ('Rocket',      7), ('Rocket',      8), ('Rocket',      9),
    ('Kale',        4), ('Kale',        5), ('Kale',        6), ('Kale',        7),
    ('Cabbage',     3), ('Cabbage',     4), ('Cabbage',     5),
    ('Broccoli',    3), ('Broccoli',    4), ('Broccoli',    5), ('Broccoli',    6), ('Broccoli',    7),
    ('Cauliflower', 4), ('Cauliflower', 5), ('Cauliflower', 6),
    ('Carrot',      3), ('Carrot',      4), ('Carrot',      5), ('Carrot',      6), ('Carrot',      7),
    ('Radish',      3), ('Radish',      4), ('Radish',      5), ('Radish',      6), ('Radish',      7), ('Radish',      8), ('Radish',      9),
    ('Beetroot',    4), ('Beetroot',    5), ('Beetroot',    6),
    ('Onion',       3), ('Onion',       4),
    ('Leek',        2), ('Leek',        3), ('Leek',        4),
    ('Pea',         3), ('Pea',         4), ('Pea',         5),
    ('Bean',        5), ('Bean',        6), ('Bean',        7),
    ('Parsley',     3), ('Parsley',     4), ('Parsley',     5), ('Parsley',     6), ('Parsley',     7), ('Parsley',     8),
    ('Basil',       4), ('Basil',       5),
    ('Dill',        4), ('Dill',        5), ('Dill',        6), ('Dill',        7), ('Dill',        8),
    ('Fennel',      4), ('Fennel',      5), ('Fennel',      6)
) AS m(veg_name, month_num) ON v.name = m.veg_name;
