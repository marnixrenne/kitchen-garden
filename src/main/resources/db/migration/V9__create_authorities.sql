CREATE TABLE authorities (
    name        VARCHAR(50)  PRIMARY KEY,
    description VARCHAR(200)
);

-- migrate any authorities already in role_authorities
INSERT INTO authorities (name)
SELECT DISTINCT authority FROM role_authorities;

ALTER TABLE role_authorities
    ADD CONSTRAINT fk_role_authority_name FOREIGN KEY (authority) REFERENCES authorities (name);
