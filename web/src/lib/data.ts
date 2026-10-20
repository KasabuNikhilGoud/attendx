/**
 * DATA LAYER — one API for every dashboard page, two backends behind it:
 *   • live   : Supabase REST (RLS enforces role access),  when .env.local is set
 *   • demo   : built-in fake data (src/lib/demo.ts)       when it is not
 */
import {
  supabase,
  isDemoMode,
  type Profile,
  type Role,
} from "./supabase";
import {
  DEMO_COUNTS,
  DEMO_DEPT_SUMMARY,
  DEMO_FACULTY_TODAY,
  DEMO_RECEIVED_ALERTS,
  DEMO_RECENT_SESSIONS,
  DEMO_SUBJECT_REPORTS,
  DEMO_USERS,
  type DeptSummary,
  type RecentStat,
  type SessionRow,
  type SubjectReport,
} from "./demo";

const DEMO_SESSION_KEY = "attendx:demo-session";

/* ------------------------------------------------------------------ */
/* Auth                                                                */
/* ------------------------------------------------------------------ */

/** Sign in. Returns the profile, or an error message. */
export async function login(
  email: string,
  password: string
): Promise<{ profile: Profile | null; error?: string }> {
  if (isDemoMode || !supabase) {
    const hit = DEMO_USERS.find(
      (u) => u.email === email.toLowerCase() && u.password === password
    );
    if (!hit) return { profile: null, error: "Invalid demo credentials." };
    localStorage.setItem(DEMO_SESSION_KEY, hit.email);
    return { profile: hit.profile };
  }

  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });
  if (error) return { profile: null, error: error.message };

  const uid = data.user.id;
  const { data: profile, error: profileError } = await supabase
    .from("profiles")
    .select("id, email, full_name, role, department_id, roll_no, designation")
    .eq("id", uid)
    .single();

  if (profileError || !profile) {
    return { profile: null, error: "Signed in, but profile is missing. Is the user registered with a role?" };
  }
  return { profile: profile as Profile };
}

/** Current profile from the active session (live or demo). */
export async function fetchProfile(): Promise<Profile | null> {
  if (isDemoMode || !supabase) {
    const email = localStorage.getItem(DEMO_SESSION_KEY);
    if (!email) return null;
    return DEMO_USERS.find((u) => u.email === email)?.profile ?? null;
  }

  const { data: session } = await supabase.auth.getSession();
  const uid = session?.session?.user?.id;
  if (!uid) return null;

  const { data } = await supabase
    .from("profiles")
    .select("id, email, full_name, role, department_id, roll_no, designation")
    .eq("id", uid)
    .single();
  return (data as Profile) ?? null;
}

export async function logout(): Promise<void> {
  if (isDemoMode || !supabase) {
    localStorage.removeItem(DEMO_SESSION_KEY);
    return;
  }
  await supabase.auth.signOut();
}

/* ------------------------------------------------------------------ */
/* Reports                                                             */
/* ------------------------------------------------------------------ */

const validRole = (r: string): Role =>
  r === "student" || r === "faculty" || r === "hod" || r === "admin" ? (r as Role) : "student";

/** Per-subject attendance percentages for one student (all-time + 30-day rolling). */
export async function subjectReports(studentId: string): Promise<SubjectReport[]> {
  if (isDemoMode || !supabase) return DEMO_SUBJECT_REPORTS;

  const { data, error } = await supabase
    .from("v_student_subject_attendance")
    .select("subject_code, subject_name, attended, held, percent")
    .eq("student_id", studentId);
  if (error) throw new Error(error.message);

  const recent = await recentBySubject(studentId);
  return ((data ?? []) as SubjectReport[]).map((r) => ({
    ...r,
    recent: recent.get(r.subject_code),
  }));
}

/**
 * Rolling 30-day attendance per subject, computed from submitted
 * attendance_records (present + late count as attended).
 */
async function recentBySubject(studentId: string): Promise<Map<string, RecentStat>> {
  if (!supabase) return new Map();

  const since = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
    .toISOString()
    .slice(0, 10);

  const res = await supabase
    .from("attendance_records")
    .select(
      `status,
       session:session_id!inner ( session_date, subject:subject_id ( name, code ) )`
    )
    .eq("student_id", studentId)
    .gte("session.session_date", since);
  if (res.error) throw new Error(res.error.message);

  interface RawRollingRow {
    status: string;
    session: {
      session_date: string;
      subject: { name: string; code: string } | { name: string; code: string }[] | null;
    } | null;
  }

  const stats = new Map<string, { attended: number; held: number }>();
  for (const r of (res.data ?? []) as unknown as RawRollingRow[]) {
    const subject = firstOf<{ name: string; code: string }>(r.session?.subject);
    if (!subject?.code) continue;
    const cur = stats.get(subject.code) ?? { attended: 0, held: 0 };
    cur.held += 1;
    if (r.status === "present" || r.status === "late") cur.attended += 1;
    stats.set(subject.code, cur);
  }

  const map = new Map<string, RecentStat>();
  for (const [code, s] of stats) {
    map.set(code, {
      attended: s.attended,
      held: s.held,
      percent: s.held > 0 ? Math.round((s.attended * 1000) / s.held) / 10 : 0,
    });
  }
  return map;
}

/** PostgREST embeds can arrive as objects or arrays — normalize to one. */
const firstOf = <T>(v: unknown): T | null => {
  if (Array.isArray(v)) return (v[0] as T | undefined) ?? null;
  return (v as T | null) ?? null;
};

