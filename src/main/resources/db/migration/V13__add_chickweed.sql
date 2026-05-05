INSERT INTO vegetables (id, name, category, emoji) VALUES
    (gen_random_uuid(), 'Chickweed', 'Leafy', '🌿');

INSERT INTO seeding_months (vegetable_id, month_num)
SELECT v.id, m.month_num
FROM vegetables v
JOIN (VALUES
    ('Chickweed', 3), ('Chickweed', 4), ('Chickweed', 9), ('Chickweed', 10)
) AS m(veg_name, month_num) ON v.name = m.veg_name;

INSERT INTO harvesting_months (vegetable_id, month_num)
SELECT v.id, m.month_num
FROM vegetables v
JOIN (VALUES
    ('Chickweed', 3), ('Chickweed', 4), ('Chickweed', 5),
    ('Chickweed', 9), ('Chickweed', 10), ('Chickweed', 11)
) AS m(veg_name, month_num) ON v.name = m.veg_name;
