ALTER TABLE vegetables ADD COLUMN sun_requirement VARCHAR(15);

UPDATE vegetables SET sun_requirement = 'full_sun' WHERE name IN (
    'Tomato', 'Cucumber', 'Bell Pepper', 'Zucchini', 'Pumpkin', 'Sweetcorn',
    'Cabbage', 'Broccoli', 'Cauliflower', 'Carrot', 'Beetroot', 'Onion', 'Leek',
    'Bean', 'Basil', 'Dill', 'Fennel', 'Radicchio', 'Chicory', 'Collard Greens',
    'Artichoke', 'Brussels Sprouts', 'Kohlrabi', 'Turnip', 'Napa Cabbage',
    'Eggplant', 'Chili Pepper', 'Squash', 'Potato', 'Sweet Potato', 'Parsnip',
    'Jerusalem Artichoke', 'Celeriac', 'Daikon', 'Garlic', 'Shallot', 'Spring Onion',
    'Asparagus', 'Broad Bean', 'Runner Bean', 'Lentil', 'Soybean',
    'Thyme', 'Rosemary', 'Oregano', 'Sage', 'Lemongrass', 'Borage', 'Caraway',
    'Common Purslane', 'Dandelion', 'Garland Chrysanthemum', 'Grape Leaves',
    'Jute Mallow', 'Kalette', 'Lamb''s Quarters', 'Mallow', 'Moringa', 'Orache',
    'Samphire', 'Sea Beet', 'Sea Kale',
    'Bitter Melon', 'Butternut Squash', 'Calabash', 'Cucamelon', 'Kabocha', 'Luffa',
    'Spaghetti Squash', 'Tomatillo', 'Watermelon', 'Winter Melon',
    'Jalapeño', 'Habanero', 'Cayenne Pepper',
    'Banana Flower', 'Caper', 'Daylily', 'Loroco',
    'Asparagus Bean', 'Adzuki Bean', 'Black-eyed Pea', 'Chickpea', 'Lima Bean',
    'Mung Bean', 'Okra', 'Winged Bean',
    'Burdock', 'Cassava', 'Horseradish', 'Jicama', 'Rutabaga', 'Salsify',
    'Scorzonera', 'Tigernut', 'Water Chestnut', 'Yam',
    'Cardoon', 'Elephant Garlic', 'Lotus Root', 'Nopal', 'Welsh Onion',
    'Aonori', 'Arame', 'Dulse', 'Hijiki', 'Kombu', 'Nori',
    'Sea Lettuce', 'Sea Grape', 'Wakame'
);

UPDATE vegetables SET sun_requirement = 'partial_shade' WHERE name IN (
    'Lettuce', 'Spinach', 'Rocket', 'Kale', 'Radish', 'Pea', 'Parsley',
    'Bok Choy', 'Swiss Chard', 'Watercress', 'Endive', 'Lamb''s Lettuce', 'Sorrel',
    'Mizuna', 'Mustard Greens', 'Rapini', 'Celery', 'Snap Pea', 'Chive',
    'Coriander', 'Mint', 'Chervil', 'Celtuce', 'Cress', 'Kai-lan', 'Komatsuna',
    'Land Cress', 'Malabar Spinach', 'New Zealand Spinach', 'Tatsoi',
    'Water Spinach', 'Wheatgrass', 'Yao Choy', 'Chayote', 'Snow Pea',
    'Bamboo Shoot', 'Galangal', 'Ginger', 'Hamburg Parsley', 'Taro', 'Turmeric',
    'Wild Leek'
);

UPDATE vegetables SET sun_requirement = 'shade' WHERE name IN (
    'Chickweed', 'Miner''s Lettuce', 'Wasabi'
);
