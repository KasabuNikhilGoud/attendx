# How We Build — Issue → Branch → PR → Review → Promote

Every change starts as a **clear issue** and ships through the environment
pipeline. OpenCode AI (`opencode.yml`) helps at two points: it analyzes new
issues and reviews every pull request.

## The full cycle (example: "new attendance percentage in the student dashboard")

### 1. Create the issue (always first)

GitHub → Issues → **✨ Feature request** → fill in:

- **Feature summary** — "Add a rolling 30-day attendance percentage to the
  student dashboard so students see their recent trend, not just all-time."
- **What exactly to build** — bullets of the concrete behaviour.
- **Where it lives** — web / app / both / supabase.
- **Environment plan** — demo-mode data updated? seed covers it? nothing new
  seeded to staging/prod?
- **Acceptance criteria** — checkable bullets.

On posting, the **`OpenCode AI → issue-triage`** job comments with: clarity
check, scope, proposed plan, suggested branch name, environment plan,
security notes and acceptance criteria. Fix anything it flags as unclear
*in the issue* before writing code.

### 2. Work branch (from `develop`)

```bash
git checkout develop && git pull
git checkout -b feat/student-attendance-percentages
```

### 3. Build it (rules)

- Implement in `web`/`app` following `AGENTS.md` conventions.
- **Demo parity**: update `web/src/lib/demo.ts` (and/or
  `supabase/seed/seed_test.sql`) so the feature is testable with fake data.
- Verify: `cd web && npm run build` ✓ and/or `cd app && flutter test` ✓.

### 4. Pull request into `develop`

```bash
git push -u origin feat/student-attendance-percentages
# GitHub → New PR → base: develop
```

- Body links the work: `Closes #<issue number>`.
- CI (`quality.yml`) runs `flutter test` + `next build` — must be green.
- **`OpenCode AI → pr-review`** posts a structured review: findings by
  severity (🔴🟠🟡🔵 with `file:line`), security pass/fail, test notes and a
  verdict. Fix 🔴/🟠 findings, push again — review re-runs automatically.
- Merge when CI + review are clean.

> After merging into `develop`, CI builds the **TEST APK** (fake-data env)
> and the issue auto-closes via `Closes #N`.

### 5. Promote: test → main/staging → production

1. PR `develop → staging` — CI gates it; merge. STAGING APK builds.
2. Verify on the staging deployment (complete app, no user data).
3. PR `staging → main` — merge.
4. Tag the release: `git tag v1.2.0 && git push origin v1.2.0` → CI builds
   the **production APK** and publishes a GitHub Release.

Production only ever moves by tags after a validated staging run.

### 6. Hotfix path (production is broken)

`hotfix/<slug>` from `main` → PR into `main` → tag a patch version →
merge `main` back into `develop` so the fix is not lost.

---

## OpenCode integration cheat-sheet

| What | Where | Trigger |
|---|---|---|
| Issue analysis report | `.opencode/agents/issue-triage.md` | new issue → `opencode.yml` job `issue-triage` |
| Structured PR review | `.opencode/agents/pr-reviewer.md` | PR opened/updated → job `pr-review` |
| Weekly vulnerability/static/secret audit | job `security-audit` | cron Mon 03:00 UTC or manual `workflow_dispatch` → comments on the "🔐 Security audit tracker" issue |
| Project rules for every agent | `AGENTS.md` + `opencode.json` | always |
| Manual AI help locally | run `opencode` in the repo | CLI (free models included) |

**No setup needed** — the default model is a **free OpenCode Zen model**
(`opencode/glm-5.3-flash-free`, keyless). Optionally set the
`OPENCODE_MODEL` repo secret to use another model (with its provider key
for premium ones).
