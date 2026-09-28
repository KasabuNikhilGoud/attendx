# AttendX — ERP Attendance Management System

A full-stack ERP system for managing attendance across institutions.

## Monorepo Structure

```
attendx/
├── app/          → Flutter mobile app (Android + iOS)
├── web/          → Next.js 14 web dashboard (Vercel)
└── supabase/     → Database schema + Edge Functions (email)
```

## Roles
- **Student** — view own attendance, percentage, subject-wise breakdown
- **Faculty** — mark attendance per subject/session, view class reports
- **HOD** — department-level reports, approve/flag sessions
- **Admin** — full CRUD: users, departments, classes, subjects, enrollments

## Tech Stack
| Layer | Tech |
|---|---|
| Mobile | Flutter 3 + Supabase Flutter |
| Web | Next.js 14 (App Router) + Tailwind CSS |
| Database | Supabase (PostgreSQL + RLS) |
| Auth | Supabase Auth (role-based) |
| Email | Supabase Edge Functions + Resend |
| Web Deploy | Vercel |
| App Deploy | Google Play + App Store |

## Getting Started

### 1. Supabase Setup
- Create project at supabase.com
- Run `supabase/migrations/` SQL files in order
- Copy your `SUPABASE_URL` and `SUPABASE_ANON_KEY`

### 2. Flutter App
```bash
cd app
flutter pub get
# add your supabase keys in lib/core/constants/app_constants.dart
flutter run
```

### 3. Next.js Web
```bash
cd web
npm install
# add keys in .env.local
npm run dev
```
