-- ============================================================
-- AttendX — TEST ENVIRONMENT SEED  (fake users + dummy data)
-- ============================================================
-- ⚠️  TARGETS THE attendx-test SUPABASE PROJECT ONLY.
--     NEVER run this on staging or production!
--
-- What it creates (all fake):
--   • 1 admin + 3 HODs + 9 faculty + 30 students = 43 accounts
--   • 6 classes, 12 subjects, 120 enrollments
--   • ~30 recent class days of attendance sessions + records
--     (1 chronic low-attendance student per class → <75% demo)
--
-- Demo logins (password = role + 123):
--   admin@attendx.com     / admin123
--   hod@attendx.com       / hod123
--   faculty@attendx.com   / faculty123
--   student@attendx.com   / student123
--   Others: hod.it@attendx.com, cs.faculty2@attendx.com,
--           cs24a002@student.attendx.com, …
--
-- IDEMPOTENT: safe to re-run; existing rows are skipped, demo
-- passwords for the 4 canonical logins are force-corrected.
-- REQUIRES: supabase/schema.sql applied to this project first.
-- Run in:   Supabase Dashboard → SQL Editor → paste → Run
-- ============================================================

set statement_timeout = '5min';

create extension if not exists pgcrypto;
create extension if not exists "uuid-ossp";

do $seed$
declare
  adm2       text;
  prefix     text;
  v_roll     text;
  v_email    text;
  v_user_id  uuid;
  v_fullname text;
  v_sess_id  uuid;
  v_absent   double precision;
  v_rand     double precision;
  v_status   text;
  v_day      date;
  cls        record;
  sub        record;
  rec        record;
