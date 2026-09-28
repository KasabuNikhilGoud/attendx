import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _profile;
  int _currentNavIndex = 0;

  final _navItems = const [
    {'icon': Icons.home_rounded, 'label': 'Home'},
    {'icon': Icons.settings_rounded, 'label': 'Manage'},
    {'icon': Icons.info_outline_rounded, 'label': 'Info'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await AuthService.getProfile();
    if (mounted) setState(() => _profile = p);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [_buildHome(), _buildManage(), _buildInfo()];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 2,
        flexibleSpace: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Image.asset('assets/images/logo.png', height: 60, fit: BoxFit.contain),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.primaryRed),
            onPressed: () async {
              await AuthService.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: screens[_currentNavIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.navBar,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) {
              final isActive = _currentNavIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _currentNavIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? LinearGradient(
                            colors: [
                              AppColors.primaryRed.withOpacity(0.15),
                              AppColors.primaryRed.withOpacity(0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.withOpacity(0.1),
                              Colors.grey.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: AppBorderRadius.xxl,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _navItems[i]['icon'] as IconData,
                        size: 16,
                        color: isActive ? AppColors.primaryRed : Colors.grey[400],
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Text(
                          _navItems[i]['label'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(19.65),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${_profile?['full_name'] ?? 'Admin'} 👋',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage the entire system from here',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Total Users', value: '--', color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Departments', value: '--', color: AppColors.greenSuccess)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Classes', value: '--', color: AppColors.warning)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManage() {
    final tiles = [
      {'icon': Icons.people_rounded, 'label': 'Manage Users', 'sub': 'Add, edit, remove students & faculty', 'color': AppColors.primary},
      {'icon': Icons.account_tree_rounded, 'label': 'Departments', 'sub': 'Create and manage departments', 'color': AppColors.greenSuccess},
      {'icon': Icons.class_rounded, 'label': 'Classes', 'sub': 'Manage classes and batches', 'color': AppColors.warning},
      {'icon': Icons.book_rounded, 'label': 'Subjects', 'sub': 'Assign subjects to faculty', 'color': const Color(0xFF9C27B0)},
      {'icon': Icons.how_to_reg_rounded, 'label': 'Enrollments', 'sub': 'Enroll students into classes', 'color': const Color(0xFF00BCD4)},
      {'icon': Icons.email_rounded, 'label': 'Email Settings', 'sub': 'Configure notification emails', 'color': AppColors.redDanger},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(19.65),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Management',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkText)),
          const SizedBox(height: 12),
          ...tiles.map((t) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppBorderRadius.lg,
                  boxShadow: AppShadows.card,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (t['color'] as Color).withOpacity(0.1),
                      borderRadius: AppBorderRadius.lg,
                    ),
                    child: Icon(t['icon'] as IconData, color: t['color'] as Color, size: 22),
                  ),
                  title: Text(t['label'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(t['sub'] as String,
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () {},
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('About AttendX',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'AttendX v1.0.0\nERP Attendance Management System',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppBorderRadius.lg,
          boxShadow: AppShadows.statCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
