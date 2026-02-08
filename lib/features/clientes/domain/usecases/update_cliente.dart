import 'package:dartz/dartz.dart';
import '../entities/cliente.dart';
import '../repositories/cliente_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use Case: Actualizar un cliente existente
/// 
/// Este caso de uso maneja la actualización de un cliente,
/// incluyendo validaciones de negocio.
class UpdateCliente {
  final ClienteRepository repository;

  UpdateCliente(this.repository);

  /// Ejecuta el caso de uso
  /// 
  /// Parameters:
  ///   - cliente: Cliente con los datos actualizados (debe incluir ID)
  /// 
  /// Returns:
  ///   - Right(Cliente): Cliente actualizado
  ///   - Left(Failure): Error de validación o persistencia
  Future<Either<Failure, Cliente>> call(Cliente cliente) async {
    // Validar que el cliente tenga ID
    if (cliente.id == null || cliente.id! <= 0) {
      return Left(ValidationFailure(
        'El cliente debe tener un ID válido para ser actualizado'
      ));
    }

    // Validaciones de negocio
    final validationResult = _validateCliente(cliente);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Verificar que el cliente existe
    final existsResult = await repository.getClienteById(cliente.id!);
    
    return existsResult.fold(
      (failure) => Left(DatabaseFailure(
        'No se encontró el cliente con ID ${cliente.id}'
      )),
      (existingCliente) async {
        // Verificar que no exista otro cliente con el mismo CI
        final ciExistsResult = await repository.existeClienteConCI(
          cliente.ci,
          excludeId: cliente.id,
        );

        return ciExistsResult.fold(
          (failure) => Left(failure),
          (exists) async {
            if (exists) {
              return Left(ValidationFailure(
                'Ya existe otro cliente registrado con el CI ${cliente.ci}'
              ));
            }

            // Actualizar el cliente
            return await repository.updateCliente(cliente);
          },
        );
      },
    );
  }

  /// Valida los datos del cliente antes de actualizar
  ValidationFailure? _validateCliente(Cliente cliente) {
    // Validar nombre
    if (cliente.nombre.trim().isEmpty) {
      return ValidationFailure('El nombre del cliente es requerido');
    }

    if (cliente.nombre.trim().length < 3) {
      return ValidationFailure('El nombre debe tener al menos 3 caracteres');
    }

    // Validar CI
    if (cliente.ci.trim().isEmpty) {
      return ValidationFailure('El CI del cliente es requerido');
    }

    if (cliente.ci.trim().length < 5) {
      return ValidationFailure('El CI debe tener al menos 5 caracteres');
    }

    // Validar email si está presente
    if (cliente.email != null && cliente.email!.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(cliente.email!)) {
        return ValidationFailure('El formato del email no es válido');
      }
    }

    // Validar teléfono si está presente
    if (cliente.telefono != null && cliente.telefono!.isNotEmpty) {
      final cleaned = cliente.telefono!.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleaned.length < 7 || cleaned.length > 15) {
        return ValidationFailure(
          'El teléfono debe tener entre 7 y 15 dígitos'
        );
      }
    }

    return null;
  }
}