begin
  -- ------------------------------------------------------------------
  -- 0. Sanity — schema.sql must be applied to this project first.
  -- ------------------------------------------------------------------
  if  to_regclass('public.profiles')           is null
  or  to_regclass('public.attendance_records') is null
  or  to_regclass('auth.users')                is null then
    raise exception 'Run supabase/schema.sql first — required tables are missing.';
  end if;

  perform setseed(0.42);  -- deterministic pseudo-random attendance

  -- ------------------------------------------------------------------
  -- 1. DEPARTMENTS (idempotent — schema seed already adds these)
  -- ------------------------------------------------------------------
  insert into public.departments (name, code) values
    ('Computer Science', 'CS'),
    ('Information Technology', 'IT'),
    ('Electronics', 'ECE')
  on conflict (code) do nothing;

  -- ------------------------------------------------------------------
  -- 2. ADMIN (trigger on auth.users auto-creates the profile)
  -- ------------------------------------------------------------------
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

  -- ------------------------------------------------------------------
  -- 3. HODs (CS reuses the canonical demo login hod@attendx.com)
  -- ------------------------------------------------------------------
  insert into auth.users
    (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
     raw_app_meta_data, raw_user_meta_data, confirmation_token, recovery_token,
     email_change, email_change_token_new, created_at, updated_at)
  select
    '00000000-0000-0000-0000-000000000000', uuid_generate_v4(),
    'authenticated', 'authenticated',
    t.email, crypt('hod123', gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}',
    jsonb_build_object('full_name', t.name, 'role', 'hod'),
    '', '', '', '', now(), now()
  from (values
    ('hod@attendx.com',    'Dr. Anita Patel'),
    ('hod.it@attendx.com', 'Dr. Suresh Menon'),
    ('hod.ece@attendx.com','Dr. Kavitha Nair')
  ) as t(email, name)
  where not exists (select 1 from auth.users u where u.email = t.email);

  -- ------------------------------------------------------------------
  -- 4. FACULTY (9 — CS faculty1 reuses faculty@attendx.com)
  -- ------------------------------------------------------------------
  insert into auth.users
    (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
     raw_app_meta_data, raw_user_meta_data, confirmation_token, recovery_token,
     email_change, email_change_token_new, created_at, updated_at)
  select
    '00000000-0000-0000-0000-000000000000', uuid_generate_v4(),
    'authenticated', 'authenticated',
    t.email, crypt('faculty123', gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}',
    jsonb_build_object('full_name', t.name, 'role', 'faculty'),
    '', '', '', '', now(), now()
  from (values
    ('faculty@attendx.com',     'Prof. Ramesh Kumar'),
    ('cs.faculty2@attendx.com', 'Prof. Sowmya Reddy'),
    ('cs.faculty3@attendx.com', 'Prof. Vikram Singh'),
    ('it.faculty1@attendx.com', 'Prof. Anitha Joshi'),
    ('it.faculty2@attendx.com', 'Prof. Praveen Naidu'),
    ('it.faculty3@attendx.com', 'Prof. Deepa Iyer'),
    ('ece.faculty1@attendx.com','Prof. Manoj Varma'),
    ('ece.faculty2@attendx.com','Prof. Lakshmi Prasad'),
    ('ece.faculty3@attendx.com','Prof. Srinath Babu')
  ) as t(email, name)
  where not exists (select 1 from auth.users u where u.email = t.email);

  -- ------------------------------------------------------------------
  -- 5. STUDENTS — 5 per class × 6 classes = 30
  --    roll_no = <DEPT><ADM><SECTION><SEQ>  e.g. CS24A001
  --    email   = cs24a001@student.attendx.com
  --    (CS 2-A seat #1 = canonical student@attendx.com demo login)
  -- ------------------------------------------------------------------
  for cls in
    select c.id as class_id, c.department_id, d.code, c.year, c.section
    from public.classes c
    join public.departments d on d.id = c.department_id
    order by d.code, c.year
  loop
    adm2   := lpad(mod((2025 - (cls.year - 1))::int, 100)::text, 2, '0');
    prefix := cls.code || adm2 || cls.section;

    for i in 1..5 loop
      v_roll := prefix || lpad(i::text, 3, '0');
      if cls.code = 'CS' and cls.year = 2 and cls.section = 'A' and i = 1 then
        v_email := 'student@attendx.com';
      else
        v_email := lower(v_roll) || '@student.attendx.com';
      end if;

      v_fullname := (array['Rahul','Aarav','Diya','Rohan','Ishita'])[i] || ' ' ||
        case cls.code
          when 'CS'  then (array['Reddy','Goud','Sharma','Gupta','Rao'])[i]
          when 'IT'  then (array['Joshi','Nair','Iyer','Patel','Singh'])[i]
          else            (array['Varma','Prasad','Babu','Naidu','Pillai'])[i]
        end;

      if not exists (select 1 from auth.users u where u.email = v_email) then
        insert into auth.users
          (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
           raw_app_meta_data, raw_user_meta_data, confirmation_token, recovery_token,
           email_change, email_change_token_new, created_at, updated_at)
        values
          ('00000000-0000-0000-0000-000000000000', uuid_generate_v4(),
           'authenticated', 'authenticated',
           v_email, crypt('student123', gen_salt('bf')), now(),
           '{"provider":"email","providers":["email"]}',
           jsonb_build_object('full_name', v_fullname, 'role', 'student'),
           '', '', '', '', now(), now())
        returning id into v_user_id;
      else
        v_user_id := (select id from auth.users u where u.email = v_email);
      end if;

      update public.profiles
      set department_id = cls.department_id,
          roll_no       = v_roll
      where id = v_user_id;
    end loop;
  end loop;

  -- ------------------------------------------------------------------
  -- 6. CLASSES — 2 per dept (2nd & 3rd year), deterministic names
  -- ------------------------------------------------------------------
  insert into public.classes (name, department_id, year, section, academic_year)
  select concat(d.code, ' ', c.y, c.s, ' (2025-26)'), d.id, c.y, c.s, '2025-26'
  from (values
    ('CS',2,'A'), ('CS',3,'A'),
    ('IT',2,'A'), ('IT',3,'B'),
    ('ECE',2,'A'), ('ECE',3,'A')
  ) as c(code, y, s)
  join public.departments d on d.code = c.code
  on conflict do nothing;

  -- ------------------------------------------------------------------
  -- 7. SUBJECTS — 4 per dept, taught by that dept's faculty
  -- ------------------------------------------------------------------
  insert into public.subjects (name, code, credits, department_id, faculty_id, semester, is_active)
  select t.name, t.code, t.credits, d.id, p.id, t.sem, true
  from (values
    ('Data Structures',             'CS201', 3, 3, 'faculty@attendx.com'),
    ('Operating Systems',           'CS202', 3, 4, 'cs.faculty2@attendx.com'),
    ('Database Management Systems', 'CS203', 4, 5, 'cs.faculty3@attendx.com'),
    ('Software Engineering',        'CS204', 2, 5, 'faculty@attendx.com'),
    ('Web Technologies',            'IT201', 3, 3, 'it.faculty1@attendx.com'),
    ('Computer Networks',           'IT202', 3, 4, 'it.faculty2@attendx.com'),
    ('Information Security',        'IT203', 2, 5, 'it.faculty3@attendx.com'),
    ('Cloud Computing',             'IT204', 2, 5, 'it.faculty1@attendx.com'),
    ('Digital Electronics',         'ECE201',3, 3, 'ece.faculty1@attendx.com'),
    ('Signals and Systems',         'ECE202',3, 4, 'ece.faculty2@attendx.com'),
    ('Microcontrollers',            'ECE203',2, 5, 'ece.faculty3@attendx.com'),
    ('Communication Systems',       'ECE204',3, 5, 'ece.faculty1@attendx.com')
  ) as t(name, code, credits, sem, fac_email)
  join public.departments d on d.code = left(t.code, 2)
  join public.profiles   p on p.email = t.fac_email
  on conflict (code) do nothing;

  -- ------------------------------------------------------------------
  -- 8. LINK department HODs (hod_id)
  -- ------------------------------------------------------------------
  update public.departments d
  set hod_id = p.id
  from public.profiles p
  where (d.code = 'CS'  and p.email = 'hod@attendx.com')
     or (d.code = 'IT'  and p.email = 'hod.it@attendx.com')
     or (d.code = 'ECE' and p.email = 'hod.ece@attendx.com');

  -- ------------------------------------------------------------------
  -- 9. LINK staff → departments, add designations, force demo roles
  -- ------------------------------------------------------------------
  update public.profiles p
  set department_id = d.id
  from public.departments d
  where (d.code = 'CS'  and (p.email = 'faculty@attendx.com' or p.email like 'cs.%'  or p.email = 'admin@attendx.com' or p.email = 'hod@attendx.com'))
     or (d.code = 'IT'  and (p.email like 'it.%' or p.email = 'hod.it@attendx.com'))
     or (d.code = 'ECE' and (p.email like 'ece.%' or p.email = 'hod.ece@attendx.com'));

  update public.profiles set designation = 'System Administrator'
    where email = 'admin@attendx.com';
  update public.profiles set designation = 'Head of Department'
    where email in ('hod@attendx.com','hod.it@attendx.com','hod.ece@attendx.com');
  update public.profiles set designation = 'Assistant Professor'
    where email in ('faculty@attendx.com','cs.faculty2@attendx.com','cs.faculty3@attendx.com',
                    'it.faculty1@attendx.com','it.faculty2@attendx.com','it.faculty3@attendx.com',
                    'ece.faculty1@attendx.com','ece.faculty2@attendx.com','ece.faculty3@attendx.com');

  -- self-heal roles in case a user pre-existed with the default role
  update public.profiles set role = 'admin'   where email = 'admin@attendx.com'   and role <> 'admin';
  update public.profiles set role = 'hod'
    where email in ('hod@attendx.com','hod.it@attendx.com','hod.ece@attendx.com') and role <> 'hod';
  update public.profiles set role = 'faculty'
    where (email in ('faculty@attendx.com','cs.faculty2@attendx.com','cs.faculty3@attendx.com',
                     'it.faculty1@attendx.com','it.faculty2@attendx.com','it.faculty3@attendx.com',
                     'ece.faculty1@attendx.com','ece.faculty2@attendx.com','ece.faculty3@attendx.com'))
      and role <> 'faculty';

  -- force-correct the 4 canonical demo passwords (so docs always work)
  update auth.users set encrypted_password = crypt('admin123',   gen_salt('bf'))
    where email = 'admin@attendx.com';
  update auth.users set encrypted_password = crypt('hod123',     gen_salt('bf'))
    where email = 'hod@attendx.com';
  update auth.users set encrypted_password = crypt('faculty123', gen_salt('bf'))
    where email = 'faculty@attendx.com';
  update auth.users set encrypted_password = crypt('student123', gen_salt('bf'))
    where email = 'student@attendx.com';

  -- ------------------------------------------------------------------
  -- 10. AUTH IDENTITIES — backfill once for every seeded email user
  --     (required by newer GoTrue for social-free email logins)
  -- ------------------------------------------------------------------
  insert into auth.identities
    (id, user_id, provider_id, provider, identity_data, last_sign_in_at, created_at, updated_at)
  select uuid_generate_v4(), u.id, 'email', 'email',
         jsonb_build_object('sub', u.id::text, 'email', u.email,
                            'email_verified', true, 'phone_verified', false),
         null, now(), now()
  from auth.users u
  where u.email like '%@student.attendx.com'
     or u.email like '%@attendx.com'
  on conflict do nothing;

  update auth.identities
  set identity_data = jsonb_set(identity_data, '{email_verified}', 'true')
  where provider = 'email'
    and identity_data->>'email_verified' is distinct from 'true';

  -- ------------------------------------------------------------------
  -- 11. ENROLLMENTS — student × 4 subjects of their dept
  --     (class matched from admission year + section inside roll_no)
  -- ------------------------------------------------------------------
  insert into public.enrollments (student_id, class_id, subject_id)
  select st.id, c.id, s.id
  from public.profiles st
  join public.departments d
    on d.id = st.department_id
   and st.role = 'student' and st.roll_no is not null
  join public.classes c
    on c.department_id = d.id
   and c.academic_year = '2025-26'
   and c.section = substring(st.roll_no, 5, 1)
   and ('20' || substring(st.roll_no, 3, 2))::int = 2025 - (c.year - 1)
  join public.subjects s
    on s.department_id = d.id
  on conflict do nothing;

  -- ------------------------------------------------------------------
  -- 12. ATTENDANCE — ~30 recent class days (Sundays off)
  --     Sessions per (class × subject), records per enrolled student.
  --     Seat #5 of every class is a chronic absentee (<75% alerts).
  -- ------------------------------------------------------------------
  for v_day in
    select g::date as d
    from generate_series(current_date - 35, current_date - 1, interval '1 day') g
    where extract(dow from g) <> 0
  loop
    for cls in
      select c.id as class_id, d.id as dept_id
      from public.classes c
      join public.departments d on d.id = c.department_id
    loop
      for sub in
        select s.id as subject_id, s.faculty_id,
               row_number() over (order by s.code) as rn
        from public.subjects s
        where s.department_id = cls.dept_id
      loop
        if not exists (
          select 1 from public.attendance_sessions ses
          where ses.subject_id = sub.subject_id
            and ses.class_id = cls.class_id
            and ses.session_date = v_day
        ) then
          insert into public.attendance_sessions
            (subject_id, class_id, faculty_id, session_date, start_time, end_time, is_submitted)
          values
            (sub.subject_id, cls.class_id, sub.faculty_id, v_day,
             (array['09:30','11:00','14:00','15:30'])[sub.rn]::time,
             (array['10:30','12:00','15:00','16:30'])[sub.rn]::time,
             true)
          returning id into v_sess_id;

          for rec in
            select e.student_id,
                   row_number() over (order by st.roll_no) as seat
            from public.enrollments e
            join public.profiles st on st.id = e.student_id
            where e.class_id = cls.class_id
              and e.subject_id = sub.subject_id
          loop
            v_absent := case when rec.seat = 5 then 0.45 else 0.15 end;
            v_rand   := random();
            v_status := case
                          when v_rand < v_absent            then 'absent'
                          when v_rand < v_absent + 0.08     then 'late'
                          else 'present'
                        end;

            insert into public.attendance_records
              (session_id, student_id, status, marked_by)
            values
              (v_sess_id, rec.student_id, v_status, sub.faculty_id)
            on conflict do nothing;
          end loop;
        end if;
      end loop;
    end loop;
  end loop;
end;
$seed$;
