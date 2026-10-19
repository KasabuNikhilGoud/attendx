import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/apple_pressable.dart';
import '../../core/widgets/frosted_nav_bar.dart';
import '../../core/widgets/shadcn_badge.dart';
import 'hod_mock_data.dart';

/// HOD dashboard — department overview, faculty and attendance reports.
/// Runs entirely on local mock data (offline showcase build).
class HodDashboard extends StatefulWidget {
  const HodDashboard({super.key});

  @override
  State<HodDashboard> createState() => _HodDashboardState();
}


const List<String> _tabLabels = ['Dashboard', 'Faculty', 'Reports'];

/// "Dr. Priya Patel" -> "PP" (honorifics such as Dr./Prof. are skipped).
String _initialsOf(String name) {
  const titles = {'dr', 'prof', 'mr', 'ms', 'mrs'};
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .where((word) => !titles.contains(word.replaceAll('.', '').toLowerCase()))
      .toList();
  if (words.isEmpty) return '?';
  final first = words.first[0];
  final last = words.length > 1 ? words.last[0] : '';
  return '$first$last'.toUpperCase();
}

/// Attendance thresholds: >= 85% green · >= 70% amber · below red.
Color _attendanceColor(double percent) {
  if (percent >= 85) return AppColors.greenPresent;
  if (percent >= 70) return AppColors.warning;
  return AppColors.redAbsent;
}

Color _activityColor(HodActivityStatus status) {
  switch (status) {
    case HodActivityStatus.present:
      return AppColors.greenPresent;
    case HodActivityStatus.absent:
      return AppColors.redAbsent;
    case HodActivityStatus.late:
      return AppColors.warning;
  }
}

String _activityLabel(HodActivityStatus status) {
  switch (status) {
    case HodActivityStatus.present:
      return 'Present';
    case HodActivityStatus.absent:
      return 'Absent';
    case HodActivityStatus.late:
      return 'Late';
  }
}

