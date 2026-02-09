import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern Vibrant Color Palette
  static const Color primaryColor = Color(0xFF6C63FF); // Modern Indigo
  static const Color _secondaryColor = Color(0xFF2A2D3E); // Dark Gunmetal
  static const Color _accentColor = Color(0xFFFF6584); // Vibrant Pink

  static const Color _backgroundColor = Color(0xFFF8F9FE); // Clean Off-White
  static const Color _surfaceColor = Colors.white;
  static const Color _errorColor = Color(0xFFFF4757);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4834D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6584), Color(0xFFFF7F50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category Colors (Pastel & Vibrant Mix)
  static final Map<String, Color> categoryColors = {
    'Arcade': Color(0xFF70A1FF), // Soft Blue
    'Classic Board': Color(0xFFFF7F50), // Coral
    'Word Games': Color(0xFF2ED573), // Emerald
    'Brain Training': Color(0xFFA29BFE), // Periwinkle
    'Puzzle': Color(0xFFFF6B81), // Watermelon
    'Quick Casual': Color(0xFFECCC68), // Mustard
    'Strategy': Color(0xFF1E90FF), // Dodger Blue
    'Reaction': Color(0xFFFF4757), // Red
    'Educational': Color(0xFF5352ED), // Royal Blue
  };

  // Modern Text Theme
  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.outfit(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
      color: _secondaryColor,
    ),
    displayMedium: GoogleFonts.outfit(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: _secondaryColor,
    ),
    displaySmall: GoogleFonts.outfit(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: _secondaryColor,
    ),
    headlineMedium: GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: _secondaryColor,
    ),
    titleLarge: GoogleFonts.dmSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: _secondaryColor,
    ),
    bodyLarge: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: _secondaryColor.withValues(alpha: 0.8),
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: _secondaryColor.withValues(alpha: 0.6),
    ),
    labelLarge: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
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
      secondary: _accentColor,
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
      secondary: _accentColor,
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
}
