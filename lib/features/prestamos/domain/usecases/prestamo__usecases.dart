import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/prestamo.dart';
import '../entities/cuota.dart';
import '../repositories/prestamo_repository.dart';
import 'generar_tabla_amortizacion.dart';

// ============================================================================
// GET PRESTAMOS
// ============================================================================

class GetPrestamos {
  final PrestamoRepository repository;

  GetPrestamos(this.repository);

  Future<Either<Failure, List<Prestamo>>> call() async {
    return await repository.getPrestamos();
  }
}

class GetPrestamoById {
  final PrestamoRepository repository;

  GetPrestamoById(this.repository);

  Future<Either<Failure, Prestamo>> call(int id) async {
    return await repository.getPrestamoById(id);
  }
}

class GetPrestamosByCliente {
  final PrestamoRepository repository;

  GetPrestamosByCliente(this.repository);

  Future<Either<Failure, List<Prestamo>>> call(int clienteId) async {
    return await repository.getPrestamosByCliente(clienteId);
  }
}

class GetPrestamosByEstado {
  final PrestamoRepository repository;

  GetPrestamosByEstado(this.repository);

  Future<Either<Failure, List<Prestamo>>> call(EstadoPrestamo estado) async {
    return await repository.getPrestamosByEstado(estado);
  }
}

class SearchPrestamos {
  final PrestamoRepository repository;

  SearchPrestamos(this.repository);

  Future<Either<Failure, List<Prestamo>>> call(String query) async {
    if (query.trim().isEmpty) {
      return await repository.getPrestamos();
    }
    return await repository.searchPrestamos(query);
  }
}

class GetPrestamosActivos {
  final PrestamoRepository repository;

  GetPrestamosActivos(this.repository);

  Future<Either<Failure, List<Prestamo>>> call() async {
    return await repository.getPrestamosActivos();
  }
}

class GetPrestamosEnMora {
  final PrestamoRepository repository;

  GetPrestamosEnMora(this.repository);

  Future<Either<Failure, List<Prestamo>>> call() async {
    return await repository.getPrestamosEnMora();
  }
}

// ============================================================================
// CREATE PRESTAMO
// ============================================================================

class CreatePrestamo {
  final PrestamoRepository repository;
  final GenerarTablaAmortizacion generarTabla;

  CreatePrestamo(this.repository, this.generarTabla);

  Future<Either<Failure, Prestamo>> call(Prestamo prestamo) async {
    // Validaciones de negocio
    final validationError = _validate(prestamo);
    if (validationError != null) {
      return Left(validationError);
    }

    // Calcular totales
    final totales = GenerarTablaAmortizacion.calcularTotales(
      monto: prestamo.montoOriginal,
      tasaInteres: prestamo.tasaInteres,
      tipoInteres: prestamo.tipoInteres,
      plazoMeses: prestamo.plazoMeses,
    );

    // Crear préstamo con valores calculados
    final prestamoCompleto = prestamo.copyWith(
      montoTotal: totales['montoTotal']!,
      saldoPendiente: totales['montoTotal']!,
      cuotaMensual: totales['cuotaMensual']!,
      estado: EstadoPrestamo.activo,
      fechaRegistro: DateTime.now(),
    );

    return await repository.createPrestamo(prestamoCompleto);
  }

  ValidationFailure? _validate(Prestamo prestamo) {
    if (prestamo.montoOriginal <= 0) {
      return ValidationFailure('El monto debe ser mayor a 0');
    }

    if (prestamo.tasaInteres < 0 || prestamo.tasaInteres > 100) {
      return ValidationFailure('La tasa de interés debe estar entre 0 y 100');
    }

    if (prestamo.plazoMeses <= 0) {
      return ValidationFailure('El plazo debe ser mayor a 0 meses');
    }

    if (prestamo.plazoMeses > 120) {
      return ValidationFailure('El plazo máximo es 120 meses (10 años)');
    }

    if (prestamo.fechaInicio.isAfter(prestamo.fechaVencimiento)) {
      return ValidationFailure('La fecha de inicio debe ser anterior a la de vencimiento');
    }

    return null;
  }
}

// ============================================================================
// UPDATE PRESTAMO
// ============================================================================

class UpdatePrestamo {
  final PrestamoRepository repository;

  UpdatePrestamo(this.repository);

  Future<Either<Failure, Prestamo>> call(Prestamo prestamo) async {
    if (prestamo.id == null) {
      return Left(ValidationFailure('El préstamo debe tener un ID'));
    }

    // Solo permitir actualizar ciertos campos
    // No se puede cambiar monto, tasa o plazo una vez creado
    final prestamoActualizado = prestamo.copyWith(
      fechaActualizacion: DateTime.now(),
    );

    return await repository.updatePrestamo(prestamoActualizado);
  }
}

// ============================================================================
// CANCEL PRESTAMO
// ============================================================================

class CancelarPrestamo {
  final PrestamoRepository repository;

  CancelarPrestamo(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    // Verificar que el préstamo exista
    final prestamoResult = await repository.getPrestamoById(id);
    
    return prestamoResult.fold(
      (failure) => Left(failure),
      (prestamo) async {
        // Solo se puede cancelar si no está pagado
        if (prestamo.estado == EstadoPrestamo.pagado) {
          return Left(ValidationFailure('No se puede cancelar un préstamo ya pagado'));
        }

        return await repository.cancelarPrestamo(id);
      },
    );
  }
}

// ============================================================================
// DELETE PRESTAMO
// ============================================================================

class DeletePrestamo {
  final PrestamoRepository repository;

  DeletePrestamo(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    // Verificar que el préstamo exista
    final prestamoResult = await repository.getPrestamoById(id);
    
    return prestamoResult.fold(
      (failure) => Left(failure),
      (prestamo) async {
        // No permitir eliminar préstamos con pagos
        if (prestamo.montoPagado > 0) {
          return Left(ValidationFailure(
            'No se puede eliminar un préstamo con pagos registrados. Cancélelo en su lugar.'
          ));
        }

        return await repository.deletePrestamo(id);
      },
    );
  }
}

// ============================================================================
// ACTUALIZAR ESTADO
// ============================================================================

class ActualizarEstadoPrestamo {
  final PrestamoRepository repository;

  ActualizarEstadoPrestamo(this.repository);

  Future<Either<Failure, void>> call(int prestamoId) async {
    return await repository.actualizarEstadoPrestamo(prestamoId);
  }
}

class ActualizarEstadosCuotas {
  final PrestamoRepository repository;

  ActualizarEstadosCuotas(this.repository);

  Future<Either<Failure, void>> call(int prestamoId) async {
    return await repository.actualizarEstadosCuotas(prestamoId);
  }
}