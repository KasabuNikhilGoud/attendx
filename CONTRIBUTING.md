# Contributing to AttendX

Welcome! The whole project runs **issue-driven** with **AI-reviewed pull
requests**. Read this before opening your first PR.

## The one rule that matters most

> **All pull requests go into `develop` (the TEST branch).**
>
> **Nobody — ever — opens a PR directly into `main` (production).** `main`
> only moves through the promotion chain after a validated staging run.

```text
your branch ──PR──> develop (TEST) ──PR──> staging ──PR──> main (PROD)
                                   you never touch these two directly
```

## The full cycle

1. **Issue first** — open an issue (✨ feature / 🐞 bug / 🔐 security
   template). The **OpenCode bot comments automatically** with a clarity
   check, work plan and suggested branch name — no API key or setup needed
   (it runs on a free model).
2. **Branch from `develop`**
   ```bash
   git checkout develop && git pull
   git checkout -b feat/your-slug
   ```
3. **Build it** — follow `AGENTS.md` conventions. Web changes must also
   work in demo mode (`web/src/lib/demo.ts`). Verify:
   `cd web && npm run build` ✓ / `cd app && flutter test` ✓
4. **PR into `develop`** — link the issue (`Closes #N`). Then:
   - CI (`quality.yml`) runs tests + build — must be green.
   - The **OpenCode bot reviews your diff** and posts findings
     (🔴 must-fix / 🟠 should-fix / 🟡 consider / 🔵 nit) with `file:line`
     references, plus a security pass/fail and a verdict. Fix 🔴/🟠 items
     and push again — review re-runs automatically.
   - When CI + review are clean → merge.
5. **Promotion (maintainers)** — `develop → staging` PR, verify, then
   `staging → main` PR. Production releases are tags (`vX.Y.Z`) on `main`.

## Working from a second GitHub account

- The repo owner adds the account as a **collaborator**
  (Settings → Collaborators), then that account pushes branches **to this
  same repo** and opens PRs into `develop`.
- Same-repo PRs let the AI bot post review comments on them. (Fork PRs run
  CI fine, but the bot may be unable to comment there — prefer
  collaborator branches.)
- The owner account reviews/maintains; the bot reviews every PR regardless
  of author.

## Ground rules

- Never commit secrets (`.env*` is ignored; only `.env.example` files exist).
- Every new Supabase table ships with RLS policies in the same PR.
- Demo data (`web/src/lib/demo.ts`) must mirror `seed_test.sql` semantics.
- Commit subjects: `area: short imperative summary` (e.g. `web: add …`).

Full docs: [`docs/workflow.md`](docs/workflow.md) ·
[`docs/environments.md`](docs/environments.md)
