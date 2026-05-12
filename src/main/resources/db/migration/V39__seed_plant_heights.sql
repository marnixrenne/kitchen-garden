-- V39: Populate height_min_cm / height_max_cm for all plants.
-- Sea vegetables (aonori, arame, dulse, hijiki, kombu, nori, sea lettuce, sea grape, wakame)
-- are aquatic and have no terrestrial height, so they remain NULL.

UPDATE pts_plants SET height_min_cm =  60, height_max_cm = 180 WHERE name = 'Tomato';
UPDATE pts_plants SET height_min_cm =  45, height_max_cm =  90 WHERE name = 'Bell Pepper';
UPDATE pts_plants SET height_min_cm =  45, height_max_cm =  90 WHERE name = 'Cayenne Pepper';
UPDATE pts_plants SET height_min_cm =  45, height_max_cm =  90 WHERE name = 'Chili Pepper';
UPDATE pts_plants SET height_min_cm =  45, height_max_cm =  90 WHERE name = 'Habanero';
UPDATE pts_plants SET height_min_cm =  45, height_max_cm =  75 WHERE name = 'Jalapeño';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm =  90 WHERE name = 'Eggplant';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm = 200 WHERE name = 'Cucumber';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm =  90 WHERE name = 'Zucchini';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Squash';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Butternut Squash';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Kabocha';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Spaghetti Squash';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Pumpkin';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Watermelon';
UPDATE pts_plants SET height_min_cm = 180, height_max_cm = 240 WHERE name = 'Sweetcorn';
UPDATE pts_plants SET height_min_cm =  90, height_max_cm = 120 WHERE name = 'Tomatillo';
UPDATE pts_plants SET height_min_cm = 120, height_max_cm = 180 WHERE name = 'Okra';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 300 WHERE name = 'Luffa';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 300 WHERE name = 'Calabash';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 300 WHERE name = 'Cucamelon';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 400 WHERE name = 'Bitter Melon';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 300 WHERE name = 'Chayote';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Winter Melon';

-- Root / tuber
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  30 WHERE name = 'Carrot';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  40 WHERE name = 'Beetroot';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  30 WHERE name = 'Radish';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  50 WHERE name = 'Daikon';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  40 WHERE name = 'Parsnip';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  30 WHERE name = 'Turnip';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  40 WHERE name = 'Rutabaga';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm =  90 WHERE name = 'Potato';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  30 WHERE name = 'Sweet Potato';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  40 WHERE name = 'Celeriac';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  40 WHERE name = 'Salsify';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  40 WHERE name = 'Scorzonera';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  50 WHERE name = 'Hamburg Parsley';
UPDATE pts_plants SET height_min_cm = 150, height_max_cm = 250 WHERE name = 'Jerusalem Artichoke';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm = 150 WHERE name = 'Horseradish';
UPDATE pts_plants SET height_min_cm =  90, height_max_cm = 150 WHERE name = 'Taro';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm = 100 WHERE name = 'Ginger';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm = 100 WHERE name = 'Turmeric';
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 200 WHERE name = 'Galangal';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  50 WHERE name = 'Jicama';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm =  90 WHERE name = 'Water Chestnut';
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 300 WHERE name = 'Cassava';
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 200 WHERE name = 'Yam';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  40 WHERE name = 'Tigernut';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Lotus Root';

-- Brassicas
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  45 WHERE name = 'Cabbage';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm =  90 WHERE name = 'Broccoli';
UPDATE pts_plants SET height_min_cm =  45, height_max_cm =  60 WHERE name = 'Cauliflower';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm =  90 WHERE name = 'Brussels Sprouts';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm =  90 WHERE name = 'Kale';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm =  90 WHERE name = 'Lacinato Kale';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm =  90 WHERE name = 'Collard Greens';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  45 WHERE name = 'Kohlrabi';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  45 WHERE name = 'Bok Choy';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  45 WHERE name = 'Napa Cabbage';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  45 WHERE name = 'Kai-lan';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  40 WHERE name = 'Mizuna';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Mustard Greens';
UPDATE pts_plants SET height_min_cm =  15, height_max_cm =  30 WHERE name = 'Tatsoi';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  45 WHERE name = 'Rapini';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Celtuce';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  40 WHERE name = 'Komatsuna';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm =  90 WHERE name = 'Sea Kale';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm =  90 WHERE name = 'Kalette';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  45 WHERE name = 'Rocket';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Land Cress';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  45 WHERE name = 'Cress';

-- Legumes
UPDATE pts_plants SET height_min_cm =  30, height_max_cm = 200 WHERE name = 'Bean';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm = 150 WHERE name = 'Broad Bean';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 300 WHERE name = 'Runner Bean';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm = 150 WHERE name = 'Pea';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm = 150 WHERE name = 'Snap Pea';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm = 150 WHERE name = 'Snow Pea';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 300 WHERE name = 'Asparagus Bean';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm =  90 WHERE name = 'Soybean';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Chickpea';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  40 WHERE name = 'Lentil';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Lima Bean';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Black-eyed Pea';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Adzuki Bean';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Mung Bean';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 400 WHERE name = 'Winged Bean';

