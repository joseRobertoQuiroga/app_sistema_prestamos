import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sistema de temas modernizado con Glassmorphism (Dark) y Diseño Profesional (Light)
class AppTheme {
  // ===========================================================================
  // PALETA DE COLORES
  // ===========================================================================

  // Primary Colors (Brand)
  static const Color primaryBrand = Color(0xFF6366F1); // Indigo-500
  static const Color primaryDark = Color(0xFF818CF8);  // Indigo-400
  static const Color primaryLight = Color(0xFF4F46E5); // Indigo-600

  static const Color secondaryBrand = Color(0xFFA855F7); // Purple-500
  static const Color secondaryDark = Color(0xFFC084FC);  // Purple-400
  static const Color secondaryLight = Color(0xFF9333EA); // Purple-600

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color error = Color(0xFFEF4444);   // Red-500
  static const Color info = Color(0xFF3B82F6);    // Blue-500

  // Background Colors - DARK (Deep Space Blue)
  static const Color darkBackground = Color(0xFF0F111A); 
  static const Color darkSurface = Color(0xFF1E2130);
  static const Color darkCard = Color(0xFF262A40); // Slightly lighter for contrast

  // Background Colors - LIGHT (Professional Gray)
  static const Color lightBackground = Color(0xFFF3F4F6); // Gray-100
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF111827); // Gray-900
  static const Color textSecondaryLight = Color(0xFF6B7280); // Gray-500
  
  static const Color textPrimaryDark = Color(0xFFF9FAFB); // Gray-50
  static const Color textSecondaryDark = Color(0xFF9CA3AF); // Gray-400

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF262A40), Color(0xFF1E2130)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===========================================================================
  // TEMA CLARO (PROFESIONAL & CLEAN)
  // ===========================================================================
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: primaryLight,
      secondary: secondaryLight,
      surface: lightSurface,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryLight,
      onError: Colors.white,
      primaryContainer: const Color(0xFFE0E7FF), // Indigo-100
      secondaryContainer: const Color(0xFFF3E8FF), // Purple-100
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBackground,
      
      // Tipografía Profesional
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(fontSize: 57, fontWeight: FontWeight.bold, color: textPrimaryLight),
        displayMedium: GoogleFonts.outfit(fontSize: 45, fontWeight: FontWeight.bold, color: textPrimaryLight),
        displaySmall: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: textPrimaryLight),
        headlineLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryLight),
        headlineMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimaryLight),
        headlineSmall: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimaryLight),
        titleLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimaryLight),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimaryLight),
        titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textSecondaryLight),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: textPrimaryLight),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: textSecondaryLight),
      ),

      // AppBar - Limpia y blanca
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimaryLight),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
      ),

      // Cards - Elevación suave estilo SaaS
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Inputs - Estilo moderno
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
      ),

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ===========================================================================
  // TEMA OSCURO (MODERN GLASSMORPHISM)
  // ===========================================================================
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: primaryDark,
      secondary: secondaryDark,
      surface: darkSurface,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryDark,
      onError: Colors.black,
      primaryContainer: const Color(0xFF312E81), // Indigo-900
      secondaryContainer: const Color(0xFF581C87), // Purple-900
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,

      // Tipografía High Contrast
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontSize: 57, fontWeight: FontWeight.bold, color: textPrimaryDark),
        displayMedium: GoogleFonts.outfit(fontSize: 45, fontWeight: FontWeight.bold, color: textPrimaryDark),
        displaySmall: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: textPrimaryDark),
        headlineLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryDark),
        headlineMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimaryDark),
        headlineSmall: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimaryDark),
        titleLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimaryDark),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimaryDark),
        titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textSecondaryDark),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: textPrimaryDark),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: textSecondaryDark),
      ),

      // AppBar - Dark & Seamless
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimaryDark),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
      ),

      // Cards - Glass-like feel
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),

      // Inputs - Deep integration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E2130),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryDark, width: 2),
        ),
      ),

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBrand, // Un poco más vibrante en dark mode
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryBrand.withOpacity(0.5), // Glow effect
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static InputDecoration getInputDecoration({
    required String label,
    Widget? prefixIcon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryBrand, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
