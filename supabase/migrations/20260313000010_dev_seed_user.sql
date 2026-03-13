-- Create dev test user for local development
-- This inserts directly into auth.users (only works in local dev / Supabase CLI)

INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_user_meta_data,
  raw_app_meta_data,
  aud,
  role,
  confirmation_token,
  recovery_token,
  email_change_token_new,
  email_change
)
VALUES (
  '00000000-0000-0000-0001-000000000001'::UUID,
  'dev@caapp.com',
  crypt('Dev@123456', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  jsonb_build_object('firm_id', '00000000-0000-0000-0000-000000000001', 'role', 'admin'),
  '{"provider":"email","providers":["email"]}'::jsonb,
  'authenticated',
  'authenticated',
  '',
  '',
  '',
  ''
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO auth.identities (
  id,
  user_id,
  provider_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at
)
VALUES (
  gen_random_uuid(),
  '00000000-0000-0000-0001-000000000001'::UUID,
  'dev@caapp.com',
  jsonb_build_object('sub', '00000000-0000-0000-0001-000000000001', 'email', 'dev@caapp.com'),
  'email',
  NOW(),
  NOW(),
  NOW()
)
ON CONFLICT DO NOTHING;

-- NOTE: profiles row inserted in seed.sql (after firms are seeded)
