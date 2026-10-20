"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { LogOut, UserCircle2 } from "lucide-react";
import type { Profile } from "@/lib/supabase";
import { logout } from "@/lib/data";
import { Badge } from "./ui";

const NAV: Record<string, { href: string; label: string }[]> = {
  student: [
    { href: "/dashboard/student", label: "My Attendance" },
    { href: "/dashboard/student", label: "Subjects" },
  ],
  faculty: [{ href: "/dashboard/faculty", label: "Today's Sessions" }],
  hod: [{ href: "/dashboard/hod", label: "Department" }],
  admin: [{ href: "/dashboard/admin", label: "Overview" }],
};

export function DashboardShell({
  profile,
  children,
}: {
  profile: Profile;
  children: React.ReactNode;
}) {
  const router = useRouter();

  const onLogout = async () => {
    await logout();
    router.replace("/login");
  };

  return (
    <div className="flex min-h-screen bg-zinc-50">
      {/* Sidebar */}
      <aside className="hidden w-60 shrink-0 border-r border-zinc-200 bg-white px-4 py-6 md:block">
        <Link href="/" className="flex items-center gap-2 px-2">
          <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-brand text-white">
            <svg viewBox="0 0 24 24" className="h-5 w-5" fill="currentColor">
              <path d="M12 3 2 8l10 5 8-4v6h2V8L12 3zM5 13.2V17c0 2.2 3.1 4 7 4s7-1.8 7-4v-3.8l-7 3.5-7-3.5z" />
            </svg>
          </span>
          <span className="text-lg font-bold tracking-tight text-ink">AttendX</span>
        </Link>

        <nav className="mt-8 space-y-1">
          {(NAV[profile.role] ?? []).map((item, i) => (
            <a
              key={`${item.label}-${i}`}
              href={item.href}
              className="block rounded-xl px-3 py-2 text-sm font-medium text-zinc-600 transition hover:bg-zinc-100 hover:text-ink"
            >
              {item.label}
            </a>
          ))}
        </nav>

        {profile.role !== "student" ? (
          <p className="mt-10 px-3 text-[11px] font-semibold uppercase tracking-wider text-zinc-400">
            {profile.designation ?? profile.role.toUpperCase()}
          </p>
        ) : null}
      </aside>

      {/* Main */}
      <div className="flex min-w-0 flex-1 flex-col">
        <header className="flex items-center justify-between border-b border-zinc-200 bg-white px-5 py-3">
          <div className="flex items-center gap-2 text-sm font-semibold text-ink md:hidden">
            AttendX
          </div>
          <div className="ml-auto flex items-center gap-3">
            <Badge tone={profile.role === "admin" ? "red" : "blue"}>
              {profile.role.toUpperCase()}
            </Badge>
            <span className="hidden text-sm text-zinc-600 sm:inline">
              <UserCircle2 className="mr-1 -mt-0.5 inline h-4 w-4" />
              {profile.full_name}
            </span>
            <button
              onClick={onLogout}
              className="inline-flex items-center gap-1 rounded-xl border border-zinc-200 px-3 py-1.5 text-sm text-zinc-600 transition hover:border-red-200 hover:bg-brand-soft hover:text-brand"
            >
              <LogOut className="h-4 w-4" /> Out
            </button>
          </div>
        </header>
        <main className="flex-1 overflow-y-auto p-5 md:p-8">{children}</main>
      </div>
    </div>
  );
}
