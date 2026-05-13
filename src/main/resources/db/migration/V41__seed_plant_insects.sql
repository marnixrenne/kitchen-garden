-- Lavender
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Lavender';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Lavender';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly', 'pollinator' FROM pts_plants WHERE name = 'Lavender';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Lavender';

-- Borage
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Borage';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Borage';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',  'beneficial' FROM pts_plants WHERE name = 'Borage';

-- Chamomile
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Chamomile';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Chamomile';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',  'beneficial' FROM pts_plants WHERE name = 'Chamomile';

-- Calendula (trap crop — attracts pollinators and aphids, which draw ladybirds)
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Calendula';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Calendula';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Calendula';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',  'beneficial' FROM pts_plants WHERE name = 'Calendula';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Calendula';

-- Nasturtium (trap crop — draws aphids away from other plants, ladybirds follow)
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Nasturtium';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Nasturtium';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',  'beneficial' FROM pts_plants WHERE name = 'Nasturtium';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Nasturtium';

-- Sunflower
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Sunflower';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Sunflower';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly', 'pollinator' FROM pts_plants WHERE name = 'Sunflower';

-- Cornflower
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Cornflower';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Cornflower';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly', 'pollinator' FROM pts_plants WHERE name = 'Cornflower';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Cornflower';

-- Elderflower
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Elderflower';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Elderflower';

-- Rose
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Rose';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Rose';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Rose';

-- Viola
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Viola';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly', 'pollinator' FROM pts_plants WHERE name = 'Viola';

-- Thyme
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Thyme';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Thyme';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Thyme';

-- Mint
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Mint';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Mint';

-- Oregano
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Oregano';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Oregano';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Oregano';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly', 'pollinator' FROM pts_plants WHERE name = 'Oregano';

-- Rosemary
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Rosemary';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Rosemary';

-- Sage
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Sage';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Sage';

-- Chive
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Chive';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Chive';

-- Basil
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Basil';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Basil';

-- Dill (excellent for beneficial insects)
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',      'pollinator' FROM pts_plants WHERE name = 'Dill';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',      'beneficial' FROM pts_plants WHERE name = 'Dill';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'parasitic_wasp','beneficial' FROM pts_plants WHERE name = 'Dill';

-- Fennel
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',      'pollinator' FROM pts_plants WHERE name = 'Fennel';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly',     'pollinator' FROM pts_plants WHERE name = 'Fennel';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',      'beneficial' FROM pts_plants WHERE name = 'Fennel';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'parasitic_wasp','beneficial' FROM pts_plants WHERE name = 'Fennel';

-- Coriander
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',      'pollinator' FROM pts_plants WHERE name = 'Coriander';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',      'pollinator' FROM pts_plants WHERE name = 'Coriander';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'parasitic_wasp','beneficial' FROM pts_plants WHERE name = 'Coriander';

-- Parsley
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',      'pollinator' FROM pts_plants WHERE name = 'Parsley';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'parasitic_wasp','beneficial' FROM pts_plants WHERE name = 'Parsley';

-- Chervil
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',      'pollinator' FROM pts_plants WHERE name = 'Chervil';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'parasitic_wasp','beneficial' FROM pts_plants WHERE name = 'Chervil';

-- Caraway
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',      'pollinator' FROM pts_plants WHERE name = 'Caraway';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',      'pollinator' FROM pts_plants WHERE name = 'Caraway';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'parasitic_wasp','beneficial' FROM pts_plants WHERE name = 'Caraway';

-- Lovage
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Lovage';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',  'beneficial' FROM pts_plants WHERE name = 'Lovage';

-- Dandelion (superb all-round insect plant)
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Dandelion';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Dandelion';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly', 'pollinator' FROM pts_plants WHERE name = 'Dandelion';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Dandelion';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'lacewing',  'beneficial' FROM pts_plants WHERE name = 'Dandelion';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'ladybird',  'beneficial' FROM pts_plants WHERE name = 'Dandelion';

-- Mallow
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Mallow';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Mallow';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly', 'pollinator' FROM pts_plants WHERE name = 'Mallow';

-- Artichoke
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Artichoke';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Artichoke';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'butterfly', 'pollinator' FROM pts_plants WHERE name = 'Artichoke';

-- Tomato
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Tomato';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Tomato';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'whitefly',  'pest'       FROM pts_plants WHERE name = 'Tomato';

-- Cucumber
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Cucumber';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Cucumber';

-- Squash
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Squash';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Squash';

-- Pumpkin
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Pumpkin';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Pumpkin';

-- Zucchini
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Zucchini';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Zucchini';

-- Butternut Squash
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Butternut Squash';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Butternut Squash';

-- Eggplant
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Eggplant';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'whitefly',  'pest'       FROM pts_plants WHERE name = 'Eggplant';

