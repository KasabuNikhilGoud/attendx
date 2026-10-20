"use client";

import { useEffect, useState } from "react";
import { adminCounts, adminDepartments, deptSummaries } from "@/lib/data";
import type { DeptSummary } from "@/lib/demo";
import { Badge, Card, ErrorNote, PageTitle, PercentBar, Stat, Table } from "@/components/ui";

export default function AdminDashboard() {
  const [counts, setCounts] = useState({ students: 0, faculty: 0, classes: 0, departments: 0 });
  const [departments, setDepartments] = useState<{ name: string; code: string; hod_id: string | null }[]>([]);
  const [summaries, setSummaries] = useState<DeptSummary[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let alive = true;
    (async () => {
      try {
        const [c, d, s] = await Promise.all([adminCounts(), adminDepartments(), deptSummaries()]);
        if (!alive) return;
        setCounts(c);
        setDepartments(d);
        setSummaries(s);
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
        Loading overview…
      </div>
    );
  }

  return (
    <div>
      <PageTitle
        title="Admin Overview"
        subtitle="Institute-wide counters, departments and attendance health."
      />

      {error ? <div className="mb-4"><ErrorNote message={error} /></div> : null}

      <div className="grid gap-4 sm:grid-cols-4">
        <Stat label="Students" value={counts.students} />
        <Stat label="Faculty" value={counts.faculty} />
        <Stat label="Classes" value={counts.classes} />
        <Stat label="Departments" value={counts.departments} />
      </div>

      <div className="mt-4 grid gap-4 lg:grid-cols-2">
        <Card>
          <h2 className="mb-3 text-sm font-semibold uppercase tracking-wider text-zinc-500">
            Departments
          </h2>
          <Table
            head={["Name", "Code", "HOD assigned"]}
            rows={departments.map((d) => [
              d.name,
              d.code,
              d.hod_id ? <Badge tone="green">assigned</Badge> : <Badge tone="amber">none yet</Badge>,
            ])}
          />
        </Card>

        <Card>
          <h2 className="mb-3 text-sm font-semibold uppercase tracking-wider text-zinc-500">
            Attendance health
          </h2>
          <div className="space-y-4">
            {summaries.map((d) => (
              <div key={d.department_name}>
                <div className="mb-1 flex items-center justify-between text-sm">
                  <span className="font-medium text-ink">{d.department_name}</span>
                  <span className="text-zinc-500">{d.avg_attendance}%</span>
                </div>
                <PercentBar percent={d.avg_attendance} />
              </div>
            ))}
          </div>
        </Card>
      </div>
    </div>
  );
}
