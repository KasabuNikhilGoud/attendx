// Mock data for the student dashboard. AttendX runs as an offline showcase
// (no backend/database configured), so the student experience is rendered from
// this local data. Subjects and identity mirror the AttendX web dashboard.

/// Attendance status for a single class.
enum AttendanceStatus { present, absent, late }

/// A subject the student is enrolled in, with attendance counts.
class StudentSubject {
  const StudentSubject({
    required this.name,
    required this.code,
    required this.faculty,
    required this.classesHeld,
    required this.classesAttended,
  });

  final String name;
  final String code;
  final String faculty;
  final int classesHeld;
  final int classesAttended;

  /// Attendance percentage in the 0-100 range.
  double get percent =>
      classesHeld == 0 ? 0 : (classesAttended / classesHeld) * 100;
}

/// One attendance entry shown in recent lists and history.
class StudentAttendanceRecord {
  const StudentAttendanceRecord({
    required this.subjectCode,
    required this.date,
    required this.time,
    required this.status,
  });

  final String subjectCode;
  final String date;
  final String time;
  final AttendanceStatus status;
}

/// Const mock data for the demo student (Rahul Student).
class StudentMockData {
  const StudentMockData._();

  // ---- Identity ----
  static const String fullNameFallback = 'Rahul Student';
  static const String email = 'student@attendx.com';
  static const String rollNumber = 'CS2022-001';
  static const String department = 'Computer Science & Engineering';
  static const String year = '3rd Year';
  static const String semester = '6th Semester';

  // ---- Subjects (same five subjects as the web app) ----
  static const List<StudentSubject> subjects = [
    StudentSubject(
      name: 'Data Structures',
      code: 'CS201',
      faculty: 'Prof. Sharma',
      classesHeld: 50,
      classesAttended: 46,
    ),
    StudentSubject(
      name: 'Algorithms',
      code: 'CS202',
      faculty: 'Dr. Meera Iyer',
      classesHeld: 50,
      classesAttended: 42,
    ),
    StudentSubject(
      name: 'Database Systems',
      code: 'CS203',
      faculty: 'Prof. Verma',
      classesHeld: 50,
      classesAttended: 39,
    ),
    StudentSubject(
      name: 'Computer Networks',
      code: 'CS204',
      faculty: 'Dr. Rakesh Rao',
      classesHeld: 50,
      classesAttended: 29,
    ),
    StudentSubject(
      name: 'Operating Systems',
      code: 'CS205',
      faculty: 'Prof. Anita Desai',
      classesHeld: 45,
      classesAttended: 32,
    ),
  ];

  // ---- Recent attendance records (newest first, same-day by time) ----
  static const List<StudentAttendanceRecord> records = [
    StudentAttendanceRecord(
      subjectCode: 'CS205',
      date: '17 Oct 2026',
      time: '11:05 AM',
      status: AttendanceStatus.present,
    ),
    StudentAttendanceRecord(
      subjectCode: 'CS201',
      date: '17 Oct 2026',
      time: '09:15 AM',
      status: AttendanceStatus.present,
    ),
    StudentAttendanceRecord(
      subjectCode: 'CS202',
      date: '16 Oct 2026',
      time: '02:00 PM',
      status: AttendanceStatus.present,
    ),
    StudentAttendanceRecord(
      subjectCode: 'CS203',
      date: '16 Oct 2026',
      time: '10:30 AM',
      status: AttendanceStatus.present,
    ),
    StudentAttendanceRecord(
      subjectCode: 'CS204',
      date: '15 Oct 2026',
      time: '11:05 AM',
      status: AttendanceStatus.absent,
    ),
    StudentAttendanceRecord(
      subjectCode: 'CS201',
      date: '15 Oct 2026',
      time: '09:15 AM',
      status: AttendanceStatus.present,
    ),
    StudentAttendanceRecord(
      subjectCode: 'CS202',
      date: '14 Oct 2026',
      time: '02:00 PM',
      status: AttendanceStatus.late,
    ),
    StudentAttendanceRecord(
      subjectCode: 'CS203',
      date: '14 Oct 2026',
      time: '10:30 AM',
      status: AttendanceStatus.present,
    ),
    StudentAttendanceRecord(
      subjectCode: 'CS205',
      date: '13 Oct 2026',
      time: '09:15 AM',
      status: AttendanceStatus.present,
    ),
    StudentAttendanceRecord(
      subjectCode: 'CS202',
      date: '12 Oct 2026',
      time: '02:00 PM',
      status: AttendanceStatus.present,
    ),
    StudentAttendanceRecord(
      subjectCode: 'CS204',
      date: '12 Oct 2026',
      time: '11:05 AM',
      status: AttendanceStatus.late,
    ),
    StudentAttendanceRecord(
      subjectCode: 'CS201',
      date: '10 Oct 2026',
      time: '09:15 AM',
      status: AttendanceStatus.present,
    ),
    StudentAttendanceRecord(
      subjectCode: 'CS203',
      date: '09 Oct 2026',
      time: '10:30 AM',
      status: AttendanceStatus.present,
    ),
    StudentAttendanceRecord(
      subjectCode: 'CS205',
      date: '08 Oct 2026',
      time: '11:05 AM',
      status: AttendanceStatus.late,
    ),
    StudentAttendanceRecord(
      subjectCode: 'CS204',
      date: '07 Oct 2026',
      time: '02:00 PM',
      status: AttendanceStatus.present,
    ),
  ];

  // ---- Aggregates (computed from real held/attended counts) ----

  static int get totalClassesHeld =>
      subjects.fold(0, (sum, subject) => sum + subject.classesHeld);

  static int get totalClassesAttended =>
      subjects.fold(0, (sum, subject) => sum + subject.classesAttended);

  /// Overall attendance across all subjects (0-100). 188 / 245 = ~77%.
  static double get overallPercent => totalClassesHeld == 0
      ? 0
      : (totalClassesAttended / totalClassesHeld) * 100;

  static StudentSubject? subjectByCode(String code) {
    for (final subject in subjects) {
      if (subject.code == code) {
        return subject;
      }
    }
    return null;
  }

  static List<StudentAttendanceRecord> recordsForSubject(String code) =>
      records.where((record) => record.subjectCode == code).toList();

  /// Number of recent records with the given status.
  static int countWithStatus(AttendanceStatus status) =>
      records.where((record) => record.status == status).length;

  /// Subjects below the 75% requirement, worst first.
  static List<StudentSubject> get belowRequirement {
    final list = subjects.where((subject) => subject.percent < 75).toList()
      ..sort((a, b) => a.percent.compareTo(b.percent));
    return list;
  }
}
