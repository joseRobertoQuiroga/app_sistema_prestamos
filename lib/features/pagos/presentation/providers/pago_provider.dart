import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pago.dart';
import '../../domain/entities/pago.dart' as domain;
import '../../domain/usecases/pago_usecases.dart';
import '../../data/datasources/pago_local_data_source.dart';
import '../../data/repositories/pago_repository_impl.dart';
import '../../../../core/database/database_provider.dart';

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

// ✅ NUEVO: Use case para obtener TODOS los pagos
final getPagosUseCaseProvider = Provider<GetPagos>((ref) {
  final repository = ref.watch(pagoRepositoryProvider);
  return GetPagos(repository);
});

// Provider para lista de pagos por préstamo
final pagosListProvider = FutureProvider.family<List<domain.Pago>, int>((ref, prestamoId) async {
  final useCase = ref.watch(getPagosByPrestamoUseCaseProvider);
  final result = await useCase(prestamoId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (pagos) => pagos.cast<domain.Pago>(),
  );
});

// ✅ NUEVO: Provider para TODOS los pagos
final allPagosListProvider = FutureProvider<List<domain.Pago>>((ref) async {
  final useCase = ref.watch(getPagosUseCaseProvider);
  final result = await useCase();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (pagos) => pagos.cast<domain.Pago>(),
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