-- Leafy greens
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  30 WHERE name = 'Lettuce';
UPDATE pts_plants SET height_min_cm =  15, height_max_cm =  30 WHERE name = 'Spinach';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Swiss Chard';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Sorrel';
UPDATE pts_plants SET height_min_cm =  10, height_max_cm =  20 WHERE name = 'Watercress';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  40 WHERE name = 'New Zealand Spinach';
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 150 WHERE name = 'Orache';
UPDATE pts_plants SET height_min_cm =  10, height_max_cm =  20 WHERE name = 'Lamb''s Lettuce';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Chicory';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  30 WHERE name = 'Radicchio';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  30 WHERE name = 'Endive';
UPDATE pts_plants SET height_min_cm =  10, height_max_cm =  30 WHERE name = 'Dandelion';
UPDATE pts_plants SET height_min_cm =  10, height_max_cm =  20 WHERE name = 'Common Purslane';
UPDATE pts_plants SET height_min_cm =  10, height_max_cm =  20 WHERE name = 'Miner''s Lettuce';
UPDATE pts_plants SET height_min_cm =   5, height_max_cm =  15 WHERE name = 'Chickweed';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  90 WHERE name = 'Lamb''s Quarters';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  50 WHERE name = 'Garland Chrysanthemum';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  70 WHERE name = 'Water Spinach';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 300 WHERE name = 'Malabar Spinach';
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 200 WHERE name = 'Jute Mallow';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Yao Choy';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm =  90 WHERE name = 'Fiddlehead';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Sea Beet';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  50 WHERE name = 'Wild Leek';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 500 WHERE name = 'Grape Leaves';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Mallow';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  30 WHERE name = 'Wheatgrass';

-- Alliums
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Onion';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Garlic';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm =  90 WHERE name = 'Leek';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  40 WHERE name = 'Shallot';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  40 WHERE name = 'Spring Onion';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  40 WHERE name = 'Chive';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Welsh Onion';
UPDATE pts_plants SET height_min_cm =  90, height_max_cm = 120 WHERE name = 'Elephant Garlic';

-- Herbs
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Basil';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  40 WHERE name = 'Parsley';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  50 WHERE name = 'Coriander';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm = 150 WHERE name = 'Dill';
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 200 WHERE name = 'Fennel';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  90 WHERE name = 'Mint';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm = 150 WHERE name = 'Rosemary';
UPDATE pts_plants SET height_min_cm =  15, height_max_cm =  30 WHERE name = 'Thyme';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Sage';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  50 WHERE name = 'Oregano';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Chervil';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm =  90 WHERE name = 'Tarragon';
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 200 WHERE name = 'Lovage';
UPDATE pts_plants SET height_min_cm =  90, height_max_cm = 150 WHERE name = 'Lemongrass';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm =  80 WHERE name = 'Caraway';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  40 WHERE name = 'Samphire';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Wasabi';

-- Other
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 200 WHERE name = 'Asparagus';
UPDATE pts_plants SET height_min_cm =  90, height_max_cm = 150 WHERE name = 'Artichoke';
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 200 WHERE name = 'Cardoon';
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 300 WHERE name = 'Sunflower';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Celery';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm = 100 WHERE name = 'Caper';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm = 120 WHERE name = 'Burdock';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 500 WHERE name = 'Bamboo Shoot';
UPDATE pts_plants SET height_min_cm = 300, height_max_cm = 1000 WHERE name = 'Moringa';
UPDATE pts_plants SET height_min_cm = 200, height_max_cm = 600 WHERE name = 'Elderflower';
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 200 WHERE name = 'Nopal';
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 200 WHERE name = 'Loroco';
UPDATE pts_plants SET height_min_cm = 100, height_max_cm = 300 WHERE name = 'Banana Flower';

-- Edible flowers
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  40 WHERE name = 'Nasturtium';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  60 WHERE name = 'Calendula';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm = 100 WHERE name = 'Borage';
UPDATE pts_plants SET height_min_cm =  20, height_max_cm =  50 WHERE name = 'Chamomile';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  90 WHERE name = 'Cornflower';
UPDATE pts_plants SET height_min_cm =  30, height_max_cm =  90 WHERE name = 'Lavender';
UPDATE pts_plants SET height_min_cm =  60, height_max_cm = 200 WHERE name = 'Rose';
UPDATE pts_plants SET height_min_cm =  10, height_max_cm =  20 WHERE name = 'Viola';
UPDATE pts_plants SET height_min_cm =  45, height_max_cm =  90 WHERE name = 'Daylily';
