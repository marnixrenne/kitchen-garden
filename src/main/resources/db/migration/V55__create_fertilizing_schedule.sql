CREATE TABLE pts_fertilizing_schedule (
    fertilizer_type       VARCHAR(20) NOT NULL,
    start_days_after_seed SMALLINT    NOT NULL,
    interval_days         SMALLINT    NOT NULL,
    window_days           SMALLINT    NOT NULL,
    max_applications      SMALLINT    NOT NULL,
    CONSTRAINT pk_fertilizing_schedule PRIMARY KEY (fertilizer_type)
);

INSERT INTO pts_fertilizing_schedule (fertilizer_type, start_days_after_seed, interval_days, window_days, max_applications) VALUES
    ('heavy_feeder',    14, 14, 6, 5),
    ('moderate_feeder', 21, 21, 6, 3),
    ('light_feeder',    28, 28, 6, 2),
    ('none',             0,  0, 0, 0);
