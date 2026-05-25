CREATE TABLE pts_watering_schedule (
    plant_category        VARCHAR(50) PRIMARY KEY,
    start_days_after_seed INT NOT NULL,
    interval_days         INT NOT NULL,
    window_days           INT NOT NULL
);

INSERT INTO pts_watering_schedule (plant_category, start_days_after_seed, interval_days, window_days) VALUES
    ('Fruiting', 3, 14, 7),
    ('Leafy',    3, 14, 7),
    ('Brassica', 3, 21, 7),
    ('Root',     3, 21, 7),
    ('Legume',   3, 14, 7),
    ('Flower',   3, 14, 7),
    ('Fruit',    3, 14, 7),
    ('Sea',      0,  0, 0);
