CREATE TABLE pts_plant_plan_entry (
    id            UUID        NOT NULL,
    log_entry_id  UUID        NOT NULL REFERENCES pts_plant_log_entry(id) ON DELETE CASCADE,
    action        VARCHAR(30) NOT NULL,
    planned_date  DATE        NOT NULL,
    created_at    TIMESTAMP   NOT NULL,
    CONSTRAINT pk_plant_plan_entry PRIMARY KEY (id)
);

CREATE INDEX idx_plant_plan_entry_log_entry ON pts_plant_plan_entry(log_entry_id);