class _HodDashboardState extends State<HodDashboard> {
  Map<String, dynamic>? _profile;
  int _navIndex = 0;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getProfile();
    if (!mounted) return;
    setState(() => _profile = profile);
  }

  String get _hodName {
    final name = _profile?['full_name'];
    if (name is String && name.trim().isNotEmpty) return name.trim();
    return 'Dr. HOD Patel';
  }

  void _selectTab(int index) {
    if (_tabIndex == index) return;
    setState(() {
      _tabIndex = index;
      _navIndex = index == 2 ? 1 : 0;
    });
  }

  void _selectNav(int index) {
    if (_navIndex == index) return;
    setState(() {
      _navIndex = index;
      if (index == 0) _tabIndex = 0;
      if (index == 1) _tabIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/logo.png',
                height: 38,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        actions: [
          ApplePressable(
            onTap: () async {
              await AuthService.logout();
              if (!context.mounted) return;
              context.go('/login');
            },
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
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              child: _navIndex == 2
                  ? const SizedBox(width: double.infinity)
                  : _buildSegmentedControl(),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  fit: StackFit.expand,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                ),
                transitionBuilder: (child, animation) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.02),
                        end: Offset.zero,
                      ).animate(curved),
                      child: child,
                    ),
                  );
                },
                child: _buildCurrentTab(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------------------------------------------------------------- header

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 14, AppSpacing.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOD Dashboard',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Department of ${HodMockData.departmentName}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _Avatar(name: _hodName, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello 👋',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _hodName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- segmented

  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.zinc100,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.zinc200, width: 1),
        ),
        child: Row(
          children: List.generate(_tabLabels.length, (index) {
            final isSelected = _tabIndex == index;
            return Expanded(
              child: ApplePressable(
                onTap: () => _selectTab(index),
                borderRadius: BorderRadius.circular(100),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: AppCurves.spring,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                    border: isSelected
                        ? Border.all(color: AppColors.zinc200, width: 1)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    _tabLabels[index],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primaryRed
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ---------------------------------------------------------- bottom nav

  Widget _buildBottomNav() {
    return FrostedNavBar(
      currentIndex: _navIndex,
      onTap: _selectNav,
      items: const [
        FrostedNavItem(icon: Icons.home_rounded, label: 'Home'),
        FrostedNavItem(icon: Icons.analytics_rounded, label: 'Reports'),
        FrostedNavItem(icon: Icons.info_outline_rounded, label: 'Info'),
      ],
    );
  }

  // ------------------------------------------------------------- contents

  Widget _buildCurrentTab() {
    if (_navIndex == 2) return _buildInfo();
    if (_tabIndex == 1) return _buildFacultyTab();
    if (_tabIndex == 2) return _buildReportsTab();
    return _buildDashboardTab();
  }

  Widget _buildDashboardTab() {
    final average = HodMockData.averageAttendance;
    return SingleChildScrollView(
      key: const ValueKey('hod-tab-dashboard'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.section,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total Students',
                  value: '${HodMockData.students.length}',
                  color: AppColors.primaryRed,
                  icon: Icons.groups_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  label: 'Faculty',
                  value: '${HodMockData.faculty.length}',
                  color: AppColors.darkText,
                  icon: Icons.school_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Avg Attendance',
                  value: '${average.toStringAsFixed(1)}%',
                  color: _attendanceColor(average),
                  icon: Icons.insights_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  label: 'Classes',
                  value: '${HodMockData.classesThisWeek}',
                  color: AppColors.darkText,
                  icon: Icons.event_available_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _SectionHeader(
            title: 'Faculty Overview',
            caption: '${HodMockData.faculty.length} members',
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < HodMockData.faculty.length; i++) ...[
            _FacultyOverviewCard(faculty: HodMockData.faculty[i]),
            if (i != HodMockData.faculty.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.xxl),
          const _SectionHeader(title: 'Recent Activity', caption: 'Last 7 days'),
          const SizedBox(height: AppSpacing.md),
          _RecentActivityCard(records: HodMockData.recentActivity),
        ],
      ),
    );
  }

  Widget _buildFacultyTab() {
    return SingleChildScrollView(
      key: const ValueKey('hod-tab-faculty'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.section,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Department Faculty',
            caption: '${HodMockData.faculty.length} members',
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < HodMockData.faculty.length; i++) ...[
            _FacultyCard(faculty: HodMockData.faculty[i]),
            if (i != HodMockData.faculty.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      key: const ValueKey('hod-tab-reports'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.section,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SummaryCard(),
          const SizedBox(height: AppSpacing.xxl),
          _SectionHeader(
            title: 'Subject Attendance',
            caption: '${HodMockData.subjects.length} subjects',
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < HodMockData.subjects.length; i++) ...[
            _SubjectReportCard(subject: HodMockData.subjects[i]),
            if (i != HodMockData.subjects.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return SingleChildScrollView(
      key: const ValueKey('hod-info'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.section,
        AppSpacing.xl,
        AppSpacing.section,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 30,
              color: AppColors.primaryRed,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'About AttendX',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ERP Attendance Management System',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.grayLight,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppBorderRadius.xl,
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                const _InfoRow(
                  label: 'Department',
                  value: HodMockData.departmentName,
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.divider),
                _InfoRow(
                  label: 'Faculty',
                  value: '${HodMockData.faculty.length} members',
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.divider),
                _InfoRow(
                  label: 'Subjects',
                  value: '${HodMockData.subjects.length} subjects',
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.divider),
                const _InfoRow(label: 'Data Mode', value: 'Demo (mock data)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------- widgets

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ApplePressable(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(height: AppSpacing.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? caption;

  const _SectionHeader({required this.title, this.caption});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            caption!,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.neutralGray,
            ),
          ),
        ],
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final double size;

  const _Avatar({required this.name, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Text(
        _initialsOf(name),
        style: GoogleFonts.inter(
          fontSize: size * 0.32,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryRed,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool highlighted;

  const _Chip({required this.text, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return ShadcnBadge(
      label: text,
      variant: highlighted ? ShadcnBadgeVariant.secondary : ShadcnBadgeVariant.outline,
      fontSize: 11,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }
}


class _AttendanceBar extends StatelessWidget {
  final double percent;
  final Color color;

  const _AttendanceBar({
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final target = (percent / 100).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: AppBorderRadius.fullPill,
      child: Container(
        height: 6,
        color: AppColors.divider,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: target),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => FractionallySizedBox(
            widthFactor: value,
            child: Container(color: color),
          ),
        ),
      ),
    );
  }
}

class _FacultyOverviewCard extends StatelessWidget {
  final HodFaculty faculty;

  const _FacultyOverviewCard({required this.faculty});

  @override
  Widget build(BuildContext context) {
    final color = _attendanceColor(faculty.attendance);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(name: faculty.name),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faculty.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      faculty.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${faculty.attendance.toStringAsFixed(1)}%',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final subject in faculty.subjects) _Chip(text: subject),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _AttendanceBar(percent: faculty.attendance, color: color),
        ],
      ),
    );
  }
}

class _FacultyCard extends StatelessWidget {
  final HodFaculty faculty;

  const _FacultyCard({required this.faculty});

  @override
  Widget build(BuildContext context) {
    final color = _attendanceColor(faculty.attendance);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
              _Avatar(name: faculty.name, size: 48),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faculty.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      faculty.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppBorderRadius.fullPill,
                ),
                child: Text(
                  '${faculty.attendance.toStringAsFixed(1)}%',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Chip(text: faculty.department, highlighted: true),
              for (final subject in faculty.subjects) _Chip(text: subject),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.history_rounded,
                size: 15,
                color: AppColors.neutralGray,
              ),
              const SizedBox(width: 6),
              Text(
                '${faculty.records} attendance records',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final List<HodActivity> records;

  const _RecentActivityCard({required this.records});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.xl,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          for (var i = 0; i < records.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: AppColors.divider),
            _ActivityRow(record: records[i]),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final HodActivity record;

  const _ActivityRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final color = _activityColor(record.status);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  record.date,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppBorderRadius.fullPill,
            ),
            child: Text(
              _activityLabel(record.status),
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    final average = HodMockData.averageAttendance;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
                  'Overall Summary',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              Text(
                '${HodMockData.totalSessions} sessions logged',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutralGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MiniStat(
                label: 'Overall',
                value: '${average.toStringAsFixed(1)}%',
                color: _attendanceColor(average),
              ),
              _MiniStat(
                label: 'Present',
                value: '${HodMockData.totalPresent}',
                color: AppColors.greenPresent,
              ),
              _MiniStat(
                label: 'Absent',
                value: '${HodMockData.totalAbsent}',
                color: AppColors.redAbsent,
              ),
              _MiniStat(
                label: 'Late',
                value: '${HodMockData.totalLate}',
                color: AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectReportCard extends StatelessWidget {
  final HodSubject subject;

  const _SubjectReportCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    final percent = subject.attendancePercent;
    final color = _attendanceColor(percent);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subject.code,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.neutralGray,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _CountChip(
                  label: 'Present',
                  value: subject.present,
                  color: AppColors.greenPresent,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _CountChip(
                  label: 'Absent',
                  value: subject.absent,
                  color: AppColors.redAbsent,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _CountChip(
                  label: 'Late',
                  value: subject.late,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _AttendanceBar(percent: percent, color: color),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _CountChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              '$value',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
