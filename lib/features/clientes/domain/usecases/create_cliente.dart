import 'package:dartz/dartz.dart';
import '../entities/cliente.dart';
import '../repositories/cliente_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use Case: Crear un nuevo cliente
/// 
/// Este caso de uso maneja la creación de un nuevo cliente,
/// incluyendo validaciones de negocio antes de persistir.
class CreateCliente {
  final ClienteRepository repository;

  CreateCliente(this.repository);

  /// Ejecuta el caso de uso
  /// 
  /// Parameters:
  ///   - cliente: Cliente a crear (sin ID)
  /// 
  /// Returns:
  ///   - Right(Cliente): Cliente creado con su ID asignado
  ///   - Left(Failure): Error de validación o persistencia
  Future<Either<Failure, Cliente>> call(Cliente cliente) async {
    // Validaciones de negocio
    final validationResult = _validateCliente(cliente);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Verificar que no exista otro cliente con el mismo CI
    final existsResult = await repository.existeClienteConCI(cliente.ci);
    
    return existsResult.fold(
      (failure) => Left(failure),
      (exists) async {
        if (exists) {
          return Left(ValidationFailure(
            'Ya existe un cliente registrado con el CI ${cliente.ci}'
          ));
        }

        // Crear el cliente
        return await repository.createCliente(cliente);
      },
    );
  }

  /// Valida los datos del cliente antes de crear
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