import 'dart:io';

void main() async {
  final files = [
    r'c:\Users\Roberto\Desktop\PROYECTOS\sistema prestamos\prestamos_app\lib\features\caja\presentation\screens\generar_movimiento_screen.dart',
    r'c:\Users\Roberto\Desktop\PROYECTOS\sistema prestamos\prestamos_app\lib\presentation\widgets\app_drawer.dart'
  ];

  for (final path in files) {
    var file = File(path);
    if (!await file.exists()) continue;

    var content = await file.readAsString();

    content = content.replaceAll(r'isDark ? const Color(0xFF0F111A) : const Color(0xFFF3F4F6)', r'AppColors.background(context)');
    content = content.replaceAll(r'isDark ? const Color(0xFF1E2130) : Colors.white', r'AppColors.surface(context)');
    content = content.replaceAll(r'isDark ? const Color(0xFF0F111A) : Colors.white', r'AppColors.inputFill(context)');
    content = content.replaceAll(r'isDark ? const Color(0xFF262A40) : Colors.white', r'AppColors.cardBg(context)');
    
    content = content.replaceAll(r'isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)', r'AppColors.border(context)');
    
    content = content.replaceAll(r'isDark ? Colors.white : const Color(0xFF1E293B)', r'AppColors.textPrimary(context)');
    content = content.replaceAll(r'isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B)', r'AppColors.textSecondary(context)');

    // Algunos hardcoded text en hover states
    content = content.replaceAll(r'isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC)', r'AppColors.background(context)');
    
    // Import en app_drawer.dart si no lo tiene
    if (path.contains('app_drawer') && !content.contains('app_theme.dart')) {
        content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../core/theme/app_theme.dart';");
    }

    await file.writeAsString(content);
    print('Updated $path');
  }
}
