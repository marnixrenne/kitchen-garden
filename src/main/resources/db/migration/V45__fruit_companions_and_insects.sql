-- V45: Companion plants and insect associations for the Fruit category

-- ============================================================
-- COMPANION PLANTS
-- ============================================================

-- Strawberry
-- Good: Borage deters aphids and attracts pollinators; alliums repel pests; lettuce and spinach work as ground cover
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Strawberry' AND v2.name = 'Borage'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Strawberry' AND v2.name = 'Chive'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Strawberry' AND v2.name = 'Garlic'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Strawberry' AND v2.name = 'Lettuce'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Strawberry' AND v2.name = 'Spinach'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
-- Bad: Fennel is allelopathic; Cabbage competes strongly for resources
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Strawberry' AND v2.name = 'Fennel'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Strawberry' AND v2.name = 'Cabbage'
ON CONFLICT (plant_id, companion_id) DO NOTHING;

-- Raspberry
-- Good: alliums and nasturtium repel and trap aphids
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Raspberry' AND v2.name = 'Garlic'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Raspberry' AND v2.name = 'Chive'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Raspberry' AND v2.name = 'Nasturtium'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
-- Bad: Potato shares Verticillium wilt; Tomato shares fungal diseases
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Raspberry' AND v2.name = 'Potato'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Raspberry' AND v2.name = 'Tomato'
ON CONFLICT (plant_id, companion_id) DO NOTHING;

-- Blackberry
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Blackberry' AND v2.name = 'Garlic'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Blackberry' AND v2.name = 'Chive'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Blackberry' AND v2.name = 'Nasturtium'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Blackberry' AND v2.name = 'Potato'
ON CONFLICT (plant_id, companion_id) DO NOTHING;

