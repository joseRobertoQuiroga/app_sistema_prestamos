import 'package:drift/drift.dart';
import '../models/cliente_model.dart';
import '../../../../core/database/database.dart';

/// Data Source local para Clientes - Capa de Datos
/// 
/// Maneja todas las operaciones de base de datos para clientes usando Drift.
/// ✅ CORREGIDO: Búsquedas actualizadas para usar nombres+apellidos y numeroDocumento
class ClienteLocalDataSource {
  final AppDatabase database;

  ClienteLocalDataSource(this.database);

  /// Obtiene todos los clientes de la base de datos
  Future<List<ClienteModel>> getClientes() async {
    final clientes = await database.select(database.clientes).get();
    return clientes.map((data) => ClienteModel.fromDrift(data)).toList();
  }

  /// Obtiene un cliente por su ID
  /// 
  /// Throws [Exception] si no se encuentra el cliente
  Future<ClienteModel> getClienteById(int id) async {
    final cliente = await (database.select(database.clientes)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    if (cliente == null) {
      throw Exception('Cliente con ID $id no encontrado');
    }

    return ClienteModel.fromDrift(cliente);
  }

  /// Busca clientes por nombre o CI
  /// ✅ CORREGIDO: Busca en nombres, apellidos y numeroDocumento
  /// 
  /// La búsqueda es case-insensitive y busca coincidencias parciales
  Future<List<ClienteModel>> searchClientes(String query) async {
    final searchQuery = '%${query.toLowerCase()}%';
    
    final clientes = await (database.select(database.clientes)
          ..where((tbl) =>
              tbl.nombres.lower().like(searchQuery) |
              tbl.apellidos.lower().like(searchQuery) |
              tbl.numeroDocumento.like(searchQuery))) // ✅ Buscar en numeroDocumento
        .get();

    return clientes.map((data) => ClienteModel.fromDrift(data)).toList();
  }

  /// Crea un nuevo cliente en la base de datos
  /// 
  /// Returns el cliente creado con su ID asignado
  Future<ClienteModel> createCliente(ClienteModel cliente) async {
    final id = await database.into(database.clientes).insert(
          cliente.toCompanion(),
        );

    return cliente.copyWith(id: id);
  }

  /// Actualiza un cliente existente
  /// 
  /// Throws [Exception] si el cliente no existe
  Future<ClienteModel> updateCliente(ClienteModel cliente) async {
    if (cliente.id == null) {
      throw Exception('El cliente debe tener un ID para ser actualizado');
    }

    final updated = await (database.update(database.clientes)
          ..where((tbl) => tbl.id.equals(cliente.id!)))
        .write(cliente.toCompanionForUpdate());

    if (updated == 0) {
      throw Exception('Cliente con ID ${cliente.id} no encontrado');
    }

    return cliente;
  }

  /// Elimina un cliente de la base de datos
  /// 
  /// Throws [Exception] si el cliente no existe
  Future<void> deleteCliente(int id) async {
    final deleted = await (database.delete(database.clientes)
          ..where((tbl) => tbl.id.equals(id)))
        .go();

    if (deleted == 0) {
      throw Exception('Cliente con ID $id no encontrado');
    }
  }

  /// Verifica si existe un cliente con el CI especificado
  /// ✅ CORREGIDO: Busca en numeroDocumento en lugar de ci
  /// 
  /// Parameters:
  ///   - ci: CI a buscar
  ///   - excludeId: ID a excluir de la búsqueda (opcional)
  Future<bool> existeClienteConCI(String ci, {int? excludeId}) async {
    var query = database.select(database.clientes)
      ..where((tbl) => tbl.numeroDocumento.equals(ci)); // ✅ numeroDocumento

    if (excludeId != null) {
      query = query..where((tbl) => tbl.id.equals(excludeId).not());
    }

    final cliente = await query.getSingleOrNull();
    return cliente != null;
  }

  /// Obtiene la cantidad total de clientes
  Future<int> getClientesCount() async {
    final countQuery = database.selectOnly(database.clientes)
      ..addColumns([database.clientes.id.count()]);

    final result = await countQuery.getSingle();
    return result.read(database.clientes.id.count()) ?? 0;
  }

  /// Obtiene solo los clientes activos
  Future<List<ClienteModel>> getClientesActivos() async {
    final clientes = await (database.select(database.clientes)
          ..where((tbl) => tbl.activo.equals(true)))
        .get();

    return clientes.map((data) => ClienteModel.fromDrift(data)).toList();
  }

  /// Obtiene clientes ordenados por nombre
  /// ✅ CORREGIDO: Ordena por nombres y apellidos
  Future<List<ClienteModel>> getClientesOrdenados() async {
    final clientes = await (database.select(database.clientes)
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.nombres),
            (tbl) => OrderingTerm.asc(tbl.apellidos),
          ]))
        .get();

    return clientes.map((data) => ClienteModel.fromDrift(data)).toList();
  }

  /// Obtiene los últimos N clientes registrados
  Future<List<ClienteModel>> getUltimosClientes({int limit = 10}) async {
    final clientes = await (database.select(database.clientes)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.fechaRegistro)])
          ..limit(limit))
        .get();

    return clientes.map((data) => ClienteModel.fromDrift(data)).toList();
  }

  /// Desactiva un cliente (soft delete)
  Future<void> desactivarCliente(int id) async {
    await (database.update(database.clientes)
          ..where((tbl) => tbl.id.equals(id)))
        .write(const ClientesCompanion(activo: Value(false)));
  }

  /// Activa un cliente previamente desactivado
  Future<void> activarCliente(int id) async {
    await (database.update(database.clientes)
          ..where((tbl) => tbl.id.equals(id)))
        .write(const ClientesCompanion(activo: Value(true)));
  }
}