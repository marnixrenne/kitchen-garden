-- Fruiting vegetables
INSERT INTO vegetables (id, name, category, emoji) VALUES
  (1,  'Tomato',      'Fruiting', '🍅'),
  (2,  'Cucumber',    'Fruiting', '🥒'),
  (3,  'Bell Pepper', 'Fruiting', '🫑'),
  (4,  'Zucchini',    'Fruiting', '🥬'),
  (5,  'Pumpkin',     'Fruiting', '🎃'),
  (6,  'Sweetcorn',   'Fruiting', '🌽');

-- Leafy vegetables
INSERT INTO vegetables (id, name, category, emoji) VALUES
  (7,  'Lettuce',  'Leafy', '🥗'),
  (8,  'Spinach',  'Leafy', '🌿'),
  (9,  'Rocket',   'Leafy', '🌱');

-- Brassicas
INSERT INTO vegetables (id, name, category, emoji) VALUES
  (10, 'Kale',        'Brassica', '🥦'),
  (11, 'Cabbage',     'Brassica', '🥦'),
  (12, 'Broccoli',    'Brassica', '🥦'),
  (13, 'Cauliflower', 'Brassica', '🥦');

-- Root vegetables
INSERT INTO vegetables (id, name, category, emoji) VALUES
  (14, 'Carrot',   'Root', '🥕'),
  (15, 'Radish',   'Root', '🌰'),
  (16, 'Beetroot', 'Root', '🍠'),
  (17, 'Onion',    'Root', '🧅'),
  (18, 'Leek',     'Root', '🥬');

-- Legumes
INSERT INTO vegetables (id, name, category, emoji) VALUES
  (19, 'Pea',  'Legume', '🫛'),
  (20, 'Bean', 'Legume', '🫘');

-- Herbs
INSERT INTO vegetables (id, name, category, emoji) VALUES
  (21, 'Parsley', 'Herb', '🌿'),
  (22, 'Basil',   'Herb', '🌿'),
  (23, 'Dill',    'Herb', '🌿'),
  (24, 'Fennel',  'Herb', '🌿');


-- Seeding months (temperate European climate, ~Netherlands)
-- Tomato: Feb–Apr (start indoors)
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (1,2),(1,3),(1,4);
-- Cucumber: Mar–May (Mar/Apr indoors, May direct)
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (2,3),(2,4),(2,5);
-- Bell Pepper: Feb–Mar (start indoors)
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (3,2),(3,3);
-- Zucchini: Apr–May
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (4,4),(4,5);
-- Pumpkin: Apr–May
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (5,4),(5,5);
-- Sweetcorn: May
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (6,5);
-- Lettuce: Mar–Sep
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (7,3),(7,4),(7,5),(7,6),(7,7),(7,8),(7,9);
-- Spinach: Feb–Apr, Aug–Sep
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (8,2),(8,3),(8,4),(8,8),(8,9);
-- Rocket: Apr–Sep
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (9,4),(9,5),(9,6),(9,7),(9,8),(9,9);
-- Kale: Apr–Jul
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (10,4),(10,5),(10,6),(10,7);
-- Cabbage: Mar–May
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (11,3),(11,4),(11,5);
-- Broccoli: Mar–Jul
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (12,3),(12,4),(12,5),(12,6),(12,7);
-- Cauliflower: Apr–Jun
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (13,4),(13,5),(13,6);
-- Carrot: Mar–Jul
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (14,3),(14,4),(14,5),(14,6),(14,7);
-- Radish: Mar–Sep
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (15,3),(15,4),(15,5),(15,6),(15,7),(15,8),(15,9);
-- Beetroot: Apr–Jun
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (16,4),(16,5),(16,6);
-- Onion: Mar–Apr
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (17,3),(17,4);
-- Leek: Feb–Apr
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (18,2),(18,3),(18,4);
-- Pea: Mar–May
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (19,3),(19,4),(19,5);
-- Bean: May–Jul
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (20,5),(20,6),(20,7);
-- Parsley: Mar–Aug
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (21,3),(21,4),(21,5),(21,6),(21,7),(21,8);
-- Basil: Apr–May (start indoors)
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (22,4),(22,5);
-- Dill: Apr–Aug
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (23,4),(23,5),(23,6),(23,7),(23,8);
-- Fennel: Apr–Jun
INSERT INTO seeding_months (vegetable_id, month_num) VALUES (24,4),(24,5),(24,6);