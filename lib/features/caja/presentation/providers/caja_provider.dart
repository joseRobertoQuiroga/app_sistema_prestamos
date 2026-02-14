import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/caja.dart';
import '../../domain/entities/movimiento.dart';
import '../../domain/entities/resumen_caja.dart';
import '../../domain/usecases/caja_usecases.dart';
import '../../data/datasources/caja_local_data_source.dart';
import '../../data/repositories/caja_repository_impl.dart';
import '../../../../core/database/database_provider.dart';


// Provider del data source
final cajaLocalDataSourceProvider = Provider<CajaLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return CajaLocalDataSource(database);
});

// Provider del repositorio
final cajaRepositoryProvider = Provider<CajaRepositoryImpl>((ref) {
  final dataSource = ref.watch(cajaLocalDataSourceProvider);
  return CajaRepositoryImpl(localDataSource: dataSource);
});

// Providers de use cases - Cajas
final getCajasUseCaseProvider = Provider<GetCajas>((ref) {
  return GetCajas(ref.watch(cajaRepositoryProvider));
});

final getCajasActivasUseCaseProvider = Provider<GetCajasActivas>((ref) {
  return GetCajasActivas(ref.watch(cajaRepositoryProvider));
});

final createCajaUseCaseProvider = Provider<CreateCaja>((ref) {
  return CreateCaja(ref.watch(cajaRepositoryProvider));
});

final updateCajaUseCaseProvider = Provider<UpdateCaja>((ref) {
  return UpdateCaja(ref.watch(cajaRepositoryProvider));
});

final deleteCajaUseCaseProvider = Provider<DeleteCaja>((ref) {
  return DeleteCaja(ref.watch(cajaRepositoryProvider));
});

// Providers de use cases - Movimientos
final registrarIngresoUseCaseProvider = Provider<RegistrarIngreso>((ref) {
  return RegistrarIngreso(ref.watch(cajaRepositoryProvider));
});

final registrarEgresoUseCaseProvider = Provider<RegistrarEgreso>((ref) {
  final repository = ref.watch(cajaRepositoryProvider);
  return RegistrarEgreso(repository);
});

final getCategoriasUseCaseProvider = Provider<GetCategorias>((ref) {
  final repository = ref.watch(cajaRepositoryProvider);
  return GetCategorias(repository);
});

final registrarTransferenciaUseCaseProvider = Provider<RegistrarTransferencia>((ref) {
  return RegistrarTransferencia(ref.watch(cajaRepositoryProvider));
});

final getMovimientosByCajaUseCaseProvider = Provider<GetMovimientosByCaja>((ref) {
  return GetMovimientosByCaja(ref.watch(cajaRepositoryProvider));
});

// Providers de use cases - Consultas
final getSaldoTotalUseCaseProvider = Provider<GetSaldoTotal>((ref) {
  return GetSaldoTotal(ref.watch(cajaRepositoryProvider));
});

final getResumenCajaUseCaseProvider = Provider<GetResumenCaja>((ref) {
  return GetResumenCaja(ref.watch(cajaRepositoryProvider));
});

final getResumenGeneralUseCaseProvider = Provider<GetResumenGeneral>((ref) {
  return GetResumenGeneral(ref.watch(cajaRepositoryProvider));
});

final categoriasProvider = FutureProvider.family<List<String>, String>((ref, tipo) async {
  final useCase = ref.watch(getCategoriasUseCaseProvider);
  final result = await useCase(tipo);
  return result.fold((l) => [], (r) => r);
});

// Provider para lista de cajas
final cajasListProvider = FutureProvider<List<Caja>>((ref) async {
  final useCase = ref.watch(getCajasUseCaseProvider);
  final result = await useCase();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (cajas) => cajas,
  );
});

// Provider para cajas activas
final cajasActivasProvider = FutureProvider<List<Caja>>((ref) async {
  final useCase = ref.watch(getCajasActivasUseCaseProvider);
  final result = await useCase();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (cajas) => cajas,
  );
});

// Provider para movimientos por caja
final movimientosByCajaProvider = FutureProvider.family<List<Movimiento>, int>((ref, cajaId) async {
  final useCase = ref.watch(getMovimientosByCajaUseCaseProvider);
  final result = await useCase(cajaId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (movimientos) => movimientos,
  );
});

// Provider para saldo total
final saldoTotalProvider = FutureProvider<double>((ref) async {
  final useCase = ref.watch(getSaldoTotalUseCaseProvider);
  final result = await useCase();
  
  return result.fold(
    (failure) => 0.0,
    (saldo) => saldo,
  );
});

// Provider de use case - GetCajaById
final getCajaByIdUseCaseProvider = Provider<GetCajaById>((ref) {
  return GetCajaById(ref.watch(cajaRepositoryProvider));
});

// Provider para obtener una caja por ID
final cajaByIdProvider = FutureProvider.family<Caja?, int>((ref, id) async {
  if (id <= 0) return null;
  final useCase = ref.watch(getCajaByIdUseCaseProvider);
  final result = await useCase(id);
  
  return result.fold(
    (failure) => null, // O manejar error
    (caja) => caja,
  );
});

// Provider para resumen de caja
final resumenCajaProvider = FutureProvider.family<ResumenCaja, int>((ref, cajaId) async {
  final useCase = ref.watch(getResumenCajaUseCaseProvider);
  final result = await useCase(cajaId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (resumen) => resumen,
  );
});

// Provider para resumen general
final resumenGeneralProvider = FutureProvider<Map<String, double>>((ref) async {
  final useCase = ref.watch(getResumenGeneralUseCaseProvider);
  final result = await useCase();
  
  return result.fold(
    (failure) => {},
    (resumen) => resumen,
  );
});

// Provider for cajas (needed by movimientos screen)
final cajasProvider = FutureProvider<List<Caja>>((ref) async {
  final useCase = ref.watch(getCajasUseCaseProvider);
  final result = await useCase();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (cajas) => cajas,
  );
});

// Provider para todos los movimientos del sistema
final movimientosGeneralesProvider = FutureProvider<List<Movimiento>>((ref) async {
  final dataSource = ref.watch(cajaLocalDataSourceProvider);
  final movimientos = await dataSource.getMovimientos();
  return movimientos;
});

// ✅ NUEVO: Provider para el query de búsqueda de cajas
final cajaSearchQueryProvider = StateProvider<String>((ref) => '');

// ✅ NUEVO: Provider para lista de cajas filtrada por búsqueda
final filteredCajasProvider = Provider<AsyncValue<List<Caja>>>((ref) {
  final cajasAsync = ref.watch(cajasListProvider);
  final searchQuery = ref.watch(cajaSearchQueryProvider).toLowerCase();

  return cajasAsync.when(
    data: (cajas) {
      if (searchQuery.isEmpty) return AsyncValue.data(cajas);
      
      final filtered = cajas.where((caja) {
        return caja.nombre.toLowerCase().contains(searchQuery) ||
               (caja.banco?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});