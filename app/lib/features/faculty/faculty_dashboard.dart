import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/apple_pressable.dart';
import '../../core/widgets/frosted_nav_bar.dart';
import 'faculty_mock_data.dart';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({super.key});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

/// In-page sub-views that replace the tab content (mark flow / reports).
enum _SubView { mark, reports }

class _FacultyDashboardState extends State<FacultyDashboard> {
  Map<String, dynamic>? _profile;
  int _currentNavIndex = 0;
  _SubView? _subView;

  // Mark flow (local state only — no backend calls).
  FacultySubject? _markSubject;
  final Map<String, AttendanceStatus> _marks = {};
  bool _submitted = false;

  // Reports.
  FacultySubject? _reportFocus;


  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await AuthService.getProfile();
    if (mounted) setState(() => _profile = p);
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    context.go('/login');
  }

  String get _facultyName =>
      (_profile?['full_name'] as String?) ?? 'Prof. Sharma';

  // -------------------------------------------------------------- actions

  void _openMark([FacultySubject? subject]) {
    setState(() {
      _subView = _SubView.mark;
      _submitted = false;
      _marks.clear();
      _markSubject = subject;
      if (subject != null) {
        for (final s in subject.students) {
          _marks[s.rollNo] = AttendanceStatus.present;
        }
      }
    });
  }

  void _selectMarkSubject(FacultySubject subject) {
    setState(() {
      _markSubject = subject;
      _marks.clear();
      for (final s in subject.students) {
        _marks[s.rollNo] = AttendanceStatus.present;
      }
    });
  }

  void _openReports([FacultySubject? focus]) {
    setState(() {
      _subView = _SubView.reports;
      _reportFocus = focus;
    });
  }

  void _closeSubView() {
    setState(() {
      _subView = null;
      _markSubject = null;
      _marks.clear();
      _submitted = false;
      _reportFocus = null;
    });
  }

  void _switchTab(int index) {
    if (_currentNavIndex == index && _subView == null) return;
    setState(() {
      _currentNavIndex = index;
      _subView = null;
      _markSubject = null;
      _marks.clear();
      _submitted = false;
      _reportFocus = null;
    });
  }

  void _submitAttendance() => setState(() => _submitted = true);

  void _finishMark() {
    setState(() {
      _subView = null;
      _currentNavIndex = 0;
      _markSubject = null;
      _marks.clear();
      _submitted = false;
    });
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 64,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.transparent),
          ),
        ),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.8),
        ),
        title: Image.asset(
          'assets/images/logo.png',
          height: 38,
          fit: BoxFit.contain,
        ),
        actions: [
          ApplePressable(
            onTap: _logout,
            borderRadius: BorderRadius.circular(100),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Icon(
                Icons.logout_rounded,
                color: AppColors.primaryRed,
                size: 22,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.015),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: _buildCurrentView(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCurrentView() {
    final sub = _subView;
    if (sub == _SubView.mark) {
      return KeyedSubtree(
        key: const ValueKey('sub_mark'),
        child: _buildMarkView(),
      );
    }
    if (sub == _SubView.reports) {
      return KeyedSubtree(
        key: const ValueKey('sub_reports'),
        child: _buildReportsView(),
      );
    }
    return KeyedSubtree(
      key: ValueKey('tab_$_currentNavIndex'),
      child: _buildTab(_currentNavIndex),
    );
  }

  Widget _buildTab(int index) {
    switch (index) {
      case 1:
        return _buildOverview();
      case 2:
        return _buildInfo();
      default:
        return _buildHome();
    }
  }

  // --------------------------------------------------------- bottom nav

  Widget _buildBottomNav() {
    return FrostedNavBar(
      currentIndex: _currentNavIndex,
      onTap: _switchTab,
      items: const [
        FrostedNavItem(icon: Icons.home_rounded, label: 'Home'),
        FrostedNavItem(icon: Icons.calendar_month_rounded, label: 'View'),
        FrostedNavItem(icon: Icons.info_outline_rounded, label: 'Info'),
      ],
    );
  }

  // ---------------------------------------------------------------- home

  Widget _buildHome() {
    final today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $_facultyName 👋',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 13, color: AppColors.neutralGray),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  today,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.edit_calendar_rounded,
                    label: 'Mark Attendance',
                    caption: "Today's classes",
                    color: AppColors.primaryRed,
                    onTap: _openMark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.insights_rounded,
                    label: 'View Reports',
                    caption: 'Class summary',
                    color: AppColors.greenSuccess,
                    onTap: _openReports,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Text(
                'My Subjects',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const Spacer(),
              Text(
                '${mockFacultySubjects.length} assigned',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final subject in mockFacultySubjects) ...[
            _SubjectCard(
              subject: subject,
              onMark: () => _openMark(subject),
              onReports: () => _openReports(subject),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------ overview

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Overview of your classes this term',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          _OverallAttendanceCard(subjects: mockFacultySubjects),
          const SizedBox(height: 12),
          for (final subject in mockFacultySubjects) ...[
            _SubjectSummaryCard(
              subject: subject,
              onTap: () => _openReports(subject),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- info

  Widget _buildInfo() {
    final email = _profile?['email'] as String?;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Info',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Profile and app details',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          _Card(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: AppColors.primaryRed, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _facultyName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Faculty • $kMockFacultyDepartment',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (email != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.grayLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.school_rounded,
                  title: AppConstants.appName,
                  subtitle:
                      'v${AppConstants.appVersion} • ERP Attendance Management System',
                ),
                const Divider(height: 25, color: AppColors.divider),
                const _InfoRow(
                  icon: Icons.cloud_off_rounded,
                  title: 'Demo mode',
                  subtitle:
                      'Running on local mock data — no server connection needed',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- reports

  Widget _buildReportsView() {
    final focused = _reportFocus;
    final subjects =
        focused == null ? mockFacultySubjects : <FacultySubject>[focused];
    final studentTotal = focused == null
        ? mockFacultySubjects.fold<int>(0, (sum, s) => sum + s.studentCount)
        : focused.studentCount;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BackRow(onTap: _closeSubView),
          const SizedBox(height: 10),
          Text(
            'Attendance Reports',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            focused == null
                ? '$studentTotal students • ${subjects.length} subjects'
                : '${focused.code} • ${focused.section} • $studentTotal students',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          _OverallAttendanceCard(subjects: subjects),
          const SizedBox(height: 12),
          for (final subject in subjects) ...[
            _SubjectSummaryCard(subject: subject, showStudents: true),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  // --------------------------------------------------------- mark flow

  Widget _buildMarkView() {
    final Widget panel;
    if (_submitted) {
      panel = _buildMarkSuccess();
    } else if (_markSubject == null) {
      panel = _buildSubjectPicker();
    } else {
      panel = _buildMarkForm();
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BackRow(onTap: _closeSubView),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.02),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: panel,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectPicker() {
    return Column(
      key: const ValueKey('mark_picker'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mark Attendance',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Pick a subject to record today's attendance",
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 18),
        for (final subject in mockFacultySubjects) ...[
          _SubjectPickTile(
            subject: subject,
            onTap: () => _selectMarkSubject(subject),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildMarkForm() {
    final subject = _markSubject!;
    final today = DateFormat('EEE, d MMM').format(DateTime.now());
    return Column(
      key: const ValueKey('mark_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subject.name,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${subject.code} • ${subject.section} • $today',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        _Card(
          child: Column(
            children: [
              for (var i = 0; i < subject.students.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: AppColors.divider,
                  ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subject.students[i].name,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          Text(
                            subject.students[i].rollNo,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: AppColors.grayLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _StatusSegmented(
                        value: _marks[subject.students[i].rollNo] ??
                            AttendanceStatus.present,
                        onChanged: (status) => setState(
                          () => _marks[subject.students[i].rollNo] = status,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitAttendance,
            child: const Text('Submit Attendance'),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Demo mode — attendance is not saved to a server',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: AppColors.grayLight,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildMarkSuccess() {
    final subject = _markSubject!;
    var present = 0;
    var late = 0;
    var absent = 0;
    for (final student in subject.students) {
      switch (_marks[student.rollNo] ?? AttendanceStatus.present) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.absent:
          absent++;
        case AttendanceStatus.late:
          late++;
      }
    }
    return SizedBox(
      key: const ValueKey('mark_success'),
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 18),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) => Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: scale.clamp(0.0, 1.0).toDouble(),
                child: child,
              ),
            ),
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.greenSuccess.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.greenSuccess, size: 44),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Attendance Submitted!',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '${subject.name} • ${subject.section}',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _Card(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Expanded(
                  child: _SuccessStat(
                    label: 'Present',
                    value: present,
                    color: AppColors.greenSuccess,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SuccessStat(
                    label: 'Late',
                    value: late,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SuccessStat(
                    label: 'Absent',
                    value: absent,
                    color: AppColors.redAbsent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _finishMark,
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

}

// ------------------------------------------------------------- widgets

/// Shadcn white surface — radius 16, 1px border, subtle micro-elevation.
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card({
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String caption;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.caption,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.xl,
        boxShadow: AppShadows.card,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: AppBorderRadius.xl,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: AppBorderRadius.md,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  caption,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final FacultySubject subject;
  final VoidCallback onMark;
  final VoidCallback onReports;

  const _SubjectCard({
    required this.subject,
    required this.onMark,
    required this.onReports,
  });

  @override
  Widget build(BuildContext context) {
    final avg = subject.averagePercent;
    final color = _percentColor(avg);
    return _Card(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.08),
                  borderRadius: AppBorderRadius.md,
                ),
                child: Icon(_subjectIcon(subject.code),
                    color: AppColors.primaryRed, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${subject.code} • ${subject.section}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '${subject.studentCount} students',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '$avg% avg',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _PercentBar(percent: avg, color: color),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SmallButton(label: 'Mark', filled: true, onTap: onMark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallButton(
                    label: 'Reports', filled: false, onTap: onReports),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _SmallButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primaryRed : AppColors.surface,
      borderRadius: AppBorderRadius.md,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : AppColors.darkText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackRow extends StatelessWidget {
  final VoidCallback onTap;

  const _BackRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: AppBorderRadius.fullPill,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chevron_left_rounded,
                    size: 22, color: AppColors.primaryRed),
                Text(
                  'Back',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryRed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectPickTile extends StatelessWidget {
  final FacultySubject subject;
  final VoidCallback onTap;

  const _SubjectPickTile({required this.subject, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: AppBorderRadius.xl,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withValues(alpha: 0.08),
                    borderRadius: AppBorderRadius.md,
                  ),
                  child: Icon(_subjectIcon(subject.code),
                      color: AppColors.primaryRed, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${subject.code} • ${subject.section} • '
                        '${subject.studentCount} students',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 22, color: AppColors.grayLight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusSegmented extends StatelessWidget {
  final AttendanceStatus value;
  final ValueChanged<AttendanceStatus> onChanged;

  const _StatusSegmented({required this.value, required this.onChanged});

  static const List<AttendanceStatus> _options = [
    AttendanceStatus.present,
    AttendanceStatus.absent,
    AttendanceStatus.late,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.zinc100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.zinc200, width: 1),
      ),
      child: Row(
        children: [
          for (final option in _options)
            Expanded(
              child: ApplePressable(
                onTap: () => onChanged(option),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: AppCurves.spring,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: option == value
                        ? _statusColor(option)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: option == value
                        ? [
                            BoxShadow(
                              color: _statusColor(option).withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      _statusLabel(option),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: option == value
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: option == value
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PercentBar extends StatelessWidget {
  final int percent;
  final Color color;

  const _PercentBar({
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppBorderRadius.fullPill,
      child: Container(
        height: 6,
        color: AppColors.divider,
        child: TweenAnimationBuilder<double>(
          tween: Tween(
            begin: 0.0,
            end: (percent / 100).clamp(0.0, 1.0).toDouble(),
          ),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: value,
              child: Container(color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _SuccessStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppBorderRadius.md,
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryRed.withValues(alpha: 0.08),
            borderRadius: AppBorderRadius.md,
          ),
          child: Icon(icon, color: AppColors.primaryRed, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverallAttendanceCard extends StatelessWidget {
  final List<FacultySubject> subjects;

  const _OverallAttendanceCard({required this.subjects});

  @override
  Widget build(BuildContext context) {
    var present = 0;
    var late = 0;
    var absent = 0;
    var studentSessions = 0;
    var studentCount = 0;
    for (final subject in subjects) {
      present += subject.presentTotal;
      late += subject.lateTotal;
      absent += subject.absentTotal;
      studentSessions += subject.sessions * subject.studentCount;
      studentCount += subject.studentCount;
    }
    final percent = studentSessions == 0
        ? 0
        : ((present + late) * 100 / studentSessions).round();
    final color = _percentColor(percent);
    return _Card(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Attendance',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$percent%',
                      style: GoogleFonts.inter(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: color,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$studentCount students • '
                      '${subjects.length == 1 ? 'subject' : 'subjects'}: '
                      '$present present · $late late · $absent absent',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.donut_large_rounded, color: color, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PercentBar(percent: percent, color: color),
        ],
      ),
    );
  }
}

class _SubjectSummaryCard extends StatelessWidget {
  final FacultySubject subject;
  final bool showStudents;
  final VoidCallback? onTap;

  const _SubjectSummaryCard({
    required this.subject,
    this.showStudents = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avg = subject.averagePercent;
    final color = _percentColor(avg);
    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.08),
                  borderRadius: AppBorderRadius.md,
                ),
                child: Icon(_subjectIcon(subject.code),
                    color: AppColors.primaryRed, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${subject.code} • ${subject.section}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$avg%',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.grayLight),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SuccessStat(
                  label: 'Present',
                  value: subject.presentTotal,
                  color: AppColors.greenSuccess,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SuccessStat(
                  label: 'Late',
                  value: subject.lateTotal,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SuccessStat(
                  label: 'Absent',
                  value: subject.absentTotal,
                  color: AppColors.redAbsent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PercentBar(percent: avg, color: color),
          if (showStudents) ...[
            const SizedBox(height: 8),
            for (var i = 0; i < subject.students.length; i++) ...[
              if (i > 0)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.divider,
                ),
              _StudentRow(subject: subject, student: subject.students[i]),
            ],
          ],
        ],
      ),
    );
    if (onTap == null) return _Card(child: content);
    return _Card(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: AppBorderRadius.xl,
          onTap: onTap,
          child: content,
        ),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final FacultySubject subject;
  final StudentAttendance student;

  const _StudentRow({required this.subject, required this.student});

  @override
  Widget build(BuildContext context) {
    final percent = subject.percentFor(student);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  student.rollNo,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.grayLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$percent%',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: _percentColor(percent),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------- helpers

Color _percentColor(int percent) {
  if (percent >= 85) return AppColors.greenSuccess;
  if (percent >= 75) return AppColors.warning;
  return AppColors.redAbsent;
}

Color _statusColor(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return AppColors.greenPresent;
    case AttendanceStatus.absent:
      return AppColors.redAbsent;
    case AttendanceStatus.late:
      return AppColors.warning;
  }
}

String _statusLabel(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return 'Present';
    case AttendanceStatus.absent:
      return 'Absent';
    case AttendanceStatus.late:
      return 'Late';
  }
}

IconData _subjectIcon(String code) {
  switch (code) {
    case 'CS201':
      return Icons.account_tree_rounded;
    case 'CS205':
      return Icons.memory_rounded;
    default:
      return Icons.menu_book_rounded;
  }
}
