// Local mock data for the Faculty dashboard.
//
// AttendX runs as an offline showcase build, so the faculty
// screens are backed by the const data below instead of network calls.

/// Session status for a student on a given day.
enum AttendanceStatus { present, absent, late }

/// A student's attendance record inside a [FacultySubject].
class StudentAttendance {
  final String rollNo;
  final String name;

  /// Sessions attended on time (out of [FacultySubject.sessions]).
  final int presentCount;

  /// Sessions attended but marked late.
  final int lateCount;

  const StudentAttendance({
    required this.rollNo,
    required this.name,
    required this.presentCount,
    required this.lateCount,
  });

  int get attendedCount => presentCount + lateCount;
}

/// A subject taught by the demo faculty member.
class FacultySubject {
  final String id;
  final String name;
  final String code;
  final String section;
  final String facultyName;
  final String department;

  /// Total sessions conducted so far this term.
  final int sessions;

  final List<StudentAttendance> students;

  const FacultySubject({
    required this.id,
    required this.name,
    required this.code,
    required this.section,
    required this.facultyName,
    required this.department,
    required this.sessions,
    required this.students,
  });

  int get studentCount => students.length;

  int get presentTotal =>
      students.fold(0, (sum, s) => sum + s.presentCount);

  int get lateTotal => students.fold(0, (sum, s) => sum + s.lateCount);

  int get absentTotal => sessions * studentCount - presentTotal - lateTotal;

  /// Class average attendance percentage (0-100).
  int get averagePercent {
    final total = sessions * studentCount;
    if (total == 0) return 0;
    return ((presentTotal + lateTotal) * 100 / total).round();
  }

  /// Attendance percentage for a single student (0-100).
  int percentFor(StudentAttendance student) {
    if (sessions == 0) return 0;
    return (student.attendedCount * 100 / sessions).round();
  }

  /// Sessions missed by a single student.
  int absentFor(StudentAttendance student) =>
      sessions - student.attendedCount;
}

const String kMockFacultyName = 'Dr. Priya Patel';
const String kMockFacultyDepartment = 'Computer Science';

const List<FacultySubject> mockFacultySubjects = [
  FacultySubject(
    id: 'cs201',
    name: 'Data Structures',
    code: 'CS201',
    section: 'CSE-A',
    facultyName: kMockFacultyName,
    department: kMockFacultyDepartment,
    sessions: 40,
    students: [
      StudentAttendance(
          rollNo: 'CS2022-001',
          name: 'Aditya Rao',
          presentCount: 36,
          lateCount: 1),
      StudentAttendance(
          rollNo: 'CS2022-002',
          name: 'Sneha Reddy',
          presentCount: 35,
          lateCount: 1),
      StudentAttendance(
          rollNo: 'CS2022-003',
          name: 'Karthik Menon',
          presentCount: 31,
          lateCount: 0),
      StudentAttendance(
          rollNo: 'CS2022-004',
          name: 'Ananya Iyer',
          presentCount: 26,
          lateCount: 1),
      StudentAttendance(
          rollNo: 'CS2022-005',
          name: 'Rahul Verma',
          presentCount: 37,
          lateCount: 1),
      StudentAttendance(
          rollNo: 'CS2022-006',
          name: 'Priya Nair',
          presentCount: 33,
          lateCount: 0),
      StudentAttendance(
          rollNo: 'CS2022-007',
          name: 'Vikram Singh',
          presentCount: 23,
          lateCount: 0),
      StudentAttendance(
          rollNo: 'CS2022-008',
          name: 'Meera Joshi',
          presentCount: 35,
          lateCount: 1),
    ],
  ),
  FacultySubject(
    id: 'cs205',
    name: 'Operating Systems',
    code: 'CS205',
    section: 'CSE-A',
    facultyName: kMockFacultyName,
    department: kMockFacultyDepartment,
    sessions: 40,
    students: [
      StudentAttendance(
          rollNo: 'CS2022-001',
          name: 'Aditya Rao',
          presentCount: 33,
          lateCount: 1),
      StudentAttendance(
          rollNo: 'CS2022-002',
          name: 'Sneha Reddy',
          presentCount: 31,
          lateCount: 0),
      StudentAttendance(
          rollNo: 'CS2022-003',
          name: 'Karthik Menon',
          presentCount: 36,
          lateCount: 1),
      StudentAttendance(
          rollNo: 'CS2022-004',
          name: 'Ananya Iyer',
          presentCount: 28,
          lateCount: 1),
      StudentAttendance(
          rollNo: 'CS2022-005',
          name: 'Rahul Verma',
          presentCount: 35,
          lateCount: 0),
      StudentAttendance(
          rollNo: 'CS2022-006',
          name: 'Priya Nair',
          presentCount: 25,
          lateCount: 1),
      StudentAttendance(
          rollNo: 'CS2022-007',
          name: 'Vikram Singh',
          presentCount: 32,
          lateCount: 0),
      StudentAttendance(
          rollNo: 'CS2022-008',
          name: 'Meera Joshi',
          presentCount: 37,
          lateCount: 1),
    ],
  ),
];
