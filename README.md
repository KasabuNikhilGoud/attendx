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
# 1. Supabase: create a project → SQL Editor → run supabase/schema.sql
#    (3 projects for test / staging / production — see docs/environments.md)

# 2. Web (easiest to test — works with zero config in demo mode)
cd web
npm install
npm run dev            # http://localhost:3000

# 3. App
cd app
flutter pub get
flutter run --dart-define-from-file=.env.test
```

Demo logins: `admin@attendx.com` / `hod@` / `faculty@` / `student@` + role123
(e.g. `admin123`). They exist after running `supabase/seed/seed_test.sql`
on the **test** project.

## Environments

| Environment | Branch | Supabase project | Data |
|---|---|---|---|
| Test | `develop` | `attendx-test` | fake users + dummy data |
| Main (Staging) | `staging` | `attendx-staging` | schema only + bootstrap admin |
| Production | `main` | `attendx-prod` | real users |

Full runbook: [`docs/environments.md`](docs/environments.md) — includes
CI/CD (GitHub Actions) build-per-environment and the promotion flow
`develop → staging → tag → main`.

## Issue-driven workflow + AI review

Every change starts as a GitHub issue (✨ feature / 🐞 bug / 🔐 security
template) → `feat/*` branch → PR into `develop` → promote to `staging`/`main`.
OpenCode AI (`opencode.yml`) analyzes new issues, reviews every PR with
structured findings and runs a weekly security audit. Full guide:
[`docs/workflow.md`](docs/workflow.md).
