import 'package:dartz/dartz.dart';
import '../entities/dashboard_entities.dart';
import '../repositories/dashboard_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use Case: Obtener KPIs
class GetDashboardKPIs {
  final DashboardRepository repository;
  GetDashboardKPIs(this.repository);

  Future<Either<Failure, DashboardKPIs>> call() async {
    return await repository.getKPIs();
  }
}

/// Use Case: Obtener Alertas
class GetDashboardAlertas {
  final DashboardRepository repository;
  GetDashboardAlertas(this.repository);

  Future<Either<Failure, List<DashboardAlerta>>> call() async {
    return await repository.getAlertas();
  }
}

/// Use Case: Obtener Próximos Vencimientos
class GetProximosVencimientos {
  final DashboardRepository repository;
  GetProximosVencimientos(this.repository);

  Future<Either<Failure, List<ProximoVencimiento>>> call({int dias = 30}) async {
    if (dias <= 0) {
      return Left(ValidationFailure('Los días deben ser mayor a 0'));
    }
    return await repository.getProximosVencimientos(dias: dias);
  }
}

/// Use Case: Obtener Préstamos en Mora
class GetPrestamosEnMora {
  final DashboardRepository repository;
  GetPrestamosEnMora(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() async {
    return await repository.getPrestamosEnMora();
  }
}

/// Use Case: Obtener Distribución de Cartera
class GetDistribucionCartera {
  final DashboardRepository repository;
  GetDistribucionCartera(this.repository);

  Future<Either<Failure, Map<String, double>>> call() async {
    return await repository.getDistribucionCartera();
  }
}

/// Use Case: Obtener Evolución de Saldos
class GetEvolucionSaldos {
  final DashboardRepository repository;
  GetEvolucionSaldos(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call({int meses = 6}) async {
    if (meses <= 0 || meses > 24) {
      return Left(ValidationFailure('Los meses deben estar entre 1 y 24'));
    }
    return await repository.getEvolucionSaldos(meses: meses);
  }
}

/// Use Case: Obtener Movimientos por Categoría
class GetMovimientosPorCategoria {
  final DashboardRepository repository;
  GetMovimientosPorCategoria(this.repository);

  Future<Either<Failure, Map<String, double>>> call() async {
    return await repository.getMovimientosPorCategoria();
  }
}