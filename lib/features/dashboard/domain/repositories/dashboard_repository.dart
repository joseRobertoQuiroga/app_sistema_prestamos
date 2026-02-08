import 'package:dartz/dartz.dart';
import '../entities/dashboard_entities.dart';
import '../../../../core/errors/failures.dart';

/// Repositorio abstracto del Dashboard - Capa de Dominio
abstract class DashboardRepository {
  /// Obtiene todos los KPIs del sistema
  Future<Either<Failure, DashboardKPIs>> getKPIs();

  /// Obtiene las alertas activas
  Future<Either<Failure, List<DashboardAlerta>>> getAlertas();

  /// Obtiene los próximos vencimientos
  Future<Either<Failure, List<ProximoVencimiento>>> getProximosVencimientos({
    int dias = 30,
  });

  /// Obtiene préstamos en mora
  Future<Either<Failure, List<Map<String, dynamic>>>> getPrestamosEnMora();

  /// Obtiene distribución de cartera por estado
  Future<Either<Failure, Map<String, double>>> getDistribucionCartera();

  /// Obtiene evolución de saldos (últimos N meses)
  Future<Either<Failure, List<Map<String, dynamic>>>> getEvolucionSaldos({
    int meses = 6,
  });

  /// Obtiene movimientos del mes por categoría
  Future<Either<Failure, Map<String, double>>> getMovimientosPorCategoria();

  /// Obtiene resumen de actividad reciente
  Future<Either<Failure, Map<String, dynamic>>> getActividadReciente();
}