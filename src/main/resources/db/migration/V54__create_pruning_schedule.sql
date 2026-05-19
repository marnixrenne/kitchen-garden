CREATE TABLE pts_pruning_schedule (
    pruning_type        VARCHAR(20) NOT NULL,
    weeks_before_start  SMALLINT    NOT NULL,
    weeks_before_end    SMALLINT    NOT NULL,
    CONSTRAINT pk_pruning_schedule PRIMARY KEY (pruning_type)
);

-- weeks_before_start: how many weeks before harvest start the pruning window opens
-- weeks_before_end:   how many weeks before harvest start the pruning window closes
INSERT INTO pts_pruning_schedule (pruning_type, weeks_before_start, weeks_before_end) VALUES
    ('deadheading',  8, 2),
    ('pinching',    10, 6),
    ('suckering',    6, 2),
    ('cutting_back', 4, 2),
    ('topping',      8, 4),
    ('leaf_removal', 6, 2);
