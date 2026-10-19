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
import 'admin_mock_data.dart';

/// Admin dashboard — demo/mock mode.
///
/// Home: greeting, 2×2 stat tiles, a compact department overview and the
/// management list. Every management row opens a bottom-sheet preview backed
/// by [AdminMockData], so no tap is ever a dead end.
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

enum _ManageSection { users, departments, classes, subjects, enrollments, email }



class _ManagementEntry {
  final _ManageSection section;
  final IconData icon;
  final String title;
  final String subtitle;

  const _ManagementEntry({
    required this.section,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}



const List<_ManagementEntry> _managementEntries = [
  _ManagementEntry(
    section: _ManageSection.users,
    icon: Icons.people_rounded,
    title: 'Users',
    subtitle: 'Add, edit, remove students & faculty',
  ),
  _ManagementEntry(
    section: _ManageSection.departments,
    icon: Icons.account_tree_rounded,
    title: 'Departments',
    subtitle: 'Create and manage departments',
  ),
  _ManagementEntry(
    section: _ManageSection.classes,
    icon: Icons.class_rounded,
    title: 'Classes',
    subtitle: 'Manage classes and batches',
  ),
  _ManagementEntry(
    section: _ManageSection.subjects,
    icon: Icons.book_rounded,
    title: 'Subjects',
    subtitle: 'Assign subjects to faculty',
  ),
  _ManagementEntry(
    section: _ManageSection.enrollments,
    icon: Icons.how_to_reg_rounded,
    title: 'Enrollments',
    subtitle: 'Enroll students into classes',
  ),
  _ManagementEntry(
    section: _ManageSection.email,
    icon: Icons.email_rounded,
    title: 'Email Settings',
    subtitle: 'Configure notification emails',
  ),
];

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _profile;
  int _currentNavIndex = 0;

  static const EdgeInsets _pagePadding = EdgeInsets.fromLTRB(
    AppSpacing.xl,
    AppSpacing.xl,
    AppSpacing.xl,
    AppSpacing.form,
  );

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getProfile();
    if (mounted) setState(() => _profile = profile);
  }

  String get _adminName => (_profile?['full_name'] as String?) ?? 'Admin User';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
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
        child: _buildCurrentTab(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentNavIndex) {
      case 1:
        return _buildManageTab();
      case 2:
        return _buildInfoTab();
      default:
        return _buildHomeTab();
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: Colors.white.withValues(alpha: 0.85),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
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
            if (mounted) context.go('/login');
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
        const SizedBox(width: AppSpacing.xs),
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
        FrostedNavItem(icon: Icons.settings_rounded, label: 'Manage'),
        FrostedNavItem(icon: Icons.info_outline_rounded, label: 'Info'),
      ],
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      key: const ValueKey('admin-home'),
      padding: _pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $_adminName 👋',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Manage the entire system',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people_alt_rounded,
                  label: 'Total Users',
                  value: '${AdminMockData.totalUsers}',
                  accent: AppColors.primaryRed,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: Icons.account_tree_rounded,
                  label: 'Departments',
                  value: '${AdminMockData.totalDepartments}',
                  accent: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.groups_rounded,
                  label: 'Classes',
                  value: '${AdminMockData.totalClasses}',
                  accent: AppColors.neutralGray,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: Icons.book_rounded,
                  label: 'Subjects',
                  value: '${AdminMockData.totalSubjects}',
                  accent: AppColors.primaryRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          const _SectionTitle('Overview'),
          const SizedBox(height: AppSpacing.md),
          const _OverviewCard(),
          const SizedBox(height: AppSpacing.section),
          const _SectionTitle('Management'),
          const SizedBox(height: AppSpacing.md),
          _buildManagementList(),
        ],
      ),
    );
  }

  Widget _buildManageTab() {
    return SingleChildScrollView(
      key: const ValueKey('admin-manage'),
      padding: _pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Management',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Open a section to preview its data',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildManagementList(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      key: const ValueKey('admin-info'),
      padding: _pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Info',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const _AboutCard(),
        ],
      ),
    );
  }

  Widget _buildManagementList() {
    return Column(
      children: [
        for (final entry in _managementEntries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _ManagementTile(
              entry: entry,
              onTap: () => _openSection(entry),
            ),
          ),
      ],
    );
  }

  void _openSection(_ManagementEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SectionSheet(
        section: entry.section,
        icon: entry.icon,
        title: entry.title,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: AppColors.darkText,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
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
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: AppBorderRadius.sm,
            ),
            child: Icon(icon, size: 17, color: accent),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.0,
              color: accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
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
  );
}
}

