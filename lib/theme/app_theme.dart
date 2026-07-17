import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet warna dinamis: menyesuaikan otomatis ke light/dark
/// berdasarkan Theme.of(context).brightness saat ini.
class AppColors {
  final bool isDark;
  const AppColors._(this.isDark);

  static AppColors of(BuildContext context) {
    return AppColors._(Theme.of(context).brightness == Brightness.dark);
  }

  // Brand color, sama di kedua mode.
  Color get primary => const Color(0xFF6C63FF);
  Color get primaryLight => const Color(0xFF9C93FF);
  Color get accent => const Color(0xFF00E5C7);
  Color get danger => const Color(0xFFFF6584);
  Color get success => const Color(0xFF2ED8A7);
  Color get gold => const Color(0xFFFFC542);

  Color get background => isDark ? const Color(0xFF0F1120) : const Color(0xFFF4F5FA);
  Color get surface => isDark ? const Color(0xFF1A1D33) : Colors.white;
  Color get surfaceLight => isDark ? const Color(0xFF242847) : const Color(0xFFEEF0F8);
  Color get textPrimary => isDark ? const Color(0xFFF5F5FA) : const Color(0xFF1D1E33);
  Color get textSecondary => isDark ? const Color(0xFFA0A3BD) : const Color(0xFF6E7191);
  Color get border => isDark ? Colors.white12 : const Color(0xFFE3E5F0);

  LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6C63FF), Color(0xFF4834D4)],
      );

  LinearGradient get goldGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFC542), Color(0xFFFF9F45)],
      );
}

/// Biar gampang dipakai: `context.colors.primary` dst, tanpa perlu
/// manggil AppColors.of(context) berulang-ulang.
extension AppColorsX on BuildContext {
  AppColors get colors => AppColors.of(this);
}

class AppTheme {
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final Color background = isDark ? const Color(0xFF0F1120) : const Color(0xFFF4F5FA);
    final Color surface = isDark ? const Color(0xFF1A1D33) : Colors.white;
    final Color surfaceLight = isDark ? const Color(0xFF242847) : const Color(0xFFEEF0F8);
    final Color textPrimary = isDark ? const Color(0xFFF5F5FA) : const Color(0xFF1D1E33);
    final Color textSecondary = isDark ? const Color(0xFFA0A3BD) : const Color(0xFF6E7191);
    const Color primary = Color(0xFF6C63FF);
    const Color accent = Color(0xFF00E5C7);
    const Color danger = Color(0xFFFF6584);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: GoogleFonts.poppins().fontFamily,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: Colors.black,
        error: danger,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.poppins(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
      dividerColor: isDark ? Colors.white12 : const Color(0xFFE3E5F0),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? surfaceLight : textPrimary,
        contentTextStyle: TextStyle(color: isDark ? textPrimary : Colors.white),
        actionTextColor: primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}