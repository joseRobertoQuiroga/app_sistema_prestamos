import 'package:dartz/dartz.dart';
import '../entities/pago.dart';
import '../entities/detalle_pago.dart';
import '../entities/resultado_aplicacion_pago.dart';
import '../../../../core/errors/failures.dart';

/// Repositorio abstracto de Pagos - Capa de Dominio
abstract class PagoRepository {
  /// Registra un nuevo pago y lo aplica automáticamente en cascada
  Future<Either<Failure, ResultadoAplicacionPago>> registrarPago({
    required int prestamoId,
    required double monto,
    required DateTime fechaPago,
    int? cajaId,
    String? metodoPago,
    String? referencia,
    String? observaciones,
  });

  /// Obtiene todos los pagos
  Future<Either<Failure, List<Pago>>> getPagos();

  /// Obtiene un pago por su ID
  Future<Either<Failure, Pago>> getPagoById(int id);

  /// Obtiene todos los pagos de un préstamo
  Future<Either<Failure, List<Pago>>> getPagosByPrestamo(int prestamoId);

  /// Obtiene el detalle de un pago
  Future<Either<Failure, List<DetallePago>>> getDetallesPago(int pagoId);

  /// Obtiene el total pagado en un préstamo
  Future<Either<Failure, double>> getTotalPagado(int prestamoId);

  /// Obtiene el resumen de pagos de un préstamo
  Future<Either<Failure, Map<String, double>>> getResumenPagos(int prestamoId);

  /// Elimina un pago (reversión)
  Future<Either<Failure, void>> eliminarPago(int id);

  /// Genera el código único para un pago
  Future<Either<Failure, String>> generarCodigoPago();
}