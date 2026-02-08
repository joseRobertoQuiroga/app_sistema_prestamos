import 'package:equatable/equatable.dart';

class Cuota extends Equatable {
  final int? id;
  final int prestamoId;
  final int numeroCuota;
  final DateTime fechaVencimiento;
  final double montoCuota;
  final double capital;
  final double interes;
  final double saldoPendiente;
  final double montoPagado;
  final double montoMora;
  final EstadoCuota estado;
  final DateTime? fechaPago;
  final DateTime fechaRegistro;

  const Cuota({
    this.id,
    required this.prestamoId,
    required this.numeroCuota,
    required this.fechaVencimiento,
    required this.montoCuota,
    required this.capital,
    required this.interes,
    required this.saldoPendiente,
    this.montoPagado = 0.0,
    this.montoMora = 0.0,
    required this.estado,
    this.fechaPago,
    required this.fechaRegistro,
  });

  // Calcular saldo de la cuota
  double get saldoCuota => montoCuota - montoPagado;

  // Verificar si está completamente pagada
  bool get estaPagada => montoPagado >= montoCuota;

  // Verificar si está vencida
  bool get estaVencida {
    if (estaPagada) return false;
    return DateTime.now().isAfter(fechaVencimiento);
  }

  // Calcular días de mora
  int get diasMora {
    if (!estaVencida) return 0;
    return DateTime.now().difference(fechaVencimiento).inDays;
  }

  // Calcular mora diaria (0.5% por día sobre saldo pendiente)
  double calcularMora({double tasaMoraDiaria = 0.5}) {
    if (diasMora <= 0) return 0.0;
    final saldo = saldoCuota;
    return (saldo * tasaMoraDiaria / 100) * diasMora;
  }

  // Copiar con cambios
  Cuota copyWith({
    int? id,
    int? prestamoId,
    int? numeroCuota,
    DateTime? fechaVencimiento,
    double? montoCuota,
    double? capital,
    double? interes,
    double? saldoPendiente,
    double? montoPagado,
    double? montoMora,
    EstadoCuota? estado,
    DateTime? fechaPago,
    DateTime? fechaRegistro,
  }) {
    return Cuota(
      id: id ?? this.id,
      prestamoId: prestamoId ?? this.prestamoId,
      numeroCuota: numeroCuota ?? this.numeroCuota,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      montoCuota: montoCuota ?? this.montoCuota,
      capital: capital ?? this.capital,
      interes: interes ?? this.interes,
      saldoPendiente: saldoPendiente ?? this.saldoPendiente,
      montoPagado: montoPagado ?? this.montoPagado,
      montoMora: montoMora ?? this.montoMora,
      estado: estado ?? this.estado,
      fechaPago: fechaPago ?? this.fechaPago,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  List<Object?> get props => [
        id,
        prestamoId,
        numeroCuota,
        fechaVencimiento,
        montoCuota,
        capital,
        interes,
        saldoPendiente,
        montoPagado,
        montoMora,
        estado,
        fechaPago,
        fechaRegistro,
      ];
}

// Enumeración de estados de cuota
enum EstadoCuota {
  pendiente,
  pagada,
  mora,
  vencida;

  String get displayName {
    switch (this) {
      case EstadoCuota.pendiente:
        return 'Pendiente';
      case EstadoCuota.pagada:
        return 'Pagada';
      case EstadoCuota.mora:
        return 'En Mora';
      case EstadoCuota.vencida:
        return 'Vencida';
    }
  }

  static EstadoCuota fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDIENTE':
        return EstadoCuota.pendiente;
      case 'PAGADA':
        return EstadoCuota.pagada;
      case 'MORA':
        return EstadoCuota.mora;
      case 'VENCIDA':
        return EstadoCuota.vencida;
      default:
        return EstadoCuota.pendiente;
    }
  }

  String toStorageString() {
    switch (this) {
      case EstadoCuota.pendiente:
        return 'PENDIENTE';
      case EstadoCuota.pagada:
        return 'PAGADA';
      case EstadoCuota.mora:
        return 'MORA';
      case EstadoCuota.vencida:
        return 'VENCIDA';
    }
  }
}