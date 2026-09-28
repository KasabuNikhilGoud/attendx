import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF007AFF);
  static const primaryRed = Color(0xFFE53935);
  static const primaryOrange = Color(0xFFFF6B35);
  static const greenSuccess = Color(0xFF28A745);
  static const greenPresent = Color(0xFF10B981);
  static const redDanger = Color(0xFFDC3545);
  static const redAbsent = Color(0xFFEF4444);
  static const blueInfo = Color(0xFF2196F3);
  static const gold = Color(0xFFFFD700);
  static const goldDark = Color(0xFFDAA520);
  static const warning = Color(0xFFFF9800);
  static const lightGreen = Color(0xFFE8F5E9);
  static const nearWhite = Color(0xFFF2F2F7);
  static const presentPill = Color(0xFFE6F5E6);
  static const absentPill = Color(0xFFFDE7E7);
  static const tableBorder = Color(0xFFE2E8F0);
  static const rowSeparator = Color(0xFFF7FAFC);
  static const darkText = Color(0xFF1A202C);
  static const neutralGray = Color(0xFF718096);
  static const surface = Color(0xFFF8F9FA);
  static const textPrimary = Color(0xFF202124);
  static const textSecondary = Color(0xFF5F6368);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 2,
          centerTitle: false,
          foregroundColor: AppColors.textPrimary,
          toolbarHeight: 70,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          labelStyle: const TextStyle(color: Colors.black54),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
      );
}

class AppShadows {
  static List<BoxShadow> get navBar => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ];

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get statCard => [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get featureCard => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get table => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          offset: const Offset(0, 2),
          blurRadius: 8,
        ),
      ];
}

class AppBorderRadius {
  static const BorderRadius xs = BorderRadius.all(Radius.circular(4));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(6));
  static const BorderRadius md = BorderRadius.all(Radius.circular(10));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(12));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(16));
  static const BorderRadius xxl = BorderRadius.all(Radius.circular(20));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(24));
  static const BorderRadius glass = BorderRadius.all(Radius.circular(32));
  static const BorderRadius button = BorderRadius.all(Radius.circular(35));
  static const BorderRadius fullPill = BorderRadius.all(Radius.circular(100));
}

class AppGradients {
  static const LinearGradient navActive = LinearGradient(
    colors: [
      Color(0xFFE53935),
      Color(0xFFE53935),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient navInactive = LinearGradient(
    colors: [
      Colors.grey.withOpacity(0.1),
      Colors.grey.withOpacity(0.05),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient attendanceHeader = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFF2196F3)],
  );

  static LinearGradient sectionAccent(Color color) => LinearGradient(
        colors: [color, color.withOpacity(0.3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient sectionBg(Color color) => LinearGradient(
        colors: [color.withOpacity(0.3), Colors.white],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  static LinearGradient featureCard(Color start, Color end) => LinearGradient(
        colors: [start, end],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static const LinearGradient goldBadge = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFC107), Color(0xFFFFB300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bottomFooter = LinearGradient(
    colors: [
      Color(0xFFE53935),
      Color(0xFFE53935),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> featureCardColors = [
    Color(0xFFd9f1ff),
    Color(0xFFd0f8dc),
    Color(0xFFffd3fe),
    Color(0xFFffe4d9),
    Color(0xFFfff4d9),
    Color(0xFFbcf3f4),
    Color(0xFFe4dfff),
    Color(0xFFffd2d7),
    Color(0xFFd3edff),
    Color(0xFFd5ffc7),
  ];
}

class AppTypography {
  static const double size7 = 7.5;
  static const double size9 = 9;
  static const double size10 = 10;
  static const double size11 = 11;
  static const double size12 = 12;
  static const double size13 = 13;
  static const double size14 = 14;
  static const double size15 = 15;
  static const double size16 = 16;
  static const double size17 = 17;
  static const double size18 = 18;
  static const double size20 = 20;
  static const double size22 = 22;
  static const double size24 = 24;
  static const double size26 = 26;
  static const double size28 = 28;
  static const double size42 = 42;
  static const double size48 = 48;
  static const double size56 = 56;
  static const double size85 = 85;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double section = 30;
  static const double form = 32;
}
