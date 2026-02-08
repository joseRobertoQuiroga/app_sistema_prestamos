import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../domain/usecases/dashboard_usecases.dart';
import '../../data/datasources/dashboard_local_data_source.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../../../core/database/database.dart';

// Provider de database (compartido)
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

// Provider del data source
final dashboardLocalDataSourceProvider = Provider<DashboardLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return DashboardLocalDataSource(database);
});

// Provider del repositorio
final dashboardRepositoryProvider = Provider<DashboardRepositoryImpl>((ref) {
  final dataSource = ref.watch(dashboardLocalDataSourceProvider);
  return DashboardRepositoryImpl(localDataSource: dataSource);
});

// Providers de use cases
final getDashboardKPIsUseCaseProvider = Provider<GetDashboardKPIs>((ref) {
  return GetDashboardKPIs(ref.watch(dashboardRepositoryProvider));
});

final getDashboardAlertasUseCaseProvider = Provider<GetDashboardAlertas>((ref) {
  return GetDashboardAlertas(ref.watch(dashboardRepositoryProvider));
});

final getProximosVencimientosUseCaseProvider = Provider<GetProximosVencimientos>((ref) {
  return GetProximosVencimientos(ref.watch(dashboardRepositoryProvider));
});

final getPrestamosEnMoraUseCaseProvider = Provider<GetPrestamosEnMora>((ref) {
  return GetPrestamosEnMora(ref.watch(dashboardRepositoryProvider));
});

final getDistribucionCarteraUseCaseProvider = Provider<GetDistribucionCartera>((ref) {
  return GetDistribucionCartera(ref.watch(dashboardRepositoryProvider));
});

final getMovimientosPorCategoriaUseCaseProvider = Provider<GetMovimientosPorCategoria>((ref) {
  return GetMovimientosPorCategoria(ref.watch(dashboardRepositoryProvider));
});

// Provider para KPIs (con auto-refresh cada 30 segundos)
final dashboardKPIsProvider = FutureProvider.autoDispose<DashboardKPIs>((ref) async {
  final useCase = ref.watch(getDashboardKPIsUseCaseProvider);
  final result = await useCase();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (kpis) => kpis,
  );
});

// Provider para alertas
final dashboardAlertasProvider = FutureProvider.autoDispose<List<DashboardAlerta>>((ref) async {
  final useCase = ref.watch(getDashboardAlertasUseCaseProvider);
  final result = await useCase();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (alertas) => alertas,
  );
});

// Provider para próximos vencimientos
final proximosVencimientosProvider = FutureProvider.autoDispose.family<List<ProximoVencimiento>, int>(
  (ref, dias) async {
    final useCase = ref.watch(getProximosVencimientosUseCaseProvider);
    final result = await useCase(dias: dias);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (vencimientos) => vencimientos,
    );
  },
);

// Provider para préstamos en mora
final prestamosEnMoraProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final useCase = ref.watch(getPrestamosEnMoraUseCaseProvider);
  final result = await useCase();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (prestamos) => prestamos,
  );
});

// Provider para distribución de cartera
final distribucionCarteraProvider = FutureProvider.autoDispose<Map<String, double>>((ref) async {
  final useCase = ref.watch(getDistribucionCarteraUseCaseProvider);
  final result = await useCase();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (distribucion) => distribucion,
  );
});

// Provider para movimientos por categoría
final movimientosPorCategoriaProvider = FutureProvider.autoDispose<Map<String, double>>((ref) async {
  final useCase = ref.watch(getMovimientosPorCategoriaUseCaseProvider);
  final result = await useCase();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (movimientos) => movimientos,
  );
});