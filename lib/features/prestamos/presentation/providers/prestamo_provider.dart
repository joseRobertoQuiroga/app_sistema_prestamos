import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart' hide Prestamo, Cuota;
import '../../../../core/database/database_provider.dart';
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
// PROVIDERS DE CÁLCULO
// ============================================================================

final calcularTotalesProvider = FutureProvider.family<Map<String, double>, ({double monto, double tasaInteres, TipoInteres tipoInteres, int plazoMeses})>((ref, p) async {
  final tasaMensual = p.tasaInteres / 100 / 12;
  double cuota, total;
  if (p.tipoInteres == TipoInteres.simple) {
    total = p.monto + (p.monto * tasaMensual * p.plazoMeses);
    cuota = total / p.plazoMeses;
  } else {
    cuota = p.monto * (tasaMensual * pow(1 + tasaMensual, p.plazoMeses)) / (pow(1 + tasaMensual, p.plazoMeses) - 1);
    total = cuota * p.plazoMeses;
  }
  return {'montoOriginal': p.monto, 'interesTotal': total - p.monto, 'montoTotal': total, 'cuotaMensual': cuota};
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
// FILTROS, DASHBOARD & STATS
// ============================================================================

// Filtro de estado actual
final estadoFiltroProvider = StateProvider<EstadoPrestamo?>((ref) => null);

class PrestamosDashboardStats {
  final double totalPrestado;
  final double moraTotal;
  final int countTodos;
  final int countActivo;
  final int countPagado;
  final int countMora;

  PrestamosDashboardStats({
    this.totalPrestado = 0,
    this.moraTotal = 0,
    this.countTodos = 0,
    this.countActivo = 0,
    this.countPagado = 0,
    this.countMora = 0,
  });
}

// Provider para el dashboard (estadísticas y lista filtrada)
final prestamosDashboardProvider = Provider<AsyncValue<({List<Prestamo> items, PrestamosDashboardStats stats})>>((ref) {
  final prestamosAsync = ref.watch(prestamosListProvider);
  final estadoFiltro = ref.watch(estadoFiltroProvider);

  return prestamosAsync.when(
    data: (allPrestamos) {
      double totalPrestado = 0;
      double moraTotal = 0;
      int countActivo = 0;
      int countPagado = 0;
      int countMora = 0;

      for (final p in allPrestamos) {
        totalPrestado += p.montoOriginal;
        if (p.estado == EstadoPrestamo.mora) {
          moraTotal += p.saldoPendiente;
          countMora++;
        } else if (p.estado == EstadoPrestamo.activo) {
          countActivo++;
        } else if (p.estado == EstadoPrestamo.pagado) {
          countPagado++;
        }
      }

      final stats = PrestamosDashboardStats(
        totalPrestado: totalPrestado,
        moraTotal: moraTotal,
        countTodos: allPrestamos.length,
        countActivo: countActivo,
        countPagado: countPagado,
        countMora: countMora,
      );

      final filteredItems = allPrestamos.where((p) {
        if (estadoFiltro == null) return true;
        return p.estado == estadoFiltro;
      }).toList();

      return AsyncValue.data((items: filteredItems, stats: stats));
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

// Provider legacy para no romper otros componentes si lo usan (opcional)
final prestamosFilteredProvider = Provider<AsyncValue<List<Prestamo>>>((ref) {
  final dashboardAsync = ref.watch(prestamosDashboardProvider);
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.items),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});