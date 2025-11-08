import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color primaryBlue = Color(0xFF6FA8DC);
  static const Color background = Color(0xFFF8F9FB);
  static const Color safeGreen = Color(0xFF2ECC71);
  static const Color warningYellow = Color(0xFFF1C40F);
  static const Color alertRed = Color(0xFFE74C3C);
}

class AppTheme {
  static ThemeData light({required bool highContrast}) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
      ),
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor:
          highContrast ? Colors.white : AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: highContrast ? Colors.black : AppColors.primaryBlue,
        foregroundColor: highContrast ? Colors.white : Colors.white,
        centerTitle: true,
      ),
      cardColor: highContrast ? Colors.white : Colors.white,
    );
  }

  static ThemeData dark({required bool highContrast}) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor:
          highContrast ? Colors.black : const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: highContrast ? Colors.black : const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      cardColor:
          highContrast ? const Color(0xFF1F1F1F) : const Color(0xFF1E1E1E),
    );
  }
}
