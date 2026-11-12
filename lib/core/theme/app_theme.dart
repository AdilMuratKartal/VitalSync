import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Ortak Material 3 Açık (Light) ve Koyu (Dark) tema yapılandırması.
class AppTheme {
  /// Uygulama genelinde açık/koyu tema geçişini yönetmek için ortak kontrolcü.
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  /// Açık Tema (Stitch Klinik Tasarım Paleti)
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      inversePrimary: AppColors.inversePrimary,
      surfaceTint: AppColors.surfaceTint,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: 'Plus Jakarta Sans',
      textTheme: _buildTextTheme(AppColors.onSurface, AppColors.onSurfaceVariant),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceContainerHigh,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Koyu Tema (Gece Modu / Klinik Koyu Palet)
  static ThemeData get darkTheme {
    const darkSurface = Color(0xFF0B1520);
    const darkOnSurface = Color(0xFFEAF2F8);
    const darkOnSurfaceVariant = Color(0xFFA3B8C2);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primaryFixedDim,
      onPrimary: AppColors.onPrimaryFixed,
      primaryContainer: AppColors.primary,
      onPrimaryContainer: AppColors.primaryFixed,
      secondary: AppColors.secondaryFixedDim,
      onSecondary: AppColors.onSecondaryFixed,
      secondaryContainer: AppColors.onSecondaryFixedVariant,
      onSecondaryContainer: AppColors.secondaryFixed,
      tertiary: AppColors.tertiaryFixedDim,
      error: const Color(0xFFFFB4AB),
      surface: darkSurface,
      onSurface: darkOnSurface,
      onSurfaceVariant: darkOnSurfaceVariant,
      outline: const Color(0xFF5C707A),
      outlineVariant: const Color(0xFF233845),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkSurface,
      fontFamily: 'Plus Jakarta Sans',
      textTheme: _buildTextTheme(darkOnSurface, darkOnSurfaceVariant),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF1E313E),
        thickness: 1,
        space: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primaryText, Color secondaryText) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 34,
        height: 41 / 34,
        letterSpacing: -0.68,
        fontWeight: FontWeight.w700,
        color: primaryText,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 28,
        height: 34 / 28,
        letterSpacing: -0.42,
        fontWeight: FontWeight.w700,
        color: primaryText,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 24,
        height: 30 / 24,
        letterSpacing: -0.24,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 20,
        height: 26 / 20,
        letterSpacing: -0.1,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 18,
        height: 24 / 18,
        letterSpacing: -0.09,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 17,
        height: 22 / 17,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 17,
        height: 24 / 17,
        fontWeight: FontWeight.w400,
        color: primaryText,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w400,
        color: primaryText,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.12,
        fontWeight: FontWeight.w400,
        color: secondaryText,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 15,
        height: 20 / 15,
        letterSpacing: -0.075,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w500,
        color: primaryText,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 11,
        height: 14 / 11,
        letterSpacing: 0.22,
        fontWeight: FontWeight.w600,
        color: secondaryText,
      ),
    );
  }
}