class _ManagementTile extends StatelessWidget {
  final _ManagementEntry entry;
  final VoidCallback onTap;

  const _ManagementTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ApplePressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withValues(alpha: 0.08),
                    borderRadius: AppBorderRadius.lg,
                  ),
                  child: Icon(entry.icon, size: 21, color: AppColors.primaryRed),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.grayLight,
                ),
              ],
            ),
          ),
        ),
      );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard();

  @override
  Widget build(BuildContext context) {
    final departments = AdminMockData.departments;
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
      child: Column(
        children: [
          for (var i = 0; i < departments.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 14,
              ),
              child: Row(
                children: [
                  const _EntityIcon(Icons.account_tree_rounded),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                departments[i].name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _CodePill(code: departments[i].code),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${departments[i].facultyCount}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkText,
                                ),
                              ),
                              TextSpan(
                                text: ' faculty · ',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text: '${departments[i].studentCount}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkText,
                                ),
                              ),
                              TextSpan(
                                text: ' students',
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
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CodePill extends StatelessWidget {
  final String code;

  const _CodePill({required this.code});

  @override
  Widget build(BuildContext context) {
    return ShadcnBadge(
      label: code,
      variant: ShadcnBadgeVariant.secondary,
      fontSize: 10.5,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.xl,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.08),
              borderRadius: AppBorderRadius.xl,
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 30,
              color: AppColors.primaryRed,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppConstants.appName,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version ${AppConstants.appVersion}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'A simple ERP attendance management system for users, '
            'departments, classes, subjects and enrollments — all in one place.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionSheet extends StatelessWidget {
  final _ManageSection section;
  final IconData icon;
  final String title;

  const _SectionSheet({
    required this.section,
    required this.icon,
    required this.title,
  });

  String get _descriptor {
    switch (section) {
      case _ManageSection.users:
        return '${AdminMockData.students.length} students · '
            '${AdminMockData.faculty.length} faculty';
      case _ManageSection.departments:
        return '${AdminMockData.totalDepartments} departments';
      case _ManageSection.classes:
        return '${AdminMockData.totalClasses} classes';
      case _ManageSection.subjects:
        return '${AdminMockData.totalSubjects} subjects · '
            '${AdminMockData.totalCredits} credits';
      case _ManageSection.enrollments:
        return '${AdminMockData.classes.first.studentCount} students enrolled';
      case _ManageSection.email:
        return 'Outgoing mail configuration';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grayLight.withValues(alpha: 0.6),
                borderRadius: AppBorderRadius.fullPill,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withValues(alpha: 0.08),
                      borderRadius: AppBorderRadius.md,
                    ),
                    child: Icon(icon, size: 20, color: AppColors.primaryRed),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _descriptor,
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
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.xxl,
                ),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (section) {
      case _ManageSection.users:
        return _buildUsers();
      case _ManageSection.departments:
        return _buildDepartments();
      case _ManageSection.classes:
        return _buildClasses();
      case _ManageSection.subjects:
        return _buildSubjects();
      case _ManageSection.enrollments:
        return _buildEnrollments();
      case _ManageSection.email:
        return _buildEmail();
    }
  }

  Widget _buildUsers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SheetLabel('Students · ${AdminMockData.students.length}'),
        for (final student in AdminMockData.students)
          _SheetListRow(
            leading: _InitialsAvatar(name: student.name),
            title: student.name,
            subtitle: '${student.rollNo} · ${student.email}',
          ),
        _SheetLabel('Faculty · ${AdminMockData.faculty.length}'),
        for (final member in AdminMockData.faculty)
          _SheetListRow(
            leading: _InitialsAvatar(name: member.name),
            title: member.name,
            subtitle: member.email,
            trailing: _TrailingText('${member.subjects.length} subjects'),
          ),
      ],
    );
  }

  Widget _buildDepartments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SheetLabel('All departments · ${AdminMockData.totalDepartments}'),
        for (final department in AdminMockData.departments)
          _SheetListRow(
            leading: const _EntityIcon(Icons.account_tree_rounded),
            title: department.name,
            subtitle: 'HOD · ${department.hod}',
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _CountText(
                  value: '${department.facultyCount}',
                  label: 'faculty',
                ),
                const SizedBox(height: 2),
                _CountText(
                  value: '${department.studentCount}',
                  label: 'students',
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildClasses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SheetLabel('All classes · ${AdminMockData.totalClasses}'),
        for (final adminClass in AdminMockData.classes)
          _SheetListRow(
            leading: const _EntityIcon(Icons.groups_rounded),
            title: adminClass.name,
            subtitle: '${adminClass.department} · ${adminClass.year} Year',
            trailing: _TrailingText('${adminClass.studentCount} students'),
          ),
      ],
    );
  }

  Widget _buildSubjects() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SheetLabel('All subjects · ${AdminMockData.totalSubjects}'),
        for (final subject in AdminMockData.subjects)
          _SheetListRow(
            leading: const _EntityIcon(Icons.book_rounded),
            title: subject.name,
            subtitle: '${subject.code} · ${subject.faculty}',
            trailing: _TrailingText('${subject.credits} credits'),
          ),
      ],
    );
  }

  Widget _buildEnrollments() {
    final primaryClass = AdminMockData.classes.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SheetLabel(
          '${primaryClass.name} · ${primaryClass.studentCount} enrolled',
        ),
        for (final student in AdminMockData.students)
          _SheetListRow(
            leading: _InitialsAvatar(name: student.name),
            title: student.name,
            subtitle: student.rollNo,
          ),
        _SheetLabel('Other classes'),
        for (final adminClass in AdminMockData.classes.skip(1))
          _SheetListRow(
            leading: const _EntityIcon(Icons.groups_rounded),
            title: adminClass.name,
            subtitle: '${adminClass.department} · ${adminClass.year} Year',
            trailing: _TrailingText('${adminClass.studentCount} students'),
          ),
      ],
    );
  }

  Widget _buildEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SheetLabel('Mail server'),
        const _EmailRow(label: 'Sender name', value: AdminMockData.senderName),
        const Divider(height: 1),
        const _EmailRow(
          label: 'Sender email',
          value: AdminMockData.senderEmail,
        ),
        const Divider(height: 1),
        const _EmailRow(label: 'SMTP host', value: AdminMockData.smtpHost),
        const Divider(height: 1),
        const _EmailRow(label: 'Port · security', value: AdminMockData.smtpPort),
        const SizedBox(height: AppSpacing.lg),
        const _SheetLabel('Notifications'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final item in AdminMockData.notifications)
              _NotificationChip(label: item),
          ],
        ),
      ],
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;

  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.neutralGray,
        ),
      ),
    );
  }
}

class _SheetListRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SheetListRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          leading,
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                  subtitle,
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
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String name;

  const _InitialsAvatar({required this.name});

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
    );
  }
}

class _EntityIcon extends StatelessWidget {
  final IconData icon;

  const _EntityIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.md,
      ),
      child: Icon(icon, size: 18, color: AppColors.textSecondary),
    );
  }
}

class _TrailingText extends StatelessWidget {
  final String text;

  const _TrailingText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _CountText extends StatelessWidget {
  final String value;
  final String label;

  const _CountText({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          TextSpan(
            text: ' $label',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailRow extends StatelessWidget {
  final String label;
  final String value;

  const _EmailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationChip extends StatelessWidget {
  final String label;

  const _NotificationChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withValues(alpha: 0.08),
        borderRadius: AppBorderRadius.fullPill,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryRed,
        ),
      ),
    );
  }
}
