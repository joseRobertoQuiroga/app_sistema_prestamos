import 'package:drift/drift.dart';
import '../../domain/entities/cliente.dart';
import '../../../../core/database/database.dart' as db;

/// Modelo de datos de Cliente - Capa de Datos
/// 
/// Extiende la entidad Cliente y agrega métodos de conversión
/// para interactuar con la base de datos Drift.
class ClienteModel extends Cliente {
  const ClienteModel({
    super.id,
    required super.nombre,
    required super.ci,
    super.telefono,
    super.email,
    super.direccion,
    super.ciudad,
    super.departamento,
    super.referencia,
    required super.fechaRegistro,
    super.activo,
    super.notas,
  });

  /// Crea un ClienteModel desde una entidad Cliente
  factory ClienteModel.fromEntity(Cliente cliente) {
    return ClienteModel(
      id: cliente.id,
      nombre: cliente.nombre,
      ci: cliente.ci,
      telefono: cliente.telefono,
      email: cliente.email,
      direccion: cliente.direccion,
      ciudad: cliente.ciudad,
      departamento: cliente.departamento,
      referencia: cliente.referencia,
      fechaRegistro: cliente.fechaRegistro,
      activo: cliente.activo,
      notas: cliente.notas,
    );
  }

  /// Crea un ClienteModel desde una fila de la base de datos Drift
  factory ClienteModel.fromDrift(db.Cliente data) {
    return ClienteModel(
      id: data.id,
      // DRIFT: nombres + apellidos → DOMAIN: nombre
      nombre: '${data.nombres} ${data.apellidos}'.trim(),
      // DRIFT: numeroDocumento → DOMAIN: ci
      ci: data.numeroDocumento,
      telefono: data.telefono,
      email: data.email,
      direccion: data.direccion,
      // Campos que NO existen en Drift
      ciudad: null,
      departamento: null,
      referencia: data.referencia,
      fechaRegistro: data.fechaRegistro,
      activo: data.activo,
      // DRIFT: observaciones → DOMAIN: notas
      notas: data.observaciones,
    );
  }

  /// Convierte el modelo a un objeto Companion para inserción en Drift
  db.ClientesCompanion toCompanion() {
    final partes = _separarNombre(nombre);
    
    return db.ClientesCompanion.insert(
      nombres: partes['nombres']!,
      apellidos: partes['apellidos']!,
      tipoDocumento: 'CI', // Valor por defecto
      numeroDocumento: ci,
      telefono: telefono ?? '', // Drift requiere no-null en definition
      email: Value(email),
      direccion: direccion ?? '', // Drift requiere no-null
      referencia: Value(referencia),
      observaciones: Value(notas),
      fechaRegistro: Value(fechaRegistro),
      activo: Value(activo ?? true),
    );
  }

  /// Convierte el modelo a un objeto Companion para actualización en Drift
  db.ClientesCompanion toCompanionForUpdate() {
    final partes = _separarNombre(nombre);
    
    return db.ClientesCompanion(
      id: Value(id!),
      nombres: Value(partes['nombres']!),
      apellidos: Value(partes['apellidos']!),
      // tipoDocumento: const Value('CI'), // No actualizar tipo por defecto
      numeroDocumento: Value(ci),
      telefono: Value(telefono ?? ''),
      email: Value(email),
      direccion: Value(direccion ?? ''),
      referencia: Value(referencia),
      observaciones: Value(notas),
      // fechaRegistro: Value(fechaRegistro), // No actualizar fecha registro
      activo: Value(activo ?? true),
      fechaActualizacion: Value(DateTime.now()),
    );
  }

  /// Helper para separar nombre y apellido
  Map<String, String> _separarNombre(String nombreCompleto) {
    final partes = nombreCompleto.trim().split(' ');
    if (partes.length < 2) {
      return {'nombres': partes.isNotEmpty ? partes[0] : '', 'apellidos': ''};
    }
    // Asumimos última palabra es apellido, resto nombres
    final apellido = partes.last;
    final nombres = partes.sublist(0, partes.length - 1).join(' ');
    return {'nombres': nombres, 'apellidos': apellido};
  }

  @override
  ClienteModel copyWith({
    int? id,
    String? nombre,
    String? ci,
    String? telefono,
    String? email,
    String? direccion,
    String? ciudad,
    String? departamento,
    String? referencia,
    DateTime? fechaRegistro,
    bool? activo,
    String? notas,
  }) {
    return ClienteModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      ci: ci ?? this.ci,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      ciudad: ciudad ?? this.ciudad,
      departamento: departamento ?? this.departamento,
      referencia: referencia ?? this.referencia,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      activo: activo ?? this.activo,
      notas: notas ?? this.notas,
    );
  }
}