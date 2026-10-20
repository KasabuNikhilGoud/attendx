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

  const held30 = reports.reduce((a, r) => a + (r.recent?.held ?? 0), 0);
  const attended30 = reports.reduce((a, r) => a + (r.recent?.attended ?? 0), 0);
  const overall30 = held30 > 0 ? Math.round((attended30 * 1000) / held30) / 10 : 0;

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
        <Stat
          label="Last 30 days"
          value={held30 > 0 ? `${overall30}%` : "—"}
          hint={held30 > 0 ? `${attended30} of ${held30} recent sessions` : "no recent sessions"}
        />
        <Stat label="Subjects" value={reports.length} />
      </div>

      <div className="mt-4 grid gap-4">
        {reports.map((r) => (
          <Card key={r.subject_code}>
            <div className="mb-2 flex items-center justify-between gap-3">
              <div>
                <p className="font-semibold text-ink">{r.subject_name}</p>
                <p className="text-xs text-zinc-500">{r.subject_code}</p>
              </div>
              <div className="flex items-center gap-2">
                {r.recent ? (
                  <Badge tone={r.recent.percent >= 75 ? "green" : r.recent.percent >= 60 ? "amber" : "red"}>
                    30d {arrow(r.recent.percent - r.percent)} {r.recent.percent}%
                  </Badge>
                ) : null}
                <Badge tone={r.percent >= 75 ? "green" : r.percent >= 60 ? "amber" : "red"}>
                  {Math.round(r.percent * 10) / 10}%
                </Badge>
              </div>
            </div>
            <PercentBar percent={r.percent} />
            <p className="mt-2 text-xs text-zinc-500">
              attended {r.attended} of {r.held} held sessions
              {r.recent ? ` · ${r.recent.attended}/${r.recent.held} in the last 30 days` : ""}
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

/** Trend arrow: 30-day vs all-time. */
function arrow(delta: number): string {
  if (delta >= 1) return "↑";
  if (delta <= -1) return "↓";
  return "→";
}
