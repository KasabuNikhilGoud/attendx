export interface AttendanceRecord {
  id: string
  subjectId: string
  subjectName: string
  date: string
  status: 'present' | 'absent' | 'late'
  time: string
}

export const MOCK_STUDENT = {
  id: 'stu-1',
  name: 'Rahul Sharma',
  email: 'student@attendx.com',
  rollNo: 'CS2022-001',
  department: 'Computer Science',
  year: '3rd Year',
  semester: '6th Sem',
}

export const MOCK_STUDENTS = [
  { id: 'stu-1', name: 'Rahul Sharma', rollNo: 'CS2022-001', email: 'rahul@attendx.com', department: 'Computer Science', year: '3rd', semester: '6th' },
  { id: 'stu-2', name: 'Priya Verma', rollNo: 'CS2022-002', email: 'priya@attendx.com', department: 'Computer Science', year: '3rd', semester: '6th' },
  { id: 'stu-3', name: 'Amit Kumar', rollNo: 'CS2022-003', email: 'amit@attendx.com', department: 'Computer Science', year: '3rd', semester: '6th' },
  { id: 'stu-4', name: 'Sneha Gupta', rollNo: 'CS2022-004', email: 'sneha@attendx.com', department: 'Computer Science', year: '3rd', semester: '6th' },
  { id: 'stu-5', name: 'Rohit Singh', rollNo: 'CS2022-005', email: 'rohit@attendx.com', department: 'Computer Science', year: '3rd', semester: '6th' },
  { id: 'stu-6', name: 'Ananya Reddy', rollNo: 'CS2022-006', email: 'ananya@attendx.com', department: 'Computer Science', year: '3rd', semester: '6th' },
  { id: 'stu-7', name: 'Vikram Joshi', rollNo: 'CS2022-007', email: 'vikram@attendx.com', department: 'Computer Science', year: '3rd', semester: '6th' },
  { id: 'stu-8', name: 'Neha Kapoor', rollNo: 'CS2022-008', email: 'neha@attendx.com', department: 'Computer Science', year: '3rd', semester: '6th' },
]

export const MOCK_FACULTY = [
  { id: 'fac-1', name: 'Dr. Priya Patel', email: 'priya@attendx.com', department: 'Computer Science', subjects: ['Data Structures', 'Operating Systems'] },
  { id: 'fac-2', name: 'Prof. Amit Sharma', email: 'amit@attendx.com', department: 'Computer Science', subjects: ['Algorithms'] },
  { id: 'fac-3', name: 'Dr. Sneha Reddy', email: 'sneha@attendx.com', department: 'Computer Science', subjects: ['Database Systems'] },
  { id: 'fac-4', name: 'Prof. Vikram Singh', email: 'vikram@attendx.com', department: 'Computer Science', subjects: ['Computer Networks'] },
]

export const MOCK_SUBJECTS = [
  { id: 'sub-1', name: 'Data Structures', code: 'CS201', faculty: 'Dr. Priya Patel', facultyId: 'fac-1', credits: 4, department: 'Computer Science', semester: 6, students: ['stu-1', 'stu-2', 'stu-3', 'stu-4', 'stu-5', 'stu-6', 'stu-7', 'stu-8'] },
  { id: 'sub-2', name: 'Algorithms', code: 'CS202', faculty: 'Prof. Amit Sharma', facultyId: 'fac-2', credits: 4, department: 'Computer Science', semester: 6, students: ['stu-1', 'stu-2', 'stu-3', 'stu-4', 'stu-5', 'stu-6', 'stu-7', 'stu-8'] },
  { id: 'sub-3', name: 'Database Systems', code: 'CS203', faculty: 'Dr. Sneha Reddy', facultyId: 'fac-3', credits: 3, department: 'Computer Science', semester: 6, students: ['stu-1', 'stu-2', 'stu-3', 'stu-4', 'stu-5', 'stu-6', 'stu-7', 'stu-8'] },
  { id: 'sub-4', name: 'Computer Networks', code: 'CS204', faculty: 'Prof. Vikram Singh', facultyId: 'fac-4', credits: 3, department: 'Computer Science', semester: 6, students: ['stu-1', 'stu-2', 'stu-3', 'stu-4', 'stu-5', 'stu-6', 'stu-7', 'stu-8'] },
  { id: 'sub-5', name: 'Operating Systems', code: 'CS205', faculty: 'Dr. Priya Patel', facultyId: 'fac-1', credits: 4, department: 'Computer Science', semester: 6, students: ['stu-1', 'stu-2', 'stu-3', 'stu-4', 'stu-5', 'stu-6', 'stu-7', 'stu-8'] },
]

