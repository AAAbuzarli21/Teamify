import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Vibrant Accent Colors
const Color accentTurquoise = Color(0xFF40E0D0);
const Color accentOrange = Color(0xFFFFA500);
const Color accentNeonGreen = Color(0xFF39FF14);
const Color accentDeepBlue = Color(0xFF00008B);

class AppTheme {
  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.oswald(
        fontSize: 57, fontWeight: FontWeight.w700, color: Colors.white),
    headlineLarge: GoogleFonts.oswald(
        fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white),
    titleLarge: GoogleFonts.roboto(
        fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
    bodyLarge: GoogleFonts.roboto(
        fontSize: 16, color: Colors.white.withAlpha(230)), // 90% opacity
    bodyMedium: GoogleFonts.roboto(
        fontSize: 14, color: Colors.white.withAlpha(204)), // 80% opacity
    labelLarge: GoogleFonts.roboto(
        fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF111111),
      primaryColor: accentTurquoise,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentTurquoise,
        brightness: Brightness.dark,
        surface: const Color(0xFF111111),
        primary: accentTurquoise,
        secondary: accentOrange,
      ),
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _textTheme.headlineLarge?.copyWith(fontSize: 24),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1C1C1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentTurquoise,
          foregroundColor: Colors.black,
          textStyle:
              _textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentTurquoise,
        foregroundColor: Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C1C1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: _textTheme.bodyMedium,
      ),
    );
  }
}
