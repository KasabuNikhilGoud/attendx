# AttendX — AI-Native ERP Attendance System

One platform for attendance, roles, reports and offline-first mobile.
Single source of truth in PostgreSQL (Supabase), AI-ready from day one —
built **issue-driven** with **AI code review** on every pull request.

```text
┌────────────────────────────────────────────────────────────────┐
│  Flutter app (offline-first)      Next.js 15 web dashboard     │
│          ↓ HTTPS + auth                    ↓ HTTPS + auth      │
│              Supabase  →  Auth  →  RLS  →  PostgreSQL          │
│         Realtime · Edge Functions · AI tools · audit logs      │
└────────────────────────────────────────────────────────────────┘
```

## Repo map

```text
attendx/
├── app/                Flutter mobile app (student/faculty/HOD/admin)
│   └── lib/
│       ├── core/       env loading, theme, services, router
│       └── features/   role dashboards + splash/onboarding
├── web/                Next.js 15 dashboard (zero-config demo mode!)
│   └── src/            app routes · lib (data layer + demo data) · components
├── supabase/           schema.sql (idempotent, RLS) + seed/ (fake users)
├── docs/               environments.md · workflow.md · ai-native-erp.md
├── .github/            CI/CD + OpenCode AI workflows + issue templates
├── .opencode/          AI agents (issue triage, PR reviewer)
├── AGENTS.md           project rules for every AI agent
├── opencode.json       OpenCode project config
└── .devcontainer/      GitHub Codespaces (web-ready on open)
```

## Quickstart — test the web in 60 seconds (no backend needed)

The web dashboard runs in **demo mode** with built-in fake data when no
Supabase keys are configured — perfect for GitHub Codespaces:

```bash
cd web
npm install
npm run dev            # → http://localhost:3000
```

Sign in with any role (one-tap prefill on the login page):

| Role    | Email                 | Password    |
|---|---|---|
| Student | `student@attendx.com` | `student123` |
| Faculty | `faculty@attendx.com` | `faculty123` |
| HOD     | `hod@attendx.com`     | `hod123`     |
| Admin   | `admin@attendx.com`   | `admin123`   |

### Mobile app

```bash
cd app
flutter pub get
flutter run --dart-define-from-file=.env.test   # TEST world (fake users)
```

Create your `app/.env.test` from `app/.env.example` (Supabase Dashboard →
Settings → API → Project URL + anon key). The splash screen always shows
which world you're on: `TEST DATABASE` / `STAGING` / `DEMO MODE` — never in
production.

## Environments — one codebase, three worlds

| Env | Branch | Supabase project | Data |
|---|---|---|---|
| **Test** | `develop` | `attendx-test` | fake users + dummy attendance (`seed_test.sql`) |
| **Main/Staging** | `staging` | `attendx-staging` | schema only + bootstrap admin |
| **Production** | `main` | `attendx-prod` | real users, real data |

```text
feature/* → PR → develop → PR → staging → PR → main → tag vX.Y.Z
   (CI: tests)      (CI+AI review)  (staging APK)   (production release)
```

Production only ever moves by **tags** after a validated staging run.
Full runbook: [`docs/environments.md`](docs/environments.md) (Supabase setup,
seeding, re-seeding, go-live checklist).

## How we build — issue-driven + AI review

Every change starts as a **GitHub issue** (✨ feature / 🐞 bug / 🔐 security
template) → `feat/<slug>` branch → PR into `develop` → promote via PRs.
Full guide: [`docs/workflow.md`](docs/workflow.md).

The **OpenCode AI** workflow (`.github/workflows/opencode.yml`):

| Job | Trigger | Does |
|---|---|---|
| `issue-triage` | new issue | posts clarity check, scope, work plan, branch name, env plan, security notes |
| `pr-review` | PR opened/updated | structured review: findings 🔴🟠🟡🔵 with `file:line`, security pass/fail, verdict |
| `security-audit` | weekly + manual | `npm audit` + `flutter analyze` + secret scan → posts to the security tracker issue |

## CI/CD

| Workflow | Trigger | Effect |
|---|---|---|
| `quality.yml` | any PR | `flutter test` + `next build` gates |
| `build-app.yml` | push `develop` / `staging` / tag `v*` | per-environment release APK (+ GitHub Release on tags) |
| `opencode.yml` | issues / PRs / weekly | AI triage, AI review, security audit |

## Setup checklist (from zero)

1. [ ] Create Supabase projects: `attendx-test`, `attendx-staging` (+ your
       existing project = `attendx-prod`); run `supabase/schema.sql` in each.
2. [ ] Seed: `seed_test.sql` **only** on test; `bootstrap_admin.sql` on
       staging/prod.
3. [ ] Fill local env files from the committed `.env.example`s
       (`app/.env.test`, `web/.env.local`) — never commit them.
4. [ ] Repo secrets → `Actions`: `SUPABASE_URL_TEST/_STAGING/_PRODUCTION` +
       `ANON_KEY_*` (APK builds). The AI workflows need **no key** — they
       auto-pick the best available free OpenCode Zen model and fail over
       across all of them (optionally pin one via `OPENCODE_MODEL`).
5. [ ] Branch protection already on `main`/`staging` (PRs required).

## Stack

| Layer | Tech |
|---|---|
| Mobile | Flutter 3, Supabase Flutter, Riverpod |
| Web | Next.js 15, React 19, Tailwind v4 |
| Data | Supabase (PostgreSQL + RLS) |
| Auth | Supabase Auth, role-based |
| AI/Review | OpenCode V2 agents in GitHub Actions |

## Docs index

- [`CONTRIBUTING.md`](CONTRIBUTING.md) — how to contribute (PRs go to `develop` only!)
- [`docs/environments.md`](docs/environments.md) — environments, branches, seeding, CI, go-live
- [`docs/workflow.md`](docs/workflow.md) — issue → branch → PR → review → promote
- [`docs/ai-native-erp.md`](docs/ai-native-erp.md) — product vision
- [`docs/learning-roadmap.md`](docs/learning-roadmap.md) — build order
- [`web/README.md`](web/README.md) — web specifics

## Known follow-ups

- `v_student_subject_attendance` view is not class-scoped (percentages read
  lower than reality with seeded data) — see `docs/environments.md` §7.
