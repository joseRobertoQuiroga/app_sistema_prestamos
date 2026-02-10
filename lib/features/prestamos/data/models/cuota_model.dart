import 'package:drift/drift.dart' as drift;
import '../../domain/entities/cuota.dart';
import '../../../../core/database/database.dart' as db;

/// Modelo de Cuota - Capa de Datos
/// ✅ CORREGIDO: fromDrift recibe db.Cuota, no Cuota (entidad) ni CuotaData
class CuotaModel extends Cuota {
  const CuotaModel({
    super.id,
    required super.prestamoId,
    required super.numeroCuota,
    required super.fechaVencimiento,
    required super.montoCuota,
    required super.capital,
    required super.interes,
    required super.saldoPendiente,
    super.montoPagado = 0.0,
    super.montoMora = 0.0,
    required super.estado,
    super.fechaPago,
    required super.fechaRegistro,
  });

  /// Convertir desde Drift a Modelo
  factory CuotaModel.fromDrift(db.Cuota cuotaData) {
    return CuotaModel(
      id: cuotaData.id,
      prestamoId: cuotaData.prestamoId,
      numeroCuota: cuotaData.numeroCuota,
      fechaVencimiento: cuotaData.fechaVencimiento,
      montoCuota: cuotaData.montoCuota,
      capital: cuotaData.capital,
      interes: cuotaData.interes,
      saldoPendiente: cuotaData.saldoPendiente,
      montoPagado: cuotaData.montoPagado,
      montoMora: cuotaData.montoMora,
      // ✅ Convertir string de BD a enum EstadoCuota
      estado: _parseEstado(cuotaData.estado),
      fechaPago: cuotaData.fechaPago,
      fechaRegistro: cuotaData.fechaRegistro,
    );
  }

  /// Convertir a Companion para INSERT
  db.CuotasCompanion toCompanion() {
    return db.CuotasCompanion.insert(
      prestamoId: prestamoId,
      numeroCuota: numeroCuota,
      fechaVencimiento: fechaVencimiento,
      montoCuota: montoCuota,
      capital: capital,
      interes: interes,
      saldoPendiente: saldoPendiente,
      montoPagado: drift.Value(montoPagado),
      montoMora: drift.Value(montoMora),
      estado: _enumToString(estado),
      fechaPago: drift.Value(fechaPago),
      fechaRegistro: drift.Value(fechaRegistro),
    );
  }

  /// Convertir a Companion para UPDATE
  db.CuotasCompanion toCompanionForUpdate() {
    return db.CuotasCompanion(
      id: drift.Value(id!),
      prestamoId: drift.Value(prestamoId),
      numeroCuota: drift.Value(numeroCuota),
      fechaVencimiento: drift.Value(fechaVencimiento),
      montoCuota: drift.Value(montoCuota),
      capital: drift.Value(capital),
      interes: drift.Value(interes),
      saldoPendiente: drift.Value(saldoPendiente),
      montoPagado: drift.Value(montoPagado),
      montoMora: drift.Value(montoMora),
      estado: drift.Value(_enumToString(estado)),
      fechaPago: drift.Value(fechaPago),
      // fechaRegistro: no se actualiza
    );
  }

  /// Copiar desde entidad
  factory CuotaModel.fromEntity(Cuota cuota) {
    return CuotaModel(
      id: cuota.id,
      prestamoId: cuota.prestamoId,
      numeroCuota: cuota.numeroCuota,
      fechaVencimiento: cuota.fechaVencimiento,
      montoCuota: cuota.montoCuota,
      capital: cuota.capital,
      interes: cuota.interes,
      saldoPendiente: cuota.saldoPendiente,
      montoPagado: cuota.montoPagado,
      montoMora: cuota.montoMora,
      estado: cuota.estado,
      fechaPago: cuota.fechaPago,
      fechaRegistro: cuota.fechaRegistro,
    );
  }

  // --- Helpers ---

  static EstadoCuota _parseEstado(String value) {
    return EstadoCuota.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstadoCuota.pendiente,
    );
  }

  static String _enumToString(Object e) => e.toString().split('.').last;
}