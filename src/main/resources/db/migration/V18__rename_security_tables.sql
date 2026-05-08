ALTER TABLE users            RENAME TO sec_users;
ALTER TABLE signup_tokens    RENAME TO sec_signup_tokens;
ALTER TABLE roles            RENAME TO sec_roles;
ALTER TABLE authorities      RENAME TO sec_authorities;
ALTER TABLE role_authorities RENAME TO sec_role_authorities;
ALTER TABLE user_roles       RENAME TO sec_user_roles;
