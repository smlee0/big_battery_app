// 앱에서 사용하는 색상 팔레트와 Light/Dark 테마 팩토리.
import 'package:flutter/material.dart';

/// 전체 UI에서 공통으로 쓰는 핵심 색상 정의.
class AppColors {
  const AppColors._();

  static const Color primaryBlue = Color(0xFF6FA8DC);
  static const Color background = Color(0xFFF8F9FB);
  static const Color safeGreen = Color(0xFF2ECC71);
  static const Color warningYellow = Color(0xFFF1C40F);
  static const Color alertRed = Color(0xFFE74C3C);
}

/// 라이트/다크 ThemeData 를 반환하는 유틸리티.
class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
      ),
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      cardColor: Colors.white,
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      cardColor: const Color(0xFF1F1F1F),
    );
  }
}
