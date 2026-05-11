-- Country-specific seeding and harvesting months.
-- NULL country_code = global default (existing rows).
-- Southern Hemisphere (AU, NZ, ZA, AR): seasons reversed, +6 month shift.
-- Mediterranean    (ES, PT, IT):         4–6 weeks earlier, extended harvest.
-- Nordic           (NO, SE, FI):         4–6 weeks later, shorter season.

INSERT INTO seeding_months (vegetable_id, month_num, country_code)
SELECT v.id, m.month_num, m.country_code
FROM vegetables v
JOIN (VALUES
    -- ── SOUTHERN HEMISPHERE (AU, NZ, ZA, AR) ─────────────────────────────
    -- Tomato 3,4 → 9,10
    ('Tomato', 9,'AU'),('Tomato',10,'AU'),('Tomato', 9,'NZ'),('Tomato',10,'NZ'),
    ('Tomato', 9,'ZA'),('Tomato',10,'ZA'),('Tomato', 9,'AR'),('Tomato',10,'AR'),
    -- Cucumber 4,5 → 10,11
    ('Cucumber',10,'AU'),('Cucumber',11,'AU'),('Cucumber',10,'NZ'),('Cucumber',11,'NZ'),
    ('Cucumber',10,'ZA'),('Cucumber',11,'ZA'),('Cucumber',10,'AR'),('Cucumber',11,'AR'),
    -- Bell Pepper 2,3 → 8,9
    ('Bell Pepper',8,'AU'),('Bell Pepper',9,'AU'),('Bell Pepper',8,'NZ'),('Bell Pepper',9,'NZ'),
    ('Bell Pepper',8,'ZA'),('Bell Pepper',9,'ZA'),('Bell Pepper',8,'AR'),('Bell Pepper',9,'AR'),
    -- Zucchini 4,5 → 10,11
    ('Zucchini',10,'AU'),('Zucchini',11,'AU'),('Zucchini',10,'NZ'),('Zucchini',11,'NZ'),
    ('Zucchini',10,'ZA'),('Zucchini',11,'ZA'),('Zucchini',10,'AR'),('Zucchini',11,'AR'),
    -- Pumpkin 4,5 → 10,11
    ('Pumpkin',10,'AU'),('Pumpkin',11,'AU'),('Pumpkin',10,'NZ'),('Pumpkin',11,'NZ'),
    ('Pumpkin',10,'ZA'),('Pumpkin',11,'ZA'),('Pumpkin',10,'AR'),('Pumpkin',11,'AR'),
    -- Sweetcorn 4,5 → 10,11
    ('Sweetcorn',10,'AU'),('Sweetcorn',11,'AU'),('Sweetcorn',10,'NZ'),('Sweetcorn',11,'NZ'),
    ('Sweetcorn',10,'ZA'),('Sweetcorn',11,'ZA'),('Sweetcorn',10,'AR'),('Sweetcorn',11,'AR'),
    -- Lettuce 3,4,8,9 → 9,10,2,3
    ('Lettuce', 9,'AU'),('Lettuce',10,'AU'),('Lettuce',2,'AU'),('Lettuce',3,'AU'),
    ('Lettuce', 9,'NZ'),('Lettuce',10,'NZ'),('Lettuce',2,'NZ'),('Lettuce',3,'NZ'),
    ('Lettuce', 9,'ZA'),('Lettuce',10,'ZA'),('Lettuce',2,'ZA'),('Lettuce',3,'ZA'),
    ('Lettuce', 9,'AR'),('Lettuce',10,'AR'),('Lettuce',2,'AR'),('Lettuce',3,'AR'),
    -- Spinach 3,4,8,9 → 9,10,2,3
    ('Spinach', 9,'AU'),('Spinach',10,'AU'),('Spinach',2,'AU'),('Spinach',3,'AU'),
    ('Spinach', 9,'NZ'),('Spinach',10,'NZ'),('Spinach',2,'NZ'),('Spinach',3,'NZ'),
    ('Spinach', 9,'ZA'),('Spinach',10,'ZA'),('Spinach',2,'ZA'),('Spinach',3,'ZA'),
    ('Spinach', 9,'AR'),('Spinach',10,'AR'),('Spinach',2,'AR'),('Spinach',3,'AR'),
    -- Rocket 3–9 → 9–3
    ('Rocket', 9,'AU'),('Rocket',10,'AU'),('Rocket',11,'AU'),('Rocket',12,'AU'),('Rocket',1,'AU'),('Rocket',2,'AU'),('Rocket',3,'AU'),
    ('Rocket', 9,'NZ'),('Rocket',10,'NZ'),('Rocket',11,'NZ'),('Rocket',12,'NZ'),('Rocket',1,'NZ'),('Rocket',2,'NZ'),('Rocket',3,'NZ'),
    ('Rocket', 9,'ZA'),('Rocket',10,'ZA'),('Rocket',11,'ZA'),('Rocket',12,'ZA'),('Rocket',1,'ZA'),('Rocket',2,'ZA'),('Rocket',3,'ZA'),
    ('Rocket', 9,'AR'),('Rocket',10,'AR'),('Rocket',11,'AR'),('Rocket',12,'AR'),('Rocket',1,'AR'),('Rocket',2,'AR'),('Rocket',3,'AR'),
    -- Kale 5,6,7 → 11,12,1
    ('Kale',11,'AU'),('Kale',12,'AU'),('Kale',1,'AU'),
    ('Kale',11,'NZ'),('Kale',12,'NZ'),('Kale',1,'NZ'),
    ('Kale',11,'ZA'),('Kale',12,'ZA'),('Kale',1,'ZA'),
    ('Kale',11,'AR'),('Kale',12,'AR'),('Kale',1,'AR'),
    -- Cabbage 2,3,7,8 → 8,9,1,2
    ('Cabbage',8,'AU'),('Cabbage',9,'AU'),('Cabbage',1,'AU'),('Cabbage',2,'AU'),
    ('Cabbage',8,'NZ'),('Cabbage',9,'NZ'),('Cabbage',1,'NZ'),('Cabbage',2,'NZ'),
    ('Cabbage',8,'ZA'),('Cabbage',9,'ZA'),('Cabbage',1,'ZA'),('Cabbage',2,'ZA'),
    ('Cabbage',8,'AR'),('Cabbage',9,'AR'),('Cabbage',1,'AR'),('Cabbage',2,'AR'),
    -- Broccoli 3,4,7,8 → 9,10,1,2
    ('Broccoli',9,'AU'),('Broccoli',10,'AU'),('Broccoli',1,'AU'),('Broccoli',2,'AU'),
    ('Broccoli',9,'NZ'),('Broccoli',10,'NZ'),('Broccoli',1,'NZ'),('Broccoli',2,'NZ'),
    ('Broccoli',9,'ZA'),('Broccoli',10,'ZA'),('Broccoli',1,'ZA'),('Broccoli',2,'ZA'),
    ('Broccoli',9,'AR'),('Broccoli',10,'AR'),('Broccoli',1,'AR'),('Broccoli',2,'AR'),
    -- Cauliflower 2,3,7,8 → 8,9,1,2
    ('Cauliflower',8,'AU'),('Cauliflower',9,'AU'),('Cauliflower',1,'AU'),('Cauliflower',2,'AU'),
    ('Cauliflower',8,'NZ'),('Cauliflower',9,'NZ'),('Cauliflower',1,'NZ'),('Cauliflower',2,'NZ'),
    ('Cauliflower',8,'ZA'),('Cauliflower',9,'ZA'),('Cauliflower',1,'ZA'),('Cauliflower',2,'ZA'),
    ('Cauliflower',8,'AR'),('Cauliflower',9,'AR'),('Cauliflower',1,'AR'),('Cauliflower',2,'AR'),
    -- Carrot 3–8 → 9–2
    ('Carrot', 9,'AU'),('Carrot',10,'AU'),('Carrot',11,'AU'),('Carrot',12,'AU'),('Carrot',1,'AU'),('Carrot',2,'AU'),
    ('Carrot', 9,'NZ'),('Carrot',10,'NZ'),('Carrot',11,'NZ'),('Carrot',12,'NZ'),('Carrot',1,'NZ'),('Carrot',2,'NZ'),
    ('Carrot', 9,'ZA'),('Carrot',10,'ZA'),('Carrot',11,'ZA'),('Carrot',12,'ZA'),('Carrot',1,'ZA'),('Carrot',2,'ZA'),
    ('Carrot', 9,'AR'),('Carrot',10,'AR'),('Carrot',11,'AR'),('Carrot',12,'AR'),('Carrot',1,'AR'),('Carrot',2,'AR'),
    -- Radish 3–9 → 9–3
    ('Radish', 9,'AU'),('Radish',10,'AU'),('Radish',11,'AU'),('Radish',12,'AU'),('Radish',1,'AU'),('Radish',2,'AU'),('Radish',3,'AU'),
    ('Radish', 9,'NZ'),('Radish',10,'NZ'),('Radish',11,'NZ'),('Radish',12,'NZ'),('Radish',1,'NZ'),('Radish',2,'NZ'),('Radish',3,'NZ'),
    ('Radish', 9,'ZA'),('Radish',10,'ZA'),('Radish',11,'ZA'),('Radish',12,'ZA'),('Radish',1,'ZA'),('Radish',2,'ZA'),('Radish',3,'ZA'),
    ('Radish', 9,'AR'),('Radish',10,'AR'),('Radish',11,'AR'),('Radish',12,'AR'),('Radish',1,'AR'),('Radish',2,'AR'),('Radish',3,'AR'),
    -- Beetroot 3–7 → 9–1
    ('Beetroot', 9,'AU'),('Beetroot',10,'AU'),('Beetroot',11,'AU'),('Beetroot',12,'AU'),('Beetroot',1,'AU'),
    ('Beetroot', 9,'NZ'),('Beetroot',10,'NZ'),('Beetroot',11,'NZ'),('Beetroot',12,'NZ'),('Beetroot',1,'NZ'),
    ('Beetroot', 9,'ZA'),('Beetroot',10,'ZA'),('Beetroot',11,'ZA'),('Beetroot',12,'ZA'),('Beetroot',1,'ZA'),
    ('Beetroot', 9,'AR'),('Beetroot',10,'AR'),('Beetroot',11,'AR'),('Beetroot',12,'AR'),('Beetroot',1,'AR'),
    -- Onion 1,2,3,8,9 → 7,8,9,2,3
    ('Onion',7,'AU'),('Onion',8,'AU'),('Onion',9,'AU'),('Onion',2,'AU'),('Onion',3,'AU'),
    ('Onion',7,'NZ'),('Onion',8,'NZ'),('Onion',9,'NZ'),('Onion',2,'NZ'),('Onion',3,'NZ'),
    ('Onion',7,'ZA'),('Onion',8,'ZA'),('Onion',9,'ZA'),('Onion',2,'ZA'),('Onion',3,'ZA'),
    ('Onion',7,'AR'),('Onion',8,'AR'),('Onion',9,'AR'),('Onion',2,'AR'),('Onion',3,'AR'),
    -- Leek 2,3,4 → 8,9,10
    ('Leek',8,'AU'),('Leek',9,'AU'),('Leek',10,'AU'),
    ('Leek',8,'NZ'),('Leek',9,'NZ'),('Leek',10,'NZ'),
    ('Leek',8,'ZA'),('Leek',9,'ZA'),('Leek',10,'ZA'),
    ('Leek',8,'AR'),('Leek',9,'AR'),('Leek',10,'AR'),
    -- Pea 2,3,9,10 → 8,9,3,4
    ('Pea',8,'AU'),('Pea',9,'AU'),('Pea',3,'AU'),('Pea',4,'AU'),
    ('Pea',8,'NZ'),('Pea',9,'NZ'),('Pea',3,'NZ'),('Pea',4,'NZ'),
    ('Pea',8,'ZA'),('Pea',9,'ZA'),('Pea',3,'ZA'),('Pea',4,'ZA'),
    ('Pea',8,'AR'),('Pea',9,'AR'),('Pea',3,'AR'),('Pea',4,'AR'),
    -- Bean 5,6 → 11,12
    ('Bean',11,'AU'),('Bean',12,'AU'),('Bean',11,'NZ'),('Bean',12,'NZ'),
    ('Bean',11,'ZA'),('Bean',12,'ZA'),('Bean',11,'AR'),('Bean',12,'AR'),
    -- Parsley 3,4 → 9,10
    ('Parsley',9,'AU'),('Parsley',10,'AU'),('Parsley',9,'NZ'),('Parsley',10,'NZ'),
    ('Parsley',9,'ZA'),('Parsley',10,'ZA'),('Parsley',9,'AR'),('Parsley',10,'AR'),
    -- Basil 4,5 → 10,11
    ('Basil',10,'AU'),('Basil',11,'AU'),('Basil',10,'NZ'),('Basil',11,'NZ'),
    ('Basil',10,'ZA'),('Basil',11,'ZA'),('Basil',10,'AR'),('Basil',11,'AR'),
    -- Dill 4,5,6 → 10,11,12
    ('Dill',10,'AU'),('Dill',11,'AU'),('Dill',12,'AU'),
    ('Dill',10,'NZ'),('Dill',11,'NZ'),('Dill',12,'NZ'),
    ('Dill',10,'ZA'),('Dill',11,'ZA'),('Dill',12,'ZA'),
    ('Dill',10,'AR'),('Dill',11,'AR'),('Dill',12,'AR'),
    -- Fennel 4,5 → 10,11
    ('Fennel',10,'AU'),('Fennel',11,'AU'),('Fennel',10,'NZ'),('Fennel',11,'NZ'),
    ('Fennel',10,'ZA'),('Fennel',11,'ZA'),('Fennel',10,'AR'),('Fennel',11,'AR'),

    -- ── MEDITERRANEAN (ES, PT, IT) ────────────────────────────────────────
    -- Tomato: 2,3 (was 3,4)
    ('Tomato',2,'ES'),('Tomato',3,'ES'),('Tomato',2,'PT'),('Tomato',3,'PT'),('Tomato',2,'IT'),('Tomato',3,'IT'),
    -- Cucumber: 3,4 (was 4,5)
    ('Cucumber',3,'ES'),('Cucumber',4,'ES'),('Cucumber',3,'PT'),('Cucumber',4,'PT'),('Cucumber',3,'IT'),('Cucumber',4,'IT'),
    -- Bell Pepper: 1,2 (was 2,3)
    ('Bell Pepper',1,'ES'),('Bell Pepper',2,'ES'),('Bell Pepper',1,'PT'),('Bell Pepper',2,'PT'),('Bell Pepper',1,'IT'),('Bell Pepper',2,'IT'),
    -- Zucchini: 3,4 (was 4,5)
    ('Zucchini',3,'ES'),('Zucchini',4,'ES'),('Zucchini',3,'PT'),('Zucchini',4,'PT'),('Zucchini',3,'IT'),('Zucchini',4,'IT'),
    -- Pumpkin: 3,4 (was 4,5)
    ('Pumpkin',3,'ES'),('Pumpkin',4,'ES'),('Pumpkin',3,'PT'),('Pumpkin',4,'PT'),('Pumpkin',3,'IT'),('Pumpkin',4,'IT'),
    -- Sweetcorn: 3,4 (was 4,5)
    ('Sweetcorn',3,'ES'),('Sweetcorn',4,'ES'),('Sweetcorn',3,'PT'),('Sweetcorn',4,'PT'),('Sweetcorn',3,'IT'),('Sweetcorn',4,'IT'),
    -- Lettuce: 2,3,9,10 (was 3,4,8,9)
    ('Lettuce',2,'ES'),('Lettuce',3,'ES'),('Lettuce',9,'ES'),('Lettuce',10,'ES'),
    ('Lettuce',2,'PT'),('Lettuce',3,'PT'),('Lettuce',9,'PT'),('Lettuce',10,'PT'),
    ('Lettuce',2,'IT'),('Lettuce',3,'IT'),('Lettuce',9,'IT'),('Lettuce',10,'IT'),
    -- Spinach: 2,3,9,10 (was 3,4,8,9)
    ('Spinach',2,'ES'),('Spinach',3,'ES'),('Spinach',9,'ES'),('Spinach',10,'ES'),
    ('Spinach',2,'PT'),('Spinach',3,'PT'),('Spinach',9,'PT'),('Spinach',10,'PT'),
    ('Spinach',2,'IT'),('Spinach',3,'IT'),('Spinach',9,'IT'),('Spinach',10,'IT'),
    -- Kale: 4,5,6 (was 5,6,7)
    ('Kale',4,'ES'),('Kale',5,'ES'),('Kale',6,'ES'),('Kale',4,'PT'),('Kale',5,'PT'),('Kale',6,'PT'),('Kale',4,'IT'),('Kale',5,'IT'),('Kale',6,'IT'),
    -- Cabbage: 1,2,7,8 (was 2,3,7,8)
    ('Cabbage',1,'ES'),('Cabbage',2,'ES'),('Cabbage',7,'ES'),('Cabbage',8,'ES'),
    ('Cabbage',1,'PT'),('Cabbage',2,'PT'),('Cabbage',7,'PT'),('Cabbage',8,'PT'),
    ('Cabbage',1,'IT'),('Cabbage',2,'IT'),('Cabbage',7,'IT'),('Cabbage',8,'IT'),
    -- Broccoli: 2,3,7,8 (was 3,4,7,8)
    ('Broccoli',2,'ES'),('Broccoli',3,'ES'),('Broccoli',7,'ES'),('Broccoli',8,'ES'),
    ('Broccoli',2,'PT'),('Broccoli',3,'PT'),('Broccoli',7,'PT'),('Broccoli',8,'PT'),
    ('Broccoli',2,'IT'),('Broccoli',3,'IT'),('Broccoli',7,'IT'),('Broccoli',8,'IT'),
    -- Cauliflower: 1,2,7,8 (was 2,3,7,8)
    ('Cauliflower',1,'ES'),('Cauliflower',2,'ES'),('Cauliflower',7,'ES'),('Cauliflower',8,'ES'),
    ('Cauliflower',1,'PT'),('Cauliflower',2,'PT'),('Cauliflower',7,'PT'),('Cauliflower',8,'PT'),
    ('Cauliflower',1,'IT'),('Cauliflower',2,'IT'),('Cauliflower',7,'IT'),('Cauliflower',8,'IT'),
    -- Carrot: 2–8 (was 3–8)
    ('Carrot',2,'ES'),('Carrot',3,'ES'),('Carrot',4,'ES'),('Carrot',5,'ES'),('Carrot',6,'ES'),('Carrot',7,'ES'),('Carrot',8,'ES'),
    ('Carrot',2,'PT'),('Carrot',3,'PT'),('Carrot',4,'PT'),('Carrot',5,'PT'),('Carrot',6,'PT'),('Carrot',7,'PT'),('Carrot',8,'PT'),
    ('Carrot',2,'IT'),('Carrot',3,'IT'),('Carrot',4,'IT'),('Carrot',5,'IT'),('Carrot',6,'IT'),('Carrot',7,'IT'),('Carrot',8,'IT'),
    -- Beetroot: 2–6 (was 3–7)
    ('Beetroot',2,'ES'),('Beetroot',3,'ES'),('Beetroot',4,'ES'),('Beetroot',5,'ES'),('Beetroot',6,'ES'),
    ('Beetroot',2,'PT'),('Beetroot',3,'PT'),('Beetroot',4,'PT'),('Beetroot',5,'PT'),('Beetroot',6,'PT'),
    ('Beetroot',2,'IT'),('Beetroot',3,'IT'),('Beetroot',4,'IT'),('Beetroot',5,'IT'),('Beetroot',6,'IT'),
    -- Pea: 1,2,10,11 (was 2,3,9,10)
    ('Pea',1,'ES'),('Pea',2,'ES'),('Pea',10,'ES'),('Pea',11,'ES'),
    ('Pea',1,'PT'),('Pea',2,'PT'),('Pea',10,'PT'),('Pea',11,'PT'),
    ('Pea',1,'IT'),('Pea',2,'IT'),('Pea',10,'IT'),('Pea',11,'IT'),
    -- Bean: 4,5 (was 5,6)
    ('Bean',4,'ES'),('Bean',5,'ES'),('Bean',4,'PT'),('Bean',5,'PT'),('Bean',4,'IT'),('Bean',5,'IT'),
    -- Basil: 3,4 (was 4,5)
    ('Basil',3,'ES'),('Basil',4,'ES'),('Basil',3,'PT'),('Basil',4,'PT'),('Basil',3,'IT'),('Basil',4,'IT'),

    -- ── NORDIC (NO, SE, FI) ───────────────────────────────────────────────
    -- Tomato: 4,5 (was 3,4)
    ('Tomato',4,'NO'),('Tomato',5,'NO'),('Tomato',4,'SE'),('Tomato',5,'SE'),('Tomato',4,'FI'),('Tomato',5,'FI'),
    -- Cucumber: 5,6 (was 4,5)
    ('Cucumber',5,'NO'),('Cucumber',6,'NO'),('Cucumber',5,'SE'),('Cucumber',6,'SE'),('Cucumber',5,'FI'),('Cucumber',6,'FI'),
    -- Bell Pepper: 3,4 (was 2,3)
    ('Bell Pepper',3,'NO'),('Bell Pepper',4,'NO'),('Bell Pepper',3,'SE'),('Bell Pepper',4,'SE'),('Bell Pepper',3,'FI'),('Bell Pepper',4,'FI'),
    -- Zucchini: 5,6 (was 4,5)
    ('Zucchini',5,'NO'),('Zucchini',6,'NO'),('Zucchini',5,'SE'),('Zucchini',6,'SE'),('Zucchini',5,'FI'),('Zucchini',6,'FI'),
    -- Pumpkin: 5 (was 4,5)
    ('Pumpkin',5,'NO'),('Pumpkin',5,'SE'),('Pumpkin',5,'FI'),
    -- Sweetcorn: 5 (was 4,5)
    ('Sweetcorn',5,'NO'),('Sweetcorn',5,'SE'),('Sweetcorn',5,'FI'),
    -- Lettuce: 4,5,8 (was 3,4,8,9 — narrow autumn window)
    ('Lettuce',4,'NO'),('Lettuce',5,'NO'),('Lettuce',8,'NO'),
    ('Lettuce',4,'SE'),('Lettuce',5,'SE'),('Lettuce',8,'SE'),
    ('Lettuce',4,'FI'),('Lettuce',5,'FI'),('Lettuce',8,'FI'),
    -- Spinach: 4,5,8 (was 3,4,8,9)
    ('Spinach',4,'NO'),('Spinach',5,'NO'),('Spinach',8,'NO'),
    ('Spinach',4,'SE'),('Spinach',5,'SE'),('Spinach',8,'SE'),
    ('Spinach',4,'FI'),('Spinach',5,'FI'),('Spinach',8,'FI'),
    -- Kale: 6,7 (was 5,6,7)
    ('Kale',6,'NO'),('Kale',7,'NO'),('Kale',6,'SE'),('Kale',7,'SE'),('Kale',6,'FI'),('Kale',7,'FI'),
    -- Carrot: 5,6,7 (was 3–8)
    ('Carrot',5,'NO'),('Carrot',6,'NO'),('Carrot',7,'NO'),
    ('Carrot',5,'SE'),('Carrot',6,'SE'),('Carrot',7,'SE'),
    ('Carrot',5,'FI'),('Carrot',6,'FI'),('Carrot',7,'FI'),
    -- Radish: 5,6,7,8 (was 3–9)
    ('Radish',5,'NO'),('Radish',6,'NO'),('Radish',7,'NO'),('Radish',8,'NO'),
    ('Radish',5,'SE'),('Radish',6,'SE'),('Radish',7,'SE'),('Radish',8,'SE'),
    ('Radish',5,'FI'),('Radish',6,'FI'),('Radish',7,'FI'),('Radish',8,'FI'),
    -- Beetroot: 5,6 (was 3–7)
    ('Beetroot',5,'NO'),('Beetroot',6,'NO'),('Beetroot',5,'SE'),('Beetroot',6,'SE'),('Beetroot',5,'FI'),('Beetroot',6,'FI'),
    -- Pea: 4,5 (was 2,3,9,10 — spring only, no autumn sowing)
    ('Pea',4,'NO'),('Pea',5,'NO'),('Pea',4,'SE'),('Pea',5,'SE'),('Pea',4,'FI'),('Pea',5,'FI'),
    -- Bean: 6 (was 5,6)
    ('Bean',6,'NO'),('Bean',6,'SE'),('Bean',6,'FI'),
    -- Basil: 5,6 (was 4,5)
    ('Basil',5,'NO'),('Basil',6,'NO'),('Basil',5,'SE'),('Basil',6,'SE'),('Basil',5,'FI'),('Basil',6,'FI')
) AS m(veg_name, month_num, country_code) ON v.name = m.veg_name
ON CONFLICT DO NOTHING;


