import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _background = Color(0xFF0F0F0F); // Very dark background
  static const Color _surface = Color(0xFF1E1E1E); // Slightly lighter for cards/panels
  static const Color _primary = Color(0xFFBB86FC); // Light purple accent
  static const Color _secondary = Color(0xFF03DAC6); // Teal accent
  static const Color _textPrimary = Color(0xFFE0E0E0);
  static const Color _textSecondary = Color(0xFFA0A0A0);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        secondary: _secondary,
        surface: _surface,
        background: _background,
        onSurface: _textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: _textPrimary,
        displayColor: _textPrimary,
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: _textSecondary),
      ),
      iconTheme: const IconThemeData(
        color: _textSecondary,
      ),
    );
  }
}
