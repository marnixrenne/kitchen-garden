CREATE TABLE user_preferences (
    user_id UUID         NOT NULL,
    key     VARCHAR(100) NOT NULL,
    value   VARCHAR(500) NOT NULL,
    CONSTRAINT pk_user_preference  PRIMARY KEY (user_id, key),
    CONSTRAINT fk_preference_user  FOREIGN KEY (user_id) REFERENCES users (id)
);
