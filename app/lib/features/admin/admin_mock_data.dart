/// Local mock data for the admin dashboard (demo mode).
///
/// Mirrors `web/lib/mock/data.ts` so the app shows the same records as the
/// web app: 8 students, 4 faculty, 5 subjects, 3 classes, 3 departments.
class AdminStudent {
  final String id;
  final String name;
  final String rollNo;
  final String email;
  final String department;
  final String year;
  final String semester;

  const AdminStudent({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.email,
    required this.department,
    required this.year,
    required this.semester,
  });
}

class AdminFaculty {
  final String id;
  final String name;
  final String email;
  final String department;
  final List<String> subjects;

  const AdminFaculty({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.subjects,
  });
}

class AdminSubject {
  final String id;
  final String name;
  final String code;
  final String faculty;
  final int credits;
  final String department;
  final int semester;
  final int studentCount;

  const AdminSubject({
    required this.id,
    required this.name,
    required this.code,
    required this.faculty,
    required this.credits,
    required this.department,
    required this.semester,
    required this.studentCount,
  });
}

class AdminClass {
  final String id;
  final String name;
  final String department;
  final String year;
  final int studentCount;

  const AdminClass({
    required this.id,
    required this.name,
    required this.department,
    required this.year,
    required this.studentCount,
  });
}

class AdminDepartment {
  final String id;
  final String name;
  final String code;
  final String hod;
  final int facultyCount;
  final int studentCount;

  const AdminDepartment({
    required this.id,
    required this.name,
    required this.code,
    required this.hod,
    required this.facultyCount,
    required this.studentCount,
  });
}

class AdminMockData {
  AdminMockData._();

  // ---- Students (8) ----
  static const List<AdminStudent> students = [
    AdminStudent(id: 'stu-1', name: 'Rahul Sharma', rollNo: 'CS2022-001', email: 'rahul@attendx.com', department: 'Computer Science', year: '3rd', semester: '6th'),
    AdminStudent(id: 'stu-2', name: 'Priya Verma', rollNo: 'CS2022-002', email: 'priya@attendx.com', department: 'Computer Science', year: '3rd', semester: '6th'),
    AdminStudent(id: 'stu-3', name: 'Amit Kumar', rollNo: 'CS2022-003', email: 'amit@attendx.com', department: 'Computer Science', year: '3rd', semester: '6th'),
    AdminStudent(id: 'stu-4', name: 'Sneha Gupta', rollNo: 'CS2022-004', email: 'sneha@attendx.com', department: 'Computer Science', year: '3rd', semester: '6th'),
    AdminStudent(id: 'stu-5', name: 'Rohit Singh', rollNo: 'CS2022-005', email: 'rohit@attendx.com', department: 'Computer Science', year: '3rd', semester: '6th'),
    AdminStudent(id: 'stu-6', name: 'Ananya Reddy', rollNo: 'CS2022-006', email: 'ananya@attendx.com', department: 'Computer Science', year: '3rd', semester: '6th'),
    AdminStudent(id: 'stu-7', name: 'Vikram Joshi', rollNo: 'CS2022-007', email: 'vikram@attendx.com', department: 'Computer Science', year: '3rd', semester: '6th'),
    AdminStudent(id: 'stu-8', name: 'Neha Kapoor', rollNo: 'CS2022-008', email: 'neha@attendx.com', department: 'Computer Science', year: '3rd', semester: '6th'),
  ];

  // ---- Faculty (4) ----
  static const List<AdminFaculty> faculty = [
    AdminFaculty(id: 'fac-1', name: 'Dr. Priya Patel', email: 'priya@attendx.com', department: 'Computer Science', subjects: ['Data Structures', 'Operating Systems']),
    AdminFaculty(id: 'fac-2', name: 'Prof. Amit Sharma', email: 'amit@attendx.com', department: 'Computer Science', subjects: ['Algorithms']),
    AdminFaculty(id: 'fac-3', name: 'Dr. Sneha Reddy', email: 'sneha@attendx.com', department: 'Computer Science', subjects: ['Database Systems']),
    AdminFaculty(id: 'fac-4', name: 'Prof. Vikram Singh', email: 'vikram@attendx.com', department: 'Computer Science', subjects: ['Computer Networks']),
  ];

  // ---- Subjects (5) ----
  static const List<AdminSubject> subjects = [
    AdminSubject(id: 'sub-1', name: 'Data Structures', code: 'CS201', faculty: 'Dr. Priya Patel', credits: 4, department: 'Computer Science', semester: 6, studentCount: 8),
    AdminSubject(id: 'sub-2', name: 'Algorithms', code: 'CS202', faculty: 'Prof. Amit Sharma', credits: 4, department: 'Computer Science', semester: 6, studentCount: 8),
    AdminSubject(id: 'sub-3', name: 'Database Systems', code: 'CS203', faculty: 'Dr. Sneha Reddy', credits: 3, department: 'Computer Science', semester: 6, studentCount: 8),
    AdminSubject(id: 'sub-4', name: 'Computer Networks', code: 'CS204', faculty: 'Prof. Vikram Singh', credits: 3, department: 'Computer Science', semester: 6, studentCount: 8),
    AdminSubject(id: 'sub-5', name: 'Operating Systems', code: 'CS205', faculty: 'Dr. Priya Patel', credits: 4, department: 'Computer Science', semester: 6, studentCount: 8),
  ];

  // ---- Classes (3) ----
  static const List<AdminClass> classes = [
    AdminClass(id: 'cls-1', name: 'CS 3rd Year A', department: 'Computer Science', year: '3rd', studentCount: 8),
    AdminClass(id: 'cls-2', name: 'CS 3rd Year B', department: 'Computer Science', year: '3rd', studentCount: 0),
    AdminClass(id: 'cls-3', name: 'CS 2nd Year A', department: 'Computer Science', year: '2nd', studentCount: 0),
  ];

  // ---- Departments (3) ----
  static const List<AdminDepartment> departments = [
    AdminDepartment(id: 'dept-1', name: 'Computer Science', code: 'CS', hod: 'Dr. Rajesh Kumar', facultyCount: 4, studentCount: 8),
    AdminDepartment(id: 'dept-2', name: 'Information Technology', code: 'IT', hod: 'Dr. Meera Nair', facultyCount: 0, studentCount: 0),
    AdminDepartment(id: 'dept-3', name: 'Electronics', code: 'EC', hod: 'Prof. Suresh Reddy', facultyCount: 0, studentCount: 0),
  ];

  // ---- Summary counts ----
  static int get totalUsers => students.length + faculty.length;
  static int get totalDepartments => departments.length;
  static int get totalClasses => classes.length;
  static int get totalSubjects => subjects.length;
  static int get totalCredits =>
      subjects.fold<int>(0, (sum, subject) => sum + subject.credits);

  // ---- Email settings ----
  static const String senderName = 'AttendX Admin';
  static const String senderEmail = 'admin@attendx.com';
  static const String smtpHost = 'smtp.attendx.com';
  static const String smtpPort = '587 · TLS';
  static const List<String> notifications = [
    'Attendance Alerts',
    'Weekly Reports',
    'Announcements',
  ];
}
