import '../../domain/entities/cliente.dart';
import '../../../../core/database/database.dart';

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
  factory ClienteModel.fromDrift(ClienteData data) {
    return ClienteModel(
      id: data.id,
      nombre: data.nombre,
      ci: data.ci,
      telefono: data.telefono,
      email: data.email,
      direccion: data.direccion,
      ciudad: data.ciudad,
      departamento: data.departamento,
      referencia: data.referencia,
      fechaRegistro: data.fechaRegistro,
      activo: data.activo,
      notas: data.notas,
    );
  }

  /// Convierte el modelo a un objeto Companion para inserción en Drift
  ClientesCompanion toCompanion() {
    return ClientesCompanion.insert(
      nombre: nombre,
      ci: ci,
      telefono: Value(telefono),
      email: Value(email),
      direccion: Value(direccion),
      ciudad: Value(ciudad),
      departamento: Value(departamento),
      referencia: Value(referencia),
      fechaRegistro: fechaRegistro,
      activo: activo,
      notas: Value(notas),
    );
  }

  /// Convierte el modelo a un objeto Companion para actualización en Drift
  ClientesCompanion toCompanionForUpdate() {
    return ClientesCompanion(
      id: Value(id!),
      nombre: Value(nombre),
      ci: Value(ci),
      telefono: Value(telefono),
      email: Value(email),
      direccion: Value(direccion),
      ciudad: Value(ciudad),
      departamento: Value(departamento),
      referencia: Value(referencia),
      fechaRegistro: Value(fechaRegistro),
      activo: Value(activo),
      notas: Value(notas),
    );
  }

  /// Crea una copia del modelo como ClienteModel (no Cliente)
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

  /// Convierte a un Map (útil para debugging o JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'ci': ci,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'ciudad': ciudad,
      'departamento': departamento,
      'referencia': referencia,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'activo': activo,
      'notas': notas,
    };
  }

  /// Crea un ClienteModel desde un Map
  factory ClienteModel.fromMap(Map<String, dynamic> map) {
    return ClienteModel(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      ci: map['ci'] as String,
      telefono: map['telefono'] as String?,
      email: map['email'] as String?,
      direccion: map['direccion'] as String?,
      ciudad: map['ciudad'] as String?,
      departamento: map['departamento'] as String?,
      referencia: map['referencia'] as String?,
      fechaRegistro: DateTime.parse(map['fechaRegistro'] as String),
      activo: map['activo'] as bool? ?? true,
      notas: map['notas'] as String?,
    );
  }
}