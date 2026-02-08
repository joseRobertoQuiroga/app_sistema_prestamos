import 'package:dartz/dartz.dart';
import '../entities/caja.dart';
import '../entities/movimiento.dart';
import '../entities/resumen_caja.dart';
import '../repositories/caja_repository.dart';
import '../../../../core/errors/failures.dart';

// ============= CAJAS =============

class GetCajas {
  final CajaRepository repository;
  GetCajas(this.repository);

  Future<Either<Failure, List<Caja>>> call() async {
    return await repository.getCajas();
  }
}

class GetCajasActivas {
  final CajaRepository repository;
  GetCajasActivas(this.repository);

  Future<Either<Failure, List<Caja>>> call() async {
    return await repository.getCajasActivas();
  }
}

class GetCajaById {
  final CajaRepository repository;
  GetCajaById(this.repository);

  Future<Either<Failure, Caja>> call(int id) async {
    if (id <= 0) {
      return Left(ValidationFailure('ID de caja inválido'));
    }
    return await repository.getCajaById(id);
  }
}

class CreateCaja {
  final CajaRepository repository;
  CreateCaja(this.repository);

  Future<Either<Failure, Caja>> call(Caja caja) async {
    // Validaciones
    if (caja.nombre.trim().isEmpty) {
      return Left(ValidationFailure('El nombre de la caja es requerido'));
    }

    if (caja.tipo.trim().isEmpty) {
      return Left(ValidationFailure('El tipo de caja es requerido'));
    }

    if (caja.saldo < 0) {
      return Left(ValidationFailure('El saldo inicial no puede ser negativo'));
    }

    return await repository.createCaja(caja);
  }
}

class UpdateCaja {
  final CajaRepository repository;
  UpdateCaja(this.repository);

  Future<Either<Failure, Caja>> call(Caja caja) async {
    if (caja.id == null || caja.id! <= 0) {
      return Left(ValidationFailure('ID de caja inválido'));
    }

    if (caja.nombre.trim().isEmpty) {
      return Left(ValidationFailure('El nombre de la caja es requerido'));
    }

    return await repository.updateCaja(caja);
  }
}

class DeleteCaja {
  final CajaRepository repository;
  DeleteCaja(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    if (id <= 0) {
      return Left(ValidationFailure('ID de caja inválido'));
    }
    return await repository.deleteCaja(id);
  }
}

// ============= MOVIMIENTOS =============

class RegistrarIngreso {
  final CajaRepository repository;
  RegistrarIngreso(this.repository);

  Future<Either<Failure, Movimiento>> call({
    required int cajaId,
    required double monto,
    required String categoria,
    required String descripcion,
    required DateTime fecha,
    String? referencia,
  }) async {
    if (cajaId <= 0) {
      return Left(ValidationFailure('ID de caja inválido'));
    }

    if (monto <= 0) {
      return Left(ValidationFailure('El monto debe ser mayor a 0'));
    }

    if (descripcion.trim().isEmpty) {
      return Left(ValidationFailure('La descripción es requerida'));
    }

    return await repository.registrarIngreso(
      cajaId: cajaId,
      monto: monto,
      categoria: categoria,
      descripcion: descripcion,
      fecha: fecha,
      referencia: referencia,
    );
  }
}

class RegistrarEgreso {
  final CajaRepository repository;
  RegistrarEgreso(this.repository);

  Future<Either<Failure, Movimiento>> call({
    required int cajaId,
    required double monto,
    required String categoria,
    required String descripcion,
    required DateTime fecha,
    String? referencia,
  }) async {
    if (cajaId <= 0) {
      return Left(ValidationFailure('ID de caja inválido'));
    }

    if (monto <= 0) {
      return Left(ValidationFailure('El monto debe ser mayor a 0'));
    }

    if (descripcion.trim().isEmpty) {
      return Left(ValidationFailure('La descripción es requerida'));
    }

    // Verificar que haya saldo suficiente
    final cajaResult = await repository.getCajaById(cajaId);
    return cajaResult.fold(
      (failure) => Left(failure),
      (caja) async {
        if (caja.saldo < monto) {
          return Left(ValidationFailure(
            'Saldo insuficiente. Disponible: ${caja.saldo}, Requerido: $monto'
          ));
        }

        return await repository.registrarEgreso(
          cajaId: cajaId,
          monto: monto,
          categoria: categoria,
          descripcion: descripcion,
          fecha: fecha,
          referencia: referencia,
        );
      },
    );
  }
}

