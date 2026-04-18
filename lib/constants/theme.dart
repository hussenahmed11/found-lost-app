import 'package:flutter/material.dart';

/// App color palette matching the original React Native theme.
class AppColors {
  static const Color primary = Color(0xFF007AFF);       // Vibrant Blue
  static const Color secondary = Color(0xFF34C759);      // Found Green
  static const Color danger = Color(0xFFFF3B30);         // Lost Red
  static const Color warning = Color(0xFFFF9500);        // Alert Orange
  static const Color background = Color(0xFFF2F2F7);     // iOS Background
  static const Color surface = Color(0xFFFFFFFF);        // White
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color border = Color(0xFFC6C6C8);
  static const Color shadow = Color(0xFF000000);
}

/// Spacing constants.
class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
}

/// Border radius constants.
class AppRadius {
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double round = 999;
}

/// Box shadow presets.
class AppShadows {
  static List<BoxShadow> light = [
    BoxShadow(
      color: AppColors.shadow.withValues(alpha: 0.05),
      offset: const Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  static List<BoxShadow> medium = [
    BoxShadow(
      color: AppColors.shadow.withValues(alpha: 0.1),
      offset: const Offset(0, 4),
      blurRadius: 12,
    ),
  ];
}

/// Material ThemeData built from our design tokens.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 18,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
    ),
  );
}
