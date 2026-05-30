-- ============================================================
-- ANNUAL
-- ============================================================
UPDATE pts_plants SET lifespan = 'annual' WHERE name IN (
    'Adzuki Bean', 'Asparagus Bean', 'Basil', 'Bean', 'Bell Pepper',
    'Bitter Melon', 'Black-eyed Pea', 'Bok Choy', 'Borage', 'Broad Bean',
    'Broccoli', 'Butternut Squash', 'Calabash', 'Calendula', 'Cauliflower',
    'Cayenne Pepper', 'Celtuce', 'Chamomile', 'Chervil', 'Chickpea',
    'Chili Pepper', 'Common Purslane', 'Coriander', 'Cornflower', 'Cress',
    'Cucamelon', 'Cucumber', 'Dill', 'Eggplant', 'Garland Chrysanthemum',
    'Garlic', 'Habanero', 'Jalapeño', 'Jicama', 'Jute Mallow',
    'Kabocha', 'Kai-lan', 'Komatsuna', 'Lentil', 'Lettuce',
    'Lima Bean', 'Luffa', 'Malabar Spinach', 'Mizuna', 'Mung Bean',
    'Mustard Greens', 'Napa Cabbage', 'Nasturtium', 'New Zealand Spinach', 'Nori',
    'Okra', 'Orache', 'Pea', 'Potato', 'Pumpkin',
    'Radish', 'Rapini', 'Rocket', 'Runner Bean', 'Snap Pea',
    'Snow Pea', 'Soybean', 'Spaghetti Squash', 'Spinach', 'Spring Onion',
    'Squash', 'Sunflower', 'Sweet Potato', 'Sweetcorn', 'Tatsoi',
    'Tomatillo', 'Tomato', 'Viola', 'Water Spinach', 'Watermelon',
    'Wheatgrass', 'Winged Bean', 'Winter Melon', 'Yam', 'Yao Choy',
    'Zucchini'
);
UPDATE pts_plants SET lifespan = 'annual' WHERE name = 'Lamb''s Quarters';
UPDATE pts_plants SET lifespan = 'annual' WHERE name = 'Miner''s Lettuce';

-- ============================================================
-- BIENNIAL
-- ============================================================
UPDATE pts_plants SET lifespan = 'biennial' WHERE name IN (
    'Beetroot', 'Brussels Sprouts', 'Burdock', 'Cabbage', 'Caraway',
    'Carrot', 'Celeriac', 'Celery', 'Collard Greens', 'Daikon',
    'Elephant Garlic', 'Endive', 'Hamburg Parsley', 'Kale', 'Kalette',
    'Kohlrabi', 'Lacinato Kale', 'Land Cress', 'Leek', 'Onion',
    'Parsley', 'Parsnip', 'Radicchio', 'Rutabaga', 'Salsify',
    'Sea Beet', 'Shallot', 'Swiss Chard', 'Turnip'
);
UPDATE pts_plants SET lifespan = 'biennial' WHERE name = 'Lamb''s Lettuce';

-- ============================================================
-- PERENNIAL
-- ============================================================
UPDATE pts_plants SET lifespan = 'perennial' WHERE name IN (
    'Aonori', 'Apple', 'Arame', 'Artichoke', 'Asparagus',
    'Bamboo Shoot', 'Banana Flower', 'Blackberry', 'Blackcurrant', 'Blueberry',
    'Cardoon', 'Caper', 'Cassava', 'Chayote', 'Cherry',
    'Chicory', 'Chive', 'Dandelion', 'Daylily', 'Dulse',
    'Elderflower', 'Fennel', 'Fiddlehead', 'Galangal', 'Ginger',
    'Gooseberry', 'Grape', 'Grape Leaves', 'Hijiki', 'Hops',
    'Horseradish', 'Jerusalem Artichoke', 'Kombu', 'Lavender', 'Lemongrass',
    'Loroco', 'Lotus Root', 'Lovage', 'Mallow', 'Mint',
    'Moringa', 'Nopal', 'Oregano', 'Pear', 'Plum',
    'Raspberry', 'Redcurrant', 'Rhubarb', 'Rose', 'Rosemary',
    'Sage', 'Samphire', 'Scorzonera', 'Sea Grape', 'Sea Kale',
    'Sea Lettuce', 'Sorrel', 'Strawberry', 'Taro', 'Tarragon',
    'Thyme', 'Tigernut', 'Turmeric', 'Wakame', 'Wasabi',
    'Water Chestnut', 'Watercress', 'Welsh Onion', 'Wild Leek'
);
