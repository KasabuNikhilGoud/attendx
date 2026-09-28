// Mirrors Supabase `profiles` + ERP core entities (single source of truth).
// Keep in sync with supabase/migrations/*.sql

export type UserRole = 'student' | 'faculty' | 'hod' | 'admin';

export interface Profile {
  id: string;
  email: string;
  full_name: string;
  role: UserRole;
  phone?: string | null;
  institution_id?: string | null;
  created_at?: string;
}

export interface Department {
  id: string;
  name: string;
  code: string;
  hod_id?: string | null;
}

export interface ClassSection {
  id: string;
  name: string;
  section: string;
  batch_year: string;
  department_id: string;
}

export interface Subject {
  id: string;
  name: string;
  code: string;
  department_id?: string | null;
  faculty_id?: string | null;
  semester?: number | null;
}

export type AttendanceStatus = 'present' | 'absent' | 'late';

export interface AttendanceSession {
  id: string;
  subject_id: string;
  class_id?: string | null;
  date: string;
  created_by?: string | null;
}

export interface AttendanceRecord {
  id: string;
  session_id?: string;
  student_id: string;
  status: AttendanceStatus;
  marked_at?: string;
}
