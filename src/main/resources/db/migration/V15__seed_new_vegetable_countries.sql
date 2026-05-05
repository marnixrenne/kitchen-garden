INSERT INTO vegetable_countries (vegetable_id, country_code)
SELECT v.id, m.country_code
FROM vegetables v
JOIN (VALUES
    -- =========================================================
    -- LEAFY GREENS (V12)
    -- =========================================================

    -- Bok Choy: Asian origin, widely grown in Europe and globally
    ('Bok Choy', 'NL'), ('Bok Choy', 'DE'), ('Bok Choy', 'GB'), ('Bok Choy', 'BE'), ('Bok Choy', 'FR'),
    ('Bok Choy', 'AT'), ('Bok Choy', 'DK'), ('Bok Choy', 'SE'),
    ('Bok Choy', 'CN'), ('Bok Choy', 'JP'), ('Bok Choy', 'IN'),
    ('Bok Choy', 'US'), ('Bok Choy', 'CA'), ('Bok Choy', 'AU'), ('Bok Choy', 'NZ'),

    -- Swiss Chard: widely grown across all temperate regions
    ('Swiss Chard', 'AT'), ('Swiss Chard', 'BE'), ('Swiss Chard', 'CH'), ('Swiss Chard', 'CZ'),
    ('Swiss Chard', 'DE'), ('Swiss Chard', 'DK'), ('Swiss Chard', 'ES'), ('Swiss Chard', 'FR'),
    ('Swiss Chard', 'GB'), ('Swiss Chard', 'HR'), ('Swiss Chard', 'HU'), ('Swiss Chard', 'IE'),
    ('Swiss Chard', 'IT'), ('Swiss Chard', 'LU'), ('Swiss Chard', 'NL'), ('Swiss Chard', 'NO'),
    ('Swiss Chard', 'PL'), ('Swiss Chard', 'PT'), ('Swiss Chard', 'RO'), ('Swiss Chard', 'SE'),
    ('Swiss Chard', 'SI'), ('Swiss Chard', 'SK'), ('Swiss Chard', 'UA'),
    ('Swiss Chard', 'US'), ('Swiss Chard', 'CA'), ('Swiss Chard', 'AU'), ('Swiss Chard', 'NZ'),
    ('Swiss Chard', 'ZA'), ('Swiss Chard', 'CN'),

    -- Watercress: aquatic plant, widely cultivated
    ('Watercress', 'GB'), ('Watercress', 'IE'), ('Watercress', 'FR'), ('Watercress', 'DE'),
    ('Watercress', 'NL'), ('Watercress', 'BE'), ('Watercress', 'AT'), ('Watercress', 'CH'),
    ('Watercress', 'ES'), ('Watercress', 'PT'), ('Watercress', 'IT'),
    ('Watercress', 'US'), ('Watercress', 'CA'), ('Watercress', 'AU'), ('Watercress', 'NZ'),

    -- Endive: Belgian/French origin, widely grown
    ('Endive', 'BE'), ('Endive', 'FR'), ('Endive', 'NL'), ('Endive', 'DE'), ('Endive', 'CH'),
    ('Endive', 'AT'), ('Endive', 'LU'), ('Endive', 'IT'), ('Endive', 'ES'), ('Endive', 'GB'),
    ('Endive', 'DK'), ('Endive', 'SE'),
    ('Endive', 'US'), ('Endive', 'CA'), ('Endive', 'AU'),

    -- Radicchio: Italian origin, specialty European
    ('Radicchio', 'IT'), ('Radicchio', 'HR'), ('Radicchio', 'SI'), ('Radicchio', 'AT'),
    ('Radicchio', 'CH'), ('Radicchio', 'DE'), ('Radicchio', 'FR'), ('Radicchio', 'NL'),
    ('Radicchio', 'GB'), ('Radicchio', 'BE'), ('Radicchio', 'ES'),
    ('Radicchio', 'US'), ('Radicchio', 'CA'), ('Radicchio', 'AU'),

    -- Chicory: Belgian/French origin, widely grown
    ('Chicory', 'BE'), ('Chicory', 'FR'), ('Chicory', 'NL'), ('Chicory', 'DE'), ('Chicory', 'IT'),
    ('Chicory', 'AT'), ('Chicory', 'CH'), ('Chicory', 'LU'), ('Chicory', 'DK'), ('Chicory', 'SE'),
    ('Chicory', 'GB'), ('Chicory', 'IE'), ('Chicory', 'CZ'), ('Chicory', 'PL'), ('Chicory', 'ES'),
    ('Chicory', 'US'), ('Chicory', 'CA'),

    -- Lamb's Lettuce: European salad staple
    ('Lamb''s Lettuce', 'DE'), ('Lamb''s Lettuce', 'AT'), ('Lamb''s Lettuce', 'CH'), ('Lamb''s Lettuce', 'FR'),
    ('Lamb''s Lettuce', 'NL'), ('Lamb''s Lettuce', 'BE'), ('Lamb''s Lettuce', 'IT'), ('Lamb''s Lettuce', 'ES'),
    ('Lamb''s Lettuce', 'PT'), ('Lamb''s Lettuce', 'GB'), ('Lamb''s Lettuce', 'DK'), ('Lamb''s Lettuce', 'SE'),
    ('Lamb''s Lettuce', 'LU'), ('Lamb''s Lettuce', 'CZ'), ('Lamb''s Lettuce', 'PL'),
    ('Lamb''s Lettuce', 'US'), ('Lamb''s Lettuce', 'CA'), ('Lamb''s Lettuce', 'AU'), ('Lamb''s Lettuce', 'NZ'),

    -- Sorrel: European perennial herb/green
    ('Sorrel', 'FR'), ('Sorrel', 'DE'), ('Sorrel', 'NL'), ('Sorrel', 'BE'), ('Sorrel', 'AT'),
    ('Sorrel', 'CH'), ('Sorrel', 'GB'), ('Sorrel', 'IE'), ('Sorrel', 'DK'), ('Sorrel', 'SE'),
    ('Sorrel', 'NO'), ('Sorrel', 'FI'), ('Sorrel', 'PL'), ('Sorrel', 'CZ'), ('Sorrel', 'IT'),
    ('Sorrel', 'US'), ('Sorrel', 'CA'), ('Sorrel', 'AU'),

    -- Mizuna: Japanese origin, popular in Europe
    ('Mizuna', 'JP'), ('Mizuna', 'CN'),
    ('Mizuna', 'NL'), ('Mizuna', 'DE'), ('Mizuna', 'GB'), ('Mizuna', 'FR'), ('Mizuna', 'BE'),
    ('Mizuna', 'US'), ('Mizuna', 'CA'), ('Mizuna', 'AU'), ('Mizuna', 'NZ'),

    -- Collard Greens: American South staple, grown globally
    ('Collard Greens', 'US'), ('Collard Greens', 'CA'), ('Collard Greens', 'BR'), ('Collard Greens', 'ZA'),
    ('Collard Greens', 'PT'), ('Collard Greens', 'ES'), ('Collard Greens', 'GB'),
    ('Collard Greens', 'NL'), ('Collard Greens', 'DE'), ('Collard Greens', 'AU'),

    -- Mustard Greens: Asian origin, widely grown
    ('Mustard Greens', 'CN'), ('Mustard Greens', 'JP'), ('Mustard Greens', 'IN'),
    ('Mustard Greens', 'US'), ('Mustard Greens', 'CA'),
    ('Mustard Greens', 'DE'), ('Mustard Greens', 'NL'), ('Mustard Greens', 'GB'), ('Mustard Greens', 'FR'),
    ('Mustard Greens', 'AU'),

    -- =========================================================
    -- BRASSICAS & RELATED (V12)
    -- =========================================================

    -- Artichoke: Mediterranean origin, grown globally
    ('Artichoke', 'IT'), ('Artichoke', 'ES'), ('Artichoke', 'FR'), ('Artichoke', 'PT'),
    ('Artichoke', 'HR'), ('Artichoke', 'SI'), ('Artichoke', 'DE'), ('Artichoke', 'NL'),
    ('Artichoke', 'BE'), ('Artichoke', 'GB'), ('Artichoke', 'AT'), ('Artichoke', 'CH'),
    ('Artichoke', 'US'), ('Artichoke', 'CA'), ('Artichoke', 'AU'), ('Artichoke', 'AR'), ('Artichoke', 'MX'),

    -- Brussels Sprouts: Belgian origin, widely grown
    ('Brussels Sprouts', 'BE'), ('Brussels Sprouts', 'NL'), ('Brussels Sprouts', 'GB'),
    ('Brussels Sprouts', 'DE'), ('Brussels Sprouts', 'FR'), ('Brussels Sprouts', 'IE'),
    ('Brussels Sprouts', 'DK'), ('Brussels Sprouts', 'SE'), ('Brussels Sprouts', 'NO'),
    ('Brussels Sprouts', 'AT'), ('Brussels Sprouts', 'CH'), ('Brussels Sprouts', 'LU'),
    ('Brussels Sprouts', 'US'), ('Brussels Sprouts', 'CA'), ('Brussels Sprouts', 'AU'), ('Brussels Sprouts', 'NZ'),

    -- Kohlrabi: central European staple
    ('Kohlrabi', 'DE'), ('Kohlrabi', 'AT'), ('Kohlrabi', 'CH'), ('Kohlrabi', 'CZ'), ('Kohlrabi', 'SK'),
    ('Kohlrabi', 'PL'), ('Kohlrabi', 'HU'), ('Kohlrabi', 'NL'), ('Kohlrabi', 'BE'), ('Kohlrabi', 'FR'),
    ('Kohlrabi', 'IT'), ('Kohlrabi', 'DK'), ('Kohlrabi', 'SE'), ('Kohlrabi', 'GB'),
    ('Kohlrabi', 'US'), ('Kohlrabi', 'CA'), ('Kohlrabi', 'CN'), ('Kohlrabi', 'IN'),

    -- Turnip: temperate regions, widely grown
    ('Turnip', 'GB'), ('Turnip', 'IE'), ('Turnip', 'FR'), ('Turnip', 'DE'), ('Turnip', 'NL'),
    ('Turnip', 'BE'), ('Turnip', 'AT'), ('Turnip', 'CH'), ('Turnip', 'DK'), ('Turnip', 'SE'),
    ('Turnip', 'NO'), ('Turnip', 'FI'), ('Turnip', 'PL'), ('Turnip', 'CZ'),
    ('Turnip', 'CN'), ('Turnip', 'JP'), ('Turnip', 'IN'),
    ('Turnip', 'US'), ('Turnip', 'CA'), ('Turnip', 'AU'),

    -- Napa Cabbage: Asian origin, widely grown
    ('Napa Cabbage', 'CN'), ('Napa Cabbage', 'JP'),
    ('Napa Cabbage', 'DE'), ('Napa Cabbage', 'NL'), ('Napa Cabbage', 'PL'), ('Napa Cabbage', 'CZ'),
    ('Napa Cabbage', 'AT'), ('Napa Cabbage', 'CH'), ('Napa Cabbage', 'GB'), ('Napa Cabbage', 'FR'),
    ('Napa Cabbage', 'BE'),
    ('Napa Cabbage', 'US'), ('Napa Cabbage', 'CA'), ('Napa Cabbage', 'AU'),

    -- Rapini: Italian origin, Mediterranean specialty
    ('Rapini', 'IT'), ('Rapini', 'ES'), ('Rapini', 'PT'), ('Rapini', 'HR'), ('Rapini', 'SI'),
    ('Rapini', 'FR'), ('Rapini', 'DE'), ('Rapini', 'NL'), ('Rapini', 'BE'), ('Rapini', 'GB'),
    ('Rapini', 'US'), ('Rapini', 'CA'), ('Rapini', 'AU'),

    -- =========================================================
    -- FRUITING VEGETABLES (V12)
    -- =========================================================

    -- Eggplant: warm-season, grown across Mediterranean and globally
    ('Eggplant', 'IT'), ('Eggplant', 'ES'), ('Eggplant', 'FR'), ('Eggplant', 'PT'),
    ('Eggplant', 'HR'), ('Eggplant', 'HU'), ('Eggplant', 'RO'), ('Eggplant', 'SI'),
    ('Eggplant', 'NL'), ('Eggplant', 'DE'), ('Eggplant', 'GB'), ('Eggplant', 'BE'), ('Eggplant', 'AT'),
    ('Eggplant', 'CN'), ('Eggplant', 'IN'), ('Eggplant', 'JP'),
    ('Eggplant', 'US'), ('Eggplant', 'CA'), ('Eggplant', 'AU'), ('Eggplant', 'ZA'),
    ('Eggplant', 'BR'), ('Eggplant', 'AR'), ('Eggplant', 'MX'),

    -- Chili Pepper: warm-season, widely grown globally
    ('Chili Pepper', 'ES'), ('Chili Pepper', 'IT'), ('Chili Pepper', 'HR'), ('Chili Pepper', 'HU'),
    ('Chili Pepper', 'PT'), ('Chili Pepper', 'RO'), ('Chili Pepper', 'SI'),
    ('Chili Pepper', 'NL'), ('Chili Pepper', 'DE'), ('Chili Pepper', 'FR'), ('Chili Pepper', 'GB'),
    ('Chili Pepper', 'BE'), ('Chili Pepper', 'AT'), ('Chili Pepper', 'CH'),
    ('Chili Pepper', 'MX'), ('Chili Pepper', 'IN'), ('Chili Pepper', 'CN'),
    ('Chili Pepper', 'US'), ('Chili Pepper', 'CA'), ('Chili Pepper', 'AU'), ('Chili Pepper', 'ZA'),
    ('Chili Pepper', 'BR'), ('Chili Pepper', 'AR'),

    -- Squash: very widely grown globally
    ('Squash', 'AT'), ('Squash', 'BE'), ('Squash', 'CH'), ('Squash', 'CZ'), ('Squash', 'DE'),
    ('Squash', 'DK'), ('Squash', 'ES'), ('Squash', 'FR'), ('Squash', 'GB'), ('Squash', 'HR'),
    ('Squash', 'HU'), ('Squash', 'IE'), ('Squash', 'IT'), ('Squash', 'NL'), ('Squash', 'NO'),
    ('Squash', 'PL'), ('Squash', 'PT'), ('Squash', 'RO'), ('Squash', 'SE'), ('Squash', 'SI'),
    ('Squash', 'SK'), ('Squash', 'UA'),
    ('Squash', 'US'), ('Squash', 'CA'), ('Squash', 'MX'), ('Squash', 'BR'), ('Squash', 'AR'),
    ('Squash', 'AU'), ('Squash', 'NZ'), ('Squash', 'ZA'), ('Squash', 'CN'), ('Squash', 'IN'),

    -- =========================================================
    -- ROOT VEGETABLES (V12)
    -- =========================================================

    -- Potato: universal crop
    ('Potato', 'AT'), ('Potato', 'BE'), ('Potato', 'CH'), ('Potato', 'CZ'), ('Potato', 'DE'),
    ('Potato', 'DK'), ('Potato', 'ES'), ('Potato', 'FI'), ('Potato', 'FR'), ('Potato', 'GB'),
    ('Potato', 'HR'), ('Potato', 'HU'), ('Potato', 'IE'), ('Potato', 'IT'), ('Potato', 'LU'),
    ('Potato', 'NL'), ('Potato', 'NO'), ('Potato', 'PL'), ('Potato', 'PT'), ('Potato', 'RO'),
    ('Potato', 'SE'), ('Potato', 'SI'), ('Potato', 'SK'), ('Potato', 'UA'),
    ('Potato', 'US'), ('Potato', 'CA'), ('Potato', 'AU'), ('Potato', 'NZ'), ('Potato', 'ZA'),
    ('Potato', 'BR'), ('Potato', 'AR'), ('Potato', 'IN'), ('Potato', 'CN'),

    -- Sweet Potato: warm-season, widely grown
    ('Sweet Potato', 'ES'), ('Sweet Potato', 'PT'), ('Sweet Potato', 'IT'), ('Sweet Potato', 'HR'),
    ('Sweet Potato', 'MX'), ('Sweet Potato', 'CN'), ('Sweet Potato', 'JP'), ('Sweet Potato', 'IN'),
    ('Sweet Potato', 'US'), ('Sweet Potato', 'CA'), ('Sweet Potato', 'BR'), ('Sweet Potato', 'AR'),
    ('Sweet Potato', 'AU'), ('Sweet Potato', 'NZ'), ('Sweet Potato', 'ZA'),

    -- Parsnip: northern European and temperate regions
    ('Parsnip', 'GB'), ('Parsnip', 'IE'), ('Parsnip', 'NL'), ('Parsnip', 'DE'), ('Parsnip', 'BE'),
    ('Parsnip', 'FR'), ('Parsnip', 'AT'), ('Parsnip', 'CH'), ('Parsnip', 'DK'), ('Parsnip', 'SE'),
    ('Parsnip', 'NO'), ('Parsnip', 'FI'), ('Parsnip', 'LU'), ('Parsnip', 'PL'), ('Parsnip', 'CZ'),
    ('Parsnip', 'US'), ('Parsnip', 'CA'), ('Parsnip', 'AU'), ('Parsnip', 'NZ'),

    -- Jerusalem Artichoke: widely grown in temperate regions
    ('Jerusalem Artichoke', 'FR'), ('Jerusalem Artichoke', 'DE'), ('Jerusalem Artichoke', 'NL'),
    ('Jerusalem Artichoke', 'BE'), ('Jerusalem Artichoke', 'AT'), ('Jerusalem Artichoke', 'CH'),
    ('Jerusalem Artichoke', 'GB'), ('Jerusalem Artichoke', 'IE'), ('Jerusalem Artichoke', 'DK'),
    ('Jerusalem Artichoke', 'SE'), ('Jerusalem Artichoke', 'PL'), ('Jerusalem Artichoke', 'CZ'),
    ('Jerusalem Artichoke', 'IT'),
    ('Jerusalem Artichoke', 'US'), ('Jerusalem Artichoke', 'CA'), ('Jerusalem Artichoke', 'AU'),

    -- Celeriac: central and northern Europe
    ('Celeriac', 'DE'), ('Celeriac', 'AT'), ('Celeriac', 'CH'), ('Celeriac', 'CZ'), ('Celeriac', 'SK'),
    ('Celeriac', 'PL'), ('Celeriac', 'HU'), ('Celeriac', 'NL'), ('Celeriac', 'BE'), ('Celeriac', 'FR'),
    ('Celeriac', 'GB'), ('Celeriac', 'DK'), ('Celeriac', 'SE'), ('Celeriac', 'NO'), ('Celeriac', 'FI'),
    ('Celeriac', 'IT'), ('Celeriac', 'RO'), ('Celeriac', 'UA'),
    ('Celeriac', 'US'), ('Celeriac', 'CA'), ('Celeriac', 'AU'),

    -- Daikon: Asian origin, grown in Europe too
    ('Daikon', 'JP'), ('Daikon', 'CN'), ('Daikon', 'IN'),
    ('Daikon', 'DE'), ('Daikon', 'NL'), ('Daikon', 'GB'), ('Daikon', 'FR'), ('Daikon', 'BE'),
    ('Daikon', 'US'), ('Daikon', 'CA'), ('Daikon', 'AU'),

    -- =========================================================
    -- ALLIUMS (V12)
    -- =========================================================

    -- Garlic: universal crop
    ('Garlic', 'ES'), ('Garlic', 'IT'), ('Garlic', 'FR'), ('Garlic', 'PT'), ('Garlic', 'HR'),
    ('Garlic', 'HU'), ('Garlic', 'RO'), ('Garlic', 'SI'), ('Garlic', 'DE'), ('Garlic', 'NL'),
    ('Garlic', 'BE'), ('Garlic', 'GB'), ('Garlic', 'AT'), ('Garlic', 'CH'), ('Garlic', 'PL'),
    ('Garlic', 'CZ'), ('Garlic', 'UA'),
    ('Garlic', 'CN'), ('Garlic', 'IN'),
    ('Garlic', 'US'), ('Garlic', 'CA'), ('Garlic', 'MX'), ('Garlic', 'BR'), ('Garlic', 'AR'),
    ('Garlic', 'AU'), ('Garlic', 'ZA'),

    -- Shallot: widely grown, especially in France and Asia
    ('Shallot', 'FR'), ('Shallot', 'NL'), ('Shallot', 'BE'), ('Shallot', 'DE'), ('Shallot', 'AT'),
    ('Shallot', 'CH'), ('Shallot', 'GB'), ('Shallot', 'IE'), ('Shallot', 'IT'), ('Shallot', 'ES'),
    ('Shallot', 'SE'), ('Shallot', 'DK'), ('Shallot', 'LU'),
    ('Shallot', 'CN'), ('Shallot', 'IN'),
    ('Shallot', 'US'), ('Shallot', 'CA'), ('Shallot', 'AU'),

    -- Spring Onion: universal salad vegetable
    ('Spring Onion', 'GB'), ('Spring Onion', 'IE'), ('Spring Onion', 'NL'), ('Spring Onion', 'DE'),
    ('Spring Onion', 'BE'), ('Spring Onion', 'FR'), ('Spring Onion', 'AT'), ('Spring Onion', 'CH'),
    ('Spring Onion', 'DK'), ('Spring Onion', 'SE'), ('Spring Onion', 'NO'), ('Spring Onion', 'FI'),
    ('Spring Onion', 'PL'), ('Spring Onion', 'IT'), ('Spring Onion', 'ES'),
    ('Spring Onion', 'CN'), ('Spring Onion', 'JP'), ('Spring Onion', 'IN'),
    ('Spring Onion', 'US'), ('Spring Onion', 'CA'), ('Spring Onion', 'AU'), ('Spring Onion', 'NZ'),

    -- =========================================================
    -- STALKS & SHOOTS (V12)
    -- =========================================================

    -- Celery: widely grown
    ('Celery', 'GB'), ('Celery', 'IE'), ('Celery', 'NL'), ('Celery', 'DE'), ('Celery', 'BE'),
    ('Celery', 'FR'), ('Celery', 'AT'), ('Celery', 'CH'), ('Celery', 'IT'), ('Celery', 'ES'),
    ('Celery', 'DK'), ('Celery', 'SE'), ('Celery', 'PL'),
    ('Celery', 'US'), ('Celery', 'CA'), ('Celery', 'AU'), ('Celery', 'NZ'),
    ('Celery', 'CN'), ('Celery', 'IN'), ('Celery', 'ZA'),

    -- Asparagus: widely grown in Europe and globally
    ('Asparagus', 'DE'), ('Asparagus', 'NL'), ('Asparagus', 'BE'), ('Asparagus', 'FR'),
    ('Asparagus', 'GB'), ('Asparagus', 'IE'), ('Asparagus', 'AT'), ('Asparagus', 'CH'),
    ('Asparagus', 'IT'), ('Asparagus', 'ES'), ('Asparagus', 'PT'), ('Asparagus', 'DK'),
    ('Asparagus', 'SE'), ('Asparagus', 'NO'), ('Asparagus', 'PL'), ('Asparagus', 'CZ'),
    ('Asparagus', 'US'), ('Asparagus', 'CA'), ('Asparagus', 'AU'), ('Asparagus', 'NZ'),
    ('Asparagus', 'ZA'), ('Asparagus', 'CN'),

    -- =========================================================
    -- LEGUMES (V12)
    -- =========================================================

    -- Broad Bean: Mediterranean and global temperate
    ('Broad Bean', 'IT'), ('Broad Bean', 'ES'), ('Broad Bean', 'PT'), ('Broad Bean', 'FR'),
    ('Broad Bean', 'GB'), ('Broad Bean', 'IE'), ('Broad Bean', 'NL'), ('Broad Bean', 'DE'),
    ('Broad Bean', 'BE'), ('Broad Bean', 'AT'), ('Broad Bean', 'CH'), ('Broad Bean', 'HR'),
    ('Broad Bean', 'SI'),
    ('Broad Bean', 'MX'), ('Broad Bean', 'CN'), ('Broad Bean', 'IN'), ('Broad Bean', 'BR'),
    ('Broad Bean', 'AU'), ('Broad Bean', 'NZ'), ('Broad Bean', 'ZA'),

    -- Runner Bean: UK and temperate European staple
    ('Runner Bean', 'GB'), ('Runner Bean', 'IE'), ('Runner Bean', 'NL'), ('Runner Bean', 'DE'),
    ('Runner Bean', 'BE'), ('Runner Bean', 'FR'), ('Runner Bean', 'AT'), ('Runner Bean', 'CH'),
    ('Runner Bean', 'DK'), ('Runner Bean', 'SE'), ('Runner Bean', 'PL'), ('Runner Bean', 'CZ'),
    ('Runner Bean', 'IT'), ('Runner Bean', 'ES'),
    ('Runner Bean', 'US'), ('Runner Bean', 'CA'), ('Runner Bean', 'AU'), ('Runner Bean', 'NZ'),
    ('Runner Bean', 'ZA'),

    -- Snap Pea: widely grown
    ('Snap Pea', 'NL'), ('Snap Pea', 'DE'), ('Snap Pea', 'BE'), ('Snap Pea', 'FR'), ('Snap Pea', 'GB'),
    ('Snap Pea', 'IE'), ('Snap Pea', 'AT'), ('Snap Pea', 'CH'), ('Snap Pea', 'DK'), ('Snap Pea', 'SE'),
    ('Snap Pea', 'NO'), ('Snap Pea', 'IT'), ('Snap Pea', 'ES'),
    ('Snap Pea', 'US'), ('Snap Pea', 'CA'), ('Snap Pea', 'AU'), ('Snap Pea', 'NZ'), ('Snap Pea', 'CN'),

    -- Lentil: widely grown in drier climates
    ('Lentil', 'FR'), ('Lentil', 'DE'), ('Lentil', 'ES'), ('Lentil', 'IT'), ('Lentil', 'PT'),
    ('Lentil', 'PL'), ('Lentil', 'CZ'), ('Lentil', 'HU'),
    ('Lentil', 'IN'), ('Lentil', 'CN'),
    ('Lentil', 'CA'), ('Lentil', 'US'), ('Lentil', 'AU'), ('Lentil', 'ZA'), ('Lentil', 'AR'),

    -- Soybean: major global crop
    ('Soybean', 'CN'), ('Soybean', 'JP'), ('Soybean', 'IN'),
    ('Soybean', 'US'), ('Soybean', 'CA'), ('Soybean', 'BR'), ('Soybean', 'AR'),
    ('Soybean', 'DE'), ('Soybean', 'NL'), ('Soybean', 'FR'), ('Soybean', 'AT'), ('Soybean', 'AU'),

    -- =========================================================
    -- HERBS (V12)
    -- =========================================================

    -- Chive: widely grown across all temperate regions
    ('Chive', 'AT'), ('Chive', 'BE'), ('Chive', 'CH'), ('Chive', 'CZ'), ('Chive', 'DE'),
    ('Chive', 'DK'), ('Chive', 'FI'), ('Chive', 'FR'), ('Chive', 'GB'), ('Chive', 'HR'),
    ('Chive', 'HU'), ('Chive', 'IE'), ('Chive', 'IT'), ('Chive', 'LU'), ('Chive', 'NL'),
    ('Chive', 'NO'), ('Chive', 'PL'), ('Chive', 'PT'), ('Chive', 'SE'), ('Chive', 'SI'),
    ('Chive', 'SK'), ('Chive', 'UA'),
    ('Chive', 'US'), ('Chive', 'CA'), ('Chive', 'AU'), ('Chive', 'NZ'),

    -- Coriander: global culinary herb
    ('Coriander', 'IN'), ('Coriander', 'CN'), ('Coriander', 'MX'),
    ('Coriander', 'ES'), ('Coriander', 'PT'), ('Coriander', 'IT'), ('Coriander', 'FR'),
    ('Coriander', 'DE'), ('Coriander', 'NL'), ('Coriander', 'GB'), ('Coriander', 'BE'),
    ('Coriander', 'US'), ('Coriander', 'CA'), ('Coriander', 'AU'), ('Coriander', 'ZA'),
    ('Coriander', 'AR'), ('Coriander', 'BR'),

    -- Mint: widely grown across all temperate and warm regions
    ('Mint', 'AT'), ('Mint', 'BE'), ('Mint', 'CH'), ('Mint', 'CZ'), ('Mint', 'DE'),
    ('Mint', 'DK'), ('Mint', 'ES'), ('Mint', 'FI'), ('Mint', 'FR'), ('Mint', 'GB'),
    ('Mint', 'HR'), ('Mint', 'IE'), ('Mint', 'IT'), ('Mint', 'LU'), ('Mint', 'NL'),
    ('Mint', 'NO'), ('Mint', 'PL'), ('Mint', 'PT'), ('Mint', 'SE'), ('Mint', 'SI'), ('Mint', 'UA'),
    ('Mint', 'IN'),
    ('Mint', 'US'), ('Mint', 'CA'), ('Mint', 'AU'), ('Mint', 'NZ'), ('Mint', 'ZA'),

    -- Thyme: Mediterranean origin, widely grown
    ('Thyme', 'FR'), ('Thyme', 'IT'), ('Thyme', 'ES'), ('Thyme', 'PT'), ('Thyme', 'HR'),
    ('Thyme', 'SI'), ('Thyme', 'DE'), ('Thyme', 'NL'), ('Thyme', 'BE'), ('Thyme', 'GB'),
    ('Thyme', 'IE'), ('Thyme', 'AT'), ('Thyme', 'CH'), ('Thyme', 'DK'), ('Thyme', 'SE'),
    ('Thyme', 'US'), ('Thyme', 'CA'), ('Thyme', 'AU'), ('Thyme', 'ZA'),

    -- Rosemary: Mediterranean origin, widely grown
    ('Rosemary', 'IT'), ('Rosemary', 'ES'), ('Rosemary', 'FR'), ('Rosemary', 'PT'),
    ('Rosemary', 'HR'), ('Rosemary', 'SI'), ('Rosemary', 'DE'), ('Rosemary', 'NL'),
    ('Rosemary', 'BE'), ('Rosemary', 'GB'), ('Rosemary', 'IE'), ('Rosemary', 'AT'),
    ('Rosemary', 'CH'), ('Rosemary', 'DK'), ('Rosemary', 'SE'),
    ('Rosemary', 'US'), ('Rosemary', 'CA'), ('Rosemary', 'AU'), ('Rosemary', 'ZA'),

    -- Oregano: Mediterranean origin, widely grown
    ('Oregano', 'IT'), ('Oregano', 'ES'), ('Oregano', 'FR'), ('Oregano', 'PT'),
    ('Oregano', 'HR'), ('Oregano', 'SI'), ('Oregano', 'DE'), ('Oregano', 'NL'),
    ('Oregano', 'BE'), ('Oregano', 'GB'), ('Oregano', 'IE'), ('Oregano', 'AT'), ('Oregano', 'CH'),
    ('Oregano', 'US'), ('Oregano', 'CA'), ('Oregano', 'AU'), ('Oregano', 'ZA'), ('Oregano', 'MX'),

    -- Sage: Mediterranean origin, widely grown
    ('Sage', 'IT'), ('Sage', 'ES'), ('Sage', 'FR'), ('Sage', 'PT'), ('Sage', 'HR'),
    ('Sage', 'SI'), ('Sage', 'DE'), ('Sage', 'NL'), ('Sage', 'BE'), ('Sage', 'GB'),
    ('Sage', 'IE'), ('Sage', 'AT'), ('Sage', 'CH'), ('Sage', 'DK'), ('Sage', 'SE'),
    ('Sage', 'US'), ('Sage', 'CA'), ('Sage', 'AU'), ('Sage', 'NZ'),

    -- Chervil: French cuisine herb, European
    ('Chervil', 'FR'), ('Chervil', 'DE'), ('Chervil', 'NL'), ('Chervil', 'BE'), ('Chervil', 'AT'),
    ('Chervil', 'CH'), ('Chervil', 'LU'), ('Chervil', 'GB'), ('Chervil', 'DK'), ('Chervil', 'SE'),
    ('Chervil', 'IT'),
    ('Chervil', 'US'), ('Chervil', 'CA'), ('Chervil', 'AU'),

    -- Lemongrass: tropical origin, grown globally
    ('Lemongrass', 'IN'), ('Lemongrass', 'CN'),
    ('Lemongrass', 'MX'), ('Lemongrass', 'BR'),
    ('Lemongrass', 'AU'), ('Lemongrass', 'ZA'),
    ('Lemongrass', 'US'), ('Lemongrass', 'CA'),
    ('Lemongrass', 'NL'), ('Lemongrass', 'GB'), ('Lemongrass', 'DE'), ('Lemongrass', 'FR'),

    -- Chickweed: widespread weed/salad green found globally
    ('Chickweed', 'AT'), ('Chickweed', 'BE'), ('Chickweed', 'CH'), ('Chickweed', 'CZ'),
    ('Chickweed', 'DE'), ('Chickweed', 'DK'), ('Chickweed', 'FI'), ('Chickweed', 'FR'),
    ('Chickweed', 'GB'), ('Chickweed', 'HR'), ('Chickweed', 'HU'), ('Chickweed', 'IE'),
    ('Chickweed', 'IT'), ('Chickweed', 'LU'), ('Chickweed', 'NL'), ('Chickweed', 'NO'),
    ('Chickweed', 'PL'), ('Chickweed', 'PT'), ('Chickweed', 'RO'), ('Chickweed', 'SE'),
    ('Chickweed', 'SI'), ('Chickweed', 'SK'), ('Chickweed', 'UA'),
    ('Chickweed', 'JP'), ('Chickweed', 'CN'), ('Chickweed', 'IN'),
    ('Chickweed', 'US'), ('Chickweed', 'CA'), ('Chickweed', 'AU'), ('Chickweed', 'NZ'), ('Chickweed', 'ZA'),

    -- =========================================================
    -- V14 WILD & SPECIALTY GREENS
    -- =========================================================

    -- Borage: European herb, widely grown
    ('Borage', 'AT'), ('Borage', 'BE'), ('Borage', 'CH'), ('Borage', 'CZ'), ('Borage', 'DE'),
    ('Borage', 'DK'), ('Borage', 'ES'), ('Borage', 'FR'), ('Borage', 'GB'), ('Borage', 'HR'),
    ('Borage', 'IE'), ('Borage', 'IT'), ('Borage', 'LU'), ('Borage', 'NL'), ('Borage', 'NO'),
    ('Borage', 'PL'), ('Borage', 'PT'), ('Borage', 'SE'), ('Borage', 'SI'), ('Borage', 'UA'),
    ('Borage', 'US'), ('Borage', 'CA'), ('Borage', 'AU'), ('Borage', 'NZ'),

    -- Caraway: central and northern European spice
    ('Caraway', 'DE'), ('Caraway', 'AT'), ('Caraway', 'CH'), ('Caraway', 'CZ'), ('Caraway', 'SK'),
    ('Caraway', 'PL'), ('Caraway', 'HU'), ('Caraway', 'NL'), ('Caraway', 'FI'), ('Caraway', 'DK'),
    ('Caraway', 'SE'), ('Caraway', 'NO'), ('Caraway', 'GB'), ('Caraway', 'FR'),
    ('Caraway', 'IN'),
    ('Caraway', 'US'), ('Caraway', 'CA'),

    -- Celtuce: Chinese origin, niche in West
    ('Celtuce', 'CN'), ('Celtuce', 'JP'),
    ('Celtuce', 'NL'), ('Celtuce', 'DE'), ('Celtuce', 'GB'), ('Celtuce', 'FR'),
    ('Celtuce', 'US'), ('Celtuce', 'CA'), ('Celtuce', 'AU'),

    -- Common Purslane: cosmopolitan weed/salad green
    ('Common Purslane', 'AT'), ('Common Purslane', 'BE'), ('Common Purslane', 'CH'),
    ('Common Purslane', 'DE'), ('Common Purslane', 'ES'), ('Common Purslane', 'FR'),
    ('Common Purslane', 'GB'), ('Common Purslane', 'IT'), ('Common Purslane', 'NL'),
    ('Common Purslane', 'PT'),
    ('Common Purslane', 'CN'), ('Common Purslane', 'IN'),
    ('Common Purslane', 'US'), ('Common Purslane', 'CA'), ('Common Purslane', 'AU'),
    ('Common Purslane', 'ZA'), ('Common Purslane', 'MX'), ('Common Purslane', 'BR'),

    -- Cress: widely grown across temperate regions
    ('Cress', 'AT'), ('Cress', 'BE'), ('Cress', 'CH'), ('Cress', 'CZ'), ('Cress', 'DE'),
    ('Cress', 'DK'), ('Cress', 'FI'), ('Cress', 'FR'), ('Cress', 'GB'), ('Cress', 'HR'),
    ('Cress', 'HU'), ('Cress', 'IE'), ('Cress', 'IT'), ('Cress', 'LU'), ('Cress', 'NL'),
    ('Cress', 'NO'), ('Cress', 'PL'), ('Cress', 'PT'), ('Cress', 'SE'), ('Cress', 'SI'),
    ('Cress', 'SK'), ('Cress', 'UA'),
    ('Cress', 'CN'), ('Cress', 'IN'),
    ('Cress', 'US'), ('Cress', 'CA'), ('Cress', 'AU'), ('Cress', 'NZ'),

    -- Dandelion: cosmopolitan, found globally
    ('Dandelion', 'AT'), ('Dandelion', 'BE'), ('Dandelion', 'CH'), ('Dandelion', 'CZ'),
    ('Dandelion', 'DE'), ('Dandelion', 'DK'), ('Dandelion', 'FI'), ('Dandelion', 'FR'),
    ('Dandelion', 'GB'), ('Dandelion', 'HR'), ('Dandelion', 'HU'), ('Dandelion', 'IE'),
    ('Dandelion', 'IT'), ('Dandelion', 'LU'), ('Dandelion', 'NL'), ('Dandelion', 'NO'),
    ('Dandelion', 'PL'), ('Dandelion', 'PT'), ('Dandelion', 'RO'), ('Dandelion', 'SE'),
    ('Dandelion', 'SI'), ('Dandelion', 'SK'), ('Dandelion', 'UA'),
    ('Dandelion', 'CN'), ('Dandelion', 'JP'), ('Dandelion', 'IN'),
    ('Dandelion', 'US'), ('Dandelion', 'CA'), ('Dandelion', 'AU'), ('Dandelion', 'NZ'),

    -- Fiddlehead: forest fern, northern regions
    ('Fiddlehead', 'CA'), ('Fiddlehead', 'US'), ('Fiddlehead', 'JP'), ('Fiddlehead', 'CN'),
    ('Fiddlehead', 'AU'), ('Fiddlehead', 'NZ'), ('Fiddlehead', 'NO'), ('Fiddlehead', 'FI'),
    ('Fiddlehead', 'SE'),

    -- Garland Chrysanthemum: Asian origin, niche Western market
    ('Garland Chrysanthemum', 'CN'), ('Garland Chrysanthemum', 'JP'),
    ('Garland Chrysanthemum', 'NL'), ('Garland Chrysanthemum', 'DE'), ('Garland Chrysanthemum', 'GB'),
    ('Garland Chrysanthemum', 'FR'),
    ('Garland Chrysanthemum', 'US'), ('Garland Chrysanthemum', 'CA'), ('Garland Chrysanthemum', 'AU'),
    ('Garland Chrysanthemum', 'NZ'),

    -- Grape Leaves: Mediterranean specialty
    ('Grape Leaves', 'IT'), ('Grape Leaves', 'HR'), ('Grape Leaves', 'SI'), ('Grape Leaves', 'HU'),
    ('Grape Leaves', 'RO'), ('Grape Leaves', 'AT'), ('Grape Leaves', 'CH'), ('Grape Leaves', 'DE'),
    ('Grape Leaves', 'FR'), ('Grape Leaves', 'ES'), ('Grape Leaves', 'PT'),
    ('Grape Leaves', 'US'), ('Grape Leaves', 'CA'), ('Grape Leaves', 'AU'), ('Grape Leaves', 'AR'),

    -- Jute Mallow: tropical/subtropical green
    ('Jute Mallow', 'IN'), ('Jute Mallow', 'CN'), ('Jute Mallow', 'ZA'), ('Jute Mallow', 'BR'),
    ('Jute Mallow', 'MX'),
    ('Jute Mallow', 'IT'), ('Jute Mallow', 'ES'), ('Jute Mallow', 'PT'), ('Jute Mallow', 'NL'),
    ('Jute Mallow', 'US'), ('Jute Mallow', 'CA'),

    -- Kai-lan: Asian brassica
    ('Kai-lan', 'CN'), ('Kai-lan', 'JP'),
    ('Kai-lan', 'AU'), ('Kai-lan', 'NZ'),
    ('Kai-lan', 'NL'), ('Kai-lan', 'DE'), ('Kai-lan', 'GB'), ('Kai-lan', 'FR'), ('Kai-lan', 'BE'),
    ('Kai-lan', 'US'), ('Kai-lan', 'CA'),

    -- Kalette: UK-developed brassica hybrid
    ('Kalette', 'GB'), ('Kalette', 'NL'), ('Kalette', 'BE'), ('Kalette', 'DE'), ('Kalette', 'FR'),
    ('Kalette', 'US'), ('Kalette', 'CA'), ('Kalette', 'AU'),

    -- Komatsuna: Japanese green
    ('Komatsuna', 'JP'), ('Komatsuna', 'CN'),
    ('Komatsuna', 'NL'), ('Komatsuna', 'DE'), ('Komatsuna', 'GB'),
    ('Komatsuna', 'US'), ('Komatsuna', 'CA'), ('Komatsuna', 'AU'),

    -- Lamb's Quarters: cosmopolitan weed/green
    ('Lamb''s Quarters', 'AT'), ('Lamb''s Quarters', 'BE'), ('Lamb''s Quarters', 'CH'),
    ('Lamb''s Quarters', 'CZ'), ('Lamb''s Quarters', 'DE'), ('Lamb''s Quarters', 'DK'),
    ('Lamb''s Quarters', 'FI'), ('Lamb''s Quarters', 'FR'), ('Lamb''s Quarters', 'GB'),
    ('Lamb''s Quarters', 'HR'), ('Lamb''s Quarters', 'HU'), ('Lamb''s Quarters', 'IE'),
    ('Lamb''s Quarters', 'IT'), ('Lamb''s Quarters', 'LU'), ('Lamb''s Quarters', 'NL'),
    ('Lamb''s Quarters', 'NO'), ('Lamb''s Quarters', 'PL'), ('Lamb''s Quarters', 'SE'),
    ('Lamb''s Quarters', 'SI'), ('Lamb''s Quarters', 'SK'), ('Lamb''s Quarters', 'UA'),
    ('Lamb''s Quarters', 'IN'), ('Lamb''s Quarters', 'CN'),
    ('Lamb''s Quarters', 'US'), ('Lamb''s Quarters', 'CA'), ('Lamb''s Quarters', 'AU'),

    -- Land Cress: European salad cress
    ('Land Cress', 'GB'), ('Land Cress', 'IE'), ('Land Cress', 'NL'), ('Land Cress', 'DE'),
    ('Land Cress', 'BE'), ('Land Cress', 'FR'), ('Land Cress', 'AT'), ('Land Cress', 'CH'),
    ('Land Cress', 'DK'), ('Land Cress', 'SE'),
    ('Land Cress', 'US'), ('Land Cress', 'CA'), ('Land Cress', 'AU'),

    -- Malabar Spinach: tropical climbing green
    ('Malabar Spinach', 'IN'), ('Malabar Spinach', 'CN'), ('Malabar Spinach', 'JP'),
    ('Malabar Spinach', 'ZA'), ('Malabar Spinach', 'BR'), ('Malabar Spinach', 'MX'),
    ('Malabar Spinach', 'NL'), ('Malabar Spinach', 'DE'), ('Malabar Spinach', 'GB'),
    ('Malabar Spinach', 'US'), ('Malabar Spinach', 'CA'), ('Malabar Spinach', 'AU'),

    -- Mallow: widespread edible weed
    ('Mallow', 'AT'), ('Mallow', 'BE'), ('Mallow', 'CH'), ('Mallow', 'DE'), ('Mallow', 'ES'),
    ('Mallow', 'FR'), ('Mallow', 'GB'), ('Mallow', 'IT'), ('Mallow', 'NL'), ('Mallow', 'PT'),
    ('Mallow', 'IN'), ('Mallow', 'CN'),
    ('Mallow', 'US'), ('Mallow', 'CA'), ('Mallow', 'AU'), ('Mallow', 'ZA'),

    -- Miner's Lettuce: North American origin
    ('Miner''s Lettuce', 'US'), ('Miner''s Lettuce', 'CA'),
    ('Miner''s Lettuce', 'NL'), ('Miner''s Lettuce', 'DE'), ('Miner''s Lettuce', 'GB'),
    ('Miner''s Lettuce', 'FR'), ('Miner''s Lettuce', 'BE'), ('Miner''s Lettuce', 'AT'),
    ('Miner''s Lettuce', 'AU'), ('Miner''s Lettuce', 'NZ'),

    -- Moringa: tropical nutritional plant
    ('Moringa', 'IN'), ('Moringa', 'ZA'), ('Moringa', 'MX'), ('Moringa', 'BR'), ('Moringa', 'CN'),
    ('Moringa', 'ES'), ('Moringa', 'PT'), ('Moringa', 'IT'),
    ('Moringa', 'US'), ('Moringa', 'CA'), ('Moringa', 'AU'),

    -- New Zealand Spinach: Australasian origin, grown globally
    ('New Zealand Spinach', 'NZ'), ('New Zealand Spinach', 'AU'), ('New Zealand Spinach', 'JP'),
    ('New Zealand Spinach', 'GB'), ('New Zealand Spinach', 'NL'), ('New Zealand Spinach', 'DE'),
    ('New Zealand Spinach', 'FR'), ('New Zealand Spinach', 'BE'), ('New Zealand Spinach', 'AT'),
    ('New Zealand Spinach', 'CH'),
    ('New Zealand Spinach', 'US'), ('New Zealand Spinach', 'CA'),

    -- Orache: European coastal/garden plant
    ('Orache', 'AT'), ('Orache', 'BE'), ('Orache', 'CH'), ('Orache', 'CZ'), ('Orache', 'DE'),
    ('Orache', 'DK'), ('Orache', 'FI'), ('Orache', 'FR'), ('Orache', 'GB'), ('Orache', 'HR'),
    ('Orache', 'HU'), ('Orache', 'IE'), ('Orache', 'IT'), ('Orache', 'LU'), ('Orache', 'NL'),
    ('Orache', 'NO'), ('Orache', 'PL'), ('Orache', 'SE'), ('Orache', 'SI'), ('Orache', 'SK'),
    ('Orache', 'UA'),
    ('Orache', 'US'), ('Orache', 'CA'), ('Orache', 'AU'),

    -- Samphire: coastal European specialty
    ('Samphire', 'GB'), ('Samphire', 'FR'), ('Samphire', 'NL'), ('Samphire', 'DE'), ('Samphire', 'IE'),
    ('Samphire', 'BE'), ('Samphire', 'DK'), ('Samphire', 'SE'), ('Samphire', 'NO'),
    ('Samphire', 'IT'), ('Samphire', 'ES'), ('Samphire', 'PT'),
    ('Samphire', 'US'), ('Samphire', 'CA'), ('Samphire', 'AU'),

    -- Sea Beet: European coastal plant, ancestor of beet
    ('Sea Beet', 'GB'), ('Sea Beet', 'IE'), ('Sea Beet', 'NL'), ('Sea Beet', 'FR'), ('Sea Beet', 'DE'),
    ('Sea Beet', 'BE'), ('Sea Beet', 'DK'), ('Sea Beet', 'NO'), ('Sea Beet', 'SE'), ('Sea Beet', 'FI'),
    ('Sea Beet', 'IT'), ('Sea Beet', 'ES'), ('Sea Beet', 'PT'), ('Sea Beet', 'AU'),

    -- Sea Kale: European coastal specialty
    ('Sea Kale', 'GB'), ('Sea Kale', 'IE'), ('Sea Kale', 'NL'), ('Sea Kale', 'DE'), ('Sea Kale', 'BE'),
    ('Sea Kale', 'FR'), ('Sea Kale', 'DK'), ('Sea Kale', 'SE'), ('Sea Kale', 'NO'),
    ('Sea Kale', 'US'), ('Sea Kale', 'CA'), ('Sea Kale', 'AU'),

    -- Tatsoi: Asian brassica, grown in temperate West
    ('Tatsoi', 'CN'), ('Tatsoi', 'JP'),
    ('Tatsoi', 'NL'), ('Tatsoi', 'DE'), ('Tatsoi', 'GB'), ('Tatsoi', 'FR'), ('Tatsoi', 'BE'),
    ('Tatsoi', 'US'), ('Tatsoi', 'CA'), ('Tatsoi', 'AU'), ('Tatsoi', 'NZ'),

    -- Water Spinach: tropical aquatic green
    ('Water Spinach', 'CN'), ('Water Spinach', 'IN'),
    ('Water Spinach', 'AU'), ('Water Spinach', 'NZ'),
    ('Water Spinach', 'NL'), ('Water Spinach', 'DE'), ('Water Spinach', 'GB'),
    ('Water Spinach', 'US'), ('Water Spinach', 'CA'), ('Water Spinach', 'MX'),
    ('Water Spinach', 'BR'), ('Water Spinach', 'ZA'),

    -- Wheatgrass: health food, grown globally
    ('Wheatgrass', 'US'), ('Wheatgrass', 'CA'),
    ('Wheatgrass', 'GB'), ('Wheatgrass', 'DE'), ('Wheatgrass', 'NL'),
    ('Wheatgrass', 'AU'), ('Wheatgrass', 'NZ'), ('Wheatgrass', 'IN'), ('Wheatgrass', 'CN'),

    -- Yao Choy: Chinese green
    ('Yao Choy', 'CN'),
    ('Yao Choy', 'NL'), ('Yao Choy', 'DE'), ('Yao Choy', 'GB'), ('Yao Choy', 'FR'),
    ('Yao Choy', 'US'), ('Yao Choy', 'CA'), ('Yao Choy', 'AU'),

    -- =========================================================
    -- V14 FRUITING VEGETABLES
    -- =========================================================

    -- Bitter Melon: tropical Asian origin
    ('Bitter Melon', 'IN'), ('Bitter Melon', 'CN'), ('Bitter Melon', 'JP'),
    ('Bitter Melon', 'ZA'), ('Bitter Melon', 'BR'), ('Bitter Melon', 'MX'),
    ('Bitter Melon', 'NL'), ('Bitter Melon', 'DE'),
    ('Bitter Melon', 'US'), ('Bitter Melon', 'CA'), ('Bitter Melon', 'AU'),

    -- Butternut Squash: widely grown
    ('Butternut Squash', 'US'), ('Butternut Squash', 'CA'), ('Butternut Squash', 'ZA'),
    ('Butternut Squash', 'AU'), ('Butternut Squash', 'NZ'),
    ('Butternut Squash', 'GB'), ('Butternut Squash', 'IE'), ('Butternut Squash', 'NL'),
    ('Butternut Squash', 'DE'), ('Butternut Squash', 'FR'), ('Butternut Squash', 'BE'),
    ('Butternut Squash', 'AT'), ('Butternut Squash', 'IT'), ('Butternut Squash', 'ES'),

    -- Calabash: tropical gourd
    ('Calabash', 'IN'), ('Calabash', 'CN'), ('Calabash', 'ZA'), ('Calabash', 'BR'), ('Calabash', 'MX'),
    ('Calabash', 'IT'), ('Calabash', 'ES'),
    ('Calabash', 'US'), ('Calabash', 'CA'), ('Calabash', 'AU'),

    -- Chayote: Central American origin, grown globally
    ('Chayote', 'MX'), ('Chayote', 'BR'),
    ('Chayote', 'AU'), ('Chayote', 'ZA'),
    ('Chayote', 'FR'), ('Chayote', 'ES'), ('Chayote', 'PT'), ('Chayote', 'IT'),
    ('Chayote', 'CN'), ('Chayote', 'IN'),
    ('Chayote', 'US'), ('Chayote', 'CA'),

    -- Cucamelon: Mexican origin, specialty crop
    ('Cucamelon', 'MX'),
    ('Cucamelon', 'NL'), ('Cucamelon', 'DE'), ('Cucamelon', 'GB'), ('Cucamelon', 'FR'),
    ('Cucamelon', 'BE'),
    ('Cucamelon', 'US'), ('Cucamelon', 'CA'), ('Cucamelon', 'AU'),

    -- Kabocha: Japanese squash variety
    ('Kabocha', 'JP'), ('Kabocha', 'CN'),
    ('Kabocha', 'AU'), ('Kabocha', 'NZ'),
    ('Kabocha', 'NL'), ('Kabocha', 'DE'), ('Kabocha', 'GB'), ('Kabocha', 'FR'),
    ('Kabocha', 'US'), ('Kabocha', 'CA'),

    -- Luffa: tropical gourd, widely grown
    ('Luffa', 'IN'), ('Luffa', 'CN'), ('Luffa', 'JP'),
    ('Luffa', 'ZA'), ('Luffa', 'BR'), ('Luffa', 'MX'),
    ('Luffa', 'IT'), ('Luffa', 'ES'),
    ('Luffa', 'US'), ('Luffa', 'CA'), ('Luffa', 'AU'),

    -- Spaghetti Squash: North American origin, widely grown
    ('Spaghetti Squash', 'US'), ('Spaghetti Squash', 'CA'),
    ('Spaghetti Squash', 'AU'), ('Spaghetti Squash', 'NZ'),
    ('Spaghetti Squash', 'NL'), ('Spaghetti Squash', 'DE'), ('Spaghetti Squash', 'GB'),
    ('Spaghetti Squash', 'FR'), ('Spaghetti Squash', 'BE'), ('Spaghetti Squash', 'IT'),
    ('Spaghetti Squash', 'ES'),

    -- Tomatillo: Mexican origin
    ('Tomatillo', 'MX'),
    ('Tomatillo', 'NL'), ('Tomatillo', 'DE'), ('Tomatillo', 'GB'), ('Tomatillo', 'FR'),
    ('Tomatillo', 'BE'),
    ('Tomatillo', 'US'), ('Tomatillo', 'CA'), ('Tomatillo', 'AU'),

    -- Watermelon: warm-season, grown globally
    ('Watermelon', 'ES'), ('Watermelon', 'IT'), ('Watermelon', 'PT'), ('Watermelon', 'HR'),
    ('Watermelon', 'HU'), ('Watermelon', 'RO'),
    ('Watermelon', 'IN'), ('Watermelon', 'CN'),
    ('Watermelon', 'US'), ('Watermelon', 'CA'), ('Watermelon', 'MX'), ('Watermelon', 'BR'),
    ('Watermelon', 'AR'), ('Watermelon', 'AU'), ('Watermelon', 'ZA'), ('Watermelon', 'JP'),

    -- Winter Melon: Asian origin
    ('Winter Melon', 'CN'), ('Winter Melon', 'IN'), ('Winter Melon', 'JP'),
    ('Winter Melon', 'NL'), ('Winter Melon', 'DE'), ('Winter Melon', 'GB'),
    ('Winter Melon', 'US'), ('Winter Melon', 'CA'), ('Winter Melon', 'AU'),

    -- =========================================================
    -- V14 HOT PEPPERS
    -- =========================================================

    -- Jalapeño: Mexican origin, widely grown
    ('Jalapeño', 'MX'), ('Jalapeño', 'IN'), ('Jalapeño', 'CN'),
    ('Jalapeño', 'ES'), ('Jalapeño', 'PT'),
    ('Jalapeño', 'NL'), ('Jalapeño', 'DE'), ('Jalapeño', 'GB'),
    ('Jalapeño', 'US'), ('Jalapeño', 'CA'), ('Jalapeño', 'AU'), ('Jalapeño', 'ZA'),

    -- Habanero: Caribbean/Mexican origin
    ('Habanero', 'MX'), ('Habanero', 'IN'), ('Habanero', 'ZA'),
    ('Habanero', 'NL'), ('Habanero', 'DE'), ('Habanero', 'GB'),
    ('Habanero', 'US'), ('Habanero', 'CA'), ('Habanero', 'AU'),

    -- Cayenne Pepper: widely grown globally
    ('Cayenne Pepper', 'MX'), ('Cayenne Pepper', 'IN'), ('Cayenne Pepper', 'CN'),
    ('Cayenne Pepper', 'ES'), ('Cayenne Pepper', 'PT'), ('Cayenne Pepper', 'IT'),
    ('Cayenne Pepper', 'NL'), ('Cayenne Pepper', 'DE'), ('Cayenne Pepper', 'GB'),
    ('Cayenne Pepper', 'US'), ('Cayenne Pepper', 'CA'), ('Cayenne Pepper', 'AU'),
    ('Cayenne Pepper', 'ZA'), ('Cayenne Pepper', 'BR'), ('Cayenne Pepper', 'AR'),

    -- =========================================================
    -- V14 FLOWERS & EDIBLE BLOSSOMS
    -- =========================================================

    -- Banana Flower: tropical origin
    ('Banana Flower', 'IN'), ('Banana Flower', 'CN'), ('Banana Flower', 'BR'), ('Banana Flower', 'MX'),
    ('Banana Flower', 'ZA'), ('Banana Flower', 'AU'),
    ('Banana Flower', 'US'), ('Banana Flower', 'CA'),

    -- Caper: Mediterranean specialty
    ('Caper', 'IT'), ('Caper', 'ES'), ('Caper', 'FR'), ('Caper', 'PT'), ('Caper', 'HR'),
    ('Caper', 'SI'), ('Caper', 'NL'), ('Caper', 'DE'), ('Caper', 'GB'),
    ('Caper', 'US'), ('Caper', 'CA'), ('Caper', 'AU'), ('Caper', 'ZA'),

    -- Daylily: Asian origin, edible buds
    ('Daylily', 'CN'), ('Daylily', 'JP'),
    ('Daylily', 'NL'), ('Daylily', 'DE'), ('Daylily', 'GB'), ('Daylily', 'FR'), ('Daylily', 'BE'),
    ('Daylily', 'US'), ('Daylily', 'CA'), ('Daylily', 'AU'),

    -- Loroco: Central American flower vegetable
    ('Loroco', 'MX'),
    ('Loroco', 'NL'), ('Loroco', 'DE'),
    ('Loroco', 'US'), ('Loroco', 'CA'), ('Loroco', 'AU'),

    -- =========================================================
    -- V14 BEANS & LEGUMES
    -- =========================================================

    -- Asparagus Bean: Asian origin, tropical legume
    ('Asparagus Bean', 'CN'), ('Asparagus Bean', 'IN'), ('Asparagus Bean', 'JP'),
    ('Asparagus Bean', 'ZA'), ('Asparagus Bean', 'BR'),
    ('Asparagus Bean', 'NL'), ('Asparagus Bean', 'DE'), ('Asparagus Bean', 'GB'), ('Asparagus Bean', 'FR'),
    ('Asparagus Bean', 'US'), ('Asparagus Bean', 'CA'), ('Asparagus Bean', 'AU'),

    -- Adzuki Bean: East Asian origin
    ('Adzuki Bean', 'JP'), ('Adzuki Bean', 'CN'), ('Adzuki Bean', 'IN'),
    ('Adzuki Bean', 'NZ'),
    ('Adzuki Bean', 'DE'), ('Adzuki Bean', 'NL'), ('Adzuki Bean', 'GB'),
    ('Adzuki Bean', 'US'), ('Adzuki Bean', 'CA'), ('Adzuki Bean', 'AU'),

    -- Black-eyed Pea: African/Asian origin, warm-season legume
    ('Black-eyed Pea', 'IN'), ('Black-eyed Pea', 'ZA'), ('Black-eyed Pea', 'BR'), ('Black-eyed Pea', 'MX'),
    ('Black-eyed Pea', 'IT'), ('Black-eyed Pea', 'ES'), ('Black-eyed Pea', 'PT'),
    ('Black-eyed Pea', 'US'), ('Black-eyed Pea', 'CA'), ('Black-eyed Pea', 'AU'),

    -- Chickpea: Mediterranean and global drylands
    ('Chickpea', 'IN'), ('Chickpea', 'ES'), ('Chickpea', 'IT'), ('Chickpea', 'PT'),
    ('Chickpea', 'FR'), ('Chickpea', 'DE'), ('Chickpea', 'NL'), ('Chickpea', 'GB'),
    ('Chickpea', 'AU'), ('Chickpea', 'ZA'),
    ('Chickpea', 'US'), ('Chickpea', 'CA'), ('Chickpea', 'MX'), ('Chickpea', 'AR'), ('Chickpea', 'BR'),

    -- Lima Bean: American origin, widely grown
    ('Lima Bean', 'MX'), ('Lima Bean', 'BR'), ('Lima Bean', 'AR'),
    ('Lima Bean', 'IN'), ('Lima Bean', 'ZA'),
    ('Lima Bean', 'IT'), ('Lima Bean', 'ES'), ('Lima Bean', 'FR'),
    ('Lima Bean', 'NL'), ('Lima Bean', 'DE'), ('Lima Bean', 'GB'),
    ('Lima Bean', 'US'), ('Lima Bean', 'CA'), ('Lima Bean', 'AU'),

    -- Mung Bean: Asian origin, widely grown
    ('Mung Bean', 'IN'), ('Mung Bean', 'CN'), ('Mung Bean', 'JP'),
    ('Mung Bean', 'ZA'), ('Mung Bean', 'BR'),
    ('Mung Bean', 'NL'), ('Mung Bean', 'DE'), ('Mung Bean', 'GB'),
    ('Mung Bean', 'US'), ('Mung Bean', 'CA'), ('Mung Bean', 'AU'),

    -- Okra: tropical African origin, widely grown
    ('Okra', 'IN'), ('Okra', 'ZA'), ('Okra', 'CN'),
    ('Okra', 'MX'), ('Okra', 'BR'),
    ('Okra', 'IT'), ('Okra', 'ES'), ('Okra', 'PT'),
    ('Okra', 'NL'), ('Okra', 'DE'), ('Okra', 'GB'),
    ('Okra', 'US'), ('Okra', 'CA'), ('Okra', 'AU'),

    -- Snow Pea: Asian origin, widely grown
    ('Snow Pea', 'CN'), ('Snow Pea', 'JP'),
    ('Snow Pea', 'AU'), ('Snow Pea', 'NZ'),
    ('Snow Pea', 'NL'), ('Snow Pea', 'DE'), ('Snow Pea', 'GB'), ('Snow Pea', 'FR'),
    ('Snow Pea', 'BE'), ('Snow Pea', 'AT'), ('Snow Pea', 'IT'), ('Snow Pea', 'ES'),
    ('Snow Pea', 'US'), ('Snow Pea', 'CA'),

    -- Winged Bean: tropical Southeast Asian legume
    ('Winged Bean', 'IN'), ('Winged Bean', 'CN'), ('Winged Bean', 'ZA'),
    ('Winged Bean', 'AU'), ('Winged Bean', 'NZ'),
    ('Winged Bean', 'NL'), ('Winged Bean', 'DE'), ('Winged Bean', 'GB'),
    ('Winged Bean', 'US'), ('Winged Bean', 'CA'),

    -- =========================================================
    -- V14 ROOT & TUBER VEGETABLES
    -- =========================================================

    -- Bamboo Shoot: Asian origin
    ('Bamboo Shoot', 'CN'), ('Bamboo Shoot', 'JP'), ('Bamboo Shoot', 'IN'),
    ('Bamboo Shoot', 'ZA'),
    ('Bamboo Shoot', 'DE'), ('Bamboo Shoot', 'NL'), ('Bamboo Shoot', 'GB'),
    ('Bamboo Shoot', 'US'), ('Bamboo Shoot', 'CA'), ('Bamboo Shoot', 'AU'),

    -- Burdock: Asian origin, used in Japanese and European cuisine
    ('Burdock', 'JP'), ('Burdock', 'CN'),
    ('Burdock', 'NL'), ('Burdock', 'DE'), ('Burdock', 'GB'), ('Burdock', 'FR'),
    ('Burdock', 'US'), ('Burdock', 'CA'), ('Burdock', 'AU'),

    -- Cassava: tropical staple
    ('Cassava', 'IN'), ('Cassava', 'CN'), ('Cassava', 'BR'), ('Cassava', 'MX'),
    ('Cassava', 'ZA'), ('Cassava', 'AR'),
    ('Cassava', 'US'), ('Cassava', 'CA'), ('Cassava', 'AU'),

    -- Galangal: Southeast Asian spice root
    ('Galangal', 'IN'), ('Galangal', 'CN'), ('Galangal', 'JP'),
    ('Galangal', 'AU'),
    ('Galangal', 'DE'), ('Galangal', 'NL'), ('Galangal', 'GB'), ('Galangal', 'FR'),
    ('Galangal', 'US'), ('Galangal', 'CA'),

    -- Ginger: tropical origin, widely grown globally
    ('Ginger', 'IN'), ('Ginger', 'CN'), ('Ginger', 'JP'),
    ('Ginger', 'ZA'), ('Ginger', 'BR'),
    ('Ginger', 'AU'),
    ('Ginger', 'DE'), ('Ginger', 'NL'), ('Ginger', 'GB'), ('Ginger', 'FR'), ('Ginger', 'BE'),
    ('Ginger', 'US'), ('Ginger', 'CA'),

    -- Hamburg Parsley: central European root vegetable
    ('Hamburg Parsley', 'DE'), ('Hamburg Parsley', 'AT'), ('Hamburg Parsley', 'CH'),
    ('Hamburg Parsley', 'PL'), ('Hamburg Parsley', 'CZ'),
    ('Hamburg Parsley', 'NL'), ('Hamburg Parsley', 'BE'), ('Hamburg Parsley', 'FR'),
    ('Hamburg Parsley', 'GB'), ('Hamburg Parsley', 'DK'), ('Hamburg Parsley', 'SE'),

    -- Horseradish: eastern European origin
    ('Horseradish', 'DE'), ('Horseradish', 'AT'), ('Horseradish', 'CH'), ('Horseradish', 'CZ'),
    ('Horseradish', 'HU'), ('Horseradish', 'PL'), ('Horseradish', 'UA'), ('Horseradish', 'SK'),
    ('Horseradish', 'RO'), ('Horseradish', 'NL'), ('Horseradish', 'GB'), ('Horseradish', 'SE'),
    ('Horseradish', 'DK'),
    ('Horseradish', 'US'), ('Horseradish', 'CA'), ('Horseradish', 'AU'),

    -- Jicama: Mexican root vegetable
    ('Jicama', 'MX'), ('Jicama', 'CN'),
    ('Jicama', 'NL'), ('Jicama', 'DE'), ('Jicama', 'GB'),
    ('Jicama', 'US'), ('Jicama', 'CA'), ('Jicama', 'AU'),

    -- Rutabaga: Scandinavian/northern European root
    ('Rutabaga', 'GB'), ('Rutabaga', 'SE'), ('Rutabaga', 'NO'), ('Rutabaga', 'FI'),
    ('Rutabaga', 'DK'), ('Rutabaga', 'DE'), ('Rutabaga', 'NL'), ('Rutabaga', 'BE'),
    ('Rutabaga', 'FR'),
    ('Rutabaga', 'CA'), ('Rutabaga', 'US'), ('Rutabaga', 'AU'), ('Rutabaga', 'NZ'),

    -- Salsify: European root vegetable
    ('Salsify', 'FR'), ('Salsify', 'IT'), ('Salsify', 'ES'), ('Salsify', 'PT'),
    ('Salsify', 'DE'), ('Salsify', 'NL'), ('Salsify', 'BE'), ('Salsify', 'AT'), ('Salsify', 'CH'),
    ('Salsify', 'GB'),
    ('Salsify', 'US'), ('Salsify', 'CA'), ('Salsify', 'AU'),

    -- Scorzonera: European specialty root
    ('Scorzonera', 'DE'), ('Scorzonera', 'AT'), ('Scorzonera', 'CH'), ('Scorzonera', 'NL'),
    ('Scorzonera', 'BE'), ('Scorzonera', 'FR'), ('Scorzonera', 'GB'), ('Scorzonera', 'IT'),
    ('Scorzonera', 'ES'), ('Scorzonera', 'DK'), ('Scorzonera', 'SE'), ('Scorzonera', 'PL'),
    ('Scorzonera', 'CZ'),
    ('Scorzonera', 'US'), ('Scorzonera', 'CA'),

    -- Taro: tropical root crop, widely grown
    ('Taro', 'IN'), ('Taro', 'CN'), ('Taro', 'JP'),
    ('Taro', 'ZA'), ('Taro', 'BR'), ('Taro', 'MX'),
    ('Taro', 'AU'),
    ('Taro', 'NL'), ('Taro', 'DE'), ('Taro', 'GB'),
    ('Taro', 'US'), ('Taro', 'CA'),

    -- Tigernut: Mediterranean and African
    ('Tigernut', 'ES'), ('Tigernut', 'IT'), ('Tigernut', 'PT'), ('Tigernut', 'ZA'),
    ('Tigernut', 'IN'), ('Tigernut', 'CN'),
    ('Tigernut', 'US'), ('Tigernut', 'CA'), ('Tigernut', 'AU'),

    -- Turmeric: South Asian spice root
    ('Turmeric', 'IN'), ('Turmeric', 'CN'), ('Turmeric', 'JP'),
    ('Turmeric', 'ZA'), ('Turmeric', 'BR'),
    ('Turmeric', 'AU'),
    ('Turmeric', 'DE'), ('Turmeric', 'NL'), ('Turmeric', 'GB'),
    ('Turmeric', 'US'), ('Turmeric', 'CA'),

    -- Wasabi: Japanese specialty
    ('Wasabi', 'JP'), ('Wasabi', 'CN'),
    ('Wasabi', 'NZ'), ('Wasabi', 'AU'),
    ('Wasabi', 'NL'), ('Wasabi', 'DE'), ('Wasabi', 'GB'),
    ('Wasabi', 'US'), ('Wasabi', 'CA'),

    -- Water Chestnut: Asian aquatic crop
    ('Water Chestnut', 'CN'), ('Water Chestnut', 'JP'), ('Water Chestnut', 'IN'),
    ('Water Chestnut', 'AU'),
    ('Water Chestnut', 'DE'), ('Water Chestnut', 'NL'), ('Water Chestnut', 'GB'),
    ('Water Chestnut', 'US'), ('Water Chestnut', 'CA'),

    -- Yam: tropical tuber, widely grown
    ('Yam', 'IN'), ('Yam', 'CN'), ('Yam', 'ZA'), ('Yam', 'BR'), ('Yam', 'MX'),
    ('Yam', 'AU'),
    ('Yam', 'NL'), ('Yam', 'DE'), ('Yam', 'GB'),
    ('Yam', 'US'), ('Yam', 'CA'),

    -- =========================================================
    -- V14 SPECIALTY VEGETABLES
    -- =========================================================

    -- Cardoon: Mediterranean thistle vegetable
    ('Cardoon', 'IT'), ('Cardoon', 'ES'), ('Cardoon', 'FR'), ('Cardoon', 'PT'),
    ('Cardoon', 'AT'), ('Cardoon', 'CH'), ('Cardoon', 'DE'), ('Cardoon', 'NL'), ('Cardoon', 'GB'),
    ('Cardoon', 'AR'),
    ('Cardoon', 'US'), ('Cardoon', 'CA'), ('Cardoon', 'AU'),

    -- Elephant Garlic: widely grown, mild garlic relative
    ('Elephant Garlic', 'US'), ('Elephant Garlic', 'CA'),
    ('Elephant Garlic', 'GB'), ('Elephant Garlic', 'AU'), ('Elephant Garlic', 'NZ'),
    ('Elephant Garlic', 'NL'), ('Elephant Garlic', 'DE'), ('Elephant Garlic', 'FR'),
    ('Elephant Garlic', 'ES'), ('Elephant Garlic', 'IT'), ('Elephant Garlic', 'PT'),

    -- Lotus Root: Asian aquatic vegetable
    ('Lotus Root', 'CN'), ('Lotus Root', 'JP'), ('Lotus Root', 'IN'),
    ('Lotus Root', 'AU'),
    ('Lotus Root', 'DE'), ('Lotus Root', 'NL'), ('Lotus Root', 'GB'),
    ('Lotus Root', 'US'), ('Lotus Root', 'CA'),

    -- Nopal: Mexican cactus vegetable
    ('Nopal', 'MX'), ('Nopal', 'IT'), ('Nopal', 'ES'), ('Nopal', 'PT'),
    ('Nopal', 'ZA'), ('Nopal', 'AR'), ('Nopal', 'BR'),
    ('Nopal', 'US'), ('Nopal', 'CA'), ('Nopal', 'AU'),

    -- Welsh Onion: Asian origin, widely grown
    ('Welsh Onion', 'CN'), ('Welsh Onion', 'JP'),
    ('Welsh Onion', 'DE'), ('Welsh Onion', 'NL'), ('Welsh Onion', 'GB'),
    ('Welsh Onion', 'FR'), ('Welsh Onion', 'BE'),
    ('Welsh Onion', 'US'), ('Welsh Onion', 'CA'), ('Welsh Onion', 'AU'),

    -- Wild Leek: North American and European woodlands
    ('Wild Leek', 'US'), ('Wild Leek', 'CA'),
    ('Wild Leek', 'NO'), ('Wild Leek', 'SE'), ('Wild Leek', 'FI'),
    ('Wild Leek', 'DE'), ('Wild Leek', 'NL'), ('Wild Leek', 'GB'),
    ('Wild Leek', 'PL'), ('Wild Leek', 'CZ'), ('Wild Leek', 'AT'), ('Wild Leek', 'CH'),
    ('Wild Leek', 'AU'),

    -- =========================================================
    -- V14 SEA VEGETABLES
    -- =========================================================

    -- Aonori: Japanese green seaweed
    ('Aonori', 'JP'), ('Aonori', 'CN'),
    ('Aonori', 'AU'),
    ('Aonori', 'NL'), ('Aonori', 'DE'), ('Aonori', 'GB'),
    ('Aonori', 'US'), ('Aonori', 'CA'),

    -- Arame: Japanese brown seaweed
    ('Arame', 'JP'),
    ('Arame', 'IE'), ('Arame', 'NO'),
    ('Arame', 'NL'), ('Arame', 'DE'), ('Arame', 'GB'),
    ('Arame', 'AU'), ('Arame', 'NZ'),
    ('Arame', 'US'), ('Arame', 'CA'),

    -- Dulse: North Atlantic red seaweed
    ('Dulse', 'IE'), ('Dulse', 'GB'), ('Dulse', 'NO'), ('Dulse', 'DK'),
    ('Dulse', 'FR'),
    ('Dulse', 'CA'), ('Dulse', 'US'), ('Dulse', 'AU'), ('Dulse', 'NZ'),

    -- Hijiki: Japanese black seaweed
    ('Hijiki', 'JP'), ('Hijiki', 'CN'),
    ('Hijiki', 'NL'), ('Hijiki', 'DE'), ('Hijiki', 'GB'),
    ('Hijiki', 'AU'), ('Hijiki', 'NZ'),
    ('Hijiki', 'US'), ('Hijiki', 'CA'),

    -- Kombu: North Atlantic and Pacific kelp
    ('Kombu', 'JP'), ('Kombu', 'CN'),
    ('Kombu', 'NO'), ('Kombu', 'IE'), ('Kombu', 'GB'), ('Kombu', 'DK'), ('Kombu', 'SE'),
    ('Kombu', 'AU'), ('Kombu', 'NZ'),
    ('Kombu', 'US'), ('Kombu', 'CA'),

    -- Nori: widely consumed seaweed (sushi)
    ('Nori', 'JP'), ('Nori', 'CN'),
    ('Nori', 'NO'), ('Nori', 'IE'), ('Nori', 'GB'),
    ('Nori', 'NL'), ('Nori', 'DE'),
    ('Nori', 'AU'), ('Nori', 'NZ'),
    ('Nori', 'US'), ('Nori', 'CA'),

    -- Sea Lettuce: widespread green seaweed
    ('Sea Lettuce', 'GB'), ('Sea Lettuce', 'IE'), ('Sea Lettuce', 'NO'), ('Sea Lettuce', 'DK'),
    ('Sea Lettuce', 'SE'), ('Sea Lettuce', 'FI'), ('Sea Lettuce', 'FR'),
    ('Sea Lettuce', 'NL'), ('Sea Lettuce', 'DE'),
    ('Sea Lettuce', 'AU'), ('Sea Lettuce', 'NZ'),
    ('Sea Lettuce', 'US'), ('Sea Lettuce', 'CA'),

    -- Sea Grape: Japanese/Pacific seaweed
    ('Sea Grape', 'JP'),
    ('Sea Grape', 'AU'), ('Sea Grape', 'NZ'),
    ('Sea Grape', 'NL'), ('Sea Grape', 'DE'),
    ('Sea Grape', 'US'), ('Sea Grape', 'CA'),

    -- Wakame: widely consumed Asian seaweed
    ('Wakame', 'JP'), ('Wakame', 'CN'),
    ('Wakame', 'NO'), ('Wakame', 'IE'), ('Wakame', 'GB'), ('Wakame', 'DK'), ('Wakame', 'SE'),
    ('Wakame', 'FR'),
    ('Wakame', 'AU'), ('Wakame', 'NZ'),
    ('Wakame', 'US'), ('Wakame', 'CA')

) AS m(veg_name, country_code) ON v.name = m.veg_name;
