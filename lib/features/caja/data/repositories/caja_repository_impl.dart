import 'package:dartz/dartz.dart';
import '../../domain/entities/caja.dart';
import '../../domain/entities/movimiento.dart';
import '../../domain/entities/resumen_caja.dart';
import '../../domain/repositories/caja_repository.dart';
import '../datasources/caja_local_data_source.dart';
import '../../../../core/errors/failures.dart';

/// Implementación del repositorio de cajas
class CajaRepositoryImpl implements CajaRepository {
  final CajaLocalDataSource localDataSource;

  CajaRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Caja>>> getCajas() async {
    try {
      final cajas = await localDataSource.getCajas();
      return Right(cajas);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener cajas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Caja>> getCajaById(int id) async {
    try {
      final caja = await localDataSource.getCajaById(id);
      return Right(caja);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener caja: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Caja>>> getCajasActivas() async {
    try {
      final cajas = await localDataSource.getCajasActivas();
      return Right(cajas);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener cajas activas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Caja>> createCaja(Caja caja) async {
    try {
      final cajaModel = CajaModel.fromEntity(caja);
      final created = await localDataSource.createCaja(cajaModel);
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure('Error al crear caja: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Caja>> updateCaja(Caja caja) async {
    try {
      final cajaModel = CajaModel.fromEntity(caja);
      final updated = await localDataSource.updateCaja(cajaModel);
      return Right(updated);
    } catch (e) {
      return Left(DatabaseFailure('Error al actualizar caja: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCaja(int id) async {
    try {
      await localDataSource.deleteCaja(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Error al eliminar caja: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleActivaCaja(int id, bool activa) async {
    try {
      await localDataSource.toggleActivaCaja(id, activa);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Error al cambiar estado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Movimiento>> registrarIngreso({
    required int cajaId,
    required double monto,
    required String categoria,
    required String descripcion,
    required DateTime fecha,
    String? referencia,
  }) async {
    try {
      final movimiento = await localDataSource.registrarIngreso(
        cajaId: cajaId,
        monto: monto,
        categoria: categoria,
        descripcion: descripcion,
        fecha: fecha,
        referencia: referencia,
      );
      return Right(movimiento);
    } catch (e) {
      return Left(DatabaseFailure('Error al registrar ingreso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Movimiento>> registrarEgreso({
    required int cajaId,
    required double monto,
    required String categoria,
    required String descripcion,
    required DateTime fecha,
    String? referencia,
  }) async {
    try {
      final movimiento = await localDataSource.registrarEgreso(
        cajaId: cajaId,
        monto: monto,
        categoria: categoria,
        descripcion: descripcion,
        fecha: fecha,
        referencia: referencia,
      );
      return Right(movimiento);
    } catch (e) {
      return Left(DatabaseFailure('Error al registrar egreso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Movimiento>>> registrarTransferencia({
    required int cajaOrigenId,
    required int cajaDestinoId,
    required double monto,
    required String descripcion,
    required DateTime fecha,
    String? referencia,
  }) async {
    try {
      final movimientos = await localDataSource.registrarTransferencia(
        cajaOrigenId: cajaOrigenId,
        cajaDestinoId: cajaDestinoId,
        monto: monto,
        descripcion: descripcion,
        fecha: fecha,
        referencia: referencia,
      );
      return Right(movimientos);
    } catch (e) {
      return Left(DatabaseFailure('Error al registrar transferencia: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Movimiento>>> getMovimientos() async {
    try {
      final movimientos = await localDataSource.getMovimientos();
      return Right(movimientos);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener movimientos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Movimiento>>> getMovimientosByCaja(int cajaId) async {
    try {
      final movimientos = await localDataSource.getMovimientosByCaja(cajaId);
      return Right(movimientos);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener movimientos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Movimiento>>> getMovimientosPorPeriodo({
    required int cajaId,
    required DateTime inicio,
    required DateTime fin,
  }) async {
    try {
      final movimientos = await localDataSource.getMovimientosPorPeriodo(
        cajaId: cajaId,
        inicio: inicio,
        fin: fin,
      );
      return Right(movimientos);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener movimientos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> getSaldoTotal() async {
    try {
      final saldo = await localDataSource.getSaldoTotal();
      return Right(saldo);
    } catch (e) {
      return Left(DatabaseFailure('Error al calcular saldo total: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ResumenCaja>> getResumenCaja(int cajaId) async {
    try {
      final resumen = await localDataSource.getResumenCaja(cajaId);
      return Right(resumen);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener resumen: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getResumenGeneral() async {
    try {
      final resumen = await localDataSource.getResumenGeneral();
      return Right(resumen);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener resumen general: ${e.toString()}'));
    }
  }
}