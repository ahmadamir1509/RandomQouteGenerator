import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ─── Palette ────────────────────────────────────────────────────────────────

  static const Color _seedColor = Color(0xFF6C63FF);

  static const Color _lightBackground1 = Color(0xFFF0EFFF);
  static const Color _lightBackground2 = Color(0xFFE8F4FD);
  static const Color _darkBackground1 = Color(0xFF0D0D1A);
  static const Color _darkBackground2 = Color(0xFF1A1A2E);

  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _darkCard = Color(0xFF1E1E35);

  static const Color _lightText = Color(0xFF1A1A2E);
  static const Color _darkText = Color(0xFFF0EFFF);

  static const Color _lightSubtext = Color(0xFF6B7280);
  static const Color _darkSubtext = Color(0xFFB0BAC9);

  static const Color _accent = Color(0xFF6C63FF);

  // ─── Gradient helpers ────────────────────────────────────────────────────────

  static LinearGradient backgroundGradient(
    Brightness brightness, {
    int variant = 0,
  }) {
    // Provide a few tasteful background variants.
    if (variant == 1) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: brightness == Brightness.dark
            ? [Color(0xFF0B1222), Color(0xFF14203A)]
            : [Color(0xFFFAF7FF), Color(0xFFE7F0FF)],
      );
    }

    if (variant == 2) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: brightness == Brightness.dark
            ? [Color(0xFF0F0E1A), Color(0xFF26213A)]
            : [Color(0xFFFFFBF0), Color(0xFFF0E9FF)],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: brightness == Brightness.dark
          ? [_darkBackground1, _darkBackground2]
          : [_lightBackground1, _lightBackground2],
    );
  }

  // ─── Light theme ─────────────────────────────────────────────────────────────

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
      ),
      brightness: Brightness.light,
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _lightText,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: _lightText),
      ),
      cardTheme: CardThemeData(
        color: _lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: _accent.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textTheme: _textTheme(_lightText, _lightSubtext),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _darkCard,
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Dark theme ──────────────────────────────────────────────────────────────

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ),
      brightness: Brightness.dark,
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _darkText,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: _darkText),
      ),
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: _accent.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textTheme: _textTheme(_darkText, _darkSubtext),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _lightCard,
        contentTextStyle: GoogleFonts.poppins(fontSize: 14, color: _lightText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.4,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: primary,
        height: 1.45,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      bodyMedium: GoogleFonts.poppins(fontSize: 16, color: secondary),
      labelLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  static Color cardShadowColor(Brightness brightness) =>
      brightness == Brightness.dark
      ? Colors.black.withValues(alpha: 0.4)
      : _accent.withValues(alpha: 0.12);
}
