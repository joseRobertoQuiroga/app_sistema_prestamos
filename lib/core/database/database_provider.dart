import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';

/// Provider global para la base de datos AppDatabase
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  
  // Asegurarse de cerrar la base de datos cuando el provider sea destruido
  ref.onDispose(() async {
    await database.close();
  });
  
  return database;
});
