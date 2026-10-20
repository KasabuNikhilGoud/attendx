"use client";

import { useEffect, useState } from "react";
import { fetchProfile, recentSessions, subjectReports } from "@/lib/data";
import type { SubjectReport } from "@/lib/demo";
import type { SessionRow } from "@/lib/demo";
import { Badge, Card, ErrorNote, PageTitle, PercentBar, Stat, statusBadgeTone, Table } from "@/components/ui";

export default function StudentDashboard() {
  const [reports, setReports] = useState<SubjectReport[]>([]);
  const [rows, setRows] = useState<SessionRow[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let alive = true;
    (async () => {
      try {
        const profile = await fetchProfile();
        if (!profile) return;
        const [r, s] = await Promise.all([
          subjectReports(profile.id),
          recentSessions(profile.id),
        ]);
        if (!alive) return;
        setReports(r);
        setRows(s);
      } catch (e) {
        if (alive) setError(String(e instanceof Error ? e.message : e));
      } finally {
        if (alive) setLoading(false);
      }
    })();
    return () => {
      alive = false;
    };
  }, []);

  const held = reports.reduce((a, r) => a + r.held, 0);
  const attended = reports.reduce((a, r) => a + r.attended, 0);
  const overall = held > 0 ? Math.round((attended * 1000) / held) / 10 : 0;
  const flagged = reports.filter((r) => r.percent < 75);

  if (loading) return <Loading />;

  return (
    <div>
      <PageTitle
        title="My Attendance"
        subtitle="Per-subject percentages, counted from submitted sessions only."
      />

      {error ? <div className="mb-4"><ErrorNote message={error} /></div> : null}

      {flagged.length > 0 ? (
        <div className="mb-4 rounded-2xl border border-red-200 bg-brand-soft p-4 text-sm text-brand">
          ⚠ Below the 75% gate in {flagged.length} subject
          {flagged.length > 1 ? "s" : ""} ({flagged.map((f) => f.subject_code).join(", ")}) —
          the attendance-alert workflow will notify you.
        </div>
      ) : null}

      <div className="grid gap-4 sm:grid-cols-3">
        <Stat label="Overall" value={`${overall}%`} hint={`${attended} of ${held} sessions`} />
        <Stat label="Subjects" value={reports.length} />
        <Stat label="Gate" value={overall >= 75 ? "Clear" : "At risk"} hint="75% minimum required" />
      </div>

      <div className="mt-4 grid gap-4">
        {reports.map((r) => (
          <Card key={r.subject_code}>
            <div className="mb-2 flex items-center justify-between">
              <div>
                <p className="font-semibold text-ink">{r.subject_name}</p>
                <p className="text-xs text-zinc-500">{r.subject_code}</p>
              </div>
              <Badge tone={r.percent >= 75 ? "green" : r.percent >= 60 ? "amber" : "red"}>
                {Math.round(r.percent * 10) / 10}%
              </Badge>
            </div>
            <PercentBar percent={r.percent} />
            <p className="mt-2 text-xs text-zinc-500">
              attended {r.attended} of {r.held} held sessions
            </p>
          </Card>
        ))}
      </div>

      <Card className="mt-4">
        <h2 className="mb-3 text-sm font-semibold uppercase tracking-wider text-zinc-500">
          Recent sessions
        </h2>
        <Table
          head={["Date", "Time", "Subject", "Class", "Status"]}
          rows={rows.map((s) => [
            s.session_date,
            `${s.start_time.slice(0, 5)} – ${s.end_time.slice(0, 5)}`,
            `${s.subject_name}`,
            s.class_name,
            <Badge tone={statusBadgeTone(s.status)}>{s.status}</Badge>,
          ])}
        />
      </Card>
    </div>
  );
}

function Loading() {
  return (
    <div className="flex min-h-[60vh] items-center justify-center text-sm text-zinc-500">
      Loading attendance…
    </div>
  );
}
