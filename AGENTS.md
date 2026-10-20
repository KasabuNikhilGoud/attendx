# AttendX — Agent Instructions (applies to every OpenCode session/agent)

AttendX = ERP attendance system. One codebase, three isolated environments.
Read `docs/environments.md` before doing anything environment-related.

## Repo map

```text
app/                 Flutter (mobile) — Dart, Riverpod, Supabase Flutter
  lib/core/config/   env loading (AppEnvConfig, EnvLoader, SupabaseService)
  lib/features/      role dashboards (student/faculty/hod/admin), splash…
  lib/**/*_mock_data.dart   offline demo datasets (parity with web demo!)
web/                 Next.js 15 + React 19 + Tailwind v4 (TypeScript, strict)
  src/lib/           supabase.ts (client) · data.ts (data layer) · demo.ts (fake data)
  src/app/dashboard/ role pages behind auth gate
supabase/            schema.sql (idempotent, RLS) + seed/ (seed_test.sql, bootstrap_admin.sql)
docs/                environments.md · workflow.md
.github/workflows/   quality.yml · build-app.yml · opencode.yml
```

## Environment & branch model (non-negotiable)

- `develop` → TEST Supabase (fake users) · `staging` → STAGING (schema only) ·
  `main` → PRODUCTION (real users).
- All work: branch from `develop` as `feat/<slug>` / `fix/<slug>` → PR into
  `develop` → promote via PRs `develop → staging → main`. Never write
  directly to `staging`/`main`.
- Every feature must work in **demo mode** (web `src/lib/demo.ts`) and/or be
  seedable in the **test DB** (`supabase/seed/seed_test.sql`) — a feature
  that only works against production data is not finished.
- Reference issues in PRs (`Closes #N`).

## Conventions

### web (TypeScript)
- Strict TS; no `any` leaks — normalize Supabase embeds (objects **or**
  arrays) with the `firstOf` helper in `src/lib/data.ts`.
- All data access goes through `src/lib/data.ts`; pages never touch
  `supabase` directly.
- Demo data must mirror `seed_test.sql` semantics (roles, email/password
  patterns, percentages).
- Tailwind v4: theme tokens via `@theme` in `src/app/globals.css`
  (`brand` red `#E53935`, `ink`); no hard-coded hex in components.

### app (Flutter/Dart)
- Keys come from `--dart-define` / bundled `.env` via `SupabaseService` —
  never hard-code URLs/keys.
- Env badge on splash must never appear in production.
- `flutter analyze` clean; add/extend tests in `app/test/`.

### supabase (SQL)
- Migrations/seeds must be **idempotent** (guard with `not exists` / `on
  conflict do nothing`).
- RLS stays enabled on every table; policies use `current_user_role()` /
  `is_staff()` helpers — new tables need policies in the same PR.
- `seed_test.sql` runs ONLY on the test project; `bootstrap_admin.sql` is the
  only seed allowed on staging/prod.

## Security rules (always)

1. Never commit secrets — `.env*` is gitignored; repo secrets live in GitHub
   Settings. Only `anon` keys belong in client code; **never** `service_role`.
2. Keep RLS: any new table/column exposing user data needs a policy check.
3. Render user data safely (no raw HTML injection; React escapes by default
   — don't use `dangerouslySetInnerHTML`).
4. Validate server-side assumptions even when the client checks first.
5. Report suspected vulnerabilities as a **security issue template**, not a
   public PR with details.

## Commits & PRs

- Commit subject: `area: short imperative summary` (e.g. `web: add rolling
  30-day attendance to student dashboard`).
- PR body: link the issue (`Closes #N`), 3-bullet what/why, screenshot for
  UI changes when possible.
- Before requesting review: `npm run build` (web) and `flutter test`
  (app) must pass locally.

## PR review output format (pr-reviewer agent)

Follow the exact structure defined in the agent file: Summary → What's good
→ Findings (🔴/🟠/🟡/🔵 with file:line) → Security & data → Tests → Verdict.
Findings must cite real code from the diff; no generic advice.
