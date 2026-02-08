import 'package:equatable/equatable.dart';
import 'caja.dart';

/// Resumen de Caja - Capa de Dominio
/// 
/// Contiene información consolidada de una caja
/// incluyendo totales de ingresos, egresos y movimientos.
class ResumenCaja extends Equatable {
  final Caja caja;
  final double totalIngresos;
  final double totalEgresos;
  final double totalTransferenciasEntrada;
  final double totalTransferenciasSalida;
  final int cantidadMovimientos;
  final DateTime? ultimoMovimiento;

  const ResumenCaja({
    required this.caja,
    required this.totalIngresos,
    required this.totalEgresos,
    required this.totalTransferenciasEntrada,
    required this.totalTransferenciasSalida,
    required this.cantidadMovimientos,
    this.ultimoMovimiento,
  });

  /// Saldo total calculado
  double get saldoCalculado => 
      caja.saldo + totalIngresos - totalEgresos + 
      totalTransferenciasEntrada - totalTransferenciasSalida;

  /// Diferencia entre saldo real y calculado
  double get diferenciasSaldo => caja.saldo - saldoCalculado;

  /// Verifica si hay discrepancia en el saldo
  bool get hayDiscrepancia => diferenciasSaldo.abs() > 0.01;

  /// Total de entradas (ingresos + transferencias entrada)
  double get totalEntradas => totalIngresos + totalTransferenciasEntrada;

  /// Total de salidas (egresos + transferencias salida)
  double get totalSalidas => totalEgresos + totalTransferenciasSalida;

  /// Balance neto
  double get balanceNeto => totalEntradas - totalSalidas;

  @override
  List<Object?> get props => [
        caja,
        totalIngresos,
        totalEgresos,
        totalTransferenciasEntrada,
        totalTransferenciasSalida,
        cantidadMovimientos,
        ultimoMovimiento,
      ];

  @override
  String toString() {
    return 'ResumenCaja(${caja.nombre}, saldo: ${caja.saldo}, movimientos: $cantidadMovimientos)';
  }
}