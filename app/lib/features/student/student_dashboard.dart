import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/apple_pressable.dart';
import '../../core/widgets/frosted_nav_bar.dart';
import '../../core/widgets/shadcn_badge.dart';
import 'student_mock_data.dart';

/// Green >= 75%, amber 60-74%, red below 60%.
Color _attendanceColor(double percent) => switch (percent) {
      >= 75 => AppColors.greenSuccess,
      >= 60 => AppColors.warning,
      _ => AppColors.redAbsent,
    };

String _attendanceLabel(double percent) => switch (percent) {
      >= 75 => 'Good standing',
      >= 60 => 'Needs improvement',
      _ => 'At risk',
    };

Color _statusColor(AttendanceStatus status) => switch (status) {
      AttendanceStatus.present => AppColors.greenPresent,
      AttendanceStatus.absent => AppColors.redAbsent,
      AttendanceStatus.late => AppColors.warning,
    };

String _statusLabel(AttendanceStatus status) => switch (status) {
      AttendanceStatus.present => 'Present',
      AttendanceStatus.absent => 'Absent',
      AttendanceStatus.late => 'Late',
    };

String _initialsOf(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return '?';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}


class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {

  Map<String, dynamic>? _profile;
  int _currentNavIndex = 0;
  String? _historyFilter;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    Map<String, dynamic>? profile;
    try {
      profile = await AuthService.getProfile();
    } catch (_) {
      // Offline showcase build: fall back to the mock identity.
      profile = null;
    }
    if (!mounted) {
      return;
    }
    setState(() => _profile = profile);
  }

  Future<void> _handleLogout() async {
    try {
      await AuthService.logout();
    } catch (_) {
      // Demo mode has no backend session to clear — sign out locally only.
      debugPrint('AuthService.logout skipped (demo mode).');
    }
    if (mounted) {
      context.go('/login');
    }
  }

  /// Shows a confirmation dialog, then signs the student out.
  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppBorderRadius.xl),
        title: Text(
          'Log out?',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        content: Text(
          'You will be signed out of your student account on this device.',
          style: GoogleFonts.inter(
            fontSize: 13.5,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _handleLogout();
    }
  }

  String get _studentName {
    final name = _profile?['full_name'];
    if (name is String && name.trim().isNotEmpty) {
      return name.trim();
    }
    return StudentMockData.fullNameFallback;
  }

  String get _studentEmail {
    final email = _profile?['email'];
    if (email is String && email.trim().isNotEmpty) {
      return email.trim();
    }
    return StudentMockData.email;
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[_buildHome(), _buildHistory(), _buildInfo()];
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey(_currentNavIndex),
          child: pages[_currentNavIndex],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.85),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Image.asset(
        'assets/images/logo.png',
        height: 38,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Text(
          AppConstants.appName,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: ApplePressable(
          onTap: () => setState(() => _currentNavIndex = 2),
          borderRadius: BorderRadius.circular(100),
          child: Tooltip(
            message: 'Profile',
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.all(6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryRed.withValues(alpha: 0.20),
                  width: 1,
                ),
              ),
              child: Text(
                _initialsOf(_studentName),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryRed,
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        ApplePressable(
          onTap: _confirmLogout,
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
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: SizedBox(
          height: 1,
          width: double.infinity,
          child: ColoredBox(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return FrostedNavBar(
      currentIndex: _currentNavIndex,
      onTap: (index) => setState(() => _currentNavIndex = index),
      items: const [
        FrostedNavItem(icon: Icons.home_rounded, label: 'Home'),
        FrostedNavItem(icon: Icons.calendar_month_rounded, label: 'View'),
        FrostedNavItem(icon: Icons.info_outline_rounded, label: 'Info'),
      ],
    );
  }


  // ---------------------------------------------------------------- Home tab

  Widget _buildHome() {
    final overall = StudentMockData.overallPercent;
    final recent = StudentMockData.records.take(6).toList();
    final atRisk = StudentMockData.belowRequirement;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $_studentName 👋',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Here is your ${StudentMockData.semester.toLowerCase()} attendance summary.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _OverallAttendanceCard(
            percent: overall,
            attended: StudentMockData.totalClassesAttended,
            held: StudentMockData.totalClassesHeld,
          ),
          const SizedBox(height: AppSpacing.lg),
          const _QuickStatsRow(),
          if (atRisk.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _AtRiskBanner(subjects: atRisk),
          ],
          const SizedBox(height: AppSpacing.section),
          const _SectionHeader(
            title: 'Subject-wise Attendance',
            trailing: 'Tap to expand',
          ),
          const SizedBox(height: AppSpacing.md),
          for (final subject in StudentMockData.subjects) ...[
            _SubjectCard(subject: subject),
            const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(
            title: 'Recent Attendance',
            action: 'See all',
            onAction: () => setState(() => _currentNavIndex = 1),
          ),
          const SizedBox(height: AppSpacing.md),
          if (recent.isEmpty)
            const _EmptyStateCard(
              message: 'No attendance recorded yet.',
            )
          else
            _TimelineCard(records: recent),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- View tab

  Widget _buildHistory() {
    final all = StudentMockData.records;
    final selected = _historyFilter == null
        ? null
        : StudentMockData.subjectByCode(_historyFilter!);
    final records = _historyFilter == null
        ? all
        : StudentMockData.recordsForSubject(_historyFilter!);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance History',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${all.length} recent entries · ${StudentMockData.totalClassesHeld} '
            'classes held this semester',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _historyFilter == null,
                  onTap: () => setState(() => _historyFilter = null),
                ),
                for (final subject in StudentMockData.subjects)
                  _FilterChip(
                    label: subject.code,
                    selected: _historyFilter == subject.code,
                    onTap: () => setState(
                      () => _historyFilter = _historyFilter == subject.code
                          ? null
                          : subject.code,
                    ),
                  ),
              ],
            ),
          ),
          if (selected != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              '${selected.name} · ${selected.percent.round()}% attendance',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            child: records.isEmpty
                ? const _EmptyStateCard(
                    key: ValueKey('history-empty'),
                    message: 'No attendance records for this subject.',
                  )
                : _TimelineCard(
                    key: ValueKey(_historyFilter ?? 'all'),
                    records: records,
                  ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- Info tab

  Widget _buildInfo() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Student account details',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppBorderRadius.xl,
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _initialsOf(_studentName),
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _studentName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            StudentMockData.rollNumber,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.xs),
                const _InfoRow(
                  icon: Icons.badge_outlined,
                  label: 'Roll Number',
                  value: StudentMockData.rollNumber,
                ),
                const _InfoRow(
                  icon: Icons.school_outlined,
                  label: 'Department',
                  value: StudentMockData.department,
                ),
                const _InfoRow(
                  icon: Icons.timeline_rounded,
                  label: 'Year & Semester',
                  value: '${StudentMockData.year} · ${StudentMockData.semester}',
                ),
                _InfoRow(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: _studentEmail,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppBorderRadius.xl,
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'About AttendX',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppBorderRadius.fullPill,
                      ),
                      child: Text(
                        'v${AppConstants.appVersion}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'ERP attendance management system for students, faculty and administration.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppBorderRadius.xl,
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Signed in as $_studentEmail',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _confirmLogout,
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Log out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryRed,
                      side: const BorderSide(
                        color: AppColors.primaryRed,
                        width: 1.2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.lg,
                      ),
                      textStyle: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ Widgets

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing, this.action, this.onAction});

  final String title;
  final String? trailing;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.darkText,
            ),
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Text(
              action!,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryRed,
              ),
            ),
          )
        else if (trailing != null)
          Text(
            trailing!,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.grayLight,
            ),
          ),
      ],
    );
  }
}

