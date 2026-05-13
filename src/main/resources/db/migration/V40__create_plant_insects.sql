CREATE TABLE pts_plant_insects (
    plant_id    UUID         NOT NULL REFERENCES pts_plants(id),
    insect_name VARCHAR(50)  NOT NULL,
    insect_type VARCHAR(15)  NOT NULL,
    PRIMARY KEY (plant_id, insect_name)
);
