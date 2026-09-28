-- ============================================================
-- AttendX — Supabase Database Schema
-- Run this in Supabase SQL Editor
-- ============================================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ============================================================
-- 1. PROFILES (extends Supabase auth.users)
-- ============================================================
create table public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text unique not null,
  full_name   text not null,
  role        text not null check (role in ('student', 'faculty', 'hod', 'admin')),
  phone       text,
  created_at  timestamptz default now()
);

-- ============================================================
-- 2. DEPARTMENTS
-- ============================================================
create table public.departments (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,
  code        text unique not null,   -- e.g. CSE, IT, ECE
  hod_id      uuid references public.profiles(id),
  created_at  timestamptz default now()
);

-- ============================================================
-- 3. CLASSES
-- ============================================================
create table public.classes (
  id              uuid primary key default uuid_generate_v4(),
  name            text not null,       -- e.g. CSE-A
  section         text not null,       -- A, B, C
  batch_year      text not null,       -- e.g. 2023-2027
  department_id   uuid references public.departments(id) on delete cascade,
  created_at      timestamptz default now()
);

-- ============================================================
-- 4. ENROLLMENTS (student ↔ class)
-- ============================================================
create table public.enrollments (
  id          uuid primary key default uuid_generate_v4(),
  student_id  uuid references public.profiles(id) on delete cascade,
  class_id    uuid references public.classes(id) on delete cascade,
  roll_number text,
  created_at  timestamptz default now(),
  unique(student_id, class_id)
);

-- ============================================================
-- 5. SUBJECTS
-- ============================================================
create table public.subjects (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,
  code        text not null,
  class_id    uuid references public.classes(id) on delete cascade,
  faculty_id  uuid references public.profiles(id),
  created_at  timestamptz default now()
);

-- ============================================================
-- 6. ATTENDANCE SESSIONS (one per class per subject per date)
-- ============================================================
create table public.attendance_sessions (
  id          uuid primary key default uuid_generate_v4(),
  subject_id  uuid references public.subjects(id) on delete cascade,
  faculty_id  uuid references public.profiles(id),
  date        date not null,
  status      text default 'submitted' check (status in ('draft', 'submitted', 'approved')),
  created_at  timestamptz default now(),
  unique(subject_id, date)
);

-- ============================================================
-- 7. ATTENDANCE RECORDS (one per student per session)
-- ============================================================
create table public.attendance_records (
  id          uuid primary key default uuid_generate_v4(),
  session_id  uuid references public.attendance_sessions(id) on delete cascade,
  student_id  uuid references public.profiles(id) on delete cascade,
  is_present  boolean default true,
  created_at  timestamptz default now(),
  unique(session_id, student_id)
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
alter table public.profiles           enable row level security;
alter table public.departments        enable row level security;
alter table public.classes            enable row level security;
alter table public.enrollments        enable row level security;
alter table public.subjects           enable row level security;
alter table public.attendance_sessions enable row level security;
alter table public.attendance_records  enable row level security;

-- Helper: get current user role
create or replace function public.get_my_role()
returns text language sql security definer stable as $$
  select role from public.profiles where id = auth.uid();
$$;

-- PROFILES policies
create policy "Users can read own profile"
  on public.profiles for select using (id = auth.uid());

create policy "Admin can read all profiles"
  on public.profiles for select using (get_my_role() = 'admin');

create policy "Admin can insert profiles"
  on public.profiles for insert with check (get_my_role() = 'admin');

create policy "Admin can update profiles"
  on public.profiles for update using (get_my_role() = 'admin');

create policy "Admin can delete profiles"
  on public.profiles for delete using (get_my_role() = 'admin');

-- DEPARTMENTS policies
create policy "All authenticated can read departments"
  on public.departments for select using (auth.uid() is not null);

create policy "Admin can manage departments"
  on public.departments for all using (get_my_role() = 'admin');

-- CLASSES policies
create policy "All authenticated can read classes"
  on public.classes for select using (auth.uid() is not null);

create policy "Admin can manage classes"
  on public.classes for all using (get_my_role() = 'admin');

-- ENROLLMENTS policies
create policy "Students can read own enrollment"
  on public.enrollments for select using (student_id = auth.uid());

create policy "Admin and HOD can read all enrollments"
  on public.enrollments for select using (get_my_role() in ('admin', 'hod'));

create policy "Admin can manage enrollments"
  on public.enrollments for all using (get_my_role() = 'admin');

-- SUBJECTS policies
create policy "All authenticated can read subjects"
  on public.subjects for select using (auth.uid() is not null);

create policy "Admin can manage subjects"
  on public.subjects for all using (get_my_role() = 'admin');

-- ATTENDANCE SESSIONS policies
create policy "Faculty can manage own sessions"
  on public.attendance_sessions for all using (faculty_id = auth.uid());

create policy "HOD and Admin can read all sessions"
  on public.attendance_sessions for select using (get_my_role() in ('hod', 'admin'));

-- ATTENDANCE RECORDS policies
create policy "Students can read own records"
  on public.attendance_records for select using (student_id = auth.uid());

create policy "Faculty can manage records for their sessions"
  on public.attendance_records for all
  using (
    exists (
      select 1 from public.attendance_sessions s
      where s.id = session_id and s.faculty_id = auth.uid()
    )
  );

create policy "HOD and Admin can read all records"
  on public.attendance_records for select using (get_my_role() in ('hod', 'admin'));

-- ============================================================
-- AUTO-CREATE PROFILE ON SIGNUP
-- ============================================================
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', 'User'),
    coalesce(new.raw_user_meta_data->>'role', 'student')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