class _OverallAttendanceCard extends StatelessWidget {
  const _OverallAttendanceCard({
    required this.percent,
    required this.attended,
    required this.held,
  });

  final double percent;
  final int attended;
  final int held;

  @override
  Widget build(BuildContext context) {
    final color = _attendanceColor(percent);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Overall Attendance',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ShadcnBadge(
                label: _attendanceLabel(percent),
                variant: percent >= 75
                    ? ShadcnBadgeVariant.success
                    : (percent >= 60
                        ? ShadcnBadgeVariant.warning
                        : ShadcnBadgeVariant.destructive),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: percent),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => Text(
                  '${value.round()}%',
                  style: GoogleFonts.inter(
                    fontSize: 40,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '$attended of $held classes attended',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _PercentBar(percent: percent, color: color),
        ],
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Present',
            caption: 'recent',
            value: StudentMockData.countWithStatus(AttendanceStatus.present),
            color: AppColors.greenPresent,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatTile(
            label: 'Absent',
            caption: 'recent',
            value: StudentMockData.countWithStatus(AttendanceStatus.absent),
            color: AppColors.redAbsent,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatTile(
            label: 'Late',
            caption: 'recent',
            value: StudentMockData.countWithStatus(AttendanceStatus.late),
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.caption,
    required this.value,
    required this.color,
  });

  final String label;
  final String caption;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ApplePressable(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(height: 10),
            Text(
              '$value',
              style: GoogleFonts.inter(
                fontSize: 20,
                height: 1,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$label · $caption',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AtRiskBanner extends StatelessWidget {
  const _AtRiskBanner({required this.subjects});

  final List<StudentSubject> subjects;

  @override
  Widget build(BuildContext context) {
    final summary =
        subjects.map((s) => '${s.code} ${s.percent.round()}%').join('   ·   ');
    final plural = subjects.length == 1 ? 'subject' : 'subjects';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: AppBorderRadius.xl,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Below 75% in ${subjects.length} $plural',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  summary,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PercentBar extends StatelessWidget {
  const _PercentBar({
    required this.percent,
    required this.color,
    this.height = 8,
  });

  final double percent;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final factor = (percent / 100).clamp(0.0, 1.0).toDouble();
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: AppBorderRadius.fullPill,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.divider),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: factor),
              duration: const Duration(milliseconds: 750),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: AppBorderRadius.fullPill,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatefulWidget {
  const _SubjectCard({required this.subject});

  final StudentSubject subject;

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;
    final color = _attendanceColor(subject.percent);
    final records = StudentMockData.recordsForSubject(subject.code);
    return Container(
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          splashColor: AppColors.primaryRed.withValues(alpha: 0.05),
          highlightColor: AppColors.primaryRed.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
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
                            subject.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${subject.code} · ${subject.faculty}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      '${subject.percent.round()}%',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColors.grayLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _PercentBar(percent: subject.percent, color: color, height: 6),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _expanded
                      ? _buildRecords(records)
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecords(List<StudentAttendanceRecord> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.sm),
        if (records.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              'No recent classes recorded.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          for (final record in records)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _statusColor(record.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${record.date} · ${record.time}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(status: record.status, dense: true),
                ],
              ),
            ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, this.dense = false});

  final AttendanceStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    ShadcnBadgeVariant variant;
    switch (status) {
      case AttendanceStatus.present:
        variant = ShadcnBadgeVariant.success;
        break;
      case AttendanceStatus.absent:
        variant = ShadcnBadgeVariant.destructive;
        break;
      case AttendanceStatus.late:
        variant = ShadcnBadgeVariant.warning;
        break;
    }

    return ShadcnBadge(
      label: _statusLabel(status),
      variant: variant,
      fontSize: dense ? 10 : 11.5,
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 7 : 9,
        vertical: dense ? 2 : 4,
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({super.key, required this.records});

  final List<StudentAttendanceRecord> records;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
      child: Column(
        children: [
          for (var i = 0; i < records.length; i++)
            _TimelineRow(
              record: records[i],
              isFirst: i == 0,
              isLast: i == records.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.record,
    required this.isFirst,
    required this.isLast,
  });

  static const double _dotOffset = 15;
  static const double _dotSize = 10;

  final StudentAttendanceRecord record;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final subject = StudentMockData.subjectByCode(record.subjectCode);
    final color = _statusColor(record.status);
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Stack(
              children: [
                if (!isFirst)
                  Positioned(
                    left: 9,
                    top: 0,
                    height: _dotOffset + _dotSize / 2,
                    child: Container(
                      width: 2,
                      decoration: const BoxDecoration(
                        color: AppColors.border,
                        borderRadius: AppBorderRadius.fullPill,
                      ),
                    ),
                  ),
                if (!isLast)
                  Positioned(
                    left: 9,
                    top: _dotOffset + _dotSize / 2,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      decoration: const BoxDecoration(
                        color: AppColors.border,
                        borderRadius: AppBorderRadius.fullPill,
                      ),
                    ),
                  ),
                Positioned(
                  left: 5,
                  top: _dotOffset,
                  child: Container(
                    width: _dotSize,
                    height: _dotSize,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject?.name ?? record.subjectCode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${record.date} · ${record.time}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: _StatusPill(status: record.status),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryRed : Colors.white,
            borderRadius: AppBorderRadius.fullPill,
            boxShadow: selected ? null : AppShadows.featureCard,
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.xl,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_busy_rounded,
            size: 28,
            color: AppColors.grayLight,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.grayLight),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
