import 'package:dartz/dartz.dart';
import '../entities/resultado_aplicacion_pago.dart';
import '../repositories/pago_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use Case: Registrar Pago
/// 
/// Registra un pago y lo aplica automáticamente en cascada:
/// 1. Primero cubre la mora de las cuotas vencidas
/// 2. Luego cubre los intereses pendientes
/// 3. Finalmente abona al capital
class RegistrarPago {
  final PagoRepository repository;

  RegistrarPago(this.repository);

  /// Ejecuta el registro de pago
  /// 
  /// Parameters:
  ///   - prestamoId: ID del préstamo a pagar
  ///   - monto: Monto del pago
  ///   - fechaPago: Fecha en que se realizó el pago
  ///   - cajaId: ID de la caja donde se recibe el pago (opcional)
  ///   - metodoPago: Método de pago (Efectivo, Transferencia, etc.)
  ///   - referencia: Número de referencia (cheque, transferencia, etc.)
  ///   - observaciones: Notas adicionales
  /// 
  /// Returns:
  ///   - Right(ResultadoAplicacionPago): Detalle de cómo se aplicó el pago
  ///   - Left(Failure): Error si falla el registro
  Future<Either<Failure, ResultadoAplicacionPago>> call({
    required int prestamoId,
    required double monto,
    required DateTime fechaPago,
    int? cajaId,
    String? metodoPago,
    String? referencia,
    String? observaciones,
  }) async {
    // Validaciones
    if (prestamoId <= 0) {
      return Left(ValidationFailure('ID de préstamo inválido'));
    }

    if (monto <= 0) {
      return Left(ValidationFailure('El monto debe ser mayor a 0'));
    }

    if (fechaPago.isAfter(DateTime.now())) {
      return Left(ValidationFailure('La fecha de pago no puede ser futura'));
    }

    // Registrar el pago con aplicación en cascada
    return await repository.registrarPago(
      prestamoId: prestamoId,
      monto: monto,
      fechaPago: fechaPago,
      cajaId: cajaId,
      metodoPago: metodoPago,
      referencia: referencia,
      observaciones: observaciones,
    );
  }
}

/// Use Case: Obtener Pagos por Préstamo
class GetPagosByPrestamo {
  final PagoRepository repository;

  GetPagosByPrestamo(this.repository);

  Future<Either<Failure, List>> call(int prestamoId) async {
    if (prestamoId <= 0) {
      return Left(ValidationFailure('ID de préstamo inválido'));
    }
    return await repository.getPagosByPrestamo(prestamoId);
  }
}

/// Use Case: Obtener Detalles de Pago
class GetDetallesPago {
  final PagoRepository repository;

  GetDetallesPago(this.repository);

  Future<Either<Failure, List>> call(int pagoId) async {
    if (pagoId <= 0) {
      return Left(ValidationFailure('ID de pago inválido'));
    }
    return await repository.getDetallesPago(pagoId);
  }
}

/// Use Case: Obtener Resumen de Pagos
class GetResumenPagos {
  final PagoRepository repository;

  GetResumenPagos(this.repository);

  Future<Either<Failure, Map<String, double>>> call(int prestamoId) async {
    if (prestamoId <= 0) {
      return Left(ValidationFailure('ID de préstamo inválido'));
    }
    return await repository.getResumenPagos(prestamoId);
  }
}

/// Use Case: Generar Código de Pago
class GenerarCodigoPago {
  final PagoRepository repository;

  GenerarCodigoPago(this.repository);

  Future<Either<Failure, String>> call() async {
    return await repository.generarCodigoPago();
  }
}