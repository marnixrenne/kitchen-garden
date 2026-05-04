ALTER TABLE users ADD COLUMN email VARCHAR(200);

CREATE TABLE signup_tokens (
    token      UUID         PRIMARY KEY,
    email      VARCHAR(200) NOT NULL,
    expires_at BIGINT       NOT NULL
);
