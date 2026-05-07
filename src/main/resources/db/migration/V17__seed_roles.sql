-- Seed the admin authority
INSERT INTO authorities (name, description)
SELECT 'ROLE_ADMIN', 'Full administrative access'
WHERE NOT EXISTS (SELECT 1 FROM authorities WHERE name = 'ROLE_ADMIN');

-- Seed the Admins role
INSERT INTO roles (id, name)
SELECT gen_random_uuid(), 'Admins'
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'Admins');

-- Link the role to the authority
INSERT INTO role_authorities (role_id, authority)
SELECT r.id, 'ROLE_ADMIN'
FROM roles r
WHERE r.name = 'Admins'
  AND NOT EXISTS (
      SELECT 1 FROM role_authorities ra
      WHERE ra.role_id = r.id AND ra.authority = 'ROLE_ADMIN'
  );