interface RawRecentRow {
  id: string;
  status: string;
  session: {
    session_date: string;
    start_time: string;
    end_time: string;
    subject: { name: string; code: string } | { name: string; code: string }[] | null;
    class: { name: string } | { name: string }[] | null;
  } | null;
}

/** Most recent attendance records for one student. */
export async function recentSessions(studentId: string): Promise<SessionRow[]> {
  if (isDemoMode || !supabase) return DEMO_RECENT_SESSIONS;

  const res = await supabase
    .from("attendance_records")
    .select(
      `id, status,
       session:session_id ( session_date, start_time, end_time,
         subject:subject_id ( name, code ),
         class:class_id ( name )
       )`
    )
    .eq("student_id", studentId)
    .order("created_at", { ascending: false })
    .limit(6);

  if (res.error) throw new Error(res.error.message);

  return ((res.data ?? []) as unknown as RawRecentRow[])
    .filter((r) => r.session)
    .map((r) => {
      const s = r.session!;
      const subject = firstOf<{ name: string; code: string }>(s.subject);
      const klass = firstOf<{ name: string }>(s.class);
      return {
        id: r.id,
        session_date: s.session_date,
        start_time: s.start_time,
        end_time: s.end_time,
        subject_name: subject?.name ?? "—",
        subject_code: subject?.code ?? "—",
        class_name: klass?.name ?? "—",
        status: validRowStatus(r.status),
      };
    });
}

const validRowStatus = (s: string): "present" | "absent" | "late" =>
  s === "present" || s === "absent" || s === "late" ? (s as "present" | "absent" | "late") : "absent";

/** Today's sessions of one faculty member. */
export async function facultyToday(facultyId: string): Promise<SessionRow[]> {
  if (isDemoMode || !supabase) return DEMO_FACULTY_TODAY;

  const today = new Date().toISOString().slice(0, 10);
  const { data, error } = await supabase
    .from("attendance_sessions")
    .select(
      `id, session_date, start_time, end_time,
       subject:subject_id ( name, code ),
       class:class_id ( name )`
    )
    .eq("faculty_id", facultyId)
    .gte("session_date", today)
    .order("session_date", { ascending: true });

  if (error) throw new Error(error.message);

  return ((data ?? []) as unknown as RawSessionRow[]).map((r) => {
    const subject = firstOf<{ name: string; code: string }>(r.subject);
    const klass = firstOf<{ name: string }>(r.class);
    return {
      id: r.id,
      session_date: r.session_date,
      start_time: r.start_time,
      end_time: r.end_time,
      subject_name: subject?.name ?? "—",
      subject_code: subject?.code ?? "—",
      class_name: klass?.name ?? "—",
      status: "present" as const,
    };
  });
}

interface RawSessionRow {
  id: string;
  session_date: string;
  start_time: string;
  end_time: string;
  subject: { name: string; code: string } | { name: string; code: string }[] | null;
  class: { name: string } | { name: string }[] | null;
}

/** Department attendance summary (HOD + admin). */
export async function deptSummaries(): Promise<DeptSummary[]> {
  if (isDemoMode || !supabase) return DEMO_DEPT_SUMMARY;

  const { data, error } = await supabase
    .from("v_department_summary")
    .select("department_name, total_sessions, total_present, total_absent, total_late, avg_attendance");
  if (error) throw new Error(error.message);
  return (data ?? []) as DeptSummary[];
}

/** Students below the 75% gate — HOD attention list (demo mirrors seed intent). */
export async function lowAttendanceStudents(): Promise<
  { student: string; class_name: string; percent: number }[]
> {
  if (isDemoMode || !supabase) {
    // see docs/environments.md §7 — view is class-unscoped; seeded low students
    // appear lower than reality here, data is illustrative.
    return DEMO_RECEIVED_ALERTS;
  }

  const { data, error } = await supabase
    .from("v_student_subject_attendance")
    .select("subject_code, subject_name, percent")
    .lt("percent", 75)
    .limit(20);
  if (error) throw new Error(error.message);

  return (data ?? []).map((r) => ({
    student: `${r.subject_code} · ${r.subject_name}`,
    class_name: "—",
    percent: r.percent ?? 0,
  }));
}

/** Simple counters for the admin overview. */
export async function adminCounts(): Promise<{
  students: number;
  faculty: number;
  classes: number;
  departments: number;
}> {
  if (isDemoMode || !supabase) return DEMO_COUNTS;

  const count = async (table: string, column?: string, value?: string) => {
    let q = supabase!.from(table).select("*", { count: "exact", head: true });
    if (column && value) q = q.eq(column, value);
    const { count, error } = await q;
    if (error) throw new Error(error.message);
    return count ?? 0;
  };

  const [students, faculty, classes, departments] = await Promise.all([
    count("profiles", "role", "student"),
    count("profiles", "role", "faculty"),
    count("classes"),
    count("departments"),
  ]);
  return { students, faculty, classes, departments };
}

/** Departments table for admin (schema seed guarantee: CS/IT/ECE). */
export async function adminDepartments(): Promise<
  { name: string; code: string; hod_id: string | null }[]
> {
  if (isDemoMode || !supabase) {
    const demo: { name: string; code: string; hod_id: string | null }[] = [
      { name: "Computer Science", code: "CS", hod_id: "demo-hod" },
      { name: "Information Technology", code: "IT", hod_id: null },
      { name: "Electronics", code: "ECE", hod_id: null },
    ];
    return demo;
  }

  const { data, error } = await supabase
    .from("departments")
    .select("name, code, hod_id")
    .order("name");
  if (error) throw new Error(error.message);
  return data ?? [];
}

// `Role` re-export keeps imports in pages consistent
export type { Role };
