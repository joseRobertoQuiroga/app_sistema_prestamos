import 'package:equatable/equatable.dart';

/// Entidad Cliente - Capa de Dominio
/// 
/// Representa un cliente en el sistema de préstamos.
/// Esta clase es independiente de cualquier framework o tecnología.
class Cliente extends Equatable {
  final int? id;
  final String nombre;
  final String ci;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? ciudad;
  final String? departamento;
  final String? referencia;
  final DateTime fechaRegistro;
  final bool activo;
  final String? notas;

  const Cliente({
    this.id,
    required this.nombre,
    required this.ci,
    this.telefono,
    this.email,
    this.direccion,
    this.ciudad,
    this.departamento,
    this.referencia,
    required this.fechaRegistro,
    this.activo = true,
    this.notas,
  });

  /// Crea una copia del cliente con los campos modificados
  Cliente copyWith({
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
    return Cliente(
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

  /// Obtiene el nombre completo formateado
  String get nombreCompleto => nombre.trim();

  /// Verifica si el cliente tiene información de contacto
  bool get tieneContacto => 
      (telefono != null && telefono!.isNotEmpty) || 
      (email != null && email!.isNotEmpty);

  /// Verifica si el cliente tiene dirección completa
  bool get tieneDireccionCompleta => 
      direccion != null && 
      direccion!.isNotEmpty && 
      ciudad != null && 
      ciudad!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        nombre,
        ci,
        telefono,
        email,
        direccion,
        ciudad,
        departamento,
        referencia,
        fechaRegistro,
        activo,
        notas,
      ];

  @override
  String toString() {
    return 'Cliente(id: $id, nombre: $nombre, ci: $ci, activo: $activo)';
  }
}