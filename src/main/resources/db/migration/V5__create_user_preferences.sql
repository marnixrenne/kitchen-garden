CREATE TABLE user_preferences (
    user_id  UUID         NOT NULL,
    pref_key   VARCHAR(100) NOT NULL,
    pref_value VARCHAR(500) NOT NULL,
    CONSTRAINT pk_user_preference  PRIMARY KEY (user_id, pref_key),
    CONSTRAINT fk_preference_user  FOREIGN KEY (user_id) REFERENCES users (id)
);
