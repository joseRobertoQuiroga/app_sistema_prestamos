import 'package:equatable/equatable.dart';

/// Entidad Caja - Capa de Dominio
/// 
/// Representa una caja o cuenta donde se maneja dinero.
/// Puede ser efectivo, cuenta bancaria, etc.
class Caja extends Equatable {
  final int? id;
  final String nombre;
  final String tipo; // EFECTIVO, BANCO, OTRO
  final double saldo;
  final String? numeroCuenta; // Para bancos
  final String? banco; // Nombre del banco
  final String? titular; // Titular de la cuenta
  final String? descripcion;
  final bool activa;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;

  const Caja({
    this.id,
    required this.nombre,
    required this.tipo,
    required this.saldo,
    this.numeroCuenta,
    this.banco,
    this.titular,
    this.descripcion,
    this.activa = true,
    required this.fechaCreacion,
    this.fechaActualizacion,
  });

  /// Verifica si es una caja de efectivo
  bool get esEfectivo => tipo == 'EFECTIVO';

  /// Verifica si es una cuenta bancaria
  bool get esBanco => tipo == 'BANCO';

  /// Verifica si tiene saldo disponible
  bool get tieneSaldo => saldo > 0;

  /// Verifica si puede realizar una operación de monto específico
  bool puedeSacar(double monto) => saldo >= monto && activa;

  /// Obtiene el nombre completo (incluye banco si aplica)
  String get nombreCompleto {
    if (esBanco && banco != null) {
      return '$nombre - $banco';
    }
    return nombre;
  }

  /// Obtiene información de la cuenta si es banco
  String? get infoCuenta {
    if (esBanco && numeroCuenta != null) {
      return 'Cuenta: $numeroCuenta${titular != null ? ' - $titular' : ''}';
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        tipo,
        saldo,
        numeroCuenta,
        banco,
        titular,
        descripcion,
        activa,
        fechaCreacion,
        fechaActualizacion,
      ];

  /// Crea una copia de la caja con campos modificados
  Caja copyWith({
    int? id,
    String? nombre,
    String? tipo,
    double? saldo,
    String? numeroCuenta,
    String? banco,
    String? titular,
    String? descripcion,
    bool? activa,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Caja(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      saldo: saldo ?? this.saldo,
      numeroCuenta: numeroCuenta ?? this.numeroCuenta,
      banco: banco ?? this.banco,
      titular: titular ?? this.titular,
      descripcion: descripcion ?? this.descripcion,
      activa: activa ?? this.activa,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  String toString() {
    return 'Caja(id: $id, nombre: $nombre, saldo: $saldo, activa: $activa)';
  }
}