import 'package:drift/drift.dart' as drift;
import '../../domain/entities/cuota.dart';
import '../../../../data/database/database.dart';

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

  // Convertir desde Drift a Modelo
  factory CuotaModel.fromDrift(Cuota cuotaData) {
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
      estado: cuotaData.estado,
      fechaPago: cuotaData.fechaPago,
      fechaRegistro: cuotaData.fechaRegistro,
    );
  }

  // Convertir a Companion para INSERT
  CuotasCompanion toCompanion() {
    return CuotasCompanion.insert(
      prestamoId: prestamoId,
      numeroCuota: numeroCuota,
      fechaVencimiento: fechaVencimiento,
      montoCuota: montoCuota,
      capital: capital,
      interes: interes,
      saldoPendiente: saldoPendiente,
      montoPagado: drift.Value(montoPagado),
      montoMora: drift.Value(montoMora),
      estado: estado.toStorageString(),
      fechaPago: drift.Value(fechaPago),
      fechaRegistro: drift.Value(fechaRegistro),
    );
  }

  // Convertir a Companion para UPDATE
  CuotasCompanion toCompanionForUpdate() {
    return CuotasCompanion(
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
      estado: drift.Value(estado.toStorageString()),
      fechaPago: drift.Value(fechaPago),
    );
  }

  // Copiar desde entidad
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
}