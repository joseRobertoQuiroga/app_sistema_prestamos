import '../../domain/entities/pago.dart';
import '../../domain/entities/detalle_pago.dart';
import '../../../../core/database/database.dart';

/// Modelo de Pago - Capa de Datos
class PagoModel extends Pago {
  const PagoModel({
    super.id,
    required super.prestamoId,
    required super.codigo,
    required super.montoTotal,
    required super.montoMora,
    required super.montoInteres,
    required super.montoCapital,
    required super.fechaPago,
    super.cajaId,
    super.metodoPago,
    super.referencia,
    super.observaciones,
    required super.fechaRegistro,
  });

  factory PagoModel.fromEntity(Pago pago) {
    return PagoModel(
      id: pago.id,
      prestamoId: pago.prestamoId,
      codigo: pago.codigo,
      montoTotal: pago.montoTotal,
      montoMora: pago.montoMora,
      montoInteres: pago.montoInteres,
      montoCapital: pago.montoCapital,
      fechaPago: pago.fechaPago,
      cajaId: pago.cajaId,
      metodoPago: pago.metodoPago,
      referencia: pago.referencia,
      observaciones: pago.observaciones,
      fechaRegistro: pago.fechaRegistro,
    );
  }

  factory PagoModel.fromDrift(PagoData data) {
    return PagoModel(
      id: data.id,
      prestamoId: data.prestamoId,
      codigo: data.codigo,
      montoTotal: data.montoTotal,
      montoMora: data.montoMora,
      montoInteres: data.montoInteres,
      montoCapital: data.montoCapital,
      fechaPago: data.fechaPago,
      cajaId: data.cajaId,
      metodoPago: data.metodoPago,
      referencia: data.referencia,
      observaciones: data.observaciones,
      fechaRegistro: data.fechaRegistro,
    );
  }

  PagosCompanion toCompanion() {
    return PagosCompanion.insert(
      prestamoId: prestamoId,
      codigo: codigo,
      montoTotal: montoTotal,
      montoMora: montoMora,
      montoInteres: montoInteres,
      montoCapital: montoCapital,
      fechaPago: fechaPago,
      cajaId: Value(cajaId),
      metodoPago: Value(metodoPago),
      referencia: Value(referencia),
      observaciones: Value(observaciones),
      fechaRegistro: fechaRegistro,
    );
  }
}

/// Modelo de DetallePago - Capa de Datos
class DetallePagoModel extends DetallePago {
  const DetallePagoModel({
    super.id,
    required super.pagoId,
    required super.cuotaId,
    required super.numeroCuota,
    required super.montoMora,
    required super.montoInteres,
    required super.montoCapital,
    required super.montoTotal,
    required super.fechaRegistro,
  });

  factory DetallePagoModel.fromEntity(DetallePago detalle) {
    return DetallePagoModel(
      id: detalle.id,
      pagoId: detalle.pagoId,
      cuotaId: detalle.cuotaId,
      numeroCuota: detalle.numeroCuota,
      montoMora: detalle.montoMora,
      montoInteres: detalle.montoInteres,
      montoCapital: detalle.montoCapital,
      montoTotal: detalle.montoTotal,
      fechaRegistro: detalle.fechaRegistro,
    );
  }

  factory DetallePagoModel.fromDrift(DetallePagoData data) {
    return DetallePagoModel(
      id: data.id,
      pagoId: data.pagoId,
      cuotaId: data.cuotaId,
      numeroCuota: data.numeroCuota,
      montoMora: data.montoMora,
      montoInteres: data.montoInteres,
      montoCapital: data.montoCapital,
      montoTotal: data.montoTotal,
      fechaRegistro: data.fechaRegistro,
    );
  }

  DetallePagosCompanion toCompanion() {
    return DetallePagosCompanion.insert(
      pagoId: pagoId,
      cuotaId: cuotaId,
      numeroCuota: numeroCuota,
      montoMora: montoMora,
      montoInteres: montoInteres,
      montoCapital: montoCapital,
      montoTotal: montoTotal,
      fechaRegistro: fechaRegistro,
    );
  }
}