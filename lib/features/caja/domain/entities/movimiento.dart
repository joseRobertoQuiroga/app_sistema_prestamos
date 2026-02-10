import 'package:equatable/equatable.dart';

/// Entidad Movimiento - Capa de Dominio
/// 
/// Representa un movimiento de dinero en una caja.
/// Puede ser ingreso, egreso o transferencia.
class Movimiento extends Equatable {
  final int? id;
  final String? codigo; // Nuevo campo
  final int cajaId;
  final String tipo; // INGRESO, EGRESO, TRANSFERENCIA
  final String categoria; // DESEMBOLSO, PAGO, GASTO, TRANSFERENCIA, OTRO
  final double monto;
  final String descripcion;
  final DateTime fecha;
  final double saldoAnterior;
  final double saldoNuevo;
  final int? cajaDestinoId; // Para transferencias
  final int? prestamoId; // Si está relacionado con un préstamo
  final int? pagoId; // Si está relacionado con un pago
  final String? referencia; // Número de documento, etc.
  final DateTime fechaRegistro;

  const Movimiento({
    this.id,
    this.codigo,
    required this.cajaId,
    required this.tipo,
    required this.categoria,
    required this.monto,
    required this.descripcion,
    required this.fecha,
    required this.saldoAnterior,
    required this.saldoNuevo,
    this.cajaDestinoId,
    this.prestamoId,
    this.pagoId,
    this.referencia,
    required this.fechaRegistro,
  });

  /// Verifica si es un ingreso
  bool get esIngreso => tipo == 'INGRESO';

  /// Verifica si es un egreso
  bool get esEgreso => tipo == 'EGRESO';

  /// Verifica si es una transferencia
  bool get esTransferencia => tipo == 'TRANSFERENCIA';

  /// Verifica si está relacionado con un préstamo
  bool get tienePrestamoRelacionado => prestamoId != null;

  /// Verifica si está relacionado con un pago
  bool get tienePagoRelacionado => pagoId != null;

  /// Obtiene el símbolo según el tipo
  String get simbolo {
    switch (tipo) {
      case 'INGRESO':
        return '+';
      case 'EGRESO':
        return '-';
      case 'TRANSFERENCIA':
        return '↔';
      default:
        return '';
    }
  }

  /// Calcula la diferencia del saldo
  double get diferencia => saldoNuevo - saldoAnterior;

  @override
  List<Object?> get props => [
        id,
        codigo,
        cajaId,
        tipo,
        categoria,
        monto,
        descripcion,
        fecha,
        saldoAnterior,
        saldoNuevo,
        cajaDestinoId,
        prestamoId,
        pagoId,
        referencia,
        fechaRegistro,
      ];

  /// Crea una copia del movimiento con campos modificados
  Movimiento copyWith({
    int? id,
    String? codigo,
    int? cajaId,
    String? tipo,
    String? categoria,
    double? monto,
    String? descripcion,
    DateTime? fecha,
    double? saldoAnterior,
    double? saldoNuevo,
    int? cajaDestinoId,
    int? prestamoId,
    int? pagoId,
    String? referencia,
    DateTime? fechaRegistro,
  }) {
    return Movimiento(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      cajaId: cajaId ?? this.cajaId,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
      monto: monto ?? this.monto,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      saldoAnterior: saldoAnterior ?? this.saldoAnterior,
      saldoNuevo: saldoNuevo ?? this.saldoNuevo,
      cajaDestinoId: cajaDestinoId ?? this.cajaDestinoId,
      prestamoId: prestamoId ?? this.prestamoId,
      pagoId: pagoId ?? this.pagoId,
      referencia: referencia ?? this.referencia,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  String toString() {
    return 'Movimiento(id: $id, tipo: $tipo, monto: $monto, fecha: $fecha)';
  }
}