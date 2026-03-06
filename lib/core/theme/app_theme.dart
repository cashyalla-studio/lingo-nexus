import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Tokens — Scripta Sync brand palette
  static const Color background = Color(0xFF101010);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surface2 = Color(0xFF222222);
  static const Color outline = Color(0xFF333333);
  static const Color textPrimary = Color(0xFFF8F9FA);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color accentPrimary = Color(0xFF0FC8AA);   // Scripta Sync teal
  static const Color accentDim = Color(0xFF0A9E85);       // teal variant (hover/pressed)
  static const Color danger = Color(0xFFFF5252);
  static const Color success = Color(0xFF69F0AE);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        surfaceContainerHighest: surface2,
        primary: accentPrimary,
        secondary: accentDim,
        outline: outline,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        error: danger,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2, color: textPrimary),
        titleLarge: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4, color: textPrimary),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, height: 1.8, color: textPrimary),
        labelMedium: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5, color: textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 8.0,
        activeTrackColor: accentPrimary,
        inactiveTrackColor: outline,
        thumbColor: accentPrimary,
        overlayColor: accentPrimary.withValues(alpha: 0.15),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: textPrimary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface2,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
    );
  }
}
