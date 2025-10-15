import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Enhanced colors for a more premium look
  static final Color _lightPrimaryColor = Color(0xFF2563EB);
  static final Color _darkPrimaryColor = Color(0xFF60A5FA);

  // Gradient colors
  static final List<Color> primaryGradient = [
    Color(0xFF2563EB), // Primary blue
    Color(0xFF3B82F6), // Lighter blue
  ];

  static final List<Color> surfaceGradient = [
    Color(0xFFF8FAFC),
    Colors.white,
  ];

  static final List<Color> cardGradient = [
    Colors.white,
    Color(0xFFF8FAFC),
  ];

  // Category card colors
  static final Map<String, List<Color>> categoryGradients = {
    'Arcade': [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    'Classic Board': [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    'Word Games': [Color(0xFFEF4444), Color(0xFFF87171)],
    'Brain Training': [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    'Puzzle': [Color(0xFFF97316), Color(0xFFFB923C)],
    'Quick Casual': [Color(0xFF22C55E), Color(0xFF4ADE80)],
    'Strategy': [Color(0xFF14B8A6), Color(0xFF2DD4BF)],
    'Reaction': [Color(0xFFFACC15), Color(0xFFFDE047)],
    'Educational': [Color(0xFF6366F1), Color(0xFF818CF8)],
  };

  // Enhanced text themes with better hierarchy
  static final _lightTextTheme = TextTheme(
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      color: Colors.black.withValues(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 0.87 * 255,
      ),
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: Colors.black.withValues(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 0.87 * 255,
      ),
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: Colors.black.withValues(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 0.87 * 255,
      ),
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: Colors.black.withValues(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 0.87 * 255,
      ),
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: Colors.black.withValues(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 0.87 * 255,
      ),
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: Colors.black.withValues(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 0.87 * 255,
      ),
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      color: Colors.black.withValues(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 0.87 * 255,
      ),
    ),
  );

  static final _darkTextTheme = TextTheme(
    headlineLarge: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      color: Colors.white,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: _lightPrimaryColor,
    scaffoldBackgroundColor: surfaceGradient[0],
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      secondary: Color(0xFF3B82F6),
      tertiary: Color(0xFF6366F1),
      surface: surfaceGradient[0],
      onSurface: Colors.black.withValues(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 0.87 * 255,
      ),
    ),
    textTheme: _lightTextTheme,
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      shadowColor: Colors.black.withValues(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 0.03 * 255,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _lightPrimaryColor;
        }
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _lightPrimaryColor.withValues(
            red: _lightPrimaryColor.r.toDouble(),
            green: _lightPrimaryColor.g.toDouble(),
            blue: _lightPrimaryColor.b.toDouble(),
            alpha: 0.5 * 255,
          );
        }
        return Colors.grey.withValues(
          red: Colors.grey.r.toDouble(),
          green: Colors.grey.g.toDouble(),
          blue: Colors.grey.b.toDouble(),
          alpha: 0.5 * 255,
        );
      }),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    colorScheme: ColorScheme.dark(
      primary: _darkPrimaryColor,
      secondary: Colors.blue.shade200,
      surface: const Color(0xFF1A1A1A),
      onSurface: Colors.white,
    ),
    textTheme: _darkTextTheme,
    cardTheme: CardThemeData(
      color: const Color(0xFF2A2A2A),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _darkPrimaryColor;
        }
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _darkPrimaryColor.withValues(
            red: _darkPrimaryColor.r.toDouble(),
            green: _darkPrimaryColor.g.toDouble(),
            blue: _darkPrimaryColor.b.toDouble(),
            alpha: 0.5 * 255,
          );
        }
        return Colors.grey.withValues(
          red: Colors.grey.r.toDouble(),
          green: Colors.grey.g.toDouble(),
          blue: Colors.grey.b.toDouble(),
          alpha: 0.5 * 255,
        );
      }),
    ),
  );
}