-- Broad Bean
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Broad Bean';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'honeybee',  'pollinator' FROM pts_plants WHERE name = 'Broad Bean';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'blackfly',  'pest'       FROM pts_plants WHERE name = 'Broad Bean';

-- Pea
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Pea';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'pea_moth',  'pest'       FROM pts_plants WHERE name = 'Pea';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Pea';

-- Bean
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Bean';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Bean';

-- Runner Bean
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Runner Bean';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'hoverfly',  'pollinator' FROM pts_plants WHERE name = 'Runner Bean';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'blackfly',  'pest'       FROM pts_plants WHERE name = 'Runner Bean';

-- Snap Pea
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'bumblebee', 'pollinator' FROM pts_plants WHERE name = 'Snap Pea';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',     'pest'       FROM pts_plants WHERE name = 'Snap Pea';

-- Cabbage
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'cabbage_white', 'pest' FROM pts_plants WHERE name = 'Cabbage';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'flea_beetle',   'pest' FROM pts_plants WHERE name = 'Cabbage';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',         'pest' FROM pts_plants WHERE name = 'Cabbage';

-- Broccoli
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'cabbage_white', 'pest' FROM pts_plants WHERE name = 'Broccoli';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'flea_beetle',   'pest' FROM pts_plants WHERE name = 'Broccoli';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',         'pest' FROM pts_plants WHERE name = 'Broccoli';

-- Kale
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'cabbage_white', 'pest' FROM pts_plants WHERE name = 'Kale';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'flea_beetle',   'pest' FROM pts_plants WHERE name = 'Kale';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',         'pest' FROM pts_plants WHERE name = 'Kale';

-- Lacinato Kale
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'cabbage_white', 'pest' FROM pts_plants WHERE name = 'Lacinato Kale';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'flea_beetle',   'pest' FROM pts_plants WHERE name = 'Lacinato Kale';

-- Brussels Sprouts
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'cabbage_white', 'pest' FROM pts_plants WHERE name = 'Brussels Sprouts';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',         'pest' FROM pts_plants WHERE name = 'Brussels Sprouts';

-- Cauliflower
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'cabbage_white', 'pest' FROM pts_plants WHERE name = 'Cauliflower';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'flea_beetle',   'pest' FROM pts_plants WHERE name = 'Cauliflower';

-- Kohlrabi
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'flea_beetle', 'pest' FROM pts_plants WHERE name = 'Kohlrabi';

-- Turnip
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'flea_beetle',   'pest' FROM pts_plants WHERE name = 'Turnip';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'cabbage_white', 'pest' FROM pts_plants WHERE name = 'Turnip';

-- Rapini
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'flea_beetle', 'pest' FROM pts_plants WHERE name = 'Rapini';

-- Mizuna
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'flea_beetle', 'pest' FROM pts_plants WHERE name = 'Mizuna';

-- Bok Choy
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'flea_beetle',   'pest' FROM pts_plants WHERE name = 'Bok Choy';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'cabbage_white', 'pest' FROM pts_plants WHERE name = 'Bok Choy';

-- Napa Cabbage
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'flea_beetle',   'pest' FROM pts_plants WHERE name = 'Napa Cabbage';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'cabbage_white', 'pest' FROM pts_plants WHERE name = 'Napa Cabbage';

-- Collard Greens
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'cabbage_white', 'pest' FROM pts_plants WHERE name = 'Collard Greens';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',         'pest' FROM pts_plants WHERE name = 'Collard Greens';

-- Mustard Greens
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'flea_beetle', 'pest' FROM pts_plants WHERE name = 'Mustard Greens';
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid',       'pest' FROM pts_plants WHERE name = 'Mustard Greens';

-- Rocket
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'flea_beetle', 'pest' FROM pts_plants WHERE name = 'Rocket';

-- Radish
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'flea_beetle', 'pest' FROM pts_plants WHERE name = 'Radish';

-- Lettuce
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid', 'pest' FROM pts_plants WHERE name = 'Lettuce';

-- Spinach
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid', 'pest' FROM pts_plants WHERE name = 'Spinach';

-- Carrot
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'carrot_fly', 'pest' FROM pts_plants WHERE name = 'Carrot';

-- Leek
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'onion_fly', 'pest' FROM pts_plants WHERE name = 'Leek';

-- Onion
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'onion_fly', 'pest' FROM pts_plants WHERE name = 'Onion';

-- Sweetcorn
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'corn_earworm', 'pest' FROM pts_plants WHERE name = 'Sweetcorn';

-- Potato
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid', 'pest' FROM pts_plants WHERE name = 'Potato';

-- Beetroot
INSERT INTO pts_plant_insects (plant_id, insect_name, insect_type) SELECT id, 'aphid', 'pest' FROM pts_plants WHERE name = 'Beetroot';