export const MOCK_ATTENDANCE: AttendanceRecord[] = [
  { id: 'att-1', subjectId: 'sub-1', subjectName: 'Data Structures', date: '2026-07-10', status: 'present', time: '10:00 AM' },
  { id: 'att-2', subjectId: 'sub-1', subjectName: 'Data Structures', date: '2026-07-08', status: 'present', time: '10:00 AM' },
  { id: 'att-3', subjectId: 'sub-1', subjectName: 'Data Structures', date: '2026-07-06', status: 'absent', time: '10:00 AM' },
  { id: 'att-4', subjectId: 'sub-2', subjectName: 'Algorithms', date: '2026-07-10', status: 'present', time: '11:00 AM' },
  { id: 'att-5', subjectId: 'sub-2', subjectName: 'Algorithms', date: '2026-07-08', status: 'absent', time: '11:00 AM' },
  { id: 'att-6', subjectId: 'sub-2', subjectName: 'Algorithms', date: '2026-07-05', status: 'present', time: '11:00 AM' },
  { id: 'att-7', subjectId: 'sub-3', subjectName: 'Database Systems', date: '2026-07-09', status: 'present', time: '02:00 PM' },
  { id: 'att-8', subjectId: 'sub-3', subjectName: 'Database Systems', date: '2026-07-07', status: 'present', time: '02:00 PM' },
  { id: 'att-9', subjectId: 'sub-3', subjectName: 'Database Systems', date: '2026-07-04', status: 'present', time: '02:00 PM' },
  { id: 'att-10', subjectId: 'sub-4', subjectName: 'Computer Networks', date: '2026-07-09', status: 'absent', time: '09:00 AM' },
  { id: 'att-11', subjectId: 'sub-4', subjectName: 'Computer Networks', date: '2026-07-07', status: 'present', time: '09:00 AM' },
  { id: 'att-12', subjectId: 'sub-4', subjectName: 'Computer Networks', date: '2026-07-04', status: 'absent', time: '09:00 AM' },
  { id: 'att-13', subjectId: 'sub-5', subjectName: 'Operating Systems', date: '2026-07-10', status: 'present', time: '01:00 PM' },
  { id: 'att-14', subjectId: 'sub-5', subjectName: 'Operating Systems', date: '2026-07-07', status: 'present', time: '01:00 PM' },
  { id: 'att-15', subjectId: 'sub-5', subjectName: 'Operating Systems', date: '2026-07-03', status: 'present', time: '01:00 PM' },
]

export const MOCK_CLASSES = [
  { id: 'cls-1', name: 'CS 3rd Year A', department: 'Computer Science', year: '3rd', students: 8 },
  { id: 'cls-2', name: 'CS 3rd Year B', department: 'Computer Science', year: '3rd', students: 0 },
  { id: 'cls-3', name: 'CS 2nd Year A', department: 'Computer Science', year: '2nd', students: 0 },
]

export const MOCK_DEPARTMENTS = [
  { id: 'dept-1', name: 'Computer Science', code: 'CS', hod: 'Dr. Rajesh Kumar', facultyCount: 4, studentCount: 8 },
  { id: 'dept-2', name: 'Information Technology', code: 'IT', hod: 'Dr. Meera Nair', facultyCount: 0, studentCount: 0 },
  { id: 'dept-3', name: 'Electronics', code: 'EC', hod: 'Prof. Suresh Reddy', facultyCount: 0, studentCount: 0 },
]

export function getStudentAttendance(studentId: string) {
  return MOCK_ATTENDANCE
}

export function getSubjectAttendance(subjectId: string) {
  return MOCK_ATTENDANCE.filter(a => a.subjectId === subjectId)
}

export function getAttendancePercentage(subjectId: string) {
  const records = MOCK_ATTENDANCE.filter(a => a.subjectId === subjectId)
  if (records.length === 0) return 0
  const present = records.filter(r => r.status === 'present').length
  return Math.round((present / records.length) * 100)
}

export function getOverallAttendance() {
  const present = MOCK_ATTENDANCE.filter(r => r.status === 'present').length
  return Math.round((present / MOCK_ATTENDANCE.length) * 100)
}

export function getStudentForSubject(subjectId: string) {
  const sub = MOCK_SUBJECTS.find(s => s.id === subjectId)
  if (!sub) return []
  return MOCK_STUDENTS.filter(s => sub.students.includes(s.id))
}
