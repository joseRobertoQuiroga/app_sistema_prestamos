import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/prestamo.dart';
import '../../domain/entities/cuota.dart';
import '../../domain/repositories/prestamo_repository.dart';
import '../datasources/prestamo_local_data_source.dart';
import '../models/prestamo_model.dart';
import '../models/cuota_model.dart';

class PrestamoRepositoryImpl implements PrestamoRepository {
  final PrestamoLocalDataSource localDataSource;

  PrestamoRepositoryImpl(this.localDataSource);

  // ============================================================================
  // PRÉSTAMOS
  // ============================================================================

  @override
  Future<Either<Failure, List<Prestamo>>> getPrestamos() async {
    try {
      final prestamos = await localDataSource.getPrestamos();
      return Right(prestamos);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Prestamo>> getPrestamoById(int id) async {
    try {
      final prestamo = await localDataSource.getPrestamoById(id);
      if (prestamo == null) {
        return Left(NotFoundFailure('Préstamo no encontrado'));
      }
      return Right(prestamo);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Prestamo>>> getPrestamosByCliente(
    int clienteId,
  ) async {
    try {
      final prestamos = await localDataSource.getPrestamosByCliente(clienteId);
      return Right(prestamos);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Prestamo>>> getPrestamosByEstado(
    EstadoPrestamo estado,
  ) async {
    try {
      final prestamos = await localDataSource.getPrestamosByEstado(estado);
      return Right(prestamos);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Prestamo>> createPrestamo(Prestamo prestamo) async {
    try {
      final model = PrestamoModel.fromEntity(prestamo);
      final id = await localDataSource.createPrestamo(model);
      final created = await localDataSource.getPrestamoById(id);
      
      if (created == null) {
        return Left(DatabaseFailure('Error al crear préstamo'));
      }
      
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Prestamo>> updatePrestamo(Prestamo prestamo) async {
    try {
      final model = PrestamoModel.fromEntity(prestamo);
      final success = await localDataSource.updatePrestamo(model);
      
      if (!success) {
        return Left(DatabaseFailure('Error al actualizar préstamo'));
      }

      final updated = await localDataSource.getPrestamoById(prestamo.id!);
      if (updated == null) {
        return Left(NotFoundFailure('Préstamo no encontrado'));
      }

      return Right(updated);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePrestamo(int id) async {
    try {
      await localDataSource.deletePrestamo(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelarPrestamo(int id) async {
    try {
      await localDataSource.cancelarPrestamo(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Prestamo>>> searchPrestamos(String query) async {
    try {
      final prestamos = await localDataSource.searchPrestamos(query);
      return Right(prestamos);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Prestamo>>> getPrestamosActivos() async {
    try {
      final prestamos = await localDataSource.getPrestamosActivos();
      return Right(prestamos);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Prestamo>>> getPrestamosEnMora() async {
    try {
      final prestamos = await localDataSource.getPrestamosEnMora();
      return Right(prestamos);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  // ============================================================================
  // CUOTAS
  // ============================================================================

  @override
  Future<Either<Failure, List<Cuota>>> getCuotasByPrestamo(
    int prestamoId,
  ) async {
    try {
      final cuotas = await localDataSource.getCuotasByPrestamo(prestamoId);
      return Right(cuotas);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Cuota>> getCuotaById(int id) async {
    try {
      final cuota = await localDataSource.getCuotaById(id);
      if (cuota == null) {
        return Left(NotFoundFailure('Cuota no encontrada'));
      }
      return Right(cuota);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Cuota>>> getCuotasPendientes(
    int prestamoId,
  ) async {
    try {
      final cuotas = await localDataSource.getCuotasPendientes(prestamoId);
      return Right(cuotas);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Cuota>>> getCuotasVencidas(
    int prestamoId,
  ) async {
    try {
      final cuotas = await localDataSource.getCuotasVencidas(prestamoId);
      return Right(cuotas);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCuota(Cuota cuota) async {
    try {
      final model = CuotaModel.fromEntity(cuota);
      await localDataSource.updateCuota(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  // ============================================================================
  // ACTUALIZACIÓN DE ESTADOS
  // ============================================================================

  @override
  Future<Either<Failure, void>> actualizarEstadoPrestamo(int prestamoId) async {
    try {
      await localDataSource.actualizarEstadoPrestamo(prestamoId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> actualizarEstadosCuotas(int prestamoId) async {
    try {
      await localDataSource.actualizarEstadosCuotas(prestamoId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}