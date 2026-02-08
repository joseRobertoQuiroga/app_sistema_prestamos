import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/prestamo_repository.dart';

class GenerarCodigoPrestamo {
  final PrestamoRepository repository;

  GenerarCodigoPrestamo(this.repository);

  Future<Either<Failure, String>> call() async {
    try {
      final now = DateTime.now();
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');
      
      // Obtener todos los préstamos para calcular el siguiente número
      final prestamosResult = await repository.getPrestamos();
      
      return prestamosResult.fold(
        (failure) => Left(failure),
        (prestamos) {
          // Filtrar préstamos del mes actual
          final prestamosDelMes = prestamos.where((p) {
            final fecha = p.fechaRegistro;
            return fecha.year == now.year && fecha.month == now.month;
          }).toList();

          final numero = (prestamosDelMes.length + 1).toString().padLeft(4, '0');
          final codigo = 'PRE-$year$month-$numero';
          
          return Right(codigo);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Error al generar código: ${e.toString()}'));
    }
  }
}