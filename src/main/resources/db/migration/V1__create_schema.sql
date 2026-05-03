CREATE TABLE vegetables (
    id      BIGINT       PRIMARY KEY,
    name     VARCHAR(100) NOT NULL,
    category VARCHAR(50)  NOT NULL,
    emoji    VARCHAR(10)
);

CREATE TABLE seeding_months (
    vegetable_id BIGINT NOT NULL,
    month_num    INT    NOT NULL,
    CONSTRAINT fk_vegetable FOREIGN KEY (vegetable_id) REFERENCES vegetables (id)
);