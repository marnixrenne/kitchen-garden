-- V62: Add days-to-maturity and image URLs for Grape and Hops
-- Both are vegetatively propagated so seed_depth_mm and germination values remain NULL.
-- Maturity is counted from bare-root / rhizome planting to first usable harvest.

UPDATE pts_plants SET
    days_to_maturity_min = 1095,
    days_to_maturity_max = 1825,
    image_url            = '/images/plants/grape.jpg'
WHERE name = 'Grape';

UPDATE pts_plants SET
    days_to_maturity_min = 365,
    days_to_maturity_max = 1095,
    image_url            = '/images/plants/hops.jpg'
WHERE name = 'Hops';
