import 'package:equatable/equatable.dart';

/// Entidad Pago - Capa de Dominio
/// 
/// Representa un pago realizado a un préstamo.
/// Los pagos se aplican en cascada: Mora → Interés → Capital
class Pago extends Equatable {
  final int? id;
  final int prestamoId;
  final String codigo; // Formato: PAG-YYYYMM-NNNN
  final double montoTotal;
  final double montoMora;
  final double montoInteres;
  final double montoCapital;
  final DateTime fechaPago;
  final int? cajaId; // Caja donde se recibe el pago
  final String? metodoPago; // Efectivo, Transferencia, Cheque
  final String? referencia; // Número de transferencia, cheque, etc.
  final String? observaciones;
  final DateTime fechaRegistro;

  const Pago({
    this.id,
    required this.prestamoId,
    required this.codigo,
    required this.montoTotal,
    required this.montoMora,
    required this.montoInteres,
    required this.montoCapital,
    required this.fechaPago,
    this.cajaId,
    this.metodoPago,
    this.referencia,
    this.observaciones,
    required this.fechaRegistro,
  });

  /// Verifica si el pago cubre solo mora
  bool get esSoloMora => montoMora > 0 && montoInteres == 0 && montoCapital == 0;

  /// Verifica si el pago cubre mora e interés
  bool get cubriMoraEInteres => montoMora > 0 && montoInteres > 0 && montoCapital == 0;

  /// Verifica si el pago incluye abono a capital
  bool get incluyeCapital => montoCapital > 0;

  /// Obtiene un resumen del pago
  String get resumen {
    final parts = <String>[];
    if (montoMora > 0) parts.add('Mora');
    if (montoInteres > 0) parts.add('Interés');
    if (montoCapital > 0) parts.add('Capital');
    return parts.isEmpty ? 'Sin desglose' : parts.join(' + ');
  }

  @override
  List<Object?> get props => [
        id,
        prestamoId,
        codigo,
        montoTotal,
        montoMora,
        montoInteres,
        montoCapital,
        fechaPago,
        cajaId,
        metodoPago,
        referencia,
        observaciones,
        fechaRegistro,
      ];

  /// Crea una copia del pago con campos modificados
  Pago copyWith({
    int? id,
    int? prestamoId,
    String? codigo,
    double? montoTotal,
    double? montoMora,
    double? montoInteres,
    double? montoCapital,
    DateTime? fechaPago,
    int? cajaId,
    String? metodoPago,
    String? referencia,
    String? observaciones,
    DateTime? fechaRegistro,
  }) {
    return Pago(
      id: id ?? this.id,
      prestamoId: prestamoId ?? this.prestamoId,
      codigo: codigo ?? this.codigo,
      montoTotal: montoTotal ?? this.montoTotal,
      montoMora: montoMora ?? this.montoMora,
      montoInteres: montoInteres ?? this.montoInteres,
      montoCapital: montoCapital ?? this.montoCapital,
      fechaPago: fechaPago ?? this.fechaPago,
      cajaId: cajaId ?? this.cajaId,
      metodoPago: metodoPago ?? this.metodoPago,
      referencia: referencia ?? this.referencia,
      observaciones: observaciones ?? this.observaciones,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  String toString() {
    return 'Pago(id: $id, codigo: $codigo, monto: $montoTotal, fecha: $fechaPago)';
  }
}