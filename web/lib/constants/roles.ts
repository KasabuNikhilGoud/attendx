export type { UserRole } from '../supabase/client';

export const ROLES = ['admin', 'hod', 'faculty', 'student'] as const;
export type Role = (typeof ROLES)[number];

export const ROLE_HOME: Record<Role, string> = {
  admin: '/admin',
  hod: '/hod',
  faculty: '/faculty',
  student: '/student',
};

export const ROLE_LABEL: Record<Role, string> = {
  admin: 'Admin',
  hod: 'HOD',
  faculty: 'Faculty',
  student: 'Student',
};
