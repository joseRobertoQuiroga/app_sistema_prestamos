import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Proveedor para el modo de tema (ligero/oscuro/sistema)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Notificador para gestionar el modo de tema
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _key = 'theme_mode';
  
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadThemeMode();
  }
  
  /// Cargar el modo de tema guardado
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_key);
      
      if (themeModeString != null) {
        state = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.light,
        );
      }
    } catch (e) {
      // Si hay error, usar tema claro por defecto
      state = ThemeMode.light;
    }
  }
  
  /// Cambiar el modo de tema
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.toString());
    } catch (e) {
      // Manejar error de guardado
      debugPrint('Error al guardar modo de tema: $e');
    }
  }
  
  /// Alternar entre modo claro y oscuro
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
  
  /// Verificar si está en modo oscuro
  bool get isDarkMode => state == ThemeMode.dark;
}
