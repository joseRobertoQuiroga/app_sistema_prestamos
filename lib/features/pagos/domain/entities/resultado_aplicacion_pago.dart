import 'package:equatable/equatable.dart';
import 'detalle_pago.dart';

/// Resultado de Aplicación de Pago - Capa de Dominio
/// 
/// Contiene el resultado de aplicar un pago a un préstamo,
/// incluyendo cómo se distribuyó en las cuotas.
class ResultadoAplicacionPago extends Equatable {
  final double montoOriginal;
  final double montoAplicado;
  final double montoRestante;
  final double totalMora;
  final double totalInteres;
  final double totalCapital;
  final List<DetallePago> detalles;
  final List<int> cuotasPagadas; // IDs de cuotas que quedaron totalmente pagadas
  final String mensaje;

  const ResultadoAplicacionPago({
    required this.montoOriginal,
    required this.montoAplicado,
    required this.montoRestante,
    required this.totalMora,
    required this.totalInteres,
    required this.totalCapital,
    required this.detalles,
    required this.cuotasPagadas,
    required this.mensaje,
  });

  /// Verifica si el pago se aplicó completamente
  bool get aplicacionCompleta => montoRestante == 0;

  /// Verifica si hubo un sobrante
  bool get huboSobrante => montoRestante > 0;

  /// Cantidad de cuotas afectadas por el pago
  int get cuotasAfectadas => detalles.length;

  /// Resumen de la aplicación
  String get resumen {
    return '''
Monto pagado: $montoOriginal
Aplicado: $montoAplicado
${huboSobrante ? 'Sobrante: $montoRestante' : ''}
Distribución:
  - Mora: $totalMora
  - Interés: $totalInteres
  - Capital: $totalCapital
Cuotas afectadas: $cuotasAfectadas
Cuotas pagadas completas: ${cuotasPagadas.length}
''';
  }

  @override
  List<Object?> get props => [
        montoOriginal,
        montoAplicado,
        montoRestante,
        totalMora,
        totalInteres,
        totalCapital,
        detalles,
        cuotasPagadas,
        mensaje,
      ];

  @override
  String toString() {
    return 'ResultadoAplicacionPago(aplicado: $montoAplicado, cuotas: $cuotasAfectadas)';
  }
}