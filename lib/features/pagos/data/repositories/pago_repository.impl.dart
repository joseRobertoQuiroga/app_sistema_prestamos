import 'package:dartz/dartz.dart';
import '../../domain/entities/pago.dart';
import '../../domain/entities/detalle_pago.dart';
import '../../domain/entities/resultado_aplicacion_pago.dart';
import '../../domain/repositories/pago_repository.dart';
import '../datasources/pago_local_data_source.dart';
import '../../../../core/errors/failures.dart';

/// Implementación del repositorio de pagos
class PagoRepositoryImpl implements PagoRepository {
  final PagoLocalDataSource localDataSource;

  PagoRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, ResultadoAplicacionPago>> registrarPago({
    required int prestamoId,
    required double monto,
    required DateTime fechaPago,
    int? cajaId,
    String? metodoPago,
    String? referencia,
    String? observaciones,
  }) async {
    try {
      final resultado = await localDataSource.registrarPago(
        prestamoId: prestamoId,
        monto: monto,
        fechaPago: fechaPago,
        cajaId: cajaId,
        metodoPago: metodoPago,
        referencia: referencia,
        observaciones: observaciones,
      );
      return Right(resultado);
    } catch (e) {
      return Left(DatabaseFailure('Error al registrar pago: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Pago>>> getPagos() async {
    try {
      final pagos = await localDataSource.getPagos();
      return Right(pagos);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener pagos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Pago>> getPagoById(int id) async {
    try {
      final pago = await localDataSource.getPagoById(id);
      return Right(pago);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener pago: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Pago>>> getPagosByPrestamo(int prestamoId) async {
    try {
      final pagos = await localDataSource.getPagosByPrestamo(prestamoId);
      return Right(pagos);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener pagos del préstamo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DetallePago>>> getDetallesPago(int pagoId) async {
    try {
      final detalles = await localDataSource.getDetallesPago(pagoId);
      return Right(detalles);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener detalles: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalPagado(int prestamoId) async {
    try {
      final resumen = await localDataSource.getResumenPagos(prestamoId);
      return Right(resumen['totalPagado'] ?? 0);
    } catch (e) {
      return Left(DatabaseFailure('Error al calcular total: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getResumenPagos(int prestamoId) async {
    try {
      final resumen = await localDataSource.getResumenPagos(prestamoId);
      return Right(resumen);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener resumen: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> eliminarPago(int id) async {
    // TODO: Implementar reversión de pago
    return Left(ValidationFailure('Eliminación de pagos no implementada'));
  }

  @override
  Future<Either<Failure, String>> generarCodigoPago() async {
    // TODO: Exponer método público en datasource
    return const Left(ValidationFailure('No implementado'));
  }
}