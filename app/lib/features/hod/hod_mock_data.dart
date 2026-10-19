/// Local mock data for the HOD dashboard.
///
/// The app runs as an offline showcase build, so every number on
/// the HOD screens comes from these const fixtures — mirroring the web app.
library;

class HodFaculty {
  final String name;
  final String email;
  final String department;
  final List<String> subjects;
  final double attendance;
  final int records;

  const HodFaculty({
    required this.name,
    required this.email,
    required this.department,
    required this.subjects,
    required this.attendance,
    required this.records,
  });
}

class HodSubject {
  final String name;
  final String code;
  final int present;
  final int absent;
  final int late;

  const HodSubject({
    required this.name,
    required this.code,
    required this.present,
    required this.absent,
    required this.late,
  });

  int get total => present + absent + late;

  double get attendancePercent => total == 0 ? 0 : (present / total) * 100;
}

class HodStudent {
  final String name;
  final String rollNo;
  final String program;
  final double attendance;

  const HodStudent({
    required this.name,
    required this.rollNo,
    required this.program,
    required this.attendance,
  });
}

enum HodActivityStatus { present, absent, late }

class HodActivity {
  final String subject;
  final String date;
  final HodActivityStatus status;

  const HodActivity({
    required this.subject,
    required this.date,
    required this.status,
  });
}

class HodMockData {
  HodMockData._();

  static const String departmentName = 'Computer Science';
  static const int classesThisWeek = 24;

  static const List<HodFaculty> faculty = [
    HodFaculty(
      name: 'Dr. Priya Patel',
      email: 'priya.patel@attendx.edu',
      department: departmentName,
      subjects: ['Data Structures', 'Algorithms'],
      attendance: 92.4,
      records: 128,
    ),
    HodFaculty(
      name: 'Prof. Amit Sharma',
      email: 'amit.sharma@attendx.edu',
      department: departmentName,
      subjects: ['DBMS', 'Operating Systems'],
      attendance: 86.7,
      records: 104,
    ),
    HodFaculty(
      name: 'Dr. Sneha Reddy',
      email: 'sneha.reddy@attendx.edu',
      department: departmentName,
      subjects: ['Computer Networks'],
      attendance: 94.2,
      records: 92,
    ),
    HodFaculty(
      name: 'Prof. Vikram Singh',
      email: 'vikram.singh@attendx.edu',
      department: departmentName,
      subjects: ['Software Engineering', 'Machine Learning'],
      attendance: 78.5,
      records: 76,
    ),
  ];

  static const List<HodSubject> subjects = [
    HodSubject(
      name: 'Data Structures',
      code: 'CS301',
      present: 142,
      absent: 10,
      late: 2,
    ),
    HodSubject(
      name: 'DBMS',
      code: 'CS302',
      present: 118,
      absent: 22,
      late: 4,
    ),
    HodSubject(
      name: 'Operating Systems',
      code: 'CS303',
      present: 126,
      absent: 14,
      late: 4,
    ),
    HodSubject(
      name: 'Computer Networks',
      code: 'CS304',
      present: 98,
      absent: 26,
      late: 6,
    ),
    HodSubject(
      name: 'Software Engineering',
      code: 'CS305',
      present: 134,
      absent: 8,
      late: 2,
    ),
  ];

  static const List<HodStudent> students = [
    HodStudent(
      name: 'Aarav Sharma',
      rollNo: 'CS21B001',
      program: 'B.Tech CSE, Sem 5',
      attendance: 94.0,
    ),
    HodStudent(
      name: 'Diya Verma',
      rollNo: 'CS21B002',
      program: 'B.Tech CSE, Sem 5',
      attendance: 88.5,
    ),
    HodStudent(
      name: 'Arjun Mehta',
      rollNo: 'CS21B003',
      program: 'B.Tech CSE, Sem 5',
      attendance: 72.3,
    ),
    HodStudent(
      name: 'Ishita Nair',
      rollNo: 'CS21B004',
      program: 'B.Tech CSE, Sem 5',
      attendance: 96.1,
    ),
    HodStudent(
      name: 'Rohan Gupta',
      rollNo: 'CS21B005',
      program: 'B.Tech CSE, Sem 5',
      attendance: 65.8,
    ),
    HodStudent(
      name: 'Ananya Iyer',
      rollNo: 'CS21B006',
      program: 'B.Tech CSE, Sem 5',
      attendance: 90.4,
    ),
    HodStudent(
      name: 'Kabir Malhotra',
      rollNo: 'CS21B007',
      program: 'B.Tech CSE, Sem 5',
      attendance: 79.2,
    ),
    HodStudent(
      name: 'Meera Joshi',
      rollNo: 'CS21B008',
      program: 'B.Tech CSE, Sem 5',
      attendance: 85.6,
    ),
  ];

  static const List<HodActivity> recentActivity = [
    HodActivity(
      subject: 'Data Structures',
      date: 'Oct 17, 2026',
      status: HodActivityStatus.present,
    ),
    HodActivity(
      subject: 'DBMS',
      date: 'Oct 17, 2026',
      status: HodActivityStatus.present,
    ),
    HodActivity(
      subject: 'Operating Systems',
      date: 'Oct 16, 2026',
      status: HodActivityStatus.late,
    ),
    HodActivity(
      subject: 'Computer Networks',
      date: 'Oct 16, 2026',
      status: HodActivityStatus.absent,
    ),
    HodActivity(
      subject: 'Software Engineering',
      date: 'Oct 15, 2026',
      status: HodActivityStatus.present,
    ),
    HodActivity(
      subject: 'Data Structures',
      date: 'Oct 15, 2026',
      status: HodActivityStatus.present,
    ),
    HodActivity(
      subject: 'DBMS',
      date: 'Oct 14, 2026',
      status: HodActivityStatus.late,
    ),
    HodActivity(
      subject: 'Computer Networks',
      date: 'Oct 14, 2026',
      status: HodActivityStatus.present,
    ),
  ];

  // ---- Aggregates (always derived from the subject fixtures) ----

  static int get totalSessions =>
      subjects.fold(0, (sum, subject) => sum + subject.total);

  static int get totalPresent =>
      subjects.fold(0, (sum, subject) => sum + subject.present);

  static int get totalAbsent =>
      subjects.fold(0, (sum, subject) => sum + subject.absent);

  static int get totalLate =>
      subjects.fold(0, (sum, subject) => sum + subject.late);

  static double get averageAttendance {
    final sessions = totalSessions;
    if (sessions == 0) return 0;
    return (totalPresent / sessions) * 100;
  }
}
