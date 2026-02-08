import 'package:equatable/equatable.dart';

class Prestamo extends Equatable {
  final int? id;
  final String codigo;
  final int clienteId;
  final int cajaId;
  final double montoOriginal;
  final double montoTotal; // Con intereses
  final double saldoPendiente;
  final double tasaInteres; // Porcentaje
  final TipoInteres tipoInteres;
  final int plazoMeses;
  final double cuotaMensual;
  final DateTime fechaInicio;
  final DateTime fechaVencimiento;
  final EstadoPrestamo estado;
  final String? observaciones;
  final DateTime fechaRegistro;
  final DateTime? fechaActualizacion;

  // Campos calculados (no persistidos)
  final String? nombreCliente;
  final String? nombreCaja;

  const Prestamo({
    this.id,
    required this.codigo,
    required this.clienteId,
    required this.cajaId,
    required this.montoOriginal,
    required this.montoTotal,
    required this.saldoPendiente,
    required this.tasaInteres,
    required this.tipoInteres,
    required this.plazoMeses,
    required this.cuotaMensual,
    required this.fechaInicio,
    required this.fechaVencimiento,
    required this.estado,
    this.observaciones,
    required this.fechaRegistro,
    this.fechaActualizacion,
    this.nombreCliente,
    this.nombreCaja,
  });

  // Calcular porcentaje pagado
  double get porcentajePagado {
    if (montoTotal == 0) return 0;
    return ((montoTotal - saldoPendiente) / montoTotal) * 100;
  }

  // Calcular monto pagado
  double get montoPagado => montoTotal - saldoPendiente;

  // Verificar si está en mora
  bool get enMora => estado == EstadoPrestamo.mora;

  // Verificar si está activo
  bool get activo => estado == EstadoPrestamo.activo;

  // Verificar si está pagado
  bool get pagado => estado == EstadoPrestamo.pagado;

  // Copiar con cambios
  Prestamo copyWith({
    int? id,
    String? codigo,
    int? clienteId,
    int? cajaId,
    double? montoOriginal,
    double? montoTotal,
    double? saldoPendiente,
    double? tasaInteres,
    TipoInteres? tipoInteres,
    int? plazoMeses,
    double? cuotaMensual,
    DateTime? fechaInicio,
    DateTime? fechaVencimiento,
    EstadoPrestamo? estado,
    String? observaciones,
    DateTime? fechaRegistro,
    DateTime? fechaActualizacion,
    String? nombreCliente,
    String? nombreCaja,
  }) {
    return Prestamo(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      clienteId: clienteId ?? this.clienteId,
      cajaId: cajaId ?? this.cajaId,
      montoOriginal: montoOriginal ?? this.montoOriginal,
      montoTotal: montoTotal ?? this.montoTotal,
      saldoPendiente: saldoPendiente ?? this.saldoPendiente,
      tasaInteres: tasaInteres ?? this.tasaInteres,
      tipoInteres: tipoInteres ?? this.tipoInteres,
      plazoMeses: plazoMeses ?? this.plazoMeses,
      cuotaMensual: cuotaMensual ?? this.cuotaMensual,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      nombreCaja: nombreCaja ?? this.nombreCaja,
    );
  }

  @override
  List<Object?> get props => [
        id,
        codigo,
        clienteId,
        cajaId,
        montoOriginal,
        montoTotal,
        saldoPendiente,
        tasaInteres,
        tipoInteres,
        plazoMeses,
        cuotaMensual,
        fechaInicio,
        fechaVencimiento,
        estado,
        observaciones,
        fechaRegistro,
        fechaActualizacion,
      ];
}

// Enumeración de tipos de interés
enum TipoInteres {
  simple,
  compuesto;

  String get displayName {
    switch (this) {
      case TipoInteres.simple:
        return 'Interés Simple';
      case TipoInteres.compuesto:
        return 'Interés Compuesto';
    }
  }

  static TipoInteres fromString(String value) {
    switch (value.toUpperCase()) {
      case 'SIMPLE':
        return TipoInteres.simple;
      case 'COMPUESTO':
        return TipoInteres.compuesto;
      default:
        return TipoInteres.simple;
    }
  }

  String toStorageString() {
    switch (this) {
      case TipoInteres.simple:
        return 'SIMPLE';
      case TipoInteres.compuesto:
        return 'COMPUESTO';
    }
  }
}

// Enumeración de estados de préstamo
enum EstadoPrestamo {
  activo,
  pagado,
  mora,
  cancelado;

  String get displayName {
    switch (this) {
      case EstadoPrestamo.activo:
        return 'Activo';
      case EstadoPrestamo.pagado:
        return 'Pagado';
      case EstadoPrestamo.mora:
        return 'En Mora';
      case EstadoPrestamo.cancelado:
        return 'Cancelado';
    }
  }

  static EstadoPrestamo fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ACTIVO':
        return EstadoPrestamo.activo;
      case 'PAGADO':
        return EstadoPrestamo.pagado;
      case 'MORA':
        return EstadoPrestamo.mora;
      case 'CANCELADO':
        return EstadoPrestamo.cancelado;
      default:
        return EstadoPrestamo.activo;
    }
  }

  String toStorageString() {
    switch (this) {
      case EstadoPrestamo.activo:
        return 'ACTIVO';
      case EstadoPrestamo.pagado:
        return 'PAGADO';
      case EstadoPrestamo.mora:
        return 'MORA';
      case EstadoPrestamo.cancelado:
        return 'CANCELADO';
    }
  }
}