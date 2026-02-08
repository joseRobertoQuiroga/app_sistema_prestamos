import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pago.dart';
import '../../domain/usecases/pago_usecases.dart';
import '../../data/datasources/pago_local_data_source.dart';
import '../../data/repositories/pago_repository_impl.dart';
import '../../../../core/database/database.dart';

// Provider de database (asume que ya existe)
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

// Provider del data source
final pagoLocalDataSourceProvider = Provider<PagoLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return PagoLocalDataSource(database);
});

// Provider del repositorio
final pagoRepositoryProvider = Provider<PagoRepositoryImpl>((ref) {
  final dataSource = ref.watch(pagoLocalDataSourceProvider);
  return PagoRepositoryImpl(localDataSource: dataSource);
});

// Providers de use cases
final registrarPagoUseCaseProvider = Provider<RegistrarPago>((ref) {
  final repository = ref.watch(pagoRepositoryProvider);
  return RegistrarPago(repository);
});

final getPagosByPrestamoUseCaseProvider = Provider<GetPagosByPrestamo>((ref) {
  final repository = ref.watch(pagoRepositoryProvider);
  return GetPagosByPrestamo(repository);
});

final getDetallesPagoUseCaseProvider = Provider<GetDetallesPago>((ref) {
  final repository = ref.watch(pagoRepositoryProvider);
  return GetDetallesPago(repository);
});

final getResumenPagosUseCaseProvider = Provider<GetResumenPagos>((ref) {
  final repository = ref.watch(pagoRepositoryProvider);
  return GetResumenPagos(repository);
});

// Provider para lista de pagos por préstamo
final pagosListProvider = FutureProvider.family<List<Pago>, int>((ref, prestamoId) async {
  final useCase = ref.watch(getPagosByPrestamoUseCaseProvider);
  final result = await useCase(prestamoId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (pagos) => pagos,
  );
});

// Provider para resumen de pagos
final resumenPagosProvider = FutureProvider.family<Map<String, double>, int>((ref, prestamoId) async {
  final useCase = ref.watch(getResumenPagosUseCaseProvider);
  final result = await useCase(prestamoId);
  
  return result.fold(
    (failure) => {},
    (resumen) => resumen,
  );
});