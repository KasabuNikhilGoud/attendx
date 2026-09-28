// UI-facing ERP view models (decoupled from raw DB rows).
export interface StudentSummary {
  id: string;
  name: string;
  rollNo: string;
  email: string;
  department: string;
  attendancePct: number;
}

export interface SubjectSummary {
  id: string;
  name: string;
  code: string;
  faculty: string;
  attendancePct: number;
}

export interface DashboardKpi {
  label: string;
  value: string | number;
  delta?: string;
}
