import 'package:dartz/dartz.dart';
import '../entities/cliente.dart';
import '../../../../core/errors/failures.dart';

/// Repositorio abstracto de Clientes - Capa de Dominio
/// 
/// Define el contrato que debe implementar cualquier repositorio de clientes.
/// Esta interfaz es independiente de la implementación (puede ser local, remota, etc.)
abstract class ClienteRepository {
  /// Obtiene todos los clientes
  /// 
  /// Returns:
  ///   - Right(List<Cliente>): Lista de clientes si la operación es exitosa
  ///   - Left(Failure): Error si algo falla
  Future<Either<Failure, List<Cliente>>> getClientes();

  /// Obtiene un cliente por su ID
  /// 
  /// Parameters:
  ///   - id: ID del cliente a buscar
  /// 
  /// Returns:
  ///   - Right(Cliente): Cliente encontrado
  ///   - Left(Failure): Error si no se encuentra o falla
  Future<Either<Failure, Cliente>> getClienteById(int id);

  /// Busca clientes por nombre o CI
  /// 
  /// Parameters:
  ///   - query: Texto a buscar (puede ser nombre o CI)
  /// 
  /// Returns:
  ///   - Right(List<Cliente>): Lista de clientes que coinciden con la búsqueda
  ///   - Left(Failure): Error si falla la búsqueda
  Future<Either<Failure, List<Cliente>>> searchClientes(String query);

  /// Crea un nuevo cliente
  /// 
  /// Parameters:
  ///   - cliente: Cliente a crear (sin ID)
  /// 
  /// Returns:
  ///   - Right(Cliente): Cliente creado con su ID asignado
  ///   - Left(Failure): Error si falla la creación
  Future<Either<Failure, Cliente>> createCliente(Cliente cliente);

  /// Actualiza un cliente existente
  /// 
  /// Parameters:
  ///   - cliente: Cliente con los datos actualizados (debe tener ID)
  /// 
  /// Returns:
  ///   - Right(Cliente): Cliente actualizado
  ///   - Left(Failure): Error si falla la actualización
  Future<Either<Failure, Cliente>> updateCliente(Cliente cliente);

  /// Elimina un cliente
  /// 
  /// Parameters:
  ///   - id: ID del cliente a eliminar
  /// 
  /// Returns:
  ///   - Right(void): Éxito en la eliminación
  ///   - Left(Failure): Error si falla la eliminación
  Future<Either<Failure, void>> deleteCliente(int id);

  /// Verifica si existe un cliente con el CI especificado
  /// 
  /// Parameters:
  ///   - ci: Número de CI a verificar
  ///   - excludeId: ID a excluir de la búsqueda (útil para actualizaciones)
  /// 
  /// Returns:
  ///   - Right(bool): true si existe, false si no
  ///   - Left(Failure): Error si falla la verificación
  Future<Either<Failure, bool>> existeClienteConCI(String ci, {int? excludeId});

  /// Obtiene la cantidad total de clientes
  /// 
  /// Returns:
  ///   - Right(int): Cantidad de clientes
  ///   - Left(Failure): Error si falla el conteo
  Future<Either<Failure, int>> getClientesCount();

  /// Obtiene los clientes activos
  /// 
  /// Returns:
  ///   - Right(List<Cliente>): Lista de clientes activos
  ///   - Left(Failure): Error si falla
  Future<Either<Failure, List<Cliente>>> getClientesActivos();

  /// Verifica si un cliente tiene préstamos activos
  /// 
  /// Parameters:
  ///   - clienteId: ID del cliente a verificar
  /// 
  /// Returns:
  ///   - Right(bool): true si tiene préstamos activos, false si no
  ///   - Left(Failure): Error si falla la verificación
  Future<Either<Failure, bool>> clienteTienePrestamosActivos(int clienteId);
}