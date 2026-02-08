import 'package:dartz/dartz.dart';
import '../entities/cliente.dart';
import '../repositories/cliente_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use Case: Obtener todos los clientes
/// 
/// Este caso de uso obtiene la lista completa de clientes del repositorio.
class GetClientes {
  final ClienteRepository repository;

  GetClientes(this.repository);

  /// Ejecuta el caso de uso
  /// 
  /// Returns:
  ///   - Right(List<Cliente>): Lista de todos los clientes
  ///   - Left(Failure): Error si falla la operación
  Future<Either<Failure, List<Cliente>>> call() async {
    return await repository.getClientes();
  }
}

/// Use Case: Obtener cliente por ID
/// 
/// Este caso de uso obtiene un cliente específico por su ID.
class GetClienteById {
  final ClienteRepository repository;

  GetClienteById(this.repository);

  /// Ejecuta el caso de uso
  /// 
  /// Parameters:
  ///   - id: ID del cliente a obtener
  /// 
  /// Returns:
  ///   - Right(Cliente): Cliente encontrado
  ///   - Left(Failure): Error si no se encuentra o falla
  Future<Either<Failure, Cliente>> call(int id) async {
    if (id <= 0) {
      return Left(ValidationFailure('ID de cliente inválido'));
    }
    return await repository.getClienteById(id);
  }
}

/// Use Case: Buscar clientes
/// 
/// Este caso de uso busca clientes por nombre o CI.
class SearchClientes {
  final ClienteRepository repository;

  SearchClientes(this.repository);

  /// Ejecuta el caso de uso
  /// 
  /// Parameters:
  ///   - query: Texto a buscar
  /// 
  /// Returns:
  ///   - Right(List<Cliente>): Lista de clientes encontrados
  ///   - Left(Failure): Error si falla la búsqueda
  Future<Either<Failure, List<Cliente>>> call(String query) async {
    if (query.trim().isEmpty) {
      // Si la búsqueda está vacía, devolver todos los clientes
      return await repository.getClientes();
    }
    return await repository.searchClientes(query.trim());
  }
}

/// Use Case: Obtener clientes activos
/// 
/// Este caso de uso obtiene solo los clientes activos.
class GetClientesActivos {
  final ClienteRepository repository;

  GetClientesActivos(this.repository);

  /// Ejecuta el caso de uso
  /// 
  /// Returns:
  ///   - Right(List<Cliente>): Lista de clientes activos
  ///   - Left(Failure): Error si falla la operación
  Future<Either<Failure, List<Cliente>>> call() async {
    return await repository.getClientesActivos();
  }
}