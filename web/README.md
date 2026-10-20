# AttendX Web — Next.js dashboard

Web counterpart of the Flutter app: role dashboards (student / faculty /
HOD / admin) over the same Supabase data.

- **Zero-config DEMO MODE** — with no env configured, the site runs on
  built-in fake data (mirrors `supabase/seed/seed_test.sql`), so it works
  anywhere including GitHub Codespaces.
- **Live mode** — set Supabase env and every page hits the real backend
  (auth + RLS-protected queries).

## Run (local or Codespaces)

```bash
cd web
npm install
npm run dev          # http://localhost:3000
```

Optional live mode:

```bash
cp .env.example .env.local   # then paste Supabase URL + anon key
npm run dev
```

In Codespaces the port-3000 panel opens automatically (see
`.devcontainer/devcontainer.json`).

## Demo logins (DEMO MODE = same credentials as the test project)

| Role    | Email                  | Password    |
|---|---|---|
| Student | `student@attendx.com`  | `student123` |
| Faculty | `faculty@attendx.com`  | `faculty123` |
| HOD     | `hod@attendx.com`      | `hod123`     |
| Admin   | `admin@attendx.com`    | `admin123`   |

The login page prefills these with one tap in demo mode.

## Structure

```text
web/src/
├── app/
│   ├── page.tsx               landing (shows DEMO / CONNECTED banner)
│   ├── login/                 email+password sign in (live or demo)
│   └── dashboard/
│       ├── layout.tsx         auth gate + sidebar shell
│       ├── page.tsx           role-based redirect
│       ├── student/           %, per-subject bars, recent sessions
│       ├── faculty/           today's sessions
│       ├── hod/               department summary + <75% watchlist
│       └── admin/             institute counters + departments
├── components/                ui primitives + DashboardShell
└── lib/
    ├── supabase.ts            client factory + config detection
    ├── data.ts                one API: live queries OR demo fallback
    └── demo.ts                fake data (mirror of seed_test.sql)
```

## Stacks / diligence

- Next 15.5.28 (React 19), Tailwind v4 (CSS-first `@theme` tokens,
  brand red `#E53935` matching the Flutter app), lucide-react icons.
- `npm audit` clean at time of writing (postcss pinned via overrides).
- Environments remain branch-driven: see `docs/environments.md`.
