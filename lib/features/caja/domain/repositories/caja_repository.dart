import 'package:dartz/dartz.dart';
import '../entities/caja.dart';
import '../entities/movimiento.dart';
import '../entities/resumen_caja.dart';
import '../../../../core/errors/failures.dart';

/// Repositorio abstracto de Cajas - Capa de Dominio
abstract class CajaRepository {
  // CRUD de Cajas
  Future<Either<Failure, List<Caja>>> getCajas();
  Future<Either<Failure, Caja>> getCajaById(int id);
  Future<Either<Failure, List<Caja>>> getCajasActivas();
  Future<Either<Failure, Caja>> createCaja(Caja caja);
  Future<Either<Failure, Caja>> updateCaja(Caja caja);
  Future<Either<Failure, void>> deleteCaja(int id);
  Future<Either<Failure, void>> toggleActivaCaja(int id, bool activa);

  // Movimientos
  Future<Either<Failure, Movimiento>> registrarIngreso({
    required int cajaId,
    required double monto,
    required String categoria,
    required String descripcion,
    required DateTime fecha,
    String? referencia,
    int? prestamoId,
    int? pagoId,
  });

  Future<Either<Failure, Movimiento>> registrarEgreso({
    required int cajaId,
    required double monto,
    required String categoria,
    required String descripcion,
    required DateTime fecha,
    String? referencia,
    int? prestamoId,
    int? pagoId,
  });

  Future<Either<Failure, List<Movimiento>>> registrarTransferencia({
    required int cajaOrigenId,
    required int cajaDestinoId,
    required double monto,
    required String descripcion,
    required DateTime fecha,
    String? referencia,
  });

  Future<Either<Failure, List<Movimiento>>> getMovimientos();
  Future<Either<Failure, List<Movimiento>>> getMovimientosByCaja(int cajaId);
  Future<Either<Failure, List<Movimiento>>> getMovimientosPorPeriodo({
    required int cajaId,
    required DateTime inicio,
    required DateTime fin,
  });

  Future<Either<Failure, List<String>>> getCategorias(String tipo);

  // Consultas
  Future<Either<Failure, double>> getSaldoTotal();
  Future<Either<Failure, ResumenCaja>> getResumenCaja(int cajaId);
  Future<Either<Failure, Map<String, double>>> getResumenGeneral();
}