import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFF4B860); // Warm premium gold
  static const Color _secondaryColor = Color(0xFF475569); // Slate 600
  static const Color accentColor = Color(0xFF7CC6D9); // Soft sky teal
  static const Color _backgroundColor = Color(0xFF0F172A); // Slate 900
  static const Color _surfaceColor = Color(0xFF1E293B); // Slate 800
  static const Color _errorColor = Color(0xFFEF4444);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF4B860), Color(0xFFE6A24E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF7CC6D9), Color(0xFF5CA9BF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final Map<String, Color> categoryColors = {
    'Arcade': Color(0xFF70A1FF),
    'Classic Board': Color(0xFFFF7F50),
    'Word Games': Color(0xFF2ED573),
    'Brain Training': Color(0xFF8FA7D8),
    'Puzzle': Color(0xFFFF6B81),
    'Quick Casual': Color(0xFFECCC68),
    'Strategy': Color(0xFF1E90FF),
    'Reaction': Color(0xFFFF4757),
    'Educational': Color(0xFF5E7CB6),
  };

  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.outfit(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.5,
      color: Colors.white,
    ),
    displayMedium: GoogleFonts.outfit(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
      color: Colors.white,
    ),
    displaySmall: GoogleFonts.outfit(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    headlineMedium: GoogleFonts.outfit(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white.withValues(alpha: 0.9),
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white.withValues(alpha: 0.7),
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: primaryColor,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: _backgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: _surfaceColor,
      error: _errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _secondaryColor,
      onError: Colors.white,
    ),
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: _backgroundColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _textTheme.titleLarge,
      iconTheme: IconThemeData(color: _secondaryColor),
    ),
    cardTheme: CardThemeData(
      color: _surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: _textTheme.labelLarge?.copyWith(color: Colors.white),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: _textTheme.labelLarge,
      ),
    ),
    iconTheme: IconThemeData(
      color: _secondaryColor,
      size: 24,
    ),
    dividerTheme: DividerThemeData(
      color: _secondaryColor.withValues(alpha: 0.1),
      thickness: 1,
      space: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: Color(0xFF1E1E1E),
      error: _errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    textTheme: _textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: Color(0xFF1E1E1E),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );

  static BoxDecoration glassmorphicDecoration({
    Color backgroundColor = Colors.white,
    Color borderColor = Colors.white,
    double borderWidth = 1,
    double borderRadius = 24,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: backgroundColor.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor.withValues(alpha: 0.1),
        width: borderWidth,
      ),
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: -5,
                offset: const Offset(0, 10),
              ),
            ]
          : [],
    );
  }
}

