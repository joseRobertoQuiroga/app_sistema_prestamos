import 'package:equatable/equatable.dart';

/// Entidad que representa el resumen de cuotas de un préstamo
/// 
/// Contiene estadísticas consolidadas sobre el estado de las cuotas
class ResumenCuotas extends Equatable {
  final int prestamoId;
  final int totalCuotas;
  final int cuotasPagadas;
  final int cuotasPendientes;
  final int cuotasVencidas;
  final int cuotasEnMora;
  final double montoPagado;
  final double montoPendiente;
  final double montoMora;
  final double montoTotal;

  const ResumenCuotas({
    required this.prestamoId,
    required this.totalCuotas,
    required this.cuotasPagadas,
    required this.cuotasPendientes,
    required this.cuotasVencidas,
    required this.cuotasEnMora,
    required this.montoPagado,
    required this.montoPendiente,
    required this.montoMora,
    required this.montoTotal,
  });

  /// Progreso de pago en porcentaje (0-100)
  double get progreso {
    if (totalCuotas == 0) return 0;
    return (cuotasPagadas / totalCuotas) * 100;
  }

  /// Porcentaje del monto pagado respecto al total
  double get porcentajeMontoPagado {
    if (montoTotal == 0) return 0;
    return (montoPagado / montoTotal) * 100;
  }

  /// Indica si el préstamo está al día
  bool get estaAlDia => cuotasVencidas == 0 && cuotasEnMora == 0;

  /// Indica si el préstamo está completamente pagado
  bool get estaPagado => cuotasPagadas == totalCuotas;

  /// Indica si hay cuotas en mora
  bool get tieneMora => cuotasEnMora > 0;

  @override
  List<Object?> get props => [
        prestamoId,
        totalCuotas,
        cuotasPagadas,
        cuotasPendientes,
        cuotasVencidas,
        cuotasEnMora,
        montoPagado,
        montoPendiente,
        montoMora,
        montoTotal,
      ];

  @override
  String toString() {
    return 'ResumenCuotas(total: $totalCuotas, pagadas: $cuotasPagadas, '
        'pendientes: $cuotasPendientes, progreso: ${progreso.toStringAsFixed(1)}%)';
  }
}