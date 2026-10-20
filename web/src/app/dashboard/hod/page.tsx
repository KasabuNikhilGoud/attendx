"use client";

import { useEffect, useState } from "react";
import { deptSummaries, lowAttendanceStudents } from "@/lib/data";
import type { DeptSummary } from "@/lib/demo";
import { Badge, Card, ErrorNote, PageTitle, PercentBar, Stat, Table } from "@/components/ui";

export default function HodDashboard() {
  const [departments, setDepartments] = useState<DeptSummary[]>([]);
  const [alerts, setAlerts] = useState<{ student: string; class_name: string; percent: number }[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let alive = true;
    (async () => {
      try {
        const [d, a] = await Promise.all([deptSummaries(), lowAttendanceStudents()]);
        if (!alive) return;
        setDepartments(d);
        setAlerts(a);
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
        Loading department summary…
      </div>
    );
  }

  const overall = departments.length
    ? Math.round((departments.reduce((a, d) => a + d.avg_attendance, 0) / departments.length) * 10) / 10
    : 0;

  return (
    <div>
      <PageTitle
        title="Department Overview"
        subtitle="Attendance across the department, classes and the <75% watchlist."
      />

      {error ? <div className="mb-4"><ErrorNote message={error} /></div> : null}

      <div className="grid gap-4 sm:grid-cols-3">
        <Stat label="Avg attendance" value={`${overall}%`} hint="all departments shown" />
        <Stat label="Sessions held" value={departments.reduce((a, d) => a + d.total_sessions, 0)} />
        <Stat label="Watchlist" value={alerts.length} hint="below 75% threshold" />
      </div>

      <div className="mt-4 grid gap-4">
        {departments.map((d) => (
          <Card key={d.department_name}>
            <div className="mb-2 flex items-center justify-between">
              <p className="font-semibold text-ink">{d.department_name}</p>
              <Badge tone={d.avg_attendance >= 75 ? "green" : "amber"}>
                {d.avg_attendance}%
              </Badge>
            </div>
            <PercentBar percent={d.avg_attendance} />
            <p className="mt-2 text-xs text-zinc-500">
              {d.total_sessions} sessions · {d.total_present} present · {d.total_absent} absent · {d.total_late} late
            </p>
          </Card>
        ))}
      </div>

      <Card className="mt-4">
        <h2 className="mb-3 text-sm font-semibold uppercase tracking-wider text-zinc-500">
          Low attendance watchlist (&lt;75%)
        </h2>
        <Table
          head={["Subject / Student", "Class", "Percent"]}
          rows={alerts.map((a) => [
            a.student,
            a.class_name,
            <Badge tone="red">{a.percent}%</Badge>,
          ])}
        />
        {alerts.length === 0 ? (
          <p className="text-sm text-zinc-500">Nobody below the gate. 🎉</p>
        ) : null}
      </Card>
    </div>
  );
}
