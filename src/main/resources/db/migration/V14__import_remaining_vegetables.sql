-- V14: Import remaining vegetables (87 total)
-- New categories introduced: Flower, Sea

-- ============================================================
-- INSERT VEGETABLES
-- ============================================================

INSERT INTO vegetables (id, name, category, emoji) VALUES
    -- Leafy
    (gen_random_uuid(), 'Borage', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Caraway', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Celtuce', 'Leafy', '🥬'),
    (gen_random_uuid(), 'Common Purslane', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Cress', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Dandelion', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Fiddlehead', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Garland Chrysanthemum', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Grape Leaves', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Jute Mallow', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Kai-lan', 'Leafy', '🥬'),
    (gen_random_uuid(), 'Kalette', 'Leafy', '🥬'),
    (gen_random_uuid(), 'Komatsuna', 'Leafy', '🥬'),
    (gen_random_uuid(), 'Lamb''s Quarters', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Land Cress', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Malabar Spinach', 'Leafy', '🥬'),
    (gen_random_uuid(), 'Mallow', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Miner''s Lettuce', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Moringa', 'Leafy', '🌿'),
    (gen_random_uuid(), 'New Zealand Spinach', 'Leafy', '🥬'),
    (gen_random_uuid(), 'Orache', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Samphire', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Sea Beet', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Sea Kale', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Tatsoi', 'Leafy', '🥬'),
    (gen_random_uuid(), 'Water Spinach', 'Leafy', '🥬'),
    (gen_random_uuid(), 'Wheatgrass', 'Leafy', '🌿'),
    (gen_random_uuid(), 'Yao Choy', 'Leafy', '🥬'),

    -- Fruiting
    (gen_random_uuid(), 'Bitter Melon', 'Fruiting', '🌱'),
    (gen_random_uuid(), 'Butternut Squash', 'Fruiting', '🌱'),
    (gen_random_uuid(), 'Calabash', 'Fruiting', '🌱'),
    (gen_random_uuid(), 'Chayote', 'Fruiting', '🌱'),
    (gen_random_uuid(), 'Cucamelon', 'Fruiting', '🌱'),
    (gen_random_uuid(), 'Kabocha', 'Fruiting', '🌱'),
    (gen_random_uuid(), 'Luffa', 'Fruiting', '🌱'),
    (gen_random_uuid(), 'Spaghetti Squash', 'Fruiting', '🌱'),
    (gen_random_uuid(), 'Tomatillo', 'Fruiting', '🍅'),
    (gen_random_uuid(), 'Watermelon', 'Fruiting', '🍉'),
    (gen_random_uuid(), 'Winter Melon', 'Fruiting', '🌱'),
    (gen_random_uuid(), 'Jalapeño', 'Fruiting', '🌶️'),
    (gen_random_uuid(), 'Habanero', 'Fruiting', '🌶️'),
    (gen_random_uuid(), 'Cayenne Pepper', 'Fruiting', '🌶️'),

    -- Flower (new category)
    (gen_random_uuid(), 'Banana Flower', 'Flower', '🌸'),
    (gen_random_uuid(), 'Caper', 'Flower', '🌸'),
    (gen_random_uuid(), 'Daylily', 'Flower', '🌸'),
    (gen_random_uuid(), 'Loroco', 'Flower', '🌸'),

    -- Legume
    (gen_random_uuid(), 'Asparagus Bean', 'Legume', '🫘'),
    (gen_random_uuid(), 'Adzuki Bean', 'Legume', '🫘'),
    (gen_random_uuid(), 'Black-eyed Pea', 'Legume', '🫘'),
    (gen_random_uuid(), 'Chickpea', 'Legume', '🫘'),
    (gen_random_uuid(), 'Lima Bean', 'Legume', '🫘'),
    (gen_random_uuid(), 'Mung Bean', 'Legume', '🫘'),
    (gen_random_uuid(), 'Okra', 'Legume', '🌱'),
    (gen_random_uuid(), 'Snow Pea', 'Legume', '🫛'),
    (gen_random_uuid(), 'Winged Bean', 'Legume', '🫘'),

    -- Root
    (gen_random_uuid(), 'Bamboo Shoot', 'Root', '🌱'),
    (gen_random_uuid(), 'Burdock', 'Root', '🌱'),
    (gen_random_uuid(), 'Cassava', 'Root', '🌱'),
    (gen_random_uuid(), 'Galangal', 'Root', '🌱'),
    (gen_random_uuid(), 'Ginger', 'Root', '🫚'),
    (gen_random_uuid(), 'Hamburg Parsley', 'Root', '🌱'),
    (gen_random_uuid(), 'Horseradish', 'Root', '🌱'),
    (gen_random_uuid(), 'Jicama', 'Root', '🌱'),
    (gen_random_uuid(), 'Rutabaga', 'Root', '🌱'),
    (gen_random_uuid(), 'Salsify', 'Root', '🌱'),
    (gen_random_uuid(), 'Scorzonera', 'Root', '🌱'),
    (gen_random_uuid(), 'Taro', 'Root', '🌱'),
    (gen_random_uuid(), 'Tigernut', 'Root', '🌱'),
    (gen_random_uuid(), 'Turmeric', 'Root', '🫚'),
    (gen_random_uuid(), 'Wasabi', 'Root', '🌱'),
    (gen_random_uuid(), 'Water Chestnut', 'Root', '🌱'),
    (gen_random_uuid(), 'Yam', 'Root', '🌱'),
    -- Bulb/Stem → Root
    (gen_random_uuid(), 'Cardoon', 'Root', '🌱'),
    (gen_random_uuid(), 'Elephant Garlic', 'Root', '🧄'),
    (gen_random_uuid(), 'Lotus Root', 'Root', '🌸'),
    (gen_random_uuid(), 'Nopal', 'Root', '🌱'),
    (gen_random_uuid(), 'Welsh Onion', 'Root', '🌱'),
    (gen_random_uuid(), 'Wild Leek', 'Root', '🌱'),

    -- Sea (new category)
    (gen_random_uuid(), 'Aonori', 'Sea', '🌊'),
    (gen_random_uuid(), 'Arame', 'Sea', '🌊'),
    (gen_random_uuid(), 'Dulse', 'Sea', '🌊'),
    (gen_random_uuid(), 'Hijiki', 'Sea', '🌊'),
    (gen_random_uuid(), 'Kombu', 'Sea', '🌊'),
    (gen_random_uuid(), 'Nori', 'Sea', '🌊'),
    (gen_random_uuid(), 'Sea Lettuce', 'Sea', '🌊'),
    (gen_random_uuid(), 'Sea Grape', 'Sea', '🌊'),
    (gen_random_uuid(), 'Wakame', 'Sea', '🌊');

-- ============================================================
-- SEEDING MONTHS
-- ============================================================

INSERT INTO seeding_months (vegetable_id, month_num)
SELECT v.id, m.month_num
FROM vegetables v
JOIN (VALUES
    -- Leafy
    ('Borage', 4), ('Borage', 5), ('Borage', 6),
    ('Caraway', 3), ('Caraway', 4), ('Caraway', 5),
    ('Celtuce', 3), ('Celtuce', 4), ('Celtuce', 5),
    ('Common Purslane', 4), ('Common Purslane', 5), ('Common Purslane', 6),
    ('Cress', 3), ('Cress', 4), ('Cress', 5), ('Cress', 6), ('Cress', 7), ('Cress', 8), ('Cress', 9),
    ('Dandelion', 3), ('Dandelion', 4), ('Dandelion', 5),
    ('Fiddlehead', 3), ('Fiddlehead', 4),
    ('Garland Chrysanthemum', 3), ('Garland Chrysanthemum', 4), ('Garland Chrysanthemum', 5), ('Garland Chrysanthemum', 8), ('Garland Chrysanthemum', 9),
    ('Jute Mallow', 5), ('Jute Mallow', 6),
    ('Kai-lan', 3), ('Kai-lan', 4), ('Kai-lan', 5), ('Kai-lan', 8), ('Kai-lan', 9),
    ('Kalette', 4), ('Kalette', 5),
    ('Komatsuna', 3), ('Komatsuna', 4), ('Komatsuna', 5), ('Komatsuna', 8), ('Komatsuna', 9),
    ('Lamb''s Quarters', 4), ('Lamb''s Quarters', 5),
    ('Land Cress', 3), ('Land Cress', 4), ('Land Cress', 5), ('Land Cress', 8), ('Land Cress', 9),
    ('Malabar Spinach', 4), ('Malabar Spinach', 5),
    ('Mallow', 4), ('Mallow', 5),
    ('Miner''s Lettuce', 3), ('Miner''s Lettuce', 4), ('Miner''s Lettuce', 9), ('Miner''s Lettuce', 10),
    ('Moringa', 4), ('Moringa', 5),
    ('New Zealand Spinach', 4), ('New Zealand Spinach', 5),
    ('Orache', 3), ('Orache', 4), ('Orache', 5),
    ('Samphire', 3), ('Samphire', 4),
    ('Sea Beet', 3), ('Sea Beet', 4),
    ('Sea Kale', 3), ('Sea Kale', 4),
    ('Tatsoi', 3), ('Tatsoi', 4), ('Tatsoi', 5), ('Tatsoi', 8), ('Tatsoi', 9),
    ('Water Spinach', 4), ('Water Spinach', 5),
    ('Wheatgrass', 1), ('Wheatgrass', 2), ('Wheatgrass', 3), ('Wheatgrass', 4), ('Wheatgrass', 5), ('Wheatgrass', 6),
    ('Wheatgrass', 7), ('Wheatgrass', 8), ('Wheatgrass', 9), ('Wheatgrass', 10), ('Wheatgrass', 11), ('Wheatgrass', 12),
    ('Yao Choy', 3), ('Yao Choy', 4), ('Yao Choy', 5), ('Yao Choy', 8), ('Yao Choy', 9),

    -- Fruiting
    ('Bitter Melon', 3), ('Bitter Melon', 4),
    ('Butternut Squash', 4), ('Butternut Squash', 5),
    ('Calabash', 4), ('Calabash', 5),
    ('Chayote', 4), ('Chayote', 5),
    ('Cucamelon', 3), ('Cucamelon', 4),
    ('Kabocha', 4), ('Kabocha', 5),
    ('Luffa', 3), ('Luffa', 4),
    ('Spaghetti Squash', 4), ('Spaghetti Squash', 5),
    ('Tomatillo', 3), ('Tomatillo', 4),
    ('Watermelon', 4), ('Watermelon', 5),
    ('Winter Melon', 4), ('Winter Melon', 5),
    ('Jalapeño', 2), ('Jalapeño', 3),
    ('Habanero', 2), ('Habanero', 3),
    ('Cayenne Pepper', 2), ('Cayenne Pepper', 3),

    -- Flower
    ('Banana Flower', 4), ('Banana Flower', 5),
    ('Caper', 4), ('Caper', 5),
    ('Daylily', 3), ('Daylily', 4),
    ('Loroco', 4), ('Loroco', 5),

    -- Legume
    ('Asparagus Bean', 5), ('Asparagus Bean', 6),
    ('Adzuki Bean', 5), ('Adzuki Bean', 6),
    ('Black-eyed Pea', 5), ('Black-eyed Pea', 6),
    ('Chickpea', 4), ('Chickpea', 5),
    ('Lima Bean', 5), ('Lima Bean', 6),
    ('Mung Bean', 5), ('Mung Bean', 6),
    ('Okra', 4), ('Okra', 5),
    ('Snow Pea', 3), ('Snow Pea', 4), ('Snow Pea', 5),
    ('Winged Bean', 5), ('Winged Bean', 6),

    -- Root
    ('Bamboo Shoot', 4), ('Bamboo Shoot', 5),
    ('Burdock', 3), ('Burdock', 4), ('Burdock', 5),
    ('Cassava', 4), ('Cassava', 5),
    ('Galangal', 4), ('Galangal', 5),
    ('Ginger', 3), ('Ginger', 4),
    ('Hamburg Parsley', 3), ('Hamburg Parsley', 4),
    ('Horseradish', 3), ('Horseradish', 4),
    ('Jicama', 4), ('Jicama', 5),
    ('Rutabaga', 5), ('Rutabaga', 6), ('Rutabaga', 7),
    ('Salsify', 3), ('Salsify', 4),
    ('Scorzonera', 3), ('Scorzonera', 4),
    ('Taro', 4), ('Taro', 5),
    ('Tigernut', 4), ('Tigernut', 5),
    ('Turmeric', 4), ('Turmeric', 5),
    ('Wasabi', 3), ('Wasabi', 4),
    ('Water Chestnut', 4), ('Water Chestnut', 5),
    ('Yam', 4), ('Yam', 5),
    ('Cardoon', 3), ('Cardoon', 4),
    ('Elephant Garlic', 10), ('Elephant Garlic', 11),
    ('Lotus Root', 4), ('Lotus Root', 5),
    ('Nopal', 4), ('Nopal', 5),
    ('Welsh Onion', 3), ('Welsh Onion', 4), ('Welsh Onion', 5),
    ('Wild Leek', 3), ('Wild Leek', 4)

    -- Sea vegetables: no seeding months
) AS m(veg_name, month_num) ON v.name = m.veg_name;

-- ============================================================
-- HARVESTING MONTHS
-- ============================================================

INSERT INTO harvesting_months (vegetable_id, month_num)
SELECT v.id, m.month_num
FROM vegetables v
JOIN (VALUES
    -- Leafy
    ('Borage', 6), ('Borage', 7), ('Borage', 8), ('Borage', 9),
    ('Caraway', 7), ('Caraway', 8), ('Caraway', 9),
    ('Celtuce', 5), ('Celtuce', 6), ('Celtuce', 7),
    ('Common Purslane', 6), ('Common Purslane', 7), ('Common Purslane', 8), ('Common Purslane', 9),
    ('Cress', 3), ('Cress', 4), ('Cress', 5), ('Cress', 6), ('Cress', 7), ('Cress', 8), ('Cress', 9), ('Cress', 10),
    ('Dandelion', 4), ('Dandelion', 5), ('Dandelion', 6), ('Dandelion', 7), ('Dandelion', 8), ('Dandelion', 9), ('Dandelion', 10),
    ('Fiddlehead', 4), ('Fiddlehead', 5),
    ('Garland Chrysanthemum', 5), ('Garland Chrysanthemum', 6), ('Garland Chrysanthemum', 7), ('Garland Chrysanthemum', 9), ('Garland Chrysanthemum', 10),
    ('Grape Leaves', 5), ('Grape Leaves', 6), ('Grape Leaves', 7),
    ('Jute Mallow', 7), ('Jute Mallow', 8), ('Jute Mallow', 9),
    ('Kai-lan', 5), ('Kai-lan', 6), ('Kai-lan', 7), ('Kai-lan', 9), ('Kai-lan', 10),
    ('Kalette', 9), ('Kalette', 10), ('Kalette', 11), ('Kalette', 12),
    ('Komatsuna', 5), ('Komatsuna', 6), ('Komatsuna', 7), ('Komatsuna', 9), ('Komatsuna', 10),
    ('Lamb''s Quarters', 5), ('Lamb''s Quarters', 6), ('Lamb''s Quarters', 7), ('Lamb''s Quarters', 8),
    ('Land Cress', 4), ('Land Cress', 5), ('Land Cress', 6), ('Land Cress', 9), ('Land Cress', 10), ('Land Cress', 11),
    ('Malabar Spinach', 7), ('Malabar Spinach', 8), ('Malabar Spinach', 9),
    ('Mallow', 6), ('Mallow', 7), ('Mallow', 8), ('Mallow', 9),
    ('Miner''s Lettuce', 4), ('Miner''s Lettuce', 5), ('Miner''s Lettuce', 6), ('Miner''s Lettuce', 10), ('Miner''s Lettuce', 11), ('Miner''s Lettuce', 12),
    ('Moringa', 7), ('Moringa', 8), ('Moringa', 9),
    ('New Zealand Spinach', 6), ('New Zealand Spinach', 7), ('New Zealand Spinach', 8), ('New Zealand Spinach', 9),
    ('Orache', 5), ('Orache', 6), ('Orache', 7), ('Orache', 8),
    ('Samphire', 5), ('Samphire', 6), ('Samphire', 7), ('Samphire', 8),
    ('Sea Beet', 5), ('Sea Beet', 6), ('Sea Beet', 7), ('Sea Beet', 8), ('Sea Beet', 9), ('Sea Beet', 10),
    ('Sea Kale', 3), ('Sea Kale', 4), ('Sea Kale', 5), ('Sea Kale', 6), ('Sea Kale', 7),
    ('Tatsoi', 5), ('Tatsoi', 6), ('Tatsoi', 7), ('Tatsoi', 9), ('Tatsoi', 10),
    ('Water Spinach', 6), ('Water Spinach', 7), ('Water Spinach', 8), ('Water Spinach', 9),
    ('Wheatgrass', 1), ('Wheatgrass', 2), ('Wheatgrass', 3), ('Wheatgrass', 4), ('Wheatgrass', 5), ('Wheatgrass', 6),
    ('Wheatgrass', 7), ('Wheatgrass', 8), ('Wheatgrass', 9), ('Wheatgrass', 10), ('Wheatgrass', 11), ('Wheatgrass', 12),
    ('Yao Choy', 5), ('Yao Choy', 6), ('Yao Choy', 7), ('Yao Choy', 9), ('Yao Choy', 10),

    -- Fruiting
    ('Bitter Melon', 7), ('Bitter Melon', 8), ('Bitter Melon', 9),
    ('Butternut Squash', 9), ('Butternut Squash', 10),
    ('Calabash', 8), ('Calabash', 9), ('Calabash', 10),
    ('Chayote', 8), ('Chayote', 9), ('Chayote', 10),
    ('Cucamelon', 7), ('Cucamelon', 8), ('Cucamelon', 9),
    ('Kabocha', 8), ('Kabocha', 9), ('Kabocha', 10),
    ('Luffa', 8), ('Luffa', 9), ('Luffa', 10),
    ('Spaghetti Squash', 9), ('Spaghetti Squash', 10),
    ('Tomatillo', 7), ('Tomatillo', 8), ('Tomatillo', 9),
    ('Watermelon', 8), ('Watermelon', 9),
    ('Winter Melon', 9), ('Winter Melon', 10),
    ('Jalapeño', 7), ('Jalapeño', 8), ('Jalapeño', 9), ('Jalapeño', 10),
    ('Habanero', 8), ('Habanero', 9), ('Habanero', 10),
    ('Cayenne Pepper', 7), ('Cayenne Pepper', 8), ('Cayenne Pepper', 9), ('Cayenne Pepper', 10),

    -- Flower
    ('Banana Flower', 9), ('Banana Flower', 10),
    ('Caper', 5), ('Caper', 6), ('Caper', 7), ('Caper', 8),
    ('Daylily', 5), ('Daylily', 6), ('Daylily', 7),
    ('Loroco', 6), ('Loroco', 7), ('Loroco', 8), ('Loroco', 9),

    -- Legume
    ('Asparagus Bean', 7), ('Asparagus Bean', 8), ('Asparagus Bean', 9),
    ('Adzuki Bean', 9), ('Adzuki Bean', 10),
    ('Black-eyed Pea', 8), ('Black-eyed Pea', 9),
    ('Chickpea', 8), ('Chickpea', 9),
    ('Lima Bean', 8), ('Lima Bean', 9),
    ('Mung Bean', 8), ('Mung Bean', 9),
    ('Okra', 7), ('Okra', 8), ('Okra', 9),
    ('Snow Pea', 5), ('Snow Pea', 6), ('Snow Pea', 7),
    ('Winged Bean', 8), ('Winged Bean', 9), ('Winged Bean', 10),

    -- Root
    ('Bamboo Shoot', 4), ('Bamboo Shoot', 5), ('Bamboo Shoot', 6),
    ('Burdock', 9), ('Burdock', 10), ('Burdock', 11),
    ('Cassava', 9), ('Cassava', 10), ('Cassava', 11),
    ('Galangal', 9), ('Galangal', 10), ('Galangal', 11),
    ('Ginger', 9), ('Ginger', 10),
    ('Hamburg Parsley', 9), ('Hamburg Parsley', 10), ('Hamburg Parsley', 11),
    ('Horseradish', 9), ('Horseradish', 10), ('Horseradish', 11),
    ('Jicama', 9), ('Jicama', 10),
    ('Rutabaga', 9), ('Rutabaga', 10), ('Rutabaga', 11), ('Rutabaga', 12),
    ('Salsify', 10), ('Salsify', 11), ('Salsify', 12),
    ('Scorzonera', 10), ('Scorzonera', 11), ('Scorzonera', 12),
    ('Taro', 9), ('Taro', 10),
    ('Tigernut', 9), ('Tigernut', 10),
    ('Turmeric', 9), ('Turmeric', 10),
    ('Wasabi', 9), ('Wasabi', 10), ('Wasabi', 11), ('Wasabi', 12),
    ('Water Chestnut', 9), ('Water Chestnut', 10),
    ('Yam', 9), ('Yam', 10), ('Yam', 11),
    ('Cardoon', 9), ('Cardoon', 10), ('Cardoon', 11),
    ('Elephant Garlic', 6), ('Elephant Garlic', 7),
    ('Lotus Root', 9), ('Lotus Root', 10), ('Lotus Root', 11),
    ('Nopal', 6), ('Nopal', 7), ('Nopal', 8), ('Nopal', 9),
    ('Welsh Onion', 6), ('Welsh Onion', 7), ('Welsh Onion', 8), ('Welsh Onion', 9), ('Welsh Onion', 10),
    ('Wild Leek', 4), ('Wild Leek', 5)

    -- Sea vegetables: no harvesting months
) AS m(veg_name, month_num) ON v.name = m.veg_name;
