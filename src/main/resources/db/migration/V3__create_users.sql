CREATE TABLE users (
    id           UUID         PRIMARY KEY,
    username     VARCHAR(50)  NOT NULL UNIQUE,
    password     VARCHAR(100) NOT NULL,
    display_name VARCHAR(100) NOT NULL
);
