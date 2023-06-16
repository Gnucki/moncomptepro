-- This script:
-- - override data at specified id without deleting database
-- - is idempotent.

INSERT INTO users
  (id, email, email_verified, email_verified_at, encrypted_password, created_at, updated_at, given_name, family_name,
   phone_number, job)
VALUES
  (1,
   'user@yopmail.com',
   'true',
   CURRENT_TIMESTAMP,
   '$2a$10$5oxACsw3NngPAXALyB2G3u/C0Ej0CFUyPJhPtyyHP737Xn3lW1Mv.', -- password is 'user@yopmail.com'
   CURRENT_TIMESTAMP,
   CURRENT_TIMESTAMP,
   'Jean',
   'User',
   '0123456789',
   'International knowledge practice leader'),
  -- password for the following users is 'password123'
  (2, 'c6c64542-5601-43e0-b320-b20da72f6edc@mailslurp.com', 'true', CURRENT_TIMESTAMP, '$2a$10$kzY3LINL6..50Fy9shWCcuNlRfYq0ft5lS.KCcJ5PzrhlWfKK4NIO', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Jean', 'User2', '0123456789', 'Sbire'),
  (3, '34c5063f-81c0-4d09-9d0b-a7502f844cdf@mailslurp.com', 'true', CURRENT_TIMESTAMP, '$2a$10$kzY3LINL6..50Fy9shWCcuNlRfYq0ft5lS.KCcJ5PzrhlWfKK4NIO', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Jean', 'User3', '0123456789', 'Sbire'),
  (4, '761a72f6-d051-4df5-a733-62e207c4989b@mailslurp.com', 'true', CURRENT_TIMESTAMP, '$2a$10$kzY3LINL6..50Fy9shWCcuNlRfYq0ft5lS.KCcJ5PzrhlWfKK4NIO', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Jean', 'User4', '0123456789', 'Sbire'),
  (5, 'be040966-0142-421b-8041-5a3543a79a8a@mailslurp.com', 'true', CURRENT_TIMESTAMP, '$2a$10$kzY3LINL6..50Fy9shWCcuNlRfYq0ft5lS.KCcJ5PzrhlWfKK4NIO', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Jean', 'User5', '0123456789', 'Sbire'),
  (6, '487ef426-6135-42c9-b805-9161d3474974@mailslurp.com', 'true', CURRENT_TIMESTAMP, '$2a$10$kzY3LINL6..50Fy9shWCcuNlRfYq0ft5lS.KCcJ5PzrhlWfKK4NIO', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Jean', 'User6', '0123456789', 'Sbire'),
  (7, '4fd3acbc-8711-4487-9313-c52dee8afcbb@mailslurp.com', 'true', CURRENT_TIMESTAMP, '$2a$10$kzY3LINL6..50Fy9shWCcuNlRfYq0ft5lS.KCcJ5PzrhlWfKK4NIO', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Jean', 'User7', '0123456789', 'Sbire')
ON CONFLICT (id)
  DO UPDATE
  SET (email, email_verified, email_verified_at, encrypted_password, created_at, updated_at, given_name, family_name,
       phone_number, job)
    = (EXCLUDED.email, EXCLUDED.email_verified, EXCLUDED.email_verified_at, EXCLUDED.encrypted_password, EXCLUDED.created_at,
       EXCLUDED.updated_at, EXCLUDED.given_name, EXCLUDED.family_name,
       EXCLUDED.phone_number, EXCLUDED.job);

SELECT setval(
    'users_id_seq',
    GREATEST(
        (SELECT MAX(id) FROM users),
        (SELECT last_value FROM users_id_seq)
      )
  );

INSERT INTO organizations
  (id, siret, verified_email_domains, authorized_email_domains, created_at, updated_at)
VALUES
  -- COMMUNE DE CLAMART - Mairie
  (1, '21920023500014', '{"mailslurp.com"}', '{"mailslurp.com"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  -- COMMUNE DE CLAMART - Service assainissement
  (2, '21920023500394', '{}', '{"mailslurp.com"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  -- DIRECTION INTERMINISTERIELLE DU NUMERIQUE (DINUM)
  (3, '13002526500013', '{"beta.gouv.fr"}', '{"beta.gouv.fr"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)

ON CONFLICT (id)
  DO UPDATE
  SET (siret, authorized_email_domains, created_at, updated_at)
    = (EXCLUDED.siret, EXCLUDED.authorized_email_domains, EXCLUDED.created_at, EXCLUDED.updated_at);

SELECT setval(
    'organizations_id_seq',
    GREATEST(
        (SELECT MAX(id) FROM organizations),
        (SELECT last_value FROM organizations_id_seq)
      )
  );

INSERT INTO users_organizations
  (user_id, organization_id, verification_type, authentication_by_peers_type, has_been_greeted)
VALUES
  (3, 1, 'verified_email_domain', 'all_members_notified', true),
  (4, 1, 'verified_email_domain', 'all_members_notified', true),
  (5, 1, 'verified_email_domain', 'all_members_notified', true),
  (6, 1, 'verified_email_domain', 'all_members_notified', true),
  (7, 1, 'verified_email_domain', 'all_members_notified', true),
  (3, 2, 'verified_email_domain', 'all_members_notified', true),
  (4, 2, 'verified_email_domain', 'all_members_notified', true),
  (5, 2, 'verified_email_domain', 'all_members_notified', true),
  (6, 2, 'verified_email_domain', 'all_members_notified', true),
  (7, 2, 'verified_email_domain', 'all_members_notified', true)
ON CONFLICT (user_id, organization_id)
  DO UPDATE
  SET (verification_type, authentication_by_peers_type, has_been_greeted)
    = (EXCLUDED.verification_type, EXCLUDED.authentication_by_peers_type, EXCLUDED.has_been_greeted);

SELECT setval(
    'oidc_clients_id_seq',
    GREATEST(
        (SELECT MAX(id) FROM oidc_clients),
        (SELECT last_value FROM oidc_clients_id_seq)
      )
  );
