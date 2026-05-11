-- Additional companion planting data based on multiple sources:
-- Old Farmer's Almanac, RHS, West Coast Seeds, UMN Extension, MOFGA, Farmers' Almanac
-- Uses ON CONFLICT DO NOTHING so it is safe to run even if some pairs already exist.

-- ============================================================
-- GOOD companions (additional)
-- ============================================================

-- Borage: deters aphids, tomato hornworm, squash vine borers
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Borage' AND v2.name = 'Tomato'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Borage' AND v2.name = 'Squash'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Borage' AND v2.name = 'Zucchini'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Borage' AND v2.name = 'Bean'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Borage' AND v2.name = 'Cucumber'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Broad Bean: fixes nitrogen, benefits potatoes and many neighbours
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Broad Bean' AND v2.name = 'Potato'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Broad Bean' AND v2.name = 'Spinach'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Broad Bean' AND v2.name = 'Borage'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Runner Bean: similar companions to bush bean
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Runner Bean' AND v2.name = 'Cucumber'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Runner Bean' AND v2.name = 'Sweetcorn'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Runner Bean' AND v2.name = 'Squash'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Swiss Chard
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Swiss Chard' AND v2.name = 'Bean'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Swiss Chard' AND v2.name = 'Onion'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Swiss Chard' AND v2.name = 'Carrot'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Collard Greens: tomatoes repel flea beetles that attack collards
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Collard Greens' AND v2.name = 'Tomato'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Collard Greens' AND v2.name = 'Onion'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Cucumber + brassicas (brassicas shade roots; cucumber shades ground)
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cucumber' AND v2.name = 'Broccoli'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cucumber' AND v2.name = 'Cabbage'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cucumber' AND v2.name = 'Cauliflower'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Kale: alliums and aromatic herbs deter pests
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Kale' AND v2.name = 'Onion'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Kale' AND v2.name = 'Garlic'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Kale' AND v2.name = 'Dill'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Cauliflower
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cauliflower' AND v2.name = 'Dill'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cauliflower' AND v2.name = 'Onion'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Cauliflower' AND v2.name = 'Celery'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Brussels Sprouts
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Brussels Sprouts' AND v2.name = 'Onion'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Brussels Sprouts' AND v2.name = 'Garlic'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Brussels Sprouts' AND v2.name = 'Celery'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Kohlrabi
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Kohlrabi' AND v2.name = 'Onion'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Kohlrabi' AND v2.name = 'Celery'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Spinach
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Spinach' AND v2.name = 'Bean'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Spinach' AND v2.name = 'Carrot'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Potato: garlic deters pests; horseradish repels Colorado potato beetle
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Potato' AND v2.name = 'Garlic'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Potato' AND v2.name = 'Horseradish'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Lettuce + Chive (chives deter aphids)
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Lettuce' AND v2.name = 'Chive'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Chive + brassicas (repels aphids and cabbage white butterfly)
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Chive' AND v2.name = 'Broccoli'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Chive' AND v2.name = 'Cauliflower'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Dill + Onion (dill attracts beneficial insects)
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Dill' AND v2.name = 'Onion'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Thyme: aromatic herb that protects brassicas and potatoes
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Thyme' AND v2.name = 'Broccoli'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Thyme' AND v2.name = 'Cauliflower'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Thyme' AND v2.name = 'Potato'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Rosemary + brassicas (repels cabbage moth and aphids)
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Rosemary' AND v2.name = 'Broccoli'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Sage + Broccoli
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Sage' AND v2.name = 'Broccoli'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Oregano: repels pests from tomatoes and peppers
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Oregano' AND v2.name = 'Tomato'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Oregano' AND v2.name = 'Bell Pepper'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Basil: broader companions beyond tomato
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Basil' AND v2.name = 'Cucumber'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Basil' AND v2.name = 'Zucchini'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Basil' AND v2.name = 'Eggplant'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Basil' AND v2.name = 'Squash'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Coriander: attracts beneficial insects, deters aphids and carrot fly
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Coriander' AND v2.name = 'Carrot'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Coriander' AND v2.name = 'Potato'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Garlic + peppers (repels aphids)
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Garlic' AND v2.name = 'Bell Pepper'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Leek + Beetroot
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Leek' AND v2.name = 'Beetroot'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Parsnip: alliums repel parsnip fly
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Parsnip' AND v2.name = 'Onion'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Parsnip' AND v2.name = 'Garlic'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Celery + Bean (celery deters bean aphids)
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Celery' AND v2.name = 'Bean'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Turnip + Onion (alliums help deter turnip pests)
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Turnip' AND v2.name = 'Onion'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- ============================================================
-- BAD companions (additional)
-- ============================================================

-- Asparagus: alliums and potatoes compete with or harm asparagus roots
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Asparagus' AND v2.name = 'Onion'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Asparagus' AND v2.name = 'Garlic'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Asparagus' AND v2.name = 'Potato'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Eggplant: nightshade diseases shared with potato; cucumber and beet compete
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Eggplant' AND v2.name = 'Potato'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Eggplant' AND v2.name = 'Cucumber'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Eggplant' AND v2.name = 'Beetroot'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Rocket: shares pests and diseases with other brassicas (cabbage white, club root)
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Rocket' AND v2.name = 'Cabbage'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Rocket' AND v2.name = 'Broccoli'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Rocket' AND v2.name = 'Cauliflower'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Rocket' AND v2.name = 'Kale'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Fennel: allelopathic, inhibits most vegetables (additional pairs beyond V23)
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Fennel' AND v2.name = 'Lettuce'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Fennel' AND v2.name = 'Bean'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Fennel' AND v2.name = 'Pea'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Fennel' AND v2.name = 'Cabbage'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Fennel' AND v2.name = 'Basil'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;

-- Kohlrabi + Tomato (kohlrabi said to inhibit tomato growth)
INSERT INTO companion_plants (vegetable_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM vegetables v1, vegetables v2 WHERE v1.name = 'Kohlrabi' AND v2.name = 'Tomato'
ON CONFLICT (vegetable_id, companion_id) DO NOTHING;
