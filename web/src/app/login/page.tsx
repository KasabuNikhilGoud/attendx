"use client";

import { useRouter } from "next/navigation";
import Link from "next/link";
import { useState } from "react";
import { login } from "@/lib/data";
import { isDemoMode } from "@/lib/supabase";

const HINTS: { email: string; password: string; role: string }[] = [
  { email: "student@attendx.com", password: "student123", role: "Student" },
  { email: "faculty@attendx.com", password: "faculty123", role: "Faculty" },
  { email: "hod@attendx.com", password: "hod123", role: "HOD" },
  { email: "admin@attendx.com", password: "admin123", role: "Admin" },
];

export default function Login() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const { profile, error } = await login(email.trim(), password);
      if (!profile) {
        setError(error ?? "Sign in failed.");
        return;
      }
      router.replace("/dashboard");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-zinc-50 px-6">
      <div className="w-full max-w-md">
        <Link href="/" className="mb-8 flex items-center justify-center gap-2">
          <span className="flex h-11 w-11 items-center justify-center rounded-2xl bg-brand text-white">
            <svg viewBox="0 0 24 24" className="h-6 w-6" fill="currentColor">
              <path d="M12 3 2 8l10 5 8-4v6h2V8L12 3zM5 13.2V17c0 2.2 3.1 4 7 4s7-1.8 7-4v-3.8l-7 3.5-7-3.5z" />
            </svg>
          </span>
          <span className="text-2xl font-bold tracking-tight text-ink">AttendX</span>
        </Link>

        <div className="rounded-2xl border border-zinc-200 bg-white p-7 shadow-card">
          <h1 className="text-lg font-bold text-ink">Sign in</h1>
          <p className="mt-1 text-sm text-zinc-500">
            Use your AttendX account email and password.
          </p>

          {isDemoMode ? (
            <div className="mt-4 rounded-xl border border-amber-200 bg-amber-50 p-3 text-xs text-amber-800">
              <p className="font-semibold">DEMO MODE — no Supabase configured.</p>
              <p className="mt-1">
                Tap a role to prefill fake credentials (works offline / Codespaces):
              </p>
              <div className="mt-2 grid grid-cols-2 gap-2">
                {HINTS.map((h) => (
                  <button
                    key={h.role}
                    type="button"
                    onClick={() => {
                      setEmail(h.email);
                      setPassword(h.password);
                      setError(null);
                    }}
                    className="rounded-lg border border-amber-200 bg-white px-2 py-1.5 text-xs font-semibold text-amber-800 hover:bg-amber-100"
                  >
                    {h.role}
                  </button>
                ))}
              </div>
            </div>
          ) : null}

          <form onSubmit={submit} className="mt-5 space-y-4">
            <div>
              <label htmlFor="email" className="mb-1 block text-xs font-semibold text-zinc-600">
                Email
              </label>
              <input
                id="email"
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="student@attendx.com"
                className="w-full rounded-xl border border-zinc-200 px-3 py-2.5 text-sm outline-none transition focus:border-brand focus:ring-2 focus:ring-brand/20"
              />
            </div>
            <div>
              <label htmlFor="password" className="mb-1 block text-xs font-semibold text-zinc-600">
                Password
              </label>
              <input
                id="password"
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full rounded-xl border border-zinc-200 px-3 py-2.5 text-sm outline-none transition focus:border-brand focus:ring-2 focus:ring-brand/20"
              />
            </div>

            {error ? (
              <p className="rounded-xl border border-red-200 bg-brand-soft px-3 py-2 text-xs text-brand">
                {error}
              </p>
            ) : null}

            <button
              type="submit"
              disabled={busy}
              className="w-full rounded-xl bg-brand px-4 py-3 text-sm font-semibold text-white transition hover:bg-brand-dark disabled:opacity-60"
            >
              {busy ? "Signing in…" : "Sign in"}
            </button>
          </form>
        </div>

        <p className="mt-5 text-center text-xs text-zinc-400">
          Test env demo logins: role + 123 · docs/environments.md
        </p>
      </div>
    </div>
  );
}
