-- ============================================================
-- AttendX — BOOTSTRAP ADMIN  (staging & production)
-- ============================================================
-- Creates (or repairs) the single admin account used to sign in
-- and configure a fresh project. Run right after schema.sql on:
--   • attendx-staging  — staging rehearsal admin
--   • attendx-prod     — the go-live admin (change password after!)
--
-- NO other user data belongs on staging/production.
-- Idempotent: safe to re-run.
--
-- Login: admin@attendx.com / admin123   → rotate on go-live!
-- ============================================================

set statement_timeout = '2min';

create extension if not exists pgcrypto;
create extension if not exists "uuid-ossp";

-- 1. Ensure auth user + profile (schema trigger auto-creates profile)
insert into auth.users
  (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
   raw_app_meta_data, raw_user_meta_data, confirmation_token, recovery_token,
   email_change, email_change_token_new, created_at, updated_at)
select
  '00000000-0000-0000-0000-000000000000', uuid_generate_v4(),
  'authenticated', 'authenticated',
  'admin@attendx.com', crypt('admin123', gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}',
  jsonb_build_object('full_name', 'System Administrator', 'role', 'admin'),
  '', '', '', '', now(), now()
where not exists (select 1 from auth.users u where u.email = 'admin@attendx.com');

-- 2. Force-correct profile role + password (self-healing)
update public.profiles
set role = 'admin',
    designation = 'System Administrator'
where email = 'admin@attendx.com'
  and (role <> 'admin' or designation is null);

update auth.users
set encrypted_password = crypt('admin123', gen_salt('bf'))
where email = 'admin@attendx.com';

-- 3. Backfill email identity (Required by newer GoTrue on login)
insert into auth.identities
  (id, user_id, provider_id, provider, identity_data, last_sign_in_at, created_at, updated_at)
select uuid_generate_v4(), u.id, 'email', 'email',
       jsonb_build_object('sub', u.id::text, 'email', u.email,
                          'email_verified', true, 'phone_verified', false),
       null, now(), now()
from auth.users u
where u.email = 'admin@attendx.com'
on conflict do nothing;

update auth.identities
set identity_data = jsonb_set(identity_data, '{email_verified}', 'true')
where provider = 'email'
  and identity_data->>'email_verified' is distinct from 'true'
  and identity_data->>'email' = 'admin@attendx.com';
