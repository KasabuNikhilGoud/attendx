"use client";

import { useEffect, useState } from "react";
import { fetchProfile, facultyToday } from "@/lib/data";
import type { SessionRow } from "@/lib/demo";
import { Card, ErrorNote, PageTitle, Stat, Table } from "@/components/ui";

export default function FacultyDashboard() {
  const [sessions, setSessions] = useState<SessionRow[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let alive = true;
    (async () => {
      try {
        const profile = await fetchProfile();
        if (!profile) return;
        const s = await facultyToday(profile.id);
        if (!alive) return;
        setSessions(s);
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

  if (loading) {
    return (
      <div className="flex min-h-[60vh] items-center justify-center text-sm text-zinc-500">
        Loading sessions…
      </div>
    );
  }

  const submitted = sessions.length > 0;

  return (
    <div>
      <PageTitle
        title="Today's Sessions"
        subtitle="Sessions assigned to you. Marking happens on mobile and syncs here (roadmap: v2)."
      />

      {error ? <div className="mb-4"><ErrorNote message={error} /></div> : null}

      <div className="grid gap-4 sm:grid-cols-3">
        <Stat label="Sessions today" value={sessions.length} />
        <Stat label="Classes" value={new Set(sessions.map((s) => s.class_name)).size} />
        <Stat label="Subjects" value={new Set(sessions.map((s) => s.subject_code)).size} />
      </div>

      <Card className="mt-4">
        <Table
          head={["Time", "Subject", "Class", "Date", "Marking"]}
          rows={sessions.map((s) => [
            `${s.start_time.slice(0, 5)} – ${s.end_time.slice(0, 5)}`,
            `${s.subject_name} (${s.subject_code})`,
            s.class_name,
            s.session_date,
            <span className="rounded-lg border border-zinc-200 px-2 py-1 text-xs text-zinc-500">
              {submitted ? "via mobile app" : "—"}
            </span>,
          ])}
        />
        {sessions.length === 0 ? (
          <p className="mt-2 text-sm text-zinc-500">No sessions scheduled for today.</p>
        ) : null}
      </Card>
    </div>
  );
}
