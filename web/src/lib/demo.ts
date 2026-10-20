/**
 * DEMO DATA — mirrors supabase/seed/seed_test.sql so the web app is fully
 * testable with zero configuration (GitHub Codespaces, no Supabase keys).
 * Replaced 1:1 by live queries in src/lib/data.ts once .env.local is set.
 */
import type { Profile } from "./supabase";

export interface DemoUser {
  email: string;
  password: string;
  profile: Profile;
}

export const DEMO_USERS: DemoUser[] = [
  {
    email: "student@attendx.com",
    password: "student123",
    profile: {
      id: "demo-student",
      email: "student@attendx.com",
      full_name: "Rahul Sharma",
      role: "student",
      department_id: "demo-cs",
      roll_no: "CS24A001",
      designation: null,
    },
  },
  {
    email: "faculty@attendx.com",
    password: "faculty123",
    profile: {
      id: "demo-faculty",
      email: "faculty@attendx.com",
      full_name: "Prof. Ramesh Kumar",
      role: "faculty",
      department_id: "demo-cs",
      roll_no: null,
      designation: "Assistant Professor",
    },
  },
  {
    email: "hod@attendx.com",
    password: "hod123",
    profile: {
      id: "demo-hod",
      email: "hod@attendx.com",
      full_name: "Dr. Anita Patel",
      role: "hod",
      department_id: "demo-cs",
      roll_no: null,
      designation: "Head of Department",
    },
  },
  {
    email: "admin@attendx.com",
    password: "admin123",
    profile: {
      id: "demo-admin",
      email: "admin@attendx.com",
      full_name: "System Administrator",
      role: "admin",
      department_id: "demo-cs",
      roll_no: null,
      designation: "System Administrator",
    },
  },
];

export interface SubjectReport {
  subject_code: string;
  subject_name: string;
  attended: number;
  held: number;
  percent: number;
}

export const DEMO_SUBJECT_REPORTS: SubjectReport[] = [
  { subject_code: "CS201", subject_name: "Data Structures", attended: 24, held: 30, percent: 80.0 },
  { subject_code: "CS202", subject_name: "Operating Systems", attended: 26, held: 32, percent: 81.3 },
  { subject_code: "CS203", subject_name: "Database Management Systems", attended: 22, held: 31, percent: 71.0 },
  { subject_code: "CS204", subject_name: "Software Engineering", attended: 28, held: 32, percent: 87.5 },
];

export interface SessionRow {
  id: string;
  session_date: string;
  start_time: string;
  end_time: string;
  subject_name: string;
  subject_code: string;
  class_name: string;
  status: "present" | "absent" | "late";
}

export const DEMO_RECENT_SESSIONS: SessionRow[] = [
  { id: "s1", session_date: "2026-10-20", start_time: "09:30:00", end_time: "10:30:00", subject_name: "Data Structures", subject_code: "CS201", class_name: "CS 2A", status: "present" },
  { id: "s2", session_date: "2026-10-20", start_time: "11:00:00", end_time: "12:00:00", subject_name: "Operating Systems", subject_code: "CS202", class_name: "CS 2A", status: "present" },
  { id: "s3", session_date: "2026-10-19", start_time: "14:00:00", end_time: "15:00:00", subject_name: "Database Management Systems", subject_code: "CS203", class_name: "CS 2A", status: "absent" },
  { id: "s4", session_date: "2026-10-19", start_time: "15:30:00", end_time: "16:30:00", subject_name: "Software Engineering", subject_code: "CS204", class_name: "CS 2A", status: "late" },
  { id: "s5", session_date: "2026-10-18", start_time: "09:30:00", end_time: "10:30:00", subject_name: "Data Structures", subject_code: "CS201", class_name: "CS 2A", status: "present" },
];

export const DEMO_FACULTY_TODAY: SessionRow[] = [
  { id: "f1", session_date: "2026-10-20", start_time: "09:30:00", end_time: "10:30:00", subject_name: "Data Structures", subject_code: "CS201", class_name: "CS 2A", status: "present" },
  { id: "f2", session_date: "2026-10-20", start_time: "11:00:00", end_time: "12:00:00", subject_name: "Software Engineering", subject_code: "CS204", class_name: "CS 3A", status: "present" },
  { id: "f3", session_date: "2026-10-20", start_time: "14:00:00", end_time: "15:00:00", subject_name: "Data Structures", subject_code: "CS201", class_name: "CS 3A", status: "present" },
];

export interface DeptSummary {
  department_name: string;
  total_sessions: number;
  total_present: number;
  total_absent: number;
  total_late: number;
  avg_attendance: number;
}

export const DEMO_DEPT_SUMMARY: DeptSummary[] = [
  { department_name: "Computer Science", total_sessions: 248, total_present: 1905, total_absent: 380, total_late: 107, avg_attendance: 82.4 },
  { department_name: "Information Technology", total_sessions: 236, total_present: 1792, total_absent: 421, total_late: 98, avg_attendance: 79.1 },
  { department_name: "Electronics", total_sessions: 230, total_present: 1644, total_absent: 512, total_late: 88, avg_attendance: 74.8 },
];

export const DEMO_COUNTS = {
  students: 30,
  faculty: 9,
  classes: 6,
  departments: 3,
};

export const DEMO_RECEIVED_ALERTS = [
  { student: "Kiran Varma", class_name: "ECE 2A", percent: 61.5 },
  { student: "Meera Pillai", class_name: "IT 3B", percent: 68.2 },
  { student: "Ishita Rao", class_name: "CS 2A", percent: 71.0 },
];
