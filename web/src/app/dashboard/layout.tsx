"use client";

import { useEffect, useState } from "react";
import { fetchProfile } from "@/lib/data";
import { DashboardShell } from "@/components/shell";
import type { Profile } from "@/lib/supabase";

/**
 * Auth gate: resolves the profile for the current session (live Supabase
 * or demo localStorage) and renders the dashboard shell around children.
 * Unauthenticated visitors are bounced to /login.
 */
export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const [profile, setProfile] = useState<Profile | null>(null);
  const [state, setState] = useState<"loading" | "ready">("loading");

  useEffect(() => {
    let alive = true;
    fetchProfile()
      .then((p) => {
        if (!alive) return;
        if (!p) {
          window.location.replace("/login");
          return;
        }
        setProfile(p);
        setState("ready");
      })
      .catch(() => {
        if (alive) window.location.replace("/login");
      });
    return () => {
      alive = false;
    };
  }, []);

  if (state !== "ready" || !profile) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-zinc-50">
        <div className="flex items-center gap-3 text-sm text-zinc-500">
          <span className="h-4 w-4 animate-spin rounded-full border-2 border-brand border-t-transparent" />
          Loading AttendX…
        </div>
      </div>
    );
  }

  return <DashboardShell profile={profile}>{children}</DashboardShell>;
}
