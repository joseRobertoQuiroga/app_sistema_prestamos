import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cuota.dart';
import '../repositories/prestamo_repository.dart';

// ============================================================================
// GET CUOTAS
// ============================================================================

class GetCuotasByPrestamo {
  final PrestamoRepository repository;

  GetCuotasByPrestamo(this.repository);

  Future<Either<Failure, List<Cuota>>> call(int prestamoId) async {
    return await repository.getCuotasByPrestamo(prestamoId);
  }
}

class GetCuotaById {
  final PrestamoRepository repository;

  GetCuotaById(this.repository);

  Future<Either<Failure, Cuota>> call(int id) async {
    return await repository.getCuotaById(id);
  }
}

class GetCuotasPendientes {
  final PrestamoRepository repository;

  GetCuotasPendientes(this.repository);

  Future<Either<Failure, List<Cuota>>> call(int prestamoId) async {
    return await repository.getCuotasPendientes(prestamoId);
  }
}

class GetCuotasVencidas {
  final PrestamoRepository repository;

  GetCuotasVencidas(this.repository);

  Future<Either<Failure, List<Cuota>>> call(int prestamoId) async {
    return await repository.getCuotasVencidas(prestamoId);
  }
}

// ============================================================================
// UPDATE CUOTA
// ============================================================================

class UpdateCuota {
  final PrestamoRepository repository;

  UpdateCuota(this.repository);

  Future<Either<Failure, void>> call(Cuota cuota) async {
    if (cuota.id == null) {
      return Left(ValidationFailure('La cuota debe tener un ID'));
    }

    return await repository.updateCuota(cuota);
  }
}

// ============================================================================
// CALCULAR MORA
// ============================================================================

class CalcularMoraCuota {
  static const double tasaMoraDiaria = 0.5; // 0.5% por día

  Either<Failure, double> call(Cuota cuota) {
    try {
      if (cuota.estaPagada) {
        return const Right(0.0);
      }

      final now = DateTime.now();
      if (!now.isAfter(cuota.fechaVencimiento)) {
        return const Right(0.0);
      }

      final diasMora = now.difference(cuota.fechaVencimiento).inDays;
      if (diasMora <= 0) {
        return const Right(0.0);
      }

      final saldo = cuota.saldoCuota;
      final mora = (saldo * tasaMoraDiaria / 100) * diasMora;

      return Right(mora);
    } catch (e) {
      return Left(CalculationFailure('Error al calcular mora: ${e.toString()}'));
    }
  }
}

// ============================================================================
// OBTENER PRÓXIMA CUOTA
// ============================================================================

class GetProximaCuota {
  final PrestamoRepository repository;

  GetProximaCuota(this.repository);

  Future<Either<Failure, Cuota?>> call(int prestamoId) async {
    final cuotasResult = await repository.getCuotasPendientes(prestamoId);

    return cuotasResult.fold(
      (failure) => Left(failure),
      (cuotas) {
        if (cuotas.isEmpty) {
          return const Right(null);
        }

        // Ordenar por fecha de vencimiento
        cuotas.sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));
        
        return Right(cuotas.first);
      },
    );
  }
}

// ============================================================================
// OBTENER RESUMEN DE CUOTAS
// ============================================================================

class GetResumenCuotas {
  final PrestamoRepository repository;

  GetResumenCuotas(this.repository);

  Future<Either<Failure, ResumenCuotas>> call(int prestamoId) async {
    final cuotasResult = await repository.getCuotasByPrestamo(prestamoId);

    return cuotasResult.fold(
      (failure) => Left(failure),
      (cuotas) {
        int totalCuotas = cuotas.length;
        int cuotasPagadas = 0;
        int cuotasPendientes = 0;
        int cuotasVencidas = 0;
        double montoTotal = 0;
        double montoPagado = 0;
        double montoPendiente = 0;
        double moraTotal = 0;

        for (final cuota in cuotas) {
          montoTotal += cuota.montoCuota;
          montoPagado += cuota.montoPagado;
          moraTotal += cuota.montoMora;

          if (cuota.estaPagada) {
            cuotasPagadas++;
          } else {
            montoPendiente += cuota.saldoCuota;
            cuotasPendientes++;
            
            if (cuota.estaVencida) {
              cuotasVencidas++;
            }
          }
        }

        return Right(ResumenCuotas(
          totalCuotas: totalCuotas,
          cuotasPagadas: cuotasPagadas,
          cuotasPendientes: cuotasPendientes,
          cuotasVencidas: cuotasVencidas,
          montoTotal: montoTotal,
          montoPagado: montoPagado,
          montoPendiente: montoPendiente,
          moraTotal: moraTotal,
        ));
      },
    );
  }
}

// Clase para el resumen de cuotas
class ResumenCuotas {
  final int totalCuotas;
  final int cuotasPagadas;
  final int cuotasPendientes;
  final int cuotasVencidas;
  final double montoTotal;
  final double montoPagado;
  final double montoPendiente;
  final double moraTotal;

  ResumenCuotas({
    required this.totalCuotas,
    required this.cuotasPagadas,
    required this.cuotasPendientes,
    required this.cuotasVencidas,
    required this.montoTotal,
    required this.montoPagado,
    required this.montoPendiente,
    required this.moraTotal,
  });

  double get porcentajePagado {
    if (montoTotal == 0) return 0;
    return (montoPagado / montoTotal) * 100;
  }
}