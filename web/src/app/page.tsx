import Link from "next/link";
import { isDemoMode } from "@/lib/supabase";

const features = [
  { title: "Role dashboards", body: "Student, Faculty, HOD and Admin views with role-aware access via Supabase RLS." },
  { title: "Subject attendance", body: "Percentages per subject, held vs attended counts and <75% alert workflows." },
  { title: "Departments & classes", body: "CS / IT / ECE setup with classes, subjects and faculty assignment." },
  { title: "One codebase, three worlds", body: "Test (fake users), staging (no users) and production (real users) via env config." },
];

export default function Landing() {
  return (
    <div className="min-h-screen bg-white">
      {/* Nav */}
      <header className="mx-auto flex max-w-6xl items-center justify-between px-6 py-5">
        <div className="flex items-center gap-2">
          <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-brand text-white">
            <svg viewBox="0 0 24 24" className="h-5 w-5" fill="currentColor">
              <path d="M12 3 2 8l10 5 8-4v6h2V8L12 3zM5 13.2V17c0 2.2 3.1 4 7 4s7-1.8 7-4v-3.8l-7 3.5-7-3.5z" />
            </svg>
          </span>
          <span className="text-lg font-bold tracking-tight text-ink">AttendX</span>
        </div>
        <Link
          href="/login"
          className="rounded-xl bg-brand px-4 py-2 text-sm font-semibold text-white transition hover:bg-brand-dark"
        >
          Sign in
        </Link>
      </header>

      {/* Hero */}
      <section className="mx-auto max-w-6xl px-6 pb-20 pt-14 text-center md:pt-24">
        {isDemoMode ? (
          <p className="mx-auto mb-6 inline-flex items-center gap-2 rounded-full border border-amber-200 bg-amber-50 px-3 py-1 text-xs font-semibold text-amber-700">
            DEMO MODE · built-in fake data — add web/.env.local to connect Supabase
          </p>
        ) : (
          <p className="mx-auto mb-6 inline-flex items-center gap-2 rounded-full border border-emerald-200 bg-emerald-50 px-3 py-1 text-xs font-semibold text-emerald-700">
            CONNECTED · live Supabase backend
          </p>
        )}
        <h1 className="mx-auto max-w-3xl text-balance text-4xl font-bold leading-tight tracking-tight text-ink md:text-6xl">
          Attendance that runs itself.
        </h1>
        <p className="mx-auto mt-5 max-w-2xl text-lg text-zinc-600">
          ERP-class attendance platform: subject/session records, role dashboards,
          department reports and offline-first mobile — one source of truth in
          PostgreSQL (Supabase).
        </p>
        <div className="mt-8 flex items-center justify-center gap-3">
          <Link
            href="/login"
            className="rounded-xl bg-brand px-6 py-3 text-sm font-semibold text-white transition hover:bg-brand-dark"
          >
            Open dashboards
          </Link>
          <Link
            href="https://github.com/KasabuNikhilGoud/attendx"
            className="rounded-xl border border-zinc-200 px-6 py-3 text-sm font-semibold text-zinc-700 transition hover:bg-zinc-50"
          >
            View repo
          </Link>
        </div>
      </section>

      {/* Features */}
      <section className="border-t border-zinc-100 bg-zinc-50 py-16">
        <div className="mx-auto grid max-w-6xl gap-4 px-6 sm:grid-cols-2">
          {features.map((f) => (
            <div
              key={f.title}
              className="rounded-2xl border border-zinc-200 bg-white p-6 shadow-card"
            >
              <h2 className="text-base font-semibold text-ink">{f.title}</h2>
              <p className="mt-2 text-sm text-zinc-600">{f.body}</p>
            </div>
          ))}
        </div>
      </section>

      <footer className="border-t border-zinc-100 py-8 text-center text-xs text-zinc-400">
        AttendX · AI-Native ERP Attendance · docs/environments.md explains all three worlds
      </footer>
    </div>
  );
}
