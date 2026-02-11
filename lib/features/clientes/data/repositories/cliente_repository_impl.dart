import 'package:dartz/dartz.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../datasources/cliente_local_data_source.dart';
import '../models/cliente_model.dart';
import '../../../../core/errors/failures.dart';

/// Implementación del repositorio de clientes - Capa de Datos
/// 
/// Implementa la interfaz ClienteRepository definida en la capa de dominio.
/// Maneja la lógica de acceso a datos y convierte excepciones en Failures.
class ClienteRepositoryImpl implements ClienteRepository {
  final ClienteLocalDataSource localDataSource;

  ClienteRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Cliente>>> getClientes() async {
    try {
      final clientes = await localDataSource.getClientes();
      return Right(clientes);
    } catch (e) {
      return Left(DatabaseFailure(
        'Error al obtener clientes: ${e.toString()}'
      ));
    }
  }

  @override
  Future<Either<Failure, Cliente>> getClienteById(int id) async {
    try {
      final cliente = await localDataSource.getClienteById(id);
      return Right(cliente);
    } catch (e) {
      return Left(DatabaseFailure(
        'Error al obtener cliente: ${e.toString()}'
      ));
    }
  }

  @override
  Future<Either<Failure, List<Cliente>>> searchClientes(String query) async {
    try {
      final clientes = await localDataSource.searchClientes(query);
      return Right(clientes);
    } catch (e) {
      return Left(DatabaseFailure(
        'Error al buscar clientes: ${e.toString()}'
      ));
    }
  }

  @override
  Future<Either<Failure, Cliente>> createCliente(Cliente cliente) async {
    try {
      final clienteModel = ClienteModel.fromEntity(cliente);
      final createdCliente = await localDataSource.createCliente(clienteModel);
      return Right(createdCliente);
    } catch (e) {
      return Left(DatabaseFailure(
        'Error al crear cliente: ${e.toString()}'
      ));
    }
  }

  @override
  Future<Either<Failure, Cliente>> updateCliente(Cliente cliente) async {
    try {
      final clienteModel = ClienteModel.fromEntity(cliente);
      final updatedCliente = await localDataSource.updateCliente(clienteModel);
      return Right(updatedCliente);
    } catch (e) {
      return Left(DatabaseFailure(
        'Error al actualizar cliente: ${e.toString()}'
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCliente(int id) async {
    try {
      await localDataSource.deleteCliente(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        'Error al eliminar cliente: ${e.toString()}'
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> existeClienteConCI(
    String ci, {
    int? excludeId,
  }) async {
    try {
      final exists = await localDataSource.existeClienteConCI(
        ci,
        excludeId: excludeId,
      );
      return Right(exists);
    } catch (e) {
      return Left(DatabaseFailure(
        'Error al verificar CI: ${e.toString()}'
      ));
    }
  }

  @override
  Future<Either<Failure, int>> getClientesCount() async {
    try {
      final count = await localDataSource.getClientesCount();
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure(
        'Error al contar clientes: ${e.toString()}'
      ));
    }
  }

  @override
  Future<Either<Failure, List<Cliente>>> getClientesActivos() async {
    try {
      final clientes = await localDataSource.getClientesActivos();
      return Right(clientes);
    } catch (e) {
      return Left(DatabaseFailure(
        'Error al obtener clientes activos: ${e.toString()}'
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> clienteTienePrestamosActivos(int clienteId) async {
    try {
      final tienePrestamos = await localDataSource.clienteTienePrestamosActivos(clienteId);
      return Right(tienePrestamos);
    } catch (e) {
      return Left(DatabaseFailure(
        'Error al verificar préstamos activos: ${e.toString()}'
      ));
    }
  }
}