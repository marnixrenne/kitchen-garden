CREATE TABLE roles (
    id   UUID        PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE role_authorities (
    role_id   UUID        NOT NULL,
    authority VARCHAR(50) NOT NULL,
    CONSTRAINT fk_role_authority FOREIGN KEY (role_id) REFERENCES roles (id)
);

CREATE TABLE user_roles (
    user_id UUID NOT NULL,
    role_id UUID NOT NULL,
    CONSTRAINT fk_user_role_user FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT fk_user_role_role FOREIGN KEY (role_id) REFERENCES roles (id)
);
