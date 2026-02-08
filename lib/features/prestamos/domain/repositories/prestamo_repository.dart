import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/prestamo.dart';
import '../entities/cuota.dart';

abstract class PrestamoRepository {
  // Operaciones CRUD de Préstamos
  Future<Either<Failure, List<Prestamo>>> getPrestamos();
  Future<Either<Failure, Prestamo>> getPrestamoById(int id);
  Future<Either<Failure, List<Prestamo>>> getPrestamosByCliente(int clienteId);
  Future<Either<Failure, List<Prestamo>>> getPrestamosByEstado(EstadoPrestamo estado);
  Future<Either<Failure, Prestamo>> createPrestamo(Prestamo prestamo);
  Future<Either<Failure, Prestamo>> updatePrestamo(Prestamo prestamo);
  Future<Either<Failure, void>> deletePrestamo(int id);
  Future<Either<Failure, void>> cancelarPrestamo(int id);

  // Operaciones de búsqueda
  Future<Either<Failure, List<Prestamo>>> searchPrestamos(String query);
  Future<Either<Failure, List<Prestamo>>> getPrestamosActivos();
  Future<Either<Failure, List<Prestamo>>> getPrestamosEnMora();

  // Operaciones de Cuotas
  Future<Either<Failure, List<Cuota>>> getCuotasByPrestamo(int prestamoId);
  Future<Either<Failure, Cuota>> getCuotaById(int id);
  Future<Either<Failure, List<Cuota>>> getCuotasPendientes(int prestamoId);
  Future<Either<Failure, List<Cuota>>> getCuotasVencidas(int prestamoId);
  Future<Either<Failure, void>> updateCuota(Cuota cuota);

  // Operaciones de actualización de estado
  Future<Either<Failure, void>> actualizarEstadoPrestamo(int prestamoId);
  Future<Either<Failure, void>> actualizarEstadosCuotas(int prestamoId);
}