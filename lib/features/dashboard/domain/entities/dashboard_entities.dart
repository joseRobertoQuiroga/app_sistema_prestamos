import 'package:equatable/equatable.dart';

/// KPIs del Dashboard - Capa de Dominio
/// 
/// Contiene todos los indicadores clave de rendimiento del sistema
class DashboardKPIs extends Equatable {
  // Cartera
  final double carteraTotal;
  final double capitalPorCobrar;
  final double interesesGanados;
  final double moraCobrada;
  
  // Préstamos
  final int totalPrestamos;
  final int prestamosActivos;
  final int prestamosEnMora;
  final int prestamosPagados;
  final int prestamosCancelados;
  
  // Cajas
  final double saldoTotalCajas;
  final double ingresosDelMes;
  final double egresosDelMes;
  
  // Clientes
  final int totalClientes;
  final int clientesActivos;
  
  // Cálculos derivados
  final double tasaMorosidad;
  final double porcentajeCarteraPagada;

  const DashboardKPIs({
    required this.carteraTotal,
    required this.capitalPorCobrar,
    required this.interesesGanados,
    required this.moraCobrada,
    required this.totalPrestamos,
    required this.prestamosActivos,
    required this.prestamosEnMora,
    required this.prestamosPagados,
    required this.prestamosCancelados,
    required this.saldoTotalCajas,
    required this.ingresosDelMes,
    required this.egresosDelMes,
    required this.totalClientes,
    required this.clientesActivos,
    required this.tasaMorosidad,
    required this.porcentajeCarteraPagada,
  });

  /// Total ganado (intereses + mora)
  double get totalGanado => interesesGanados + moraCobrada;

  /// Balance del mes
  double get balanceMensual => ingresosDelMes - egresosDelMes;

  /// Porcentaje de préstamos activos
  double get porcentajePrestamosActivos {
    if (totalPrestamos == 0) return 0;
    return (prestamosActivos / totalPrestamos) * 100;
  }

  /// Porcentaje de préstamos en mora
  double get porcentajePrestamosEnMora {
    if (totalPrestamos == 0) return 0;
    return (prestamosEnMora / totalPrestamos) * 100;
  }

  /// Salud de la cartera (0-100)
  double get saludCartera {
    if (totalPrestamos == 0) return 100;
    final score = 100 - tasaMorosidad;
    return score.clamp(0, 100);
  }

  @override
  List<Object?> get props => [
        carteraTotal,
        capitalPorCobrar,
        interesesGanados,
        moraCobrada,
        totalPrestamos,
        prestamosActivos,
        prestamosEnMora,
        prestamosPagados,
        prestamosCancelados,
        saldoTotalCajas,
        ingresosDelMes,
        egresosDelMes,
        totalClientes,
        clientesActivos,
        tasaMorosidad,
        porcentajeCarteraPagada,
      ];
}

/// Alerta del Dashboard
class DashboardAlerta extends Equatable {
  final String tipo; // VENCIMIENTO, MORA, BAJO_SALDO
  final String severidad; // ALTA, MEDIA, BAJA
  final String titulo;
  final String mensaje;
  final DateTime fecha;
  final int? prestamoId;
  final int? cuotaId;

  const DashboardAlerta({
    required this.tipo,
    required this.severidad,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    this.prestamoId,
    this.cuotaId,
  });

  bool get esAlta => severidad == 'ALTA';
  bool get esMedia => severidad == 'MEDIA';
  bool get esBaja => severidad == 'BAJA';

  @override
  List<Object?> get props => [
        tipo,
        severidad,
        titulo,
        mensaje,
        fecha,
        prestamoId,
        cuotaId,
      ];
}

/// Próximo Vencimiento
class ProximoVencimiento extends Equatable {
  final int cuotaId;
  final int prestamoId;
  final String codigoPrestamo;
  final String nombreCliente;
  final int numeroCuota;
  final DateTime fechaVencimiento;
  final double montoCuota;
  final double montoInteres;
  final double montoPendiente;
  final int diasParaVencer;

  const ProximoVencimiento({
    required this.cuotaId,
    required this.prestamoId,
    required this.codigoPrestamo,
    required this.nombreCliente,
    required this.numeroCuota,
    required this.fechaVencimiento,
    required this.montoCuota,
    required this.montoInteres,
    required this.montoPendiente,
    required this.diasParaVencer,
  });

  bool get esUrgente => diasParaVencer <= 3;
  bool get esCercano => diasParaVencer <= 7;

  @override
  List<Object?> get props => [
        cuotaId,
        prestamoId,
        codigoPrestamo,
        nombreCliente,
        numeroCuota,
        fechaVencimiento,
        montoCuota,
        montoInteres,
        montoPendiente,
        diasParaVencer,
      ];
}