INSERT INTO harvesting_months (vegetable_id, month_num, country_code)
SELECT v.id, m.month_num, m.country_code
FROM vegetables v
JOIN (VALUES
    -- ── SOUTHERN HEMISPHERE (AU, NZ, ZA, AR) ─────────────────────────────
    -- Tomato 7,8,9,10 → 1,2,3,4
    ('Tomato',1,'AU'),('Tomato',2,'AU'),('Tomato',3,'AU'),('Tomato',4,'AU'),
    ('Tomato',1,'NZ'),('Tomato',2,'NZ'),('Tomato',3,'NZ'),('Tomato',4,'NZ'),
    ('Tomato',1,'ZA'),('Tomato',2,'ZA'),('Tomato',3,'ZA'),('Tomato',4,'ZA'),
    ('Tomato',1,'AR'),('Tomato',2,'AR'),('Tomato',3,'AR'),('Tomato',4,'AR'),
    -- Cucumber 7,8,9 → 1,2,3
    ('Cucumber',1,'AU'),('Cucumber',2,'AU'),('Cucumber',3,'AU'),
    ('Cucumber',1,'NZ'),('Cucumber',2,'NZ'),('Cucumber',3,'NZ'),
    ('Cucumber',1,'ZA'),('Cucumber',2,'ZA'),('Cucumber',3,'ZA'),
    ('Cucumber',1,'AR'),('Cucumber',2,'AR'),('Cucumber',3,'AR'),
    -- Bell Pepper 8,9,10 → 2,3,4
    ('Bell Pepper',2,'AU'),('Bell Pepper',3,'AU'),('Bell Pepper',4,'AU'),
    ('Bell Pepper',2,'NZ'),('Bell Pepper',3,'NZ'),('Bell Pepper',4,'NZ'),
    ('Bell Pepper',2,'ZA'),('Bell Pepper',3,'ZA'),('Bell Pepper',4,'ZA'),
    ('Bell Pepper',2,'AR'),('Bell Pepper',3,'AR'),('Bell Pepper',4,'AR'),
    -- Zucchini 7,8,9 → 1,2,3
    ('Zucchini',1,'AU'),('Zucchini',2,'AU'),('Zucchini',3,'AU'),
    ('Zucchini',1,'NZ'),('Zucchini',2,'NZ'),('Zucchini',3,'NZ'),
    ('Zucchini',1,'ZA'),('Zucchini',2,'ZA'),('Zucchini',3,'ZA'),
    ('Zucchini',1,'AR'),('Zucchini',2,'AR'),('Zucchini',3,'AR'),
    -- Pumpkin 9,10 → 3,4
    ('Pumpkin',3,'AU'),('Pumpkin',4,'AU'),('Pumpkin',3,'NZ'),('Pumpkin',4,'NZ'),
    ('Pumpkin',3,'ZA'),('Pumpkin',4,'ZA'),('Pumpkin',3,'AR'),('Pumpkin',4,'AR'),
    -- Sweetcorn 8,9 → 2,3
    ('Sweetcorn',2,'AU'),('Sweetcorn',3,'AU'),('Sweetcorn',2,'NZ'),('Sweetcorn',3,'NZ'),
    ('Sweetcorn',2,'ZA'),('Sweetcorn',3,'ZA'),('Sweetcorn',2,'AR'),('Sweetcorn',3,'AR'),
    -- Lettuce 5–11 → 11,12,1,2,3,4,5
    ('Lettuce',11,'AU'),('Lettuce',12,'AU'),('Lettuce',1,'AU'),('Lettuce',2,'AU'),('Lettuce',3,'AU'),('Lettuce',4,'AU'),('Lettuce',5,'AU'),
    ('Lettuce',11,'NZ'),('Lettuce',12,'NZ'),('Lettuce',1,'NZ'),('Lettuce',2,'NZ'),('Lettuce',3,'NZ'),('Lettuce',4,'NZ'),('Lettuce',5,'NZ'),
    ('Lettuce',11,'ZA'),('Lettuce',12,'ZA'),('Lettuce',1,'ZA'),('Lettuce',2,'ZA'),('Lettuce',3,'ZA'),('Lettuce',4,'ZA'),('Lettuce',5,'ZA'),
    ('Lettuce',11,'AR'),('Lettuce',12,'AR'),('Lettuce',1,'AR'),('Lettuce',2,'AR'),('Lettuce',3,'AR'),('Lettuce',4,'AR'),('Lettuce',5,'AR'),
    -- Spinach 4,5,6,10,11 → 10,11,12,4,5
    ('Spinach',10,'AU'),('Spinach',11,'AU'),('Spinach',12,'AU'),('Spinach',4,'AU'),('Spinach',5,'AU'),
    ('Spinach',10,'NZ'),('Spinach',11,'NZ'),('Spinach',12,'NZ'),('Spinach',4,'NZ'),('Spinach',5,'NZ'),
    ('Spinach',10,'ZA'),('Spinach',11,'ZA'),('Spinach',12,'ZA'),('Spinach',4,'ZA'),('Spinach',5,'ZA'),
    ('Spinach',10,'AR'),('Spinach',11,'AR'),('Spinach',12,'AR'),('Spinach',4,'AR'),('Spinach',5,'AR'),
    -- Rocket 5–11 → 11,12,1,2,3,4,5
    ('Rocket',11,'AU'),('Rocket',12,'AU'),('Rocket',1,'AU'),('Rocket',2,'AU'),('Rocket',3,'AU'),('Rocket',4,'AU'),('Rocket',5,'AU'),
    ('Rocket',11,'NZ'),('Rocket',12,'NZ'),('Rocket',1,'NZ'),('Rocket',2,'NZ'),('Rocket',3,'NZ'),('Rocket',4,'NZ'),('Rocket',5,'NZ'),
    ('Rocket',11,'ZA'),('Rocket',12,'ZA'),('Rocket',1,'ZA'),('Rocket',2,'ZA'),('Rocket',3,'ZA'),('Rocket',4,'ZA'),('Rocket',5,'ZA'),
    ('Rocket',11,'AR'),('Rocket',12,'AR'),('Rocket',1,'AR'),('Rocket',2,'AR'),('Rocket',3,'AR'),('Rocket',4,'AR'),('Rocket',5,'AR'),
    -- Kale 9,10,11,12,1,2 → 3,4,5,6,7,8
    ('Kale',3,'AU'),('Kale',4,'AU'),('Kale',5,'AU'),('Kale',6,'AU'),('Kale',7,'AU'),('Kale',8,'AU'),
    ('Kale',3,'NZ'),('Kale',4,'NZ'),('Kale',5,'NZ'),('Kale',6,'NZ'),('Kale',7,'NZ'),('Kale',8,'NZ'),
    ('Kale',3,'ZA'),('Kale',4,'ZA'),('Kale',5,'ZA'),('Kale',6,'ZA'),('Kale',7,'ZA'),('Kale',8,'ZA'),
    ('Kale',3,'AR'),('Kale',4,'AR'),('Kale',5,'AR'),('Kale',6,'AR'),('Kale',7,'AR'),('Kale',8,'AR'),
    -- Cabbage 7,8,9,10 → 1,2,3,4
    ('Cabbage',1,'AU'),('Cabbage',2,'AU'),('Cabbage',3,'AU'),('Cabbage',4,'AU'),
    ('Cabbage',1,'NZ'),('Cabbage',2,'NZ'),('Cabbage',3,'NZ'),('Cabbage',4,'NZ'),
    ('Cabbage',1,'ZA'),('Cabbage',2,'ZA'),('Cabbage',3,'ZA'),('Cabbage',4,'ZA'),
    ('Cabbage',1,'AR'),('Cabbage',2,'AR'),('Cabbage',3,'AR'),('Cabbage',4,'AR'),
    -- Broccoli 6,7,8,9,10 → 12,1,2,3,4
    ('Broccoli',12,'AU'),('Broccoli',1,'AU'),('Broccoli',2,'AU'),('Broccoli',3,'AU'),('Broccoli',4,'AU'),
    ('Broccoli',12,'NZ'),('Broccoli',1,'NZ'),('Broccoli',2,'NZ'),('Broccoli',3,'NZ'),('Broccoli',4,'NZ'),
    ('Broccoli',12,'ZA'),('Broccoli',1,'ZA'),('Broccoli',2,'ZA'),('Broccoli',3,'ZA'),('Broccoli',4,'ZA'),
    ('Broccoli',12,'AR'),('Broccoli',1,'AR'),('Broccoli',2,'AR'),('Broccoli',3,'AR'),('Broccoli',4,'AR'),
    -- Cauliflower 7,8,9,10 → 1,2,3,4
    ('Cauliflower',1,'AU'),('Cauliflower',2,'AU'),('Cauliflower',3,'AU'),('Cauliflower',4,'AU'),
    ('Cauliflower',1,'NZ'),('Cauliflower',2,'NZ'),('Cauliflower',3,'NZ'),('Cauliflower',4,'NZ'),
    ('Cauliflower',1,'ZA'),('Cauliflower',2,'ZA'),('Cauliflower',3,'ZA'),('Cauliflower',4,'ZA'),
    ('Cauliflower',1,'AR'),('Cauliflower',2,'AR'),('Cauliflower',3,'AR'),('Cauliflower',4,'AR'),
    -- Carrot 7,8,9,10 → 1,2,3,4
    ('Carrot',1,'AU'),('Carrot',2,'AU'),('Carrot',3,'AU'),('Carrot',4,'AU'),
    ('Carrot',1,'NZ'),('Carrot',2,'NZ'),('Carrot',3,'NZ'),('Carrot',4,'NZ'),
    ('Carrot',1,'ZA'),('Carrot',2,'ZA'),('Carrot',3,'ZA'),('Carrot',4,'ZA'),
    ('Carrot',1,'AR'),('Carrot',2,'AR'),('Carrot',3,'AR'),('Carrot',4,'AR'),
    -- Radish 5–11 → 11,12,1,2,3,4,5
    ('Radish',11,'AU'),('Radish',12,'AU'),('Radish',1,'AU'),('Radish',2,'AU'),('Radish',3,'AU'),('Radish',4,'AU'),('Radish',5,'AU'),
    ('Radish',11,'NZ'),('Radish',12,'NZ'),('Radish',1,'NZ'),('Radish',2,'NZ'),('Radish',3,'NZ'),('Radish',4,'NZ'),('Radish',5,'NZ'),
    ('Radish',11,'ZA'),('Radish',12,'ZA'),('Radish',1,'ZA'),('Radish',2,'ZA'),('Radish',3,'ZA'),('Radish',4,'ZA'),('Radish',5,'ZA'),
    ('Radish',11,'AR'),('Radish',12,'AR'),('Radish',1,'AR'),('Radish',2,'AR'),('Radish',3,'AR'),('Radish',4,'AR'),('Radish',5,'AR'),
    -- Beetroot 7,8,9,10 → 1,2,3,4
    ('Beetroot',1,'AU'),('Beetroot',2,'AU'),('Beetroot',3,'AU'),('Beetroot',4,'AU'),
    ('Beetroot',1,'NZ'),('Beetroot',2,'NZ'),('Beetroot',3,'NZ'),('Beetroot',4,'NZ'),
    ('Beetroot',1,'ZA'),('Beetroot',2,'ZA'),('Beetroot',3,'ZA'),('Beetroot',4,'ZA'),
    ('Beetroot',1,'AR'),('Beetroot',2,'AR'),('Beetroot',3,'AR'),('Beetroot',4,'AR'),
    -- Onion 7,8,9 → 1,2,3
    ('Onion',1,'AU'),('Onion',2,'AU'),('Onion',3,'AU'),
    ('Onion',1,'NZ'),('Onion',2,'NZ'),('Onion',3,'NZ'),
    ('Onion',1,'ZA'),('Onion',2,'ZA'),('Onion',3,'ZA'),
    ('Onion',1,'AR'),('Onion',2,'AR'),('Onion',3,'AR'),
    -- Leek 9,10,11,12,1,2,3 → 3,4,5,6,7,8,9
    ('Leek',3,'AU'),('Leek',4,'AU'),('Leek',5,'AU'),('Leek',6,'AU'),('Leek',7,'AU'),('Leek',8,'AU'),('Leek',9,'AU'),
    ('Leek',3,'NZ'),('Leek',4,'NZ'),('Leek',5,'NZ'),('Leek',6,'NZ'),('Leek',7,'NZ'),('Leek',8,'NZ'),('Leek',9,'NZ'),
    ('Leek',3,'ZA'),('Leek',4,'ZA'),('Leek',5,'ZA'),('Leek',6,'ZA'),('Leek',7,'ZA'),('Leek',8,'ZA'),('Leek',9,'ZA'),
    ('Leek',3,'AR'),('Leek',4,'AR'),('Leek',5,'AR'),('Leek',6,'AR'),('Leek',7,'AR'),('Leek',8,'AR'),('Leek',9,'AR'),
    -- Pea 6,7,8 → 12,1,2
    ('Pea',12,'AU'),('Pea',1,'AU'),('Pea',2,'AU'),
    ('Pea',12,'NZ'),('Pea',1,'NZ'),('Pea',2,'NZ'),
    ('Pea',12,'ZA'),('Pea',1,'ZA'),('Pea',2,'ZA'),
    ('Pea',12,'AR'),('Pea',1,'AR'),('Pea',2,'AR'),
    -- Bean 7,8,9,10 → 1,2,3,4
    ('Bean',1,'AU'),('Bean',2,'AU'),('Bean',3,'AU'),('Bean',4,'AU'),
    ('Bean',1,'NZ'),('Bean',2,'NZ'),('Bean',3,'NZ'),('Bean',4,'NZ'),
    ('Bean',1,'ZA'),('Bean',2,'ZA'),('Bean',3,'ZA'),('Bean',4,'ZA'),
    ('Bean',1,'AR'),('Bean',2,'AR'),('Bean',3,'AR'),('Bean',4,'AR'),
    -- Parsley 6,7,8,9,10 → 12,1,2,3,4
    ('Parsley',12,'AU'),('Parsley',1,'AU'),('Parsley',2,'AU'),('Parsley',3,'AU'),('Parsley',4,'AU'),
    ('Parsley',12,'NZ'),('Parsley',1,'NZ'),('Parsley',2,'NZ'),('Parsley',3,'NZ'),('Parsley',4,'NZ'),
    ('Parsley',12,'ZA'),('Parsley',1,'ZA'),('Parsley',2,'ZA'),('Parsley',3,'ZA'),('Parsley',4,'ZA'),
    ('Parsley',12,'AR'),('Parsley',1,'AR'),('Parsley',2,'AR'),('Parsley',3,'AR'),('Parsley',4,'AR'),
    -- Basil 7,8,9 → 1,2,3
    ('Basil',1,'AU'),('Basil',2,'AU'),('Basil',3,'AU'),
    ('Basil',1,'NZ'),('Basil',2,'NZ'),('Basil',3,'NZ'),
    ('Basil',1,'ZA'),('Basil',2,'ZA'),('Basil',3,'ZA'),
    ('Basil',1,'AR'),('Basil',2,'AR'),('Basil',3,'AR'),
    -- Dill 7,8,9,10 → 1,2,3,4
    ('Dill',1,'AU'),('Dill',2,'AU'),('Dill',3,'AU'),('Dill',4,'AU'),
    ('Dill',1,'NZ'),('Dill',2,'NZ'),('Dill',3,'NZ'),('Dill',4,'NZ'),
    ('Dill',1,'ZA'),('Dill',2,'ZA'),('Dill',3,'ZA'),('Dill',4,'ZA'),
    ('Dill',1,'AR'),('Dill',2,'AR'),('Dill',3,'AR'),('Dill',4,'AR'),
    -- Fennel 8,9,10 → 2,3,4
    ('Fennel',2,'AU'),('Fennel',3,'AU'),('Fennel',4,'AU'),
    ('Fennel',2,'NZ'),('Fennel',3,'NZ'),('Fennel',4,'NZ'),
    ('Fennel',2,'ZA'),('Fennel',3,'ZA'),('Fennel',4,'ZA'),
    ('Fennel',2,'AR'),('Fennel',3,'AR'),('Fennel',4,'AR'),

    -- ── MEDITERRANEAN (ES, PT, IT) ────────────────────────────────────────
    -- Tomato: 6–11 (was 7–10)
    ('Tomato',6,'ES'),('Tomato',7,'ES'),('Tomato',8,'ES'),('Tomato',9,'ES'),('Tomato',10,'ES'),('Tomato',11,'ES'),
    ('Tomato',6,'PT'),('Tomato',7,'PT'),('Tomato',8,'PT'),('Tomato',9,'PT'),('Tomato',10,'PT'),('Tomato',11,'PT'),
    ('Tomato',6,'IT'),('Tomato',7,'IT'),('Tomato',8,'IT'),('Tomato',9,'IT'),('Tomato',10,'IT'),('Tomato',11,'IT'),
    -- Cucumber: 6–10 (was 7–9)
    ('Cucumber',6,'ES'),('Cucumber',7,'ES'),('Cucumber',8,'ES'),('Cucumber',9,'ES'),('Cucumber',10,'ES'),
    ('Cucumber',6,'PT'),('Cucumber',7,'PT'),('Cucumber',8,'PT'),('Cucumber',9,'PT'),('Cucumber',10,'PT'),
    ('Cucumber',6,'IT'),('Cucumber',7,'IT'),('Cucumber',8,'IT'),('Cucumber',9,'IT'),('Cucumber',10,'IT'),
    -- Bell Pepper: 7–11 (was 8–10)
    ('Bell Pepper',7,'ES'),('Bell Pepper',8,'ES'),('Bell Pepper',9,'ES'),('Bell Pepper',10,'ES'),('Bell Pepper',11,'ES'),
    ('Bell Pepper',7,'PT'),('Bell Pepper',8,'PT'),('Bell Pepper',9,'PT'),('Bell Pepper',10,'PT'),('Bell Pepper',11,'PT'),
    ('Bell Pepper',7,'IT'),('Bell Pepper',8,'IT'),('Bell Pepper',9,'IT'),('Bell Pepper',10,'IT'),('Bell Pepper',11,'IT'),
    -- Zucchini: 6–10 (was 7–9)
    ('Zucchini',6,'ES'),('Zucchini',7,'ES'),('Zucchini',8,'ES'),('Zucchini',9,'ES'),('Zucchini',10,'ES'),
    ('Zucchini',6,'PT'),('Zucchini',7,'PT'),('Zucchini',8,'PT'),('Zucchini',9,'PT'),('Zucchini',10,'PT'),
    ('Zucchini',6,'IT'),('Zucchini',7,'IT'),('Zucchini',8,'IT'),('Zucchini',9,'IT'),('Zucchini',10,'IT'),
    -- Pumpkin: 8–11 (was 9–10)
    ('Pumpkin',8,'ES'),('Pumpkin',9,'ES'),('Pumpkin',10,'ES'),('Pumpkin',11,'ES'),
    ('Pumpkin',8,'PT'),('Pumpkin',9,'PT'),('Pumpkin',10,'PT'),('Pumpkin',11,'PT'),
    ('Pumpkin',8,'IT'),('Pumpkin',9,'IT'),('Pumpkin',10,'IT'),('Pumpkin',11,'IT'),
    -- Lettuce: 4–12 (was 5–11)
    ('Lettuce',4,'ES'),('Lettuce',5,'ES'),('Lettuce',6,'ES'),('Lettuce',7,'ES'),('Lettuce',8,'ES'),('Lettuce',9,'ES'),('Lettuce',10,'ES'),('Lettuce',11,'ES'),('Lettuce',12,'ES'),
    ('Lettuce',4,'PT'),('Lettuce',5,'PT'),('Lettuce',6,'PT'),('Lettuce',7,'PT'),('Lettuce',8,'PT'),('Lettuce',9,'PT'),('Lettuce',10,'PT'),('Lettuce',11,'PT'),('Lettuce',12,'PT'),
    ('Lettuce',4,'IT'),('Lettuce',5,'IT'),('Lettuce',6,'IT'),('Lettuce',7,'IT'),('Lettuce',8,'IT'),('Lettuce',9,'IT'),('Lettuce',10,'IT'),('Lettuce',11,'IT'),('Lettuce',12,'IT'),
    -- Spinach: 3,4,5,10,11,12 (was 4,5,6,10,11)
    ('Spinach',3,'ES'),('Spinach',4,'ES'),('Spinach',5,'ES'),('Spinach',10,'ES'),('Spinach',11,'ES'),('Spinach',12,'ES'),
    ('Spinach',3,'PT'),('Spinach',4,'PT'),('Spinach',5,'PT'),('Spinach',10,'PT'),('Spinach',11,'PT'),('Spinach',12,'PT'),
    ('Spinach',3,'IT'),('Spinach',4,'IT'),('Spinach',5,'IT'),('Spinach',10,'IT'),('Spinach',11,'IT'),('Spinach',12,'IT'),
    -- Carrot: 6–11 (was 7–10)
    ('Carrot',6,'ES'),('Carrot',7,'ES'),('Carrot',8,'ES'),('Carrot',9,'ES'),('Carrot',10,'ES'),('Carrot',11,'ES'),
    ('Carrot',6,'PT'),('Carrot',7,'PT'),('Carrot',8,'PT'),('Carrot',9,'PT'),('Carrot',10,'PT'),('Carrot',11,'PT'),
    ('Carrot',6,'IT'),('Carrot',7,'IT'),('Carrot',8,'IT'),('Carrot',9,'IT'),('Carrot',10,'IT'),('Carrot',11,'IT'),
    -- Broccoli: 5–11 (was 6–10)
    ('Broccoli',5,'ES'),('Broccoli',6,'ES'),('Broccoli',7,'ES'),('Broccoli',8,'ES'),('Broccoli',9,'ES'),('Broccoli',10,'ES'),('Broccoli',11,'ES'),
    ('Broccoli',5,'PT'),('Broccoli',6,'PT'),('Broccoli',7,'PT'),('Broccoli',8,'PT'),('Broccoli',9,'PT'),('Broccoli',10,'PT'),('Broccoli',11,'PT'),
    ('Broccoli',5,'IT'),('Broccoli',6,'IT'),('Broccoli',7,'IT'),('Broccoli',8,'IT'),('Broccoli',9,'IT'),('Broccoli',10,'IT'),('Broccoli',11,'IT'),
    -- Pea: 4,5,6 (was 6,7,8 — earlier due to mild winters)
    ('Pea',4,'ES'),('Pea',5,'ES'),('Pea',6,'ES'),('Pea',4,'PT'),('Pea',5,'PT'),('Pea',6,'PT'),('Pea',4,'IT'),('Pea',5,'IT'),('Pea',6,'IT'),
    -- Bean: 6–10 (was 7–10)
    ('Bean',6,'ES'),('Bean',7,'ES'),('Bean',8,'ES'),('Bean',9,'ES'),('Bean',10,'ES'),
    ('Bean',6,'PT'),('Bean',7,'PT'),('Bean',8,'PT'),('Bean',9,'PT'),('Bean',10,'PT'),
    ('Bean',6,'IT'),('Bean',7,'IT'),('Bean',8,'IT'),('Bean',9,'IT'),('Bean',10,'IT'),
    -- Beetroot: 6–10 (was 7–10)
    ('Beetroot',6,'ES'),('Beetroot',7,'ES'),('Beetroot',8,'ES'),('Beetroot',9,'ES'),('Beetroot',10,'ES'),
    ('Beetroot',6,'PT'),('Beetroot',7,'PT'),('Beetroot',8,'PT'),('Beetroot',9,'PT'),('Beetroot',10,'PT'),
    ('Beetroot',6,'IT'),('Beetroot',7,'IT'),('Beetroot',8,'IT'),('Beetroot',9,'IT'),('Beetroot',10,'IT'),

    -- ── NORDIC (NO, SE, FI) ───────────────────────────────────────────────
    -- Tomato: 8,9 (was 7–10)
    ('Tomato',8,'NO'),('Tomato',9,'NO'),('Tomato',8,'SE'),('Tomato',9,'SE'),('Tomato',8,'FI'),('Tomato',9,'FI'),
    -- Cucumber: 8,9 (was 7–9)
    ('Cucumber',8,'NO'),('Cucumber',9,'NO'),('Cucumber',8,'SE'),('Cucumber',9,'SE'),('Cucumber',8,'FI'),('Cucumber',9,'FI'),
    -- Bell Pepper: 9,10 (was 8–10)
    ('Bell Pepper',9,'NO'),('Bell Pepper',10,'NO'),('Bell Pepper',9,'SE'),('Bell Pepper',10,'SE'),('Bell Pepper',9,'FI'),('Bell Pepper',10,'FI'),
    -- Zucchini: 8 (was 7–9)
    ('Zucchini',8,'NO'),('Zucchini',8,'SE'),('Zucchini',8,'FI'),
    -- Pumpkin: 10 (was 9–10 — too short for 9 typically)
    ('Pumpkin',10,'NO'),('Pumpkin',10,'SE'),('Pumpkin',10,'FI'),
    -- Lettuce: 7,8,9 (was 5–11)
    ('Lettuce',7,'NO'),('Lettuce',8,'NO'),('Lettuce',9,'NO'),
    ('Lettuce',7,'SE'),('Lettuce',8,'SE'),('Lettuce',9,'SE'),
    ('Lettuce',7,'FI'),('Lettuce',8,'FI'),('Lettuce',9,'FI'),
    -- Spinach: 6,7,9,10 (was 4,5,6,10,11)
    ('Spinach',6,'NO'),('Spinach',7,'NO'),('Spinach',9,'NO'),('Spinach',10,'NO'),
    ('Spinach',6,'SE'),('Spinach',7,'SE'),('Spinach',9,'SE'),('Spinach',10,'SE'),
    ('Spinach',6,'FI'),('Spinach',7,'FI'),('Spinach',9,'FI'),('Spinach',10,'FI'),
    -- Kale: 10,11,12,1 (was 9–2 — later start, shorter into winter)
    ('Kale',10,'NO'),('Kale',11,'NO'),('Kale',12,'NO'),('Kale',1,'NO'),
    ('Kale',10,'SE'),('Kale',11,'SE'),('Kale',12,'SE'),('Kale',1,'SE'),
    ('Kale',10,'FI'),('Kale',11,'FI'),('Kale',12,'FI'),('Kale',1,'FI'),
    -- Carrot: 8,9 (was 7–10)
    ('Carrot',8,'NO'),('Carrot',9,'NO'),('Carrot',8,'SE'),('Carrot',9,'SE'),('Carrot',8,'FI'),('Carrot',9,'FI'),
    -- Radish: 6,7,8,9 (was 5–11)
    ('Radish',6,'NO'),('Radish',7,'NO'),('Radish',8,'NO'),('Radish',9,'NO'),
    ('Radish',6,'SE'),('Radish',7,'SE'),('Radish',8,'SE'),('Radish',9,'SE'),
    ('Radish',6,'FI'),('Radish',7,'FI'),('Radish',8,'FI'),('Radish',9,'FI'),
    -- Beetroot: 8,9 (was 7–10)
    ('Beetroot',8,'NO'),('Beetroot',9,'NO'),('Beetroot',8,'SE'),('Beetroot',9,'SE'),('Beetroot',8,'FI'),('Beetroot',9,'FI'),
    -- Pea: 7,8 (was 6–8)
    ('Pea',7,'NO'),('Pea',8,'NO'),('Pea',7,'SE'),('Pea',8,'SE'),('Pea',7,'FI'),('Pea',8,'FI'),
    -- Bean: 8,9 (was 7–10)
    ('Bean',8,'NO'),('Bean',9,'NO'),('Bean',8,'SE'),('Bean',9,'SE'),('Bean',8,'FI'),('Bean',9,'FI')
) AS m(veg_name, month_num, country_code) ON v.name = m.veg_name
ON CONFLICT DO NOTHING;
