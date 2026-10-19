import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/apple_pressable.dart';
import '../../core/widgets/shadcn_button.dart';

/// AttendX sign-in — iOS-style: one white card on a dimmed photo,
/// generous whitespace, a single red accent and subtle entrance motion.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const BorderRadius _cardRadius = BorderRadius.all(Radius.circular(24));

  final _emailCtrl = TextEditingController(text: 'admin@attendx.com');
  final _passCtrl = TextEditingController(text: 'admin123');
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _obscure = true;
  String? _error;
  String _selectedDemo = 'admin';

  late final AnimationController _entrance;
  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardOffset;
  late final Animation<double> _footerOpacity;

  static const List<Map<String, String>> _demoAccounts = [
    {
      'role': 'admin',
      'email': 'admin@attendx.com',
      'pass': 'admin123',
      'label': 'Admin',
    },
    {
      'role': 'hod',
      'email': 'hod@attendx.com',
      'pass': 'hod123',
      'label': 'HOD',
    },
    {
      'role': 'faculty',
      'email': 'faculty@attendx.com',
      'pass': 'faculty123',
      'label': 'Faculty',
    },
    {
      'role': 'student',
      'email': 'student@attendx.com',
      'pass': 'student123',
      'label': 'Student',
    },
  ];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _cardOpacity = _entrance.drive(
      CurveTween(curve: const Interval(0, 0.7, curve: Curves.easeOutCubic)),
    );
    _cardOffset = _entrance.drive(
      Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic)),
    );
    _footerOpacity = _entrance.drive(
      CurveTween(curve: const Interval(0.4, 1, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _selectDemo(Map<String, String> acc) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedDemo = acc['role']!;
      _emailCtrl.text = acc['email']!;
      _passCtrl.text = acc['pass']!;
      _error = null;
    });
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await AuthService.login(_emailCtrl.text.trim(), _passCtrl.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (res['success'] == true) {
      final role = res['role'] as String?;
      switch (role) {
        case UserRole.student:
          context.go('/student');
          break;
        case UserRole.faculty:
          context.go('/faculty');
          break;
        case UserRole.hod:
          context.go('/hod');
          break;
        case UserRole.admin:
          context.go('/admin');
          break;
        default:
          setState(() => _error = 'Unknown role. Contact admin.');
      }
    } else {
      setState(() => _error = res['message'] as String? ?? 'Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dark system UI icons — the screen sits on a clean white background.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Soft neutral glow so the white card reads on a white canvas.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF7F7F8), Colors.white],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.section,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeTransition(
                        opacity: _cardOpacity,
                        child: SlideTransition(
                          position: _cardOffset,
                          child: _buildCard(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FadeTransition(
                        opacity: _footerOpacity,
                        child: Text(
                          'AttendX — ERP Attendance System',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.neutralGray,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _cardRadius,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBrandRow(),
            const SizedBox(height: AppSpacing.section),
            _buildEmailField(),
            const SizedBox(height: AppSpacing.lg),
            _buildPasswordField(),
            _buildErrorBanner(),
            const SizedBox(height: AppSpacing.xl),
            _buildSignInButton(),
            const SizedBox(height: AppSpacing.md),
            _buildSignUpRow(),
            const SizedBox(height: AppSpacing.xl),
            _buildDemoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandRow() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primaryRed,
            borderRadius: AppBorderRadius.xl,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryRed.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ERP Dashboard',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: const [AutofillHints.email],
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(
          Icons.mail_outline_rounded,
          size: 20,
          color: AppColors.neutralGray,
        ),
      ),
      validator: (v) =>
          v == null || !v.contains('@') ? 'Enter a valid email' : null,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passCtrl,
      obscureText: _obscure,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          size: 20,
          color: AppColors.neutralGray,
        ),
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Show password' : 'Hide password',
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
            color: AppColors.neutralGray,
          ),
        ),
      ),
      validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
      onFieldSubmitted: (_) {
        if (!_loading) _login();
      },
    );
  }

  Widget _buildErrorBanner() {
    final error = _error;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1,
          child: child,
        ),
      ),
      child: error == null
          ? const SizedBox.shrink(key: ValueKey<String>('no-error'))
          : Container(
              key: ValueKey<String>(error),
              margin: const EdgeInsets.only(top: AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.absentPill,
                borderRadius: AppBorderRadius.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 16,
                    color: AppColors.redDanger,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      error,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.redDanger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSignInButton() {
    return ShadcnButton(
      text: 'Sign In',
      variant: ShadcnButtonVariant.brand,
      size: ShadcnButtonSize.lg,
      fullWidth: true,
      isLoading: _loading,
      onPressed: _login,
    );
  }

  Widget _buildSignUpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'New to AttendX?',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => context.go('/signup'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Sign up'),
        ),
      ],
    );
  }

  Widget _buildDemoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Expanded(
              child: Divider(color: AppColors.border, height: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'Demo accounts',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralGray,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const Expanded(
              child: Divider(color: AppColors.border, height: 1),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.center,
          children: _demoAccounts.map(_buildDemoPill).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Tap a role to auto-fill credentials',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.neutralGray,
          ),
        ),
      ],
    );
  }

  Widget _buildDemoPill(Map<String, String> acc) {
    final isActive = _selectedDemo == acc['role'];
    return ApplePressable(
      onTap: () => _selectDemo(acc),
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: AppCurves.spring,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryRed : AppColors.zinc100,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isActive ? AppColors.primaryRed : AppColors.zinc200,
            width: 1,
          ),
        ),
        child: Text(
          acc['label']!,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

