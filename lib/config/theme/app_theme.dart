import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Design constants for responsive layout
  static const double maxContentWidth = 1200.0;
  static const double maxFormWidth = 800.0;
  static const double standardPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  static const double sectionSpacing = 32.0;
  static const double cardSpacing = 16.0;
  
  // Colores principales - Modernizados
  static const Color primaryColor = Color(0xFF1976D2); // Azul
  static const Color secondaryColor = Color(0xFF424242); // Gris oscuro
  static const Color accentColor = Color(0xFF4CAF50); // Verde
  static const Color errorColor = Color(0xFFD32F2F); // Rojo
  static const Color warningColor = Color(0xFFFFA726); // Naranja
  static const Color successColor = Color(0xFF66BB6A); // Verde claro

  // Colores de estado de préstamos
  static const Color activoColor = Color(0xFF4CAF50);
  static const Color pagadoColor = Color(0xFF2196F3);
  static const Color moraColor = Color(0xFFF44336);
  static const Color canceladoColor = Color(0xFF9E9E9E);

  // Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),

      // Tipografía
      textTheme: GoogleFonts.poppinsTextTheme(),

      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Cards - Mejorado
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: standardPadding,
          vertical: cardSpacing / 2,
        ),
      ),

      // Input Decoration - Mejorado
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
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
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: standardPadding,
          vertical: standardPadding,
        ),
        labelStyle: GoogleFonts.poppins(fontSize: 14),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: largePadding,
            vertical: standardPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: largePadding,
            vertical: standardPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: standardPadding,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        thickness: 1,
        space: 1,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Tema oscuro (opcional)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ),
    );
  }

  // Helpers de estado
  static Color getEstadoColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'ACTIVO':
        return activoColor;
      case 'PAGADO':
        return pagadoColor;
      case 'MORA':
        return moraColor;
      case 'CANCELADO':
        return canceladoColor;
      default:
        return Colors.grey;
    }
  }

  static Color getEstadoCuotaColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        return warningColor;
      case 'PAGADA':
        return successColor;
      case 'MORA':
      case 'VENCIDA':
        return errorColor;
      default:
        return Colors.grey;
    }
  }
}
