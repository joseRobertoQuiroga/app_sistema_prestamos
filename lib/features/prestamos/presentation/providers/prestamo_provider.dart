import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart' hide Prestamo, Cuota;
import '../../domain/entities/prestamo.dart';
import '../../domain/entities/cuota.dart';
import '../../domain/usecases/generar_codigo_prestamo.dart';
import '../../domain/usecases/generar_tabla_amortizacion.dart';
import '../../domain/usecases/prestamo_usecases.dart';
import '../../domain/usecases/cuota_usecases.dart';
import '../../data/datasources/prestamo_local_data_source.dart';
import '../../data/repositories/prestamo_repository_impl.dart';

// ============================================================================
// PROVIDERS DE INFRAESTRUCTURA
// ============================================================================

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Data Source provider
final prestamoLocalDataSourceProvider = Provider<PrestamoLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return PrestamoLocalDataSource(database);
});

// Repository provider
final prestamoRepositoryProvider = Provider<PrestamoRepositoryImpl>((ref) {
  final dataSource = ref.watch(prestamoLocalDataSourceProvider);
  return PrestamoRepositoryImpl(dataSource);
});

// ============================================================================
// PROVIDERS DE USE CASES
// ============================================================================

// Generadores
final generarCodigoPrestamoProvider = Provider<GenerarCodigoPrestamo>((ref) {
  final repository = ref.watch(prestamoRepositoryProvider);
  return GenerarCodigoPrestamo(repository);
});

final generarTablaAmortizacionProvider = Provider<GenerarTablaAmortizacion>((ref) {
  return GenerarTablaAmortizacion();
});

// CRUD Préstamos
final getPrestamosProvider = Provider<GetPrestamos>((ref) {
  final repository = ref.watch(prestamoRepositoryProvider);
  return GetPrestamos(repository);
});

final getPrestamoByIdProvider = Provider<GetPrestamoById>((ref) {
  final repository = ref.watch(prestamoRepositoryProvider);
  return GetPrestamoById(repository);
});

final getPrestamosByClienteProvider = Provider<GetPrestamosByCliente>((ref) {
  final repository = ref.watch(prestamoRepositoryProvider);
  return GetPrestamosByCliente(repository);
});

final searchPrestamosProvider = Provider<SearchPrestamos>((ref) {
  final repository = ref.watch(prestamoRepositoryProvider);
  return SearchPrestamos(repository);
});

final createPrestamoProvider = Provider<CreatePrestamo>((ref) {
  final repository = ref.watch(prestamoRepositoryProvider);
  final generarTabla = ref.watch(generarTablaAmortizacionProvider);
  return CreatePrestamo(repository, generarTabla);
});

final updatePrestamoProvider = Provider<UpdatePrestamo>((ref) {
  final repository = ref.watch(prestamoRepositoryProvider);
  return UpdatePrestamo(repository);
});

final deletePrestamoProvider = Provider<DeletePrestamo>((ref) {
  final repository = ref.watch(prestamoRepositoryProvider);
  return DeletePrestamo(repository);
});

final cancelarPrestamoProvider = Provider<CancelarPrestamo>((ref) {
  final repository = ref.watch(prestamoRepositoryProvider);
  return CancelarPrestamo(repository);
});

// Cuotas
final getCuotasByPrestamoProvider = Provider<GetCuotasByPrestamo>((ref) {
  final repository = ref.watch(prestamoRepositoryProvider);
  return GetCuotasByPrestamo(repository);
});

final getResumenCuotasProvider = Provider<GetResumenCuotas>((ref) {
  final repository = ref.watch(prestamoRepositoryProvider);
  return GetResumenCuotas(repository);
});

// ============================================================================
// STATE PROVIDERS
// ============================================================================

// Lista de préstamos
final prestamosListProvider = StateNotifierProvider<PrestamosListNotifier, AsyncValue<List<Prestamo>>>((ref) {
  final getPrestamos = ref.watch(getPrestamosProvider);
  final searchPrestamos = ref.watch(searchPrestamosProvider);
  return PrestamosListNotifier(getPrestamos, searchPrestamos);
});

class PrestamosListNotifier extends StateNotifier<AsyncValue<List<Prestamo>>> {
  final GetPrestamos getPrestamos;
  final SearchPrestamos searchPrestamos;

  PrestamosListNotifier(this.getPrestamos, this.searchPrestamos)
      : super(const AsyncValue.loading()) {
    loadPrestamos();
  }

  Future<void> loadPrestamos() async {
    state = const AsyncValue.loading();
    final result = await getPrestamos();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (prestamos) => state = AsyncValue.data(prestamos),
    );
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      await loadPrestamos();
      return;
    }

    state = const AsyncValue.loading();
    final result = await searchPrestamos(query);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (prestamos) => state = AsyncValue.data(prestamos),
    );
  }

  void refresh() {
    loadPrestamos();
  }
}

// Préstamo individual
final prestamoDetailProvider = FutureProvider.family<Prestamo, int>((ref, id) async {
  final getPrestamoById = ref.watch(getPrestamoByIdProvider);
  final result = await getPrestamoById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (prestamo) => prestamo,
  );
});

// Cuotas de un préstamo
final cuotasListProvider = FutureProvider.family<List<Cuota>, int>((ref, prestamoId) async {
  final getCuotas = ref.watch(getCuotasByPrestamoProvider);
  final result = await getCuotas(prestamoId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (cuotas) => cuotas,
  );
});

// Resumen de cuotas
final resumenCuotasProvider = FutureProvider.family<ResumenCuotas, int>((ref, prestamoId) async {
  final getResumen = ref.watch(getResumenCuotasProvider);
  final result = await getResumen(prestamoId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (resumen) => resumen,
  );
});

// ============================================================================
// FILTROS Y OPCIONES
// ============================================================================

// Filtro de estado actual
final estadoFiltroProvider = StateProvider<EstadoPrestamo?>((ref) => null);

// Lista filtrada por estado
final prestamosFilteredProvider = Provider<AsyncValue<List<Prestamo>>>((ref) {
  final prestamosAsync = ref.watch(prestamosListProvider);
  final estadoFiltro = ref.watch(estadoFiltroProvider);

  return prestamosAsync.when(
    data: (prestamos) {
      if (estadoFiltro == null) {
        return AsyncValue.data(prestamos);
      }
      final filtered = prestamos.where((p) => p.estado == estadoFiltro).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});