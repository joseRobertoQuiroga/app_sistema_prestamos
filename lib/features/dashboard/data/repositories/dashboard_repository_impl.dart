import 'package:dartz/dartz.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_data_source.dart';
import '../../../../core/errors/failures.dart';

/// Implementación del repositorio del Dashboard
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;

  DashboardRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, DashboardKPIs>> getKPIs() async {
    try {
      final kpis = await localDataSource.getKPIs();
      return Right(kpis);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener KPIs: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DashboardAlerta>>> getAlertas() async {
    try {
      final alertas = await localDataSource.getAlertas();
      return Right(alertas);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener alertas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ProximoVencimiento>>> getProximosVencimientos({
    int dias = 30,
  }) async {
    try {
      final vencimientos = await localDataSource.getProximosVencimientos(dias: dias);
      return Right(vencimientos);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener vencimientos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPrestamosEnMora() async {
    try {
      final prestamos = await localDataSource.getPrestamosEnMora();
      return Right(prestamos);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener préstamos en mora: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getDistribucionCartera() async {
    try {
      final distribucion = await localDataSource.getDistribucionCartera();
      return Right(distribucion);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener distribución: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getEvolucionSaldos({
    int meses = 6,
  }) async {
    try {
      // TODO: Implementar en data source
      return Right([]);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener evolución: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getMovimientosPorCategoria() async {
    try {
      final movimientos = await localDataSource.getMovimientosPorCategoria();
      return Right(movimientos);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener movimientos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getActividadReciente() async {
    try {
      // TODO: Implementar actividad reciente
      return Right({});
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener actividad: ${e.toString()}'));
    }
  }
}