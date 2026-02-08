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
  /// 
  /// Note: En producción, se debería verificar que el cliente
  /// no tenga préstamos activos antes de eliminarlo.
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
        // TODO: En el futuro, verificar que no tenga préstamos activos
        // Por ahora, procedemos con la eliminación
        
        return await repository.deleteCliente(id);
      },
    );
  }
}