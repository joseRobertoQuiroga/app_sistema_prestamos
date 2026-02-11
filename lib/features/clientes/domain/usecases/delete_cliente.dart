import 'package:dartz/dartz.dart';
import '../repositories/cliente_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use Case: Eliminar un cliente
/// 
/// Este caso de uso maneja la eliminación de un cliente,
/// incluyendo validaciones previas.
class DeleteCliente {
  final ClienteRepository repository;

  DeleteCliente(this.repository);

  /// Ejecuta el caso de uso
  /// 
  /// Parameters:
  ///   - id: ID del cliente a eliminar
  /// 
  /// Returns:
  ///   - Right(void): Éxito en la eliminación
  ///   - Left(Failure): Error si falla la validación o eliminación
  Future<Either<Failure, void>> call(int id) async {
    // Validar ID
    if (id <= 0) {
      return Left(ValidationFailure('ID de cliente inválido'));
    }

    // Verificar que el cliente existe
    final existsResult = await repository.getClienteById(id);
    
    return existsResult.fold(
      (failure) => Left(DatabaseFailure(
        'No se encontró el cliente con ID $id'
      )),
      (cliente) async {
        // ✅ VALIDACIÓN CRÍTICA: Verificar préstamos activos
        final tienePrestamosResult = await repository.clienteTienePrestamosActivos(id);
        
        return tienePrestamosResult.fold(
          (failure) => Left(failure),
          (tienePrestamos) async {
            if (tienePrestamos) {
              return Left(ValidationFailure(
                'No se puede eliminar el cliente porque tiene préstamos activos o en mora. '
                'Por favor, cancele o finalice los préstamos antes de eliminar el cliente.'
              ));
            }
            
            // Si no tiene préstamos activos, proceder con la eliminación
            return await repository.deleteCliente(id);
          },
        );
      },
    );
  }
}