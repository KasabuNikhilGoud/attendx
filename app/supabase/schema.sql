-- ============================================================
-- AttendX — Supabase Database Schema (Phase 1) — IDEMPOTENT
-- ============================================================
-- Safe to run multiple times. If tables already exist they are kept;
-- missing ones are created; seed rows are inserted with ON CONFLICT
-- DO NOTHING so re-running never errors and never duplicates.
--
-- Run in: Supabase Dashboard → SQL Editor → New Query → Run
-- ============================================================

create extension if not exists "uuid-ossp";

-- 1. DEPARTMENTS
-- ------------------------------------------------------------
create table if not exists public.departments (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null unique,
  code        text not null unique,
  hod_id      uuid,
  created_at  timestamptz not null default now()
);

-- 2. PROFILES (1:1 with auth.users)
-- ------------------------------------------------------------
create table if not exists public.profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  email         text not null unique,
  full_name     text not null,
  role          text not null check (role in ('student','faculty','hod','admin')),
  department_id uuid references public.departments(id) on delete set null,
  roll_no       text,
  designation   text,
  is_active     boolean not null default true,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- HOD FK (only if not already present)
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'fk_departments_hod'
  ) then
    alter table public.departments
      add constraint fk_departments_hod
      foreign key (hod_id) references public.profiles(id) on delete set null;
  end if;
end $$;

-- 3. CLASSES
-- ------------------------------------------------------------
create table if not exists public.classes (
  id            uuid primary key default uuid_generate_v4(),
  name          text not null,
  department_id uuid not null references public.departments(id) on delete cascade,
  year          int  not null,
  section       text not null,
  academic_year text not null,
  created_at    timestamptz not null default now()
);

-- 4. SUBJECTS
-- ------------------------------------------------------------
create table if not exists public.subjects (
  id            uuid primary key default uuid_generate_v4(),
  name          text not null,
  code          text not null unique,
  credits       int  not null default 3,
  department_id uuid not null references public.departments(id) on delete cascade,
  faculty_id    uuid references public.profiles(id) on delete set null,
  semester      int  not null default 1,
  is_active     boolean not null default true,
  created_at    timestamptz not null default now()
);

