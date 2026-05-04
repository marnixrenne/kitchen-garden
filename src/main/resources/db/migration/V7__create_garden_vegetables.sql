CREATE TABLE garden_vegetables (
    user_id      UUID NOT NULL,
    vegetable_id UUID NOT NULL,
    CONSTRAINT pk_garden_vegetable  PRIMARY KEY (user_id, vegetable_id),
    CONSTRAINT fk_garden_user       FOREIGN KEY (user_id)      REFERENCES users (id),
    CONSTRAINT fk_garden_vegetable  FOREIGN KEY (vegetable_id) REFERENCES vegetables (id)
);
