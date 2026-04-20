import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'config/router/app_router.dart';

void main() async {
  final startTime = DateTime.now();
  debugPrint('🚀 Starting App Initialization...');
  
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('⏱️ Flutter Binding Initialized: ${DateTime.now().difference(startTime).inMilliseconds}ms');
  
  // Capturar errores de Flutter
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('❌ Flutter Error: ${details.exception}');
  };

  try {
    // Inicializar datos de localización para español
    debugPrint('⏳ Initializing Date Formatting...');
    await initializeDateFormatting('es', null);
    debugPrint('⏱️ Date Formatting Initialized: ${DateTime.now().difference(startTime).inMilliseconds}ms');
    
    debugPrint('🏁 RunApp started at: ${DateTime.now().difference(startTime).inMilliseconds}ms');
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint('❌ Critical Error during startup: $e');
    debugPrint(stack.toString());
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: 'Sistema de Préstamos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      locale: const Locale('es', 'BO'),
    );
  }
}