-- 5. ENROLLMENTS
-- ------------------------------------------------------------
create table if not exists public.enrollments (
  id         uuid primary key default uuid_generate_v4(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  class_id   uuid not null references public.classes(id) on delete cascade,
  subject_id uuid not null references public.subjects(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- 6. ATTENDANCE SESSIONS
-- ------------------------------------------------------------
create table if not exists public.attendance_sessions (
  id           uuid primary key default uuid_generate_v4(),
  subject_id   uuid not null references public.subjects(id) on delete cascade,
  class_id     uuid not null references public.classes(id) on delete cascade,
  faculty_id   uuid not null references public.profiles(id) on delete cascade,
  session_date date not null,
  start_time   time,
  end_time     time,
  topic        text,
  is_submitted boolean not null default false,
  created_at   timestamptz not null default now()
);

-- 7. ATTENDANCE RECORDS
-- ------------------------------------------------------------
create table if not exists public.attendance_records (
  id         uuid primary key default uuid_generate_v4(),
  session_id uuid not null references public.attendance_sessions(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  status     text not null check (status in ('present','absent','late')),
  marked_by  uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

-- 8. SMTP SETTINGS
-- ------------------------------------------------------------
create table if not exists public.smtp_settings (
  id                uuid primary key default uuid_generate_v4(),
  host              text not null default 'smtp.attendx.com',
  port              int  not null default 587,
  username          text,
  from_email        text,
  from_name         text default 'AttendX',
  enable_tls        boolean not null default true,
  attendance_alerts boolean not null default true,
  weekly_reports    boolean not null default false,
  updated_at        timestamptz not null default now()
);

-- Unique constraints (safe to add repeatedly)
create unique index if not exists uq_enrollments_student_subject
  on public.enrollments (student_id, subject_id);
create unique index if not exists uq_records_session_student
  on public.attendance_records (session_id, student_id);
create unique index if not exists uq_classes_identity
  on public.classes (department_id, year, section, academic_year);

-- ============================================================
-- INDEXES
-- ------------------------------------------------------------
create index if not exists idx_profiles_role        on public.profiles(role);
create index if not exists idx_profiles_dept        on public.profiles(department_id);
create index if not exists idx_enrollments_student  on public.enrollments(student_id);
create index if not exists idx_enrollments_subject  on public.enrollments(subject_id);
create index if not exists idx_sessions_subject     on public.attendance_sessions(subject_id);
create index if not exists idx_sessions_faculty     on public.attendance_sessions(faculty_id);
create index if not exists idx_sessions_date        on public.attendance_sessions(session_date);
create index if not exists idx_records_session      on public.attendance_records(session_id);
create index if not exists idx_records_student      on public.attendance_records(student_id);

-- ============================================================
-- RLS
-- ------------------------------------------------------------
alter table public.departments          enable row level security;
alter table public.profiles             enable row level security;
alter table public.classes              enable row level security;
alter table public.subjects             enable row level security;
alter table public.enrollments          enable row level security;
alter table public.attendance_sessions  enable row level security;
alter table public.attendance_records   enable row level security;
alter table public.smtp_settings        enable row level security;

create or replace function public.current_user_role()
returns text language sql security definer stable as $$
  select role from public.profiles where id = auth.uid();
$$;

create or replace function public.is_staff()
returns boolean language sql security definer stable as $$
  select public.current_user_role() in ('faculty','hod','admin');
$$;

-- PROFILES
drop policy if exists "profiles_select_own_or_staff" on public.profiles;
create policy "profiles_select_own_or_staff" on public.profiles for select
  using (id = auth.uid() or public.is_staff() or public.current_user_role() = 'student');

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles for update
  using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists "profiles_update_staff" on public.profiles;
create policy "profiles_update_staff" on public.profiles for update
  using (public.is_staff());

drop policy if exists "profiles_insert_staff" on public.profiles;
create policy "profiles_insert_staff" on public.profiles for insert
  with check (public.is_staff());

-- DEPARTMENTS
drop policy if exists "departments_select" on public.departments;
create policy "departments_select" on public.departments for select
  using (auth.uid() is not null);
drop policy if exists "departments_write_admin" on public.departments;
create policy "departments_write_admin" on public.departments for all
  using (public.current_user_role() = 'admin');

-- CLASSES
drop policy if exists "classes_select" on public.classes;
create policy "classes_select" on public.classes for select using (auth.uid() is not null);
drop policy if exists "classes_write_admin" on public.classes;
create policy "classes_write_admin" on public.classes for all
  using (public.current_user_role() = 'admin');

-- SUBJECTS
drop policy if exists "subjects_select" on public.subjects;
create policy "subjects_select" on public.subjects for select using (auth.uid() is not null);
drop policy if exists "subjects_write_admin" on public.subjects;
create policy "subjects_write_admin" on public.subjects for all
  using (public.current_user_role() = 'admin');

-- ENROLLMENTS
drop policy if exists "enrollments_select" on public.enrollments;
create policy "enrollments_select" on public.enrollments for select using (auth.uid() is not null);
drop policy if exists "enrollments_write_admin" on public.enrollments;
create policy "enrollments_write_admin" on public.enrollments for all
  using (public.current_user_role() = 'admin');

-- SESSIONS
drop policy if exists "sessions_select" on public.attendance_sessions;
create policy "sessions_select" on public.attendance_sessions for select using (auth.uid() is not null);
drop policy if exists "sessions_insert_staff" on public.attendance_sessions;
create policy "sessions_insert_staff" on public.attendance_sessions for insert
  with check (public.is_staff());
drop policy if exists "sessions_update_own" on public.attendance_sessions;
create policy "sessions_update_own" on public.attendance_sessions for update
  using (faculty_id = auth.uid() or public.current_user_role() in ('hod','admin'));

-- RECORDS
drop policy if exists "records_select" on public.attendance_records;
create policy "records_select" on public.attendance_records for select using (auth.uid() is not null);
drop policy if exists "records_insert_staff" on public.attendance_records;
create policy "records_insert_staff" on public.attendance_records for insert
  with check (public.is_staff());
drop policy if exists "records_update_own" on public.attendance_records;
create policy "records_update_own" on public.attendance_records for update
  using (marked_by = auth.uid() or public.current_user_role() in ('hod','admin'));

-- SMTP
drop policy if exists "smtp_select_admin" on public.smtp_settings;
create policy "smtp_select_admin" on public.smtp_settings for select
  using (public.current_user_role() = 'admin');
drop policy if exists "smtp_update_admin" on public.smtp_settings;
create policy "smtp_update_admin" on public.smtp_settings for update
  using (public.current_user_role() = 'admin');

-- ============================================================
-- AUTO-CREATE PROFILE on signup
-- ------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'role', 'student')
  )
  on conflict (id) do update set
    full_name = excluded.full_name,
    role      = excluded.role;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- SEED DATA (idempotent — ON CONFLICT DO NOTHING)
-- ------------------------------------------------------------
insert into public.departments (name, code) values
  ('Computer Science', 'CS'),
  ('Information Technology', 'IT'),
  ('Electronics', 'ECE')
on conflict (code) do nothing;

insert into public.smtp_settings (host, port)
select 'smtp.attendx.com', 587
where not exists (select 1 from public.smtp_settings);

-- ============================================================
-- VIEWS (server-side aggregates — Phase 4-6)
-- ------------------------------------------------------------
create or replace view public.v_student_subject_attendance as
select
  e.student_id,
  s.id   as subject_id,
  s.code as subject_code,
  s.name as subject_name,
  count(ar.id) filter (where ar.status in ('present','late')) as attended,
  count(ar.id) as held,
  round(
    count(ar.id) filter (where ar.status in ('present','late')) * 100.0
    / nullif(count(ar.id), 0), 1
  ) as percent
from public.enrollments e
join public.subjects s on s.id = e.subject_id
left join public.attendance_sessions ses on ses.subject_id = s.id
left join public.attendance_records ar
  on ar.session_id = ses.id and ar.student_id = e.student_id
group by e.student_id, s.id, s.code, s.name;

create or replace view public.v_department_summary as
select
  d.id   as department_id,
  d.name as department_name,
  count(distinct ses.id) as total_sessions,
  count(ar.id) filter (where ar.status = 'present') as total_present,
  count(ar.id) filter (where ar.status = 'absent')  as total_absent,
  count(ar.id) filter (where ar.status = 'late')    as total_late,
  round(
    count(ar.id) filter (where ar.status in ('present','late')) * 100.0
    / nullif(count(ar.id), 0), 1
  ) as avg_attendance
from public.departments d
left join public.subjects s        on s.department_id = d.id
left join public.attendance_sessions ses on ses.subject_id = s.id
left join public.attendance_records ar   on ar.session_id = ses.id
group by d.id, d.name;

-- DONE. Re-run safely any time; seed rows will not duplicate.
