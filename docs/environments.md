# AttendX — Company-Level Environments & Branches

One codebase → three isolated deployments. Each environment has its own
Supabase project (own database, own auth, own data) while the app binary is
identical apart from compile-time env config (`--dart-define` / `.env`).

| Env | Branch | Supabase project | Database content | Purpose |
|---|---|---|---|---|
| **Test** | `develop` | `attendx-test` | schema + `seed_test.sql` fake users/data | Daily dev, experiments, QA. Free to break and re-seed. |
| **Main / Staging** | `staging` | `attendx-staging` | schema only + `bootstrap_admin.sql` | Release rehearsal — complete app, **no user data**. |
| **Production** | `main` | `attendx-prod` | schema + **real users & data** | Live system for the institute. Never deploy directly. |

---

## 1. Branch model

```text
main        ← production releases only (protected)
staging     ← release candidates checked here (protected)
develop     ← default working/integration branch
feature/*   ← branch from develop, PR back into develop
bugfix/*    ← fixes found in test env (→ develop)
hotfix/*    ← production emergencies: branch from main, PR into main,
              then merge main into staging + develop
release/*   ← optional stabilization branch staging→main
```

### Promotion flow

```text
feature/* → PR → develop        (CI: flutter test)
develop  → PR → staging         (CI: flutter test + staging APK)
staging  → tag vX.Y.Z + PR → main   (CI: production release APK)
```

A tag on `main` (e.g. `v1.1.0`) is what releases to production — the
production job builds the release APK and attaches it to a GitHub Release.

---

## 2. Running the app locally

```bash
cd app
flutter pub get

flutter run --dart-define-from-file=.env.test        # TEST world (fake users)
flutter run --dart-define-from-file=.env.staging     # STAGING world (no users)
flutter run --dart-define-from-file=.env.production  # PROD  (fill keys first)

flutter run                                          # plain dev → uses bundled .env
```

The splash screen shows which world you are on:
`TEST DATABASE` (amber) · `STAGING` (blue) · `DEMO MODE` (offline build) ·
production shows **no badge on purpose** (never label the real thing as such).

`.env*` files are gitignored — only `.env.example` is committed.
Secrets never enter git; they reach CI through repo *secrets* and local runs
through your local files.

---

## 3. Supabase setup (one-time per environment)

For **each** new project (`attendx-test`, `attendx-staging`; your current
project becomes `attendx-prod`):

1. Supabase Dashboard → New project → free plan, region near you.
2. **SQL Editor → New query →** paste `supabase/schema.sql` → **Run**.
3. Content step differs per environment:
   - **test** → paste `supabase/seed/seed_test.sql` → Run
     (creates 43 fake accounts, classes, subjects, ~30 days of attendance;
      one chronic-absentee student per class to demo <75% alerts).
   - **staging / prod** → paste `supabase/seed/bootstrap_admin.sql` only
     (single admin account; **never** run `seed_test.sql` there).
4. **Settings → API** → copy `Project URL` + `anon public` key into the
   matching local file: `app/.env.test` / `app/.env.staging` / `app/.env.production`.

> Re-seeding the test data: delete users in Dashboard → Authentication → Users
> (or truncate `attendance_records`, `attendance_sessions`, `enrollments`,
> `subjects`, `classes`, `profiles`, `departments`), then re-run
> `schema.sql` + `seed_test.sql`.

---

## 4. Demo credentials (test environment only)

| Role | Email | Password |
|---|---|---|
| Admin | `admin@attendx.com` | `admin123` |
| HOD (CS) | `hod@attendx.com` | `hod123` |
| HOD (IT) | `hod.it@attendx.com` | `hod123` |
| HOD (ECE) | `hod.ece@attendx.com` | `hod123` |
| Faculty (CS) | `faculty@attendx.com` | `faculty123` |
| Student (CS 2-A) | `student@attendx.com` | `student123` |

Extra fake users follow the patterns:
`cs.faculty2@attendx.com`, `it.faculty1@attendx.com`,
`cs24a002@student.attendx.com`, `it24a003@…`, `ece23a004@…`
(passwords `hod123` / `faculty123` / `student123` by role).

---

## 5. CI/CD (GitHub Actions)

| Workflow | Trigger | Effect |
|---|---|---|
| `quality.yml` | PR → develop/staging/main | `flutter test` must pass to merge |
| `build-app.yml` | push `develop` | test-gate + release APK (TEST env) as artifact `attendx-test-apk` |
| 〃 | push `staging` | test-gate + release APK (STAGING env) as artifact `attendx-staging-apk` |
| 〃 | tag `v*` | test-gate + production APK attached to a GitHub Release |

Configure once: **Repo → Settings → Secrets and variables → Actions**, add:

```
SUPABASE_URL_TEST, SUPABASE_ANON_KEY_TEST
SUPABASE_URL_STAGING, SUPABASE_ANON_KEY_STAGING
SUPABASE_URL_PRODUCTION, SUPABASE_ANON_KEY_PRODUCTION
```

(Missing secrets are safe: the build falls back to offline demo mode.)

### Branch protection (recommended)

Repo → Settings → Branches → Add rule:

- `main`  → require PR, 1 approval, blocks force push/deletion.
- `staging` → require PR, blocks force push/deletion.

---

## 6. Production go-live checklist

1. [ ] `attendx-prod` project created; `schema.sql` + `bootstrap_admin.sql` applied.
2. [ ] Admin password rotated (Supabase Auth → Users → admin@).
3. [ ] Real accounts provisioned (sitewide signup enabled or imported by admin).
4. [ ] GitHub secrets for production filled; tag `v1.0.0` on `main` → release APK.
5. [ ] APK distributed (Play Store / MDM / direct APK).
6. [ ] Database backups observed (Dashboard → Database → Backups).
7. [ ] Spike-check: email (Edge Functions/Resend) works from prod domain.
8. [ ] `docs/environments.md` + README keep matching reality.

---

## 7. Known issue (tracked)

`v_student_subject_attendance` counts sessions of **all** classes for a
subject (the left join isn't scoped by the student's class), so seeded
per-class attendance percentages read lower than reality. Seed data still
demonstrates the full pipeline; the view needs a class-scope fix in a
follow-up PR (target `develop`).
