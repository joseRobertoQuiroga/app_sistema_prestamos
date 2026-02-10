import 'package:drift/drift.dart';
import '../../domain/entities/pago.dart';
import '../../domain/entities/detalle_pago.dart';
import '../../../../core/database/database.dart' as db;

/// Modelo de Pago - Capa de Datos
/// ✅ CORREGIDO: Mapeo correcto con tabla Drift
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

  /// ✅ CORREGIDO: Mapea montoPago de Drift a montoTotal de entidad
  /// Usamos db.Pago porque la clase generada por Drift para la tabla Pagos se llama Pago
  /// y entra en conflicto con nuestra entidad Pago.
  factory PagoModel.fromDrift(db.Pago data) {
    return PagoModel(
      id: data.id,
      prestamoId: data.prestamoId,
      codigo: data.codigo,
      // ✅ DRIFT: montoPago → DOMAIN: montoTotal
      montoTotal: data.montoPago,
      montoMora: data.montoMora,
      montoInteres: data.montoInteres,
      montoCapital: data.montoCapital,
      fechaPago: data.fechaPago,
      cajaId: data.cajaId,
      metodoPago: data.metodoPago,
      // ✅ Drift no tiene campo 'referencia', usar observaciones
      referencia: null,
      observaciones: data.observaciones,
      fechaRegistro: data.fechaRegistro,
    );
  }

  /// ✅ CORREGIDO: Incluye clienteId requerido por Drift
  db.PagosCompanion toCompanion({required int clienteId}) {
    return db.PagosCompanion.insert(
      prestamoId: prestamoId,
      // ✅ Campo obligatorio que faltaba
      clienteId: clienteId,
      codigo: codigo,
      // ✅ DOMAIN: montoTotal → DRIFT: montoPago
      montoPago: montoTotal,
      montoMora: Value(montoMora),
      montoInteres: montoInteres,
      montoCapital: montoCapital,
      fechaPago: fechaPago,
      cajaId: cajaId ?? 1,
      metodoPago: metodoPago ?? 'EFECTIVO',
      observaciones: Value(observaciones),
      fechaRegistro: Value(fechaRegistro),
    );
  }
}

/// Modelo de DetallePago - Capa de Datos
/// ✅ CORREGIDO: Ajustado a estructura real de Drift
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

  /// ✅ CORREGIDO: Drift solo tiene montoAplicado y montoMora
  /// Los demás campos no están en la tabla
  factory DetallePagoModel.fromDrift(db.DetallePago data) {
    return DetallePagoModel(
      id: data.id,
      pagoId: data.pagoId,
      cuotaId: data.cuotaId,
      // ⚠️ Drift NO tiene numeroCuota en DetallePagos
      // Se debe obtener con JOIN o almacenar por separado
      numeroCuota: 0, // Placeholder
      // ✅ DRIFT: montoAplicado → DOMAIN: montoTotal
      montoTotal: data.montoAplicado,
      montoMora: data.montoMora,
      // ⚠️ Drift NO tiene estos campos separados
      montoInteres: 0, // Placeholder
      montoCapital: 0,  // Placeholder
      fechaRegistro: data.fechaRegistro,
    );
  }

  /// ✅ CORREGIDO: Drift solo guarda montoAplicado y montoMora
  db.DetallePagosCompanion toCompanion() {
    return db.DetallePagosCompanion.insert(
      pagoId: pagoId,
      cuotaId: cuotaId,
      // ✅ DOMAIN: montoTotal → DRIFT: montoAplicado
      montoAplicado: montoTotal,
      montoMora: Value(montoMora),
      fechaRegistro: Value(fechaRegistro),
    );
  }
}