-- Blueberry
-- Good: Basil repels insects; Chive deters aphids
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Blueberry' AND v2.name = 'Basil'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Blueberry' AND v2.name = 'Chive'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
-- Bad: Tomato prefers very different pH (6.0–6.8 vs blueberry's 4.5–5.5) and competes for soil nutrients
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Blueberry' AND v2.name = 'Tomato'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Blueberry' AND v2.name = 'Fennel'
ON CONFLICT (plant_id, companion_id) DO NOTHING;

-- Gooseberry
-- Good: Chive repels gooseberry sawfly and aphids; Garlic repels pests
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Gooseberry' AND v2.name = 'Chive'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Gooseberry' AND v2.name = 'Garlic'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Gooseberry' AND v2.name = 'Nasturtium'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Gooseberry' AND v2.name = 'Fennel'
ON CONFLICT (plant_id, companion_id) DO NOTHING;

-- Redcurrant
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Redcurrant' AND v2.name = 'Chive'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Redcurrant' AND v2.name = 'Garlic'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Redcurrant' AND v2.name = 'Nasturtium'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Redcurrant' AND v2.name = 'Fennel'
ON CONFLICT (plant_id, companion_id) DO NOTHING;

-- Blackcurrant
-- Nasturtium traps blackfly (black bean aphid) which also attacks blackcurrants
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Blackcurrant' AND v2.name = 'Chive'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Blackcurrant' AND v2.name = 'Garlic'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Blackcurrant' AND v2.name = 'Nasturtium'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Blackcurrant' AND v2.name = 'Fennel'
ON CONFLICT (plant_id, companion_id) DO NOTHING;

-- Apple
-- Chive planted around apple trees is well-documented to reduce apple scab
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Apple' AND v2.name = 'Chive'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Apple' AND v2.name = 'Garlic'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Apple' AND v2.name = 'Nasturtium'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
-- Bad: Potato shares fungal diseases; root competition is severe under tree canopy
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Apple' AND v2.name = 'Potato'
ON CONFLICT (plant_id, companion_id) DO NOTHING;

-- Pear
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Pear' AND v2.name = 'Chive'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Pear' AND v2.name = 'Garlic'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Pear' AND v2.name = 'Nasturtium'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Pear' AND v2.name = 'Potato'
ON CONFLICT (plant_id, companion_id) DO NOTHING;

-- Cherry
-- Nasturtium traps black cherry aphid; garlic and chive repel pests generally
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Cherry' AND v2.name = 'Garlic'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Cherry' AND v2.name = 'Chive'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Cherry' AND v2.name = 'Nasturtium'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Cherry' AND v2.name = 'Potato'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Cherry' AND v2.name = 'Tomato'
ON CONFLICT (plant_id, companion_id) DO NOTHING;

-- Plum
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Plum' AND v2.name = 'Garlic'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Plum' AND v2.name = 'Chive'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Plum' AND v2.name = 'Nasturtium'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Plum' AND v2.name = 'Potato'
ON CONFLICT (plant_id, companion_id) DO NOTHING;

-- Rhubarb
-- Good: alliums repel aphids; rhubarb leaves (toxic to pests) make it a natural deterrent itself
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Rhubarb' AND v2.name = 'Garlic'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Rhubarb' AND v2.name = 'Onion'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'good' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Rhubarb' AND v2.name = 'Chive'
ON CONFLICT (plant_id, companion_id) DO NOTHING;
-- Bad: Dock (rumex) is a close relative that competes aggressively and shares diseases — Fennel allelopathic
INSERT INTO pts_companion_plants (plant_id, companion_id, relationship)
SELECT v1.id, v2.id, 'bad' FROM pts_plants v1, pts_plants v2 WHERE v1.name = 'Rhubarb' AND v2.name = 'Fennel'
ON CONFLICT (plant_id, companion_id) DO NOTHING;

-- ============================================================
-- INSECTS
-- ============================================================

-- Strawberry
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Strawberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Strawberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly', 'pollinator' FROM pts_plants WHERE name = 'Strawberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Strawberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',  'beneficial' FROM pts_plants WHERE name = 'Strawberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Strawberry';

-- Raspberry
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',      'pollinator' FROM pts_plants WHERE name = 'Raspberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee',     'pollinator' FROM pts_plants WHERE name = 'Raspberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly',     'pollinator' FROM pts_plants WHERE name = 'Raspberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',      'pollinator' FROM pts_plants WHERE name = 'Raspberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',      'beneficial' FROM pts_plants WHERE name = 'Raspberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',      'beneficial' FROM pts_plants WHERE name = 'Raspberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',         'pest'       FROM pts_plants WHERE name = 'Raspberry';

-- Blackberry
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Blackberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Blackberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly', 'pollinator' FROM pts_plants WHERE name = 'Blackberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Blackberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',  'beneficial' FROM pts_plants WHERE name = 'Blackberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Blackberry';

-- Blueberry (bumblebees are the primary pollinator via buzz pollination)
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Blueberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Blueberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly', 'pollinator' FROM pts_plants WHERE name = 'Blueberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',  'beneficial' FROM pts_plants WHERE name = 'Blueberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',  'beneficial' FROM pts_plants WHERE name = 'Blueberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Blueberry';

-- Gooseberry
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',      'pollinator' FROM pts_plants WHERE name = 'Gooseberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee',     'pollinator' FROM pts_plants WHERE name = 'Gooseberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',      'pollinator' FROM pts_plants WHERE name = 'Gooseberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',      'beneficial' FROM pts_plants WHERE name = 'Gooseberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'parasitic_wasp','beneficial' FROM pts_plants WHERE name = 'Gooseberry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',         'pest'       FROM pts_plants WHERE name = 'Gooseberry';

-- Redcurrant
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Redcurrant';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Redcurrant';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Redcurrant';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',  'beneficial' FROM pts_plants WHERE name = 'Redcurrant';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',  'beneficial' FROM pts_plants WHERE name = 'Redcurrant';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Redcurrant';

-- Blackcurrant (blackfly is a common and significant pest)
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Blackcurrant';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Blackcurrant';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Blackcurrant';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',  'beneficial' FROM pts_plants WHERE name = 'Blackcurrant';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',  'beneficial' FROM pts_plants WHERE name = 'Blackcurrant';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Blackcurrant';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'blackfly',  'pest'       FROM pts_plants WHERE name = 'Blackcurrant';

-- Apple (cross-pollination depends heavily on bees; parasitic wasps attack apple sawfly)
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',      'pollinator' FROM pts_plants WHERE name = 'Apple';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee',     'pollinator' FROM pts_plants WHERE name = 'Apple';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly',     'pollinator' FROM pts_plants WHERE name = 'Apple';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',      'pollinator' FROM pts_plants WHERE name = 'Apple';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',      'beneficial' FROM pts_plants WHERE name = 'Apple';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',      'beneficial' FROM pts_plants WHERE name = 'Apple';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'parasitic_wasp','beneficial' FROM pts_plants WHERE name = 'Apple';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',         'pest'       FROM pts_plants WHERE name = 'Apple';

-- Pear
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Pear';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Pear';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Pear';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',  'beneficial' FROM pts_plants WHERE name = 'Pear';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',  'beneficial' FROM pts_plants WHERE name = 'Pear';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Pear';

-- Cherry (black cherry aphid is a notorious pest)
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Cherry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Cherry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly', 'pollinator' FROM pts_plants WHERE name = 'Cherry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Cherry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',  'beneficial' FROM pts_plants WHERE name = 'Cherry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',  'beneficial' FROM pts_plants WHERE name = 'Cherry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Cherry';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'blackfly',  'pest'       FROM pts_plants WHERE name = 'Cherry';

-- Plum (mealy plum aphid and black plum aphid are common pests)
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Plum';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Plum';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly', 'pollinator' FROM pts_plants WHERE name = 'Plum';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Plum';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',  'beneficial' FROM pts_plants WHERE name = 'Plum';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',  'beneficial' FROM pts_plants WHERE name = 'Plum';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Plum';

-- Rhubarb (the flowers are excellent for early-season pollinators; aphids attack young stalks)
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Rhubarb';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Rhubarb';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Rhubarb';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly', 'pollinator' FROM pts_plants WHERE name = 'Rhubarb';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',  'beneficial' FROM pts_plants WHERE name = 'Rhubarb';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',  'beneficial' FROM pts_plants WHERE name = 'Rhubarb';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Rhubarb';