class RegistrarTransferencia {
  final CajaRepository repository;
  RegistrarTransferencia(this.repository);

  Future<Either<Failure, List<Movimiento>>> call({
    required int cajaOrigenId,
    required int cajaDestinoId,
    required double monto,
    required String descripcion,
    required DateTime fecha,
    String? referencia,
  }) async {
    // Validaciones
    if (cajaOrigenId <= 0 || cajaDestinoId <= 0) {
      return Left(ValidationFailure('IDs de cajas inválidos'));
    }

    if (cajaOrigenId == cajaDestinoId) {
      return Left(ValidationFailure('No puede transferir a la misma caja'));
    }

    if (monto <= 0) {
      return Left(ValidationFailure('El monto debe ser mayor a 0'));
    }

    if (descripcion.trim().isEmpty) {
      return Left(ValidationFailure('La descripción es requerida'));
    }

    // Verificar saldo suficiente en caja origen
    final cajaOrigenResult = await repository.getCajaById(cajaOrigenId);
    return cajaOrigenResult.fold(
      (failure) => Left(failure),
      (cajaOrigen) async {
        if (cajaOrigen.saldo < monto) {
          return Left(ValidationFailure(
            'Saldo insuficiente en ${cajaOrigen.nombre}. '
            'Disponible: ${cajaOrigen.saldo}, Requerido: $monto'
          ));
        }

        return await repository.registrarTransferencia(
          cajaOrigenId: cajaOrigenId,
          cajaDestinoId: cajaDestinoId,
          monto: monto,
          descripcion: descripcion,
          fecha: fecha,
          referencia: referencia,
        );
      },
    );
  }
}

class GetMovimientosByCaja {
  final CajaRepository repository;
  GetMovimientosByCaja(this.repository);

  Future<Either<Failure, List<Movimiento>>> call(int cajaId) async {
    if (cajaId <= 0) {
      return Left(ValidationFailure('ID de caja inválido'));
    }
    return await repository.getMovimientosByCaja(cajaId);
  }
}

class GetMovimientosPorPeriodo {
  final CajaRepository repository;
  GetMovimientosPorPeriodo(this.repository);

  Future<Either<Failure, List<Movimiento>>> call({
    required int cajaId,
    required DateTime inicio,
    required DateTime fin,
  }) async {
    if (cajaId <= 0) {
      return Left(ValidationFailure('ID de caja inválido'));
    }

    if (fin.isBefore(inicio)) {
      return Left(ValidationFailure('La fecha final no puede ser anterior a la inicial'));
    }

    return await repository.getMovimientosPorPeriodo(
      cajaId: cajaId,
      inicio: inicio,
      fin: fin,
    );
  }
}

// ============= CONSULTAS =============

class GetSaldoTotal {
  final CajaRepository repository;
  GetSaldoTotal(this.repository);

  Future<Either<Failure, double>> call() async {
    return await repository.getSaldoTotal();
  }
}

class GetResumenCaja {
  final CajaRepository repository;
  GetResumenCaja(this.repository);

  Future<Either<Failure, ResumenCaja>> call(int cajaId) async {
    if (cajaId <= 0) {
      return Left(ValidationFailure('ID de caja inválido'));
    }
    return await repository.getResumenCaja(cajaId);
  }
}

class GetResumenGeneral {
  final CajaRepository repository;
  GetResumenGeneral(this.repository);

  Future<Either<Failure, Map<String, double>>> call() async {
    return await repository.getResumenGeneral();
  }
}