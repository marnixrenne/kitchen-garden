CREATE TABLE harvesting_months (
    vegetable_id UUID NOT NULL,
    month_num    INT  NOT NULL,
    CONSTRAINT fk_vegetable_harvest FOREIGN KEY (vegetable_id) REFERENCES vegetables (id)
);

INSERT INTO harvesting_months (vegetable_id, month_num)
SELECT v.id, m.month_num
FROM vegetables v
JOIN (VALUES
    ('Tomato',       7), ('Tomato',       8), ('Tomato',       9), ('Tomato',      10),
    ('Cucumber',     7), ('Cucumber',     8), ('Cucumber',     9),
    ('Bell Pepper',  8), ('Bell Pepper',  9), ('Bell Pepper', 10),
    ('Zucchini',     7), ('Zucchini',     8), ('Zucchini',     9),
    ('Pumpkin',      9), ('Pumpkin',     10),
    ('Sweetcorn',    8), ('Sweetcorn',    9),
    ('Lettuce',      5), ('Lettuce',      6), ('Lettuce',      7), ('Lettuce',      8), ('Lettuce',      9), ('Lettuce',     10), ('Lettuce',     11),
    ('Spinach',      4), ('Spinach',      5), ('Spinach',      6), ('Spinach',     10), ('Spinach',     11),
    ('Rocket',       5), ('Rocket',       6), ('Rocket',       7), ('Rocket',       8), ('Rocket',       9), ('Rocket',      10), ('Rocket',      11),
    ('Kale',         9), ('Kale',        10), ('Kale',        11), ('Kale',        12), ('Kale',         1), ('Kale',         2),
    ('Cabbage',      7), ('Cabbage',      8), ('Cabbage',      9), ('Cabbage',     10),
    ('Broccoli',     6), ('Broccoli',     7), ('Broccoli',     8), ('Broccoli',     9), ('Broccoli',    10),
    ('Cauliflower',  7), ('Cauliflower',  8), ('Cauliflower',  9), ('Cauliflower', 10),
    ('Carrot',       7), ('Carrot',       8), ('Carrot',       9), ('Carrot',      10),
    ('Radish',       5), ('Radish',       6), ('Radish',       7), ('Radish',       8), ('Radish',       9), ('Radish',      10), ('Radish',      11),
    ('Beetroot',     7), ('Beetroot',     8), ('Beetroot',     9), ('Beetroot',    10),
    ('Onion',        7), ('Onion',        8), ('Onion',        9),
    ('Leek',         9), ('Leek',        10), ('Leek',        11), ('Leek',        12), ('Leek',         1), ('Leek',         2), ('Leek',         3),
    ('Pea',          6), ('Pea',          7), ('Pea',          8),
    ('Bean',         7), ('Bean',         8), ('Bean',         9), ('Bean',        10),
    ('Parsley',      6), ('Parsley',      7), ('Parsley',      8), ('Parsley',      9), ('Parsley',     10),
    ('Basil',        7), ('Basil',        8), ('Basil',        9),
    ('Dill',         7), ('Dill',         8), ('Dill',         9), ('Dill',        10),
    ('Fennel',       8), ('Fennel',       9), ('Fennel',      10)
) AS m(veg_name, month_num) ON v.name = m.veg_name;
