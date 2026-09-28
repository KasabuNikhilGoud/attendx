# AttendX — AI-Native ERP Attendance System

One platform for attendance, roles, reports, and offline-first mobile. Single source of truth in PostgreSQL (Supabase), AI-ready from day one.

## Features

- Role dashboards: Student, Faculty, HOD, Admin
- Subject/session attendance with percentages and reports
- Department, class, and subject management
- Offline-first Flutter app with auto sync (queue + conflict-safe)
- AI-ready: Copilot, insights, and workflow hooks (attendance < 75% → notify)
- Secure by default: auth, role + tenant checks, audit logs

## Architecture

```text
Flutter (offline) + Next.js web
        ↓ HTTPS
Supabase Auth → RLS → PostgreSQL
        ↓
Realtime + Edge Functions (email) + AI tools
```

See `docs/ai-native-erp.md` for vision and `docs/learning-roadmap.md` for build order.

## Repo

```text
attendx/
├── app/       Flutter mobile app
├── web/       Next.js 14 dashboard
├── supabase/  SQL migrations + edge functions
└── docs/      Vision + learning roadmap
```

## Stack

| Layer | Tech |
|---|---|
| Mobile | Flutter 3, Supabase Flutter |
| Web | Next.js 14, Tailwind |
| Data | Supabase (PostgreSQL + RLS) |
| Auth | Supabase Auth, role-based |
| Jobs/Email | Edge Functions + Resend |

## Quickstart

```bash
# 1. Supabase: create project, run supabase/migrations/*.sql in order

# 2. Web
cd web
npm install
cp .env.local.example .env.local  # fill keys
npm run dev

# 3. App
cd app
flutter pub get
# set keys in lib/core/constants/app_constants.dart
flutter run
```

Demo logins: `admin@attendx.com` / `hod@` / `faculty@` / `student@` + role123 (e.g. `admin123`).
