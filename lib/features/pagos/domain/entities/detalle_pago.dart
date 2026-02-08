import 'package:equatable/equatable.dart';

/// Entidad DetallePago - Capa de Dominio
/// 
/// Representa el detalle de cómo un pago se aplicó a una cuota específica.
/// Un pago puede aplicarse a múltiples cuotas (cascada).
class DetallePago extends Equatable {
  final int? id;
  final int pagoId;
  final int cuotaId;
  final int numeroCuota;
  final double montoMora;
  final double montoInteres;
  final double montoCapital;
  final double montoTotal;
  final DateTime fechaRegistro;

  const DetallePago({
    this.id,
    required this.pagoId,
    required this.cuotaId,
    required this.numeroCuota,
    required this.montoMora,
    required this.montoInteres,
    required this.montoCapital,
    required this.montoTotal,
    required this.fechaRegistro,
  });

  /// Verifica si la cuota quedó totalmente pagada con este pago
  bool get pagoCuotaCompleta => montoMora >= 0 && montoInteres > 0;

  /// Obtiene el resumen de la aplicación
  String get resumen {
    final parts = <String>[];
    if (montoMora > 0) parts.add('Mora: $montoMora');
    if (montoInteres > 0) parts.add('Interés: $montoInteres');
    if (montoCapital > 0) parts.add('Capital: $montoCapital');
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        pagoId,
        cuotaId,
        numeroCuota,
        montoMora,
        montoInteres,
        montoCapital,
        montoTotal,
        fechaRegistro,
      ];

  /// Crea una copia del detalle con campos modificados
  DetallePago copyWith({
    int? id,
    int? pagoId,
    int? cuotaId,
    int? numeroCuota,
    double? montoMora,
    double? montoInteres,
    double? montoCapital,
    double? montoTotal,
    DateTime? fechaRegistro,
  }) {
    return DetallePago(
      id: id ?? this.id,
      pagoId: pagoId ?? this.pagoId,
      cuotaId: cuotaId ?? this.cuotaId,
      numeroCuota: numeroCuota ?? this.numeroCuota,
      montoMora: montoMora ?? this.montoMora,
      montoInteres: montoInteres ?? this.montoInteres,
      montoCapital: montoCapital ?? this.montoCapital,
      montoTotal: montoTotal ?? this.montoTotal,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  String toString() {
    return 'DetallePago(cuota: $numeroCuota, monto: $montoTotal)';
  }
}